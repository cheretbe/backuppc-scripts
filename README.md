1. Add `/usr/bin` to PATH (for python3 shebang to work): `Edit Config` > `Server` > `MyPath`: `/bin:/usr/bin` (or set `$Conf{MyPath} = '/bin:/usr/bin';` in `/etc/BackupPC/config.pl`
2. Install dependencies
```shell
apt install cifs-utils python3-pip
pip3 install pypsrp
# For Kerberos auth
pip3 install pypsrp[kerberos]
```
3. `visudo -f /etc/sudoers.d/backuppc`
```
# Allow backuppc user to read files with rsync over SSH
backuppc ALL=NOPASSWD: /usr/bin/rsync

# Allow BackupPC process to mount Windows shares
backuppc-server ALL=NOPASSWD: /opt/backuppc-scripts/mounts.py
```
------
* https://www.bitvise.com/ssh-server-download

```shell
# Retrieve public key
ssh-keygen -yf ${VAGRANT_HOME}/insecure_private_key

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${VAGRANT_HOME}/insecure_private_key -p 8022 vagrant@localhost "CALL \\\\vboxsvr\\projects\\backuppc-scripts\\create_snapshot.bat -hostName localhost -userName localhost\\vagrant -password ${AO_DEFAULT_VAGRANT_PASSWORD} -parameters @{drives = @('c:'); share_user = 'vagrant'}"

ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -i ${VAGRANT_HOME}/insecure_private_key -p 8022 vagrant@localhost "CALL \\\\vboxsvr\\projects\\backuppc-scripts\\delete_snapshot.bat -hostName localhost -userName localhost\\vagrant -password ${AO_DEFAULT_VAGRANT_PASSWORD}"

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
