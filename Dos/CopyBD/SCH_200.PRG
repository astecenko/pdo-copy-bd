func sch_200(path_bas)
Local kl,i:=0,pki
Private n_baz_200,n_baz_rasp,n_ind_200,n_ind_rasp
  set deleted on
  set century ON
  set date to german
  set scoreboard off
  set softseek on
  set cursor off
  setblink(.f.)

  OpenBD(path_bas)
  setcolor("n/bg")
  clear

  @ 10,20 Say "Идет индексация BLANKS. Ждите...      " color "b*/bg"
  Select Blanks
  Index On Cex+chert+ps+vp+cp To Blanks
  @ 10,20 Say "Идет индексация BLANKSM. Ждите...     " color "b*/bg"
  Select Blanksm
  Index On Num+ki To Blanksm
  @ 10,20 Say "Идет индексация BLANPH. Ждите...      " color "b*/bg"
  Select Blanph
  Index On Cex+chert+ps+vp+cp To Blanph
  @ 10,20 Say "Идет индексация BLANPHM. Ждите...     " color "b*/bg"
  Select Blanphm
  Index On Num+ki To Blanphm
  @ 10,20 Say "Идет индексация BD02KI04. Ждите...    " color "b*/bg"
  Select Bd02ki04
  Index On Cex+chert+ps+vp+cp+ki To BdKi041
  @ 10,20 Say "Идет индексация BD02KI. Ждите...      " color "b*/bg"
  Select Bd02ki
  Index On Cex+chert+ps+vp+cp+ki To Bd02Ki1
  @ 10,20 Say "Идет индексация BD02KI98. Ждите...    " color "b*/bg"
  Select Bd02ki98
  Index On Cex+chert+ps+vp+cp+ki To BdKi981
  Select Bd02ki04
  do while bd02ki04->(!eof())
  @ 10,20 Say "Идет обработка BD02KI04, BD200 и BDRASP. "+str(++i) color "b*/bg"
    kl:=Bd02ki04->(Cex+chert+ps+vp+cp)
