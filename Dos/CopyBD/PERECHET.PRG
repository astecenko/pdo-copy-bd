******************************************************
*   ПЕРЕСЧЕТ УКОМПЛЕКТОВАННОСТИ (сброс накладных)
******************************************************
/* PRIOR - Приоритеты:
   0  - комплектовать вне очереди
   3  - для электрички
   1  - ЭП1, ЭД4
   2  - ОПЭ, НП-1, НП-2
   -----------------------------------------------
   PM - признак машины
   BS - байт состояния: 0 - начать с этого изделия
   -----------------------------------------------
*/
#include "Box.ch"
Func PerUk()
Local kl,cex1,kplan,i,ostatok,;
    ar3:={{"KI","C",4,0},{"PG","C",1,0},{"BU","C",2,0},{"OP","N",3,0},;
          {"K1","N",8,0},{"N2","N",8,0},{"K2","N",8,0},{"KSUT","N",8,0},;
          {"NB","N",8,0},{"KB","N",8,0},{"NTEK","N",8,0},{"KTEK","N",8,0},;
          {"NNMES","N",8,0},{"KNMES","N",8,0},{"VK","C",4,0},{"KORT","N",8,0},;
          {"KORM","N",8,0},{"NTEKS","N",8,0},{"KTEKS","N",8,0},;
          {"PRIOR","C",2,0},{"PM","C",1,0},{"NN","N",4,0},{"NSB","N",4,0},;
          {"NIZ","N",8,0},{"BS","C",2,0},{"KORMV","N",8,0},;
          {"BU1","C",1,0},{"BS1","C",2,0},{"NS","C",1,0}},;
    net_sn:="0060"/*,pCex
*/ //Закоментировано 9.08.09

Private kolr,ch80,nPok,pPc

Set softseek off
Set Date Format "dd/mm/yy"
//put_ki:="d:\2\"
If Substr(Si_Ki,35,3) == Substr(Si_nc,15,3)  //накладные уже обрабатывались
   Tone(1000,0.5)
   Alert('Накладные за '+Substr(Si_nc,7,8)+' уже были обработаны!';
       ,{" OK "},"w+/r")
   Close All
   Restore Screen
   Quit
End
NPok:=ObrPok()    //получить перечень поколений которые нужно обработать
If NPok == ""
   Tone(1000,0.5)
   Alert('Нет NP для обработки',{" OK "},"w+/r")
   Close All
   Restore Screen
   Quit
End
Setblink(.t.)
Cls
@ 10,20  say "Идет распределение накладных. Ждите..." color "b*/bg"

Select Bd02ki
Copy Structure to ("Bd02kiN")
Use ("Bd02KiN") new
Index on bd02kin->cex+bd02kin->chert+bd02kin->ps+bd02kin->vp+;
         bd02kin->cp to bd02kin

DbCreate("Tablki.dbf",ar3)
Use Tablki new
Index on TablKi->KI to TablKi
/*Index on Tablki->Prior+Tablki->Ki to TablKi1
Index on DesCend(Tablki->Prior+Tablki->Ki) to TablKi2
*/ //Закоментировано 9.08.09
Index on Tablki->Pm+Tablki->Ki to TablKi1
Index on DesCend(Tablki->Pm+Tablki->Ki) to TablKi2
Set Index to TablKi,TablKi1,TablKi2
Tablki->(DbSetOrder(0))

/*pCex:=''
*/ //Закоментировано 9.08.09
//ProstTekNM()
Select bd02ki
DO while bd02ki->(!eof())
   @ 13,35 say bd02ki->(recno()) color "n/bg"
/*   if pCex <> Bd02ki->Cex      //определить группу для цеха
      pCex:=Bd02ki->Cex        //Pc = '1' - заготовит. цеха
      pPc:=''
      if Tabl_Cex->(DbSeek(pCex))
         pPc:=Tabl_Cex->Pc
      end
   end
*/ //Закоментировано 9.08.09
   Select TablKi
   Zap
   Select bd02ki
   cex1:=bd02ki->Cex
   kl:=bd02ki->cex+bd02ki->chert+bd02ki->ps+bd02ki->vp+bd02ki->cp
   If Substr(kl,1,15) == '46529 574114 05'
      //Inkey(0)
   End
   ch80:=.f.
   kolr   :=0     //кол-во для распределения
   *-----------------------------------------------
   Do While kl == (bd02ki->cex+bd02ki->chert+bd02ki->ps+bd02ki->vp+bd02ki->cp)
      If IsBit(Substr(Bd02Ki->Bu,1,1),4)  //чертеж '80'
         ch80:=.t.
      End
      DobZap()
//      If grf->(DbSeek(bd02ki->ki))   //ищу в общем графике
/*      If (grf->(DbSeek(Bd02ki->Ki+pPc)) .or. grf->(DbSeek(bd02ki->ki)))
*/ //Закоментировано 9.08.09
      If grf->(DbSeek(bd02ki->ki))
/*         TablKi->PRIOR:=Padl(Alltrim(grf->PRIOR),2,'0')
*/ //Закоментировано 9.08.09
         TablKi->PM   :=grf->PM
         TablKi->NSB  :=Val(grf->NSB)
/*         TablKi->NN   :=Val(grf->NN)
*/ //Закоментировано 9.08.09
         TablKi->NS   :=grf->NS
         if grf->kod200=="*" .and. TablKi->KI#"0200"
          TablKi->PG   :="2"
         endif
      End
     *------------------------------------------
/*      If grf_cex->(DbSeek(bd02ki->cex+bd02ki->ki))   //ищу в графике цеха
         TablKi->NN   :=grf_cex->NN
      End
*/ //Закоментировано 9.08.09
     *------------------------------------------
     If bd02ki->KI $ '9990_9991'
         kolr        :=kolr+TablKi->ktek
         //TablKi->KORT:=TablKI->KORT+(-(TablKi->KTEK))
         TablKi->KSUT:=TablKI->KSUT+(-(TablKi->KTEK))
         //TablKi->KORM:=TablKI->KORM+(-(TablKi->KTEK))
         TablKi->KTEK:=0
         bd02ki->(DbSkip())
         loop
     End
     *------------------------------------------
/*     If grf->(dbseek(Bd02Ki->Ki)) .and. grf->kod200=="*"*/
/*     If Bd02Ki->Ki $ '0061_0201_0256_0257_0258_0260'
        TablKi->Bu1:='1'                          //пропускать
        bd02ki->(DbSkip())
        loop
     End
*/ //Закоментировано 9.08.09
     *------------------------------------------
     If TablKi->NS = '1'//$ net_sn
        TablKi->Bu1:='2'    //не снимать, но распределять 4/12/03
        bd02ki->(DbSkip())
        loop
     End
     *-------------------------------------------
