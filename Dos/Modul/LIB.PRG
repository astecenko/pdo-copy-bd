//функция Opr_Polz() для программы analiz22 обращается к базе паролей passw_an.dbf
#include "box.ch"
#include "setcurs.ch"
#include "inkey.ch"

Func Opr_Polz()
Local n_baza,Lmore:=.t.
Private Polzov1

 BASESPDO->(dbSeek("passw_an.dbf"))
 If BASESPDO->(Found())
      n_baza=AllTrim(BASESPDO->path)+"passw_an"
      If !File(n_baza+".dbf")
         Boxik(12,15,15,55,'Нет файла PASSW_AN.dbf',B_DOUBLE,"w+/r")
         Restore Screen
         Clear All
         Close All
         Quit
      EndIf
 Else
      Boxik(11,18,15,60,"Нет файла PASSW_AN.dbf в BASESPDO",B_DOUBLE,'w+/r')
      Restore Screen
      Clear All
      Close All
      Quit
 End
 *--------------------------
 If !Setka(n_baza,.F.,5)
     Boxik(11,18,15,60,'Файл PASSW_AN.dbf не доступен',B_DOUBLE,'w+/r')
     Restore Screen
     Clear All
     Close All
     Quit
 End
 //Close BASESPDO
 Do While Lmore
    If !Get_Pasw()
       Restore Screen
       Clear All
       Close All
       Quit
    End
    *------------------------------------------------------
    Select Passw_an
    Box1:=drowbox(11,20,15,60)
    @ 11,20 to 15,60 double
    @ 15,44 say ' ESC - Отмена '
    psw:=""
    i:=0
    Save_cur:=SetCursor(SC_NORMAL)
    @ 13,25 say "Введите пароль      "
    @ 13,45 say space(10) color "n/bg"
    setpos(13,45)

    Do while .t.
       nKey:=inkey(0)
       do case
          case ((nKey >= 45) .and. (nKey <= 57)).or.((nKey >=128) .and. (nKey<=239))
               @ 13,col() say "*" color "n/bg"
               if col() = 45+10
                  KEYBOARD chr(K_ENTER)
               end
               psw:=psw+chr(nKey)
          case nKey == K_ESC
               //lMore:=.f.
               exit
          case nKey == K_BS
               if !empty(psw)
                  @ row(),col()-1 say " " color "n/bg"
                  setpos(13,col()-1)
               else
                  tone(1000,0.5)
               end
               psw:=iif(!empty(psw),left(psw,len(psw)-1),"")
          case nKey == K_ENTER
               locate for RUpper(alltrim(passw_an->NAME)) ==  RUpper(alltrim(polzov1))// # "IRA"
               if Passw_an->(!Found())
                  tone(1000,0.5)
                  set cursor off
                  Boxik(11,18,15,60,"НЕТ ПОЛЬЗОВАТЕЛЯ В СПИСКЕ !",B_DOUBLE,'w+/r')
                  set cursor on
                  psw:=""
                  i:=0
                  @ 13,45 say space(10) color "n/bg"
                  setpos(13,45)
                 // LMore:=.f.
                  Exit
               end
               if Empty(psw) .or. (RUpper(alltrim(Passw_an->Pasw)) # RUpper(alltrim(psw)))
                  tone(1000,0.5)
                  set cursor off
                  Boxik(11,18,15,60,"НЕТ ДОСТУПА по этому паролю !",B_DOUBLE,'w+/r')
                  set cursor on
                  psw:=""
                  i:=0
                  @ 13,45 say space(10) color "n/bg"
                  setpos(13,45)
               else
                  LMore:=.f.
                  Exit
               end
       EndCase
    Enddo
 EndDo
 SetCursor(Save_Cur)
 delBox(11,20,15,60,Box1)
 Polzov1:=Passw_an->Name
 Close Passw_an
Return Polzov1
*--------------------------------------------------------------
func Get_Pasw()
Local Box1,p,bCex:={},;
      aCex_len,i,x1,y1,x2,y2,spis_p:={}

 Select Passw_an
 Passw_an->(DbGotop())
 Do While !EOF()
    Aadd(Spis_p,' '+Passw_an->Name)
    Passw_an->(DbSkip())
 EndDo
 setcolor("n/bg+")
 cls
 aCex:=SPIS_P
 aadd(aCex,' ВЫХОД ')
 aCex_len:=len(aCex)
 aeval(aCex,{|a| aadd(bcex,Iif(a="ВЫХОД",padc(a,16),padr(a,16)))})
 setcolor("w+/b,gr+/r")
 x1:=(maxrow()-(4+iif(aCex_len > 15,14,aCex_len))) / 2
 x1:=round(x1,0)
 x2:=x1+3+iif(aCex_len > 15,14,aCex_len)
 Box1:=drowbox(x1,32,x2,48)
 @ x1+1,33 say ' ПОЛЬЗОВАТЕЛИ: '
 @ x1+2,33 say '───────────────'
 DispBox(x1,32,x2,48,2)
 p:=achoice(x1+3,33,x2-1,47,bCex)
 DelBox(x1,32,x2,48,Box1)
 if p = 0 .or. p = aCex_len
    return .f.
 else
    polzov1:=BCex[p]
 end
return .t.
******************************************************
