__precompile__()

# This package is not written for speed -- if you need to write fast code, you
# should probably not use Stata in the first place. Instead, it should come in
# handy if you would want to use some of Stata's cleaning routines on fairly
# small DataFrames.

# TODO
# - distinguish different versions of Stata, save in a particular version of the dta format
#   to ensure readability
# - read/write of files to/from stata could be better (to ensure variable type)



module StataCallModule

    using DataFrames
    using ReadStat

    include("setup.jl")

    executable  = locate_executable()

    StataCall(commands::Array{String,1}, retrieveData = true, doNotEscapeCharacters::Bool = false) =
        StataCall_internal(commands, DataFrame(), retrieveData, doNotEscapeCharacters, false)

    StataCall(commands::Array{String,1}, dfIn::DataFrame, retrieveData = true, doNotEscapeCharacters::Bool = false) =
        StataCall_internal(commands, dfIn, retrieveData, doNotEscapeCharacters, false)

    function StataCall_internal(commands::Array{String,1}, dfIn::DataFrame, retrieveData = true, doNotEscapeCharacters::Bool = false, keepLog::Bool = false)

        # this one does the whole thing
        id = Base.Dates.datetime2epochms(now())
        csvfilename = string("__$id.csv")
        dtafilename = string("__$id.dta")
        checkdtafilename = string("__$id.chk.dta") # this is a file that we use to check whether Stata completed successfully
        dofilename = string("__$id.do")
        logfilename = string("__$id.log")
        currentDir = pwd()

        if dfIn == DataFrame()
            in_file = false # we don't need to import anything into Stata
        else
            in_file = true  # wo do need to import
                            # this means we will also need to delete the file later
        end

        # Assemble .do file commands ------------------------------------------

        prefix_commands = [string("// Temporary do-file created by StataCall.jl on ", Dates.format(now(), "e, dd u yyyy HH:MM:SS"), " \n")]
        prefix_commands = [prefix_commands; string("cd ""$currentDir"" ")]
        suffix_commands = [""]

        if in_file == true
            # put the DataFrame into a csv
            writetable(csvfilename, dfIn, header=true, nastring = "")
            # have it imported in Stata
            prefix_commands = [prefix_commands; "import delimited using $csvfilename , varnames(1)"]
        end

        if retrieveData == true
            # we need to export the data from stata to julia
            suffix_commands = [suffix_commands; "save $dtafilename, replace"]
        end

        # write check dta file
        suffix_commands = [suffix_commands; "// StataCall.jl assertation file:"]
        suffix_commands = [suffix_commands; "clear"]
        suffix_commands = [suffix_commands; "set obs 1"]
        suffix_commands = [suffix_commands; "gen check = 1"]
        suffix_commands = [suffix_commands; "save $checkdtafilename, replace"]
        suffix_commands = [suffix_commands; "log close"]

        # Write .csv file ----------------------------------------------------
        open(dofilename, "w") do f
            # write log
            for i in prefix_commands
                write(f, "$i \n")
            end
            # Stata in batch mode automatrically creates a log
            for i in commands
                write(f, "$i \n")
            end
            for i in suffix_commands
                write(f, "$i \n")
            end
            # Stata in batch mode closes automatically
       end

       # Run Stata -----------------------------------------------------------

       runStata(dofilename)

       sleep(1)

       # Check whether Stata completed successfully --------------------------

       if !isfile(checkdtafilename)
           println("Error running Stata script. Printing log file:")
           run(`cat $logfilename`)
           try
               # there was an error... still, clean up
               eraseFile(csvfilename)
               eraseFile(dofilename)
               if isfile(dtafilename)
                   eraseFile(dtafilename)
               end
           end
           error("Error running the Stata script. Check the log file $logfilename.")
       else
           eraseFile(checkdtafilename)
       end

       # If we need to retrieve the Stata file, do that now ------------------

       if retrieveData == true
           dfOut = read_dta(dtafilename)
           eraseFile(dtafilename)
       end

       # Clean up ------------------------------------------------------------

       eraseFile(dofilename)
       if in_file == true
           eraseFile(csvfilename)
       end

       # if you want to delete the log too
       if !keepLog
           eraseFile(logfilename)
       end

       # Return either the output DF or an empty DataFrame -------------------

       if retrieveData == true
           return dfOut
       else
           return DataFrame()
       end

    end

    function runStata(filename::String)
        # "C:\Program Files\Stata15\StataMP" /e do c:\data\bigjob.do
        if is_unix()

            run(`$stata_executable -e $filename`)

        elseif is_windows()

            run(`"$stata_executable" /e do $filename`)

        end
    end

    function eraseFile(filename::String)
        if is_unix()

            run(`rm $filename`)

        elseif is_windows()

        end
    end


end # module
