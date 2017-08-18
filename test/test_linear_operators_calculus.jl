# @printf("\nTesting linear operators calculus rules\n")
#
#
###########################
###### test Compose #######
###########################
#m1, m2, m3 = 4, 7, 3
#A1 = randn(m2, m1)
#A2 = randn(m3, m2)
#opA1 = MatrixOp(A1)
#opA2 = MatrixOp(A2)
#
#opC = Compose(opA2,opA1)
#x = randn(m1)
#y1 = test_op(opC, x, randn(m3), verb)
#y2 = A2*A1*x
#@test all(vecnorm.(y1 .- y2) .<= 1e-12)
#
## test Compose longer
#m1, m2, m3, m4 = 4, 7, 3, 2
#A1 = randn(m2, m1)
#A2 = randn(m3, m2)
#A3 = randn(m4, m3)
#opA1 = MatrixOp(A1)
#opA2 = MatrixOp(A2)
#opA3 = MatrixOp(A3)
#
#opC1 = Compose(opA3,Compose(opA2,opA1))
#opC2 = Compose(Compose(opA3,opA2),opA1)
#x = randn(m1)
#y1 = test_op(opC1, x, randn(m4), verb)
#y2 = test_op(opC2, x, randn(m4), verb)
#y3 = A3*A2*A1*x
#@test all(vecnorm.(y1 .- y2) .<= 1e-12)
#@test all(vecnorm.(y3 .- y2) .<= 1e-12)
#
##test Compose special cases
#@test typeof(opA1*Eye(m1)) == typeof(opA1) 
#@test typeof(Eye(m2)*opA1) == typeof(opA1) 
#@test typeof(Eye(m2)*Eye(m2)) == typeof(Eye(m2)) 
#
#opS1 = Scale(pi,opA1)
#opS2 = Scale(pi,opA2)
#@test typeof(opS2*opA1) <: Scale
#@test typeof(opA2*opS1) <: Scale
#@test typeof(opS2*opS1) <: Scale
#
##properties
#@test is_linear(opC1)           == true
#@test is_null(opC1)             == false
#@test is_eye(opC1)              == false
#@test is_diagonal(opC1)         == false
#@test is_AcA_diagonal(opC1)     == false
#@test is_AAc_diagonal(opC1)     == false
#@test is_orthogonal(opC1)       == false
#@test is_invertible(opC1)       == false
#@test is_full_row_rank(opC1)    == false
#@test is_full_column_rank(opC1) == false
#
############################
####### test DCAT    #######
############################
#
#m1, n1, m2, n2 = 4, 7, 5, 2
#A1 = randn(m1, n1)
#A2 = randn(m2, n2)
#opA1 = MatrixOp(A1)
#opA2 = MatrixOp(A2)
#opD = DCAT(opA1, opA2)
#x1 = randn(n1)
#x2 = randn(n2)
#y1 = test_op(opD, (x1, x2), (randn(m1),randn(m2)), verb)
#y2 = (A1*x1, A2*x2)
#@test all(vecnorm.(y1 .- y2) .<= 1e-12)
#
## test DCAT longer
#
#m1, n1, m2, n2, m3, n3 = 4, 7, 5, 2, 5, 5
#A1 = randn(m1, n1)
#A2 = randn(m2, n2)
#A3 = randn(m3, n3)
#opA1 = MatrixOp(A1)
#opA2 = MatrixOp(A2)
#opA3 = MatrixOp(A3)
#opD = DCAT(opA1, opA2, opA3)
#x1 = randn(n1)
#x2 = randn(n2)
#x3 = randn(n3)
#y1 = test_op(opD, (x1, x2, x3), (randn(m1),randn(m2),randn(m3)), verb)
#y2 = (A1*x1, A2*x2, A3*x3)
#@test all(vecnorm.(y1 .- y2) .<= 1e-12)
#
##properties
#@test is_linear(opD)           == true
#@test is_null(opD)             == false
#@test is_eye(opD)              == false
#@test is_diagonal(opD)         == false
#@test is_AcA_diagonal(opD)     == false
#@test is_AAc_diagonal(opD)     == false
#@test is_orthogonal(opD)       == false
#@test is_invertible(opD)       == false
#@test is_full_row_rank(opD)    == false
#@test is_full_column_rank(opD) == false
#
##########################
##### test HCAT    #######
##########################

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

