//Masha

#include "box.ch"
#include "inkey.ch"
#include "achoice.ch"

//��楤�� �஢�ન �� �����襭��
Procedure zaverOK()

Local NP_ASU := "",NP_PDO := "",j:=0

Save Screen

If (bases->(dbSeek("bd02ki.dbf")))
   si_ASU := ""
   If File(AllTrim(bases->path) + "bd02ki.dbf")
      si_ASU := GetSi(AllTrim(bases->path) + "bd02ki.dbf")
      NP_ASU = SubStr(si_ASU,15,3)
      date_ASU := SubStr(si_ASU,7,8)
   EndIf
Else
   my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
   @ 12,19 Say'    ���� BD02KI � BASES.dbf'
   @ 13,19 Say'          �� ������. '
   @ 14,19 Say'    ������ ���� ������� ...  '
   InKey(0)
   Restore Screen
   Clear Screen
   Close All
   Return
EndIf
For j:=1 To Len(aPDO)
   If aPDO[j,1] == "bd02ki"
      Exit
   EndIf
Next
date_PDO := aPDO[j, 4]

If (NP_ASU # aPDO[j,3]) //�����襭�� �� �ந���������
   my_box(9,18,18,60,B_DOUBLE+chr(32),"W+/R")
   @ 10, 19 Say'                ��������!!!'
   @ 11, 19 Say'      �� �믮��﫮�� �����襭�� ࠡ��� '
   @ 12, 19 Say'               �� ' + date_PDO
   @ 13, 19 Say'               �த������?'
   @ 16, 32 Say' �� '
   @ 16, 43 Say' ��� '
      Tone(100, 18)
      Tone(200, 12)
      Tone(100, 18)

   TekOtv := '���'
   SetColor("W+/B")
   @ 16, 43 Say' ��� '
   lkey := Inkey(0)

   While (lkey # K_ENTER)
      If (TekOtv == '��')
         SetColor("W+/R")
         @ 16, 32 Say' �� '
      Else
         SetColor("W+/R")
         @ 16, 43 Say' ��� '
      EndIf
      Do Case
         Case (lkey = K_LEFT).OR.(lkey = K_RIGHT).OR.(lkey = K_TAB)
            If TekOtv == '��'
               TekOtv = '���'
            Else
               TekOtv = '��'
            EndIf
      EndCase
      If (TekOtv == '��')
         SetColor("W+/B")
         @ 16, 32 Say' �� '
      Else
         SetColor("W+/B")
         @ 16, 43 Say' ��� '
      EndIf
      lkey = Inkey(0)
   EndDo
   If TekOtv == '��'
      my_box(9,18,19,60,B_DOUBLE+chr(32),"W+/R")
      @ 10, 19 Say'       �㤥� ����⠭������ ���� ������ '
      @ 11, 19 Say'               �� '+date_ASU
      @ 12, 19 Say'         ���४�஢�� �� '+date_PDO
      @ 13, 19 Say'              ����� �������!'
      @ 14, 19 Say'               �த������?'
      @ 17, 32 Say' �� '
      @ 17, 43 Say' ��� '
      Tone(1000, 1)
      Tone(1000, 1)
      Tone(1000, 1)
      Tone(1000, 1)

      TekOtv := '���'
      SetColor("W+/B")
      @ 17, 43 Say' ��� '
      lkey := Inkey(0)

      While (lkey # K_ENTER)
         If (TekOtv == '��')
            SetColor("W+/R")
            @ 17, 32 Say' �� '
         Else
            SetColor("W+/R")
            @ 17, 43 Say' ��� '
         EndIf
         Do Case
            Case (lkey = K_LEFT).OR.(lkey = K_RIGHT).OR.(lkey = K_TAB)
               If TekOtv == '��'
                  TekOtv = '���'
               Else
                  TekOtv = '��'
               EndIf
         EndCase
         If (TekOtv == '��')
            SetColor("W+/B")
            @ 17, 32 Say' �� '
         Else
            SetColor("W+/B")
            @ 17, 43 Say' ��� '
         EndIf
         lkey = Inkey(0)
      EndDo
      If TekOtv == '��'//ࠧ���� ����������
         Return (.T.)
      Else
         Return (.F.)//�⬥���� ����������
      EndIf
   Else
      Return (.F.)
   EndIf
EndIf

Restore Screen
Return (.T.)
//--------------------------------------------------------------------------
