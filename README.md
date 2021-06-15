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

```shell
/backuppc-scripts/snapshots_new.py 172.24.0.11 \
  --connection=unencrypted --username vagrant --password $AO_DEFAULT_VAGRANT_PASSWORD \
  --cmd-type DumpPostUserCmd --debug
```
