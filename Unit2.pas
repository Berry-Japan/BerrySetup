unit Unit2;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls;

type
  TForm2 = class(TForm)
    ComboBox1: TComboBox;
    Button1: TButton;
    TrackBar1: TTrackBar;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Memo1: TMemo;
    Label5: TLabel;
    Label6: TLabel;
    LabelInfo: TLabel;
    ProgressBar1: TProgressBar;
    Button2: TButton;
    procedure Memo1KeyPress(Sender: TObject; var Key: Char);
    procedure ComboBox1Change(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure ComboBox1KeyPress(Sender: TObject; var Key: Char);
    procedure TrackBar1KeyPress(Sender: TObject; var Key: Char);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private �錾 }
  public
    { Public �錾 }
    procedure GetDskSpace(Drive : String; var Free : Int64; var Total : Int64);
    function WinExecAndWait32V2(FileName: string; Visibility: Integer): DWORD;
  end;

var
  Form2: TForm2;
  FA: Int64;

const
  Kilo = 1024;
  strOverWriteInfo = '���Ƀf�[�^�̈悪���݂��܂��B�㏑�����Ă���낵���ł����H';
  strError = '�G���[���������܂����I';
  strComplete = '�쐬�������܂����B';
  strNoOS = 'Berry OS ���C���X�g�[������Ă��܂���I';
  ImageName = 'BERRY\berry.img';
  MKE2FS = 'Setup\mke2fs.exe';
  SwapName = 'BERRY\swap.img';
  MKSWAP = 'Setup\mkswap.exe';
  minimum = 100;        // 100MB �P��

implementation

{$R *.dfm}

procedure TForm2.Memo1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
  begin
    Key := #0;
    if StrToIntDef(Memo1.Text, minimum) < minimum then
      Memo1.Text := IntToStr(minimum);
    Button1.SetFocus;
  end
  else
    if not (Key in ['0'..'9',Chr(VK_BACK), #13]) then Key := #0;
end;

procedure TForm2.ComboBox1Change(Sender: TObject);
Var
  TA: Int64;
begin
  GetDskSpace(ComboBox1.Text, FA, TA);

  // �\��
  labelInfo.Caption := '�� ' +IntToStr(FA) + ' MB / �S�� ' +IntToStr(TA) + ' MB';

  TrackBar1.Min := minimum;
  TrackBar1.Max := FA;
end;

procedure TForm2.TrackBar1Change(Sender: TObject);
begin
  Memo1.Text := IntToStr(TrackBar1.Position);
end;

procedure TForm2.FormCreate(Sender: TObject);
begin
  FA := 0;
end;

procedure TForm2.Memo1Change(Sender: TObject);
begin
  if StrToIntDef(Memo1.Text, minimum) > FA then
    Memo1.Text := IntToStr(FA);

  TrackBar1.Position := StrToIntDef(Memo1.Text, minimum);
end;

procedure TForm2.ComboBox1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    TrackBar1.SetFocus;
end;

procedure TForm2.TrackBar1KeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #13 then
    Memo1.SetFocus;
end;

procedure TForm2.Button1Click(Sender: TObject);
var
  F: file;
  bufsize: WORD;
  bufcount : WORD;
  buff: Pointer;
  j: Integer;
  count: Integer;
  memsize: Cardinal;

begin
  Button1.Enabled := False;
  ProgressBar1.Position := 0;

  bufsize := Kilo;
  bufcount := Kilo;

  memsize := bufsize * bufcount;
  progressbar1.Min := 0;
  progressbar1.Max := StrToIntDef(Memo1.Text, minimum) - 1;

  buff := AllocMem(memsize);
  try
    if Label5.Caption = '�f�[�^�̈�' then
        AssignFile(F, ComboBox1.Text + ImageName)
    else
        AssignFile(F, ComboBox1.Text + SwapName);
    {$I-}
    Reset(F);
    {$I+}
    if IOResult = 0 then
    begin
      if MessageDlg(strOverWriteInfo,
        mtConfirmation, [mbYes, mbNo], 0) = mrNo then
      begin
        CloseFile(F);
        Exit;
      end;
    end;

    {$I-}
    Rewrite(F, bufsize);
    {$I+}
    if IOResult = 0 then
    begin
      for j := 0 to StrToIntDef(Memo1.Text, minimum) - 1 do
      begin
        {$I-}
        BlockWrite(F, buff^, bufcount, count);
        {$I+}
        if IOResult <> 0 then
        begin
          MessageDlg(strError, mtInformation, [mbOk], 0);
          Break;
        end;
        progressbar1.StepBy(1);
      end;
      CloseFile(F);
      if Label5.Caption = '�f�[�^�̈�' then
        WinExecAndWait32V2(ExtractFilePath(Application.ExeName) + MKE2FS + ' -F -j ' + ComboBox1.Text + ImageName, SW_HIDE)
      else
        WinExecAndWait32V2(ExtractFilePath(Application.ExeName) + MKSWAP + ' -v1 ' + ComboBox1.Text + SwapName, SW_HIDE);
      MessageDlg(strComplete, mtInformation, [mbOk], 0);
      ModalResult := mrOK;
    end
    else
    begin
      MessageDlg(strNoOS, mtInformation, [mbOk], 0);
    end;
  finally
    FreeMem(buff);
  end;
  Button1.Enabled := True;
end;

procedure TForm2.GetDskSpace(Drive : String; var Free : Int64; var Total : Int64);
Var
  Sector: Cardinal; //�Z�N�^���i�N���X�^����j
  nByte: Cardinal; //�o�C�g���i�Z�N�^����j
  Cluster: Cardinal; //�t���[�N���X�^��
  TotalCluster: Cardinal; //�h���C�u�̃N���X�^���i���v�j
  ClusterByte: Int64;
begin
  //�f�B�X�N�����擾
  GetDiskFreeSpace(PAnsiChar(Drive), Sector, nByte, Cluster, TotalCluster);
  ClusterByte := Sector * nByte;

  //�f�B�X�N�e�ʂ��擾
  Total := ((ClusterByte * TotalCluster) div Kilo) div Kilo;
  //�󂫗e�ʂ��擾
  Free := ((ClusterByte * Cluster) div Kilo) div Kilo;
end;

function TForm2.WinExecAndWait32V2(FileName: string; Visibility: Integer): DWORD;
var
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  FillChar(StartupInfo, SizeOf(StartupInfo), #0);
  StartupInfo.cb          := SizeOf(StartupInfo);
  StartupInfo.dwFlags     := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := Visibility;

  if not CreateProcess(nil,
    PChar(FileName),      // pointer to command line string
    nil,                  // pointer to process security attributes
    nil,                  // pointer to thread security attributes
    False,                // handle inheritance flag
    CREATE_NEW_CONSOLE or // creation flags
    NORMAL_PRIORITY_CLASS,
    nil,                  //pointer to new environment block
    nil,                  // pointer to current directory name
    StartupInfo,          // pointer to STARTUPINFO
    ProcessInfo)          // pointer to PROCESS_INF
  then Result := WAIT_FAILED
  else
  begin
    while WaitForSingleObject(ProcessInfo.hProcess,100) = WAIT_TIMEOUT do
      Application.ProcessMessages;
    GetExitCodeProcess(ProcessInfo.hProcess, Result);
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
  end;
end; { WinExecAndWait32 }

procedure TForm2.Button2Click(Sender: TObject);
begin
  Close;
end;

end.

