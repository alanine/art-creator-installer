@echo off

@echo. & echo "Stable Diffusion UI - v2.1" & echo.

@cd ..

for /f "tokens=*" %%a in ('python -c "import os; parts = os.getcwd().split(os.path.sep); print(len(parts))"') do if "%%a" NEQ "2" (
    echo. & echo "!!!! WARNING !!!!" & echo.
    echo "Your 'stable-diffusion-ui' folder is at %cd%" & echo.
    echo "The 'stable-diffusion-ui' folder needs to be at the top of your drive, for e.g. 'C:\stable-diffusion-ui' or 'D:\stable-diffusion-ui' etc."
    echo "Not placing this folder at the top of a drive can cause errors on some computers."
    echo. & echo "Recommended: Please close this window and move the 'stable-diffusion-ui' folder to the top of a drive. For e.g. 'C:\stable-diffusion-ui'. Then run the installer again." & echo.
    echo "Not Recommended: If you're sure that you want to install at the current location, please press any key to continue." & echo.

    pause
)

@>nul grep -c "sd_ui_git_cloned" scripts\install_status.txt
@if "%ERRORLEVEL%" EQU "0" (
    @echo "Stable Diffusion UI's git repository was already installed. Updating.."

    @cd sd-ui-files

    @call git reset --hard
    @call git pull

    @cd ..
) else (
    @echo. & echo "Downloading Stable Diffusion UI.." & echo.

    @call git clone https://github.com/cmdr2/stable-diffusion-ui.git sd-ui-files && (
        @echo sd_ui_git_cloned >> scripts\install_status.txt
    ) || (
        @echo "Error downloading Stable Diffusion UI. Please try re-running this installer. If it doesn't work, please copy the messages in this window, and ask the community at https://discord.com/invite/u9yhsFmEkB or file an issue at https://github.com/cmdr2/stable-diffusion-ui/issues"
        pause
        @exit /b
    )
)

@xcopy sd-ui-files\ui ui /s /i /Y
@copy sd-ui-files\scripts\on_sd_start.bat scripts\ /Y
@copy "sd-ui-files\scripts\Start Stable Diffusion UI.cmd" . /Y

@call scripts\on_sd_start.bat