@printf("\nTesting linear operators\n")

verb = true

######## Conv ############
n,m = 5, 6
h = randn(m)
op = Conv(Float64,(n,),h)
x1 = randn(n)
y1 = test_op(op, x1, randn(n+m-1), verb)
y2 = conv(x1,h)

@test all(vecnorm.(y1 .- y2) .<= 1e-12)
# other constructors
op = Conv(x1,h)

######### DCT ############
n = 4
op = DCT(Float64,(n,))
x1 = randn(n)
y1 = test_op(op, x1, randn(n), verb)
y2 = dct(x1)

@test all(vecnorm.(y1 .- y2) .<= 1e-12)

# other constructors
op = DCT((n,)) 
op = DCT(n,n) 
op = DCT(Complex{Float64}, n,n) 

######### IDCT ############
n = 4
op = IDCT(Float64,(n,))
x1 = randn(n)
y1 = test_op(op, x1, randn(n), verb)
y2 = idct(x1)

@test all(vecnorm.(y1 .- y2) .<= 1e-12)

# other constructors
op = IDCT((n,)) 
op = IDCT(n,n) 
op = IDCT(Complex{Float64}, n,n) 

######### DFT ############
n = 4
op = DFT(Float64,(n,))
x1 = randn(n)
y1 = test_op(op, x1, fft(randn(n)), verb)
y2 = fft(x1)

@test all(vecnorm.(y1 .- y2) .<= 1e-12)

op = DFT(Complex{Float64},(n,))
x1 = randn(n)+im*randn(n)
y1 = test_op(op, x1, fft(randn(n)), verb)
y2 = fft(x1)

@test all(vecnorm.(y1 .- y2) .<= 1e-12)

# other constructors
op = DFT((n,)) 
op = DFT(n,n) 
op = DFT(Complex{Float64}, n,n) 

######### IDFT ############
n = 4
op = IDFT(Float64,(n,))
x1 = randn(n)
y1 = test_op(op, x1, fft(randn(n)), verb)
y2 = ifft(x1)

@test all(vecnorm.(y1 .- y2) .<= 1e-12)

op = IDFT(Complex{Float64},(n,))
x1 = randn(n)+im*randn(n)
y1 = test_op(op, x1, fft(randn(n)), verb)
y2 = ifft(x1)

@test all(vecnorm.(y1 .- y2) .<= 1e-12)

# other constructors
op = IDFT((n,)) 
op = IDFT(n,n) 
op = IDFT(Complex{Float64}, n,n) 

######### DiagOp ############
n = 4
d = randn(n)
op = DiagOp(Float64,(n,),d)
x1 = randn(n)
y1 = test_op(op, x1, randn(n), verb)
y2 = d.*x1

@test all(vecnorm.(y1 .- y2) .<= 1e-12)

# other constructors
op = DiagOp(d) 
op = DiagOp(Float64, d)

######### Eye ############
n = 4
op = Eye(Float64,(n,))
x1 = randn(n)
y1 = test_op(op, x1, randn(n), verb)

@test all(vecnorm.(y1 .- x1) .<= 1e-12)

# other constructors
op = Eye(Float64, (n,))
op = Eye((n,)) 
op = Eye(n) 

######### Filt ############
n,m = 15,2
b,a = [1.;0.;1.;0.;0.], [1.;1.;1.]
op = Filt(Float64,(n,),b,a)
x1 = randn(n)
y1 = test_op(op, x1, randn(n), verb)
y2 = filt(b, a, x1)

@test all(vecnorm.(y1 .- y2) .<= 1e-12)

h = randn(10)
op = Filt(Float64,(n,m),h)
x1 = randn(n,m)
y1 = test_op(op, x1, randn(n,m), verb)
y2 = filt(h, [1.], x1)

@test all(vecnorm.(y1 .- y2) .<= 1e-12)

# other constructors
Filt(n,  b, a)
Filt((n,m),  b, a) 
Filt(n,  h) 
Filt((n,),  h) 
Filt(x1, b, a) 
Filt(x1, b) 

######### FiniteDiff ############
n= 10
op = FiniteDiff(Float64,(n,))
x1 = randn(n)
y1 = test_op(op, x1, randn(n), verb)
y1 = op*collect(linspace(0,1,n))
@test all(vecnorm.(y1 .- 1/9) .<= 1e-12)

n,m= 10,5
op = FiniteDiff(Float64,(n,m))
x1 = randn(n,m)
y1 = test_op(op, x1, randn(n,m), verb)
y1 = op*repmat(collect(linspace(0,1,n)),1,m)
@test all(vecnorm.(y1 .- 1/9) .<= 1e-12)

