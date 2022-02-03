### Temporary fix for share deletion error

```batch
:: [!] Make sure $Conf{BackupsDisable} = 1 for the host

Get-Content C:\ProgramData\backuppc\backup_objects.xml
vssadmin list shadows
net share
cmd /c dir C:\ProgramData\backuppc\mnt\


cd C:\ProgramData\backuppc\mnt
cmd /c rmdir drive_C
cmd /c rmdir drive_D
cmd /c mklink /D drive_C ..\temp
cmd /c mklink /D drive_D ..\temp


net share backup_C /DELETE /Y
net share backup_D /DELETE /Y
cmd /c rmdir drive_C
cmd /c rmdir drive_D

vssadmin list shadows
vssadmin delete shadows "/shadow={b9906071-dfc4-4a57-a317-f0cebab3b96f}" /quiet

remove-item C:\ProgramData\backuppc\backup_objects.xml
```

### Setup

* 1. Packages and sudoers file
    ```shell
    apt install curl libkrb5-dev cifs-utils autofs python3-venv python3-dev libterm-choose-perl

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
    win10.test.local -fstype=cifs,credentials=/root/.backuppc_smb_credentials,dir_mode=0755,file_mode=0755,uid=backuppc,rw /C ://win10.test.local/Backup_C
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
   $Conf{PingCmd} = '/bin/ping -c 1 win10.test.local';
   $Conf{DumpPostUserCmd} = '/opt/backuppc-scripts/snapshots.sh $client --cmd delete --connection=unencrypted --username vagrant --password {{ AO_DEFAULT_VAGRANT_PASSWORD }}';
   $Conf{DumpPreUserCmd} = '/opt/backuppc-scripts/snapshots.sh $client --cmd create --connection=unencrypted --username vagrant --password {{ AO_DEFAULT_VAGRANT_PASSWORD }} --drives C --share-user vagrant';
   $Conf{DumpPostShareCmd} = '/opt/backuppc-scripts/umount_autofs.py $share';
   ```

### Debugging

```shell
/backuppc-scripts/snapshots.sh win10.test.local \
  --connection=unencrypted --username vagrant --password $AO_DEFAULT_VAGRANT_PASSWORD \
  --cmd create --drives C --share-user vagrant --debug

ls /smb/win10.test.local/C -lha

/backuppc-scripts/umount_autofs.py /smb/win10.test.local/C

/backuppc-scripts/snapshots.sh win10.test.local \
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
