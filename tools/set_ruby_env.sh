#!/usr/bin/env bash

# Set up Ruby environment using rbenv and run the site build script
# Tested on macOS with zsh

export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init -)"

# Source shell config only if running in interactive zsh
echo $(ruby -v)

# Run the main site build or deployment script
./tools/run.sh

