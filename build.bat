7z a -ttar -r netbird.tar "E:\repos\netbird-merlin\netbird"
if exist "netbird.tar.gz" del /f /q "netbird.tar.gz"
7z a -aoa netbird.tar.gz netbird.tar
del /f /q netbird.tar