
function eraseFile(filename::String)

    Base.Filesystem.rm(filename)

    # if is_unix()
    #
    #     run(`rm $filename`)
    #
    # elseif is_windows()
    #
    # end
end
