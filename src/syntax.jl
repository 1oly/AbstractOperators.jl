import Base: blkdiag, transpose, *, +, -, getindex, hcat, vcat, reshape

###### blkdiag ######
blkdiag(L::Vararg{LinearOperator}) = DCAT(L...)

###### ' ######
transpose{T <: LinearOperator}(L::T) = Transpose(L)

######+,-######
(+){T <: LinearOperator}(L::T) = L
(-){T <: LinearOperator}(L::T) = Scale(-1.0, L)
(+)(L1::LinearOperator, L2::LinearOperator) = Sum(L1,  L2 )
(-)(L1::LinearOperator, L2::LinearOperator) = Sum(L1, -L2 )

###### * ######
function (*){T <: Union{AbstractArray, Tuple}}(L::LinearOperator, b::T)
	y = deepzeros(codomainType(L), size(L, 1))
	A_mul_B!(y, L, b)
	return y
end

*{T<:Number}(coeff::T, L::LinearOperator) = Scale(coeff,L)
*(L1::LinearOperator, L2::LinearOperator) = Compose(L1,L2)

# redefine .*
Base.broadcast(::typeof(*), d::AbstractArray, L::LinearOperator) = DiagOp(codomainType(L), d)*L
Base.broadcast(::typeof(*), d::AbstractArray, L::Scale)          = DiagOp(L.coeff*d)*L.A

# getindex
# slice only output 
function getindex(A::LinearOperator,idx...) 
	Gout = GetIndex(codomainType(A),size(A,1),idx)
	return Gout*A
end

# commented for the moment, maybe doesn't make sense and prone to errors
## slice output and input e.g. G[idx_out...][idx_in...] 
#function getindex{L<:Compose}(A::L,idx...) 
#	if typeof(A.A[end]) <: GetIndex
#		Gin = GetIndex(codomainType(A.A[1]),size(A.A[1],2),idx)
#		return A*Gin'
#	else
#		Gout = GetIndex(codomainType(A),size(A,1),idx)
#		return Gout*A
#	end
#end

#slicing an HCAT gives an HCAT
function getindex{M,N,L<:HCAT{M,N}}(A::L,idx) 
	HCAT(A.A[idx],A.mid,M)
end
#or the operator at idx
getindex{L<:HCAT}(A::L,idx::Int) = A.A[idx]

#slicing an VCAT gives a VCAT
function getindex{M,N,L<:VCAT{M,N}}(A::L,idx) 
	VCAT(A.A[idx],A.mid,N)
end
#or the operator at idx
getindex{L<:VCAT}(A::L,idx::Int) = A.A[idx]

#TODO slicing DCAT

hcat(L::Vararg{LinearOperator}) = HCAT(L...)
vcat(L::Vararg{LinearOperator}) = VCAT(L...)

###### reshape ######
reshape{N,A<:LinearOperator}(L::A, idx::NTuple{N,Int}) = Reshape(L,idx)
reshape{A<:LinearOperator}(L::A, idx::Vararg{Int}) = Reshape(L,idx)
