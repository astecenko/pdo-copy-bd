***********************************************************************
* ��������� �������������� �����, ����������� � �� ���, � ���������
***********************************************************************
 PROC PRFT(name)
   Local scr, lBlink:=SetBlink(.f.)
   Local cClr:=SetColor("W+/B,B*/W"),;
         cStr:=" ", cWrt:="", n:={0, 0}, len:=0, lF:=.t., lErr:=.f.

   Save Screen To scr
   Set Date To German
   CLS

   If name == NIL       // �᫨ �� ������ ���
      name:="        "
      @ 12,5 Say "������ ��� ��設��ࠬ�� (�� 8 ᨬ�����) - " Get name
      Read
      If LastKey() == 27 .OR. Empty(name)
         SetColor(cClr)
         restore screen from scr
         Return
      EndIf
      CLS
   EndIf

   WName:=name+".txt"
   If File(WName)    // ���� 㦥 ��ॢ������ 䠩�
      If Alert("��設��ࠬ�� "+name+" 㦥 ��ॢ�������;���: "+;
               DToC(FileDate(WName))+"  �६�: "+FileTime(WName),;
               {">��������<", ">���<"}, "W+/R, R*/W") != 1
         SetBlink(lBlink)
         SetColor(cClr)
         restore screen from scr
         Return
      EndIf
   EndIf

   If (nFR:=FOpen(name)) < 0
      @ 10,0 Say PadC("�訡�� ������ 䠩��-��設��ࠬ�� !!!   "+Str(FError(),2), 80) Color "R+/B"
      If FError() = 2
         @ 12,0 Say PadC("����� � ������ "+name+" ��� � ⥪�饩 ��४�ਨ", 80)
      ElseIf FError() = 32
         @ 12,0 Say PadC("���� "+name+" � ����� ������ ����� ��㣨� ���짮��⥫��",80)
      Else
         @ 12,0 Say PadC("���� "+name+" �� �⠥���. ������� NDD",80)
      EndIf
      @ 14,0 Say PadC("�� ᢨ����� !", 80)
      Wait "     ����� ������ - ������ ���� �������"
      SetBlink(lBlink)
      SetColor(cClr)
      restore screen from scr
      Return
   EndIf

   nEnd:=FSeek(nFR, 0, 2)    // ��᫥���� ������ 䠩��
   If nEnd < 80
      @ 10,0 Say PadC(Str(nEnd, 2)+" ���� - ��-祭� ��-�-�-����쪨� 䠩� !", 80) Color "R+/B"
      @ 12,0 Say PadC("�஢����, �� �� ��, ��-⠪�, ��ॢ���",80)
      FClose(nFR)
      Wait "     ����� ����� - ������ ���� �������"
      SetBlink(lBlink)
      SetColor(cClr)
      restore screen from scr
      Return
   EndIf

   nPos:=FSeek(nFR, 0, 0)    // ��砫쭠� ������
   For i=1 To 2
      cStr:=" "
      Do While Asc(cStr) <> 9
         If FRead(nFR, @cStr, 1) < 1
            @ 10,0 Say PadC(Str(nEnd, 3)+" ���� - ��-祭� ��-�-�-����쪨� 䠩� !", 80) Color "R+/B"
            @ 12,0 Say PadC("�஢����, �� �� ��, ��-⠪�, ��ॢ���",80)
            FClose(nFR)
            Wait "     ����� ����� - ������ ���� �������"
            SetBlink(lBlink)
            SetColor(cClr)
            restore screen from scr
            Return
         EndIf
      ********** �஢�ઠ �� ����室������ �८�ࠧ������
         If Asc(cStr) = 13
            FRead(nFR, @cStr, 1)
            n[i]++
            If Asc(cStr) = 10
               Alert("������� 䠩� �� �㦤����� � �८�ࠧ������.",;
                     {" ������  >ENTER< "}, "W+/R, R*/W")
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
   @ 0,0 Say PadC("�८�ࠧ������ ��設��ࠬ�� "+name+".    ����� ��ப� - "+Str(len-1, 3), 80);
             Color "R/BG"
   nFW:=FCreate(WName)

   cStr:=Space(len)
   nPos:=FSeek(nFR, nL, 0)    // ��砫쭠� ������
   Do While (nPos < nEnd)
      nL:=FRead(nFR, @cStr, len)
      nPos:=FSeek(nFR, 0, 1)    // ������ ������
      If nL < len
         If nPos = nEnd    // ����� 䠩��
            len:=nL
            cStr:=SubStr(cStr,1,len)
         Else              // �訡�� �� �⥭��
            Alert("�訡�� �� �⥭�� 䠩�� - "+Str(FError(),2), {" ENTER "}, "W+/R, R*/W")
            lErr:=.t.
            Exit
         EndIf
      EndIf
      cStr:=StrTran(cStr, CHR(0), CHR(32))
/*
      For i=1 To len
         If ASC(SubStr(cStr,i,1)) < 32 .OR. ASC(SubStr(cStr,i,1)) = 127   // �����ॡ�� ᨬ���
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
            Alert(Str(FError(),2)+" - �訡�� �� ����� 䠩�� �� ���.;��� �஢�ન ��᪠ ������� NDD",;
                  {" ENTER "}, "W+/R, R*/W")
            lErr:=.t.
            Exit
         EndIf
      Else
         cWrt:=cStr+Chr(13)+Chr(10)
         If FWrite(nFW, cWrt, len+2) < len+2
            Alert(Str(FError(),2)+" - �訡�� �� ����� 䠩�� �� ���.;��� �஢�ન ��᪠ ������� NDD",;
                  {" ENTER "}, "W+/R, R*/W")
            lErr:=.t.
            Exit
         EndIf
      EndIf
   EndDo

   If !lErr
      Alert("���� "+name+" �ᯥ譮 ��९�ᠭ.;���� 䠩� - "+name+".txt",;
            {" ENTER "}, "W+/RB, RB*/W")
   EndIf

   FClose(nFR)
   FClose(nFW)
   SetColor(cClr)
   SetBlink(lBlink)
   Restore Screen From scr
 Return
