/*компилировать с ключом /n*/
#include "box.ch"
#include "Fileio.ch"
#include "setcurs.ch"

/*Работа со стеком для сохранения и восстановления БД и видео атрибутов*/
/*Работа с видеостеком*/
Static vid_stk:="", dbf_stk:=""

/*Функция сохраняет установку Set Cursor, текущие строку и столбец курсора
и текущую установку цвета. структура элемента видеостека:
символ 1- форма курсора, символ 2-тек. строка курсора, символ 3- тек. столбец
курсора, символ 4-23 - тек. установка цвета*/
Function vstk_push
  &&объединение атрибутов и добавление в начало vid_stk
 vid_stk=Chr(Set(_SET_CURSOR))+Chr(Row())+Chr(Col())+;
         Pad (SetColor(),20)+vid_stk   /*20-число символов для задания цвета*/
Return Nil

/*функция вынимает элементы из видеостека и восстанавливает видео атрибуты*/
Function vstk_pop
 If Len(vid_stk)>0
    SetCursor(Asc(SubStr(vid_stk,1,1)))
    @ Asc(SubStr(vid_stk,2,1)), Asc(SubStr(vid_stk,3,1)) Say ""
    SetColor(Substr(vid_stk,4,20))
    /*коррекция стека*/
    vid_stk=SubStr(vid_stk,24) /*23 байта занимает один элемент vid_stk*/
 EndIf
Return Nil

/*Работа со стеком для БД
Структура элемента стека: символ 1- селектор области, символ 2-номер записи
символ 9- главный индекс, символ 10-SoftSeek, символ 11- Deleted*/

/*Функция помещает элемент в стек БД.*/
Function dstk_push
 dbf_stk=Chr(Select())+Str(RecNo(),7)+Chr(IndexOrd())+;
          Iif(Set(_SET_SOFTSEEK),"T","F")+Iif(Set(_SET_DELETED),"T","F")+;
          dbf_stk
Return Nil

/*Функция вынимает элемент из стека БД и восстанавливает ее атрибуты*/
Function dstk_pop
 If Len(dbf_stk)>0
    Set(_SET_SOFTSEEK,SubStr(dbf_stk,10,1)+"T")
    Set(_SET_DELETED,SubStr(dbf_stk,11,1)+"T")
    Select(Asc(SubStr(dbf_stk,1,1)))
    Go Val(SubStr(dbf_stk,2,7))
    Set Order To Asc(SubStr(dbf_stk,9,1))
    dbf_stk=SubStr(dbf_stk,12) /*11 байт занимает один элемент стека */
 EndIf
Return Nil

/*Функции поиска*/
Function Qsear_ar(ar,res) /*двоичный поиск в массиве*/
 Local low,high,mid
 low=1
 If res<ar[low]
    Return 0
 EndIf
 high=Len(ar)
 If res>ar[high]
    Return 0
 EndIf
 mid=Int((low+high)/2)
 Do While ar[mid]!=res .And. low<=high
    Do Case
     case res>ar[mid]
      low=mid+1
     case res<ar[mid]
      high=mid-1
     case res==ar[mid]
      Return (mid)
    EndCase
    mid=Int((low+high)/2)
 EndDo
 If ar[mid]!=res
    mid=0
 EndIf
Return (mid)

*** ДВОИЧНЫЙ ПОИСК ЗАПИСИ В .DBF ***
FUNCTION QSEARCH(Name,Pole,Low,High)
local Mid
If Empty(Low)
   Low = 1
EndIf
If Empty(High)
   High = lastrec()
EndIf
Do While Low <= High
  Mid = int((Low + High) / 2)
  Go Mid
  CC = &Name
  Do Case
    case Pole < CC
         High = Mid - 1
    case Pole > CC
         Low = Mid + 1
    otherwise
         rec_num=RecNo()
         return .T.
  EndCase
EndDo
Return .F.

/*****************************/
/*GetSi из count.prg,
но там в ней нет fclose() и после того как функция отработает нельзя открыть
БД (use БД new)*/
Function MYGetSi ( Name, Buffer )
// Функция работает с файлами DBF спецформата,
// используемым при передаче данных из BANK-формата ЕС ЭВМ на ПЭВМ.
// Предназначена для извлечения служебной информации
// спрятанной в заголовке DBF-файла.
// Формат MYGetSi( Name, Buffer ) --> NIL
//    Name - строка символов, имя файла из которого прочитать служ.инф;
//    Buffer - адрес переменной, куда прочитать;
// С.И. передается в виде непрерывной строки :
// XXXXXX - имя массива на ЕС ЭВМ
// dd/mm/yy - дата его создания на ЕС ЭВМ
// PPP - номер поколения массива
// DDD - длина нижеследующей информации
// SSSSSSS...S - собственно служебная информация массива
//                              ( состав и смысл ее полностью определяются
//                               ответственным программистом )
LOCAL nHandle, MyBuff, nFields, i, sHeader
nHandle = fopen( Name, FO_READ )
If nhandle==-1
   If !rep_open(name,FO_READ,5)
      Return .F.
   EndIf
EndIf

MyBuff = space(32)
FREAD( nHandle, @MyBuff, 32 )
sHeader = BIN2W(SUBSTR(MyBuff, 9, 2)) - 1               //Header Size
FSEEK( nHandle, 0 )
MyBuff = space(sHeader)
if (FREAD(nHandle,@MyBuff,sHeader)) <> sHeader
      set color to *gr+/r
      ? " Base header corrupted ! "
      quit
endif

// Поиск первого поля, содержащего первую порцию информации
i = 0
do while (substr(MyBuff, i+1, 3) != "SIA") .and. (i < sHeader)
        i += 32
