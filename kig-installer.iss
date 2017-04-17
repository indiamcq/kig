; -- Example1.iss --
; Demonstrates copying 3 files and creating an icon.

; SEE THE DOCUMENTATION FOR DETAILS ON CREATING .ISS SCRIPT FILES!

[Setup]
OutputBaseFilename=kig-installer
AppName=KIG K Image Gallery processor
AppVersion=3.2
DefaultDirName=C:\programs\kig
DisableDirPage=true
DefaultGroupName=K Image Gallery maker
UninstallDisplayIcon={app}\kig.ico
Compression=lzma2
SolidCompression=yes
OutputDir=userdocs:Inno Setup Examples Output

[Dirs]
Name: "C:\ProgramData\kig" ; Permissions: everyone-full

[Files]
Source: "files\kig-app.hta"; DestDir: "{app}"
Source: "files\kig.cmd"; DestDir: "{app}"
Source: "files\kig.ico"; DestDir: "{app}"
Source: "D:\All-SIL-Publishing\github\kig\branches\kig3\photos\*.GIF"; DestDir: "{app}\photos"
Source: "files\ProgramData\*.ini"; DestDir: "C:\ProgramData\kig"
Source: "files\thumb\*.jpg"; DestDir: "{app}\thumb"
Source: "Readme.md"; DestDir: "{app}"
Source: "files\kig-readme.html"; DestDir: "{app}"; Flags: isreadme
Source: "files\kig-readme.pdf"; DestDir: "{app}"
Source: "files\imagemagick\*.exe"; DestDir: "{app}\imagemagick"
Source: "files\imagemagick\*.txt"; DestDir: "{app}\imagemagick"

[Icons]
Name: "{group}\KIG-app"; Filename: "{app}\kig-app.hta"; IconFilename: "{app}\kig.ico"
Name: "{group}\Documentation\Installation Notes"; Filename: "{app}\doc\Installation Notes.txt"
Name: "{group}\Documentation\kig-readme.pdf"; Filename: "{app}\kig-readme.pdf"
Name: "{group}\Documentation\kig-readme.html"; Filename: "{app}\kig-readme.html"
Name: "{group}\Uninstall K Image Gallery"; Filename: "{uninstallexe}"

[Registry]
Root: HKCU; Subkey: "Environment"; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};C:\programs\kig"; Check: NeedsAddPath('C:\programs\kig')

[Code]

function NeedsAddPath(Param: string): boolean;
var
  OrigPath: string;
begin
  if not RegQueryStringValue(HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
    'Path', OrigPath)
  then begin
    Result := True;
    exit;
  end;
  { look for the path with leading and trailing semicolon }
  { Pos() returns 0 if not found }
  Result := Pos(';' + Param + ';', ';' + OrigPath + ';') = 0;
end;
