; Inno Setup script for the Windows installer. Built by .github/workflows/release.yml:
;   iscc /DAppVersion=1.0.0 mandi_khata.iss
; The installer is NOT code-signed unless the release workflow signs it (optional).
#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif

[Setup]
AppId={{6B0F3B8E-6C0A-4B5E-9D2F-4A1E7C5D9A10}
AppName=Mandi Khata
AppVersion={#AppVersion}
AppPublisher=Mandi Khata
DefaultDirName={autopf}\Mandi Khata
DefaultGroupName=Mandi Khata
OutputDir=..\..\..\..\dist
OutputBaseFilename=MandiKhata-Setup-{#AppVersion}
Compression=lzma2
SolidCompression=yes
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
WizardStyle=modern
UninstallDisplayIcon={app}\mandi_khata_app.exe

[Files]
Source: "..\..\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{group}\Mandi Khata"; Filename: "{app}\mandi_khata_app.exe"
Name: "{autodesktop}\Mandi Khata"; Filename: "{app}\mandi_khata_app.exe"; Tasks: desktopicon

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; Flags: unchecked

[Run]
Filename: "{app}\mandi_khata_app.exe"; Description: "Launch Mandi Khata"; Flags: nowait postinstall skipifsilent
