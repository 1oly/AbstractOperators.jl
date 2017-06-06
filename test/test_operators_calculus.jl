@printf("\nTesting linear operators calculus rules\n")

verb = true

##########################
##### test Compose #######
##########################
m1, m2, m3 = 4, 7, 3
A1 = randn(m2, m1)
A2 = randn(m3, m2)
opA1 = MatrixOp(A1)
opA2 = MatrixOp(A2)

opC = Compose(opA2,opA1)
x = randn(m1)
y1 = test_op(opC, x, randn(m3), verb)
y2 = A2*A1*x
@test all(vecnorm.(y1 .- y2) .<= 1e-12)

# test Compose longer
m1, m2, m3, m4 = 4, 7, 3, 2
A1 = randn(m2, m1)
A2 = randn(m3, m2)
A3 = randn(m4, m3)
opA1 = MatrixOp(A1)
opA2 = MatrixOp(A2)
opA3 = MatrixOp(A3)

opC1 = Compose(opA3,Compose(opA2,opA1))
opC2 = Compose(Compose(opA3,opA2),opA1)
x = randn(m1)
y1 = test_op(opC1, x, randn(m4), verb)
y2 = test_op(opC2, x, randn(m4), verb)
y3 = A3*A2*A1*x
@test all(vecnorm.(y1 .- y2) .<= 1e-12)
@test all(vecnorm.(y3 .- y2) .<= 1e-12)

###########################
###### test DCAT    #######
###########################

m1, n1, m2, n2 = 4, 7, 5, 2
A1 = randn(m1, n1)
A2 = randn(m2, n2)
opA1 = MatrixOp(A1)
opA2 = MatrixOp(A2)
opD = DCAT(opA1, opA2)
x1 = randn(n1)
x2 = randn(n2)
y1 = test_op(opD, (x1, x2), (randn(m1),randn(m2)), verb)
y2 = (A1*x1, A2*x2)
@test all(vecnorm.(y1 .- y2) .<= 1e-12)

# test DCAT longer

m1, n1, m2, n2, m3, n3 = 4, 7, 5, 2, 5, 5
A1 = randn(m1, n1)
A2 = randn(m2, n2)
A3 = randn(m3, n3)
opA1 = MatrixOp(A1)
opA2 = MatrixOp(A2)
opA3 = MatrixOp(A3)
opD = DCAT(opA1, opA2, opA3)
x1 = randn(n1)
x2 = randn(n2)
x3 = randn(n3)
y1 = test_op(opD, (x1, x2, x3), (randn(m1),randn(m2),randn(m3)), verb)
y2 = (A1*x1, A2*x2, A3*x3)
@test all(vecnorm.(y1 .- y2) .<= 1e-12)

############################
####### test HCAT    #######
############################

m, n1, n2 = 4, 7, 5
A1 = randn(m, n1)
A2 = randn(m, n2)
opA1 = MatrixOp(A1)
opA2 = MatrixOp(A2)
opH = HCAT(opA1, opA2)
x1 = randn(n1)
x2 = randn(n2)
y1 = test_op(opH, (x1, x2), randn(m), verb)
y2 = A1*x1 + A2*x2
@test vecnorm(y1-y2) <= 1e-12

# test HCAT longer

m, n1, n2, n3 = 4, 7, 5, 6
A1 = randn(m, n1)
A2 = randn(m, n2)
A3 = randn(m, n3)
opA1 = MatrixOp(A1)
opA2 = MatrixOp(A2)
opA3 = MatrixOp(A3)
opH = HCAT(opA1, opA2, opA3)
x1 = randn(n1)
x2 = randn(n2)
x3 = randn(n3)
y1 = test_op(opH, (x1, x2, x3), randn(m), verb)
y2 = A1*x1 + A2*x2 + A3*x3
@test vecnorm(y1-y2) <= 1e-12

opA3 = MatrixOp(randn(n1,n1))
@test_throws Exception HCAT(opA1,opA2,opA3)
opF = DFT(Complex{Float64},(m,))
@test_throws Exception HCAT(opA1,opF,opA2)

