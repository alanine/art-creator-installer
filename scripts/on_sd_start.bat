@echo off

@copy sd-ui-files\scripts\on_env_start.bat scripts\ /Y

@REM Caution, this file will make your eyes and brain bleed. It's such an unholy mess.
@REM Note to self: Please rewrite this in Python. For the sake of your own sanity.

@call python -c "import os; import shutil; frm = 'sd-ui-files\\ui\\hotfix\\9c24e6cd9f499d02c4f21a033736dabd365962dc80fe3aeb57a8f85ea45a20a3.26fead7ea4f0f843f6eb4055dfd25693f1a71f3c6871b184042d4b126244e142'; dst = os.path.join(os.path.expanduser('~'), '.cache', 'huggingface', 'transformers', '9c24e6cd9f499d02c4f21a033736dabd365962dc80fe3aeb57a8f85ea45a20a3.26fead7ea4f0f843f6eb4055dfd25693f1a71f3c6871b184042d4b126244e142'); shutil.copyfile(frm, dst) if os.path.exists(dst) else print(''); print('Hotfixed broken JSON file from OpenAI');"

@>nul grep -c "sd_git_cloned" scripts\install_status.txt
@if "%ERRORLEVEL%" EQU "0" (
    @echo "astica Art Creator's git repository was already installed. Updating.."

    @cd astica-art-creator

    @call git reset --hard
    @call git pull
    @call git checkout f6cfebffa752ee11a7b07497b8529d5971de916c

    @call git apply ..\ui\sd_internal\ddim_callback.patch
    @call git apply ..\ui\sd_internal\env_yaml.patch

    @cd ..
) else (
    @echo. & echo "Downloading astica Art Creator.." & echo.

    @call git clone https://github.com/alanine/art-creator && (
        @echo sd_git_cloned >> scripts\install_status.txt
    ) || (
        @echo "Error downloading astica Art Creator. Sorry about that, please try to:" & echo "  1. Run this installer again." & echo "Thanks!"
        pause
        @exit /b
    )

    @cd astica-art-creator
    @call git checkout f6cfebffa752ee11a7b07497b8529d5971de916c

    @call git apply ..\ui\sd_internal\ddim_callback.patch
    @call git apply ..\ui\sd_internal\env_yaml.patch

    @cd ..
)

@cd astica-art-creator

@>nul grep -c "conda_sd_env_created" ..\scripts\install_status.txt
@if "%ERRORLEVEL%" EQU "0" (
    @echo "Packages necessary for astica Art Creator were already installed"

    @call conda activate .\env
) else (
    @echo. & echo "Downloading packages necessary for astica Art Creator.." & echo. & echo "***** This will take some time (depending on the speed of the Internet connection) and may appear to be stuck, but please be patient ***** .." & echo.

    @rmdir /s /q .\env

    @REM prevent conda from using packages from the user's home directory, to avoid conflicts
    @set PYTHONNOUSERSITE=1

    @call conda env create --prefix env -f install/art-creator/environment.yaml || (
        @echo. & echo "Error installing the packages necessary for astica Art Creator. Sorry about that, please try to:" & echo "  1. Run this installer again." & echo "Thanks!" & echo.
        pause
        exit /b
    )

    @call conda activate .\env

    @call conda install -c conda-forge -y --prefix env antlr4-python3-runtime=4.8 || (
        @echo. & echo "Error installing antlr4-python3-runtime for astica Art Creator. Sorry about that, please try to:" & echo "  1. Run this installer again." & echo "Thanks!" & echo.
        pause
        exit /b
    )

    for /f "tokens=*" %%a in ('python -c "import torch; import ldm; import transformers; import numpy; import antlr4; print(42)"') do if "%%a" NEQ "42" (
        @echo. & echo "Dependency test failed! Error installing the packages necessary for astica Art Creator. Sorry about that, please try to:" & echo "  1. Run this installer again." & echo "Thanks!" & echo.
        pause
        exit /b
    )

    @echo conda_sd_env_created >> ..\scripts\install_status.txt
)

@>nul grep -c "conda_sd_gfpgan_deps_installed" ..\scripts\install_status.txt
@if "%ERRORLEVEL%" EQU "0" (
    @echo "Packages necessary for GFPGAN (Face Correction) were already installed"
) else (
    @echo. & echo "Downloading packages necessary for astica.org face optimization.." & echo.

    @set PYTHONNOUSERSITE=1

    @call pip install -e git+https://github.com/TencentARC/GFPGAN#egg=GFPGAN || (
        @echo. & echo "Error installing the packages necessary for face optimization. Sorry about that, please try to:" & echo "  1. Run this installer again." & echo "Thanks!" & echo.
        pause
        exit /b
    )

    @call pip install basicsr==1.4.2 || (
        @echo. & echo "Error installing the basicsr package necessary for face optimization. Sorry about that, please try to:" & echo "  1. Run this installer again." & echo "Thanks!" & echo.
        pause
        exit /b
    )

    for /f "tokens=*" %%a in ('python -c "from gfpgan import GFPGANer; print(42)"') do if "%%a" NEQ "42" (
        @echo. & echo "Dependency test failed! Error installing the packages necessary for face optimization. Sorry about that, please try to:" & echo "  1. Run this installer again." & echo "Thanks!" & echo.
        pause
        exit /b
    )

    @echo conda_sd_gfpgan_deps_installed >> ..\scripts\install_status.txt
)

