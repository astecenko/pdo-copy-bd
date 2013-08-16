#include "box.ch"
procedure sklad_f
return
/*Процедура накопления по распоряжениям, сданным на склады сбыта*/
Procedure Sklad_nakl()
Local n_skl1,ex:=.T.,skl_Si:="",bu,pei,pcena,soob,flRazn:=.F.,npASU,npPDO
 If !FileMN(n_skl_nakl+".dbf",10)
    DBCreate(n_skl_nakl,askl_nakl)
 EndIf
 skl_Si:=GetSi(n_skl_nakl+".dbf")
 For i:=1 To Len(aASU)
    If aASU[i,1]=="bd02nc"
       Exit
    EndIf
 Next
 if (substr(skl_Si,10,2)=substr(aASU[i,4],4,2));
      .and. substr(skl_Si,15,3)>=aASU[i,3] 
    Close All
    Return .T.
 endif 
 if (substr(skl_Si,10,2)<>substr(aASU[i,4],4,2))
   npPDO:=0
 else
   npPDO:=val(substr(skl_Si,15,3))
 endif
 Set Color To W+/W
 @ 6,8 Clear To 19,71
 For i:=1 To Len(aPDO)
    If aPDO[i,1]=="bd02vc"
       Exit
    EndIf
 Next
 If MYNetUse(aPDO[i,2]+aPDO[i,1],.F.,5,.T.)
    Set Index To (aPDO[i,2]+aPDO[i,1])
 Else
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say' Файл bd02vc.dbf не доступен '
    @ 13,19 Say'   Невозможно обновить данные. '
    @ 14,19 Say'    Нажмите любую клавишу ...  '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return .F.
 EndIf

 For i:=1 To Len(aPDO)
   If aPDO[i,1]=="ns02oc"
      If MYNetUse(aPDO[i,2]+aPDO[i,1],.F.,5,.T.)
         Index On chert+pcen To (aPDO[i,2]+"ns02oc")
         Exit
      Else
         my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
         @ 12,19 Say' Файл NS02OC.DBF не доступен '
         @ 13,19 Say' Невозможно обновить данные. '
         @ 14,19 Say'  Нажмите любую клавишу ...  '
         InKey(0)
         Restore Screen
         Clear Screen
         Close All
         Return .F.
      EndIf
   EndIf
 Next

 For i:=1 To Len(aPDO)
   If aPDO[i,1]=="bd02nc"
      Exit
   EndIf
 Next
 If MYNetUse(aPDO[i,2]+aPDO[i,1],.F.,5,.T.)
    //если номер поколения bd02nc != НП skl_nakl, то дозаписываю все записи с НП

    If SubStr(skl_Si,15,3)!=aASU[i,3]
       n_skl1=SubStr(n_skl_nakl,1,Rat("\",n_skl_nakl))+"skl1"
       If MYNetUse(n_skl_nakl,.T.,5)
          my_box(11,21,15,51,B_DOUBLE+chr(32),"W+/B")
          @ 12,22 Say'  Идет обработка накладных  '
          @ 13,22 Say'   сданных на склады сбыта  '
          npASU:=val(aASU[i,3])
//          npPDO:=iif(empty(aPDO[i,3]),-1000,val(aPDO[i,3]))
//          flRazn:=((npASU-npPDO)<0)
          Do While !bd02nc->(Eof())
             @ 14,31 Say bd02nc->(RecNo())
             /*If bd02nc->np==Val(aASU[i,3]) .And. ;*/
//             If ((!flRazn .and. (bd02nc->np > npPDO .and. bd02nc->np<= npASU )) .Or.;
//                (flRazn .and. (bd02nc->np <= npASU .or. bd02nc->np > npPDO ))) .And. ;
             If (bd02nc->np > npPDO .and. bd02nc->np<= npASU )
                (bd02nc->cp="20".Or.bd02nc->cp="22".Or.;
                bd02nc->cp="33".Or.;
                bd02nc->cp="39".Or.bd02nc->cp="42".Or.bd02nc->cp="57")
                skl_nakl->(dbAppend())

                skl_nakl->cex=bd02nc->cex
                skl_nakl->chert=bd02nc->chert
                skl_nakl->ps=bd02nc->ps
                skl_nakl->vp=bd02nc->vp
                skl_nakl->cp=bd02nc->cp
                skl_nakl->chmes=bd02nc->dd_vv
                skl_nakl->mes=SubStr(aASU[i,4],4,2)
                skl_nakl->god=SubStr(aASU[i,4],7,2)
                skl_nakl->np=bd02nc->np
                skl_nakl->nnakl=bd02nc->nnakl
                skl_nakl->ki=bd02nc->ki   //может корректироваться пользователем
                skl_nakl->ki_nakl=bd02nc->ki
                skl_nakl->pr=bd02nc->pr
                skl_nakl->kol=bd02nc->kol
                skl_nakl->nras=bd02nc->nras
                skl_nakl->vd=bd02nc->vd
                If skl_nakl->cp="42" //.Or. skl_nakl->cp="57"
                   //берем цену из внутризаводского ценника
                   If bd02vc->(dbSeek(skl_nakl->cex+skl_nakl->chert+skl_nakl->ps))
                      bu:='80'    //перевод исходной цены в основную цену 
                      pitog:=0
                      For k:=6 To 33
                        pitog:=pitog+bd02vc->(fieldget(k))
                      Next
                      If !SM071(@bu,bd02vc->ei,pitog,@pcena,,@pei )
                         soob := 'Ошибка в приведении цены. Нажмите любую клавишу.'
                      EndIf
                      If !Empty(soob)
                         ? soob
                         InKey(0)
                         Clear Screen
                         Quit
                      Else
                         If Len(AllTrim(Str(pcena)))>10
                            skl_nakl->ei:=bd02vc->ei
                            skl_nakl->cena:=pitog
                         Else
                            skl_nakl->ei:=pei
                            skl_nakl->cena:=pcena
                         EndIf
                      EndIf
                   EndIf
                Else //берем цену из оптового ценника
                //PCEN - Признак цены: 0-С и Ш, 1-Э, 3-С без мех.обработки для цехов 40,41,42,56
                   If skl_nakl->vp='Э'
                      pr_cen:='1'
                   ElseIf skl_nakl->vp='Ш'
                      pr_cen:='0'
                   ElseIf skl_nakl->vp='С'
                      If skl_nakl->cex='40' .Or. skl_nakl->cex='41' .Or.;
                         skl_nakl->cex='42' .Or. skl_nakl->cex='56' .Or.;
                         skl_nakl->cex='60' .Or. skl_nakl->cex='61' .Or.;
                         skl_nakl->cex='62' /*Макарова добавила цеха 60-62*/
                         pr_cen:='3'
                         If ns02oc->(!dbSeek(skl_nakl->chert+pr_cen))
                            pr_cen:='0'
                         EndIf
                      Else
                         pr_cen:='0'
                      EndIf
                   EndIf
                   If ns02oc->(dbSeek(skl_nakl->chert+pr_cen))
                      If ns02oc->(Deleted())
                         Do While ns02oc->chert=skl_nakl->chert .And. ns02oc->pcen=pr_cen
                            If !ns02oc->(Deleted())
                               bu:='80'    //перевод исходной цены в основную цену
                               If !SM071(@bu,ns02oc->ei,ns02oc->optcen,@pcena,,@pei )
                                  soob := 'Ошибка в приведении цены. Нажмите любую клавишу.'
                               EndIf
                               If !Empty(soob)
                                  ? soob
                                  InKey(0)
                                  Clear Screen
                                  Quit
                               Else
                                  If Len(AllTrim(Str(pcena)))>10
                                     skl_nakl->cena:=ns02oc->optcen
                                     skl_nakl->ei:=ns02oc->ei
                                  Else
                                     skl_nakl->ei:=pei
                                     skl_nakl->cena:=pcena
                                  EndIf
                               EndIf
                               Exit
                            EndIf
                            ns02oc->(dbSkip())
                         EndDo
                      Else
                         bu:='80'    //перевод исходной цены в основную цену
                         If !SM071(@bu,ns02oc->ei,ns02oc->optcen,@pcena,,@pei )
                            soob := 'Ошибка в приведении цены. Нажмите любую клавишу.'
                         EndIf
                         If !Empty(soob)
                            ? soob
                            InKey(0)
                            Clear Screen
                            Quit
                         Else
                            If Len(AllTrim(Str(pcena)))>10
                               skl_nakl->cena:=ns02oc->optcen
                               skl_nakl->ei:=ns02oc->ei
                            Else
                               skl_nakl->ei:=pei
                               skl_nakl->cena:=pcena
                            EndIf
                         EndIf
                      EndIf
                   EndIf
                EndIf
             EndIf
             bd02nc->(dbSkip())
          EndDo
          Select skl_nakl
          Set Color To W+/W
          @ 11,21 Clear To 16,53
          my_box(11,21,14,51,B_DOUBLE+chr(32),"W+/B")
          Set Color To W+*/B
          @ 12,22 Say'Идет сортировка SKL_NAKL.DBF'
          Sort To (n_skl1) On Cex /A, Chert /A, Ps /A, Vp /A, Cp /A,;
                                    God /A, Mes /A, Chmes /A, Nnakl /A
          Close skl_nakl
          Delete File (n_skl_nakl+".dbf")
          Delete File (n_skl_nakl+".dbt")
          Rename (n_skl1+".dbf") To (n_skl_nakl+".dbf")
          Rename (n_skl1+".dbt") To (n_skl_nakl+".dbt")
          skl_Si:="SKLADN"+aASU[i,4]+aASU[i,3]
          PutSi(n_skl_nakl+".dbf",skl_Si)
       Else
          my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
          @ 12,19 Say' Файл SKL_NAKL.DBF не доступен '
          @ 13,19 Say' Невозможно обновить данные. '
          @ 14,19 Say'  Нажмите любую клавишу ...  '
          InKey(0)
          Restore Screen
          Clear Screen
          Close All
          Return .F.
       EndIf
    EndIf
 Else
    my_box(11,18,15,51,B_DOUBLE+chr(32),"W+/R")
    @ 12,19 Say' Файл BD02NC.dbf не доступен '
    @ 13,19 Say' Невозможно обновить данные. '
    @ 14,19 Say'  Нажмите любую клавишу ...  '
    InKey(0)
    Restore Screen
    Clear Screen
    Close All
    Return .F.
 EndIf
 Close All
Return .T.
/************** ФОРМИРОВАНИЕ БД карт учета по складам сбыта=цехам получателям от плана *******/
Procedure Form_Sklad()
 blanks->(dbGoTop())
 blanksiz->(dbGoTop())
 my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
 @ 13,22 Say' Идет подготовка базы данных SKLAD  '

 Do While !sklad->(Eof())
    @ 14,32 Say sklad->(RecNo())
    sklad->(dbDelete())
    sklad->(dbSkip())
 EndDo

 my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
 Set Color To W+*/B
 Select sklad
 @ 13,22 Say " Идет индексация базы данных SKLAD  "
 Index On sklad->ki+sklad->cex+sklad->chert+sklad->ps+sklad->vp+;
          sklad->cp To (n_sklad+".ntx")

 my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
 @ 13,21 Say'      Идет обработка SKLAD.dbf       '
 Do While !blanks->(Eof())
    @ 14,35 Say blanks->(RecNo())
    If blanks->cp="20" .Or. blanks->cp="22" .Or. blanks->cp="33" .Or.;
       blanks->cp="39" .Or. blanks->cp="42" .Or. blanks->cp="57"
       blanksiz->(dbSeek(blanks->num))
       Do While blanksiz->num=blanks->num     //включаем только распоряжения
          If blanksiz->ki="0049" .Or. blanksiz->ki="0065" .Or.;
             (blanksiz->ki>="0122" .And. blanksiz->ki<="0199") .Or.;
             ((blanks->cp="20") .And. blanksiz->ki>="0800" .And. blanksiz->ki<="0899") .Or.;
             (blanksiz->ki>="1000" .And. blanksiz->ki<="6999") .Or.;
             (blanksiz->ki>="8000" .And. blanksiz->ki<="9999")
             If sklad->(dbSeek(blanksiz->ki+blanks->cex+blanks->chert+;
                blanks->ps+blanks->vp+blanks->cp))
                If sklad->(Deleted())
                   sklad->(dbRecall())
                EndIf
                sklad->kol1=blanksiz->kol1
                sklad->kol2=blanksiz->kol2
                sklad->kol3=blanksiz->kol3
                sklad->kol4=blanksiz->kol4
                sklad->num:=blanks->num
                sklad->new_pos:=blanks->new_pos
                sklad->udal_date:=blanks->udal_date
                sklad->perevod:=blanks->perevod
                sklad->name_iz:=blanksiz->name_iz
             Else
                sklad->(dbAppend())
                sklad->ki:=blanksiz->ki
                sklad->cex:=blanks->cex
                sklad->chert:=blanks->chert
                sklad->ps:=blanks->ps
                sklad->vp:=blanks->vp
                sklad->cp:=blanks->cp
                sklad->num:=blanks->num
                sklad->kol1=blanksiz->kol1
                sklad->kol2=blanksiz->kol2
                sklad->kol3=blanksiz->kol3
                sklad->kol4=blanksiz->kol4
                sklad->new_pos:=blanks->new_pos
                sklad->udal_date:=blanks->udal_date
                sklad->perevod:=blanks->perevod
                sklad->name_iz:=blanksiz->name_iz
             EndIf
          EndIf
          blanksiz->(dbSkip())
       EndDo
    EndIf
    blanks->(dbSkip())
 EndDo

//Переношу позиции удаленные из sklad в sklad_s
 sklad->(dbGoTop())
 Do While !sklad->(Eof())
    If sklad->(Deleted())
       sklad_s->(dbAppend())
       sklad_s->ki:=sklad->ki
       sklad_s->cex:=sklad->cex
       sklad_s->chert:=sklad->chert
       sklad_s->ps:=sklad->ps
       sklad_s->vp:=sklad->vp
       sklad_s->cp:=sklad->cp
       sklad_s->num:=sklad->num
       sklad_s->kol1=sklad->kol1
       sklad_s->kol2=sklad->kol2
       sklad_s->kol3=sklad->kol3
       sklad_s->kol4=sklad->kol4
       sklad_s->new_pos:=sklad->new_pos
       sklad_s->udal_date:=SubStr(blanks_Si,7,4)
       sklad_s->perevod:=sklad->perevod
       sklad_s->name_iz:=sklad->name_iz
       sklad_s->dopolnen:=sklad->dopolnen
    EndIf
    sklad->(dbSkip())
 EndDo

 Select sklad
 Pack
 my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
 Set Color To W+*/B
 @ 13,22 Say " Идет сортировка базы данных SKLAD "
 n_sklad1=SubStr(n_sklad,1,Rat("\",n_sklad))+"sklad1"
 Copy To (n_sklad1)
 Close sklad
 Delete File (n_sklad+".dbf")
 Rename (n_sklad1+".dbf") To (n_sklad+".dbf")
 Delete File (n_sklad+".dbt")
 Rename (n_sklad1+".dbt") To (n_sklad+".dbt")
 Delete File (n_sklad+".ntx")
 PutSi(n_sklad+".dbf","SKLAD "+SubStr(blanks_Si,7,11))

 Select sklad_s
 @ 13,22 Say " Идет сортировка базы данных SKLAD_S"
 n_sklad1=SubStr(n_sklad_s,1,Rat("\",n_sklad_s))+"sklad1"
 Sort To (n_sklad1) On ki,cex,chert,ps,vp,cp
 Close sklad_s
 Delete File (n_sklad_s+".dbf")
 Rename (n_sklad1+".dbf") To (n_sklad_s+".dbf")
 Delete File (n_sklad_s+".dbt")
 Rename (n_sklad1+".dbt") To (n_sklad_s+".dbt")
 PutSi(n_sklad_s+".dbf","SKLADS"+SubStr(blanks_Si,7,11))
Return

