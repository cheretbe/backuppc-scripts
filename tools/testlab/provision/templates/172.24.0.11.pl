$Conf{ClientNameAlias} = [
  'localhost'
];
$Conf{XferMethod} = 'rsync';


$Conf{BackupFilesExclude} = {
  '*' => [
    '/pagefile.sys',
    '/swapfile.sys',
    '/hiberfil.sys',
    '/$Recycle.Bin',
    '/RECYCLER',
    '/RECYCLED',
    '/System Volume Information',

    '/Documents and Settings',
    '/Program Files/AVAST Software/Avast',
    '/ProgramData/Application Data',
    '/ProgramData/AVAST Software/Avast',
    '/ProgramData/Desktop',
    '/ProgramData/Documents',
    '/ProgramData/Favorites',
    '/ProgramData/Microsoft/Diagnosis',
    '/ProgramData/Microsoft/Network/Downloader',
    '/ProgramData/Microsoft/RAC',
    '/ProgramData/Microsoft/Windows Defender',
    '/ProgramData/Microsoft/Windows/LocationProvider',
    '/ProgramData/Microsoft/Windows/SystemData',
    '/ProgramData/Microsoft/Windows/WER',
    '/ProgramData/Start Menu',
    '/ProgramData/Templates',
    '/Users/*/AppData/Local/Application Data',
    '/Users/*/AppData/Local/Google/Chrome/User Data/*/Application Cache',
    '/Users/*/AppData/Local/Google/Chrome/User Data/*/Cache',
    '/Users/*/AppData/Local/Google/Chrome/User Data/*/Code Cache',
    '/Users/*/AppData/Local/Google/Chrome/User Data/*/GPUCache',
    '/Users/*/AppData/Local/Google/Chrome/User Data/*/History Provider Cache',
    '/Users/*/AppData/Local/Google/Chrome/User Data/*/IndexedDB',
    '/Users/*/AppData/Local/Google/Chrome/User Data/*/Service Worker/CacheStorage',
    '/Users/*/AppData/Local/Google/Chrome/User Data/*/Service Worker/ScriptCache',
    '/Users/*/AppData/Local/History',
    '/Users/*/AppData/Local/Microsoft/Windows/Explorer/ThumbCacheToDelete',
    '/Users/*/AppData/Local/Microsoft/Windows/INetCache',
    '/Users/*/AppData/Local/Microsoft/Windows/Temporary Internet Files',
    '/Users/*/AppData/Local/Mozilla/Firefox',
    '/Users/*/AppData/Local/Opera Software/Opera Stable/Cache',
    '/Users/*/AppData/Local/Opera/Opera/cache',
    '/Users/*/AppData/Local/Temp',
    '/Users/*/AppData/Local/Temporary Internet Files',
    '/Users/*/AppData/Roaming/Mozilla/Firefox/Crash Reports',
    '/Users/*/AppData/Roaming/XnView/XnView.db',
    '/Users/*/AppData/Roaming/XnViewMP/Thumb.db',
    '/Users/*/Application Data',
    '/Users/*/Cookies',
    '/Users/*/Documents/My Music',
    '/Users/*/Documents/My Pictures',
    '/Users/*/Documents/My Videos',
    '/Users/*/Downloads',
    '/Users/*/Local Settings',
    '/Users/*/My Documents',
    '/Users/*/NetHood',
    '/Users/*/PrintHood',
    '/Users/*/Recent',
    '/Users/*/SendTo',
    '/Users/*/Start Menu',
    '/Users/*/Templates',
    '/Users/All Users',
    '/Users/Default User',
    '/Windows/CSC',
    '/Windows/memory.dmp',
    '/Windows/Minidump',
    '/Windows/netlogon.chg',
    '/Windows/Prefetch',
    '/Windows/Resources/Themes/aero/VSCache',
    '/Windows/SoftwareDistribution',
    '/Windows/System32/Bits.bak',
    '/Windows/System32/Bits.log',
    '/Windows/system32/LogFiles/WMI/RtBackup',
    '/Windows/system32/MSDtc/MSDTC.LOG',
    '/Windows/system32/MSDtc/trace/dtctrace.log',
    '/Windows/Temp',

    "/Program Files/Windows NT/\x{421}\x{442}\x{430}\x{43d}\x{434}\x{430}\x{440}\x{442}\x{43d}\x{44b}\x{435}",
    "/ProgramData/Microsoft/Windows/Start Menu/\x{41f}\x{440}\x{43e}\x{433}\x{440}\x{430}\x{43c}\x{43c}\x{44b}",
    "/ProgramData/\x{413}\x{43b}\x{430}\x{432}\x{43d}\x{43e}\x{435} \x{43c}\x{435}\x{43d}\x{44e}",
    "/ProgramData/\x{414}\x{43e}\x{43a}\x{443}\x{43c}\x{435}\x{43d}\x{442}\x{44b}",
    "/ProgramData/\x{418}\x{437}\x{431}\x{440}\x{430}\x{43d}\x{43d}\x{43e}\x{435}",
    "/ProgramData/\x{420}\x{430}\x{431}\x{43e}\x{447}\x{438}\x{439} \x{441}\x{442}\x{43e}\x{43b}",
    "/ProgramData/\x{428}\x{430}\x{431}\x{43b}\x{43e}\x{43d}\x{44b}",
    "/Users/*/AppData/Roaming/Microsoft/Windows/Start Menu/\x{41f}\x{440}\x{43e}\x{433}\x{440}\x{430}\x{43c}\x{43c}\x{44b}",
    "/Users/*/Documents/\x{41c}\x{43e}\x{438} \x{432}\x{438}\x{434}\x{435}\x{43e}\x{437}\x{430}\x{43f}\x{438}\x{441}\x{438}",
    "/Users/*/Documents/\x{41c}\x{43e}\x{438} \x{440}\x{438}\x{441}\x{443}\x{43d}\x{43a}\x{438}",
    "/Users/*/Documents/\x{41c}\x{43e}\x{44f} \x{43c}\x{443}\x{437}\x{44b}\x{43a}\x{430}",
    "/Users/*/\x{413}\x{43b}\x{430}\x{432}\x{43d}\x{43e}\x{435} \x{43c}\x{435}\x{43d}\x{44e}",
    "/Users/*/\x{41c}\x{43e}\x{438} \x{434}\x{43e}\x{43a}\x{443}\x{43c}\x{435}\x{43d}\x{442}\x{44b}",
    "/Users/*/\x{428}\x{430}\x{431}\x{43b}\x{43e}\x{43d}\x{44b}",
    "/Users/\x{412}\x{441}\x{435} \x{43f}\x{43e}\x{43b}\x{44c}\x{437}\x{43e}\x{432}\x{430}\x{442}\x{435}\x{43b}\x{438}",

    'Users/*/AppData/Local/SpiderOak',
    '/temp/!_no_backup',
    '/temp/_no_backup',

    "/Users/*/Documents/\x{43c}\x{43e}\x{438} \x{440}\x{438}\x{441}\x{443}\x{43d}\x{43a}\x{438}",
    "/Users/*/\x{433}\x{43b}\x{430}\x{432}\x{43d}\x{43e}\x{435} \x{43c}\x{435}\x{43d}\x{44e}"
  ]
};

$Conf{UserCmdCheckStatus} = '1';
$Conf{DumpPostShareCmd} = '/backuppc-scripts/umount_autofs.py $share';
$Conf{RsyncShareName} = [
  '/smb/172.24.0.11/C'
];
$Conf{RsyncSshArgs} = [
  '-e',
  '$sshPath -l backuppc'
];
$Conf{PingCmd} = '/bin/ping -c 1 172.24.0.11';
$Conf{DumpPostUserCmd} = '/backuppc-scripts/snapshots.sh $client --cmd delete --connection=unencrypted --username vagrant --password {{ AO_DEFAULT_VAGRANT_PASSWORD }}';
$Conf{DumpPreUserCmd} = '/backuppc-scripts/snapshots.sh $client --cmd create --connection=unencrypted --username vagrant --password {{ AO_DEFAULT_VAGRANT_PASSWORD }} --drives C --share-user vagrant';
$Conf{BackupFilesOnly} = {
  '*' => [
    '/Users'
  ]
};