# test HCAT of HCAT
opHH = HCAT(opH, opA2, opA3)
y1 = test_op(opHH, (x1, x2, x3, x2, x3), randn(m), verb)
y2 = A1*x1 + A2*x2 + A3*x3 + A2*x2 + A3*x3
@test vecnorm(y1-y2) <= 1e-12

opHH = HCAT(opH, opH, opA3)
y1 = test_op(opHH, (x1, x2, x3, x1, x2, x3, x3), randn(m), verb)
y2 = A1*x1 + A2*x2 + A3*x3 + A1*x1 + A2*x2 + A3*x3 + A3*x3
@test vecnorm(y1-y2) <= 1e-12

opA3 = MatrixOp(randn(n1,n1))
@test_throws Exception HCAT(opA1,opA2,opA3)
opF = DFT(Complex{Float64},(m,))
@test_throws Exception HCAT(opA1,opF,opA2)

# test utilities

# permutation
p = randperm(ndoms(opHH,2))
opHHp = permute(opHH,p)

x = (x1, x2, x3, x1, x2, x3, x3)
xp = x[p] 

y1 = test_op(opHHp, xp, randn(m), verb)

#properties
m, n1, n2, n3 = 4, 7, 5, 6
A1 = randn(m, n1)
A2 = randn(m, n2)
A3 = randn(m, n3)
opA1 = MatrixOp(A1)
opA2 = MatrixOp(A2)
opA3 = MatrixOp(A3)
op = HCAT(opA1, opA2, opA3)
@test is_linear(op)           == true
@test is_null(op)             == false
@test is_eye(op)              == false
@test is_diagonal(op)         == false
@test is_AcA_diagonal(op)     == false
@test is_AAc_diagonal(op)     == false
@test is_orthogonal(op)       == false
@test is_invertible(op)       == false
@test is_full_row_rank(op)    == true
@test is_full_column_rank(op) == false

d = randn(n1)+im*randn(n1)
op = HCAT(DiagOp(d), DFT(Complex{Float64},n1))
@test is_null(op)             == false
@test is_eye(op)              == false
@test is_diagonal(op)         == false
@test is_AcA_diagonal(op)     == false
@test is_AAc_diagonal(op)     == true
@test is_orthogonal(op)       == false
@test is_invertible(op)       == false
@test is_full_row_rank(op)    == true
@test is_full_column_rank(op) == false

@test diag_AAc(op) == d.*conj(d)+n1

