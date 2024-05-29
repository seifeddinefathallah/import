/*****************************************************************************/
/* nomprog       : zzstkimp.p                                                */
/* Module        :                                                           */
/* But           : Import Stock                                              */
/* Prog. origine :                                                           */
/* Appele par    :                                                           */
/* run           :                                                           */
/*                                                                           */
/* Include       :                                                           */
/*                                                                           */
/*****************************************************************************/
/* (c) copyright CSI, unpublished work                                       */
/* this computer program includes confidential, proprietary information      */
/* and is a trade secret of CSI                                              */
/* all use, disclosure, and/or reproduction is prohibited unless authorized  */
/* in writing. all rights reserved.                                          */
/*****************************************************************************/
/*---------------------------------------------------------------------------*/
/* Num modif     !Auteur! Date     ! Commentaires                            */
/*---------------!------!----------!-----------------------------------------*/
/*               !  ABD ! 27/02/23 !Creation                                 */
/* SFM_2023_001  !  ABD ! 23/06/23 !No archive, add group and location ,     */
/*               !      !          !add creation / modification              */
/*===========================================================================*/

{us/mf/mfdtitle.i} 

/*define variable site                   like si_site                     no-undo.    SFM_2023_001 cmmt*/
define variable input_dir              as character format "x(50)"                 
                                       label "Input Directory"          no-undo.
define variable ext_file               as character format "x(50)"                
                                       label "File Name" initial "*.*"  no-undo.
define variable err_dir                as character format "x(50)" 
                                       label "Error Directory"          no-undo.
/*define variable arch_dir               as character format "x(50)" 
                                       label "Arch Directory"           no-undo.  SFM_2023_001 cmmt*/
define variable v_msg                  as character                     no-undo.
define variable logfile                as character format "x(50)"      no-undo.
define variable wk_command             as character format "x(50)"      no-undo.
define variable ii                     as integer                       no-undo.
define variable wk_file                as character format "x(25)"      
                                       extent 10000                     no-undo.
define variable vLigne                 as character                     no-undo.
define variable vimphear               as logical                       no-undo.
define variable ind                    as integer                       no-undo.
define variable v_file                 as character                     no-undo.
define variable v_error                as character                     no-undo.
define variable wk_filename            as character format "x(50)"      no-undo.
define variable kk                     as integer                       no-undo.        
define variable v_fic_inp              as character                     no-undo. 
define variable v_fic_out              as character                     no-undo.
define variable v-batchrun             as logical                       no-undo.
define variable ligne                  as character                     no-undo.  
define variable filename               as character                     no-undo.
define variable result                 as character                     no-undo.
/*SFM_2023_001 begin add code*/
define buffer bcode_mstr               for code_mstr  . 
define buffer bpt_mstr                 for pt_mstr    .
/*SFM_2023_001 end add code*/

define stream zzlog.
define stream file_csv.

define temp-table tt_file              
   field tt_filename as character format "x(60)"  
   field tt_number   as integer
.

define temp-table tt_result     
   field tt_File        as character format "x(60)"
   field tt_treat       like mfc_logical
   field tt_rmk         as character format "x(80)"
.           

define temp-table tt_item no-undo    
   field tt_ItemCode          like pt_part
   field tt_UM                like pt_um
   field tt_desc1             like pt_desc1
   field tt_desc2             like pt_desc2
   field tt_prod_line         like pt_prod_line
   field tt_promo_gp          like pt_promo
   field tt_part_type         like pt_part_type
   field tt_Group             like pt_group
   field tt_draw              like pt_draw
   field tt_rev               like pt_rev
   field tt_ship_wt_um        like pt_ship_wt_um
   field tt_net_wt            like pt_net_wt
   field tt_net_wt_um         like pt_net_wt_um
   field tt_Inv_Site          like si_site
   field tt_cost_set          as character format "x(18)" label "Cost Set"
   field tt_element           as character format "x(8)"  label "Cost "
   field tt_level             as decimal format ">>>>,>>>,>>9.99<<<"
   field tt_Site              like si_site
   field tt_lot_ser           like pti_lot_ser
   field tt_Loc               like pti_loc
   field tt_memo_type         like pti_memo_type
   field tt_mstr_sched        like ptp_ms
   field tt_plan_ord          like ptp_plan_ord
   field tt_ord_pol           like ptp_ord_pol
   field tt_ord_qty           like ptp_ord_qty
   field tt_sfty_stk          like ptp_sfty_stk
   field tt_sfty_tme          like ptp_sfty_tme
   field tt_rop               like ptp_rop
   field tt_iss_pol           like ptp_iss_pol
   field tt_buyer             like ptp_buyer
   field tt_pm_code           like ptp_pm_code
   field tt_ins_lead          like ptp_ins_lead
   field tt_cum_lead          like ptp_cum_lead
   field tt_mfg_lead          like ptp_mfg_lead
   field tt_pur_lead          like ptp_pur_lead
   field tt_ord_min           like ptp_ord_min
   field tt_ord_max           like ptp_ord_max
   field tt_ord_mult          like ptp_ord_mult
   field tt_routing           like ptp_routing
   field tt_supplier          like vp_vend
   field tt_supplier_item     like vp_vend_part 
   field tt_vd_lead_time      like vp_vend_lead
   field tt_curr              like vp_curr
   field tt_q_price           like vp_q_price
   field tt_price_list        like vp_pr_list
   field tt_manufacturer_item as character format "x(60)" label "Manufacturer Item"
   field tt_comment           like vp_comment
   field tt_creation          as logical  label "Creation"        /*SFM_2023_001*/
   field tt_modification      as logical  label "Modification"    /*SFM_2023_001*/
   field tt_nbr_modif         as decimal  label "Nbr Modif"       /*SFM_2023_001*/
   /**********************************************/
   field tt_FileItem          as character format "x(60)"   label "File"    
   field tt_msg_err           as character format "x(80)"   label "Error Msg"
   field tt_msg_err_fr        as character format "x(80)"
   field tt_msg_err_us        as character format "x(80)"
   field tt_cim_ok            as character format "x(8)"    label "CIM Y/N"
   /*********************************************/
.

form
   /*site        colon 25                                                  SFM_2023_001 cmmt*/
   input_dir   colon 25 format "x(250)" view-as fill-in size 50 by 1 
   ext_file    colon 25 format "x(250)" view-as fill-in size 50 by 1 
   /*arch_dir    colon 25 format "x(250)" view-as fill-in size 50 by 1     SFM_2023_001 cmmt*/
   err_dir     colon 25 format "x(250)" view-as fill-in size 50 by 1 
with frame a side-labels width 80.
setframelabels(frame a:handle).

form
with frame b width 400 no-attr-space down.
/* SET EXTERNAL labelS */
setframelabels(frame b:handle).

form
with frame c down width 400.
/* SET EXTERNAL labelS */
setframelabels(frame c:handle).

function replace_num_separator returns char (input ip_value as char):
   define variable op_value as character.
   if index(ip_value, ".") > 0 and session:numeric-format = "EUROPEAN" then
      assign op_value = replace(ip_value, ".", ",").
   else if index(ip_value, ",") > 0 and session:numeric-format = "AMERICAN" then
      assign op_value = replace(ip_value, ",", ".").
   else assign op_value = ip_value.
   return op_value .
end.