enddo

if substr(MyBuff, i+1, 3) == "SIA"
        Buffer= substr(MyBuff, i+ 5, 6 ) +    ;
                substr(MyBuff, i+19, 14)
        i += 32
        do while i < sHeader
        Buffer += substr(MyBuff, i+ 5, 7 ) +    ;
                  substr(MyBuff, i+14, 3 ) +    ;
                  substr(MyBuff, i+19, 14)
                i += 32
        enddo
        Buffer = substr(Buffer, 1, 6+8+3+3+VAL(substr(buffer,18,3)) )
else
        Buffer = ""
endif
Fclose(nHandle)
return NIL

Function Rep_open(name,lopenmode,nsec)  /*повторять попытку открытия файла*/
 Local forever, restart, wait_time
 restart=.T.
 forever=(nsec=0)
 Do While restart
    wait_time=nsec
    Do While (forever .Or. wait_time>0)
       nHandle = fopen( Name, lopenmode )
       If nHandle==-1
       Else
          Return .T.
       EndIf
       Inkey(1)
       wait_time--
    EndDo
    If alert("Не могу заблокировать "+SubStr(name,Rat("\",name)+1);
             +", продолжить ?", {" Да ", " Нет "})==1
       restart=.T.
    Else
       restart=.F.
    EndIf
 EndDo
Return .F.

/*Создание индексного файла с проверкой на то, достаточно ли места на диске
Параметры: имя БД, имя поля(по которому индексируется БД),имя создаваемого
индексного файла.
name_db - это алиас, index_name - это полный путь (если надо)*/
Function Create_Index(name_db,name_f,index_name)
Local names
&& If Index_Size(name_db, name_f)<=Diskspace()
    my_box(12,15,16,54,B_DOUBLE+chr(32),"W+/B")
    Set Color To W+*/B
    If Rat("\",index_name)!=0
       names=SubStr(index_name,Rat("\",index_name)+1)
    Else
       names=index_name
    EndIf
    @ 14,17 Say' Создается индексный файл - '+Upper(names)
    Index On &name_f To (index_name)
*    Set Color To
*    Clear Screen
/* Else
    my_box(10,20,14,59,B_DOUBLE+chr(32),"W+/R")
    @ 11,21 Say'         НЕТ МЕСТА НА ДИСКЕ '
    @ 12,21 Say'  Невозможно создать индексный файл  '
    @ 13,21 Say'         Нажмите любую клавишу...'
    Inkey(0)
    Set Color To
    Set Cursor On
    Restore Screen
    Close All
    Clear All
    Clear Gets
    Clear Screen
    Quit
 EndIf*/
Return

Function Index_Size(name_db,name_i) /*вычисляем размер индексного файла*/
Local a,b,n_key,n_rec,n_i            /*параметры: имя БД, имя ключевого поля*/
  n_i=ValType((name_db)->(&name_i))
  Do Case
    case n_i="N"
      n_key=Len(Str((name_db)->(&name_i)))
    case n_i="D"
      n_key=Len(DtoS((name_db)->(&name_i)))
    case n_i="C"
      n_key=Len(((name_db)->(&name_i)))
  EndCase
  n_rec=(name_db)->(RecCount())
  a=860/(n_key+8)   /*1024-164=860*/
  If At(".",Str(a))!=0
     a=Int(a)+1
  EndIf
  b=n_rec/a
  If At(".",Str(b))!=0
     b=Int(b)+1
  EndIf
  i_size=(b+2)*1024
Return i_size

Function my_box(t,l,b,r,ramka,s_color)
 Set Cursor Off
 Set Color To N/N
 @ t+1,l+2,b+1,r+1 BOX "▒"
 Set Color To (s_color)
 @ t,l,b,r BOX ramka
Return

/*Сетевые функции*/
Function MYNetUse(cdatabase,lopenmode,nsec,Ro)
 Local forever, restart, wait_time
 restart=.T.
 forever=(nsec=0)
 Do While restart
    wait_time=nsec
    Do While (forever .Or. wait_time>0)
       If lopenmode
          Use (cdatabase) Exclusive New
       Else
          if (Ro <> nil) .and. Ro
             Use (cdatabase) Shared New ReadOnly
          else
             Use (cdatabase) Shared New
          end 
       EndIf
       If !NetErr()
          Return .T.
       EndIf
       Inkey(1)
       wait_time--
    EndDo
    If alert("Не могу заблокировать "+SubStr(cdatabase,Rat("\",cdatabase)+1);
             +", продолжить ?", {" Да ", " Нет "})==1
       restart=.T.
    Else
       restart=.F.
    EndIf
 EndDo
Return .F.
//открытие БД с алиасом
Function AlNetUse(cdatabase,lopenmode,nsec,al1)
 Local forever, restart, wait_time
 restart=.T.
 forever=(nsec=0)
 Do While restart
    wait_time=nsec
    Do While (forever .Or. wait_time>0)
       If lopenmode
          If al1#nil
             Use (cdatabase) Exclusive New alias &(al1)
          Else
             Use (cdatabase) Exclusive New
          End 
       Else
          If al1#nil
             Use (cdatabase) Shared New alias &(al1)
          Else
             Use (cdatabase) Shared New
          End
       EndIf
       If !NetErr()
          Return .T.
       EndIf
       Inkey(1)
       wait_time--
    EndDo
    If alert("Не могу заблокировать "+SubStr(cdatabase,Rat("\",cdatabase)+1);
             +", продолжить ?", {" Да ", " Нет "})==1
       restart=.T.
    Else
       restart=.F.
    EndIf
 EndDo
Return .F.
