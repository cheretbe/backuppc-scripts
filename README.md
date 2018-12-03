* https://www.bitvise.com/ssh-server-download

```shell
# Retrieve public key
ssh-keygen -yf ${VAGRANT_HOME}/insecure_private_key

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${VAGRANT_HOME}/insecure_private_key -p 8022 vagrant@localhost "CALL \\\\vboxsvr\\projects\\backuppc-scripts\\create_snapshot.bat -hostName localhost -userName vagrant -password ${AO_DEFAULT_VAGRANT_PASSWORD} -parameters @{drives = @('c:'); share_user = 'vagrant'}"

read -s -p "Enter password: " temp_pwd; echo ""
echo ${temp_pwd}
```

```powershell
powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -command . '\\VBOXSVR\projects\backuppc-scripts\snapshots.ps1'; CreateSnapshot -parameters @{drives = @('c'); share_user = 'vagrant'}
```

Vagrantfile
```ruby
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "cheretbe/win2008r2_ru_64"
  config.winrm.username = "vagrant"
  config.winrm.password = "#{ENV['AO_DEFAULT_VAGRANT_PASSWORD']}"
  config.vm.boot_timeout = 600
  config.vm.provider "virtualbox" do |vb|
    vb.gui = true
    vb.memory = "2048"
    vb.customize ["modifyvm", :id, "--groups", "/__vagrant"]
    vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
    vb.customize ["sharedfolder", "add", :id, "--name", "projects", "--hostpath", "/home/user/projects", "--automount"]
  end
  config.vm.network "forwarded_port", guest: 22, host: 8022
end
```
