export DFT, IDFT

abstract type FourierTransform{N,C,D,T1,T2} <: LinearOperator end

"""
`DFT([domainType=Float64::Type,] dim_in::Tuple)`

`DFT(dim_in...)`

`DFT(x::AbstractArray)`

Creates a `LinearOperator` which, when multiplied with an array `x::AbstractArray{N}`, returns the `N`-dimensional Discrete Fourier Transform of `x`. 

```julia
julia> DFT(Complex{Float64},(10,10))
ℱ  ℂ^(10, 10) -> ℂ^(10, 10) 

julia> DFT(10,10)
ℱ  ℝ^(10, 10) -> ℂ^(10, 10) 

julia> A = DFT(ones(3))
ℱ  ℝ^3 -> ℂ^3

julia> A*ones(3)
3-element Array{Complex{Float64},1}:
 3.0+0.0im
 0.0+0.0im
 0.0+0.0im
```

"""

immutable DFT{N,
	      C<:RealOrComplex,
	      D<:RealOrComplex,
	      T1<:Base.DFT.Plan,
	      T2<:Base.DFT.Plan} <: FourierTransform{N,C,D,T1,T2}
	dim_in::NTuple{N,Int}
	A::T1
	At::T2
end


"""
`IDFT([domainType=Float64::Type,] dim_in::Tuple)`

`IDFT(dim_in...)`

`IDFT(x::AbstractArray)`

Creates a `LinearOperator` which, when multiplied with an array `x::AbstractArray{N}`, returns the `N`-dimensional Inverse Discrete Fourier Transform of `x`. 

```julia
julia> IDFT(Complex{Float64},(10,10))
ℱ  ℂ^(10, 10) -> ℂ^(10, 10) 

julia> IDFT(10,10)
ℱ  ℝ^(10, 10) -> ℂ^(10, 10) 

julia> A = IDFT(ones(3))
ℱ  ℝ^(10, 10) -> ℂ^(10, 10)

julia> A*ones(3)
3-element Array{Complex{Float64},1}:
 1.0+0.0im
 0.0+0.0im
 0.0+0.0im
```

"""

immutable IDFT{N,
	       C<:RealOrComplex,
	       D<:RealOrComplex,
	       T1<:Base.DFT.Plan,
	       T2<:Base.DFT.Plan} <: FourierTransform{N,C,D,T1,T2}
	dim_in::NTuple{N,Int}
	A::T1
	At::T2
end

# Constructors
#standard constructor
DFT{N}(dim_in::NTuple{N,Int}) = DFT(zeros(dim_in))

function DFT{N,D<:Real}(x::AbstractArray{D,N})
	A,At = plan_fft(x), plan_bfft(fft(x))
	DFT{N,Complex{D},D,typeof(A),typeof(At)}(size(x),A,At)
end

function DFT{N,D<:Complex}(x::AbstractArray{D,N})
	A,At = plan_fft(x), plan_bfft(fft(x))
	DFT{N,D,D,typeof(A),typeof(At)}(size(x),A,At)
end

DFT{N}(T::Type,dim_in::NTuple{N,Int}) = DFT(zeros(T,dim_in))
DFT(dim_in::Vararg{Int}) = DFT(dim_in)
DFT(T::Type,dim_in::Vararg{Int}) = DFT(T,dim_in)

function IDFT{N,D<:Real}(x::AbstractArray{D,N})
	A,At = plan_ifft(x), plan_fft(ifft(x))
	IDFT{N,Complex{D},D,typeof(A),typeof(At)}(size(x),A,At)
end

#standard constructor
IDFT{N}(T::Type,dim_in::NTuple{N,Int}) = IDFT(zeros(T,dim_in))

function IDFT{N,D<:Complex}(x::AbstractArray{D,N})
	A,At = plan_ifft(x), plan_fft(ifft(x))
	IDFT{N,D,D,typeof(A),typeof(At)}(size(x),A,At)
end

IDFT{N}(dim_in::NTuple{N,Int}) = IDFT(zeros(dim_in))
IDFT(dim_in::Vararg{Int}) = IDFT(dim_in)
IDFT(T::Type,dim_in::Vararg{Int}) = IDFT(T,dim_in)

# Mappings

function A_mul_B!{N,C<:Complex,T1,T2}(y::AbstractArray{C,N},
				      L::DFT{N,C,C,T1,T2},
				      b::AbstractArray{C,N})
	A_mul_B!(y,L.A,b)
end

function A_mul_B!{N,C<:Complex,D<:Real,T1,T2}(y::AbstractArray{C,N},
					      L::DFT{N,C,D,T1,T2},
					      b::AbstractArray{D,N})
	A_mul_B!(y,L.A,complex(b))
end

function Ac_mul_B!{N,C<:Complex,T1,T2}(y::AbstractArray{C,N},
				       L::DFT{N,C,C,T1,T2},
				       b::AbstractArray{C,N})
	A_mul_B!(y,L.At,b)
end

function Ac_mul_B!{N,C<:Complex,D<:Real,T1,T2}(y::AbstractArray{D,N},
					      L::DFT{N,C,D,T1,T2},
					      b::AbstractArray{C,N})
	y2 = complex(y)
	A_mul_B!(y2,L.At,b)
	y .= real.(y2)
end

function A_mul_B!{N,C<:Complex,T1,T2}(y::AbstractArray{C,N},
				      L::IDFT{N,C,C,T1,T2},
				      b::AbstractArray{C,N})
	A_mul_B!(y,L.A,b)
end

function A_mul_B!{N,C<:Complex,D<:Real,T1,T2}(y::AbstractArray{C,N},
					      L::IDFT{N,C,D,T1,T2},
					      b::AbstractArray{D,N})
	A_mul_B!(y,L.A,complex(b))
end

function Ac_mul_B!{N,C<:Complex,T1,T2}(y::AbstractArray{C,N},
				       L::IDFT{N,C,C,T1,T2},
				       b::AbstractArray{C,N})
	A_mul_B!(y,L.At,b)
	y ./= length(b)
end

function Ac_mul_B!{N,C<:Complex,D<:Real,T1,T2}(y::AbstractArray{D,N},
					       L::IDFT{N,C,D,T1,T2},
					       b::AbstractArray{C,N})

	y2 = complex(y)
	A_mul_B!(y2,L.At,b)
	y .= (/).(real.(y2), length(b))
end

# Properties

size(L::FourierTransform) = (L.dim_in,L.dim_in)

fun_name(A::DFT) = "ℱ"
fun_name(A::IDFT) = "ℱ^(-1)"

domainType{N,C,D,T1,T2}(L::FourierTransform{N,C,D,T1,T2}) = D
codomainType{N,C,D,T1,T2}(L::FourierTransform{N,C,D,T1,T2}) = C

is_AcA_diagonal(L::FourierTransform)     = true
is_AAc_diagonal(L::FourierTransform)     = true
is_invertible(L::FourierTransform)       = true
is_full_row_rank(L::FourierTransform)    = true
is_full_column_rank(L::FourierTransform) = true

diag_AcA(L::DFT) = prod(size(L,1))
diag_AAc(L::DFT) = prod(size(L,1))

diag_AcA(L::IDFT) = 1/prod(size(L,1))
diag_AAc(L::IDFT) = 1/prod(size(L,1))
