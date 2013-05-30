*   СОЗДАНИЕ АРХИВА ПО УКОМПЛЕКТ-ТИ
*   сначала копируется bd02ki(ACY)
*   затем создается из него архив
*   Создание архива по снятым и добавленным позициям




#include "Fileio.ch"
#include "Box.ch"
func PODCHET(flNewYear)
Local tek_dir,put_asu,si_pdo,si_asu,si_pdo04,si_asu04,si_pdo98,si_asu98,day_pdo,day_asu,;
/*Masha*/put_asu_nc,si_asu_nc,data_asu_nc,day_asu_nc,mes_asu_nc,god_asu_nc,;
/*Masha*/put_pdo_nc,si_pdo_nc,data_pdo_nc,day_pdo_nc,mes_pdo_nc,god_pdo_nc,;
/*Макарова*/put_asu_c1,put_pdo_c1,put_asu_td,put_pdo_td,;
      data_asu,data_pdo,god_asu,god_pdo,arx_put,;
      last_god,epoch:='20',mes_asu,Box,i,;
      nErr,put_asu04,put_asu98,put_pdo04,put_pdo98

private put_pdo,put_,mes_pdo, masha_flag:=0
/*aAsu:={{'bd02ki',"k:\pdo"+chr(92),'056','13/01/02'},{}}
aPdo:={{'bd02ki','c:\karta'+chr(92),'',''},{}}
aPdo_dopol:={{'bd02ki_','c:\karta'+chr(92)},{}}
n_bd02ki_:='c:\karta\bd02ki_'*/
set cursor off
Save Screen
*----------------------------------------------
 //Копирование Сбытовских файлов
 /*If !CopySbt()
    Return (.F.)
 End*/
*----------------------------------------------
  //  получить  путь к bd02ki на сервере ОАСУП
      for i:=1 to len(aAsu)
          if aAsu[i,1] == 'bd02ki'
             put_asu:=aASU[i,2]+aASU[i,1]+".dbf"
             put_asu_c1:=aASU[i,2]+"bd02nc1.dbf" /*Макарова*/ 
             put_asu_td:=aASU[i,2]+"nstd.dbf" /*Макарова 26.02.13*/
             si_asu:=aAsu[i,3]+aAsu[i,4]
             exit
          end
      next
      if !fileMN(put_asu,10)
         boxik(11,18,15,60,' Нет файла BD02KI.dbf на сервере ОАСУП ',B_DOUBLE,"W+/r")
         RETURN (.f.)
      end
      if !fileMN(put_asu_c1,10)
         boxik(11,18,15,60,' Нет файла BD02NC1.dbf на сервере ОАСУП ',B_DOUBLE,"W+/r")
      end
      if !fileMN(put_asu_td,10)
         alert(' Нет файла NSTD.dbf на сервере ОАСУП ')
      end
*----------------------------------------------
  //  получить  путь к bd02ki04 на сервере ОАСУП /*Макарова*/
      for i:=1 to len(aAsu)
          if aAsu[i,1] == 'bd02ki04'
             put_asu04:=aASU[i,2]+aASU[i,1]+".dbf"
             si_asu04:=aAsu[i,3]+aAsu[i,4]
             exit
          end
      next
      if !fileMN(put_asu04,10)
         boxik(11,18,15,60,' Нет файла BD02KI04.dbf на сервере ОАСУП ',B_DOUBLE,"W+/r")
         RETURN (.f.)
      end
*----------------------------------------------
  //  получить  путь к bd02ki98 на сервере ОАСУП /*Макарова*/
      for i:=1 to len(aAsu)
          if aAsu[i,1] == 'bd02ki98'
             put_asu98:=aASU[i,2]+aASU[i,1]+".dbf"
             si_asu98:=aAsu[i,3]+aAsu[i,4]
             exit
          end
      next
      if !fileMN(put_asu98,10)
         boxik(11,18,15,60,' Нет файла BD02KI98.dbf на сервере ОАСУП ',B_DOUBLE,"W+/r")
         RETURN (.f.)
      end
*----------------------------------------------
  //  получить  путь к bd02nc на сервере ОАСУП
      for i:=1 to len(aAsu)
          if aAsu[i,1] == 'bd02nc'
             put_asu_nc:=aASU[i,2]+aASU[i,1]+".dbf"
             si_asu_nc:=aAsu[i,3]+aAsu[i,4]
             exit
          end
      next
      if !fileMN(put_asu_nc,10)
         boxik(11,18,15,60,' Нет файла BD02NC.dbf на сервере ОАСУП ',B_DOUBLE,"W+/r")
         RETURN (.f.)
      end
*------------------------------------------------
  //  получить  путь к bd02nc на сервере ПДО
      for i:=1 to len(aPdo)
          if aPdo[i,1] == 'bd02nc'
             put_pdo_nc:=aPDO[i,2]+aPDO[i,1]+".dbf"
             si_pdo_nc:=aPDO[i,3]+aPDO[i,4]
             exit
          end
      next
      if !fileMN(put_pdo_nc,10)
         boxik(11,18,15,60,' Нет файла BD02NC.dbf на сервере ПДО ',B_DOUBLE,"W+/r")
         RETURN (.f.)
      end
*------------------------------------------------
  //  получить  путь к bd02ki на сервере ПДО
      for i:=1 to len(aPdo)
          if aPdo[i,1] == 'bd02ki'
        //     tek_dir:=aPDO[i,2]
             put_pdo:=aPDO[i,2]+aPDO[i,1]+".dbf"
             put_pdo_c1:=aPDO[i,2]+"bd02nc1.dbf"/*Макарова*/
             si_pdo:=aPdo[i,3]+aPdo[i,4]
             exit
          end
      next
*------------------------------------------------
/*Макарова 26.02.13*/
  //  получить  путь к nstd на сервере ПДО
      for i:=1 to len(aPDO_dopol)
          if aPDO_dopol[i,1] == 'nstd'
             put_pdo_td:=&(aPDO_dopol[i,2])+".dbf"
             exit
          end
      next
