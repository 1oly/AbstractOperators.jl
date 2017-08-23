
@printf("\nTesting  calculus non linear operators\n")
##testing Scale
m = 3
x = randn(m)
r = randn(m)
A = Sigmoid(Float64,(m,),2)
op = 30*A

y, grad = test_NLop(op,x,r,verb)

Y = 30*(A*x)
@test vecnorm(Y-y) <1e-8

#testing DCAT
n,m = 4,3
x = (randn(n),randn(m))
r = (randn(n),randn(m))
A = randn(n,n)
B = Sigmoid(Float64,(m,),2)
op = DCAT(MatrixOp(A),B)

y, grad = test_NLop(op,x,r,verb)

Y = (A*x[1],B*x[2]) 
@test vecnorm(Y[1]-y[1]) <1e-8
@test vecnorm(Y[2]-y[2]) <1e-8

#testing HCAT
n,m = 4,3
x = (randn(n),randn(m))
r = randn(m)
A = randn(m,n)
B = Sigmoid(Float64,(m,),2)
op = HCAT(MatrixOp(A),B)

y, grad = test_NLop(op,x,r,verb)

Y = A*x[1]+B*x[2]
@test vecnorm(Y-y) <1e-8

#testing VCAT
n,m = 4,3
x = randn(m)
r = (randn(n),randn(m))
A = randn(n,m)
B = Sigmoid(Float64,(m,),2)
op = VCAT(MatrixOp(A),B)

y, grad = test_NLop(op,x,r,verb)

Y = (A*x,B*x)
@test vecnorm(Y[1]-y[1]) <1e-8
@test vecnorm(Y[2]-y[2]) <1e-8

#testing HCAT of VCAT
n,m1,m2,m3 = 4,3,2,7
x1 = randn(m1)
x2 = randn(m2)
x3 = randn(m3)
x = (x1,x2,x3)
r = (randn(n),randn(m1))
A1 = randn(n,m1)
A2 = randn(n,m2)
A3 = randn(n,m3)
B1 = Sigmoid(Float64,(m1,),2)
B2 = randn(m1,m2)
B3 = randn(m1,m3)
op1 = VCAT(MatrixOp(A1),B1)
op2 = VCAT(MatrixOp(A2),MatrixOp(B2))
op3 = VCAT(MatrixOp(A3),MatrixOp(B3))
op = HCAT(op1,op2,op3)

y, grad = test_NLop(op,x,r,verb)

Y = (A1*x1+A2*x2+A3*x3,B1*x1+B2*x2+B3*x3)
@test vecnorm(Y[1]-y[1]) <1e-8
@test vecnorm(Y[2]-y[2]) <1e-8

#testing VCAT of HCAT
m1,m2,m3,n1,n2 = 3,4,5,6,7
x1 = randn(m1)
x2 = randn(n1)
x3 = randn(m3)
x = (x1,x2,x3)
r = (randn(n1),randn(n2))
A1 = randn(n1,m1)
B1 = Sigmoid(Float64,(n1,),2)
C1 = randn(n1,m3)
A2 = randn(n2,m1)
B2 = randn(n2,n1) 
C2 = randn(n2,m3)
x = (x1,x2,x3)
op1 = HCAT(MatrixOp(A1),         B1 ,MatrixOp(C1))
op2 = HCAT(MatrixOp(A2),MatrixOp(B2),MatrixOp(C2))
op = VCAT(op1,op2)

y, grad = test_NLop(op,x,r,verb)

Y = (A1*x1+B1*x2+C1*x3,A2*x1+B2*x2+C2*x3)
@test vecnorm(Y[1]-y[1]) <1e-8
@test vecnorm(Y[2]-y[2]) <1e-8


#testing Compose

l,n,m = 5,4,3
x = randn(m)
r = randn(l)
A = randn(l,n)
C = randn(n,m)
opA = MatrixOp(A)
opB = Sigmoid(Float64,(n,),2)
opC = MatrixOp(C)
op = Compose(opA,Compose(opB,opC))

y, grad = test_NLop(op,x,r,verb)

Y = A*(opB*(opC*x)) 
@test vecnorm(Y-y) <1e-8

## NN
m,n,l = 4,7,5
b = randn(l)
opS1 = Sigmoid(Float64,(n,),2)
x = (randn(n,l),randn(n))
r = randn(n)

A1 = HCAT(MatrixMul(b,n) ,Eye(n))
op = Compose(opS1,A1)
y, grad = test_NLop(op,x,r,verb)


