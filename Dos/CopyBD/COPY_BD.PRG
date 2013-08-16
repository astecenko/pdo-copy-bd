                /*Разработчик - Дьяченко Ольга Викторовна*/
                              /*2000 г.*/
           /*Программа сброса БД-х для ПДО с сервера ОАСУП*/
                          /*Сетевой вариант*/
#include "box.ch"
#include "inkey.ch"
#include "achoice.ch"
#include "directry.ch"

Proc copy_bd(path_bas)
Local vr,iPathSm50
clear
if alert("Обновление данных",{"Нет","Да"},"w+/rb")#2
  return
endif

Set Procedure To f_kart
Set Procedure To f_rasp //из f_rasp используется только формирование mp31   28.11.06
Set Procedure To masha


/*Массив aASU содержит:
1-имя БД, перебрасываемой с сервера ОАСУП на сервер ПДО
2-путь к БД на сервере ОАСУП (берется из H:\bases.dbf))
3-номер поколения БД на сервере ОАСУП (GetSi())
4 - дата набора
5 - служебная информация (без 3-х байт длины служебной информации)*/

/*Номер поколения данных изменяется от 000 до 999, а потом снова
сбрасывается в 000.*/
//SM50 должна стоять до BD02NC, т.к.используется при формировании.
//NS02OC и BD02NZN должны стоять до BD02NC, т.к.после того как накладные скопированы
//мы формируем SKL_NAKL и используем индексы NS02OC и BD02NZN
//Макарова PL01 д.стоять до PL01Kx т.к.они копируются только если год совпадает
/*aASU:={{'ns02oc','','','',''},{'bd02nzn','','','',''},{'bd02nc','','','',''},;
       {'bd02ki','','','',''},/*{'bd02ph','','','',''}Макарова,{'ns02nch','','','',''},;
       {'ns02ki','','','',''},{'ns02cm','','','',''},{'ns03','','','',''},;
       {'pl01','','','',''},{'ns01ks','','','',''},{'pl03iz','','','',''},;
       {'pl03ps','','','',''},{'bd04rs','','','',''},{'mp31','','','',''},;
       {'pl02izs','','','',''},{'pl02pss','','','',''},;
       {'pl01k1','','','',''},{'pl01k2','','','',''},{'pl01k3','','','',''},;
       {'pl03k1','','','',''},{'pl03k1i','','','',''},;
       {'pl03k2','','','',''},{'pl03k2i','','','',''},;
       {'pl03k3','','','',''},{'pl03k3i','','','',''},;
       {'pl03k4','','','',''},{'pl03k4i','','','',''},;
       {'ns05tn','','','',''}}*/
aASU:={{'sm50','','','',''},{'ns02oc','','','',''},{'bd02nzn','','','',''},{'bd02nc','','','',''},;
       {'bd02ki','','','',''},{'ns02cm','','','',''},;
       {'bd02ki04','','','',''},{'bd02ki98','','','',''},;
       {'pl03iz','','','',''},{'pl03ps','','','',''},{'bd04rs','','','',''},{'mp31','','','',''},;
       {'ns05tn','','','',''},{'pl05iz','','','',''},{'pl05ps','','','',''}}

/*Массив aPDO содержит:
1-имя БД, перебрасываемой с сервера ОАСУП на сервер ПДО
2-путь к БД на сервере ПДО (берется из H:\basespdo.dbf)
3-номер поколения БД на сервере ПДО (GetSi())
4 - дата набора
5 - служебная информация (без 3-х байт длины служебной информации)*/
/*aPDO:={{'ns02oc','','','',''},{'bd02vc','','','',''},{'bd02nc','','','',''},;
       {'bd02ki','','','',''}/*,{'bd02ph','','','',''}Макарова,{'ns02nch','','','',''},;
       {'ns02ki','','','',''},{'ns02cm','','','',''},{'ns03','','','',''},;
       {'pl01','','','',''},{'ns01ks','','','',''},{'pl03iz','','','',''},;
       {'pl03ps','','','',''},{'bd04rs','','','',''},{'mp31','','','',''},;
       {'pl02izs','','','',''},{'pl02pss','','','',''},;
       {'pl01k1','','','',''},{'pl01k2','','','',''},{'pl01k3','','','',''},;
       {'pl03k1','','','',''},{'pl03k1i','','','',''},;
       {'pl03k2','','','',''},{'pl03k2i','','','',''},;
       {'pl03k3','','','',''},{'pl03k3i','','','',''},;
       {'pl03k4','','','',''},{'pl03k4i','','','',''},;
       {'ns05tn','','','',''}}*/
aPDO:={{'sm50','','','',''},{'ns02oc','','','',''},{'bd02vc','','','',''},{'bd02nc','','','',''},;
       {'bd02ki','','','',''},{'ns02cm','','','',''},;
       {'bd02ki04','','','',''},{'bd02ki98','','','',''},;
       {'pl03iz','','','',''},{'pl03ps','','','',''},{'bd04rs','','','',''},{'mp31','','','',''},;
       {'ns05tn','','','',''},{'pl05iz','','','',''},{'pl05ps','','','',''}}


/*Дополнит. массив, к-рый содержит:
1-имя БД, которая может принимать участие в переформировании БД на сервере ПДО
2-имя переменной, в к-рой будет содержаться путь+имя БД*/
aPDO_dopol:={{'bd12tc','n_bd12tc'},{'bd02ki_','n_bd02ki_'},{'bd12rs','n_bd12rs'},;
     {'blanks','n_blan'},{'blanksiz','n_blaniz'},{'blankstm','n_blantm'},{'blanksm','n_blanm'},;
     {'blanph','n_blanph'},{'blanphiz','n_blphiz'},{'blanphtm','n_blphtm'},{'blanphm','n_blphm'},;
     {'blan_s','n_blan_s'},{'blaniz_s','n_blaniz_s'},{'blanm_s','n_blanm_s'},;
     {'pl03ps','n_pl03ps'},{'pl03iz','n_pl03iz'},{'bd02ph','n_bd02ph'},;
     {'spr_rasp','n_spr_rasp'},;
     {'sklad','n_sklad'},{'sklad_s','n_sklad_s'},{'skl_nakl','n_skl_nakl'},;
     {'mp31','n_mp31'},{'grf_cex','n_grfcex'},/*Masha*/{'grf','n_grf'},;//для переформирования spr_rasp
     {'bdki561','n_bdki561'},{'bdki562','n_bdki562'},;
     {'blank561','n_blk561'},{'blank562','n_blk562'},;
     {'blanp561','n_blp561'},{'blanp562','n_blp562'},;
     {'bdkitm','n_bdkitm'},{'bd200','n_bd200'},{'bdrasp','n_bdrasp'},{'sbt','n_sbt'},{'bd02nc1','n_bd02nc1'},{'pl01sb','n_pl01sb'},;
     {'nstda','n_nstda'},{'nstd','n_nstd'},{'pl05ps','n_pl05ps'},{'pl05iz','n_pl05iz'},{'bd04rs','n_bd04rs'}}
//     {'raspor','n_raspor'},{'prior','n_prior'}, 28.11.06
//предпоследние 6 БД-х переформировываются от ценника при каждом обновлении данных
//это временные БД - разбиение 56 цеха по участкам
//blan_s, blaniz_s - БД содержат позиции введенные и снятые в одном квартале
//sklad,skl_nakl - карта и накладные для учета распоряжений по складам сбыта;
//sklad переформировываем при изменении blanks
//sklad_s - позиции снятые с плана (удаленные из sklad)
//skl_nakl - переформировываем при каждом сбросе bd02nc

Private cSi:="",blanks_Si:="",blanph_Si:="",pl03ps_Si:="",pl05ps_Si:="",bd02ph_Si:="",;
        bd02ki_Si:="",sklad_Si:="",skl_nakl:="",pl01_God:="",;
        f_notadd:=0,f_notcopy:=0,f_new:=0,f_arh_create:=.F.,num_kv:="",num_kv_pl05:="",;
        f_rasp_plan:=0,arh_path:="",kar_path:="",f_pl03_copy:=.F.,;
        /*Masha*/put_ki56:="",put_bl56:="",kv_pl05_asu:="",kv_pl03_asu:=""
        //Masha - путь к bdki561 и к blank561
        //путь к архиву, путь к каталогу KARTA
        //f_rasp_plan=0, если не переформировывать БД распоряжений от плана
   //чтобы выделять из плана (добавки) вводим флаг f_new
   //f_new==0, если в blanks формируется новый квартал
   //f_new==1, если пересоздается тот же квартал, т.е если пересоздаются
              //карточки в результате добавки к плану в том же квартале
   //num_kv - номер квартала из pl03ps(ПДО),полученного после обновления
   //f_pl03_copy=.t., если pl03ps был скопирован на сервер ПДО (ситуация, когда в си pl03 стоит планирование)
   /*f_arh_create - если была архивация за год, то флаг принимает значение True и передается функции Podchet()*/
   /*f_notadd - флаг вводим для того, чтобы не накапливать в новом году данные
     за декабрь прошлого года. Если был создан архив, то f_notadd:=1*/
   /*f_notcopy - флаг вводим для следующей ситуации: если bd02ki еще за
     прошлый год, а pl03ps уже за новый год, то f_notcopy:=1. В этом случае
     pl03ps, pl03iz и bd02ph и pl05ps,pl05iz не копируются с сервера АСУ до тех пор пока
     не будет создан архив за прошлый год.*/

/*массив структуры BD12TC - накопление накладных на сдачу за год*/
aBd12tc:={{'CEX','C',2,0},{'CHERT','C',13,0},{'PS','C',1,0},;
          {'VP','C',1,0},{'CP','C',2,0},{'POC','C',1,0},;
          {'DD_NAKL','C',2,0},{'MM_NAKL','C',2,0},{'DD_VV','C',2,0},;
          {'MES','C',2,0},{'GOD','C',2,0},;
          {'NP','N',3,0},{'NNAKL','C',4,0},{'KI','C',4,0},;
          {'PR','C',1,0},{'KOL','N',8,0},{'SP','N',2,0},;
          {'NRAS','C',4,0},{'VD','C',1,0}}
/*массив структуры BD02NC - BD02nc пересоздается при принудительном завершении года*/
aBD02NC:={{'CEX','C',2,0},{'CHERT','C',13,0},{'PS','C',1,0},;
          {'VP','C',1,0},{'CP','C',2,0},{'POC','C',1,0},;
          {'DD_NAKL','C',2,0},{'MM_NAKL','C',2,0},{'DD_VV','C',2,0},;
          {'NP','N',3,0},{'NNAKL','C',4,0},{'KI','C',4,0},;
          {'PR','C',1,0},{'KOL','N',8,0},{'SP','N',2,0},;
          {'NRAS','C',4,0},{'VD','C',1,0},{'SIA','C',0,0},{'SIB','C',0,0},{'SIC','C',0,0},{'SID','C',0,0},;
          {'SIE','C',0,0},{'SIF','C',0,0},{'SIG','C',0,0},{'SIH','C',0,0},{'SII','C',0,0},{'SIJ','C',0,0},;
          {'SIK','C',0,0},{'SIL','C',0,0}}
/*массив структуры BD12RS - накопление накладных по расходу 98 цеха за год.
 Поле Data - дата документа.В старой структуре MES,GOD-берем из сл.инф-ции bd04rs,CHMES- было поле.
в DATA сейчас ставят дату ввода этой накладной (дату обработки из SI bd04rs)
Сортировка: SKLAD+CHERT+ps+vp+cp+DATA+VR+NDOK+ki+nmash */
aBd12rs:={{'SKLAD','C',2,0},{'CP','C',2,0},{'CHERT','C',13,0},{'PS','C',1,0},{'VP','C',1,0},{'VR','C',1,0},;
          {'NDOK','C',4,0},{'NPB','N',3,0},{'NP','N',3,0},{'KI','C',4,0},;
          {'DATA','D',4,0},{'KOL','N',8,0},{'NMASH','C',4,0}}
/*массив структуры SKL_NAKL - накопление накладных на сдачу за год по цехам
получателям=складам сбыта по распоряжениям*/
aSkl_nakl:={{'CEX','C',2,0},{'CHERT','C',13,0},{'PS','C',1,0},;
          {'VP','C',1,0},{'CP','C',2,0},;
          {'CHMES','C',2,0},{'MES','C',2,0},{'GOD','C',2,0},;
          {'NP','N',3,0},{'NNAKL','C',4,0},{'KI','C',4,0},{'KI_NAKL','C',4,0},;
          {'PR','C',1,0},{'KOL','N',8,0},;
          {'CENA','N',12,2},{'EI','C',2,0},;
          {'NRAS','C',4,0},{'VD','C',1,0},{'DOPOLNEN','M',0,0},{'SIA','C',0,0}}

/*массив структуры RASPOR - БД, содержащая укомплектованность по распоряжениям*/
/*aRaspor:={{'CEX','C',2,0},{'CHERT','C',13,0},{'PS','C',1,0},;
          {'VP','C',1,0},{'CP','C',2,0},{'KI','C',4,0},;
          {'K1','N',8,0},{'KTEK','N',8,0},{'PR','C',1,0},;
          {'KORT','N',8,0},{'KOD_GR','C',4,0}} */
//массив структуры PRIOR - БД, содер. приоритеты, по к-рым распределяется
//сдача за сутки с 200 КИ на входящие в него распоряжения
//aPrior:={{'CEX','C',2,0},{'KI','C',4,0},{'PRIOR','C',1,0}}

//МАССИВ СТРУКТУРЫ mp31 -БД, содержащая последние изменения по ШМ по ЦЕХУ и ЧЕРТЕЖУ
//Ведется в течение года, затем сбрасывается в архив. В СИ пишем к/гг.
aMP31:={{'CEX','C',2,0},{'SHM','C',8,0},{'CHERT','C',13,0},{'EI','C',2,0},;
        {'NORMA','N',7,3},{'SIA','C',0,0},{'SIB','C',0,0}}

/*массив структуры БД - Справочник распоряжений*/
db_spr:={{'KOD','C',4,0},{'TEXT','C',60,0}}

//Masha
//структура bdkitm - ТМ по ключу bd02ki
aBdkitm:={{'CEX','C',2,0},{'CHERT','C',13,0},{'PS','C',1,0},;
          {'VP','C',1,0},{'CP','C',2,0},{'KI','C',4,0},{'TM','C',24,0}}

//Masha
//структуры bdki561 и bdki562
aBdki56:={{'CEX', 'C',2,0},{'CHERT','C',13,0},{'PS',   'C',1,0},;
          {'VP',  'C',1,0},{'CP',   'C', 2,0},{'KI',   'C',4,0},{'PG','C',1,0},;
          {'UCH', 'N',2,0},{'BR',   'C',24,0},;
          {'BU',  'C',2,0},{'OP',   'N', 3,0},{'K1',   'N',8,0},;
          {'N2',  'N',8,0},{'K2',   'N', 8,0},{'KSUT', 'N',8,0},;
          {'NB',  'N',8,0},{'KB',   'N', 8,0},{'NTEK', 'N',8,0},;
          {'KTEK','N',8,0},{'NNMES','N', 8,0},{'KNMES','N',8,0},;
          {'VK',  'C',4,0},{'KORT', 'N', 8,0},{'KORM', 'N',8,0},;
          {'RASG','N',8,0},{'NIZ',  'N', 8,0},{'BS',   'C',2,0},;
          {'SIA', 'C',0,0},{'SIB',  'C', 0,0},{'SIC',  'C',0,0},;
          {'SID', 'C',0,0},{'SIE',  'C', 0,0},{'SIF',  'C',0,0},;
          {'SIG', 'C',0,0},{'SIH',  'C', 0,0},{'SII',  'C',0,0},;
          {'SIJ', 'C',0,0},{'SIK',  'C', 0,0},{'SIL',  'C',0,0}}

//Masha
//структура ns05tn на сервере ПДО !!!!!!!!!!!! (не такая как на сервере АСУ)
//18.11.09 Макарова добавляю поле оборудования,
//             алгоритм добавления записи в базу не меняю
aNS05TN:={{'CEX','C',2,0},{'CHERT','C',13,0},;
          {'PS', 'C',1,0},{'BR',   'C',24,0}, {'OBOR', 'C',3,0},;
          {'SIA', 'C',0,0},{'SIB',  'C', 0,0},{'SIC',  'C',0,0},;
          {'SID', 'C',0,0},{'SIE',  'C', 0,0},{'SIF',  'C',0,0},;
          {'SIG', 'C',0,0},{'SIH',  'C', 0,0},{'SII',  'C',0,0},;
          {'SIJ', 'C',0,0},{'SIK',  'C', 0,0},{'SIL',  'C',0,0}}
//структура файла СБЫТ sbd.dbf
aSBT:={{"CEX","C",2,0},{"CHERT","C",13,0},{"PS","C",1,0},{"VP","C",1,0},{"CP","C",2,0},{"KI","C",4,0},;
       {"KTEK","N",9,0},{"KSUT","N",9,0},{"SIA","C",0,0},{"SIB","C",0,0},{"SIC","C",0,0}}
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
/*Макарова ***Резервное копирование*/
 If !CopBdki()
    //Restore Screen
    setcolor("w/n")
    Clear Screen
    Close All
    Return
 EndIf
Set Date To German
*************************************
/*Меню*/

