
/*компилировать с ключом /n*/
#include "box.ch"
#include "Fileio.ch"
#include "setcurs.ch"

Function NetUseMN(cdatabase,lopenmode,nsec)
 Local forever, restart, wait_time
 restart=.T.
 forever=(nsec=0)
 Do While restart
    wait_time=nsec
    Do While (forever .Or. wait_time>0)
       If lopenmode
          Use (cdatabase) Exclusive New ReadOnly
       Else
          Use (cdatabase) Shared New ReadOnly
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
*******************************************************
Function FileMN(cfile,nsec)
 Local  wait_time
 //Do While .T.
    wait_time=nsec
    Do While wait_time>0
       If file(cfile)
        Return .T.
       EndIf
       wait_time--
    EndDo
   /* If alert("Нет файла "+cfile+", продолжить ?", {" Да ", " Нет "})#1
      Exit
    EndIf
 EndDo*/
Return .F.
*******************************************************
Function DirChangeMN(cdir,nsec)
 Local  wait_time
 //Do While .T.
    wait_time=nsec
    Do While wait_time>0
       If DirChange(cdir)=0
        Return .T.
       EndIf
       wait_time--
    EndDo
   /* If alert("Нет директории "+cdir+", продолжить ?", {" Да ", " Нет "})#1
      Exit
    EndIf
 EndDo*/
Return .F.
*******************************************************
Function arScan(mas,sovp)//,sumTek,sumPlan)
Local i
  for i=1 to len(mas)
    if mas[i][1]==sovp
      return i
    endif
  next
return 0
*******************************************************
//открытие БД с алиасом
Function AlNetUseMN(cdatabase,lopenmode,nsec,al1,Ro)
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
            if (Ro <> nil) .and. Ro
              Use (cdatabase) Shared New ReadOnly alias &(al1)
            else
              Use (cdatabase) Shared New alias &(al1)
            end
          Else
            if (Ro <> nil) .and. Ro
              Use (cdatabase) Shared New ReadOnly
            else
              Use (cdatabase) Shared New
            end
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