n,m= 10,5
op = FiniteDiff(Float64,(n,m),2)
x1 = randn(n,m)
y1 = test_op(op, x1, randn(n,m), verb)
y1 = op*repmat(collect(linspace(0,1,n)),1,m)
@test all(vecnorm.(y1) .<= 1e-12)

n,m,l= 10,5,7
op = FiniteDiff(Float64,(n,m,l))
x1 = randn(n,m,l)
y1 = test_op(op, x1, randn(n,m,l), verb)
y1 = op*reshape(repmat(collect(linspace(0,1,n)),1,m*l),n,m,l)
@test all(vecnorm.(y1 .- 1/9) .<= 1e-12)

n,m,l= 10,5,7
op = FiniteDiff(Float64,(n,m,l),2)
x1 = randn(n,m,l)
y1 = test_op(op, x1, randn(n,m,l), verb)
y1 = op*reshape(repmat(collect(linspace(0,1,n)),1,m*l),n,m,l)
@test all(vecnorm.(y1) .<= 1e-12)

n,m,l= 10,5,7
op = FiniteDiff(Float64,(n,m,l),3)
x1 = randn(n,m,l)
y1 = test_op(op, x1, randn(n,m,l), verb)
y1 = op*reshape(repmat(collect(linspace(0,1,n)),1,m*l),n,m,l)
@test all(vecnorm.(y1) .<= 1e-12)

@test_throws ErrorException op = FiniteDiff(Float64,(n,m,l,3))
@test_throws ErrorException op = FiniteDiff(Float64,(n,m,l), 4)

## other constructors
FiniteDiff((n,m)) 
FiniteDiff(x1)

######### GetIndex ############
n,m = 5,4
k = 3
op = GetIndex(Float64,(n,),(1:k,))
x1 = randn(n)
y1 = test_op(op, x1, randn(k), verb)

@test all(vecnorm.(y1 .- x1[1:k]) .<= 1e-12)

n,m = 5,4
k = 3
op = GetIndex(Float64,(n,m),(1:k,:))
x1 = randn(n,m)
y1 = test_op(op, x1, randn(k,m), verb)

@test all(vecnorm.(y1 .- x1[1:k,:]) .<= 1e-12)

# other constructors
GetIndex((n,m), (1:k,:))
GetIndex(x1, (1:k,:)) 

@test_throws ErrorException op = GetIndex(Float64,(n,m),(1:k,:,:))
op = GetIndex(Float64,(n,m),(1:n,1:m))
@test typeof(op) <: Eye

######### MatrixOp ############

n,m = 5,4
A = randn(n,m)
op = MatrixOp(Float64,(m,),A)
x1 = randn(m)
y1 = test_op(op, x1, randn(n), verb)
y2 = A*x1

@test all(vecnorm.(y1 .- y2) .<= 1e-12)

c = 3
op = MatrixOp(Float64,(m,c),A)
@test_throws ErrorException op = MatrixOp(Float64,(m,c,3),A)
x1 = randn(m,c)
y1 = test_op(op, x1, randn(n,c), verb)
y2 = A*x1

# other constructors
op = MatrixOp(A)
op = MatrixOp(Float64, A) 
op = MatrixOp(A, c)
op = MatrixOp(Float64, A, c) 

######### MIMOFilt ############
m,n = 10,2
b = [[1.;0.;1.;0.;0.],[1.;0.;1.;0.;0.]]
a = [[1.;1.;1.],[2.;2.;2.]]
op = MIMOFilt(Float64, (m,n), b, a)

x1 = randn(m,n)
y1 = test_op(op, x1, randn(m,1), verb)
y2 = filt(b[1],a[1],x1[:,1])+filt(b[2],a[2],x1[:,2])

@test all(vecnorm.(y1 .- y2) .<= 1e-12)

m,n = 10,2
b = [[1.;0.;1.;0.;0.],[1.;0.;1.;0.;0.],[1.;0.;1.;0.;0.],[1.;0.;1.;0.;0.] ]
a = [[1.;1.;1.],[2.;2.;2.],[1.],[1.]]
op = MIMOFilt(Float64, (m,n), b, a)

x1 = randn(m,n)
y1 = test_op(op, x1, randn(m,2), verb)
y2 = [filt(b[1],a[1],x1[:,1])+filt(b[2],a[2],x1[:,2]) filt(b[3],a[3],x1[:,1])+filt(b[4],a[4],x1[:,2])]

@test all(vecnorm.(y1 .- y2) .<= 1e-12)

m,n = 10,3
b = [randn(10),randn(5),randn(10),randn(2),randn(10),randn(10)]
a = [[1.],[1.],[1.],[1.],[1.],[1.]]
op = MIMOFilt(Float64, (m,n), b, a)

