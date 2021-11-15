# TullioStatistics.jl

![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)<!--
![Lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-stable-green.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-retired-orange.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-archived-red.svg)
![Lifecycle](https://img.shields.io/badge/lifecycle-dormant-blue.svg) -->
[![Build Status](https://travis-ci.com/tbeason/TullioStatistics.jl.svg?branch=master)](https://travis-ci.com/tbeason/TullioStatistics.jl)
[![codecov.io](http://codecov.io/github/tbeason/TullioStatistics.jl/coverage.svg?branch=master)](http://codecov.io/github/tbeason/TullioStatistics.jl?branch=master)





TullioStatistics.jl uses [Tullio.jl](https://github.com/mcabbott/Tullio.jl) paired with [LoopVectorization.jl](https://github.com/chriselrod/LoopVectorization.jl) to speed up some basic statistics functions. Compared to Julia's [Statistics Standard Library](https://docs.julialang.org/en/v1/stdlib/Statistics/) and other packages, the functions here should typically be faster but less flexible and perhaps sometimes less accurate.


## Important Notes

1. Some of the speedup comes from multithreading! Be sure to start Julia with multiple threads via `julia -t auto` for automatic selection or `julia -t X` where `X` is the number of threads you'd like to use.

2. NONE OF THE FUNCTIONS ARE CURRENTLY EXPORTED. You must explicitly call into the module, i.e. `TullioStatistics.mean`. Namespace collisions are just too annoying to deal with right now, so this package just tries to hide from them.

3. These functions use the naive algorithms for computing their statistics, thus they do not attempt to avoid "catastrophic cancellation". If you believe catastrophic cancellation could occur in your situation, you should not be using this package.

4. Inputs must be indexable (support `getindex`). General iterators will not work. This implies that nice things like `skipmissing(X)` must be first sent through `collect`.

5. Functions like `median`, `quantile`, and `percentile` are not implemented. These statistics require sorting the input data, which is not an area in which Tullio adds value.

6. Currently, only `AbstractVector` and `AbstractMatrix` inputs are allowed. Extending to higher dimensional arrays is likely possible with generated functions, but it is not as straightforward.

7. No weighted statistics are currently implemented.


## Univariate Statistics

For inputs of `AbstractVector` and `AbstractMatrix`, we have `mean`, `std`, `var`, `min`, `max`, `range`, `middle`, `skewness`, `kurtosis`. If the input is a matrix, you can supply the `dims` argument with values from `{:,1,2}` (`:` is default) as with the existing implementations. In all cases, you can optionally supply a function as the first argument, such as `mean(f,x)`, which will compute the requested statistic of `f.(x)` (in a fast, non-allocating manner).

This package also includes functions for computing moving window (sometimes called rolling window) statistics. I have found them to be significantly faster than the existing implementations in other packages, without much loss in flexibility. Each of the functions listed above has a corresponding moving window function prefixed by `moving` (e.g. `movingmean` and `movingstd`). Supplying a function `f` is also possible here, as well as computing the statistic only along rows or columns of a matrix with `dims`. The window is supplied as a range of relative indices, such as `-2:0` for a 3-term backward looking window. Moving window output is by default padded to the length of the input (disable with `padded=false`) and the padding is done using `padvalue` (`missing` by default).



## Bivariate Statistics

This package also implements `cov`, `cor`, `coskewness`, `cokurtosis`. I intend to make moving window versions  available of these as well.


## Examples & Benchmarks

```julia
using TullioStatistics, Statistics, BenchmarkTools

A = rand(100);

TullioStatistics.mean(A) ≈ mean(A) # true
@btime mean($A) # 11.300 ns (0 allocations: 0 bytes)
@btime TullioStatistics.mean($A) # 10.100 ns (0 allocations: 0 bytes)

TullioStatistics.mean(log,A) ≈ mean(log,A) # true
@btime mean($(log),$A) # 388.235 ns (0 allocations: 0 bytes)
@btime TullioStatistics.mean($(log),$A) # 174.835 ns (0 allocations: 0 bytes)


B = rand(100,20);

TullioStatistics.mean(B) ≈ mean(B) # true
@btime mean($B) # 102.139 ns (0 allocations: 0 bytes)
@btime TullioStatistics.mean($B) # 78.306 ns (0 allocations: 0 bytes)

TullioStatistics.mean(B,dims=1) ≈ mean(B,dims=1) # true
@btime mean($B,dims=$1) # 319.824 ns (7 allocations: 848 bytes)
@btime TullioStatistics.mean($B,dims=$1) # 166.493 ns (2 allocations: 480 bytes)

TullioStatistics.mean(B,dims=2) ≈ mean(B,dims=2) # true
@btime mean($B,dims=$2) # 606.286 ns (11 allocations: 1.55 KiB)
@btime TullioStatistics.mean($B,dims=$2) # 162.687 ns (2 allocations: 1.75 KiB)
```


```julia
using TullioStatistics, StatsBase, BenchmarkTools

A = rand(100);

isapprox(TullioStatistics.skewness(A), skewness(A))
@btime skewness($A)
@btime TullioStatistics.skewness($A)
```