/*     If (Bd02Ki->Ki >='1000') .and. (Bd02ki->Ki<='9900');
                              .and. Left(Bd02Ki->Ki,1)#'7'
//        If !(Bd02Ki->Ki $ '8004_8048_8077_8082_8088_8090_8151_8162_8170_8172_8176'+;
//                       '_8178_8181_8200_8266_8291_8326_8370_8377_8380_8385_8417_8418'+;
//                       '_8426_8441_8479_8483_8486_8505_8517_8525_8544_8572_8583'+;
//                       '_8584_8591_8605_8607_8616_8621_8660_8662_8669_8694_8736'+;
//                       '_8782_8839_8841')
          TablKi->Bu1:='1'                          //пропускать
          Bd02Ki->(DbSkip())
          Loop
     //   End
     End
*/ //Закоментировано 9.08.09
     *------------------------------------------
/*     pPrior:=Val(TablKi->Prior)
*/ //Закоментировано 9.08.09
//Макарова Основа снятия количества-Приз.маш.:0,1-обрабатываются,остальные-нет
     pPm:=TablKi->Pm
     kplan:=Opr_K1('bd02ki')
//     If ((TablKi->Prior $ '0_1_2_3_4_5') .and. (kplan # 0))
/*     If (pPrior >= 0) .and. (pPrior <= 21) .and. (kplan # 0)
     If ((TablKi->Pm $ '0_1') .and. (kplan # 0))
*/ //Закоментировано 9.08.09
     If  (TablKi->Pm $ '0_1') .and. ((kplan # 0 .and. Tablki->ki#"0200") .or. Tablki->ki="0200")
/*        If Bd02ki->KTEK > Kplan  //снимаю кол больш планов
           kolr        :=kolr+(TablKi->ktek-kplan)
           //TablKi->KORT:=TablKi->KORT+(-(TablKi->Ktek-Kplan))
           TablKi->KSUT:=TablKi->KSUT+(-(TablKi->Ktek-Kplan))
           //TablKi->KORM:=TablKi->KORM+(-(TablKi->Ktek-Kplan))
           TablKi->KTEK:=kplan
        EndIf
*/ //Закоментировано 9.08.09
        *----------------------------------------
        If IsBit(TablKi->Bu,2) .and. !IsBit(TablKi->Bu,4) //BU - 02
           TablKi->Bu1:='1'                      //пропускать 27.01.04
           Bd02ki->(DbSkip())
           Loop
        End
        *----------------------------------------
        If IsBit(TablKi->Bu,6)  //BU - 20
           TablKi->Bu1:='1'     //пропускать 20.04.04
           Bd02ki->(DbSkip())
           Loop
        End
        *----------------------------------------
        If pPm="1" //машина
          If (IsBit(TablKi->Bu,2) .and. IsBit(TablKi->Bu,4)) //BU - 0А
             //If TablKi->Prior $ '1_2_3_4'
/*             If (pPrior >=1) .and. (pPrior <=20)
*/ //Закоментировано 9.08.09
                If TablKi->Niz # 0
                   TablKi->NN :=TablKi->Niz-1  //закрывать до № изменения
                   //TablKi->Nsb:=TablKi->Niz-1  //закрывать до № изменения
                End
/*             End
*/ //Закоментировано 9.08.09
            // Bd02Ki->(DbSkip())
            // Loop
          End
        End
        *----------------------------------------
/*        Do Case
           Case ((pPrior >=1) .and. (pPrior <=20))
*/ //Закоментировано 9.08.09
        If TablKi->PM == '1'
                   If IsBit(TablKi->Bu,3).and.(TablKi->Nsb < TablKi->Niz)//BU '04' - ?
                      kolr  :=kolr+KolDK(TablKi->Niz-1)//снимаю только до номера изм.
                   Else
                      kolr  :=kolr+KolDK(TablKi->Nsb) //было до Nn изм. 14.11.03
                   End
        Else
                   kolr  :=kolr+TablKi->KTEK  //снимаю тек.кол-во
                   //TablKi->KORT:=TablKi->KORT+(-(TablKi->KTEK))
                   TablKi->KSUT:=TablKi->KSUT+(-(TablKi->KTEK))
                   //TablKi->KORM:=TablKi->KORM+(-(TablKi->KTEK))
                   TablKi->KTEK:=0
        End
/*           Case pPrior = 21   //снимаю текущ. кол-во
                kolr  :=kolr+TablKi->Ktek
                //TablKi->KORT:=TablKi->KORT+(-(TablKi->KTEK))
                TablKi->KSUT:=TablKi->KSUT+(-(TablKi->KTEK))
                //TablKi->KORM:=TablKi->KORM+(-(TablKi->KTEK))
                TablKi->KTEK:=0

           Case pPrior = 0  //снимаем кол-во больше планового
                If TablKi->Ktek > Kplan
                   kolr        :=kolr+(TablKi->ktek-kplan)
                   //TablKi->KORT:=TablKi->KORT+(-(TablKi->Ktek-Kplan))
                   TablKi->KSUT:=TablKi->KSUT+(-(TablKi->Ktek-Kplan))
                   //TablKi->KORM:=TablKi->KORM+(-(TablKi->Ktek-Kplan))
                   TablKi->KTEK:=kplan
                End
        EndCase
*/ //Закоментировано 9.08.09
     Else
                TablKi->Bu1:='1' //позицию не обрабатывать
     EndIf
     *-------------------------------------
     If TablKi->PM == '1'
       If (IsBit(TablKi->Bu,2) .and. IsBit(TablKi->Bu,4)) //BU - 0A
/*         If ((pPrior >=1) .and. (pPrior <= 20))  //$ '1_2_3_4'
*/ //Закоментировано 9.08.09
            If TablKi->Niz # 0
               TablKi->Nsb:=TablKi->Niz-1  //закрывать до № изменения
            End
/*         End
*/ //Закоментировано 9.08.09
       End
     End
     bd02ki->(DbSkip())
   EndDo
   *---------------------------------------------
   //    взять кол-во с накладной
   Select bd02nc
   If Poisk('cex+chert+ps+vp+cp',kl)
      Do While kl == (bd02nc->cex+bd02nc->chert+bd02nc->ps+bd02nc->vp+bd02nc->cp)
         //If (substr(Si_nc,7,2) == bd02nc->CHMES).and.;//тек. день
      //   If (Val(Substr(Si_nc,15,3))=Bd02nc->Np)      //номер поколения
         If Padl(Alltrim(Str(Bd02nc->Np)),3,'0') $ NPok      //номер поколения
            kolr:=kolr+bd02nc->KOL
         End
         bd02nc->(DbSkip())
      EndDo
   End
   RaspKol(kl)
   Select bd02ki
ENDDO

NoBd02ki()
//GetCex56()     //разбивка укомпл. для 56 цеха по участкам
Close  Bd02ki
Select Bd02KiN
Copy To (put_ki+"bd02ki.dbf")
Close all
Ferase(put_ki+"Bd02ki2.ntx")
Ferase(put_ki+"Bdki.ntx")
//Copy File ("bd02kin.dbf") to (put_ki+"bd02ki.dbf")
Ferase("bd02kin.dbf"); Ferase("bd02kin.ntx")
Ferase("TablKi.dbf");  Ferase("TablKi.ntx")
Ferase("TablKi1.ntx"); Ferase("TablKi2.ntx")
SiKi()
Use (put_ki+"bd02ki") new
Index on cex+chert+ps+vp+cp to (put_ki+"bd02ki.ntx") Unique
Cls
Tone(1000,0.4)
Boxik(11,18,15,60,"Распределение накладных прошло УСПЕШНО!",B_DOUBLE,'w+/r')

Return nil
*-----------------------
Static Func ObrPok()
Local pok_ki,pok_nc,p1:='',i

pok_ki:=Val(Substr(Si_Ki,35,3))
pok_nc:=Val(Substr(Si_nc,15,3))
/*If pok_ki=0 .or. (pok_nc=0)
   Tone(1000,0.5)
   Alert('Не могу выбрать НП. Ошибка в СИ',{" OK "},"w+/r")
   Close All
   Restore Screen
   Quit
EndIf*/
If (pok_ki > pok_nc) .and. ((1000-pok_ki)+pok_nc > 20 )
   Tone(1000,0.5)
   Alert('Не могу выбрать НП. Ошибка в СИ',{" OK "},"w+/r")
   Close All
   Restore Screen
   Quit
EndIf

Do While (.t.)  //pok_ki < pok_nc
   //pok_ki:=Iif(pok_ki=999,1,pok_ki+1)
   pok_ki:=Iif(pok_ki=999,0,pok_ki+1)
   p1:=p1+Padl(Alltrim(Str(pok_ki)),3,'0')+'_'
//   ? p1
   If Pok_ki = pok_nc
      Exit
   EndIf
EndDo
Return p1
*-----------------------
Static Func SiKi()
local si2
  /*31/01/07 Макарова изменилась СИ*/
  Si_ki:=Stuff(Si_Ki,7,8,Dtoc(Date()))      //системная дата
  si2:=Val(Substr(Si_ki,15,3))            //поколение
  If si2 = 999
     si2:=000
  End
  Si2  :=Si2+1;  Si2:=Padl(Alltrim(Str(Si2,3)),3,'0')
  Si_ki:=Stuff(Si_Ki,15,3,Si2)
  Si_ki:=Stuff(Si_Ki,62,3,Si2) //В СИ программиста N пок BD02ki
  Si_ki:=Stuff(Si_Ki,27,8,substr(Si_nc,7,8)) //В СИ программиста дату BD02nc
  Si2  :=Substr(Si_Ki,39,2)   //БУ текущий
  Si2  :=Ntoc(NumOR(Si2,"01"),16,2,'0')
  Si_ki:=Stuff(Si_Ki,39,2,Si2)
  Si2  :=Substr(Si_Ki,41,2)   //БУ месячный
  Si2  :=Ntoc(NumOR(Si2,"01"),16,2,'0')
  Si_ki:=Stuff(Si_Ki,41,2,Si2)
  Si_Ki:=Stuff(Si_Ki,35,3,Substr(Si_Nc,15,3))
  PutSi(put_ki+"bd02ki.dbf",Si_Ki)
Return Nil
*****************************************************
*          ОПРЕДЕЛЕНИЕ КОЛ-ВА НА ПЛАН
*****************************************************
Static func Opr_k1(baza)
Local k3
     If (&(baza)->N2 =0)
        k3:=&(baza)->K1
     Else
        if &(baza)->NTEK <  (&(baza)->N2)
           k3:=&(baza)->K1
//        if (&(baza)->NTEK  =  (&(baza)->N2)) .and. ( &(baza)->KTEK = 0)
//           k3:=&(baza)->K1
        else
           k3:=&(baza)->K2
        end
     End
Return k3
*****************************************************
*          ОПРЕДЕЛЕНИЕ КОЛ-ВА НА ПЛАН для снятия
*****************************************************
Static func Opr_k1S(baza)
Local k3
     If (&(baza)->N2 =0)
        k3:=&(baza)->K1
     Else
        if &(baza)->NTEK <  (&(baza)->N2)
           k3:=&(baza)->K1
        elseif (&(baza)->NTEK  =  (&(baza)->N2)) .and. ( &(baza)->KTEK = 0)
           k3:=&(baza)->K1
        else
           k3:=&(baza)->K2
        end
     End
Return k3

***************************************************
*           ОПРЕДЕЛЯЮ КОЛ-ВО ДЛЯ СНЯТИЯ
***************************************************
Static Func KolDK(num)
Local Nn1,kold:=0,kplan
    Nn1:=Num
    If (Nn1 < 0) .or. (Nn1 >= TablKi->NTEK)
       return kold
    End
    *---------------------
    kplan:=TablKi->K1
    If (TablKi->N2 = 0) .or. (TablKi->NTEK < TablKi->N2)
       kold:=(TablKi->NTEK-Nn1-1)*kplan+TablKi->KTEK
    ElseIf (TablKi->N2 # 0).and. (TablKi->NTEK >= TablKi->N2).and.(Nn1<TablKi->N2)
       kold:=(TablKi->NTEK-TablKi->N2)*TablKi->K2+TablKi->KTEK+;
             (TablKi->N2-Nn1-1)*TablKi->K1
    ElseIf (TablKi->N2 # 0).and.(TablKi->NTEK >= TablKi->N2).and.(Nn1>=TablKi->N2)
       kplan:=TablKi->K2
       kold:=(TablKi->NTEK-Nn1-1)*kplan+TablKi->KTEK
    End
    TablKi->NTEK :=Nn1+1
    TablKi->KTEK :=0
    //TablKi->KORT:=TablKi->KORT+(-KOld)
    TablKi->KSUT:=TablKi->KSUT+(-KOld)
    //TablKi->KORM:=TablKi->KORM+(-KOld)

Return kold
********************************************************
*              РАСПРЕДЕЛЕНИЕ КОЛ-ВА
********************************************************
Static Func RaspKol(kl)
Local i

Select TablKi
If (kolr < 0)
   Kolr:=Abs(Kolr)
   Kor99()  //снимаю с остатка
//   ****  ПРИОРИТЕТ 5              //Макарова закоментировыны снятия 02.08.06
//   Prior03S("21")   //снять Ktek
//   ****  ПРИОРИТЕТ 3,2,1
//   Prior21S('nn')  //до ном.нужного.
//   Prior21S('nsb')  //до ном.сбыта
   ****
   Kolr:= -Kolr
   Select TablKi
   Set Filter To
ElseIf (kolr > 0)
   *------------*   Основное распределение   *------------*
   Tablki->(DbSetOrder(2))    // ключ "prior+ki" по возрастанию
  //Макарова  распределение по графику цеха
   rK(kl)
/*   ****  ПРИОРИТЕТ 0
   Prior03("00")
   ****  ПРИОРИТЕТ 1, 2 - 20
   for i:=1 to 20
       Prior12(Padl(Alltrim(Str(i)),2,'0'))
   next
//   Prior12('1');   Prior12('2'); Prior12('3'); Prior12('4')
   ****  ПРИОРИТЕТ 21
   Prior03("21")
*/ //Закоментировано 9.08.09
   set filter to
   TablKi->(DBSetorder(1))   //ключ "Ki"
Endif
*-------------------------------------------------------------
If Kolr # 0  //кол-во осталось -> сбросить на остаток
   Set Filter to
   TablKi->(DBSetorder(1))   //ключ "Ki"
   If TablKi->(!DbSeek("9990")) .and. (TablKi->(!DbSeek("9991")))
      NulZap('TablKi')
      TablKi->KI    :='9991'
      TablKi->PG    :='9'
      TablKi->NTEKS :=0;      TablKi->KTEKS :=0
   End
   Tablki->KTEK :=TablKi->KTEK+Kolr
   //TablKi->KORT :=TablKi->KORT+Kolr
   TablKi->KSUT :=TablKi->KSUT+Kolr
   //TablKi->KORM :=TablKi->KORM+Kolr
End
*-----------------------------------------------------------
//  Перезапись в новый BD02ki
Tablki->(DbSetOrder(1))    // ключ "ki"
set filter to
Tablki->(DbGotop())
Do While TablKi->(!EOF())
   If (Tablki->NtekS # TablKi->Ntek) .or. (Tablki->KtekS # TablKi->Ktek)
      TablKi->NB   :=Tablki->NTEKS
      TablKi->KB   :=Tablki->KTEKS
      TablKi->BU   :=Ntoc(NumOR(Tablki->BU,"01"),16,2,'0')
   End
   Bd02kiN->(DbAppend())
   Bd02kiN->Cex   :=Substr(Kl,1,2)
   Bd02kiN->Chert :=Substr(Kl,3,13)
   Bd02kiN->Ps    :=Substr(Kl,16,1)
   Bd02kiN->Vp    :=Substr(Kl,17,1)
   Bd02kiN->Cp    :=Substr(Kl,18,2)
   Bd02kiN->Ki    :=Tablki->Ki
   Bd02kiN->Pg    :=Tablki->Pg
   If ch80
      TablKi->BU  :=Ntoc(NumOR(Tablki->BU,"80"),16,2,'0')
   End
   Bd02kiN->Bu    :=TablKi->Bu
   Bd02kiN->Op    :=Tablki->Op
   Bd02kiN->K1    :=Tablki->K1
   Bd02kiN->N2    :=Tablki->N2;     Bd02kiN->K2    :=Tablki->K2
   Bd02kiN->Ksut  :=Tablki->Ksut;   Bd02kiN->Nb    :=Tablki->Nb
   Bd02kiN->Kb    :=Tablki->Kb
   Bd02kiN->Ntek  :=Tablki->Ntek;   Bd02kiN->Ktek  :=Tablki->Ktek
   Bd02kiN->Nnmes :=Tablki->Nnmes;  Bd02kiN->Knmes :=Tablki->Knmes
   Bd02kiN->Vk    :=Tablki->Vk;     Bd02kiN->Kort  :=Tablki->Kort
   Bd02kiN->Korm  :=Tablki->Korm;   Bd02kiN->Niz   :=Tablki->Niz
   Bd02kiN->Bs    :=Tablki->Bs
   Bd02kiN->KormV :=Tablki->KormV
   TablKi->(Dbskip())
EndDo
Return nil
*********************************************************
*           ДОБАВИТЬ ЗАПИСЬ В TABLKI
*********************************************************
Static Func DobZap()
   TablKi->(DbAppend())
   TablKi->Ki    :=Bd02ki->Ki
   TablKi->Pg    :=iif(TablKi->Ki="0200","1",iif(TablKi->Ki$"9990_9991","9","0"))
   TablKi->Bu    :=Ntoc(NumAnd(Bd02ki->BU,"FE"),16,2,'0') //ЧИЩУ БИТ 1
   TablKi->Op    :=Bd02ki->Op
   TablKi->K1    :=Bd02ki->K1
   TablKi->N2    :=Bd02ki->N2;      TablKi->K2    :=Bd02ki->K2
   TablKi->Ksut  :=0;               TablKi->Nb    :=Bd02ki->Nb
   TablKi->Kb    :=Bd02ki->Kb;      TablKi->Ntek  :=Bd02ki->Ntek
   TablKi->Ktek  :=Bd02ki->Ktek;    TablKi->Nnmes :=Bd02ki->Nnmes
   TablKi->Knmes :=Bd02ki->Knmes;   TablKi->Vk    :=Bd02ki->Vk
   TablKi->Kort  :=0
   TablKi->Korm  :=Bd02ki->Korm;    TablKi->Niz   :=Bd02ki->Niz
   TablKi->Bs    :=Bd02ki->Bs
   TablKi->KormV :=Bd02ki->KormV
   TablKi->Bu1   :='0'
   //If Substr(Si_Ki,21,2) # '00'  //была какая-то корректировка
      //TablKi->Nteks :=Bd02ki->Nb;    TablKi->Kteks :=Bd02ki->Kb
   //Else
   TablKi->Nteks :=Bd02ki->Ntek;  TablKi->Kteks :=Bd02ki->Ktek
   /*If  (IsBit(TablKi->Bu,2).and.IsBit(TablKi->Bu,4).and.;
             (TablKi->Niz#0)) //для BU=10
       TablKi->BU := Ntoc(NumAnd(Tablki->BU,"F7"),16,2,'0')  //ставлю 02
   End*/
   If  (IsBit(TablKi->Bu,2).and.IsBit(TablKi->Bu,4).and.;
             (TablKi->Ntek = TablKi->Niz).and.(TablKi->Niz#0)) //для BU=10
       TablKi->BU := Ntoc(NumAnd(Tablki->BU,"F7"),16,2,'0')  //ставлю 02
   End

   //End
Return nil
*****************************************************
*           НАКЛАДНЫЕ КОТ-ЫХ НЕТ В БД02КИ
*****************************************************
Static Func NoBd02ki()
Local Kl1,Kolr1

 Select Bd02nc
 Set Filter To ( Padl(Alltrim(Str(Bd02nc->Np)),3,'0') $ NPok )
 Bd02nc->(DbGotop())
 Do While Bd02nc->(!EOF())
    //If (substr(Si_nc,7,2) == bd02nc->CHMES) .and. ;  //текущий день
//    If  (Val(Substr(Si_nc,15,3))=Bd02nc->Np)      //номер поколения
   // If Padl(Alltrim(Str(Bd02nc->Np)),3,'0') $ NPok      //номер поколения

       Kolr1:=0
       Kl1:=bd02nc->cex+bd02nc->chert+bd02nc->ps+bd02nc->vp+bd02nc->cp//+;
               //Str(Bd02nc->Np,3)
       Do While kl1 == (bd02nc->cex+bd02nc->chert+bd02nc->ps+bd02nc->vp+;
                        bd02nc->cp)//+Str(bd02nc->Np,3))
          kolr1:=kolr1+bd02nc->KOL
          bd02nc->(DbSkip())
       EndDo
       If Bd02kin->(!DbSeek(Kl1))
          If Kolr1 # 0
             NulZap('Bd02kin')
             Bd02kiN->Cex   :=Substr(Kl1,1,2)  //Bd02nc->CEX
             Bd02kiN->Chert :=Substr(Kl1,3,13) //Bd02nc->CHERT
             Bd02kiN->Ps    :=Substr(Kl1,16,1) //Bd02nc->PS
             Bd02kiN->Vp    :=Substr(Kl1,17,1) //Bd02nc->VP
             Bd02kiN->Cp    :=Substr(Kl1,18,2) //Bd02nc->CP
             Bd02kin->KI  :='9990'
             Bd02kin->PG  :='9'
             Bd02kin->BU  :='01'
             Bd02kin->KTEK:=Kolr1
             Bd02kin->KSUT:=Bd02Kin->KSUT+Kolr1
          End
       End
 Enddo
Return nil
*****************************************************
*                 ПРИОРИТЕТ 1, 2
*****************************************************
//Макарова распределение идет по КИ из графика цеха,а не по приоритетам,как было
/*Static Func Prior12(ppr)
*/ //Закоментировано 9.08.09
Static Func Prior12(kodI)
//kolr - private
Local vix1:=(.T.),kolzak1,pr5:=0/*,kolbs1
*/ //Закоментировано 9.08.09

   If (kolr = 0)
      return nil
   End
   *--------------------------------------------
   Do While TablKi->(!EOF())
/*      If (TablKi->Prior == ppr).and.(TablKi->Bu1 # '1')
*/ //Закоментировано 9.08.09
      If (TablKi->ki == kodI).and.(TablKi->Bu1 # '1')
         If TablKi->Bs1 == '00'
            pr5:=1
         End
      EndIf
      TablKi->(DbSkip())
   EndDo
   *--------------------------------------------
/*   Set Filter to (Tablki->PRIOR == ppr)
*/ //Закоментировано 9.08.09
//Макарова оставить только машины соответствующего КИ(9-не распределяется)
   Set Filter to (Tablki->ki == kodI) .and. (Tablki->Pm="1")
   TablKi->(DbGoToP())
   If TablKi->(EOF())
      Set Filter to
      Return Nil
   End
   *---------------------------------------------
   If pr5 = 0
      Tablki->(DbGotop())
      Do While TablKi->(!EOF())
         TablKi->BS1:='00'
         TablKi->(DbSkip())
      EndDo
   End
   Tablki->(DbGotop())
   *---------------------------------------------
   kolzak1:=0   //число записей закрытых до NN
/*   kolbs1 :=0   //число записей с BS='01'
*/ //Закоментировано 9.08.09
   *---------------------------------------
   Do While  Vix1
         //все BS='01' - обнуляю их для незакрытых номеров//Макарова
         Tablki->(DbGotop())
         Do While TablKi->(!EOF())
          if TablKi->BS1='01' .and. TablKi->BU1#'1'
            TablKi->BS1:='00'
          endif
          TablKi->(DbSkip())
         EndDo
      TablKi->(DbGoToP())
/*      Do While TablKi->PRIOR == ppr
*/ //Закоментировано 9.08.09
      Do While TablKi->ki == kodI
         If (TablKi->BS1 = '00').and.(TablKi->BU1#'1')
            //закрываю один номер
            //если номер закрыт то BS='01'
            If ZakNom()
              If !(IsBit(TablKi->Bu,2).and.!IsBit(TablKi->Bu,4)) //BU-не02,но м.б.0A
               TablKi->BS1:='01'
              End
              kolzak1   :=1
            End
/*            kolbs1:=Iif(TablKi->BS=='00',1,kolbs1)
*/ //Закоментировано 9.08.09
            If kolr = 0
               Vix1:=.F.
               Exit   //return nil
            End
         End
/*         If TablKi->BU1='1'
            TablKi->Bs:='01'
         End
*/ //Закоментировано 9.08.09
         TablKi->(DbSkip())
      EndDo
      *-----------
/*      If kolbs1 = 0
         //все BS='01' - обнуляю их
         Tablki->(DbGotop())
         Do While TablKi->(!EOF())
            TablKi->BS:='00'
            TablKi->(DbSkip())
         EndDo
      End
*/ //Закоментировано 9.08.09
      If (kolzak1 = 0)
         //все закрыто до NN - закрывать нечего
         Vix1:=.f.
         Exit
      End
      kolzak1:=0;  /* kolbs1:=0
*/ //Закоментировано 9.08.09
   EndDo
//Макарова для закрытых ки обнуляю BU1 для следующего закрытия по графику цеха
         Tablki->(DbGotop())//Макарова
         Do While TablKi->(!EOF())
          if TablKi->BS1='01'
            TablKi->BS1:='00'
            TablKi->BU1:='0'
          endif
          TablKi->(DbSkip())
         EndDo
      Set Filter to
Return NIl
******************************************************
*             ЗАКРЫТЬ НОМЕР ДЛЯ ПР=1, 2
******************************************************
Static Func ZakNom()
Local kplan,kolr1,nzak:=0,nn1:=grf_cex->nn+1/*nn1:=TablKi->Nn+1
*/ //Закоментировано 9.08.09
  If (IsBit(TablKi->Bu,2).and.IsBit(TablKi->Bu,4)).and.(TablKi->Niz # 0) //BU - 0A
    nn1:=TablKi->Niz  //закрывать до № изменения
  End

kplan:=Opr_k1('Tablki')
If TablKi->PM = '1'
   If TablKi->KTEK = kplan
      TablKi->NTEK:=TablKi->NTEK+1
      TablKi->Ktek:=0
   End
   If TablKi->NTEK >= NN1//номер уже закрыт
      TablKi->BU1:='1'  //позицию не обрабатывать
      If  (IsBit(TablKi->Bu,2).and.IsBit(TablKi->Bu,4).and.(TablKi->Niz#0)) //для BU=10
          TablKi->BU := Ntoc(NumAnd(Tablki->BU,"F7"),16,2,'0')  //ставлю 02
      End
      return (.t.)
   End
   kolr1:=kplan-TablKi->KTEK  //сколько не хватает для закрытия номера
   If TablKi->NTEK < nn1   //номер < номера нужного
      If kolr < kolr1
         TablKi->KTEK:=TablKi->KTEK+kolr
         //TablKi->KORT:=TablKI->KORT+KolR
         TablKi->KSUT:=TablKI->KSUT+KolR
         //TablKi->KORM:=TablKI->KORM+KolR
         kolr:=0
      Else
         kolr:=kolr-kolr1
         TablKi->NTEK:=TablKi->NTEK+1
         TablKi->KTEK:=0
         //TablKi->KORT:=TablKi->KORT+Kolr1
         TablKi->KSUT:=TablKi->KSUT+Kolr1
         //TablKi->KORM:=TablKi->KORM+Kolr1
         nzak:=1
      End
   End
*--------------------------------
Else    //закрываю до планового
   kolr1:=kplan-TablKi->KTEK  //сколько не хватает для закрытия номера
   If kolr < kolr1
           TablKi->KTEK:=TablKi->KTEK+kolr
           //TablKi->KORT:=TablKi->KORT+KolR
           TablKi->KSUT:=TablKi->KSUT+KolR
           //TablKi->KORM:=TablKi->KORM+KolR
           kolr:=0
   Else
           kolr:=kolr-kolr1
           TablKi->KTEK:=TablKi->KTEK+kolr1
           //TablKi->KORT:=TablKi->KORT+kolr1
           TablKi->KSUT:=TablKi->KSUT+kolr1
           //TablKi->KORM:=TablKi->KORM+kolr1
           TablKi->BU1 :='1';  nzak:=1
           If  (IsBit(TablKi->Bu,2) .and.  IsBit(TablKi->Bu,4)) //для BU=10
               TablKi->BU := Ntoc(NumAnd(Tablki->BU,"F7"),16,2,'0')  //ставлю 02
           End
   End
End
If nzak =1
   Return (.t.)
End
Return (.f.)
/*********************************************************
*   ОПРЕДЕЛИТЬ ЗАКРЫТ ЛИ НОМЕР
*********************************************************
Static Func FKolZak()
Local kplan

kplan:=Opr_k1('Tablki')
If kplan= 0
   Return (.t.)
End
If TablKi->PM == '1'
   If TablKi->NTEK > TablKi->NN
      return (.t.)
   End
Else
   If (TabLki->KTEK = kplan)//.AND.(kplan # 0)
      return (.t.)
   End
End
return (.f.)*/
*********************************************************
*                    ПРИОРИТЕТ 0
*********************************************************
//Макарова кодов-не машин
/*Static Func Prior03(ppr)
*/ //Закоментировано 9.08.09
Static Func Prior03(kodI)
Local vix1,kolzak,kplan,kolr1
   select Tablki
   If kolr =  0
      return nil
   End
/*   Set Filter to ((Tablki->PRIOR == ppr).and.(TablKi->BU1#'1'))
*/ //Закоментировано 9.08.09
   Set Filter to ((Tablki->ki == kodI).and.(Tablki->Pm="0").and.(TablKi->BU1#'1'))
   TablKi->(DbGotop())
   Do While TablKi->(!EOF()) //.and. (kolr # 0)
      kplan:=Opr_K1('TablKi')
      If (TablKi->KTEK < kplan)//.and.(kplan # 0)
          kolr1:=kplan-TablKi->KTEK
          If kolr < kolr1
             TablKi->KTEK:=TablKi->KTEK+kolr
             //TablKi->KORT:=TablKI->KORT+KolR
             TablKi->KSUT:=TablKI->KSUT+KolR
             //TablKi->KORM:=TablKI->KORM+KolR
             kolr:=0
          Else
             kolr:=kolr-kolr1
             TablKi->KTEK:=TablKi->KTEK+kolr1
             //TablKi->KORT:=TablKi->KORT+Kolr1
             TablKi->KSUT:=TablKi->KSUT+Kolr1
             //TablKi->KORM:=TablKi->KORM+Kolr1
          End
      End
      *-------------------------------
      If  (IsBit(TablKi->Bu,2) .and.  IsBit(TablKi->Bu,4)) //для BU=10
          If TablKi->Ktek = Kplan  //закрыли до планового
             TablKi->BU := Ntoc(NumAnd(Tablki->BU,"F7"),16,2,'0')  //оставляю 02
          End
      End
      *-----------------------------------
      If Kolr = 0
         Exit
      End
      TablKi->(DbSkip())
   EndDo

   Set Filter to
Return nil
*******************************************************
Static Func Kor99()
 Tablki->(DbSetOrder(1))    // ключ "ki"
 If TablKi->(DbSeek('9990')) .or. TablKi->(DbSeek("9991"))
    If TablKi->Ktek <= 0
       return nil
    End
    If TablKi->Ktek <= Kolr
       Kolr        :=Kolr-TablKi->Ktek
       //TablKi->KORT:=TablKI->KORT+(-(TablKi->KTEK))
       TablKi->KSUT:=TablKI->KSUT+(-(TablKi->KTEK))
       //TablKi->KORM:=TablKI->KORM+(-(TablKi->KTEK))
       TablKi->Ktek:=0
    Else
       TablKi->Ktek:=TablKi->Ktek-Kolr
       //TablKi->KORT:=TablKI->KORT+(-(Kolr))
       TablKi->KSUT:=TablKI->KSUT+(-(Kolr))
       //TablKi->KORM:=TablKI->KORM+(-(Kolr))
       kolr        :=0
    End
 EndIf

Return Nil
*****************************************************
/*                 ПРИОРИТЕТ 2, 1
*****************************************************
Static Function Prior21S(nomer)
//kolr - private
//Nomer - номер до которого будем снимать
Local vix1:=(.t.),nrec1,nrec2,kolzak1,kolzak2,;
      trec1,trec2,kon_pr1,kon_pr2,i

   If (Kolr = 0)
      return nil
   End
   TablKi->(DbSetOrder(3))   //ключ "prior+ki" по убыванию
   *---------------------------------------------
   for i:=20 to 1 step -1
     Vix1:=.T.
     Set Filter to (Tablki->PRIOR == Padl(Alltrim(Str(i)),2,'0')  )// .OR. (Tablki->PRIOR == '1')
     TablKi->(DbGotop())
     If TablKi->(EOF())
        Vix1:=.F.
     End
     kolzak1:=0   //число записей закрытых до NN (NSB)
     Do While  Vix1
        TablKi->(DbGoTop())
        Do While TablKi->PRIOR == Padl(Alltrim(Str(i)),2,'0')
         //снимаю один номер
         //если номер снят то BS='00'
         If TablKi->BU1 = '0'
            If SnNom(Nomer)
               TablKi->BS:='00'
               kolzak1:=1
            End
            If KolR = 0
               return nil
            End
         End
         TablKi->(DbSkip())
        EndDo
        If kolzak1=0
           Vix1:=.F.
        End
        kolzak1:=0
     EndDo
   next
Return NIl*/
******************************************************
/*             СНЯТЬ НОМЕР ДЛЯ ПР=2, 1
******************************************************
Static Func SnNom(Nomer)
Local kplan,kolr1,nzak:=0,nn1

 If IsBit(TablKi->Bu,3)   //BU '04' - ?
    If TablKi->Niz # 0
       TablKi->Nn  :=TablKi->Niz-1   //не снимать ниже номера вставки КИ
       TablKi->Nsb :=TablKi->Niz-1
    End
 End
 *------------------------------------
 Nn1:=Iif(nomer=='nn',Tablki->Nn,TablKi->Nsb)
 If Nn1=0
    Return (.F.)
 End
 Nn1:=Nn1+1
 Kplan:=Opr_k1S('Tablki')
 *-------------------------------------------------------
 //If Kplan = 0
//    Return (.f.)
 //End
 *-------------------------------------------------------
 If (TablKi->KTEK = kplan)//.and.(kplan # 0)
    TablKi->NTEK:=TablKi->NTEK+1
    TablKi->Ktek:=0
 End
 If (TablKi->NTEK < NN1).or.((TablKi->Ntek=Nn1).and.(TablKi->Ktek=0))
   //номер уже снят
    TablKi->BU1:='1'
    return (.f.)
 End
 *---------------------
 If TablKi->PM # '1'   //снимаю Ktek
    If Kolr >= TablKi->Ktek
       Kolr        :=Kolr-TablKi->Ktek
       //TablKi->KORT:=TablKI->KORT+(-(TablKi->KTEK))
       TablKi->KSUT:=TablKI->KSUT+(-(TablKi->KTEK))
      // TablKi->KORM:=TablKI->KORM+(-(TablKi->KTEK))
       TablKi->KTEK:=0
    Else
       //kolr1       :=TablKi->Ktek-Kolr
       TablKi->KTEK:=TablKi->KTEK-Kolr
       TablKi->KSUT:=TablKi->KSUT+(-(Kolr))
       //TablKi->KORT:=TablKi->KORT+(-(Kolr))
      // TablKi->KORM:=TablKi->KORM+(-(Kolr))
       Kolr        :=0
    End
    TablKi->BU1:='1'
    Return (.t.)
 EndIf
 *-----------------------------------
 If TablKi->Ktek=0
    TablKi->Ntek:=TablKi->Ntek-1
    If KolR >= Kplan
       KolR        :=KolR-Kplan
       //TablKi->KORT:=TablKi->KORT+(-(Kplan))
       TablKi->KSUT:=TablKi->KSUT+(-(Kplan))
       //TablKi->KORM:=TablKi->KORM+(-(Kplan))
    Else
       TablKi->Ktek:=(Kplan-KolR)
       //TablKi->KORT:=TablKi->KORT+(-(KolR))
       TablKi->KSUT:=TablKi->KSUT+(-(KolR))
       //TablKi->KORM:=TablKi->KORM+(-(KolR))
       KolR        :=0
    End
 Else
    If KolR >= TablKi->Ktek
       KolR        :=KolR-TablKi->Ktek
       //TablKi->KORT:=TablKi->KORT+(-(TablKi->Ktek))
       TablKi->KSUT:=TablKi->KSUT+(-(TablKi->Ktek))
       //TablKi->KORM:=TablKi->KORM+(-(TablKi->Ktek))
       TablKi->Ktek:=0
    Else
       TablKi->Ktek:=TablKi->Ktek-KolR
       //TablKi->KORT:=TablKi->KORT+(-(KolR))
       TablKi->KSUT:=TablKi->KSUT+(-(KolR))
       //TablKi->KORM:=TablKi->KORM+(-(KolR))
       KolR        :=0
    End
 End

Return (.t.)*/
*********************************************************
/*                    ПРИОРИТЕТ 3
*********************************************************
//снимаю KTEK
Static Func Prior03S(ppr)
Local kplan,kolr1

 If KolR =  0
    return nil
 End
 TablKi->(DbSetorder(3))  //ключ "prior+ki"  по убыванию
 Set Filter to (Tablki->PRIOR == ppr)
 TablKi->(DbGotop())

 Do While TablKi->(!EOF()) .and. (KolR # 0)
    If (TablKi->KTEK > 0 ) .and. (TablKi->BU1 = '0')
       If KolR > TablKi->Ktek
          KolR        :=KolR-TablKi->Ktek
          //TablKi->KORT:=TablKI->KORT+(-(TablKI->KTEK))
          TablKi->KSUT:=TablKI->KSUT+(-(TablKI->KTEK))
          //TablKi->KORM:=TablKI->KORM+(-(TablKI->KTEK))
          TablKi->Ktek:=0
       Else
          TablKi->Ktek:=TablKi->Ktek-KolR
          //TablKi->KORT:=TablKI->KORT+(-(KolR))
          TablKi->KSUT:=TablKI->KSUT+(-(KolR))
          //TablKi->KORM:=TablKI->KORM+(-(KolR))
          KolR        :=0
       End
    End
    TablKi->(DbSkip())
 EndDo
Return nil*/
*******************************************************
Static Func NulZap(baza)
   &(baza)->(DbAppend())
   &(baza)->Ki    :="0000"
   &(baza)->Pg    :="0"
   &(baza)->Bu    :="00"
   &(baza)->Op    :=0;   &(baza)->K1    :=0
   &(baza)->N2    :=0;   &(baza)->K2    :=0
   &(baza)->Ksut  :=0;   &(baza)->Nb    :=0
   &(baza)->Kb    :=0;   &(baza)->Ntek  :=0
   &(baza)->Ktek  :=0;   &(baza)->Nnmes :=0
   &(baza)->Knmes :=0
   &(baza)->Vk    :='0000'
   &(baza)->Kort  :=0;   &(baza)->Korm  :=0;   &(baza)->Bs    :='00'
Return nil
*-----------------------------------------------
Static Func IngRus(str)
Local str1:='',str2,i,j,m1:={{"А","A"},{"В","B"},{"С","C"},{"Е","E"}}
  For i:=1 to 2
      str2:=SubStr(str,i,1)
      For j:= 1 to 4
         If str2==m1[j,2]
            str2:=m1[j,1]
         End
      Next
      str1:=str1+str2
  Next
Return str1
*----------------------------------------------
Static Func RusIng(str)
Local str1:='',str2,i,j,m1:={{"А","A"},{"В","B"},{"С","C"},{"Е","E"}}
  For i:=1 to 2
      str2:=SubStr(str,i,1)
      For j:= 1 to 4
         If str2==m1[j,1]
            str2:=m1[j,2]
         End
      Next
      str1:=str1+str2
  Next
Return str1
*----------------------------------------------
//Макарова  расчет комплектации по графику цеха
Static Func rK(kl)
Local kodI,ceh:=substr(kl,1,2),vrKol
  if substr(kl,1,15)="44510 081837 00"
    alert()
  endif
  grf_cex->(dbgotop())
  if grf_cex->(!dbseek(ceh))
    Return
  endif
  *----------------------------------------------
  do while grf_cex->(!eof()) .and. grf_cex->cex=ceh
//только по актуальным позициям,остальные-пропускать
    if substr(grf_cex->bu,2,1)#"2"
      grf_cex->(dbskip())
      loop
    endif
    if (kodI:=grf_cex->kod)="0200" //особое закрытие по базе BD200 в соотв.с кв.и периодом
      if bd200->(dbseek(kl))
        Tablki->(dbseek("00200"))
        Tablki->k1:=bd200->&("koln"+grf_cex->kv+grf_cex->period)//заношу кол.соот-е кв.и периоду
        vrKol:=Tablki->ktek //для сверки было ли очередное закрытие
        Prior03(kodI)
        Tablki->(dbseek("00200"))
        if vrKol#Tablki->ktek //было закрытие
          Tablki->k2:=bd200->&("koln"+grf_cex->kv+grf_cex->period) //сколько д.б.закрыться
        endif
        Tablki->k1:=bd200->k1
      endif
    else
      Prior03(kodI) //не машины
      Prior12(kodI) //машины
    endif
    if kolr=0
      exit
    endif
    grf_cex->(dbskip())
  enddo
  *----------------------------------------------
Return
/*----------------------------------------------
Static Func schKol200(kl)
Local kodI,kol200,pKv:=grf_cex->Kv,pPeriod:=grf_cex->Period,pNum,nKv,nPeriod,vrKol
  k1_200:=0
  kol200:=0
  if empty(pKv) .or. empty(pPeriod) //не заданы квартал,либо месяц
    return .F.
  endif
  if Tablki->(!dbseek("00200"))//нет 200 кода в комплектации
    return .F.
  endif
  Tablki->k1:=0
  select blanks
  if blanks->(!poisk('cex+chert+ps+vp+cp',kl))
    return .F.
  endif
  pNum:=blanks->Num
  select blanksm
  grf->(dbgotop())
  do while grf->(!eof())
    if grf->kod200#"*"
      grf->(dbskip())
      loop
    endif
    kodI:=grf->kod
    if blanksm->(!poisk('num+ki',pNum+kodI))
      grf->(dbskip())
      loop
    endif
    for nKv:=1 to 4 //по всем кварталам
      for nPeriod:=1 to 3 //по всем периодам квартала
        k1_200+=(vrKol:=blanksm->&("kolm"+str(nKv,1,0)+str(nPeriod,1,0)))//накопление планого кол.
        if nKv<val(pKv) .or. (nKv=val(pKv).and.nPeriod<=val(pPeriod)) //накопление кол.до нужного периода
          kol200+=vrKol
        endif
      next
    next
    grf->(dbskip())
  enddo
  Tablki->k1:=kol200
  Tablki->k2:=kol200
Return .T.*/
*----------------------------------------------
/*static func ProstTekNM()
Local nameBaza,recTek,recOtm
  select grf_cex
  recTek:=recno()
  go top
  do while !eof()
    if (grf->(dbseek(grf_cex->kod)))
      if grf->Pm#"1"
        if grf->kod200="*"
          grf_cex->bu:=substr(grf_cex->bu,1,1)+"1"
          skip
          loop
        endif
      endif
      if val(grf->nsb) <= (grf_cex->nn)
        grf_cex->bu:=substr(grf_cex->bu,1,1)+"2"
      else
        grf_cex->bu:=substr(grf_cex->bu,1,1)+"0"
      endif
    else
      grf_cex->bu:=substr(grf_cex->bu,1,1)+"0"
    endif
    skip
  enddo
  grf_cex->(dbgobottom())
  recOtm:=recno()
  grf_cex->(dbgotop())
  do while grf_cex->(!eof())
    if substr(grf_cex->bu,2,1)="2"
      recOtm:=recno()
      exit
    endif
    grf_cex->(dbskip())
  enddo
  grf_cex->(dbgobottom())
  do while grf_cex->(recno())#recOtm
    if grf_cex->kod="0200"
      grf_cex->bu:=substr(grf_cex->bu,1,1)+"2"
    endif
    grf_cex->(dbskip(-1))
  enddo
  do while grf_cex->(!bof())
    if grf_cex->kod="0200"
      grf_cex->bu:=substr(grf_cex->bu,1,1)+"2"
      exit
    endif
    grf_cex->(dbskip(-1))
  enddo
  grf_cex->(dbgoto(recTek))
return .T.*/
