/*�������஢��� � ���箬 /n*/
#include "box.ch"
#include "Fileio.ch"
#include "setcurs.ch"

/*����� � �⥪�� ��� ��࠭���� � ����⠭������� �� � ����� ��ਡ�⮢*/
/*����� � ������⥪��*/
Static vid_stk:="", dbf_stk:=""

/*�㭪�� ��࠭�� ��⠭���� Set Cursor, ⥪�騥 ��ப� � �⮫��� �����
� ⥪���� ��⠭���� 梥�. ������� ������� ������⥪�:
ᨬ��� 1- �ଠ �����, ᨬ��� 2-⥪. ��ப� �����, ᨬ��� 3- ⥪. �⮫���
�����, ᨬ��� 4-23 - ⥪. ��⠭���� 梥�*/
Function vstk_push
  &&��ꥤ������ ��ਡ�⮢ � ���������� � ��砫� vid_stk
 vid_stk=Chr(Set(_SET_CURSOR))+Chr(Row())+Chr(Col())+;
         Pad (SetColor(),20)+vid_stk   /*20-�᫮ ᨬ����� ��� ������� 梥�*/
Return Nil

/*�㭪�� �뭨���� �������� �� ������⥪� � ����⠭�������� ����� ��ਡ���*/
Function vstk_pop
 If Len(vid_stk)>0
    SetCursor(Asc(SubStr(vid_stk,1,1)))
    @ Asc(SubStr(vid_stk,2,1)), Asc(SubStr(vid_stk,3,1)) Say ""
    SetColor(Substr(vid_stk,4,20))
    /*���४�� �⥪�*/
    vid_stk=SubStr(vid_stk,24) /*23 ���� �������� ���� ������� vid_stk*/
 EndIf
Return Nil

/*����� � �⥪�� ��� ��
������� ������� �⥪�: ᨬ��� 1- ᥫ���� ������, ᨬ��� 2-����� �����
ᨬ��� 9- ������ ������, ᨬ��� 10-SoftSeek, ᨬ��� 11- Deleted*/

/*�㭪�� ����頥� ������� � �⥪ ��.*/
Function dstk_push
 dbf_stk=Chr(Select())+Str(RecNo(),7)+Chr(IndexOrd())+;
          Iif(Set(_SET_SOFTSEEK),"T","F")+Iif(Set(_SET_DELETED),"T","F")+;
          dbf_stk
Return Nil

/*�㭪�� �뭨���� ������� �� �⥪� �� � ����⠭�������� �� ��ਡ���*/
Function dstk_pop
 If Len(dbf_stk)>0
    Set(_SET_SOFTSEEK,SubStr(dbf_stk,10,1)+"T")
    Set(_SET_DELETED,SubStr(dbf_stk,11,1)+"T")
    Select(Asc(SubStr(dbf_stk,1,1)))
    Go Val(SubStr(dbf_stk,2,7))
    Set Order To Asc(SubStr(dbf_stk,9,1))
    dbf_stk=SubStr(dbf_stk,12) /*11 ���� �������� ���� ������� �⥪� */
 EndIf
Return Nil

/*�㭪樨 ���᪠*/
Function Qsear_ar(ar,res) /*������ ���� � ���ᨢ�*/
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

*** �������� ����� ������ � .DBF ***
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
/*GetSi �� count.prg,
�� ⠬ � ��� ��� fclose() � ��᫥ ⮣� ��� �㭪�� ��ࠡ�⠥� ����� ������
�� (use �� new)*/
Function MYGetSi ( Name, Buffer )
// �㭪�� ࠡ�⠥� � 䠩���� DBF ᯥ��ଠ�,
// �ᯮ��㥬� �� ��।�� ������ �� BANK-�ଠ� �� ��� �� ����.
// �।�����祭� ��� �����祭�� �㦥���� ���ଠ樨
// ���⠭��� � ��������� DBF-䠩��.
// ��ଠ� MYGetSi( Name, Buffer ) --> NIL
//    Name - ��ப� ᨬ�����, ��� 䠩�� �� ���ண� ������ ��.���;
//    Buffer - ���� ��६�����, �㤠 ������;
// �.�. ��।����� � ���� �����뢭�� ��ப� :
// XXXXXX - ��� ���ᨢ� �� �� ���
// dd/mm/yy - ��� ��� ᮧ����� �� �� ���
// PPP - ����� ��������� ���ᨢ�
// DDD - ����� ����᫥���饩 ���ଠ樨
// SSSSSSS...S - ᮡ�⢥��� �㦥���� ���ଠ�� ���ᨢ�
//                              ( ��⠢ � ��� �� ��������� ��।�������
//                               �⢥��⢥��� �ணࠬ���⮬ )
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

// ���� ��ࢮ�� ����, ᮤ�ঠ饣� ����� ����� ���ଠ樨
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

Function Rep_open(name,lopenmode,nsec)  /*�������� ������ ������ 䠩��*/
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
    If alert("�� ���� �������஢��� "+SubStr(name,Rat("\",name)+1);
             +", �த������ ?", {" �� ", " ��� "})==1
       restart=.T.
    Else
       restart=.F.
    EndIf
 EndDo
Return .F.

/*�������� �����᭮�� 䠩�� � �஢�મ� �� �, �����筮 �� ���� �� ��᪥
��ࠬ����: ��� ��, ��� ����(�� ���஬� ����������� ��),��� ᮧ���������
�����᭮�� 䠩��.
name_db - �� �����, index_name - �� ����� ���� (�᫨ ����)*/
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
    @ 14,17 Say' ��������� ������� 䠩� - '+Upper(names)
    Index On &name_f To (index_name)
*    Set Color To
*    Clear Screen
/* Else
    my_box(10,20,14,59,B_DOUBLE+chr(32),"W+/R")
    @ 11,21 Say'         ��� ����� �� ����� '
    @ 12,21 Say'  ���������� ᮧ���� ������� 䠩�  '
    @ 13,21 Say'         ������ ���� �������...'
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

Function Index_Size(name_db,name_i) /*����塞 ࠧ��� �����᭮�� 䠩��*/
Local a,b,n_key,n_rec,n_i            /*��ࠬ����: ��� ��, ��� ���祢��� ����*/
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
 @ t+1,l+2,b+1,r+1 BOX "�"
 Set Color To (s_color)
 @ t,l,b,r BOX ramka
Return

/*��⥢� �㭪樨*/
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
    If alert("�� ���� �������஢��� "+SubStr(cdatabase,Rat("\",cdatabase)+1);
             +", �த������ ?", {" �� ", " ��� "})==1
       restart=.T.
    Else
       restart=.F.
    EndIf
 EndDo
Return .F.
//����⨥ �� � ����ᮬ
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
    If alert("�� ���� �������஢��� "+SubStr(cdatabase,Rat("\",cdatabase)+1);
             +", �த������ ?", {" �� ", " ��� "})==1
       restart=.T.
    Else
       restart=.F.
    EndIf
 EndDo
Return .F.
