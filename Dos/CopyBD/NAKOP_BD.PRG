#include "box.ch"

function nkp_bdnc(path_ASU,path_PDO,np_ASU,np_PDO,dataASU,path_Sm50)
//Local stroc:="", chis,mes,god,rzncPok,npASU:=0,arPk:={}
Local i, j, cSi,arPromSk:={}
Local  npPDO:=0, cSScreen
//Local strc_ncpk:={{'NP','N',3,0},{'DD_VV','C',2,0},{'SIA','C',0,0}}
  set softseek on
  set confirm on
//  chis:=left(dataASU,2)
//  mes:=substr(dataASU,4,2)
//  god:=right(dataASU,2)
//  npASU:=val(np_ASU)  
  
  // Цеха промежуточного хранения брать из таблицы
  // Пр. группы ="15"
  // Накопить в массив все пары цех-склад
  if !MYNetUse(path_Sm50+"sm50"+".dbf",.T.,6)
    alert("Ошибка открытия SM50 на сервере ПДО!")
    close all
    setcolor("w/n")
    clear
    QUIT
  endif
  Locate for pr_gr="15"  
  do while sm50->(!eof()) .and. sm50->pr_gr="15"
    aadd(arPromSk,sm50->(ceh+ceh2))
    skip 
  enddo 
  close sm50   
  
////Макарова 18.11.09 доп проверка на поколения, чтоб ошибочная новая база не прошла
//  if ((rzncPok:=npASU-val(np_PDO))<0 .or. rzncPok>80).and.;
//      (1000+rzncPok<0 .or. 1000+rzncPok>80)
//    alert("BD02NC неверный на сервере АСУП: старое поколение!")
//    close all
//    return .f.
//  endif
//  npPDO:=iif(empty(np_PDO) .or. !fileMN(path_PDO+"bd02nc.dbf",10) .or. (npASU>val(np_PDO) .and. ((1000-npASU)+val(np_PDO) < 81 )),-1000,val(np_PDO))
  npPDO:=iif(empty(np_PDO) .or. !fileMN(path_PDO+"bd02nc.dbf",10),0,val(np_PDO))
//  flRazn:=((npASU-npPDO)<0)
//  cSScreen:=savescreen(0,0,maxrow(),maxcol())
//  if !fileMN(path_PDO+"ncpk"+god+mes+".dbf",10)
//    DbCreate(path_PDO+"ncpk"+god+mes+".dbf",strc_ncpk)
//  endif

//  if !MYNetUse(path_PDO+"ncpk"+god+mes+".dbf",.T.,6)
//    close all
//    setcolor("w/n")
//    clear
//    QUIT
//  endif
//  index on str(np,3,0) to (path_PDO+"ncpk"+god+mes)
//  if !("ncpk"+god+mes)->(dbseek(np_ASU))
//    ("ncpk"+god+mes)->(dbappend())
//    ("ncpk"+god+mes)->np:=npASU
//    ("ncpk"+god+mes)->dd_vv:=chis
//  endif
  if npPDO#0 //-1000
    FileCopy((path_PDO+"bd02nc.dbf"),(path_PDO+"bd02nc_.dbf"))
    nErr:=ErrorCode(.T.)
    If nErr!=0
        my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
        @ 12,19 Say'    Ошибка копирования файла   '
        @ 13,19 Say'        BD02NC - '+Str(nErr,2)
        @ 14,19 Say'        на сервере ПДО.      '
        Inkey(0)
        close all
        setcolor("w/n")
        clear
        QUIT
    EndIf
  endif
  FileCopy((path_ASU+"bd02nc.dbf"),(path_PDO+"bd02ncn.dbf"))
  nErr:=ErrorCode(.T.)
  If nErr!=0
      my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
      @ 12,19 Say'    Ошибка копирования файла   '
      @ 13,19 Say'        BD02NC - '+Str(nErr,2)
      @ 14,19 Say'         с сервера ОАСУП.      '
      Inkey(0)
      close all
      setcolor("w/n")
      clear
      QUIT
  EndIf
  if !MYNetUse(path_PDO+"bd02ncn",.T.,6)
    close all
    setcolor("w/n")
    clear
    QUIT
  endif
  if npPDO=0 //-1000
    do while !eof()
      if ((j:=ascan(arPromSk,bd02ncn->(cex+cp)))>0)
//      if bd02ncn->(cex+cp)="5663"
        bd02ncn->(dbdelete())
        bd02ncn->(dbskip())
        loop
      endif
      if (j:=ascan(arPromSk,{|x| bd02ncn->cex=right(x,2)}))>0
        bd02ncn->cex:=left(arPromSk[j],2)
//      if bd02ncn->cex="63"
//        bd02ncn->cex:="56"
      endif
