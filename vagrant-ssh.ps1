if (!(Test-Path "C:\Users\vagrant\.ssh\authorized_keys")) {
    (New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub', 'C:\Users\Administrator\.ssh\authorized_keys')
}

