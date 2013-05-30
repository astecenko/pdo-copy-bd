         /*Процедуры формирования БД для просмотра КАРТ УЧЕТА для ПДО*/
                /*Разработчик - Дьяченко Ольга Викторовна*/
                              /*2000 г.*/
                          /*Сетевой вариант*/
////////////////////////
////////////////////////В ЗАКОМЕНТИРОВАННЫЕ БЛОКИ ИЗМЕНЕНИЯ НЕ ВНОСИЛИСЬ
///////////////////////(изменения, касающиеся введения БД blanksm, blanm_s, blanphm)
#include "box.ch"
#include "inkey.ch"
#include "achoice.ch"

/*ФОРМИРОВАНИЕ БД "Карта Учета" для ПДО*/
Procedure FormBlank()
Local condit:=.F., chert_N, cikl,num_ph
//31.05.07 убрано сокращение термообработки T4567 (сокращение как для в.ценника)
//26.01.09 для позиций с термообработкой (60, 61 цех) ставить пометку "T" в поле blanks->term
T4567:={"45","49","55","60","61","67"}   /*таблица цехов для дополнительного сокращения как в pp0301(термообработка)*/
plcp:="  "                 /*это цех получатель*/
plterm:=" " //это признак термообработки
/*байт-указатель для модуля sm41(bu=00). В NeedAdd() my_bu:="00",
т.к. после отработки sm41 my_bu содержит код возврата 15 или 67*/
my_bu:="00"
/*ТМ нужен только как параметр для sm41 больше здесь нигде не uses*/
my_tm:=""
/*счетчик сокр.ТМ нужен только как параметр для sm41
больше здесь нигде не uses*/
my_count:=0

Set SoftSeek Off
Set Color To W+/W
@ 7,18 Clear To 7,70
If num_kv=="1".Or.num_kv=="2".Or.num_kv=="3".Or.num_kv=="4"
   If blanks->(LastRec())<1
      Nums=Str(Val("1"),7)
   Else
      Select blanks
      Go blanks->(LastRec())
      Nums:=blanks->num
      blanks->(dbDelete())
   EndIf
   my_box(12,20,15,59,B_DOUBLE+chr(32),"W+/B")
   @ 13,22 Say'Идет подготовка базы данных BLANKSIZ'

   Select blanksiz
   flag_del:=0 /*есть ли удаленные записи в процессе чистки: Да=1*/
   Do Case
     case num_kv="1"
       Do While !EOF()
          @ 14,32 Say blanksiz->(RecNo())
          If Empty(blanksiz->kol2).And.Empty(blanksiz->kol3);
                                  .And.Empty(blanksiz->kol4)
          /*del, если нет данных по всем кварталам*/
             flag_del:=1
             blanksiz->(dbDelete())
          Else     /*1-й квартал объявляем пустым*/
             blanksiz->kol1=0
          EndIf
          blanksiz->(dbSkip())
      EndDo
     case num_kv="2"
       Do While !EOF()
           @ 14,32 Say blanksiz->(RecNo())
          If Empty(blanksiz->kol1).And.Empty(blanksiz->kol3);
                                  .And.Empty(blanksiz->kol4)
          /*del, если нет данных по всем кварталам*/
             flag_del:=1
             blanksiz->(dbDelete())
          Else     /*2-й квартал объявляем пустым*/
             blanksiz->kol2=0
          EndIf
          blanksiz->(dbSkip())
      EndDo
     case num_kv="3"
       Do While !EOF()
          @ 14,32 Say blanksiz->(RecNo())
          If Empty(blanksiz->kol1).And.Empty(blanksiz->kol2);
                                  .And.Empty(blanksiz->kol4)
          /*del, если нет данных по всем кварталам*/
             flag_del:=1
             blanksiz->(dbDelete())
          Else     /*3-й квартал объявляем пустым*/
             blanksiz->kol3=0
          EndIf
          blanksiz->(dbSkip())
      EndDo
     case num_kv="4"
       Do While !EOF()
          @ 14,32 Say blanksiz->(RecNo())
          If Empty(blanksiz->kol2).And.Empty(blanksiz->kol3);
                                  .And.Empty(blanksiz->kol1)
          /*del, если нет данных по всем кварталам*/
             flag_del:=1
             blanksiz->(dbDelete())
          Else     /*4-й квартал объявляем пустым*/
             blanksiz->kol4=0
          EndIf
          blanksiz->(dbSkip())
      EndDo
   EndCase
   If flag_del==1
      Pack    //упаковать blanksiz
   EndIf

   my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
   Set Color To W+*/B
   @ 13,22 Say "Идет индексация базы данных BLANKSIZ"
   Index On blanksiz->num+blanksiz->ki To (n_blaniz+".ntx")

   Set Color To W+/W
   @ 12,59 Clear To 16,61
   my_box(12,20,15,59,B_DOUBLE+chr(32),"W+/B")
   @ 13,22 Say' Идет подготовка базы данных BLANKS '

   Select blanks   /*чистим blanks*/
