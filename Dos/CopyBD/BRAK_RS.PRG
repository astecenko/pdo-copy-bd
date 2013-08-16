***********   Разработчик - Макарова Наталья Анатольевна   ****************
***********                   2007 г.                      ****************
***********   Модуль дозаписи брака из BD02nc в BD04rs     ****************
Func Brak_RS()
Local path_BD04,Si_Bd04,dl_si,i
Private Si_Baz2:="",pokNew,pokBD04rs,dataBD04rs,godT,mesT,dataNew,Si_Baz:=""
  //Save Screen
  setcolor("w+/b")
  Clear Screen
                              BEGIN SEQUENCE
  @ 12,10 say "Идет запись брака в расход склада                " color "gr+/b"
  for i:=1 to len(aPDO)
    if aPDO[i,1]=="bd02nc"
      path_BD02:=aPDO[i,2]
      exit
    endif
  next
  for i:=1 to len(aASU)
    if aASU[i,1]=="bd04rs"
      path_BD04:=aASU[i,2]
      exit
    endif
  next
  If !File(path_BD04+"bd04rs.dbf")
    alert(" Файл "+path_BD04+"bd04rs.dbf"+" не найден. ")
    break
  EndIf
  If !File(path_BD02+"bd02nc.dbf")
    alert(" Файл "+path_BD02+"bd02nc.dbf"+" не найден. ")
    break
  EndIf
  Si_Bd04:=GetSi(path_BD04+"bd04rs.dbf")
  dataBD04rs:=substr(Si_Bd04,10,5)
  pokBD04rs:=val(substr(Si_Bd04,15,3))
  pokBD04rs:=Iif(pokBD04rs=999,1,pokBD04rs+1)
  dl_si:=val(substr(Si_Bd04,18,3))-6
  Si_NC:=substr(Si_Bd04,21,6)
  Si_Baz:=substr(Si_Bd04,27,dl_si)
  if file("bd04rs.dbf")
    if ferase("bd04rs.dbf")=-1
      alert("При удалении файла bd04rs.dbf возникла ошибка "+ferror())
      break
    endif
  endif
  arDir:=directory("bd04rs??.dbf")
  If !MYNetUse(path_BD04+"bd04rs.dbf",.F.,5,.T.)
    alert("Файл "+path_BD04+"BD04RS.DBF не доступен")
    break
  EndIf
  close bd04rs
  copy file (path_BD04+"bd04rs.dbf") to ("bd04rs.dbf")
  Use bd04rs new
  if neterr()
    alert("Файл BD04RS.DBF не доступен")
    break
  EndIf
  if !funProv(path_BD02+"bd02nc.dbf",val(substr(Si_NC,3,3)))
    break
  endif
  if !funZap(path_BD02+"bd02nc.dbf","bd02nc",val(substr(Si_NC,3,3)))
    break
  endif
  select bd04rs
  index on sklad+chert+ps+vp+cp+dtoc(data)+vr+ndok+ki+nmash to "bd04rsv.dbf"
  copy to ("bd04rs_.dbf")
  close bd04rs
  Si_Bd04:=stuff(Si_BD04,15,3,ntoc(pokBD04rs,10,3,"0"))
  Si_Bd04:=stuff(Si_BD04,23,3,ntoc(pokNew,10,3,"0"))
  putsi("bd04rs_.dbf",Si_Bd04)
  if ferase("bd04rs.dbf")=-1
    alert("При удалении файла bd04rs.dbf возникла ошибка "+ferror())
    break
  endif
  if ferase(path_BD04+"bd04rs.dbf")=-1
    alert("При удалении файла "+path_BD04+"bd04rs.dbf возникла ошибка "+ferror())
    break
  endif
  copy file ("bd04rs_.dbf") to (path_BD04+"bd04rs.dbf")
  if !file(path_BD04+"bd04rs.dbf")
    alert("ФАЙЛ НЕ ОБНОВИЛСЯ!!!!")
    break
  endif
  for i:=1 to len(aASU)
    if aASU[i,1]=="bd04rs"
      aASU[i,3]:=ntoc(pokBD04rs,10,3,"0")
      aASU[i,5]:=substr(si_BD04,21,val(substr(si_BD04,18,3)))
      exit
    endif
  next
  funcUd()

                              END SEQUENCE
