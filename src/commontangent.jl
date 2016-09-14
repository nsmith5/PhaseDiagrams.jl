import Base: expand

export commontangent

function isconvex(i, j, k, arr)
    @assert i < j < k
    slope = (arr[k]-arr[i])/(k-i)
    val = arr[i] + slope*(j-i)
    return arr[j] < val
end

function isstartingpoint(i, arr)
    return !isconvex(i-1, i, i+1, arr)
end

function expand(region::Tuple{Int, Int}, arr::Vector)
    left = region[1]
    right = region[2]
    # Expand left
    if left != 1 && !isconvex(left-1, left, right, arr)
        left -= 1
    end
    if right != length(arr) && !isconvex(left, right, right+1, arr)
        right += 1
    end
    return (left, right)
end

function mergeregions!(regions::Vector{Tuple{Int, Int}})
    i = 1
    while i < endof(regions)
        if regions[i][2] >= regions[i+1][1]
            regions[i] = (regions[i][1], regions[i+1][2])
            deleteat!(regions, i+1)
        end
        i += 1
    end
end

"""
    commontanget{T}(arr::Vector{T})

Given an array of values find the regions that are concave. Returns an array of
tuples of indices where the array is concave between these indices.
"""
function commontangent{T}(arr::Vector{T})
    N = length(arr)
    convexregions = Tuple{Int, Int}[]

    # Find starting points
    for i in 2:(N-1)
        isstartingpoint(i, arr) ? push!(convexregions, (i-1, i+1)) : continue
    end
    mergeregions!(convexregions)

    oldregions = Tuple{Int, Int}[]

    while oldregions != convexregions
        oldregions = copy(convexregions)
        for i in eachindex(convexregions)
            convexregions[i] = expand(convexregions[i], arr)
        end
        mergeregions!(convexregions)
    end
    return convexregions
end



