__precompile__()

# This package is not written for speed -- if you need to write fast code, you
# should probably not use Stata in the first place. Instead, it should come in
# handy if you would want to use some of Stata's cleaning routines on fairly
# small DataFrames.

# TODO
# - distinguish different versions of Stata, save in a particular version of the dta format
#   to ensure readability
# - read/write of files to/from stata could be better (to ensure variable type)

include("setup.jl")

module StataCallModule

    using DataFrames
    using ReadStat

    executable  = "/Applications/Stata/StataMP.app/Contents/MacOS/StataMP"

    # version without dfIn
    # function StataCall(commands::Array{String,1}, doNotEscapeCharacters::Bool = false, keepLog::Bool = false)
    #
    #
    #
    # end

    function StataCall(commands::Array{String,1}, dfIn::DataFrame, doNotEscapeCharacters::Bool = false, keepLog::Bool = false)

        # Stata can only handle 32-bit Float's and Int's, check that all columns are compatible
        #for col in columns(dfIn)

        id = Base.Dates.datetime2epochms(now())
        csvfilename = string("__$id.csv")
        dtafilename = string("__$id.dta")
        currentDir = pwd()

        if dfIn == DataFrame()
            prefix_commands = []
        else
            writetable(csvfilename, dfIn, header=true, nastring = "")
            prefix_commands = ["import delimited using __$id.csv , varnames(1)"]
        end

        pass_commands = [prefix_commands;
                        commands;
                        "save __$id.dta, replace"
                        ]

        logfilename = StataCall_internal(pass_commands, doNotEscapeCharacters, true)

        if !isfile(dtafilename)
            println("Error running Stata script. Printing log file:")
            run(`cat $logfilename`)
            try
                eraseFile(csvfilename)
            end
            error("Error running the Stata script. Check the log file $logfilename.")
        end

        dfOut = read_dta(dtafilename)

        # clean up
        eraseFile(dtafilename)
        eraseFile(csvfilename)

        # if you want to delete the log too
        if !keepLog
            eraseFile(logfilename)
        end

        return dfOut

    end

    function StataCall_internal(commands::Array{String,1}, doNotEscapeCharacters::Bool = false, keepLog::Bool = true)

        # TODO escape characters

        id = Base.Dates.datetime2epochms(now())
        dofilename = string("__$id.do")
        logfilename = string("__$id.log")
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

       sleep(1)

       eraseFile(dofilename)

       # if you want to delete the log too
       if !keepLog
           eraseFile(string("__$id.log"))
       end

       return logfilename

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
