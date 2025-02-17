## This is getting closer still working on it. No need to review
## Failing for CUDA mostly with eigen (I believe there is some noise in
## eigen decomp with CUBLAS to give slightly different answer than BLAS)
module TestITensorDMRG
using ITensors
using NDTensors
using NDTensors.CUDAExtensions: cu
using Random

reference_energies = Dict([
  (4, -1.6160254037844384), (8, -3.374932598687889), (10, -4.258035207282885)
])

is_broken(dev, elt::Type, conserve_qns::Val) = false
is_broken(dev::typeof(cu), elt::Type, conserve_qns::Val{true}) = true

include("dmrg.jl")

end
