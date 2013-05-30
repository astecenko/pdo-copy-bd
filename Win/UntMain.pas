unit UntMain;

interface
uses Classes, DB, VKDBFDataSet, VKDBFNTX {, VKDBFIndex, VKDBFSorters};

const
  scBases = 'basespdo.dbf';
  scBasesIndex = 'basespdo.ntx';

type
  TClassCopyBd = class(TObject)
  private
    FBasesTable: TVKDBFNTX;
    FBasesPDO: string;
    FBasesFileName: string;
    FBasesIndexName: string;
    procedure SetBasesPDO(const Value: string);
  public
    property BasesPDO: string read FBasesPDO write SetBasesPDO;
    property BasesFileName: string read FBasesFileName;
    property BasesIndexName: string read FBasesIndexName;
    function CopyBDKI: string;
    function GetBasePath(const aItemName: string): string;
    constructor Create(const aBasePath: string = '');
    destructor Destroy; override;
  end;

implementation

uses SysUtils, Dialogs, Controls, ASU_DBF, Windows, DateUtils;

function GetDateFromBD02KiSi(const aSi: string): TDate;
begin
  Result := EncodeDate(strtoint('20'+aSi[13] + aSi[14]), strtoint(aSi[10] + aSi[11]),
    strtoint(aSi[7] + aSi[8]));
end;

function SetDateToBD02KiSi(const aDate: TDate; const aSiText: string): string;
var
  s: string;
  c: char;
begin
  c := aSiText[9];
  DateTimeToString(s, 'dd"' + c + '"mm"' + c + '"yy', aDate);
  Result := copy(aSiText, 1, 6) + s + copy(aSiText, 15, Length(aSiText) - 14);
end;

{ TClassCopyBd }

function TClassCopyBd.CopyBDKI: string;
const
  scFilePostfix = 'y';
  ncItemNumber = 3;
type
  TTableCopyItem = record
    oldname, newname, oldpath, newpath: string
  end;
  TTableCopyList = array[1..ncItemNumber] of TTableCopyItem;
var
  aCopyBdArray: TTableCopyList;
  i: integer;
  s: string;
  aSi: ASU_SI;
  aDt1: TDate;
  sOldFile, sNewFile: string;
    { TODO -oСтеценко : Сделать проверку на монопольный доступ }

  function CopyBdKiFile: string;
  var
    s1:string;
  begin
    //sOldFile := aCopyBdArray[i].oldpath + aCopyBdArray[i].oldname;
    if CopyFileEx(PAnsiChar(sOldFile), PAnsiChar(sNewFile), nil, nil, nil, 0)
      = False then
      Result := 'ошибка копирования в ' + sNewFile
    else
    begin
      s1 := SetDateToBD02KiSi(date, s);
      aSi.si_text := s1;
      if PutSI(sNewFile, aSi) = False then
        Result := 'ошибка записи служебн информ в ' + sNewFile;
    end;
  end;

begin
  Result := '';
  aCopyBdArray[1].oldname := 'bd02ki.dbf';
  aCopyBdArray[1].newname := 'bd02kiy.dbf';
  aCopyBdArray[2].oldname := 'bd02ki04.dbf';
  aCopyBdArray[2].newname := 'bdki04y.dbf';
  aCopyBdArray[3].oldname := 'bd02ki98.dbf';
  aCopyBdArray[3].newname := 'bdki98y.dbf';
  i := 0;
  while (i < ncItemNumber) and (Result = '') do
  begin
    inc(i);
    aCopyBdArray[i].oldpath := GetBasePath(aCopyBdArray[i].oldname);
    aCopyBdArray[i].newpath := aCopyBdArray[i].oldpath;
    if aCopyBdArray[i].oldpath = '' then
      Result := 'не найден ' + aCopyBdArray[i].oldname;
  end;
  if Result = '' then
  begin
    i := 0;
    while (i < ncItemNumber) and (Result = '') do
    begin
      inc(i);
      sNewFile := aCopyBdArray[i].newpath + aCopyBdArray[i].newname;
      sOldFile := aCopyBdArray[i].oldpath + aCopyBdArray[i].oldname;
      if FileExists(sNewFile) then
      begin
        aSi := GetSI(sNewFile);
        s := aSi.si_text;
        aDt1 := GetDateFromBD02KiSi(aSi.si_text);
        if aDt1 <> date then
          Result := CopyBdKiFile;
      end
      else
        begin
        aSi := GetSI(sOldFile);
        Result := CopyBdKiFile;
        end;
    end;
  end;
end;

constructor TClassCopyBd.Create(const aBasePath: string);
begin
  FBasesPDO := aBasePath;
  if DirectoryExists(FBasesPDO) then
  begin
    FBasesFileName := FBasesPDO + scBases;
    FBasesIndexName := FBasesPDO + scBasesIndex;
    FBasesTable := TVKDBFNTX.Create(nil);
    FBasesTable.AccessMode.AccessMode := 64;
    FBasesTable.LockProtocol := lpClipperLock;
    FBasesTable.LobLockProtocol := lpClipperLock;
    FBasesTable.DbfVersion := xClipper;
    FBasesTable.DBFFileName := FBasesFileName;
    FBasesTable.OEM := True;
    FBasesTable.TrimCType := True;
    FBasesTable.TrimInLocate := True;
    with FBasesTable.Indexes.Add as TVKNTXIndex do
      NTXFileName := FBasesIndexName;
    FBasesTable.Open;
    FBasesTable.SetOrder(1);
  end
  else
    ; //директории нет, надо генерировать исключение
end;

destructor TClassCopyBd.Destroy;
begin
  if Assigned(FBasesTable) then
  begin
    FBasesTable.Close;
    FreeAndNil(FBasesTable);
  end;
  inherited;
end;

function TClassCopyBd.GetBasePath(const aItemName: string): string;
begin
  Result := '';
  if FBasesTable.Locate('name', aItemName, [loPartialKey]) then
    Result := FBasesTable.FieldByName('path').AsString;
end;

procedure TClassCopyBd.SetBasesPDO(const Value: string);
begin
  FBasesPDO := Value;
end;

end.

