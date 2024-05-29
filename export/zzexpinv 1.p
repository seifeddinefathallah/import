/******************************************************************************/
/* Program name  :  zzexpinv.p                                                */
/* Title         :  Interface Inventaire                                      */
/*                                                                            */
/* Purpose       : SAFE_INV_OUT                                               */
/*                                                                            */
/* Author        : Asma Ben Dhaou                                             */
/* Creation date : 14/02/2023                                                 */
/* ECO #         :                                                            */
/* Model         : QAD EE                                                     */
/******************************************************************************/
/* (c) copyright CSI, unpublished work                                        */
/* this computer program includes confidential, proprietary information       */
/* and is a trade secret of CSI                                               */
/* all use, disclosure, and/or reproduction is prohibited unless authorized   */
/* in writing. all rights reserved.                                           */
/******************************************************************************/
/*v8:convertmode=report                                                       */
/*----------------------------------------------------------------------------*/
/* Modif.        ! Auteur ! Date     ! Commentaires                           */
/*---------------!--------!----------!----------------------------------------*/
/*               !  ABD   ! 14/02/23 ! Creation                               */
/******************************************************************************/
{us/mf/mfdtitle.i}   

define variable site             like si_site                                 no-undo. 
define variable output_dir       as character format "x(50)"                  no-undo.             
define variable ext_file         as character format "x(50)" initial ".csv"   no-undo.             
define variable v_msg            as character                                 no-undo.
define variable filename         as character                                 no-undo.

define stream file_csv.
  
define temp-table tt_inv_item  
   field tt_Date              like tr_effdate
   field tt_Time              like tr_time
   field tt_DateTime          as character format "x(19)" label "Date / Time"
   field tt_TransNbr          like tr_trnbr
   field tt_Item              like tr_part
   field tt_Site              like tr_site
   field tt_Loc               like tr_loc
   field tt_Qty               as character label "Qty" 
   field tt_UM                like tr_um
   index tt_indx tt_TransNbr
.
                         
form
   site           colon 25
   output_dir     colon 25 label "Output Directory" format "x(250)" view-as fill-in size 50 by 1
   ext_file       colon 25 label "File Extention"
with frame a side-labels width 80.
setframelabels(frame a:handle).
  
form
with frame c width 400 no-attr-space down.
/* SET EXTERNAL labelS */
setframelabels(frame c:handle).
 
function replace_num_separator returns character (input ip_value as character):
   define variable op_value as character.
   if session:numeric-format = "EUROPEAN" then
      assign op_value = replace(ip_value, ",", ".").
   else assign op_value = ip_value.
   return op_value .
end.

