# StataCall

[![Build Status](https://travis-ci.org/jmboehm/StataCall.jl.svg?branch=master)](https://travis-ci.org/jmboehm/StataCall.jl) [![Coverage Status](https://coveralls.io/repos/jmboehm/StataCall.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/jmboehm/StataCall.jl?branch=master)

Allows Stata operations on Julia DataFrames by exporting it to Stata, running a .do file, and re-importing the result into Julia. Requires a copy of Stata. Tested on OSX and Windows.

## Installation

Using julia > 1.0:
```
pkg> add http://github.com/jmboehm/StataCall.jl.git
```

The package tries to detect your Stata executable automatically by seaching in the most common file paths (under OSX). If it does not find it, it expects you to pass it in the `STATA_BIN` environment variable.

## A Quick Example

```julia
srand(1)
ENV["STATA_BIN"] = "C:\\Program Files (x86)\\Stata13\\StataMP-64.exe" # this is my location of the Stata executable
df = DataFrame(myint = Int64.(floor.(100.*rand(Float64, 10))), myfloat = rand(Float64, 10))
instructions = ["gen newvar1 = myint + myfloat";
"gen newvar2 = floor(_n/2)";
"bysort newvar2: egen newvar3 = mean(newvar1)"
]
dfOut = StataCall.stataCall(instructions, df)
```

## Documentation

The main function is `stataCall()`. The full form is

```
stataCall(commands::Array{String,1},
     dfIn::DataFrame, 
     retrieveData::Bool = true, 
     doNotEscapeCharacters::Bool = false,
     quiet::Bool = false
     )
```

* `commands` is a vector of `String` that is the series of statements that you want to pass to Stata.
* `dfIn` is an (optional) `DataFrame` that you want Stata to open before starting to execute the `commands`.
* `retrieveData` is a `Bool` that says whether you want to retrieve the data after your last command. If `true`, it will be returned as a `DataFrame`.
* `doNotEscapeCharacters` is a `Bool` that determines whether the strings in `commands` should be escaped.
* `quiet` is a `Bool` that determines whether the Stata output should be suppressed if everything went well. If the script did not finish, output will be displayed.

The function can also be called without the `dfIn` argument, in which case it starts with an empty dataset.

## TODO

* Log only the body of the Stata output, not headers and footers
* Handle Inf's in DataFrame
* Support Linux; have better way of finding Stata binary under Windows
* Better sync between Julia's variable types and Stata's
* Allow an interactive mode by creating a REPL in Stata and feeding it the commands from Julia. Might be slow because we can pass data only via the hard disk (except under Windows).