mainloop:
repeat:

   result = getTermLabel("no",5).
   /*SFM_2023_001 begin cmmt *
   update 
      site 
   with frame a.
   
   find first si_mstr where si_domain = global_domain 
                       and si_site = site
                      no-lock no-error.
      if not available si_mstr then do:
         {us/bbi/pxmsg.i &MSGNUM=708 &ERRORLEVEL=3}
         next-prompt site with frame a.
         undo,retry.
      end. /* if not available si_mstr then do: */

   /* VERif SECURITE SITE */
   {us/bbi/gprun.i ""gpsiver.p""
                   "(input site, 
                   input recid(si_mstr), 
                   output return_int)"}
   if return_int = 0 then do:
      {us/bbi/pxmsg.i &MSGNUM=725 &ERRORLEVEL=3}
      /* USER DOES noT HAVE ACCESS TO SITE */
      next-prompt site with frame a.
      undo,retry.
   end. /* if return_int = 0 then do: */
   
   find first code_mstr where code_domain  = global_domain
                          and code_fldname = "SP_SITE_CARL_QAD"
                          and code_value   = site
                        no-lock no-error.
   if not available code_mstr then do :                      
      {us/bbi/pxmsg.i &MSGNUM=7081 &ERRORLEVEL=3}
      /* SITE DOES NOT EXIST */
      next-prompt site with frame a.
      undo,retry.
   end.
    
   global_site = site.

   
   run GetParameter(input  "CARL_INTERFACE_STOCK",
                    input  (site +  "_import_it_input"),
                    output input_dir
                    ).

   run GetParameter(input  "CARL_INTERFACE_STOCK",
                    input  (site +  "_import_it_archive"),
                    output arch_dir
                    ). 
 
   run GetParameter(input  "CARL_INTERFACE_STOCK",
                    input  (site +  "_import_it_error"),
                    output err_dir
                    ).

   run get-dir-path(input  arch_dir,
                    output arch_dir).
   *SFM_2023_001 end cmmt*/ 

   /*SFM_2023_001 begin add code */
   run GetParameter( input "CARL_INTERFACE_ITEM",
                     input "common_import_in",
                     output input_dir
                     ).

   run GetParameter( input  "CARL_INTERFACE_ITEM",
                     input  "common_import_error",
                     output err_dir
                     ).

   /*SFM_2023_001 end add code*/

   run get-dir-path(input  input_dir,
                    output input_dir).
                    
   run get-dir-path(input  err_dir,
                    output err_dir).
   
   /* SFM_2023_001 begin cmmt                
   run GetParameter(input  "CARL_INTERFACE_STOCK",
                    input  (site +  "_import_ext"),
                    output ext_file
                    ).  
   SFM_2023_001 end cmmt*/ 
   /*SFM_2023_001 begin add code*/  
   run GetParameter(input  "CARL_INTERFACE_ITEM",
                    input  ( "import_ext"),
                    output ext_file
                    ).  
   /*SFM_2023_001 end add code */

   if ext_file = "" then ext_file = "*.csv".
   
   if batchrun = no then do :
      update
         input_dir
         ext_file
         /*arch_dir SFM_2023_001 cmmt*/
         err_dir
      with frame a.
   end.
   
   if input_dir = "" then do:
      if not batchrun then do:
         {us/bbi/pxmsg.i &MSGNUM=40 &ERRORLEVEL=3}
      end.
      undo mainloop, retry mainloop.
   end.

   if ext_file = "" then do:
      {us/bbi/pxmsg.i &MSGNUM=40 &ERRORLEVEL=3}
      undo mainloop, retry mainloop.
   end.

   run get-dir-path(input input_dir,
                    output input_dir).
   v_msg = "".
   run check_directory (input input_dir,
                        input "D*W",
                        output v_msg).
   if v_msg <> "" then do:
      if not batchrun then do:
         {us/bbi/pxmsg.i &MSGTEXT=v_msg &ERRORLEVEL=3}
      end.
      undo mainloop, retry mainloop.
   end.

   /*SFM_2023_001 begin cmmt
   if arch_dir = "" then do:
      if not batchrun then do:
         {us/bbi/pxmsg.i &MSGNUM=40 &ERRORLEVEL=3}
      end.
      undo mainloop, retry mainloop.
   end.

   run get-dir-path(input  arch_dir,
                    output arch_dir).
   v_msg = "".
  run check_directory (input arch_dir,
                        input "D*W",
                        output v_msg).
   if v_msg <> "" then do:
      if not batchrun then do:
         {us/bbi/pxmsg.i &MSGTEXT=v_msg &ERRORLEVEL=3}
      end.
      undo mainloop, retry mainloop.
   end.
   SFM_2023_001 end cmmt*/
   
   run get-dir-path(input  err_dir,
                    output err_dir).
   v_msg = "".
   run check_directory (input err_dir,
                        input "D*W",
                        output v_msg).
   if v_msg <> "" then do:
      if not batchrun then do:
         {us/bbi/pxmsg.i &MSGTEXT=v_msg &ERRORLEVEL=3}
      end.
      undo mainloop, retry mainloop.
   end.

   empty temp-table tt_file.
   empty temp-table tt_result.
   empty temp-table tt_item.
   
   bcdparm = "".
   /*{us/mf/mfquoter.i site       }    SFM_2023_001 cmmt*/
   {us/mf/mfquoter.i input_dir  }
   {us/mf/mfquoter.i ext_file   }
   /*{us/mf/mfquoter.i arch_dir   }    SFM_2023_001 cmmt*/
   {us/mf/mfquoter.i err_dir    }
   
   {us/gp/gpselout.i &printType = "printer"                                                          
                     &printWidth = 132                                                               
                     &pagedFlag = " "                                                                
                     &stream = " "                                                                   
                     &appendToFile = " "                                                             
                     &streamedOutputToTerminal = " "                                                 
                     &withBatchOption = "yes"                                                        
                     &displayStatementType = 1                                                       
                     &withCancelMessage = "yes"                                                      
                     &pageBottomMargin = 6                                                           
                     &withEmail = "yes"                                                              
                     &withWinprint = "yes"                                                           
                     &definevariables = "yes"}                                           
   
   {us/bbi/mfphead.i} 
   
   logfile = session:temp-dir + "INV_" 
           + string(year(today),"9999") 
           + string(month(today),"99") 
           + string(day(today),"99") + ".log".

   output stream zzlog to value(logfile) append.
        
   if opsys = "UNIX" then do:
           
      run GetFileFromInputDir.
      run get_data_from_input_file.
      run tt_item_control.
      run tt_item_CIM.

   end. /*if opsys = "UNIX" then do:*/

   output stream zzlog close.
   os-delete value(logfile).
    
   for each tt_item 
   break by tt_ItemCode:
   
      display
         tt_cim_ok
         tt_ItemCode
         tt_creation 
         tt_modification
         tt_nbr_modif
         tt_msg_err   
         tt_UM        
         tt_desc1        
         tt_prod_line     
         tt_Inv_Site 
         tt_cost_set 
         tt_level  
         tt_Site   
         tt_lot_ser   
         tt_buyer             
         tt_supplier         
         tt_vd_lead_time     
         tt_curr             
         tt_q_price          
         tt_price_list       
         tt_comment
      with frame c down.
      down 1 with frame c.

   end. /*for each tt_item break by tt_FileItem by tt_ItemCode:*/

   {us/mf/mfrtrail.i}
   
end. /*repeat*/

procedure GetFileFromInputDir:

   unix silent chmod 666 value(logfile) 2> /dev/null.      

   ind = 1.       
   wk_command = "find " + substring(input_dir,1,length(input_dir) - 1 ) 
              + " -maxdepth 1 -name '" + entry(ind,ext_file) + "'".

   assign
      wk_file = ""
      ii = 1
      .

   input through value(wk_command) echo.
   repeat:
      if v_file <> "" then do :
         file-info:file-name = v_file. 
         if file-info:file-size = 0 then do :
            put stream zzlog
            " ** ERROR FILE " v_file format "x(61)" " IS empty ** "
            skip.
            v_error = " ** ERROR FILE " + v_file + " IS empty ** ".

            create tt_result.
            assign
               tt_result.tt_File        = v_file
               tt_treat       = no
               tt_rmk         = v_error
               .
            put stream zzlog unformatted v_error.
         end. /*if file-info:file-size = 0 then do :*/
      end. /*if v_file <> "" then do :*/
            
      import v_file. 
      create tt_file.

      assign 
         tt_filename = v_file
         tt_number   = ii.
         ii = ii + 1.

   end. /*repeat:*/
   input close. /*input through value(wk_command) echo.*/
   
   
end procedure. /*GetFileFromInputDir*/

procedure get_data_from_input_file:
  
   put stream zzlog
      " ** COPIE DES FICHIERS ** "
      skip
      "DEBUT TRAITEMENT: " today " - " string(time,"HH:MM:SS")
      skip.

   ReadFile:
   do kk = 1 to 10000 :
      find next tt_file no-lock no-error.
      if available tt_file then do :  

         if tt_filename = "" or tt_filename = "find:" then 
            leave.
         wk_filename = tt_filename.
         unix silent chmod 777 value(wk_filename) 2> /dev/null.
         input from value(wk_filename).
         vimphear = no.
         repeat:
            
            if vimphear = no then do:
               import vligne.
               vimphear = yes.
            end. /*if vimphear = no then do:*/
            else do:          
               create tt_item.                               
               import delimiter "|" tt_item.
               tt_item.tt_FileItem = wk_filename. 
            end. /*else do:*/
         end.
      end. /*if available tt_file then do : */
   end. /*do kk = 1 to 1000 :*/
end. /*get_data_from_input_file*/

