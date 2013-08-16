                              /*2004 г.*/
           /*Программа корректировки карточки планом прошлого периода*/
                          /*Сетевой вариант*/
///////////////////
////////////////// При корр-ке карточки планом прошлого периода изменяются только БД blanks(-iz,-tm,-m), blan_s(-m_s,-iz_s)
/////////////////не переформируются объед.чертежи, склад, распор.
#include "box.ch"
#include "inkey.ch"
#include "achoice.ch"
#include "directry.ch"
Proc kkart(path_bas)
Local vr

Set Procedure To f_kart

/*Массив aPDO содержит:
1-имя БД, перебрасываемой с сервера ОАСУП на сервер ПДО
2-путь к БД на сервере ПДО (берется из h:\basespdo.dbf)
3-номер поколения БД на сервере ПДО (GetSi())
4 - дата набора
5 - служебная информация (без 3-х байт длины служебной информации)*/
aPDO:={{'pl03psk1','','','',''},{'pl03izk1','','','',''},;
       {'pl03psk2','','','',''},{'pl03izk2','','','',''},;
       {'pl03psk3','','','',''},{'pl03izk3','','','',''},;
       {'pl03psk4','','','',''},{'pl03izk4','','','',''}}
/*Дополнит. массив, к-рый содержит:
1-имя БД, которая может принимать участие в переформировании БД на сервере ПДО
2-имя переменной, в к-рой будет содержаться путь+имя БД*/
aPDO_dopol:={{'blanks','n_blan'},{'blanksiz','n_blaniz'},{'blankstm','n_blantm'},{'blanksm','n_blanm'},;
     {'blan_s','n_blan_s'},{'blaniz_s','n_blaniz_s'},{'blanm_s','n_blanm_s'},;
     {'bdki561','n_bdki561'},{'bdki562','n_bdki562'},;
     {'blank561','n_blk561'},{'blank562','n_blk562'},{'bdkitm','n_bdkitm'}}
//это временные БД - разбиение 56 цеха по участкам
//blan_s, blaniz_s - БД содержат позиции введенные и снятые в одном квартале

Private n_pl03ps,n_pl03iz,cSi:="",blanks_Si:="",blanph_Si:="",pl03ps_Si:="",bd02ph_Si:="",;
        f_notadd:=0,f_notcopy:=0,f_new:=0,num_kv:="",;
        f_rasp_plan:=0,arh_path:="",kar_path:="",;
        /*Masha*/put_ki56:="",put_bl56:="",tek_kv
        //Masha - путь к bdki561 и к blank561
        //путь к архиву, путь к каталогу KARTA
        //f_rasp_plan=0, если не переформировывать БД распоряжений от плана
   //чтобы выделять из плана (добавки) вводим флаг f_new
   //f_new==0, если в blanks формируется новый квартал
   //f_new==1, если пересоздается тот же квартал, т.е если пересоздаются
              //карточки в результате добавки к плану в том же квартале
   //num_kv - номер квартала из pl03ps(ПДО),полученного после обновления
   /*f_notadd - флаг вводим для того, чтобы не накапливать в новом году данные
     за декабрь прошлого года. Если был создан архив, то f_notadd:=1*/
   /*f_notcopy - флаг вводим для следующей ситуации: если bd02ki еще за
     прошлый год, а pl03ps уже за новый год, то f_notcopy:=1. В этом случае
     pl03ps, pl03iz и bd02ph не копируются с сервера АСУ до тех пор пока
     не будет создан архив за прошлый год.*/
//Masha
//структура bdkitm - ТМ по ключу bd02ki
aBdkitm:={{'CEX','C',2,0},{'CHERT','C',13,0},{'PS','C',1,0},;
          {'VP','C',1,0},{'CP','C',2,0},{'KI','C',4,0},{'TM','C',24,0}}
//Masha
Public path_base //Путь BasesPdo
  if path_bas=nil
    path_base:=""
  else
    path_base:=path_bas
  endif

