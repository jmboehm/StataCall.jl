# setup.jl

@static if Sys.iswindows()

    # TODO better ways of finding the Stata binary
    function locate_executable()

        # 1.) Environment Variable
        if haskey(ENV,"STATA_BIN")
            return ENV["STATA_BIN"]
        end

        # if we're still here, we have not found the executable
        error("Could not find the Stata executable. Please set the
        \"STATA_BIN\" environment variable.")

    end

    stata_executable = locate_executable()

end

@static if Sys.isapple()

    function locate_executable()

        # try a few common directories
        if isfile("/usr/bin/stata")
            return "/usr/bin/stata"
        elseif isdir("/Applications/Stata/StataSE.app")
            appdir = "/Applications/Stata/StataSE.app"
        elseif isdir("/Applications/Stata/StataMP.app")
            appdir = "/Applications/Stata/StataMP.app"
        elseif isdir("/Applications/Stata/StataIC.app")
            appdir = "/Applications/Stata/StataIC.app"
        elseif isdir("/Applications/StataSE.app")
            appdir = "/Applications/StataSE.app"
        elseif isdir("/Applications/StataMP.app")
            appdir = "/Applications/StataMP.app"
        elseif isdir("/Applications/StataIC.app")
            appdir = "/Applications/StataIC.app"
        else
            appdir = ""
        end

        if (appdir != "") && (isfile(joinpath(appdir, "Contents", "MacOS", "StataMP")))
            return joinpath(appdir, "Contents", "MacOS", "StataMP")
        else

            # try environment variables
            if haskey(ENV,"STATA_BIN")
                return ENV["STATA_BIN"]
            end

            # if we're still here, we have not found the executable
            error("Could not find the Stata executable. Please set the
                \"STATA_BIN\" environment variable or create a symlink
                in /usr/bin/stata that points to the executable.")

        end



    end

    stata_executable = locate_executable()

end

@static if Sys.islinux()

    # TODO

end
