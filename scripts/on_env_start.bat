@echo off

@echo. & echo "astica Art Creator v0.9" & echo.

@cd ..

if exist "scripts\config.bat" (
    @call scripts\config.bat
)

if "%update_branch%"=="" (
    set update_branch=main
)

@>nul grep -c "conda_sd_ui_deps_installed" scripts\install_status.txt
@if "%ERRORLEVEL%" NEQ "0" (
    for /f "tokens=*" %%a in ('python -c "import os; parts = os.getcwd().split(os.path.sep); print(len(parts))"') do if "%%a" NEQ "2" (
        echo. & echo "!!!! WARNING !!!!" & echo.
        echo "Your 'astica-art-creator' folder is at %cd%" & echo.
        echo "The 'astica-art-creator' folder needs to be at the top of your drive, for e.g. 'C:\astica-art-creator' or 'D:\astica-art-creator' etc."
        echo "Not placing this folder at the top of a drive can cause errors on some computers."
        echo. & echo "Recommended: Please close this window and move the 'astica-art-creator' folder to the top of a drive. For e.g. 'C:\astica-art-creator'. Then run the installer again." & echo.
        echo "Not Recommended: If you're sure that you want to install at the current location, please press any key to continue." & echo.

        pause
    )
)

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
        @echo "Error downloading astica Art Creator. Sorry about that, please try to:" & echo "  1. Run this installer again." & echo "Thanks!"
        pause
        @exit /b
    )
)

@xcopy sd-ui-files\ui ui /s /i /Y
@copy sd-ui-files\scripts\on_sd_start.bat scripts\ /Y
@copy "sd-ui-files\scripts\Start astica_Art_Creator.cmd" . /Y

@call scripts\on_sd_start.bat

@pause