Set Date To German
Set ScoreBoard Off
Set SoftSeek Off

Clear Screen
Save Screen
Set Cursor Off
old_b=SetBlink(.T.)
NewColor='N/BG'
OldColor=SetColor(NewColor)
@ 0,0 Clear to 24,79

/*Меню*/

m_end:=.T.
Do While m_end
   /*Читаем данные из basespdo.dbf (сервер ПДО)*/
  if !File(vr:=path_base+"BASESPDO.dbf") .or. !File(vr:=path_base+"BASESPDO.ntx")
    alert("Нет файла "+vr)
    Restore Screen
    Clear All
    Close All
    Quit
  endif
  If AlNetUse(path_base+"basespdo.dbf",.F.,5)
      Set Index To (path_base+"basespdo.ntx")
  Else
      my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
      @ 12,19 Say'      Файл BASESPDO.DBF     '
      @ 13,19 Say'           не доступен.  '
      @ 14,19 Say'    Нажмите любую клавишу ...  '
      InKey(0)
      Restore Screen
      Clear All
      Close All
      Quit
  EndIf

   If (basespdo->(dbSeek("blanks.dbf")))
      kar_path:=AllTrim(basespdo->path) //это рабочий каталог карт учета
      If !DirChangeMN(kar_path+"temp",10)
        //создаем директорию (temp) для
        If DirMake(kar_path+"temp")!=0
          alert("    Ошибка создания каталога "+Upper(kar_path+"temp\"))
          Restore Screen
          Clear Screen
          Close All
          Quit
        EndIf
      EndIf
   EndIf

   If (basespdo->(dbSeek("pl03ps.dbf")))
      n_pl03ps:=AllTrim(basespdo->arch)
   Else
      my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
      @ 12,19 Say'          Файл '+Upper(aPDO[i,1])
      @ 13,19 Say' в  BASESPDO.dbf  не найден    '
      @ 14,19 Say'    Нажмите любую клавишу ...  '
      InKey(0)
      Restore Screen
      Clear All
      Close All
      Quit
   EndIf

   If (basespdo->(dbSeek("pl03iz.dbf")))
      n_pl03iz:=AllTrim(basespdo->arch)
   Else
      my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
      @ 12,19 Say'          Файл '+Upper(aPDO[i,1])
      @ 13,19 Say' в  BASESPDO.dbf  не найден    '
      @ 14,19 Say'    Нажмите любую клавишу ...  '
      InKey(0)
      Restore Screen
      Clear All
      Close All
      Quit
   EndIf

   /*получение путь+имя+".dbf" для БД, которые могут переформировываться в ПДО*/
   For i:=1 To Len(aPDO_dopol)
     If (basespdo->(dbSeek(aPDO_dopol[i,1]+".dbf")))
        &(aPDO_dopol[i,2]):=AllTrim(basespdo->path)+aPDO_dopol[i,1]
//Masha
        If (aPDO_dopol[i,1]=="bdki561")
           put_ki56 = AllTrim(basespdo->path)
        EndIf
        If (aPDO_dopol[i,1]=="blank561")
           put_bl56 = AllTrim(basespdo->path)
        EndIf
//Masha
     Else
        my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
        @ 12,19 Say'          Файл '+Upper(aPDO_dopol[i,1])
        @ 13,19 Say' в  BASESPDO.dbf  не найден    '
        @ 14,19 Say'    Нажмите любую клавишу ...  '
        InKey(0)
        Restore Screen
        Clear All
        Close All
        Quit
     EndIf
   Next

   Close basespdo
   Set Color To N/BG
   Clear Screen
   my_box(6,26,17,52,B_DOUBLE+chr(32),'W+/B,GR+/R')
   @ 7,28 Say 'Корректировка КАРТОЧКИ:'
   @ 8,27 Say '─────────────────────────'
   Set Wrap On
   Set Message to 24 Center
   @ 10,27 Prompt "  Планом 1-го квартала   "
   @ 12,27 Prompt "  Планом 2-го квартала   "
   @ 14,27 Prompt "  Планом 3-го квартала   "
   @ 16,27 Prompt "    Конец работы         "
   nRet=1
   Menu To nRet
   Do Case
      case nRet=0
        m_end:=.F.
      case nRet=1
        tek_kv:='1'
        m_end:=KorrKart()
      case nRet=2
        tek_kv:='2'
        m_end:=KorrKart()
      case nRet=3
        tek_kv:='3'
        m_end:=KorrKart()
      case nRet=4
        m_end:=.F.
   EndCase
   /********для Макаровой вставить обработку sch_200*********/
   //в sch_200 открываются БД заново, поэтому до вызова процедуры надо закрыть все открытые БД
   If m_end  //выбрали обработку, а не конец работы
      Close All
      sch_200(path_base)

      my_box(11,18,15,60,B_DOUBLE+chr(32),"GR+/B")
      @ 12,19 Say'    Обновление данных успешно завершено '
      @ 13,19 Say'          Нажмите любую клавишу ...     '
      InKey(0)
   EndIf
EndDo
/*******************************************************/
SetColor(OldColor)
SetBlink(old_b)
Close All
Clear All
alert("После корректировок необходимо запустить добавку!!!")
Clear Screen
@ maxrow()-2,2 Say'    Сервис ОАСУП ОАО "НПО"НЭВЗ".  '
Set Cursor On

************************************************************
Static Func KorrKart()
 /*ПРОВЕРКА НА ИЗМЕНЕНИЕ PL03 и необходимость переформирования Карточек*/
 //Считываем служебную инф-цию из blanks (сервер ПДО)
 blanks_Si:=GetSi(n_blan+".dbf")
 num_kv:=tek_kv

 //blanks можно корректировать только прошлым кварталом текущего года
 If  Substr(blanks_si,7,1)<=num_kv       //кв. blanks сравниваем с корректируемым кварталом
     my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
     @ 12,19 Say'       План  '+num_kv+'-го квартала'
     @ 13,19 Say'        за прошлый год         '
     @ 14,19 Say'    Нажмите любую клавишу ...  '
     InKey(0)
     Restore Screen
     Clear All
     Close All
     Quit
 EndIf

 //Считываем служебную инф-цию из pl03ps
 //определяем путь к pl03pskx по pl03ps basespdo->arch
 n_pl03ps:=SubStr(n_pl03ps,1,At('*',n_pl03ps)-1)+"2"+PadL(SubStr(blanks_si,9,2),3,'0')+SubStr(n_pl03ps,At('*',n_pl03ps)+1,Len(n_pl03ps)-At('*',n_pl03ps))+"pl03psk"+num_kv
 pl03ps_Si:=GetSi(n_pl03ps+".dbf")

 n_pl03iz:=SubStr(n_pl03iz,1,At('*',n_pl03iz)-1)+"2"+PadL(SubStr(blanks_si,9,2),3,'0')+SubStr(n_pl03iz,At('*',n_pl03iz)+1,Len(n_pl03iz)-At('*',n_pl03iz))+"pl03izk"+num_kv
 pl03iz_Si:=GetSi(n_pl03iz+".dbf")
 //
 If Substr(pl03ps_Si,30,2) # Substr(blanks_si,9,2) //разные года такого быть не должно, но на всякий случай оставим
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say'        План  '+"PL03PSK"+num_kv
    @ 13,19 Say'        за прошлый год         '
    @ 14,19 Say'    Нажмите любую клавишу ...  '
    InKey(0)
    Restore Screen
    Clear All
    Close All
    Quit
 End
 //
 If !New_Data(1)
    Restore Screen
    Clear Screen
    Close All
    Return .F.
 EndIf
 f_rasp_plan:=1    //формировать распоряжения от плана
 FormBlank()       &&формирование БД blanks (iz,tm) (карты учета)

//записываем в blanks и bd02ph новую служебную инф-цию
//Макарова. 27.09.12 Меняем № пок. плана текущего квартала на -1, 
// чтоб потом прошла корректировка при обновлении
 blanks_Si:=Stuff(blanks_Si,15,3,Ntoc(Val(Substr(blanks_Si,15,3))-1,10,3,'0'))
 PutSi(n_blan+".dbf",blanks_Si)

 my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
 @ 13,22 Say "  Проставляется К1 для распоряжений "
 RKol()

 Close All

 If MYNetUse(n_blan,.T.,5)
    //Обязательная индексация Blanks.dbf - создание chertks.ntx. Т.к. вносят комментарии и дата blanks.dbf изменяется
    Select blanks
    Index On chert To (SubStr(n_blan,1,Rat('\',n_blan))+'chertks.ntx')
    Set Index To
    blanks->(dbgoto(1))
 Else
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say'   Файл BLANKS.dbf не доступен '
    @ 13,19 Say'   Невозможно обновить данные. '
    @ 14,19 Say'    Нажмите любую клавишу ...  '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return .F.
 EndIf
Return .T.

/*При обновлении данных выдает сообщение и
ждет возможности заблокировать все БД
Возвращает .T. если все БД заблокированы удачно, иначе .F.*/

Procedure New_Data(variant)
//кол-во на квартал по ключу: cex+chert+ps+vp+cp,
//perevod==1, если cex+chert переводятся в cex+chertn по справочнику bd02ph
//new_pos - вновь введенная позиция, отмечаем если в новом плане появился
//  чертеж, к-го не было в прошлом плане или по этому чертежу изменился ТМ
//  (ЦС - ЦП)
//dobav - помечает добавки к плану тек.квартала

Local aBlan:={{'CEX','C',2,0},{'CHERT','C',13,0},{'PS','C',1,0},;
              {'VP','C',1,0},{'CP','C',2,0},{'Num','C',7,0},{'KV1','N',9,0},;
              {'KV2','N',9,0},{'KV3','N',9,0},{'KV4','N',9,0},;
              {'PEREVOD','N',1,0},{'NEW_POS','N',1,0},{'DOBAV','N',1,0},;
              {'UDAL_DATE','C',4,0},{'TERM','C',1,0},{'Dopolnen','M',0,0},{'SIA','C',0,0},{'SIB','C',0,0}}
Local aBlanph:={{'CEX','C',2,0},{'CHERT','C',13,0},{'PS','C',1,0},;
              {'VP','C',1,0},{'CP','C',2,0},{'Num','C',7,0},{'KV1','N',9,0},;
              {'KV2','N',9,0},{'KV3','N',9,0},{'KV4','N',9,0},;
              {'PEREVOD','N',1,0},{'NEW_POS','N',1,0},{'DOBAV','N',1,0},;
              {'UDAL_DATE','C',4,0},{'TERM','C',1,0},{'Dopolnen','M',0,0},;
              {'SIA','C',0,0},{'SIB','C',0,0}}

//кол-во на изделие на первый(2,3,4) квартал
Local aBlaniz:={{'Num','C',7,0},{'KI','C',4,0},{'Name_iz','C',8,0},;
                {'Kol1','N',9,0},{'Kol2','N',9,0},{'Kol3','N',9,0},;
                {'Kol4','N',9,0}}
Local aBlantm:={{'Num','C',7,0},{'TM','C',24,0}}
//кол-во на план по изделию по месяцам квартала KolMXY, где X- номер квартала, Y-номер месяца в квартале
Local aBlanm:={{'Num','C',7,0},{'KI','C',4,0},;
                {'KolM11','N',9,0},{'KolM12','N',9,0},{'KolM13','N',9,0},;
                {'KolM21','N',9,0},{'KolM22','N',9,0},{'KolM23','N',9,0},;
                {'KolM31','N',9,0},{'KolM32','N',9,0},{'KolM33','N',9,0},;
                {'KolM41','N',9,0},{'KolM42','N',9,0},{'KolM43','N',9,0}}

//карта для складов сбыта
Local askl:={{'KI','C',4,0},{'CEX','C',2,0},{'CHERT','C',13,0},{'PS','C',1,0},;
              {'VP','C',1,0},{'CP','C',2,0},{'Num','C',7,0},{'Kol1','N',9,0},;
              {'Kol2','N',9,0},{'Kol3','N',9,0},{'Kol4','N',9,0},{'Name_iz','C',8,0},;
              {'PEREVOD','N',1,0},{'NEW_POS','N',1,0},{'UDAL_DATE','C',4,0},;
              {'SIA','C',0,0}}

Static entre:=0
 If entre==0
    Set Color To N/BG
    Clear Screen
    entre++
    my_box(5,7,20,72,B_DOUBLE+chr(32),"W+/W")
    @ 5,28 Say "  Идет обновление данных за "+num_kv+" квартал..."
 EndIf
 Do case
  case variant==1
   FileCopy((n_PL03PS+".dbf"),(kar_path+"temp\PL03PS.dbf")) //сохраняем пред.значения
   nErr:=ErrorCode(.T.)
   If nErr!=0
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Ошибка копирования файла   '
      @ 14,19 Say' Нажмите любую клавишу ...  '
      Inkey(0)
      Return .F.
   EndIf
   If AlNetUse(kar_path+"temp\PL03PS.dbf",.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл PL03PSK'+num_kv+'.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf

   FileCopy((n_PL03iz+".dbf"),(kar_path+"temp\PL03IZ.dbf")) //сохраняем пред.значения
   nErr:=ErrorCode(.T.)
   If nErr!=0
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Ошибка копирования файла   '
      @ 14,19 Say' Нажмите любую клавишу ...  '
      Inkey(0)
      Return .F.
   EndIf
   If AlNetUse(kar_path+"temp\PL03IZ.dbf",.T.,5)
      Index On KI To (kar_path+"temp\PL03IZ.ntx")
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл PL03IZK'+num_kv+'i.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
/*Создаем структуру БД blanks, к-рая содержит ключ и связана с БД blanksiz*/
/* по полю Num; blanksiz содержит код изд.,наим., кол-во на план по чертежу*/
/*и по кол-во по изд. по кварталам*/
   If AlNetUse(n_blan,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл BLANKS.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   FileCopy((n_blaniz+".dbf"),(kar_path+"temp\old_bliz.dbf")) //сохраняем пред.значения
   //кол-ва на изд. для того чтобы правильно определить добавки
   //и записать кол-ва по КИ введенным и снятым в одном и том же квартале
   nErr:=ErrorCode(.T.)
   If nErr!=0
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Ошибка копирования файла   '
      @ 14,19 Say' Нажмите любую клавишу ...  '
      Inkey(0)
      Return .F.
   EndIf
   If AlNetUse(kar_path+"temp\old_bliz.dbf",.T.,5)
      my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
      Set Color To W+*/B
      @ 13,22 Say "Идет индексация базы данных BLANKSIZ"
      Index On Num+KI To (kar_path+"temp\old_bliz.ntx")
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл OLD_BLIZ.dbf не доступен'
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If AlNetUse(n_blaniz,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл BLANKSIZ.dbf не доступен'
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf

   FileCopy((n_blanm+".dbf"),(kar_path+"temp\old_blm.dbf")) //сохраняем пред.значения
   //кол-ва на изд. для того чтобы правильно определить добавки
   //и записать кол-ва по КИ введенным и снятым в одном и том же квартале
   nErr:=ErrorCode(.T.)
   If nErr!=0
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Ошибка копирования файла   '
      @ 14,19 Say' Нажмите любую клавишу ...  '
      Inkey(0)
      Return .F.
   EndIf
   If AlNetUse(kar_path+"temp\old_blm.dbf",.T.,5)
      my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
      Set Color To W+*/B
      @ 13,22 Say "Идет индексация базы данных BLANKSM "
      Index On Num+KI To (kar_path+"temp\old_blm.ntx")
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл OLD_BLM.dbf не доступен'
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If AlNetUse(n_blanm,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл BLANKSM.dbf не доступен'
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf

   If !File(n_blantm+".dbf")
      DBCreate(n_blantm,aBlantm)
   EndIf
   If AlNetUse(n_blantm,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл BLANKSTM.dbf не доступен '
      @ 14,19 Say'    Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
//Masha
   If !FileMN(n_bdkitm+".dbf",10)
      DBCreate(n_bdkitm,aBdkitm)
   EndIf
   If MyNetUse(n_bdkitm,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл BDKITM.dbf не доступен '
      @ 14,19 Say'    Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
//Masha

/*Создаем БД blanph,blanphiz,blanphtm содержащие данные по
преобразованным чертежам*/
   /*If AlNetUse(n_blanph,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл BLANPH.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If !File(n_blphiz+".dbf")
      DBCreate(n_blphiz,aBlaniz)
   EndIf
   If AlNetUse(n_blphiz,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл BLANPHIZ.dbf не доступен'
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If AlNetUse(n_bd02ph,.T.,5)
      Create_index("bd02ph","cex+chertn",n_bd02ph)
      Set Color To W+/W
      @ 12,9 Clear To 18,60
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл BD02PH.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf*/

   If !File(n_blan_s+".dbf")
      DBCreate(n_blan_s,aBlan)
   EndIf
   If AlNetUse(n_blan_s,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл BLAN_S.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If !File(n_blaniz_s+".dbf")
      DBCreate(n_blaniz_s,aBlaniz)
   EndIf
   If AlNetUse(n_blaniz_s,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл BLANIZ_S.dbf не доступен'
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If !File(n_blanm_s+".dbf")
      DBCreate(n_blanm_s,aBlanm)
   EndIf
   If AlNetUse(n_blanm_s,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл BLANM_S.dbf не доступен'
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf

  case variant==2 /*для формирования преобразованных чертежей*/
   If AlNetUse(n_bd02ph,.T.,5)
      Create_index("bd02ph","cex+chertn",n_bd02ph)
      Set Color To W+/W
      @ 12,9 Clear To 18,60
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл BD02PH.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If AlNetUse(n_blan,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл BLANKS.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If AlNetUse(n_blaniz,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл BLANKSIZ.dbf не доступен'
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If AlNetUse(n_blantm,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл BLANKSTM.dbf не доступен'
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
/*Создаем БД blanph,blanphiz,blanphtm содержащие данные
по преобразованным чертежам(чертежи плана преобразуются в чертежи накладных)*/
   If !File(n_blanph+".dbf")
      DBCreate(n_blanph,aBlanph)
   EndIf
   If AlNetUse(n_blanph,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл BLANPH.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If !File(n_blphiz+".dbf")
      DBCreate(n_blphiz,aBlaniz)
   EndIf
   If AlNetUse(n_blphiz,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл BLANPHIZ.dbf не доступен'
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If !File(n_blphtm+".dbf")
      DBCreate(n_blphtm,aBlantm)
   EndIf
   If AlNetUse(n_blphtm,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл BLANPHTM.dbf не доступен'
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
  case variant==3
   If AlNetUse(n_raspor,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл RASPOR.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If AlNetUse(n_prior,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл PRIOR.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   For i:=1 To Len(aPDO)
      If aPDO[i,1]=="bd02ki"
         Exit
      EndIf
   Next
   If AlNetUse(aPDO[i,2]+aPDO[i,1],.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл BD02KI.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If AlNetUse(n_blan,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл BLANKS.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If AlNetUse(n_blaniz,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл BLANKSIZ.dbf не доступен'
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If AlNetUse(n_blanph,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл BLANPH.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If AlNetUse(n_blphiz,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл BLANPHIZ.dbf не доступен'
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
 EndCase
Return .T.