/*Для того, чтобы сохранить memo в случае пересоздания квартала
(др. кварталов еще нет) сначала помечаем записи на удаление, но Pack не
выполняем. В процессе создания карточек, если такая карточка уже есть,
то проверяем ее на пометку удаления. Если она помечена, то восстанавливаем ее
Recall. Не восстановленные записи при сортировке удалятся.*/
   Go 1
   Do Case
     case num_kv="1"
       Do While !EOF()
          @ 14,32 Say blanks->(RecNo())
          //blanks->new_pos:=0
          //blanks->dobav:=0
          //blanks->perevod:=0
          //первоначально считаем позицию удаленной из тек. плана
          /*If Empty(blanks->udal_date)
             blanks->udal_date:=SubStr(pl03ps_Si,7,4)
          EndIf*/
          // 4 строки добавлены 18.12.2001
          If Empty(blanks->kv2).And.Empty(blanks->kv3).And.Empty(blanks->kv4)
          /*del, если нет данных по всем кварталам - позиция введена и снята в одном и том же квартале*/
             blanks->(dbDelete())
          Else
             blanks->kv1=0 /*1-ый квартал объявляем пустым*/
          EndIf
          blanks->(dbSkip())
       EndDo
     case num_kv="2"
       Do While !EOF()
          @ 14,32 Say blanks->(RecNo())
          //blanks->new_pos:=0
          //blanks->dobav:=0
          //blanks->perevod:=0
          //первоначально считаем позицию удаленной из тек. плана
          /*If Empty(blanks->udal_date)
             blanks->udal_date:=SubStr(pl03ps_Si,7,4)
          EndIf*/
          If Empty(blanks->kv1).And.Empty(blanks->kv3).And.Empty(blanks->kv4)
          /*del, если нет данных по всем кварталам - позиция введена и снята в одном и том же квартале*/
             blanks->(dbDelete())
          Else
             blanks->kv2=0 /*2-oй квартал объявляем пустым*/
          EndIf
          blanks->(dbSkip())
       EndDo
     case num_kv="3"
       Do While !EOF()
          @ 14,32 Say blanks->(RecNo())
          //blanks->new_pos:=0
          //blanks->dobav:=0
          //blanks->perevod:=0
          //первоначально считаем позицию удаленной из тек. плана
          /*If Empty(blanks->udal_date)
             blanks->udal_date:=SubStr(pl03ps_Si,7,4)
          EndIf */
          If Empty(blanks->kv2).And.Empty(blanks->kv1).And.Empty(blanks->kv4)
          /*del, если нет данных по всем кварталам - позиция введена и снята в одном и том же квартале*/
             blanks->(dbDelete())
          Else
             blanks->kv3=0  /*3-й квартал объявляем пустым*/
          EndIf
          blanks->(dbSkip())
       EndDo
     case num_kv="4"
       Do While !EOF()
          @ 14,32 Say blanks->(RecNo())
          //blanks->new_pos:=0
          //blanks->dobav:=0
          //blanks->perevod:=0
          //первоначально считаем позицию удаленной из тек. плана
          /*If Empty(blanks->udal_date)
             blanks->udal_date:=SubStr(pl03ps_Si,7,4)
          EndIf*/
          If Empty(blanks->kv1).And.Empty(blanks->kv2).And.Empty(blanks->kv3)
          /*del, если нет данных по всем кварталам - позиция введена и снята в одном и том же квартале*/
             blanks->(dbDelete())
          Else
             blanks->kv4=0   /*4-ый квартал объявляем пустым*/
          EndIf
          blanks->(dbSkip())
       EndDo
   EndCase

   my_box(12,20,15,59,B_DOUBLE+chr(32),"W+/B")
   Set Color To W+*/B
   @ 13,22 Say " Идет индексация базы данных BLANKS"
   Index On blanks->num To (n_blan+"n.ntx")
   Index On blanks->cex+blanks->chert+blanks->ps+blanks->vp+blanks->cp ;
            To (n_blan+".ntx")

   /*БД blankstm содержит ТМ за год, для позиций, к-рых нет в плане - сохраняются
   последние изменения; для позиций, к-рые есть в тек.плане - ТМ изменяются в
   соответствии с тек.планом. Последние изменения ТМ по карте учета поле PR=0*/
   my_box(12,20,15,59,B_DOUBLE+chr(32),"W+/B")
   @ 13,22 Say'Идет подготовка базы данных BLANKSTM'

   Select blankstm
   Do While !blankstm->(Eof())
      @ 14,32 Say blankstm->(RecNo())
      blankstm->pr:=1
      blankstm->(dbSkip())
   EndDo
   my_box(12,20,15,59,B_DOUBLE+chr(32),"W+/B")
   Set Color To W+*/B
   @ 13,22 Say "Идет индексация базы данных BLANKSTM"
   Index On blankstm->num+blankstm->tm To (n_blantm+".ntx")

   /*БД blanksm содержит нормативное кол-во на план по изделию по месяцам  Ведем аналогично blanksiz*/
   my_box(12,20,15,59,B_DOUBLE+chr(32),"W+/B")
   @ 13,22 Say'Идет подготовка базы данных BLANKSM '
   Select blanksm
   flag_del:=0 /*есть ли удаленные записи в процессе чистки: Да=1*/
   Do Case
     case num_kv="1"
       Do While !EOF()
          @ 14,32 Say blanksm->(RecNo())
          If Empty(blanksm->kolm21).And.Empty(blanksm->kolm22).And.Empty(blanksm->kolm23).And.;
             Empty(blanksm->kolm31).And.Empty(blanksm->kolm32).And.Empty(blanksm->kolm33).And.;
             Empty(blanksm->kolm41).And.Empty(blanksm->kolm42).And.Empty(blanksm->kolm43)
          /*del, если нет данных по всем кварталам*/
             flag_del:=1
             blanksm->(dbDelete())
          Else     /*1-й квартал объявляем пустым*/
             blanksm->kolm11:=0
             blanksm->kolm12:=0
             blanksm->kolm13:=0
          EndIf
          blanksm->(dbSkip())
      EndDo
     case num_kv="2"
       Do While !EOF()
          @ 14,32 Say blanksm->(RecNo())
          If Empty(blanksm->kolm11).And.Empty(blanksm->kolm12).And.Empty(blanksm->kolm13).And.;
             Empty(blanksm->kolm31).And.Empty(blanksm->kolm32).And.Empty(blanksm->kolm33).And.;
             Empty(blanksm->kolm41).And.Empty(blanksm->kolm42).And.Empty(blanksm->kolm43)
          /*del, если нет данных по всем кварталам*/
             flag_del:=1
             blanksm->(dbDelete())
          Else     /*2-й квартал объявляем пустым*/
             blanksm->kolm21:=0
             blanksm->kolm22:=0
             blanksm->kolm23:=0
          EndIf
          blanksm->(dbSkip())
      EndDo
     case num_kv="3"
       Do While !EOF()
          @ 14,32 Say blanksm->(RecNo())
          If Empty(blanksm->kolm21).And.Empty(blanksm->kolm22).And.Empty(blanksm->kolm23).And.;
             Empty(blanksm->kolm11).And.Empty(blanksm->kolm12).And.Empty(blanksm->kolm13).And.;
             Empty(blanksm->kolm41).And.Empty(blanksm->kolm42).And.Empty(blanksm->kolm43)
          /*del, если нет данных по всем кварталам*/
             flag_del:=1
             blanksm->(dbDelete())
          Else     /*3-й квартал объявляем пустым*/
             blanksm->kolm31:=0
             blanksm->kolm32:=0
             blanksm->kolm33:=0
          EndIf
          blanksm->(dbSkip())
      EndDo
     case num_kv="4"
       Do While !EOF()
          @ 14,32 Say blanksm->(RecNo())
          If Empty(blanksm->kolm21).And.Empty(blanksm->kolm22).And.Empty(blanksm->kolm23).And.;
             Empty(blanksm->kolm31).And.Empty(blanksm->kolm32).And.Empty(blanksm->kolm33).And.;
             Empty(blanksm->kolm11).And.Empty(blanksm->kolm12).And.Empty(blanksm->kolm13)
          /*del, если нет данных по всем кварталам*/
             flag_del:=1
             blanksm->(dbDelete())
          Else     /*4-й квартал объявляем пустым*/
             blanksm->kolm41:=0
             blanksm->kolm42:=0
             blanksm->kolm43:=0
          EndIf
          blanksm->(dbSkip())
      EndDo
   EndCase
   If flag_del==1
      Pack    //упаковать blanksm
   EndIf
   my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
   Set Color To W+*/B
   @ 13,22 Say "Идет индексация базы данных BLANKSM"
   Index On blanksm->num+blanksm->ki To (n_blanm+".ntx")

//Masha
   Select bdkitm
   my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
   Set Color To W+*/B
   @ 13,22 Say "Идет индексация базы данных BDKITM "
   Index On bdkitm->cex + bdkitm->chert + bdkitm->ps + bdkitm->vp + bdkitm->cp;
          + bdkitm->ki + bdkitm->tm To (n_bdkitm+".ntx")
   Set Index To (n_blantm+".ntx"), (n_bdkitm+".ntx")
//Masha

       /****** Основной алгоритм обработки квартального плана ******/

   my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
   @ 13,22 Say'  Идет обработка базы данных PL03PS '
   Do While !pl03ps->(EOF())
      @ 14,35 Say pl03ps->(RecNo())
      plcp:=""
      plterm:=" "
      pltm:=pl03ps->tm
      If NeedAdd(pl03ps->cex,pl03ps->ps,pltm,pl03ps->sp)
        /*заводить карточку по данной записи плана*/

         If blanks->(dbSeek(pl03ps->cex + pl03ps->chert + pl03ps->ps + ;
                            pl03ps->vp  + plcp))
            /*по такому ключу карточка есть - добавляем данные*/
            //blanks->udal_date:="" //восстанавливаем позицию из условно удаленных
            If blanks->(Deleted())
               blanks->(dbRecall())
               blanks->term:=plterm  //возвращает needadd
               Do Case   //у помеченной на удаление записи кварт.кол-во не обнулялось при подготовке blanks
                 case num_kv="1"
                   blanks->kv1=0
                 case num_kv="2"
                   blanks->kv2=0
                 case num_kv="3"
                   blanks->kv3=0
                 case num_kv="4"
                   blanks->kv4=0
               EndCase
            EndIf

            Do Case
              case num_kv="1"
                blanks->kv1=blanks->kv1+pl03ps->kol
              case num_kv="2"
                blanks->kv2=blanks->kv2+pl03ps->kol
              case num_kv="3"
                blanks->kv3=blanks->kv3+pl03ps->kol
              case num_kv="4"
                blanks->kv4=blanks->kv4+pl03ps->kol
            EndCase

            Select blankstm
            Set Order To 1
            If blankstm->(dbSeek(blanks->num+pltm))
            /*по номеру blanks->num данные есть,т.к. есть карточка*/
               If blankstm->pr=1
                  blankstm->pr:=0
               EndIf
            Else        /*такого ТМ по данной карточке(номеру) нет*/
              blankstm->(dbAppend())
              blankstm->num=blanks->num
              blankstm->tm=pltm
              blankstm->pr:=0
            EndIf
//Masha
            Select bdkitm
            Set Order To 2
            If .NOT.bdkitm->( dbSeek(pl03ps->cex + pl03ps->chert + ;
                                     pl03ps->ps  + pl03ps->vp + ;
                                     plcp + pl03ps->ki + pltm) )
               bdkitm->(dbAppend())
               bdkitm->cex   = pl03ps->cex
               bdkitm->chert = pl03ps->chert
               bdkitm->ps    = pl03ps->ps
               bdkitm->vp    = pl03ps->vp
               bdkitm->cp    = plcp
               bdkitm->ki    = pl03ps->ki
               bdkitm->tm    = pltm
            EndIf