*------------------------------------------------
  //  получить  путь к bd02ki04 на сервере ПДО /*Макарова*/
      for i:=1 to len(aPdo)
          if aPdo[i,1] == 'bd02ki04'
             put_pdo04:=aPDO[i,2]+aPDO[i,1]+".dbf"
             si_pdo04:=aPdo[i,3]+aPdo[i,4]
             exit
          end
      next
*------------------------------------------------
  //  получить  путь к bd02ki98 на сервере ПДО /*Макарова*/
      for i:=1 to len(aPdo)
          if aPdo[i,1] == 'bd02ki98'
             put_pdo98:=aPDO[i,2]+aPDO[i,1]+".dbf"
             si_pdo98:=aPdo[i,3]+aPdo[i,4]
             exit
          end
      next
*--------------------------------------------
      for i:=1 to len(aPdo_dopol)
          if aPdo_dopol[i,1] == 'bd02ki_'
             put_:=n_bd02ki_+".dbf"//aPDO_dopol[i,2]+aPDO_dopol[i,1]+".dbf"
             exit
          end
      next
*--------------------------------------------

   // получить день месяц и год bd02ki на сервере АСУ
      data_asu:=right(si_asu,8)
      day_asu:=substr(data_asu,1,2)
      mes_asu:=substr(data_asu,4,2)
      god_asu:=substr(data_asu,7,2)
*--------------------------------------------
   // получить день месяц и год bd02nc на сервере АСУ
      data_asu_nc:=right(si_asu_nc,8)
      day_asu_nc:=substr(data_asu_nc,1,2)
//      mes_asu_nc:=substr("02",1,2)
      mes_asu_nc:=substr(data_asu_nc,4,2)
      god_asu_nc:=substr(data_asu_nc,7,2)
*-----------------------------------------------------
   // получить день месяц и год bd02nc на сервере ПДО
      data_pdo_nc:=right(si_pdo_nc,8)
      day_pdo_nc:=substr(data_pdo_nc,1,2)
//      mes_pdo_nc:=substr("12",1,2)
      mes_pdo_nc:=substr(data_pdo_nc,4,2)
      god_pdo_nc:=substr(data_pdo_nc,7,2)
*-----------------------------------------------------
   // получить день месяц и год bd02ki на сервере ПДО
      data_pdo:=right(si_pdo,8)
      day_pdo:=substr(data_pdo,1,2)
//      mes_pdo:=substr("12",1,2)
//      god_pdo:=substr("04",1,2)
      mes_pdo:=substr(data_pdo,4,2)
      god_pdo:=substr(data_pdo,7,2)
*------------------------------------------------------------
 // нет файла bd02ki на сервере ПДО
      if empty(si_pdo)
         Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
         @ 12,19 say padc(' Копируется файл',40) color "w+/b"
         @ 13,19 say padc('BD02KI.dbf',40) color "gr+*/b"
         FileCopy(put_asu,put_pdo)
         nErr:=ErrorCode(.T.)
         If nErr!=0
            Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
            @ 12,19 say '  Ошибка копирования файла  '
            @ 13,19 Say '  '+Upper(put_asu+' - '+Str(nErr,2))
            inkey(0)
            Return (.f.)
         EndIf
         ******** Макарова ** Копирование bd02nc1.dbf *********
         Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
         @ 12,19 say padc(' Копируется файл',40) color "w+/b"
         @ 13,19 say padc('BD02NC1.dbf',40) color "gr+*/b"
         FileCopy(put_asu_c1,put_pdo_c1)
         nErr:=ErrorCode(.T.)
         If nErr!=0
            Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
            @ 12,19 say '  Ошибка копирования файла  '
            @ 13,19 Say '  '+Upper(put_asu_c1+' - '+Str(nErr,2))
            inkey(0)
         EndIf
         ******** Макарова ** Копирование nstd.dbf *********
         Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
         @ 12,19 say padc(' Копируется файл',40) color "w+/b"
         @ 13,19 say padc('NSTD.dbf',40) color "gr+*/b"
         FileCopy(put_asu_td,put_pdo_td)
         nErr:=ErrorCode(.T.)
         If nErr!=0
            Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
            @ 12,19 say '  Ошибка копирования файла  '
            @ 13,19 Say '  '+Upper(put_asu_td+' - '+Str(nErr,2))
            inkey(0)
         EndIf
         ******************************************************
         masha_flag=1
         //Rkol()
//         Restore Screen
  //       return (.f.)
     end
 // нет файла bd02ki04 на сервере ПДО
         ******** Макарова ** Копирование bd02ki04.dbf *********
      if empty(si_pdo04)
         @ 13,19 say padc('BD02KI04.dbf',40) color "gr+*/b"
         FileCopy(put_asu04,put_pdo04)
         nErr:=ErrorCode(.T.)
         If nErr!=0
            Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
            @ 12,19 say '  Ошибка копирования файла  '
            @ 13,19 Say '  '+Upper(put_asu04+' - '+Str(nErr,2))
            inkey(0)
            Return (.f.)
         EndIf
      end
 // нет файла bd02ki98 на сервере ПДО
         ******** Макарова ** Копирование bd02ki98.dbf *********
      if empty(si_pdo98)
         @ 13,19 say padc('BD02KI98.dbf',40) color "gr+*/b"
         FileCopy(put_asu98,put_pdo98)
         nErr:=ErrorCode(.T.)
         If nErr!=0
            Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
            @ 12,19 say '  Ошибка копирования файла  '
            @ 13,19 Say '  '+Upper(put_asu98+' - '+Str(nErr,2))
            inkey(0)
            Return (.f.)
         EndIf
      end
*-------------------------------------
 //создание копии bd02ki для архива снятых и удаленных позиций