y1 = randn(n1)+im*randn(n1)
@test norm(op*(op'*y1)-diag_AAc(op).*y1) <1e-12




############################
####### test Reshape #######
############################
#
#m, n = 8, 4
#dim_out = (2, 2, 2)
#A1 = randn(m, n)
#opA1 = MatrixOp(A1)
#opR = Reshape(opA1, dim_out)
#opR = Reshape(opA1, dim_out...)
#x1 = randn(n)
#y1 = test_op(opR, x1, randn(dim_out), verb)
#y2 = reshape(A1*x1, dim_out)
#@test vecnorm(y1-y2) <= 1e-12
#
#@test is_null(opR)             == is_null(opA1)            
#@test is_eye(opR)              == is_eye(opA1)             
#@test is_diagonal(opR)         == is_diagonal(opA1)        
#@test is_AcA_diagonal(opR)     == is_AcA_diagonal(opA1)    
#@test is_AAc_diagonal(opR)     == is_AAc_diagonal(opA1)    
#@test is_orthogonal(opR)       == is_orthogonal(opA1)      
#@test is_invertible(opR)       == is_invertible(opA1)      
#@test is_full_row_rank(opR)    == is_full_row_rank(opA1)   
#@test is_full_column_rank(opR) == is_full_column_rank(opA1)
#
###########################
###### test Scale   #######
###########################
#
#m, n = 8, 4
#coeff = pi
#A1 = randn(m, n)
#opA1 = MatrixOp(A1)
#opS = Scale(coeff, opA1)
#x1 = randn(n)
#y1 = test_op(opS, x1, randn(m), verb)
#y2 = coeff*A1*x1
#@test vecnorm(y1-y2) <= 1e-12
#
#coeff2 = 3
#opS2 = Scale(coeff2, opS)
#y1 = test_op(opS2, x1, randn(m), verb)
#y2 = coeff2*coeff*A1*x1
#@test vecnorm(y1-y2) <= 1e-12
#
#opF = DFT(m,n)
#opS = Scale(coeff, opF)
#x1 = randn(m,n)
#y1 = test_op(opS, x1, fft(randn(m,n)), verb)
#y2 = coeff*(fft(x1))
#@test vecnorm(y1-y2) <= 1e-12
#
#opS = Scale(coeff, opA1)
#@test is_null(opS)             == is_null(opA1)            
#@test is_eye(opS)              == is_eye(opA1)             
#@test is_diagonal(opS)         == is_diagonal(opA1)        
#@test is_AcA_diagonal(opS)     == is_AcA_diagonal(opA1)    
#@test is_AAc_diagonal(opS)     == is_AAc_diagonal(opA1)    
#@test is_orthogonal(opS)       == is_orthogonal(opA1)      
#@test is_invertible(opS)       == is_invertible(opA1)      
#@test is_full_row_rank(opS)    == is_full_row_rank(opA1)   
#@test is_full_column_rank(opS) == is_full_column_rank(opA1)
#
#op = Scale(-4.0,DFT(10))
#@test is_AAc_diagonal(op)     == true
#@test diag_AAc(op) == 16*10
#
#op = Scale(-4.0,ZeroPad((10,), 20))
#@test is_AcA_diagonal(op)     == true
#@test diag_AcA(op) == 16
#
## special case, Scale of DiagOp gets a DiagOp
#d = randn(10)
#op = Scale(3,DiagOp(d))
#@test typeof(op) <: DiagOp
#@test norm(diag(op) - 3.*d) < 1e-12
#
###########################
###### test Sum     #######
###########################
#
#m,n = 5,7
#A1 = randn(m,n)
#A2 = randn(m,n)
#opA1 = MatrixOp(A1)
#opA2 = MatrixOp(A2)
#opS = Sum(opA1,opA2)
#x1 = randn(n)
#y1 = test_op(opS, x1, randn(m), verb)
#y2 = A1*x1+A2*x1
#@test vecnorm(y1-y2) <= 1e-12
##test Sum longer
#m,n = 5,7
#A1 = randn(m,n)
#A2 = randn(m,n)
#A3 = randn(m,n)
#opA1 = MatrixOp(A1)
#opA2 = MatrixOp(A2)
#opA3 = MatrixOp(A3)
#opS = Sum(opA1,opA2,opA3)
#x1 = randn(n)
#y1 = test_op(opS, x1, randn(m), verb)
#y2 = A1*x1+A2*x1+A3*x1
#@test vecnorm(y1-y2) <= 1e-12
#
#opA3 = MatrixOp(randn(m,m))
#@test_throws Exception Sum(opA1,opA3)
#opF = DFT(Float64,(m,))
#@test_throws Exception Sum(opF,opA3)
#
#@test is_null(opS)             == false
#@test is_eye(opS)              == false 
#@test is_diagonal(opS)         == false
#@test is_AcA_diagonal(opS)     == false
#@test is_AAc_diagonal(opS)     == false
#@test is_orthogonal(opS)       == false
#@test is_invertible(opS)       == false
#@test is_full_row_rank(opS)    == true
#@test is_full_column_rank(opS) == false
#
#d = randn(10)
#op = Sum(Scale(-3.1,Eye(10)),DiagOp(d))
#@test is_diagonal(op)         == true
#@test norm(   diag(op) - (d-3.1)  )<1e-12
#
############################
####### test Transpose######
############################
#
#m,n = 5,7
#A1 = randn(m,n)
#opA1 = MatrixOp(A1)
#opA1t = MatrixOp(A1')
#opT = Transpose(opA1)
#x1 = randn(m)
#y1 = test_op(opT, x1, randn(n), verb)
#y2 = A1'*x1
#@test vecnorm(y1-y2) <= 1e-12
#
#@test is_null(opT)             == is_null(opA1t)            
#@test is_eye(opT)              == is_eye(opA1t)             
#@test is_diagonal(opT)         == is_diagonal(opA1t)        
#@test is_AcA_diagonal(opT)     == is_AcA_diagonal(opA1t)    
#@test is_AAc_diagonal(opT)     == is_AAc_diagonal(opA1t)    
#@test is_orthogonal(opT)       == is_orthogonal(opA1t)      
#@test is_invertible(opT)       == is_invertible(opA1t)      
#@test is_full_row_rank(opT)    == is_full_row_rank(opA1t)   
#@test is_full_column_rank(opT) == is_full_column_rank(opA1t)
#
#d = randn(3)
#op = Transpose(DiagOp(d))
#@test is_diagonal(op) == true
#@test diag(op) == d
#
#op = Transpose(ZeroPad((10,),5))
#@test is_AcA_diagonal(op) == false
#@test is_AAc_diagonal(op) == true
#@test diag_AAc(op) == 1
#
##############################
######### test VCAT    #######
##############################
#
#m1, m2, n = 4, 7, 5
#A1 = randn(m1, n)
#A2 = randn(m2, n)
#opA1 = MatrixOp(A1)
#opA2 = MatrixOp(A2)
#opV = VCAT(opA1, opA2)
#x1 = randn(n)
#y1 = test_op(opV, x1, (randn(m1), randn(m2)), verb)
#y2 = (A1*x1, A2*x1)
#@test all(vecnorm.(y1 .- y2) .<= 1e-12)
#
##test VCAT longer
#m1, m2, m3, n = 4, 7, 3, 5
#A1 = randn(m1, n)
#A2 = randn(m2, n)
#A3 = randn(m3, n)
#opA1 = MatrixOp(A1)
#opA2 = MatrixOp(A2)
#opA3 = MatrixOp(A3)
#opV = VCAT(opA1, opA2, opA3)
#x1 = randn(n)
#y1 = test_op(opV, x1, (randn(m1), randn(m2), randn(m3)), verb)
#y2 = (A1*x1, A2*x1, A3*x1)
#@test all(vecnorm.(y1 .- y2) .<= 1e-12)
#
##test VCAT of VCAT
#opVV = VCAT(opV,opA3)
#y1 = test_op(opVV, x1, (randn(m1), randn(m2), randn(m3), randn(m3)), verb)
#y2 = (A1*x1, A2*x1, A3*x1, A3*x1)
#@test all(vecnorm.(y1 .- y2) .<= 1e-12)
#
#opVV = VCAT(opA1,opV,opA3)
#y1 = test_op(opVV, x1, (randn(m1), randn(m1), randn(m2), randn(m3), randn(m3)), verb)
#y2 = (A1*x1, A1*x1, A2*x1, A3*x1, A3*x1)
#@test all(vecnorm.(y1 .- y2) .<= 1e-12)
#
#opA3 = MatrixOp(randn(m1,m1))
#@test_throws Exception VCAT(opA1,opA2,opA3)
#opF = DFT(Complex{Float64},(n,))
#@test_throws Exception VCAT(opA1,opF,opA2)
#
####properties
#m1, m2, m3, n = 4, 7, 3, 5
#A1 = randn(m1, n)
#A2 = randn(m2, n)
#A3 = randn(m3, n)
#opA1 = MatrixOp(A1)
#opA2 = MatrixOp(A2)
#opA3 = MatrixOp(A3)
#op = VCAT(opA1, opA2, opA3)
#@test is_linear(op)           == true
#@test is_null(op)             == false
#@test is_eye(op)              == false
#@test is_diagonal(op)         == false
#@test is_AcA_diagonal(op)     == false
#@test is_AAc_diagonal(op)     == false
#@test is_orthogonal(op)       == false
#@test is_invertible(op)       == false
#@test is_full_row_rank(op)    == false
#@test is_full_column_rank(op) == true
#
#op = VCAT(DFT(Complex{Float64},10), Eye(Complex{Float64},10) )
#@test is_AcA_diagonal(op)     == true
#@test diag_AcA(op) == 11
#
##############################
######### test combin. #######
##############################
#
### test Compose of HCAT
#m1, m2, m3, m4 = 4, 7, 3, 2
#A1 = randn(m3, m1)
#A2 = randn(m3, m2)
#A3 = randn(m4, m3)
#opA1 = MatrixOp(A1)
#opA2 = MatrixOp(A2)
#opA3 = MatrixOp(A3)
#opH = HCAT(opA1,opA2)
#opC = Compose(opA3,opH)
#x1, x2 = randn(m1), randn(m2)
#y1 = test_op(opC, (x1,x2), randn(m4), verb)
#
#y2 = A3*(A1*x1+A2*x2)
#
## test VCAT of HCAT's
#m1, m2, n1 = 4, 7, 3
#A1 = randn(n1, m1)
#A2 = randn(n1, m2)
#opA1 = MatrixOp(A1)
#opA2 = MatrixOp(A2)
#opH1 = HCAT(opA1,opA2)
#
#m1, m2, n2 = 4, 7, 5
#A3 = randn(n2, m1)
#A4 = randn(n2, m2)
#opA3 = MatrixOp(A3)
#opA4 = MatrixOp(A4)
#opH2 = HCAT(opA3,opA4)
#
#opV = VCAT(opH1,opH2)
#x1, x2 = randn(m1), randn(m2)
#y1 = test_op(opV, (x1,x2), (randn(n1),randn(n2)), verb)
#y2 = (A1*x1+A2*x2,A3*x1+A4*x2)
#@test all(vecnorm.(y1 .- y2) .<= 1e-12)
#
#
## test HCAT of VCAT's
#
#n1, n2, m1, m2 = 3, 5, 4, 7
#A = randn(m1, n1); opA = MatrixOp(A)
#B = randn(m1, n2); opB = MatrixOp(B)
#C = randn(m2, n1); opC = MatrixOp(C)
#D = randn(m2, n2); opD = MatrixOp(D)
#opV = HCAT(VCAT(opA, opC), VCAT(opB, opD))
#x1 = randn(n1)
#x2 = randn(n2)
#y1 = test_op(opV, (x1, x2), (randn(m1), randn(m2)), verb)
#y2 = (A*x1 + B*x2, C*x1 + D*x2)
#
#@test all(vecnorm.(y1 .- y2) .<= 1e-12)
#
## test Sum of HCAT's
#
#m, n1, n2, n3 = 4, 7, 5, 3
#A1 = randn(m, n1)
#A2 = randn(m, n2)
#A3 = randn(m, n3)
#B1 = randn(m, n1)
#B2 = randn(m, n2)
#B3 = randn(m, n3)
#opA1 = MatrixOp(A1)
#opA2 = MatrixOp(A2)
#opA3 = MatrixOp(A3)
#opB1 = MatrixOp(B1)
#opB2 = MatrixOp(B2)
#opB3 = MatrixOp(B3)
#opHA = HCAT(opA1, opA2, opA3)
#opHB = HCAT(opB1, opB2, opB3)
#opS = Sum(opHA, opHB)
#x1 = randn(n1)
#x2 = randn(n2)
#x3 = randn(n3)
#y1 = test_op(opS, (x1, x2, x3), randn(m), verb)
#y2 = A1*x1 + B1*x1 + A2*x2 + B2*x2 + A3*x3 + B3*x3
#
#@test vecnorm(y1-y2) <= 1e-12
#
## test Sum of VCAT's
#
#m1, m2, n = 4, 7, 5
#A1 = randn(m1, n)
#A2 = randn(m2, n)
#B1 = randn(m1, n)
#B2 = randn(m2, n)
#C1 = randn(m1, n)
#C2 = randn(m2, n)
#opA1 = MatrixOp(A1)
#opA2 = MatrixOp(A2)
#opB1 = MatrixOp(B1)
#opB2 = MatrixOp(B2)
#opC1 = MatrixOp(C1)
#opC2 = MatrixOp(C2)
#opVA = VCAT(opA1, opA2)
#opVB = VCAT(opB1, opB2)
#opVC = VCAT(opC1, opC2)
#opS = Sum(opVA, opVB, opVC)
#x = randn(n)
#y1 = test_op(opS, x, (randn(m1), randn(m2)), verb)
#y2 = (A1*x + B1*x +C1*x, A2*x + B2*x + C2*x)
#
#@test all(vecnorm.(y1 .- y2) .<= 1e-12)
#
## test Scale of DCAT
#
#m1, n1 = 4, 7
#m2, n2 = 3, 5
#A1 = randn(m1, n1)
#A2 = randn(m2, n2)
#opA1 = MatrixOp(A1)
#opA2 = MatrixOp(A2)
#opD = DCAT(opA1, opA2)
#coeff = randn()
#opS = Scale(coeff, opD)
#x1 = randn(n1)
#x2 = randn(n2)
#y = test_op(opS, (x1, x2), (randn(m1), randn(m2)), verb)
#z = (coeff*A1*x1, coeff*A2*x2)
#
#@test all(vecnorm.(y .- z) .<= 1e-12)
#
## test Scale of VCAT
#
#m1, m2, n = 4, 3, 7
#A1 = randn(m1, n)
#A2 = randn(m2, n)
#opA1 = MatrixOp(A1)
#opA2 = MatrixOp(A2)
#opV = VCAT(opA1, opA2)
#coeff = randn()
#opS = Scale(coeff, opV)
#x = randn(n)
#y = test_op(opS, x, (randn(m1), randn(m2)), verb)
#z = (coeff*A1*x, coeff*A2*x)
#
#@test all(vecnorm.(y .- z) .<= 1e-12)
#
## test Scale of HCAT
#
#m, n1, n2 = 4, 3, 7
#A1 = randn(m, n1)
#A2 = randn(m, n2)
#opA1 = MatrixOp(A1)
#opA2 = MatrixOp(A2)
#opH = HCAT(opA1, opA2)
#coeff = randn()
#opS = Scale(coeff, opH)
#x1 = randn(n1)
#x2 = randn(n2)
#y = test_op(opS, (x1, x2), randn(m), verb)
#z = coeff*(A1*x1 + A2*x2)
#
#@test all(vecnorm.(y .- z) .<= 1e-12)
#
## test Scale of Sum
#
#m,n = 5,7
#A1 = randn(m,n)
#A2 = randn(m,n)
#opA1 = MatrixOp(A1)
#opA2 = MatrixOp(A2)
#opS = Sum(opA1,opA2)
#coeff = pi
#opSS = Scale(coeff,opS)
#x1 = randn(n)
#y1 = test_op(opSS, x1, randn(m), verb)
#y2 = coeff*(A1*x1+A2*x1)
#@test vecnorm(y1-y2) <= 1e-12
#
## test Scale of Compose
#
#m1, m2, m3 = 4, 7, 3
#A1 = randn(m2, m1)
#A2 = randn(m3, m2)
#opA1 = MatrixOp(A1)
#opA2 = MatrixOp(A2)
#
#coeff = pi
#opC = Compose(opA2,opA1)
#opS = Scale(coeff,opC)
#x = randn(m1)
#y1 = test_op(opS, x, randn(m3), verb)
#y2 = coeff*(A2*A1*x)
#@test all(vecnorm.(y1 .- y2) .<= 1e-12)
