%let pgm=utl-extracting-sas-meta-data-using-sas-macro-fcmp-and-dosubl;

Create SAS FCMP, DOSUBL and MACRO functions to extract all titles from sas meta data

github
https://tinyurl.com/3ezrkyt4
https://github.com/rogerjdeangelis/utl-extracting-sas-meta-data-using-sas-macro-fcmp-and-dosubl

Some interesting properties of FCMP and DOSUBL

          1. SAS macro
             Quentin McMullen
             qmcmullen.sas@gmail.com
          2. Fcmp without dosubl
          3. Fcmp with dosubl

The fcmp dosubl solution was  an academic exercise, not even a general solution.
I would not put this into production. I was just curious.

/*                   _                         _ _ _   _
(_)_ __  _ __  _   _| |_    ___ ___  _ __   __| (_) |_(_) ___  _ __  ___
| | `_ \| `_ \| | | | __|  / __/ _ \| `_ \ / _` | | __| |/ _ \| `_ \/ __|
| | | | | |_) | |_| | |_  | (_| (_) | | | | (_| | | |_| | (_) | | | \__ \
|_|_| |_| .__/ \__,_|\__|  \___\___/|_| |_|\__,_|_|\__|_|\___/|_| |_|___/
        |_|
*/

/*---- PROBABLY NOT NEEDED                                     ----*/

title1 "Hello Q";
title2 "How is James Bond today";
title3 "How are You";


/*---- DOSUBL TENDS TO MAKE THESE ????                         ----*/
/*---- I LIKE DO THIS BEFORE AND AFTER DOSUBL                  ----*/
/*---- ONLY USED WITH FCMP WITH DOSUBL                         ----*/

PROC DATASETS LIB=WORK MT=CAT nodetails nolist;
 delete sasmac1 sasmac2 sasmac3 ;
run;quit;

/*---- ONLY USED WITH FCMP DOSUBL                              ----*/
%symdel ttl /nowarn;
%put &=ttl;

/*---- GOOD  Apparent symbolic reference TTL not resolved.     ----*/
/*---- WARNING: Apparent symbolic reference TTL not resolved.  ----*/

/*---  MAKE DOSUBL USE THE SETTINGS IN THE MAINLINE            ----*/
/*---  ONLY USE WITH DCMP DOSUBL SOLUTION                      ----*/
proc optsave out=work.opts;
run;quit;

/*---- USE BEFORE AND AFTER MARO and FCMP WITHOUT DOSUBL?       ----*/
/*---- FOPEN can habit and fail to close. This closes _all_     ----*/
%utl_close;

/*           _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| `_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
*/

/**************************************************************************************************************************/
/*                                                                                                                        */
/* THIS IS NOT WHAT WE WANT SEE                                                                                           */
/*                                                                                                                        */
/* 1. QUENTINS MARO                                                                                                       */
/*                                                                                                                        */
/*    Titles from Quentins macro   Hello Q|How is James Bond today|How are You                                            */
/*                                                                                                                        */
/* 2. FCMP WITHOUT DOSUBL                                                                                                 */
/*                                                                                                                        */
/*    FCMP WITHOUT DOSUBL         : mytitle(title) create variable  title=Hello Q|How is James Bond today|How are You     */
/*    SYSFUNC FCMP WITHOUT DOSUB  : %sysfunc(mytitle(title)) is     titl= Hello Q|How is James Bond today|How are You     */
/*                                                                                                                        */
/* 3. FCMP WITH DOSUBL                                                                                                    */
/*                                                                                                                        */
/*    FCMP WITHOUT DOSUBL         : mytitle(title) create variable  title=Hello Q|How is James Bond today|How are You     */
/*    SYSFUNC FCMP WITHOUT DOSUB  : %sysfunc(mytitle(title)) is     titl= Hello Q|How is James Bond today|How are You     */
/*                                                                                                                        */
/**************************************************************************************************************************/

/*
/ |    ___  __ _ ___   _ __ ___   __ _  ___ _ __ ___
| |   / __|/ _` / __| | `_ ` _ \ / _` |/ __| `__/ _ \
| |_  \__ \ (_| \__ \ | | | | | | (_| | (__| | | (_) |
|_(_) |___/\__,_|___/ |_| |_| |_|\__,_|\___|_|  \___/

*/

%macro utl_gettitle
   (Number=_ALL_  /*Number 1-10, _ALL_, or space delimited list of numbers*/
   ,type=T        /*T for titles, F for footnote*/
   ,dlm=|         /*delimiter for list of titles*/
   );

   %local where dsid rc ldlm titletext ;

   %let where=Type="&Type" ;
   %if %upcase(&Number) ne _ALL_ %then %do ;
      %let where=&where and Number IN (&Number)  ;
   %end ;

   %let dsid = %sysfunc ( open ( sashelp.vtitle(where=(&where)) ) ) ;

   %if &dsid > 0 %then %do ;
      %do %until ( &rc ^= 0 ) ;
         %let rc = %sysfunc ( fetch ( &dsid ) ) ;
         %if &rc=0 %then %do ;
            %let TitleText =&TitleText&ldlm%sysfunc ( getvarc ( &dsid , 3 ) ) ;
            %let ldlm=&dlm ;
         %end ;
      %end ;
      %let dsid = %sysfunc(close ( &dsid ) ) ;
   %end ;
   %else %put ER%str()ROR: (%nrstr(%%)&sysmacroname) could not open sashelp.vtitle ;

