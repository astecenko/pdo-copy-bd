#include "Fileio.ch"
#include "setcurs.ch"
#include "Inkey.ch"

func Boxik(x1,y1,x2,y2,str,board,color)
Local Save_Box:=savescreen(x1,y1,x2,y2),;
      Save_Color:=iif(color = nil,setcolor(),setcolor(color))

@ x1,y1 clear to x2,y2
@ x1,y1,x2,y2 Box board color color
@ x1+1,y1+1 say padc(str,y2-y1-2)
@ x1+2,y1+1 say padc(' ¦¬¨â¥ «î¡ãî ª« ¢¨èã ...',y2-y1-2)
Inkey(0)
setcolor(Save_Color)
restscreen(x1,y1,x2,y2,Save_Box)
return nil
*------------------------------------------------------------------
func Setka(Name,mode,nsec,Ro)
Local time

do while .t.
   time:=nsec
   do while time > 0
      if mode
         use (Name) exclusive new//ALIAS NS01KS
      else
         if (Ro <> nil) .and. Ro
            use (Name) shared new ReadOnly
         else
            use (Name) shared new
         end
      end
      if !neterr()
         return .t.
      end
      inkey(1)
      time--
   enddo
   return .f.
enddo
*-------------------------------------------------------
func MY_Alert(x1,y1,x2,y2,str,board,color)
Local Save_Box:=savescreen(x1,y1,x2,y2),;
      Save_Color:=iif(color = nil,setcolor(),setcolor(color))

@ x1,y1 clear to x2,y2
@ x1,y1,x2,y2 Box board color color
@ x1+1,y1+1 say padc(str,y2-y1-2)
//@ x2-1,y1+int((y2-y1)/2) say " OK " color "n/w"
Inkey(0)
setcolor(Save_Color)
restscreen(x1,y1,x2,y2,Save_Box)
return nil
*-------------------------------------
Func Opr_Polzov()
Local n_baza,Lmore:=.t.
Private Polzov1

 BASESPDO->(dbSeek("passw.dbf"))
 If BASESPDO->(Found())
      n_baza=AllTrim(BASESPDO->path)+"passw"
      If !File(n_baza+".dbf")
         Boxik(12,15,15,55,'¥â ä ©«  PASSW.dbf',B_DOUBLE,"w+/r")
         Restore Screen
         Clear All
         Close All
         Quit
      EndIf
 Else
      Boxik(11,18,15,60,"¥â ä ©«  PASSW.dbf ¢ BASESPDO",B_DOUBLE,'w+/r')
      Restore Screen
      Clear All
      Close All
      Quit
 End
 *--------------------------
 If !Setka(n_baza,.F.,5)
     Boxik(11,18,15,60,'” ©« PASSW.dbf ­¥ ¤®áâã¯¥­',B_DOUBLE,'w+/r')
     Restore Screen
     Clear All
     Close All
     Quit
 End
 //Close BASESPDO
 Do While Lmore
    If !Get_Passw()
       Restore Screen
       Clear All
       Close All
       Quit
    End
    *------------------------------------------------------
    Select Passw
    Box1:=drowbox(11,20,15,60)
    @ 11,20 to 15,60 double
    @ 15,44 say ' ESC - Žâ¬¥­  '
    psw:=""
    i:=0
    Save_cur:=SetCursor(SC_NORMAL)
    @ 13,25 say "‚¢¥¤¨â¥ ¯ à®«ì      "
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
               locate for RUpper(alltrim(passw->NAME)) ==  RUpper(alltrim(polzov1))// # "IRA"
               if Passw->(!Found())
                  tone(1000,0.5)
                  set cursor off
                  Boxik(11,18,15,60,"…’ Ž‹œ‡Ž‚€’…‹Ÿ ‚ ‘ˆ‘Š… !",B_DOUBLE,'w+/r')
                  set cursor on
                  psw:=""
                  i:=0
                  @ 13,45 say space(10) color "n/bg"
                  setpos(13,45)
                 // LMore:=.f.
                  Exit
               end
               If RUpper(alltrim(Passw->Name))=='Ž—ˆ…'
                  LMore:=.f.
                  exit
               End
               if Empty(psw) .or. (RUpper(alltrim(Passw->Pasw)) # RUpper(alltrim(psw)))
                  tone(1000,0.5)
                  set cursor off
                  Boxik(11,18,15,60,"…’ „Ž‘’“€ ¯® íâ®¬ã ¯ à®«î !",B_DOUBLE,'w+/r')
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
 Dostup1:=Passw->Dostup
 Polzov1:=Passw->Name
 Close Passw
Return Polzov1
*--------------------------------------------------------------
func Get_Passw()
Local Box1,p,bCex:={},;
      aCex_len,i,x1,y1,x2,y2,spis_p:={}

 Select Passw
 Passw->(DbGotop())
 Do While !EOF()
    Aadd(Spis_p,' '+Passw->Name)
    Passw->(DbSkip())
 EndDo
 setcolor("n/bg+")
 cls
 aCex:=SPIS_P
 aadd(aCex,' ‚›•Ž„ ')
 aCex_len:=len(aCex)
 aeval(aCex,{|a| aadd(bcex,Iif(a="‚›•Ž„",padc(a,16),padr(a,16)))})
 setcolor("w+/b,gr+/r")
 x1:=(maxrow()-(4+iif(aCex_len > 15,14,aCex_len))) / 2
 x1:=round(x1,0)
 x2:=x1+3+iif(aCex_len > 15,14,aCex_len)
 Box1:=drowbox(x1,32,x2,48)
 @ x1+1,33 say ' Ž‹œ‡Ž‚€’…‹ˆ: '
 @ x1+2,33 say 'ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ'
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
*-------------------------------------------------------
func Get_Alert(x1,y1,x2,y2,str,board,color)
Local Save_Box:=savescreen(x1,y1,x2,y2),;
      Save_Color:=iif(color = nil,setcolor(),setcolor(color))

@ x1,y1 clear to x2,y2
@ x1,y1,x2,y2 Box board color color
@ x1+1,y1+1 say padc(str,y2-y1-2)
setcolor(Save_Color)
return Save_Box
*------------------------------------------------------------
func Close_Alert(x1,y1,x2,y2,Box)
 restscreen(x1,y1,x2,y2,Box)
return nil
*--------------------------------------------------
// ¤¢®¨ç­ë© ¯®¨áª § ¯¨á¨ ¢ ¡ § å (â®ç­ë©)
FUNCTION POISK(Name, Pole, N_Low, N_High)
        LOCAL Low,High,Mid
        Low = IIF( N_Low == NIL, 1, N_Low )
        GO Low
        IF &Name > Pole
                RETURN .F.
        ENDIF
        High = IIF( N_High == NIL, LASTREC(), N_High )
        GO High
        IF &Name < Pole
                RETURN .F.
        ENDIF
        DO WHILE High-Low > 1
                Mid = INT((Low + High)/2)
                GO Mid
                DO CASE
                  CASE &Name >= Pole
                        High = Mid
                  CASE &Name < Pole
                        Low  = Mid
                ENDCASE
        ENDDO
GO Low
IF &Name < Pole
        GO High
ENDIF
IF &Name = Pole
        RETURN .T.
ENDIF
RETURN .F.
*-------------------------------------------------------
