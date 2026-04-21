@echo off
REM Darktide Power_DI Uploader - Windows Launcher

echo Checking dependencies...
pip show winrt-Windows.Media.Ocr >nul 2>&1
if %errorlevel% neq 0 (
    echo Installing dependencies...
    pip install winrt-Windows.Media.Ocr winrt-Windows.Storage winrt-Windows.Graphics.Imaging winrt-Windows.Globalization winrt-Windows.Storage.Streams pillow google-auth google-auth-httplib2 google-api-python-client python-dotenv
    echo.
)

echo Starting Darktide Power_DI Uploader...
python "%~dp0app.py"
