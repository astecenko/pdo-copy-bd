//Masha

#include "box.ch"
#include "inkey.ch"
#include "achoice.ch"

//Процедура проверки на завершение
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
   @ 12,19 Say'    Файл BD02KI в BASES.dbf'
   @ 13,19 Say'          не найден. '
   @ 14,19 Say'    Нажмите любую клавишу ...  '
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

If (NP_ASU # aPDO[j,3]) //завершение не производилось
   my_box(9,18,18,60,B_DOUBLE+chr(32),"W+/R")
   @ 10, 19 Say'                ВНИМАНИЕ!!!'
   @ 11, 19 Say'      Не выполнялось завершение работы '
   @ 12, 19 Say'               за ' + date_PDO
   @ 13, 19 Say'               Продолжить?'
   @ 16, 32 Say' Да '
   @ 16, 43 Say' Нет '
      Tone(100, 18)
      Tone(200, 12)
      Tone(100, 18)

   TekOtv := 'Нет'
   SetColor("W+/B")
   @ 16, 43 Say' Нет '
   lkey := Inkey(0)

   While (lkey # K_ENTER)
      If (TekOtv == 'Да')
         SetColor("W+/R")
         @ 16, 32 Say' Да '
      Else
         SetColor("W+/R")
         @ 16, 43 Say' Нет '
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
         @ 16, 32 Say' Да '
      Else
         SetColor("W+/B")
         @ 16, 43 Say' Нет '
      EndIf
      lkey = Inkey(0)
   EndDo
   If TekOtv == 'Да'
      my_box(9,18,19,60,B_DOUBLE+chr(32),"W+/R")
      @ 10, 19 Say'       Будет восстановлена база данных '
      @ 11, 19 Say'               за '+date_ASU
      @ 12, 19 Say'         Корректировки за '+date_PDO
      @ 13, 19 Say'              БУДУТ УДАЛЕНЫ!'
      @ 14, 19 Say'               Продолжить?'
      @ 17, 32 Say' Да '
      @ 17, 43 Say' Нет '
      Tone(1000, 1)
      Tone(1000, 1)
      Tone(1000, 1)
      Tone(1000, 1)

      TekOtv := 'Нет'
      SetColor("W+/B")
      @ 17, 43 Say' Нет '
      lkey := Inkey(0)

      While (lkey # K_ENTER)
         If (TekOtv == 'Да')
            SetColor("W+/R")
            @ 17, 32 Say' Да '
         Else
            SetColor("W+/R")
            @ 17, 43 Say' Нет '
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
            @ 17, 32 Say' Да '
         Else
            SetColor("W+/B")
            @ 17, 43 Say' Нет '
         EndIf
         lkey = Inkey(0)
      EndDo
      If TekOtv == 'Да'//разрешить обновление
         Return (.T.)
      Else
         Return (.F.)//отменить обновление
      EndIf
   Else
      Return (.F.)
   EndIf
EndIf

Restore Screen
Return (.T.)
//--------------------------------------------------------------------------