###testing Reshape
n = 4
x = randn(n)
r = randn(n)
opS = Sigmoid(Float64,(n,),2)
op = Reshape(opS,2,2)

y, grad = test_NLop(op,x,r,verb)

Y = reshape(opS*x,2,2)
@test vecnorm(Y-y) <1e-8

##testing Sum
m = 5
x = randn(m)
r = randn(m)
A = randn(m,m)
opA = MatrixOp(A)
opB = Sigmoid(Float64,(m,),2)
op = Sum(opA,opB)

y, grad = test_NLop(op,x,r,verb)

Y = A*x+opB*x
@test vecnorm(Y-y) <1e-8

##testing Hadamard
#n,m,l = 4,5,6
#A = randn(n,m)
#B = randn(n,l)
#x = (randn(m),randn(l))
#P = Hadamard(MatrixOp(A),MatrixOp(B))
#println(P)
#y = P*x
#@test norm((A*x[1]).*(B*x[2]) - y) <= 1e-12
#
#J = Jacobian(P,x)
#Jfd = jacobian_fd(P,x)
#y = randn(n)
#
#grad = J'*y
#gradfd = Jfd'*y
#
#@test norm(grad[1]-gradfd[1:m])<1e-6
#@test norm(grad[2]-gradfd[m+1:end])<1e-6
#
#n,m = 4,5
#A = randn(n,m)
#opS = Sigmoid(Float64,(n,),6)
#x = (randn(n),randn(m))
#P = Hadamard(opS,MatrixOp(A))
#println(P)
#y = P*x
#@test norm((opS*x[1]).*(A*x[2]) - y) <= 1e-12
#
#J = Jacobian(P,x)
#Jfd = jacobian_fd(P,x)
#y = randn(n)
#
#grad = J'*y
#gradfd = Jfd'*y
#
#@test norm(grad[1]-gradfd[1:n])<1e-6
#@test norm(grad[2]-gradfd[n+1:end])<1e-6
#
#n= 4
#opS1 = Sigmoid(Float64,(n,),6)
#opS2 = Sigmoid(Float64,(n,),10)
#x = (randn(n),randn(n))
#P = Hadamard(opS1,opS2)
#println(P)
#y = P*x
#@test norm((opS1*x[1]).*(opS2*x[2]) - y) <= 1e-12
#
#J = Jacobian(P,x)
#Jfd = jacobian_fd(P,x)
#y = randn(n)
#
#grad = J'*y
#gradfd = Jfd'*y
#
#@test norm(grad[1]-gradfd[1:n])<1e-6
#@test norm(grad[2]-gradfd[n+1:end])<1e-6
#
#n,m,l = 4,5,6
#a = randn(m)
#b = randn(n)
#opA = MatrixMul(a,l)
#opB = MatrixMul(b,l)
#X = (randn(l,m),randn(l,n))
#P = Hadamard(opA,opB)
#println(P)
#y = P*X
#
#@test norm(X[1]*a.*X[2]*b-y)<1e-6
#
#J = Jacobian(P,X)
#y = randn(l)
#
#grad = J'*y
#
#n,m1,m2,m3 = 4,5,6,7
#A1 = zeros(n,m1)
#A2 = randn(n,m2)
#A3 = randn(n,m3)
#B1 = randn(n,m1)
#B2 = zeros(n,m2)
#B3 = zeros(n,m3)
#x = (randn(m1),randn(m2),randn(m3))
#
#Y = (A1*x[1]+A2*x[2]+A3*x[3]).*(B1*x[1]+B2*x[2]+B3*x[3])
#
#HA = HCAT(Zeros(Float64,(m1,),(n,)),MatrixOp(A2),MatrixOp(A3)) 
#HB = HCAT(MatrixOp(B1),Zeros(Float64,(m2,),(n,)),Zeros(Float64,(m3,),(n,))) 
#
#P = Hadamard(HA,HB)
#println(P)
#y = P*x
#@test norm(Y - y) <= 1e-12
#
#J = Jacobian(P,x)
#Jfd = jacobian_fd(P,x)
#y = randn(n)
#
#grad = J'*y
#gradfd = Jfd'*y
#
#@test norm(grad[1]-gradfd[1:m1])<1e-6
#@test norm(grad[2]-gradfd[m1+1:m1+m2])<1e-6
#@test norm(grad[3]-gradfd[m1+m2+1:end])<1e-6
#
#n,m1,m2,m3 = 4,5,6,7
#A1 = randn(n,m1)
#A2 = randn(n,m2)
#A3 = randn(n,m3)
#P = Hadamard(MatrixOp(A1),MatrixOp(A2),MatrixOp(A3))
#x = (randn(m1),randn(m2),randn(m3))
#
#Y = (A1*x[1]).*(A2*x[2]).*(A3*x[3])
#y = P*x
#@test norm(Y - y) <= 1e-12
#
#J = Jacobian(P,x)
#Jfd = jacobian_fd(P,x)
#y = randn(n)
#
#grad = J'*y
#gradfd = Jfd'*y
#
#@test norm(grad[1]-gradfd[1:m1])<1e-6
#@test norm(grad[2]-gradfd[m1+1:m1+m2])<1e-6
#@test norm(grad[3]-gradfd[m1+m2+1:end])<1e-6
#
#n,m1,m2,m3 = 4,5,6,7
#A1 = randn(n,m1)
#A2 = randn(n,m2)
#A3 = randn(n,m3)
#P = Hadamard(HCAT(MatrixOp(A1),MatrixOp(A2)),MatrixOp(A3))
#x = (randn(m1),randn(m2),randn(m3))
#println(P)
#
#Y = (A1*x[1]+A2*x[2]).*(A3*x[3])
#y = P*x
#@test norm(Y - y) <= 1e-12
#
#J = Jacobian(P,x)
#Jfd = jacobian_fd(P,x)
#y = randn(n)
#
#grad = J'*y
#gradfd = Jfd'*y
#
#@test norm(grad[1]-gradfd[1:m1])<1e-6
#@test norm(grad[2]-gradfd[m1+1:m1+m2])<1e-6
#@test norm(grad[3]-gradfd[m1+m2+1:end])<1e-6
#
#testing NonLinearCompose