###########################
###### test Reshape #######
###########################

m, n = 8, 4
dim_out = (2, 2, 2)
A1 = randn(m, n)
opA1 = MatrixOp(A1)
opR = Reshape(opA1, dim_out)
opR = Reshape(opA1, dim_out...)
x1 = randn(n)
y1 = test_op(opR, x1, randn(dim_out), verb)
y2 = reshape(A1*x1, dim_out)
@test vecnorm(y1-y2) <= 1e-12

###########################
###### test Scale   #######
###########################

m, n = 8, 4
alpha = 2.
A1 = randn(m, n)
opA1 = MatrixOp(A1)
opS = Scale(alpha, opA1)
x1 = randn(n)
y1 = test_op(opS, x1, randn(m), verb)
y2 = alpha*A1*x1
@test vecnorm(y1-y2) <= 1e-12

alpha2 = 3.
opS2 = Scale(alpha2, opS)
y1 = test_op(opS2, x1, randn(m), verb)
y2 = alpha2*alpha*A1*x1
@test vecnorm(y1-y2) <= 1e-12

##########################
##### test Sum     #######
###########################

m,n = 5,7
A1 = randn(m,n)
A2 = randn(m,n)
opA1 = MatrixOp(A1)
opA2 = MatrixOp(A2)
opS = Sum(opA1,opA2)
x1 = randn(n)
y1 = test_op(opS, x1, randn(m), verb)
y2 = A1*x1+A2*x1
@test vecnorm(y1-y2) <= 1e-12
#test Sum longer
m,n = 5,7
A1 = randn(m,n)
A2 = randn(m,n)
A3 = randn(m,n)
opA1 = MatrixOp(A1)
opA2 = MatrixOp(A2)
opA3 = MatrixOp(A3)
opS = Sum(opA1,opA2,opA3)
x1 = randn(n)
y1 = test_op(opS, x1, randn(m), verb)
y2 = A1*x1+A2*x1+A3*x1
@test vecnorm(y1-y2) <= 1e-12

opA3 = MatrixOp(randn(m,m))
@test_throws Exception Sum(opA1,opA3)
opF = DFT(Float64,(m,))
@test_throws Exception Sum(opF,opA3)

##########################
##### test Transpose######
##########################

m,n = 5,7
A1 = randn(m,n)
opA1 = MatrixOp(A1)
opT = Transpose(opA1)
x1 = randn(m)
y1 = test_op(opT, x1, randn(n), verb)
y2 = A1'*x1
@test vecnorm(y1-y2) <= 1e-12

############################
####### test VCAT    #######
############################

m1, m2, n = 4, 7, 5
A1 = randn(m1, n)
A2 = randn(m2, n)
opA1 = MatrixOp(A1)
opA2 = MatrixOp(A2)
opV = VCAT(opA1, opA2)
x1 = randn(n)
y1 = test_op(opV, x1, (randn(m1), randn(m2)), verb)
y2 = (A1*x1, A2*x1)
@test all(vecnorm.(y1 .- y2) .<= 1e-12)

#test VCAT longer
m1, m2, m3, n = 4, 7, 3, 5
A1 = randn(m1, n)
A2 = randn(m2, n)
A3 = randn(m3, n)
opA1 = MatrixOp(A1)
opA2 = MatrixOp(A2)
opA3 = MatrixOp(A3)
opV = VCAT(opA1, opA2, opA3)
x1 = randn(n)
y1 = test_op(opV, x1, (randn(m1), randn(m2), randn(m3)), verb)
y2 = (A1*x1, A2*x1, A3*x1)
@test all(vecnorm.(y1 .- y2) .<= 1e-12)

opA3 = MatrixOp(randn(m1,m1))
@test_throws Exception VCAT(opA1,opA2,opA3)
opF = DFT(Complex{Float64},(n,))
@test_throws Exception VCAT(opA1,opF,opA2)

############################
####### test combin. #######
############################