m_end:=.T.
Do While m_end
   /*Читаем данные из H:\basespdo.dbf (сервер ПДО)*/
    if !File(vr:=path_base+"BASESPDO.dbf") .or. !File(vr:=path_base+"BASESPDO.ntx")
      alert("Нет файла "+vr)
      Restore Screen
      Clear All
      Close All
      Quit
    endif
    If !MYNetUse(path_base+"basespdo.dbf",.F.,5,.T.)
        my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
        @ 12,19 Say'     Файл BASESPDO.DBF         '
        @ 13,19 Say'          не доступен.         '
        @ 14,19 Say'    Нажмите любую клавишу ...  '
        InKey(0)
        Restore Screen
        Clear All
        Close All
        Quit
    EndIf
    Set Index To (path_base+"basespdo.ntx")

   If (basespdo->(dbSeek("blanks.dbf")))
      kar_path:=AllTrim(basespdo->path) //это рабочий каталог карт учета

      If !DirChangeMN(left(kar_path,len(kar_path)-1),10) /*Макарова*/// .and. !fileMN(kar_path+"*.*",10)
         my_box(13,18,17,57,B_DOUBLE+chr(32),"W+/R")
         @ 14,19 Say'          ВНИМАНИЕ !!!          '
         @ 15,19 Say' Каталог '+kar_path+' не найден'
         @ 16,19 Say'   Нажмите любую клавишу ...    '
         InKey(0)
         Restore Screen
         Clear All
         Close All
         Quit
      EndIf
      If !DirChangeMN(kar_path+"temp",10)
        //создаем директорию (temp) для
        If DirMake(kar_path+"temp")!=0
          my_box(13,18,17,51,B_DOUBLE+chr(32),"W+/R")
          @ 14,19 Say'    Ошибка создания каталога   '
          @ 15,31 Say Upper(kar_path+"temp\")
          @ 16,19 Say'   Нажмите любую клавишу ...   '
          InKey(0)
          Restore Screen
          Clear Screen
          Close All
          Quit
        EndIf
      EndIf
   EndIf

   For i:=1 To Len(aPDO)
     If (basespdo->(dbSeek(aPDO[i,1]+".dbf")))
        aPDO[i,2]:=AllTrim(basespdo->path)
        cSi:="" 
        If FileMN(aPDO[i,2]+aPDO[i,1]+".dbf",10) //если такой файл найден то GetSi()
           cSi:=GetSi(aPDO[i,2]+aPDO[i,1]+".dbf")
           lSi:=0
           If .Not.Empty(cSi)
              If aPDO[i,1]=="pl03ps".or.aPDO[i,1]=="pl03iz".or.;
                 aPDO[i,1]=="pl02izs".or.aPDO[i,1]=="pl02pss".OR.;
                 aPDO[i,1]=="pl01k1".OR.aPDO[i,1]=="pl01k2".OR.;//Макарова
                 aPDO[i,1]=="pl01k3".OR.;
                 aPDO[i,1]=="pl03k1".OR.aPDO[i,1]=="pl03k1i".OR.;//Masha
                 aPDO[i,1]=="pl03k2".OR.aPDO[i,1]=="pl03k2i".OR.;
                 aPDO[i,1]=="pl03k3".OR.aPDO[i,1]=="pl03k3i".OR.;//Masha
                 aPDO[i,1]=="pl03k4".OR.aPDO[i,1]=="pl03k4i".Or.;
                 aPDO[i,1]=="pl05ps".OR.aPDO[i,1]=="pl05iz"
                 //взять номер поколения
                 aPDO[i,3]:=SubStr(cSi,15,3)
                 lSi:=Val(SubStr(cSi,18,3)) //если есть служ.инф-ция
                 If lSi!=0                  //то заносим в массив
                    aPDO[i,5]:=SubStr(cSi,21,lSi)
                 EndIf
                 //дата плана в формате квартал/год(2 цифры)
                 If aPDO[i,1]=="pl01k1".OR.aPDO[i,1]=="pl01k2".OR.;//Макарова
                    aPDO[i,1]=="pl01k3"
                    iif(lSi # 0,aPDO[i,4]:=SubStr(cSi,21,4),)
                 Else
                    aPDO[i,4]:=SubStr(cSi,28,4)
                 EndIf
              Else
                 aPDO[i,3]:=Substr(cSi,15,3)
                 aPDO[i,4]:=Substr(cSi,7,8)
                 lSi:=Val(SubStr(cSi,18,3)) //если есть служ.инф-ция
                 If lSi!=0                  //то заносим в массив
                    aPDO[i,5]:=SubStr(cSi,21,lSi)
                 EndIf
              EndIf
           EndIf
        Else
           aPDO[i,3]:=cSi
           aPDO[i,4]:=cSi
           aPDO[i,5]:=cSi
        EndIf
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
   Next
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
//Макарова чистка korved.dbf и удаление korved.ntx
   If (basespdo->(dbSeek("korved.dbf")))
      Use (AllTrim(basespdo->path)+"korved.dbf") New
      Zap
      Use
   EndIf
   If (basespdo->(dbSeek("korved.ntx")))
      Delete File (AllTrim(basespdo->path)+"korved.ntx")
   EndIf
   Close basespdo

   Set Color To N/BG
   Clear Screen
   my_box(6,26,16,52,B_DOUBLE+chr(32),'W+/B,GR+/R')
   @ 7,35 Say 'ВАШ выбор:'
   @ 8,27 Say '─────────────────────────'
   Set Wrap On
   Set Message to 24 Center
   @ 10,27 Prompt "    ОБНОВЛЕНИЕ данных    "
   @ 12,27 Prompt "    УДАЛЕНИЕ архива      "
   @ 14,27 Prompt "      Конец работы       "
   nRet=1
   Menu To nRet
   Do Case
      case nRet=0
        m_end:=.F.
      case nRet=1
        Copy_new_db()
        m_end:=.T.
      case nRet=2
        Delete_arh()
        m_end:=.T.
      case nRet=3
        m_end:=.F.
   EndCase
EndDo
SetColor(OldColor)
SetBlink(old_b)
Close All
Clear All
Clear Screen
//Restore Screen
@ maxrow()-2,2 Say'    Сервис ОАСУП ОАО "НПО"НЭВЗ".  '
//@ maxrow()-1,2 Say'    Разработчик - Дьяченко О.В. '
Set Cursor On


/*Процедуры завершения года (СОЗДАНИЕ АРХИВА)*/
Procedure Create_arh()
Local dir,cget_pic,arh_path,si_mp31

 my_box(5,7,20,72,B_DOUBLE+chr(32),"W+/W")
 @ 5,31 Say' Создание архива '
 Set Color to N/W,N/G
//формируем путь для нового каталога
 arh_path:=kar_path+'arhiv\'+arh_year+'\'
 //arh_path:='e:\arhiv\'+arh_year+'\' /*Макарова*/
//проверяем, а не был ли раннее создан этот архив
//если найден создаваемый каталог, то выход
 If DirChangeMN(SubStr(arh_path,1,Len(arh_path)-1),10)
    my_box(13,18,17,57,B_DOUBLE+chr(32),"W+/R")
    @ 14,19 Say' Каталог '+Upper(arh_path)+' уже существует'
    @ 15,19 Say'     Возможно архив уже был создан   '
    @ 16,19 Say'        Нажмите любую клавишу ...    '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return .F.
 Else
    //создаем директорию (arh_year) для архива
    If DirMake(SubStr(arh_path,1,Len(arh_path)-1))!=0
       my_box(13,18,17,51,B_DOUBLE+chr(32),"W+/R")
       @ 14,19 Say'    Ошибка создания каталога   '
       @ 15,31 Say Upper(arh_path)
       @ 16,19 Say'   Нажмите любую клавишу ...   '
       InKey(0)
       Restore Screen
       Clear Screen
       Close All
       Return .F.
    EndIf
    //добавляем в basespdo.dbf новый архив arhiv____ (н-р, arhive2000) и путь
    //добавляем в C:\KARTA\basespdo.dbf (для рабочих станций пути в basespdo.dbf==G:\karta\)
    // 25.08.06 сейчас это не используется, только usesся H:\basespdo.dbf
/*    If MYNetUse(kar_path+"basespdo.dbf",.F.,5,.T.)
       Set Index To (kar_path+"basespdo.ntx")
       If .Not.(basespdo->(dbseek('arhiv'+arh_year)))
          Append Blank
       EndIf
       basespdo->name='arhiv'+arh_year
       basespdo->path=left(arh_path,len(arh_path)-5)//Макарова -'E:\arhiv\'  //возникла ошибка  путь содержит 'g:\public\karta\' : +SubStr(arh_path,2,Len(arh_path))  //maybe Len(arh_path)-1
       Index On name To (kar_path+'basespdo.ntx')
       Close basespdo
    Else
       my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
       @ 12,19 Say'Файл '+kar_path+' BASESPDO.dbf'
       @ 14,19 Say'            не доступен'
       @ 14,19 Say'    Нажмите любую клавишу ...  '
       InKey(0)
       Restore Screen
       Clear Screen
       Close All
       Return .F.
    EndIf */
    //добавляем в H:\basespdo.dbf (для сервера пути в basespdo.dbf==C:\karta\)
    If MYNetUse(path_base+"basespdo.dbf",.T.,5,.F.)
       Set Index To (path_base+"basespdo.ntx")
       If .Not.(basespdo->(dbseek('arhiv'+arh_year)))
          Append Blank
       EndIf
       basespdo->name='arhiv'+arh_year
       basespdo->path=arh_path
       Index On name To (path_base+'basespdo.ntx')
       Close basespdo
    Else
       my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
       @ 12,19 Say'      Файл BASESPDO.dbf        '
       @ 14,19 Say'            не доступен        '
       @ 14,19 Say'    Нажмите любую клавишу ...  '
       InKey(0)
       Restore Screen
       Clear Screen
       Close All
       Return .F.
    EndIf
    //накапливаем bd12tc
    If .Not. Adding()  //если не удалось заблокировать bd12tc или bd02nc
       Return .F.      //то выход в основное меню
    EndIf
    //накапливаем bd12rs
    If .Not. Adding_RS()  //если не удалось заблокировать bd12rs или bd04rs
       Return .F.      //то выход в основное меню
    EndIf
    If !FileMN(n_spr_rasp+".dbf",10)
       DbCreate(n_spr_rasp+".dbf",db_spr)
    EndIf
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/B")
    @ 12,19 Say'   Идет архивирование файла    '
    //копируем архивируемые файлы в созданный каталог
    For i:=1 To Len(aPDO_dopol)
      If aPDO_dopol[i,1]=="bd12tc".Or.aPDO_dopol[i,1]=="blanks".Or.;
         aPDO_dopol[i,1]=="blanksiz".Or.aPDO_dopol[i,1]=="blankstm".Or.aPDO_dopol[i,1]=="blanksm".Or.;
         aPDO_dopol[i,1]=="blanph".Or.aPDO_dopol[i,1]=="blanphiz".Or.aPDO_dopol[i,1]=="blanphm".Or.;
         aPDO_dopol[i,1]=="blanphtm".Or.aPDO_dopol[i,1]=="bd02ph".Or.;
         aPDO_dopol[i,1]=="bd12rs".Or.aPDO_dopol[i,1]=="sklad".Or.;
         aPDO_dopol[i,1]=="sklad_s".Or.aPDO_dopol[i,1]=="skl_nakl".Or.;
         aPDO_dopol[i,1]=="mp31".Or. aPDO_dopol[i,1]=="spr_rasp".Or.;
         aPDO_dopol[i,1]=="blan_s".Or.aPDO_dopol[i,1]=="blaniz_s".Or.aPDO_dopol[i,1]=="blanm_s".Or.;
         aPDO_dopol[i,1]=="bd200".Or.aPDO_dopol[i,1]=="sbt".Or.aPDO_dopol[i,1]=="pl01sb".Or.;
         aPDO_dopol[i,1]=="bdrasp".Or.aPDO_dopol[i,1]=="grf_cex".Or.aPDO_dopol[i,1]=="nstda"
         @ 13,19 Say'            '+Upper(aPDO_dopol[i,1])+'        '
         FileCopy((&(aPDO_dopol[i,2])+".dbf"),((arh_path)+aPDO_dopol[i,1]+".dbf"))
         nErr:=ErrorCode(.T.)
         If nErr!=0
            my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
            @ 12,19 Say'    Ошибка копирования файла   '
            @ 13,19 Say'     '+Upper(aPDO_dopol[i,1])+'.dbf - '+Str(nErr,2)
            Inkey(0)
            Return .F.
         EndIf

         If aPDO_dopol[i,1]=="blanks".Or.aPDO_dopol[i,1]=="blanph".Or.;
            aPDO_dopol[i,1]=="skl_nakl".Or.aPDO_dopol[i,1]=="sklad".Or.;
            aPDO_dopol[i,1]=="sklad_s".Or.aPDO_dopol[i,1]=="blan_s"
            FileCopy((&(aPDO_dopol[i,2])+".dbt"),((arh_path)+aPDO_dopol[i,1]+".dbt"))
            nErr:=ErrorCode(.T.)
            If nErr!=0
               my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
               @ 12,19 Say'    Ошибка копирования файла   '
               @ 13,19 Say'     '+Upper(aPDO_dopol[i,1])+'.dbt - '+Str(nErr,2)
               Inkey(0)
               Return .F.
            EndIf
         EndIf

         //копируем ВСЕ графики цехов,к-рые находим по пути grf_cex и удаляем все файлы grf_c*.dbf
         If aPDO_dopol[i,1]=="grf_cex"  //копируем ВСЕ графики цехов,к-рые находим по пути grf_cex
            path_grf_cex:=SubStr(&(aPDO_dopol[i,2]),1,Rat("\",&(aPDO_dopol[i,2])))
            aeval(directory(path_grf_cex+"grf_c*.dbf"),{ | afile | iif(afile[F_NAME]="grf_cex.DBF",,FileCopy((path_grf_cex+afile[F_NAME]),((arh_path)+afile[F_NAME]))) })
            FileDelete(path_grf_cex+"grf_c*.*")
         EndIf

      EndIf
    Next
    //чистим архивируемые файлы в C:\karta
    //Сначала пытаемся заблокировать все БД, к-рые будут чиститься
    For i:=1 To Len(aPDO_dopol)
      If aPDO_dopol[i,1]=="bd12tc".Or.aPDO_dopol[i,1]=="blanks".Or.;
         aPDO_dopol[i,1]=="blanksiz".Or.aPDO_dopol[i,1]=="blankstm".Or.aPDO_dopol[i,1]=="blanksm".Or.;
         aPDO_dopol[i,1]=="blanph".Or.aPDO_dopol[i,1]=="blanphiz".Or.aPDO_dopol[i,1]=="blanphm".Or.;
         aPDO_dopol[i,1]=="blanphtm".Or.aPDO_dopol[i,1]=="bd12rs".Or.;
         aPDO_dopol[i,1]=="sklad".Or.aPDO_dopol[i,1]=="skl_nakl".Or.;
         aPDO_dopol[i,1]=="sklad_s".Or.aPDO_dopol[i,1]=="mp31".Or.;
         aPDO_dopol[i,1]=="spr_rasp".Or.aPDO_dopol[i,1]=="bdkitm".Or.aPDO_dopol[i,1]=="bd02nc1".Or.;
         aPDO_dopol[i,1]=="blan_s".Or.aPDO_dopol[i,1]=="blaniz_s".Or.aPDO_dopol[i,1]=="blanm_s".Or.;
         aPDO_dopol[i,1]=="bd200".Or.aPDO_dopol[i,1]=="sbt".Or.aPDO_dopol[i,1]=="pl01sb".Or.;
         aPDO_dopol[i,1]=="bdrasp".Or.aPDO_dopol[i,1]=="bd04rs"
         If .Not.MYNetUse(&(aPDO_dopol[i,2]),.T.,5)
            my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
            @ 12,19 Say'    Файл '+Upper(aPDO_dopol[i,1])+' не доступен'
            @ 14,19 Say'    Нажмите любую клавишу ...  '
            InKey(0)
            Restore Screen
            Clear Screen
            Close All
            Return .F.
         EndIf
      EndIf
    Next
    //теперь чистим все заблокированные БД
    For i:=1 To Len(aPDO_dopol)
      If aPDO_dopol[i,1]=="bd12tc".Or.aPDO_dopol[i,1]=="blanks".Or.;
         aPDO_dopol[i,1]=="blanksiz".Or.aPDO_dopol[i,1]=="blankstm".Or.aPDO_dopol[i,1]=="blanksm".Or.;
         aPDO_dopol[i,1]=="blanph".Or.aPDO_dopol[i,1]=="blanphiz".Or.aPDO_dopol[i,1]=="blanphm".Or.;
         aPDO_dopol[i,1]=="blanphtm".Or.aPDO_dopol[i,1]=="bd12rs".Or.;
         aPDO_dopol[i,1]=="sklad".Or.aPDO_dopol[i,1]=="skl_nakl".Or.;
         aPDO_dopol[i,1]=="sklad_s".Or.aPDO_dopol[i,1]=="mp31".Or.;
         aPDO_dopol[i,1]=="spr_rasp".Or. aPDO_dopol[i,1]=="bdkitm".Or.aPDO_dopol[i,1]=="bd02nc1".Or.;
         aPDO_dopol[i,1]=="blan_s".Or.aPDO_dopol[i,1]=="blaniz_s".Or.aPDO_dopol[i,1]=="blanm_s".Or.;
         aPDO_dopol[i,1]=="bd200".Or.aPDO_dopol[i,1]=="sbt".Or.aPDO_dopol[i,1]=="pl01sb".Or.;
         aPDO_dopol[i,1]=="bdrasp".Or.aPDO_dopol[i,1]=="bd04rs"
         Select (aPDO_dopol[i,1])
         Zap
      EndIf
    Next
    Close All
    //в сбыт заносим СИ (служеб.инф-цию)
    PutSi(n_sbt+".dbf",'SBT   '+Dtoc(Date())+'000'+'005'+'00000')
    //в mp31 заносим СИ (служеб.инф-цию длиной 4) к/гг = 1/новый год из PL03_АСУ (в t_pl03ASU 2009)
    si_mp31:=GetSi(n_mp31+".dbf")
    PutSi(n_mp31+".dbf",Stuff(si_mp31,18,6,"0041/"+SubStr(AllTrim(Str(t_pl03ASU)),3,2)))

    //архив нестандартных обработок удаляем из тек.директории
    FileDelete(n_nstda+".dbf")

    //в bd04rs меняем СИ (служеб.инф-цию)
    si_bd04rs:=GetSi(n_bd04rs+".dbf")    
    si_bd04rs:=stuff(si_bd04rs,10,2,"01")
    si_bd04rs:=stuff(si_bd04rs,13,2,ntoc(val(right(arh_year,2))+1,10,2,"0"))
    si_bd04rs:=stuff(si_bd04rs,15,3,ntoc(val(substr(si_bd04rs,15,3))+1,10,3,"0"))
    dl_si:=val(substr(si_bd04rs,18,3))-6
    si_bd04rs:=stuff(si_bd04rs,23,3,"000")
    for i:=1 to dl_si-1 step 6
      si_bd04rs:=stuff(si_bd04rs,26+i+2,3,"000")
    next
    PutSi(n_bd04rs+".dbf",si_bd04rs) 
    for i:=1 to len(aASU)
      if aASU[i,1]="bd04rs"
        exit
      endif 
    next
     @ 13,19 Say'            BD04RS        '
     FileCopy((n_bd04rs+".dbf"),(aASU[i,2]+aASU[i,1]+".dbf"))
     nErr:=ErrorCode(.T.)
     If nErr!=0
        my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
        @ 12,19 Say'    Ошибка копирования файла   '
        @ 13,19 Say'     BD04RS.dbf - '+Str(nErr,2)
        @ 14,19 Say' Обратитесь к разработчику!!!  '
        Inkey(0)
     EndIf
    
    
    my_box(11,18,15,51,B_DOUBLE+chr(32),"GR+/B")
    @ 12,19 Say'  Архив КАРТ УЧЕТА за '+arh_year+' год'
    @ 13,19 Say'             создан.'
    @ 14,19 Say'     Нажмите любую клавишу...'
    Inkey(0)
    f_arh_create:=.T.
 EndIf
Return .T.

/*Процедуры завершения года (УДАЛЕНИЕ АРХИВА)*/
Procedure Delete_arh()
Local dir,cget_pic,arh_year,arh_path,Ret,del_arh

 my_box(5,7,20,72,B_DOUBLE+chr(32),"W+/W")
 @ 5,31 Say' Удаление архива '
 Set Color to N/W,N/G
 Set Cursor On
 arh_year=Str(Year(Date())-1,4)
 @ 20,54 Say ' Esc - отмена '
 @ 10,18 Say 'Введите год, за который будет УДАЛЕН архив:'
 cget_pic="9999"
 @ 12,37 Get arh_year Picture cget_pic Valid Len(AllTrim(arh_year))==4
 Read
 If LastKey()==K_ESC
    Set Color To N/BG
    Clear Screen
    Return
 EndIf
 arh_year=AllTrim(Upper(arh_year))
 Set Cursor Off
//формируем путь для удаляемого каталога
 arh_path:=kar_path+'arhiv\'+arh_year+'\'
 //arh_path:="e:\arhiv\"+arh_year+'\' /*Макарова*/
//проверяем этот архив существует ?
//если найден удаляемый каталог, то УДАЛЯЕМ его
 If !DirChangeMN(SubStr(arh_path,1,Len(arh_path)-1),10)
    my_box(13,18,17,51,B_DOUBLE+chr(32),"W+/R")
    @ 14,19 Say'       Архив за '+arh_year+' год'
    @ 15,19 Say'         не существует         '
    @ 16,19 Say'   Нажмите любую клавишу ...   '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return
 Else
    my_box(12,18,17,51,B_DOUBLE+chr(32),"W+/R")
    @ 13,19 Say'   !!!  В Н И М А Н И Е  !!!   '
    @ 14,19 Say' Архив за '+arh_year+' год будет УДАЛЕН'
    @ 16,19 Say'    Удалить архив?   '
    Set Wrap On
    @ 16,39 Prompt " Нет "
    @ 16,44 Prompt "  Да "
    Ret=1
    Menu To Ret
    Do Case
       case Ret=0
         del_arh:=.F.
       case Ret=1
         del_arh:=.F.
       case Ret=2
         del_arh:=.T.
    EndCase
    Set Color to N/W,N/G
    @ 12,18 Clear To 18,55
    If del_arh==.F.
       Restore Screen
       Clear Screen
       Close All
       Return
    Else
       //удаляем из C:\karta\basespdo.dbf архив arhiv____ (н-р, arhive2000)
       //в C:\karta\basespdo.dbf прописаны пути к БД для рабочих станций
       // 25.08.06 сейчас это не используется, только usesся C:\basespdo.dbf
/*       If MYNetUse(kar_path+"basespdo.dbf",.T.,5)
          Set Index To (kar_path+"basespdo.ntx")
          If (basespdo->(dbseek('arhiv'+arh_year)))
             Delete
             Pack
          EndIf
          Index On name To (kar_path+'basespdo.ntx')
          Close basespdo
       Else
          my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
          @ 12,19 Say'Файл '+kar_path+'BASESPDO.dbf'
          @ 14,19 Say'            не доступен'
          @ 14,19 Say'    Нажмите любую клавишу ...  '
          InKey(0)
          Restore Screen
          Clear Screen
          Close All
          Return
       EndIf*/
       //удаляем из H:\basespdo.dbf
       //(для сервера пути в basespdo.dbf==C:\karta\)
       If MYNetUse(path_base+"basespdo.dbf",.T.,5,.F.)
          Set Index To (path_base+"basespdo.ntx")
          If (basespdo->(dbseek('arhiv'+arh_year)))
             Delete
             Pack
          EndIf
          Index On name To (path_base+'basespdo.ntx')
          Close basespdo
       Else
          my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
          @ 12,19 Say'     Файл BASESPDO.dbf         '
          @ 14,19 Say'            не доступен        '
          @ 14,19 Say'    Нажмите любую клавишу ...  '
          InKey(0)
          Restore Screen
          Clear Screen
          Close All
          Return
       EndIf
       //удаляем директорию (arh_path)
       FileDelete(arh_path+"*.*")
       DirRemove(SubStr(arh_path,1,Len(arh_path)-1))  //удаляет только пустую директорию
//       Run ("DELTREE /Y "+SubStr(arh_path,1,Len(arh_path)-1))
       my_box(11,18,15,51,B_DOUBLE+chr(32),"GR+/B")
       @ 12,19 Say'   Архив за  '+arh_year+'  год удален.'
       @ 14,19 Say'     Нажмите любую клавишу...'
       Inkey(0)
    EndIf
 EndIf
Return

/*Процедуры обновления БД*/
Procedure Copy_new_db()
Local j
 f_pl03_copy:=.F.
 my_box(5,7,20,72,B_DOUBLE+chr(32),"W+/W")
 @ 5,22 Say' Копирование данных с сервера ОАСУП '
 /*Читаем данные из H:\bases.dbf*/
 If FileMN(path_base+"bases.dbf",10)
    If MYNetUse(path_base+"bases.dbf",.F.,5,.T.)
       Set Index To (path_base+"bases.ntx")
    Else
       my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
       @ 12,19 Say'       Файл BASES.dbf          '
       @ 13,19 Say'          не доступен.         '
       @ 14,19 Say'    Нажмите любую клавишу ...  '
       InKey(0)
       Restore Screen
       Clear Screen
       Close All
       Return
    EndIf
 Else
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say'        Файл BASES.dbf         '
    @ 13,19 Say'           не найден.          '
    @ 14,19 Say'    Нажмите любую клавишу ...  '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return
 EndIf

//Masha
 If .NOT.zaverOK()
    Return
 EndIf
//Masha

 For i:=1 To Len(aASU)
   If (bases->(dbSeek(aASU[i,1]+".dbf")))
      if left(aASU[i,1],6)="bd02nz" 
        poiskCen(AllTrim(bases->arch),"bd02nz")
      else
        aASU[i,2]:=AllTrim(bases->path)
      endif     
      cSi:=""  
      // Стеценко остановился тут 
      If FileMN(aASU[i,2]+aASU[i,1]+".dbf",10) //если такой файл найден то GetSi()
//Masha проверяем пусты ли эти файлы!    /*Макарова добавила ns02oc*/
         If aASU[i,1]=='bd02ph'.OR.aASU[i,1]=='ns02oc'.OR. left(aASU[i,1],6)=='bd02nz'.OR.;
            aASU[i,1]=='pl03iz'.OR.aASU[i,1]=='pl03ps'.OR.;
            aASU[i,1]=='pl02izs'.OR.aASU[i,1]=='pl02pss'.OR.;
            aASU[i,1]=="pl01k1".OR.aASU[i,1]=="pl01k2".OR.;//Макарова
            aASU[i,1]=="pl01k3".OR.;
            aASU[i,1]=='pl03k1'.OR.aASU[i,1]=='pl03k1i'.OR.;
            aASU[i,1]=='pl03k2'.OR.aASU[i,1]=='pl03k2i'.OR.;
            aASU[i,1]=='pl03k3'.OR.aASU[i,1]=='pl03k3i'.OR.;
            aASU[i,1]=='pl03k4'.OR.aASU[i,1]=='pl03k4i'.Or.;
            aASU[i,1]=="pl05ps".OR.aASU[i,1]=="pl05iz"
            If NetUseMN(aASU[i,2]+aASU[i,1]+".dbf",.F.,5,.T.)
                If RecCount()<1
                    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
                    @ 12,19 Say'  Файл '+UPPER(aASU[i,1])+'.dbf (ОАСУП) пуст '
                    @ 14,19 Say'    Нажмите любую клавишу ...  '
                    InKey(0)
                    Restore Screen
                    Clear All
                    Close All
                    Quit
                EndIf
                Close (aASU[i,1])
                my_box(5,7,20,72,B_DOUBLE+chr(32),"W+/W")
                @ 5,22 Say' Копирование данных с сервера ОАСУП '
            Else
                my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
                @ 12,19 Say'        Файл '+Upper(aASU[i,1])+'.DBF       '
                @ 13,19 Say' на сервере ОАСУП не доступен. '
                @ 14,19 Say'    Нажмите любую клавишу ...  '
                InKey(0)
                Restore Screen
                Clear All
                Close All
                Quit
            EndIf
         EndIf
//Masha
         cSi:=GetSi(aASU[i,2]+aASU[i,1]+".dbf")
         lSi:=0
         If .Not.Empty(cSi)
            If aASU[i,1]=="pl03ps".or.aASU[i,1]=="pl03iz".or.;
               aASU[i,1]=="pl02izs".or.aASU[i,1]=="pl02pss".OR.;
               aASU[i,1]=="pl01k1".OR.aASU[i,1]=="pl01k2".OR.;//Макарова
               aASU[i,1]=="pl01k3".OR.;
               aASU[i,1]=="pl03k1".OR.aASU[i,1]=="pl03k1i".OR.;//Masha
               aASU[i,1]=="pl03k2".OR.aASU[i,1]=="pl03k2i".OR.;
               aASU[i,1]=="pl03k3".OR.aASU[i,1]=="pl03k3i".OR.;//Masha
               aASU[i,1]=="pl03k4".OR.aASU[i,1]=="pl03k4i".Or.;
               aASU[i,1]=="pl05ps".OR.aASU[i,1]=="pl05iz"
               //взять номер поколения
               aASU[i,3]:=SubStr(cSi,15,3)
               lSi:=Val(SubStr(cSi,18,3)) //если есть служ.инф-ция
               If lSi!=0                  //то заносим в массив
                  aASU[i,5]:=SubStr(cSi,21,lSi)
               EndIf
               //дата плана в формате квартал(1 цифра)/год(2 цифры)
               If aASU[i,1]=="pl01k1".OR.aASU[i,1]=="pl01k2".OR.;//Макарова
                  aASU[i,1]=="pl01k3"
                    iif(lSi # 0, aASU[i,4]:=SubStr(cSi,21,4), )
               Else
                    aASU[i,4]:=SubStr(cSi,28,4)
                    //вставлено для последующего анализа если kv_pl05_asu<>kv_pl03_asu то карточки не переформировывать
                    If aASU[i,1]=="pl05ps"
                       kv_pl05_asu:=aASU[i,4]
                    EndIf
                    If aASU[i,1]=="pl03ps"
                       kv_pl03_asu:=aASU[i,4]
                    EndIf
               EndIf
            Else
               aASU[i,3]:=Substr(cSi,15,3) //номер поколения
               aASU[i,4]:=Substr(cSi,7,8)  //дата
               lSi:=Val(SubStr(cSi,18,3)) //если есть служ.инф-ция
               If lSi!=0                  //то заносим в массив
                  aASU[i,5]:=SubStr(cSi,21,lSi)
               EndIf
            EndIf
         EndIf
      Else
         aASU[i,3]:=cSi
         aASU[i,4]:=cSi
      EndIf
   Else
      my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
      @ 12,19 Say'  Файл '+Upper(aASU[i,1])+' в BASES.dbf'
      @ 13,19 Say'          не найден. '
      @ 14,19 Say'    Нажмите любую клавишу ...  '
      InKey(0)
      Restore Screen
      Clear Screen
      Close All
      Return
   EndIf
 Next
 Close bases

 /*Анализ на ЗАВЕРШЕНИЕ ГОДА (необходимость создания АРХИВА)*/
 //запоминаем значения года для БД bd02nc и pl03ps на серверах АСУ и ПДО
 For i:=1 To Len(aASU)
   If aASU[i,1]=="bd02nc"
      Iif(Empty(SubStr(aASU[i,4],7,2)),t_bd02ASU:=Val(""),t_bd02ASU:=Val("20"+SubStr(aASU[i,4],7,2)))
   EndIf
   If aASU[i,1]=="pl03ps"
      Iif(Empty(SubStr(aASU[i,4],3,2)),t_pl03ASU:=Val(""),t_pl03ASU:=Val("20"+SubStr(aASU[i,4],3,2)))
   EndIf
 Next
 For i:=1 To Len(aPDO)
   If aPDO[i,1]=="bd02nc"
      Iif(Empty(SubStr(aPDO[i,4],7,2)),t_bd02PDO:=Val(""),t_bd02PDO:=Val("20"+SubStr(aPDO[i,4],7,2)))
   EndIf
   If aPDO[i,1]=="pl03ps"
      Iif(Empty(SubStr(aPDO[i,4],3,2)),t_pl03PDO:=Val(""),t_pl03PDO:=Val("20"+SubStr(aPDO[i,4],3,2)))
   EndIf
 Next
 //если год pl03ps и год bd02nc на сервере АСУ равны и больше, чем года
 //соответствующих им БД на сервере ПДО, то необх. провести архивацию данных
 If ((t_bd02ASU==t_pl03ASU).And.(t_bd02ASU-1==t_bd02PDO);
                           .And.(t_pl03ASU-1==t_pl03PDO))
    arh_year:=Str(t_pl03PDO,4) //архивируемый год
    //If DirChange('c:\karta\'+arh_year+'\')==0
    If DirChangeMN(kar_path+'arhiv\'+arh_year+'\',10) /*Макарова смена директории и функции*/
    //If DirChangeMN('e:\arhiv\'+arh_year,10) /*Макарова смена директории и функции*/
       //архив уже есть
    Else
       If .Not. Create_arh()
          //если был сбой при создании архива
          my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
          @ 12,19 Say'  ОШИБКА  при создании архива  '
          @ 13,19 Say'   Обратитесь к разработчику. '
          @ 14,19 Say'    Нажмите любую клавишу ...  '
          InKey(0)
          Restore Screen
          Clear Screen
          Close All
          Return
       Else
          f_notadd:=1 //взводим флаг, чтобы не был повторно накоплен bd12tc
       EndIf
    EndIf
 EndIf
 //если bd02nc на новый год, а pl03ps на старый
 If (t_bd02ASU-1==t_pl03ASU)
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say'  НЕТ ПЛАНА на новый квартал  '
    @ 13,19 Say'  Обратитесь к разработчику. '
    @ 14,19 Say'    Нажмите любую клавишу ...  '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return
 EndIf
/* Это работало нормально, но надо было на K:/PDO создавать пустой bd02nc с датой нового года, т.к. план
уже был на новый год, а накладные на новый год еще не принесли
 //если pl03ps на новый год, а bd02nc на старый
 If (t_pl03ASU-1==t_bd02ASU)
    f_notcopy:=1
    //в этой ситуации не копируем pl03ps, pl03iz, pl05ps, pl05iz, bd02ph с сервера АСУ,
    //чтобы не рассчитать карточки на новый год до того как будет создан
    //архив за прошлый год
 EndIf
*/
 //если pl03ps на новый год, а bd02nc на старый и на сервере ПДО pl03ps и bd02nc на старый год
 //то спрашиваем пользователя проводить архивацию или нет
 //Если товар был закрыт (но новых накладных еще не поступало) пользователь может выполнить принудительную архивацию
 If ((t_pl03ASU-1==t_bd02ASU).And.(t_bd02ASU==t_bd02PDO).And.(t_pl03ASU-1==t_pl03PDO))
    //спрашиваем пользователя надо ли принудительно завершить год
    //если ДА, то проводим завершение года и создаем на сервере ПДО пустую bd02nc с датой=01.01.год_PL03_ASU и НП=000//НП=НП_bd02nc_ASU
    Save Screen
    my_box(9,14,17,65,B_DOUBLE+chr(32),"W+/R")
    @ 10, 19 Say' ВНИМАНИЕ !!!  ПЛАН на новый квартал !'
    @ 11, 19 Say'                '
    @ 12, 16 Say'Если ТОВАР ЗАКРЫТ - ВЫПОЛНИТЬ АРХИВАЦИЮ ЗА ГОД ?'
    @ 15, 32 Say' Да '
    @ 15, 43 Say' Нет '

    TekOtv := 'Нет'
    SetColor("W+/B")
    @ 15, 43 Say' Нет '
    lkey := Inkey(0)

    While (lkey # K_ENTER)
       If (TekOtv == 'Да')
          SetColor("W+/R")
          @ 15, 32 Say' Да '
       Else
          SetColor("W+/R")
          @ 15, 43 Say' Нет '
       EndIf
       Do Case
          Case (lkey = K_LEFT).OR.(lkey = K_RIGHT).OR.(lkey = K_TAB)
               If TekOtv == 'Да'
                  TekOtv = 'Нет'
               Else
                  TekOtv = 'Да'
               EndIf
       EndCase
       If (TekOtv == 'Да')
          SetColor("W+/B")
          @ 15, 32 Say' Да '
       Else
          SetColor("W+/B")
          @ 15, 43 Say' Нет '
       EndIf
       lkey = Inkey(0)
    EndDo

    If TekOtv == 'Нет'
       f_notcopy:=1
       //в этой ситуации не копируем pl03ps, pl03iz, pl05ps, pl05iz, bd02ph с сервера АСУ,
       //чтобы не рассчитать карточки на новый год до того как будет создан
       //архив за прошлый год
    Else
       arh_year:=Str(t_pl03PDO,4) //архивируемый год
       If DirChangeMN(kar_path+'arhiv\'+arh_year+'\',10) /*Макарова смена директории и функции*/
         //архив уже есть
       Else
          If .Not. Create_arh()
             //если был сбой при создании архива
             my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
             @ 12,19 Say'  ОШИБКА  при создании архива  '
             @ 13,19 Say'   Обратитесь к разработчику. '
             @ 14,19 Say'    Нажмите любую клавишу ...  '
             InKey(0)
             Restore Screen
             Clear Screen
             Close All
             Return
          Else
             f_notadd:=1 //взводим флаг, чтобы не был повторно накоплен bd12tc
             //bd02nc на сервере ПДО после накопления удаляется
             //создаем на сервере ПДО пустую bd02nc с датой=01.01.год_PL03_ASU и НП=НП_bd02nc_ASU, в массив aPDO изменения не вносятся
             For i:=1 To Len(aASU)
               If aASU[i,1]=="bd02nc"
                  si_bd02nc:=GetSi(aASU[i,2]+"bd02nc.dbf")
                  Exit
               EndIf
             Next

             For i:=1 To Len(aPDO)
               If aPDO[i,1]=="bd02nc"
                  DBCreate(aPDO[i,2]+"bd02nc.dbf",aBD02NC)
                  si_bd02nc:=Stuff(si_bd02nc,7,8,"01/01/"+SubStr(Str(t_pl03ASU),3,2))    //меняем дату на новый год
                  si_bd02nc:=Stuff(si_bd02nc,15,3,"000")    //меняем поколение на новый год
                  PutSi(aPDO[i,2]+"bd02nc.dbf",si_bd02nc)
                  Exit
               EndIf
             Next
          EndIf
       EndIf
    EndIf
 EndIf

 /*Проверка на изменение (неравенство) номера поколения БД и копирование БД*/
 copy_to:=.F.
 For i:=1 To Len(aASU)
  If FileMN(aASU[i,2]+aASU[i,1]+".dbf",10) //файл на сервере АСУ найден
     Iif(aASU[i,3]==aPDO[i,3],copy_to:=.F.,copy_to:=.T.)
     If substr(aASU[i,1],1,6)=="bd02nz"
        if aASU[i,4] # aPDO[i,4]
          copy_to:=.T.  
        endif
     endif
     If aASU[i,1]=="sm50"
       copy_to:=.T.  
     endif
     If aASU[i,1]=="bd02nc"
        if right(aASU[i,4],2) < right(aPDO[i,4],2)
          copy_to:=.F.
        elseif right(aASU[i,4],2) = right(aPDO[i,4],2) .and. substr(aASU[i,4],4,2) < substr(aPDO[i,4],4,2)
          copy_to:=.F.
        endif
     EndIf
     If aASU[i,1]=="pl01k1".Or.aASU[i,1]=="pl01k2".Or.aASU[i,1]=="pl01k3"
        if right(aASU[i,4],2) < right(aPDO[i,4],2)
          copy_to:=.F.
        endif
        if right(aASU[i,1],1) # left(aASU[i,4],1)
          alert("N кв. не соответствует названию "+aASU[i,1]+".dbf.; Позвоните операторам 21-79")
          copy_to:=.F.
        endif
        if copy_to
          if pl01_God==""
            for j=1 to len(aPDO)
              if aPDO[j,1]=="pl01"
               pl01_God:=substr(GetSi(aPDO[j,2]+aPDO[j,1]+".dbf"),23,2)
               exit
              endif
            next
          endif
          if right(aASU[i,4],2) # pl01_God
            copy_to:=.F.
          endif
        endif
     EndIf
     If aASU[i,1]=="pl03k1".Or.aASU[i,1]=="pl03k2";
       .Or.aASU[i,1]=="pl03k3".Or.aASU[i,1]=="pl03k4";
       .Or.aASU[i,1]=="pl03k1i".Or.aASU[i,1]=="pl03k2i";
       .Or.aASU[i,1]=="pl03k3i".Or.aASU[i,1]=="pl03k4i"
        if SubStr(aASU[i,1],6,1) # left(aASU[i,4],1)
        //if SubStr(aPDO[i,1],6,1) # left(aPDO[i,4],1)
          alert("N кв. не соответствует названию "+aASU[i,1]+".dbf.; Позвоните операторам 21-79")
          copy_to:=.F.
        endif
     EndIf
     If aASU[i,1]=="pl03ps".Or.aASU[i,1]=="pl03iz".Or.aASU[i,1]=="bd02ph"
        If f_notcopy==1
           copy_to:=.F.
        Else
           //ситуация, когда в си pl03 стоит планирование
           If (aASU[i,1]=="pl03ps".Or.aASU[i,1]=="pl03iz").And.;
              (At('ПЛ',RUpper(aASU[i,5]))!=0 .Or. At('ПЛ',RUpper(aPDO[i,5]))!=0)//если НП pl03 равны, а в си pl03 стоит планирование, то надо копировать файл
              copy_to:=.T.
           EndIf
        EndIf
     EndIf
     //если квартал/год pl03ps <> квартал/год pl05ps  НЕ копируем PL05. переформировать карточки от PL03 БЕЗ учета PL05
     If ((aASU[i,1]=="pl05ps".Or.aASU[i,1]=="pl05iz") .And.(kv_pl05_asu<>kv_pl03_asu))
        copy_to:=.F.
     EndIf

     If aASU[i,1]=="pl02pss".or.aASU[i,1]=="pl02izs"
        If aASU[i,5] # aPDO[i,5]
            copy_to:=.T.
        End
     End
     If aASU[i,1]=="bd02ki"
        copy_to:=.F.
     EndIf
     If aASU[i,1]=="mp31"   //номер поколения почему-то не меняется
        copy_to:=.F.
        If SubStr(aASU[i,5],2,1)<>"/"
           alert(aASU[i,1]+".dbf. НЕ квартальный!; Позвоните операторам 21-79")
        Else     //mp31 квартальный
           If (aASU[i,4]<>aPDO[i,4]).And.(SubStr(aASU[i,5],3,2)==SubStr(aPDO[i,5],3,2)) //дата создания разная, год в СИ один и тот же - проводим обновление mp31
              copy_to:=.T.
           EndIf
        EndIf
     EndIf
//Masha    переформируем ns05tn на сервере ПДО
//         (для разбиения bd02ki по участкам)
//         оставляем только все цеха и поля ЦЕХ,ЧЕРТЕЖ,ПС и БР,ОБОР
     If aASU[i,1]=="ns05tn".and.copy_to==.T.
        copy_to:=.F.
      /*Макарова вставила индекс т.к. при исп-и GoToTop с пар-ром нужна сортировка*/
        /*Use (aASU[i,2]+aASU[i,1]+".dbf") New Shared ReadOnly*/
        Use (aASU[i,2]+aASU[i,1]+".dbf") index (aASU[i,2]+aASU[i,1]+".ntx") New Shared ReadOnly
        If !NetErr()
//        If MYNetUse(aASU[i,2]+aASU[i,1]+".dbf",.F.,5)
           DbCreate(aPDO[i,2]+"ns05tn_.dbf",aNS05TN)
           Use (aPDO[i,2]+"ns05tn_") New
           index on cex+chert+ps+substr(br,1,2)+obor to (aPDO[i,2]+"ns05tn_.ntx") //Макарова 27.06.12 чтоб не было повторов  
           my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/B")
           @ 12,19 Say'  Идет переформирование файла '
           @ 14,19 Say'          на сервере ПДО.      '
           Set Color To W+*/B
           @ 13,19 Say'            '+Upper(aASU[i,1])+'            '

           Select ns05tn
           //f:='(cex=="43" .or. cex=="56")'
           /*f:='(cex="43" .or. cex="47" .or. cex="56")'
           Set Filter To &f
           If GoToTop('cex')
           Макарова 27.06.12 все цеха*/
              /*Set Filter To*//*Макарова фильтр нужен, поэтому закомментировала*/
              /*18.11.09 Макарова добавила поле оборудования*/
           Do while (!ns05tn->(Eof())) //.and.ns05tn->cex<'57' //Макарова 27.06.12 все цеха
              //if ns05tn->cex$'43_47_56'//Макарова 27.06.12 все цеха
              if ns05tn_->(!dbseek(ns05tn->(cex+chert+ps+br+obor)))
                 ns05tn_->(dbAppend())
                 ns05tn_->cex   := ns05tn->cex
                 ns05tn_->chert := ns05tn->chert
                 ns05tn_->ps    := ns05tn->ps
                 ns05tn_->br    := ns05tn->br
                 ns05tn_->obor  := ns05tn->obor
              endif //Макарова 27.06.12 чтоб не было повторов
              //endif //Макарова 27.06.12 все цеха
              ns05tn->(dbSkip())
           enddo
           //Else
           //EndIf //Макарова 27.06.12 все цеха

           Close ns05tn
           Close ns05tn_

           Delete File (aPDO[i,2]+"ns05tn.dbf")
           Delete File (aPDO[i,2]+"ns05tn_.ntx")
           Rename (aPDO[i,2]+"ns05tn_.dbf") To (aPDO[i,2]+"ns05tn.dbf")
           PutSi(aPDO[i,2]+"ns05tn.dbf","NS05TN"+aASU[i,4]+aASU[i,3])
        Else
           my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
           @ 12,19 Say'        Файл NS05TN.DBF       '
           @ 13,19 Say' на сервере ОАСУП не доступен. '
           @ 14,19 Say'    Нажмите любую клавишу ...  '
           InKey(0)
           Restore Screen
           Clear All
           Close All
           Quit
        EndIf
     EndIf
//Masha
     If aASU[i,1]="bd02nc"
        If MYNetUse(aASU[i,2]+aASU[i,1]+".dbf",.F.,5,.T.)
           If bd02nc->(LastRec())<1
//Masha    если файл накладных пустой!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
//              copy_to:=.F.
              Save Screen
              my_box(9,18,17,60,B_DOUBLE+chr(32),"W+/R")
              @ 10, 19 Say'               ВНИМАНИЕ !!!'
              @ 11, 19 Say'            Накладных НЕТ !!!'
              @ 12, 19 Say'               Продолжить?'
              @ 15, 32 Say' Да '
              @ 15, 43 Say' Нет '

              TekOtv := 'Нет'
              SetColor("W+/B")
              @ 15, 43 Say' Нет '
              lkey := Inkey(0)

              While (lkey # K_ENTER)
                 If (TekOtv == 'Да')
                    SetColor("W+/R")
                    @ 15, 32 Say' Да '
                 Else
                    SetColor("W+/R")
                    @ 15, 43 Say' Нет '
                 EndIf
                 Do Case
                  Case (lkey = K_LEFT).OR.(lkey = K_RIGHT).OR.(lkey = K_TAB)
                   If TekOtv == 'Да'
                      TekOtv = 'Нет'
                   Else
                      TekOtv = 'Да'
                   EndIf
                 EndCase
                 If (TekOtv == 'Да')
                   SetColor("W+/B")
                   @ 15, 32 Say' Да '
                 Else
                   SetColor("W+/B")
                   @ 15, 43 Say' Нет '
                 EndIf
                 lkey = Inkey(0)
              EndDo
              If TekOtv == 'Да'
              Else
                 Restore Screen
                 Clear All
                 Close All
                 Quit
              EndIf
//              my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
//              @ 12,19 Say'  Файл BD02NC.DBF (ОАСУП) пуст '
//              @ 14,19 Say'    Нажмите любую клавишу ...  '
//              InKey(0)
//Masha
           EndIf
//Masha  номера поколений bd02nc равны, т.е. на сервере АСУ старые накладные
           If copy_to == .F.
              Save Screen
              my_box(9,18,17,60,B_DOUBLE+chr(32),"W+/R")
              @ 10, 19 Say'       Накладные не обновлялись!!'
              @ 11, 19 Say'    Последние обработки за '+aPDO[i,4]
              @ 12, 19 Say'               Продолжить?'
              @ 15, 32 Say' Да '
              @ 15, 43 Say' Нет '

              TekOtv := 'Нет'
              SetColor("W+/B")
              @ 15, 43 Say' Нет '
              lkey := Inkey(0)

              While (lkey # K_ENTER)
                 If (TekOtv == 'Да')
                    SetColor("W+/R")
                    @ 15, 32 Say' Да '
                 Else
                    SetColor("W+/R")
                    @ 15, 43 Say' Нет '
                 EndIf
                 Do Case
                  Case (lkey = K_LEFT).OR.(lkey = K_RIGHT).OR.(lkey = K_TAB)
                   If TekOtv == 'Да'
                      TekOtv = 'Нет'
                   Else
                      TekOtv = 'Да'
                   EndIf
                 EndCase
                 If (TekOtv == 'Да')
                   SetColor("W+/B")
                   @ 15, 32 Say' Да '
                 Else
                   SetColor("W+/B")
                   @ 15, 43 Say' Нет '
                 EndIf
                 lkey = Inkey(0)
              EndDo
              If TekOtv == 'Да'
              Else
                 Restore Screen
                 Clear All
                 Close All
                 Quit
              EndIf
           EndIf
//Masha
           Close bd02nc
           my_box(5,7,20,72,B_DOUBLE+chr(32),"W+/W")
           @ 5,22 Say' Копирование данных с сервера ОАСУП '
        Else
           my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
           @ 12,19 Say'        Файл BD02NC.DBF       '
           @ 13,19 Say' на сервере ОАСУП не доступен. '
           @ 14,19 Say'    Нажмите любую клавишу ...  '
           InKey(0)
           Restore Screen
           Clear All
           Close All
           Quit
        EndIf
     EndIf
     If aASU[i,1]="bd04rs"
        If MYNetUse(aASU[i,2]+aASU[i,1]+".dbf",.F.,5,.T.)
           If bd04rs->(LastRec())<1
              copy_to:=.F.
              my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
              @ 12,19 Say'  Файл BD04RS.DBF (ОАСУП) пуст '
              @ 14,19 Say'    Нажмите любую клавишу ...  '
              InKey(0)
           EndIf
           Close bd04rs
           my_box(5,7,20,72,B_DOUBLE+chr(32),"W+/W")
           @ 5,22 Say' Копирование данных с сервера ОАСУП '
        Else
           my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
           @ 12,19 Say'        Файл BD04RS.DBF       '
           @ 13,19 Say' на сервере ОАСУП не доступен. '
           @ 14,19 Say'    Нажмите любую клавишу ...  '
           InKey(0)
           Restore Screen
           Clear All
           Close All
           Quit
        EndIf
     EndIf
     If copy_to
        If aASU[i,1]="ns01ks"
           For i:=1 To Len(aPDO)
               If aPDO[i,1]=="ns01ks"
                  Exit
               EndIf
           Next
           If FileDelete(aPDO[i,2]+"ns01np.ntx")
           Else
              my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
              @ 12,19 Say'   Файл '+aPDO[i,2]+"ns01np.ntx"
              @ 13,19 Say'           не найден           '
              @ 14,19 Say'   Нажмите любую клавишу...    '
              Inkey(0)
           EndIf
           If FileDelete(aPDO[i,2]+"ns01ks.ntx")
           Else
              my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
              @ 12,19 Say'   Файл '+aPDO[i,2]+"ns01ks.ntx"
              @ 13,19 Say'           не найден           '
              @ 14,19 Say'   Нажмите любую клавишу...    '
              Inkey(0)
           EndIf
        EndIf
        //если это bd02nc, то проверяем необходимость накопления bd12tc
        If aASU[i,1]="bd02nc" .And. f_notadd==0
           //если месяцы полученные по GetSi() разные (НО за один и тотже год),
           //то проводим накопление
           If (SubStr(aASU[i,4],4,2)!=SubStr(aPDO[i,4],4,2)).And.;
              (SubStr(aASU[i,4],7,2)==SubStr(aPDO[i,4],7,2))
              If .Not. Adding()  //если не удалось заблокировать bd12tc или
                 Return          //bd02nc, то выход в основное меню
              EndIf
           EndIf
        EndIf
        //если это bd04rs, то проверяем необходимость накопления bd12rs
        If aASU[i,1]="bd04rs" .And. f_notadd==0
           //если месяцы полученные по GetSi() разные (НО за один и тотже год),
           //то проводим накопление
           If (SubStr(aASU[i,4],4,2)!=SubStr(aPDO[i,4],4,2)).And.;
              (SubStr(aASU[i,4],7,2)==SubStr(aPDO[i,4],7,2))
              If .Not. Adding_RS() //если не удалось заблокировать bd12rs или
                 Return          //bd04rs, то выход в основное меню
              EndIf
           EndIf
        EndIf
        //если это mp31, то переименовываем mp31(ПДО) в mp31_(ПДО)
        If aASU[i,1]="mp31"
           If !FileMN(aPDO[i,2]+"mp31.dbf",10)
              DbCreate(aPDO[i,2]+"mp31.dbf",aMP31)
           EndIf
           Rename (aPDO[i,2]+"mp31.dbf") To (aPDO[i,2]+"mp31_.dbf")
        EndIf
        /*Макарова если сменился квартал у pl01.dbf, переименовываем предыдущий в pl01kx.dbf*/
        If aASU[i,1]="pl01" .and. FileMN(aPDO[i,2]+"pl01.dbf",10);
         .and. !(aPDO[i,5]=="") .and. !(left(aPDO[i,5],1)==left(aASU[i,5],1))
          for j=1 to len(aPDO) /*СИ - в aPDO для полученного pl01kx*/
            if aPDO[j,1]=="pl01k"+left(aPDO[i,5],1)
              Exit
            endif
          next
          if j<=len(aPDO)
            If FileMN(aPDO[j,2]+"pl01k"+left(aPDO[i,5],1)+".dbf",10)
              Delete File (aPDO[j,2]+"pl01k"+left(aPDO[i,5],1)+".dbf")
            EndIf
            Rename (aPDO[i,2]+"pl01.dbf") To (aPDO[j,2]+"pl01k"+left(aPDO[i,5],1)+".dbf")
            aPDO[j,3]:=aPDO[i,3]
            //дата плана в формате квартал/год(2 цифры)
            aPDO[j,4]:=left(aPDO[i,5],4)
            aPDO[j,5]:=aPDO[i,5]
          endif
        EndIf

        my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/B")
        @ 12,19 Say'      Идет копирование файла   '
        @ 14,19 Say'         с сервера ОАСУП.      '
        Set Color To W+*/B
        @ 13,19 Say'            '+Upper(aASU[i,1])+'            '
        If aASU[i,1]="bd02nc"
          for iPathSm50:=1 to len(aASU)
            If aPDO[iPathSm50,1]="sm50"
              exit
            Endif
          next
          copy_to:=nkp_bdnc(aASU[i][2],aPDO[i][2],aASU[i][3],aPDO[i][3],aASU[i][4],aPDO[iPathSm50][2])
        /*ElseIf aASU[i,1]="pl03ps" .and. !zmna_kol(aASU[i][2],aPDO[i][2])
          setcolor("w/n")
          clear
          QUIT*/
        Else
          FileCopy((aASU[i,2]+aASU[i,1]+".dbf"),(aPDO[i,2]+aPDO[i,1]+".dbf"))
          nErr:=ErrorCode(.T.)
          If nErr!=0
            my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
            @ 12,19 Say'    Ошибка копирования файла   '
            @ 13,19 Say'        '+Upper(aASU[i,1])+' - '+Str(nErr,2)
            @ 14,19 Say'         с сервера ОАСУП.      '
            Inkey(0)
            Return
          EndIf
           //ситуация, когда в си pl03 стоит планирование
          If aASU[i,1]="pl03ps"  //признак, что pl03 скопирован. uses при переформировании карточек
             f_pl03_copy:=.T.
          EndIf
        EndIf
        //накапливаем накладные по сбыту(цех пол=20,22,33) по распоряжениям
        If aASU[i,1]="bd02nc" .and. copy_to
//Masha
           //сортирую bd02nc с ключом cex+chert+ps+vp+cp+dd_vv
           my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/B")
           @ 12,19 Say'      Идет сортировка файла   '
           @ 13,19 Say'             BD02NC.dbf   '
           @ 14,19 Say'          на сервере ПДО   '
           Use (aPDO[i,2]+aPDO[i,1]+".dbf") New Shared ReadOnly
           If !NetErr()
              Sort to (aPDO[i,2] + aPDO[i,1] +"_.dbf") On cex,chert,ps,vp,cp,dd_vv
              close bd02nc
              si_bd02nc := getsi(aPDO[i,2]+aPDO[i,1]+".dbf")
              delete file (aPDO[i,2]+aPDO[i,1]+".dbf")
              rename (aPDO[i,2]+aPDO[i,1]+"_.dbf") to (aPDO[i,2]+aPDO[i,1]+".dbf")
              delete file (aPDO[i,2]+aPDO[i,1]+"_.dbf")
              putsi(aPDO[i,2]+aPDO[i,1]+".dbf",si_bd02nc)
           else
           endif
//Masha
           If .Not. Sklad_nakl()
              Return
           EndIf
        EndIf
        //накапливаю mp31 (ПДО)
        If aASU[i,1]="mp31"
           Form_mp31()
        EndIf
        //индексируем ценник
        If left(aASU[i,1],6)="bd02nz"
           If MYNetUse(aPDO[i,2]+aPDO[i,1],.T.,5)
              my_box(12,18,15,45,B_DOUBLE+chr(32),"W+/B")
              @ 13,19 Say ' Создается индексный файл '
              Set Color To W+*/B
              @ 14,29 Say Upper(aPDO[i,1])
              Index On ceh+chert+ps To (aPDO[i,2]+aPDO[i,1])
           Else
              my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
              @ 12,19 Say' Файл '+aPDO[i,1]+'.dbf не доступен '
              @ 13,19 Say'   Невозможно обновить данные. '
              @ 14,19 Say'    Нажмите любую клавишу ...  '
              InKey(0)
              Restore Screen
              Clear Screen
              Close All
              Return
           EndIf
           Close bd02vc
        EndIf
//Masha  если ns03, то упаковываем его и создаем индекс
        If aASU[i,1]="ns03"
           If MYNetUse(aPDO[i,2]+aPDO[i,1],.T.,5)
              my_box(12,18,15,45,B_DOUBLE+chr(32),"W+/B")
              @ 13,19 Say ' Создается индексный файл '
              Set Color To W+*/B
              @ 14,29 Say Upper(aPDO[i,1])
              Pack
              Index On shm To (aPDO[i,2]+aPDO[i,1]+"i.ntx")
           Else
              my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
              @ 12,19 Say'   Файл ns03.dbf не доступен   '
              @ 13,19 Say'   Невозможно обновить данные. '
              @ 14,19 Say'    Нажмите любую клавишу ...  '
              InKey(0)
              Restore Screen
              Clear Screen
              Close All
              Return
           EndIf
           Close ns03
        EndIf
//Masha
     EndIf
  Else
     my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
     @ 12,19 Say'  Файл '+Upper(aASU[i,1])+' на сервере ОАСУП'
     @ 13,19 Say'            не найден.         '
     @ 14,19 Say'    Нажмите любую клавишу ...  '
     InKey(0)
  EndIf
 Next

 //накопление ( архивация при завершении года) и копирование bd02ki (Кутень)
 If .Not. Podchet(f_arh_create)  //если была какая-то ошибка в Podchet                bd02ki->ktek:=0
    Return
 EndIf

 /*если нет файла BD12TC, то пересоздаем его*/
 If !FileMN(n_bd12tc+".dbf",10)
    DBCreate(n_bd12tc,aBd12tc)
 EndIf

/*если нет файла BD12RS, то пересоздаем его*/
 If !FileMN(n_bd12rs+".dbf",10)
    DBCreate(n_bd12rs,aBd12rs)
 EndIf

/*если нет файла SKL_NAKL, то пересоздаем его*/
 If !FileMN(n_skl_nakl+".dbf",10)
    DBCreate(n_skl_nakl,askl_nakl)
 EndIf

/*если нет файла SBT, то пересоздаем его*/
 If !FileMN(n_sbt+".dbf",10)
    DBCreate(n_sbt,aSbt)
    PutSi(n_sbt+".dbf",'SBT   '+Dtoc(Date())+'000'+'005'+'00000')
 EndIf

 /*ПРОВЕРКА НА ИЗМЕНЕНИЕ PL03 и необходимость переформирования Карточек*/
 //Считываем служебную инф-цию из blanks, blanph (сервер ПДО)
 For i:=1 To Len(aPDO_dopol)
   If aPDO_dopol[i,1]=="blanks"
      blanks_Si:=GetSi(&(aPDO_dopol[i,2])+".dbf")
   EndIf
   If aPDO_dopol[i,1]=="blanph"
      blanph_Si:=GetSi(&(aPDO_dopol[i,2])+".dbf")
   EndIf
 Next
 //Считываем служебную инф-цию из pl03ps, bd02ph(сервер ПДО) после обновления
 For i:=1 To Len(aPDO)
   If aPDO[i,1]=="pl03ps"
      pl03ps_Si:=GetSi(aPDO[i,2]+aPDO[i,1]+".dbf")
      num_kv:=SubStr(pl03ps_Si,28,1)
      //временно берем дату файла для пометки позиций, отсутствующих в тек.плане
   EndIf
   If aPDO[i,1]=="pl05ps"
      pl05ps_Si:=GetSi(aPDO[i,2]+aPDO[i,1]+".dbf")
   EndIf
   If aPDO[i,1]=="bd02ph"
      bd02ph_Si:=GetSi(aPDO[i,2]+aPDO[i,1]+".dbf")
   EndIf
   If aPDO[i,1]=="bd02ki"
      bd02ki_Si:=GetSi(aPDO[i,2]+aPDO[i,1]+".dbf")
   EndIf
 Next
 /*если нет какого-либо из 4-рех файлов blanks(iz,tm,m)
  или номер поколения pl03ps(ПДО) не равен номеру поколения blanks
  или изменился номер поколения pl05ps, то пересоздаем  их*/
 If !FileMN(n_blan+".dbf",10).Or.!FileMN(n_blaniz+".dbf",10).Or.!FileMN(n_blantm+".dbf",10).Or.;
    !FileMN(n_blanm+".dbf",10).Or.!FileMN(n_bdkitm+".dbf",10);
    .Or.(SubStr(pl03ps_Si,15,3)!=SubStr(blanks_Si,15,3));
    .Or.((SubStr(pl03ps_Si,15,3)==SubStr(blanks_Si,15,3)).And.f_pl03_copy); //ситуация, когда в си pl03 стоит планирование
    .Or.(SubStr(pl05ps_Si,15,3)!=SubStr(blanks_Si,27,3))
    If num_kv==SubStr(blanks_Si,7,1)
       //если были добавки к плану, то их будем выделять
       f_new:=1
    EndIf
    If !New_Data(1)
       Restore Screen
       Clear Screen
       Close All
       Return
    EndIf

    f_rasp_plan:=1    //формировать распоряжения от плана
    FormBlank()       &&формирование БД blanks (iz,tm) (карты учета)

//  f_new:=0 //убираю, чтобы использовать этот флаг при формировании распоряжений
    //записываем в blanks и bd02ph новую служебную инф-цию
    blanks_Si:="BLANKS"+SubStr(pl03ps_Si,28,4)+"    "+SubStr(pl03ps_Si,15,3)+"009"+"PL05PS"+SubStr(pl05ps_Si,15,3)
    For i:=1 To Len(aPDO_dopol)
      If aPDO_dopol[i,1]=="blanks"
         PutSi(&(aPDO_dopol[i,2])+".dbf",blanks_Si)
         Exit
      EndIf
    Next
    //в blanph в SSS(служебную инф-цию) заносим дату и номер поколения bd02ph
    blanph_Si:="BLANPH"+SubStr(pl03ps_Si,28,4)+"    "+SubStr(pl03ps_Si,15,3)+"017"+SubStr(bd02ph_Si,1,17)
    For i:=1 To Len(aPDO_dopol)
      If aPDO_dopol[i,1]=="blanph"
         PutSi(&(aPDO_dopol[i,2])+".dbf",blanph_Si)
         Exit
      EndIf
    Next
 EndIf


 /*ПРОВЕРКА НА ИЗМЕНЕНИЕ BD02PH.DBF и необходимость переформирования blanph*/
 /*если нет какого-либо из 4-рех файлов blanph(iz,tm,m) или номер поколения
 bd02ph не равен номеру поколения в SSS(служ. инф-ции) blanph,
 то пересоздаем их*/
 If !FileMN(n_blanph+".dbf",10).Or.!FileMN(n_blphiz+".dbf",10).Or.!FileMN(n_blphtm+".dbf",10).Or.;
    !FileMN(n_blphm+".dbf",10) // .Or.(SubStr(bd02ph_Si,15,3)!=SubStr(blanph_Si,35,3)) //Дьяченко 29.11.06 пока bd02ph не используется
    If !New_Data(2)
       Restore Screen
       Clear Screen
       Close All
       Return
    EndIf

    f_rasp_plan:=1    //формировать распоряжения от плана
    FormBlanPH() //формируем переводимые чертежи blanph(-iz, -tm,-m)

    //в bd02ph в SSS(служебную инф-цию) заносим дату и номер поколения bd02ph
    blanph_Si:="BLANPH"+SubStr(pl03ps_Si,28,4)+"    "+SubStr(pl03ps_Si,15,3)+"017"+SubStr(bd02ph_Si,1,17)
    For i:=1 To Len(aPDO_dopol)
      If aPDO_dopol[i,1]=="blanph"
         PutSi(&(aPDO_dopol[i,2])+".dbf",blanph_Si)
         Exit
      EndIf
    Next
 EndIf
//*********** Создание БД для складов-сбыта ****************/
/* If !FileMN(n_raspor+".dbf",10) .Or. (f_rasp_plan=1 .And. f_new=0) //смена квартала //28.11.06
    DbCreate(n_raspor,aRaspor)
    f_rasp_plan:=1    //формировать распоряжения от плана
 EndIf
 If !FileMN(n_prior+".dbf",10) .Or. (f_rasp_plan=1 .And. f_new=0) //смена квартала
    DbCreate(n_prior,aPrior) //БД приоритетов
 EndIf
*/
 If f_rasp_plan=1

    sch_200(path_base)

    If !New_Data(3)
       Restore Screen
       Clear Screen
       Close All
       Return
    EndIf

    my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
    Set Color To W+*/B
    Select blanks
    @ 13,22 Say " Идет индексация базы данных BLANKS "
    Index On blanks->cex+blanks->chert+blanks->ps+blanks->vp+blanks->cp;
             To (n_blan+".ntx")

    Select blanph
    @ 13,22 Say " Идет индексация базы данных BLANPH "
    Index On blanph->cex+blanph->chert+blanph->ps+blanph->vp+blanph->cp;
             To (n_blanph+".ntx")

    Select blanksiz
    @ 13,22 Say "Идет индексация базы данных BLANKSIZ"
    Index On blanksiz->num To (n_blaniz+".ntx")

    Select blanphiz
    @ 13,22 Say "Идет индексация базы данных BLANPHIZ"
    Index On blanphiz->num To (n_blphiz+".ntx")
//28.11.06 Не исп.raspor.dbf,prior.dbf
//    Form_Rasp() //формируем распоряжения -формирование БД Raspor (распоряжений) от плана

    Form_Sklad() //формируем карты учета для цехов-получателей=складам сбыта

    Close All

    Delete File (n_blan+".ntx")
    Delete File (n_blaniz+".ntx")
    Delete File (n_blanph+".ntx")
    Delete File (n_blphiz+".ntx")

    f_rasp_plan:=0    //при изменении плана f_rasp.prg
 EndIf

 //RKol()
//Masha
 For i:=1 To Len(aPDO_dopol)
     If aPDO_dopol[i,1]=="spr_rasp"
//        If !File(aPDO_dopol[i,2]+"spr_rasp.dbf")
           dbname := &(aPDO_dopol[i,2])
           DBCreate(dbname, db_spr)
//        EndIf
        Exit
     EndIf
 Next
 If MYNetUse(n_spr_rasp,.T.,5)
 Else
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say' Файл SPR_RASP.dbf не доступен '
    @ 13,19 Say'   Невозможно обновить данные. '
    @ 14,19 Say'    Нажмите любую клавишу ...  '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return
 EndIf
 If MYNetUse(n_grf,.T.,5)
 Else
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say'    Файл GRF.dbf не доступен '
    @ 13,19 Say'   Невозможно обновить данные. '
    @ 14,19 Say'    Нажмите любую клавишу ...  '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return
 EndIf
 Set Deleted ON //ИГНОРИРУЮ УДАЛЕННЫЕ ЗАПИСИ
 Do While .NOT.grf->(eof())
    spr_rasp->(dbAppend())
    spr_rasp->kod = grf->kod
    spr_rasp->text = grf->text
    grf->(dbSkip())
 EndDo
 select spr_rasp
 Index On kod To (dbname)
 Set Deleted OFF //ОБРАБАТЫВАЮ ЗАПИСИ, ПОМЕЧЕННЫЕ КАК УДАЛЕННЫЕ

 close grf
 close spr_rasp
//Masha

/*28.11.06 убрано
//ежедневное перераспределение сдачи за сутки с 200 КИ на распоряжения
// otvet:=balert("Будете изменять приоритеты по распоряжениям?",{" Да "," Нет "},"W+/R,B/W*,N/BG")
 If MYNetUse(n_prior,.T.,5)
 Else
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say'   Файл PRIOR.dbf не доступен '
    @ 13,19 Say'   Невозможно обновить данные. '
    @ 14,19 Say'    Нажмите любую клавишу ...  '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return
 EndIf
// If otvet==1
//    Korr_prior("prior")
// EndIf
 my_box(5,7,20,72,B_DOUBLE+chr(32),"W+/W")
 @ 5,28 Say "  Идет обновление данных  "
 For i:=1 To Len(aPDO)
    If aPDO[i,1]=="bd02ki"
       Exit
    EndIf
 Next
 If MYNetUse(aPDO[i,2]+aPDO[i,1],.T.,5,)
 Else
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say'   Файл BD02KI.dbf не доступен '
    @ 13,19 Say'   Невозможно обновить данные. '
    @ 14,19 Say'    Нажмите любую клавишу ...  '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return
 EndIf
 If MYNetUse(n_raspor,.T.,5)
    my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
    Set Color To W+/B
    Select raspor
    @ 13,22 Say " Идет индексация базы данных RASPOR "
    Index On raspor->cex+raspor->chert+raspor->ps+raspor->vp+raspor->cp;
          To (n_raspor+".ntx")
 Else
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 13,19 Say'   Файл RASPOR.dbf не доступен '
    @ 13,19 Say'   Невозможно обновить данные. '
    @ 14,19 Say'    Нажмите любую клавишу ...  '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return
 EndIf
 Select prior
 Index On cex+ki To prior

 Rasp_bd02ki()    //формирование БД Raspor (распоряжений) от укомплектованности
                  //ежедневно при изменении ук-ти f_rasp.prg
 Close raspor
 Delete File (n_raspor+".ntx")
 Close prior
 Delete File prior.ntx
*/

//Обязательная индексация BD02KI (т.к. ее скидывают за прошлый день и
//следовательно дата БД и дата индексного файла равны и индекс не пересоздатся)
 my_box(5,7,20,72,B_DOUBLE+chr(32),"W+/W")
 @ 5,28 Say "  Идет обновление данных  "
 For i:=1 To Len(aPDO)
    If aPDO[i,1]=="bd02ki"
       Exit
    EndIf
 Next
 If MYNetUse(aPDO[i,2]+aPDO[i,1],.T.,5,)
 Else
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say'   Файл BD02KI.dbf не доступен '
    @ 13,19 Say'   Невозможно обновить данные. '
    @ 14,19 Say'    Нажмите любую клавишу ...  '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return
 EndIf
 my_box(12,18,15,45,B_DOUBLE+chr(32),"W+/B")
 @ 13,19 Say ' Создается индексный файл '
 Set Color To W+*/B
 @ 14,29 Say Upper(aPDO[i,1])
 Index On cex+chert+ps+vp+cp To (aPDO[i,2]+aPDO[i,1]) Unique
 Index On cex+chert+ps+vp+cp+pg+ki To (aPDO[i,2]+aPDO[i,1]+'2') 
 Index On cex+chert+ps+vp+cp+ki To (aPDO[i,2]+'bdki') 

//Ежедневное создание временных БД для 56 цеха(разнесение по участкам в
//зависимости от текущего ценника)
 //Блокируем bd02vc, BD02KI, BLANKS, BLANPH
 For i:=1 To Len(aPDO)
    If left(aPDO[i,1],6)=="bd02vc"
       Exit
    EndIf
 Next
 If MYNetUse(aPDO[i,2]+aPDO[i,1],.F.,5,.T.)
    Set Index To (aPDO[i,2]+aPDO[i,1])
 Else
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say' Файл '+aPDO[i,1]+'.dbf не доступен '
    @ 13,19 Say'   Невозможно обновить данные. '
    @ 14,19 Say'    Нажмите любую клавишу ...  '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return
 EndIf

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
    Return
 EndIf

 If MYNetUse(n_blanph,.T.,5)
 Else
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say'   Файл BLANPH.dbf не доступен '
    @ 13,19 Say'   Невозможно обновить данные. '
    @ 14,19 Say'    Нажмите любую клавишу ...  '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return
 EndIf

 For i:=1 To Len(aPDO_dopol)
  //если мы работаем с 56 цехом, то подготавливаем БД для пересоздания
  If (/*aPDO_dopol[i,1]=="bdki561".Or.aPDO_dopol[i,1]=="bdki562".Or.*/;
      aPDO_dopol[i,1]=="blank561".Or.aPDO_dopol[i,1]=="blank562".Or.;
      aPDO_dopol[i,1]=="blanp561".Or.aPDO_dopol[i,1]=="blanp562")

/* Masha       If aPDO_dopol[i,1]=="bdki561" .Or. aPDO_dopol[i,1]=="bdki562"
           //Select bd02ki

           db_name:=put_ki56 + aPDO_dopol[i,1]
           DBCreate(db_name,aBdki56)
        EndIf*/
        If aPDO_dopol[i,1]=="blank561" .Or. aPDO_dopol[i,1]=="blank562"
           Select blanks
        EndIf
        If aPDO_dopol[i,1]=="blanp561" .Or. aPDO_dopol[i,1]=="blanp562"
           Select blanph
        EndIf
        //по другому не работает, только через переменную
        db_name:=&(aPDO_dopol[i,2])

//        If aPDO_dopol[i,1]!="bdki561" .AND. aPDO_dopol[i,1]!="bdki562"
           Copy Structure To (db_name) // раньше было для всех
//        EndIf
//Masha
  EndIf
 Next

 //Формирование BLANK561 и BLANK562
 my_box(11,18,15,60,B_DOUBLE+chr(32),"W+/B")
 @ 12,19 Say'            Идет разбивка 56 цеха    '
 @ 13,19 Say'                 по участкам'

 If MYNetUse(n_blk561,.T.,5)
 Else
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say' Файл BLANK561.dbf не доступен '
    @ 13,19 Say'   Невозможно обновить данные. '
    @ 14,19 Say'    Нажмите любую клавишу ...  '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return
 EndIf
 If MYNetUse(n_blk562,.T.,5)
 Else
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say' Файл BLANK562.dbf не доступен '
    @ 13,19 Say'   Невозможно обновить данные. '
    @ 14,19 Say'    Нажмите любую клавишу ...  '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return
 EndIf
 Select blanks
 f:='(cex="56")'
 Set Filter To &f
 If GoToTop('cex')
    Set Filter To
 Else
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say'    В BLANKS.DBF нет 56 цеха  '
    @ 13,19 Say'   Невозможно обновить данные. '
    @ 14,19 Say'    Нажмите любую клавишу ...  '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return
 EndIf
 Do While blanks->cex=="56"
    If bd02vc->(dbSeek(blanks->cex+blanks->chert+blanks->ps))
       If bd02vc->uch="01"  //если участок 001, то относим к 56/1
          blank561->(dbAppend())
          blank561->cex:=blanks->cex
          blank561->chert:=blanks->chert
          blank561->ps:=blanks->ps
          blank561->vp:=blanks->vp
          blank561->cp:=blanks->cp
          blank561->num:=blanks->num
//          blank561->uch:=bd02vc->uch
          blank561->kv1:=blanks->kv1
          blank561->kv2:=blanks->kv2
          blank561->kv3:=blanks->kv3
          blank561->kv4:=blanks->kv4
          blank561->kv1_PL05:=blanks->kv1_PL05
          blank561->kv2_PL05:=blanks->kv2_PL05
          blank561->kv3_PL05:=blanks->kv3_PL05
          blank561->kv4_PL05:=blanks->kv4_PL05
          blank561->perevod:=blanks->perevod
          blank561->new_pos:=blanks->new_pos
          blank561->dobav:=blanks->dobav
          blank561->udal_date:=blanks->udal_date
          blank561->dobav:=blanks->dobav
          blank561->term:=blanks->term
          blank561->dopolnen:=blanks->dopolnen
          blank561->SIA:=blanks->SIA
          blank561->SIB:=blanks->SIB
       Else  //все остальные участки относим к 56/2
          blank562->(dbAppend())
          blank562->cex:=blanks->cex
          blank562->chert:=blanks->chert
          blank562->ps:=blanks->ps
          blank562->vp:=blanks->vp
          blank562->cp:=blanks->cp
          blank562->num:=blanks->num
//          blank562->uch:=bd02vc->uch
          blank562->kv1:=blanks->kv1
          blank562->kv2:=blanks->kv2
          blank562->kv3:=blanks->kv3
          blank562->kv4:=blanks->kv4
          blank562->kv1_PL05:=blanks->kv1_PL05
          blank562->kv2_PL05:=blanks->kv2_PL05
          blank562->kv3_PL05:=blanks->kv3_PL05
          blank562->kv4_PL05:=blanks->kv4_PL05
          blank562->perevod:=blanks->perevod
          blank562->new_pos:=blanks->new_pos
          blank562->dobav:=blanks->dobav
          blank562->term:=blanks->term
          blank562->udal_date:=blanks->udal_date
          blank562->dopolnen:=blanks->dopolnen
          blank562->SIA:=blanks->SIA
          blank562->SIB:=blanks->SIB
       EndIf
    Else  //все остальные позиции, которых нет в ценнике относим к 56/2
       blank562->(dbAppend())
       blank562->cex:=blanks->cex
       blank562->chert:=blanks->chert
       blank562->ps:=blanks->ps
       blank562->vp:=blanks->vp
       blank562->cp:=blanks->cp
       blank562->num:=blanks->num
//       blank562->uch:=bd02vc->uch
       blank562->kv1:=blanks->kv1
       blank562->kv2:=blanks->kv2
       blank562->kv3:=blanks->kv3
       blank562->kv4:=blanks->kv4
       blank562->kv1_PL05:=blanks->kv1_PL05
       blank562->kv2_PL05:=blanks->kv2_PL05
       blank562->kv3_PL05:=blanks->kv3_PL05
       blank562->kv4_PL05:=blanks->kv4_PL05
       blank562->perevod:=blanks->perevod
       blank562->new_pos:=blanks->new_pos
       blank562->dobav:=blanks->dobav
       blank562->udal_date:=blanks->udal_date
       blank562->term:=blanks->term
       blank562->dopolnen:=blanks->dopolnen
       blank562->SIA:=blanks->SIA
       blank562->SIB:=blanks->SIB
    EndIf
    blanks->(dbSkip())
 EndDo

 //Формирование BLANP561 и BLANP562
 If MYNetUse(n_blp561,.T.,5)
 Else
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say' Файл BLANP561.dbf не доступен '
    @ 13,19 Say'   Невозможно обновить данные. '
    @ 14,19 Say'    Нажмите любую клавишу ...  '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return
 EndIf
 If MYNetUse(n_blp562,.T.,5)
 Else
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say' Файл BLANP562.dbf не доступен '
    @ 13,19 Say'   Невозможно обновить данные. '
    @ 14,19 Say'    Нажмите любую клавишу ...  '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return
 EndIf
 Select blanph
 f:='(cex="56")'
 Set Filter To &f
 If GoToTop('cex')   //в BLANPH может не быть 56 цеха
    Set Filter To
    Do While blanph->cex=="56"
       If bd02vc->(dbSeek(blanph->cex+blanph->chert+blanph->ps))
          If bd02vc->uch="01"  //если участок 001, то относим к 56/1
             blanp561->(dbAppend())
             blanp561->cex:=blanph->cex
             blanp561->chert:=blanph->chert
             blanp561->ps:=blanph->ps
             blanp561->vp:=blanph->vp
             blanp561->cp:=blanph->cp
             blanp561->num:=blanph->num
             blanp561->kv1:=blanph->kv1
             blanp561->kv2:=blanph->kv2
             blanp561->kv3:=blanph->kv3
             blanp561->kv4:=blanph->kv4
             blanp561->kv1_PL05:=blanph->kv1_PL05
             blanp561->kv2_PL05:=blanph->kv2_PL05
             blanp561->kv3_PL05:=blanph->kv3_PL05
             blanp561->kv4_PL05:=blanph->kv4_PL05
             blanp561->perevod:=blanph->perevod
             blanp561->new_pos:=blanph->new_pos
             blanp561->dobav:=blanph->dobav
             blanp561->udal_date:=blanph->udal_date
             blanp561->term:=blanph->term
             blanp561->dopolnen:=blanph->dopolnen
             blanp561->SIA:=blanph->SIA
             blanp561->SIB:=blanph->SIB
          Else  //все остальные участки относим к 56/2
             blanp562->(dbAppend())
             blanp562->cex:=blanph->cex
             blanp562->chert:=blanph->chert
             blanp562->ps:=blanph->ps
             blanp562->vp:=blanph->vp
             blanp562->cp:=blanph->cp
             blanp562->num:=blanph->num
             blanp562->kv1:=blanph->kv1
             blanp562->kv2:=blanph->kv2
             blanp562->kv3:=blanph->kv3
             blanp562->kv4:=blanph->kv4
             blanp562->kv1_PL05:=blanph->kv1_PL05
             blanp562->kv2_PL05:=blanph->kv2_PL05
             blanp562->kv3_PL05:=blanph->kv3_PL05
             blanp562->kv4_PL05:=blanph->kv4_PL05
             blanp562->perevod:=blanph->perevod
             blanp562->new_pos:=blanph->new_pos
             blanp562->dobav:=blanph->dobav
             blanp562->udal_date:=blanph->udal_date
             blanp562->term:=blanph->term
             blanp562->dopolnen:=blanph->dopolnen
             blanp562->SIA:=blanph->SIA
             blanp562->SIB:=blanph->SIB
          EndIf
       Else  //все остальные позиции, к-рых нет в ценнике относим к 56/2
          blanp562->(dbAppend())
          blanp562->cex:=blanph->cex
          blanp562->chert:=blanph->chert
          blanp562->ps:=blanph->ps
          blanp562->vp:=blanph->vp
          blanp562->cp:=blanph->cp
          blanp562->num:=blanph->num
          blanp562->kv1:=blanph->kv1
          blanp562->kv2:=blanph->kv2
          blanp562->kv3:=blanph->kv3
          blanp562->kv4:=blanph->kv4
          blanp562->kv1_PL05:=blanph->kv1_PL05
          blanp562->kv2_PL05:=blanph->kv2_PL05
          blanp562->kv3_PL05:=blanph->kv3_PL05
          blanp562->kv4_PL05:=blanph->kv4_PL05
          blanp562->perevod:=blanph->perevod
          blanp562->new_pos:=blanph->new_pos
          blanp562->dobav:=blanph->dobav
          blanp562->udal_date:=blanph->udal_date
          blanp562->term:=blanph->term
          blanp562->dopolnen:=blanph->dopolnen
          blanp562->SIA:=blanph->SIA
          blanp562->SIB:=blanph->SIB
       EndIf
       blanph->(dbSkip())
    EndDo
 EndIf

 //Формирование BDKI561 и BDKI562 с участками и бригадами
/*Masha For i:=1 To Len(aPDO)
    If aPDO[i,1]=="ns05tn"
       Exit
    EndIf
 Next*/
/* If MYNetUse(aPDO[i,2]+aPDO[i,1],.T.,5)
    if FILE(aPDO[i,2]+"ns05cex.ntx")
       Set index to (aPDO[i,2])+"ns05cex.ntx"
    else
       index on cex+chert+ps to (aPDO[i,2])+"ns05cex.ntx"
    endif
 Else
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say' Файл ns05tn.dbf не доступен '
    @ 13,19 Say'   Невозможно обновить данные. '
    @ 14,19 Say'    Нажмите любую клавишу ...  '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return
 EndIf*/
/* If MYNetUse(n_bdki561,.T.,5)
 Else
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say'  Файл BDKI561.dbf не доступен '
    @ 13,19 Say'   Невозможно обновить данные. '
    @ 14,19 Say'    Нажмите любую клавишу ...  '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return
 EndIf*/
/* If MYNetUse(n_bdki562,.T.,5)
 Else
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say'  Файл BDKI562.dbf не доступен '
    @ 13,19 Say'   Невозможно обновить данные. '
    @ 14,19 Say'    Нажмите любую клавишу ...  '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return
 EndIf*/
/* Select bd02ki
 If bd02ki->(dbSeek("56"))
    Set Order To  //сбросить индексацию
 Else
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say'    В BD02KI.DBF нет 56 цеха  '
    @ 13,19 Say'   Невозможно обновить данные. '
    @ 14,19 Say'    Нажмите любую клавишу ...  '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return
 EndIf*/
/* Do While bd02ki->cex=="56"
    If bd02vc->(dbSeek(bd02ki->cex+bd02ki->chert+bd02ki->ps))
       If bd02vc->uch=1  //если участок 001, то относим к 56/1
          bdki561->(dbAppend())
          bdki561->cex:=bd02ki->cex
          bdki561->chert:=bd02ki->chert
          bdki561->ps:=bd02ki->ps
          bdki561->vp:=bd02ki->vp
          bdki561->cp:=bd02ki->cp
          bdki561->ki:=bd02ki->ki
          bdki561->pg:=bd02ki->pg  //
          bdki561->uch:=bd02vc->uch
          bdki561->bu:=bd02ki->bu
          bdki561->op:=bd02ki->op
          bdki561->k1:=bd02ki->k1
          bdki561->n2:=bd02ki->n2
          bdki561->k2:=bd02ki->k2
          bdki561->ksut:=bd02ki->ksut
          bdki561->nb:=bd02ki->nb
          bdki561->kb:=bd02ki->kb
          bdki561->ntek:=bd02ki->ntek
          bdki561->ktek:=bd02ki->ktek
          bdki561->nnmes:=bd02ki->nnmes
          bdki561->knmes:=bd02ki->knmes
          bdki561->vk:=bd02ki->vk
          bdki561->kort:=bd02ki->kort
          bdki561->korm:=bd02ki->korm
          bdki561->rasg:=bd02ki->rasg
          bdki561->niz:=bd02ki->niz
          bdki561->bs:=bd02ki->bs
          bdki561->SIA:=bd02ki->SIA
          bdki561->SIB:=bd02ki->SIB
          bdki561->SIC:=bd02ki->SIC
          bdki561->SID:=bd02ki->SID
          bdki561->SIE:=bd02ki->SIE
          bdki561->SIF:=bd02ki->SIF
          bdki561->SIG:=bd02ki->SIG
          bdki561->SIH:=bd02ki->SIH
          bdki561->SII:=bd02ki->SII
          bdki561->SIJ:=bd02ki->SIJ
          bdki561->SIK:=bd02ki->SIK
          bdki561->SIL:=bd02ki->SIL
          BrStr:=""
          if ns05tn->(dbSeek(bd02ki->cex+bd02ki->chert+bd02ki->ps))
           while ns05tn->cex+ns05tn->chert+ns05tn->ps ==;
                  bd02ki->cex+bd02ki->chert+bd02ki->ps
            if AT(ns05tn->br,BrStr)==0
             BrStr=BrStr+ns05tn->br
            else
             fl:=0
             for i=1 to LEN(BrStr) step 2
              if SubStr(BrStr,i,2)==ns05tn->br
               fl=1
              endif
             next
             if fl==0
              BrStr=BrStr+ns05tn->br
             endif
            endif
            ns05tn->(dbSkip())
           enddo
           bdki561->br:=BrStr
          endif
       Else  //все остальные участки относим к 56/2
          bdki562->(dbAppend())
          bdki562->cex:=bd02ki->cex
          bdki562->chert:=bd02ki->chert
          bdki562->ps:=bd02ki->ps
          bdki562->vp:=bd02ki->vp
          bdki562->cp:=bd02ki->cp
          bdki562->ki:=bd02ki->ki
          bdki561->pg:=bd02ki->pg  //
          bdki562->uch:=bd02vc->uch
          bdki562->bu:=bd02ki->bu
          bdki562->op:=bd02ki->op
          bdki562->k1:=bd02ki->k1
          bdki562->n2:=bd02ki->n2
          bdki562->k2:=bd02ki->k2
          bdki562->ksut:=bd02ki->ksut
          bdki562->nb:=bd02ki->nb
          bdki562->kb:=bd02ki->kb
          bdki562->ntek:=bd02ki->ntek
          bdki562->ktek:=bd02ki->ktek
          bdki562->nnmes:=bd02ki->nnmes
          bdki562->knmes:=bd02ki->knmes
          bdki562->vk:=bd02ki->vk
          bdki562->kort:=bd02ki->kort
          bdki562->korm:=bd02ki->korm
          bdki562->rasg:=bd02ki->rasg
          bdki562->niz:=bd02ki->niz
          bdki562->bs:=bd02ki->bs
          bdki562->SIA:=bd02ki->SIA
          bdki562->SIB:=bd02ki->SIB
          bdki562->SIC:=bd02ki->SIC
          bdki562->SID:=bd02ki->SID
          bdki562->SIE:=bd02ki->SIE
          bdki562->SIF:=bd02ki->SIF
          bdki562->SIG:=bd02ki->SIG
          bdki562->SIH:=bd02ki->SIH
          bdki562->SII:=bd02ki->SII
          bdki562->SIJ:=bd02ki->SIJ
          bdki562->SIK:=bd02ki->SIK
          bdki562->SIL:=bd02ki->SIL
          BrStr:=""
          if ns05tn->(dbSeek(bd02ki->cex+bd02ki->chert+bd02ki->ps))
           while ns05tn->cex+ns05tn->chert+ns05tn->ps ==;
                  bd02ki->cex+bd02ki->chert+bd02ki->ps
            if AT(ns05tn->br,BrStr)==0
             BrStr=BrStr+ns05tn->br
            else
             fl:=0
             for i=1 to LEN(BrStr) step 2
              if SubStr(BrStr,i,2)==ns05tn->br
               fl=1
              endif
             next
             if fl==0
              BrStr=BrStr+ns05tn->br
             endif
            endif
            ns05tn->(dbSkip())
           enddo
           bdki562->br:=BrStr
          endif
       EndIf
    Else  //все остальные позиции, к-рых нет в цеенике относим к 56/2
       bdki562->(dbAppend())
       bdki562->cex:=bd02ki->cex
       bdki562->chert:=bd02ki->chert
       bdki562->ps:=bd02ki->ps
       bdki562->vp:=bd02ki->vp
       bdki562->cp:=bd02ki->cp
       bdki562->ki:=bd02ki->ki
       bdki561->pg:=bd02ki->pg  //
       bdki562->uch:=bd02vc->uch
       bdki562->bu:=bd02ki->bu
       bdki562->op:=bd02ki->op
       bdki562->k1:=bd02ki->k1
       bdki562->n2:=bd02ki->n2
       bdki562->k2:=bd02ki->k2
       bdki562->ksut:=bd02ki->ksut
       bdki562->nb:=bd02ki->nb
       bdki562->kb:=bd02ki->kb
       bdki562->ntek:=bd02ki->ntek
       bdki562->ktek:=bd02ki->ktek
       bdki562->nnmes:=bd02ki->nnmes
       bdki562->knmes:=bd02ki->knmes
       bdki562->vk:=bd02ki->vk
       bdki562->kort:=bd02ki->kort
       bdki562->korm:=bd02ki->korm
       bdki562->rasg:=bd02ki->rasg
       bdki562->niz:=bd02ki->niz
       bdki562->bs:=bd02ki->bs
       bdki562->SIA:=bd02ki->SIA
       bdki562->SIB:=bd02ki->SIB
       bdki562->SIC:=bd02ki->SIC
       bdki562->SID:=bd02ki->SID
       bdki562->SIE:=bd02ki->SIE
       bdki562->SIF:=bd02ki->SIF
       bdki562->SIG:=bd02ki->SIG
       bdki562->SIH:=bd02ki->SIH
       bdki562->SII:=bd02ki->SII
       bdki562->SIJ:=bd02ki->SIJ
       bdki562->SIK:=bd02ki->SIK
       bdki562->SIL:=bd02ki->SIL
    EndIf
    bd02ki->(dbSkip())
 EndDo*/

 Close All
 For i:=1 To Len(aPDO_dopol)
  If aPDO_dopol[i,1]=="blank561".Or.aPDO_dopol[i,1]=="blank562"
     PutSi(&(aPDO_dopol[i,2])+".dbf",blanks_Si)
  EndIf
  If aPDO_dopol[i,1]=="blanp561".Or.aPDO_dopol[i,1]=="blanp562"
     PutSi(&(aPDO_dopol[i,2])+".dbf",blanph_Si)
  EndIf
/*  If aPDO_dopol[i,1]=="bdki561".Or.aPDO_dopol[i,1]=="bdki562"
     PutSi(&(aPDO_dopol[i,2])+".dbf",bd02ki_Si)
  EndIf*/
 Next

/* For i:=1 To Len(aPDO)
    If aPDO[i,1]=="ns05tn"
       Exit
    EndIf
 Next*/
// Delete File (aPDO[i,2])+"ns05cex.ntx"
 my_box(11,18,15,60,B_DOUBLE+chr(32),"GR+/B")
 @ 12,19 Say'    Обновление данных успешно завершено '
 @ 13,19 Say'          Нажмите любую клавишу ...     '
 InKey(0)
Return

/*Процедура накопления данных по накладным за каждый месяц из bd02nc в bd12tc*/
Procedure Adding()
Local n_bd12tc1,ex:=.T.,mes_arh,god_arh
 Set Color To W+/W
 @ 6,8 Clear To 19,71
 For i:=1 To Len(aPDO)
   If aPDO[i,1]=="bd02nc"
      Exit
   EndIf
 Next
 If MYNetUse(aPDO[i,2]+aPDO[i,1],.F.,5,.T.)
    n_bd12tc1=SubStr(n_bd12tc,1,Rat("\",n_bd12tc))+"bd12tc1"
    If !FileMN(n_bd12tc+".dbf",10)
       DBCreate(n_bd12tc,aBd12tc)
    EndIf
    If MYNetUse(n_bd12tc,.T.,5)
       my_box(11,21,14,51,B_DOUBLE+chr(32),"W+/B")
       @ 12,22 Say'  Идет обработка BD12TC.dbf  '
       //проверим не было ли уже накопления в bd12tc за накапливаемый месяц
       Do While !bd12tc->(Eof()) .And. ex
          If bd12tc->mes==SubStr(aPDO[i,4],4,2)  //месяц из getsi('bd02nc')
             ex:=.F.
          EndIf
          Skip Alias bd12tc
       EndDo
       If ex //т.е. в bd12tc данных за накапливаемый месяц(bd02nc) еще нет
          mes_arh=SubStr(aPDO[i,4],4,2)
          god_arh=SubStr(aPDO[i,4],7,2)
          Do While !bd02nc->(Eof())
             @ 13,31 Say bd02nc->(RecNo())
             bd12tc->(dbAppend())

             bd12tc->cex=bd02nc->cex
             bd12tc->chert=bd02nc->chert
             bd12tc->ps=bd02nc->ps
             bd12tc->vp=bd02nc->vp
             bd12tc->cp=bd02nc->cp
             bd12tc->poc=bd02nc->poc
             bd12tc->dd_nakl=bd02nc->dd_nakl
             bd12tc->mm_nakl=bd02nc->mm_nakl
             bd12tc->dd_vv=bd02nc->dd_vv
             bd12tc->mes=mes_arh//SubStr(aPDO[i,4],4,2)
             bd12tc->god=god_arh//SubStr(aPDO[i,4],7,2)
             bd12tc->np=bd02nc->np
             bd12tc->nnakl=bd02nc->nnakl
             bd12tc->ki=bd02nc->ki
             bd12tc->pr=bd02nc->pr
             bd12tc->kol=bd02nc->kol
             bd12tc->sp=bd02nc->sp
             bd12tc->nras=bd02nc->nras
             bd12tc->vd=bd02nc->vd

             Skip Alias bd02nc
          EndDo
          my_box(11,21,14,51,B_DOUBLE+chr(32),"W+/B")
          Set Color To W+*/B
          @ 12,22 Say' Идет сортировка BD12TC.dbf '
          Sort To (n_bd12tc1) On Cex /A, Chert /A, Ps /A, Vp /A, Cp /A,;
                                    God /A, Mes /A, Dd_vv /A, Nnakl /A
          Close bd12tc
          Delete File (n_bd12tc+".dbf")
          Rename (n_bd12tc1+".dbf") To (n_bd12tc+".dbf")
          /*Макарова */
          Close bd02nc
//          aeval(directory(aPDO[i,2]+"ncpk*.dbf"),{ | afile | iif(afile[F_NAME]="ncpk"+god_arh+mes_arh,,ferase(aPDO[i,2]+afile[F_NAME])) })
          Delete File (aPDO[i,2]+"bd02nc.dbf")
          if fileMN(aPDO[i,2]+"bd02nc.dbf",10)
            alert(aPDO[i,2]+"BD02NC.dbf не удалился после накопления BD12TC.dbf !!!")
            SetColor("w/n")
            Clear Screen
            Close All
            QUIT
          endif
       Else
          my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
          @ 12,19 Say' Накопление BD12TC.dbf уже было'
          @ 14,19 Say'    Нажмите любую клавишу ...  '
          InKey(0)
       EndIf
    Else
       my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
       @ 12,19 Say' Файл BD12TC.dbf не доступен '
       @ 13,19 Say' Невозможно обновить данные. '
       @ 14,19 Say'  Нажмите любую клавишу ...  '
       InKey(0)
       Restore Screen
       Clear Screen
       Close All
       Return .F.
    EndIf
 Else
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say' Файл BD02NC.dbf не доступен '
    @ 13,19 Say' Невозможно обновить данные. '
    @ 14,19 Say'  Нажмите любую клавишу ...  '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return .F.
 EndIf
 Close All
Return .T.


/*Процедура накопления данных по накладным за каждый месяц из bd04rs в bd12rs*/
Procedure Adding_RS()
Local n_bd12rs1,ex:=.T.
 Set Color To W+/W
 @ 6,8 Clear To 19,71
 For i:=1 To Len(aPDO)
   If aPDO[i,1]=="bd04rs"
      Exit
   EndIf
 Next
 If MYNetUse(aPDO[i,2]+aPDO[i,1],.F.,5,.T.)
    n_bd12rs1=SubStr(n_bd12rs,1,Rat("\",n_bd12rs))+"bd12rs1"
    If !FileMN(n_bd12rs+".dbf",10)
       DBCreate(n_bd12rs,aBd12rs)
    EndIf
    If MYNetUse(n_bd12rs,.T.,5)
       my_box(11,21,14,51,B_DOUBLE+chr(32),"W+/B")
       @ 12,22 Say'  Идет обработка BD12RS.dbf  '
       //проверим не было ли уже накопления в bd12rs за накапливаемый месяц
       Do While !bd12rs->(Eof()) .And. ex
          If SubStr(DToC(bd12rs->data),4,2)==SubStr(aPDO[i,4],4,2) .and. ;
            SubStr(DToC(bd12rs->data),7,2)==SubStr(aPDO[i,4],7,2)//месяц и год из getsi('bd04rs')
             ex:=.F.
          EndIf
          bd12rs->(dbSkip())
       EndDo
       If ex //т.е. в bd12rs данных за накапливаемый месяц(bd04rs) еще нет
          Do While !bd04rs->(Eof())
             @ 13,31 Say bd04rs->(RecNo())
             bd12rs->(dbAppend())

             bd12rs->sklad=bd04rs->sklad
             bd12rs->cp=bd04rs->cp
             bd12rs->chert=bd04rs->chert
             bd12rs->ps=bd04rs->ps
             bd12rs->vp=bd04rs->vp
             bd12rs->vr=bd04rs->vr
             bd12rs->ndok=bd04rs->ndok
             bd12rs->npb=bd04rs->npb
             bd12rs->np=bd04rs->np
             bd12rs->ki=bd04rs->ki
             bd12rs->data=bd04rs->data
             bd12rs->kol=bd04rs->kol
             bd12rs->nmash=bd04rs->nmash

             bd04rs->(dbSkip())
          EndDo
          my_box(11,21,14,51,B_DOUBLE+chr(32),"W+/B")
          Set Color To W+*/B
          @ 12,22 Say' Идет сортировка BD12rs.dbf '
          Sort To (n_bd12rs1) On Sklad /A, Chert /A, PS /A, VP /A, CP /A, Data /A, Vr /A, NDok /A, KI /A, NMash /A
          Close bd12rs
          Delete File (n_bd12rs+".dbf")
          Rename (n_bd12rs1+".dbf") To (n_bd12rs+".dbf")
       Else
          my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
          @ 12,19 Say' Накопление BD12RS.dbf уже было'
          @ 14,19 Say'    Нажмите любую клавишу ...  '
          InKey(0)
       EndIf
    Else
       my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
       @ 12,19 Say' Файл BD12RS.dbf не доступен '
       @ 13,19 Say' Невозможно обновить данные. '
       @ 14,19 Say'  Нажмите любую клавишу ...  '
       InKey(0)
       Restore Screen
       Clear Screen
       Close All
       Return .F.
    EndIf
 Else
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say' Файл BD04RS.dbf не доступен '
    @ 13,19 Say' Невозможно обновить данные. '
    @ 14,19 Say'  Нажмите любую клавишу ...  '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return .F.
 EndIf
 Close All
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
              {'VP','C',1,0},{'CP','C',2,0},{'Num','C',7,0},;
              {'KV1','N',9,0},{'KV2','N',9,0},{'KV3','N',9,0},{'KV4','N',9,0},;
              {'KV1_PL05','N',9,0},{'KV2_PL05','N',9,0},{'KV3_PL05','N',9,0},{'KV4_PL05','N',9,0},;
              {'PEREVOD','N',1,0},{'NEW_POS','N',1,0},{'DOBAV','N',1,0},;
              {'UDAL_DATE','C',4,0},{'TERM','C',1,0},{'Dopolnen','M',0,0},{'SIA','C',0,0},{'SIB','C',0,0}}
Local aBlanph:={{'CEX','C',2,0},{'CHERT','C',13,0},{'PS','C',1,0},;
              {'VP','C',1,0},{'CP','C',2,0},{'Num','C',7,0},;
              {'KV1','N',9,0},{'KV2','N',9,0},{'KV3','N',9,0},{'KV4','N',9,0},;
              {'KV1_PL05','N',9,0},{'KV2_PL05','N',9,0},{'KV3_PL05','N',9,0},{'KV4_PL05','N',9,0},;
              {'PEREVOD','N',1,0},{'NEW_POS','N',1,0},{'DOBAV','N',1,0},;
              {'UDAL_DATE','C',4,0},{'TERM','C',1,0},{'Dopolnen','M',0,0},;
              {'SIA','C',0,0},{'SIB','C',0,0}}

//кол-во на изделие на первый(2,3,4) квартал=Kol и кол-во на план от ук-ти=Kol_PL05
Local aBlaniz:={{'Num','C',7,0},{'KI','C',4,0},{'Name_iz','C',8,0},;
                {'Kol1','N',9,0},{'Kol2','N',9,0},{'Kol3','N',9,0},{'Kol4','N',9,0},;
                {'Kol1_PL05','N',9,0},{'Kol2_PL05','N',9,0},{'Kol3_PL05','N',9,0},{'Kol4_PL05','N',9,0}}
Local aBlantm:={{'Num','C',7,0},{'TM','C',24,0},{'PR','N',1,0}}

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
              {'PEREVOD','N',1,0},{'NEW_POS','N',1,0},{'UDAL_DATE','C',4,0},{'Dopolnen','M',0,0},;
              {'SIA','C',0,0}}

Static entre:=0
 If entre==0
    Set Color To N/BG
    Clear Screen
    entre++
    my_box(5,7,20,72,B_DOUBLE+chr(32),"W+/W")
    @ 5,28 Say "  Идет обновление данных  "
 EndIf
 Do case
  case variant==1
   If MYNetUse(n_pl03ps,.F.,5,.T.)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл PL03PS.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If MYNetUse(n_pl03iz,.F.,5,.T.)
      Index On pl03iz->ki To (n_pl03iz+".ntx")
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл PL03IZ.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If MYNetUse(n_pl05ps,.F.,5,.T.)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл PL05PS.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If MYNetUse(n_pl05iz,.F.,5,.T.)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл PL05IZ.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
/*Создаем структуру БД blanks, к-рая содержит ключ и связана с БД blanksiz*/
/* по полю Num; blanksiz содержит код изд.,наим., кол-во на план по чертежу*/
/*и по кол-во по изд. по кварталам*/
   If !FileMN(n_blan+".dbf",10)
      DBCreate(n_blan,aBlan)
   EndIf
   If MYNetUse(n_blan,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл BLANKS.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf

   If !FileMN(n_blaniz+".dbf",10)
      DBCreate(n_blaniz,aBlaniz)
   EndIf
   FileCopy((n_blaniz+".dbf"),(kar_path+"temp\old_bliz.dbf")) //сохраняем пред.значения
   //кол-ва на изд. для того чтобы правильно определить добавки
   //и записать кол-ва по КИ введенным и снятым в одном и том же квартале
   nErr:=ErrorCode(.T.)
   If nErr!=0
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Ошибка копирования файла-'+Str(nErr,2)
      @ 14,19 Say' Нажмите любую клавишу ...  '
      Inkey(0)
      Return .F.
   EndIf
   If MYNetUse(kar_path+"temp\old_bliz.dbf",.T.,5)
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
   If MYNetUse(n_blaniz,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл BLANKSIZ.dbf не доступен'
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf

   If !FileMN(n_blanm+".dbf",10)
      DBCreate(n_blanm,aBlanm)
   EndIf
   FileCopy((n_blanm+".dbf"),(kar_path+"temp\old_blm.dbf")) //сохраняем пред.значения
   //кол-ва на изд. для того чтобы правильно определить добавки
   //и записать кол-ва по КИ введенным и снятым в одном и том же квартале
   nErr:=ErrorCode(.T.)
   If nErr!=0
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Ошибка копирования файла-'+Str(nErr,2)
      @ 14,19 Say' Нажмите любую клавишу ...  '
      Inkey(0)
      Return .F.
   EndIf
   If MYNetUse(kar_path+"temp\old_blm.dbf",.T.,5)
      my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
      Set Color To W+*/B
      @ 13,22 Say "Идет индексация базы данных BLANKSM "
      Index On Num+KI To (kar_path+"temp\old_blm.ntx")
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл OLD_BLM.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If MYNetUse(n_blanm,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл BLANKSM.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf

   If !FileMN(n_blantm+".dbf",10)
      DBCreate(n_blantm,aBlantm)
   EndIf
   If MYNetUse(n_blantm,.T.,5)
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
   If MYNetUse(n_bdkitm,.T.,5)
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
   If !FileMN(n_blanph+".dbf",10)
      DBCreate(n_blanph,aBlanph)
   EndIf
   If MYNetUse(n_blanph,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл BLANPH.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf

   If !FileMN(n_blphiz+".dbf",10)
      DBCreate(n_blphiz,aBlaniz)
   EndIf
   If MYNetUse(n_blphiz,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл BLANPHIZ.dbf не доступен'
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf

   If !FileMN(n_blphm+".dbf",10)
      DBCreate(n_blphm,aBlanm)
   EndIf
   If MYNetUse(n_blphm,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл BLANPHM.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf

   If !FileMN(n_blphtm+".dbf",10)
      DBCreate(n_blphtm,aBlantm)
   EndIf
   If MYNetUse(n_blphtm,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл BLANPHTM.dbf не доступен'
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf

   If MYNetUse(n_bd02ph,.T.,5)
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

   If !FileMN(n_blan_s+".dbf",10)
      DBCreate(n_blan_s,aBlan)
   EndIf
   If MYNetUse(n_blan_s,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл BLAN_S.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If !FileMN(n_blaniz_s+".dbf",10)
      DBCreate(n_blaniz_s,aBlaniz)
   EndIf
   If MYNetUse(n_blaniz_s,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл BLANIZ_S.dbf не доступен'
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If !FileMN(n_blanm_s+".dbf",10)
      DBCreate(n_blanm_s,aBlanm)
   EndIf
   If MYNetUse(n_blanm_s,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл BLANM_S.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf

  case variant==2 /*для формирования преобразованных чертежей*/
   If MYNetUse(n_bd02ph,.T.,5)
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
   If MYNetUse(n_blan,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл BLANKS.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If MYNetUse(n_blaniz,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл BLANKSIZ.dbf не доступен'
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If MYNetUse(n_blanm,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл BLANKSM.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If MYNetUse(n_blantm,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл BLANKSTM.dbf не доступен'
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
/*Создаем БД blanph,blanphiz,blanphtm,blanphm содержащие данные
по преобразованным чертежам(чертежи плана преобразуются в чертежи накладных)*/
   If !FileMN(n_blanph+".dbf",10)
      DBCreate(n_blanph,aBlanph)
   EndIf
   If MYNetUse(n_blanph,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл BLANPH.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If !FileMN(n_blphiz+".dbf",10)
      DBCreate(n_blphiz,aBlaniz)
   EndIf
   If MYNetUse(n_blphiz,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл BLANPHIZ.dbf не доступен'
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If !FileMN(n_blphm+".dbf",10)
      DBCreate(n_blphm,aBlanm)
   EndIf
   If MYNetUse(n_blphm,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл BLANPHM.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If !FileMN(n_blphtm+".dbf",10)
      DBCreate(n_blphtm,aBlantm)
   EndIf
   If MYNetUse(n_blphtm,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл BLANPHTM.dbf не доступен'
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
  case variant==3
/*   If MYNetUse(n_raspor,.T.,5) //28.11.06 убрано
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл RASPOR.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If MYNetUse(n_prior,.T.,5)
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
   If MYNetUse(aPDO[i,2]+aPDO[i,1],.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл BD02KI.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
*/
   If MYNetUse(n_blan,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл BLANKS.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If MYNetUse(n_blaniz,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл BLANKSIZ.dbf не доступен'
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If MYNetUse(n_blanph,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл BLANPH.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If MYNetUse(n_blphiz,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'Файл BLANPHIZ.dbf не доступен'
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
//карта для складов сбыта
   If !FileMN(n_sklad+".dbf",10)
      DBCreate(n_sklad,askl)
   EndIf
   If MYNetUse(n_sklad,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл SKLAD.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
   If !FileMN(n_sklad_s+".dbf",10)
      DBCreate(n_sklad_s,askl)
   EndIf
   If MYNetUse(n_sklad_s,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл SKLAD_S.dbf не доступен'
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
   EndIf
 EndCase
Return .T.
//--------------------------------------------------------------------------
Static Procedure CopBdki()
//Local pathKi, pathKiy
Local j, i, nErr,flag_copy
//Local
private pathki,pathkiy,pathki04,pathki04y,pathki98,pathki98y
aCop:={{"bd02kiy","pathKiy"},{"bd02ki","pathKi"},{"bdki04y","pathKi04y"},{"bd02ki04","pathKi04"},{"bdki98y","pathKi98y"},{"bd02ki98","pathKi98"}}

 set date format "dd/mm/yy"
 Close All

  If !FileMN(path_base+"bases.dbf",10)
      my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
      @ 12,19 Say'        Файл BASES.dbf         '
      @ 13,19 Say'           не найден.          '
      @ 14,19 Say'    Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
  EndIf
  If !MYNetUse(path_base+"bases.dbf",.F.,5,.T.)
      my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
      @ 12,19 Say'       Файл BASES.dbf          '
      @ 13,19 Say'          не доступен.         '
      @ 14,19 Say'    Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
  EndIf
  Set Index To (path_base+"bases.ntx")
  //поиск пути для bd02ki
  If !(bases->(dbSeek("bd02ki.dbf")))
      my_box(11,18,15,55,B_DOUBLE+chr(32),"W+/R")
      @ 12,19 Say' Файл BD02KI.DBF в BASES.dbf   '
      @ 13,19 Say'          не найден.           '
      @ 14,19 Say'    Нажмите любую клавишу ...  '
      InKey(0)
      Restore Screen
      Clear Screen
      Close All
      Return .F.
  EndIf
  //pathKi:=AllTrim(bases->path) //файл в H:\2
  for j=1 to len(aCop)
    if aCop[j,1]=="bd02ki"
      &(aCop[j,2]):=AllTrim(bases->path)
      exit
    endif
  next
  //поиск пути для bd02ki04
  If !(bases->(dbSeek("bd02ki04.dbf")))
      my_box(11,18,15,55,B_DOUBLE+chr(32),"W+/R")
      @ 12,19 Say' Файл BD02KI04.DBF в BASES.dbf   '
      @ 13,19 Say'          не найден. '
      @ 14,19 Say'    Нажмите любую клавишу ...  '
      InKey(0)
      Restore Screen
      Clear Screen
      Close All
      Return .F.
  EndIf
  for j=1 to len(aCop)
    if aCop[j,1]=="bd02ki04"
      &(aCop[j,2]):=AllTrim(bases->path)
      exit
    endif
  next
  //поиск пути для bd02ki98
  If !(bases->(dbSeek("bd02ki98.dbf")))
      my_box(11,18,15,55,B_DOUBLE+chr(32),"W+/R")
      @ 12,19 Say' Файл BD02KI98.DBF в BASES.dbf '
      @ 13,19 Say'          не найден.           '
      @ 14,19 Say'    Нажмите любую клавишу ...  '
      InKey(0)
      Restore Screen
      Clear Screen
      Close All
      Return .F.
  EndIf
  for j=1 to len(aCop)
    if aCop[j,1]=="bd02ki98"
      &(aCop[j,2]):=AllTrim(bases->path)
      exit
    endif
  next
  Close bases

  If !FileMN(path_base+"basespdo.dbf",10)
      my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
      @ 12,19 Say'      Файл BASESPDO.dbf        '
      @ 13,19 Say'           не найден.          '
      @ 14,19 Say'    Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
  EndIf
  If !MYNetUse(path_base+"basespdo.dbf",.F.,5,.T.)
      my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
      @ 12,19 Say'      Файл BASESPDO.dbf        '
      @ 13,19 Say'          не доступен.         '
      @ 14,19 Say'    Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
  EndIf
  Set Index To (path_base+"basespdo.ntx")
  //поиск пути для bd02ki в basespdo
  If !(basespdo->(dbSeek("bd02ki.dbf")))
      my_box(11,18,15,55,B_DOUBLE+chr(32),"W+/R")
      @ 12,19 Say'Файл BD02KI.DBF в BASESPDO.dbf'
      @ 13,19 Say'          не найден. '
      @ 14,19 Say'    Нажмите любую клавишу ...  '
      InKey(0)
      Restore Screen
      Clear Screen
      Close All
      Return .F.
  EndIf
  //pathKiy:=AllTrim(basespdo->path) //путь к файлу bd02kiY
  for j=1 to len(aCop)
    if aCop[j,1]=="bd02kiy"
      &(aCop[j,2]):=AllTrim(basespdo->path)
      exit
    endif
  next
  //поиск пути для bd02ki04 в basespdo
  If !(basespdo->(dbSeek("bd02ki04.dbf")))
      my_box(11,18,15,55,B_DOUBLE+chr(32),"W+/R")
      @ 12,19 Say'Файл BD02KI04.DBF в BASESPDO.dbf'
      @ 13,19 Say'          не найден. '
      @ 14,19 Say'    Нажмите любую клавишу ...  '
      InKey(0)
      Restore Screen
      Clear Screen
      Close All
      Return .F.
  EndIf
  for j=1 to len(aCop)
    if aCop[j,1]=="bdki04y"
      &(aCop[j,2]):=AllTrim(basespdo->path)
      exit
    endif
  next
  //поиск пути для bd02ki98 в basespdo
  If !(basespdo->(dbSeek("bd02ki98.dbf")))
      my_box(11,18,15,55,B_DOUBLE+chr(32),"W+/R")
      @ 12,19 Say'Файл BD02KI98.DBF в BASESPDO.dbf'
      @ 13,19 Say'          не найден. '
      @ 14,19 Say'    Нажмите любую клавишу ...  '
      InKey(0)
      Restore Screen
      Clear Screen
      Close All
      Return .F.
  EndIf
  for j=1 to len(aCop)
    if aCop[j,1]=="bdki98y"
      &(aCop[j,2]):=AllTrim(basespdo->path)
      exit
    endif
  next
  Close basespdo

  //если искомый файл НЕ найден в H:\2 (архив создаваемый при завершении работы)
  If !FileMN(pathKi+"bd02ki.dbf",5)
      my_box(11,18,15,55,B_DOUBLE+chr(32),"W+/R")
      @ 12,19 Say'Файл '+pathKi+'BD02KI.dbf '
      @ 13,19 Say'           не найден.          '
      @ 14,19 Say'    Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
  EndIf
  If !FileMN(pathKi04+"bd02ki04.dbf",5)
      my_box(11,18,15,55,B_DOUBLE+chr(32),"W+/R")
      @ 12,19 Say'Файл '+pathKi04+'BD02KI04.dbf '
      @ 13,19 Say'           не найден.          '
      @ 14,19 Say'    Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
  EndIf
  If !FileMN(pathKi98+"bd02ki98.dbf",5)
      my_box(11,18,15,55,B_DOUBLE+chr(32),"W+/R")
      @ 12,19 Say'Файл '+pathKi98+'BD02KI98.dbf '
      @ 13,19 Say'           не найден.          '
      @ 14,19 Say'    Нажмите любую клавишу ...  '
      InKey(0)
      Return .F.
  EndIf
  //в H:\2 есть файлы bd02ki, bd02ki98, bd02ki04 - пытаемся заблокировать в монопольном режиме все файлы массива aCop
  //если файлов bd02kiY, bdki98Y, bdki04Y нет, то их блокировать соответственно не требуется
  For i=1 to len(aCop)
      vr:=&(aCop[i,2])+aCop[i,1]+".dbf"
      If ((aCop[i,1]=="bd02kiy").Or.(aCop[i,1]=="bdki04y").Or.(aCop[i,1]=="bdki98y")) .and. !fileMN(vr,10)
        loop
      EndIf
      If !MYNetUse(vr,.T.,5)
          my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
          @ 12,19 Say'Файл '+UpPer(vr)+'.DBF'
          @ 13,19 Say'         не доступен.          '
          @ 14,19 Say'    Нажмите любую клавишу ...  '
          InKey(0)
          Restore Screen
          Clear All
          Close All
          Return .F.
      EndIf
  Next
  Close all
  //если файлы массива aCop удалось заблокировать в монопольном режиме, то
  //при необходимости копируем соот-щий файл (bd02ki) из H:\2 в (bd02kiY)
  my_box(5,7,20,72,B_DOUBLE+chr(32),"W+/W")
  @ 5,22 Say' Копирование данных с сервера ОАСУП '
  //bd02kiY
  flag_copy:=.T.
  if fileMN(pathKiy+"bd02kiy.dbf",10)
    si:=GetSi(pathKiy+"bd02kiy.dbf")
    If  substr(si,7,8)=dtoc(date())
        flag_copy:=.F.
    EndIf
  EndIf
  If flag_copy
     FileCopy(pathKi+"bd02ki.dbf",pathKiy+"bd02kiy.dbf")
     nErr:=ErrorCode(.T.)
     If nErr!=0
        my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
        @ 12,19 Say'    Ошибка копирования файла   '
        @ 13,19 Say'     BD02KI.dbf - '+Str(nErr,2)
        Inkey(0)
        Return .F.
     EndIf
     Si:=GetSi(pathKiy+"bd02kiy.dbf")
     PutSi(pathKiy+"bd02kiy.dbf",SubStr(Si,1,6)+DToC(date())+SubStr(Si,15,len(Si)-14))
  EndIf

  //bdki04Y
  flag_copy:=.T.
  if fileMN(pathKi04y+"bdki04y.dbf",10)
     si:=GetSi(pathKi04y+"bdki04y.dbf")
     If substr(si,7,8)=dtoc(date())
        flag_copy:=.F.
     EndIf
  EndIf
  If flag_copy
     FileCopy(pathKi04+"bd02ki04.dbf",pathKi04y+"bdki04y.dbf")
     nErr:=ErrorCode(.T.)
     If nErr!=0
        my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
        @ 12,19 Say'    Ошибка копирования файла   '
        @ 13,19 Say'     BD02KI04.dbf - '+Str(nErr,2)
        Inkey(0)
        Return .F.
     EndIf
     Si:=GetSi(pathKi04y+"bdki04y.dbf")
     PutSi(pathKi04y+"bdki04y.dbf",SubStr(Si,1,6)+DToC(date())+SubStr(Si,15,len(Si)-14))
  EndIf

  //bdki98Y
  flag_copy:=.T.
  if fileMN(pathKi98y+"bdki98y.dbf",10)
     si:=GetSi(pathKi98y+"bdki98y.dbf")
     If substr(si,7,8)=dtoc(date())
        flag_copy:=.F.
     EndIf
  EndIf
  If flag_copy
     FileCopy(pathKi98+"bd02ki98.dbf",pathKi98y+"bdki98y.dbf")
     nErr:=ErrorCode(.T.)
     If nErr!=0
        my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
        @ 12,19 Say'    Ошибка копирования файла   '
        @ 13,19 Say'     BD02KI98.dbf - '+Str(nErr,2)
        Inkey(0)
        Return .F.
     EndIf
     Si:=GetSi(pathKi98y+"bdki98y.dbf")
     PutSi(pathKi98y+"bdki98y.dbf",SubStr(Si,1,6)+DToC(date())+SubStr(Si,15,len(Si)-14))
  EndIf
  Restore Screen
  Clear Screen
  Close All
Return .T.
//--------------------------------------------------------------------------
Procedure poiskCen(dir_cen,nam_cen)
Local aDir, vPath,vPathFull,vName,Si_cen,vFind, aFile
Private vGod,vMes
  vFind:=at('*',dir_cen)     
  if vFind=0
      return .F.
  endif       
  vFind:=Iif(vFind=0,Len(dir_cen),vFind-1)
  vPath:=left(dir_cen,vFind)     
  aDir:=Directory(vPath+'20??','D')
  if len(aDir)=0 
    return .F.
  endif
  vGod:="2011"
  aeval(aDir,{|aFile|provNameDir(aFile[F_NAME])}) 
  if vGod="2011"
    return .F.
  endif
  vFind:=at('.',nam_cen)
  vFind:=Iif(vFind=0,Len(nam_cen),vFind-1)
  vName:=left(nam_cen,vFind)
  do while vGod>"2011" 
    vPath:=strtran(dir_cen,"*",vGod)        
    aDir:=Directory(vPath+vName+'??.dbf')
    if len(aDir)=0
      vGod:=ntoc(val(vGod)-1,10,4,'0')
      loop
    endif                                          
    vMes:='00'
    // vFind - здесь последний поиск 
    // длины основного имени ценника (например bd02nz )
    aeval(aDir,{|aFile|provNameFile(aFile[F_NAME],vFind,vPath)})  
    if vMes>'00'
      exit
    endif
    vGod:=ntoc(val(vGod)-1,10,4,'0')
  enddo
  if vGod="2011"
    return .F.
  endif 
  aASU[i,1]:=nam_cen+vMes
  aASU[i,2]:=vPath
return .T.
procedure provNameDir(namDir)
  if provCifr(namDir,4) .and. (namDir>vGod) 
    vGod:=namDir
  endif
return .T.
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
procedure provCifr(vStr,vLen)
Local k,strCifr:="0123456789"
  if len(alltrim(vStr))<>vLen 
    return .F.
  endif
  for k:=1 to vLen
    if !substr(vStr,k,1)$strCifr
      return .F.
    endif
  next
return .T.