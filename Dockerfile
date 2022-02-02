FROM mcr.microsoft.com/windows/servercore:ltsc2022 as node_installer
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';$ProgressPreference='silentlyContinue';"]
RUN Invoke-WebRequest -OutFile nodejs.zip -UseBasicParsing "https://nodejs.org/dist/latest-v14.x/node-v14.19.0-win-x64.zip"
RUN Expand-Archive "nodejs.zip" -DestinationPath "C:\\"
RUN Rename-Item "C:\\node-v14.19.0-win-x64" c:\nodejs

FROM mcr.microsoft.com/windows/servercore:ltsc2022 as nginx_installer
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';$ProgressPreference='silentlyContinue';"]
RUN Invoke-WebRequest -OutFile nginx.zip -UseBasicParsing "https://nginx.org/download/nginx-1.20.2.zip"
RUN Expand-Archive "nginx.zip" -DestinationPath "C:\\"
RUN Rename-Item "C:\\nginx-1.20.2" c:\nginx

FROM mcr.microsoft.com/windows/nanoserver:ltsc2022 as ghost_installer
USER ContainerAdministrator
WORKDIR C:\\nodejs
COPY --from=nginx_installer C:\\nginx\\ .
COPY --from=node_installer C:\\nodejs\\ .
RUN SETX PATH C:\\nodejs
RUN npm install ghost-cli@latest -g
RUN mkdir C:\\ghost
WORKDIR C:\\ghost
RUN ghost install --no-start --no-stack --no-setup --db=sqlite3

FROM mcr.microsoft.com/windows/nanoserver:ltsc2022 as ghost_run
COPY --from=node_installer C:\\nodejs\\ .
COPY --from=ghost_installer C:\\ghost\\ .
COPY --from=nginx_installer C:\\nginx\\ .
WORKDIR C:\\ghost
CMD ["ghost start"]

# TODO
# start nginx as service
# persistent storage of blog data