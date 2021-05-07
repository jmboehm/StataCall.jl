#!/bin/bash

# This is the bash script that buildkite uses to automatically build the project

set -uo pipefail

echo "--- :package: Build job checkout directory"

pwd
ls -la

echo "--- :evergreen_tree: Build job environment"

env

echo "+++ :hammer: Running Julia to test:"

mkdir artifacts

STATA_BIN='C:\Program Files\Stata16\StataMP-64.exe' julia --project -e 'using Pkg; try Pkg.test(); exit(0); catch; exit(1) end' >> artifacts/build.log
status=$?

if [ $status -eq 0 ]; then
	echo -e "Pipeline successfully run! 👍"
    echo -e "Exiting. Have a great day!"
    exit 0
fi

echo -e "Pipeline failed! Check artifacts/build.log for details."
echo -e "Exiting."
exit 1
