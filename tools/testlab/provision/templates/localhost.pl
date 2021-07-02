$Conf{BackupFilesExclude} = {
  'home' => [
    '/*/temp',
    '/*/.cache'
  ],
  'root' => [
    '/temp'
  ]
};
$Conf{RsyncShareName} = [
  'etc',
  'home',
  'root',
  'usr_local'
];
$Conf{XferMethod} = 'rsyncd';
$Conf{RsyncdPasswd} = 'backuppc';
$Conf{RsyncdUserName} = 'backuppc';
$Conf{BackupPCNightlyPeriod} = 1;
