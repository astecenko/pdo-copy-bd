                              /*2004 �.*/
           /*�ணࠬ�� ���४�஢�� ����窨 ������ ��諮�� ��ਮ��*/
                          /*��⥢�� ��ਠ��*/
///////////////////
////////////////// �� ����-�� ����窨 ������ ��諮�� ��ਮ�� ���������� ⮫쪮 �� blanks(-iz,-tm,-m), blan_s(-m_s,-iz_s)
/////////////////�� ����ନ������ ��ꥤ.��⥦�, ᪫��, �ᯮ�.
#include "box.ch"
#include "inkey.ch"
#include "achoice.ch"
#include "directry.ch"
Proc kkart(path_bas)
Local vr

Set Procedure To f_kart

/*���ᨢ aPDO ᮤ�ন�:
1-��� ��, ��ॡ��뢠���� � �ࢥ� ����� �� �ࢥ� ���
2-���� � �� �� �ࢥ� ��� (������ �� h:\basespdo.dbf)
3-����� ��������� �� �� �ࢥ� ��� (GetSi())
4 - ��� �����
5 - �㦥���� ���ଠ�� (��� 3-� ���� ����� �㦥���� ���ଠ樨)*/
aPDO:={{'pl03psk1','','','',''},{'pl03izk1','','','',''},;
       {'pl03psk2','','','',''},{'pl03izk2','','','',''},;
       {'pl03psk3','','','',''},{'pl03izk3','','','',''},;
       {'pl03psk4','','','',''},{'pl03izk4','','','',''}}
/*��������. ���ᨢ, �-�� ᮤ�ন�:
1-��� ��, ����� ����� �ਭ����� ���⨥ � ����ନ஢���� �� �� �ࢥ� ���
2-��� ��६�����, � �-ன �㤥� ᮤ�ঠ���� ����+��� ��*/
aPDO_dopol:={{'blanks','n_blan'},{'blanksiz','n_blaniz'},{'blankstm','n_blantm'},{'blanksm','n_blanm'},;
     {'blan_s','n_blan_s'},{'blaniz_s','n_blaniz_s'},{'blanm_s','n_blanm_s'},;
     {'bdki561','n_bdki561'},{'bdki562','n_bdki562'},;
     {'blank561','n_blk561'},{'blank562','n_blk562'},{'bdkitm','n_bdkitm'}}
//�� �६���� �� - ࠧ������ 56 �� �� ���⪠�
//blan_s, blaniz_s - �� ᮤ�ঠ� ����樨 �������� � ���� � ����� ����⠫�

Private n_pl03ps,n_pl03iz,cSi:="",blanks_Si:="",blanph_Si:="",pl03ps_Si:="",bd02ph_Si:="",;
        f_notadd:=0,f_notcopy:=0,f_new:=0,num_kv:="",;
        f_rasp_plan:=0,arh_path:="",kar_path:="",;
        /*Masha*/put_ki56:="",put_bl56:="",tek_kv
        //Masha - ���� � bdki561 � � blank561
        //���� � ��娢�, ���� � ��⠫��� KARTA
        //f_rasp_plan=0, �᫨ �� ����ନ஢뢠�� �� �ᯮ�殮��� �� �����
   //�⮡� �뤥���� �� ����� (�������) ������ 䫠� f_new
   //f_new==0, �᫨ � blanks �ନ����� ���� ����⠫
   //f_new==1, �᫨ ���ᮧ������ �� �� ����⠫, �.� �᫨ ���ᮧ������
              //����窨 � १���� ������� � ����� � ⮬ �� ����⠫�
   //num_kv - ����� ����⠫� �� pl03ps(���),����祭���� ��᫥ ����������
   /*f_notadd - 䫠� ������ ��� ⮣�, �⮡� �� ����������� � ����� ���� �����
     �� ������� ��諮�� ����. �᫨ �� ᮧ��� ��娢, � f_notadd:=1*/
   /*f_notcopy - 䫠� ������ ��� ᫥���饩 ���樨: �᫨ bd02ki �� ��
     ���� ���, � pl03ps 㦥 �� ���� ���, � f_notcopy:=1. � �⮬ ��砥
     pl03ps, pl03iz � bd02ph �� ���������� � �ࢥ� ��� �� �� ��� ����
     �� �㤥� ᮧ��� ��娢 �� ���� ���.*/
