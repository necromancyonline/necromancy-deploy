del deploy.tgz
SET ZIP="C:\Program Files\7-Zip\7z.exe"
if exist %ZIP% %ZIP% a -ttar -so deploy.tar .\* -x!.idea -x!.git | %ZIP% a -si .\deploy.tgz
scp deploy.tgz root@ssh.wizardry-online.com:~
REM sudo rm -rf deploy && mkdir deploy && tar -xvzf deploy.tgz -C deploy && cd ./deploy
REM dos2unix ./deploy.sh
REM sudo ./deploy.sh