procedure tt_item_control :

   define variable vold_global_user_lang  like global_user_lang   no-undo.

   for each tt_item 
   break by tt_FileItem 
   by tt_ItemCode:  

      vold_global_user_lang = global_user_lang.

      if tt_ItemCode = "" then do :
         delete tt_item .
         next.
      end.

      /*SFM_2023_001 begin add code*/
      find first pt_mstr
      where pt_domain   = global_domain 
      and pt_part       = tt_ItemCode
      no-lock no-error.

      if (tt_creation = yes and tt_modification = yes)
      or (tt_creation = no and tt_modification = no)
      then do :
         if global_user_lang = "FR" then tt_msg_err = "Choix Création/Modification Non Conforme".
         if global_user_lang = "US" then tt_msg_err = "Non-compliant Modification/Creation Choice".
         assign
            tt_msg_err_fr  = "Choix Création/Modification Non Conforme "
            tt_msg_err_us  = "Non-compliant Modification/Creation Choice "
            tt_cim_ok      = "no"
         .
         next.
      end. /*(tt_creation = yes and tt_modification = yes) or (tt_creation = no and tt_modification = no)*/
      else if tt_creation = yes and tt_modification = no and available pt_mstr 
      then do :
         if global_user_lang = "FR" then tt_msg_err = "Déjà créé : Choix Création/Modification incorrecte".
         if global_user_lang = "US" then tt_msg_err = "Already created : incorrect Modification/Creation Choice".
         assign
            tt_msg_err_fr  = tt_ItemCode + "Déjà créé : Choix Création/Modification incorrecte "
            tt_msg_err_us  = tt_ItemCode + "Already created : incorrect Modification/Creation Choice "
            tt_cim_ok      = "no"
         .
         next.
      end.
      else if tt_creation = no and tt_modification = yes and not available pt_mstr 
      then do : 
         if global_user_lang = "FR" then tt_msg_err = "Non créé : Choix Création/Modification incorrecte".
         if global_user_lang = "US" then tt_msg_err = "Not yet created : incorrect Modification/Creation Choice".
         assign
         tt_msg_err_fr  = tt_ItemCode + "Non créé : Choix Création/Modification incorrecte "
         tt_msg_err_us  = tt_ItemCode + "Not yet created : incorrect Modification/Creation Choice "
         tt_cim_ok      = "no"
      .
         next.
      end.
      else if tt_creation = yes and tt_modification = no and not available pt_mstr then do :
         tt_cim_ok      = "yes".
      end. /*else if tt_creation = yes and tt_modification = no and not available pt_mstr*/
      else if tt_creation = no and tt_modification = yes and available pt_mstr then do :
         tt_cim_ok      = "yes".
         for first ptp_det  
         where ptp_domain = global_domain 
         and ptp_part = pt_part
         and ptp_site = pt_site
         exclusive-lock: 
            ptp_run_seq2 = "|||".
         end. /*for first ptp_det*/

         for first bpt_mstr
         where bpt_mstr.pt_domain   = global_domain
         and bpt_mstr.pt_part       = tt_ItemCode
         exclusive-lock: 
            assign
               bpt_mstr.pt__dec02 = bpt_mstr.pt__dec02 + 1 .
               tt_nbr_modif       = bpt_mstr.pt__dec02
            .
         end. /*for first bpt_mstr*/
       end. /*if tt_creation = no and tt_modification = yes and available pt_mstr*/
      /*SFM_2023_001 end add code*/


      /******************************  CIM CONTROL 1.4.3*/
      find first code_mstr 
      where code_domain = global_domain 
      and code_fldname  = "pt_um"
      and code_value    = tt_UM
      no-lock no-error.
      if not available code_mstr then do :
         /*UM Value must exist in Generalized Codes*/
         {us/bbi/pxmsg.i &MSGNUM=716 &MSGBUFFER = tt_msg_err}
         global_user_lang = "FR".
         {us/bbi/pxmsg.i  &MSGNUM = 716  &MSGBUFFER = tt_msg_err_fr } 
         assign
            tt_msg_err_fr     = "UM " + tt_msg_err_fr 
            global_user_lang  = "US"
         .
         {us/bbi/pxmsg.i  &MSGNUM = 716  &MSGBUFFER = tt_msg_err_us } 
         assign
            tt_msg_err_us     = "UM " + tt_msg_err_us 
            global_user_lang  = vold_global_user_lang
         .
         assign
            tt_msg_err  = "UM " + tt_msg_err 
            tt_cim_ok   = "no".
         next.         
      end.
      
      if length(tt_desc1) > 24 then tt_desc1 = substring (tt_desc1 , 1 , 24).
      if length(tt_desc2) > 24 then tt_desc2 = substring (tt_desc2 , 1 , 24).
      
      find first pl_mstr 
      where pl_domain   = global_domain
      and pl_prod_line  = tt_prod_line
      no-lock no-error.
      if not available pl_mstr then do :
         /*Product line does not exist*/         
         {us/bbi/pxmsg.i &MSGNUM=59 &MSGBUFFER = tt_msg_err}
         global_user_lang = "FR".
         {us/bbi/pxmsg.i  &MSGNUM = 59  &MSGBUFFER = tt_msg_err_fr } 
         global_user_lang = "US".
         {us/bbi/pxmsg.i  &MSGNUM = 59  &MSGBUFFER = tt_msg_err_us } 
         assign
            global_user_lang  = vold_global_user_lang
            tt_cim_ok         = "no"
         .
         next.
      end.

      find first code_mstr 
      where code_domain = global_domain 
      and code_fldname  = "pt_promo"
      and code_value    = tt_promo_gp
      no-lock no-error.
      if not available code_mstr then do :
         /*Prom Group Value must exist in Generalized Codes*/
         {us/bbi/pxmsg.i &MSGNUM=716 &MSGBUFFER = tt_msg_err}
         global_user_lang = "FR".
         {us/bbi/pxmsg.i  &MSGNUM = 716  &MSGBUFFER = tt_msg_err_fr } 
         assign
            tt_msg_err_fr     = "Promo Group " + tt_msg_err_fr 
            global_user_lang  = "US"
         .
         {us/bbi/pxmsg.i  &MSGNUM = 716  &MSGBUFFER = tt_msg_err_us } 
         assign
            tt_msg_err_us     = "Promo Group " + tt_msg_err_us 
            tt_msg_err        = "Promo Group " + tt_msg_err 
            tt_cim_ok         = "no"
            global_user_lang  = vold_global_user_lang
         .
         next.         
      end.

      find first code_mstr 
      where code_domain = global_domain 
      and code_fldname  = "pt_part_type"
      and code_value    = tt_part_type
      no-lock no-error.
      if not available code_mstr then do :
         /*Prom Group Value must exist in Generalized Codes*/
         {us/bbi/pxmsg.i &MSGNUM=716 &MSGBUFFER = tt_msg_err}
         global_user_lang = "FR".
         {us/bbi/pxmsg.i  &MSGNUM = 716  &MSGBUFFER = tt_msg_err_fr } 
         assign
            tt_msg_err_fr     = "Item Type " + tt_msg_err_fr 
            global_user_lang  = "US"
         .
         {us/bbi/pxmsg.i  &MSGNUM = 716  &MSGBUFFER = tt_msg_err_us } 
         assign
            tt_msg_err_us     = "Item Type " + tt_msg_err_us 
            tt_msg_err        = "Item Type " + tt_msg_err 
            tt_cim_ok         = "no"
            global_user_lang  = vold_global_user_lang
         .
         next.         
      end.

      /*SFM_2023_001 begin cmmt***
      find first code_mstr 
      where code_domain = global_domain 
      and code_fldname  = "pt_group"
      and code_value    = tt_Group
      no-lock no-error.
      if not available code_mstr then do :

         /*Prom Group Value must exist in Generalized Codes*/
         {us/bbi/pxmsg.i &MSGNUM=716 &MSGBUFFER = tt_msg_err}
         global_user_lang = "FR".
         {us/bbi/pxmsg.i  &MSGNUM = 716  &MSGBUFFER = tt_msg_err_fr } 
         assign
            tt_msg_err_fr     = "Group " + tt_msg_err_fr 
            global_user_lang  = "US"
         .
         {us/bbi/pxmsg.i  &MSGNUM = 716  &MSGBUFFER = tt_msg_err_us } 
         assign
            tt_msg_err_us     = "Group " + tt_msg_err_us 
            tt_msg_err        = "Group " + tt_msg_err 
            tt_cim_ok         = "no"
            global_user_lang  = vold_global_user_lang
         .
         next.         
      end.
      ***SFM_2023_001 end cmmt*/
    
      if tt_net_wt_um = "" 
      then do :
         {us/bbi/pxmsg.i &MSGNUM=40 &MSGBUFFER = tt_msg_err}
         global_user_lang = "FR".
         {us/bbi/pxmsg.i  &MSGNUM = 40  &MSGBUFFER = tt_msg_err_fr } 
         assign
            tt_msg_err_fr     = "Net Weight UM : " + tt_msg_err_fr 
            global_user_lang  = "US"
         .
         {us/bbi/pxmsg.i  &MSGNUM = 40  &MSGBUFFER = tt_msg_err_us } 
         assign
            tt_msg_err_us     = "Net Weight UM : " + tt_msg_err_us 
            tt_cim_ok         = "no"
            tt_msg_err        = "Net Weight UM : " + tt_msg_err 
            global_user_lang  = vold_global_user_lang
         .
         next.
      end.

      if tt_ship_wt_um = "" 
      then do :
         {us/bbi/pxmsg.i &MSGNUM=40 &MSGBUFFER = tt_msg_err}
         global_user_lang = "FR".
         {us/bbi/pxmsg.i  &MSGNUM = 40  &MSGBUFFER = tt_msg_err_fr } 
         assign
            tt_msg_err_fr     = "Poids d'expedition : " + tt_msg_err_fr 
            global_user_lang  = "US"
         .
         {us/bbi/pxmsg.i  &MSGNUM = 40  &MSGBUFFER = tt_msg_err_us } 
         assign
            tt_msg_err_us     = "Ship Weight : " + tt_msg_err_us 
            tt_cim_ok         = "no"
            tt_msg_err        = "Poids d'expedition UM : " +  tt_msg_err
            global_user_lang  = vold_global_user_lang
         .
         next.
      end.

      /******************************  CIM CONTROL 1.4.15*/
      find first si_mstr
      where si_domain = global_domain 
      and si_site     = tt_Inv_Site
      no-lock no-error.
      if not available si_mstr then do :
         /*Site does not exist*/
         {us/bbi/pxmsg.i &MSGNUM=708 &MSGBUFFER = tt_msg_err}
         global_user_lang = "FR".
         {us/bbi/pxmsg.i  &MSGNUM = 708  &MSGBUFFER = tt_msg_err_fr } 
         global_user_lang = "US".
         {us/bbi/pxmsg.i  &MSGNUM = 708  &MSGBUFFER = tt_msg_err_us } 
         assign
            global_user_lang  = vold_global_user_lang
            tt_cim_ok         = "no" 
         .
         next.
      end.
      find first cs_mstr
      where cs_domain   = global_domain
      and cs_set        = tt_cost_set
      no-lock no-error.
      if not available cs_mstr then do :
         /*Cost set does not exist*/
         {us/bbi/pxmsg.i &MSGNUM=5407 &MSGBUFFER = tt_msg_err}
         global_user_lang = "FR".
         {us/bbi/pxmsg.i  &MSGNUM = 5407  &MSGBUFFER = tt_msg_err_fr } 
         global_user_lang = "US".
         {us/bbi/pxmsg.i  &MSGNUM = 5407  &MSGBUFFER = tt_msg_err_us } 
         assign
            global_user_lang  = vold_global_user_lang
            tt_cim_ok         = "no" 
         .
         next.
      end.

      find first sc_mstr
      where sc_domain = global_domain
      and sc_sim      = tt_cost_set
      and sc_element  = tt_element
      no-lock no-error.
      if not available sc_mstr then do :
         /*Element not defined*/
         {us/bbi/pxmsg.i &MSGNUM=103 &MSGBUFFER = tt_msg_err}
         global_user_lang = "FR".
         {us/bbi/pxmsg.i  &MSGNUM = 103  &MSGBUFFER = tt_msg_err_fr } 
         global_user_lang = "US".
         {us/bbi/pxmsg.i  &MSGNUM = 103  &MSGBUFFER = tt_msg_err_us } 
         assign
            global_user_lang  = vold_global_user_lang
            tt_cim_ok         = "no" 
         .
         next.
      end.

      /******************************  CIM CONTROL 1.4.16*/
      find first si_mstr
      where si_domain = global_domain 
      and si_site     = tt_Site
      no-lock no-error.
      if not available si_mstr then do :
         /*Site does not exist*/
         {us/bbi/pxmsg.i &MSGNUM=708 &MSGBUFFER = tt_msg_err}
         global_user_lang = "FR".
         {us/bbi/pxmsg.i  &MSGNUM = 708  &MSGBUFFER = tt_msg_err_fr } 
         global_user_lang = "US".
         {us/bbi/pxmsg.i  &MSGNUM = 708  &MSGBUFFER = tt_msg_err_us } 
         assign
            global_user_lang  = vold_global_user_lang
            tt_cim_ok         = "no" 
         .
         next.
      end.

      if lookup (tt_lot_ser , "L,S") = 0 
      and tt_lot_ser <> ""
      then do :
         /*Value must be (L)ot, (S)ingle or blank*/
         {us/bbi/pxmsg.i &MSGNUM=1371 &MSGBUFFER = tt_msg_err}
         global_user_lang = "FR".
         {us/bbi/pxmsg.i  &MSGNUM = 1371  &MSGBUFFER = tt_msg_err_fr } 
         assign
            tt_msg_err_fr     = "Lot/Control " + tt_msg_err_fr 
            global_user_lang  = "US"
         .
         {us/bbi/pxmsg.i  &MSGNUM = 1371  &MSGBUFFER = tt_msg_err_us } 
         assign
            tt_msg_err_us     = "Lot/Control " + tt_msg_err_us 
            tt_cim_ok         = "no" 
            tt_msg_err        = "Lot/Control " + tt_msg_err
            global_user_lang  = vold_global_user_lang
         .
         next.         
      end.
         
      /*SFM_2023_001 begin add code */
      find first loc_mstr 
      where loc_domain  = global_domain
      and loc_site      = tt_Site
      and loc_loc       = tt_Loc 
      no-lock no-error.
      if not available loc_mstr then run Cim_1_1_18(  input tt_ItemCode ,
                                                      input tt_Site     ,
                                                      input tt_Loc      ).
      if v_error = "" then do:
         find first loc_mstr 
         where loc_domain  = global_domain
         and loc_site      = tt_Site
         and loc_loc       = tt_Loc
         no-lock no-error.
         if not available loc_mstr then do:
            assign
               tt_msg_err_fr = " Cim 1_1_18 OK mais loc_mstr non crée"  
               tt_msg_err_us = " Cim 1_1_18 OK but loc_mstr not created"  
               tt_cim_ok     = "no"
            . 
            next.
         end. /* if not available loc_mstr*/
        
      end. /*if v_error = "" then do:*/
      /*SFM_2023_001 end add code */

      find first code_mstr 
      where code_domain = global_domain 
      and code_fldname  = "pti_memo_type"
      and code_value    = tt_memo_type
      no-lock no-error.
      if not available code_mstr and tt_memo_type <> "" then do :
         /*Memo Order Type Value must exist in Generalized Codes*/
         {us/bbi/pxmsg.i &MSGNUM=716 &MSGBUFFER = tt_msg_err}
         global_user_lang = "FR".
         {us/bbi/pxmsg.i  &MSGNUM = 716  &MSGBUFFER = tt_msg_err_fr } 
         assign
            tt_msg_err_fr     = "Memo Order Type " + tt_msg_err_fr 
            global_user_lang  = "US"
         .
         {us/bbi/pxmsg.i  &MSGNUM = 716  &MSGBUFFER = tt_msg_err_us } 
         assign
            tt_msg_err_us     = "Memo Order Type " + tt_msg_err_us 
            tt_msg_err        = "Memo Order Type " + tt_msg_err 
            tt_cim_ok         = "no"
            global_user_lang  = vold_global_user_lang
         .
         next.         
      end.    

      /******************************  CIM CONTROL 1.4.17*/
      if length (tt_ord_pol) > 3 
      then do :
         /*Order Policy Code too long*/
         {us/bbi/pxmsg.i &MSGNUM=10626 &MSGBUFFER = tt_msg_err}
         global_user_lang = "FR".
         {us/bbi/pxmsg.i  &MSGNUM = 10626  &MSGBUFFER = tt_msg_err_fr } 
         assign
            tt_msg_err_fr     = "Order Policy " + tt_msg_err_fr 
            global_user_lang  = "US"
         .
         {us/bbi/pxmsg.i  &MSGNUM = 10626  &MSGBUFFER = tt_msg_err_us } 
         assign
            tt_msg_err_us     = "Order Policy " + tt_msg_err_us 
            tt_msg_err        = "Order Policy " + tt_msg_err 
            tt_cim_ok         = "no"
            global_user_lang  = vold_global_user_lang
         .
         next.
      end.

      find first code_mstr 
      where code_domain = global_domain 
      and code_fldname  = "ptp_buyer"
      and code_value    = tt_buyer
      no-lock no-error.
      if not available code_mstr then do :
         /*Buyer/Planner Value must exist in Generalized Codes*/
         {us/bbi/pxmsg.i &MSGNUM=716 &MSGBUFFER = tt_msg_err}
         global_user_lang = "FR".
         {us/bbi/pxmsg.i  &MSGNUM = 716  &MSGBUFFER = tt_msg_err_fr } 
         assign
            tt_msg_err_fr     = "Buyer/Planner " + tt_msg_err_fr 
            global_user_lang  = "US"
         .
         {us/bbi/pxmsg.i  &MSGNUM = 716  &MSGBUFFER = tt_msg_err_us } 
         assign
            tt_msg_err_us     = "Buyer/Planner " + tt_msg_err_us 
            tt_msg_err        = "Buyer/Planner " + tt_msg_err 
            tt_cim_ok         = "no"
            global_user_lang  = vold_global_user_lang
         .
         next.         
      end.    
      
      find first code_mstr 
      where code_domain = global_domain 
      and code_fldname  = "ptp_pm_code"
      and code_value    = tt_pm_code
      no-lock no-error.
      if not available code_mstr then do :
         /* Purchase/Manufacture Value must exist in Generalized Codes*/
         {us/bbi/pxmsg.i &MSGNUM=716 &MSGBUFFER = tt_msg_err}
         global_user_lang = "FR".
         {us/bbi/pxmsg.i  &MSGNUM = 716  &MSGBUFFER = tt_msg_err_fr } 
         assign
            tt_msg_err_fr     = "Purchase/Manufacture " + tt_msg_err_fr 
            global_user_lang  = "US"
         .
         {us/bbi/pxmsg.i  &MSGNUM = 716  &MSGBUFFER = tt_msg_err_us } 
         assign
            tt_msg_err_us     = "Purchase/Manufacture " + tt_msg_err_us 
            tt_msg_err        = "Purchase/Manufacture " + tt_msg_err 
            tt_cim_ok         = "no"
            global_user_lang  = vold_global_user_lang
         .
         next.         
      end.         
   
      /******************************  CIM CONTROL 1.19*/
      find first vd_mstr
      where vd_domain   = global_domain 
      and vd_addr       = tt_supplier
      no-lock no-error.
      if not available vd_mstr then do:
         /*Not a valid supplier*/
         {us/bbi/pxmsg.i &MSGNUM=2 &MSGBUFFER = tt_msg_err}
         global_user_lang = "FR".
         {us/bbi/pxmsg.i  &MSGNUM = 2  &MSGBUFFER = tt_msg_err_fr } 
         global_user_lang = "US".
         {us/bbi/pxmsg.i  &MSGNUM = 2  &MSGBUFFER = tt_msg_err_us } 
         assign
            global_user_lang  = vold_global_user_lang
            tt_cim_ok         = "no"
         .
         next.       
      end.

      if length (tt_supplier_item) > 30 
      then do :
         /*Supplier Item Code too long*/
         {us/bbi/pxmsg.i &MSGNUM=10626 &MSGBUFFER = tt_msg_err}
         global_user_lang = "FR".
         {us/bbi/pxmsg.i  &MSGNUM = 10626  &MSGBUFFER = tt_msg_err_fr } 
         assign
            tt_msg_err_fr     = "Supplier Item " + tt_msg_err_fr 
            global_user_lang  = "US"
         .
         {us/bbi/pxmsg.i  &MSGNUM = 10626  &MSGBUFFER = tt_msg_err_us } 
         assign
            tt_msg_err_us     = "Supplier Item " + tt_msg_err_us 
            tt_msg_err        = "Supplier Item " + tt_msg_err 
            tt_cim_ok         = "no"
            global_user_lang  = vold_global_user_lang
         .
         next.
      end.
      
      find first cu_mstr
      where cu_curr = tt_curr
      no-lock no-error.
      if not available cu_mstr then do:
         /*Invalid Currency Code*/
         {us/bbi/pxmsg.i &MSGNUM=3109 &MSGBUFFER = tt_msg_err}
         global_user_lang = "FR".
         {us/bbi/pxmsg.i  &MSGNUM = 3109  &MSGBUFFER = tt_msg_err_fr } 
         global_user_lang = "US".
         {us/bbi/pxmsg.i  &MSGNUM = 3109  &MSGBUFFER = tt_msg_err_us } 
         assign
            global_user_lang  = vold_global_user_lang
            tt_cim_ok         = "no"
         .
         next.         
      end.

      find first pc_mstr
      where pc_domain   = global_domain
      and pc_list       = tt_price_list
      no-lock no-error.
      if not available pc_mstr then do:
         /*Price list must exist*/
         {us/bbi/pxmsg.i &MSGNUM=7253 &MSGBUFFER = tt_msg_err}
         global_user_lang = "FR".
         {us/bbi/pxmsg.i  &MSGNUM = 7253  &MSGBUFFER = tt_msg_err_fr } 
         global_user_lang = "US".
         {us/bbi/pxmsg.i  &MSGNUM = 7253  &MSGBUFFER = tt_msg_err_us } 
         assign
            global_user_lang  = vold_global_user_lang
            tt_cim_ok         = "no"
         .
         next.         
      end.

      run check_manufacturer_item(  input tt_manufacturer_item ,
                                    input tt_comment           ,
                                    output tt_manufacturer_item,
                                    output tt_comment          ).

      if length (tt_comment) > 40 
      then do :
         /*"Manuf/item|Comment" Code too long*/
         {us/bbi/pxmsg.i &MSGNUM=10626 &MSGBUFFER = tt_msg_err}
         global_user_lang     = "FR".
         {us/bbi/pxmsg.i  &MSGNUM = 10626  &MSGBUFFER = tt_msg_err_fr } 
         assign
            tt_msg_err_fr     = "'Manuf/item|Comment' " + tt_msg_err_fr 
            global_user_lang  = "US"
         .
         {us/bbi/pxmsg.i  &MSGNUM = 10626  &MSGBUFFER = tt_msg_err_us } 
         assign
            tt_msg_err_us     = "'Manuf/item|Comment' " + tt_msg_err_us 
            tt_msg_err        = "'Manuf/item|Comment' " + tt_msg_err 
            tt_cim_ok         = "no"
            global_user_lang  = vold_global_user_lang
         .
         next.
      end. 
   end. /*for each tt_item break by tt_FileItem by tt_ItemCode:*/

