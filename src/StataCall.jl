__precompile__()

# This package is not written for speed -- if you need to write fast code, you
# should probably not use Stata in the first place. Instead, it should come in
# handy if you would want to use some of Stata's cleaning routines on fairly
# small DataFrames.

include("setup.jl")

module StataCall

    using DataFrames

    executable  = "/Applications/Stata/StataMP.app/Contents/MacOS/StataMP"

    function StataCall(command::String)

        # "C:\Program Files\Stata15\StataMP" /e do c:\data\bigjob.do

    end


end # module