/*         Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
         @ 12,19 say padc(' Создается копия файла',40) color "w+/b"
         @ 13,19 say padc('BD02KI.dbf',40) color "gr+*//*b"
         FileCopy(put_pdo,'temp_das.dbf')
         nErr:=ErrorCode(.T.)
         If nErr!=0
            Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
            @ 12,19 say '  Ошибка копирования файла  '
            @ 13,19 Say '  '+Upper(put_pdo+' - '+Str(nErr,2))
            inkey(0)
            Return (.f.)
         EndIf
         Close_Alert(11,18,15,60,Box)                    */
*-------------------------------------
     //If god_asu_nc # god_pdo_nc                    // пришел новый год !
//20.12.07 Макарова смена года не должна зависеть от накладных, только от архивации
     If flNewYear                    // пришел новый год !
        If !Setka(path_base+"BASESPDO.DBF",.f.,5)
            boxik(11,18,15,51,'Файл BASESPDO.dbf недоступен',;
            B_DOUBLE,"W+/R")
            Restore Screen
            Clear All
            Close All
            Quit
        Else
            set index to (path_base+"BASESPDO")
        EndIf
        last_god:=epoch+god_pdo_nc
        basespdo->(dbseek("arhiv"+last_god))
        if basespdo->(!found())
           boxik(11,15,15,54,'Ошибка при создании архива (путь не найден)!',;
           B_DOUBLE,"W+/R")
           Restore Screen
           Clear All
           Close All
           Quit
        end
        arx_put:=basespdo->path
        close basespdo
        *----------------------------------------------
//        Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
//        @ 12,19 say '    Создается архив за ' color "w+/b"
//        @ 12,42 say RusMonth(mes_pdo) color "gr+*/b"
//        @ row(),col() say ' месяц ' color "w+/b"
        //make_arxiv(mes_pdo_nc)
        if fileMN(put_,10)  //путь к bd02ki_.dbf
           //tek_dir:=DirName()
        /*   if DirChange("C:\KARTA"+chr(92)+last_god)  == -3
              Dirmake("C:\KARTA"+chr(92)+last_god)
           end*/
           //DirChange(tek_dir)
           Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
           @ 12,19 say '       Создается архив за ' color "w+/b"
           @ 12,42 say Last_god color "gr+*/b"
           @ row(),col() say ' год ' color "w+/b"

           FileCopy(put_,rtrim(arx_put)+"bd02ki_.dbf")
           nErr:=ErrorCode(.T.)
           If nErr!=0
              Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
              @ 12,19 say '  Ошибка копирования файла  ' color "w+/b"
              @ 13,19 Say'  '+Upper(put_+' - '+Str(nErr,2)) color "w+/b"
              inkey(0)
              Return (.f.)
           EndIf
//           erase(put_)
             *-----------------------------------
             If !Setka(put_,.T.,5)
              boxik(11,18,15,51,'Файл BD02KI_.dbf на сервере ПДО недоступен',;
                     B_DOUBLE,"W+/R")
              Restore Screen
              Clear All
              Close All
              Quit
             EndIf
             *-----------------------------------
             Zap
             Close bd02ki_
        end

        Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
        @ 12,19 say padc(' Копируется файл',40) color "w+/b"
        @ 13,19 say padc('BD02KI.dbf',40) color "gr+*/b"
        FileCopy(put_asu,put_pdo)
        nErr:=ErrorCode(.T.)
        If nErr!=0
           Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
           @ 12,19 say '  Ошибка копирования файла  '
           @ 13,19 Say'  '+Upper(put_asu+' - '+Str(nErr,2))
           inkey(0)
           Return (.f.)
        EndIf
        @ 13,19 say padc('BD02KI04.dbf',40) color "gr+*/b"
        FileCopy(put_asu04,put_pdo04)
        nErr:=ErrorCode(.T.)
        If nErr!=0
           Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
           @ 12,19 say '  Ошибка копирования файла  '
           @ 13,19 Say'  '+Upper(put_asu04+' - '+Str(nErr,2))
           inkey(0)
           Return (.f.)
        EndIf
        @ 13,19 say padc('BD02KI98.dbf',40) color "gr+*/b"
        FileCopy(put_asu98,put_pdo98)
        nErr:=ErrorCode(.T.)
        If nErr!=0
           Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
           @ 12,19 say '  Ошибка копирования файла  '
           @ 13,19 Say'  '+Upper(put_asu98+' - '+Str(nErr,2))
           inkey(0)
           Return (.f.)
        EndIf
//20.12.07 Макарова при смене года bd02nc1 должен оставаться пустым!Не копировать!
/*         ******** Макарова ** Копирование bd02nc1.dbf *********
         Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
         @ 12,19 say padc(' Копируется файл',40) color "w+/b"
         @ 13,19 say padc('BD02NC1.dbf',40) color "gr+/b"
         FileCopy(put_asu_c1,put_pdo_c1)
         nErr:=ErrorCode(.T.)
         If nErr!=0
            Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
            @ 12,19 say '  Ошибка копирования файла  '
            @ 13,19 Say '  '+Upper(put_asu_c1+' - '+Str(nErr,2))
            inkey(0)
         EndIf
         ******************************************************/
         ******** Макарова ** Копирование nstd.dbf *********
         Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
         @ 12,19 say padc(' Копируется файл',40) color "w+/b"
         @ 13,19 say padc('NSTD.dbf',40) color "gr+/b"
         FileCopy(put_asu_td,put_pdo_td)
         nErr:=ErrorCode(.T.)
         If nErr!=0
            Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
            @ 12,19 say '  Ошибка копирования файла  '
            @ 13,19 Say '  '+Upper(put_asu_td+' - '+Str(nErr,2))
            inkey(0)
         EndIf
         ******************************************************
         masha_flag=1
        //Rkol()
//Masha        Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
//Masha        @ 12,19 say '    Создается архив за ' color "w+/b"
//Masha        @ 12,42 say RusMonth(mes_asu) color "gr+*/b"
//Masha        @ row(),col() say ' месяц ' color "w+/b"
//Masha        make_arxiv(mes_asu)

     *-------------------------
     elseif mes_asu_nc  #  mes_pdo_nc       // наступил новый месяц

