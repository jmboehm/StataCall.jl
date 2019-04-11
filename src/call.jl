
stataCall(commands::Array{String,1}, retrieveData::Bool = true, doNotEscapeCharacters::Bool = false, quiet::Bool = false) =
    stataCall_internal(commands, DataFrame(), retrieveData=retrieveData, doNotEscapeCharacters=doNotEscapeCharacters, keepLog=false, quiet=quiet)

stataCall(commands::Array{String,1}, dfIn::DataFrame, retrieveData::Bool = true, doNotEscapeCharacters::Bool = false, quiet::Bool = false) =
    stataCall_internal(commands, dfIn, retrieveData=retrieveData, doNotEscapeCharacters=doNotEscapeCharacters, keepLog = false, quiet = quiet)

function stataCall_internal(commands::Array{String,1}, dfIn::DataFrame; retrieveData = true, doNotEscapeCharacters::Bool = false, keepLog::Bool = false, quiet::Bool = false)

    # this one does the whole thing
    id = Dates.datetime2epochms(now())
    currentDir = pwd()
    csvfilename = string(joinpath(currentDir, "__$id.csv"))
    dtafilename = string(joinpath(currentDir, "__$id.dta"))
    checkdtafilename = string(joinpath(currentDir, "__$id.chk.dta")) # this is a file that we use to check whether Stata completed successfully
    dofilename = string(joinpath(currentDir, "__$id.do"))
    logfilename = string(joinpath(currentDir, "__$id.log"))
    

    if dfIn == DataFrame()
        in_file = false # we don't need to import anything into Stata
    else
        in_file = true  # wo do need to import
                        # this means we will also need to delete the file later
    end

    # Assemble .do file commands ------------------------------------------

    prefix_commands = [string("// Temporary do-file created by StataCall.jl on ", Dates.format(now(), "e, dd u yyyy HH:MM:SS"), " \n")]
    prefix_commands = [prefix_commands; string("cd \"$currentDir\" ")]
    suffix_commands = [""]

    if in_file == true
        # put the DataFrame into a csv
        CSV.write(csvfilename, dfIn; missingstring = "")
        # have it imported in Stata
        prefix_commands = [prefix_commands; "import delimited using \"$csvfilename\" , varnames(1) asdouble case(preserve)"]
    end

    if retrieveData == true
        # we need to export the data from stata to julia
        suffix_commands = [suffix_commands; "save \"$dtafilename\", replace"]
    end

    # write check dta file
    suffix_commands = [suffix_commands; "// StataCall.jl assertation file:"]
    suffix_commands = [suffix_commands; "clear"]
    suffix_commands = [suffix_commands; "set obs 1"]
    suffix_commands = [suffix_commands; "gen check = 1"]
    suffix_commands = [suffix_commands; "save \"$checkdtafilename\", replace"]
    suffix_commands = [suffix_commands; "cap log close"]

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
           rm(csvfilename)
           rm(dofilename)
           if isfile(dtafilename)
               rm(dtafilename)
           end
        catch 

       end
       error("Error running the Stata script. Check the log file $logfilename.")
       run(`cat $logfilename`)
   else
       rm(checkdtafilename)
       if quiet==false
          run(`cat $logfilename`)
       end
    #    f = open("$logfilename");
    #    println(readlines(f))
    #    close(f)
   end

   # If we need to retrieve the Stata file, do that now ------------------

   if retrieveData == true
       dfOut = DataFrame(load(dtafilename))
       rm(dtafilename)
   end

   # Clean up ------------------------------------------------------------

   rm(dofilename)
   if in_file == true
       rm(csvfilename)
   end

   # if you want to delete the log too
   if !keepLog
       rm(logfilename)
   end

   # Return either the output DF or an empty DataFrame -------------------

   if retrieveData == true
       return dfOut
   else
       return DataFrame()
   end

end

function runStata(filename::String)

    if Sys.isunix()
        # "/Applications/Stata/StataMP.app/Contents/MacOS/StataMP" -e bigjob.do
        run(`$stata_executable -e $filename`)

    elseif Sys.iswindows()
        # "C:\Program Files\Stata15\StataMP" /e do c:\data\bigjob.do
        run(`"$stata_executable" /e do $filename`)

    end
end
