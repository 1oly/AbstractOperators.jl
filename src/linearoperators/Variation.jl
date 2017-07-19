export Variation

immutable Variation{T,N} <: LinearOperator
	dim_in::NTuple{N,Int}
end

# Constructors
#default constructor
function Variation{N}(domainType::Type, dim_in::NTuple{N,Int}) 
	N == 1 && error("use FiniteDiff instead!")
	Variation{domainType,N}(dim_in)
end

Variation(domainType::Type, dim_in::Vararg{Int}) = Variation(domainType, dim_in)
Variation{N}(dim_in::NTuple{N,Int}) = Variation(Float64, dim_in)
Variation(dim_in::Vararg{Int}) = Variation(dim_in)
Variation(x::AbstractArray)  = Variation(eltype(x), size(x))

# Mappings

#TODO use @generated
@generated function A_mul_B!{T,N}(y::AbstractArray{T,2}, A::Variation{T,N}, b::AbstractArray{T,N})

	ex = :()

	for i = 1:N
		z = zeros(Int,N)
		z[i] = 1
		z = (z...)
		ex = :($ex; y[cnt,$i] = I[$i] == 1 ? b[I+CartesianIndex($z)]-b[I] : 
		       b[I]-b[I-CartesianIndex($z)])
	end

	ex2 = quote 
		cnt = 0
		for I in CartesianRange(size(b))
			cnt += 1
			$ex
		end
		return y
	end
end

@generated function Ac_mul_B!{T,N}(y::AbstractArray{T,N}, A::Variation{T,N}, b::AbstractArray{T,2})

	ex = :(y[I] = I[1] == 1  ? -(b[cnt,1] + b[cnt+1,1]) :
	              I[1] == 2  ?   b[cnt,1] + b[cnt-1,1] - b[cnt+1,1] :
	       I[1] == size(y,1) ?   b[cnt,1] : b[cnt,  1] - b[cnt+1,1]
	       )

	Nx = :(size(y,1))
	for i = 2:N
		ex = quote 
			$ex 
			y[I] += I[$i] == 1  ? -(b[cnt,$i] + b[cnt+$Nx,$i]) :
			        I[$i] == 2  ?   b[cnt,$i] + b[cnt-$Nx,$i] - b[cnt+$Nx,$i] :
			        I[$i] == size(y,$i) ?   b[cnt,$i] : b[cnt,  $i]   - b[cnt+$Nx,$i]
		end
		Nx = :($Nx*size(y,$i))
	end

	ex2 = quote 
		cnt = 0
		for I in CartesianRange(size(y))
			cnt += 1
			$ex
		end
		return y
	end
end

# Properties

domainType{T,N}(L::Variation{T,N}) = T
codomainType{T,N}(L::Variation{T,N}) = T

size{T,N}(L::Variation{T,N}) = ((prod(L.dim_in), N), L.dim_in)

fun_name(L::Variation)  = "Ʋ"