//           Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
//           @ 12,19 say '    Создается архив за ' color "w+/b"
//           @ 12,42 say RusMonth(mes_pdo) color "gr+*/b"
//           @ row(),col() say ' месяц ' color "w+/b"
           //make_arxiv(mes_pdo_nc)
           Close_Alert(11,18,15,60,Box)

           Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
           @ 12,19 say padc(' Копируется файл',40) color "w+/b"
           @ 13,19 say padc('BD02KI.dbf',40) color "gr+*/b"
           FileCopy(put_asu,put_pdo)
           nErr:=ErrorCode(.T.)
           If nErr!=0
              Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
              @ 12,19 say '  Ошибка копирования файла  '
              @ 13,19 Say'  '+Upper(put_asu+' - '+Str(nErr,2))
              inkey(0)
              Return (.f.)
           EndIf
         masha_flag=1
          ******** Макарова ** Копирование bd02nc1.dbf *********
          Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
          @ 12,19 say padc(' Копируется файл',40) color "w+/b"
          @ 13,19 say padc('BD02NC1.dbf',40) color "gr+*/b"
          FileCopy(put_asu_c1,put_pdo_c1)
          nErr:=ErrorCode(.T.)
          If nErr!=0
              Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
              @ 12,19 say '  Ошибка копирования файла  '
              @ 13,19 Say '  '+Upper(put_asu_c1+' - '+Str(nErr,2))
              inkey(0)
          EndIf
          ******** Макарова ** Копирование nstd.dbf *********
          Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
          @ 12,19 say padc(' Копируется файл',40) color "w+/b"
          @ 13,19 say padc('NSTD.dbf',40) color "gr+*/b"
          FileCopy(put_asu_td,put_pdo_td)
          nErr:=ErrorCode(.T.)
          If nErr!=0
              Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
              @ 12,19 say '  Ошибка копирования файла  '
              @ 13,19 Say '  '+Upper(put_asu_td+' - '+Str(nErr,2))
              inkey(0)
          EndIf
          ******************************************************
          @ 13,19 say padc('BD02KI04.dbf',40) color "gr+*/b"
          FileCopy(put_asu04,put_pdo04)
          nErr:=ErrorCode(.T.)
          If nErr!=0
            Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
            @ 12,19 say '  Ошибка копирования файла  '
            @ 13,19 Say'  '+Upper(put_asu04+' - '+Str(nErr,2))
            inkey(0)
            Return (.f.)
          EndIf
          ******************************************************
          @ 13,19 say padc('BD02KI98.dbf',40) color "gr+*/b"
          FileCopy(put_asu98,put_pdo98)
          nErr:=ErrorCode(.T.)
          If nErr!=0
            Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
            @ 12,19 say '  Ошибка копирования файла  '
            @ 13,19 Say'  '+Upper(put_asu98+' - '+Str(nErr,2))
            inkey(0)
            Return (.f.)
          EndIf
           Close_Alert(11,18,15,60,Box)
           //Rkol()

     *--------------------------
     elseif day_asu_nc # day_pdo_nc       //  изменился день
           Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
           @ 12,19 say padc(' Копируется файл',40) color "w+/b"
           @ 13,19 say padc('BD02KI.dbf',40) color "gr+*/b"
           FileCopy(put_asu,put_pdo)
           nErr:=ErrorCode(.T.)
           If nErr!=0
              Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
              @ 12,19 say '  Ошибка копирования файла  '
              @ 13,19 Say'  '+Upper(put_asu+' - '+Str(nErr,2))
              inkey(0)
              Return (.f.)
           EndIf
         masha_flag=1
          ******** Макарова ** Копирование bd02nc1.dbf *********
          Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
          @ 12,19 say padc(' Копируется файл',40) color "w+/b"
          @ 13,19 say padc('BD02NC1.dbf',40) color "gr+*/b"
          FileCopy(put_asu_c1,put_pdo_c1)
          nErr:=ErrorCode(.T.)
          If nErr!=0
              Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
              @ 12,19 say '  Ошибка копирования файла  '
              @ 13,19 Say '  '+Upper(put_asu_c1+' - '+Str(nErr,2))
              inkey(0)
          EndIf
          ******** Макарова ** Копирование nstd.dbf *********
          Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
          @ 12,19 say padc(' Копируется файл',40) color "w+/b"
          @ 13,19 say padc('NSTD.dbf',40) color "gr+*/b"
          FileCopy(put_asu_td,put_pdo_td)
          nErr:=ErrorCode(.T.)
          If nErr!=0
              Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
              @ 12,19 say '  Ошибка копирования файла  '
              @ 13,19 Say '  '+Upper(put_asu_td+' - '+Str(nErr,2))
              inkey(0)
          EndIf
          ******************************************************
          @ 13,19 say padc('BD02KI04.dbf',40) color "gr+*/b"
          FileCopy(put_asu04,put_pdo04)
          nErr:=ErrorCode(.T.)
          If nErr!=0
            Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
            @ 12,19 say '  Ошибка копирования файла  '
            @ 13,19 Say'  '+Upper(put_asu04+' - '+Str(nErr,2))
            inkey(0)
            Return (.f.)
          EndIf
          ******************************************************
          @ 13,19 say padc('BD02KI98.dbf',40) color "gr+*/b"
          FileCopy(put_asu98,put_pdo98)
          nErr:=ErrorCode(.T.)
          If nErr!=0
            Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
            @ 12,19 say '  Ошибка копирования файла  '
            @ 13,19 Say'  '+Upper(put_asu98+' - '+Str(nErr,2))
            inkey(0)
            Return (.f.)
          EndIf
          ******************************************************
           Close_Alert(11,18,15,60,Box)
           //Rkol()
    *------------------------------
     else//if substr(si_asu,1,3) # substr(si_pdo,1,3)
       //  изменился номер поколения
           Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
           @ 12,19 say padc(' Копируется файл',40) color "w+/b"
           @ 13,19 say padc('BD02KI.dbf',40) color "gr+*/b"
           FileCopy(put_asu,put_pdo)
           nErr:=ErrorCode(.T.)
           If nErr!=0
              Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
              @ 12,19 say '  Ошибка копирования файла  '
              @ 13,19 Say'  '+Upper(put_asu+' - '+Str(nErr,2))
              inkey(0)
              Return (.f.)
           EndIf
         masha_flag=1
          ******** Макарова ** Копирование bd02nc1.dbf *********
          Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
          @ 12,19 say padc(' Копируется файл',40) color "w+/b"
          @ 13,19 say padc('BD02NC1.dbf',40) color "gr+*/b"
          FileCopy(put_asu_c1,put_pdo_c1)
          nErr:=ErrorCode(.T.)
          If nErr!=0
              Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
              @ 12,19 say '  Ошибка копирования файла  '
              @ 13,19 Say '  '+Upper(put_asu_c1+' - '+Str(nErr,2))
              inkey(0)
          EndIf
          ******** Макарова ** Копирование nstd.dbf *********
          Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
          @ 12,19 say padc(' Копируется файл',40) color "w+/b"
          @ 13,19 say padc('NSTD.dbf',40) color "gr+*/b"
          FileCopy(put_asu_td,put_pdo_td)
          nErr:=ErrorCode(.T.)
          If nErr!=0
              Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
              @ 12,19 say '  Ошибка копирования файла  '
              @ 13,19 Say '  '+Upper(put_asu_td+' - '+Str(nErr,2))
              inkey(0)
          EndIf
          ******************************************************
          @ 13,19 say padc('BD02KI04.dbf',40) color "gr+*/b"
          FileCopy(put_asu04,put_pdo04)
          nErr:=ErrorCode(.T.)
          If nErr!=0
            Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
            @ 12,19 say '  Ошибка копирования файла  '
            @ 13,19 Say'  '+Upper(put_asu04+' - '+Str(nErr,2))
            inkey(0)
            Return (.f.)
          EndIf
          ******************************************************
          @ 13,19 say padc('BD02KI98.dbf',40) color "gr+*/b"
          FileCopy(put_asu98,put_pdo98)
          nErr:=ErrorCode(.T.)
          If nErr!=0
            Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
            @ 12,19 say '  Ошибка копирования файла  '
            @ 13,19 Say'  '+Upper(put_asu98+' - '+Str(nErr,2))
            inkey(0)
            Return (.f.)
          EndIf
          ******************************************************
           Close_Alert(11,18,15,60,Box)
           //Rkol()
     End
     *-------------------------------------------------