end. /*tt_item_control*/ 

procedure tt_item_CIM :
    
   for each tt_item
   where  tt_cim_ok = "yes"
   or tt_cim_ok = ""
   break by tt_FileItem 
   by tt_ItemCode:

      assign
         tt_element  = replace_num_separator(tt_element)
         tt_ord_qty  = decimal (replace_num_separator(string(tt_ord_qty )))
         tt_sfty_stk = decimal (replace_num_separator(string(tt_sfty_stk)))
         tt_q_price  = decimal (replace_num_separator(string(tt_q_price )))
      .

      /*SFM_2023_001 begin add code */
      find first code_mstr 
      where code_domain = global_domain 
      and code_fldname  = "pt_group"
      and code_value    = tt_Group
      no-lock no-error.
      if not available code_mstr then do :
         create bcode_mstr.
         assign
            bcode_mstr.code_domain  = global_domain
            bcode_mstr.code_fldname = "pt_group"
            bcode_mstr.code_value   = tt_Group
         .
      end. /*if not available code_mstr*/
      /*SFM_2023_001 end add code */

      CIM:
      do transaction :
         v_error        = "".

         run Cim_1_4_3( input tt_ItemCode ,
                        input tt_UM       ,
                        input tt_desc1    , 
                        input tt_desc2    , 
                        input tt_prod_line, 
                        input tt_promo_gp , 
                        input tt_part_type, 
                        input tt_Group    , 
                        input tt_draw     , 
                        input tt_rev      ).

         if v_error <> "" then do :
            if tt_msg_err_fr = "" then do :
               assign
                  tt_msg_err_fr = v_error
                  tt_msg_err_us = v_error
               .
            end.
            assign
               tt_cim_ok          = getTermLabel("no",5)
               tt_msg_err         = v_error

            .
            undo CIM,leave CIM.
         end.

         for first pt_mstr
         where pt_domain   = global_domain
         and pt_part       =  tt_ItemCode
         exclusive-lock:
            assign
               pt_ship_wt_um  = tt_ship_wt_um
               pt_net_wt      = decimal (replace_num_separator(string(tt_net_wt)))
               pt_net_wt_um   = tt_net_wt_um
            .
         end.

         run Cim_1_4_15(   input tt_ItemCode ,
                           input tt_Inv_Site ,
                           input tt_cost_set ,
                           input tt_element  ,
                           input tt_level    ).

         if v_error <> "" then do :
            if tt_msg_err_fr = "" then do :
               assign
                  tt_msg_err_fr = v_error
                  tt_msg_err_us = v_error
               .
            end.
            assign
               tt_cim_ok          = getTermLabel("no",5)
               tt_msg_err         = v_error
            .
            undo CIM,leave CIM.
         end.            
         
         run Cim_1_4_16 (  input tt_ItemCode ,
                           input tt_Site     ,
                           input tt_lot_ser  ,
                           input tt_Loc      ,
                           input tt_memo_type).

         if v_error <> "" then do :
            if tt_msg_err_fr = "" then do :
               assign
                  tt_msg_err_fr = v_error
                  tt_msg_err_us = v_error
               .
            end.
            assign
               tt_cim_ok          = getTermLabel("no",5)
               tt_msg_err         = v_error
            .
            undo CIM,leave CIM.
         end.                  

         run Cim_1_4_17 (  input tt_ItemCode    ,
                           input tt_Site        ,
                           input tt_mstr_sched  ,
                           input tt_plan_ord    ,
                           input tt_ord_pol     ,
                           input tt_ord_qty     ,
                           input tt_sfty_stk    ,
                           input tt_sfty_tme    ,
                           input tt_rop         ,
                           input tt_rev         ,
                           input tt_iss_pol     ,
                           input tt_buyer       ,
                           input tt_pm_code     ,
                           input tt_ins_lead    ,
                           input tt_cum_lead    ,
                           input tt_mfg_lead    ,
                           input tt_pur_lead    ,
                           input tt_ord_min     ,
                           input tt_ord_max     ,
                           input tt_ord_mult    ,
                           input tt_routing     ).

         if v_error <> "" then do :
            if tt_msg_err_fr = "" then do :
               assign
                  tt_msg_err_fr = v_error
                  tt_msg_err_us = v_error
               .
            end.
            assign
               tt_cim_ok          = getTermLabel("no",5)
               tt_msg_err         = v_error
            .
         undo CIM,leave CIM.
         end. 

         run Cim_1_19 ( input tt_ItemCode          ,
                        input tt_supplier          ,
                        input tt_supplier_item     ,
                        input tt_UM                ,
                        input tt_vd_lead_time      ,
                        input tt_curr              ,
                        input tt_q_price           ,
                        input tt_price_list        ,
                        input tt_manufacturer_item ,
                        input tt_comment           ).

         if v_error <> "" then do :
            if tt_msg_err_fr = "" then do :
               assign
                  tt_msg_err_fr = v_error
                  tt_msg_err_us = v_error
               .
            end.
            assign
               tt_cim_ok          = getTermLabel("no",5)
               tt_msg_err         = v_error
            .
         undo CIM,leave CIM.
         end.
         else do :
            tt_cim_ok          = getTermLabel("yes",5).
            tt_msg_err         = "".
         end. 

      end. /*do transaction :*/

   end. /*for each tt_item break by tt_FileItem by tt_ItemCode:*/

   /*** Erreur ***/
   for each tt_item 
   where tt_cim_ok = "no"
   break by tt_FileItem 
         by tt_ItemCode: 
      if last-of(tt_ItemCode) then do:  

         filename = err_dir + "ITEM_Err_" + tt_ItemCode + "_" 
                  + string(year(today),"9999") 
                  + string(month(today),"99") 
                  + string(day(today),"99") 
                  + "_"
                  + replace(string(time,"hh:mm:ss"),":","")
                  + ".csv".

         output stream file_csv to value(filename).
         /*SFM_2023_001 begin add code*/
         put stream file_csv unformatted
            "Code article|"
            "UM|"
            "Description 1|"
            "Description 2|"
            "Prod Line|"
            "Promo Group|"
            "Item type|"
            "Group|"
            "Drawing|"
            "Item Rev|"
            "Point d'expédition|"
            "Net Weight|"
            "Net Weight-2|"
            "Inventory Site|"
            "Cost Set|"
            "Element|"
            "Montant HT|"
            "Site|"
            "Lot/Control|"
            "Location|"
            "Memo Order Type|"
            "Mstr Sched|"
            "Plan Orders|"
            "Order Policy|"
            "Order Qty|"
            "Safety Stock|"
            "Safety Time|"
            "Reorder Point|"
            "Issue Policy|"
            "Buyer/Planner|"
            "Purchase/Manufacture|"
            "Inspect LT|"
            "Cum LT|"
            "Mfg LT|"
            "Pur LT|"
            "Minimum Order|"
            "Maximum Order|"
            "Order Multiple|"
            "Routing Code|"
            "Supplier|"
            "Supplier Item|"
            "Supplier Lead Time|"
            "Currency|"
            "PMP|"
            "Price list|"
            "Manufacturer Item|"
            "Comment|"
            "Creation|"
            "Modification"
         skip
         .
         /*SFM_2023_001 end add code*/
         put stream file_csv unformatted
            tt_ItemCode                "|"
            tt_UM                      "|"
            tt_desc1                   "|"
            tt_desc2                   "|" 
            tt_prod_line               "|"
            tt_promo_gp                "|"
            tt_part_type               "|"
            tt_Group                   "|"
            tt_draw                    "|"
            tt_rev                     "|"
            tt_ship_wt_um              "|"
            tt_net_wt                  "|"
            tt_net_wt_um               "|"
            tt_Inv_Site                "|"
            tt_cost_set                "|"
            tt_element                 "|"
            tt_level                   "|"
            tt_Site                    "|"
            tt_lot_ser                 "|"
            tt_Loc                     "|"
            tt_memo_type               "|"
            tt_mstr_sched              "|"
            tt_plan_ord                "|"
            tt_ord_pol                 "|"
            tt_ord_qty                 "|"
            tt_sfty_stk                "|"
            tt_sfty_tme                "|"
            tt_rop                     "|"
            tt_iss_pol                 "|"
            tt_buyer                   "|"
            tt_pm_code                 "|"
            tt_ins_lead                "|"
            tt_cum_lead                "|"
            tt_mfg_lead                "|"
            tt_pur_lead                "|"
            tt_ord_min                 "|"
            tt_ord_max                 "|"
            tt_ord_mult                "|"
            tt_routing                 "|"
            tt_supplier                "|"
            tt_supplier_item           "|"
            tt_vd_lead_time            "|"
            tt_curr                    "|"
            tt_q_price                 "|"
            tt_price_list              "|" 
            tt_manufacturer_item       "|"
            tt_comment                 "|"   skip
            "ERREUR : " tt_msg_err_fr  "|"   skip
            "ERROR  : " tt_msg_err_us  "|"   skip
         . 
         output stream file_csv close .
      end. /*if last-of(tt_ItemCode) then do:  */
   end. /*for each tt_item where tt_cim_ok = no */

   /*Delete input file */
   for each tt_item 
   break by tt_FileItem:
      if last-of(tt_FileItem) and tt_FileItem <> "" then do:     
         os-delete value(tt_FileItem).    
      end. /*if last-of(tt_FileItem) then do:*/ 
   end.
   
   /***SFM_2023_001 begin cmmt***
   /*** Archive ***/
   for each tt_item 
   break by tt_FileItem:
      if last-of(tt_FileItem) and tt_FileItem <> "" then do:     
         wk_command = "mv -f "  + tt_FileItem + " " + arch_dir.
         os-command silent value(wk_command).            
      end. /*if last-of(tt_FileItem) then do:*/ 
   end.
   ***SFM_2023_001 end cmmt***/
