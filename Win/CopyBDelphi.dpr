program CopyBDelphi;

uses
  Forms,
  Unt1 in 'Unt1.pas' {FrmCopyBD1},
  UntMain in 'UntMain.pas',
  UaPDO in 'UaPDO.pas',
  MNALIB in 'MNALIB.pas';

{$R *.res}
begin
  Application.Initialize;
  Application.CreateForm(TFrmCopyBD1, FrmCopyBD1);
  Application.Run;
end.
