unit UntMain;

interface
uses Classes, DB, VKDBFDataSet, VKDBFNTX, UaPDO {, VKDBFIndex, VKDBFSorters};

const
  scBases = 'basespdo.dbf';
  scBasesIndex = 'basespdo.ntx';
  aPDO_array_count = 15;

  scTestList1 = 'bd02ph.dbf ns02oc.dbf pl03iz.dbf pl03ps.dbf pl02izs.dbf ' +
    'pl02pss.dbf pl01k1.dbf pl01k2.dbf pl01k3.dbf pl03k1.dbf ' +
    'pl03k1i.dbf pl03k2.dbf pl03k2i.dbf pl03k3.dbf pl03k3i.dbf ' +
    'pl03k4.dbf pl03k4i.dbf pl05ps.dbf pl05iz.dbf';

  scTestList2 = 'pl03iz.dbf pl03ps.dbf pl02izs.dbf ' +
    'pl02pss.dbf pl01k1.dbf pl01k2.dbf pl01k3.dbf pl03k1.dbf ' +
    'pl03k1i.dbf pl03k2.dbf pl03k2i.dbf pl03k3.dbf pl03k3i.dbf ' +
    'pl03k4.dbf pl03k4i.dbf pl05ps.dbf pl05iz.dbf';

type

  TClassCopyBd = class(TObject)
  private
    FBasesTable: TVKDBFNTX;
    FaPDO, FaASU: TaPDO;
    FaPDO_dopol: TStringList;
    FBasesPDO: string;
    FBasesFileName: string;
    FBasesIndexName: string;
    Fput_ki56, Fput_bl56: string;
    Fkv_pl05_asu, Fkv_pl03_asu: string;
    Fkar_path: string;
    procedure SetBasesPDO(const Value: string);
    procedure SetaPDO_dopol(const Value: TStringList);
    procedure SetKar_path(const Value: string);
    procedure SetPut_bl56(const Value: string);
    procedure SetPut_ki56(const Value: string);
    procedure Setkv_pl03_asu(const Value: string);
    procedure Setkv_pl05_asu(const Value: string);
  public
    property BasesPDO: string read FBasesPDO write SetBasesPDO;
    property aPDO_dopol: TStringList read FaPDO_dopol write SetaPDO_dopol;
    property BasesFileName: string read FBasesFileName;
    property BasesIndexName: string read FBasesIndexName;
    property Put_ki56: string read FPut_ki56 write SetPut_ki56;
    property Put_bl56: string read FPut_bl56 write SetPut_bl56;
    property Kar_path: string read FKar_path write SetKar_path;
    property kv_pl05_asu: string read Fkv_pl05_asu write Setkv_pl05_asu;
    property kv_pl03_asu: string read Fkv_pl03_asu write Setkv_pl03_asu;
    function CopyBDKI: string;
    function GetBasePath(const aItemName: string): string;
    function GetArchPath(const aItemName: string): string;
    function Prepare: string;
    function Copy_new_db: string;
    function Delete_arh(const aYear: string): string;
    function Create_arh(const aYear: string): string;
    function ZaverOK: string;
    function PoiskCen(const dir_cen, nam_cen: string; const aASUNum: integer):
      boolean;
    function Adding: string;
    constructor Create(const aBasePath: string = '');
    destructor Destroy; override;
  end;

implementation

uses SysUtils, Dialogs, Controls, ASU_DBF, Windows, DateUtils, SAVLIB_DBF,
  SAVLIB, mnalib, strutils;