end procedure. /* tt_item_CIM */       

procedure check_manufacturer_item:
   
   define input parameter  ip_manufacturer_item as character      no-undo.
   define input parameter  ip_comment           like vp_comment   no-undo.

   define output parameter op_manufacturer_item as character      no-undo.
   define output parameter op_comment           like vp_comment   no-undo.

   if length (ip_manufacturer_item) > 18 
   then do:
      if ip_comment <> "" then 
         assign
            op_manufacturer_item = substring (ip_manufacturer_item , 1 , 18)
            op_comment           = substring (ip_manufacturer_item , 19 , length(ip_manufacturer_item))
                                 +  "|"
                                 + ip_comment
         .
      else 
         assign
            op_manufacturer_item = substring (ip_manufacturer_item , 1 , 18)
            op_comment           = substring (ip_manufacturer_item , 19 , length(ip_manufacturer_item))                            
            .
   end.   
end procedure. /*check_manufacturer_item*/

PROCEDURE  Cim_1_4_3:
   /* Cim_1_4_3 */
   define input  parameter ip_part       	like pt_part      	no-undo.
   define input  parameter ip_um         	like pt_um        	no-undo.
   define input  parameter ip_desc1      	like pt_desc1      	no-undo.
   define input  parameter ip_desc2      	like pt_desc2      	no-undo.
   define input  parameter ip_prd_line    like pt_prod_line    no-undo.
   define input  parameter ip_promo     	like pt_promo     	no-undo.
   define input  parameter ip_part_type  	like pt_part_type    no-undo.
   define input  parameter ip_group     	like pt_group        no-undo.
   define input  parameter ip_draw    		like pt_draw        	no-undo.
   define input  parameter ip_rev    		like pt_rev        	no-undo.

   /* CREATION DU FICHIER POUR SIMULATION */

   assign 
      v_fic_inp   = 'Cim_1_4_3_'
                  + string(TODAY,'999999')
                  + string(TIME)
      v_fic_out   = v_fic_inp + '.out'
      v_fic_inp   = v_fic_inp + '.inp'
      v_error     = ""
   .

   CIM_1_4_3:
   do transaction:

      output to value(v_fic_inp).

      put unformatted
         '"' ip_part  	   '"'   skip  /*Item Number           */      
         '"' ip_um  	   '"'      space /*UOM                   */    
         '"' ip_desc1  	'"'      space /*Description1          */  
         '"' ip_desc2  	'"'      skip  /*Description2          */       
         '"' ip_prd_line  '"'    space /*Prod Line             */
         '"' today	  	   '"'   space /*Added                 */    
         '-'                     space /*Design Group          */  
         '"' ip_promo  	'"'      space /*Promo Group           */   
         '"' ip_part_type '"'    space /*Item Type             */  
         '-'                     space /*Status                */
         '"' ip_group 		'"'   space /*Group                 */ 
         '"' ip_draw  		'"'   space /*Drawing               */  
         '"' ip_rev  		'"'   space /*Item Rev              */  
         '-'                     space /*Drawing Loc           */
         '-'                     space /*Size                  */
         '-'                     skip  /*Price Break Categorie */
      . 
      output close.

      v-batchrun = batchrun.
      batchrun = yes.
      input  from value(v_fic_inp).
      output  to   value (v_fic_out).
      {us/bbi/gprun.i ""ppptmt04.p""}
      output close.
      input  close.
  
      batchrun = v-batchrun.

      input from  value (v_fic_out).
      repeat:
         import unformatted ligne.
         if ligne begins "*" 
         or ligne begins "error"
         or ligne begins "erreur" then do:
            if v_error = "" then 
               v_error = "ERROR CIM 1.4.3 : "  + ligne .
            else 
               v_error = v_error + "~n " + ligne .
           input close.
           undo CIM_1_4_3, leave CIM_1_4_3.
         end.
      end. /* repeat */
      input close.

      os-delete value(v_fic_inp).
      os-delete value(v_fic_out).
      
   end. /*do transaction:*/
