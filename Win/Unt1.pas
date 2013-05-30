unit Unt1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UntMain, StdCtrls, DateUtils;

type
  TFrmCopyBD1 = class(TForm)
    Button1: TButton;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  FrmCopyBD1: TFrmCopyBD1;
  CopyBd1: TClassCopyBd;
implementation

{$R *.dfm}

procedure TFrmCopyBD1.FormCreate(Sender: TObject);
begin
  if ParamCount > 0 then
    CopyBd1 := TClassCopyBd.Create(ParamStr(1));
end;

procedure TFrmCopyBD1.FormDestroy(Sender: TObject);
begin
  if Assigned(CopyBd1) then
    FreeAndNil(CopyBd1);
end;

procedure TFrmCopyBD1.Button1Click(Sender: TObject);
begin
  if Assigned(CopyBd1) then
  begin
    CopyBd1.CopyBDKI;
  end;
end;

end.

