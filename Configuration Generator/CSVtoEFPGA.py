import csv

def csvData(file):
    path = "Configuration Generator/"
    line = 1
    data = []
    with open(path + file, newline='') as csvfile:
        csv_reader = csv.reader(csvfile)
        for row in csv_reader:
            if line > 1:
                data.append(row)
            else:
                cell = ascii(row[0])
                data.append(cell[13:len(cell)-1])
            line += 1
    return data



def LSdata(LS):
    data = []

    LUTs_prog = [["" for col in range(32)] for row in range(16)]
    out_prog_LO = ["" for row in range(12)]
    out_prog_right = ["" for row in range(12)]
    in_prog = ["" for row in range(12)]
    regs_prog = ["" for row in range(16)]
    ys_prog = ["" for row in range(12)]

    Y_prog = ["" for row in range(6)]
    X_prog = ["" for row in range(60)]
    REG_prog = ""
    LUT_prog = ["" for row in range(16)]

    i = 0
    r = 0
    for row in LS:
        if (i == 0):
            print(row)
            #data.append(row)
        elif (i < 9+r*11 and i > r*11):
            for ii in range(4):
                LUTs_prog[int((i-1) / 11)*4][32-(ii*8+i%11)] = row[66+ii]
                LUTs_prog[int((i-1) / 11)*4+1][32-(ii*8+i%11)] = row[44+ii]
                LUTs_prog[int((i-1) / 11)*4+2][32-(ii*8+i%11)] = row[22+ii]
                LUTs_prog[int((i-1) / 11)*4+3][32-(ii*8+i%11)] = row[0+ii]
            out_prog_right[int((i-1) / 11)*3] = out_prog_right[int((i-1) / 11)*3] + row[48] + row[49]
            out_prog_right[int((i-1) / 11)*3+1] = out_prog_right[int((i-1) / 11)*3+1] + row[26] + row[27]
            out_prog_right[int((i-1) / 11)*3+2] = out_prog_right[int((i-1) / 11)*3+2] + row[4] + row[5]
            prog = ""
            for col in row:
                prog = prog + col
            in_prog[int((i-1) / 11)*3] = in_prog[int((i-1) / 11)*3] + prog[50:66]
            in_prog[int((i-1) / 11)*3+1] = in_prog[int((i-1) / 11)*3+1] + prog[28:44]
            in_prog[int((i-1) / 11)*3+2] = in_prog[int((i-1) / 11)*3+2] + prog[6:22]

        elif (i == 9+r*11):
            prog = ""
            for col in row:
                prog = prog + col
            out_prog_LO[int((i-1) / 11)*3] = prog[16:24]
            out_prog_LO[int((i-1) / 11)*3+1] = prog[8:16]
            out_prog_LO[int((i-1) / 11)*3+2] = prog[0:8]
        elif (i == 10+r*11):
            prog = ""
            for col in row:
                prog = prog + col
            out_prog_LO[int((i-1) / 11)*3] = out_prog_LO[int((i-1) / 11)*3][0:2] + prog[16:18] + out_prog_LO[int((i-1) / 11)*3][2:10]
            out_prog_LO[int((i-1) / 11)*3] = out_prog_LO[int((i-1) / 11)*3] + prog[18:24]
            out_prog_LO[int((i-1) / 11)*3+1] = out_prog_LO[int((i-1) / 11)*3+1][0:2] + prog[8:10] + out_prog_LO[int((i-1) / 11)*3+1][2:10]
            out_prog_LO[int((i-1) / 11)*3+1] = out_prog_LO[int((i-1) / 11)*3+1] + prog[10:16]
            out_prog_LO[int((i-1) / 11)*3+2] = out_prog_LO[int((i-1) / 11)*3+2][0:2] + prog[0:2] + out_prog_LO[int((i-1) / 11)*3+2][2:10]
            out_prog_LO[int((i-1) / 11)*3+2] = out_prog_LO[int((i-1) / 11)*3+2] + prog[2:8]
        else:
            prog = ""
            for col in row:
                prog = prog + col
            regs_prog[int((i-1) / 11)*4] = prog[54:56]
            ys_prog[int((i-1) / 11)*3] = prog[38:54]
            regs_prog[int((i-1) / 11)*4+1] = prog[36:38]
            ys_prog[int((i-1) / 11)*3+1] = prog[20:36]
            regs_prog[int((i-1) / 11)*4+2] = prog[18:20]
            ys_prog[int((i-1) / 11)*3+2] = prog[2:18]
            regs_prog[int((i-1) / 11)*4+3] = prog[0:2]

            r += 1
        i += 1
    
    for i in range(16):
        prog = ""
        for col in LUTs_prog[i]:
            prog = prog + col
        LUT_prog[i] = prog
        REG_prog = regs_prog[i] + REG_prog

    prog = ""
    for i in range(12):
        prog = prog + out_prog_LO[11-i] + out_prog_right[11-i] + in_prog[11-i]
    for i in range(60):
        X_prog[i] = prog[(59-i)*32:(60-i)*32]
    for i in range(6):
        Y_prog[i] = ys_prog[i*2+1] + ys_prog[i*2]

    for row in LUT_prog:
       data.append(row)
    data.append(REG_prog)
    for row in X_prog:
       data.append(row)
    for row in Y_prog:
       data.append(row)

    return data