function GetDateFromBD02KiSi(const aSi: string): TDate;
begin
  Result := EncodeDate(strtoint('20' + aSi[13] + aSi[14]), strtoint(aSi[10] +
    aSi[11]),
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
{
В случае ошибки возвращает описание ошибки, в случае успеха - возвращает пустую строку
}

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
    s1: string;
  begin
    //sOldFile := aCopyBdArray[i].oldpath + aCopyBdArray[i].oldname;
    if CopyFileEx(PAnsiChar(sOldFile), PAnsiChar(sNewFile), nil, nil, nil, 0)
      = False then
      Result := 'ошибка копирования ' + sOldFile + ' в ' + sNewFile
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
  Fput_ki56 := '';
  Fput_bl56 := '';
  Fkar_path := '';
  Fkv_pl05_asu := '';
  Fkv_pl03_asu := '';
  FBasesPDO := aBasePath;
  FaASU := TaPDO.Create;
  with FaASU do
  begin
    Add('sm50.dbf');
    Add('ns02oc.dbf');
    Add('bd02nzn.dbf');
    Add('bd02nc.dbf');
    Add('bd02ki.dbf');
    Add('ns02cm.dbf');
    Add('bd02ki04.dbf');
    Add('bd02ki98.dbf');
    Add('pl03iz.dbf');
    Add('pl03ps.dbf');
    Add('bd04rs.dbf');
    Add('mp31.dbf');
    Add('ns05tn.dbf');
    Add('pl05iz.dbf');
    Add('pl05ps.dbf');
  end;
  FaPDO := TaPDO.Create;
  with FaPDO do
  begin
    Add('sm50.dbf');
    Add('ns02oc.dbf');
    Add('bd02vc.dbf');
    Add('bd02nc.dbf');
    Add('bd02ki.dbf');
    Add('ns02cm.dbf');
    Add('bd02ki04.dbf');
    Add('bd02ki98.dbf');
    Add('pl03iz.dbf');
    Add('pl03ps.dbf');
    Add('bd04rs.dbf');
    Add('mp31.dbf');
    Add('ns05tn.dbf');
    Add('pl05iz.dbf');
    Add('pl05ps.dbf');
  end;
  FaPDO_dopol := TStringList.Create;
  with FaPDO_dopol do
  begin
    Add('bd02ki_.dbf=');
    Add('bd02nc1.dbf=');
    Add('bd02ph.dbf=');
    Add('bd04rs.dbf=');
    Add('bd12rs.dbf=');
    Add('bd12tc.dbf=');
    Add('bd200.dbf=');
    Add('bdki561.dbf=');
    Add('bdki562.dbf=');
    Add('bdkitm.dbf=');
    Add('bdrasp.dbf=');
    Add('blaniz_s.dbf=');
    Add('blank561.dbf=');
    Add('blank562.dbf=');
    Add('blanks.dbf=');
    Add('blanksiz.dbf=');
    Add('blanksm.dbf=');
    Add('blankstm.dbf=');
    Add('blanm_s.dbf=');
    Add('blanp561.dbf=');
    Add('blanp562.dbf=');
    Add('blanph.dbf=');
    Add('blanphiz.dbf=');
    Add('blanphm.dbf=');
    Add('blanphtm.dbf=');
    Add('blan_s.dbf=');
    Add('grf.dbf=');
    Add('grf_cex.dbf=');
    Add('mp31.dbf=');
    Add('nstd.dbf=');
    Add('nstda.dbf=');
    Add('pl01sb.dbf=');
    Add('pl03iz.dbf=');
    Add('pl03ps.dbf=');
    Add('pl05iz.dbf=');
    Add('pl05ps.dbf=');
    Add('sbt.dbf=');
    Add('sklad.dbf=');
    Add('sklad_s.dbf=');
    Add('skl_nakl.dbf=');
    Add('spr_rasp.dbf=');
  end;
  if DirectoryExists(FBasesPDO) then
  begin
    FBasesFileName := FBasesPDO + scBases;
    FBasesIndexName := FBasesPDO + scBasesIndex;
    FBasesTable := TVKDBFNTX.Create(nil);
    InitOpenDBF(FBasesTable, FBasesFileName, 66);
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
  FreeAndNil(FaASU);
  FreeAndNil(FaPDO);
  FreeAndNil(FaPDO_dopol);
  inherited;
end;

function TClassCopyBd.Prepare: string;
const
  csTemp = 'temp';
var
  s_1: string;
  s_path,
    csi: string; // служебная информация
  lsi: integer; //длина служебной информации
  i, n: integer;
  Table1: TVKDBFNTX;
begin
  Result := CopyBDKI;
  if Result = '' then
  begin
    s_1 := GetBasePath('blanks.dbf');
    if s_1 <> '' then
    begin
      if not DirectoryExists(s_1) then
        Result := 'Каталог ' + s_1 + ' не найден'
      else
      begin
        Kar_path := s_1;
        s_1 := s_1 + csTemp;
        if not CreateDir(s_1) then
          Result := 'Ошибка создания каталога' + s_1;
      end;
    end;
    if Result <> '' then
    begin
      i := 0;
      while (i < FaPDO.Count) and (Result = '') do
      begin
        s_path := GetBasePath(FaPDO._Name[i]);
        if s_path = '' then
          Result := 'В basespdo.dbf не найден ' + FaPDO._Name[i]
        else
        begin
          FaPDO._Path[i] := s_path;
          csi := '';
          s_path := s_path + FaPDO._Name[i];
          if FileExists(s_path) then
          begin
            with FaPDO do
            begin
              csi := GetSI(s_path).si_text;
              if csi <> '' then
              begin
                _Generation[i] := strtoint(copy(csi, 15, 3));
                lsi := StrToIntDef(copy(csi, 18, 3), 0);
                if lsi <> 0 then
                  _SI[i] := copy(csi, 21, lsi);
                if (_Name[i] = 'pl03ps') or (_Name[i] = 'pl03iz') or
                  (_Name[i] = 'pl02izs') or (_Name[i] = 'pl02pss') or
                  (_Name[i] = 'pl01k1') or (_Name[i] = 'pl01k2') or
                  (_Name[i] = 'pl01k3') or (_Name[i] = 'pl03k1') or
                  (_Name[i] = 'pl03k1i') or (_Name[i] = 'pl03k2') or
                  (_Name[i] = 'pl03k2i') or (_Name[i] = 'pl03k3') or
                  (_Name[i] = 'pl03k3i') or (_Name[i] = 'pl03k4') or
                  (_Name[i] = 'pl03k4i') or (_Name[i] = 'pl05ps') or
                  (_Name[i] = 'pl05iz') then
                begin
                  //дата плана в формате квартал/год(2 цифры)
                  if (_Name[i] = 'pl01k1') or (_Name[i] = 'pl01k2') or (_Name[i]
                    =
                    'pl01k3') then
                  begin
                    if lsi <> 0 then
                      _Date[i] := copy(csi, 21, 4);
                  end
                  else
                    _Date[i] := copy(csi, 28, 4);
                end
                else
                  _Date[i] := copy(cSi, 7, 8);
              end
            end
          end
          else
          begin
            FaPDO._Generation[i] := 0;
            FaPDO._Date[i] := '';
            FaPDO._SI[i] := '';
          end;
          inc(i);
        end;
      end;
      i := 0;
      n := FaPDO_dopol.Count;
      while (i < n) and (Result = '') do
      begin
        s_path := GetBasePath(FaPDO_dopol.Names[i]);
        if s_path = '' then
          Result := 'Файл ' + FaPDO_dopol.Names[i] + ' в BASESPDO.dbf не найден'
        else
        begin
          FaPDO_dopol.ValueFromIndex[i] := s_path + FaPDO_dopol.Names[i];
          if FaPDO_dopol.Names[i] = 'bdki561.dbf' then
            put_ki56 := s_path;
          if FaPDO_dopol.Names[i] = 'blank561.dbf' then
            put_bl56 := s_path;
          inc(i);
        end;
      end;
      if Result = '' then
      begin
        s_path := GetBasePath('korved.dbf');
        if s_path <> '' then
        begin
          s_path := s_path + 'korved.dbf';
          if FileExists(s_path) then
          begin
            Table1 := TVKDBFNTX.Create(nil);
            InitOpenDBF(Table1, s_path, 2);
            Table1.Open;
            Table1.Truncate;
            Table1.Close;
            FreeAndNil(Table1);
            s_path := GetBasePath('korved.ntx');
            if s_path <> '' then
              DeleteFile(PAnsiChar(s_path));
          end;
        end;
      end;
    end;
  end;
end;

function TClassCopyBd.GetBasePath(const aItemName: string): string;
begin
  Result := '';
  if FBasesTable.Locate('name', aItemName, [loPartialKey]) then
    Result := FBasesTable.FieldByName('path').AsString;
end;

procedure TClassCopyBd.SetaPDO_dopol(const Value: TStringList);
begin
  FaPDO_dopol := Value;
end;

procedure TClassCopyBd.SetBasesPDO(const Value: string);
begin
  FBasesPDO := Value;
end;

procedure TClassCopyBd.SetKar_path(const Value: string);
begin
  FKar_path := Value;
end;

procedure TClassCopyBd.SetPut_bl56(const Value: string);
begin
  FPut_bl56 := Value;
end;

procedure TClassCopyBd.SetPut_ki56(const Value: string);
begin
  FPut_ki56 := Value;
end;

function TClassCopyBd.Copy_new_db: string;
var
  i, n, lSi: integer;
  s, arh_year: string;
  cSi: string;
  Table1: TVKDBFNTX;
  t_bd02ASU, t_pl03ASU, t_bd02PDO, t_pl03PDO: integer;

  procedure Check_1(out Peremen1: integer; const DateText: string; const
    CopyStart: integer);
  var
    s1: string;
  begin
    s1 := copy(DateText, CopyStart, 2);
    if Trim(s1) = '' then
      Peremen1 := 0
    else
      Peremen1 := 2000 + strtoint(s1);
  end;

begin
  Result := ZaverOK;
  if Result = '' then
  begin
    n := FaASU.Count - 1;
    Table1 := TVKDBFNTX.Create(nil);
    Table1.TrimCType := True;
    Table1.DbfVersion := xClipper;
    Table1.LockProtocol := lpClipperLock;
    for i := 0 to n do
    begin
      s := GetBasePath(FaASU._Name[i]);
      if s <> '' then
      begin
        if copy(FaASU._Name[i], 1, 6) = 'bd02nz' then
        begin
          s := GetArchPath(FaASU._Name[i]);
          if s <> '' then
            PoiskCen(s, 'bd02nz', i);
        end
        else
          FaASU._Path[i] := s;
        cSi := '';
        s := IncludeTrailingPathDelimiter(FaASU._Path[i]) + FaASU._Name[i];
        if FileExists(s) then
        begin
          if (copy(FaASU._Name[i], 1, 6) = 'bd02nz') or
            (pos(FaASU._Name[i], scTestList1) > 0) then
          begin
            if NetUseMN(Table1, s, False, 5) then
            begin
              if Table1.IsEmpty then
                Result := 'Файл ' + s + ' пуст!'
              else
                Table1.Close;
            end
            else
              Result := 'Файл ' + s + ' не доступен!';
          end;
          //Masha COPY_BD.RPG 850
          if Result = '' then
          begin
            csi := ASU_DBF.GetSI(s).si_text;
            lSi := 0;
            if Trim(csi) <> '' then
            begin
              //взять номер поколения
              FaASU._Generation[i] := strtoint(copy(csi, 15, 3));
              lSi := strtointdef(copy(csi, 18, 3), 0);
              //если есть служ.инф-ция
              if lSi <> 0 then //то заносим в массив
                FaASU._SI[i] := copy(csi, 21, lsi);
              if pos(FaASU._Name[i], scTestList2) > 0 then
              begin
                //дата плана в формате квартал(1 цифра)/год(2 цифры)
                if (FaASU._Name[i] = 'pl01k1.dbf') or (FaASU._Name[i] =
                  'pl01k2.dbf')
                  or (FaASU._Name[i] = 'pl01k3.dbf') then //Макарова
                begin
                  if lSi <> 0 then
                    FaASU._Date[i] := copy(cSi, 21, 4)
                end
                else
                begin
                  FaASU._Date[i] := copy(cSi, 28, 4);
                  //вставлено для последующего анализа если kv_pl05_asu<>kv_pl03_asu то карточки не переформировывать
                  if FaASU._Name[i] = 'pl05ps.dbf' then
                    kv_pl05_asu := FaASU._Date[i]
                  else if FaASU._Name[i] = 'pl03ps.dbf' then
                    kv_pl03_asu := FaASU._Date[i];
                end;
              end
              else
                FaASU._Date[i] := Copy(cSi, 7, 8); //дата
            end;
          end;
        end
        else
        begin
          FaASU._Date[i] := '';
          FaASU._Generation[i] := 0;
        end;
      end
      else
      begin
        Result := 'Файл ' + FaASU._Name[i] + ' не найден в bases.dbf';
        Break;
      end;
    end;
    Table1.Close;
    FreeAndNil(Table1);
    if Result = '' then
    begin
      //Анализ на ЗАВЕРШЕНИЕ ГОДА (необходимость создания АРХИВА) COPY_BD.PRG 910
      //запоминаем значения года для БД bd02nc и pl03ps на серверах АСУ и ПДО
      n := FaASU.Count - 1;
      for i := 0 to n do
      begin
        if FaASU._Name[i] = 'bd02nc.dbf' then
          Check_1(t_bd02ASU, FaASU._Date[i], 7);
        if FaASU._Name[i] = 'pl03ps.dbf' then
          Check_1(t_pl03ASU, FaASU._Date[i], 3);
      end;
      n := FaPDO.Count - 1;
      for i := 0 to n do
      begin
        if FaPDO._Name[i] = 'bd02nc.dbf' then
          Check_1(t_bd02PDO, FaASU._Date[i], 7);
        if FaPDO._Name[i] = 'pl03ps.dbf' then
          Check_1(t_pl03PDO, FaASU._Date[i], 3);
      end;
      //если год pl03ps и год bd02nc на сервере АСУ равны и больше, чем года
      //соответствующих им БД на сервере ПДО, то необх. провести архивацию данных
      if (t_bd02ASU = t_pl03ASU) and (t_bd02ASU - 1 = t_bd02PDO) and (t_pl03ASU
        - 1 = t_pl03PDO) then
      begin
        arh_year := inttostr(t_pl03PDO); //архивируемый год
        //If DirChange('c:\karta\'+arh_year+'\')==0
        if DirectoryExists(Kar_path + 'arhiv\' + arh_year + '\') then
        begin
          ; //архив уже есть
        end
        else
        begin
          Result := Create_arh(arh_year);
          if Result = '' then
          begin
            //  f_notadd:=1
            { TODO : НАДО ДОДЕЛАТЬ ТУТ! }
          end;
        end;
      end;
    end;
  end;
end;

function TClassCopyBd.Delete_arh(const aYear: string): string;
var
  arh_path: string;
begin
  Result := '';
  arh_path := Kar_path + 'arhiv\' + aYear + '\';
  if DirectoryExists(arh_path) then
  begin
    if FBasesTable.Locate('name', 'arhiv' + aYear, [loPartialKey]) then
    begin
      FBasesTable.Delete;
      FBasesTable.Pack;
      { TODO : Добавить реиндексацию basespdo }
    end;
    if DelDir(arh_path) = False then
      Result := 'Не удалось удалить каталог ' + arh_path +
        ' Удалите каталог вручную!';
  end
  else
    Result := 'Архив за ' + aYear + ' год не существует';
end;

function TClassCopyBd.ZaverOK: string;
const
  csBd02ki = 'bd02ki.dbf';
var
  NP_ASU, NP_PDO: integer; // номер поколения
  j: integer;
  si_ASU, s_path1,
    date_ASU, date_PDO, s: string;
begin
  s_path1 := GetBasePath(csBd02ki);
  if s_path1 = '' then
    Result := 'Файл BD02KI не найден в BASES.dbf'
  else
  begin
    Result := '';
    si_ASU := '';
    NP_ASU := -1;
    date_ASU := '';
    s_path1 := s_path1 + csBd02ki;
    if FileExists(s_path1) then
    begin
      si_ASU := ASU_DBF.GetSI(s_path1).si_text;
      NP_ASU := StrToIntDef(copy(si_ASU, 15, 3), -1);
      date_ASU := copy(si_ASU, 7, 8);
    end;
    j := FaPDO.NumByName(csBd02ki);
    date_PDO := FaPDO._Date[j];
    if NP_ASU <> FaPDO._Generation[j] then
    begin //завершение не производилось
      s := 'Не выполнялось завершение работы за ' + date_PDO +
        '. Продолжить?';
      if MessageBox(0, PAnsiChar(s), 'ВНИМАНИЕ!!!', MB_YESNO +
        MB_ICONWARNING +
        MB_TASKMODAL) = IDYES then
      begin
        s := 'Будет восстановлена база данных за  ' + date_ASU +
          '  Корректировки за ' + date_PDO + 'БУДУТ УДАЛЕНЫ! Продолжить?';
        if MessageBox(0, PAnsiChar(s), 'ВНИМАНИЕ!!!', MB_YESNO +
          MB_ICONQUESTION
          + MB_TASKMODAL) <> IDYES then
          Result := 'Отмена обновления';

      end
      else
        Result := 'Отмена обновления';
    end;
  end;
end;

function TClassCopyBd.PoiskCen(const dir_cen, nam_cen: string; const
  aASUNum:
  integer): boolean;
var
  vFind, i, j, n: integer;
  vPath, vGod, vName, vMes: string;
  aDir: TStringList;
  (*

procedure provNameFile(namFile,lenName,vPath)
Local vMes0,vSi
  vMes0:=substr(namFile,lenName+1,len(namFile)-4-lenName)
  if !provCifr(vMes0,2)
    return .F.
  endif
  vSi:=getsi(vPath+namFile)
  if (substr(vSi, 10, 2)<>vMes0) .or. (substr(vSi, 13, 2)<>substr(vGod,3,2))
    return .F.
  endif
  if  (vMes0>vMes)
    vMes:=vMes0
  endif
return .T.

  *)

  function provCifr(const vStr: string; const vLen: integer): boolean;
  var
    k: integer;
    strCifr: string;

  begin
    if Length(Trim(vStr)) <> vLen then
      Result := False
    else
    begin
      for k := 1 to vLen do
        case vStr[k] of
          '1'..'9': ;
        else
          Result := False;
          Exit;
        end;
      Result := True;
    end;
  end;

  procedure provNameDir(const namDir: string);
  begin
    if provCifr(namDir, 4) and (namDir > vGod) then
      vGod := namDir;
  end;

  function provNameFile(const namFile: string; const lenName: integer;
    const
    vPath: string): boolean;
  var
    vMes0, vSi: string;
  begin
    vMes0 := copy(namFile, lenName + 1, length(namFile) - 4 - lenName);
    if not provCifr(vMes0, 2) then
      Result := False
    else
    begin
      vSi := getsi(vPath + namFile).si_text;
      Result := not ((copy(vSi, 10, 2) <> vMes0) or (copy(vSi, 13, 2) <>
        copy(vGod, 3, 2)));
      if Result and (vMes0 > vMes) then
        vMes := vMes0;
    end
  end;

  procedure GetDirectoryList(DirList: TStrings; const aDirName: string =
    '';
    const aFilter: string = '*.*');
  var
    sr: TSearchRec;
    sDirPath: string;
  begin
    sDirPath := IncludeTrailingPathDelimiter(aDirName) + aFilter;
    DirList.Clear;
    if SysUtils.FindFirst(sDirPath, faAnyFile, sr) = 0 then
      repeat
        if sr.Attr and faDirectory <> 0 then
          DirList.Add(sr.Name);
      until SysUtils.FindNext(sr) <> 0;
    SysUtils.FindClose(sr);
  end;

  procedure GetFilesList(FileList: TStrings; const aDirName: string = '';
    const
    aFilter: string = '*.*');
  var
    SearchRec: TSearchRec;
    sDirPath: string;
  begin
    sDirPath := IncludeTrailingPathDelimiter(aDirName) + aFilter;
    if SysUtils.FindFirst(sDirPath, faAnyFile - faDirectory, SearchRec) = 0 then
      try
        FileList.Add(SearchRec.Name);
        while SysUtils.FindNext(SearchRec) = 0 do
          FileList.Add(SearchRec.Name);
      finally
        SysUtils.FindClose(SearchRec);
      end;
  end;

begin
  Result := True;
  aDir := TStringList.Create;
  vFind := pos('*', dir_cen);
  if vFind > 0 then
  begin
    vPath := Copy(dir_cen, 1, pred(vFind));
    GetDirectoryList(aDir, vPath, '20??');
    if aDir.Count = 0 then
      Result := False
    else
    begin
      vGod := '2011';
      i := 0;
      while i < aDir.Count do
      begin
        provNameDir(ExtractFileName(aDir[i]));
        inc(i);
      end;
      if vGod <> '2011' then
      begin
        vFind := Pos('.', nam_cen);
        if vFind = 0 then
          vFind := length(nam_cen)
        else
          dec(vFind);
        vName := copy(nam_cen, 1, vFind);
        while vGod > '2011' do
        begin
          vPath := stringReplace(dir_cen, '*', vGod, [rfReplaceAll]);
          GetFilesList(aDir, IncludeTrailingPathDelimiter(vPath) + vName,
            '??.dbf');
          if aDir.Count = 0 then
          begin
            vGod := inttostr(pred(strtoint(vGod)));
            Continue;
          end;
          vMes := '00';
          // aeval(aDir,{|aFile|provNameFile(aFile[F_NAME],vFind,vPath)})
          i := 0;
          while i < aDir.Count do
          begin
            provNameFile(aDir[i], vFind, vPath);
            inc(i);
          end;
          if vMes > '00' then
            Break;
          vGod := inttostr(strtoint(vGod) - 1);
        end;
        if vGod = '2011' then
          Result := False
        else
        begin
          FaASU._Name[aASUNum] := nam_cen + vMes + '.dbf';
          { TODO : тут добавил расширение .dbf }
          FaASU._Path[aASUNum] := vPath;
        end;
      end
      else
        Result := False;
    end
  end
  else
    Result := False;
  FreeAndNil(aDir);
end;

function TClassCopyBd.GetArchPath(const aItemName: string): string;
begin
  Result := '';
  if FBasesTable.Locate('name', aItemName, [loPartialKey]) then
    Result := FBasesTable.FieldByName('arch').AsString;
end;

procedure TClassCopyBd.Setkv_pl03_asu(const Value: string);
begin
  Fkv_pl03_asu := Value;
end;

procedure TClassCopyBd.Setkv_pl05_asu(const Value: string);
begin
  Fkv_pl05_asu := Value;
end;

(*Процедура завершения года (СОЗДАНИЕ АРХИВА)*)

function TClassCopyBd.Create_arh(const aYear: string): string;
var
  arh_path: string;
  //dir,cget_pic,si_mp31
  s: string;
begin
  Result := '';
  arh_path := kar_path + 'arhiv\' + aYear + '\';
  if DirectoryExists(arh_path) then
  begin
    if ForceDirectories(arh_path) then
    begin
      s := 'arhiv' + aYear;
      if FBasesTable.Locate('name', s, []) then
        FBasesTable.Edit
      else
        FBasesTable.Append;
      FBasesTable.FieldByName('name').AsString := s;
      FBasesTable.FieldByName('path').AsString := arh_path;
      FBasesTable.Post;
      FBasesTable.Reindex
        { TODO -oСтеценко : Проверить, нужно ли тут переиндексировать? }
      { TODO -oСтеценко : ТУТ ДЕЛАЮ }
    end
    else
      Result := 'Ошибка создания каталога"' + arh_path + '"';
  end
  else
    Result := 'Каталог "' + arh_path +
      '" существует. Возможно архив был создан ранее.';
end;

(*Процедура накопления данных по накладным за каждый месяц из bd02nc в bd12tc*)

function TClassCopyBd.Adding: string;
var
  i: integer;
begin
  i := FaPDO.NumByName('bd02nc.dbf');
    { TODO -oСтеценко : ТУТ ДЕЛАЮ последний }
end;

end.

