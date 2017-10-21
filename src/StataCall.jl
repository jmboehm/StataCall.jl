__precompile__()

# This package is not written for speed -- if you need to write fast code, you
# should probably not use Stata in the first place. Instead, it should come in
# handy if you would want to use some of Stata's cleaning routines on fairly
# small DataFrames.

include("setup.jl")

module StataCallModule

    using DataFrames

    executable  = "/Applications/Stata/StataMP.app/Contents/MacOS/StataMP"

    function StataCall(command::String)
        StataCall([command])
    end

    function StataCall(commands::Array{String,1}, doNotEscapeCharacters::Bool = false, keepLog::Bool = false)

        # TODO escape characters

        id = Base.Dates.datetime2epochms(now())
        dofilename = string("__$id.do")
        currentDir = pwd()

        open(dofilename, "w") do f
            # write log
            write(f, string("// Temporary do-file created by StataCall.jl on ", Dates.format(now(), "e, dd u yyyy HH:MM:SS"), " \n\n"))
            write(f, string("cd ""$currentDir"" \n"))
            # Stata in batch mode automatrically creates a log
            #write(f, string("log\n"))# using $id.log\n"))
            for i in commands
                write(f, "$i \n")
            end
            write(f, string("log close \n"))
            #write(f, string("quit() \n"))
       end

       runStata(dofilename)

       sleep(2)

       eraseFile(dofilename)

       # if you want to delete the log too
       if !keepLog
           eraseFile(string("__$id.log"))
       end

    end

    function runStata(filename::String)
        # "C:\Program Files\Stata15\StataMP" /e do c:\data\bigjob.do
        if is_unix()

            run(`$executable -e $filename`)

        elseif is_windows()

        end
    end

    function eraseFile(filename::String)
        if is_unix()

            run(`rm $filename`)

        elseif is_windows()

        end
    end


end # module
