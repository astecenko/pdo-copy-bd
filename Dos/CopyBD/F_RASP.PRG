         /*��楤��� �ନ஢���� �� ������������ ��� ���*/
                /*���ࠡ��稪 - ���祭�� ��죠 ����஢��*/
                              /*2001 �.*/
                          /*��⥢�� ��ਠ��*/

#include "box.ch"
#include "inkey.ch"
#include "achoice.ch"


/************** ������������ �� ��ᯮ�殮��� ��� ��� �� ����� *******/
Procedure Form_Rasp()
Public db:="",dbiz:=""
 my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
 @ 13,22 Say' ���� �����⮢�� ���� ������ RASPOR '

 Do While !Raspor->(Eof())
    @ 14,32 Say Raspor->(RecNo())
    If raspor->pr="0" //pr="1", ��� �� ��.,�-�� ����� ���짮��⥫� ������
       raspor->(dbDelete())
    EndIf
    raspor->(dbSkip())
 EndDo

 @ 13,22 Say' ���� �����⮢�� ���� ������ PRIOR '
 Do While !prior->(Eof())
    @ 14,32 Say prior->(RecNo())
    prior->(dbDelete())
    prior->(dbSkip())
 EndDo

 my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
 Set Color To W+*/B
 Select raspor
 @ 13,22 Say " ���� �������� ���� ������ RASPOR "
 Index On raspor->cex+raspor->chert+raspor->ps+raspor->vp+raspor->cp+;
          raspor->ki To (n_raspor+".ntx")

 my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
 @ 13,21 Say'  ���� ��ࠡ�⪠ RASPOR.dbf (�� �����)'
 Do While !bd02ki->(Eof())
    @ 14,35 Say bd02ki->(RecNo())
    If bd02ki->ki="0200" .Or. bd02ki->ki="0120"
       If blanph->(dbSeek(bd02ki->cex+bd02ki->chert+bd02ki->ps+;
                          bd02ki->vp+bd02ki->cp))
          blanphiz->(dbSeek(blanph->num))
          db:="blanph"
          dbiz:="blanphiz"
          Obrab_blaniz()
       Else
          If blanks->(dbSeek(bd02ki->cex+bd02ki->chert+bd02ki->ps+;
                             bd02ki->vp+bd02ki->cp))
             blanksiz->(dbSeek(blanks->num))
             db:="blanks"
             dbiz:="blanksiz"
             Obrab_blaniz()
          EndIf
       EndIf
    EndIf
    bd02ki->(dbSkip())
 EndDo

 Select raspor
 Pack
 my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
 Set Color To W+*/B
 @ 13,22 Say " ���� ���஢�� ���� ������ RASPOR "
 n_rasp1=SubStr(n_raspor,1,Rat("\",n_raspor))+"raspor1"
 Copy To (n_rasp1)
 Close raspor
 Delete File (n_raspor+".dbf")
 Rename (n_rasp1+".dbf") To (n_raspor+".dbf")
 Delete File (n_raspor+".ntx")

 //�ନ�㥬 �� �ਮ��⮢
 If MYNetUse(n_raspor,.T.,5)
 Else
    my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
    @ 13,19 Say' ���� RASPOR.dbf �� ����㯥� '
    @ 14,19 Say'  ������ ���� ������� ...  '
    InKey(0)
    Close All
    Return .F.
 EndIf
 Index On cex+ki To (n_raspor+".ntx") Unique
 Do While !Raspor->(Eof())
    If prior->(dbSeek(raspor->cex+raspor->ki))
       If prior->(Deleted())
          prior->(dbRecall())
       EndIf
    Else
      //�ନ�㥬 �� 200 �� � �� ��. ⥪.����⠫�
       If raspor->kod_gr="0200" .And. raspor->pr!="1"
          prior->(dbAppend())
          prior->cex:=raspor->cex
          prior->ki:=raspor->ki
          prior->prior:="0"
       EndIf
    EndIf
    raspor->(dbSkip())
 EndDo
 Close raspor
 Delete File (n_raspor+".ntx")

 Select prior
 Pack
 my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
 Set Color To W+*/B
 @ 13,22 Say " ���� ���஢�� ���� ������ PRIOR "
 n_p1=SubStr(n_prior,1,Rat("\",n_prior))+"prior1"
 Sort To (n_p1+".dbf") On cex /A, ki /A
 Close prior
 Delete File (n_prior+".dbf")
 Rename (n_p1+".dbf") To (n_prior+".dbf")
Return

//*********** ��ࠡ�⪠ blanks(ph)iz �� �����⭮�� ����� -
//                                             �ᯮ�����. ��� Form_rasp()
Function Obrab_blaniz()
 Do Case
    case bd02ki->ki="0120"
      Do While (dbiz)->num=(db)->num
         //�᫨ ��. �室�� � 0120 ��� 0200 ��
         If (dbiz)->ki="0049" .Or. (dbiz)->ki="0065" .Or.;
            ((dbiz)->ki>="0122" .And. (dbiz)->ki<="0199")
            Append_rasp()
         EndIf
         If (dbiz)->ki>"0199"   //???
            Exit
         EndIf
         (dbiz)->(dbSkip())
      EndDo
    case bd02ki->ki="0200"
      Do While (dbiz)->num=(db)->num
         //�᫨ ��. �室�� � 0120 ��� 0200 ��
         If ((dbiz)->ki>="1000" .And. (dbiz)->ki<="6999") .Or.;
            ((dbiz)->ki>="8000" .And. (dbiz)->ki<="9999")
            Append_rasp()
         EndIf
         (dbiz)->(dbSkip())
      EndDo
 EndCase
Return

//************ �������� ��. -�ᯮ����⥫쭠� ��� Obrab_blaniz() ****
Procedure Append_rasp()
 If raspor->(dbSeek((db)->cex+(db)->chert+(db)->ps+(db)->vp+(db)->cp+(dbiz)->ki))
    //�� ⠪��� ����� ��. ���� - ���塞 ���-�� �� ����
    Do Case
       case num_kv="1"
         If !Empty((dbiz)->kol1)
            If raspor->(Deleted())
               raspor->(dbRecall())
            EndIf
            raspor->k1:=(dbiz)->kol1
         EndIf
       case num_kv="2"
         If !Empty((dbiz)->kol2)
            If raspor->(Deleted())
               raspor->(dbRecall())
            EndIf
            raspor->k1:=(dbiz)->kol2
         EndIf
       case num_kv="3"
         If !Empty((dbiz)->kol3)
            If raspor->(Deleted())
               raspor->(dbRecall())
            EndIf
            raspor->k1:=(dbiz)->kol3
         EndIf
       case num_kv="4"
         If !Empty((dbiz)->kol4)
            If raspor->(Deleted())
               raspor->(dbRecall())
            EndIf
            raspor->k1:=(dbiz)->kol4
         EndIf
    EndCase
 Else  //�� ⠪��� ����� ��. ��� - ������塞 ��.
    Do Case
       case num_kv="1"
         If !Empty((dbiz)->kol1)
            raspor->(dbAppend())
            raspor->cex:=bd02ki->cex
            raspor->chert:=bd02ki->chert
            raspor->ps:=bd02ki->ps
            raspor->vp:=bd02ki->vp
            raspor->cp:=bd02ki->cp
            raspor->ki:=(dbiz)->ki
            raspor->kod_gr:=bd02ki->ki
            raspor->k1:=(dbiz)->kol1
         EndIf
       case num_kv="2"
         If !Empty((dbiz)->kol2)
            raspor->(dbAppend())
            raspor->cex:=bd02ki->cex
            raspor->chert:=bd02ki->chert
            raspor->ps:=bd02ki->ps
            raspor->vp:=bd02ki->vp
            raspor->cp:=bd02ki->cp
            raspor->ki:=(dbiz)->ki
            raspor->kod_gr:=bd02ki->ki
            raspor->k1:=(dbiz)->kol2
         EndIf
       case num_kv="3"
         If !Empty((dbiz)->kol3)
            raspor->(dbAppend())
            raspor->cex:=bd02ki->cex
            raspor->chert:=bd02ki->chert
            raspor->ps:=bd02ki->ps
            raspor->vp:=bd02ki->vp
            raspor->cp:=bd02ki->cp
            raspor->ki:=(dbiz)->ki
            raspor->kod_gr:=bd02ki->ki
            raspor->k1:=(dbiz)->kol3
         EndIf
       case num_kv="4"
         If !Empty((dbiz)->kol4)
            raspor->(dbAppend())
            raspor->cex:=bd02ki->cex
            raspor->chert:=bd02ki->chert
            raspor->ps:=bd02ki->ps
            raspor->vp:=bd02ki->vp
            raspor->cp:=bd02ki->cp
            raspor->ki:=(dbiz)->ki
            raspor->kod_gr:=bd02ki->ki
            raspor->k1:=(dbiz)->kol4
         EndIf
    EndCase
 EndIf
Return

//****************** ��ନ஢���� ��. �� 㪮�����⮢������ **********
//�����।������ ᤠ� �� ��⪨ �� 200 �� �� ��.
Procedure Rasp_bd02ki()
Local s_ktek:=0, rec_beg:=0,i
 my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
 @ 13,21 Say' ���� ��ࠡ�⪠ RASPOR.dbf (ᤠ�/���)'
 Do While !bd02ki->(Eof())
    @ 14,35 Say bd02ki->(RecNo())
    If bd02ki->ki="0200" .And. bd02ki->ksut!=0
       If raspor->(dbSeek(bd02ki->cex+bd02ki->chert+bd02ki->ps+bd02ki->vp+;
                                                               bd02ki->cp))
          s_ksut:=bd02ki->ksut
          rec_beg:=raspor->(RecNo()) //��ࢠ� ������ �� �����
          For i:=2 To 1 Step -1  //�ਮ��� 0 - �� �������⮢���
              Do While raspor->cex==bd02ki->cex .And.;
                       raspor->chert==bd02ki->chert .And. raspor->ps==bd02ki->ps;
                       .And. raspor->vp==bd02ki->vp .And. raspor->cp==bd02ki->cp
                 //�᫨ ��. �室�� � ��ࠡ��뢠���� ��㯯�
                 If raspor->kod_gr="0200" .And. raspor->pr!="1"
                    If prior->(dbSeek(raspor->cex+raspor->ki))
                       If prior->prior=Str(i,1)
                          If raspor->k1 > raspor->ktek  //��. �� ������
                             If (raspor->k1-raspor->ktek) >= s_ksut
                                raspor->ktek:=raspor->ktek+s_ksut
                                s_ksut:=0
                                Exit //����� ��祣� �����।�����
                             Else
                                s_ksut:=s_ksut-(raspor->k1-raspor->ktek)
                                raspor->ktek:=raspor->k1  //����뢠� ��.
                             EndIf
                          EndIf
                       EndIf
                    EndIf
                 EndIf
                 raspor->(dbSkip())
              EndDo
              If s_ksut>0
                 raspor->(dbGoto(rec_beg))
              Else
                 Exit
              EndIf
          Next
       EndIf
    EndIf
    bd02ki->(dbSkip())
 EndDo
Return



//****************** ��ନ஢���� ��. �� 㪮�����⮢������ **********
Procedure Rasp_ktek_bd02ki()   //������. ktek
Local s_ktek:=0, rec_beg:=0
 my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
 @ 13,21 Say'  ���� ��ࠡ�⪠ RASPOR.dbf (�� �-�)'
 Do While !bd02ki->(Eof())
    @ 14,35 Say bd02ki->(RecNo())
    If bd02ki->ki="0200" .Or. bd02ki->ki="0120"
       If raspor->(dbSeek(bd02ki->cex+bd02ki->chert+bd02ki->ps+bd02ki->vp+;
                                                               bd02ki->cp))
          s_ktek:=0 //�㬬� raspor->ktek �� �����
          rec_beg:=raspor->(RecNo()) //��ࢠ� ������ �� �����
          //����㬬��㥬 ktek �� ��., �室�騬 � ��।. ��㯯�
          Do While raspor->cex==bd02ki->cex .And.;
                   raspor->chert==bd02ki->chert .And. raspor->ps==bd02ki->ps;
                   .And. raspor->vp==bd02ki->vp .And. raspor->cp==bd02ki->cp
             //�᫨ ��. �室�� � ��ࠡ��뢠���� ��㯯�
             If (bd02ki->ki="0120" .And. (raspor->ki="0049" .Or. ;
                   raspor->ki="0065" .Or. raspor->ki="0066" .Or.;
                   (raspor->ki>="0121" .And. raspor->ki<="0199"))) .Or.;
                (bd02ki->ki="0200" .And. ;
                   ((raspor->ki>="1000" .And. raspor->ki<="7000") .Or.;
                   (raspor->ki>="8000" .And. raspor->ki<="9999")))

                s_ktek:=s_ktek+raspor->ktek
             EndIf
             raspor->(dbSkip())
          EndDo

          //��।��塞, ���� �� ࠧ��� ����� ����㬬�஢���� ktek ��.
          //� ktek ���� ��㯯�, �᫨ ����, � ����뢠�� ��������� ��.
          If s_ktek < bd02ki->ktek     //�����।��塞 ࠧ���� � 0200 ��
             raspor->(dbGoto(rec_beg)) //�� ��������� �ᯮ�殮���
             s_ktek:=bd02ki->ktek-s_ktek  //ࠧ��� � 0200 ��
             Do While raspor->cex==bd02ki->cex .And.;
                      raspor->chert==bd02ki->chert .And. raspor->ps==bd02ki->ps;
                      .And. raspor->vp==bd02ki->vp .And. raspor->cp==bd02ki->cp
                //�᫨ ��. �室�� � ��ࠡ��뢠���� ��㯯�
                If (bd02ki->ki="0120" .And. (raspor->ki="0049" .Or. ;
                      raspor->ki="0065" .Or. raspor->ki="0066" .Or.;
                      (raspor->ki>="0121" .And. raspor->ki<="0199"))) .Or.;
                   (bd02ki->ki="0200" .And. ;
                      ((raspor->ki>="1000" .And. raspor->ki<="7000") .Or.;
                      (raspor->ki>="8000" .And. raspor->ki<="9999")))

                    If raspor->k1 > raspor->ktek  //��. �� ������
                       If (raspor->k1-raspor->ktek) >= s_ktek
                          raspor->ktek:=raspor->ktek+s_ktek
                          Exit //����� ��祣� �����।�����
                       Else
                          s_ktek:=s_ktek-(raspor->k1-raspor->ktek)
                          raspor->ktek:=raspor->k1  //����뢠� ��.
                       EndIf
                    EndIf
                EndIf
                raspor->(dbSkip())
             EndDo
          EndIf
       EndIf
    EndIf
    bd02ki->(dbSkip())
 EndDo
Return

//******************* ���������� mp31******************//
//mp31_ - �� MP31 (���), mp31 - �� MP31 (᪮��஢���� � �����)
Procedure Form_mp31()
Local str,j:=0
 Set Color To N/BG
 Clear Screen
 my_box(5,7,20,72,B_DOUBLE+chr(32),"W+/W")
 @ 5,28 Say "  ���� ���������� ������  "
 Use (aPDO[i,2]+"mp31") New ReadOnly   //aPDO ����஥� �� mp31, �.�. �� ⮫쪮 �� ᪮��஢��� mp31
* If MYNetUse(aPDO[i,2]+"mp31",.T.,5)      //���祭�� ⠪ ����� ��������, �� ���� �� ���塞
* Else
*    my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
*    @ 13,19 Say'  ���� MP31.dbf �� ����㯥� '
*    @ 14,19 Say'  ������ ���� ������� ...  '
*    InKey(0)
*    Return .F.
* EndIf
 my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
 Set Color To W+*/B
 @ 13,22 Say "  ���� �������� ���� ������ MP31 "
 Index On cex+chert+shm To (aPDO[i,2]+"mp31.ntx")

 Use (aPDO[i,2]+"mp31_") New
*Use (aPDO[i,2]+"mp31_") Exclusive New     //���祭�� ⠪ ����� ��������, �� ���� �� ���塞
 my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
 Set Color To W+*/B
 @ 13,22 Say "  ���� �������� ���� ������ MP31_ "
 Index On cex+chert+shm To (aPDO[i,2]+"mp31_.ntx")

 my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
 @ 13,22 Say'  ���� �����⮢�� ���� ������ MP31_ '
 Do While !mp31_->(Eof())
    @ 14,32 Say mp31_->(RecNo())
    str:=mp31_->cex+mp31_->chert
    If mp31->(dbSeek(mp31_->cex+mp31_->chert)) //�⮡� �� 㤠���� ����樨 ����� ����⠫��
       Do While str==mp31_->cex+mp31_->chert
          mp31_->(dbDelete())
          str:=mp31_->cex+mp31_->chert
          mp31_->(dbSkip())
       EndDo
    Else
       Do While str==mp31_->cex+mp31_->chert
          str:=mp31_->cex+mp31_->chert
          mp31_->(dbSkip())
       EndDo
    EndIf
 EndDo

 @ 13,22 Say'   ���� ��ࠡ�⪠ ���� ������ MP31_ '
 @ 14,32 Say '        '
 mp31_->(dbGoTop())
 mp31->(dbGoTop())
 Do While !mp31->(Eof())
    @ 14,32 Say Str(j++)
    If mp31_->(dbSeek(mp31->cex+mp31->chert+mp31->shm))
       mp31_->(dbRecall())
       mp31_->norma:=mp31->norma
       mp31_->ei:=mp31->ei
    Else
       mp31_->(dbAppend())
       mp31_->cex:=mp31->cex
       mp31_->chert:=mp31->chert
       mp31_->shm:=mp31->shm
       mp31_->norma:=mp31->norma
       mp31_->ei:=mp31->ei
    EndIf
    mp31->(dbSkip())
 EndDo
 Close mp31
 @ 13,22 Say'    ���� 㯠����� ���� ������ MP31_ '
 @ 14,22 Say'                                '
 Select mp31_
 Pack
 Set Index To  //������� ������ mp31 ��। 㤠������
 Delete File (aPDO[i,2]+"mp31.ntx")
 Delete File (aPDO[i,2]+"mp31.dbf")
 Delete File (aPDO[i,2]+"mp31_.ntx")
 my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
 Set Color To W+*/B
 @ 13,22 Say " ���� ���஢�� ���� ������ MP31  "
 Sort To (aPDO[i,2]+"mp31.dbf") On cex, shm, chert
 Close All
 Delete File (aPDO[i,2]+"mp31_.dbf")
 PutSi(aPDO[i,2]+"mp31.dbf","MP31  "+aASU[i,4]+aASU[i,3]+"004"+SubStr(aASU[i,5],1,4)) 
 If !MYNetUse(aPDO[i,2]+"mp31",.T.,5)      //����஢� ᮧ����� ������ ��� ����� mp31
    my_box(12,18,15,48,B_DOUBLE+chr(32),"W+/R")
    @ 13,19 Say' ���� 䠩� MP31.dbf �� ����㯥� '
    @ 14,19 Say'  ������ ���� ������� ...      '
    InKey(0)
    Return .F.
 EndIf
 Index On cex+chert+shm To (aPDO[i,2]+"mp31.ntx")
Return