## test Compose of HCAT
m1, m2, m3, m4 = 4, 7, 3, 2
A1 = randn(m3, m1)
A2 = randn(m3, m2)
A3 = randn(m4, m3)
opA1 = MatrixOp(A1)
opA2 = MatrixOp(A2)
opA3 = MatrixOp(A3)
opH = HCAT(opA1,opA2)
opC = Compose(opA3,opH)
x1, x2 = randn(m1), randn(m2)
y1 = test_op(opC, (x1,x2), randn(m4), verb)

y2 = A3*(A1*x1+A2*x2)

# test VCAT of HCAT's
m1, m2, n1 = 4, 7, 3
A1 = randn(n1, m1)
A2 = randn(n1, m2)
opA1 = MatrixOp(A1)
opA2 = MatrixOp(A2)
opH1 = HCAT(opA1,opA2)

m1, m2, n2 = 4, 7, 5
A3 = randn(n2, m1)
A4 = randn(n2, m2)
opA3 = MatrixOp(A3)
opA4 = MatrixOp(A4)
opH2 = HCAT(opA3,opA4)

opV = VCAT(opH1,opH2)
x1, x2 = randn(m1), randn(m2)
y1 = test_op(opV, (x1,x2), (randn(n1),randn(n2)), verb)
y2 = (A1*x1+A2*x2,A3*x1+A4*x2)
@test all(vecnorm.(y1 .- y2) .<= 1e-12)


# test HCAT of VCAT's

n1, n2, m1, m2 = 3, 5, 4, 7
A = randn(m1, n1); opA = MatrixOp(A)
B = randn(m1, n2); opB = MatrixOp(B)
C = randn(m2, n1); opC = MatrixOp(C)
D = randn(m2, n2); opD = MatrixOp(D)
opV = HCAT(VCAT(opA, opC), VCAT(opB, opD))
x1 = randn(n1)
x2 = randn(n2)
y1 = test_op(opV, (x1, x2), (randn(m1), randn(m2)), verb)
y2 = (A*x1 + B*x2, C*x1 + D*x2)

@test all(vecnorm.(y1 .- y2) .<= 1e-12)

# test Sum of HCAT's

m, n1, n2, n3 = 4, 7, 5, 3
A1 = randn(m, n1)
A2 = randn(m, n2)
A3 = randn(m, n3)
B1 = randn(m, n1)
B2 = randn(m, n2)
B3 = randn(m, n3)
opA1 = MatrixOp(A1)
opA2 = MatrixOp(A2)
opA3 = MatrixOp(A3)
opB1 = MatrixOp(B1)
opB2 = MatrixOp(B2)
opB3 = MatrixOp(B3)
opHA = HCAT(opA1, opA2, opA3)
opHB = HCAT(opB1, opB2, opB3)
opS = Sum(opHA, opHB)
x1 = randn(n1)
x2 = randn(n2)
x3 = randn(n3)
y1 = test_op(opS, (x1, x2, x3), randn(m), verb)
y2 = A1*x1 + B1*x1 + A2*x2 + B2*x2 + A3*x3 + B3*x3

@test vecnorm(y1-y2) <= 1e-12

# test Sum of VCAT's

m1, m2, n = 4, 7, 5
A1 = randn(m1, n)
A2 = randn(m2, n)
B1 = randn(m1, n)
B2 = randn(m2, n)
C1 = randn(m1, n)
C2 = randn(m2, n)
opA1 = MatrixOp(A1)
opA2 = MatrixOp(A2)
opB1 = MatrixOp(B1)
opB2 = MatrixOp(B2)
opC1 = MatrixOp(C1)
opC2 = MatrixOp(C2)
opVA = VCAT(opA1, opA2)
opVB = VCAT(opB1, opB2)
opVC = VCAT(opC1, opC2)
opS = Sum(opVA, opVB, opVC)
x = randn(n)
y1 = test_op(opS, x, (randn(m1), randn(m2)), verb)
y2 = (A1*x + B1*x +C1*x, A2*x + B2*x + C2*x)

@test all(vecnorm.(y1 .- y2) .<= 1e-12)


#
