# test the StataCall() functions

using DataFrames, Base.Test

myeps = 1e-5

srand(1)
df = DataFrame(myint = Int64.(floor.(100.*rand(Float64, 10))), myfloat = rand(Float64, 10))
instructions = ["gen newvar1 = myint + myfloat";
"gen newvar2 = floor(_n/2)";
"bysort newvar2: egen newvar3 = mean(newvar1)"
]
dfOut = StataCall.stataCall(instructions, df)
testOut = [23.555752
32.930912
32.930912
24.527206
24.527206
58.230427
58.230427
62.154037
62.154037
98.85951]
for i in 1:length(testOut)
    @test isapprox(dfOut[:newvar3].data[i], testOut[i], atol = myeps)
end

# With missing values
srand(1)
df = DataFrame(myint = Int64.(floor.(100.*rand(Float64, 10))), myfloat = rand(Float64, 10))
df[4,:myint] = NA
df[2,:myfloat] = NA
instructions = ["gen newvar1 = myint + myfloat";
"gen newvar2 = floor(_n/2)";
"bysort newvar2: egen newvar3 = mean(newvar1)"
]
dfOut = StataCall.stataCall(instructions, df)
testOut = [23.55575
31.42472
31.42472
48.28119
48.28119
58.23043
58.23043
62.15404
62.15404
98.85951]
for i in 1:length(testOut)
    @test isapprox(dfOut[:newvar3].data[i], testOut[i], atol = myeps)
end