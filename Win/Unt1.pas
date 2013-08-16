unit Unt1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UntMain, StdCtrls, DateUtils, Buttons, Spin, DB, DBTables;

type
  TFrmCopyBD1 = class(TForm)
    btnRefresh: TBitBtn;
    btnDeleteArc: TBitBtn;
    btnCancel: TBitBtn;
    grpRefresh: TGroupBox;
    grpDeleteArc: TGroupBox;
    btnPrepare: TBitBtn;
    mmoLog: TMemo;
    seYearDelete: TSpinEdit;
    btn1: TButton;
    qry1: TQuery;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnPrepareClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnRefreshClick(Sender: TObject);
    procedure btnDeleteArcClick(Sender: TObject);

  private
    { Private declarations }
  public
    procedure AddLog(const aLogItem: string);
  end;

var
  FrmCopyBD1: TFrmCopyBD1;
  CopyBd1: TClassCopyBd;
implementation
uses SavLib;

{$DEFINE TESTMODE}
{$R *.dfm}

procedure TFrmCopyBD1.FormCreate(Sender: TObject);
begin
  if ParamCount > 0 then
    CopyBd1 := TClassCopyBd.Create(ParamStr(1));
  AddLog('Начало работы');
end;

procedure TFrmCopyBD1.FormDestroy(Sender: TObject);
begin
  if Assigned(CopyBd1) then
    FreeAndNil(CopyBd1);
end;

(*{$IFDEF TESTMODE}
showmessage('test');
{$ENDIF}*)

procedure TFrmCopyBD1.btnPrepareClick(Sender: TObject);
var
  s: string;
begin         
  AddLog('Начало подготовки');
  s := CopyBd1.Prepare;
  if s = '' then
  begin
    grpRefresh.Visible := True;
    grpDeleteArc.Visible := True;
    AddLog('Подготовка завершена');
  end
  else
    AddLog(s);
end;

procedure TFrmCopyBD1.AddLog(const aLogItem: string);
begin
  mmoLog.Lines.Add('[' + DateTimeToStr(Now) + '] ' + aLogItem);
end;

procedure TFrmCopyBD1.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TFrmCopyBD1.btnRefreshClick(Sender: TObject);
var
  s: string;
begin
  AddLog('Начало обновления');
  s := CopyBd1.Copy_new_db;
  if s = '' then
    AddLog('Обновление успешно')
  else
    AddLog(s);  
end;

procedure TFrmCopyBD1.btnDeleteArcClick(Sender: TObject);
var
  s: string;
begin
  s := 'Вы действительно хотите удалить архив за ' + seYearDelete.Text +
    ' год?';
  if Application.MessageBox(PAnsiChar(s), 'Удаление архива!', MB_YESNOCANCEL +
    MB_ICONQUESTION + MB_DEFBUTTON2) = IDYES then
  begin
    AddLog('Начало удаления архива за ' + seYearDelete.Text + ' год');
    s := CopyBd1.Delete_arh(seYearDelete.Text);
    if s = '' then
      AddLog('Удаление архива завершено успешно')
    else
      AddLog(s);
  end;

end;

end.