//Masha
            If blanksiz->(dbSeek(blanks->num+pl03ps->ki))
            /*по номеру blanks->num данные есть,т.к. есть карточка*/
            /*если такой код изд. уже есть*/
               //выделяем новые позиции появившиеся в плане, если этого
               //кода изд. не было в прошлом квартале
               /*If num_kv!="1" .And. blanks->new_pos=0 .And.;
                  blanksiz->ki>="0001" .And. blanksiz->ki<="0074" .And.;
                  blanksiz->ki!="0049" .And. blanksiz->ki!="0065"
                  Do Case
                    case num_kv="2"
                      If Empty(blanksiz->kol1)
                         blanks->new_pos:=1 //выделяем новые позиции появившиеся в плане
                      EndIf
                    case num_kv="3"
                      If Empty(blanksiz->kol2)
                         blanks->new_pos:=1 //выделяем новые позиции появившиеся в плане
                      EndIf
                    case num_kv="4"
                      If Empty(blanksiz->kol3)
                         blanks->new_pos:=1 //выделяем новые позиции появившиеся в плане
                      EndIf
                  EndCase
               EndIf*/

               Do Case
                 case num_kv="1"
                   blanksiz->kol1=blanksiz->kol1+pl03ps->kol
                 case num_kv="2"
                   blanksiz->kol2=blanksiz->kol2+pl03ps->kol
                 case num_kv="3"
                   blanksiz->kol3=blanksiz->kol3+pl03ps->kol
                 case num_kv="4"
                   blanksiz->kol4=blanksiz->kol4+pl03ps->kol
               EndCase
            Else
              /*такого кода изд. по данной карточке(номеру) нет*/
              /*If f_new=1  //выделяем добавки появившиеся в плане
                 blanks->dobav:=1
              EndIf */
              blanksiz->(dbAppend())
              blanksiz->num=blanks->num
              blanksiz->ki=pl03ps->ki
              /*If num_kv!="1" .And.blanks->new_pos=0 .And.;
                 blanksiz->ki>="0001" .And. blanksiz->ki<="0074" .And.;
                 blanksiz->ki!="0049" .And. blanksiz->ki!="0065"
                 blanks->new_pos:=1 //выделяем новые позиции появившиеся в плане
              EndIf */
              Do Case
                case num_kv="1"
                  blanksiz->kol1=blanksiz->kol1+pl03ps->kol
                case num_kv="2"
                  blanksiz->kol2=blanksiz->kol2+pl03ps->kol
                case num_kv="3"
                  blanksiz->kol3=blanksiz->kol3+pl03ps->kol
                case num_kv="4"
                  blanksiz->kol4=blanksiz->kol4+pl03ps->kol
              EndCase
            EndIf

            If blanksm->(dbSeek(blanks->num+pl03ps->ki))
               /*по номеру blanks->num данные есть,т.к. есть карточка*/
               /*если такой код изд. уже есть*/
            Else  /*такого кода изд. по данной карточке(номеру) нет*/
              blanksm->(dbAppend())
              blanksm->num=blanks->num
              blanksm->ki=pl03ps->ki
            EndIf
            Do Case
               case num_kv="1"
                  Do Case
                     case pl03ps->period="1"
                       blanksm->kolm11=blanksm->kolm11+pl03ps->kol
                     case pl03ps->period="2"
                       blanksm->kolm12=blanksm->kolm12+pl03ps->kol
                     case pl03ps->period="3"
                       blanksm->kolm13=blanksm->kolm13+pl03ps->kol
                  EndCase
               case num_kv="2"
                  Do Case
                     case pl03ps->period="1"
                       blanksm->kolm21=blanksm->kolm21+pl03ps->kol
                     case pl03ps->period="2"
                       blanksm->kolm22=blanksm->kolm22+pl03ps->kol
                     case pl03ps->period="3"
                       blanksm->kolm23=blanksm->kolm23+pl03ps->kol
                  EndCase
               case num_kv="3"
                  Do Case
                     case pl03ps->period="1"
                       blanksm->kolm31=blanksm->kolm31+pl03ps->kol
                     case pl03ps->period="2"
                       blanksm->kolm32=blanksm->kolm32+pl03ps->kol
                     case pl03ps->period="3"
                       blanksm->kolm33=blanksm->kolm33+pl03ps->kol
                  EndCase
               case num_kv="4"
                  Do Case
                     case pl03ps->period="1"
                       blanksm->kolm41=blanksm->kolm41+pl03ps->kol
                     case pl03ps->period="2"
                       blanksm->kolm42=blanksm->kolm42+pl03ps->kol
                     case pl03ps->period="3"
                       blanksm->kolm43=blanksm->kolm43+pl03ps->kol
                  EndCase
            EndCase
         Else
           /*по такому ключу карточки в БД нет*/
            blanks->(dbAppend())
            blanks->cex=pl03ps->cex
            blanks->chert=pl03ps->chert
            blanks->ps=pl03ps->ps
            blanks->vp=pl03ps->vp
            blanks->cp=plcp
            blanks->num=Nums
            blanks->term:=plterm  //возвращает needadd
            //если это не первый план первого квартала
            /*If !(f_new=0 .And. num_kv=="1")
               blanks->new_pos:=1 //выделяем новые позиции появившиеся в плане
            EndIf
            If f_new=1  //выделяем добавки появившиеся в плане
               blanks->dobav:=1
            EndIf*/
            Do Case
              case num_kv="1"
                blanks->kv1=blanks->kv1+pl03ps->kol
              case num_kv="2"
                blanks->kv2=blanks->kv2+pl03ps->kol
              case num_kv="3"
                blanks->kv3=blanks->kv3+pl03ps->kol
              case num_kv="4"
                blanks->kv4=blanks->kv4+pl03ps->kol
            EndCase

            /*такого ТМ по данной карточке(номеру) нет*/
            Select blankstm
            Set Order To 1
            blankstm->(dbAppend())
            blankstm->num=blanks->num
            blankstm->tm=pltm
            blankstm->pr:=0

            blanksiz->(dbAppend())
            blanksiz->num=blanks->num
            blanksiz->ki=pl03ps->ki
            Do Case
              case num_kv="1"
                blanksiz->kol1=blanksiz->kol1+pl03ps->kol
              case num_kv="2"
                blanksiz->kol2=blanksiz->kol2+pl03ps->kol
              case num_kv="3"
                blanksiz->kol3=blanksiz->kol3+pl03ps->kol
              case num_kv="4"
                blanksiz->kol4=blanksiz->kol4+pl03ps->kol
            EndCase

            blanksm->(dbAppend())
            blanksm->num=blanks->num
            blanksm->ki=pl03ps->ki
            Do Case
               case num_kv="1"
                  Do Case
                     case pl03ps->period="1"
                       blanksm->kolm11=blanksm->kolm11+pl03ps->kol
                     case pl03ps->period="2"
                       blanksm->kolm12=blanksm->kolm12+pl03ps->kol
                     case pl03ps->period="3"
                       blanksm->kolm13=blanksm->kolm13+pl03ps->kol
                  EndCase
               case num_kv="2"
                  Do Case
                     case pl03ps->period="1"
                       blanksm->kolm21=blanksm->kolm21+pl03ps->kol
                     case pl03ps->period="2"
                       blanksm->kolm22=blanksm->kolm22+pl03ps->kol
                     case pl03ps->period="3"
                       blanksm->kolm23=blanksm->kolm23+pl03ps->kol
                  EndCase
               case num_kv="3"
                  Do Case
                     case pl03ps->period="1"
                       blanksm->kolm31=blanksm->kolm31+pl03ps->kol
                     case pl03ps->period="2"
                       blanksm->kolm32=blanksm->kolm32+pl03ps->kol
                     case pl03ps->period="3"
                       blanksm->kolm33=blanksm->kolm33+pl03ps->kol
                  EndCase
               case num_kv="4"
                  Do Case
                     case pl03ps->period="1"
                       blanksm->kolm41=blanksm->kolm41+pl03ps->kol
                     case pl03ps->period="2"
                       blanksm->kolm42=blanksm->kolm42+pl03ps->kol
                     case pl03ps->period="3"
                       blanksm->kolm43=blanksm->kolm43+pl03ps->kol
                  EndCase
            EndCase
//Masha
            Select bdkitm
            Set Order To 2
            If .NOT.bdkitm->( dbSeek(pl03ps->cex + pl03ps->chert + pl03ps->ps;
                               + pl03ps->vp + plcp + pl03ps->ki + pltm) )
               bdkitm->(dbAppend())
               bdkitm->cex   = pl03ps->cex
               bdkitm->chert = pl03ps->chert
               bdkitm->ps    = pl03ps->ps
               bdkitm->vp    = pl03ps->vp
               bdkitm->cp    = plcp
               bdkitm->ki    = pl03ps->ki
               bdkitm->tm    = pltm
            EndIf
