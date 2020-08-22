#!/bin/bash

# when run in Linux, dotnet libraries
# we use depend on "libcurl3" so install it
apt-get install -y libcurl3

# go to extension workspace folder and
# install all yarn dependencies
cd $CODESPACE_ROOT/vscode
yarn install

# restore the solution in the root
cd $CODESPACE_ROOT
dotnet restore

# generate the TS times for the contracts
dotnet restore $CODESPACE_ROOT/Tools/TypescriptGenerator/LiveShare.TypescriptGenerator.csproj

# for some reason we need to webpack web
# extension to be able to run the nodejs version
cd $CODESPACE_ROOT/vscode/liveshare/web
yarn webpack

# gulp release the project
cd $CODESPACE_ROOT/vscode/extension
yarn global add gulp
gulp release && yarn compile

## done, ask to open the [liveshare.code-workspace] file 🎉

LIVESHARE_WORKSPACE_FILE_NAME="liveshare.code-workspace"
LIVESHARE_WORKSPACE_FILE_PATH=$(realpath "$CODESPACE_DEFAULT_PATH/../liveshare/liveshare.code-workspace")

echo -e "$PALETTE_CYAN\n💡  Do you want to open $PALETTE_PURPLE$LIVESHARE_WORKSPACE_FILE_NAME$PALETTE_CYAN file?$PALETTE_RESET [Y/n] \n"

printf "Answer: "
read ANSWER

LOWERCASE_ANSWER=$(echo "$ANSWER" | tr '[:upper:]' '[:lower:]')

if [ "$LOWERCASE_ANSWER" = "y" ] || [ -z "$LOWERCASE_ANSWER" ]; then
    OPEN_WP="code -r \"$LIVESHARE_WORKSPACE_FILE_PATH\""
    echo -e "\nalias code:wp='$OPEN_WP'" >> ~/.bashrc

    eval $OPEN_WP
fi