def ILdata(IL):
    data = []

    clk_prog = ""
    REGS_prog = ["", ""]
    LUT_prog = ["" for row in range(8)]

    i = 0
    for row in IL:
        if (i == 0):
            print(row)
            #data.append(row)
        else:
            clk_prog = row[0] + clk_prog
            REGS_prog[0] = row[2] + row[1] + REGS_prog[0]

            ii = (i-1) % 4
            if ii == 0:
                index = int((i-1)/4)
                for col in row[3:19]:
                    LUT_prog[index] = LUT_prog[index] + col
        i += 1

    REGS_prog[1] = REGS_prog[0][0:32]
    REGS_prog[0] = REGS_prog[0][32:64]

    data.append(clk_prog)
    data.append(REGS_prog[0])
    data.append(REGS_prog[1])
    for i in range(4):
        data.append(LUT_prog[i*2+1] + LUT_prog[i*2])

    return data



def CBdata(CB):
    data = []

    Y_prog_N = ""
    Y_prog_W = ""
    Y_prog_S = ""
    Y_prog_E = ""
    X_prog_NW = ["" for row in range(16)]
    X_prog_NE = ["" for row in range(32)]
    X_prog_SW = ["" for row in range(8)]
    X_prog_SE = ["" for row in range(16)]

    i = 0
    for row in CB:
        if (i == 0):
            print(row)
            #data.append(row)
        elif (i < 33):
            ii = 0
            for col in row:
                #col = "[" + str(i) + "," + str(ii) + "]"
                if ii < 16:
                    X_prog_NW[(i-1) >> 1] = X_prog_NW[(i-1) >> 1] + col
                elif ii == 16:
                    Y_prog_E = col + Y_prog_E
                else:
                    X_prog_NE[i-1] = X_prog_NE[i-1] + col
                ii += 1
            if (i % 2 == 0):
                X_prog_NW[(i-1) >> 1] = X_prog_NW[(i-1) >> 1][16:32] + X_prog_NW[(i-1) >> 1][0:16]
        elif (i == 33):
            ii = 0
            for col in row:
                #col = "[" + str(i) + "," + str(ii) + "]"
                if ii < 16:
                    Y_prog_N = Y_prog_N + col
                elif ii > 16:
                    Y_prog_S = Y_prog_S + col
                ii += 1
        else:
            ii = 0
            for col in row:
                #col = "[" + str(i) + "," + str(ii) + "]"
                if ii < 16:
                    X_prog_SW[(i-34) >> 1] = X_prog_SW[(i-34) >> 1] + col
                elif ii == 16:
                    Y_prog_W = col + Y_prog_W
                else:
                    X_prog_SE[i-34] = X_prog_SE[i-34] + col
                ii += 1
            if (i % 2 == 1):
                X_prog_SW[(i-34) >> 1] = X_prog_SW[(i-34) >> 1][16:32] + X_prog_SW[(i-34) >> 1][0:16]
        i += 1

    data.append(Y_prog_W + Y_prog_N)
    data.append(Y_prog_S)
    data.append(Y_prog_E)
    for row in X_prog_NW:
       data.append(row)
    for row in X_prog_NE:
       data.append(row)
    for row in X_prog_SW:
       data.append(row)
    for row in X_prog_SE:
       data.append(row)

    return data



