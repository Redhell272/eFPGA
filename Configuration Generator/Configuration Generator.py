
import tkinter as tk
from tkinter import filedialog, ttk
from pathlib import Path
from collections import deque
import re


class CrossoutGridApp:
    def __init__(self, root: tk.Tk) -> None:
        self.root = root
        self.root.title("eFPGA Configuration Generator")
        self.root.minsize(640, 700)

        self.grid_rows = self.grid_cols = 0
        self.base_cell_size, self.base_padding = 8, 6
        self.zoom, self.min_zoom, self.max_zoom = 1.0, 0.1, 10.0
        self.cell_size, self.padding = 8, 6
        # Below this cell size (pixels) individual rectangles and symbols are
        # too small to be useful.  All item-creation paths bail out early,
        # keeping the canvas item count near-zero at overview zoom levels.
        self._lod_cell_size: float = 4.0
        self._draw_x = 0.0
        self._draw_y = 0.0
        self._last_routing_key: tuple | None = None
        self._last_impacted_cells: set[tuple[int, int]] = set()

        self.crossed_cells = set()
        self._compose_info: dict | None = None
        self.active_inputs = set()
        self._last_save_path: str | None = None
        self._drag_add: bool | None = None
        self._drag_visited: set = set()
        self._rendered_cells: dict[tuple[int, int], int] = {}
        self._rendered_points: dict[tuple[int, int], list[int]] = {}
        self._rendered_bridges: dict[tuple, int] = {}
        self._rendered_markers: dict[tuple, int] = {}
        self._rendered_range: tuple[int, int, int, int] = (0, 0, 0, 0)
        self._grid_lines_dirty: bool = True
        self._module_boundaries_drawn: bool = False
        self._viewport_job: str | None = None
        self._node_cells: dict[tuple[int, int], str] = {}  # built once per layout load

        self.layout_cells = []
        self.top_entries: set[tuple[int, int]] = set()
        self.bottom_entries: set[tuple[int, int]] = set()
        self.left_entries: set[tuple[int, int]] = set()
        self.right_entries: set[tuple[int, int]] = set()
        self.static_entries: set[tuple[str, int, int]] = set()
        self.bridge_entries: set[tuple] = set()
        self._bridge_cell_positions: set[tuple[int, int]] = set()
        self._left_entry_rows: set[int] = set()
        self._right_entry_rows: set[int] = set()
        self._top_entry_cols: set[int] = set()
        self._bottom_entry_cols: set[int] = set()

        self.default_color = "#f2f2f2"
        self.logic_cell_color = "#d8e8d0"
        self.row_col_highlight = "#b8e1ff"
        self.crossed_color = "#ffb3b3"
        self.input_highlight = "#b8e1ff"
        self.active_entry_color = "#d90f0f"
        self.grid_outline = "#4c4c4c"

        self._build_ui()
        self._apply_zoom()

    def _build_ui(self):
        controls = ttk.Frame(self.root, padding=(16, 12)); controls.pack(fill="x")
        ttk.Label(controls, text="Cols:").pack(side="left")
        self._n_var = tk.StringVar(value="2")
        ttk.Spinbox(controls, textvariable=self._n_var, from_=1, to=32, width=3).pack(side="left", padx=(4, 0))
        ttk.Label(controls, text="Rows:").pack(side="left", padx=(8, 0))
        self._m_var = tk.StringVar(value="2")
        ttk.Spinbox(controls, textvariable=self._m_var, from_=1, to=32, width=3).pack(side="left", padx=(4, 0))
        ttk.Button(controls, text="Build eFPGA", command=self._build_efpga).pack(side="left", padx=(10, 0))
        ttk.Button(controls, text="Clear", command=self._clear_crosses).pack(side="left", padx=(10, 0))
        ttk.Button(controls, text="Load Config", command=self._load_configuration).pack(side="left", padx=(10, 0))
        ttk.Button(controls, text="Save Config", command=self._save_configuration).pack(side="left", padx=(6, 0))
        ttk.Separator(controls, orient="vertical").pack(side="left", fill="y", padx=12)
        ttk.Button(controls, text="Zoom -", command=self._zoom_out).pack(side="left")
        ttk.Button(controls, text="Zoom +", command=self._zoom_in).pack(side="left", padx=(6, 0))
        ttk.Button(controls, text="Fit", command=self._fit_to_window).pack(side="left", padx=(6, 0))
        self.zoom_label_var = tk.StringVar(value=f"Zoom: {int(self.zoom * 100)}%")
        ttk.Label(controls, textvariable=self.zoom_label_var).pack(side="left", padx=(10, 0))
        self.layout_label_var = tk.StringVar(value="No layout loaded")
        self.info_var = tk.StringVar(value="No layout loaded")
        info_bar = ttk.Frame(self.root, padding=(16, 0, 16, 4)); info_bar.pack(fill="x")
        ttk.Label(info_bar, textvariable=self.info_var).pack(anchor="w")
        self.canvas_frame = ttk.Frame(self.root, padding=(16, 8, 16, 16)); self.canvas_frame.pack(fill="both", expand=True)
        self.grid_canvas = tk.Canvas(self.canvas_frame, bg="#f2f2f2", highlightthickness=0)
        self.grid_canvas.pack(fill="both", expand=True)
        self.grid_canvas.bind("<Button-1>", self._on_canvas_click)
        self.grid_canvas.bind("<B1-Motion>", self._on_canvas_drag)
        self.grid_canvas.bind("<ButtonRelease-1>", self._on_canvas_release)
        self.grid_canvas.bind("<Control-MouseWheel>", self._on_ctrl_mousewheel)
        self.grid_canvas.bind("<MouseWheel>", self._on_mousewheel)
        self.grid_canvas.bind("<Shift-MouseWheel>", self._on_shift_mousewheel)
        self.grid_canvas.bind("<ButtonPress-2>", self._on_pan_start)
        self.grid_canvas.bind("<B2-Motion>", self._on_pan_move)
        self.grid_canvas.bind("<Configure>", lambda _e: self._update_viewport())
        self.root.bind("<Control-plus>", lambda _e: self._zoom_in())
        self.root.bind("<Control-equal>", lambda _e: self._zoom_in())
        self.root.bind("<Control-minus>", lambda _e: self._zoom_out())
        self.root.bind("<Control-s>", lambda _e: self._save_configuration_quick())

    def _apply_zoom(self):
        self.cell_size = max(1.0, self.base_cell_size * self.zoom)
        self.padding = max(1.0, self.base_padding * self.zoom)
        self.zoom_label_var.set(f"Zoom: {int(self.zoom * 100)}%")

    def _zoom_in(self, pivot=None):
        cx = self.grid_canvas.canvasx(pivot.x) if pivot else None
        cy = self.grid_canvas.canvasy(pivot.y) if pivot else None
        old_zoom = self.zoom; old_draw_x = self._draw_x; old_draw_y = self._draw_y
        self.zoom = min(self.max_zoom, self.zoom * 1.2)
        self._apply_zoom(); self._build_grid()
        if pivot:
            self._scroll_to_pivot(cx, cy, old_draw_x, old_draw_y, old_zoom, pivot.x, pivot.y)
        self._do_update_viewport()

    def _zoom_out(self, pivot=None):
        cx = self.grid_canvas.canvasx(pivot.x) if pivot else None
        cy = self.grid_canvas.canvasy(pivot.y) if pivot else None
        old_zoom = self.zoom; old_draw_x = self._draw_x; old_draw_y = self._draw_y
        self.zoom = max(self.min_zoom, self.zoom / 1.2)
        self._apply_zoom(); self._build_grid()
        if pivot:
            self._scroll_to_pivot(cx, cy, old_draw_x, old_draw_y, old_zoom, pivot.x, pivot.y)
        self._do_update_viewport()

    def _scroll_to_pivot(self, old_cx, old_cy, old_draw_x, old_draw_y, old_zoom, screen_x, screen_y):
        ratio = self.zoom / old_zoom
        new_cx = self._draw_x + (old_cx - old_draw_x) * ratio
        new_cy = self._draw_y + (old_cy - old_draw_y) * ratio
        edge_margin = self.cell_size
        grid_w = self.grid_cols * self.cell_size
        grid_h = self.grid_rows * self.cell_size
        vw = max(1.0, self.grid_canvas.winfo_width())
        vh = max(1.0, self.grid_canvas.winfo_height())
        total_w = grid_w + 2 * self._draw_x
        total_h = grid_h + 2 * self._draw_y
        # extra_x must satisfy both the anti-off-screen limit and the pivot requirement.
        # Tkinter clamps xview_moveto to [0, 1 - vw/sr_w], so the right-side constraint needs + vw.
        extra_x = max(edge_margin, vw - total_w,
                      screen_x - new_cx + edge_margin,
                      new_cx - screen_x - total_w + vw + edge_margin)
        extra_y = max(edge_margin, vh - total_h,
                      screen_y - new_cy + edge_margin,
                      new_cy - screen_y - total_h + vh + edge_margin)
        self.grid_canvas.config(scrollregion=(-extra_x, -extra_y, total_w + extra_x, total_h + extra_y))
        sr_w = total_w + 2 * extra_x
        sr_h = total_h + 2 * extra_y
        if sr_w <= 0 or sr_h <= 0:
            return
        fx = max(0.0, min(1.0, (new_cx - screen_x + extra_x) / sr_w))
        fy = max(0.0, min(1.0, (new_cy - screen_y + extra_y) / sr_h))
        self.grid_canvas.xview_moveto(fx)
        self.grid_canvas.yview_moveto(fy)

    def _fit_to_window(self):
        self.root.update_idletasks()
        w = max(300, self.canvas_frame.winfo_width() - 20)
        h = max(260, self.canvas_frame.winfo_height() - 20)
        if self.grid_cols <= 0 or self.grid_rows <= 0: return
        cell = max(8, min(w / self.grid_cols, h / self.grid_rows) - 2)
        self.zoom = min(self.max_zoom, max(self.min_zoom, cell / self.base_cell_size))
        self._apply_zoom(); self._build_grid()
        self._do_update_viewport()

    def _on_ctrl_mousewheel(self, event):
        if event.delta > 0: self._zoom_in(pivot=event)
        elif event.delta < 0: self._zoom_out(pivot=event)

    def _on_mousewheel(self, event):
        self.grid_canvas.yview_scroll(int(-1 * (event.delta / 120)), "units")
        self._update_viewport()

    def _on_shift_mousewheel(self, event):
        self.grid_canvas.xview_scroll(int(-1 * (event.delta / 120)), "units")
        self._update_viewport()

    def _on_pan_start(self, event):
        self.grid_canvas.scan_mark(event.x, event.y)

    def _on_pan_move(self, event):
        self.grid_canvas.scan_dragto(event.x, event.y, gain=1)
        self._update_viewport()

    def _on_canvas_click(self, event):
        x, y = self.grid_canvas.canvasx(event.x), self.grid_canvas.canvasy(event.y)
        entry = self._entry_at_point(x, y)
        if entry: self._toggle_input(entry); return
        if x < self._draw_x or y < self._draw_y: return
        col, row = int((x - self._draw_x) // self.cell_size), int((y - self._draw_y) // self.cell_size)
        if 0 <= row < self.grid_rows and 0 <= col < self.grid_cols:
            key = (row, col)
            added = self._toggle_cell_quiet(row, col)
            if added is not None:
                self._drag_add = added
                self._drag_visited.add(key)
                self._draw_drag_preview(row, col, added)

    def _on_canvas_drag(self, event):
        if self._drag_add is None:
            return
        x, y = self.grid_canvas.canvasx(event.x), self.grid_canvas.canvasy(event.y)
        if x < self._draw_x or y < self._draw_y: return
        col, row = int((x - self._draw_x) // self.cell_size), int((y - self._draw_y) // self.cell_size)
        if not (0 <= row < self.grid_rows and 0 <= col < self.grid_cols): return
        key = (row, col)
        if key in self._drag_visited: return
        if not self.layout_cells or self.layout_cells[row][col] in ("", "o", "v", "+", "\\", "+\\"):
            return
        self._drag_visited.add(key)
        if self._drag_add:
            self.crossed_cells.add(key)
        else:
            self.crossed_cells.discard(key)
        self._draw_drag_preview(row, col, self._drag_add)

    def _on_canvas_release(self, event):
        if self._drag_add is not None:
            self._drag_add = None
            self._drag_visited.clear()
            self.grid_canvas.delete("drag_preview")
            self._refresh_colors()

    def _draw_drag_preview(self, row: int, col: int, adding: bool) -> None:
        cs = self.cell_size
        x0 = self._draw_x + col * cs
        y0 = self._draw_y + row * cs
        fill = self.crossed_color if adding else self.default_color
        self.grid_canvas.create_rectangle(
            x0, y0, x0 + cs, y0 + cs,
            fill=fill, outline=self.grid_outline, tags=("drag_preview", "cell"),
        )

    def _build_grid(self):
        self.grid_canvas.update_idletasks()
        vw = max(1.0, self.grid_canvas.winfo_width())
        vh = max(1.0, self.grid_canvas.winfo_height())
        self.grid_canvas.delete("all")
        self._rendered_cells.clear()
        self._rendered_points.clear()
        self._rendered_bridges.clear()
        self._rendered_markers.clear()
        self._last_routing_key = None
        self._last_impacted_cells = set()
        self._rendered_range = (-1, -1, -1, -1)
        self._grid_lines_dirty = True
        self._module_boundaries_drawn = False
        grid_w = self.grid_cols * self.cell_size
        grid_h = self.grid_rows * self.cell_size
        self._draw_x = self.padding
        self._draw_y = self.padding
        edge_margin = self.cell_size
        total_w = grid_w + 2 * self.padding
        total_h = grid_h + 2 * self.padding
        extra_x = max(edge_margin, vw - total_w)
        extra_y = max(edge_margin, vh - total_h)
        self.grid_canvas.config(scrollregion=(-extra_x, -extra_y, total_w + extra_x, total_h + extra_y))

    def _visible_cell_range(self, buffer: int = 5) -> tuple[int, int, int, int]:
        cs = self.cell_size
        dx, dy = self._draw_x, self._draw_y
        vx0 = self.grid_canvas.canvasx(0)
        vy0 = self.grid_canvas.canvasy(0)
        vx1 = self.grid_canvas.canvasx(self.grid_canvas.winfo_width())
        vy1 = self.grid_canvas.canvasy(self.grid_canvas.winfo_height())
        r0 = max(0, int((vy0 - dy) / cs) - buffer)
        r1 = min(self.grid_rows, int((vy1 - dy) / cs) + buffer + 1)
        c0 = max(0, int((vx0 - dx) / cs) - buffer)
        c1 = min(self.grid_cols, int((vx1 - dx) / cs) + buffer + 1)
        return r0, r1, c0, c1

    def _update_viewport(self) -> None:
        if self._viewport_job:
            self.root.after_cancel(self._viewport_job)
        self._viewport_job = self.root.after(40, self._do_update_viewport)

    def _do_update_viewport(self) -> None:
        self._viewport_job = None
        if not self.layout_cells:
            return
        r0, r1, c0, c1 = self._visible_cell_range()
        new_range = (r0, r1, c0, c1)

        if new_range == self._rendered_range:
            return

        old_r0, old_r1, old_c0, old_c1 = self._rendered_range
        first_render = (old_r0 == -1)

        def _add_cell(r: int, c: int) -> None:
            if (r, c) in self._rendered_cells:
                return
            token = self.layout_cells[r][c]
            if token in ("", "o", "v", "+", "\\", "+\\"):
                return
            if self.cell_size < self._lod_cell_size:
                return
            if token not in ("l", "r"):
                return
            x0 = self._draw_x + c * self.cell_size
            y0 = self._draw_y + r * self.cell_size
            self._rendered_cells[(r, c)] = self.grid_canvas.create_rectangle(
                x0, y0, x0 + self.cell_size, y0 + self.cell_size,
                fill=self.logic_cell_color, outline="",
                tags=(f"cell_{r}_{c}", "cell", "cell_logic"),
            )

        def _evict_cell(r: int, c: int) -> None:
            if (r, c) in self._rendered_cells:
                self.grid_canvas.delete(self._rendered_cells.pop((r, c)))
            if (r, c) in self._rendered_points:
                for id_ in self._rendered_points.pop((r, c)):
                    self.grid_canvas.delete(id_)

        if first_render:
            for r in range(r0, r1):
                for c in range(c0, c1):
                    _add_cell(r, c)
        else:
            overlap_r0 = max(r0, old_r0)
            overlap_r1 = min(r1, old_r1)

            # Evict rows that left the viewport
            for r in range(old_r0, min(old_r1, r0)):
                for c in range(old_c0, old_c1):
                    _evict_cell(r, c)
            for r in range(max(old_r0, r1), old_r1):
                for c in range(old_c0, old_c1):
                    _evict_cell(r, c)
            # Evict cols that left (only within still-visible rows)
            if overlap_r0 < overlap_r1:
                for r in range(overlap_r0, overlap_r1):
                    for c in range(old_c0, min(old_c1, c0)):
                        _evict_cell(r, c)
                    for c in range(max(old_c0, c1), old_c1):
                        _evict_cell(r, c)

            # Add newly visible rows
            for r in range(r0, min(old_r0, r1)):
                for c in range(c0, c1):
                    _add_cell(r, c)
            for r in range(max(old_r1, r0), r1):
                for c in range(c0, c1):
                    _add_cell(r, c)
            # Add newly visible cols (only within already-visible rows)
            if overlap_r0 < overlap_r1:
                for r in range(overlap_r0, overlap_r1):
                    for c in range(c0, min(old_c0, c1)):
                        _add_cell(r, c)
                    for c in range(max(old_c1, c0), c1):
                        _add_cell(r, c)

        self._rendered_range = new_range
        if self._grid_lines_dirty:
            self._draw_grid_lines()
            self._grid_lines_dirty = False
        self._refresh_colors()

    def _draw_grid_lines(self) -> None:
        """Draw grid lines for the entire layout once. Called once per zoom/load,
        not on every scroll, so the full-grid scan cost is paid only when needed."""
        self.grid_canvas.delete("grid_frame")
        if not self.layout_cells:
            return
        r0, r1, c0, c1 = 0, self.grid_rows, 0, self.grid_cols
        cs = self.cell_size
        dx, dy = self._draw_x, self._draw_y

        def is_drawn(r: int, c: int) -> bool:
            return (0 <= r < self.grid_rows and 0 <= c < self.grid_cols
                    and self.layout_cells[r][c] not in ("", "o", "v", "+", "\\", "+\\"))

        for r in range(r0, r1 + 1):
            y = dy + r * cs
            c = c0
            while c < c1:
                if is_drawn(r - 1, c) or is_drawn(r, c):
                    start = c
                    while c < c1 and (is_drawn(r - 1, c) or is_drawn(r, c)):
                        c += 1
                    self.grid_canvas.create_line(
                        dx + start * cs, y, dx + c * cs, y,
                        fill=self.grid_outline, width=1, tags="grid_frame",
                    )
                else:
                    c += 1

        for col in range(c0, c1 + 1):
            x = dx + col * cs
            r = r0
            while r < r1:
                if is_drawn(r, col - 1) or is_drawn(r, col):
                    start = r
                    while r < r1 and (is_drawn(r, col - 1) or is_drawn(r, col)):
                        r += 1
                    self.grid_canvas.create_line(
                        x, dy + start * cs, x, dy + r * cs,
                        fill=self.grid_outline, width=1, tags="grid_frame",
                    )
                else:
                    r += 1

    def _toggle_cell(self, row, col):
        if self.layout_cells and self.layout_cells[row][col] in ("", "o", "v", "+", "\\", "+\\"): return
        key = (row, col)
        if key in self.crossed_cells: self.crossed_cells.remove(key)
        else: self.crossed_cells.add(key)
        self._refresh_colors()

    def _toggle_cell_quiet(self, row, col):
        """Toggle a cell without refreshing. Returns True if added, False if removed, None if not configurable."""
        if self.layout_cells and self.layout_cells[row][col] in ("", "o", "v", "+", "\\", "+\\"):
            return None
        key = (row, col)
        if key in self.crossed_cells:
            self.crossed_cells.remove(key)
            return False
        else:
            self.crossed_cells.add(key)
            return True

    def _toggle_input(self, entry):
        if entry in self.active_inputs: self.active_inputs.remove(entry)
        else: self.active_inputs.add(entry)
        self._refresh_colors()

    def _clear_crosses(self):
        self.crossed_cells.clear()
        self.active_inputs.clear()
        self._last_save_path = None
        self._refresh_colors()

    def _save_configuration(self) -> None:
        """Always prompt for a save location, then save."""
        if not self._compose_info or not self.layout_cells:
            self.info_var.set("No eFPGA loaded. Build one first.")
            return
        path_str = filedialog.asksaveasfilename(
            title="Save configuration",
            defaultextension=".txt",
            filetypes=[("Text files", "*.txt"), ("All files", "*.*")],
            initialfile=Path(self._last_save_path).name if self._last_save_path else None,
        )
        if not path_str:
            return
        self._last_save_path = path_str
        self._do_save(path_str)

    def _save_configuration_quick(self) -> None:
        """Save to the last used path, or prompt if never saved."""
        if not self._compose_info or not self.layout_cells:
            self.info_var.set("No eFPGA loaded. Build one first.")
            return
        if self._last_save_path:
            self._do_save(self._last_save_path)
        else:
            self._save_configuration()

    def _do_save(self, path_str: str) -> None:
        """Write .txt and .data configuration files to the given path."""
        n = self._compose_info["n_cols"]
        m = self._compose_info["n_rows"]
        modules = self._compose_info["modules"]
        configs = self._compose_info["configs"]
        configurable = {"x", "y", "l", "r"}

        def module_type(mi: int, mj: int) -> str:
            if mi % 2 == 0:
                return "CB" if mj % 2 == 0 else "CBH"
            return "CBV" if mj % 2 == 0 else "LS"

        m_rows_total = 2 * m + 1
        m_cols_total = 2 * n + 1

        row_offsets = [0] * m_rows_total
        col_offsets = [0] * m_cols_total
        acc = 0
        for mi in range(m_rows_total):
            row_offsets[mi] = acc
            acc += len(modules["CB" if mi % 2 == 0 else "CBV"]["cells"])
        acc = 0
        for mj in range(m_cols_total):
            col_offsets[mj] = acc
            key = "CB" if mj % 2 == 0 else "CBH"
            cells = modules[key]["cells"]
            acc += len(cells[0]) if cells else 0

        # Build column-major config→layout mapping for each module type.
        # Scan both grids column-by-column; skip non-configurable layout cells and
        # '.' config cells.  The i-th surviving position in each list maps to the other.
        config_to_layout: dict[str, dict[tuple[int, int], tuple[int, int]]] = {}
        for mtype in ("CB", "CBH", "CBV", "LS"):
            mod_cells = modules[mtype]["cells"]
            mod_cfg   = configs[mtype]
            lh = len(mod_cells);  lw = len(mod_cells[0]) if mod_cells else 0
            ch = len(mod_cfg);    cw = len(mod_cfg[0])   if mod_cfg   else 0
            layout_pos = [
                (r, c)
                for c in range(lw)
                for r in range(lh)
                if mod_cells[r][c] in configurable
            ]
            config_pos = [
                (r, c)
                for c in range(cw)
                for r in range(ch)
                if mod_cfg[r][c] != "."
            ]
            if len(layout_pos) != len(config_pos):
                self.info_var.set(
                    f"Config/layout cell count mismatch for {mtype}: "
                    f"{len(layout_pos)} layout vs {len(config_pos)} config cells."
                )
                return
            config_to_layout[mtype] = dict(zip(config_pos, layout_pos))

        all_entries = sorted(
            [("left",   r, c) for r, c in self.left_entries] +
            [("right",  r, c) for r, c in self.right_entries] +
            [("top",    r, c) for r, c in self.top_entries] +
            [("bottom", r, c) for r, c in self.bottom_entries]
        )
        inputs_mask = sum(
            (1 << i) for i, e in enumerate(all_entries) if e in self.active_inputs
        )

        lines = [
            f"# eFPGA {n}x{m} Configuration",
            "# Cell values: 1 = set, 0 = not set, . = pad (not a config bit)",
            f"# Active inputs: {hex(inputs_mask)}",
            "",
        ]
        bitstream_bits: list[str] = []

        type_idx: dict[str, int] = {"CB": 0, "CBH": 0, "CBV": 0, "LS": 0}
        for mi in range(m_rows_total):
            for mj in range(m_cols_total):
                mtype = module_type(mi, mj)
                idx = type_idx[mtype]
                type_idx[mtype] += 1
                mod_cfg = configs[mtype]
                cfg_h = len(mod_cfg)
                cfg_w = len(mod_cfg[0]) if mod_cfg else 0
                mapping = config_to_layout[mtype]
                row_off = row_offsets[mi]
                col_off = col_offsets[mj]
                lines.append(f"{mtype}{idx}")
                for cr in range(cfg_h):
                    row_vals: list[str] = []
                    for cc in range(cfg_w):
                        if mod_cfg[cr][cc] == ".":
                            row_vals.append(".")
                        else:
                            lr, lc = mapping[(cr, cc)]
                            row_vals.append(
                                "1" if (row_off + lr, col_off + lc) in self.crossed_cells else "0"
                            )
                    lines.append(" ".join(row_vals))
                lines.append("")
                # Bitstream: column-major scan, '.' treated as 0
                for cc in range(cfg_w):
                    for cr in range(cfg_h):
                        tok = mod_cfg[cr][cc]
                        if tok == ".":
                            bitstream_bits.append("0")
                        else:
                            lr, lc = mapping[(cr, cc)]
                            bitstream_bits.append(
                                "1" if (row_off + lr, col_off + lc) in self.crossed_cells else "0"
                            )

        Path(path_str).write_text("\n".join(lines), encoding="utf-8")

        # Pad bitstream to a multiple of 32 and write .data file
        remainder = len(bitstream_bits) % 32
        if remainder:
            bitstream_bits.extend(["0"] * (32 - remainder))
        data_lines = [
            "".join(reversed(bitstream_bits[i : i + 32]))
            for i in range(0, len(bitstream_bits), 32)
        ]
        data_path = Path(path_str).with_suffix(".data")
        data_path.write_text("\n".join(data_lines), encoding="utf-8")

        self.info_var.set(
            f"Configuration written to {Path(path_str).name} and {data_path.name}"
        )

    def _load_configuration(self) -> None:
        """Load a .data bitstream file and restore crossed_cells."""
        if not self._compose_info or not self.layout_cells:
            self.info_var.set("No eFPGA loaded. Build one first.")
            return
        path_str = filedialog.askopenfilename(
            title="Load configuration",
            filetypes=[("Data files", "*.data"), ("All files", "*.*")],
        )
        if not path_str:
            return

        # Read bitstream: un-reverse each 32-bit word to recover collection order
        raw_lines = Path(path_str).read_text(encoding="utf-8").splitlines()
        bitstream_bits: list[str] = []
        for line in raw_lines:
            line = line.strip()
            if not line:
                continue
            if len(line) != 32 or not all(c in "01" for c in line):
                self.info_var.set("Invalid .data file format.")
                return
            bitstream_bits.extend(reversed(line))

        n = self._compose_info["n_cols"]
        m = self._compose_info["n_rows"]
        modules = self._compose_info["modules"]
        configs = self._compose_info["configs"]
        configurable = {"x", "y", "l", "r"}

        def module_type(mi: int, mj: int) -> str:
            if mi % 2 == 0:
                return "CB" if mj % 2 == 0 else "CBH"
            return "CBV" if mj % 2 == 0 else "LS"

        m_rows_total = 2 * m + 1
        m_cols_total = 2 * n + 1

        row_offsets = [0] * m_rows_total
        col_offsets = [0] * m_cols_total
        acc = 0
        for mi in range(m_rows_total):
            row_offsets[mi] = acc
            acc += len(modules["CB" if mi % 2 == 0 else "CBV"]["cells"])
        acc = 0
        for mj in range(m_cols_total):
            col_offsets[mj] = acc
            key = "CB" if mj % 2 == 0 else "CBH"
            cells = modules[key]["cells"]
            acc += len(cells[0]) if cells else 0

        # Rebuild column-major config→layout mapping
        config_to_layout: dict[str, dict[tuple[int, int], tuple[int, int]]] = {}
        for mtype in ("CB", "CBH", "CBV", "LS"):
            mod_cells = modules[mtype]["cells"]
            mod_cfg   = configs[mtype]
            lh = len(mod_cells);  lw = len(mod_cells[0]) if mod_cells else 0
            ch = len(mod_cfg);    cw = len(mod_cfg[0])   if mod_cfg   else 0
            layout_pos = [
                (r, c)
                for c in range(lw)
                for r in range(lh)
                if mod_cells[r][c] in configurable
            ]
            config_pos = [
                (r, c)
                for c in range(cw)
                for r in range(ch)
                if mod_cfg[r][c] != "."
            ]
            config_to_layout[mtype] = dict(zip(config_pos, layout_pos))

        # Decode bitstream back into crossed_cells
        bit_idx = 0
        new_crossed: set[tuple[int, int]] = set()
        for mi in range(m_rows_total):
            for mj in range(m_cols_total):
                mtype = module_type(mi, mj)
                mod_cfg = configs[mtype]
                cfg_h = len(mod_cfg)
                cfg_w = len(mod_cfg[0]) if mod_cfg else 0
                mapping = config_to_layout[mtype]
                row_off = row_offsets[mi]
                col_off = col_offsets[mj]
                for cc in range(cfg_w):
                    for cr in range(cfg_h):
                        if bit_idx >= len(bitstream_bits):
                            self.info_var.set("Bitstream too short for this eFPGA configuration.")
                            return
                        bit = bitstream_bits[bit_idx]
                        bit_idx += 1
                        if mod_cfg[cr][cc] != "." and bit == "1":
                            lr, lc = mapping[(cr, cc)]
                            new_crossed.add((row_off + lr, col_off + lc))

        self.crossed_cells = new_crossed

        # Restore active inputs from companion .txt file
        new_active: set = set()
        txt_path = Path(path_str).with_suffix(".txt")
        if txt_path.exists():
            all_entries = sorted(
                [("left",   r, c) for r, c in self.left_entries] +
                [("right",  r, c) for r, c in self.right_entries] +
                [("top",    r, c) for r, c in self.top_entries] +
                [("bottom", r, c) for r, c in self.bottom_entries]
            )
            for line in txt_path.read_text(encoding="utf-8").splitlines():
                if line.startswith("# Active inputs:"):
                    try:
                        mask = int(line.split(":", 1)[1].strip(), 0)
                        new_active = {
                            e for i, e in enumerate(all_entries) if mask & (1 << i)
                        }
                    except ValueError:
                        pass
                    break
        self.active_inputs = new_active
        self._last_save_path = None
        self._refresh_colors()
        self.info_var.set(f"Configuration loaded from {Path(path_str).name}")

    def _refresh_colors(self, update_routing: bool = True) -> None:
        routing_key = (frozenset(self.active_inputs), frozenset(self.crossed_cells))
        prev_routing_key = self._last_routing_key
        if update_routing and routing_key != self._last_routing_key:
            self._last_impacted_cells = self._active_input_cells()
            self._last_routing_key = routing_key
            redraw_routing = True
        else:
            redraw_routing = False
        impacted_cells = self._last_impacted_cells

        # Compute which rows/cols are highlighted by a crossed cell.
        highlight_sources = {
            (r, c)
            for r, c in self.crossed_cells
            if not self.layout_cells or self.layout_cells[r][c] not in {"x", "y", "v", "o", "l", "r"}
        }
        highlighted_rows = {r for r, _ in highlight_sources}
        highlighted_cols = {c for _, c in highlight_sources}

        if redraw_routing:
            self._draw_layout_lines(prev_routing_key)
            if self.grid_canvas.find_withtag("layout_line"):
                self.grid_canvas.tag_lower("module_boundary", "layout_line")

        # Always rebuild highlight overlays so panning into new areas shows the
        # correct colours for impacted/crossed cells (viewport bounds change on pan
        # even when no new logic-cell rects are created).
        self.grid_canvas.delete("hl_overlay")
        cs = self.cell_size
        dx, dy = self._draw_x, self._draw_y
        gw = self.grid_cols * cs
        gh = self.grid_rows * cs
        r0_vp, r1_vp, c0_vp, c1_vp = self._rendered_range
        for r in highlighted_rows:
            self.grid_canvas.create_rectangle(
                dx, dy + r * cs, dx + gw, dy + (r + 1) * cs,
                fill=self.row_col_highlight, outline="", tags=("hl_overlay", "cell"),
            )
        for c in highlighted_cols:
            self.grid_canvas.create_rectangle(
                dx + c * cs, dy, dx + (c + 1) * cs, dy + gh,
                fill=self.row_col_highlight, outline="", tags=("hl_overlay", "cell"),
            )
        for (r, c) in impacted_cells:
            if r0_vp <= r < r1_vp and c0_vp <= c < c1_vp:
                token = self.layout_cells[r][c] if self.layout_cells else ""
                if token not in ("", "o", "v", "+", "\\", "+\\", "l", "r"):
                    self.grid_canvas.create_rectangle(
                        dx + c * cs, dy + r * cs,
                        dx + (c + 1) * cs, dy + (r + 1) * cs,
                        fill=self.input_highlight, outline="", tags=("hl_overlay", "cell"),
                    )
        for (r, c) in self.crossed_cells:
            if r0_vp <= r < r1_vp and c0_vp <= c < c1_vp:
                token = self.layout_cells[r][c] if self.layout_cells else ""
                if token not in ("", "o", "v", "+", "\\", "+\\"):
                    self.grid_canvas.create_rectangle(
                        dx + c * cs, dy + r * cs,
                        dx + (c + 1) * cs, dy + (r + 1) * cs,
                        fill=self.crossed_color, outline="", tags=("hl_overlay", "cell"),
                    )

        # Keep routing lines below cell items (overlays just created above).
        if self.grid_canvas.find_withtag("layout_line") and self.grid_canvas.find_withtag("cell"):
            self.grid_canvas.tag_lower("layout_line", "cell")

        r0, r1, c0, c1 = self._rendered_range
        self._draw_layout_points(impacted_cells, r0, r1, c0, c1, force_redraw=redraw_routing)
        self._draw_entry_markers(force_redraw=redraw_routing)
        self.grid_canvas.tag_raise("grid_frame")
        self.grid_canvas.tag_raise("layout_point")
        self.grid_canvas.tag_raise("layout_entry")

        count = len(self.crossed_cells)
        active_inputs = len(self.active_inputs)
        self.info_var.set(
            f"{self.layout_label_var.get()} | Crossed out: {count} | Active inputs: {active_inputs}"
        )

    def _active_input_cells(self) -> set[tuple[int, int]]:
        impacted_cells: set[tuple[int, int]] = set()
        for entry in self.active_inputs:
            _, cells = self._trace_active_entry(entry)
            impacted_cells.update(cells)
        return impacted_cells

    def _draw_layout_points(self, impacted: set[tuple[int, int]] | None = None,
                            r0: int = 0, r1: int = -1, c0: int = 0, c1: int = -1,
                            force_redraw: bool = False) -> bool:
        """Returns True if any new canvas items were created."""
        if not self.layout_cells:
            return False
        if self.cell_size < self._lod_cell_size:
            return False  # symbols invisible at this zoom; skip all item creation
        if r1 < 0: r1 = self.grid_rows
        if c1 < 0: c1 = self.grid_cols

        if force_redraw:
            for ids in self._rendered_points.values():
                for id_ in ids:
                    self.grid_canvas.delete(id_)
            self._rendered_points.clear()
        else:
            # Evict stale items not already removed by the delta cell eviction.
            to_remove = [k for k in self._rendered_points if not (r0 <= k[0] < r1 and c0 <= k[1] < c1)]
            for k in to_remove:
                for id_ in self._rendered_points.pop(k):
                    self.grid_canvas.delete(id_)

        # Iterate only pre-indexed node cells instead of scanning the full visible
        # range — O(n_nodes) rather than O(visible_rows * visible_cols).
        added = False
        for (r, c), token in self._node_cells.items():
            if not (r0 <= r < r1 and c0 <= c < c1):
                continue
            if (r, c) in self._rendered_points:
                continue
            ids: list[int] = []
            if token == "y":
                ids = self._draw_y_node(r, c)
            elif token == "v":
                ids = self._draw_v_node(r, c, active=(impacted is not None and (r, c) in impacted))
            elif token == "o":
                ids = self._draw_o_node(r, c, active=(impacted is not None and (r, c) in impacted))
            elif token == "+":
                ids = self._draw_plus_node(r, c)
            elif token == "\\":
                ids = self._draw_cut_node(r, c)
            elif token == "+\\":
                ids = self._draw_plus_node(r, c) + self._draw_cut_node(r, c)
            if ids:
                self._rendered_points[(r, c)] = ids
                added = True

        bridge_added = self._draw_bridge_entries(r0, r1, c0, c1, impacted=impacted, force_redraw=force_redraw)
        return added or bridge_added

    def _draw_cut_node(self, row: int, col: int) -> list[int]:
        cx, cy = self._cell_center(row, col)
        arm = self.cell_size * 0.22
        w = max(1, int(self.cell_size * 0.07))
        id_ = self.grid_canvas.create_line(cx - arm, cy - arm, cx + arm, cy + arm, fill="#cc2222", width=w, tags=("layout_point",))
        return [id_]

    def _draw_plus_node(self, row: int, col: int) -> list[int]:
        cx, cy = self._cell_center(row, col)
        arm = self.cell_size * 0.22
        w = max(1, int(self.cell_size * 0.07))
        id1 = self.grid_canvas.create_line(cx - arm, cy, cx + arm, cy, fill="#555555", width=w, tags=("layout_point",))
        id2 = self.grid_canvas.create_line(cx, cy - arm, cx, cy + arm, fill="#555555", width=w, tags=("layout_point",))
        return [id1, id2]

    def _draw_y_node(self, row: int, col: int) -> list[int]:
        cx, cy = self._cell_center(row, col)
        radius = self.cell_size * 0.12
        color = "#0c7d4b" if (row, col) not in self.crossed_cells else "#a23a3a"
        id_ = self.grid_canvas.create_oval(
            cx - radius, cy - radius, cx + radius, cy + radius,
            fill=color, outline="", tags=("layout_point",),
        )
        return [id_]

    def _draw_v_node(self, row: int, col: int, active: bool = False) -> list[int]:
        cx, cy = self._cell_center(row, col)
        r = self.cell_size * 0.30
        fill = self.input_highlight if active else self.default_color
        outline_w = max(1, int(self.cell_size * 0.08))
        points = [cx, cy - r, cx + r, cy, cx, cy + r, cx - r, cy]
        id_ = self.grid_canvas.create_polygon(
            points, fill=fill, outline="#1a6fa8", width=outline_w,
            tags=("layout_point",),
        )
        return [id_]

    def _draw_o_node(self, row: int, col: int, active: bool = False) -> list[int]:
        cx, cy = self._cell_center(row, col)
        r = max(2.0, self.cell_size * 0.33)
        fill = "#d90f0f" if active else "#f2f2f2"
        id_ = self.grid_canvas.create_oval(
            cx - r, cy - r, cx + r, cy + r,
            fill=fill, outline="#2f2f2f", width=max(1, int(self.cell_size * 0.08)),
            tags=("layout_point",),
        )
        return [id_]

    def _draw_bridge_entries(self, r0: int = 0, r1: int = -1,
                              c0: int = 0, c1: int = -1,
                              impacted=None, force_redraw: bool = False) -> bool:
        """Returns True if any new bridge items were created."""
        if not self.bridge_entries:
            return False
        if self.cell_size < self._lod_cell_size:
            return False  # bridge pills invisible at this zoom
        if r1 < 0:
            r1 = self.grid_rows
        if c1 < 0:
            c1 = self.grid_cols

        if force_redraw:
            for id_ in self._rendered_bridges.values():
                self.grid_canvas.delete(id_)
            self._rendered_bridges.clear()
        else:
            # Evict bridges that scrolled out of view
            to_remove = []
            for key, id_ in self._rendered_bridges.items():
                if key[0] == "h":
                    _, row, col1, _col2 = key
                    if not (r0 <= row < r1 and c0 <= col1 < c1):
                        to_remove.append(key)
                else:
                    _, row1, _row2, col = key
                    if not (r0 <= row1 < r1 and c0 <= col < c1):
                        to_remove.append(key)
            for key in to_remove:
                self.grid_canvas.delete(self._rendered_bridges.pop(key))

        half = max(2.0, self.cell_size * 0.33)
        added = False
        for entry in self.bridge_entries:
            if entry in self._rendered_bridges:
                continue
            if entry[0] == "h":
                _, row, col1, col2 = entry
                if r0 <= row < r1 and c0 <= col1 < c1:
                    x1, y  = self._cell_center(row, col1)
                    x2, _y = self._cell_center(row, col2)
                    active = impacted is not None and (
                        (row, col1) in impacted or (row, col2) in impacted
                    )
                    fill = "#d90f0f" if active else "#f2f2f2"
                    self._rendered_bridges[entry] = self.grid_canvas.create_oval(
                        x1 - half, y - half, x2 + half, y + half,
                        fill=fill, outline="#2f2f2f",
                        width=max(1, int(self.cell_size * 0.08)),
                        tags=("layout_point",),
                    )
                    added = True
            elif entry[0] == "v":
                _, row1, row2, col = entry
                if r0 <= row1 < r1 and c0 <= col < c1:
                    x,  y1 = self._cell_center(row1, col)
                    _x, y2 = self._cell_center(row2, col)
                    active = impacted is not None and (
                        (row1, col) in impacted or (row2, col) in impacted
                    )
                    fill = "#d90f0f" if active else "#f2f2f2"
                    self._rendered_bridges[entry] = self.grid_canvas.create_oval(
                        x - half, y1 - half, x + half, y2 + half,
                        fill=fill, outline="#2f2f2f",
                        width=max(1, int(self.cell_size * 0.08)),
                        tags=("layout_point",),
                    )
                    added = True
        return added

    def _build_bridge_positions(self) -> set[tuple[int, int]]:
        """Return the set of all (row, col) cells that are part of a bridge entry."""
        pos: set[tuple[int, int]] = set()
        for e in self.bridge_entries:
            if e[0] == "h":
                pos.add((e[1], e[2]))
                pos.add((e[1], e[3]))
            else:  # "v"
                pos.add((e[1], e[3]))
                pos.add((e[2], e[3]))
        return pos

    def _build_cell_index(self) -> None:
        """Pre-index node cells once per layout load so _draw_layout_points can
        iterate only drawable symbols rather than scanning the entire grid."""
        node_tokens = {"y", "v", "o", "+", "\\", "+\\"}
        self._node_cells = {
            (r, c): tok
            for r, row in enumerate(self.layout_cells)
            for c, tok in enumerate(row)
            if tok in node_tokens
        }

    def _draw_module_boundaries(self) -> None:
        """Draw short tick marks along internal module boundary seams.
        Each tick is centred in its cell and has a fixed 3-pixel half-length
        so it never changes size when zooming."""
        if not self.bridge_entries:
            return
        v_seams: set[int] = set()
        h_seams: set[int] = set()
        for e in self.bridge_entries:
            if e[0] == "h":
                v_seams.add(e[3])
            else:
                h_seams.add(e[2])
        cs = self.cell_size
        tick = min(3.0, cs * 0.45)   # 3 px fixed; shrink gracefully for tiny cells
        for col2 in v_seams:
            x = self._draw_x + col2 * cs
            for row in range(self.grid_rows):
                cy = self._draw_y + (row + 0.5) * cs
                self.grid_canvas.create_line(
                    x, cy - tick, x, cy + tick,
                    fill="#2f2f2f", width=1, tags=("module_boundary",),
                )
        for row2 in h_seams:
            y = self._draw_y + row2 * cs
            for col in range(self.grid_cols):
                cx = self._draw_x + (col + 0.5) * cs
                self.grid_canvas.create_line(
                    cx - tick, y, cx + tick, y,
                    fill="#2f2f2f", width=1, tags=("module_boundary",),
                )

    def _draw_layout_lines(self, prev_routing_key: tuple | None = None) -> None:
        if not self.layout_cells:
            return
        # Module boundaries are layout-static — draw once per build, not on every
        # routing change.
        if not self._module_boundaries_drawn:
            self._draw_module_boundaries()
            self._module_boundaries_drawn = True

        all_entries = (
            [("left",   r, c) for r, c in self.left_entries] +
            [("right",  r, c) for r, c in self.right_entries] +
            [("top",    r, c) for r, c in self.top_entries] +
            [("bottom", r, c) for r, c in self.bottom_entries]
        )

        full_redraw = prev_routing_key is None
        if full_redraw:
            prev_active: frozenset = frozenset()
            crossed_changed = True
        else:
            prev_active = prev_routing_key[0]
            crossed_changed = frozenset(self.crossed_cells) != prev_routing_key[1]

        for entry in all_entries:
            in_curr = entry in self.active_inputs
            in_prev = entry in prev_active
            if full_redraw:
                needs_redraw = True
            elif in_curr != in_prev:
                needs_redraw = True  # entry changed active/inactive state
            elif crossed_changed and in_curr:
                needs_redraw = True  # active entry BFS may change with crossed_cells
            else:
                needs_redraw = False

            if not needs_redraw:
                continue
            side, r, c = entry
            entry_tag = f"eline_{side[0]}_{r}_{c}"
            self.grid_canvas.delete(entry_tag)
            self._draw_entry_route(entry, entry_tag)

        # Raise active entry lines above inactive ones so they always render on top.
        # tag_lower("layout_line", "cell") in _refresh_colors then keeps everything
        # below cell rectangles.
        for entry in all_entries:
            if entry in self.active_inputs:
                side, r, c = entry
                self.grid_canvas.tag_raise(f"eline_{side[0]}_{r}_{c}")

    def _draw_entry_route(self, entry: tuple[str, int, int], entry_tag: str) -> None:
        if entry in self.active_inputs:
            paths, _ = self._trace_active_entry(entry)
            for path in paths:
                self._draw_path(path, active=True, entry_tag=entry_tag)
            return

        # Inactive entry: scan inward for the first non-empty cell.
        # Draw to it only if it is a + node; otherwise draw a 1-cell stub.
        side, primary, secondary = entry
        dr, dc = {"left": (0, 1), "right": (0, -1), "top": (1, 0), "bottom": (-1, 0)}[side]
        r, c = primary, secondary
        limit = max(self.grid_rows, self.grid_cols)
        found_step = None
        first_token = None
        for step in range(1, limit + 1):
            nr, nc = r + dr * step, c + dc * step
            if not (0 <= nr < self.grid_rows and 0 <= nc < self.grid_cols):
                break
            first_token = self.layout_cells[nr][nc]
            if first_token != "":
                if first_token in ("+", "+\\"):
                    found_step = step
                break
        if found_step is not None:
            end_step = found_step
        elif first_token in ("x", "y"):
            # Draw stub only to the cell boundary (midpoint between centres) so
            # the line stops at the grid edge and doesn't enter the bare cell.
            cx0, cy0 = self._cell_center(r, c)
            cx1, cy1 = self._cell_center(r + dr, c + dc)
            self._draw_path([(cx0, cy0), ((cx0 + cx1) / 2, (cy0 + cy1) / 2)],
                            active=False, entry_tag=entry_tag)
            return
        else:
            end_step = 1
        path = [self._cell_center(r, c)]
        for step in range(1, end_step + 1):
            path.append(self._cell_center(r + dr * step, c + dc * step))
        self._draw_path(path, active=False, entry_tag=entry_tag)

    def _trace_straight_entry(
        self, entry: tuple[str, int, int]
    ) -> tuple[list[tuple[float, float]], list[tuple[int, int]]]:
        side, primary, secondary = entry
        path: list[tuple[float, float]] = []
        cells: list[tuple[int, int]] = []

        if side == "left":
            positions = [(primary, col) for col in range(secondary, self.grid_cols)]
        elif side == "right":
            positions = [(primary, col) for col in range(secondary, -1, -1)]
        elif side == "top":
            positions = [(row, secondary) for row in range(primary, self.grid_rows)]
        elif side == "bottom":
            positions = [(row, secondary) for row in range(primary, -1, -1)]
        else:
            return path, cells

        pending_path: list[tuple[float, float]] = []
        for row, col in positions:
            if not self._is_passable(row, col):
                break
            if self.layout_cells[row][col] == "y" and (row, col) not in self.crossed_cells:
                break
            if self.layout_cells[row][col] == "o":
                break
            if self.layout_cells[row][col] in ("\\", "+\\"):
                break
            if self.layout_cells[row][col] in ("l", "r"):
                path.extend(pending_path)
                pending_path.clear()
                cells.append((row, col))
                path.append(self._cell_center(row, col))
                break
            if self.layout_cells[row][col] == "":
                pending_path.append(self._cell_center(row, col))
            else:
                path.extend(pending_path)
                pending_path.clear()
                cells.append((row, col))
                path.append(self._cell_center(row, col))
        # pending_path (trailing blank cells) is intentionally discarded

        return path, cells

    def _trace_active_entry(
        self, entry: tuple[str, int, int]
    ) -> tuple[list[list[tuple[float, float]]], set[tuple[int, int]]]:
        start_point, initial_state = self._entry_state(entry)
        if start_point is None or initial_state is None:
            return [], set()

        queue: deque[tuple[tuple[int, int], tuple[int, int], int, int]] = deque([initial_state])
        seen_states: set[tuple[tuple[int, int], tuple[int, int], int, int]] = set()
        impacted_cells: set[tuple[int, int]] = set()
        segments: list[list[tuple[float, float]]] = []

        while queue:
            (row, col), direction, horizontal_dc, vertical_dr = queue.popleft()
            state = ((row, col), direction, horizontal_dc, vertical_dr)
            if state in seen_states:
                continue
            seen_states.add(state)

            dr, dc = direction
            next_row = row + dr
            next_col = col + dc
            if not self._is_passable(next_row, next_col):
                continue

            token = self.layout_cells[next_row][next_col]
            if token == "y" and (next_row, next_col) not in self.crossed_cells:
                continue

            if 0 <= row < self.grid_rows and 0 <= col < self.grid_cols:
                start = self._cell_center(row, col)
            else:
                start = start_point
            end = self._cell_center(next_row, next_col)
            segments.append([start, end])
            if token != "" or (next_row, next_col) in self._bridge_cell_positions:
                impacted_cells.add((next_row, next_col))

            next_horizontal_dc = horizontal_dc
            next_vertical_dr = vertical_dr
            if dc != 0:
                next_horizontal_dc = dc
            if dr != 0:
                next_vertical_dr = dr

            next_directions = [direction]
            if token in ("o", "\\") or token in ("l", "r"):
                next_directions = []
            elif token == "x" and (next_row, next_col) in self.crossed_cells:
                branch_direction = self._branch_direction_for_cross(next_row, next_col, direction)
                if self._is_valid_branch(next_row, next_col, branch_direction):
                    next_directions.append(branch_direction)
            elif token in ("+", "+\\"):
                dr_in, dc_in = direction
                perp_dirs = [(-1, 0), (1, 0)] if dc_in != 0 else [(0, -1), (0, 1)]
                for perp in perp_dirs:
                    if self._is_valid_branch(next_row, next_col, perp):
                        next_directions.append(perp)
                if token == "+\\":
                    next_directions = [d for d in next_directions if d != direction]

            for next_direction in next_directions:
                queue.append(((next_row, next_col), next_direction, next_horizontal_dc, next_vertical_dr))

        return self._trim_trailing_blank_segments(segments), impacted_cells

    def _branch_direction_for_cross(self, row: int, col: int, direction: tuple[int, int]) -> tuple[int, int]:
        dr, dc = direction
        if dc != 0:
            return self._vertical_flow_direction(col)
        return self._horizontal_flow_direction(row)

    def _trim_trailing_blank_segments(
        self, segments: list[list[tuple[float, float]]]
    ) -> list[list[tuple[float, float]]]:
        """Iteratively remove segments whose endpoint is a blank cell with no outgoing segment."""
        def to_rc(pt: tuple[float, float]) -> tuple[int, int]:
            x, y = pt
            col = round((x - self._draw_x - self.cell_size / 2) / self.cell_size)
            row = round((y - self._draw_y - self.cell_size / 2) / self.cell_size)
            return row, col

        def is_blank(rc: tuple[int, int]) -> bool:
            r, c = rc
            return 0 <= r < self.grid_rows and 0 <= c < self.grid_cols and self.layout_cells[r][c] == ""

        changed = True
        while changed:
            changed = False
            start_rcs = {to_rc(seg[0]) for seg in segments}
            kept = []
            for seg in segments:
                if is_blank(to_rc(seg[1])) and to_rc(seg[1]) not in start_rcs:
                    changed = True
                else:
                    kept.append(seg)
            segments = kept
        return segments

    def _vertical_flow_direction(self, col: int) -> tuple[int, int]:
        if col in self._top_entry_cols:
            return (1, 0)
        if col in self._bottom_entry_cols:
            return (-1, 0)
        return (1, 0)

    def _horizontal_flow_direction(self, row: int) -> tuple[int, int]:
        if row in self._left_entry_rows:
            return (0, 1)
        if row in self._right_entry_rows:
            return (0, -1)
        return (0, 1)

    def _is_valid_branch(self, row: int, col: int, direction: tuple[int, int]) -> bool:
        next_row = row + direction[0]
        next_col = col + direction[1]
        if not self._is_passable(next_row, next_col):
            return False
        if self.layout_cells[next_row][next_col] == "y" and (next_row, next_col) not in self.crossed_cells:
            return False
        return True

    def _entry_state(
        self, entry: tuple[str, int, int]
    ) -> tuple[tuple[float, float] | None, tuple[tuple[int, int], tuple[int, int], int, int] | None]:
        side, primary, secondary = entry
        if side == "left":
            return self._cell_center(primary, secondary), ((primary, secondary), (0, 1), 1, 0)
        if side == "right":
            return self._cell_center(primary, secondary), ((primary, secondary), (0, -1), -1, 0)
        if side == "top":
            return self._cell_center(primary, secondary), ((primary, secondary), (1, 0), 0, 1)
        if side == "bottom":
            return self._cell_center(primary, secondary), ((primary, secondary), (-1, 0), 0, -1)
        return None, None

    def _draw_path(self, path: list[tuple[float, float]], active: bool = False,
                   entry_tag: str | None = None) -> None:
        if len(path) < 2:
            return
        flat_points: list[float] = []
        for x, y in path:
            flat_points.extend([x, y])
        tags = ("layout_line", entry_tag) if entry_tag is not None else ("layout_line",)
        self.grid_canvas.create_line(
            *flat_points,
            fill=self.active_entry_color if active else "#2f2f2f",
            width=2.8 if active else 2.3,
            capstyle=tk.ROUND,
            tags=tags,
        )

    def _draw_entry_markers(self, force_redraw: bool = False) -> bool:
        """Returns True if any new marker items were created."""
        if self.cell_size < self._lod_cell_size:
            return False  # markers invisible at this zoom
        r0, r1, c0, c1 = self._rendered_range
        # Extra margin so markers drawn just outside the grid edge are still included
        er0, er1, ec0, ec1 = r0 - 2, r1 + 2, c0 - 2, c1 + 2

        if force_redraw:
            for id_ in self._rendered_markers.values():
                self.grid_canvas.delete(id_)
            self._rendered_markers.clear()
        else:
            # Evict markers that scrolled out of view.
            # Regular entry keys: (side, row, col)  → indices [1], [2]
            # Static entry keys:  ("s", side, row, col) → indices [2], [3]
            to_remove = [k for k in self._rendered_markers
                         if not ((er0 <= k[2] < er1 and ec0 <= k[3] < ec1) if len(k) == 4
                                 else (er0 <= k[1] < er1 and ec0 <= k[2] < ec1))]
            for k in to_remove:
                self.grid_canvas.delete(self._rendered_markers.pop(k))

        radius = max(2.0, self.cell_size * 0.33)
        added = False
        for row, start_col in self.left_entries:
            key = ("left", row, start_col)
            if er0 <= row < er1 and ec0 <= start_col < ec1 and key not in self._rendered_markers:
                self._rendered_markers[key] = self._draw_entry_marker_at(key, self._cell_center(row, start_col), radius)
                added = True
        for row, start_col in self.right_entries:
            key = ("right", row, start_col)
            if er0 <= row < er1 and ec0 <= start_col < ec1 and key not in self._rendered_markers:
                self._rendered_markers[key] = self._draw_entry_marker_at(key, self._cell_center(row, start_col), radius)
                added = True
        for start_row, col in self.top_entries:
            key = ("top", start_row, col)
            if er0 <= start_row < er1 and ec0 <= col < ec1 and key not in self._rendered_markers:
                self._rendered_markers[key] = self._draw_entry_marker_at(key, self._cell_center(start_row, col), radius)
                added = True
        for start_row, col in self.bottom_entries:
            key = ("bottom", start_row, col)
            if er0 <= start_row < er1 and ec0 <= col < ec1 and key not in self._rendered_markers:
                self._rendered_markers[key] = self._draw_entry_marker_at(key, self._cell_center(start_row, col), radius)
                added = True

        # Static (non-interactive) logic input markers — drawn as small grey squares
        s_radius = max(2.0, self.cell_size * 0.22)
        for side, primary, secondary in self.static_entries:
            key = ("s", side, primary, secondary)
            if er0 <= primary < er1 and ec0 <= secondary < ec1 and key not in self._rendered_markers:
                cx, cy = self._cell_center(primary, secondary)
                self._rendered_markers[key] = self.grid_canvas.create_rectangle(
                    cx - s_radius, cy - s_radius,
                    cx + s_radius, cy + s_radius,
                    fill="#888888",
                    outline="",
                    tags=("layout_entry",),
                )
                added = True
        return added

    def _draw_entry_marker_at(
        self, entry: tuple[str, int, int], point: tuple[float, float], radius: float
    ) -> int:
        x, y = point
        return self.grid_canvas.create_oval(
            x - radius,
            y - radius,
            x + radius,
            y + radius,
            fill=self.active_entry_color if entry in self.active_inputs else "#2f2f2f",
            outline="",
            tags=("layout_entry",),
        )

    def _entry_at_point(self, x: float, y: float) -> tuple[str, int, int] | None:
        radius = max(2.0, self.cell_size * 0.33)
        radius_sq = radius * radius

        for row, start_col in self.left_entries:
            if self._point_in_radius(x, y, self._cell_center(row, start_col), radius_sq):
                return ("left", row, start_col)
        for row, start_col in self.right_entries:
            if self._point_in_radius(x, y, self._cell_center(row, start_col), radius_sq):
                return ("right", row, start_col)
        for start_row, col in self.top_entries:
            if self._point_in_radius(x, y, self._cell_center(start_row, col), radius_sq):
                return ("top", start_row, col)
        for start_row, col in self.bottom_entries:
            if self._point_in_radius(x, y, self._cell_center(start_row, col), radius_sq):
                return ("bottom", start_row, col)
        return None

    def _point_in_radius(
        self, x: float, y: float, center: tuple[float, float], radius_sq: float
    ) -> bool:
        center_x, center_y = center
        dx = x - center_x
        dy = y - center_y
        return dx * dx + dy * dy <= radius_sq

    def _is_passable(self, row: int, col: int) -> bool:
        if row < 0 or row >= self.grid_rows or col < 0 or col >= self.grid_cols:
            return False
        return self.layout_cells[row][col] in {"x", "y", "v", "o", "+", "\\", "+\\", "l", "r", ""}

    def _cell_center(self, row: int, col: int) -> tuple[float, float]:
        x = self._draw_x + col * self.cell_size + self.cell_size / 2
        y = self._draw_y + row * self.cell_size + self.cell_size / 2
        return x, y

    def _edge_point_left(self, row: int) -> tuple[float, float]:
        _, y = self._cell_center(row, 0)
        return self._draw_x - self.cell_size * 0.75, y

    def _edge_point_right(self, row: int) -> tuple[float, float]:
        _, y = self._cell_center(row, self.grid_cols - 1)
        x = self._draw_x + self.grid_cols * self.cell_size + self.cell_size * 0.75
        return x, y

    def _edge_point_top(self, col: int) -> tuple[float, float]:
        x, _ = self._cell_center(0, col)
        return x, self._draw_y - self.cell_size * 0.75

    def _edge_point_bottom(self, col: int) -> tuple[float, float]:
        x, _ = self._cell_center(self.grid_rows - 1, col)
        y = self._draw_y + self.grid_rows * self.cell_size + self.cell_size * 0.75
        return x, y

    def _build_efpga(self) -> None:
        """Build eFPGA directly from the toolbar N/M spinboxes."""
        try:
            n = int(self._n_var.get())
            m = int(self._m_var.get())
            if n < 1 or m < 1:
                raise ValueError("Columns and Rows must each be at least 1.")
        except ValueError as exc:
            self.info_var.set(f"Error: {exc}")
            return
        folder = Path(__file__).parent
        module_files = {
            "CB":  folder / "crossbar.layout",
            "CBH": folder / "H_crossbar.layout",
            "CBV": folder / "V_crossbar.layout",
            "LS":  folder / "logic_slice.layout",
        }
        missing = [k for k, p in module_files.items() if not p.exists()]
        if missing:
            self.info_var.set(f"Missing layout files: {', '.join(missing)}")
            return
        try:
            modules = {key: self._parse_layout(path) for key, path in module_files.items()}
        except ValueError as exc:
            self.info_var.set(f"Parse error: {exc}")
            return
        config_files = {
            "CB":  folder / "crossbar.config",
            "CBH": folder / "H_crossbar.config",
            "CBV": folder / "V_crossbar.config",
            "LS":  folder / "logic_slice.config",
        }
        missing_cfg = [k for k, p in config_files.items() if not p.exists()]
        if missing_cfg:
            self.info_var.set(f"Missing config files: {', '.join(missing_cfg)}")
            return
        configs = {key: self._parse_config(path) for key, path in config_files.items()}
        composed = self._compose_efpga(n, m, modules)
        self._compose_info = {"n_cols": n, "n_rows": m, "modules": modules, "configs": configs}
        self._last_save_path = None
        self._load_composed_layout(composed, f"eFPGA {n}\u00d7{m}")

    def _compose_efpga(
        self, n_cols: int, n_rows: int, modules: dict
    ) -> dict:
        """
        Compose an N-columns x M-rows (of Logic Slices) eFPGA from the four
        parsed module dicts keyed 'CB', 'CBH', 'CBV', 'LS'.

        Tiling pattern for a 3x2 eFPGA:
          CB  CBH CB  CBH CB  CBH CB
          CBV LS  CBV LS  CBV LS  CBV
          CB  CBH CB  CBH CB  CBH CB
          CBV LS  CBV LS  CBV LS  CBV
          CB  CBH CB  CBH CB  CBH CB
        """
        def module_type(mi: int, mj: int) -> str:
            if mi % 2 == 0:
                return "CB" if mj % 2 == 0 else "CBH"
            return "CBV" if mj % 2 == 0 else "LS"

        m_rows_total = 2 * n_rows + 1
        m_cols_total = 2 * n_cols + 1

        # Height of each module row (CB/CBH rows share CB height; CBV/LS rows share CBV height)
        def row_height(mi: int) -> int:
            key = "CB" if mi % 2 == 0 else "CBV"
            return len(modules[key]["cells"])

        # Width of each module column (CB/CBV cols share CB width; CBH/LS cols share CBH width)
        def col_width(mj: int) -> int:
            key = "CB" if mj % 2 == 0 else "CBH"
            cells = modules[key]["cells"]
            return len(cells[0]) if cells else 0

        row_heights = [row_height(mi) for mi in range(m_rows_total)]
        col_widths  = [col_width(mj)  for mj in range(m_cols_total)]
        row_offsets = [sum(row_heights[:i]) for i in range(m_rows_total)]
        col_offsets = [sum(col_widths[:j])  for j in range(m_cols_total)]
        total_rows  = sum(row_heights)
        total_cols  = sum(col_widths)

        composed: list[list[str]] = [["" ] * total_cols for _ in range(total_rows)]
        top_entries:    set[tuple[int, int]]       = set()
        bottom_entries: set[tuple[int, int]]       = set()
        left_entries:   set[tuple[int, int]]       = set()
        right_entries:  set[tuple[int, int]]       = set()
        static_entries: set[tuple[str, int, int]]  = set()

        for mi in range(m_rows_total):
            for mj in range(m_cols_total):
                mtype   = module_type(mi, mj)
                mod     = modules[mtype]
                row_off = row_offsets[mi]
                col_off = col_offsets[mj]

                for r, row in enumerate(mod["cells"]):
                    for c, token in enumerate(row):
                        if token:
                            composed[row_off + r][col_off + c] = token

                for r, c in mod["top_entries"]:
                    top_entries.add((row_off + r, col_off + c))
                for r, c in mod["bottom_entries"]:
                    bottom_entries.add((row_off + r, col_off + c))
                for r, c in mod["left_entries"]:
                    left_entries.add((row_off + r, col_off + c))
                for r, c in mod["right_entries"]:
                    right_entries.add((row_off + r, col_off + c))
                for side, r, c in mod["static_entries"]:
                    static_entries.add((side, row_off + r, col_off + c))

        # At every internal column boundary, 'o' cells on either facing side would
        # stop traces before they cross into the adjacent module.  Replace them with
        # "" so both trace functions pass through transparently.
        for mj in range(m_cols_total - 1):          # each internal vertical seam
            left_col  = col_offsets[mj + 1] - 1     # rightmost col of left module
            right_col = col_offsets[mj + 1]          # leftmost col of right module
            for r in range(total_rows):
                if composed[r][left_col]  == "o":
                    composed[r][left_col]  = ""
                if composed[r][right_col] == "o":
                    composed[r][right_col] = ""

        for mi in range(m_rows_total - 1):           # each internal horizontal seam
            top_row = row_offsets[mi + 1] - 1        # bottommost row of top module
            bot_row = row_offsets[mi + 1]             # topmost row of bottom module
            for c in range(total_cols):
                if composed[top_row][c] == "o":
                    composed[top_row][c] = ""
                if composed[bot_row][c] == "o":
                    composed[bot_row][c] = ""

        # Demote entries at internal module boundaries from the selectable sets into
        # bridge_entries.  These represent fixed wire connections, not clickable I/Os.
        bridge_entries: set[tuple] = set()

        for mj in range(m_cols_total - 1):
            left_col  = col_offsets[mj + 1] - 1
            right_col = col_offsets[mj + 1]
            # Gather entries facing across this seam and remove them.
            internal: set[tuple[int, int]] = (
                {(r, c) for r, c in right_entries if c == left_col} |
                {(r, c) for r, c in left_entries  if c == right_col}
            )
            right_entries -= {(r, c) for r, c in right_entries if c == left_col}
            left_entries  -= {(r, c) for r, c in left_entries  if c == right_col}
            # Also demote static entries (logic-cell inputs) sitting on these cols.
            sb = {(s, r, c) for s, r, c in static_entries
                  if c in (left_col, right_col) and s in ("left", "right")}
            static_entries -= sb
            internal |= {(r, c) for s, r, c in sb}
            for r, _ in internal:
                bridge_entries.add(("h", r, left_col, right_col))

        for mi in range(m_rows_total - 1):
            top_row = row_offsets[mi + 1] - 1
            bot_row = row_offsets[mi + 1]
            internal = (
                {(r, c) for r, c in bottom_entries if r == top_row} |
                {(r, c) for r, c in top_entries    if r == bot_row}
            )
            bottom_entries -= {(r, c) for r, c in bottom_entries if r == top_row}
            top_entries    -= {(r, c) for r, c in top_entries    if r == bot_row}
            sb = {(s, r, c) for s, r, c in static_entries
                  if r in (top_row, bot_row) and s in ("top", "bottom")}
            static_entries -= sb
            internal |= {(r, c) for s, r, c in sb}
            for _, c in internal:
                bridge_entries.add(("v", top_row, bot_row, c))

        return {
            "cells":          composed,
            "top_entries":    top_entries,
            "bottom_entries": bottom_entries,
            "left_entries":   left_entries,
            "right_entries":  right_entries,
            "static_entries": static_entries,
            "bridge_entries": bridge_entries,
        }

    def _load_composed_layout(self, parsed: dict, label: str) -> None:
        """Load a pre-parsed/composed layout dict (no file on disk)."""
        self.layout_cells   = parsed["cells"]
        self.grid_rows      = len(self.layout_cells)
        self.grid_cols      = len(self.layout_cells[0]) if self.layout_cells else 0
        self.top_entries    = parsed["top_entries"]
        self.bottom_entries = parsed["bottom_entries"]
        self.left_entries   = parsed["left_entries"]
        self.right_entries  = parsed["right_entries"]
        self.static_entries = parsed["static_entries"]
        self._left_entry_rows   = {r for r, _ in self.left_entries}
        self._right_entry_rows  = {r for r, _ in self.right_entries}
        self._top_entry_cols    = {c for _, c in self.top_entries}
        self._bottom_entry_cols = {c for _, c in self.bottom_entries}

        self.crossed_cells.clear()
        self.active_inputs.clear()
        self.bridge_entries = parsed.get("bridge_entries", set())
        self._bridge_cell_positions = self._build_bridge_positions()
        self.layout_label_var.set(f"Layout: {label}")
        self.info_var.set(self.layout_label_var.get())
        self._build_cell_index()
        self._build_grid()
        self._do_update_viewport()

    def _parse_config(self, path: Path) -> list[list[str]]:
        """Parse a .config file into a 2D grid of tokens ('x','y','l','r','.')."""
        valid = {"x", "y", "l", "r"}
        raw_lines = path.read_text(encoding="utf-8").splitlines()
        rows: list[list[str]] = []
        for line in raw_lines:
            if not line:
                continue
            if "\t" in line:
                tokens = [t.strip().lower() for t in line.split("\t")]
            else:
                tokens = [t.strip().lower() for t in re.split(r" +", line.strip())]
            rows.append(tokens)
        if not rows:
            return []
        width = max(len(r) for r in rows)
        padded = [row + ["."] * (width - len(row)) for row in rows]
        return [[tok if (tok in valid or tok == ".") else "." for tok in row] for row in padded]

    def _parse_layout(self, path: Path) -> dict[str, object]:
        raw_lines = path.read_text(encoding="utf-8").splitlines()
        rows: list[list[str]] = []
        for line in raw_lines:
            # Keep empty columns when the file is tab-delimited; they carry layout meaning.
            # Only skip truly empty lines (no characters); tab-only lines are blank spacer rows.
            if not line:
                continue

            if "\t" in line:
                tokens = [token.strip().lower() for token in line.split("\t")]
            else:
                # Space-only fallback: split on runs of spaces.
                tokens = [token.strip().lower() for token in re.split(r" +", line.strip())]

            rows.append(tokens)

        if not rows:
            raise ValueError(f"Layout file {path.name} is empty.")

        width = max(len(row) for row in rows)
        padded_rows: list[list[str]] = [row + [""] * (width - len(row)) for row in rows]

        if not width:
            raise ValueError(f"Layout file {path.name} does not contain an interior grid.")

        cells = [[tok if tok in {"x", "y", "v", "o", "+", "\\", "+\\", "l", "r"} else "" for tok in row] for row in padded_rows]

        top_entries: set[tuple[int, int]] = set()
        bottom_entries: set[tuple[int, int]] = set()
        left_entries: set[tuple[int, int]] = set()
        right_entries: set[tuple[int, int]] = set()

        # Post-process: 'o' cells adjacent to 'l'/'r' are output entry markers.
        # The signal goes AWAY from the logic cell, so the entry direction is opposite to
        # the side where the l/r cell sits.
        n_rows = len(cells)
        n_cols = len(cells[0]) if cells else 0
        for r in range(n_rows):
            for c in range(n_cols):
                if cells[r][c] != "o":
                    continue
                below = cells[r + 1][c] if r + 1 < n_rows else ""
                above = cells[r - 1][c] if r > 0 else ""
                right = cells[r][c + 1] if c + 1 < n_cols else ""
                left  = cells[r][c - 1] if c > 0 else ""
                if below in ("l", "r"):
                    cells[r][c] = ""
                    bottom_entries.add((r, c))   # signal goes UP (away from logic cell below)
                elif above in ("l", "r"):
                    cells[r][c] = ""
                    top_entries.add((r, c))      # signal goes DOWN (away from logic cell above)
                elif right in ("l", "r"):
                    cells[r][c] = ""
                    right_entries.add((r, c))    # signal goes LEFT (away from logic cell right)
                elif left in ("l", "r"):
                    cells[r][c] = ""
                    left_entries.add((r, c))     # signal goes RIGHT (away from logic cell left)

        static_entries: set[tuple[str, int, int]] = set()

        # Horizontal entry markers: detect ALL '-' tokens in any row
        for r, row_tokens in enumerate(padded_rows):
            for c, tok in enumerate(row_tokens):
                if tok != "-":
                    continue
                if c == 0:
                    adj = row_tokens[c + 1] if c + 1 < width else ""
                    if adj in ("l", "r"):
                        static_entries.add(("left", r, 0))
                    else:
                        left_entries.add((r, 0))
                elif c == width - 1:
                    adj = row_tokens[c - 1]
                    if adj in ("l", "r"):
                        static_entries.add(("right", r, width - 1))
                    else:
                        right_entries.add((r, width - 1))
                else:
                    right_tok = row_tokens[c + 1]
                    left_tok = row_tokens[c - 1]
                    if right_tok not in ("", "-", "|"):
                        if right_tok in ("l", "r"):
                            static_entries.add(("left", r, c))
                        else:
                            left_entries.add((r, c))
                    elif left_tok not in ("", "-", "|"):
                        if left_tok in ("l", "r"):
                            static_entries.add(("right", r, c))
                        else:
                            right_entries.add((r, c))

        # Vertical entry markers: detect ALL '|' tokens in any row
        n_padded = len(padded_rows)
        for r, row_tokens in enumerate(padded_rows):
            for c, tok in enumerate(row_tokens):
                if tok != "|":
                    continue
                if r == 0:
                    adj = padded_rows[r + 1][c] if r + 1 < n_padded else ""
                    if adj in ("l", "r"):
                        static_entries.add(("top", 0, c))
                    else:
                        top_entries.add((0, c))
                elif r == n_padded - 1:
                    adj = padded_rows[r - 1][c]
                    if adj in ("l", "r"):
                        static_entries.add(("bottom", r, c))
                    else:
                        bottom_entries.add((r, c))
                else:
                    below_tok = padded_rows[r + 1][c]
                    above_tok = padded_rows[r - 1][c]
                    if below_tok not in ("", "-", "|"):
                        if below_tok in ("l", "r"):
                            static_entries.add(("top", r, c))
                        else:
                            top_entries.add((r, c))
                    elif above_tok not in ("", "-", "|"):
                        if above_tok in ("l", "r"):
                            static_entries.add(("bottom", r, c))
                        else:
                            bottom_entries.add((r, c))

        return {
            "cells": cells,
            "top_entries": top_entries,
            "bottom_entries": bottom_entries,
            "left_entries": left_entries,
            "right_entries": right_entries,
            "static_entries": static_entries,
        }


def main() -> None:
    root = tk.Tk()
    # Set a default ttk theme when available for cleaner controls on Windows.
    style = ttk.Style(root)
    if "clam" in style.theme_names():
        style.theme_use("clam")

    CrossoutGridApp(root)
    root.mainloop()


if __name__ == "__main__":
    main()