mainloop:
repeat:

   update 
      site 
   with frame a.
     
   find first si_mstr 
   where si_domain   = global_domain 
   and si_site       = site
   no-lock no-error.
   if not available si_mstr then do:
      {us/bbi/pxmsg.i &MSGNUM=708 &ERRORLEVEL=3}
      next-prompt site with frame a.
      undo,retry.
   end. /* if not available si_mstr then do: */
  
   /* VERif SECURITE SITE */
   {us/bbi/gprun.i   ""gpsiver.p""
                     "(input site, 
                     input recid(si_mstr), 
                     output return_int)"}
   if return_int = 0 then do:
      {us/bbi/pxmsg.i &MSGNUM=725 &ERRORLEVEL=3}
      /* USER DOES noT HAVE ACCESS TO SITE */
      next-prompt site with frame a.
      undo,retry.
   end. /* if return_int = 0 then do: */
   
   find first code_mstr 
   where code_domain = global_domain
   and code_fldname  = "SP_SITE_CARL_QAD"
   and code_value    = site
   no-lock no-error.
   if not available code_mstr then do :                      
      {us/bbi/pxmsg.i &MSGNUM=7081 &ERRORLEVEL=3}
      /* SITE DOES NOT EXIST */
      next-prompt site with frame a.
      undo,retry.
   end.
      
   global_site = site.
   
   run GetParameter( input  "CARL_INTERFACE_STOCK",
                     input  (site +  "_export_inv_out"),
                     output output_dir).

   run get-dir-path( input  output_dir, 
                     output output_dir).                      

   if ext_file = "" then ext_file = "*.csv".

   if batchrun = no then do :
      update            
         output_dir
         ext_file             
      with frame a.
   end.

   /*Output directory control*/
   if output_dir = "" then do:
      if not batchrun then do:
         {us/bbi/pxmsg.i &MSGNUM=40 &ERRORLEVEL=3}
      end.
      undo mainloop, retry mainloop.
   end.

   run get-dir-path( input output_dir, 
                     output output_dir).
                     
   v_msg = "".
   run check_directory (input output_dir,
                        input "D*W",
                        output v_msg).
   if v_msg <> "" then do:
      if not batchrun then do:
         {us/bbi/pxmsg.i &MSGTEXT=v_msg &ERRORLEVEL=3}
      end.
      undo mainloop, retry mainloop.
   end.

   if ext_file = "" then do:
      if not batchrun then do:
         {us/bbi/pxmsg.i &MSGNUM=40 &ERRORLEVEL=3}
      end.
      undo mainloop, retry mainloop.
   end.

   bcdparm = ""                  .
   {us/mf/mfquoter.i site        }
   {us/mf/mfquoter.i output_dir  }
   {us/mf/mfquoter.i ext_file    }

   empty temp-table tt_inv_item.

   /* SELECT PRINTER  */
   {us/gp/gpselout.i &printType                 = "printer"
                     &printWidth                = 80
                     &pagedFlag                 = " "
                     &stream                    = " "
                     &appendToFile              = " "
                     &streamedOutputToTerminal  = " "
                     &withBatchOption           = "yes"
                     &displayStatementType      = 1
                     &withCancelMessage         = "yes"
                     &pageBottomMargin          = 6
                     &withEmail                 = "yes"
                     &withWinprint              = "yes"
                     &defineVariables           = "yes"}
   {us/bbi/mfphead.i}
   
   for each tr_hist 
   where tr_domain   = global_domain
   and tr_site       = site                                
   and (tr_type      = "CYC-RCNT" or tr_type = "CYC-CNT") 
   and tr_effdate    = today no-lock :  

      find first pt_mstr 
      where pt_dom      = global_domain                                 
      and pt_part       = tr_part                                                           
      and pt_prod_line  = "MAST"                                                       
      no-lock no-error.                                                               
      if not  avail pt_mstr then next.   

      find first usrw_wkfl 
      where usrw_domain = global_domain
      and usrw_key1     = "INVENTORY_EXPORT"
      and usrw_key2     = "INVENTORY_EXPORT" + string(tr_trnbr)
      no-lock no-error.
      if available usrw_wkfl then next.

      create tt_inv_item.
      assign
         tt_Date     = tr_effdate
         tt_Time     = tr_time
         tt_DateTime = string(day(tr_effdate), "99")
                     + "/"
                     + string (month (tr_effdate), "99")
                     + "/"
                     + string (year(tr_effdate) , "9999")
                     + " "
                     + string (tr_time , "HH:MM:SS")
         tt_TransNbr = tr_trnbr
         tt_Item     = tr_part
         tt_Site     = tr_site
         tt_Loc      = tr_loc
         tt_Qty      = replace_num_separator(string(tr_qty_req))  
         tt_UM       = tr_um        
      .    
   end. 

   for each tt_inv_item 
   break by tt_TransNbr :
      /*Disp report*/
      display
      tt_TransNbr 
      tt_Item   
      tt_Qty
      tt_UM
      tt_Site
      tt_Loc
      tt_DateTime
      with frame c.
      down 1 with frame c width 400.
      
      /*Create usrw_wkfl*/
      find first usrw_wkfl 
      where usrw_domain = global_domain
      and usrw_key1     = "INVENTORY_EXPORT"
      and usrw_key2     = "INVENTORY_EXPORT" + string(tt_TransNbr) 
      no-lock no-error.
      if not available usrw_wkfl then do:
         create usrw_wkfl.
         assign
            usrw_domain = global_domain                      
            usrw_key1   = "INVENTORY_EXPORT"                      
            usrw_key2   = "INVENTORY_EXPORT" + string(tt_TransNbr).
         release usrw_wkfl.
      end. 

      if first-of (tt_TransNbr) then do :

         filename = output_dir 
                  + "INV_"
                  + string(year (tt_Date), "9999")
                  + string(month (tt_Date), "99")
                  + string(day (tt_Date), "99")
                  + "_"
                  + entry(1, string (tt_Time, "HH:MM:SS") , ":")
                  + entry(2, string (tt_Time, "HH:MM:SS") , ":")
                  + entry(3, string (tt_Time, "HH:MM:SS") , ":")
                  + ext_file . 

         output stream file_csv to value(filename).
         put stream file_csv unformatted
            "externalSystem"      ";"
            "QAD_INV_IN"          ";"
            "exchangeInterface"   ";"
            "SAFE_INVENTORY_IN"   ";"
            ""                    ";" 
            ""                    ";"
            "timezone"            ";"
            "Europe/Paris"        ";" 
            ""                    ";"
            ""                    ";"
            ""                    ";"
            skip      
         .
      end.

      put stream file_csv unformatted
         "INVENTORY"          ";"     
         "INVENTORY"          ";"          
         tt_DateTime          ";"
         tt_TransNbr          ";"
         "CARLSOURCE"         ";"
         "CARLSOURCE"         ";"
         tt_Item              ";"  
         tt_Site + "-MAGPR"   ";"  
         tt_Loc               ";"  
         tt_Qty               ";"
         tt_UM                ";"
         skip
      . 

      if last-of(tt_TransNbr) then 
         output stream file_csv close .
   end. /*for each tt_item:*/

   {us/mf/mfrtrail.i}
end. /*mainloop*/
{/apps/qad/qad/customizations/mfg/default/src/us/zz/zzproasn.i}
