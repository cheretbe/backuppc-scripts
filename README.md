### Setup

* 1. Packages and sudoers file
    ```shell
    apt install curl libkrb5-dev cifs-utils autofs python3-venv python3-dev

    # [!] Don't mess with sudoers file directly, it's extremely dangerous
    tmpfile=$(mktemp)
    cat > "${tmpfile}"<< EOF
    # Allow BackupPC helper script to unmount Windows shares
    backuppc-server ALL=NOPASSWD: /bin/umount -t cifs /smb/*
    EOF
    visudo -cf "${tmpfile}"
    mv "${tmpfile}" /etc/sudoers.d/backuppc_server
    ```

* 2. Auto-mounting shares with autofs
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

* 3. Custom commands
   ```perl
   $Conf{ClientNameAlias} = [
     'localhost'
   ];
   $Conf{PingCmd} = '/bin/ping -c 1 172.24.0.11';
   $Conf{DumpPostUserCmd} = '/opt/backuppc-scripts/snapshots.sh $client --cmd delete --connection=unencrypted --username vagrant --password {{ AO_DEFAULT_VAGRANT_PASSWORD }}';
   $Conf{DumpPreUserCmd} = '/opt/backuppc-scripts/snapshots.sh $client --cmd create --connection=unencrypted --username vagrant --password {{ AO_DEFAULT_VAGRANT_PASSWORD }} --drives C --share-user vagrant';
   $Conf{DumpPostShareCmd} = '/opt/backuppc-scripts/umount_autofs.py $share';
   ```

### Debugging

```shell
/backuppc-scripts/snapshots.sh 172.24.0.11 \
  --connection=unencrypted --username vagrant --password $AO_DEFAULT_VAGRANT_PASSWORD \
  --cmd create --drives C --share-user vagrant --debug

ls /smb/172.24.0.11/C -lha

/backuppc-scripts/umount_autofs.py /smb/172.24.0.11/C

/backuppc-scripts/snapshots.sh 172.24.0.11 \
  --connection=unencrypted --username vagrant --password $AO_DEFAULT_VAGRANT_PASSWORD \
  --cmd delete --debug
```

```shell
export TEST_HOST=host.domain.tld
read -s -p "Password: " TEST_PWD; echo ""; export TEST_PWD

/opt/backuppc-scripts/snapshots.sh $TEST_HOST \
  --connection=ssl --username backuppc --password $TEST_PWD \
  --cmd create --drives C D --share-user backuppc --debug

ls /smb/$TEST_HOST/C -lha
ls /smb/$TEST_HOST/D -lha

/opt/backuppc-scripts/umount_autofs.py /smb/$TEST_HOST/D
/opt/backuppc-scripts/umount_autofs.py /smb/$TEST_HOST/C

/opt/backuppc-scripts/snapshots.sh $TEST_HOST \
  --connection=ssl --username backuppc --password $TEST_PWD \
  --cmd delete --debug
```
