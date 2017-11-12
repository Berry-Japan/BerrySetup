unit Unit3;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm3 = class(TForm)
    Memo1: TMemo;
    Button1: TButton;
    Button2: TButton;
    procedure FormShow(Sender: TObject);
  private
    { Private êÈåæ }
  public
    { Public êÈåæ }
  end;

var
  Form3: TForm3;

implementation

uses Unit1;

{$R *.dfm}

procedure TForm3.FormShow(Sender: TObject);
begin
  Memo1.Lines.LoadFromFile(AppDir + 'License.txt');
end;

end.