end procedure . /*Cim_1_4_3*/


PROCEDURE  Cim_1_4_15:
   /* Cim_1_4_15 */
   define input  parameter ip_part       	   like pt_part      	no-undo.
   define input  parameter ip_site         	like pt_site       	no-undo.
   define input  parameter ip_costset      	as character     	   no-undo.
   define input  parameter ip_element     	as character      	no-undo.
   define input  parameter ip_level    	   as decimal           no-undo.
   
   /* CREATION DU FICHIER POUR SIMULATION */

   assign 
      v_fic_inp   = 'Cim_1_4_15_'
                  + string(TODAY,'999999')
                  + string(TIME)
      v_fic_out   = v_fic_inp + '.out'
      v_fic_inp   = v_fic_inp + '.inp'
      v_error     = ""
   .

   CIM_1_4_15:
   do transaction:

      output to value(v_fic_inp).

      put unformatted
         '"y"'                   skip  /*Initial Existing Detail  */      
         '"' ip_part  	   '"'   space /*Item Number              */    
         '"' ip_site  	   '"'   skip  /*Site                     */  
         '"' ip_costset  	'"'   skip  /*Cost Set                 */       
         '"' ip_element  '"'     space /*Element                  */
         '"' ip_level	  	'"'   space /*Level                    */    
         '.'                     skip  /*F4                       */
         '.'                     skip  /*F4                       */
      . 
      output close.

      v-batchrun = batchrun.
      batchrun = yes.
      input  from value(v_fic_inp).
      output  to   value (v_fic_out).
      {us/bbi/gprun.i ""ppcsbtld.p""}
      output close.
      input  close.
  
      batchrun = v-batchrun.

      input from  value (v_fic_out).
      repeat:
         import unformatted ligne.
         
         if ligne begins "*" 
         or ligne begins "error"
         or ligne begins "erreur" then do:
            if v_error = "" then 
               v_error = "ERROR CIM 1.4.15 : "  + ligne .
            else 
               v_error = v_error + "~n " + ligne .
           input close.
           undo CIM_1_4_15, leave CIM_1_4_15.
         end.
      end. /* repeat */
      input close.

      os-delete value(v_fic_inp).
      os-delete value(v_fic_out).
      
   end. /*do transaction:*/
