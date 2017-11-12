unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ShellAPI, ProgressDialog;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    Button6: TButton;
    Button7: TButton;
    Button8: TButton;
    Label1: TLabel;
    ComboBox1: TComboBox;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
  private
    { Private 宣言 }
    procedure CopyFiles(fFrom, fTo : String);
    procedure DeleteFiles(fFrom : String);
    procedure SetMenu;
    procedure DisableButton;
    // 解凍関連
    procedure WMCommand(var msg: TMessage);message WM_COMMAND;
    procedure UnzipAbort(Sender: TObject);
  public
    { Public 宣言 }
  end;

var
  Form1: TForm1;
  Error: Boolean;
  WindowsPath : array [0..256] of char;
  AppDir:   String;
  SysDrive: String;
  DstDrive: String;
  IsOS: Boolean;
  IsGRUB: Boolean;
  IsNTLDR: Boolean;
  LangID: Integer;
  // 解凍関連
  tpd: TProgressDialog;
  UserPressedAbort: Boolean;

  const OSButtonLabel : array[0..2] of String = (
   'Berry OS のアンインストール',
   'Berry OS のインストール（640MB の空きが必要）',
   'Berry OS のインストール'
  );

  const GRUBButtonLabel : array[0..2] of String = (
    'ブートローダの削除 (NTLDR)',
    'ブートローダの追加（5MB の空きが必要）',
    'ブートローダの追加 (NTLDR)'
  );

const
  OSArea = 640;
  GRUBArea = 5;
  OSSource = 'BERRY';   // BERRYディレクトリ
  GRUBSource = 'Setup'; // Setupディレクトリ
  OSDest = 'BERRY';     // インストール先ディレクトリ
  GRUBDest = 'BERRY';   // インストール先ディレクトリ
  strOSError = '申し訳ありません。ブートローダの追加は Windows 95/98/Me には対応していません。';
  strComplete = 'インストールに成功しました。';
  strUnpack = 'コピーしています...';
  cm_showpercent = $1070;  // 解凍関連

implementation

uses Unit2, Unit3, ZipTypes, Unzip;

{$R *.dfm}

// 解凍関連
procedure TForm1.WMCommand(var msg: TMessage);
var ppercent:^word;
begin
  inherited;
  if msg.WParam=cm_showpercent then begin
    ppercent:=pointer(msg.LParam);
    if ppercent<>nil then begin
      if (ppercent^>=0) and (ppercent^<=100) then
        tpd.Position := ppercent^;
      if UserPressedAbort then
        ppercent^:=$ffff
      else
        ppercent^:=0;
    end;
  end;
end;

// キャンセル処理
procedure TForm1.UnzipAbort(Sender: TObject);
begin
  UserPressedAbort := True;
end;

// 終了
procedure TForm1.Button7Click(Sender: TObject);
//var
//  tpd: TProgressDialog;
begin
//  tpd := TProgressDialog.Create(self);
//  tpd.Execute;
//  tpd.Stop;
  // 終了
  Close;
end;

// インストール
procedure TForm1.Button1Click(Sender: TObject);
var
  str1: String;
  str2: String;

  rc: integer;  // 解凍関連
  r: tziprec;

