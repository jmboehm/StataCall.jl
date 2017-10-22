# test the StataCall() functions

using DataFrames

myeps = 1e-5

srand(1)
df = DataFrame(myint = Int64.(floor.(100.*rand(Float64, 10))), myfloat = rand(Float64, 10))
instructions = ["gen newvar1 = myint + myfloat";
"gen newvar2 = floor(_n/2)";
"bysort newvar2: egen newvar3 = mean(newvar1)"
]
dfOut = StataCallModule.StataCall(instructions, df)
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
