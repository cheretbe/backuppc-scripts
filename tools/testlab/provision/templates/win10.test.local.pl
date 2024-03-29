$Conf{ClientNameAlias} = [
  'localhost'
];
$Conf{XferMethod} = 'rsyncd';
$Conf{RsyncdPasswd} = 'backuppc';
$Conf{RsyncdUserName} = 'backuppc';

$Conf{BackupFilesExclude} = {
  '*' => [
    '/$$PendingFiles',
    '/$Recycle.Bin',
    '/$WinREAgent',
    '/Config.Msi',
    '/Documents and Settings',
    '/hiberfil.sys',
    '/pagefile.sys',
    '/RECYCLED',
    '/RECYCLER',
    '/swapfile.sys',
    '/System Volume Information',

    '/Program Files/AVAST Software/Avast',
    '/Program Files/WindowsApps',
    '/ProgramData/Application Data',
    '/ProgramData/AVAST Software/Avast',
    '/ProgramData/Desktop',
    '/ProgramData/Documents',
    '/ProgramData/Favorites',
    '/ProgramData/Kaspersky Lab',
    '/ProgramData/KasperskyLab',
    '/ProgramData/Microsoft/Diagnosis',
    '/ProgramData/Microsoft/Network/Downloader',
    '/ProgramData/Microsoft/RAC',
    '/ProgramData/Microsoft/Windows Defender',
    '/ProgramData/Microsoft/Windows/AppRepository',
    '/ProgramData/Microsoft/Windows/LocationProvider',
    '/ProgramData/Microsoft/Windows/SystemData',
    '/ProgramData/Microsoft/Windows/WER',
    '/ProgramData/Packages',
    '/ProgramData/Start Menu',
    '/ProgramData/Templates',
    '/ProgramData/Windows Defender Advanced Threat Protection',

    '/Users/*/AppData/Local/Application Data',
    '/Users/*/AppData/Local/Google/Chrome/User Data/*/Application Cache',
    '/Users/*/AppData/Local/Google/Chrome/User Data/*/Cache',
    '/Users/*/AppData/Local/Google/Chrome/User Data/*/Code Cache',
    '/Users/*/AppData/Local/Google/Chrome/User Data/*/File System',
    '/Users/*/AppData/Local/Google/Chrome/User Data/*/GPUCache',
    '/Users/*/AppData/Local/Google/Chrome/User Data/*/History Provider Cache',
    '/Users/*/AppData/Local/Google/Chrome/User Data/*/IndexedDB',
    '/Users/*/AppData/Local/Google/Chrome/User Data/*/Local Storage',
    '/Users/*/AppData/Local/Google/Chrome/User Data/*/Service Worker',
    '/Users/*/AppData/Local/History',
    '/Users/*/AppData/Local/Microsoft/Edge/User Data/*/Application Cache',
    '/Users/*/AppData/Local/Microsoft/Edge/User Data/*/Cache',
    '/Users/*/AppData/Local/Microsoft/Edge/User Data/*/Code Cache',
    '/Users/*/AppData/Local/Microsoft/Edge/User Data/*/File System',
    '/Users/*/AppData/Local/Microsoft/Edge/User Data/*/GPUCache',
    '/Users/*/AppData/Local/Microsoft/Edge/User Data/*/History Provider Cache',
    '/Users/*/AppData/Local/Microsoft/Edge/User Data/*/IndexedDB',
    '/Users/*/AppData/Local/Microsoft/Edge/User Data/*/Local Storage',
    '/Users/*/AppData/Local/Microsoft/Edge/User Data/*/Service Worker',
    '/Users/*/AppData/Local/Microsoft/Windows/Explorer',
    '/Users/*/AppData/Local/Microsoft/Windows/INetCache',
    '/Users/*/AppData/Local/Microsoft/Windows/Temporary Internet Files',
    '/Users/*/AppData/Local/Microsoft/Windows/WER',
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
    '/Windows/ServiceProfiles/LocalService/AppData/Local/Microsoft/Ngc',
    '/Windows/servicing/LCU',
    '/Windows/SoftwareDistribution',
    '/Windows/System32/Bits.bak',
    '/Windows/System32/Bits.log',
    '/Windows/System32/config/systemprofile/AppData/Local/Microsoft/Windows/INetCache',
    '/Windows/system32/LogFiles/WMI/RtBackup',
    '/Windows/system32/MSDtc/MSDTC.LOG',
    '/Windows/system32/MSDtc/trace/dtctrace.log',
    '/Windows/System32/Tasks/Microsoft/Windows/Shell/CreateObjectTask',
    '/Windows/Temp',
    '/Windows/WinSxS',

    "/Program Files/Windows NT/\x{421}\x{442}\x{430}\x{43d}\x{434}\x{430}\x{440}\x{442}\x{43d}\x{44b}\x{435}",
    "/Program Files/windows nt/\x{421}\x{442}\x{430}\x{43d}\x{434}\x{430}\x{440}\x{442}\x{43d}\x{44b}\x{435}",
    "/ProgramData/Microsoft/Windows/Start Menu/\x{41f}\x{440}\x{43e}\x{433}\x{440}\x{430}\x{43c}\x{43c}\x{44b}",
    "/ProgramData/\x{413}\x{43b}\x{430}\x{432}\x{43d}\x{43e}\x{435} \x{43c}\x{435}\x{43d}\x{44e}",
    "/ProgramData/\x{433}\x{43b}\x{430}\x{432}\x{43d}\x{43e}\x{435} \x{43c}\x{435}\x{43d}\x{44e}",
    "/ProgramData/\x{414}\x{43e}\x{43a}\x{443}\x{43c}\x{435}\x{43d}\x{442}\x{44b}",
    "/ProgramData/\x{418}\x{437}\x{431}\x{440}\x{430}\x{43d}\x{43d}\x{43e}\x{435}",
    "/ProgramData/\x{420}\x{430}\x{431}\x{43e}\x{447}\x{438}\x{439} \x{441}\x{442}\x{43e}\x{43b}",
    "/ProgramData/\x{428}\x{430}\x{431}\x{43b}\x{43e}\x{43d}\x{44b}",
    "/Users/*/AppData/Roaming/Microsoft/Windows/Start Menu/\x{41f}\x{440}\x{43e}\x{433}\x{440}\x{430}\x{43c}\x{43c}\x{44b}",
    "/Users/*/Documents/\x{41c}\x{43e}\x{438} \x{432}\x{438}\x{434}\x{435}\x{43e}\x{437}\x{430}\x{43f}\x{438}\x{441}\x{438}",
    "/Users/*/Documents/\x{41c}\x{43e}\x{438} \x{440}\x{438}\x{441}\x{443}\x{43d}\x{43a}\x{438}",
    "/Users/*/Documents/\x{43c}\x{43e}\x{438} \x{440}\x{438}\x{441}\x{443}\x{43d}\x{43a}\x{438}",
    "/Users/*/Documents/\x{41c}\x{43e}\x{44f} \x{43c}\x{443}\x{437}\x{44b}\x{43a}\x{430}",
    "/Users/*/\x{413}\x{43b}\x{430}\x{432}\x{43d}\x{43e}\x{435} \x{43c}\x{435}\x{43d}\x{44e}",
    "/Users/*/\x{433}\x{43b}\x{430}\x{432}\x{43d}\x{43e}\x{435} \x{43c}\x{435}\x{43d}\x{44e}",
    "/Users/*/\x{41c}\x{43e}\x{438} \x{434}\x{43e}\x{43a}\x{443}\x{43c}\x{435}\x{43d}\x{442}\x{44b}",
    "/Users/*/\x{428}\x{430}\x{431}\x{43b}\x{43e}\x{43d}\x{44b}",
    "/Users/\x{412}\x{441}\x{435} \x{43f}\x{43e}\x{43b}\x{44c}\x{437}\x{43e}\x{432}\x{430}\x{442}\x{435}\x{43b}\x{438}",

    '/Users/*/AppData/Local/SpiderOak',
    '/temp/!_no_backup',
    '/temp/_no_backup'
  ]
};

$Conf{UserCmdCheckStatus} = '1';
$Conf{DumpPostShareCmd} = '/backuppc-scripts/umount_autofs.py /$share';
$Conf{RsyncShareName} = [
  'smb/win10.test.local/C/'
];
$Conf{PingCmd} = '/bin/ping -c 1 win10.test.local';
$Conf{DumpPostUserCmd} = '/backuppc-scripts/snapshots.sh $client --cmd delete --connection=unencrypted --username vagrant --password {{ AO_DEFAULT_VAGRANT_PASSWORD }}';
$Conf{DumpPreUserCmd} = '/backuppc-scripts/snapshots.sh $client --cmd create --connection=unencrypted --username vagrant --password {{ AO_DEFAULT_VAGRANT_PASSWORD }} --drives C --share-user vagrant';

$Conf{BackupsDisable} = 1;
$Conf{RsyncRestoreArgsExtra} = [
  '--chmod=ugo=rwX'
];