begin
  DisableButton;
  if IsOS then
  begin
    // アンインストール
    //str1 := SysDrive + OSDest;
    str1 := DstDrive + '\' + OSDest;
    DeleteFiles(str1);
  end
  else
  begin
    // インストール
    if Form3.ShowModal = mrOk then
    begin
        // OS 本体
        str1 := AppDir + OSSource;
        //str2 := SysDrive + OSDest;
        str2 := DstDrive + '\' + OSDest;

        if FileExists(str1 + '\berry.zip') then begin
          // 圧縮ファイルを解凍
          tpd := TProgressDialog.Create(self);
          tpd.Title := strUnpack;
          //tpd.TextLine1 := 'berry.zip';
          tpd.TextLine2 := char($27)+str1+char($27)+' から '+char($27)+str2+char($27)+' へ';
          tpd.CommonAVI := aviCopyFiles;
          tpd.Max := 100;
          tpd.Position := 0;
          UserPressedAbort := False;
          tpd.OnCancel := UnzipAbort;
          tpd.Execute;

          //FileUnzip(PAnsiChar(str1 + '\berry.zip'), PAnsiChar(str2), '*.*', nil, nil);
          rc := getfirstinzip(PAnsiChar(str1+'\berry.zip'), r);
          while rc = unzip_ok do begin
            rc := unzipfile(PAnsiChar(str1+'\berry.zip'), PAnsiChar(str2+'\'+r.filename), r.headeroffset, self.Handle, cm_showpercent);
//            rc := unzipfile(PAnsiChar(str1+'\berry.zip'), PAnsiChar(str2+'\'+r.filename), r.headeroffset, Form1.Handle, cm_showpercent);
            if (rc = unzip_ReadErr) or (rc = unzip_Userabort) or
               (rc = unzip_InUse)   or (rc = unzip_ZipFileErr) then
              rc := unzip_SeriousError {Serious error, force abort}
            else
              rc := getnextinzip(r);
          end;
          closezipfile(r);
          //tpd.Stop;
          tpd.Destroy;
        end else begin
          // 普通にコピー
          CopyFiles(str1, str2);
        end;

        // GRUB
        str1 := AppDir + GRUBSource;
        //str2 := SysDrive + GRUBDest;  // C:\のみ可
        str2 := DstDrive + GRUBDest;
        CopyFiles(str1, str2);
        // GRUB4DOS
        CopyFile(PChar(AppDir + GRUBSource + '\grldr'), PChar('C:\grldr'), FALSE);
        //MessageDlg(strComplete, mtInformation, [mbOk], 0);
    end;
  end;
  SetMenu;
end;

procedure TForm1.Button2Click(Sender: TObject);
{var
  str1: String;
  str2: String;}
begin
  DisableButton;
  {if IsGRUB then
  begin
    // ブートローダ削除
    ShellExecute(0, 'open', PChar(AppDir + GRUBSource + '\unsetup.bat'), nil, nil, SW_HIDE);
    str1 := SysDrive + GRUBDest;
    DeleteFiles(str1);
  end
  else
  begin}
    // ブートローダ追加
    {str1 := AppDir + GRUBSource;
    str2 := SysDrive + GRUBDest;
    CopyFiles(str1, str2);}
    ShellExecute(0, 'open', PChar(AppDir + GRUBSource + '\setup.bat'), nil, nil, SW_HIDE);
  //end;
  SetMenu;
end;

procedure TForm1.Button3Click(Sender: TObject);
//var
  //str1: String;
  //str2: String;
begin
  DisableButton;
  //if IsGRUB then
  //begin
    // ブートローダ削除
    ShellExecute(0, 'open', PChar(AppDir + GRUBSource + '\unsetup.bat'), nil, nil, SW_HIDE);
    //str1 := SysDrive + GRUBDest;
    //DeleteFiles(str1);
  {end
  else
  begin
    // ブートローダ追加
    str1 := AppDir + GRUBSource;
    str2 := SysDrive + GRUBDest;
    CopyFiles(str1, str2);
    ShellExecute(0, 'open', PChar(AppDir + GRUBSource + '\setup.bat'), nil, nil, SW_HIDE);
  end;}
  SetMenu;
end;

// データ領域の作成
procedure TForm1.Button4Click(Sender: TObject);
var
  Ret: Integer;// ビットマスク
  i: integer;
  n: integer;
  kind: word;
  drive: string;
begin
  DisableButton;

  // 利用可能なドライブを取得
  n := -1;
  Ret := GetLogicalDrives;
  with Form2 do
  begin
    ComboBox1.Clear;
    For i := 0 to 25 do
    begin
      // 存在する＝論理積が0ではない時リストに追加
      if (Ret and(1 shl i)) <> 0 then
      begin                    
        drive := Char(Ord('A') + i) + ':\';
        kind := GetDriveType(PChar(drive));
        //if kind = DRIVE_FIXED then
        if (kind = DRIVE_FIXED) or (kind = 2) or (kind = 4) then
        begin
          ComboBox1.Items.Add(drive);
          Inc(n);
          if CompareText(drive, DstDrive+'\') = 0 then
              ComboBox1.ItemIndex := n;
        end;
      end;
    end;
    //ComboBox1.ItemIndex := 0;
    ComboBox1.OnChange(Self);
    ProgressBar1.Position := 0;
    Label3.Caption := 'Berry OS のデータ領域を作成します。';
    Label5.Caption := 'データ領域';
    ShowModal;
  end;
  SetMenu;
end;

// スワップ領域の作成
procedure TForm1.Button5Click(Sender: TObject);
var
  Ret: Integer;// ビットマスク
  i: integer;
  n: integer;
  kind: word;
  drive: string;
begin
  DisableButton;

  // 利用可能なドライブを取得
  n := -1;
  Ret := GetLogicalDrives;
  with Form2 do
  begin
    ComboBox1.Clear;
    For i := 0 to 25 do
    begin
      // 存在する＝論理積が0ではない時リストに追加
      if (Ret and(1 shl i)) <> 0 then
      begin
        drive := Char(Ord('A') + i) + ':\';
        kind := GetDriveType(PChar(drive));
        if (kind = DRIVE_FIXED) or (kind = 2) or (kind = 4) then
        begin
          ComboBox1.Items.Add(drive);
          Inc(n);
          if CompareText(drive, DstDrive+'\') = 0 then
              ComboBox1.ItemIndex := n;
        end;
      end;
    end;
    ComboBox1.OnChange(Self);
    ProgressBar1.Position := 0;
    Label3.Caption := 'Berry OS のスワップ領域を作成します。';
    Label5.Caption := 'スワップ領域';
    ShowModal;
  end;
  SetMenu;
end;

// syslinux によるインストール
procedure TForm1.Button6Click(Sender: TObject);
var
  from :String;
  dest :String;
  options :String;
begin
  DisableButton;

  if Form3.ShowModal = mrOk then
  begin
    // OS 本体
    from := AppDir + OSSource;
    dest := DstDrive + '\' + OSDest;
    CopyFiles(from, dest);
    // カーネル
    from := AppDir + GRUBSource + '\vmlinuz';
    dest := DstDrive + '\';
    CopyFiles(from, dest);
    from := AppDir + GRUBSource + '\initrd.gz';
    dest := DstDrive + '\';
    CopyFiles(from, dest);
    // SysLinux
    //from := AppDir + '1280x1024.cfg';
    from := AppDir + GRUBSource + '\syslinux.cfg';
    dest := DstDrive + '\syslinux.cfg';
    CopyFile(PChar(from), PChar(dest), FALSE);
    options := '-ma ' + DstDrive;
    ShellExecute(0, 'open', PChar(AppDir + GRUBSource + '\syslinux.exe'), PChar(options), nil, SW_HIDE);

    MessageDlg(strComplete, mtInformation, [mbOk], 0);
  end;
  SetMenu;
end;


// ファイルをコピーする
procedure TForm1.CopyFiles(fFrom, fTo : String);
var
  foStruct : TSHFileOpStruct;
begin
  with foStruct do
  begin
    wnd := handle; wFunc := FO_COPY;
    pFrom := PAnsiChar(fFrom + '\*.*' + #0);
    pTo := PAnsiChar(fTo + '\' + #0);
    fFlags := FOF_FILESONLY or FOF_ALLOWUNDO;
    fAnyOperationsAborted := False;
    lpszProgressTitle := nil;
  end;
  SHFileOperation(foStruct);
end;

// ファイルを削除する
procedure TForm1.DeleteFiles(fFrom : String);
var
  foStruct : TSHFileOpStruct;
begin
  with foStruct do
  begin
    wnd := handle; wFunc := FO_DELETE;
    pFrom := PAnsiChar(fFrom + #0);
    pTo := nil;
    fFlags := FOF_ALLOWUNDO;
    fAnyOperationsAborted := False;
    lpszProgressTitle := nil;
  end;
  SHFileOperation(foStruct);
end;

// フォームの初期化
procedure TForm1.FormCreate(Sender: TObject);
var
  info: OSVERSIONINFO;
begin
  // OSチェック
  Error := False;

  info.dwOSVersionInfoSize := SizeOf(info);
  GetVersionEx(info);
  if info.dwPlatFormId = VER_PLATFORM_WIN32_NT then
  begin
  end
  else if info.dwPlatFormId = VER_PLATFORM_WIN32_WINDOWS then
  begin
  end
  else
  begin
    Error := True;
  end;

  // 起動ディレクトリ
  AppDir := ExtractFilePath(Application.ExeName);

  // システムドライブ
  GetWindowsDirectory(WindowsPath, sizeof(WindowsPath));
  SysDrive := Copy(WindowsPath, 1, 3);
  //Label2.Caption := SysDrive;

  // インストール先
  Button8.Click;
  Button6.Enabled := false;
  DstDrive := Copy(SysDrive, 1, 2);

  // 言語
  LangID := GetUserDefaultLangID;
  //Label2.Caption := LangID;

  SetMenu;
end;

// メニューの表示設定
procedure TForm1.SetMenu;
var
  Free: Int64;
  Total: Int64;
  btnindex: Integer;
begin
  IsOS := False;
  IsGRUB := False;
  IsNTLDR := False;
  btnindex := 0;

  // フリー領域
  Form2.GetDskSpace({SysDrive}DstDrive, Free, Total);

  // ファイルチェック
  if DirectoryExists({SysDrive}DstDrive + '\' + OSDest + '\') then
    IsOS := True;
  if DirectoryExists({SysDrive}DstDrive + '\' + GRUBDest + '\') then
    IsGRUB := True;
  if FileExists(DstDrive + '\ntldr') then
    IsNTLDR := True;

  if IsOS then
  begin
    Button1.Enabled := True;
  end
  else
  begin
    if Free < OSArea then
    begin
      Button1.Enabled := False;
      btnindex := 1;
    end
    else
    begin
      Button1.Enabled := True;
      btnindex := 2;
    end;
  end;
  Button1.Caption := OSButtonLabel[btnindex];

  //btnindex := 0;
  {if IsGRUB then
  begin
    Button2.Enabled := True;
  end
  else
  begin}
    if Free < GRUBArea then
    begin
      Button2.Enabled := False;
      btnindex := 1;
    end
    else
    begin
      Button2.Enabled := True;
      btnindex := 2;
    end;
  //end;
  Button2.Caption := GRUBButtonLabel[btnindex];

  if IsNTLDR then
  begin
    Button2.Enabled := True;
    Button3.Enabled := True;
  end
  else
  begin
    Button2.Enabled := False;
    Button3.Enabled := False;
  end;

  Button4.Enabled := True;
  Button5.Enabled := True;
  //Button6.Enabled := True;
  Button8.Enabled := True;
  ComboBox1.Enabled := True;
end;

procedure TForm1.DisableButton;
begin
  Button1.Enabled := False;
  Button2.Enabled := False;
  Button3.Enabled := False;
  Button4.Enabled := False;
  Button5.Enabled := False;
  Button6.Enabled := False;
  Button8.Enabled := False;
  ComboBox1.Enabled := False;
end;


procedure TForm1.FormShow(Sender: TObject);
begin
  if Error then
  begin
     MessageDlg(strOSError, mtInformation, [mbOk], 0);
     //Close;
  end;
end;

procedure TForm1.Button8Click(Sender: TObject);
var
  Ret : Integer;// ビットマスク
  i   : integer;
  n   : integer;
  drvname : String;
  dtype : String;
begin
  //Ret:= GetLogicalDrives;

  ComboBox1.Clear;
  //ComboBox1.ItemIndex := -1;
  n := -1;

  // 0-25(A-Z)
  For i := 0 to 25 do
  begin
    drvname := Char(Ord('A') + i) + ':\';
    Ret := GetDriveType(PChar(drvname));

    Case Ret of
      0 : dtype := '未知';
      1 : dtype := '存在しません';
      2 : dtype := 'リムーバブル ディスク';
      3 : dtype := 'ローカル ディスク';
      4 : dtype := 'ネットワーク ドライブ';
      5 : dtype := 'CD/DVD ドライブ';
      6 : dtype := 'RAM';
      else
        dtype := IntToStr(Ret);
    end;

    if Ret <> 1 then
    begin
       Inc(n); 
       ComboBox1.Items.Add(drvname + ' : ' + dtype);
       if CompareText(drvname, SysDrive) = 0 then
          ComboBox1.ItemIndex := n;
          //MessageDlg(drvname+' '+inttostr(n), mtInformation, [mbOk], 0);
    end;
  end;
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  if Combobox1.ItemIndex > -1 then
  begin
    DstDrive := Copy(Combobox1.Items.Strings[Combobox1.ItemIndex], 1, 2);
    if GetDriveType(PChar(DstDrive)) = 2 then
       Button6.Enabled := true
    else
       Button6.Enabled := false;
    SetMenu;
  end;
end;

end.
