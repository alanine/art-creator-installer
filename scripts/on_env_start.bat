@echo off

title astica Art Creator 0.9 & echo.
@echo. & echo "astica Art Creator v0.9" & echo.
@echo working >> scripts\install_status.txt

@cd ..

if exist "scripts\config.bat" (
    @call scripts\config.bat
)

if "%update_branch%"=="" (
    set update_branch=main
)

@>nul grep -c "conda_sd_ui_deps_installed" scripts\install_status.txtecho. 
echo. 
echo. 
echo "You are about to install the astica.org Art Creator"
echo. & echo "Disk space required: 19.2GB"
echo. & echo "This may take 10 - 30 minutes depending on network speed."
echo. & echo "NOTE: Process stuck? Tap enter."
echo. 
echo. 
echo. 

@>nul grep -c "sd_ui_git_cloned" scripts\install_status.txt
@if "%ERRORLEVEL%" EQU "0" (
    @echo "astica Art Creator's git repository was already installed. Updating from %update_branch%.."

    @cd sd-ui-files

    @call git reset --hard
    @call git checkout "%update_branch%"
    @call git pull

    @cd ..
) else (
    @echo. & echo "Downloading astica Art Creator.." & echo.
    @echo "Using the %update_branch% channel" & echo.

    @call git clone -b "%update_branch%" https://github.com/alanine/art-creator-installer.git sd-ui-files && (
        @echo sd_ui_git_cloned >> scripts\install_status.txt
    ) || (
        @echo "Error downloading astica Art Creator. Sorry about that, please try to:" & echo "  1. Run this installer again." & echo "  2. Send a screenshot of the error to help@artificialdesign.org" & echo "Thanks!"
        pause
        @exit /b
    )
)

@xcopy sd-ui-files\ui ui /s /i /Y
@copy sd-ui-files\scripts\on_sd_start.bat scripts\ /Y
@copy "sd-ui-files\scripts\Start astica_Art_Creator.cmd" . /Y

@call scripts\on_sd_start.bat

@pause
