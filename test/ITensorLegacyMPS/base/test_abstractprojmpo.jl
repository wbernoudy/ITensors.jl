using ITensors
using Random
using Test

@testset "AbstractProjMPO (eltype=$elt, conserve_qns=$conserve_qns)" for elt in (
    Float32, Float64, Complex{Float32}, Complex{Float64}
  ),
  conserve_qns in [false, true]

  n = 4
  s = siteinds("S=1/2", n; conserve_qns)
  o = MPO(elt, s, "I")
  x = MPS(elt, s, j -> isodd(j) ? "↑" : "↓")
  pmpo = ProjMPO(o)
  position!(pmpo, x, 2)
  @testset "ProjMPO (storage=$storage)" for storage in (identity, ITensors.disk)
    po = storage(pmpo)

    # `AbstractProjMPO` interface.
    @test ITensors.nsite(po) == 2
    @test ITensors.site_range(po) == 2:3
    @test eltype(po) == elt
    @test isnothing(ITensors.checkflux(po))
    po_contracted = contract(po, ITensor(one(Bool)))
    @test po_contracted isa ITensor
    @test ndims(po_contracted) == 8
    @test eltype(po_contracted) == elt

    # Specific to `ProjMPO`.
    @test lproj(po) isa ITensor
    @test ndims(lproj(po)) == 3
    @test eltype(lproj(po)) == elt
    @test rproj(po) isa ITensor
    @test ndims(rproj(po)) == 3
    @test eltype(rproj(po)) == elt
  end
  @testset "ProjMPOSum (storage=$storage)" for storage in (identity, ITensors.disk)
    po = storage(ProjMPOSum([pmpo, pmpo]))

    # `AbstractProjMPO` interface.
    @test ITensors.nsite(po) == 2
    @test ITensors.site_range(po) == 2:3
    @test eltype(po) == elt
    @test isnothing(ITensors.checkflux(po))
    po_contracted = contract(po, ITensor(one(Bool)))
    @test po_contracted isa ITensor
    @test ndims(po_contracted) == 8
    @test eltype(po_contracted) == elt

    # Specific to `ProjMPOSum`.
    @test length(ITensors.terms(po)) == 2
  end
  @testset "ITensors.ProjMPS" begin
    # TODO: Replace with `ProjOuter`, make it into
    # a proper `AbstractProjMPO`.
    px = ITensors.ProjMPS(x)
    position!(px, x, 2)

    # `AbstractProjMPO` interface.
    @test ITensors.nsite(px) == 2
    @test ITensors.site_range(px) == 2:3
    @test_broken eltype(px) == elt
    @test isnothing(ITensors.checkflux(px))
    @test_broken contract(px, ITensor(one(Bool)))
  end
  @testset "ITensors.ProjMPO_MPS" begin
    # TODO: Replace with `ProjOuter`, make it into
    # a proper `AbstractProjMPO`.
    po = ITensors.ProjMPO_MPS(o, [x])
    position!(po, x, 2)

    # `AbstractProjMPO` interface.
    @test ITensors.nsite(po) == 2
    @test ITensors.site_range(po) == 2:3
    @test_broken eltype(po) == elt
    @test isnothing(ITensors.checkflux(po))
    @test_broken contract(po, ITensor(one(Bool)))
  end
end
