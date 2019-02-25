
struct MPO
  N_::Int
  A_::Vector{ITensor}

  MPO() = new(0,Vector{ITensor}())

  function MPO(N::Int, A::Vector{ITensor})
    new(N,A)
  end
  
  function MPO(sites::SiteSet)
    N = length(sites)
    new(N,fill(ITensor(),N))
  end
  function MPO(sites::SiteSet, ops::Vector{String})
    N = length(sites)
    its = Vector{ITensor}(undef, N)
    spin_sites = Vector{Site}(undef, N)
    link_inds  = Vector{Index}(undef, N)
    for ii in 1:N
        i_is = ops[ii]
        i_site = sites[ii]
        spin_sites[ii] = i_site.dim == 2 ? SpinSite{Val{1//2}}(i_site) : SpinSite{Val{1}}(i_site)
        spin_op = op(spin_sites[ii], i_is)
        link_inds[ii] = Index(1, "Link,n=$ii")
        s = i_site 
        local this_it
        if ii == 1
            this_it = ITensor(link_inds[ii], i_site, i_site')
            this_it[link_inds[ii](1), s[:], s'[:]] = spin_op[s[:], s'[:]]
        elseif ii == N
            this_it = ITensor(link_inds[ii-1], i_site, i_site')
            this_it[link_inds[ii-1](1), s[:], s'[:]] = spin_op[s[:], s'[:]]
        else
            this_it = ITensor(link_inds[ii-1], link_inds[ii], i_site, i_site')
            this_it[link_inds[ii-1](1), link_inds[ii](1), s[:], s'[:]] = spin_op[s[:], s'[:]]
        end
        its[ii] = this_it
    end
    new(N,its)
  end
  MPO(sites::SiteSet, ops::String) = MPO(sites, fill(ops, length(sites)))
end

length(m::MPO) = m.N_

getindex(m::MPO, n::Integer) = getindex(m.A_,n)
setindex!(m::MPO,T::ITensor,n::Integer) = setindex!(m.A_,T,n)

copy(m::MPO) = MPO(m.N_,copy(m.A_))

function show(io::IO,
              W::MPO)
  print(io,"MPO")
  (length(W) > 0) && print(io,"\n")
  for i=1:length(W)
    println(io,"$i  $(W[i])")
  end
end