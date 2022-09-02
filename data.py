from scipy import optimize
import pandas as pd
import numpy as np
import math

data_nsc = pd.read_csv('data_nsc.csv')
data_sc = pd.read_csv('data_sc.csv')

nsc_col = len(data_nsc.columns)-2
sc_col = len(data_sc.columns)-2

nmet_nsc = math.sqrt(nsc_col)
nmet_sc = math.sqrt(sc_col)

def fit(x,a,b):
    return a*x+b

if nmet_nsc == nmet_sc and nmet_nsc % 1 == 0 and nmet_sc % 1 == 0:
    nmet = int(nmet_nsc)
    x = np.array(data_nsc['v'])
    nsc_matrix = np.ones((nmet,nmet))
    sc_matrix = np.ones((nmet,nmet))
    #print(nsc_matrix)
    #print(x)
    for i in range(1,nmet+1):
        #print(i)
        for j in range(1,nmet+1):
            #print(j)
            y1 = np.array(data_nsc["nsc{}-{}".format(i,j)])
            y2 = np.array(data_sc["sc{}-{}".format(i,j)])
            a1,b1 = optimize.curve_fit(fit,x,y1)[0]
            a2,b2 = optimize.curve_fit(fit,x,y2)[0]
            #print("nsc slope:{}".format(a1))
            #print("sc slope:{}".format(a2))
            nsc_matrix[i-1][j-1] = a1
            sc_matrix[i-1][j-1] = a2
    nsc_matrix_inverse = np.linalg.inv(nsc_matrix)
    sc_matrix_inverse = np.linalg.inv(sc_matrix)
    u_matrix = sc_matrix_inverse-nsc_matrix_inverse
    print(u_matrix)
    u_diagonal = np.diagonal(u_matrix)
    print("u diagonal:")
    print(u_diagonal)
else:
    print("extra columns in data_nsc.csv or data_sc.csv")






    

#u_value = 1/a2-1/a1
#print("u value:{}".format(u_value))