//Masha
//������� bdkitm - �� �� ����� bd02ki
aBdkitm:={{'CEX','C',2,0},{'CHERT','C',13,0},{'PS','C',1,0},;
          {'VP','C',1,0},{'CP','C',2,0},{'KI','C',4,0},{'TM','C',24,0}}
//Masha
Public path_base //���� BasesPdo
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

/*����*/

m_end:=.T.
Do While m_end
   /*��⠥� ����� �� basespdo.dbf (�ࢥ� ���)*/
  if !File(vr:=path_base+"BASESPDO.dbf") .or. !File(vr:=path_base+"BASESPDO.ntx")
    alert("��� 䠩�� "+vr)
    Restore Screen
    Clear All
    Close All
    Quit
  endif
  If AlNetUse(path_base+"basespdo.dbf",.F.,5)
      Set Index To (path_base+"basespdo.ntx")
  Else
      my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
      @ 12,19 Say'      ���� BASESPDO.DBF     '
      @ 13,19 Say'           �� ����㯥�.  '
      @ 14,19 Say'    ������ ���� ������� ...  '
      InKey(0)
      Restore Screen
      Clear All
      Close All
      Quit
  EndIf

   If (basespdo->(dbSeek("blanks.dbf")))
      kar_path:=AllTrim(basespdo->path) //�� ࠡ�稩 ��⠫�� ���� ���
      If !DirChangeMN(kar_path+"temp",10)
        //ᮧ���� ��४��� (temp) ���
        If DirMake(kar_path+"temp")!=0
          alert("    �訡�� ᮧ����� ��⠫��� "+Upper(kar_path+"temp\"))
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
      @ 12,19 Say'          ���� '+Upper(aPDO[i,1])
      @ 13,19 Say' �  BASESPDO.dbf  �� ������    '
      @ 14,19 Say'    ������ ���� ������� ...  '
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
      @ 12,19 Say'          ���� '+Upper(aPDO[i,1])
      @ 13,19 Say' �  BASESPDO.dbf  �� ������    '
      @ 14,19 Say'    ������ ���� ������� ...  '
      InKey(0)
      Restore Screen
      Clear All
      Close All
      Quit
   EndIf

   /*����祭�� ����+���+".dbf" ��� ��, ����� ����� ����ନ஢뢠���� � ���*/
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
        @ 12,19 Say'          ���� '+Upper(aPDO_dopol[i,1])
        @ 13,19 Say' �  BASESPDO.dbf  �� ������    '
        @ 14,19 Say'    ������ ���� ������� ...  '
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
   @ 7,28 Say '���४�஢�� ��������:'
   @ 8,27 Say '�������������������������'
   Set Wrap On
   Set Message to 24 Center
   @ 10,27 Prompt "  ������ 1-�� ����⠫�   "
   @ 12,27 Prompt "  ������ 2-�� ����⠫�   "
   @ 14,27 Prompt "  ������ 3-�� ����⠫�   "
   @ 16,27 Prompt "    ����� ࠡ���         "
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
   /********��� ����஢�� ��⠢��� ��ࠡ��� sch_200*********/
   //� sch_200 ���뢠���� �� ������, ���⮬� �� �맮�� ��楤��� ���� ������� �� ������ ��
   If m_end  //��ࠫ� ��ࠡ���, � �� ����� ࠡ���
      Close All
      sch_200(path_base)

      my_box(11,18,15,60,B_DOUBLE+chr(32),"GR+/B")
      @ 12,19 Say'    ���������� ������ �ᯥ譮 �����襭� '
      @ 13,19 Say'          ������ ���� ������� ...     '
      InKey(0)
   EndIf
EndDo
/*******************************************************/
SetColor(OldColor)
SetBlink(old_b)
Close All
Clear All
alert("��᫥ ���४�஢�� ����室��� �������� �������!!!")
Clear Screen
@ maxrow()-2,2 Say'    ��ࢨ� ����� ��� "���"����".  '
Set Cursor On

************************************************************
Static Func KorrKart()
 /*�������� �� ��������� PL03 � ����室������ ����ନ஢���� ����祪*/
 //���뢠�� �㦥���� ���-�� �� blanks (�ࢥ� ���)
 blanks_Si:=GetSi(n_blan+".dbf")
 num_kv:=tek_kv

 //blanks ����� ���४�஢��� ⮫쪮 ���� ����⠫�� ⥪�饣� ����
 If  Substr(blanks_si,7,1)<=num_kv       //��. blanks �ࠢ������ � ���४��㥬� ����⠫��
     my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
     @ 12,19 Say'       ����  '+num_kv+'-�� ����⠫�'
     @ 13,19 Say'        �� ���� ���         '
     @ 14,19 Say'    ������ ���� ������� ...  '
     InKey(0)
     Restore Screen
     Clear All
     Close All
     Quit
 EndIf

 //���뢠�� �㦥���� ���-�� �� pl03ps
 //��।��塞 ���� � pl03pskx �� pl03ps basespdo->arch
 n_pl03ps:=SubStr(n_pl03ps,1,At('*',n_pl03ps)-1)+"2"+PadL(SubStr(blanks_si,9,2),3,'0')+SubStr(n_pl03ps,At('*',n_pl03ps)+1,Len(n_pl03ps)-At('*',n_pl03ps))+"pl03psk"+num_kv
 pl03ps_Si:=GetSi(n_pl03ps+".dbf")

 n_pl03iz:=SubStr(n_pl03iz,1,At('*',n_pl03iz)-1)+"2"+PadL(SubStr(blanks_si,9,2),3,'0')+SubStr(n_pl03iz,At('*',n_pl03iz)+1,Len(n_pl03iz)-At('*',n_pl03iz))+"pl03izk"+num_kv
 pl03iz_Si:=GetSi(n_pl03iz+".dbf")
 //
 If Substr(pl03ps_Si,30,2) # Substr(blanks_si,9,2) //ࠧ�� ���� ⠪��� ���� �� ������, �� �� ��直� ��砩 ��⠢��
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say'        ����  '+"PL03PSK"+num_kv
    @ 13,19 Say'        �� ���� ���         '
    @ 14,19 Say'    ������ ���� ������� ...  '
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
 f_rasp_plan:=1    //�ନ஢��� �ᯮ�殮��� �� �����
 FormBlank()       &&�ନ஢���� �� blanks (iz,tm) (����� ���)

//�����뢠�� � blanks � bd02ph ����� �㦥���� ���-��
//����஢�. 27.09.12 ���塞 � ���. ����� ⥪�饣� ����⠫� �� -1, 
// �⮡ ��⮬ ��諠 ���४�஢�� �� ����������
 blanks_Si:=Stuff(blanks_Si,15,3,Ntoc(Val(Substr(blanks_Si,15,3))-1,10,3,'0'))
 PutSi(n_blan+".dbf",blanks_Si)

 my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
 @ 13,22 Say "  ���⠢����� �1 ��� �ᯮ�殮��� "
 RKol()

 Close All

 If MYNetUse(n_blan,.T.,5)
    //��易⥫쭠� �������� Blanks.dbf - ᮧ����� chertks.ntx. �.�. ������ �������ਨ � ��� blanks.dbf ���������
    Select blanks
    Index On chert To (SubStr(n_blan,1,Rat('\',n_blan))+'chertks.ntx')
    Set Index To
    blanks->(dbgoto(1))
 Else
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say'   ���� BLANKS.dbf �� ����㯥� '
    @ 13,19 Say'   ���������� �������� �����. '
    @ 14,19 Say'    ������ ���� ������� ...  '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return .F.
 EndIf
Return .T.

/*�� ���������� ������ �뤠�� ᮮ�饭�� �
���� ���������� �������஢��� �� ��
�����頥� .T. �᫨ �� �� �������஢��� 㤠筮, ���� .F.*/

Procedure New_Data(variant)
//���-�� �� ����⠫ �� �����: cex+chert+ps+vp+cp,
//perevod==1, �᫨ cex+chert ��ॢ������ � cex+chertn �� �ࠢ�筨�� bd02ph
//new_pos - ����� ��������� ������, �⬥砥� �᫨ � ����� ����� �����
//  ��⥦, �-�� �� �뫮 � ��諮� ����� ��� �� �⮬� ��⥦� ��������� ��
//  (�� - ��)
//dobav - ����砥� ������� � ����� ⥪.����⠫�

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

//���-�� �� ������� �� ����(2,3,4) ����⠫
Local aBlaniz:={{'Num','C',7,0},{'KI','C',4,0},{'Name_iz','C',8,0},;
                {'Kol1','N',9,0},{'Kol2','N',9,0},{'Kol3','N',9,0},;
                {'Kol4','N',9,0}}
Local aBlantm:={{'Num','C',7,0},{'TM','C',24,0}}
//���-�� �� ���� �� ������� �� ����栬 ����⠫� KolMXY, ��� X- ����� ����⠫�, Y-����� ����� � ����⠫�
Local aBlanm:={{'Num','C',7,0},{'KI','C',4,0},;
                {'KolM11','N',9,0},{'KolM12','N',9,0},{'KolM13','N',9,0},;
                {'KolM21','N',9,0},{'KolM22','N',9,0},{'KolM23','N',9,0},;
                {'KolM31','N',9,0},{'KolM32','N',9,0},{'KolM33','N',9,0},;
                {'KolM41','N',9,0},{'KolM42','N',9,0},{'KolM43','N',9,0}}

//���� ��� ᪫���� ���
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
    @ 5,28 Say "  ���� ���������� ������ �� "+num_kv+" ����⠫..."
 EndIf
 Do case
  case variant==1
   FileCopy((n_PL03PS+".dbf"),(kar_path+"temp\PL03PS.dbf")) //��࠭塞 �।.���祭��
   nErr:=ErrorCode(.T.)
   If nErr!=0
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' �訡�� ����஢���� 䠩��   '
      @ 14,19 Say' ������ ���� ������� ...  '
      Inkey(0)
      Return .F.
   EndIf
   If AlNetUse(kar_path+"temp\PL03PS.dbf",.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' ���� PL03PSK'+num_kv+'.dbf �� ����㯥� '
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf

   FileCopy((n_PL03iz+".dbf"),(kar_path+"temp\PL03IZ.dbf")) //��࠭塞 �।.���祭��
   nErr:=ErrorCode(.T.)
   If nErr!=0
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' �訡�� ����஢���� 䠩��   '
      @ 14,19 Say' ������ ���� ������� ...  '
      Inkey(0)
      Return .F.
   EndIf
   If AlNetUse(kar_path+"temp\PL03IZ.dbf",.T.,5)
      Index On KI To (kar_path+"temp\PL03IZ.ntx")
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' ���� PL03IZK'+num_kv+'i.dbf �� ����㯥� '
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf
/*������� �������� �� blanks, �-�� ᮤ�ন� ���� � �易�� � �� blanksiz*/
/* �� ���� Num; blanksiz ᮤ�ন� ��� ���.,����., ���-�� �� ���� �� ��⥦�*/
/*� �� ���-�� �� ���. �� ����⠫��*/
   If AlNetUse(n_blan,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' ���� BLANKS.dbf �� ����㯥� '
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf
   FileCopy((n_blaniz+".dbf"),(kar_path+"temp\old_bliz.dbf")) //��࠭塞 �।.���祭��
   //���-�� �� ���. ��� ⮣� �⮡� �ࠢ��쭮 ��।����� �������
   //� ������� ���-�� �� �� �������� � ���� � ����� � ⮬ �� ����⠫�
   nErr:=ErrorCode(.T.)
   If nErr!=0
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' �訡�� ����஢���� 䠩��   '
      @ 14,19 Say' ������ ���� ������� ...  '
      Inkey(0)
      Return .F.
   EndIf
   If AlNetUse(kar_path+"temp\old_bliz.dbf",.T.,5)
      my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
      Set Color To W+*/B
      @ 13,22 Say "���� �������� ���� ������ BLANKSIZ"
      Index On Num+KI To (kar_path+"temp\old_bliz.ntx")
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'���� OLD_BLIZ.dbf �� ����㯥�'
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf
   If AlNetUse(n_blaniz,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'���� BLANKSIZ.dbf �� ����㯥�'
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf

   FileCopy((n_blanm+".dbf"),(kar_path+"temp\old_blm.dbf")) //��࠭塞 �।.���祭��
   //���-�� �� ���. ��� ⮣� �⮡� �ࠢ��쭮 ��।����� �������
   //� ������� ���-�� �� �� �������� � ���� � ����� � ⮬ �� ����⠫�
   nErr:=ErrorCode(.T.)
   If nErr!=0
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' �訡�� ����஢���� 䠩��   '
      @ 14,19 Say' ������ ���� ������� ...  '
      Inkey(0)
      Return .F.
   EndIf
   If AlNetUse(kar_path+"temp\old_blm.dbf",.T.,5)
      my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
      Set Color To W+*/B
      @ 13,22 Say "���� �������� ���� ������ BLANKSM "
      Index On Num+KI To (kar_path+"temp\old_blm.ntx")
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' ���� OLD_BLM.dbf �� ����㯥�'
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf
   If AlNetUse(n_blanm,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' ���� BLANKSM.dbf �� ����㯥�'
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf

   If !File(n_blantm+".dbf")
      DBCreate(n_blantm,aBlantm)
   EndIf
   If AlNetUse(n_blantm,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' ���� BLANKSTM.dbf �� ����㯥� '
      @ 14,19 Say'    ������ ���� ������� ...  '
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
      @ 13,19 Say' ���� BDKITM.dbf �� ����㯥� '
      @ 14,19 Say'    ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf
//Masha

/*������� �� blanph,blanphiz,blanphtm ᮤ�ঠ騥 ����� ��
�८�ࠧ������ ��⥦��*/
   /*If AlNetUse(n_blanph,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' ���� BLANPH.dbf �� ����㯥� '
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf
   If !File(n_blphiz+".dbf")
      DBCreate(n_blphiz,aBlaniz)
   EndIf
   If AlNetUse(n_blphiz,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'���� BLANPHIZ.dbf �� ����㯥�'
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf
   If AlNetUse(n_bd02ph,.T.,5)
      Create_index("bd02ph","cex+chertn",n_bd02ph)
      Set Color To W+/W
      @ 12,9 Clear To 18,60
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' ���� BD02PH.dbf �� ����㯥� '
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf*/

   If !File(n_blan_s+".dbf")
      DBCreate(n_blan_s,aBlan)
   EndIf
   If AlNetUse(n_blan_s,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' ���� BLAN_S.dbf �� ����㯥� '
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf
   If !File(n_blaniz_s+".dbf")
      DBCreate(n_blaniz_s,aBlaniz)
   EndIf
   If AlNetUse(n_blaniz_s,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'���� BLANIZ_S.dbf �� ����㯥�'
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf
   If !File(n_blanm_s+".dbf")
      DBCreate(n_blanm_s,aBlanm)
   EndIf
   If AlNetUse(n_blanm_s,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' ���� BLANM_S.dbf �� ����㯥�'
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf

  case variant==2 /*��� �ନ஢���� �८�ࠧ������� ��⥦��*/
   If AlNetUse(n_bd02ph,.T.,5)
      Create_index("bd02ph","cex+chertn",n_bd02ph)
      Set Color To W+/W
      @ 12,9 Clear To 18,60
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' ���� BD02PH.dbf �� ����㯥� '
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf
   If AlNetUse(n_blan,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' ���� BLANKS.dbf �� ����㯥� '
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf
   If AlNetUse(n_blaniz,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'���� BLANKSIZ.dbf �� ����㯥�'
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf
   If AlNetUse(n_blantm,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'���� BLANKSTM.dbf �� ����㯥�'
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf
/*������� �� blanph,blanphiz,blanphtm ᮤ�ঠ騥 �����
�� �८�ࠧ������ ��⥦��(��⥦� ����� �८�ࠧ����� � ��⥦� ���������)*/
   If !File(n_blanph+".dbf")
      DBCreate(n_blanph,aBlanph)
   EndIf
   If AlNetUse(n_blanph,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' ���� BLANPH.dbf �� ����㯥� '
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf
   If !File(n_blphiz+".dbf")
      DBCreate(n_blphiz,aBlaniz)
   EndIf
   If AlNetUse(n_blphiz,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'���� BLANPHIZ.dbf �� ����㯥�'
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf
   If !File(n_blphtm+".dbf")
      DBCreate(n_blphtm,aBlantm)
   EndIf
   If AlNetUse(n_blphtm,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'���� BLANPHTM.dbf �� ����㯥�'
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf
  case variant==3
   If AlNetUse(n_raspor,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' ���� RASPOR.dbf �� ����㯥� '
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf
   If AlNetUse(n_prior,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' ���� PRIOR.dbf �� ����㯥� '
      @ 14,19 Say'  ������ ���� ������� ...  '
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
      @ 13,19 Say' ���� BD02KI.dbf �� ����㯥� '
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf
   If AlNetUse(n_blan,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' ���� BLANKS.dbf �� ����㯥� '
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf
   If AlNetUse(n_blaniz,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'���� BLANKSIZ.dbf �� ����㯥�'
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf
   If AlNetUse(n_blanph,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' ���� BLANPH.dbf �� ����㯥� '
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf
   If AlNetUse(n_blphiz,.T.,5)
   Else
      my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say'���� BLANPHIZ.dbf �� ����㯥�'
      @ 14,19 Say'  ������ ���� ������� ...  '
      InKey(0)
      Return .F.
   EndIf
 EndCase
Return .T.