@>nul grep -c "conda_sd_esrgan_deps_installed" ..\scripts\install_status.txt
@if "%ERRORLEVEL%" EQU "0" (
    @echo "Packages necessary for upscale optimization were already installed"
) else (
    @echo. & echo "Downloading packages necessary for upscale optimization.." & echo.

    @set PYTHONNOUSERSITE=1

    @call pip install -e git+https://github.com/xinntao/Real-ESRGAN#egg=realesrgan || (
        @echo. & echo "Error installing the packages necessary for upscale optimization. Sorry about that, please try to:" & echo "  1. Run this installer again." & echo "Thanks!" & echo.
        pause
        exit /b
    )

    for /f "tokens=*" %%a in ('python -c "from basicsr.archs.rrdbnet_arch import RRDBNet; from realesrgan import RealESRGANer; print(42)"') do if "%%a" NEQ "42" (
        @echo. & echo "Dependency test failed! Error installing the packages necessary for upscale optimization. Sorry about that, please try to:" & echo "  1. Run this installer again." & echo "Thanks!" & echo.
        pause
        exit /b
    )

    @echo conda_sd_esrgan_deps_installed >> ..\scripts\install_status.txt
)

@>nul grep -c "conda_sd_ui_deps_installed" ..\scripts\install_status.txt
@if "%ERRORLEVEL%" EQU "0" (
    echo "Packages necessary for astica Art Creator were already installed"
) else (
    @echo. & echo "Downloading packages necessary for astica Art Creator UI.." & echo.

    @set PYTHONNOUSERSITE=1

    @call conda install -c conda-forge -y --prefix env uvicorn fastapi || (
        echo "Error installing the packages necessary for astica Art Creator. Sorry about that, please try to:" & echo "  1. Run this installer again." & echo "Thanks!"
        pause
        exit /b
    )
)

call WHERE uvicorn > .tmp
@>nul grep -c "uvicorn" .tmp
@if "%ERRORLEVEL%" NEQ "0" (
    @echo. & echo "Packages not found! Sorry about that, please try to:" & echo "  1. Run this installer again." & echo "Thanks!" & echo.
    pause
    exit /b
)

@>nul grep -c "conda_sd_ui_deps_installed" ..\scripts\install_status.txt
@if "%ERRORLEVEL%" NEQ "0" (
    @echo conda_sd_ui_deps_installed >> ..\scripts\install_status.txt
)



@if exist "sd-v1-4.ckpt" (
    for %%I in ("sd-v1-4.ckpt") do if "%%~zI" EQU "4265380512" (
        echo "Data files (weights) necessary for astica Art Creator were already downloaded"
    ) else (
        for %%J in ("sd-v1-4.ckpt") do if "%%~zJ" EQU "7703807346" (
            echo "Data files (weights) necessary for astica Art Creator were already downloaded"
        ) else (
            for %%K in ("sd-v1-4.ckpt") do if "%%~zK" EQU "7703810927" (
                echo "Data files (weights) necessary for astica Art Creator were already downloaded"
            ) else (
                echo. & echo "The model file present at %cd%\sd-v1-4.ckpt is invalid. It is only %%~zK bytes in size. Re-downloading.." & echo.
                del "sd-v1-4.ckpt"
            )
        )
    )
)

@if not exist "sd-v1-4.ckpt" (
    @echo. & echo "Downloading data files (weights) for astica Art Creator.." & echo.

    @call curl -L -k https://me.cmdr2.org/stable-diffusion-ui/sd-v1-4.ckpt > sd-v1-4.ckpt

    @if exist "sd-v1-4.ckpt" (
        for %%I in ("sd-v1-4.ckpt") do if "%%~zI" NEQ "4265380512" (
            echo. & echo "Error: The downloaded model file was invalid! Bytes downloaded: %%~zI" & echo.
            echo. & echo "Error downloading the data files (weights) for astica Art Creator. Sorry about that, please try to:" & echo "  1. Run this installer again." & echo "Thanks!" & echo.
            pause
            exit /b
        )
    ) else (
        @echo. & echo "Error downloading the data files (weights) for astica Art Creator. Sorry about that, please try to:" & echo "  1. Run this installer again." & echo "Thanks!" & echo.
        pause
        exit /b
    )
)



@if exist "GFPGANv1.3.pth" (
    for %%I in ("GFPGANv1.3.pth") do if "%%~zI" EQU "348632874" (
        echo "Data files (weights) necessary for face correction were already downloaded"
    ) else (
        echo. & echo "The GFPGAN model file present at %cd%\GFPGANv1.3.pth is invalid. It is only %%~zI bytes in size. Re-downloading.." & echo.
        del "GFPGANv1.3.pth"
    )
)

