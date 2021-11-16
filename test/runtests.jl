using TullioStatistics
using Test
using Statistics
using StableRNGs

rng = StableRNG(111)

A = rand(rng,100);

@test TullioStatistics.mean(A) ≈ mean(A)
