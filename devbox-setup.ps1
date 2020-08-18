
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#essential
choco install vscode -y
choco install docker-desktop -y
choco install git -y

code --install-extension hashicorp.terraform --force
code --install-extension ms-azuretools.vscode-docker --force
code --install-extension ms-vscode-remote.vscode-remote-extensionpack --force
code --install-extension vscoss.vscode-ansible --force
code --install-extension erd0s.terraform-autocomplete --force

