### Setup

* 1. Packages and sudoers file
    ```shell
    apt install curl libkrb5-dev cifs-utils autofs

    cat > /etc/sudoers.d/backuppc_server<< EOF
    # Allow BackupPC helper script to unmount Windows shares
    backuppc-server ALL=NOPASSWD: /bin/umount -t cifs /smb/*
    EOF
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
$Conf{DumpPostUserCmd} = '/backuppc-scripts/snapshots.sh $client --cmd delete --connection=unencrypted --username vagrant --password {{ AO_DEFAULT_VAGRANT_PASSWORD }}';
$Conf{DumpPreUserCmd} = '/backuppc-scripts/snapshots.sh $client --cmd create --connection=unencrypted --username vagrant --password {{ AO_DEFAULT_VAGRANT_PASSWORD }} --drives C --share-user vagrant';
$Conf{DumpPostShareCmd} = '/backuppc-scripts/umount_autofs.py $share';
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