def CBHdata(CBH):
    data = []

    X_prog_LB = ["", ""]
    Y_prog_0 = ""
    Y_prog_1 = ""
    Y_prog_2 = ""
    X_prog_W0 = ["" for row in range(16)]
    X_prog_E0 = ["" for row in range(8)]
    X_prog_W1 = ["" for row in range(16)]
    X_prog_E1 = ["" for row in range(8)]
    X_prog_W2 = ["" for row in range(16)]
    X_prog_E2 = ["" for row in range(8)]

    i = 0
    for row in CBH:
        if (i == 0):
            print(row)
            #data.append(row)
        elif (i < 33):
            ii = 0
            for col in row:
                #col = "[" + str(i) + "," + str(ii) + "]"
                if ii < 16:
                    X_prog_W2[(i-1) >> 1] = X_prog_W2[(i-1) >> 1] + col
                elif ii < 32:
                    X_prog_W1[(i-1) >> 1] = X_prog_W1[(i-1) >> 1] + col
                else:
                    X_prog_W0[(i-1) >> 1] = X_prog_W0[(i-1) >> 1] + col
                ii += 1
            if (i % 2 == 0):
                X_prog_W0[(i-1) >> 1] = X_prog_W0[(i-1) >> 1][16:32] + X_prog_W0[(i-1) >> 1][0:16]
                X_prog_W1[(i-1) >> 1] = X_prog_W1[(i-1) >> 1][16:32] + X_prog_W1[(i-1) >> 1][0:16]
                X_prog_W2[(i-1) >> 1] = X_prog_W2[(i-1) >> 1][16:32] + X_prog_W2[(i-1) >> 1][0:16]
        elif (i == 33):
            ii = 0
            for col in row:
                #col = "[" + str(i) + "," + str(ii) + "]"
                if ii < 16:
                    Y_prog_2 = Y_prog_2 + col
                elif ii < 32:
                    Y_prog_1 = Y_prog_1 + col
                else:
                    Y_prog_0 = Y_prog_0 + col
                ii += 1
        elif (i < 50):
            ii = 0
            for col in row:
                #col = "[" + str(i) + "," + str(ii) + "]"
                if ii < 16:
                    X_prog_E2[(i-34) >> 1] = X_prog_E2[(i-34) >> 1] + col
                elif ii < 32:
                    X_prog_E1[(i-34) >> 1] = X_prog_E1[(i-34) >> 1] + col
                else:
                    X_prog_E0[(i-34) >> 1] = X_prog_E0[(i-34) >> 1] + col
                ii += 1
            if (i % 2 == 1):
                X_prog_E0[(i-34) >> 1] = X_prog_E0[(i-34) >> 1][16:32] + X_prog_E0[(i-34) >> 1][0:16]
                X_prog_E1[(i-34) >> 1] = X_prog_E1[(i-34) >> 1][16:32] + X_prog_E1[(i-34) >> 1][0:16]
                X_prog_E2[(i-34) >> 1] = X_prog_E2[(i-34) >> 1][16:32] + X_prog_E2[(i-34) >> 1][0:16]
        else:
            ii = 0
            for col in row:
                #col = "[" + str(i) + "," + str(ii) + "]"
                if (ii > 5 and 16 > ii):
                    X_prog_LB[1] = X_prog_LB[1] + col
                elif (ii > 21 and 32 > ii):
                    X_prog_LB[0] = X_prog_LB[0] + col
                ii += 1
        i += 1

    X_prog_LB[0] = X_prog_LB[0][30:40] + X_prog_LB[0][20:30] + X_prog_LB[0][10:20] + X_prog_LB[0][0:10]
    X_prog_LB[1] = X_prog_LB[1][30:40] + X_prog_LB[1][20:30] + X_prog_LB[1][10:20] + X_prog_LB[1][0:10]

    data.append(X_prog_LB[0][8:40])
    data.append(X_prog_LB[1][16:40]+ X_prog_LB[0][0:8])
    data.append(Y_prog_0 + X_prog_LB[1][0:16])
    data.append(Y_prog_2 + Y_prog_1)
    for row in X_prog_W0:
       data.append(row)
    for row in X_prog_E0:
       data.append(row)
    for row in X_prog_W1:
       data.append(row)
    for row in X_prog_E1:
       data.append(row)
    for row in X_prog_W2:
       data.append(row)
    for row in X_prog_E2:
       data.append(row)

    return data



