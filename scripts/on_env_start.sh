#!/bin/bash

printf "\n\nastica Art Creator\n\n"

if [ -f "scripts/config.sh" ]; then
    source scripts/config.sh
fi

if [ "$update_branch" == "" ]; then
    export update_branch="main"
fi

if [ -f "scripts/install_status.txt" ] && [ `grep -c sd_ui_git_cloned scripts/install_status.txt` -gt "0" ]; then
    echo "astica Art Creator's git repository was already installed. Updating from $update_branch.."

    cd sd-ui-files

    git reset --hard
    git checkout "$update_branch"
    git pull

    cd ..
else
    printf "\n\nDownloading astica Art Creator..\n\n"
    printf "Using the $update_branch channel\n\n"

    if git clone -b "$update_branch" https://github.com/alanine/art-creator-installer.git sd-ui-files ; then
        echo sd_ui_git_cloned >> scripts/install_status.txt
    else
        printf "\n\nError downloading astica Art Creator. Sorry about that, please try to:\n  1. Run this installer again.\n  \nThanks!\n\n"
        read -p "Press any key to continue"
        exit
    fi
fi

rm -rf ui
cp -Rf sd-ui-files/ui .
cp sd-ui-files/scripts/on_sd_start.sh scripts/
cp sd-ui-files/scripts/start.sh .

./scripts/on_sd_start.sh

read -p "Press any key to continue"
