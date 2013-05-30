***********************************************************************
* ПРОГРАММА ПРЕОБРАЗОВАНИЯ ФАЙЛА, ПОЛУЧЕННОГО С ЕС ЭВМ, В ТЕКСТОВЫЙ
***********************************************************************
 PROC PRFT(name)
   Local scr, lBlink:=SetBlink(.f.)
   Local cClr:=SetColor("W+/B,B*/W"),;
         cStr:=" ", cWrt:="", n:={0, 0}, len:=0, lF:=.t., lErr:=.f.

   Save Screen To scr
   Set Date To German
   CLS

   If name == NIL       // Если не задано имя
      name:="        "
      @ 12,5 Say "Задайте имя машинограммы (до 8 символов) - " Get name
      Read
      If LastKey() == 27 .OR. Empty(name)
         SetColor(cClr)
         restore screen from scr
         Return
      EndIf
      CLS
   EndIf

   WName:=name+".txt"
   If File(WName)    // Есть уже переведенный файл
      If Alert("Машинограмма "+name+" уже переводилась;Дата: "+;
               DToC(FileDate(WName))+"  Время: "+FileTime(WName),;
               {">Заменить<", ">Нет<"}, "W+/R, R*/W") != 1
         SetBlink(lBlink)
         SetColor(cClr)
         restore screen from scr
         Return
      EndIf
   EndIf

   If (nFR:=FOpen(name)) < 0
      @ 10,0 Say PadC("Ошибка открытия файла-машинограммы !!!   "+Str(FError(),2), 80) Color "R+/B"
      If FError() = 2
         @ 12,0 Say PadC("Файла с именем "+name+" нет в текущей директории", 80)
      ElseIf FError() = 32
         @ 12,0 Say PadC("Файл "+name+" в данный момент занят другим пользователем",80)
      Else
         @ 12,0 Say PadC("Файл "+name+" не читается. Запустите NDD",80)
      EndIf
      @ 14,0 Say PadC("До свидания !", 80)
      Wait "     Когда прочтёте - нажмите любую клавишу"
      SetBlink(lBlink)
      SetColor(cClr)
      restore screen from scr
      Return
   EndIf

   nEnd:=FSeek(nFR, 0, 2)    // Последняя позиция файла
   If nEnd < 80
      @ 10,0 Say PadC(Str(nEnd, 2)+" байт - оч-чень ма-а-а-аленький файл !", 80) Color "R+/B"
      @ 12,0 Say PadC("Проверьте, что же Вы, все-таки, перевели",80)
      FClose(nFR)
      Wait "     Когда прочтете - нажмите любую клавишу"
      SetBlink(lBlink)
      SetColor(cClr)
      restore screen from scr
      Return
   EndIf

   nPos:=FSeek(nFR, 0, 0)    // Начальная позиция
   For i=1 To 2
      cStr:=" "
      Do While Asc(cStr) <> 9
         If FRead(nFR, @cStr, 1) < 1
            @ 10,0 Say PadC(Str(nEnd, 3)+" байт - оч-чень ма-а-а-аленький файл !", 80) Color "R+/B"
            @ 12,0 Say PadC("Проверьте, что же Вы, все-таки, перевели",80)
            FClose(nFR)
            Wait "     Когда прочтете - нажмите любую клавишу"
            SetBlink(lBlink)
            SetColor(cClr)
            restore screen from scr
            Return
         EndIf
      ********** Проверка на необходимость преобразования
         If Asc(cStr) = 13
            FRead(nFR, @cStr, 1)
            n[i]++
            If Asc(cStr) = 10
               Alert("Заданный файл не нуждается в преобразовании.",;
                     {" Нажмите  >ENTER< "}, "W+/R, R*/W")
               FClose(nFR)
               SetBlink(lBlink)
               SetColor(cClr)
               restore screen from scr
               Return
            EndIf
         EndIf
      ****************************************************
         n[i]++
      EndDo
   Next i

   len:=n[2]
   nL:=n[1]

   CLS
   @ 0,0 Say PadC("Преобразование машинограммы "+name+".    Длина строки - "+Str(len-1, 3), 80);
             Color "R/BG"
   nFW:=FCreate(WName)

   cStr:=Space(len)
   nPos:=FSeek(nFR, nL, 0)    // Начальная позиция
   Do While (nPos < nEnd)
      nL:=FRead(nFR, @cStr, len)
      nPos:=FSeek(nFR, 0, 1)    // Текущая позиция
      If nL < len
         If nPos = nEnd    // Конец файла
            len:=nL
            cStr:=SubStr(cStr,1,len)
         Else              // Ошибка при чтении
            Alert("Ошибка при чтении файла - "+Str(FError(),2), {" ENTER "}, "W+/R, R*/W")
            lErr:=.t.
            Exit
         EndIf
      EndIf
      cStr:=StrTran(cStr, CHR(0), CHR(32))
/*
      For i=1 To len
         If ASC(SubStr(cStr,i,1)) < 32 .OR. ASC(SubStr(cStr,i,1)) = 127   // Непотребный символ
            cStr:=Stuff(cStr,i,1," ")
         EndIf
      Next i
*/
      If len > 78
         ? SubStr(cStr,1,78)
      Else
         ? cStr
      EndIf
      If lF
         cWrt:=SubStr(cStr, 1, len-1)+Chr(13)+Chr(10)
         If FWrite(nFW, cWrt, len+1) < len+1
            Alert(Str(FError(),2)+" - Ошибка при записи файла на диск.;Для проверки диска запустите NDD",;
                  {" ENTER "}, "W+/R, R*/W")
            lErr:=.t.
            Exit
         EndIf
      Else
         cWrt:=cStr+Chr(13)+Chr(10)
         If FWrite(nFW, cWrt, len+2) < len+2
            Alert(Str(FError(),2)+" - Ошибка при записи файла на диск.;Для проверки диска запустите NDD",;
                  {" ENTER "}, "W+/R, R*/W")
            lErr:=.t.
            Exit
         EndIf
      EndIf
   EndDo

   If !lErr
      Alert("Файл "+name+" успешно переписан.;Новый файл - "+name+".txt",;
            {" ENTER "}, "W+/RB, RB*/W")
   EndIf

   FClose(nFR)
   FClose(nFW)
   SetColor(cClr)
   SetBlink(lBlink)
   Restore Screen From scr
 Return