*-------------  архив по снятым и добавленным позициям  -----------
//close bd02ki
//Dobav_Poz()
//Restore Screen

//Masha
//If (masha_flag == 1)  //Если было копирование
 Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
 @ 12,19 say padc('  Идет обработка BD02KI  ',40) color "w+/b"

 For i:=1 To Len(aPDO)
    If aPDO[i,1]=="bd02ki"
       Exit
    EndIf
 Next
 //первые 2 байта системной информации в 0 (в скопированном bd02ki)
 si_new := GetSi(aPDO[i,2] + aPDO[i,1] + ".dbf")
 len_si := VAL(SubStr(si_new, 18, 3))
 IF (len_si != 0)
//    si_new = SubStr(si_new, 1, 20) + "00" + SubStr(si_new, 23, Len(si_new)-22)
    si_new = SubStr(si_new, 1, 38) + "00" + SubStr(si_new, 41, Len(si_new)-40)
 ENDIF

 USE ((aPDO[i,2]) + (aPDO[i,1]) + ".dbf") NEW
 do while .NOT.eof()
    FIELD->KORT = 0   //обнуляем корректировку (в скопированном bd02ki)
    @ 13,19 Say padc(bd02ki->(RecNo()),40) color "w+/b"
    SKIP
 enddo
 CLOSE (aPDO[i,1])

 PutSi((aPDO[i,2]) + (aPDO[i,1]) + ".dbf",si_new)