x1 = randn(m,n)
y1 = test_op(op, x1, randn(m,2), verb)
y2 = [filt(b[1],a[1],x1[:,1])+filt(b[2],a[2],x1[:,2])+filt(b[3],a[3],x1[:,3]) filt(b[4],a[4],x1[:,1])+filt(b[5],a[5],x1[:,2])+filt(b[6],a[6],x1[:,3])]

@test all(vecnorm.(y1 .- y2) .<= 1e-12)

## other constructors
MIMOFilt((10,3),  b, a)
MIMOFilt((10,3),  b) 
MIMOFilt(x1,  b, a) 
MIMOFilt(x1,  b) 

#errors
@test_throws ErrorException op = MIMOFilt(Float64, (10,3,2) ,b,a)
a2 = [[1.0f0],[1.0f0],[1.0f0],[1.0f0],[1.0f0],[1.0f0]]
b2 = convert.(Array{Float32,1},b)
@test_throws ErrorException op = MIMOFilt(Float64, (m,n),b2,a2)
@test_throws ErrorException op = MIMOFilt(Float64, (m,n),b,a[1:end-1])
push!(a2,[1.0f0])
push!(b2,randn(Float32,10))
@test_throws ErrorException op = MIMOFilt(Float32, (m,n),b2,a2)
a[1][1] = 0.
@test_throws ErrorException op = MIMOFilt(Float64, (m,n) ,b,a)

######## Variation ############

n,m = 10,5
op = Variation(Float64,(n,m))
x1 = randn(n,m)
y1 = test_op(op, x1, randn(m*n,2), verb)

y1 = op*repmat(collect(linspace(0,1,n)),1,m)
@test all(vecnorm.(y1[:,1] .- 1/(n-1) ) .<= 1e-12)
@test all(vecnorm.(y1[:,2] ) .<= 1e-12)

n,m,l = 10,5,3
op = Variation(Float64,(n,m,l))
x1 = randn(n,m,l)
y1 = test_op(op, x1, randn(m*n*l,3), verb)

y1 = op*reshape(repmat(collect(linspace(0,1,n)),1,m*l),n,m,l)
@test all(vecnorm.(y1[:,1] .- 1/(n-1) ) .<= 1e-12)
@test all(vecnorm.(y1[:,2] ) .<= 1e-12)
@test all(vecnorm.(y1[:,3] ) .<= 1e-12)

### other constructors
Variation(Float64, n,m)
Variation((n,m)) 
Variation(n,m)
Variation(x1) 

##errors
@test_throws ErrorException op = Variation(Float64,(n,m,l,4))
@test_throws ErrorException op = Variation(Float64,(n,))

######### Xcorr ############
n,m = 5, 6
h = randn(m)
op = Xcorr(Float64,(n,),h)
x1 = randn(n)
y1 = test_op(op, x1, randn(n+m), verb)
y2 = xcorr(x1, h)

@test all(vecnorm.(y1 .- y2) .<= 1e-12)
# other constructors
op = Xcorr(x1,h)

######## ZeroPad ############
n = (3,)
z = (5,)
op = ZeroPad(Float64,n,z)
x1 = randn(n)
y1 = test_op(op, x1, randn(n.+z), verb)
@test all(vecnorm.(y1 .- [x1;zeros(5)] ) .<= 1e-12)

n = (3,2)
z = (5,3)
op = ZeroPad(Float64,n,z)
x1 = randn(n)
y1 = test_op(op, x1, randn(n.+z), verb)
y2 = zeros(n.+z)
y2[1:n[1],1:n[2]] = x1
@test all(vecnorm.(y1 .- y2 ) .<= 1e-12)

n = (3,2,2)
z = (5,3,1)
op = ZeroPad(Float64,n,z)
x1 = randn(n)
y1 = test_op(op, x1, randn(n.+z), verb)
y2 = zeros(n.+z)
y2[1:n[1],1:n[2],1:n[3]] = x1
@test all(vecnorm.(y1 .- y2 ) .<= 1e-12)

# other constructors
ZeroPad(n, z...)
ZeroPad(Float64, n, z...) 
ZeroPad(n, z...) 
ZeroPad(x1, z) 
ZeroPad(x1, z...) 

#errors
@test_throws ErrorException op = ZeroPad(Float64,n,(1,2))
@test_throws ErrorException op = ZeroPad(Float64,n,(1,-2,3))
@test_throws ErrorException op = ZeroPad(Float64,(1,2,3,4),(1,2,3,4))

######### Zeros ############
n = (3,4)
D = Float64
m = (5,2)
C = Complex{Float64}
op = Zeros(D,n,C,m)
x1 = randn(n)
y1 = test_op(op, x1, randn(m)+im*randn(m), verb)