end procedure . /*Cim_1_4_15*/

procedure Cim_1_4_16 :

  define input  parameter ip_part         	like pt_part           	no-undo.
  define input  parameter ip_site           	like pt_site            no-undo. 
  define input  parameter ip_lot_ser      	like pti_lot_ser       	no-undo.
  define input  parameter ip_loc          	like pti_loc           	no-undo.
  define input  parameter ip_memo_type    	like pti_memo_type      no-undo.

   /* CREATION DU FICHIER POUR SIMULATION */

   ASSIGN 
      v_fic_inp   = 'Cim_1_4_16_'
                  + string(TODAY,'999999')
                  + string(TIME)
      v_fic_out   = v_fic_inp + '.out'
      v_fic_inp   = v_fic_inp + '.inp'
      v_error     = ""
   .

   CIM_1_4_16:
   do transaction:
      output to value(v_fic_inp).

      put unformatted
         '"' ip_part  	   '"'   space /*Item Number           */
         '"' ip_site       '"'   skip  /*Site                  */     
         '-'                     space /*ABC Class             */ 
         '"' ip_lot_ser    '"'   space /*Lot Control           */ 
         '"' ip_loc        '"'   space /*Location              */
         '-'                     space /*Location Type         */ 
         '-'                     space /*Auto Lot Numbers      */ 
         '-'                     space /*Average Interval      */ 
         '-'                     space /*Cycle Count Interval  */ 
         '-'                     space /*Shelf Life            */
         '-'                     space /*Key Item              */ 
         '-'                     space /*PO rcpt Status        */ 
         '-'                     space /*Active                */
         '-'                     space /*WO rcpt Status        */
         '-'                     space /*Active                */
         '"' ip_memo_type   '"'   skip /*Memo Order Type       */
      .
      output close.

      v-batchrun = batchrun.
      batchrun = yes.
      input  from value(v_fic_inp).
      output  to   value (v_fic_out).
      {us/bbi/gprun.i ""pppsmt01.p""}
      output close.
      input  close.
  
      batchrun = v-batchrun.

      input from  value (v_fic_out).
      repeat:
         import unformatted ligne.
         
         if ligne begins "*" 
         or ligne begins "error"
         or ligne begins "erreur" then do:
            if v_error = "" then 
               v_error = "ERROR CIM 1.4.16 : "  + ligne .
            else 
               v_error = v_error + "~n " + ligne .
           input close.
           undo CIM_1_4_16, leave CIM_1_4_16.
         end.
      end. /* repeat */
      input close.

      os-delete value(v_fic_inp).
      os-delete value(v_fic_out).
      
   end. /*do transaction:*/
end procedure . /*Cim_1_4_16 */

