program Setup;

{%File 'unzip.inc'}

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas' {Form2},
  Unit3 in 'Unit3.pas' {Form3},
  unzip in 'unzip.pas',
  ziptypes in 'ziptypes.pas',
  ProgressDialog in 'ProgressDialog.pas',
  BlockDev in 'BlockDev.pas',
  WinIOCTL in 'WinIOCTL.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.CreateForm(TForm2, Form2);
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
