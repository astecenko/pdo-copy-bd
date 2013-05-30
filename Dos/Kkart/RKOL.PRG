
***********    Подстановка К1 для распоряжений из
***********    бд Blanks.dbf и Blanksiz.dbf
***********
Func Rkol()
Local N_baza,N_baza1,N_baza2,i,kol1

  if !File(vr:=path_base+"BASESPDO.dbf") .or. !File(vr:=path_base+"BASESPDO.ntx")
    alert("Нет файла "+vr)
    Restore Screen
    Clear All
    Close All
    Quit
  endif
  Use (path_base+"BASESPDO") index (path_base+"BASESPDO") Shared New Readonly
*---------------------------------------------------
basespdo->(dbSeek("bd02ki.dbf"))
 If basespdo->(Found())
      n_baza=AllTrim(basespdo->path)+"bd02ki"
      If !File(n_baza+".dbf")
         Boxik(12,18,15,50,'Нет файла BD02KI.dbf',B_DOUBLE,"w+/r")
         Restore Screen
         Clear All
         Close All
         Quit
      EndIf
 Else
         Boxik(12,18,15,50,'Нет BD02KI в BASESPDO.dbf',B_DOUBLE,"w+/r")
         Restore Screen
         Clear All
         Close All
         Quit
 End
*---------------------------------------------------
basespdo->(dbSeek("blanks.dbf"))
 If basespdo->(Found())
      n_baza1=AllTrim(basespdo->path)+"blanks"
      If !File(n_baza+".dbf")
         Boxik(12,18,15,50,'Нет файла BLANKS.dbf',B_DOUBLE,"w+/r")
         Restore Screen
         Clear All
         Close All
         Quit
      EndIf
 Else
         Boxik(12,18,15,50,'Нет BLANKS в BASESPDO.dbf',B_DOUBLE,"w+/r")
         Restore Screen
         Clear All
         Close All
         Quit
 End

*---------------------------------------------------
basespdo->(dbSeek("blanksiz.dbf"))
 If basespdo->(Found())
      n_baza2=AllTrim(basespdo->path)+"blanksiz"
      If !File(n_baza+".dbf")
         Boxik(12,18,15,50,'Нет файла BLANKSIZ.dbf',B_DOUBLE,"w+/r")
         Restore Screen
         Clear All
         Close All
         Quit
      EndIf
 Else
         Boxik(12,18,15,50,'Нет BLANKSIZ в BASESPDO.dbf',B_DOUBLE,"w+/r")
         Restore Screen
         Clear All
         Close All
         Quit
 End


*------------------------------------------------------------
 CLOSE BASESPDO
 If !Setka(N_baza,.T.,5)
    boxik(11,18,15,51,'Файл BD02KI.dbf на сервере ПДО недоступен',;
          B_DOUBLE,"W+/R")
    Restore Screen
    Clear All
    Close All
    Quit
 EndIf
*-----------------------------------
 If !Setka(N_baza1,.T.,5)
    boxik(11,18,15,51,'Файл BLANKS.dbf на сервере ПДО недоступен',;
          B_DOUBLE,"W+/R")
    Restore Screen
    Clear All
    Close All
    Quit
 EndIf
*-----------------------------------
 If !Setka(N_baza2,.T.,5)
    boxik(11,18,15,51,'Файл BLANKSIZ.dbf на сервере ПДО недоступен',;
          B_DOUBLE,"W+/R")
    Restore Screen
    Clear All
    Close All
    Quit
 EndIf
*-----------------------------------
select bd02ki
do while bd02ki->(!eof())
  if (bd02ki->Ki > '1000').and. (bd02ki->Ki < '9990')
      if Poisk3()
         select blanksiz
         if Poisk('num+ki',blanks->num+bd02ki->Ki)
            kol1:=0
            for i:=1 to 4
                kol1:=kol1+blanksiz->(&('kol'+str(i,1)))
            next
            bd02ki->K1:=kol1
         end
         select bd02ki
      end
  end
  bd02ki->(dbskip())
enddo
*-----------------------------------
static Func Poisk3()
local kl1,kl2
Do while (.t.)
   kl1:=bd02ki->cex+bd02ki->chert+bd02ki->ps+bd02ki->vp+bd02ki->cp
   kl2:=blanks->cex+blanks->chert+blanks->ps+blanks->vp+blanks->cp
  if blanks->(eof())
      return (.f.)
  end
  if kl1 == kl2
     //Poisk4(ar)
     return (.t.)
  elseif (kl1 > kl2)
     blanks->(dbskip())
  else
     return (.f.)
  end
Enddo
*-----------------------------------
static Func Poisk4(ar)
Local num2

select blanksiz
if !Poisk('num',blanks->num)
   return (.f.)
end
num2:=blanksiz->Num
do while (blanksiz->Num) == Num2
   aadd(ar,{blanksiz->Ki,blanksiz->Kol1,blanksiz->Kol2,blanksiz->Kol3,;
            blanksiz->Kol4})
   blanksiz->(dbskip())
enddo




if blanksiz->Num # (blanks->Num)
   if !Poisk('num',blanks->num)
      return (.f.)
   end
   do while blanksiz->Num == Num2
      if bd02ki->Ki == blanksiz->Ki
         return (.t.)
      end
      blanksiz->(dbskip())
   enddo
else

end
select bd02ki
return (.f.)
*-----------------------------------
Close All
return nil