//      if ("ncpk"+god+mes)->(dbseek(str(bd02ncn->np,3,0)))
//        if !empty(("ncpk"+god+mes)->dd_vv)
//          bd02ncn->dd_vv:=("ncpk"+god+mes)->dd_vv
//        else
//          if ascan(arPk,bd02ncn->np)=0
//            dat:="  "
//            @ 8,10 say "Новое поколение-"+np_ASU+",для поколения  "+str(np,3,0)+" введите день месяца " get dat picture "@K 99" color "w+/b"
//            read
//            restscreen(0,0,maxrow(),maxcol(),cSScreen)
//            if !empty(dat)
//              dat:=padl(alltrim(dat),2,"0")
//              bd02ncn->dd_vv:=dat
//              ("ncpk"+god+mes)->dd_vv:=dat
//            else
//              aadd(arPk,bd02ncn->np)
//            endif
//          endif
//          //stroc+=iif(!empty(stroc),"",",")+str(bd02ncn->np,3,0)
//        endif
//      else
//        ("ncpk"+god+mes)->(dbappend())
//        ("ncpk"+god+mes)->np:=bd02ncn->np
//        if ascan(arPk,bd02ncn->np)=0
//          dat:="  "
//          @ 8,10 say "Новое поколение-"+np_ASU+",для поколения  "+str(np,3,0)+" введите день месяца " get dat picture "@K 99" color "w+/b"
//          read
//          restscreen(0,0,maxrow(),maxcol(),cSScreen)
//          if !empty(dat)
//            dat:=padl(alltrim(dat),2,"0")
//            bd02ncn->dd_vv:=dat
//            ("ncpk"+god+mes)->dd_vv:=dat
//          else
//            aadd(arPk,bd02ncn->np)
//          endif
//        endif
//        //stroc+=iif(!empty(stroc),"",",")+str(bd02ncn->np,3,0)
//      endif
      skip
    enddo
    select bd02ncn
    pack
    close bd02ncn
//    if len(arPk)>0
//      asort(arPk)
//      stroc:=str(arPk[1],3,0)
//      for i=2 to len(arPk)
//       stroc+=", "+str(arPk[i],3,0)
//      next
//      alert("Нет даты за поколения:;"+stroc+";BD02NC не будет обновлен!")
//      close all
//      return .f.
//    endif
    Rename (path_PDO+"bd02ncn.dbf") To (path_PDO+"bd02nc.dbf")
    Brak_RS()
  else
    if !MYNetUse(path_PDO+"bd02nc_",.T.,6)
      close all
      setcolor("w/n")
      clear
      QUIT
    endif
    select bd02ncn
    do while !eof()
//      if (flRazn .and. (np > npASU .and. np<= npPDO )) .or.;
//        (!flRazn .and. (np <= npPDO .or. np > npASU ))
      if (np<= npPDO)
        skip
        loop
      endif
      if ((j:=ascan(arPromSk,bd02ncn->(cex+cp)))>0)
//      if bd02ncn->(cex+cp)="5663"
        skip
        loop
      endif
      bd02nc_->(dbappend())
      for i=1 to fcount()
        bd02nc_->(fieldput(i,bd02ncn->(fieldget(i))))
      next
      if (j:=ascan(arPromSk,{|x| bd02nc_->cex=right(x,2)}))>0
        bd02nc_->cex:=left(arPromSk[j],2)
//      if bd02nc_->cex="63"
//        bd02nc_->cex:="56"
      endif
//      if ("ncpk"+god+mes)->(dbseek(str(bd02ncn->np,3,0)))
//        if !empty(("ncpk"+god+mes)->dd_vv)
//          bd02nc_->dd_vv:=("ncpk"+god+mes)->dd_vv
//        else
//          if ascan(arPk,bd02ncn->np)=0
//            dat:="  "
//            @ 8,10 say "Новое поколение-"+np_ASU+",для поколения  "+str(np,3,0)+" введите день месяца " get dat picture "@K 99" color "w+/b"
//            read
//            restscreen(0,0,maxrow(),maxcol(),cSScreen)
//            if !empty(dat)
//              dat:=padl(alltrim(dat),2,"0")
//              bd02nc_->dd_vv:=dat
//              ("ncpk"+god+mes)->dd_vv:=dat
//            else
//              aadd(arPk,bd02ncn->np)
//            endif
//          endif
//          //stroc+=iif(!empty(stroc),"",",")+str(bd02ncn->np,3,0)
//        endif
//      else
//        ("ncpk"+god+mes)->(dbappend())
//        ("ncpk"+god+mes)->np:=bd02ncn->np
//        if ascan(arPk,bd02ncn->np)=0
//          dat:="  "
//          @ 8,10 say "Новое поколение-"+np_ASU+",для поколения  "+str(np,3,0)+" введите день месяца " get dat picture "@K 99" color "w+/b"
//          read
//          restscreen(0,0,maxrow(),maxcol(),cSScreen)
//          if !empty(dat)
//            dat:=padl(alltrim(dat),2,"0")
//            bd02nc_->dd_vv:=dat
//            ("ncpk"+god+mes)->dd_vv:=dat
//          else
//            aadd(arPk,bd02ncn->np)
//          endif
//        endif
//        //stroc+=iif(!empty(stroc),"",",")+str(bd02ncn->np,3,0)
//      endif
      skip
    enddo
    close bd02ncn
    close bd02nc_
//    if len(arPk)>0
//      asort(arPk)
//      stroc:=str(arPk[1],3,0)
//      for i=2 to len(arPk)
//       stroc+=", "+str(arPk[i],3,0)
//      next
//      alert("Нет даты за поколения:;"+stroc+";BD02NC не будет обновлен!")
//      close all
//      return .f.
//    endif
    cSi:=getsi(path_PDO+"bd02ncn.dbf")
    putsi(path_PDO+"bd02nc_.dbf",cSi)
    if ferase(path_PDO+"bd02ncn.dbf")#0
      alert("Ошибка при удалении bd02ncn - "+str(ferror()))
    endif
    if ferase(path_PDO+"bd02nc.dbf")#0
      alert("Ошибка при удалении bd02nc - "+str(ferror()))
      close all
      setcolor("w/n")
      clear
      QUIT
    endif
    Rename (path_PDO+"bd02nc_.dbf") To (path_PDO+"bd02nc.dbf")
    Brak_RS()
  endif
//  close ("ncpk"+god+mes)
//  cSi:="NC"+god+mes+dataASU+np_ASU
//  putsi(path_PDO+"ncpk"+god+mes+".dbf",cSi)
return .t.
