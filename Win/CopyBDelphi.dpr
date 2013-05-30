program CopyBDelphi;

uses
  Forms,
  Unt1 in 'Unt1.pas' {FrmCopyBD1},
  UntMain in 'UntMain.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TFrmCopyBD1, FrmCopyBD1);
  Application.Run;
end.