if select("bd04rs")>0
  close bd04rs
endif
setcolor("w/n")
clear
return
**********************************************************************
Static Func funProv(namFile,pok)
Local siN,mesN,godN
  siN:=GetSi(namFile)
  mesT:=substr(dataBD04rs,1,2)
  godT:=substr(dataBD04rs,4,2)
  mesN:=substr(siN,10,2)
  godN:=substr(siN,13,2)
  pokNew:=val(substr(siN,15,3))
  if godN=godT .and. mesN=mesT .and. pok<>pokNew
    return .T.
  endif
return .F.
**********************************************************************
Static Func funZap(full_name,namFile,pok)
Local strPok:="",set_dat,dat
  strPok:=ObrPok(pok,pokNew)
  If !MYNetUse(full_name,.F.,5,.T.)
    alert("Файл "+full_name+" не доступен")
    return .F.
  EndIf
  set_dat:=set(_SET_DATEFORMAT)
  set date format to "dd/mm/yyyy"
  do while (namFile)->(!eof())
    @ 12,10 say "Идет запись брака в расход склада "+str((namFile)->(recno()));
                                                     color "gr+/b"
    if ntoc((namFile)->np,10,3,"0")$strPok .and. (namFile)->cex$"04_98";
         .and. (namFile)->pr$"7"
/*      dat:=ctod((namFile)->dd_nakl+"/"+(namFile)->mm_nakl+"/20"+;
            ntoc(iif((namFile)->mm_nakl>mesT,val(godT)-1,val(godT)),10,2,"0"))*/ 
// 04.10.12 Брать дату ввода. Чтоб точно соответствовало месяцу обработки
      dat:=ctod((namFile)->dd_vv+"/"+mesT+"/20"+;
            ntoc(val(godT),10,2,"0"))
      bd04rs->(dbappend())
      bd04rs->sklad:=(namFile)->cex
      bd04rs->chert:=(namFile)->chert
      bd04rs->ps:=(namFile)->ps
      bd04rs->vp:=(namFile)->vp
      bd04rs->cp:=(namFile)->cp
      bd04rs->vr:="7"
      bd04rs->ndok:=(namFile)->nnakl
      bd04rs->npb:=(namFile)->np
      bd04rs->np:=pokBD04rs
      bd04rs->ki:=(namFile)->ki
      bd04rs->data:=dat
      bd04rs->kol:=(namFile)->kol
      bd04rs->nmash:="0000"
    endif
    (namFile)->(dbskip())
  enddo
  set date format to set_dat
  close (namFile)
return .T.
**********************************************************************
Static Func ObrPok(pokIsh,pokNew)
Local p1:='',i

//If (pokIsh > pokNew) .and. ((1000-pokIsh)+pokNew > 80 )
If (pokIsh >= pokNew) 
   Tone(1000,0.5)
   Alert('Не могу выбрать НП. Ошибка в СИ',{" OK "},"w+/r")
   Close All
   Restore Screen
   Quit
EndIf

Do While (.t.)
//   pokIsh:=Iif(pokIsh=999,0,pokIsh+1)
   pokIsh:=pokIsh+1
   p1:=p1+Padl(Alltrim(Str(pokIsh)),3,'0')+'_'
   If PokIsh = pokNew
      Exit
   EndIf
EndDo
Return p1
**********************************************************************
Static Func funcUd()
Local i, arFile:={"bd04rsv.dbf","bd04rs_.dbf"}
for i:=1 to len(arFile)
  if file(arFile[i])
    Ferase(arFile[i])
  endif
next
return nil

