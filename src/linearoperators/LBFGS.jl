export LBFGS, update!

"""
`LBFGS(T::Type, dim::Tuple, Memory::Int)`

`LBFGS{N}(T::NTuple{N,Type}, dim::NTuple{N,Tuple}, M::Int)`

`LBFGS(x::AbstractArray, Memory::Int)`

Construct a Limited-Memory BFGS `LinearOperator` with memory `M`. The memory of `LBFGS` can be updated using the function `update!`, where the current iteration variable and gradient (`x`, `grad`) and the previous ones (`x_prev` and `grad_prev`) are needed:

```
julia> L = LBFGS(Float64,(4,),5)
LBFGS  ℝ^4 -> ℝ^4

julia> update!(L,x,x_prev,grad,grad_prev); #update memory

julia> d = L*x;                            #compute new direction

```
"""

mutable struct LBFGS{R, T <: BlockArray, M} <: LinearOperator
	currmem::Int
	curridx::Int
	s::T
	y::T
	s_m::NTuple{M, T}
	y_m::NTuple{M, T}
	ys_m::Array{R, 1}
	alphas::Array{R, 1}
	H::R
end

# Constructors

function LBFGS(T::Type, dim::NTuple{N,Int}, M::Int) where {N}
	s_m = tuple([deepzeros(T,dim) for i = 1:M]...)
	y_m = tuple([deepzeros(T,dim) for i = 1:M]...)
	s = deepzeros(T,dim)
	y = deepzeros(T,dim)
	R = real(T)
	ys_m = zeros(R, M)
	alphas = zeros(R, M)
	LBFGS{M,N,R,T,typeof(s)}(0, 0, s, y, s_m, y_m, ys_m, alphas, one(R))
end

function LBFGS(x::T, M::Int)

end

"""
`update!(L::LBFGS, x, x_prex, grad, grad_prev)`

See `LBFGS` documentation.

"""

function update!(L::LBFGS{M,N,R,T,A},
		 x::A,
		 x_prev::A,
		 gradx::A,
		 gradx_prev::A) where {M,N,R,T,A}

	ys = update_s_y(L,x,x_prev,gradx,gradx_prev)

	if ys > 0
		L.curridx += 1
		if L.curridx > M L.curridx = 1 end
		L.currmem += 1
		if L.currmem > M L.currmem = M end


		yty = update_s_m_y_m(L,L.curridx)
		L.ys_m[L.curridx] = ys
		L.H = ys/yty
	end
	return L
end

function update_s_y(L::LBFGS{M,N,R,T,A}, x::A, x_prev::A, gradx::A, gradx_prev::A) where {M,N,R,T,A}
	L.s .= (-).(x, x_prev)
	L.y .= (-).(gradx, gradx_prev)
	ys = real(vecdot(L.s,L.y))
	return ys
end

function update_s_m_y_m(L::LBFGS{M,N,R,T,A}, curridx::Int) where {M,N,R,T,A}
	L.s_m[curridx] .=  L.s
	L.y_m[curridx] .=  L.y

	yty = real(vecdot(L.y,L.y))
	return yty
end

function A_mul_B!(d::A, L::LBFGS{M,N,R,T,A}, gradx::A) where {M,N,R,T,A}
	d .= (-).(gradx)
	idx = loop1!(d,L)
	d .= (*).(L.H, d)
	d = loop2!(d,idx,L)
end

function loop1!(d::A, L::LBFGS{M,N,R,T,A}) where {M,N,R,T,A}
	idx = L.curridx
	for i=1:L.currmem
		L.alphas[idx] = real(vecdot(L.s_m[idx], d))/L.ys_m[idx]
		d .-= L.alphas[idx].*L.y_m[idx]
		idx -= 1
		if idx == 0 idx = M end
	end
	return idx
end

function loop2!(d::A, idx::Int, L::LBFGS{M,N,R,T,A}) where {M,N,R,T,A}
	for i=1:L.currmem
		idx += 1
		if idx > M idx = 1 end
		beta = real(vecdot(L.y_m[idx], d))/L.ys_m[idx]
		d .+= (L.alphas[idx].-beta).*L.s_m[idx]
	end
	return d
end

# Properties
  domainType(L::LBFGS{R, T, M}) where {R, T, M} = T
codomainType(L::LBFGS{R, T, M}) where {R, T, M} = T

size(A::LBFGS) = (size(A.s), size(A.s))

fun_name(A::LBFGS) = "LBFGS"
