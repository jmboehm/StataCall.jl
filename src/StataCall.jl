__precompile__()

module StataCall

    ##############################################################################
    ##
    #   TODO:
    #
    #   FUNCTIONALITY:
    #   -
    #
    #   TECHNICAL:
    #   - distinguish different versions of Stata, save in a particular version of
    #   the dta format to ensure readability
    #   - read/write of files to/from stata could be better (to ensure variable type)
    #   - use tempname() and tempdir() for temporary files
    #
    #   NOTE:
    #   This package is not written for speed -- if you need to write fast code, you
    #   should probably not use Stata in the first place. Instead, it should come in
    #   handy if you would want to use some of Stata's cleaning routines on fairly
    #   small DataFrames.
    #
    ##
    ##############################################################################


    ##############################################################################
    ##
    ## Dependencies
    ##
    ##############################################################################

    using FileIO, StatFiles, DataFrames, CSV, Dates

    ##############################################################################
    ##
    ## Exported methods and types
    ##
    ##############################################################################

    export stataCall

    ##############################################################################
    ##
    ## Load files
    ##
    ##############################################################################

    include("setup.jl")
    include("call.jl")

    executable  = locate_executable()



end # module