/*    if bd02ki->(dbseek(kl+"0200"))
      Vstavka200(kl)
    endif
*/
    do while bd02ki04->(!eof()) .and.;
             Bd02ki04->(Cex+chert+ps+vp+cp)=kl
      /*if bd02ki04->k1=0
        bd02ki04->(dbskip())
        loop
      endif*/
      pki:=bd02ki04->ki
      if pki=="0200"
        Vstavka200(kl,,"bd02ki04")
      elseif grf->(dbseek(pki)) .and. grf->pm="0"
        VstavkaRasp(kl,pki,"bd02ki04",grf->kod200#"*")
      endif
      bd02ki04->(dbskip())
    enddo
  enddo
  Select Bd02ki
  set filter to (cex#"04" .and. cex#"98")
  go top
  do while bd02ki->(!eof())
  @ 10,20 Say "Идет обработка BD02KI,   BD200 и BDRASP. "+str(++i) color "b*/bg"
    kl:=Bd02ki->(Cex+chert+ps+vp+cp)
/*    if bd02ki->(dbseek(kl+"0200"))
      Vstavka200(kl)
    endif
*/
    do while bd02ki->(!eof()) .and.;
             Bd02ki->(Cex+chert+ps+vp+cp)=kl
      pki:=bd02ki->ki
      if pki=="0200"
        Vstavka200(kl,,"bd02ki")
      elseif grf->(dbseek(pki)) .and. grf->pm="0"
        VstavkaRasp(kl,pki,"bd02ki",grf->kod200#"*")
      endif
      bd02ki->(dbskip())
    enddo
  enddo
  Select Bd02ki98
  do while bd02ki98->(!eof())
  @ 10,20 Say "Идет обработка BD02KI98, BD200 и BDRASP. "+str(++i) color "b*/bg"
    kl:=Bd02ki98->(Cex+chert+ps+vp+cp)
/*    if bd02ki->(dbseek(kl+"0200"))
      Vstavka200(kl)
    endif
*/
    do while bd02ki98->(!eof()) .and.;
             Bd02ki98->(Cex+chert+ps+vp+cp)=kl
      /*if bd02ki98->k1=0
        bd02ki98->(dbskip())
        loop
      endif*/
      pki:=bd02ki98->ki
      if pki=="0200"
        Vstavka200(kl,,"bd02ki98")
      elseif grf->(dbseek(pki)) .and. grf->pm="0"
        VstavkaRasp(kl,pki,"bd02ki98",grf->kod200#"*")
      endif
      bd02ki98->(dbskip())
    enddo
  enddo
  FileEr()
  setcolor("n/bg")
  clear
return nil
*---------------------------------------------------------------------------
static func OpenBd(path_bas)
Local aBD200:={{"CEX","C",2,0},{"CHERT","C",13,0},{"PS","C",1,0},{"VP","C",1,0},;
                {"CP","C",2,0},{"K1","N",8,0},;
                {"KOLM11","N",9,0},{"KOLM12","N",9,0},{"KOLM13","N",9,0},;
                {"KOLM21","N",9,0},{"KOLM22","N",9,0},{"KOLM23","N",9,0},;
                {"KOLM31","N",9,0},{"KOLM32","N",9,0},{"KOLM33","N",9,0},;
                {"KOLM41","N",9,0},{"KOLM42","N",9,0},{"KOLM43","N",9,0},;
                {"KOLN11","N",9,0},{"KOLN12","N",9,0},{"KOLN13","N",9,0},;
                {"KOLN21","N",9,0},{"KOLN22","N",9,0},{"KOLN23","N",9,0},;
                {"KOLN31","N",9,0},{"KOLN32","N",9,0},{"KOLN33","N",9,0},;
                {"KOLN41","N",9,0},{"KOLN42","N",9,0},{"KOLN43","N",9,0}}
Local aBDRasp:={{"CEX","C",2,0},{"CHERT","C",13,0},{"PS","C",1,0},{"VP","C",1,0},;
                {"CP","C",2,0},{"KI","C",4,0},{"K1","N",8,0},;
                {"KOLN11","N",9,0},{"KOLN12","N",9,0},{"KOLN13","N",9,0},;
                {"KOLN21","N",9,0},{"KOLN22","N",9,0},{"KOLN23","N",9,0},;
                {"KOLN31","N",9,0},{"KOLN32","N",9,0},{"KOLN33","N",9,0},;
                {"KOLN41","N",9,0},{"KOLN42","N",9,0},{"KOLN43","N",9,0}}
Local n_baza,n_ind,i,;
      ar_bd:={{'grf','grf','kod'},;
              {'bd02ki04','',''},;
              {'bd02ki','',''},;
              {'bd02ki98','',''},;
              {'blanks','',''},{'blanksm','',''},;
              {'blanphm','',''},{'blanph','',''},;
              {'bd200','bd200','cex+chert+ps+vp+cp'},;
              {'bdrasp','bdrasp','cex+chert+ps+vp+cp+ki'}}

 if !File(vr:=path_bas+"BASESPDO.dbf") .or. !File(vr:=path_bas+"BASESPDO.ntx")
    alert("Нет файла "+vr)
    Clear All
    Close All
    Quit
 endif
 Use (path_bas+"BASESPDO") index (path_bas+"BASESPDO") Shared New Readonly
 For i:=1 to len(ar_bd)
    If BASESPDO->(!DbSeek(ar_bd[i,1]))
        alert("Нет файла "+ar_bd[i,1]+".dbf в BASESPDO",'w+/r')
        //Restore Screen
        Clear All
        Close All
        Quit
    End
    n_baza=AllTrim(BASESPDO->path)+ar_bd[i,1]
    if ar_bd[i,1]="bd200"
      n_baz_200=n_baza
    elseif ar_bd[i,1]="bdrasp"
      n_baz_rasp=n_baza
    endif

    If !File(n_baza+".dbf")
      alert("Нет файла "+ar_bd[i,1]+".dbf",'w+/r')
      //Restore Screen
      Clear All
      Close All
      Quit
    EndIf
    *------------------
    If empty(ar_bd[i,3])
      If !Setka(n_baza,.t.,5)
        alert('Файл '+ar_bd[i,1]+'.dbf не доступен',"w+/r")
        //Restore Screen
        Clear All
        Close All
        Quit
      End
    Else
    *-------------------
      If basespdo->(!DbSeek(ar_bd[i,2]+".ntx"))
        alert('Нет '+ar_bd[i,2]+'.ntx в BASESPDO.dbf',"w+/r")
        //Restore Screen
        Clear All
        Close All
        Quit
      End
//      n_baza=AllTrim(basespdo->path)+ar_bd[i,1]
      n_ind:=alltrim(basespdo->path)+ar_bd[i,2]
      if ar_bd[i,1]="bd200"
        n_ind_200=n_ind
      elseif ar_bd[i,1]="bdrasp"
        n_ind_rasp=n_ind
      endif
      If !File(n_ind+".ntx") .OR.;
        ar_bd[i,1] $ 'grf&grf_cex&bd200&bdrasp'
        If !Setka(n_baza,.t.,5)
          alert('Файл '+ar_bd[i,1]+'.dbf не доступен',"w+/r")
          //Restore Screen
          Clear All
          Close All
          Quit
        Else
          @ 10,10 say "Создается Индексный файл "+ar_bd[i,2]+".NTX    " 
          Index on &(ar_bd[i,3]) to (n_ind)
          close &(ar_bd[i,1])
        End
      End
      If !Setka(n_baza,.t.,5)
        alert('Файл '+ar_bd[i,1]+'.dbf не доступен',"w+/r")
        //Restore Screen
        Clear All
        Close All
        Quit
      Else
        Set index to (n_ind)
      End
    End
//22.05.12 Макарова создание временных баз по 200 ки и распоряжениям (чтобы не удалять имеющиеся)
    If ar_bd[i,1]$"bd200_bdrasp"
      close (ar_bd[i,1])
      dbcreate(n_baza+"n.dbf",iif(ar_bd[i,1]="bd200",aBD200,aBDRasp))
      AlNetUseMN(n_baza+"n",.T.,5,ar_bd[i,1],.F.)
      index on &(ar_bd[i,3]) to (n_ind+"n.ntx")
//      dbcreate(n_baza+".dbf",aBD200)
      Set index to (n_ind+"n")
    EndIf
 Next

 Close BASESPDO

return nil
*----------------------------------------------
Static Func schKol200(kl,bazKi)
Local kodI,nKv,nPeriod,pNum,k1_200,kol200,vrKol,baza
  k1_200:=0
  bd200->k1:=k1_200
  if blanks->(!dbseek(kl))
    return .F.
  endif
  If Blanks->Perevod # 0
    Select BlanPh
    If BlanPh->(!dbseek(kl))
      return .F.
    End
    pNum:=BlanPhM->Num
    if BlanPhM->(!dbseek(pNum))
      return .F.
    endif
    baza:="blanphm"
  Else
    pNum:=blanks->Num
    if blanksm->(!dbseek(pNum))
      return .F.
    endif
    baza:="blanksm"
  EndIf
  //pNum:=blanks->Num
  grf->(dbgotop())
  do while grf->(!eof())
    if grf->kod200#"*"
      grf->(dbskip())
      loop
    endif
    kodI:=grf->kod
    if (baza)->(!dbseek(pNum+kodI))
      grf->(dbskip())
      loop
    endif
    kol200:=0
    for nKv:=1 to 4 //по всем кварталам
      for nPeriod:=1 to 3 //по всем периодам квартала
        k1_200+=(vrKol:=(baza)->&("kolm"+str(nKv,1,0)+str(nPeriod,1,0)))//накопление планого кол.
        kol200+=vrKol
        bd200->&("kolm"+str(nKv,1,0)+str(nPeriod,1,0))+=vrKol//
        bd200->&("koln"+str(nKv,1,0)+str(nPeriod,1,0))+=kol200//накопление
      next
    next
    grf->(dbskip())
  enddo
  bd200->k1:=k1_200
  (bazKi)->k1:=k1_200
  (bazKi)->k2:=0
Return .T.
*----------------------------------------------
Static Func schKolRasp(kl,pki,bazKi,flRasp)
Local nKv,nPeriod,pNum,k1_Rasp,kolRasp,vrKol,baza
  k1_Rasp:=0
  if blanks->(!dbseek(kl))
    return .F.
  endif
  kolRasp:=0
  If Blanks->Perevod # 0
    Select BlanPh
    If BlanPh->(!dbseek(kl))
      return .F.
    End
    pNum:=BlanPhM->Num
    if BlanPhM->(!dbseek(pNum+pki))
      return .F.
    endif
    baza:="blanphm"
  Else
    pNum:=blanks->Num
    if blanksm->(!dbseek(pNum+pki))
      return .F.
    endif
    baza:="blanksm"
  EndIf
  for nKv:=1 to 4 //по всем кварталам
    for nPeriod:=1 to 3 //по всем периодам квартала
      k1_Rasp+=(vrKol:=(baza)->&("kolm"+str(nKv,1,0)+str(nPeriod,1,0)))//накопление планого кол.
      kolRasp+=vrKol
      if flRasp
        bdRasp->&("koln"+str(nKv,1,0)+str(nPeriod,1,0))+=kolRasp//накопление
      endif
    next
  next
  if flRasp
    bdRasp->k1:=k1_Rasp
  endif
  (bazKi)->k1:=k1_Rasp
  (bazKi)->k2:=0
Return .T.
*----------------------------------------------
static func Vstavka200(kl,pki,baza)
  if bd200->(!dbseek(kl))
    bd200->(dbappend())
    bd200->cex:=(baza)->cex
    bd200->chert:=(baza)->chert
    bd200->ps:=(baza)->ps
    bd200->vp:=(baza)->vp
    bd200->cp:=(baza)->cp
    bd200->kolm11:=0; bd200->kolm12:=0; bd200->kolm13:=0
    bd200->kolm21:=0; bd200->kolm22:=0; bd200->kolm23:=0
    bd200->kolm31:=0; bd200->kolm32:=0; bd200->kolm33:=0
    bd200->kolm41:=0; bd200->kolm42:=0; bd200->kolm43:=0
    bd200->koln11:=0; bd200->koln12:=0; bd200->koln13:=0
    bd200->koln21:=0; bd200->koln22:=0; bd200->koln23:=0
    bd200->koln31:=0; bd200->koln32:=0; bd200->koln33:=0
    bd200->koln41:=0; bd200->koln42:=0; bd200->koln43:=0
  endif
  schKol200(kl,baza)

return
//
*----------------------------------------------
static func VstavkaRasp(kl,pki,baza,flRasp)
  if flRasp
    if bdRasp->(!dbseek(kl+pki))
      bdRasp->(dbappend())
      bdRasp->cex:=(baza)->cex
      bdRasp->chert:=(baza)->chert
      bdRasp->ps:=(baza)->ps
      bdRasp->vp:=(baza)->vp
      bdRasp->cp:=(baza)->cp
      bdRasp->ki:=pki
      bdRasp->koln11:=0; bdRasp->koln12:=0; bdRasp->koln13:=0
      bdRasp->koln21:=0; bdRasp->koln22:=0; bdRasp->koln23:=0
      bdRasp->koln31:=0; bdRasp->koln32:=0; bdRasp->koln33:=0
      bdRasp->koln41:=0; bdRasp->koln42:=0; bdRasp->koln43:=0
    endif
  endif
  schKolRasp(kl,pki,baza,flRasp)

return
*-----------------------------------------------------------
Static Func FileEr()
Local kol_lz
Local arf:={"Blanks.ntx","Blanksm.ntx","Blanph.ntx","Blanphm.ntx","Bd02ki1.ntx","Bdki041.ntx","Bdki981.ntx"},i
      ar_bd:={'grf','bd02ki','bd02ki04','bd02ki98','blanks','blanksm','blanphm','blanph'} //,'bd200',;
             //'bdrasp'}

kol_lz:=bd200->(lastrec())
close bd200
if kol_lz>0
  if Ferase(n_ind_200+".ntx")=-1
    alert("Ошибка удаления "+n_ind_200+".ntx - "+str(ferror()))
    return
  endif
  if Ferase(n_baz_200+".dbf")=-1
    alert("Ошибка удаления "+n_baz_200+".dbf - "+str(ferror()))
    return
  endif
  if frename(n_baz_200+"n.dbf",n_baz_200+".dbf")=-1
    alert("Ошибка переименования bd200n.dbf в "+n_baz_200+".dbf - "+str(ferror()))
    return
  endif
  if frename(n_ind_200+"n.ntx",n_ind_200+".ntx")=-1
    alert("Ошибка переименования bd200n.ntx в "+n_ind_200+".ntx - "+str(ferror()))
    return
  endif
endif
kol_lz:=bdrasp->(lastrec())
close bdrasp
if kol_lz>0
  if Ferase(n_ind_rasp+".ntx")=-1
    alert("Ошибка удаления "+n_ind_rasp+".ntx - "+str(ferror()))
    return
  endif
  if Ferase(n_baz_rasp+".dbf")=-1
    alert("Ошибка удаления "+n_baz_rasp+".dbf - "+str(ferror()))
    return
  endif
  if Frename(n_baz_rasp+"n.dbf",n_baz_rasp+".dbf")=-1
    alert("Ошибка переименования bdrasp.dbf в "+n_baz_rasp+".dbf - "+str(ferror()))
    return
  endif
  if Frename(n_ind_rasp+"n.ntx",n_ind_rasp+".ntx")=-1
    alert("Ошибка переименования bdrasp.ntx в "+n_ind_rasp+".ntx - "+str(ferror()))
    return
  endif
endif
For i:=1 to Len(ar_bd)
    close (ar_bd[i])
Next
For i:=1 to Len(arF)
  if file(arF[i])
    Ferase(arF[i])
  endif
Next
Return nil
//