//Masha
            Nums=Str(Val(Nums)+1,7)
         EndIf
      EndIf
      pl03ps->(dbSkip())
   EndDo

   //сохраняем позиции введенные и снятые в одном и том же квартале в БД blan_s и blaniz_s
   my_box(12,20,15,59,B_DOUBLE+chr(32),"W+/B")
   @ 13,22 Say'    Идет обработка снятых позиций   '
   i:=0
   blanks->(dbGoTop())
   Do While !blanks->(Eof())
      @ 14,35 Say i++
      If blanks->(Deleted()) .And. blanks->cex!="AA"
         blan_s->(dbAppend())
         blan_s->cex=blanks->cex
         blan_s->chert=blanks->chert
         blan_s->ps=blanks->ps
         blan_s->vp=blanks->vp
         blan_s->cp=blanks->cp
         blan_s->num=blanks->num
         blan_s->kv1=blanks->kv1
         blan_s->kv2=blanks->kv2
         blan_s->kv3=blanks->kv3
         blan_s->kv4=blanks->kv4
         blan_s->udal_date:=SubStr(pl03ps_Si,28,4) //квартал, в к-ром введена и снята позиция
         //blan_s->perevod:=blanks->perevod
         blan_s->new_pos:=blanks->new_pos
         blan_s->dobav:=blanks->dobav
         blan_s->term:=blanks->term

         old_bliz->(dbSeek(blanks->num))
         Do While old_bliz->num==blanks->num
            blaniz_s->(dbAppend())
            blaniz_s->num=old_bliz->num
            blaniz_s->ki=old_bliz->ki
            blaniz_s->name_iz=old_bliz->name_iz
            blaniz_s->kol1=old_bliz->kol1
            blaniz_s->kol2=old_bliz->kol2
            blaniz_s->kol3=old_bliz->kol3
            blaniz_s->kol4=old_bliz->kol4
            old_bliz->(dbSkip())
         EndDo

         old_blm->(dbSeek(blanks->num))
         Do While old_blm->num==blanks->num
            blanm_s->(dbAppend())
            blanm_s->num=old_blm->num
            blanm_s->ki=old_blm->ki
            blanm_s->kolm11=old_blm->kolm11
            blanm_s->kolm12=old_blm->kolm12
            blanm_s->kolm13=old_blm->kolm13
            blanm_s->kolm21=old_blm->kolm21
            blanm_s->kolm22=old_blm->kolm22
            blanm_s->kolm23=old_blm->kolm23
            blanm_s->kolm31=old_blm->kolm31
            blanm_s->kolm32=old_blm->kolm32
            blanm_s->kolm33=old_blm->kolm33
            blanm_s->kolm41=old_blm->kolm41
            blanm_s->kolm42=old_blm->kolm42
            blanm_s->kolm43=old_blm->kolm43
            old_blm->(dbSkip())
         EndDo
      EndIf
      blanks->(dbSkip())
   EndDo

   //упаковываем blanks.dbf - удаляя те позиции, к-рые введены и сняты в одном и том же квартале
   my_box(12,20,15,59,B_DOUBLE+chr(32),"W+/B")      //добавлено 18.12.2001
   @ 13,22 Say' Идет упаковка базы данных BLANKS  '
   Select blanks
   Pack

   //восстанавливаем те записи blankstm, к-рые помечены как снятые в blanks
   //для того, чтобы сохранить посл. изменения ТМ по позициям помеченным как снятые
   my_box(12,20,15,59,B_DOUBLE+chr(32),"W+/B")
   @ 13,22 Say' Идет обработка базы данных BLANKSTM'
   Select blanks
   Set Order To
   blanks->(dbGoto(1))
   Do While !blanks->(Eof())
      @ 14,35 Say blankstm->(RecNo())
      If !Empty(blanks->(udal_date))
         If blankstm->(dbSeek(blanks->num))
            Do While blankstm->num==blanks->num
               If blankstm->pr=1
                  blankstm->pr:=0
               EndIf
               blankstm->(dbSkip())
            EndDo
         EndIf
      EndIf
      blanks->(dbSkip())
   EndDo

   Select blanks
   Set Index To (n_blan+"n.ntx") //индексация по Num, введена для опред. добавок
   Select blanksiz
   blanksiz->(dbGoTop())   //Go 1
   x_say:=1
   @ 13,22 Say' Идет обработка базы данных BLANKSIZ'
   @ 14,22 Say'                                    '
   var_num:="AAAAAAA"
   Do While !blanksiz->(Eof())
      Do Case
        case num_kv="1"
          condit:=!Empty(blanksiz->kol1)
        case num_kv="2"
          condit:=!Empty(blanksiz->kol2)
        case num_kv="3"
          condit:=!Empty(blanksiz->kol3)
        case num_kv="4"
          condit:=!Empty(blanksiz->kol4)
      EndCase
      @ 14,32 Say Str(x_say)
      x_say:=x_say+1
      If condit
//если это КИ, н-р, 7110 (добавка к КИ 0010), то делить надо на кол-во
//изделий 0010. Если в pl03iz не найден КИ 0010, то делим на кол-во изделий
//7110.
   /*      If (SubStr(blanksiz->ki,1,1)=="7").And.;
            (pl03iz->(dbSeek("00"+SubStr(blanksiz->ki,3,2))))
            Do Case
//кол-во на единицу изд. считаем как в pp01, но в случае 0 ставим 1
              case num_kv="1"
                blanksiz->kol1=Int(blanksiz->kol1/pl03iz->kol)
   //если значение количества на 1 изделие равно 0, то положим его равным 1
                If blanksiz->kol1==0
                   blanksiz->kol1=1
                EndIf
            //если кол-во на изд. в плане изменилось, то эта позиция - добавка
                If var_num!=blanksiz->num
                   blanks->(dbSeek(blanksiz->num))
                EndIf
                If blanks->dobav=0
                   If old_bliz->(dbSeek(blanksiz->num+blanksiz->ki))
                      If blanksiz->kol1!=old_bliz->kol1 .And. f_new=1
                         blanks->dobav:=1
                      EndIf
                   EndIf
                EndIf
              case num_kv="2"
                blanksiz->kol2=Int(blanksiz->kol2/pl03iz->kol)
                If blanksiz->kol2==0
                   blanksiz->kol2=1
                EndIf
            //если кол-во на изд. в плане изменилось, то эта позиция - добавка
                If var_num!=blanksiz->num
                   blanks->(dbSeek(blanksiz->num))
                EndIf
                If blanks->dobav=0
                   If old_bliz->(dbSeek(blanksiz->num+blanksiz->ki))
                      If blanksiz->kol2!=old_bliz->kol2 .And. f_new=1
                         blanks->dobav:=1
                      EndIf
                   EndIf
                EndIf
              case num_kv="3"
                blanksiz->kol3=Int(blanksiz->kol3/pl03iz->kol)
                If blanksiz->kol3==0
                   blanksiz->kol3=1
                EndIf
            //если кол-во на изд. в плане изменилось, то эта позиция - добавка
                If var_num!=blanksiz->num
                   blanks->(dbSeek(blanksiz->num))
                EndIf
                If blanks->dobav=0
                   If old_bliz->(dbSeek(blanksiz->num+blanksiz->ki))
                      If blanksiz->kol3!=old_bliz->kol3 .And. f_new=1
                         blanks->dobav:=1
                      EndIf
                   EndIf
                EndIf
              case num_kv="4"
                blanksiz->kol4=Int(blanksiz->kol4/pl03iz->kol)
                If blanksiz->kol4==0
                   blanksiz->kol4=1
                EndIf
            //если кол-во на изд. в плане изменилось, то эта позиция - добавка
                If var_num!=blanksiz->num
                   blanks->(dbSeek(blanksiz->num))
                EndIf
                If blanks->dobav=0
                   If old_bliz->(dbSeek(blanksiz->num+blanksiz->ki))
                      If blanksiz->kol4!=old_bliz->kol4 .And. f_new=1
                         blanks->dobav:=1
                      EndIf
                   EndIf
                EndIf
            EndCase
            If pl03iz->(dbSeek(blanksiz->ki))
               blanksiz->name_iz=pl03iz->naim
            EndIf
         Else*/
            If pl03iz->(dbSeek(blanksiz->ki))
               blanksiz->name_iz=pl03iz->naim
               kol_iz=0                            //подсуммировка кол-ва изделий по периоду
               Do While pl03iz->ki==blanksiz->ki
                  kol_iz=kol_iz+pl03iz->kol
                  pl03iz->(dbSkip())
               EndDo
               Do Case
                 case num_kv="1"
                   blanksiz->kol1=Int(blanksiz->kol1/kol_iz)  //pl03iz->kol)
      /*если значение количества на 1 изделие равно 0, то положим его равным 1*/
                   If blanksiz->kol1==0
                      blanksiz->kol1=1
                   EndIf
            //если кол-во на изд. в плане изменилось, то эта позиция - добавка
                   If var_num!=blanksiz->num
                      blanks->(dbSeek(blanksiz->num))
                   EndIf
                   If blanks->dobav=0
                      If old_bliz->(dbSeek(blanksiz->num+blanksiz->ki))
                         If blanksiz->kol1!=old_bliz->kol1 .And. f_new=1
                            blanks->dobav:=1
                         EndIf
                      EndIf
                   EndIf
                 case num_kv="2"
                   blanksiz->kol2=Int(blanksiz->kol2/kol_iz)  //pl03iz->kol)
                   If blanksiz->kol2==0
                      blanksiz->kol2=1
                   EndIf
            //если кол-во на изд. в плане изменилось, то эта позиция - добавка
                   If var_num!=blanksiz->num
                      blanks->(dbSeek(blanksiz->num))
                   EndIf
                   If blanks->dobav=0
                      If old_bliz->(dbSeek(blanksiz->num+blanksiz->ki))
                         If blanksiz->kol2!=old_bliz->kol2 .And. f_new=1
                            blanks->dobav:=1
                         EndIf
                      EndIf
                   EndIf
                 case num_kv="3"
                   blanksiz->kol3=Int(blanksiz->kol3/kol_iz)  //pl03iz->kol)
                   If blanksiz->kol3==0
                      blanksiz->kol3=1
                   EndIf
            //если кол-во на изд. в плане изменилось, то эта позиция - добавка
                   If var_num!=blanksiz->num
                      blanks->(dbSeek(blanksiz->num))
                   EndIf
                   If blanks->dobav=0
                      If old_bliz->(dbSeek(blanksiz->num+blanksiz->ki))
                         If blanksiz->kol3!=old_bliz->kol3 .And. f_new=1
                            blanks->dobav:=1
                         EndIf
                      EndIf
                   EndIf
                 case num_kv="4"
                   blanksiz->kol4=Int(blanksiz->kol4/kol_iz)  //pl03iz->kol)
                   If blanksiz->kol4==0
                      blanksiz->kol4=1
                   EndIf
            //если кол-во на изд. в плане изменилось, то эта позиция - добавка
                   If var_num!=blanksiz->num
                      blanks->(dbSeek(blanksiz->num))
                   EndIf
                   If blanks->dobav=0
                      If old_bliz->(dbSeek(blanksiz->num+blanksiz->ki))
                         If blanksiz->kol4!=old_bliz->kol4 .And. f_new=1
                            blanks->dobav:=1
                         EndIf
                      EndIf
                   EndIf
               EndCase
            EndIf
         //EndIf
      EndIf
      var_num:=blanksiz->num
      Skip Alias blanksiz
   EndDo

   Close old_bliz
   Delete File (kar_path+"temp\old_bliz.dbf")
   Delete File (kar_path+"temp\old_bliz.ntx")

   Close old_blm
   Delete File (kar_path+"temp\old_blm.dbf")
   Delete File (kar_path+"temp\old_blm.ntx")

   Select blanks
   Set Index To (n_blan+".ntx") //индексация по ключу cex+chert+ps+vp+cp