PROCEDURE  Cim_1_4_17:

   define input  parameter ip_part        like pt_part      	no-undo.
   define input  parameter ip_site         like pt_site   		no-undo.
   define input  parameter ip_ms 		   like ptp_ms  		   no-undo.
   define input  parameter ip_plan_ord 	like ptp_plan_ord  	no-undo.
   define input  parameter ip_ord_pol 	   like ptp_ord_pol 	   no-undo.
   define input  parameter ip_ord_qty 	   like ptp_ord_qty  	no-undo.
   define input  parameter ip_sfty_stk 	like ptp_sfty_stk  	no-undo.
   define input  parameter ip_sfty_tme 	like ptp_sfty_tme  	no-undo.
   define input  parameter ip_rop 		   like ptp_rop     	   no-undo.
   define input  parameter ip_rev 		   like ptp_rev    	   no-undo. 
   define input  parameter ip_iss_pol 	   like ptp_iss_pol  	no-undo.
   define input  parameter ip_buyer 	   like pt_buyer  		no-undo.
   define input  parameter ip_per_man 	   like ptp_pm_code 		no-undo.
   define input  parameter ip_ins_lead    like ptp_ins_lead  	no-undo.
   define input  parameter ip_cum_lead 	like ptp_cum_lead  	no-undo.
   define input  parameter ip_mfg_lead    like ptp_mfg_lead  	no-undo.
   define input  parameter ip_pur_lead 	like ptp_pur_lead  	no-undo.
   define input  parameter ip_ord_min 	   like pt_ord_min  	   no-undo.
   define input  parameter ip_ord_max 	   like pt_ord_max  	   no-undo.
   define input  parameter ip_ord_mult 	like pt_ord_mult  	no-undo.
   define input  parameter ip_routing 	   like pt_routing  	   no-undo.

   /* CREATION DU FICHIER POUR SIMULATION */

   ASSIGN 
      v_fic_inp   = 'Cim_1_4_17_'
                  + string(TODAY,'999999')
                  + string(TIME)
      v_fic_out   = v_fic_inp + '.out'
      v_fic_inp   = v_fic_inp + '.inp'
      v_error     = ""
   .

   CIM_1_4_17:
   do transaction:
      output to value(v_fic_inp).

      put unformatted
      '"' ip_part       '"' space            /*Item Number  */
      '"' ip_site       '"' skip .           /*Site         */

      if ip_ms = yes then                    /*Mstr Sched   */
         put unformatted	'"y"'     space .
      else 
         put unformatted   '"n"'    space .

      if ip_plan_ord = yes then              /*Plan Orders  */
         put unformatted	'"y"'     space .
      else 
         put unformatted   '"n"'    space .

      put unformatted	
         '-'                    space  /*Time Fence      */
         '"' ip_ord_pol '"'     space  /*Order Policy    */
         '"' ip_ord_qty '"'     space  /*Order Qty       */
         '-'                    space  /*Order Period    */
         '"' ip_sfty_stk '"'    space  /*Safety Stock    */
         '"' ip_sfty_tme '"'    space  /*Safety Time     */
         '"' ip_rop  '"'        space  /*Reorder Point   */
         '-'                    space  /*Planning Rev    */
      . 

      if ip_iss_pol = yes then
         put unformatted	'"y"'     space .
      else 
         put unformatted   '"n"'    space .  

      put unformatted	
         '"' ip_buyer '"'       space /*Buyer/Planner          */
      	'-'                    space /*Supplier               */
         '-'                    space /*PO Site                */
         '"' ip_per_man '"'     space /*Purchase/Manufacture   */
         '-'                    space /*Configuration Type     */
         '-'                    space /*Insp Location          */
         '-'                    space /*Inspect Req            */
         '"' ip_ins_lead  '"'   space  /*Inspect LT            */
         '"' ip_cum_lead '"'    space /*Cum LT                 */
         '"' ip_mfg_lead  '"'   space /*Mfg LT                 */
         '"' ip_pur_lead '"'    space /*Pur LT                 */
         '-'                     space /*ATP Enforcement       */
         '-'                     space /*Family ATP            */
         '-'                     space /*ATP Horizon           */
         '-'                     space /*Run Seq 1             */
         '-'                     space /*Run Seq 2             */
         '-'                     space /*Phantom               */
         '"' ip_ord_min '"'      space /*Minimum Order         */
         '"' ip_ord_max '"'      space /*Maximum Order         */
         '"' ip_ord_mult '"'     space /*Order Multiple        */
         '-'                     space /*Op Based Yield        */
         '-'                     space /*Yield Percent         */
         '-'                     space /*Run Time              */
         '-'                     space /*Setup Time            */
         '-'                     space /*EMT Type              */
         '-'                     space /*Auto EMT Processing   */
         '-'                     space /*Network Code          */
         '-'                     space /*Op Based Yield        */
         '"' ip_routing '"'      space /*Routing Code          */
         '-'                     space /*BOM/Formula           */
         '-'                     skip  /*Replenishment Method  */
      .

      output close.

      v-batchrun = batchrun.
      batchrun = yes.
      input  from value(v_fic_inp).
      output  to   value (v_fic_out).
      {us/bbi/gprun.i ""pppsmt02.p""}
      output close.
      input  close.
  
      batchrun = v-batchrun.

      input from  value (v_fic_out).
      repeat:
         import unformatted ligne.
         
         if ligne begins "*" 
         or ligne begins "error"
         or ligne begins "erreur" then do:
            if v_error = "" then 
               v_error = "ERROR CIM 1.4.17 : "  + ligne .
            else 
               v_error = v_error + "~n " + ligne .
           input close.
           undo CIM_1_4_17, leave CIM_1_4_17.
         end.
      end. /* repeat */
      input close.
 
      os-delete value(v_fic_inp).
      os-delete value(v_fic_out).
     
   end. /*do transaction:*/
end procedure . /*Cim_1_4_17 */

procedure Cim_1_19 :

   define input  parameter ip_part         	like pt_part        no-undo.
   define input  parameter ip_supplier       like vp_vend        no-undo. 
   define input  parameter ip_supp_item   	like vp_vend_part   no-undo.
   define input  parameter ip_um         	   like pt_um          no-undo.
   define input  parameter ip_supp_LT      	like vp_vend_lead   no-undo.
   define input  parameter ip_currency      	like vp_curr        no-undo.
   define input  parameter ip_quote_price  	like vp_q_price     no-undo.
   define input  parameter ip_price_list  	like vp_pr_list     no-undo.
   define input  parameter ip_manuf_item  	as character        no-undo.
   define input  parameter ip_comment       	like vp_comment     no-undo.

   /* CREATION DU FICHIER POUR SIMULATION */

   ASSIGN 
      v_fic_inp   = 'Cim_1_19_'
                  + string(TODAY,'999999')
                  + string(TIME)
      v_fic_out   = v_fic_inp + '.out'
      v_fic_inp   = v_fic_inp + '.inp'
      v_error     = ""
   .

   CIM_1_19:
   do transaction:
      output to value(v_fic_inp).

      put unformatted
         '"' ip_part  	      '"'   space /*Item Number           */
         '"' ip_supplier      '"'   space /*Supplier              */     
         '"' ip_supp_item     '"'   skip  /*Supplier Item         */ 
         '"' ip_um            '"'   space /*UOM                   */ 
         '"' ip_supp_LT       '"'   space /*Supplier Lead Time    */
         '-'                        space /*Use SO Reduction Price*/ 
         '-'                        space  
         '"' ip_currency      '"'   space /*Currency              */ 
         '"' ip_quote_price   '"'   space /*Quote Price           */ 
         '-'                        space /*Quote Date            */
         '-'                        space /*Quote Qty             */ 
         '"' ip_price_list     '"'  space /*Price List            */
         '-'                        space /*Manufacturer          */ 
         '"' ip_manuf_item    '"'   space /*Manufacturer Item     */
         '"' ip_comment       '"'   skip  /*Comment               */
      .
      output close.

      v-batchrun = batchrun.
      batchrun = yes.
      input  from value(v_fic_inp).
      output  to   value (v_fic_out).
      {us/bbi/gprun.i ""ppvpmt.p""}
      output close.
      input  close.

      batchrun = v-batchrun.

      input from  value (v_fic_out).
      repeat:
         import unformatted ligne.
         
         if ligne begins "*" 
         or ligne begins "error"
         or ligne begins "erreur" then do:
            if v_error = "" then 
               v_error = "ERROR CIM 1.19 : "  + ligne .
            else 
               v_error = v_error + "~n " + ligne .
         input close.
         undo CIM_1_19, leave CIM_1_19.
         end.
      end. /* repeat */
      input close.

      os-delete value(v_fic_inp).
      os-delete value(v_fic_out).

   end. /*do transaction:*/
end procedure . /*Cim_1_19 */

/*SFM_2023_001 begin add code */
procedure Cim_1_1_18:                     

   define input  parameter ip_item        as character   no-undo.
   define input  parameter ip_site        as character   no-undo.
   define input  parameter ip_loc         as character   no-undo.   

   define variable desc1                  as character   no-undo. 
   define variable ligne                  as character   no-undo.  
   
   v_error   = "" .
      
   assign 
      v_fic_inp   = 'Cim_1_1_18_'
                    + string(today,'999999')
                    + string(time)
      v_fic_out   = v_fic_inp + '.out'
      v_fic_inp   = v_fic_inp + '.inp'
     . 
                           

   Cim_1_1_18:
   do transaction:
      
      output to value(v_fic_inp).
      desc1 = ip_site + "_" + ip_loc + "_PRMNT_CARL" .   

      put unformatted 
         '"' ip_site '"'    space
         '"' ip_loc '"'     skip
         '"' desc1 '"'      space
         '"' "DISPOEXN" '"' space
         "-"                space    
         '"' today '"'      space
         '"' yes '"'        skip
         "."                skip
         "."                
      .
         
      output close.

      v-batchrun = batchrun.
      batchrun = yes.
      input  from value(v_fic_inp).
      output  to   value (v_fic_out).
      {us/bbi/gprun.i ""iclomt.p""}
      output close.
      input  close.
  
      batchrun = v-batchrun.
      input from  value (v_fic_out).
      repeat:
      
         import unformatted ligne.
         
         if ligne begins "*" 
         or ligne begins "error"
         or ligne begins "erreur" then do:
            if v_error = "" then 
               v_error = "ERROR CIM : "  + ligne .
            else 
               v_error = v_error + "~n " + ligne .
           input close.
           undo Cim_1_1_18, leave Cim_1_1_18.
         end.
      end. /* repeat */
      input close.

      os-delete value(v_fic_inp).
      os-delete value(v_fic_out).

   end. /*do transaction:*/

end procedure. /* Cim_1_1_18 */
/*SFM_2023_001 end add code */
{/apps/qad/qad/customizations/mfg/default/src/us/zz/zzproasn.i} /*SFM_2023_001   */ 
