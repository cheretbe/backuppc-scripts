```shell
apt install libkrb5-dev autofs cifs-utils
```

```shell
# credentials file example:
cat > /root/.backuppc_smb_credentials<< EOF
username=user
password=pwd
EOF

chmod 600 /root/.backuppc_smb_credentials
```

`/etc/auto.smb_backuppc` example
```
172.24.0.11 -fstype=cifs,credentials=/root/.backuppc_smb_credentials,dir_mode=0755,file_mode=0755,uid=backuppc,rw /C ://172.24.0.11/Backup_C
```

```shell
mkdir /etc/auto.master.d/
echo "/smb  /etc/auto.smb_backuppc --timeout=600 -browse" > /etc/auto.master.d/smb_backuppc.autofs
service autofs restart
```

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
/backuppc-scripts/snapshots.sh 172.24.0.11 \
  --connection=unencrypted --username vagrant --password $AO_DEFAULT_VAGRANT_PASSWORD \
  --cmd create --drives C --share-user vagrant --debug

/backuppc-scripts/snapshots.sh 172.24.0.11 \
  --connection=unencrypted --username vagrant --password $AO_DEFAULT_VAGRANT_PASSWORD \
  --cmd delete --debug
```
