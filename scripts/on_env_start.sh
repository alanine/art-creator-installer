#!/bin/bash

printf "\n\nStable Diffusion UI\n\n"

if [ -f "scripts/config.sh" ]; then
    source scripts/config.sh
fi

if [ "$update_branch" == "" ]; then
    export update_branch="main"
fi

if [ -f "scripts/install_status.txt" ] && [ `grep -c sd_ui_git_cloned scripts/install_status.txt` -gt "0" ]; then
    echo "Stable Diffusion UI's git repository was already installed. Updating from $update_branch.."

    cd sd-ui-files

    git reset --hard
    git checkout "$update_branch"
    git pull

    cd ..
else
    printf "\n\nDownloading Stable Diffusion UI..\n\n"
    printf "Using the $update_branch channel\n\n"

    if git clone -b "$update_branch" https://github.com/cmdr2/stable-diffusion-ui.git sd-ui-files ; then
        echo sd_ui_git_cloned >> scripts/install_status.txt
    else
        printf "\n\nError downloading Stable Diffusion UI. Sorry about that, please try to:\n  1. Run this installer again.\n  2. If that doesn't fix it, please try the common troubleshooting steps at https://github.com/cmdr2/stable-diffusion-ui/blob/main/Troubleshooting.md\n  3. If those steps don't help, please copy *all* the error messages in this window, and ask the community at https://discord.com/invite/u9yhsFmEkB\n  4. If that doesn't solve the problem, please file an issue at https://github.com/cmdr2/stable-diffusion-ui/issues\nThanks!\n\n"
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