#with vectors
n,m = 3,4
x = (randn(1,m),randn(n))
A = randn(m,n)
r = randn(1)

P = NonLinearCompose( Eye(1,m), MatrixOp(A) )
y, grad = test_NLop(P,x,r,verb)

Y = x[1]*(A*x[2])
@test norm(Y - y) <= 1e-12

#with matrices
l,m1,m2,n1,n2 = 2,3,4,5,6
x = (randn(m1,m2),randn(n1,n2))
A = randn(l,m1)
B = randn(m2,n1)
r = randn(l,n2)

P = NonLinearCompose( MatrixOp(A,m2), MatrixOp(B,n2) )
y, grad = test_NLop(P,x,r,verb)

Y = A*x[1]*B*x[2]
@test norm(Y - y) <= 1e-12

#further test on gradient with analytical formulas
grad2 =  ((B*x[2])*(A'*r)')', B'*(A*x[1])'*r
@test vecnorm(grad[1]-grad2[1]) <1e-7
@test vecnorm(grad[2]-grad2[2]) <1e-7

#nested NonLinearOp
l1,l2,m1,m2,n1,n2 = 2,3,4,5,6,7
x = (randn(l1,l2),randn(m1,m2),randn(n1,n2))
A = randn(l2,l1)
B = randn(l2,m1)
C = randn(m2,n1)
r = randn(l2,n2)

P1  = NonLinearCompose( MatrixOp(B,m2), MatrixOp(C,n2) )
P = NonLinearCompose( MatrixOp(A,l2), P1 )
y, grad = test_NLop(P,x,r,verb)

Y = A*x[1]*B*x[2]*C*x[3]
@test norm(Y - y) <= 1e-12

#further test on gradient with analytical formulas
grad2 =  A'*(r*(B*x[2]*C*x[3])'), B'*((r'*A*x[1])'*(C*x[3])'), C'*(B*x[2])'*(A*x[1])'*r
@test vecnorm(grad[1]-grad2[1]) <1e-7
@test vecnorm(grad[2]-grad2[2]) <1e-7
@test vecnorm(grad[3]-grad2[3]) <1e-7

## DNN
m,n,l = 4,7,5
b = randn(l)
opS1 = Sigmoid(Float64,(n,),2)
opS2 = Sigmoid(Float64,(n,),2)
opS3 = Sigmoid(Float64,(m,),2)

A1 = HCAT(MatrixMul(b,n) ,Eye(n))
L1 = Compose(opS1,A1)
A2 = NonLinearCompose(Eye(n,n) , L1)
L2 = Compose(opS2,A2)
A3 = NonLinearCompose(Eye(m,n) , L2)
L3 = Compose(opS3,A3)

r = randn(m) 
x = randn.(size(L3,2)) 

y, grad = test_NLop(L3,x,r,verb)

Y = opS3*(x[1]*(opS2*(x[2]*(opS1*(x[3]*b+x[4])))))
@test norm(Y - y) <= 1e-12














