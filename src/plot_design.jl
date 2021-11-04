
using Makie
import Makie.plot
using StatsBase
using SparseArrays
function plot(X::Unfold.DesignMatrix;standardize=true,sort=false)

    designmat = Unfold.get_Xs(X);
    if standardize
        designmat = designmat ./ std(designmat,dims=1)
        designmat[isinf.(designmat)] .= 1.
    end
    if sort
        designmat = Base.sort(designmat,dims=1)
    end
    labels = Unfold.get_coefnames(X)

    if isa(designmat, SparseMatrixCSC)
        @assert(!sort,"Sorting does not make sense for timeexpanded designmatrices")
        designmat = Matrix(designmat[end÷2-2000:end÷2+2000,:])
    end
    # plot Designmatrix
    fig, ax, hm = heatmap(designmat',axis=(xticks=(1:length(labels),labels),xticklabelrotation = pi/8),)
    Colorbar(fig[1,2],hm)
    
    return fig
end

function plot2(X::Unfold.DesignMatrix;standardize=true,sort=false)

    # plot events on top
    hline!()
end