&TitleText /*return*/
%mend utl_gettitle ;

%put "Titles from Quentins macro" %utl_gettitle ;

/*___       __                                  __          _                 _     _
|___ \     / _| ___ _ __ ___  _ __   __      __/ /__     __| | ___  ___ _   _| |__ | |
  __) |   | |_ / __| `_ ` _ \| `_ \  \ \ /\ / / / _ \   / _` |/ _ \/ __| | | | `_ \| |
 / __/ _  |  _| (__| | | | | | |_) |  \ V  V / / (_) | | (_| | (_) \__ \ |_| | |_) | |
|_____(_) |_|  \___|_| |_| |_| .__/    \_/\_/_/ \___/   \__,_|\___/|___/\__,_|_.__/|_|
*/

title1 "Hello Q";
title2 "How is James Bond today";
title3 "How are You";

options cmplib=work.functions;
proc fcmp outlib=work.functions.mytitle;
function mytitle(ttl$) $2550;
    outargs ttl;
    length ttl trct $2550; /*---- SAS MAX SIZE FOR 10 TITLES        ----*/

    dsid = open ( "sashelp.vtitle" );

   if  dsid > 0 then do ;
      do until ( rc ^= 0 ) ;
         rc = fetch ( dsid )  ;
         if rc=0 then do ;
            ttl = catx('|',ttl, getvarc ( dsid , 3 ));
         end ;
      end ;
      dsid =close ( dsid ) ;
   end ;
   else put "Rstr()ROR: (nrstr()&sysmacroname) could not open sashelp.vtitle" ;

   put ttl=;
return(ttl);

endfunc;
run;quit;

data _null_;
  length title $2550;
  title=mytitle(title);
  put 'FCMP without DOSUBL mytitle(title))' title;
run;quit;

%put 'FCMP without DOSUBL %sysfunc(mytitle(title))' %sysfunc(mytitle(title)) ;

/*____     __                                 _ _   _          _                 _     _
|___ /    / _| ___ _ __ ___  _ __   __      _(_) |_| |__    __| | ___  ___ _   _| |__ | |
  |_ \   | |_ / __| `_ ` _ \| `_ \  \ \ /\ / / | __| `_ \  / _` |/ _ \/ __| | | | `_ \| |
 ___) |  |  _| (__| | | | | | |_) |  \ V  V /| | |_| | | || (_| | (_) \__ \ |_| | |_) | |
|____(_) |_|  \___|_| |_| |_| .__/    \_/\_/ |_|\__|_| |_| \__,_|\___/|___/\__,_|_.__/|_|
*/

/*---- JUST IN CASE                                            ----*/
filename clp clear;

/*---- PROBABLY NOT NEEDED                                     ----*/

title1 "Hello Q";
title2 "How is James Bond today";
title3 "How are You";


/*---- DOSUBL TENDS TO MAKE THESE ????                         ----*/
/*---- I LIKE DO THIS BEFORE AND AFTER DOSUBL                  ----*/
/*---- ONLY USED WITH FCMP WITH DOSUBL                         ----*/

PROC DATASETS LIB=WORK MT=CAT nodetails nolist;
 delete sasmac1 sasmac2 sasmac3 ;
run;quit;

/*---- ONLY USED WITH FCMP DOSUBL                              ----*/
%symdel ttl /nowarn;
%put &=ttl;

/*---- GOOD  Apparent symbolic reference TTL not resolved.     ----*/
/*---- WARNING: Apparent symbolic reference TTL not resolved.  ----*/

/*---  MAKE DOSUBL USE THE SETTINGS IN THE MAINLINE            ----*/
/*---  ONLY USE WITH DCMP DOSUBL SOLUTION                      ----*/
proc optsave out=work.opts;
run;quit;

/*---- USE BEFORE AND AFTER MARO and FCMP WITHOUT DOSUBL?       ----*/
/*---- FOPEN can habit and fail to close. This closes _all_     ----*/
%utl_close;

/*---  DOSUBL CANNOT ACCESS SASHELP.VTITLE SO USE WORK         ----*/
data title;
  set sashelp.vtitle;
run;quit;

options cmplib=work.functions;
proc fcmp outlib=work.functions.mytitle;
function mytitle(ttl$) $2550;
    outargs ttl;

    filename clp clipbrd; /*---- SURPRISED                     ----*/

    length ttl $2550; /*---- SAS MAX SIZE FOR 10 TITLES        ----*/

    /*---- RESET TO DEFAULT CLIPBRD TEXT                       ----*/
    %DOSUBL('
       data _null_;
          file clp;
          put "default";
       run;quit;
    ');

    %dosubl('
     data _null_;
     length ttl $2550;
     file clp;
     do until (dne);
        set work.title end=dne;
        ttl=catx('|',ttl,text);
     end;
     put ttl;
     stop;
     run;quit;
   ');

   %dosubl('
     data _null_ ;
       length ttl $2550;
       infile clp;
       input;
       put _infile_;
       call symputx("ttl",_infile_);
     run;quit;
   ');

    ttl = "&ttl";

return(ttl);

endfunc;
run;quit;

data _null_;
  length title $2550;
  title=mytitle(title);
  put title=;
run;quit;

%put 'Macro System Function   : %sysfunc(mytitle(title)) is' %sysfunc(mytitle(title));

/*              _
  ___ _ __   __| |
 / _ \ `_ \ / _` |
|  __/ | | | (_| |
 \___|_| |_|\__,_|

*/
