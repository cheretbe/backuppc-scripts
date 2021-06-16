$Conf{BackupFilesExclude} = {
  '/home' => [
    '/*/temp',
    '/*/.cache'
  ],
  '/root' => [
    '/temp'
  ]
};
$Conf{RsyncShareName} = [
  '/etc',
  '/home',
  '/root',
  '/usr/local'
];
$Conf{XferMethod} = 'rsync';
$Conf{RsyncClientPath} = 'nice -n 19 sudo /usr/bin/rsync';
$Conf{RsyncSshArgs} = [
  '-e',
  '$sshPath -l backuppc'
];
$Conf{BackupPCNightlyPeriod} = 1;