/*Формирование БД, содержащих преобразрванные чертежи накладных на сдачу
(chertn) из чертежей плана(chert)*/

/*   @ 13,22 Say'  Идет обработка базы данных BD02PH '
   @ 14,22 Say'                                    '
   /*Очищаем БД с преобразованными чертежами накладных*/
  /* Num_ph=Str(Val("1"),7)
   Select blanph
   Zap
   Index On blanph->cex+blanph->chert+blanph->ps+blanph->vp+blanph->cp ;
                                                       To (n_blanph+".ntx")
   Select blanphiz
   Zap
   Index On blanphiz->num+blanphiz->ki To (n_blphiz+".ntx")

   Select blanphtm
   Zap
   Index On blanphtm->num+blanphtm->tm To (n_blphtm+".ntx")

   Select bd02ph  /*проиндексирована по cex+chertN в mainkart.prg*/
   /*Go 1
   Select blanph
   chert_N:="AAA AAAAAA AA" //chert_N меняется только при обработке нового
                            //                            bd02ph->chertN
   Do While !bd02ph->(Eof())
     @ 14,35 Say bd02ph->(RecNo())
     If chert_N==bd02ph->chertN
        //Да, обрабатываем все чертежи(chert) преобразуемые в текущий(chertN)
        Do While chert_N==bd02ph->chertN
         If (blanks->(dbSeek(bd02ph->cex+bd02ph->chert)))
            cikl:=.T.
   //обрабатываем все записи из blanks по ключу bd02ph->cex+bd02ph->chert
   //(т.к. maybe разные цеха получатели)
            Do While cikl
             If (blanph->(dbSeek(bd02ph->cex+chert_N+blanks->ps+blanks->vp+;
                                                                blanks->cp)))
                //Такая карта уже есть, добавляем количества
                blanph->kv1=blanph->kv1+blanks->kv1
                blanph->kv2=blanph->kv2+blanks->kv2
                blanph->kv3=blanph->kv3+blanks->kv3
                blanph->kv4=blanph->kv4+blanks->kv4
                blanksiz->(dbSeek(blanks->num))
                // Цикл по всем КИ в пределах текущего Num
                Do While blanksiz->num==blanks->num
                 If (blanphiz->(dbSeek(blanph->num+blanksiz->ki)))
                   //такой Код Изделия в карточке есть
                   blanphiz->kol1=blanphiz->kol1+blanksiz->kol1
                   blanphiz->kol2=blanphiz->kol2+blanksiz->kol2
                   blanphiz->kol3=blanphiz->kol3+blanksiz->kol3
                   blanphiz->kol4=blanphiz->kol4+blanksiz->kol4
                 Else
                   //такого КИ в карточке нет
                   blanphiz->(dbAppend())
                   blanphiz->num=blanph->num
                   blanphiz->ki=blanksiz->ki
                   blanphiz->name_iz=blanksiz->name_iz
                   blanphiz->kol1=blanphiz->kol1+blanksiz->kol1
                   blanphiz->kol2=blanphiz->kol2+blanksiz->kol2
                   blanphiz->kol3=blanphiz->kol3+blanksiz->kol3
                   blanphiz->kol4=blanphiz->kol4+blanksiz->kol4
                 EndIf
                 Skip Alias blanksiz
                EndDo
                blankstm->(dbSeek(blanks->num))
                // Цикл по всем ТМ в пределах текущего Num
                Do While blankstm->num==blanks->num
                 If (blanphtm->(dbSeek(blanph->num+blankstm->tm)))
                   //такой Техн.Маршрут в карточке есть
                 Else
                   //такого ТМ в карточке нет
                   blanphtm->(dbAppend())
                   blanphtm->num=blanph->num
                   blanphtm->tm=blankstm->tm
                   blanphtm->pr=blankstm->pr
                 EndIf
                 Skip Alias blankstm
                EndDo
             Else
               //Такой карты в blanph нет, вводим новую карту
                blanph->(dbAppend())
                blanph->cex=bd02ph->cex
                blanph->chert=chert_N
                blanph->ps=blanks->ps
                blanph->vp=blanks->vp
                blanph->cp=blanks->cp
                blanph->new_pos:=blanks->new_pos
                blanph->dobav:=blanks->dobav
                blanph->udal_date:=blanks->udal_date
                blanph->term:=blanks->term
                blanph->num=Num_ph
                Num_ph=Str(Val(Num_ph)+1,7)
                blanph->kv1=blanph->kv1+blanks->kv1
                blanph->kv2=blanph->kv2+blanks->kv2
                blanph->kv3=blanph->kv3+blanks->kv3
                blanph->kv4=blanph->kv4+blanks->kv4
                blanksiz->(dbSeek(blanks->num))
                // Цикл по всем КИ в пределах текущего Num
                Do While blanksiz->num==blanks->num
                 blanphiz->(dbAppend())
                 blanphiz->num=blanph->num
                 blanphiz->ki=blanksiz->ki
                 blanphiz->name_iz=blanksiz->name_iz
                 blanphiz->kol1=blanphiz->kol1+blanksiz->kol1
                 blanphiz->kol2=blanphiz->kol2+blanksiz->kol2
                 blanphiz->kol3=blanphiz->kol3+blanksiz->kol3
                 blanphiz->kol4=blanphiz->kol4+blanksiz->kol4
                 Skip Alias blanksiz
                EndDo
                blankstm->(dbSeek(blanks->num))
                // Цикл по всем ТМ в пределах текущего Num
                Do While blankstm->num==blanks->num
                 blanphtm->(dbAppend())
                 blanphtm->num=blanph->num
                 blanphtm->tm=blankstm->tm
                 blanphtm->pr=blankstm->pr
                 Skip Alias blankstm
                EndDo
             EndIf
             blanks->perevod=1
             Skip Alias blanks
             If !((blanks->cex==bd02ph->cex).And.;
                  (blanks->chert==bd02ph->chert))
                cikl:=.F.   //все записи по текущему ключу
                            //bd02ph->cex+bd02ph->chert обработаны
             EndIf
            EndDo
         EndIf
         Skip Alias bd02ph
        EndDo
     Else //Нет, обрабатываем новый chertN
        chert_N:=bd02ph->chertN
        If (blanks->(dbSeek(bd02ph->cex+chert_N)))
            cikl:=.T.
   //обрабатываем все записи из blanks по ключу bd02ph->cex+chert_N
   //(т.к. maybe разные цеха получатели)
            Do While cikl
             If (blanph->(dbSeek(bd02ph->cex+chert_N+blanks->ps+blanks->vp+;
                                                                blanks->cp)))
                //Такая карта уже есть, добавляем количества
                blanph->kv1=blanph->kv1+blanks->kv1
                blanph->kv2=blanph->kv2+blanks->kv2
                blanph->kv3=blanph->kv3+blanks->kv3
                blanph->kv4=blanph->kv4+blanks->kv4
                blanksiz->(dbSeek(blanks->num))
                // Цикл по всем КИ в пределах текущего Num
                Do While blanksiz->num==blanks->num
                 If (blanphiz->(dbSeek(blanph->num+blanksiz->ki)))
                   //такой Код Изделия в карточке есть
                   blanphiz->kol1=blanphiz->kol1+blanksiz->kol1
                   blanphiz->kol2=blanphiz->kol2+blanksiz->kol2
                   blanphiz->kol3=blanphiz->kol3+blanksiz->kol3
                   blanphiz->kol4=blanphiz->kol4+blanksiz->kol4
                 Else
                   //такого КИ в карточке нет
                   blanphiz->(dbAppend())
                   blanphiz->num=blanph->num
                   blanphiz->ki=blanksiz->ki
                   blanphiz->name_iz=blanksiz->name_iz
                   blanphiz->kol1=blanphiz->kol1+blanksiz->kol1
                   blanphiz->kol2=blanphiz->kol2+blanksiz->kol2
                   blanphiz->kol3=blanphiz->kol3+blanksiz->kol3
                   blanphiz->kol4=blanphiz->kol4+blanksiz->kol4
                 EndIf
                 Skip Alias blanksiz
                EndDo
                blankstm->(dbSeek(blanks->num))
                // Цикл по всем ТМ в пределах текущего Num
                Do While blankstm->num==blanks->num
                 If (blanphtm->(dbSeek(blanph->num+blankstm->tm)))
                   //такой Техн.Маршрут в карточке есть
                 Else
                   //такого ТМ в карточке нет
                   blanphtm->(dbAppend())
                   blanphtm->num=blanph->num
                   blanphtm->tm=blankstm->tm
                   blanphtm->pr=blankstm->pr
                 EndIf
                 Skip Alias blankstm
                EndDo
             Else
               //Такой карты в blanph нет, вводим новую карту
                blanph->(dbAppend())
                blanph->cex=bd02ph->cex
                blanph->chert=chert_N
                blanph->ps=blanks->ps
                blanph->vp=blanks->vp
                blanph->cp=blanks->cp
                blanph->new_pos:=blanks->new_pos
                blanph->dobav:=blanks->dobav
                blanph->udal_date:=blanks->udal_date
                blanph->term:=blanks->term
                blanph->num=Num_ph
                Num_ph=Str(Val(Num_ph)+1,7)
                blanph->kv1=blanph->kv1+blanks->kv1
                blanph->kv2=blanph->kv2+blanks->kv2
                blanph->kv3=blanph->kv3+blanks->kv3
                blanph->kv4=blanph->kv4+blanks->kv4
                blanksiz->(dbSeek(blanks->num))
                // Цикл по всем КИ в пределах текущего Num
                Do While blanksiz->num==blanks->num
                 blanphiz->(dbAppend())
                 blanphiz->num=blanph->num
                 blanphiz->ki=blanksiz->ki
                 blanphiz->name_iz=blanksiz->name_iz
                 blanphiz->kol1=blanphiz->kol1+blanksiz->kol1
                 blanphiz->kol2=blanphiz->kol2+blanksiz->kol2
                 blanphiz->kol3=blanphiz->kol3+blanksiz->kol3
                 blanphiz->kol4=blanphiz->kol4+blanksiz->kol4
                 Skip Alias blanksiz
                EndDo
                blankstm->(dbSeek(blanks->num))
                // Цикл по всем ТМ в пределах текущего Num
                Do While blankstm->num==blanks->num
                 blanphtm->(dbAppend())
                 blanphtm->num=blanph->num
                 blanphtm->tm=blankstm->tm
                 blanphtm->pr=blankstm->pr
                 Skip Alias blankstm
                EndDo
             EndIf
             blanks->perevod=1
             Skip Alias blanks
             If !((blanks->cex==bd02ph->cex).And.(blanks->chert==chert_N))
                cikl:=.F.   //все записи по текущему ключу
                            //bd02ph->cex+chert_N обработаны
             EndIf
            EndDo
        EndIf
     EndIf
   EndDo */

   Close pl03ps
   Close pl03iz

   //my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
   //Set Color To W+*/B
   /*@ 13,22 Say " Идет сортировка базы данных BLANPH"
   Select blanph
  /*Sort To blanph1 On Cex /A, Chert /A, Ps /A, Vp /A, Cp /A*/
   /*n_blanp1=SubStr(n_blanph,1,Rat("\",n_blanph))+"blanph1"
   Copy To (n_blanp1)
   Close blanph
   Delete File (n_blanph+".dbf")
   Rename (n_blanp1+".dbf") To (n_blanph+".dbf")
   Delete File (n_blanph+".dbt")
   Rename (n_blanp1+".dbt") To (n_blanph+".dbt")

   my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")*/
   //Set Color To W+*/B
   /*@ 13,22 Say "Идет сортировка базы данных BLANPHIZ"
   Select blanphiz
   n_blizp1=SubStr(n_blphiz,1,Rat("\",n_blphiz))+"blanpi1"
   Copy To (n_blizp1)                /*Sort To blanpi1 On Num /A, KI /A*/
   /*Close blanphiz
   Delete File (n_blphiz+".dbf")
   Rename (n_blizp1+".dbf") To (n_blphiz+".dbf")

   my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")*/
   //Set Color To W+*/B
   /*@ 13,22 Say "Идет сортировка базы данных BLANPHTM"
   Select blanphtm
   n_bltmp1=SubStr(n_blphtm,1,Rat("\",n_blphtm))+"blanpt1"
   Copy To (n_bltmp1)                /*Sort To blanpt1 On Num /A, TM /A*/
   /*Close blanphtm
   Delete File (n_blphtm+".dbf")
   Rename (n_bltmp1+".dbf") To (n_blphtm+".dbf")

   Close bd02ph*/

   my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
   Set Color To W+*/B
   @ 13,22 Say "Идет сортировка базы данных BLANIZ_S"
   Select blaniz_s
   Sort To (kar_path+"temp\blaniz1") On Num /A, KI /A
   Close blaniz_s
   Delete File (n_blaniz_s+".dbf")
   Rename (kar_path+"temp\blaniz1.dbf") To (n_blaniz_s+".dbf")

   my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
   Set Color To W+*/B
   @ 13,22 Say "Идет сортировка базы данных BLANM_S "
   Select blanm_s
   Sort To (kar_path+"temp\blanm1") On Num /A, KI /A
   Close blanm_s
   Delete File (n_blanm_s+".dbf")
   Rename (kar_path+"temp\blanm1.dbf") To (n_blanm_s+".dbf")

   my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
   Set Color To W+*/B
   @ 13,22 Say "  Идет сортировка базы данных BLAN_S"
   Select blan_s
   Sort To (kar_path+"temp\blan1") On Cex /A, Chert /A, Ps /A, Vp /A, Cp /A
   Close blan_s
   Delete File (n_blan_s+".dbf")
   Rename (kar_path+"temp\blan1.dbf") To (n_blan_s+".dbf")
   Delete File (n_blan_s+".dbt")
   Rename (kar_path+"temp\blan1.dbt") To (n_blan_s+".dbt")

   my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
   Set Color To W+*/B
   @ 13,22 Say "Идет сортировка базы данных BLANKSIZ"
   Select blanksiz
   n_blaniz1=SubStr(n_blaniz,1,Rat("\",n_blaniz))+"blanksi1"
   Copy To (n_blaniz1)                /*Sort To blanksi1 On Num /A, KI /A*/
   Close blanksiz
   Delete File (n_blaniz+".dbf")
   Rename (n_blaniz1+".dbf") To (n_blaniz+".dbf")

   my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
   Set Color To W+*/B
   @ 13,22 Say "Идет сортировка базы данных BLANKSM "
   Select blanksm
   n_blanm1=SubStr(n_blanm,1,Rat("\",n_blanm))+"blanksm1"
   Copy To (n_blanm1)                /*Sort To blanksm1 On Num /A, KI /A*/
   Close blanksm
   Delete File (n_blanm+".dbf")
   Rename (n_blanm1+".dbf") To (n_blanm+".dbf")

   my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
   Set Color To W+*/B
   @ 13,22 Say "Идет сортировка базы данных BLANKSTM"
   Select blankstm
   n_blantm1=SubStr(n_blantm,1,Rat("\",n_blantm))+"blankst1"
   Copy To (n_blantm1)                /*Sort To blanktm1 On Num /A, TM /A*/
   Close blankstm
   Delete File (n_blantm+".dbf")
   Rename (n_blantm1+".dbf") To (n_blantm+".dbf")

//Masha
   my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
   Set Color To W+*/B
   @ 13,22 Say "Идет индексация базы данных BDKITM"
   Select bdkitm
   Index On bdkitm->cex + bdkitm->chert + bdkitm->ps + bdkitm->vp + bdkitm->cp;
          + bdkitm->ki + bdkitm->tm To (n_bdkitm+".ntx")
//Masha
//Masha
   my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
   Set Color To W+*/B
   @ 13,22 Say "Идет сортировка базы данных BDKITM"
   Select bdkitm
   n_bdkitm1=SubStr(n_bdkitm,1,Rat("\",n_bdkitm))+"bdkitm01"
   Copy To (n_bdkitm1)                /*Sort To bdkitm1 On Num /A, TM /A*/
   Close bdkitm
   Delete File (n_bdkitm+".dbf")
   Rename (n_bdkitm1+".dbf") To (n_bdkitm+".dbf")
//Masha

   my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
   Set Color To W+*/B
   @ 13,22 Say "  Идет сортировка базы данных BLANKS"
   Set Deleted On
   Select blanks
  /*Sort To blanks1 On Cex /A, Chert /A, Ps /A, Vp /A, Cp /A*/
   n_blan1=SubStr(n_blan,1,Rat("\",n_blan))+"blanks1"
   Copy To (n_blan1)
   Close blanks
   Delete File (n_blan+".dbf")
   Rename (n_blan1+".dbf") To (n_blan+".dbf")
   Delete File (n_blan+".dbt")
   Rename (n_blan1+".dbt") To (n_blan+".dbt")
   Set Deleted Off

   If AlNetUse(n_blan,.T.,5)
   Else
      my_box(12,18,15,60,B_DOUBLE+chr(32),"W+/R")
      @ 13,19 Say' Файл BLANKS.dbf не доступен '
      @ 14,19 Say'  Нажмите любую клавишу ...  '
      InKey(0)
      Restore Screen
      Close All
      Clear All
      Quit
   EndIf
   blanks->(dbAppend())
   blanks->cex="AA"
   blanks->chert="AAA AAAAAA AA"
   blanks->ps="A"
   blanks->vp="A"
   blanks->cp="AA"
   blanks->num=Nums
   blanks->(dbDelete())
   Close blanks
Else
   my_box(12,24,15,61,B_DOUBLE+chr(32),"W+/R")
   @ 13,26 Say " Неверный номер квартала в PL03PS "
   @ 14,26 Say "      Нажмите любую клавишу...    "
   Inkey(0)
   Restore Screen
   Close All
   Clear All
   Quit
EndIf
Delete File (n_blan+".ntx")
Delete File (n_blan+"n.ntx")
Delete File (n_blaniz+".ntx")
Delete File (n_blanm+".ntx")
Delete File (n_blantm+".ntx")
//Delete File (n_pl03iz+".ntx")
//Delete File (n_blanph+".ntx")
//Delete File (n_blphiz+".ntx")
//Delete File (n_blphtm+".ntx")
Delete File (n_bdkitm+".ntx")
Delete File (kar_path+"temp\old_bliz.dbf")
Delete File (kar_path+"temp\old_bliz.ntx")
Delete File (kar_path+"temp\old_blm.dbf")
Delete File (kar_path+"temp\old_blm.ntx")
Delete File (kar_path+"temp\pl03ps.dbf")
Delete File (kar_path+"temp\pl03iz.dbf")
Delete File (kar_path+"temp\pl03iz.ntx")
Return

/******************************/
/*Дополнительные процедуры для FormBlank (формирование учетных карточек)*/

/* Функция проверяет заводить карточку по данной записи из плана и возвращает
.F. - если не заводить
.T. - если заводить карточку и номер цеха получателя в переменной plcp и признак термообработки в переменной plterm*/

Function NeedAdd(cex,ps,tm,sp) /*заводить карточку по данной записи из плана*/
 Local k,i,ex:=.F.,cex_t,cex_n
 If sp=="00"          /*нет, это не межцеховой маршрут*/
    Return .F.
 EndIf
 my_tm:=tm
 my_bu:="01"
 sm41(@my_tm,@my_bu,@my_count)
 If At("A",my_tm)>0
    tm:=SubStr(my_tm,1,At("A",my_tm)-1)
 Else
    tm:=AllTrim(my_tm)
 EndIf
/*Дополнительное сокращение маршрута из pp03 - это было для bu=="01"*/ //убрано 31.05.07
// k:=Len(tm)
// Do While !ex
//   cex_t:=SubStr(tm,1,2)
//   cex_n:=If(3<=k-1, SubStr(tm,3,2), "")
//   If (cex_t=="60").Or.(cex_t=="61") /*1-й цех это 60 или 61*/
//      If Ascan(T4567,cex_n)>0        /*след. цех принадлежит таблице T4567*/
//         tm:=SubStr(tm,3)          /*удаляем 1-й цех из ТМ*/
//      Else
//         ex:=.T.
//      EndIf
//   Else
//      ex:=.T.
//   EndIf
// EndDo
 k:=Len(tm)
 If Len(tm)==2       /*нет, это внутрицеховой маршрут*/
    Return .F.
 EndIf

 /*определение цеха получателя*/
 count_in:=0 /*кол-во вхождений цеха сдатчика в ТМ*/
 For i:=1 To k-1 Step 2
    If SubStr(tm,i,2)==cex
       count_in:=count_in+1
       If Val(ps)==count_in
          If i==(k-1)   /*нет, это последний цех в маршруте*/
             Return .F.
          Else          /*да, это не последний цех в маршруте*/
             plcp:=SubStr(tm,i+2,2) /*определили цех получатель*/
             /*Определение термообработки*/ //введено 26.01.09
             plterm:=" "
             //если cex=60,61 и перед ним в tm только 60,61 и plcp входит в T4567, то это термообработка
             If ((cex="60").Or.(cex="61")).And.(Ascan(T4567,plcp)>0)
                plterm:="T" //англ.загл.
                For k1:=1 To i-1 Step 2
                    If (SubStr(tm,k1,2)<>"60").And.(SubStr(tm,k1,2)<>"61")
                       plterm:=" "
                       exit
                    EndIf
                Next
             EndIf
             /*Определение термообработки*/
             Return .T.
          EndIf
       EndIf
    EndIf
 Next

 If count_in==0   /* в новом ТМ cex отсутствует */
    Return .F.
 EndIf
Return .T.


/*Формирование БД blanph и blanphiz для преобразованных чертежей
(чертежей накладных на сдачу, в которые преобразуются чертежи плана
по справочнику bd02ph)*/

Procedure FormBlanPH()

 /*Формирование БД, содержащих преобразованные чертежи*/
 Set Color To W+/W
 @ 12,15 Clear To 18,60

 my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
 Select blankstm
 Set Color To W+*/B
 @ 13,22 Say "Идет индексация базы данных BLANKSTM"
 Index On blankstm->num+blankstm->tm To (n_blantm+".ntx")

 my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
 Select blanksiz
 Set Color To W+*/B
 @ 13,22 Say "Идет индексация базы данных BLANKSIZ"
 Index On blanksiz->num+blanksiz->ki To (n_blaniz+".ntx")

 Select blanks
 my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
 Set Color To W+*/B
 @ 13,22 Say " Идет индексация базы данных BLANKS"
 Index On blanks->cex+blanks->chert+blanks->ps+blanks->vp+blanks->cp ;
 To (n_blan+".ntx")

 my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
 @ 13,22 Say'  Идет обработка базы данных BD02PH '

 /*Очищаем БД с преобразованными чертежами*/
 Num_ph=Str(Val("1"),7)
 Select blanph
 Zap
 Index On blanph->cex+blanph->chert+blanph->ps+blanph->vp+blanph->cp ;
                                                  To (n_blanph+".ntx")
 Select blanphtm
 Zap
 Index On blanphtm->num+blanphtm->tm To (n_blphtm+".ntx")

 Select blanphiz
 Zap
 Index On blanphiz->num+blanphiz->ki To (n_blphiz+".ntx")

 Select bd02ph  /*проиндексирована по cex+chertN в mainkart.prg*/
 Go 1
 Select blanph
 chert_N:="AAA AAAAAA AA" //chert_N меняется только при обработке нового
                          //                            bd02ph->chertN
 Do While !bd02ph->(Eof())
   @ 14,35 Say bd02ph->(RecNo())
   If chert_N==bd02ph->chertN
        //Да, обрабатываем все чертежи(chert) преобразуемые в текущий(chertN)
      Do While chert_N==bd02ph->chertN
       If (blanks->(dbSeek(bd02ph->cex+bd02ph->chert)))
          cikl:=.T.
 //обрабатываем все записи из blanks по ключу bd02ph->cex+bd02ph->chert
 //(т.к. maybe разные цеха получатели)
          Do While cikl
           If (blanph->(dbSeek(bd02ph->cex+chert_N+blanks->ps+blanks->vp+;
                                                              blanks->cp)))
              //Такая карта уже есть, добавляем количества
              blanph->kv1=blanph->kv1+blanks->kv1
              blanph->kv2=blanph->kv2+blanks->kv2
              blanph->kv3=blanph->kv3+blanks->kv3
              blanph->kv4=blanph->kv4+blanks->kv4
              blanksiz->(dbSeek(blanks->num))
              // Цикл по всем КИ в пределах текущего Num
              Do While blanksiz->num==blanks->num
               If (blanphiz->(dbSeek(blanph->num+blanksiz->ki)))
                 //такой Код Изделия в карточке есть
                 blanphiz->kol1=blanphiz->kol1+blanksiz->kol1
                 blanphiz->kol2=blanphiz->kol2+blanksiz->kol2
                 blanphiz->kol3=blanphiz->kol3+blanksiz->kol3
                 blanphiz->kol4=blanphiz->kol4+blanksiz->kol4
               Else
                 //такого КИ в карточке нет
                 blanphiz->(dbAppend())
                 blanphiz->num=blanph->num
                 blanphiz->ki=blanksiz->ki
                 blanphiz->name_iz=blanksiz->name_iz
                 blanphiz->kol1=blanphiz->kol1+blanksiz->kol1
                 blanphiz->kol2=blanphiz->kol2+blanksiz->kol2
                 blanphiz->kol3=blanphiz->kol3+blanksiz->kol3
                 blanphiz->kol4=blanphiz->kol4+blanksiz->kol4
               EndIf
               Skip Alias blanksiz
              EndDo
              blankstm->(dbSeek(blanks->num))
              // Цикл по всем ТМ в пределах текущего Num
              Do While blankstm->num==blanks->num
               If (blanphtm->(dbSeek(blanph->num+blankstm->tm)))
                 //такой Техн.Маршрут в карточке есть
               Else
                 //такого ТМ в карточке нет
                 blanphtm->(dbAppend())
                 blanphtm->num=blanph->num
                 blanphtm->tm=blankstm->tm
                 blanphtm->pr=blankstm->pr
               EndIf
               Skip Alias blankstm
              EndDo
           Else
             //Такой карты в blanph нет, вводим новую карту
              blanph->(dbAppend())
              blanph->cex=bd02ph->cex
              blanph->chert=chert_N
              blanph->ps=blanks->ps
              blanph->vp=blanks->vp
              blanph->cp=blanks->cp
              blanph->new_pos:=blanks->new_pos
              blanph->dobav:=blanks->dobav
              blanph->udal_date:=blanks->udal_date
              blanph->term:=blanks->term
              blanph->num=Num_ph
              Num_ph=Str(Val(Num_ph)+1,7)
              blanph->kv1=blanph->kv1+blanks->kv1
              blanph->kv2=blanph->kv2+blanks->kv2
              blanph->kv3=blanph->kv3+blanks->kv3
              blanph->kv4=blanph->kv4+blanks->kv4
              blanksiz->(dbSeek(blanks->num))
              // Цикл по всем КИ в пределах текущего Num
              Do While blanksiz->num==blanks->num
               blanphiz->(dbAppend())
               blanphiz->num=blanph->num
               blanphiz->ki=blanksiz->ki
               blanphiz->name_iz=blanksiz->name_iz
               blanphiz->kol1=blanphiz->kol1+blanksiz->kol1
               blanphiz->kol2=blanphiz->kol2+blanksiz->kol2
               blanphiz->kol3=blanphiz->kol3+blanksiz->kol3
               blanphiz->kol4=blanphiz->kol4+blanksiz->kol4
               Skip Alias blanksiz
              EndDo
              blankstm->(dbSeek(blanks->num))
              // Цикл по всем ТМ в пределах текущего Num
              Do While blankstm->num==blanks->num
               blanphtm->(dbAppend())
               blanphtm->num=blanph->num
               blanphtm->tm=blankstm->tm
               blanphtm->pr=blankstm->pr
               Skip Alias blankstm
              EndDo
           EndIf
           blanks->perevod=1
           Skip Alias blanks
           If !((blanks->cex==bd02ph->cex).And.(blanks->chert==bd02ph->chert))
              cikl:=.F.   //все записи по текущему ключу
                          //bd02ph->cex+bd02ph->chert обработаны
           EndIf
          EndDo
       EndIf
       Skip Alias bd02ph
      EndDo
   Else //Нет, обрабатываем новый chertN
      chert_N:=bd02ph->chertN
      If (blanks->(dbSeek(bd02ph->cex+chert_N)))
          cikl:=.T.
 //обрабатываем все записи из blanks по ключу bd02ph->cex+chert_N
 //(т.к. maybe разные цеха получатели)
          Do While cikl
           If (blanph->(dbSeek(bd02ph->cex+chert_N+blanks->ps+blanks->vp+;
                                                              blanks->cp)))
              //Такая карта уже есть, добавляем количества
              blanph->kv1=blanph->kv1+blanks->kv1
              blanph->kv2=blanph->kv2+blanks->kv2
              blanph->kv3=blanph->kv3+blanks->kv3
              blanph->kv4=blanph->kv4+blanks->kv4
              blanksiz->(dbSeek(blanks->num))
              // Цикл по всем КИ в пределах текущего Num
              Do While blanksiz->num==blanks->num
               If (blanphiz->(dbSeek(blanph->num+blanksiz->ki)))
                 //такой Код Изделия в карточке есть
                 blanphiz->kol1=blanphiz->kol1+blanksiz->kol1
                 blanphiz->kol2=blanphiz->kol2+blanksiz->kol2
                 blanphiz->kol3=blanphiz->kol3+blanksiz->kol3
                 blanphiz->kol4=blanphiz->kol4+blanksiz->kol4
               Else
                 //такого КИ в карточке нет
                 blanphiz->(dbAppend())
                 blanphiz->num=blanph->num
                 blanphiz->ki=blanksiz->ki
                 blanphiz->name_iz=blanksiz->name_iz
                 blanphiz->kol1=blanphiz->kol1+blanksiz->kol1
                 blanphiz->kol2=blanphiz->kol2+blanksiz->kol2
                 blanphiz->kol3=blanphiz->kol3+blanksiz->kol3
                 blanphiz->kol4=blanphiz->kol4+blanksiz->kol4
               EndIf
               Skip Alias blanksiz
              EndDo
              blankstm->(dbSeek(blanks->num))
              // Цикл по всем ТМ в пределах текущего Num
              Do While blankstm->num==blanks->num
               If (blanphtm->(dbSeek(blanph->num+blankstm->tm)))
                 //такой Техн.Маршрут в карточке есть
               Else
                 //такого ТМ в карточке нет
                 blanphtm->(dbAppend())
                 blanphtm->num=blanph->num
                 blanphtm->tm=blankstm->tm
                 blanphtm->pr=blankstm->pr
               EndIf
               Skip Alias blankstm
              EndDo
           Else
             //Такой карты в blanph нет, вводим новую карту
              blanph->(dbAppend())
              blanph->cex=bd02ph->cex
              blanph->chert=chert_N
              blanph->ps=blanks->ps
              blanph->vp=blanks->vp
              blanph->cp=blanks->cp
              blanph->new_pos:=blanks->new_pos
              blanph->dobav:=blanks->dobav
              blanph->udal_date:=blanks->udal_date
              blanph->term:=blanks->term
              blanph->num=Num_ph
              Num_ph=Str(Val(Num_ph)+1,7)
              blanph->kv1=blanph->kv1+blanks->kv1
              blanph->kv2=blanph->kv2+blanks->kv2
              blanph->kv3=blanph->kv3+blanks->kv3
              blanph->kv4=blanph->kv4+blanks->kv4
              blanksiz->(dbSeek(blanks->num))
              // Цикл по всем КИ в пределах текущего Num
              Do While blanksiz->num==blanks->num
               blanphiz->(dbAppend())
               blanphiz->num=blanph->num
               blanphiz->ki=blanksiz->ki
               blanphiz->name_iz=blanksiz->name_iz
               blanphiz->kol1=blanphiz->kol1+blanksiz->kol1
               blanphiz->kol2=blanphiz->kol2+blanksiz->kol2
               blanphiz->kol3=blanphiz->kol3+blanksiz->kol3
               blanphiz->kol4=blanphiz->kol4+blanksiz->kol4
               Skip Alias blanksiz
              EndDo
              blankstm->(dbSeek(blanks->num))
              // Цикл по всем ТМ в пределах текущего Num
              Do While blankstm->num==blanks->num
               blanphtm->(dbAppend())
               blanphtm->num=blanph->num
               blanphtm->tm=blankstm->tm
               blanphtm->pr=blankstm->pr
               Skip Alias blankstm
              EndDo
           EndIf
           blanks->perevod=1
           Skip Alias blanks
           If !((blanks->cex==bd02ph->cex).And.(blanks->chert==chert_N))
              cikl:=.F.   //все записи по текущему ключу
                          //bd02ph->cex+chert_N обработаны
           EndIf
          EndDo
      EndIf
   EndIf
 EndDo

 my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
 Set Color To W+*/B
 @ 13,22 Say " Идет сортировка базы данных BLANPH"
 Select blanph
/*Sort To blanph1 On Cex /A, Chert /A, Ps /A, Vp /A, Cp /A*/
 n_blanp1=SubStr(n_blanph,1,Rat("\",n_blanph))+"blanph1"
 Copy To (n_blanp1)
 Close blanph
 Delete File (n_blanph+".dbf")
 Rename (n_blanp1+".dbf") To (n_blanph+".dbf")
 Delete File (n_blanph+".dbt")
 Rename (n_blanp1+".dbt") To (n_blanph+".dbt")

 my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
 Set Color To W+*/B
 @ 13,22 Say "Идет сортировка базы данных BLANPHIZ"
 Select blanphiz
 n_blizp1=SubStr(n_blphiz,1,Rat("\",n_blphiz))+"blanpi1"
 Copy To (n_blizp1)                /*Sort To blanpi1 On Num /A, KI /A*/
 Close blanphiz
 Delete File (n_blphiz+".dbf")
 Rename (n_blizp1+".dbf") To (n_blphiz+".dbf")

 my_box(12,20,15,60,B_DOUBLE+chr(32),"W+/B")
 Set Color To W+*/B
 @ 13,22 Say "Идет сортировка базы данных BLANPHTM"
 Select blanphtm
 n_bltmp1=SubStr(n_blphtm,1,Rat("\",n_blphtm))+"blanpt1"
 Copy To (n_bltmp1)                /*Sort To blanpt1 On Num /A, TM /A*/
 Close blanphtm
 Delete File (n_blphtm+".dbf")
 Rename (n_bltmp1+".dbf") To (n_blphtm+".dbf")

 Close bd02ph
 Close blanks
 Close blanksiz
 Close blankstm
 Delete File (n_blan+".ntx")
 Delete File (n_blaniz+".ntx")
 Delete File (n_blantm+".ntx")
 Delete File (n_blanph+".ntx")
 Delete File (n_blphiz+".ntx")
 Delete File (n_blphtm+".ntx")
Return
