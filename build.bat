cd /d %~dp0
7z a -ttar -r .\builds\netbird.tar ".\netbird"
if exist ".\builds\netbird.tar.gz" del /f /q ".\builds\netbird.tar.gz"
7z a -aoa .\builds\netbird.tar.gz .\builds\netbird.tar
del /f /q .\builds\netbird.tar