@if not exist "GFPGANv1.3.pth" (
    @echo. & echo "Downloading data files (weights) for face correction.." & echo.

    @call curl -L -k https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.3.pth > GFPGANv1.3.pth

    @if exist "GFPGANv1.3.pth" (
        for %%I in ("GFPGANv1.3.pth") do if "%%~zI" NEQ "348632874" (
            echo. & echo "Error: The downloaded face correction model file was invalid! Bytes downloaded: %%~zI" & echo.
            echo. & echo "Error downloading the data files (weights) for face correction. Sorry about that, please try to:" & echo "  1. Run this installer again." & echo "Thanks!" & echo.
            pause
            exit /b
        )
    ) else (
        @echo. & echo "Error downloading the data files (weights) for face correction. Sorry about that, please try to:" & echo "  1. Run this installer again." & echo "Thanks!" & echo.
        pause
        exit /b
    )
)



@if exist "RealESRGAN_x4plus.pth" (
    for %%I in ("RealESRGAN_x4plus.pth") do if "%%~zI" EQU "67040989" (
        echo "Data files (weights) necessary for upscale optimization x4plus were already downloaded"
    ) else (
        echo. & echo "The upscale optimization model file present at %cd%\RealESRGAN_x4plus.pth is invalid. It is only %%~zI bytes in size. Re-downloading.." & echo.
        del "RealESRGAN_x4plus.pth"
    )
)

@if not exist "RealESRGAN_x4plus.pth" (
    @echo. & echo "Downloading data files (weights) for upscale optimization x4plus.." & echo.

    @call curl -L -k https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth > RealESRGAN_x4plus.pth

    @if exist "RealESRGAN_x4plus.pth" (
        for %%I in ("RealESRGAN_x4plus.pth") do if "%%~zI" NEQ "67040989" (
            echo. & echo "Error: The downloaded upscale optimization x4plus model file was invalid! Bytes downloaded: %%~zI" & echo.
            echo. & echo "Error downloading the data files (weights) for upscale optimization x4plus. Sorry about that, please try to:" & echo "  1. Run this installer again." & echo "Thanks!" & echo.
            pause
            exit /b
        )
    ) else (
        @echo. & echo "Error downloading the data files (weights) for upscale optimization x4plus. Sorry about that, please try to:" & echo "  1. Run this installer again." & echo "Thanks!" & echo.
        pause
        exit /b
    )
)



@if exist "RealESRGAN_x4plus_anime_6B.pth" (
    for %%I in ("RealESRGAN_x4plus_anime_6B.pth") do if "%%~zI" EQU "17938799" (
        echo "Data files (weights) necessary for upscale optimization x4plus_anime were already downloaded"
    ) else (
        echo. & echo "The upscale optimization model file present at %cd%\RealESRGAN_x4plus_anime_6B.pth is invalid. It is only %%~zI bytes in size. Re-downloading.." & echo.
        del "RealESRGAN_x4plus_anime_6B.pth"
    )
)

@if not exist "RealESRGAN_x4plus_anime_6B.pth" (
    @echo. & echo "Downloading data files (weights) for upscale optimization x4plus_anime.." & echo.

    @call curl -L -k https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.2.4/RealESRGAN_x4plus_anime_6B.pth > RealESRGAN_x4plus_anime_6B.pth

    @if exist "RealESRGAN_x4plus_anime_6B.pth" (
        for %%I in ("RealESRGAN_x4plus_anime_6B.pth") do if "%%~zI" NEQ "17938799" (
            echo. & echo "Error: The downloaded upscale optimization model file was invalid! Bytes downloaded: %%~zI" & echo.
            echo. & echo "Error downloading the data files (weights) for upscale optimization x4plus_anime. Sorry about that, please try to:" & echo "  1. Run this installer again." & echo "Thanks!" & echo.
            pause
            exit /b
        )
    ) else (
        @echo. & echo "Error downloading the data files (weights) for upscale optimization x4plus_anime. Sorry about that, please try to:" & echo "  1. Run this installer again." & echo "Thanks!" & echo.
        pause
        exit /b
    )
)



@>nul grep -c "sd_install_complete" ..\scripts\install_status.txt
@if "%ERRORLEVEL%" NEQ "0" (
    @echo sd_weights_downloaded >> ..\scripts\install_status.txt
    @echo sd_install_complete >> ..\scripts\install_status.txt
)

@echo. & echo "astica Art Creator is now ready!" & echo.

@set SD_DIR=%cd%

@cd env\lib\site-packages
@set PYTHONPATH=%SD_DIR%;%cd%
@cd ..\..\..
@echo PYTHONPATH=%PYTHONPATH%

@cd ..
@set SD_UI_PATH=%cd%\ui
@cd astica-art-creator

@call python --version

@uvicorn server:app --app-dir "%SD_UI_PATH%" --port 9000 --host 0.0.0.0

@pause
