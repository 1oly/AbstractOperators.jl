export LBFGS, update!

"""
`LBFGS(x::Tuple, M::Integer)`

`LBFGS(x::AbstractArray, M::Integer)`

Construct a Limited-Memory BFGS `LinearOperator` with memory `M`. The memory of `LBFGS` can be updated using the function `update!`, where the current iteration variable and gradient (`x`, `grad`) and the previous ones (`x_prev` and `grad_prev`) are needed:

```
julia> L = LBFGS(Float64,(4,),5)
LBFGS  ℝ^4 -> ℝ^4

julia> update!(L,x,x_prev,grad,grad_prev); # update memory

julia> d = L*grad; # compute new direction

```
"""

mutable struct LBFGS{R, T <: BlockArray, M, I <: Integer} <: LinearOperator
	currmem::I
	curridx::I
	s::T
	y::T
	s_M::Array{T, 1}
	y_M::Array{T, 1}
	ys_M::Array{R, 1}
	alphas::Array{R, 1}
	H::R
end

function LBFGS(x::T, M::I) where {T <: BlockArray, I <: Integer}
	s_M = [blockzeros(x) for i = 1:M]
	y_M = [blockzeros(x) for i = 1:M]
	s = blockzeros(x)
	y = blockzeros(x)
	ys_M = zeros(M)
	alphas = zeros(M)
	R = real(eltype(x[1])) 
	LBFGS{R, T, M, I}(0, 0, s, y, s_M, y_M, ys_M, alphas, one(R))
end

function LBFGS(domainType::D, dim::T, M::I) where {D <: Type , 
						   T <: Tuple,  I <: Integer}
	x = blockzeros(domainType, dim)
	return LBFGS(x,M)
end

function LBFGS(domainType::D, dim::T, M::I) where {N, D <: NTuple{N,Type}, 
						   T <: NTuple{N,Tuple},  I <: Integer}
	x = blockzeros(domainType, dim)
	return LBFGS(x,M)
end

function LBFGS(dim::T, M::I) where {T <: Tuple,  I <: Integer}
	x = blockzeros(dim)
	return LBFGS(x,M)
end

"""
`update!(L::LBFGS, x, x_prex, grad, grad_prev)`

See the documentation for `LBFGS`.
"""

function update!(L::LBFGS{R, T, M, I}, x::T, x_prev::T, gradx::T, gradx_prev::T) where {R, T, M, I}
	L.s .= x .- x_prev
	L.y .= gradx .- gradx_prev
	ys = real(blockvecdot(L.s, L.y))
	if ys > 0
		L.curridx += 1
		if L.curridx > M L.curridx = 1 end
		L.currmem += 1
		if L.currmem > M L.currmem = M end
		L.ys_M[L.curridx] = ys
		blockcopy!(L.s_M[L.curridx], L.s)
		blockcopy!(L.y_M[L.curridx], L.y)
		yty = real(blockvecdot(L.y, L.y))
		L.H = ys/yty
	end
	return L
end

# LBFGS operators are symmetric

Ac_mul_B!(x::T, L::LBFGS{R, T, M, I}, y::T) where {R, T, M, I} = A_mul_B!(x, L, y)

# Two-loop recursion

function A_mul_B!(d::T, L::LBFGS{R, T, M, I}, gradx::T) where {R, T, M, I}
	d .= gradx
	idx = loop1!(d,L)
	d .= (*).(L.H, d)
	d = loop2!(d,idx,L)
end

function loop1!(d::T, L::LBFGS{R, T, M, I}) where {R, T, M, I}
	idx = L.curridx
	for i = 1:L.currmem
		L.alphas[idx] = real(blockvecdot(L.s_M[idx], d))/L.ys_M[idx]
		d .-= L.alphas[idx] .* L.y_M[idx]
		idx -= 1
		if idx == 0 idx = M end
	end
	return idx
end

function loop2!(d::T, idx::Int, L::LBFGS{R, T, M, I}) where {R, T, M, I}
	for i = 1:L.currmem
		idx += 1
		if idx > M idx = 1 end
		beta = real(blockvecdot(L.y_M[idx], d))/L.ys_M[idx]
		d .+= (L.alphas[idx] - beta) .* L.s_M[idx]
	end
	return d
end

# Properties
domainType(L::LBFGS{R, T, M}) where {R, T, M} = blockeltype(L.y_M[1])
codomainType(L::LBFGS{R, T, M}) where {R, T, M} = blockeltype(L.y_M[1])

size(A::LBFGS) = (blocksize(A.s), blocksize(A.s))

fun_name(A::LBFGS) = "LBFGS"