def CBVdata(CBV):
    data = []

    X_prog_LO_N = ["" for row in range(4)]
    X_prog_LO_S = [["", ""] for row in range(4)]
    X_prog_LO_D = [["", ""] for row in range(4)]
    X_prog_LI_N = [["" for col in range(4)] for row in range(4)]
    X_prog_LI_S = [["" for col in range(8)] for row in range(4)]

    i = 0
    for row in CBV:
        if (i == 0):
            print(row)
            #data.append(row)
        elif (((i-1) % 10) < 2):
            index = int((i-1)/10)
            ii = 0
            for col in row:
                #col = "[" + str(i) + "," + str(ii) + "]"
                if ii < 8:
                    col = ""
                elif ii < 24:
                    X_prog_LO_N[index] = X_prog_LO_N[index] + col
                else:
                    X_prog_LO_S[index][1 - (i-1) % 10] = X_prog_LO_S[index][1 - (i-1) % 10] + col
                ii += 1
            #if (i % 2 == 0):
            #    X_prog_LO_N[index] = X_prog_LO_N[index][16:32] + X_prog_LO_N[index][0:16]
        else:
            index = int((i-1)/10)
            ii = 0
            for col in row:
                #col = "[" + str(i) + "," + str(ii) + "]"
                if ii < 8:
                    X_prog_LO_D[index][((i-3) % 10) >> 2] = X_prog_LO_D[index][((i-3) % 10) >> 2] + col
                elif ii < 24:
                    X_prog_LI_N[index][((i-3) % 10) >> 1] = X_prog_LI_N[index][((i-3) % 10) >> 1] + col
                else:
                    X_prog_LI_S[index][(i-3) % 10] = X_prog_LI_S[index][(i-3) % 10] + col
                ii += 1
            if (i % 2 == 0):
                X_prog_LI_N[index][((i-3) % 10) >> 1] = X_prog_LI_N[index][((i-3) % 10) >> 1][16:32] + X_prog_LI_N[index][((i-3) % 10) >> 1][0:16]
            if (((i-3) % 10) == 3 or ((i-3) % 10) == 7):
                X_prog_LO_D[index][((i-3) % 10) >> 2] = X_prog_LO_D[index][((i-3) % 10) >> 2][24:32] + X_prog_LO_D[index][((i-3) % 10) >> 2][16:24] + X_prog_LO_D[index][((i-3) % 10) >> 2][8:16] + X_prog_LO_D[index][((i-3) % 10) >> 2][0:8]
        i += 1

    for i in range(4):
        data.append(X_prog_LO_N[i])
        data.append(X_prog_LO_S[i][0])
        data.append(X_prog_LO_S[i][1])
        data.append(X_prog_LO_D[i][0])
        data.append(X_prog_LO_D[i][1])
        for row in X_prog_LI_N[i]:
            data.append(row)
        for row in X_prog_LI_S[i]:
            data.append(row)

    return data
   


def main():
    H = 1
    V = 1

    BRAM = []
    CBi = 0; CBHi = 0; ILi = 0; CBVi = 0; LSi = 0
    for h in range(H*2+1):
        if(h%2 == 0):
            data = []
            for row in CBdata(csvData(f"CB{CBi}.csv")):
                data.append(row)
            CBi += 1

            for v in range(V):
                for row in CBHdata(csvData(f"CBH{CBHi}.csv")):
                    data.append(row)
                CBHi += 1

                for row in CBdata(csvData(f"CB{CBi}.csv")):
                    data.append(row)
                CBi += 1
            
            for row in reversed(data):
                BRAM.append(row)

        else:
            data = []
            for row in ILdata(csvData(f"IL{ILi}.csv")):
                data.append(row)
            ILi += 1

            for row in CBVdata(csvData(f"CBV{CBVi}.csv")):
                data.append(row)
            CBVi += 1

            for v in range(V):
                for row in LSdata(csvData(f"LS{LSi}.csv")):
                    data.append(row)
                LSi += 1

                for row in CBVdata(csvData(f"CBV{CBVi}.csv")):
                    data.append(row)
                CBVi += 1
            
            for row in reversed(data):
                BRAM.append(row)

    with open("rams_init_file.data", "w") as f:
        for row in BRAM:
            f.write(f'{row}\n')
    f.close
    
    

if __name__ == "__main__":
    main()
