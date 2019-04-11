# test the StataCall() functions

using DataFrames, Test
using Random
using Missings

myeps = 1e-5

Random.seed!(1)
df = DataFrame(myint = Int64.(floor.(100 .*rand(Float64, 10))), myfloat = rand(Float64, 10))
instructions = ["gen newvar1 = myint + myfloat";
"gen newvar2 = floor(_n/2)";
"bysort newvar2: egen newvar3 = mean(newvar1)"
]
dfOut = StataCall.stataCall(instructions, df)
testOut = [55.236034f0
42.829613
42.829613
52.74826
52.74826
23.081442
23.081442
15.625783
15.625783
85.986664]
for i in 1:length(testOut)
    @test isapprox(dfOut[:newvar3][i], testOut[i], atol = myeps)
end

# With missing values
Random.seed!(1)
df = DataFrame(myint = Int64.(floor.(100 .*rand(Float64, 10))), myfloat = rand(Float64, 10))
df[:myint] = convert(Array{Union{Int64,Missing},1},df[:myint])
df[:myfloat] = convert(Array{Union{Float64,Missing},1},df[:myfloat])
df[4,:myint] = missing
df[2,:myfloat] = missing

instructions = ["gen newvar1 = myint + myfloat";
"gen newvar2 = floor(_n/2)";
"bysort newvar2: egen newvar3 = mean(newvar1)"
]
dfOut = StataCall.stataCall(instructions, df)
testOut = [55.236034
42.312706
42.312706
28.488613
28.488613
23.081442
23.081442
15.625783
15.625783
85.986664]
for i in 1:length(testOut)
    @test isapprox(dfOut[:newvar3][i], testOut[i], atol = myeps)
end