//EndIf
//Masha  Копируется вчерашний bd02ki (полученный при завершении работы и
//                                    прописанный в bases.dbf)
//                                    в архив на диске D (D:\ARH\)
          If !DirChangeMN(aPDO[i,2]+'ARH',10)
            //создаем директорию () для
            If DirMake(aPDO[i,2]+'ARH')!=0
              my_box(13,18,17,51,B_DOUBLE+chr(32),"W+/R")
              @ 14,19 Say'    Ошибка создания каталога   '
              @ 15,31 Say Upper(aPDO[i,2]+'ARH\')
              @ 16,19 Say'   Нажмите любую клавишу ...   '
              InKey(0)
              Restore Screen
              Clear Screen
              Close All
              Quit
            EndIf
          EndIf
           //put_arh := 'D:\ARH\bd02ki.dbf'
           put_arh := aPDO[i,2]+'ARH\bd02ki.dbf'
           Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
           @ 12,19 say padc(' Копируется файл во временный архив',40) color "w+/b"
           @ 13,19 say padc('BD02KI.dbf',40) color "gr+*/b"
           FileCopy(put_asu,put_arh)
           nErr:=ErrorCode(.T.)
           If nErr!=0
              Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
              @ 12,19 say '  Ошибка копирования файла  '
              @ 13,19 Say'  '+Upper(put_asu+' - '+Str(nErr,2))
              inkey(0)
              Return (.f.)
           EndIf
***********************************************************
 Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
 @ 12,19 say padc('  Идет обработка BD02KI04',40) color "w+/b"

 For i:=1 To Len(aPDO)
    If aPDO[i,1]=="bd02ki04"
       Exit
    EndIf
 Next
 //первые 2 байта системной информации в 0 (в скопированном bd02ki04)
 si_new := GetSi(aPDO[i,2] + aPDO[i,1] + ".dbf")
 len_si := VAL(SubStr(si_new, 18, 3))
 IF (len_si != 0)
    si_new = SubStr(si_new, 1, 38) + "00" + SubStr(si_new, 41, Len(si_new)-40)
 ENDIF

 USE ((aPDO[i,2]) + (aPDO[i,1]) + ".dbf") NEW
 do while .NOT.eof()
    FIELD->KORT = 0   //обнуляем корректировку (в скопированном bd02ki04)
    @ 13,19 Say padc(bd02ki04->(RecNo()),40) color "w+/b"
    SKIP
 enddo
 CLOSE (aPDO[i,1])

 PutSi((aPDO[i,2]) + (aPDO[i,1]) + ".dbf",si_new)
//  Копируется вчерашний bd02ki04 (полученный при завершении работы и
//                                    прописанный в bases.dbf)
//                                    в архив
           put_arh := aPDO[i,2]+'ARH\bd02ki04.dbf'
           Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
           @ 12,19 say padc(' Копируется файл во временный архив',40) color "w+/b"
           @ 13,19 say padc('BD02KI04.dbf',40) color "gr+*/b"
           FileCopy(put_asu04,put_arh)
           nErr:=ErrorCode(.T.)
           If nErr!=0
              Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
              @ 12,19 say '  Ошибка копирования файла  '
              @ 13,19 Say'  '+Upper(put_asu04+' - '+Str(nErr,2))
              inkey(0)
              Return (.f.)
           EndIf
***********************************************************
 Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
 @ 12,19 say padc('  Идет обработка BD02KI98',40) color "w+/b"

 For i:=1 To Len(aPDO)
    If aPDO[i,1]=="bd02ki98"
       Exit
    EndIf
 Next
 //первые 2 байта системной информации в 0 (в скопированном bd02ki98)
 si_new := GetSi(aPDO[i,2] + aPDO[i,1] + ".dbf")
 len_si := VAL(SubStr(si_new, 18, 3))
 IF (len_si != 0)
    si_new = SubStr(si_new, 1, 38) + "00" + SubStr(si_new, 41, Len(si_new)-40)
 ENDIF

 USE ((aPDO[i,2]) + (aPDO[i,1]) + ".dbf") NEW
 do while .NOT.eof()
    FIELD->KORT = 0   //обнуляем корректировку (в скопированном bd02ki98)
    @ 13,19 Say padc(bd02ki98->(RecNo()),40) color "w+/b"
    SKIP
 enddo
 CLOSE (aPDO[i,1])

 PutSi((aPDO[i,2]) + (aPDO[i,1]) + ".dbf",si_new)
//  Копируется вчерашний bd02ki98 (полученный при завершении работы и
//                                    прописанный в bases.dbf)
//                                    в архив
           put_arh := aPDO[i,2]+'ARH\bd02ki98.dbf'
           Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
           @ 12,19 say padc(' Копируется файл во временный архив',40) color "w+/b"
           @ 13,19 say padc('BD02KI98.dbf',40) color "gr+*/b"
           FileCopy(put_asu98,put_arh)
           nErr:=ErrorCode(.T.)
           If nErr!=0
              Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
              @ 12,19 say '  Ошибка копирования файла  '
              @ 13,19 Say'  '+Upper(put_asu98+' - '+Str(nErr,2))
              inkey(0)
              Return (.f.)
           EndIf

           Close_Alert(11,18,15,60,Box)

return (.t.)
****************************************************************
static func Dobav_Poz()
Local aDbf,put1,Box,kv1,kol

 kv1:=ceiling(val(mes_pdo)/3)
 kv1:=str(kv1,1)
 put1:=strtran(put_pdo,"bd02ki","das_poz")
 if !fileMN(put1,10)
      aDbf:={{"CEX","C",2,0},;
           {"CHERT","C",13,0},{"PS","C",1,0},;
           {"VP","C",1,0},{"CP","C",2,0},{"KI","C",4,0},;
           {"KVART","C",1,0},{"NTEK","N",8,0},{"KTEK","N",8,0},;
           {"NIZ","N",8,0},{"BU","C",2,0}}
           DbCreate(put1,aDbf)
 end
 *----------------------------------------------------
 If !Setka(put_Pdo,.T.,5)
    boxik(11,18,15,51,'Файл BD02KI.dbf на сервере ПДО недоступен',;
          B_DOUBLE,"W+/R")
    Restore Screen
    Clear All
    Close All
    Quit
 EndIf

*-----------------------------------
 If !Setka(put1,.T.,5)
    boxik(11,18,15,51,'Файл DAS_POZ.dbf на сервере ПДО недоступен',;
          B_DOUBLE,"W+/R")
    Restore Screen
    Clear All
    Close All
    Quit
 EndIf
*-----------------------------------
 If !Setka('temp_das',.T.,5)
    boxik(11,18,15,51,'Файл TEMP_DAS.dbf на сервере ПДО недоступен',;
          B_DOUBLE,"W+/R")
    Restore Screen
    Clear All
    Close All
    Quit
 EndIf
*-----------------------------------
 put1:=strtran(put_pdo,"bd02ki","niz")
 If !Setka(put1,.T.,5)
    boxik(11,18,15,51,'Файл NIZ.dbf на сервере ПДО недоступен',;
          B_DOUBLE,"W+/R")
    Restore Screen
    Clear All
    Close All
    Quit
 EndIf
*------------------------------------
  select das_poz
  Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
  @ 12,19 say padc(' Создается индексный файл',40) color "w+/b"
  @ 13,19 say padc('DAS_POZ.ntx',40) color "gr+*/b"

  index on das_poz->cex+das_poz->chert+das_poz->ps+das_poz->vp+das_poz->cp+;
           das_poz->ki+das_poz->kvart to das_poz
  *------------------------
  select temp_das
  index on temp_das->cex+temp_das->chert+temp_das->ps+temp_das->vp+temp_das->cp+;
           temp_das->ki to temp_das
  *------------------------

  select bd02ki
  index on bd02ki->cex+bd02ki->chert+bd02ki->ps+bd02ki->vp+bd02ki->cp+;
           bd02ki->ki to bd02ki1
  Close_Alert(11,18,15,60,Box)
*----------------------------------
 // добавленные позиции
 kol:=0
 Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
 @ 12,19 say padc(' Создается архив по новым позициям',40) color "w+/b"
 bd02ki->(dbgotop())
 do while bd02ki->(!eof())
//       locate for niz->ki == bd02ki->ki

  if (bd02ki->ki < '0120') .or. (bd02ki->ki='0228')
    //if bd02ki->BU = '04'   //позиция новая
    temp_das->(dbseek(bd02ki->cex+bd02ki->chert+bd02ki->ps+bd02ki->vp+;
                 bd02ki->cp+bd02ki->ki))
    if temp_das->(!found())  //позиция новая пометка bu='04'
       kol:=kol+1
       @ 13,19 say padc(rtrim(str(kol)),40) color "w+/b"
       das_poz->(dbseek(bd02ki->cex+bd02ki->chert+bd02ki->ps+bd02ki->vp+;
                 bd02ki->cp+bd02ki->ki+kv1))
       if das_poz->(!found())
          das_poz->(dbappend())
          das_poz->cex  :=bd02ki->cex
          das_poz->chert:=bd02ki->chert
          das_poz->ps   :=bd02ki->ps
          das_poz->vp   :=bd02ki->vp
          das_poz->cp   :=bd02ki->cp
          das_poz->ki   :=bd02ki->ki
          das_poz->kvart:=kv1
       end
       das_poz->ntek:=bd02ki->ntek
       das_poz->ktek:=bd02ki->ktek
       das_poz->bu  :='04'//bd02ki->bu
       select niz
       locate for niz->ki == bd02ki->ki
       if niz->(found())
          das_poz->niz  :=niz->ntek
       end
       select bd02ki
    end
    //end
  end
    bd02ki->(dbskip())
 enddo
 Close_Alert(11,18,15,60,Box)
 *----------------------------
 // удаленные позиции  temp_das -копия старой bd02ki.dbf
 kol:=0
 Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
 @ 12,19 say padc(' Создается архив по удаленным позициям',40) color "w+/b"
 temp_das->(dbgotop())
 do while temp_das->(!eof())
  if (temp_das->ki < '0120') .or. (temp_das->ki='0228')

    bd02ki->(dbseek(temp_das->cex+temp_das->chert+temp_das->ps+temp_das->vp+;
                 temp_das->cp+temp_das->ki))
    if bd02ki->(!found())  //позиция удалилась  пометка bu='09'
       kol:=kol+1
       @ 13,19 say padc(rtrim(str(kol)),40) color "w+/b"
       das_poz->(dbseek(temp_das->cex+temp_das->chert+temp_das->ps+temp_das->vp+;
                 temp_das->cp+temp_das->ki+kv1))
       if das_poz->(!found())
          das_poz->(dbappend())
          das_poz->cex  :=temp_das->cex
          das_poz->chert:=temp_das->chert
          das_poz->ps   :=temp_das->ps
          das_poz->vp   :=temp_das->vp
          das_poz->cp   :=temp_das->cp
          das_poz->ki   :=temp_das->ki
          das_poz->kvart:=kv1
       end
       das_poz->ntek:=temp_das->ntek
       das_poz->ktek:=temp_das->ktek
       das_poz->bu  :='09'
       select niz
       locate for niz->ki == temp_das->ki
       if niz->(found())
          das_poz->niz  :=niz->ntek
       end
       select bd02ki

    end
  end
  temp_das->(dbskip())
 enddo
 Close_Alert(11,18,15,60,Box)
 *----------------------------
 close bd02ki
 close das_poz
 close temp_das
 ferase('temp_das.dbf')
 ferase('temp_das.ntx')
 ferase('bd02ki1.ntx')
return nil
***********************
static func Make_Arxiv(mes)
Local adbf
 if !fileMN(put_,10)
      aDbf:={{"MONTH","C",2,0},{"CEX","C",2,0},;
           {"CHERT","C",13,0},{"PS","C",1,0},;
           {"VP","C",1,0},{"CP","C",2,0},{"KI","C",4,0},{"PG","C",1,0},;
           {"K1","N",8,0},{"N2","N",8,0},{"K2","N",8,0},{"KORM","N",8,0},;
           {"NNMES","N",8,0},{"KNMES","N",8,0},;
           {"NTEK","N",8,0},{"KTEK","N",8,0},;
           {"SIA","C",0,0}}
           DbCreate(put_,aDbf)
 end
 *----------------------------------------------------
 If !Setka(put_Pdo,.T.,5)
    boxik(11,18,15,51,'Файл BD02KI.dbf на сервере ПДО недоступен',;
          B_DOUBLE,"W+/R")
    Restore Screen
    Clear All
    Close All
    Quit
 EndIf
*-----------------------------------
 If !Setka(put_,.T.,5)
    boxik(11,18,15,51,'Файл BD02KI_.dbf на сервере ПДО недоступен',;
          B_DOUBLE,"W+/R")
    Restore Screen
    Clear All
    Close All
    Quit
 EndIf
*-----------------------------------
bd02ki_->(dbGoBottom())
if bd02ki_->month # mes
Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
@ 12,19 say '    Создается архив за ' color "w+/b"
@ 12,42 say RusMonth(mes) color "gr+*/b"
@ row(),col() say ' месяц ' color "w+/b"
do while bd02ki->(!eof())
    bd02ki_->(dbappend())
    bd02ki_->month :=mes
    bd02ki_->CEX   :=bd02ki->CEX
    bd02ki_->CHERT :=bd02ki->CHERT
    bd02ki_->PS    :=bd02ki->PS
    bd02ki_->VP    :=bd02ki->VP
    bd02ki_->CP    :=bd02ki->CP
    bd02ki_->KI    :=bd02ki->KI
    bd02ki_->PG    :=bd02ki->PG  //
    bd02ki_->K1    :=bd02ki->K1
    bd02ki_->K2    :=bd02ki->K2
    bd02ki_->N2    :=bd02ki->N2
    bd02ki_->KORM  :=bd02ki->KORM
    bd02ki_->NNMES :=bd02ki->NNMES
    bd02ki_->KNMES :=bd02ki->KNMES
    bd02ki_->NTEK  :=bd02ki->NTEK
    bd02ki_->KTEK  :=bd02ki->KTEK

    bd02ki->(dbskip())
enddo
endif
 close bd02ki_
 close bd02ki
return nil
*----------------------------------------------------------
static Func CopySbt()
Local n_baza

/*If File("C:\basespdo.dbf")
    Use C:\basespdo Index c:\basespdo New ReadOnly
else
         Boxik(12,18,15,50,'Нет файла BASESPDO.dbf',B_DOUBLE,"w+/r")
         Restore Screen
         Clear All
         Close All
         Quit
end*/
*---------------------------------------------------
basespdo->(dbSeek("pl03izs.dbf"))
 If basespdo->(Found())
      n_baza=AllTrim(basespdo->path)+"pl03izs"
      If !FileMN(n_baza+".dbf",10)
         Boxik(12,18,15,50,'Нет файла PL03IZS.dbf',B_DOUBLE,"w+/r")
         Restore Screen
         Clear All
         Close All
         Return (.F.)
      EndIf
 Else
         Boxik(12,18,15,50,'Нет PL03IZS в BASESPDO.dbf',B_DOUBLE,"w+/r")
         Restore Screen
         Clear All
         Close All
         Quit
 End
*---------------------------------------------------
basespdo->(dbSeek("blanks.dbf"))
 If basespdo->(Found())
      n_baza1=AllTrim(basespdo->path)+"blanks"
      If !FileMN(n_baza+".dbf",10)
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
      If !FileMN(n_baza+".dbf",10)
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
 If !Setka(N_baza,.t.,5)
    boxik(11,18,15,51,'Файл BD02KI.dbf на сервере ПДО недоступен',;
          B_DOUBLE,"W+/R")
    Restore Screen
    Clear All
    Close All
    Quit
 EndIf
*-----------------------------------
 If !Setka(N_baza1,.t.,5)
    boxik(11,18,15,51,'Файл BLANKS.dbf на сервере ПДО недоступен',;
          B_DOUBLE,"W+/R")
    Restore Screen
    Clear All
    Close All
    Quit
 EndIf
*-----------------------------------
 If !Setka(N_baza2,.t.,5)
    boxik(11,18,15,51,'Файл BLANKSIZ.dbf на сервере ПДО недоступен',;
          B_DOUBLE,"W+/R")
    Restore Screen
    Clear All
    Close All
    Quit
 EndIf
*-----------------------------------
 Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
 @ 12,19 say padc(' Проставляется К1 для распоряжений',40) color "w+*/b"


Return nil
*----------------------------------------------------------
***********    Подстановка К1 для распоряжений из
***********    бд Blanks.dbf и Blanksiz.dbf
***********
Func Rkol()
Local N_baza,N_baza1,N_baza2,i,kol1,Box

If FileMN(path_base+"basespdo.dbf",10)
    Use (path_base+"basespdo") Index (path_base+"basespdo") SHARED New ReadOnly
else
         Boxik(12,18,15,50,'Нет файла BASESPDO.dbf',B_DOUBLE,"w+/r")
         Restore Screen
         Clear All
         Close All
         Quit
end
*---------------------------------------------------
basespdo->(dbSeek("bd02ki.dbf"))
 If basespdo->(Found())
      n_baza=AllTrim(basespdo->path)+"bd02ki"
//      n_baza="D:\2\bd02ki"
      If !FileMN(n_baza+".dbf",10)
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
      If !FileMN(n_baza+".dbf",10)
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
      If !FileMN(n_baza+".dbf",10)
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
 If !Setka(N_baza,.t.,5)
    boxik(11,18,15,51,'Файл BD02KI.dbf на сервере ПДО недоступен',;
          B_DOUBLE,"W+/R")
    Restore Screen
    Clear All
    Close All
    Quit
 EndIf
*-----------------------------------
 If !Setka(N_baza1,.t.,5)
    boxik(11,18,15,51,'Файл BLANKS.dbf на сервере ПДО недоступен',;
          B_DOUBLE,"W+/R")
    Restore Screen
    Clear All
    Close All
    Quit
 EndIf
*-----------------------------------
 If !Setka(N_baza2,.t.,5)
    boxik(11,18,15,51,'Файл BLANKSIZ.dbf на сервере ПДО недоступен',;
          B_DOUBLE,"W+/R")
    Restore Screen
    Clear All
    Close All
    Quit
 EndIf
*-----------------------------------
 Box:=Get_Alert(11,18,15,60,' ',B_DOUBLE,"W+/b")
 @ 12,19 say padc(' Проставляется К1 для распоряжений',40) color "w+*/b"

select bd02ki
do while bd02ki->(!eof())
  //if (bd02ki->Ki > '1000').and. (bd02ki->Ki < '9990')
//  if (bd02ki->Ki $ '0061_0201_0256_0257_0258_0260') .or. ((bd02ki->Ki > '1000').and. (bd02ki->Ki < '9990'))//Макарова добавила 201 код 20/09/05,61 код 05.07.06
  if (bd02ki->Ki $ '0061_0259') .or. ((bd02ki->Ki > '1000').and. (bd02ki->Ki < '9990'))  //1.11.06 Дьяченко
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
//Close_Alert(11,18,15,60,Box)
CLOSE bd02ki
CLOSE blanks
CLOSE blanksiz
return nil
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
/*Func Poisk4(ar)
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
enddo*/
/*if blanksiz->Num # (blanks->Num)
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
return (.f.)*/
*-----------------------------------
//Close All
