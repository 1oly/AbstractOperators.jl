########### Test for LinearOperators
function test_op(A::AbstractOperator, x, y, verb::Bool = false)

  verb && (println(); show(A); println())

  Ax = A*x
  Ax2 = AbstractOperators.deepsimilar(Ax)
  verb && println("forward preallocated")
  A_mul_B!(Ax2, A, x) #verify in-place linear operator works
  verb && @time A_mul_B!(Ax2, A, x)

  @test AbstractOperators.deepvecnorm(Ax .- Ax2) <= 1e-8

  Acy = A'*y
  Acy2 = AbstractOperators.deepsimilar(Acy)
  verb && println("adjoint preallocated")
  Ac_mul_B!(Acy2, A, y) #verify in-place linear operator works
  verb && @time Ac_mul_B!(Acy2, A, y)

  @test AbstractOperators.deepvecnorm(Acy .- Acy2) <= 1e-8

  s1 = AbstractOperators.deepvecdot(Ax2, y)
  s2 = AbstractOperators.deepvecdot(x, Acy2)

  @test abs( s1 - s2 ) < 1e-8

  return Ax
end

########### Test for LinearOperators
function test_NLop(A::AbstractOperator, x, y, verb::Bool = false)

	verb && (println(),println(A))

	Ax = A*x
	Ax2 = AbstractOperators.deepsimilar(Ax)
	verb && println("forward preallocated")
	A_mul_B!(Ax2, A, x) #verify in-place linear operator works
	verb && @time A_mul_B!(Ax2, A, x)

	@test_throws ErrorException A'

	@test AbstractOperators.deepvecnorm(Ax .- Ax2) <= 1e-8

	J = Jacobian(A,x)
	verb && println(J)

	grad = J'*y
	A_mul_B!(Ax2, A, x) #redo forward
	verb && println("jacobian Ac_mul_B! preallocated")
	grad2 = AbstractOperators.deepsimilar(grad)
	Ac_mul_B!(grad2, J, y) #verify in-place linear operator works
	verb && A_mul_B!(Ax2, A, x) #redo forward
	verb && @time Ac_mul_B!(grad2, J, y) 

	@test AbstractOperators.deepvecnorm(grad .- grad2) < 1e-8

	return Ax, grad
end

############# Finite Diff for Jacobian tests

function jacobian_fd{A<:AbstractOperator}(op::A, x0::AbstractArray) # need to have vector input-output
	
	y0 = op*x0
	if size(y0,2) != 1 error("fd jacobian implemented only vectors input-output operators ") end
	J =  zeros(size(op,1)[1],size(op,2)[1])
	h = sqrt(eps())
	for i = 1:size(J,2)
		x = copy(x0)
		x[i] = x[i]+h
		y = op*x
		J[:,i] = (y-y0)/h
	end
	return J
end

jacobian_fd{N,A<:DCAT{N}}(op::A, x0::NTuple{N,AbstractArray}) = jacobian_fd.(op.A,x0) 

function jacobian_fd{M,N}(op::HCAT{M,N}, x0::NTuple{N,AbstractArray}) # need to have vector input-output
	
	y0 = vcat((op*x0)...)
	J =  zeros(length(y0),length(vcat(x0...)))
	h = sqrt(eps())
	c = 1
	for k = 1:N
		for i = 1:length(x0[k])
			x = deepcopy(x0)
			x[k][i] = x[k][i]+h
			y = op*x
			J[:,c] = (vcat(y...)-y0)/h
			c += 1
		end
	end
	return J
end

#function jacobian_fd{N,M}(op::Hadamard{N}, x0::NTuple{M,AbstractArray}) # need to have vector input-output
#	
#	y0 = vcat((op*x0)...)
#	J =  zeros(length(y0),length(vcat(x0...)))
#	h = sqrt(eps())
#	c = 1
#	for k = 1:M
#		for i = 1:length(x0[k])
#			x = deepcopy(x0)
#			x[k][i] = x[k][i]+h
#			y = op*x
#			J[:,c] = (vcat(y...)-y0)/h
#			c += 1
#		end
#	end
#	return J
#end
#
function jacobian_fd(op::NonLinearCompose, x0) # need to have vector input-output
	
	y0 = vcat((op*x0)...)
	J =  zeros(length(y0),sum(length.(x0)) )
	h = sqrt(eps())
	c = 1
	for k = 1:length(x0)
		for i = 1:length(x0[k])
			x = deepcopy(x0)
			x[k][i] = x[k][i]+h
			y = op*x
			J[:,c] = (vcat(y...)-y0)/h
			c += 1
		end
	end
	return J
end

function jacobian_fd{A<:VCAT}(op::A, x0::AbstractArray) # need to have vector input-output
	
	y0 = vcat((op*x0)...)
	J =  zeros(length(y0),length(vcat(x0...)))
	h = sqrt(eps())
	c = 1
		
	for i = 1:length(x0)
		x = deepcopy(x0)
		x[i] = x[i]+h
		y = op*x
		J[:,c] = (vcat(y...)-y0)/h
		c += 1
	end
	return J
end
