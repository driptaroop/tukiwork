/******************************************************************************************************************************************
 * AT&T Customizations
 ******************************************************************************************************************************************
 * HEADER  
 *  Modified by: Ganesh Venkataramani on 3/17/2003   
 *
 * PROGRAM NAME
 *  CUSTOM.pll
 * 
 * DESCRIPTION
 *  Customized the program to enforce change in the Suppliers form(APXVDMVD)
 *
 * USAGE
 *   To install       Transfer the CUSTOM.pll to $AUT_TOP/resource and execute the command
 											 f60gen module=CUSTOM.pll userid=apps/apps_patriots mnodule=library
 *   To execute       The application executes the CUSTOM.pll library when any given form is opened
 *
 * PARAMETERS
 * ==========
 * NAME              DESCRIPTION
.* ----------------- ------------------------------------------------------
 * N/A
 *
 * DEPENDENCIES
 *   None
 *
 * CALLED BY
 *   Automatically by Orale FORMS
 *
 * LAST UPDATE DATE   4/17/2003
 *   
 * HISTORY
 * =======
 * VERSION DATE        AUTHOR(S)            DESCRIPTION
 * ------- ----------- -------------------- -----------------------------------------------------------------------------------------------
 * 1.00    14-APR-2003 <Name author>        Original Version taken from $AU_TOP/resource
 * 2.00    17-APR-2003 Ganesh Venkataramani Made Chnages to Modify the Functionality of the Suppliers Form(APXVDMVD)
 * 3.00    11-FEB-2009 Jenny Sun            Add external application down load code 'F' and 'O' for item-propgation.
 * 4.00    22-OCT-2009 Nilesh Kothamasu     Created CUST_NHI_RPI_PKG and changes in zoom_available function and some changes
 *                                          in PO receips form is CUSTOM pkg etc., as a part of New Horizon project.
 * 5.0    09-NOV-2009  Salman Siddiqui      Added external application download code 'M' for item propagation.  
 * 6.0    09-SEP-2010   Salman Siddiqui     Adding CSUTOM.pll changes Evgueni and Amod for CR changes other than R2.119 and R2.120
 *																					the main package also contains some of the R2.119 changes for restriction of copy document.
 *																					Evgueni's changes are for R3.049 and have his initials as EMC.
 *																					Amod Joshi' changes are for Rice 217 and amends the code for 
 * 																					Cingular Enhancement CRP5: NOTIFY USER WHEN REQUISITION EXCEEDS PROJECT BUDGET
 *																					by Jayashree R. 
 * 																					The existing code for PO Requisition form is modified to incorporate 
 *																					the Rice 217 changes.  This will be marked as R217 in the code
 * 7.0   28-Sep-2010  Salman Siddiqui      commented out Amod Joshis's code and restored original code. This will be uncommented after NHR2 go live
 * 8.0   31-JAN-2011  Salman Siddiqui	     Uncomment Amod Joshi's code as per latest production code.
 * 9.0   02-MAY-2011  Ravi Balusu          Change for CQ WUP00494878
 * 10.0  05-03-2013   Lav Kumar            NHR8 Enhansment : To Make form Readonly based on Profile Value - "CUST_OM_ZOOM_FORM_READ_ONLY"
 * 11.0  19-APR-2013  Ankita Priya				 NHR8 Changes for PO, Requisitions and Item form
 * 12.0  06-SEP-2013	Ankita Priya				 NHR8 Red Hat Enhancements QC#2539
 * 13.0  02-SEP-2013  Pratik Terni				 Added changes for QC 3720 
 * 14.0  06-SEP-2013  Pratik Terni				 Added changes for QC 4002
 * 
 ******************************************************************************************************************************************/

package body custom is 
  -- 
  -- Customize this package to provide specific responses to events 
  -- within Oracle Applications forms. 
  -- 
  -- Do not change the specification of the CUSTOM package in any way. 
  -- You may, however, add additional packages to this library. 
  -- 
  -------------------------------------------------------------------- 
  /* Modified Date 12/18/07 Karthik PO_CONTROL PO_DOCON_CONTROL*/
  proj_pref_id  number;
  proj_pref_num	varchar2(30);
  v_login_id number := fnd_global.login_id;
  
  function zoom_available return boolean is 
  -- 
  -- This function allows you to specify if zooms exist for the current    
  -- context. If zooms are available for this block, then return TRUE; 
  -- else return FALSE.  
  -- 
  -- This routine is called on a per-block basis within every Applications  
  -- form from the WHEN-NEW-BLOCK-INSTANCE trigger. Therefore, any code 
  -- that will enable Zoom must test the current form and block from  
  -- which the call is being made.  
  -- 
  -- By default this routine must return FALSE. 
  -- 
  /* Sample code: 
    form_name  varchar2(30) := name_in('system.current_form'); 
    block_name varchar2(30) := name_in('system.cursor_block');  
  begin 
    if (form_name = 'DEMXXEOR' and block_name = 'ORDERS') then 
      return TRUE; 
    else 
      return FALSE; 
    end if; 
  end zoom_available; 
  */ 
  -- 
  -- Real code starts here 
  -- 
    form_name  varchar2(30) := NAME_IN('system.current_form'); 
    block_name varchar2(30) := NAME_IN('system.cursor_block');  
  --
  begin 
  	
  	
   -- Cingular Enhancement CRP5: FMG.328Project Transfers - Start
   -- Vinay - 10/23/2003 
    if (form_name = 'PAXTRAPE' and block_name = 'EXP_ITEMS') then
      return TRUE; 
    elsif(form_name = 'OEXOEORD' and block_name = 'ORDER') then
      return TRUE;
    elsif (form_name = 'POXRQVRQ'  and block_name = 'REQ_HEADERS_FOLDER') then --req view form
    	return TRUE; 
    elsif (form_name = 'POXPOVPO'  and block_name = 'HEADERS_FOLDER') 
    	AND	NVL(name_in('HEADERS_FOLDER.ATTRIBUTE5'),'WIRELESS') != 'WIRELINE-ESS' --Added by kavya for ESS
    	then --po view form
    	return TRUE;
	  elsif (form_name = 'POXBWVRP'  and block_name = 'REQ_LINES') then
    	return TRUE;  
    	/*----------NHI--------------*/
	  elsif (form_name = 'POXRQERQ'  and block_name = 'PO_REQ_HDR') and
	  	    upper(fnd_profile.VALUE('CUST_NH_RESP_IDENTIFIER')) = 'WIRELINE' then  ---req entry from
	  	    --fnd_message.DEBUG('Zoom avail function check.');
    	return TRUE; 
	  elsif (form_name = 'POXPOEPO'  and block_name = 'PO_HEADERS') and 
	  	  upper(fnd_profile.VALUE('CUST_NH_RESP_IDENTIFIER')) = 'WIRELINE' and
	  	  name_in('PO_HEADERS.TYPE_LOOKUP_CODE') <> 'BLANKET'  then  ---po entry form
    	return TRUE;
    	
    	/*NHR8 AP799M */
	  elsif (form_name = 'CWPOXPOVPO'  and block_name = 'LINES_FOLDER')  
	  	AND NVL(upper(fnd_profile.VALUE('CUST_NH_RESP_IDENTIFIER')),'WIRELESS') != 'WIRELINE-ESS'    --Added by kavya for ESS
	  	then
	  	return TRUE;
	  	/*NHR8 AP799M */
 
     	/* NHR4 Kavya.D.Bondalapati*/	
	    elsif (form_name IN( 'POXPOEPO','CWPOXPOEPO')  and block_name = 'PO_HEADERS')
	    --	AND	NVL(name_in('PO_HEADERS.ATTRIBUTE5'),'WIRELESS')  != 'WIRELINE-ESS' --Added by kavya for ESS
	   AND NVL(upper(fnd_profile.VALUE('CUST_NH_RESP_IDENTIFIER')),'WIRELESS') != 'WIRELINE-ESS'    --Added by kavya for ESS
	    	then  ---po entry form   --Added VJ 'CWPOXPOEPO'  	
    	return TRUE;
    	/* NHR4	Kavya.D.Bondalapati*/   	
    		
      /* NHI Mareddy*/	
	    elsif (form_name IN( 'POXPOEPO','CWPOXPOEPO')  and block_name = 'PO_LINES')
	    --	AND	NVL(name_in('PO_HEADERS.ATTRIBUTE5'),'WIRELESS')  != 'WIRELINE-ESS' --Added by kavya for ESS
	    AND NVL(upper(fnd_profile.VALUE('CUST_NH_RESP_IDENTIFIER')),'WIRELESS') != 'WIRELINE-ESS'    --Added by kavya for ESS
	    	then  ---po entry form   --Added VJ 'CWPOXPOEPO'  	
    	return TRUE;
    	/* NHI Mareddy*/		/* NHI PR6570 added D_SUM_FOLDER block to the zoom*/
	    elsif (form_name = 'APXINWKB'  
	    	AND	NVL(NAME_IN('INV_SUM_FOLDER.ATTRIBUTE12'),'WIRELESS') <> 'WIRELINE-ESS'  --Added by kavya for ESS
	    	and (block_name = 'INV_SUM_FOLDER' 
	    	OR block_name = 'D_SUM_FOLDER')) 
	   
    		--and upper(fnd_profile.VALUE('CUST_NH_RESP_IDENTIFIER')) = 'WIRELINE'    ---commented on 19-MAY-2011 rb819s for M2CFAS-II
	  	   then --invoice form
    	return TRUE;  	    	
     	/*----------NHI--------------*/	

      /*----------EMC-start added on 9/9/2010---------*/
      elsif (form_name = 'POXPOEPO'  and block_name = 'PO_HEADERS') /*and 
            upper(fnd_profile.VALUE('CUST_NH_RESP_IDENTIFIER')) = 'WIRELINE'*/ 
           -- AND	NVL(name_in('PO_HEADERS.ATTRIBUTE5'),'WIRELESS') != 'WIRELINE-ESS' --Added by kavya for ESS
           AND NVL(upper(fnd_profile.VALUE('CUST_NH_RESP_IDENTIFIER')),'WIRELESS') != 'WIRELINE-ESS' then   --Added by kavya for ESS
            
          return TRUE;
       /*----------EMC-end-----------*/    
 		
    else 
      return FALSE; 
    end if; 
   -- Vinay -- FMG.328 - CW Project Transfers - 10/23/2003 End
  end zoom_available; 
 
  -------------------------------------------------------------------- 
 
  function style(event_name varchar2) return integer is 
  -- 
  -- This function allows you to determine the execution style for some 
  -- product-specific events. You can choose to have your code execute 
  -- before, after, or in place of the code provided in Oracle  
  -- Applications. See the Applications Technical Reference manuals for a 
  -- list of events that are available through this interface. 
  -- 
  -- Any event that returns a style other than custom.standard must have 
  -- corresponding code in custom.event which will be executed at the  
  -- time specified.  
  --   
  -- The following package variables should be used as return values: 
  -- 
  --    custom.before 
  --    custom.after 
  --    custom.override 
  --    custom.standard 
  -- 
  -- By default this routine must return custom.standard 
  -- 
  -- Oracle Corporation reserves the right to change the events  
  -- available through this interface at any time. 
  -- 
  /* Sample code: 
  begin 
    if event_name = 'OE_LINES_PRICING' then 
      return custom.override; 
    else 
      return custom.standard; 
    end if; 
  end style; 
  */ 
  -- 
  -- Real code starts here 
  -- 
  begin 
    return custom.standard; 
  end style; 
 
  -------------------------------------------------------------------- 
 
  procedure event(event_name varchar2) is 
  
  -- 
  -- This procedure allows you to execute your code at specific events 
  -- including: 
  -- 
  --    ZOOM 
  --    WHEN-NEW-FORM-INSTANCE 
  --    WHEN-NEW-BLOCK-INSTANCE 
  --    WHEN-NEW-RECORD-INSTANCE 
  --    WHEN-NEW-ITEM-INSTANCE 
  --    WHEN-VALIDATE-RECORD 
  -- 
  -- Additionally, product-specific events will be passed via this 
  -- interface (see the Applications Technical Reference manuals for  
  -- a list of events that are available).  
  -- 
  -- By default this routine must perform 'null;'. 
  -- 
  -- Oracle Corporation reserves the right to change the events  
  -- available through this interface at any time. 
  -- 
  /* Sample code:
 
    form_name      varchar2(30) := name_in('system.current_form'); 
    block_name     varchar2(30) := name_in('system.cursor_block');  
    param_to_pass1 varchar2(255); 
    param_to_pass2 varchar2(255); 
  begin 
    -- Zoom event opens a new session of a form and 
    -- passes parameter values to the new session.  The parameters
    -- already exist in the form being opened.
    if (event_name = 'ZOOM') then   
      if (form_name = 'DEMXXEOR' and block_name = 'ORDERS') then 
        param_to_pass1 := name_in('ORDERS.order_id'); 
        param_to_pass2 := name_in('ORDERS.customer_name'); 
        fnd_function.execute(FUNCTION_NAME=>'DEM_DEMXXEOR',  
                             OPEN_FLAG=>'Y',  
                             SESSION_FLAG=>'Y',  
                             OTHER_PARAMS=>'ORDER_ID="'||param_to_pass1|| 
                               '" CUSTOMER_NAME="'||param_to_pass2||'"'); 
		-- all the extra single and double quotes account for 
		-- any spaces that might be in the passed values 
      end if; 

    -- This is an example of a product-specific event.  Note that as
    -- of Prod 15, this event doesn't exist.
    elsif (event_name = 'OE_LINES_PRICING') then 
      get_custom_pricing('ORDERS.item_id', 'ORDERS.price'); 

    -- This is an example of enforcing a company-specific business
    -- rule, in this case, that all vendor names must be uppercase.
    elsif (event_name = 'WHEN-VALIDATE-RECORD') then
      if (form_name = 'APXVENDR') then
        if (block_name = 'VENDOR') then
          copy(upper(name_in('VENDOR.NAME')), 'VENDOR.NAME');       
        end if;
      end if;
    else 
      null; 
    end if; 
  end event; 
  */ 
  -- 
  -- Real code starts here 
  -- 
  form_name							varchar2(60) := name_in('system.current_form');
  block_name						varchar2(60) := name_in('system.cursor_block');
  tp_main								TAB_PAGE;
  tp_sites							TAB_PAGE;
  v_add_profile_value		varchar2(80);
  v_bank_profile_value	varchar2(80);
  v_employee_type 			varchar2(80);
  v_account_use					varchar2(80);
  
/* CRP3 variables start here */
  
  item_name						  varchar2(90) := name_in('system.cursor_item');
  
  /*Pranay created 2 separate RG for APXINWKB and POs on 06/24/06*/
  ccwpa_iet_rg_id1       RECORDGROUP;
  ccwpa_iet_rg_error1    NUMBER;
  ccwpa_iet_rg_count1    NUMBER;
  
	ccwpa_iet_rg_id2       RECORDGROUP;
	ccwpa_iet_rg_error2    NUMBER;
	ccwpa_iet_rg_count2    NUMBER;
	
	pg_distro_id					NUMBER;
	pg_exp_type						VARCHAR2(30);
  /*End Pranay mods on 06/24/06*/
  
  ccwpa_iet_expenditure_type  VARCHAR2(30) := NULL;
  ccwpa_iet_item_id           NUMBER       := NULL;
  ccwpa_iet_item_number       VARCHAR2(81) := NULL;
  ccwpa_iet_item_category     VARCHAR2(30) := NULL;
  --added by vineet 11/11/04
  ccwpa_iet_org_id NUMBER := NULL;
  ccwpa_iet_proj varchar2(30) :=NULL;
  
  -- end vineets addition
  
  --added by Pranay 05/08/06 for using exp_type from item master
  ccwpa_iet_master_rg_id1 		RECORDGROUP;
  ccwpa_iet_master_rg_error1 NUMBER;
  ccwpa_iet_master_rg_count1 NUMBER;
  ccwpa_iet_master_org_id1 	NUMBER := NULL;
  
  ccwpa_iet_master_rg_id2 		RECORDGROUP;
  ccwpa_iet_master_rg_error2 NUMBER;
  ccwpa_iet_master_rg_count2 NUMBER;
  ccwpa_iet_master_org_id2 	NUMBER := NULL;
  --end Pranay additions
    
/* CRP3 variables end here */

/* CRP5 variables for FMG.318REV "Reverse Capitalization" start here */
  ccwpa_rev_cap_date_id       RECORDGROUP;
  ccwpa_rev_cap_date_error    NUMBER;

  ccwpa_rev_cap_id            RECORDGROUP;
  ccwpa_rev_cap_error         NUMBER;
  ccwpa_rev_cap_count         NUMBER;
  
  ccwpa_capitalized_date      VARCHAR2(50) := NULL;
  ccwpa_reversal_date         VARCHAR2(50) := NULL;  
/* CRP5 variables for FMG.318REV "Reverse Capitalization" end here */

/***RGC  */

v_pref_project_id_global        NUMBER;	         --Added for test rgc
--v_pref_project_id1       NUMBER;	         --Added for test rgc
v_pref_project     VARCHAR2(30) := NULL;
v_pref_proj_id2 number; ---temp
	           v_pref_proj   varchar2(100);  
            v_pref_proj_id  number;
             v_pref_loc    varchar2(50); 


/***RGC  */

-- Variables for OEXOEORD  Karthik
l_resp_id number := fnd_profile.value('RESP_ID'); 
l_user_id number := FND_PROFILE.VALUE('USER_ID'); 
l_responsibility_name varchar2(100); 
lfound varchar2(1) := 'N';
  rg_name1  VARCHAR2(40); 
  rg_id1    RecordGroup; 
   rg_name2  VARCHAR2(40); 
  rg_id2    RecordGroup;  
   rg_name3  VARCHAR2(40); 
  rg_id3   RecordGroup; 
   gc_id    GroupColumn; 
  errcode  NUMBER; 
  v_formpath VARCHAR2(100);
  v_logappl VARCHAR2(100) := FND_PROFILE.VALUE('LOG_FORMAPPL');     
    v_order_category      varchar2(60) ;
  v_booked_flag         oe_order_lines_all.booked_flag%TYPE;
  CURSOR c_order_category IS
          select meaning, lookup_code 
               from oe_lookups 
              where lookup_type = 'ORDER_CATEGORY' 
                and lookup_code='ORDER'
                and lookup_code=v_ORDER_CATEGORY;
c_order_Category_rec c_order_category%ROWTYPE;   
v_ptype  number;
v_value  varchar2(40);  
basetable  VARCHAR2(80);           
-- Variables End for OEXOEORD
param_to_pass1 varchar2(90);  
v_count number;
v_pds varchar2(10); 

l_so_header_id OE_ORDER_HEADERS_ALL.header_id%type; -- By ak667t for R2.179 08-10-2010
v_context      OE_TRANSACTION_TYPES_ALL.context%type; -- By ak667t for R2.179 08-19-2010
-- Variable declaration for Rice 34 - R78 - Added by Amod Joshi on 24-Jun-2010
v_button_selection INTEGER;
v_invoice_id       NUMBER;
v_invoice_num			 VARCHAR2(50);
v_invoice_amount	 NUMBER;
v_hold_status      VARCHAR(1);
v_item_id					 NUMBER;
v_vendor_id				 NUMBER;
v_vendor_num			 VARCHAR2(100);
v_vendor_site_code VARCHAR2(100);
v_vendor_site_id   NUMBER;
v_po_number				 VARCHAR2(50); 
v_hold_description VARCHAR2(100);
     
BEGIN

IF     event_name = 'ZOOM'
AND    FORM_NAME  = 'OEXOEORD'    
AND    BLOCK_NAME = 'ORDER'
THEN
  /* 
   Update dated '08-19-2010' for NHR2.179 - Custom OM Zoom Form - ak667t   
   Custom OM zoom form will be called only for wireline responsibility and wireline order type. 
   If these conditions are not satisfied, per original code, CW_OM_CC_ZOOM procedure will be called.  
  */

/*******************************NHR8 Extentions Start ********************************/
/*Added CUST_OM_ZOOM_FORM_READ_ONLY option condition, if value is 'Y' for the Profile Option then Form will open
in Query only mode, Else Normal form with Insert update and Delete options*/
   IF UPPER(fnd_profile.VALUE('CUST_OM_ZOOM_FORM_READ_ONLY')) = 'Y' 
   	or UPPER(fnd_profile.VALUE('CUST_OM_ZOOM_FORM_READ_ONLY')) = 'YES'
        THEN
         l_so_header_id := NVL(TO_NUMBER(NAME_IN('ORDER.HEADER_ID')),0);
         
               SELECT  NVL(OTTA.context,'xyz') 
                INTO   v_context
                FROM   OE_ORDER_HEADERS_ALL OOHA, OE_TRANSACTION_TYPES_ALL OTTA 
                WHERE  OOHA.order_type_id       = OTTA.transaction_type_id  
                AND    OOHA.header_id           = l_so_header_id;

               IF UPPER(v_context) = 'WIRELINE' THEN
                  FND_FUNCTION.EXECUTE(FUNCTION_NAME => 'CUST_OM_ACCT_ZOOM',
                                       OPEN_FLAG     => 'Y',
                                       SESSION_FLAG  => 'Y',
                                       OTHER_PARAMS  => 'QUERY_ONLY="YES" P_SOURCE_ID='||l_so_header_id);   --NHR8 (Added QUERY_ONLY="YES")
               ELSE
                  fnd_message.debug('It is NOT a Wireline Order');
                  CW_OM_CC_ZOOM;
               END IF;

/*******************************NHR8 Extentions End ********************************/
        ELSIF UPPER(fnd_profile.VALUE('CUST_NH_RESP_IDENTIFIER')) = 'WIRELINE' THEN

               l_so_header_id := NVL(TO_NUMBER(NAME_IN('ORDER.HEADER_ID')),0);
               
               SELECT  NVL(OTTA.context,'xyz') 
                INTO   v_context
                FROM   OE_ORDER_HEADERS_ALL OOHA, OE_TRANSACTION_TYPES_ALL OTTA 
                WHERE  OOHA.order_type_id       = OTTA.transaction_type_id  
                AND    OOHA.header_id           = l_so_header_id;

               IF UPPER(v_context) = 'WIRELINE' THEN
                  FND_FUNCTION.EXECUTE(FUNCTION_NAME => 'CUST_OM_ACCT_ZOOM',
                                       OPEN_FLAG     => 'Y',
                                       SESSION_FLAG  => 'Y',
                                       OTHER_PARAMS  => 'P_SOURCE_ID='||l_so_header_id);
               ELSE
                  fnd_message.debug('It is NOT a Wireline Order');
                  CW_OM_CC_ZOOM;
               END IF;

        ELSE
           fnd_message.debug('It is NOT a Wireline Responsibility');
           CW_OM_CC_ZOOM;
        END IF;   
   
   
END IF;

/* NHR3 CR Nilesh  4/2/10 START*/
If 	event_name = 'WHEN-NEW-FORM-INSTANCE'  and
   	FORM_NAME	 = 'POXPOEPO' and	
	 name_in ('PARAMETER.poxpoepo_calling_form') = 'POXBWVRP' and
	 UPPER(fnd_profile.VALUE('CUST_NH_RESP_IDENTIFIER')) != 'WIRELINE-ESS' and --Added by kavya for ESS
	 name_in ('PARAMETER.po_header_id') is not null then
	 
	--- fnd_message.debug('Calling freight logic');
	 CUST_PO_FREIGHT_UPDATE(name_in ('PARAMETER.po_header_id'));
	
end if;


--Added for NHR8 Red Hat enhancement QC#2539 start
Declare
	v_lkp_value VARCHAR2(50);
	v_req_id NUMBER;
	v_req_line_id NUMBER;
	v_doc_type VARCHAR2(200); --:=NAME_IN ('PO_REQ_HDR.DOCUMENT_TYPE_DISPLAY');

BEGIN
--fnd_message.debug('Document Type Display1'||' '||v_doc_type); 
IF     event_name = 'WHEN-NEW-RECORD-INSTANCE'
  AND FORM_NAME = 'POXRQERQ'
  AND BLOCK_NAME = 'PO_REQ_HDR'
  AND NAME_IN ('SYSTEM.RECORD_STATUS') IN ('NEW', 'INSERT')
  --AND NAME_IN ('PO_REQ_HDR.DOCUMENT_TYPE_DISPLAY') IN ('Internal Requisition')
 THEN
 --v_doc_type:=NAME_IN ('PO_REQ_HDR.DOCUMENT_TYPE_DISPLAY');
 
 --fnd_message.debug('Document Type Display2'||' '||v_doc_type); 
 
   IF UPPER (fnd_profile.VALUE ('CUST_DSL_MANUAL_IR')) IN ('Y', 'Yes') THEN
   --	fnd_message.debug('profile value for ATT DSL Transfers:'||' '||upper(fnd_profile.VALUE('CUST_DSL_MANUAL_IR')));
   	--fnd_message.debug('Document Type Display3'||' '||v_doc_type); 
   	
   	COPY ('Internal Requisition', 'PO_REQ_HDR.DOCUMENT_TYPE_DISPLAY');
   	 /*IF v_doc_type = ('Internal Requisition') THEN  
   	 	fnd_message.debug('Document Type Display4'||' '||v_doc_type); */
   	 	
   	     SELECT tag 
           INTO v_lkp_value
           FROM fnd_lookup_values
          WHERE lookup_type LIKE 'CUST_IR_SUPPLIER_DSL'  
            AND lookup_Code = 'IR'
            AND enabled_flag = 'Y'
            AND NVL (TRUNC (end_date_active), TRUNC (SYSDATE)) >=TRUNC (SYSDATE);
        -- fnd_message.debug('v_lkp_value'||v_lkp_value);
         
         COPY (v_lkp_value, 'PO_REQ_HDR.INTERFACE_SOURCE_CODE');
         
         --APP_ITEM_PROPERTY2.SET_PROPERTY( 'LINES.DEST_SUBINVENTORY',REQUIRED, PROPERTY_TRUE);
   --	 END IF;
   END IF;
END IF;


   IF event_name = 'WHEN-NEW-RECORD-INSTANCE'
     AND FORM_NAME = 'POXRQERQ'
     AND BLOCK_NAME = 'LINES'
     AND NAME_IN ('SYSTEM.RECORD_STATUS') IN ('INSERT', 'NEW')
     AND NAME_IN ('LINES.ITEM_CATEGORY') IS NULL
   THEN
     IF UPPER (fnd_profile.VALUE ('CUST_DSL_MANUAL_IR')) IN ('Y', 'Yes') THEN
       --fnd_message.debug('Testing for red_hat');
       
       SET_ITEM_PROPERTY('LINES.DEST_SUBINVENTORY',REQUIRED,PROPERTY_TRUE);
       --SET_ITEM_INSTANCE_PROPERTY ('LINES.DEST_SUBINVENTORY',CURRENT_RECORD,INSERT_ALLOWED,PROPERTY_TRUE);
       --SET_ITEM_INSTANCE_PROPERTY ('LINES.DEST_SUBINVENTORY',CURRENT_RECORD,UPDATE_ALLOWED,PROPERTY_TRUE);
                        
       COPY(NULL,'LINES.DEST_SUBINVENTORY');
     ELSE 
     	null;
     END IF;
   END IF;
   

 IF     event_name = 'WHEN-NEW-RECORD-INSTANCE'
   AND                               ---'WHEN-NEW-RECORD-INSTANCE'
       FORM_NAME = 'POXRQERQ'
   AND BLOCK_NAME = 'PO_APPROVE'
 THEN
   --fnd_message.DEBUG('WNRI: Block-PO_APPROVE.');
   v_req_id := NAME_IN ('PO_REQ_HDR.REQUISITION_HEADER_ID');
   v_req_line_id := NAME_IN ('LINES.REQUISITION_LINE_ID');
  BEGIN
    IF UPPER (fnd_profile.VALUE ('CUST_DSL_MANUAL_IR')) IN ('Y', 'Yes') THEN
   	 --IF v_doc_type IN ('Internal Requisition') THEN 
   	 	-- fnd_message.debug('TEST RED hat');
   	 	 --SET_ITEM_PROPERTY( 'LINES.DEST_SUBINVENTORY',REQUIRED, PROPERTY_TRUE);
   	 	 IF NAME_IN('LINES.DEST_SUBINVENTORY') IS NULL
        THEN
          fnd_message.debug('SUBINVENTORY CODE needs to be entered for the IR to be approved.');
          --GO_ITEM ('LINES.DEST_SUBINVENTORY');
          RAISE form_trigger_failure;
          
   	 	 END IF;
   	  --END IF;
     END IF;
    END;
   END IF;

END;
--Added for NHR8 Red Hat enhancement QC#2539 ends

/* NHR3 CR Nilesh  4/2/10 END */

/* NHI */ 
 CUST_NHI_RPI_PKG.cust_nhi_rpi(event_name);
/* NHI */

--R2.119 Changes    -- moved to bottom of this code
--cust_nhr2_119 (event_name );
--R2.119 changes

/* START----------By Nilesh Kothamasu.  -- 4/7/09 */

declare
	oldmsg VARCHAR2(20) :=name_in('system.Message_Level');  -- Old Message Level Setting
  v_dummy number;
  v_item varchar2(2000);
  v_channel varchar2(2000);
  v_rank varchar2(2000);
  v_sdate date;
  v_edate date;
  v_dummy_date date;
  v_active varchar2(2000);
  v_range varchar2(2000);
  v_status number;
  v_parent_occurence  number;
  v_child_occurence number;
  v_error_msg1 varchar2(2000);
  v_error_msg2 varchar2(2000);
  v_error_msg varchar2(2000);
BEGIN
	 	 
	  if  form_name  = 'QLTRSINF' and
		    block_name = 'Q_RES'  and
	     event_name = 'WHEN-FORM-NAVIGATE' and
		 	 name_in('Q_RES_HEAD.NAME') in ('RL1_REPLACEMENT_IDENTIFIER','RL31_REPL_PHONE_TO_ACCESSORIES') and
			  name_in('system.record_status')  in ('CHANGED')  then

	      ccwq_sub_matrix.status_upd(name_in('Q_RES_HEAD.NAME'), name_in('Q_RES.OCCURRENCE'));
	     
	     If  name_in('Q_RES_HEAD.NAME') in ('RL1_REPLACEMENT_IDENTIFIER') then
	      
	       ccwq_sub_matrix.date_range_check(name_in('Q_RES.OCCURRENCE'),v_error_msg1);
	       
	       ccwq_sub_matrix.chan_rank_item_check(name_in('Q_RES.OCCURRENCE'),v_error_msg2);
	       
	        v_error_msg := v_error_msg1||v_error_msg2;
	       
	       If v_error_msg is not null then
	       	 	COPY('N','Q_RES.DISPLAY1');
	       	 	v_error_msg := v_error_msg||'Inactivating identifier';
	       	 	select substr(v_error_msg,1,140)
	       	 	  into v_error_msg
	       	 	  from dual;
	       	 	COPY(v_error_msg,'Q_RES.DISPLAY3');
	       	 	fnd_message.debug('Inactivating the identifier due to duplicate child records. All changes are being saved');
	       	 	commit;
	       else
	       	   If name_in('Q_RES.DISPLAY3') is not null then
	       	   	 COPY(null,'Q_RES.DISPLAY3');
	       	   	 fnd_message.debug('No duplicate child records. Clearing the error message and saving all the changes. Please activate the identifier if necessary');
	       	   	 commit;
	       	   end if;
	       end if;
	     end if;
	     
	     
	     If  name_in('Q_RES_HEAD.NAME') in ('RL31_REPL_PHONE_TO_ACCESSORIES') then
	        
	       ccwq_sub_matrix.item_check(name_in('Q_RES.OCCURRENCE'),v_error_msg);
	       
	       If v_error_msg is not null then
	       	 	COPY('N','Q_RES.DISPLAY1');
	       	 	v_error_msg := v_error_msg||'Inactivating identifier.';
	       	 	
	       	 	COPY(v_error_msg,'Q_RES.DISPLAY2');
	       	 	fnd_message.debug('Inactivating the identifier due to duplicate child records. All changes are being saved');
	       	 	commit;
	       else
	       	   If name_in('Q_RES.DISPLAY2') is not null then
	       	   	 COPY(null,'Q_RES.DISPLAY2');
	       	   	 fnd_message.debug('No duplicate child records. Clearing the error message and saving all the changes. Please activate the identifier if necessary');
	       	   	 commit;
	       	   end if;
	       end if;
	     end if;
	  end if;
	  
	          /*--------EMC-start added on 9/9/10-----------*/    
DECLARE
   lc_po_header_id   VARCHAR2 (255);
BEGIN
   IF form_name = 'POXPOEPO'
  AND block_name = 'PO_HEADERS'
  AND cwpo_nh_acct_gen_pkg.check_resp = 'WIRELINE'
   THEN
      IF event_name = 'WHEN-NEW-FORM-INSTANCE'
      THEN
         app_special2.instantiate('SPECIAL22', 'View Transmission Details', NULL, TRUE, NULL);
      ELSIF (event_name = 'SPECIAL22')
      THEN
         lc_po_header_id   := NAME_IN ('PO_HEADERS.po_header_id');
         IF lc_po_header_id IS NULL
         THEN
            fnd_message.set_string ('Please select the Purchase Order.');
            fnd_message.show;
            RAISE form_trigger_failure;
         ELSE
            fnd_function.execute (
               function_name   => 'VIEW_TRANSMISSION_DETAILS',
               open_flag       => 'Y',
               session_flag    => 'N',
               other_params    => 'PO_HEADER_ID="' || lc_po_header_id || '"'
            );
         END IF;         
      END IF;
   /*ELSE
      NULL; 
      SET_MENU_ITEM_PROPERTY ('SPECIAL.SPECIAL20', ENABLED, PROPERTY_FALSE );*/
   END IF;
END;   
    /*--------EMC-end-------------*/

	  
    
    
    if  form_name  = 'QLTRSMDF' and
		    block_name = 'Q_RES'  and
	     event_name = 'WHEN-FORM-NAVIGATE' and
		 	 name_in('Q_RES_HEAD.NAME') in ('RL1_REPLACEMENT_IDENTIFIER','RL31_REPL_PHONE_TO_ACCESSORIES') then
			 -- name_in('system.record_status')  in ('CHANGED')  then
			
			 ccwq_sub_matrix.status_upd(name_in('Q_RES_HEAD.NAME'), null);
	     
	     If  name_in('Q_RES_HEAD.NAME') in ('RL1_REPLACEMENT_IDENTIFIER') then
	        
	       ccwq_sub_matrix.date_range_check(name_in('Q_RES.OCCURRENCE'),v_error_msg1);
	       
	       ccwq_sub_matrix.chan_rank_item_check(name_in('Q_RES.OCCURRENCE'),v_error_msg2);
	       
	        v_error_msg := v_error_msg1||v_error_msg2;
	       
	       If v_error_msg is not null then
	       	 	COPY('N','Q_RES.DISPLAY1');
	       	 	v_error_msg := v_error_msg||'Inactivating identifier';
	       	 	select substr(v_error_msg,1,140)
	       	 	  into v_error_msg
	       	 	  from dual;
	       	 	COPY(v_error_msg,'Q_RES.DISPLAY3');
	       	 	fnd_message.debug('Inactivating the identifier due to duplicate child records. All changes are being saved');
	       	 	commit;
	       else
	       	   If name_in('Q_RES.DISPLAY3') is not null then
	       	   	 COPY(null,'Q_RES.DISPLAY3');
	       	   	 fnd_message.debug('No duplicate child records. Clearing the error message and saving all the changes. Please activate the identifier if necessary');
	       	   	 commit;
	       	   end if;
	       end if;
	     end if;
	     
	     
	    If  name_in('Q_RES_HEAD.NAME') in ('RL31_REPL_PHONE_TO_ACCESSORIES') then
	        
	       ccwq_sub_matrix.item_check(name_in('Q_RES.OCCURRENCE'),v_error_msg);
	      
	       If v_error_msg is not null then
	       	 	COPY('N','Q_RES.DISPLAY1');
	       	 	v_error_msg := v_error_msg||'Inactivating identifier.';
	       	 	
	       	 	COPY(v_error_msg,'Q_RES.DISPLAY2');
	       	 	fnd_message.debug('Inactivating the identifier due to duplicate child records. All changes are being saved');
	       	 	commit;
	       else
	       	   If name_in('Q_RES.DISPLAY2') is not null then
	       	   	 COPY(null,'Q_RES.DISPLAY2');
	       	   	 fnd_message.debug('No duplicate child records. Clearing the error message and saving all the changes. Please activate the identifier if necessary');
	       	   	 commit;
	       	   end if;
	       end if;
	     end if;
	     
	   end if;


    
	 	 
	 if form_name  = 'QLTRSMDF' then        
	   If  block_name = 'Q_RES'   then
	 	    
	 	    If ( (event_name = 'WHEN-NEW-RECORD-INSTANCE'  and
	 	    	     name_in('Q_RES_HEAD.NAME') in ('RL1_REPLACEMENT_IDENTIFIER','RL_ITEMS','RL23_DEDUCTIBLE_AMOUNTS','RL31_REPL_PHONE_TO_ACCESSORIES'))
	 	    	     OR 
	 	    	    (event_name = 'WHEN-NEW-ITEM-INSTANCE' and 
	 	    	     name_in('Q_RES_HEAD.NAME') in ('RL23_DEDUCTIBLE_AMOUNTS','RL21_REPLACEMENT_PHONES','RL41_ACS','RL1_REPLACEMENT_IDENTIFIER','RL31_REPL_PHONE_TO_ACCESSORIES'))
	 	    	   )
	 	    	  and
	 	    	 name_in('system.form_status')  in ('CHANGED') 
	 	    then
	 	    
	 	       copy('20','SYSTEM.MESSAGE_LEVEL');
	 	    	
	 	   If name_in('Q_RES_HEAD.NAME') = 'RL1_REPLACEMENT_IDENTIFIER' then
	 	   	 If event_name = 'WHEN-NEW-RECORD-INSTANCE'            then
	 	    		v_item := name_in('Q_RES.DISPLAY4');
	 	    		 POST; 
	 	     If v_item is not null then	
	 	    	
	 	              select count(*) 
                    into v_dummy
                    from QA_RESULTS_V qrp
                  where qrp.name = 'RL1_REPLACEMENT_IDENTIFIER'
                   and qrp.character4 = v_item;
	 	    	  
	 	 	      If v_dummy > 1 then
	 	    	  	fnd_message.debug('This item already exists. Please choose an item from the list of values');
	 	    	  --	COPY(NULL,'Q_RES.DISPLAY2');
	 	    	  --	go_item('Q_RES.DISPLAY2');
	 	    	    delete_record;
	 	    	   	raise form_trigger_failure;
	 	    	  end if;
	 	     end if;
	 	     
	 	    /* elsif event_name = 'WHEN-NEW-ITEM-INSTANCE' then
	 	     	  	v_item := name_in('Q_RES.DISPLAY2');
	 	     	  	v_active := name_in('Q_RES.DISPLAY1');
	 	     	  If v_item is not null and v_active is not null then
	 	     	  	 POST;
	 	     	  end if;
	 	     	*/  
	 	   	 end if;
	 	   	  
-----------------------**********************************************	 	    
	 	    elsif name_in('Q_RES_HEAD.NAME') = 'RL_ITEMS' then
	 	    	   v_item := name_in('Q_RES.DISPLAY1');
	 	    	   
	 	    	   POST;
	 	    
	 	    	If v_item is not null then
	 	    		
                 select count(*) 
                   into v_dummy
	 	    	   from QA_RESULTS_V qrp
	 	    	  where qrp.name = 'RL_ITEMS'
              and qrp.character1 = v_item;
	 	    	
	 	    	  If v_dummy > 1 then
	 	    	  	fnd_message.debug('This item already exists. Please choose an item from the list of values');
              delete_record;
	 	    	  	raise form_trigger_failure;
	 	    	  end if;
	 	      end if;
	 	
-----------------------**********************************************	 
  	  elsif name_in('Q_RES_HEAD.NAME') = 'RL31_REPL_PHONE_TO_ACCESSORIES' then
	 	     If event_name = 'WHEN-NEW-RECORD-INSTANCE'            then	 
	 	    	   v_item := name_in('Q_RES.DISPLAY3');
	 	    	   POST;
	 	    	 If v_item is not null then
	 	    		
                 select count(*) 
                   into v_dummy
	 	    	   from QA_RESULTS_V qrp
	 	    	  where qrp.name = 'RL31_REPL_PHONE_TO_ACCESSORIES'
              and qrp.character3 = v_item;
	 	    	
	 	    	 If v_dummy > 1 then
	 	    	  	fnd_message.debug('This item already exists. Please choose an item from the list of values');
              delete_record;
	 	    	  	raise form_trigger_failure;
	 	    	  end if;
	 	    	 end if;
	 	    	/* elsif event_name = 'WHEN-NEW-ITEM-INSTANCE'    then	 
	 	    	 	 v_item := name_in('Q_RES.DISPLAY1');
	 	    	 	 
	 	    	 	 if v_item is not null then
	 	    	 	 	  POST;
	 	    	 	 end if;
	 	    	 */	 
	 	    	 end if;
	 	    	 	 	    	 	
	 	    

	 	  end if;	 ---q_res_head.name
	 	     	 copy(oldmsg,'SYSTEM.MESSAGE_LEVEL'); 
	 	    end if;--when new rec instance
	   end if;--block if
	 end if;--form if
	 
	 	 if  form_name  in ('QLTRSMDF','QLTRSINF') and
	       block_name = 'Q_RES'   and	 	    
	 	     event_name in ('WHEN-NEW-RECORD-INSTANCE','WHEN-VALIDATE-RECORD', 'WHEN-NEW-FORM-INSTANCE')  then
	 	     
	 	     If  name_in('Q_RES_HEAD.NAME') in ('RL1_REPLACEMENT_IDENTIFIER') and
	 	         event_name = 'WHEN-NEW-RECORD-INSTANCE' then
	 	       	 set_item_property('Q_RES.DISPLAY3',INSERT_ALLOWED, PROPERTY_FALSE);	 
	 	 	 	 	 	 set_item_property('Q_RES.DISPLAY3',UPDATE_ALLOWED, PROPERTY_FALSE);
	 	 	 	 end if;
	 	 	 	 	
	 	 	 	 If  name_in('Q_RES_HEAD.NAME') in ('RL1_REPLACEMENT_IDENTIFIER') and 
	 	 	 	 	   event_name = 'WHEN-VALIDATE-RECORD' and
	 	 	 	 	 	  name_in('Q_RES.DISPLAY3') is not null then
	 	 	 	 	 	  COPY('N','Q_RES.DISPLAY1'); 
	 	 	 	 end if;
	 	 	 	 
	 	 	 If  name_in('Q_RES_HEAD.NAME') in ('RL31_REPL_PHONE_TO_ACCESSORIES') and
	 	         event_name = 'WHEN-NEW-RECORD-INSTANCE' then
	 	       	 set_item_property('Q_RES.DISPLAY2',INSERT_ALLOWED, PROPERTY_FALSE);	 
	 	 	 	 	 	 set_item_property('Q_RES.DISPLAY2',UPDATE_ALLOWED, PROPERTY_FALSE);
	 	 	 	 end if;
	 	 	 	 	
	 	 	 	 If  name_in('Q_RES_HEAD.NAME') in ('RL31_REPL_PHONE_TO_ACCESSORIES') and 
	 	 	 	 	   event_name = 'WHEN-VALIDATE-RECORD' and
	 	 	 	 	 	  name_in('Q_RES.DISPLAY2') is not null then
	 	 	 	 	 	  COPY('N','Q_RES.DISPLAY1'); 
	 	 	 	 	end if;
	 	 	 	 	
	 	 end if; 

	 	 
	 	 If form_name  = 'FNDSCSGN' and
	       block_name = 'NAVIGATOR'   and	 	    
	 	     event_name = 'WHEN-FORM-NAVIGATE' then
	 	     -----to_number(fnd_profile.value('RESP_ID'))
	 	     ccwq_sub_matrix.active_upd;
	 	 end if;
 
END;	

/* END  ----------By Nilesh Kothamasu.  -- 4/7/09 */

	-- Code Start for OM Customization  Karthik Ramanathan
IF (FORM_NAME	='OEXOEORD') THEN
	IF v_logappl = 'ONT' THEN

		--v_error := 'N';
					lfound := 'N';

   BEGIN
        select 'Y' into lfound from fnd_responsibility_tl fr, fnd_lookup_values flv
        where lookup_type = 'CCW_DOC_DISABLE_RMA'
        and meaning = responsibility_name
        and   responsibility_id = l_resp_id;
			EXCEPTION
				 WHEN NO_DATA_FOUND THEN NULL;
				 WHEN OTHERS THEN RAISE;
			END;
IF lfound = 'Y' THEN
		v_order_category := name_in('order.order_category_code');
		
		   --	fnd_message.set_string(event_name);
      --	fnd_message.show;
  BEGIN
  	    --fnd_message.set_string(v_order_category || ' '||l_resp_id ||' Event Name '|| event_name);
      	--fnd_message.show;
		IF (event_name in ('PRE-QUERY','PRE-QUERY','POST_QUERY','POST-QUERY')) and block_name in ('ORDER','LINE') THEN
     IF c_order_category%ISOPEN THEN
    	CLOSE c_order_category;
     END IF;
     OPEN c_order_category;
      FETCH c_order_category INTO c_order_category_rec;
      IF c_order_category%NOTFOUND THEN
      	g_error := 'Y';
      ELSE
      	g_error := 'N';
      END IF;
     CLOSE c_order_category;
		END IF;
		EXCEPTION
			WHEN OTHERS THEN
			  g_error := 'Y';
		END;
		IF (event_name = 'WHEN-NEW-RECORD-INSTANCE') THEN
		If g_error = 'Y' THEN
			--EXIT_FORM;
			      app_form.query_only_mode;
		ELSE
			
  BEGIN
    COPY('Entering Entry mode.','global.frd_debug');
    copy('NO', 'parameter.query_only');
    app_menu.set_prop('FILE.SAVE', enabled, property_on);
    app_menu.set_prop('FILE.ACCEPT', enabled, property_on);
    form_name  := Name_In('system.current_form');
    block_name := Get_Form_Property(form_name, FIRST_BLOCK);
    while (block_name is not null) loop
      if (Get_Block_Property(block_name, BASE_TABLE) is not NULL) then
        Set_Block_Property(block_name, INSERT_ALLOWED, PROPERTY_TRUE);
        Set_Block_Property(block_name, UPDATE_ALLOWED, PROPERTY_TRUE);
        Set_Block_Property(block_name, DELETE_ALLOWED, PROPERTY_TRUE);
      end if;
      block_name := Get_Block_Property(block_name, NEXTBLOCK);
    end loop;
    COPY('Completed Entry mode.','global.frd_debug');
  END ;
		END IF;
		END IF;
END IF;		
		lfound := 'N';
		IF (event_name = 'WHEN-NEW-FORM-INSTANCE') THEN
			BEGIN
        select 'Y' into lfound from fnd_responsibility_tl fr, fnd_lookup_values flv
        where lookup_type = 'CCW_DOC_DISABLE_PAY_TERM'
        and meaning = responsibility_name
        and   responsibility_id = l_resp_id;
			EXCEPTION
				 WHEN NO_DATA_FOUND THEN lfound := 'N';
				 WHEN OTHERS THEN RAISE;
			END;

      IF lfound = 'Y' THEN
	 set_item_property('ORDER.TERMS',ENABLED, PROPERTY_FALSE);
	 	 set_item_property('ORDER.TERMS',NAVIGABLE, PROPERTY_FALSE);
	 	 	 set_item_property('ORDER.TERMS',INSERT_ALLOWED, PROPERTY_FALSE);	 
	 	 	 	 	 	 set_item_property('ORDER.TERMS',UPDATE_ALLOWED, PROPERTY_FALSE);	
	 --set_item_property('ORDER_DETAILS.TERMS',ENABLED, PROPERTY_FALSE);
	 	 --set_item_property('ORDER_DETAILS.TERMS',NAVIGABLE, PROPERTY_FALSE);
	 	 -- set_item_property('ORDER_DETAILS.TERMS',INSERT_ALLOWED, PROPERTY_FALSE);	 
	 	 	 	 --	 	 set_item_property('ORDER_DETAILS.TERMS',UPDATE_ALLOWED, PROPERTY_FALSE);		 	 	 	 	 	 	 
	 	 	 	 	 	 set_item_property('LINE.TERMS_MIR',ENABLED, PROPERTY_FALSE);
	 	 set_item_property('LINE.TERMS_MIR',NAVIGABLE, PROPERTY_FALSE);
	 	 	 set_item_property('LINE.TERMS_MIR',INSERT_ALLOWED, PROPERTY_FALSE);	 
	 	 	 	 	 	 set_item_property('LINE.TERMS_MIR',UPDATE_ALLOWED, PROPERTY_FALSE);	
	 --Commented based on 11.5.10 upgrade issue VJ
	 --set_item_property('LINES_DETAILS.TERMS',ENABLED, PROPERTY_FALSE);
	 	 --set_item_property('LINES_DETAILS.TERMS',NAVIGABLE, PROPERTY_FALSE);
	 	 	 --set_item_property('LINES_DETAILS.TERMS',INSERT_ALLOWED, PROPERTY_FALSE);	 
	 	 	 	 --	 	 set_item_property('LINES_DETAILS.TERMS',UPDATE_ALLOWED, PROPERTY_FALSE);		 	 	--set_item_property('ORDER.TERMS',LOV_NAME, '');	 	 	 	 
ELSE	 
	 set_item_property('ORDER.TERMS',ENABLED, PROPERTY_TRUE);	
	 	 	 set_item_property('ORDER.TERMS',NAVIGABLE, PROPERTY_TRUE);
	 	 	 set_item_property('ORDER.TERMS',INSERT_ALLOWED, PROPERTY_TRUE);	 
	 	 	 	 	 	 set_item_property('ORDER.TERMS',UPDATE_ALLOWED, PROPERTY_TRUE);
	 	 	 	 	 	 	--	 		 set_item_property('ORDER_DETAILS.TERMS',ENABLED, PROPERTY_TRUE);
	 	-- set_item_property('ORDER_DETAILS.TERMS',NAVIGABLE, PROPERTY_TRUE);
	 	 	-- set_item_property('ORDER_DETAILS.TERMS',INSERT_ALLOWED, PROPERTY_TRUE);	 
	 	 	 	 --	 	 set_item_property('ORDER_DETAILS.TERMS',UPDATE_ALLOWED, PROPERTY_TRUE);		
	 set_item_property('LINE.TERMS_MIR',ENABLED, PROPERTY_TRUE);	
	 	 	 set_item_property('LINE.TERMS_MIR',NAVIGABLE, PROPERTY_TRUE);
	 	 	 set_item_property('LINE.TERMS_MIR',INSERT_ALLOWED, PROPERTY_TRUE);	 
	 	 	 	 	 	 set_item_property('LINE.TERMS_MIR',UPDATE_ALLOWED, PROPERTY_TRUE);		 	 	 	 	 	  	 	 	 --set_item_property('ORDER.TERMS',LOV_NAME, NULL);	 	 
--Commented based on 11.5.10 upgrade issue VJ	 	 	 	 	 	 
	 --set_item_property('LINES_DETAILS.TERMS',ENABLED, PROPERTY_TRUE);
	 	 --set_item_property('LINES_DETAILS.TERMS',NAVIGABLE, PROPERTY_TRUE);
	 	 	 --set_item_property('LINES_DETAILS.TERMS',INSERT_ALLOWED, PROPERTY_tRUE);	 
	 	 	 	 --	 	 set_item_property('LINES_DETAILS.TERMS',UPDATE_ALLOWED, PROPERTY_TRUE);	
END IF;
			lfound := 'N';
      BEGIN
      						v_booked_flag := name_in('line.booked_flag');
        select 'Y' into lfound from fnd_responsibility_tl fr, fnd_lookup_values flv
        where lookup_type = 'CCW_DOC_DISABLE_QTY_UPDATE'
        and meaning = responsibility_name
        and   responsibility_id = l_resp_id;
			EXCEPTION
				 WHEN NO_DATA_FOUND THEN 	lfound := 'N';
				 WHEN OTHERS THEN RAISE;
			END;
			--IF v_booked_flag='Y' THEN
IF lfound = 'Y' THEN
	 set_item_property('LINE.ORDERED_QUANTITY',UPDATE_ALLOWED, PROPERTY_FALSE);
	 set_item_property('LINE.ORDERED_QUANTITY_PRICING',UPDATE_ALLOWED, PROPERTY_FALSE);	 
	 set_item_property('LINE.ORDERED_QUANTITY_SHIPPING',UPDATE_ALLOWED, PROPERTY_FALSE);	 
	 set_item_property('LINE.ORDERED_QUANTITY_ADDRESSES',UPDATE_ALLOWED, PROPERTY_FALSE);	 
	 set_item_property('LINE.ORDERED_QUANTITY_RETURNS',UPDATE_ALLOWED, PROPERTY_FALSE);	 
	 set_item_property('LINE.ORDERED_QUANTITY_OTHERS',UPDATE_ALLOWED, PROPERTY_FALSE);	 
ELSE	 
	 set_item_property('LINE.ORDERED_QUANTITY',UPDATE_ALLOWED, PROPERTY_TRUE);
	 set_item_property('LINE.ORDERED_QUANTITY_PRICING',UPDATE_ALLOWED, PROPERTY_TRUE);	 
	 set_item_property('LINE.ORDERED_QUANTITY_SHIPPING',UPDATE_ALLOWED, PROPERTY_TRUE);
	 set_item_property('LINE.ORDERED_QUANTITY_ADDRESSES',UPDATE_ALLOWED, PROPERTY_TRUE);
	 set_item_property('LINE.ORDERED_QUANTITY_RETURNS',UPDATE_ALLOWED, PROPERTY_TRUE);
	 set_item_property('LINE.ORDERED_QUANTITY_OTHERS',UPDATE_ALLOWED, PROPERTY_TRUE);	 
END IF;
--END IF;
			lfound := 'N';
      BEGIN
        select 'Y' into lfound from fnd_responsibility_tl fr, fnd_lookup_values flv
        where lookup_type = 'CCW_DOC_DISABLE_RMA'
        and meaning = responsibility_name
        and   responsibility_id = l_resp_id;
			EXCEPTION
				 WHEN NO_DATA_FOUND THEN lfound := 'N';
				 WHEN OTHERS THEN RAISE;
			END;
IF lfound = 'Y' THEN
		
BEGIN 
  /* 
  ** Make sure the record group does not already exist.
  */ 
  		    rg_name1 := 'ORDER_CATEGORY_QF';
   rg_id1 := Find_Group(rg_name1);   	        
    Delete_Group_Row(rg_id1 ,ALL_ROWS);
             
      errcode := Populate_Group_With_Query( rg_id1, 
                  'select meaning, lookup_code ' 
                ||'from oe_lookups ' 
                ||'where lookup_type = ''ORDER_CATEGORY'' ' 
                ||'and lookup_code=''ORDER'' '
                  ||'order by meaning'          
                  );     
  
  
  rg_name2 := 'ORDER_TYPE';
  rg_id2 := Find_Group(rg_name2); 
  /* 
  ** If it does not exist, create it and add the two 
  ** necessary columns to it. 
  */ 
  IF Id_Null(rg_id2) THEN 
    --rg_id := Create_Group(rg_name);
    /* Add two number columns to the record group */ 
    --gc_id := Add_Group_Column(rg_id, 'Base_Sal_Range',                               NUMBER_COLUMN); 
    --gc_id := Add_Group_Column(rg_id, 'Emps_In_Range',                               NUMBER_COLUMN); 
    NULL;
  END IF; 
  /* 
  ** Populate group with a query 
  */ 
     --rg_id2 := Find_Group(rg_name2);   	        
    Delete_Group_Row(rg_id2 ,ALL_ROWS);


  errcode := Populate_Group_With_Query( rg_id2, 
                  'select order_type_id, name, description  ' 
                ||'from oe_order_types_v ' 
                ||'where sysdate between start_date_active ' 
                ||'and nvl(end_date_active,sysdate) '
                 ||'and order_category_code=''ORDER'' '
                  ||'order by name'          ); 
  
  rg_name3 := 'ORDER_TYPES_QF';  
     rg_id3 := Find_Group(rg_name3);   	        
    Delete_Group_Row(rg_id3 ,ALL_ROWS);
    errcode := Populate_Group_With_Query( rg_id3, 
                  'select name, description, order_type_id  ' 
                ||'from oe_order_types_v ' 
                ||'where sysdate between start_date_active ' 
                ||'and nvl(end_date_active,sysdate) '
                 ||'and order_category_code=''ORDER'' '
                  ||'order by name'          ); 
     
  --v_formpath := fnd_navigate.Formpath('CCWONT', FORM_NAME);
 
    --fnd_message.set_string('Event '|| event_name);
    --fnd_message.show;
    
                       
END; 
ELSE	 
	 set_item_property('LINE.ORDERED_QUANTITY',UPDATE_ALLOWED, PROPERTY_TRUE);
END IF;
END IF;
END IF;

--IF (event_name = 'WHEN-NEW-RECORD-INSTANCE') THEN
	
IF (block_name='LINE') AND 	v_logappl = 'ONT' THEN
IF name_in('system.record_status')  in ('NEW','INSERT') THEN
	    --fnd_message.set_string(v_logappl||' Event '|| event_name || ' block '|| block_name);
    --fnd_message.show;
	set_item_property('LINE.UNIT_SELLING_PRICE_DSP',UPDATE_ALLOWED, PROPERTY_FALSE);
	set_item_property('LINE.UNIT_SELLING_PRICE_DSP',INSERT_ALLOWED, PROPERTY_FALSE);	
	set_item_property('LINE.REASON', required, property_false); 
ELSIF NVL(name_in('system.record_status'),'NEW')  NOT IN ('INSERT', 'NEW') THEN	
	set_item_property('LINE.UNIT_SELLING_PRICE_DSP',INSERT_ALLOWED, PROPERTY_TRUE);		
	set_item_property('LINE.UNIT_SELLING_PRICE_DSP',UPDATE_ALLOWED, PROPERTY_TRUE);
	set_item_property('LINE.REASON', required, property_true); 
	--set_item_property('LINE.UNIT_SELLING_PRICE',UPDATE_ALLOWED, PROPERTY_TRUE);	
END IF;	
/*
ELSIF (block_name='LINE') AND 
	v_logappl = 'CCWONT' THEN
		    --fnd_message.set_string(v_logappl||' Event '|| event_name|| ' block '|| block_name);
    --fnd_message.show;

	set_item_property('LINE.UNIT_SELLING_PRICE_DSP',INSERT_ALLOWED, PROPERTY_TRUE);		
	set_item_property('LINE.UNIT_SELLING_PRICE_DSP',UPDATE_ALLOWED, PROPERTY_TRUE);
	*/
END IF;


/*

IF (block_name='LINE') AND  v_logappl = 'ONT' THEN		
 	    --fnd_message.set_string(v_logappl||' Event 2 '|| event_name|| ' block '|| block_name);
    --fnd_message.show;

if name_in('system.record_status') NOT in ('NEW','INSERT') THEN
   --SHOW the field for entering the reason.
   set_item_property('LINE.REASON', required, property_true); 
else
   set_item_property('LINE.REASON', required, property_false); 
end if;
END IF;
*/
/*
ELSIF (block_name='LINE') AND 
	v_logappl = 'CCWONT' THEN
	
		    fnd_message.set_string(v_logappl||' Event 2'|| event_name|| ' block '|| block_name);
    fnd_message.show;

	   set_item_property('LINE.REASON', required, property_true); 
END IF;   
*/
--END IF;
END IF;

-- Code End for OM Customization  Karthik Ramanathan 
  		

	
  	
-- Cingular Enhancement CRP2: PRG-301B - "Supplier Form - Hide Employee Vendor Address Information" begins

  -- In the Suppliers Form(APXVDMVD) the access to the Supplier Sites level (which contains Vendor Address Infomation )
  -- should be based on 2 factors: 1. Whether the Vendor(Supplier) is an Employee Vendor 2. Does the current responsibility
  -- have access to the Supplier Sites Level
  -- The Login responsibility should have the Should have the Profile Option set to YES 
  -- at the responsibility level for accessing the sites information.		
		IF (event_name = 'WHEN-NEW-RECORD-INSTANCE') THEN
			IF (form_name = 'APXVDMVD') THEN
					tp_main := FIND_TAB_PAGE('VNDR_REGIONS.USES');  
				  set_tab_page_property(tp_main,ENABLED,PROPERTY_FALSE);
				  v_employee_type := name_in('VNDR.VENDOR_TYPE_DISP_MIR');
				IF v_employee_type = 'Employee' THEN
					fnd_profile.get(name => 'CCWAP_SHOW_EMP_VENDOR_ADDRESS',
													val  =>	v_add_profile_value
												 );											 
						 IF NVL(v_add_profile_value,'X') <> 'Y' THEN			
					   		app_item_property2.set_property('VNDR.SITES',ENABLED,PROPERTY_OFF);
                hide_window('VENDOR_SITE');
					   END IF;		
						 IF v_add_profile_value = 'Y' THEN
						 	  app_item_property2.set_property('VNDR.SITES',ENABLED,PROPERTY_ON);
						 END IF;	  
				ELSE IF 	v_employee_type <> 'Employee' THEN
									app_item_property2.set_property('VNDR.SITES',ENABLED,PROPERTY_ON);
						 END IF;		
				END IF;
			END IF;
		END IF;	
		
-- Cingular Enhancement CRP2: PRG-301B - "Supplier Form - Hide Employee Vendor Address Information" ends

-- Cingular Enhancement CRP2: PRG-301A - "Supplier Form - Hide Bank Account Information" begins

  -- In the Suppliers form (APXVDMVD) we need to make the Banking Information at the Header level in-accessible to all
  -- ther users.  Therefore we hide the entire tab page information from all the users at the header level.
		IF (event_name = 'WHEN-NEW-FORM-INSTANCE') THEN
			IF (form_name = 'APXVDMVD') THEN
				tp_main := FIND_TAB_PAGE('VNDR_REGIONS.USES');  
				set_tab_page_property(tp_main,ENABLED,PROPERTY_FALSE);
			END IF;
		END IF;
		
	-- In the Suppliers Form (APXVDMVD) acess to the Bank Information at the sites level is Controlled based the
	-- responsibility.  A profile option for viewing the Bank Details Information is created and linked at the responsibility
	-- level.  Therefore only those responsibilities that have the option set to YES should have access to this tab page
	
		IF (event_name = 'WHEN-NEW-RECORD-INSTANCE') THEN
			IF (form_name = 'APXVDMVD') THEN
				
					fnd_profile.get(name => 'CCWAP_SHOW_VENDOR_BANK_INFO',
													val  =>	v_bank_profile_value
												 );
						 IF NVL(v_bank_profile_value,'X') <> 'Y' THEN			
					   	  tp_sites := find_tab_page('SITE_REGIONS.SITE_BANK_USES');
					   	  Set_tab_page_property(tp_sites,ENABLED,PROPERTY_FALSE);
					   ELSE		IF NVL(v_bank_profile_value,'X') = 'Y' THEN
						 	  			tp_sites := find_tab_page('SITE_REGIONS.SITE_BANK_USES');
					   	  			Set_tab_page_property(tp_sites,ENABLED,PROPERTY_TRUE);
					   				END IF;	  
					   END IF;
						 
			END IF;
		END IF;	
	
  -- The below makes the vendor site field mandatory for the SUPPLIER account type, otherwise the bank account gets
  -- linked to the supplier header (need is to link it to the supplier site)
  
		IF (event_name = 'WHEN-NEW-RECORD-INSTANCE') THEN
			IF (form_name = 'APXSUMBA') THEN
				
						v_account_use := name_in('ACCOUNTS.ACCOUNT_TYPE');
		
						IF  v_account_use = 'SUPPLIER' THEN
							 				app_item_property2.set_property('USES.VENDOR_SITE_CODE',REQUIRED,PROPERTY_ON);
						ELSE  IF v_account_use <> 'SUPPLIER' THEN	
											app_item_property2.set_property('USES.VENDOR_SITE_CODE',REQUIRED,PROPERTY_OFF);							
									END IF;		
						END IF;
						
			END IF;
		END IF;	
		
/* Added by hp5043 for the CQ WUP00555952 on 07/17/2011 begin */


IF 
	--event_name = 'WHEN-NEW-RECORD-INSTANCE'   --changes for R12 QC # 3233 
	event_name IN( 'WHEN-NEW-ITEM-INSTANCE','WHEN-NEW-RECORD-INSTANCE', 'WHEN-NEW-BLOCK-INSTANCE')  
	AND form_name = 'APXINWKB' AND block_name in('INV_SUM_FOLDER','LINE_SUM_FOLDER', 'LINE_SUM_CONTROL') 
  AND name_in('PARAMETER.QUERY_ONLY') = 'NO' 
	
THEN
	
							--fnd_message.debug('name_in(PARAMETER.QUERY_ONLY)' ||' '||name_in('PARAMETER.QUERY_ONLY'));
       	    
       	      If name_in('INV_SUM_FOLDER.INVOICE_ID') is not null  AND
     	            	 --    (name_in('INV_SUM_FOLDER.ATTRIBUTE12') is null OR name_in('INV_SUM_FOLDER.ATTRIBUTE12') = 'WIRELESS') AND -- OR, AND  was added by hp5043 for CQ WUP00555952 on 07/17/2011
           	     (name_in('INV_SUM_FOLDER.ATTRIBUTE11') = 'A' OR name_in('INV_SUM_FOLDER.ATTRIBUTE11') = 'I') then
           	  set_item_property('INV_SUM_CONTROL.ACTIONS', enabled,PROPERTY_FALSE);
           	  set_item_property('LINE_SUM_CONTROL.DISCARD_LINE', enabled, PROPERTY_FALSE);
            	else
              set_item_property('INV_SUM_CONTROL.ACTIONS', enabled,PROPERTY_TRUE);
              set_item_property('LINE_SUM_CONTROL.DISCARD_LINE', enabled, PROPERTY_TRUE);
            	end if;

END IF; 

/* Added by hp5043 for the CQ WUP00555952 on 07/17/2011 end */

-- Cingular Enhancement CRP2: PRG-301A - "Supplier Form - Hide Bank Account Information" ends

-- Cingular Enhancement CRP3: FMG.XXX - "Item to Expenditure Type Mapping" begins

    -- In the AP Invoice Entry screens, the POET expenditure type on a matched PO invoice needs to match the 
    -- PO item's expenditure type.
    
    IF form_name = 'APXINWKB' AND block_name = 'D_SUM_FOLDER' AND event_name = 'WHEN-VALIDATE-RECORD' 
    	AND NAME_IN('INV_SUM_FOLDER.ATTRIBUTE12')!='WIRELINE-ESS' --Added by kavya for ESS
    	THEN
    	
       -- validate only if it is matched PO invoice and if project information has been entered

       IF name_in('d_sum_folder.po_distribution_id') IS NOT NULL AND
			    name_in('d_sum_folder.project_id') IS NOT NULL   THEN 
				
       		--Pranay on 06/24/06 fetched distribution id into a variable, to show in message later, and also to be used in query
       		pg_distro_id := name_in('d_sum_folder.po_distribution_id');
       		--end distro fetch pranay
       
          --start Pranay 05/10/06
          
          ccwpa_iet_master_rg_id1 := FIND_GROUP ('CCWPA_IET_MASTER_RG1');--???
          
          IF NOT ID_NULL(ccwpa_iet_master_rg_id1) THEN
          	 DELETE_GROUP(ccwpa_iet_master_rg_id1);
          END IF;
          
          ccwpa_iet_master_rg_id1 := CREATE_GROUP_FROM_QUERY ('CCWPA_IET_MASTER_RG1', 'SELECT mp.master_organization_id master_org FROM '||'mtl_parameters mp, po_distributions pd '||'WHERE pd.po_distribution_id = '||name_in('d_sum_folder.po_distribution_id')||' AND mp.organization_id = pd.destination_organization_id ');
          
          ccwpa_iet_master_rg_error1 := POPULATE_GROUP(ccwpa_iet_master_rg_id1);
          
			  IF ccwpa_iet_master_rg_error1 <> 0 THEN
						 fnd_message.set_string('Error in record group ' || ccwpa_iet_master_rg_error1);
						 fnd_message.error;        
			  END IF;
          
          ccwpa_iet_master_rg_count1 := GET_GROUP_ROW_COUNT(ccwpa_iet_master_rg_id1);
          
          IF ccwpa_iet_master_rg_count1 > 0 THEN
			
			IF GET_GROUP_NUMBER_CELL('CCWPA_IET_MASTER_RG1.master_org',1) IS NULL THEN
			
				-- No Master Org info could be found (do we need this?)
				NULL;
				
			ELSE
				ccwpa_iet_master_org_id1 := GET_GROUP_NUMBER_CELL('CCWPA_IET_MASTER_RG1.master_org', 1);
				
			END IF;
			
		  END IF;
				
          --end Pranay 05/10/06
          
          ccwpa_iet_rg_id1 := FIND_GROUP ('CCWPA_ITEM_TO_EXP_TYPE_RG1');
          
          IF NOT ID_NULL(ccwpa_iet_rg_id1) THEN
          	 DELETE_GROUP(ccwpa_iet_rg_id1);
          END IF;
        
        --Added message Pranay 06/24/06
        --fnd_message.set_string('APXINWKB form before creating RG. Master Org value: '||ccwpa_iet_master_org_id1);
        --fnd_message.show;
        --end message Pranay
          -- the query makes sure that the PO line was item-based
					
					--Pranay on 06/25/06 replaced the base table query back by kfv query to resolve issues in forming record group
          /*
          ccwpa_iet_rg_id1 := CREATE_GROUP_FROM_QUERY ('CCWPA_ITEM_TO_EXP_TYPE_RG1',
          'SELECT msi.segment1||"."||msi.segment3 item_no, msi.attribute12 exp_type FROM mtl_system_items_b msi, po_lines_all pl, po_distributions_all pd '||' WHERE pd.po_line_id = pl.po_line_id AND pd.po_distribution_id = '||pg_distro_id||' AND msi.organization_id = '||ccwpa_iet_master_org_id1||' AND pl.item_id IS NOT NULL AND msi.inventory_item_id = pl.item_id');
		      -- 05/09/06 Pranay changed from mtl_system_items_b_kfv to mtl_system_items_b, removed concatenated_segments and replaced them with segment1||segment3, removed mtl_parameters, passed org id via variable instead of pd.destination_organization_id
        	*/
					--Query added in lieu of the above query on 06/25/06 Pranay
					ccwpa_iet_rg_id1 := CREATE_GROUP_FROM_QUERY ('CCWPA_ITEM_TO_EXP_TYPE_RG1',' SELECT msik.concatenated_segments item_no, msik.attribute12 exp_type FROM mtl_system_items_b_kfv msik, po_lines_all pl, po_distributions_all pd '||' WHERE pd.po_line_id = pl.po_line_id AND pd.po_distribution_id = '||pg_distro_id||' AND msik.organization_id = '||ccwpa_iet_master_org_id1||' AND pl.item_id IS NOT NULL AND msik.inventory_item_id = pl.item_id');        	
					--end of query added in lieu of the earlier query on 06/25/06 Pranay        
    
        --Added message Pranay 06/24/06
              	
        --fnd_message.set_string('APXINWKB form after creating RG. Distribution ID: '||pg_distro_id);
        --fnd_message.show;
        --end message Pranay
          ccwpa_iet_rg_error1 := POPULATE_GROUP(ccwpa_iet_rg_id1);
        
          -- 1403 is "record not found" which should also result in row count of 0
          -- 1403 implies that it was a non-item PO line
          IF ccwpa_iet_rg_error1 NOT IN (0, 1403) THEN
				     fnd_message.set_string('Error in record group ' || ccwpa_iet_rg_error1);
				     fnd_message.error;        
          END IF;

          ccwpa_iet_rg_count1 := GET_GROUP_ROW_COUNT(ccwpa_iet_rg_id1);
        
          -- note: if project_id is populated, form ensures that exp type is populated too
          IF ccwpa_iet_rg_count1 > 0 THEN
          	
	          	 			--start pranay 06/24/06
	          	 			--pg_exp_type := GET_GROUP_CHAR_CELL ('CCWPA_ITEM_TO_EXP_TYPE_RG1.exp_type', 1);
	          	 			--fnd_message.set_string('APXINWKB form after null check exp type. Exp Type: '||pg_exp_type);
	        					--fnd_message.show;
        		   			 --end pranay 06/24/06          	
          	
          	 IF    GET_GROUP_CHAR_CELL ('CCWPA_ITEM_TO_EXP_TYPE_RG1.exp_type', 1) IS NULL THEN
	          	 			--start pranay 06/24/06          	
                   --fnd_message.set_string('APXINWKB form after null check exp type. Exp Type Null: '||pg_distro_id);
        					 --fnd_message.show;
        		   			 --end pranay 06/24/06        					 
                   -- item has not been setup with an expenditure type => no validation required
                   NULL;
                                   
          	 ELSIF GET_GROUP_CHAR_CELL ('CCWPA_ITEM_TO_EXP_TYPE_RG1.exp_type', 1)
          	 	     <> name_in('d_sum_folder.expenditure_type')       THEN

                   -- if exp types do not match, error out with a custom message
                   fnd_message.set_name('CCWPA', 'CCWPA_ITEM_TO_EXP_TYPE_ERROR');
                   fnd_message.set_token('ITEM_NO', GET_GROUP_CHAR_CELL ('CCWPA_ITEM_TO_EXP_TYPE_RG1.item_no', 1));
                   fnd_message.set_token('EXP_TYPE', GET_GROUP_CHAR_CELL ('CCWPA_ITEM_TO_EXP_TYPE_RG1.exp_type', 1));
                   fnd_message.error;
                   RAISE form_trigger_failure;
                   
             END IF;
           
          END IF;	
						      
		   END IF;	

    END IF;

    -- In the Requisitions/PO/Release Entry screens, the POET expenditure type needs to match the item's 
    -- expenditure type. (POXRQERQ = Requisitions Entry, POXPOEPO = Standard PO Entry, POXPOERL = Releases Entry)
    
    --modification by vineet mukul for expenditure type validaion on the distributions form
    -- completed on 19-NOV-2004
    
    
    /* ADDED block_name = 'LINES' and (form_name = 'POXDOPRE' AND block_name = 'PO_DEFAULTS'      
       AND   event_name = 'WHEN-VALIDATE-RECORD') by RGC 09/15  */
       
    /* Added validation on project to ensure expense item not charges to Capital Project 
       Sue Gibson 17-AUG-2007 CR WUP00047479 */      

    IF (form_name = 'POXRQERQ' AND (block_name = 'DISTRIBUTIONS' OR block_name = 'LINES')    
    	                         AND  event_name = 'WHEN-VALIDATE-RECORD') OR
    	 (form_name = 'POXPOEPO' AND block_name  = 'PO_DISTRIBUTIONS' AND event_name = 'WHEN-VALIDATE-RECORD') OR
    	 (form_name = 'POXPOERL' AND block_name  = 'PO_DISTRIBUTIONS' AND event_name = 'WHEN-VALIDATE-RECORD') OR
    	 (form_name = 'POXDOPRE' AND block_name  = 'PO_DEFAULTS'      AND event_name = 'WHEN-VALIDATE-RECORD') THEN
    	
       IF form_name = 'POXRQERQ' THEN
						 
						 --fnd_message.DEBUG('WVR-item-capital project check.');
						 
             ccwpa_iet_expenditure_type := NAME_IN('DISTRIBUTIONS.EXPENDITURE_TYPE');
             ccwpa_iet_item_id          := NAME_IN('LINES.ITEM_ID');
             ccwpa_iet_item_number      := NAME_IN('LINES.ITEM_NUMBER');
             ccwpa_iet_org_id           := NAME_IN('LINES.DEST_ORGANIZATION_ID');
             ccwpa_iet_proj             := name_in('DISTRIBUTIONS.PROJECT');
             
       
      -- ELSIF form_name = 'POXPOEPO' THEN
       	 ELSIF form_name = 'POXPOEPO' and NAME_IN ('PO_HEADERS.ATTRIBUTE5') != 'WIRELINE-ESS' THEN --Added by kavya for ESS
       	
             ccwpa_iet_expenditure_type := name_in('po_distributions.expenditure_type');
             ccwpa_iet_item_id          := name_in('po_lines.item_id');
             ccwpa_iet_item_number      := name_in('po_lines.item_number');
             --ccwpa_iet_org_id           := NAME_IN('PO_HEADERS.SHIP_TO_ORG_ID'); --changed 07/05/06 PG
             ccwpa_iet_org_id           := NAME_IN('PO_DISTRIBUTIONS.DESTINATION_ORGANIZATION_ID');
						 ccwpa_iet_proj             := name_in('PO_DISTRIBUTIONS.PROJECT');
						 
       ELSIF form_name = 'POXPOERL' THEN
       	
             ccwpa_iet_expenditure_type := name_in('po_distributions.expenditure_type');
             ccwpa_iet_item_id          := name_in('po_shipments.item_id');
             ccwpa_iet_item_number      := name_in('po_shipments.item_num');
						 ccwpa_iet_org_id           := NAME_IN('PO_SHIPMENTS.SHIP_TO_ORGANIZATION_ID');
						 ccwpa_iet_proj             := name_in('PO_DISTRIBUTIONS.PROJECT');
		
       END IF;

       
                     
             IF (CCWPA_IET_PROJ IS NOT NULL AND CCWPA_IET_ITEM_ID IS null ) THEN 
             	  fnd_message.set_string('Project and Expenditure Type should be NULL for transactions which do not use inventory items');
                fnd_message.show;  	 
             	RAISE FORM_TRIGGER_FAILURE;
             END IF;
             
       -- validate only if POET information is entered and it is an item-based line
      IF ccwpa_iet_expenditure_type IS NOT NULL AND ccwpa_iet_item_id IS NOT NULL   THEN 
				
			  --start Pranay 2:56 PM 5/10/2006
			  
			  ccwpa_iet_master_rg_id2 := FIND_GROUP ('CCWPA_IET_MASTER_RG2');--???
			  
			  IF NOT ID_NULL(ccwpa_iet_master_rg_id2) THEN
				 DELETE_GROUP(ccwpa_iet_master_rg_id2);
			  END IF;
			  
			  ccwpa_iet_master_rg_id2 := CREATE_GROUP_FROM_QUERY ('CCWPA_IET_MASTER_RG2', 'SELECT mp.master_organization_id master_org FROM ' 
			  ||'mtl_parameters mp ' ||'WHERE mp.organization_id = '||ccwpa_iet_org_id);
			  
					  
			  ccwpa_iet_master_rg_error2 := POPULATE_GROUP(ccwpa_iet_master_rg_id2);
			  
			  IF ccwpa_iet_master_rg_error2 <> 0 THEN
						 fnd_message.set_string('Error in record group ' || ccwpa_iet_master_rg_error2);
						 fnd_message.error;        
			  END IF;
			 
			  ccwpa_iet_master_rg_count2 := GET_GROUP_ROW_COUNT(ccwpa_iet_master_rg_id2);
			  
			  IF ccwpa_iet_master_rg_count2 > 0 THEN
				
				IF GET_GROUP_NUMBER_CELL('CCWPA_IET_MASTER_RG2.master_org',1) IS NULL THEN
				
					-- No Master Org info could be found (do we need this?)
					NULL;
					
				ELSE
					ccwpa_iet_master_org_id2 := GET_GROUP_NUMBER_CELL('CCWPA_IET_MASTER_RG2.master_org', 1);
					
				END IF;
				
			  END IF;
					
			  --end Pranay 05/10/06			
			
			
				--IF ccwpa_iet_expenditure_type IS NOT NULL THEN 
          ccwpa_iet_rg_id2 := FIND_GROUP ('CCWPA_ITEM_TO_EXP_TYPE_RG2');
          
          IF NOT ID_NULL(ccwpa_iet_rg_id2) THEN
          	 DELETE_GROUP(ccwpa_iet_rg_id2);
          END IF;
          
          ccwpa_iet_rg_id2 := CREATE_GROUP_FROM_QUERY ('CCWPA_ITEM_TO_EXP_TYPE_RG2','SELECT nvl(msi.attribute12,''X'') exp_type,gcc.segment2 iet_gcc_segment2 FROM'||' mtl_system_items_b msi,gl_code_combinations gcc '||' WHERE msi.inventory_item_id = '||ccwpa_iet_item_id||' and msi.organization_id = '||ccwpa_iet_master_org_id2||' and msi.expense_account = gcc.code_combination_id ');
			 --Pranay 05/08/06 updated query to fetch exp_type from master org, also removed mtl_parameters join
          
          ccwpa_iet_rg_error2 := POPULATE_GROUP(ccwpa_iet_rg_id2);
        
          -- 1403 ("record not found") should not happen for the item
          IF ccwpa_iet_rg_error2 <> 0 THEN
				     fnd_message.set_string('Error in record group ' || ccwpa_iet_rg_error2);
				     fnd_message.error;        
          END IF;

          -- note: if project_id is populated, form ensures that exp type is populated too
          -- set the value of the global if any item to exp type verification is done
          IF    GET_GROUP_CHAR_CELL ('CCWPA_ITEM_TO_EXP_TYPE_RG2.exp_type', 1) = 'X' THEN
  
            if (
            	  GET_GROUP_CHAR_CELL ('CCWPA_ITEM_TO_EXP_TYPE_RG2.iet_gcc_segment2',1) not like '15%' and 
            	  GET_GROUP_CHAR_CELL ('CCWPA_ITEM_TO_EXP_TYPE_RG2.iet_gcc_segment2',1) not like '16%' and
            	  GET_GROUP_CHAR_CELL ('CCWPA_ITEM_TO_EXP_TYPE_RG2.iet_gcc_segment2',1) not like '17%' -- Pranay 05/05/06 pg17_accum_dep_acc
            	 ) then
            	
            -- 	if CCWPA_IET_PROJ IS NOT NULL then
            	if name_in('global.gv_iet_msg_ctr1') = 'DISPLAY' then
              --  fnd_message.set_string('Expense item without item level expenditure type assignment. No validation performed. Update project and account if required');
 ---03/13/07 ss9085 as per RID 2172    fnd_message.set_string('You are charging an expense item to a project. There is no expenditure type validation for expense items. Please verify that your project information is correct. If you do not intend to charge a project for this item, delete the line and then re-enter the item. Go to the distribution and enter the GL code manually. This message appears only for the first expense item on a transaction');
----09/18/07 by ss9085 fnd_message.set_string ('STOP!!!!!  Your action may violate accounting rules!'||CHR(10)|| 'If you are charging an Expense Item to a Project/Capital Task, this is a violation of accounting rules. Please read this entire message for clarification:'||CHR(10)|| '- If you are requesting to purchase a capital item, delete the line. You must locate the appropriate capital item in the item master, then re-enter the line with your Capital Item and Project/Capital Task information.'||CHR(10)|| '- If you are requesting to purchase an `expense item` to be charged to a Project/Expense Task, you must verify that the account created by the Project information entered on the requisition line distribution matches the account default for that expense item on the item file.'||CHR(10)||' - If you are requesting to purchase an `expense item` that will not be charged to a Project/Expense Task, allow the system to default the account from the item file.'||CHR(10)|| 'In summary:  Capital Items ­must be charged to a Project/Capital Task. Expense Items cannot be charged to a Project/Capital Task.'||CHR(10)|| 'Expense Items can be charged to a Project/Expense Task.'||CHR(10)||'Please direct any questions to your Market Financial Manager.');

   ---            fnd_message.show;
            	copy('DO NOT DISPLAY','global.gv_iet_msg_ctr1');
            	end if;
            	
            --   raise form_trigger_failure; do not raise here
            --   per Vito users can enter project info on expense item lines
            -- 	end if; -- end of CCWPA_IET_PROJ IS NOT NULL
         
          	else -- for capital items
          	
  --        	fnd_message.set_string('Capital item without item level expenditure type assignment. Cannot proceed with this transaction. Please contact Inventory Item maintenance team to modify item setup');
  -- by ss9085 09/18/07 
  fnd_message.set_string('Capital item without item level expenditure type assignment. Cannot proceed with this transaction. Please contact Inventory Item maintenance team to modify item setup');
      fnd_message.show;		
  --9/18/07 by ss9085          
  raise form_trigger_failure;
            	
            end if;
          
                --NULL; -- original code

          ELSIF GET_GROUP_CHAR_CELL ('CCWPA_ITEM_TO_EXP_TYPE_RG2.exp_type', 1) <> ccwpa_iet_expenditure_type THEN
         
          	
          	--ADDED BY VINEET 11/11/04
          	-- copy(ccwpa_iet_expenditure_type,'DISTRIBUTIONS.EXPENDITURE_TYPE');
          	--requisitions
          	if form_name = 'POXRQERQ' AND block_name = 'DISTRIBUTIONS' then
          	copy(GET_GROUP_CHAR_CELL('CCWPA_ITEM_TO_EXP_TYPE_RG2.exp_type', 1),'DISTRIBUTIONS.EXPENDITURE_TYPE');
          	end if;
          	--purchase orders
          --	if form_name = 'POXPOEPO' AND block_name = 'PO_DISTRIBUTIONS' then
          		if form_name = 'POXPOEPO' AND block_name = 'PO_DISTRIBUTIONS' and NAME_IN ('PO_HEADERS.ATTRIBUTE5') != 'WIRELINE-ESS' then--Added by kavya for ESS
          	copy(GET_GROUP_CHAR_CELL('CCWPA_ITEM_TO_EXP_TYPE_RG2.exp_type', 1),'PO_DISTRIBUTIONS.EXPENDITURE_TYPE');
          	end if;
          	--releases
          	if form_name = 'POXPOERL' AND block_name = 'PO_DISTRIBUTIONS' then
          	copy(GET_GROUP_CHAR_CELL('CCWPA_ITEM_TO_EXP_TYPE_RG2.exp_type', 1),'PO_DISTRIBUTIONS.EXPENDITURE_TYPE');
          	end if;
          	-- end of code added by vineet 11/11/04
         
                copy('Y', 'GLOBAL.ITEM_EXP_TYPE_TESTED');
              /*
                -- if exp types do not match, error out with a custom message
                fnd_message.set_name('CCWPA', 'CCWPA_ITEM_TO_EXP_TYPE_ERROR');
                fnd_message.set_token('ITEM_NO', ccwpa_iet_item_number);
                fnd_message.set_token('EXP_TYPE', GET_GROUP_CHAR_CELL ('CCWPA_ITEM_TO_EXP_TYPE_RG.exp_type', 1));
                fnd_message.error;
                RAISE form_trigger_failure;
               */
                --fnd_message.set_string('Expenditure Type Updated'); Commented out 01/06 for Clariify Ticket 
                  -- 20051128_01785  RGC
                --fnd_message.show;
                
          ELSE	
                copy('Y', 'GLOBAL.ITEM_EXP_TYPE_TESTED');
                
          END IF;	
						      
		   END IF;	

    END IF;

    -- This initializes the value of the global by retrieving the record status
    IF ((form_name = 'POXRQERQ' AND block_name = 'LINES') OR 
    	--(form_name = 'POXPOEPO' AND block_name = 'PO_LINES')) 
    	(form_name = 'POXPOEPO' and NAME_IN ('PO_HEADERS.ATTRIBUTE5') != 'WIRELINE-ESS' AND block_name = 'PO_LINES'))  --Added by kavya for ESS
    	  AND event_name = 'WHEN-NEW-RECORD-INSTANCE' 
    	  AND name_in('system.record_status') NOT IN ('INSERT') THEN
			
			 --fnd_message.DEBUG('WNRI-L-Status:no insert.');
			 
       copy('N', 'GLOBAL.ITEM_EXP_TYPE_TESTED');
       
    END IF;

    -- The global value is used to disallow a user to change the item after exp type match was performed
    -- Note: for saved records, standard Oracle does not allow a user to change the item so this
    --       is needed to be done only for uncommitted records
    --       Also, this is not an issue for Releases because Items are not picked there
    IF ((form_name = 'POXRQERQ' AND block_name = 'LINES' AND item_name = 'LINES.ITEM_NUMBER') OR 
    	 -- (form_name = 'POXPOEPO' AND block_name = 'PO_LINES' AND item_name = 'PO_LINES.ITEM_NUMBER'))
    	  (form_name = 'POXPOEPO' AND NAME_IN('PO_HEADERS.ATTRIBUTE5') != 'WIRELINE-ESS' AND block_name = 'PO_LINES' AND item_name = 'PO_LINES.ITEM_NUMBER')) --Added by kavya for ESS
    	 AND event_name = 'WHEN-NEW-ITEM-INSTANCE'
    	 AND name_in('system.record_status') IN ('INSERT') THEN

       --fnd_message.DEBUG('WNII-L-L.Item_number-Status:I.');
       
       IF form_name = 'POXRQERQ' THEN

             ccwpa_iet_item_number := name_in('lines.item_number');
             ccwpa_iet_item_category := 'lines.item_category';
       
       ELSIF form_name = 'POXPOEPO' THEN
       	
             ccwpa_iet_item_number := name_in('po_lines.item_number');
             ccwpa_iet_item_category := 'po_lines.item_category';
             
       END IF;
       
       IF ccwpa_iet_item_number IS NOT NULL AND NVL(name_in('GLOBAL.ITEM_EXP_TYPE_TESTED'), 'N') = 'Y'  THEN
       	 
          fnd_message.set_name('CCWPA', 'CCWPA_ITEM_TO_EXP_TYPE_NOTE');
					fnd_message.show;
					go_item(ccwpa_iet_item_category);
          -- The below methods were tried but did not work since standard form code gets executed after their invocation
          --fnd_key_flex.update_definition (BLOCK  => 'LINES',
          --                                FIELD  => 'ITEM_NUMBER',
          --                                ENABLED => 'N');
  	   		--app_item_property2.set_property('lines.item_number', ENABLED, PROPERTY_OFF);
  	   END IF;				

    END IF;
-- Cingular Enhancement CRP3: FMG.XXX - "Item to Expenditure Type Mapping" ends

/****************************************************************************************
 *Cingular Enhancement :PRG.06 Require POET fields for 'Capital Items/Account' for CRP3
 
 * CALLED BY
 *   Purchase Order, Requsitions ,PO Releases
 *
 * LAST UPDATE DATE   10-Jun-2003
 *
 *
 * HISTORY
 * =======
 *
 * VERSION DATE        AUTHOR(S)       DESCRIPTION
 * ------- ----------- --------------- ------------------------------------
 * 1.00    10-Jun-2003 Gunaseelan M    Creation
 * 1.1		 20-Aug-2003 Gunaseelan M	   Modified
 * 1.2     01-Oct-2003 Gunaseelan M    Modified as per CR149 
 * 1.3     11-nOV-2003 Gunaseelan M	   Modified as per CR's 1241-1243
 * <v.nr>  dd-mon-yyyy <Name author>   <Modification description>
 *
 * <additional records for modifications>
 * 
 * Caution: Please do not delete the code, have the piece code in CUSTOM.pll always in the
 *          procedure 'event'.
 ***************************************************************************************/
 
 /*********************** Start of code PRG.06 ***********************************/

DECLARE
		 v_pocharge						VARCHAR2(81) DEFAULT NULL;
		 v_project						VARCHAR2(30) DEFAULT NULL;
		 v_item_desc					VARCHAR2(81) DEFAULT NULL;		 
		 v_item_id						NUMBER;                     --Added for CR149
		 v_org_id							NUMBER;                     --Added for CR149
		 v_capital_item				VARCHAR2(1)  DEFAULT NULL;  --Added for CR149
		 v_project_id         NUMBER;                     --Added for CR149
		 v_location           VARCHAR2(30) DEFAULT NULL;  --Added for CR149
		 v_valid_location     VARCHAR2(1)  DEFAULT NULL;  --Added for CR149       
		          
BEGIN

/* PO Core Data Entry form & PO Release Data Entry Form */
	IF ( event_name = 'WHEN-VALIDATE-RECORD') THEN 
		
				  					  					  	 
		IF ((--form_name = 'POXPOEPO' 
				(form_name = 'POXPOEPO' and NAME_IN ('PO_HEADERS.ATTRIBUTE5') != 'WIRELINE-ESS')--Added by kavya for ESS
			 OR form_name = 'POXPOERL') AND 
			  (block_name = 'PO_DISTRIBUTIONS' OR block_name = 'PO_SHIPMENTS')) THEN
			  
			v_pocharge := NAME_IN('PO_DISTRIBUTIONS.CHARGE_ACCOUNT_FLEX');
			v_project  := NAME_IN('PO_DISTRIBUTIONS.PROJECT');
      -- Check for the account segments entered by users in GUI for 'Capital Account'
			IF (SUBSTR(v_pocharge,6,4) LIKE('15__') OR  SUBSTR(v_pocharge,6,4) LIKE('16__') OR  SUBSTR(v_pocharge,6,4) LIKE('17__')) AND v_project IS NULL THEN --2
				-- Assign the Item Description to pass on to GUI error message (05/05/06 Added Accumulated Depriciation account to validation check above  pg17_accum_dep_acc -Pranay) 
				IF form_name = 'POXPOEPO' THEN --3
					v_item_desc := NAME_IN('PO_LINES.ITEM_NUMBER');
				ELSIF form_name = 'POXPOREL' THEN --3
					v_item_desc := NAME_IN('PO_SHIPMENTS.ITEM_NUM');
				END IF; --3
				-- Set the messge and assign the item description 
				FND_MESSAGE.SET_NAME('CCWPO','CW_PO_POET_WF_MSG');
        FND_MESSAGE.SET_TOKEN('ITEM',v_item_desc);
        FND_MESSAGE.ERROR;
				RAISE form_trigger_failure;
			END IF; --2
			/**************************************************************************
			*      Enhancement CR149 to validate the project and location in PO, REL  *
			**************************************************************************
	  ****************************************************************************
	  *    Changes have been made to this block of code by RGC in order to resovle clarify ticket
	  *    #20040924_00316.  The block name was added to the IF statements along with changing
	  *    the ORG_ID's that the code looks at for the variable v_org_id.
		****************************************************************************************/	
			-- Get the Item & Org from GUI
			--changes to add paranthesis on the block names by Mayuri 10/27/06
			--IF form_name = 'POXPOEPO' and block_name = 'PO_LINES' OR block_name = 'PO_DISTRIBUTIONS' THEN
			IF --form_name = 'POXPOEPO' 
				(form_name = 'POXPOEPO' and NAME_IN ('PO_HEADERS.ATTRIBUTE5') != 'WIRELINE-ESS')--Added by kavya for ESS
				and (block_name = 'PO_LINES' OR block_name = 'PO_DISTRIBUTIONS') THEN
				 
				v_item_id := NAME_IN('PO_LINES.ITEM_ID');
				--v_org_ig := NAME_IN('PO_DISTRIBUTIONS.DESTINATION_ORGANIZATION_ID');			
			ELSIF form_name = 'POXPOERL' and block_name = 'PO_SHIPMENTS' THEN
				v_item_id := NAME_IN('PO_SHIPMENTS.ITEM_ID');			
				--v_org_id  := NAME_IN('PO_SHIPMENTS.SHIP_TO_ORGANIZATION_ID');
			END IF;
			
			v_org_id  := NAME_IN('PO_STARTUP_VALUES.ORG_ID'); 
			
			IF (v_item_id IS NOT NULL AND v_org_id IS NOT NULL) THEN --4
			   -- Check for the line Item is defined as Capital Item for the organization
			   CW_PO_POET_WF_PKG.CAPITAL_ITEM(v_item_id,v_org_id,v_capital_item);

				IF v_capital_item = 'T' AND v_project IS NOT NULL THEN --5
					-- Get the project ID and Location ID from GUI
					v_project_id   := NAME_IN('PO_DISTRIBUTIONS.PROJECT_ID');
					
			
					
					-- Assign the ship to location if the deliver to location is NULL
					v_location := NVL(NAME_IN('PO_DISTRIBUTIONS.DELIVER_TO_LOCATION'),NAME_IN('PO_SHIPMENTS.SHIP_TO_LOCATION_CODE'));
					
					-- Check the location is valid
					CW_PO_POET_WF_PKG.VALID_LOCATION(v_project_id,v_location,v_valid_location);
					
					--FND_MESSAGE.SET_STRING('Project :'||v_project||' Location :'||v_location||' Valid:'||v_valid_location);
          --FND_MESSAGE.show;
       
/*  START Sue Gibson 19-JUN-08 		commented out block as it duplicates code in separate location/project validation block below
-- start Sue Gibson 15-AUG-07 allow change to project, then make ship-to location change to match; see validation
    --	 IF 	v_location IS NOT NULL AND v_project_id IS NOT NULL  THEN  
	   	 IF 	v_location   IS NOT NULL AND 
	   	 	    v_project_id IS NOT NULL AND
	   	 	    NAME_IN('PO_SHIPMENTS.SHIP_TO_LOCATION_CODE') IS NOT NULL THEN    
-- end 15-AUG-07	   	 	
	   			-- If the location is not valid then stop user saving the distributions
					-- Show an error message
					IF v_valid_location = 'F' THEN --6
						-- Set the messge and assign the Location description 
						
					  FND_MESSAGE.SET_STRING('Ship-To/Deliver-To Location'||''''||v_location||''''||' is not valid for Project '||''''||v_project||'''');
        		FND_MESSAGE.ERROR;
						RAISE form_trigger_failure;
					END IF;--6
	   			END IF; 
END 19-JUN-08  */	   			
	   	 END IF;--5
	   	 END IF; --4
		
			/*************************************************************************
			*     Enhancement CR149 to validate the project and location in PO, REL  *
			*************************************************************************/
		END IF;--1
	END IF;
		END;

------------------------------------------------------------------------------------------
/* PO Requisition Data Entry form */


DECLARE
		 v_pocharge						 VARCHAR2(81) DEFAULT NULL;
		 v_project						 VARCHAR2(30) DEFAULT NULL;
		 v_item_desc					 VARCHAR2(81) DEFAULT NULL;		 
		 v_item_id						 NUMBER;                      --Added for CR149
		 v_org_id							 NUMBER;                      --Added for CR149
		 v_capital_item				 VARCHAR2(1)  DEFAULT NULL;   --Added for CR149
		 v_project_id          NUMBER := 0;                      --Added for CR149
		 v_location            VARCHAR2(30) DEFAULT NULL;   --Added for CR149
		 v_valid_location      VARCHAR2(1)  DEFAULT NULL;   --Added for CR149
		 v_rec_status			     varchar2(100);
		 v_line_num            NUMBER;
		 v_proj_id 			       number;	

		 
		  v2_project				VARCHAR2(30)  := NULL;
			v2_project_id	   	NUMBER; 

			--Additional Validation for location code based on project id in Po requistion Form
			--Date March 20 2006. Vijay & Salman  
  	  vv_project 				varchar2(100);
		  vv_LINE_NUM  			NUMBER;  
BEGIN	  				  	

	IF        (form_name  = 'POXDOPRE'      AND 
	          block_name = 'PO_DEFAULTS'  
	          --AND item_name = ('PO_DEFAULTS.PROJECT')
	          )  
	          THEN  
	         proj_pref_num   := NAME_IN('PO_DEFAULTS.PROJECT');
           proj_pref_id    := NAME_IN('PO_DEFAULTS.PROJECT_ID');
          -- v_user_id			 := fnd_global.user_id;
 --          FND_MESSAGE.SET_STRING('Checking Values:  '||v_login_id);
 --						fnd_message.show;
           
					 CCW_LOCATION_PROJECT_NUM(proj_pref_num, proj_pref_id, v_login_id);

	END IF;
 
	IF    (event_name = 'WHEN-VALIDATE-RECORD'     OR 
				 event_name = 'WHEN-NEW-RECORD-INSTANCE' OR 
				 event_name = 'ZOOM'                     OR
				 event_name = 'WHEN-NEW-ITEM-INSTANCE')         
		AND
		 		     (form_name  = 'POXRQERQ'                
		 		 AND (block_name = 'DISTRIBUTIONS' OR block_name = 'LINES' OR block_name = 'PO_REQ_HDR'))                    
		AND (name_in('system.record_status') IN ('INSERT','CHANGED','NEW'))THEN	
		 	 
			   --fnd_message.DEBUG('WNRI or WVR.');
			   
			   v_pocharge := NAME_IN('DISTRIBUTIONS.CHARGE_ACCOUNT_FLEX');
		  	 v_project  := NAME_IN('DISTRIBUTIONS.PROJECT');
		  		  	 
		  	 	-- Get the Item & Org from GUI
		     v_item_id := NAME_IN('LINES.ITEM_ID');
		     
		     v_line_num := NAME_IN('LINES.LINE_NUM');
		     			
			 --v_org_id  := NAME_IN('PO_STARTUP_VALUES.ORG_ID');  Commented out for clarify ticket #20040924_00316  Resley Cole 03/05
			
		     v_org_id  := NAME_IN('LINES.DEST_ORGANIZATION_ID');  --Added for clarify ticket #20040924_00316  Resley Cole 03/05					
			
			-- Check for the accoutn segments entered by users in GUI for 'Capital Account'
--	Sue Gibson 11/14/06		IF (SUBSTR(v_pocharge,6,4) LIKE('15__') OR  SUBSTR(v_pocharge,6,4) LIKE('16__') OR  SUBSTR(v_pocharge,6,4) LIKE('17__')) AND v_project IS NULL THEN
			IF (SUBSTR(v_pocharge,6,4) LIKE ('15%') OR      -- sg1457
				  SUBSTR(v_pocharge,6,4) LIKE ('16%') OR      -- sg1457
				  SUBSTR(v_pocharge,6,4) LIKE ('17%'))   AND  -- sg1457
				  v_project IS NULL                            THEN
				-- Assign the Item Description to pass on to GUI error message
				v_item_desc := NAME_IN('LINES.ITEM_NUMBER');
			  -- Set the messge and assign the item description 
        FND_MESSAGE.SHOW;  
			  RAISE form_trigger_failure;
			END IF;
       

			/*************************************************************************
			*      Enhancement CR149 to validate the project and location in REQ     *
			*************************************************************************/	 
      --	FND_MESSAGE.SET_STRING('Checking after IF PROJECT IS NULL:  '||proj_pref_id||'-'|| proj_pref_num);
		--	  fnd_message.show;

			IF (v_item_id IS NOT NULL AND v_org_id IS NOT NULL) THEN
			   -- Check for the line Item is defined as Capital Item for the organization
			   CW_PO_POET_WF_PKG.CAPITAL_ITEM(v_item_id,v_org_id,v_capital_item);
				
				 -----------------------------------------------------------------
		   --Additional Validation for location code based on project id in Po requistion Form
			   --Date March 20 2006. Vijay & Salman 
			   vv_project := name_in('PO_REQ_HDR.SEGMENT1');
			   vv_LINE_NUM := name_in('LINES.LINE_NUM');  

--  new message string added 08/08/06
--	FND_MESSAGE.SET_STRING('Checking before IF V_PROJECT IS NULL:  '||proj_pref_id||'-'|| proj_pref_num);
--	fnd_message.show;
						   
			   IF V_PROJECT IS NULL THEN

--			FND_MESSAGE.SET_STRING('Checking after IF PROJECT IS NULL:  '||proj_pref_id||'-'|| proj_pref_num);
---			fnd_message.show;
			   	
			   		begin
			   		select 
						pap.project_id,PAP.SEGMENT1 INTO V_PROJECT_id,v_project
						FROM po.PO_REQUISITION_HEADERS_ALL prh
						,po.po_REQUISITION_lines_all prl
						,po.PO_REQ_DISTRIBUTIONS_ALL prd 
						,pa.pa_projects_all pap
						WHERE prh.REQUISITION_HEADER_ID = prl.REQUISITION_HEADER_ID
						AND prl.REQUISITION_LINE_ID = prd.REQUISITION_LINE_ID 
						AND prd.project_id = pap.project_id
						and prh.segment1 =  vv_project 
						and prl.line_num = vv_line_num;
			   		exception
			   		when no_data_found
			   		then 
			   		begin
			   		select project_id, project_num 
			   		into v_project_id, v_project 
			   		from ccw_location_project 
			   		where login_id = v_login_id;
			   		
			   		exception 
			   			when no_data_found then null;
			   	  end;
--						FND_MESSAGE.SET_STRING('Checking after no data found: '||v_project||'-'||v_project_id);
--						fnd_message.show;	
			   		when others then
--			FND_MESSAGE.SET_STRING('Checking after when other exc: '||v_project||'-'||v_project_id);
--			fnd_message.show;		   		
			   		null;
			   		end;
		    	END IF;  
				 -----------------------------------------------------------------			
			   
				IF v_capital_item = 'T' AND v_project IS NOT NULL THEN
					-- Get the project ID and Location ID from GUI					
					v_project_id   := NAME_IN('DISTRIBUTIONS.PROJECT_ID');				

				 -----------------------------------------------------------------
			   --Additional Validation for location code based on project id in Po requistion Form
			   --Date March 20 2006. Vijay & Salman 
				if v_project_id is null then
						begin
			   		select 
						pap.project_id INTO V_PROJECT_id
						FROM po.PO_REQUISITION_HEADERS_ALL prh
						,po.po_REQUISITION_lines_all prl
						,po.PO_REQ_DISTRIBUTIONS_ALL prd 
						,pa.pa_projects_all pap
						WHERE prh.REQUISITION_HEADER_ID = prl.REQUISITION_HEADER_ID
						AND prl.REQUISITION_LINE_ID = prd.REQUISITION_LINE_ID 
						AND prd.project_id = pap.project_id
						and prh.segment1 =  vv_project 
						and prl.line_num = vv_line_num;
						exception
						when no_data_found
						then
						begin 
			   		select project_id into v_project_id from ccw_location_project where login_id = v_login_id;
						exception when no_data_found then null;
							end;
--			FND_MESSAGE.SET_STRING('Checking after when no data found: '||'-'||v_project_id);
--			fnd_message.show;	   			
			   		when others then
--			FND_MESSAGE.SET_STRING('Checking after when others: '||'-'||v_project_id);
--			fnd_message.show;	
  		null;
			   		end;
			   	end if;   
				 -----------------------------------------------------------------
					
					-- Assign the deliver to location
					v_location := NAME_IN('LINES.DELIVER_TO_LOCATION');	
					IF block_name = 'LINES' OR block_name = 'DISTRIBUTIONS'   THEN
						   	 		IF 	v_location IS NOT NULL AND v_project_id IS NOT NULL THEN
					-- Check the location is valid					
       		CW_PO_POET_WF_PKG.VALID_LOCATION(v_project_id,v_location,v_valid_location);        	   	  
					-- If the location is not valid then stop user saving the distributions
					-- Show an error message
					IF					 v_valid_location = 'F' THEN						 
						-- Set the messge and assign the Location description 
					   --Set_Menu_Item_Property('FILE.SAVE', ENABLED, PROPERTY_FALSE );
					  FND_MESSAGE.SET_STRING('Deliver-To Location - Line Number '||''''||v_location||'-'||to_char(vv_line_num)||''''||' is not valid for Project '||''''||v_project||'''');
				--	 FND_MESSAGE.SET_STRING('Deliver-To Location - Line Number '||''''||v_location||' is not valid for Project '||''''||v_project||'''');
        		FND_MESSAGE.ERROR;
        	--	copy(NULL, 'LINES.DELIVER_TO_LOCATION');
 						RAISE form_trigger_failure;
END IF;
END IF;
	   	 		END IF;
	   	 		
 	 		
        END IF;
        END IF;
				END IF;
						
END;



		
/*************************************************************************
*      Enhancement CR149 to validate the project and location in REQ     *
*************************************************************************/

/*********************************************************************************
*     START of Clarify ticket #20050419_02101 
      Project and Location validation.                 04/05 RGC
*********************************************************************************/
--Start of validation of PROJECT in the Preference form
DECLARE
	
form_name       VARCHAR2(30)  := name_in('system.current_form');
block_name      VARCHAR2(30)  := name_in('system.cursor_block');
item_name				VARCHAR2(90)  := name_in('system.cursor_item');
v1_project_id    NUMBER;
s1_rg_query      VARCHAR2(2000):= 'SELECT * 
                                   FROM   CUSTOM_PROJ_LOV_V 
                                   WHERE  LOCATION_CODE = :PO_DEFAULTS.S_DELIVER_TO_LOCATION';                 
rq1_rg_id        RECORDGROUP;                           
new1_rq_rg_id    NUMBER;
rq1_group_name   VARCHAR2(30) := 'PROJECT_NUM';
v1_project       VARCHAR2(30) := NULL; 		
v1_location      VARCHAR2(30) := NULL;
v1_location_id   VARCHAR2(30) := NULL;
v1_valid_location VARCHAR2(30) := NULL;
v1_ship_location VARCHAR2(30) := NULL;    --added by salman 10/17/06
v1_ship_loc_id   VARCHAR2(30) := NULL;    -- added by salman

BEGIN

--new code start (salman 7/21/06)   --this is for preference form , locations validation.
	
	IF         (form_name  = 'POXDOPRE'      AND 
	          block_name = 'PO_DEFAULTS'   AND
	          event_name = 'WHEN-NEW-ITEM-INSTANCE'  AND 
	     ---     item_name = ('PO_DEFAULTS.CURRENCY_CODE')  AND        
	     --10/17/06  name_in('PO_DEFAULTS.S_DELIVER_TO_LOCATION')IS NOT NULL) THEN
	         (name_in('PO_DEFAULTS.S_DELIVER_TO_LOCATION')IS NOT NULL
	          OR name_in('PO_DEFAULTS.SHIP_TO_LOCATION')IS NOT NULL         
	          )) THEN
    
	          v1_project       := NAME_IN('PO_DEFAULTS.PROJECT');	
            v1_project_id    := NAME_IN('PO_DEFAULTS.PROJECT_ID');
            v1_location      := NAME_IN('PO_DEFAULTS.S_DELIVER_TO_LOCATION'); 
	          v1_location_id   := NAME_IN('PO_DEFAULTS.S_DELIVER_TO_LOCATION_ID');  
	          v1_ship_location := NAME_IN('PO_DEFAULTS.SHIP_TO_LOCATION');   --10/17/06
						v1_ship_loc_id   := NAME_IN('PO_DEFAULTS.SHIP_TO_LOCATION_ID'); --10/17/06 salman
	        
	    IF  v1_location IS NOT NULL AND v1_project IS NOT NULL THEN 
	    	
	    	CW_PO_POET_WF_PKG.VALID_LOCATION(v1_project_id,v1_location,v1_valid_location);        	   	  
					-- If the location is not valid then stop user saving the distributions
					-- Show an error message
					IF					 v1_valid_location = 'F' THEN						 
						-- Set the messge and assign the Location description 
					   --Set_Menu_Item_Property('FILE.SAVE', ENABLED, PROPERTY_FALSE );
				--	  FND_MESSAGE.SET_STRING('Deliver-To Location - Line Number '||''''||v_location||'-'||to_char(vv_line_num)||''''||' is not valid for Project '||''''||v_project||'''');
					 FND_MESSAGE.SET_STRING('Pref. Deliver-To Location '||''''||v1_location||' is not valid for Project '||''''||v1_project||'''   Please Re-Enter Valid Location before saving Preferences');
        		FND_MESSAGE.ERROR;
					copy(NULL, 'PO_DEFAULTS.S_DELIVER_TO_LOCATION');
					---	copy(NULL, 'PO_DEFAULTS.PROJECT');
						RAISE form_trigger_failure;
						            
					END IF;
					END IF;	
					
--salman 10/17/06

--new code to make changes for ship to location
	    IF  v1_ship_location IS NOT NULL AND v1_project IS NOT NULL THEN 
	    	
--					FND_MESSAGE.SET_STRING('Checking value for ship_to_location and id after IF : '||v1_ship_location||'-'||v1_ship_loc_id);
--					fnd_message.show;	    	
					
	    	CW_PO_POET_WF_PKG.VALID_LOCATION(v1_project_id,v1_ship_location,v1_valid_location);        	   	  
					-- If the location is not valid then stop user saving the distributions
					-- Show an error message
					IF					 v1_valid_location = 'F' THEN						 
						-- Set the messge and assign the Location description 
					   --Set_Menu_Item_Property('FILE.SAVE', ENABLED, PROPERTY_FALSE );
				--	  FND_MESSAGE.SET_STRING('Deliver-To Location - Line Number '||''''||v_location||'-'||to_char(vv_line_num)||''''||' is not valid for Project '||''''||v_project||'''');
					 FND_MESSAGE.SET_STRING('Pref. Ship-To Location '||''''||v1_ship_location||' is not valid for Project '||''''||v1_project||'''   Please Re-Enter Valid Location before saving Preferences');
        		FND_MESSAGE.ERROR;
					copy(NULL, 'PO_DEFAULTS.SHIP_TO_LOCATION');
					---	copy(NULL, 'PO_DEFAULTS.PROJECT');
						RAISE form_trigger_failure;
						            
					END IF;
					END IF;
---new code end							
					
					END IF;
--new code end (salman 7/21/06)

		
	
	
IF         (form_name  = 'POXDOPRE'      AND 
	          block_name = 'PO_DEFAULTS'   AND
	          event_name = 'WHEN-NEW-ITEM-INSTANCE'  AND 
	          item_name = ('PO_DEFAULTS.PROJECT')  AND        
	          name_in('PO_DEFAULTS.S_DELIVER_TO_LOCATION')IS NOT NULL) THEN
    
	          v1_project       := NAME_IN('PO_DEFAULTS.PROJECT');	
            v1_project_id    := NAME_IN('PO_DEFAULTS.PROJECT_ID');
            v1_location      := NAME_IN('PO_DEFAULTS.S_DELIVER_TO_LOCATION'); 
	          v1_location_id   := NAME_IN('PO_DEFAULTS.S_DELIVER_TO_LOCATION_ID');  
	          
	    IF  v1_location IS NOT NULL AND v1_project IS NOT NULL THEN 
	    	
	    	CW_PO_POET_WF_PKG.VALID_LOCATION(v1_project_id,v1_location,v1_valid_location);        	   	  
					-- If the location is not valid then stop user saving the distributions
					-- Show an error message
					IF					 v1_valid_location = 'F' THEN						 
						-- Set the messge and assign the Location description 
					   --Set_Menu_Item_Property('FILE.SAVE', ENABLED, PROPERTY_FALSE );
				--	  FND_MESSAGE.SET_STRING('Deliver-To Location - Line Number '||''''||v_location||'-'||to_char(vv_line_num)||''''||' is not valid for Project '||''''||v_project||'''');
					 FND_MESSAGE.SET_STRING('Pref. Deliver-To Location '||''''||v1_location||' is not valid for Project '||''''||v1_project||'''');
        		FND_MESSAGE.ERROR;
        		RAISE form_trigger_failure;            
        END IF;
          rq1_rg_id     := find_group('PROJECT_NUM'); 	     	        
	        
          Delete_Group_Row(rq1_rg_id, ALL_ROWS);    
              
          new1_rq_rg_id := POPULATE_GROUP_WITH_QUERY(rq1_rg_id,s1_rg_query);       
               
          SET_LOV_COLUMN_PROPERTY('PROJECT_NUM',1,TITLE,'Project Number');
          SET_LOV_COLUMN_PROPERTY('PROJECT_NUM',1,WIDTH,1);
          
          SET_LOV_COLUMN_PROPERTY('PROJECT_NUM',2,TITLE,'Project Name');
          SET_LOV_COLUMN_PROPERTY('PROJECT_NUM',2,WIDTH,2);
                                       
          SET_LOV_COLUMN_PROPERTY('PROJECT_NUM',3,TITLE,'Start Date');         
          SET_LOV_COLUMN_PROPERTY('PROJECT_NUM',3,WIDTH,1); 
          
          SET_LOV_COLUMN_PROPERTY('PROJECT_NUM',4,TITLE,'Completion Date');         
          SET_LOV_COLUMN_PROPERTY('PROJECT_NUM',4,WIDTH,1);
          
          SET_LOV_COLUMN_PROPERTY('PROJECT_NUM',5,TITLE,'PROJECT_ID');         
          SET_LOV_COLUMN_PROPERTY('PROJECT_NUM',5,WIDTH,0);
          
          SET_LOV_PROPERTY('PROJECT_NUM',AUTO_REFRESH,PROPERTY_FALSE);     
END IF; 
END IF;       
          	
END;
--End of validation of PROJECT in the Preference form

--Start of validation of LOCATION in the Preference form
/*
DECLARE
	
form_name       VARCHAR2(30)  := name_in('system.current_form');
block_name      VARCHAR2(30)  := name_in('system.cursor_block');
item_name				VARCHAR2(90)  := name_in('system.cursor_item');
v2_project_id    NUMBER;
s2_rg_query      VARCHAR2(2000):= 'SELECT * 
                                   FROM   CUSTOM_DELLOC_LOV_V 
                                   WHERE  PROJECT_ID  = :PO_DEFAULTS.PROJECT_ID';                 
rq2_rg_id        RECORDGROUP;                           
new2_rq_rg_id    NUMBER;
rq2_group_name   VARCHAR2(30) := 'PO_DELIVER_TO_LOCATION';
v2_project       VARCHAR2(30) DEFAULT NULL; 		
v2_location      VARCHAR2(30) DEFAULT NULL;
v2_location_id   VARCHAR2(30) DEFAULT NULL;

BEGIN

IF         (form_name  = 'POXDOPRE'      AND 
	          block_name = 'PO_DEFAULTS'   AND
	          event_name = 'WHEN-NEW-ITEM-INSTANCE'  AND
	          item_name = ('PO_DEFAULTS.S_DELIVER_TO_LOCATION')  AND          
	          name_in('PO_DEFAULTS.PROJECT')IS NOT NULL) THEN  
	         
	          v2_project       := NAME_IN('PO_DEFAULTS.PROJECT');	
            v2_project_id    := NAME_IN('PO_DEFAULTS.PROJECT_ID');
            v2_location      := NAME_IN('PO_DEFAULTS.S_DELIVER_TO_LOCATION'); 
	          v2_location_id   := NAME_IN('PO_DEFAULTS.S_DELIVER_TO_LOCATION_ID');
	          
IF     	  v2_project IS NOT NULL THEN
	 	 
          rq2_rg_id     := find_group('PO_DELIVER_TO_LOCATION'); 	     	        
	        
          Delete_Group_Row(rq2_rg_id, ALL_ROWS);    
              
          new2_rq_rg_id := POPULATE_GROUP_WITH_QUERY(rq2_rg_id,s2_rg_query);       
               
          SET_LOV_COLUMN_PROPERTY('PO_DELIVER_TO_LOCATION',1,TITLE,'Location_Num');
          SET_LOV_COLUMN_PROPERTY('PO_DELIVER_TO_LOCATION',1,WIDTH,1);
          
          SET_LOV_COLUMN_PROPERTY('PO_DELIVER_TO_LOCATION',2,TITLE,'Location_ID');
          SET_LOV_COLUMN_PROPERTY('PO_DELIVER_TO_LOCATION',2,WIDTH,0);
                                       
          SET_LOV_COLUMN_PROPERTY('PO_DELIVER_TO_LOCATION',3,TITLE,'Comp_Code / Description / Street Address / Loc Type / Eng Cell');         
          SET_LOV_COLUMN_PROPERTY('PO_DELIVER_TO_LOCATION',3,WIDTH,10);  
          
          SET_LOV_PROPERTY('PO_DELIVER_TO_LOCATION',AUTO_REFRESH,PROPERTY_FALSE);       
END IF; 
END IF;       
          	
END;
--End of validation of LOCATION in the Preference form

/*
--Start of validation of PROJECT in the Requisition form
DECLARE
	
form_name        VARCHAR2(30)  := NAME_IN('system.current_form');
block_name       VARCHAR2(30)  := NAME_IN('system.cursor_block');
item_name				 VARCHAR2(90)  := NAME_IN('system.cursor_item');
v3_project_id    NUMBER        := NULL;
s3_rg_query      VARCHAR2(2000):= 'SELECT * 
                                   FROM CUSTOM_PROJ_LOV_V 
                                   WHERE LOCATION_CODE = :LINES.DELIVER_TO_LOCATION';                 
rq3_rg_id        RECORDGROUP;                           
new3_rq_rg_id    NUMBER;
rq3_group_name   VARCHAR2(30) := 'PROJECT_NUM';
v3_project       VARCHAR2(30) := NULL;		
v3_location      VARCHAR2(30);
v3_location_id   NUMBER;
v3_task          VARCHAR2(30) := NULL;

BEGIN

IF          
	          (event_name = 'WHEN-NEW-RECORD-INSTANCE'                  AND
	          (form_name  = 'POXRQERQ'                                AND 
	          (block_name = 'LINES' OR block_name = 'DISTRIBUTIONS')  AND	
	           item_name  = 'DISTRIBUTIONS.PROJECT') )                THEN  
	           
          v3_location    := NAME_IN('LINES.DELIVER_TO_LOCATION'); 
	        v3_location_id := NAME_IN('LINES.DELIVER_TO_LOCATION_ID');
	        v3_project     := NAME_IN('DISTRIBUTIONS.PROJECT');	
          v3_project_id  := NAME_IN('DISTRIBUTIONS.PROJECT_ID');
          v3_task        := NAME_IN('DISTRIBUTIONS.TASK'); 

IF        v3_project IS NOT NULL THEN	
	   	
          rq3_rg_id      := find_group('PROJECT_NUM'); 	     	        
	        
          Delete_Group_Row(rq3_rg_id,ALL_ROWS);    
              
          new3_rq_rg_id  := POPULATE_GROUP_WITH_QUERY(rq3_rg_id,s3_rg_query);       
               
          SET_LOV_COLUMN_PROPERTY('PROJECT_NUM',1,TITLE,'Project Number');
          SET_LOV_COLUMN_PROPERTY('PROJECT_NUM',1,WIDTH,1);
          
          SET_LOV_COLUMN_PROPERTY('PROJECT_NUM',2,TITLE,'Project Name');
          SET_LOV_COLUMN_PROPERTY('PROJECT_NUM',2,WIDTH,2);
                                       
          SET_LOV_COLUMN_PROPERTY('PROJECT_NUM',3,TITLE,'Start Date');         
          SET_LOV_COLUMN_PROPERTY('PROJECT_NUM',3,WIDTH,1); 
          
          SET_LOV_COLUMN_PROPERTY('PROJECT_NUM',4,TITLE,'Completion Date');         
          SET_LOV_COLUMN_PROPERTY('PROJECT_NUM',4,WIDTH,1);
          
          SET_LOV_COLUMN_PROPERTY('PROJECT_NUM',5,TITLE,'Project ID');         
          SET_LOV_COLUMN_PROPERTY('PROJECT_NUM',5,WIDTH,0);          
          
          SET_LOV_PROPERTY('PROJECT_NUM',AUTO_REFRESH,PROPERTY_FALSE);        
END IF; 
END IF;
END;
--End of validation of PROJECT in the Requisition form

--Start of validation of LOCATION in the Requisition form
DECLARE	
form_name        VARCHAR2(30)  := name_in('system.current_form');
block_name       VARCHAR2(30)  := name_in('system.cursor_block');
item_name				 VARCHAR2(90)  := name_in('system.cursor_item');
v4_project_id    NUMBER        := NULL;
v4_project2_id   NUMBER        := NULL;
s4_rg_query      VARCHAR2(2000):= 'SELECT * 
                                   FROM   CUSTOM_DELLOC_LOV_V 
                                   WHERE  PROJECT_ID = :DISTRIBUTIONS.PROJECT_ID';                             
rq4_rg_id        RECORDGROUP;                           
new4_rq_rg_id    NUMBER;
rq4_group_name   VARCHAR2(30)  := 'DELIVER_TO_LOCATION';
v4_project       VARCHAR2(30)  := NULL; 		
v4_location      VARCHAR2(30);
v4_location_id   VARCHAR2(30);
v4_req_line_id   NUMBER;
v4_item_id       NUMBER;
v4_line_num1     NUMBER;
v4_line_num2     NUMBER;
ccwpo_lov_error  NUMBER;

BEGIN

IF          
	          ((event_name = 'WHEN-NEW-RECORD-INSTANCE')                  AND
	          ((form_name  = 'POXRQERQ'                                AND 
	           (block_name = 'LINES' OR block_name = 'DISTRIBUTIONS')  AND	
	            item_name  = 'LINES.DELIVER_TO_LOCATION')))              THEN    	             

	          v4_project       := NAME_IN('DISTRIBUTIONS.PROJECT');	
            v4_project_id    := NAME_IN('DISTRIBUTIONS.PROJECT_ID');
            v4_location      := NAME_IN('LINES.DELIVER_TO_LOCATION'); 
	          v4_location_id   := NAME_IN('LINES.DELIVER_TO_LOCATION_ID');
	          v4_req_line_id   := NAME_IN('LINES.REQUISITION_LINE_ID');	          
	          v4_item_id       := NAME_IN('LINES.ITEM_ID');
	          v4_line_num1     := NAME_IN('LINES.LINE_NUM');	    
       
IF        v4_project is not null then      
          rq4_rg_id := find_group('DELIVER_TO_LOCATION'); 	     	        
	       
          Delete_Group_Row(rq4_rg_id,ALL_ROWS);    
 
          new4_rq_rg_id := POPULATE_GROUP_WITH_QUERY(rq4_rg_id,s4_rg_query);  
          
               
          SET_LOV_COLUMN_PROPERTY('DELIVER_TO_LOCATION',1,TITLE,'Location_Name');
          SET_LOV_COLUMN_PROPERTY('DELIVER_TO_LOCATION',1,WIDTH,2);
          
          SET_LOV_COLUMN_PROPERTY('DELIVER_TO_LOCATION',2,TITLE,'Location_ID');
          SET_LOV_COLUMN_PROPERTY('DELIVER_TO_LOCATION',2,WIDTH,0);
                                       
          SET_LOV_COLUMN_PROPERTY('DELIVER_TO_LOCATION',3,TITLE,'Comp_Code / Description / Street Address / Loc Type / Eng Cell');         
          SET_LOV_COLUMN_PROPERTY('DELIVER_TO_LOCATION',3,WIDTH,2);  
       
          SET_LOV_PROPERTY('DELIVER_TO_LOCATION',AUTO_REFRESH,PROPERTY_FALSE);       
END IF;
END IF;
END;
--End of validation of LOCATION in the Requisition form
*/

--END of Clarify ticket #20050419_02101 04/05 RGC	    

/*********************** End of code PRG.06 ***********************************/


/********************** Cingular Enhancement CRP3: FMG-217 Manual Asset Creation" *****/
-- In Prepare Mass Additions form disable the Button 'NEW' and enable Invoice Number and vendor Name
DECLARE
		 v_item_desc					VARCHAR2(81) DEFAULT NULL;	
BEGIN	
 	   	  
 		IF (event_name = 'WHEN-NEW-FORM-INSTANCE') THEN
			IF (form_name = 'FAXMADDS') THEN
					   		app_item_property2.set_property('MASS_ADDITIONS_QF.NEW',ENABLED,PROPERTY_OFF);
			END IF;		
 		END IF;	
/* 		
 			IF (event_name = 'WHEN-VALIDATE-RECORD') THEN
 					IF form_name = 'FAXMADDS' then
 						v_item_desc := NAME_IN('MASS_ADDITIONS.QUEUE_NAME_DISP');
 						IF v_item_desc <> 'Posted' THEN
					app_item_property2.set_property('MASS_ADDITIONS.INVOICE_NUMBER',ENABLED,PROPERTY_ON);
					app_item_property2.set_property('MASS_ADDITIONS.S_INVOICE_NUMBER',ENABLED,PROPERTY_ON);
					app_item_property2.set_property('MASS_ADDITIONS.S_VENDOR_NAME',ENABLED,PROPERTY_ON);
					app_item_property2.set_property('MASS_ADDITIONS.VENDOR_NAME',ENABLED,PROPERTY_ON);
 						END IF;
 					END IF; 					
 			END IF;
 	END;	
*/
 				
		-- Added by VJ Swamy for 11.510 11-MAR-2008
		IF ( form_name = 'FAXMADDS' and event_name= 'WHEN-NEW-RECORD-INSTANCE') THEN
 							v_item_desc := NAME_IN('MASS_ADDITIONS.S_QUEUE_NAME_DISP');
 						IF v_item_desc <> 'Posted' THEN 
 						 app_item_property2.set_property('MASS_ADDITIONS.INVOICE_NUMBER',ENABLED,PROPERTY_ON); --Added VJ
 						 app_item_property2.set_property('MASS_ADDITIONS.S_INVOICE_NUMBER',ENABLED,PROPERTY_ON); --Added VJ
					   app_item_property2.set_property('MASS_ADDITIONS.PO_NUMBER',ENABLED,PROPERTY_ON);
				     app_item_property2.set_property('MASS_ADDITIONS.S_PO_NUMBER',ENABLED,PROPERTY_ON);
					   app_item_property2.set_property('MASS_ADDITIONS.S_VENDOR_NAME',ENABLED,PROPERTY_ON);
					   app_item_property2.set_property('MASS_ADDITIONS.VENDOR_NAME',ENABLED,PROPERTY_ON);
 						end if; 
 					end if; 

end;
 	
/*****************End FMG-217 Manual Asset Creation****************************/
 
-- Cingular Enhancement CRP4.1: BOM Explosion
--Purchase Orders
 DECLARE
 	x_result varchar2(30);
 	x_req_header_id number;
 	normal_order exception;
 BEGIN
    IF  form_name = 'POXRQERQ' and block_name = 'PO_APPROVE' THEN
    	  IF    event_name = 'WHEN-NEW-BLOCK-INSTANCE' THEN 
    	  	    
    	  	    --fnd_message.DEBUG('WNBI-PO_APPROVE-POs.');
    	  	    
    	  	    x_req_header_id := name_in('PO_REQ_HDR.REQUISITION_HEADER_ID');
    	  	    --message('Requisition Header: '||x_req_header_id);
    	  	    --message('x_result: '||x_result);
    	  	    CCWPO_BOM_CUST_EXP.IS_REQ_VALID(X_req_HEADER_ID, x_result);
    	  	        	  	   -- message('Requisition Header: '||x_req_header_id);
    	  	   -- message('x_result: '||x_result);
    	  	    IF x_result = 'TOO_MANY_MODELS' then
    	  	    	 fnd_message.set_name ('CCWPO','CW_PO_INVALID_PO_MSG');
    	  	    	 fnd_message.set_token('INVALID_TEXT','Only one Network Model may be ordered per Requisition.  To order multiple Models, please create separate Requisitions.');
    	  	    Elsif x_result = 'INCOMPATIBLE_LINES' then
    	  	    	 fnd_message.set_name ('CCWPO','CW_PO_INVALID_PO_MSG');
    	  	    	 fnd_message.set_token('INVALID_TEXT','Models and standard Items can not be ordered together on the same Requisition.  Please create separate Requisitions.');
    	  	    Elsif x_result = 'INVALID_QUANTITY' then
    	  	    	 fnd_message.set_name ('CCWPO','CW_PO_INVALID_PO_MSG');
    	  	    	 fnd_message.set_token('INVALID_TEXT','Only one Network Model may be ordered per Requisition.  To order quantities greater than one, please create separate Requisitions.');
    	  	    Elsif x_result = 'INVALID_DOCUMENT' then
    	  	    	 fnd_message.set_name ('CCWPO','CW_PO_INVALID_PO_MSG');
    	  	    	 fnd_message.set_token('INVALID_TEXT','Requisition has Invalid Document Type. PO status not Changed');
    	  	    Elsif x_result = 'INVALID_EXP_TYPE' then
    	  	    	fnd_message.set_name ('CCWPO','CW_PO_INVALID_PO_MSG');
    	  	    	fnd_message.set_token('INVALID_TEXT','Error: One or more of the Network Model Components do not have a default Expenditure Type.  Please  ask your system administrator to verify the Item setup for the BOM Components before re-submitting the Requisition for Approval.');
    	  	    Elsif x_result = 'INVALID_BOM' then
    	  	    	 fnd_message.set_name ('CCWPO','CW_PO_INVALID_PO_MSG');
    	  	    	 fnd_message.set_token('INVALID_TEXT','Error: The Network Model being ordered has not been properly defined in the Bill of Materials module.   Please ask your system administrator to verify the BOM setup before re-submitting the Requisition for Approval.');
    	  	    Elsif x_result = 'INVALID_TASK_EXP' then
    	  	    	 fnd_message.set_name ('CCWPO','CW_PO_INVALID_PO_MSG');
    	  	    	 fnd_message.set_token('INVALID_TEXT','Error: Invalid Custom Expenditure Type assigned to one of the component items. Please ask your system administrator to verify the BOM setup before re-submitting the Requisition for Approval.');
    	  	    END IF;
    	  	    
    	  	    IF x_result = 'NON_BOM' THEN
    	  	    	 raise normal_order;
    	  	    end if;
    	  	    if x_result <> 'Y' then
--    	  	       fnd_message.set_name ('FND','WANT TO CONTINUE');
--    	  	    	 fnd_message.set_token('PROCEDURE','Requisition exceeds Project Budget');
    	  	    	 --fnd_message.show;
--    	  	    	 IF (FND_MESSAGE.WARN) then
--    	  	    	 	  null;
--    	  	    	 else
--    	  	    	 	  raise FORM_TRIGGER_FAILURE;
--    	  	    	 END IF;
    	  	       fnd_message.show;
    	  	       
    	  	    else
    	  	    	  null;
    	  	    end if;
    	  END IF;
    END IF;
  
  if x_result <> 'Y' then
  	GO_BLOCK('PO_REQ_HDR');
  	--message('Before Exception');
  	raise form_trigger_failure;
  	--message('After Exception');
  	GO_BLOCK('PO_REQ_HDR');
  end if;
  Exception
  When normal_order then
       null;
   When others then
   --message('In Others');
       raise form_trigger_failure;
  END;

-- Cingular Enhancement CRP4.1: BOM Explosion
--Purchase Orders
 DECLARE
 	x_result varchar2(30);
 	x_po_header_id number;
 	normal_order exception;
 BEGIN
   -- IF  form_name = 'POXPOEPO' and block_name = 'PO_APPROVE'  THEN
   	 IF  form_name = 'POXPOEPO' and block_name = 'PO_APPROVE'  and NAME_IN('PO_HEADERS.ATTRIBUTE5') != 'WIRELINE-ESS' THEN --Added by kavya for ESS
    	  IF    event_name = 'WHEN-NEW-BLOCK-INSTANCE'  THEN 
    	  	    x_po_header_id := name_in('PO_HEADERS.PO_HEADER_ID');
    	  	    CCWPO_BOM_CUST_EXP.IS_PO_VALID(X_PO_HEADER_ID, x_result);
    	  	    IF x_result = 'TOO_MANY_MODELS' then
    	  	    	 fnd_message.set_name ('CCWPO','CW_PO_INVALID_PO_MSG');
    	  	    	 fnd_message.set_token('INVALID_TEXT','Only one Network Model may be ordered per Purchase Order.  To order multiple Models, please create separate Purchase Orders.');
    	  	    Elsif x_result = 'INCOMPATIBLE_LINES' then
    	  	    	 fnd_message.set_name ('CCWPO','CW_PO_INVALID_PO_MSG');
    	  	    	 fnd_message.set_token('INVALID_TEXT','Models and standard Items can not be ordered together on the same Purchase Order.  Please create separate Purchase Orders.');
    	  	    Elsif x_result = 'INVALID_QUANTITY' then
    	  	    	 fnd_message.set_name ('CCWPO','CW_PO_INVALID_PO_MSG');
    	  	    	 fnd_message.set_token('INVALID_TEXT','Only one Network Model may be ordered per Purchase Order.  To order quantities greater than one, please create separate Purchase Orders.');
    	  	    Elsif x_result = 'INVALID_DOCUMENT' then
    	  	    	 fnd_message.set_name ('CCWPO','CW_PO_INVALID_PO_MSG');
    	  	    	 fnd_message.set_token('INVALID_TEXT','Invalid PO Document Type. PO status not Changed');
    	  	    Elsif x_result = 'INVALID_EXP_TYPE' then
    	  	    	fnd_message.set_name ('CCWPO','CW_PO_INVALID_PO_MSG');
    	  	    	fnd_message.set_token('INVALID_TEXT','Error: One or more of the Network Model Components do not have a default Expenditure Type.  Please  ask your system administrator to verify the Item setup for the BOM Components before re-submitting the Purchase Order for Approval.');
							Elsif x_result = 'INVALID_BOM' then
    	  	    	 fnd_message.set_name ('CCWPO','CW_PO_INVALID_PO_MSG');
    	  	    	 fnd_message.set_token('INVALID_TEXT','Error: The Network Model being ordered has not been properly defined in the Bill of Materials module.   Please ask your system administrator to  verify the BOM setup before re-submitting the Purchase Order for Approval.');
    	  	    Elsif x_result = 'INVALID_TASK_EXP' then
    	  	    	 fnd_message.set_name ('CCWPO','CW_PO_INVALID_PO_MSG');
    	  	    	 fnd_message.set_token('INVALID_TEXT','Error: Invalid Expenditure Type assigned to one of the component items. Please ask your system administrator to verify the BOM setup before re-submitting the PO for Approval.');
   	  	      Elsif x_result = 'BLANKET_EXCEPTION' then
    	  	    	 fnd_message.set_name ('CCWPO','CW_PO_INVALID_PO_MSG');
    	  	    	 fnd_message.set_token('INVALID_TEXT','Blanket Purchase Agreements may not contain Network Models. Please create a Standard Purchase Order Instead.');
    	  	    END IF;
    	  	    --message('x_result: '||x_result);
    	  	    IF x_result = 'NON_BOM' THEN
    	  	    	 raise normal_order;
    	  	    end if;
    	  	    if x_result <> 'Y' then
    	  	    /*
    	  	    	 fnd_message.set_name ('FND','WANT TO CONTINUE');
    	  	    	 fnd_message.set_token('PROCEDURE','Requisition exceeds Project Budget');
    	  	    	 --fnd_message.show;
    	  	    	 IF (FND_MESSAGE.WARN) then
    	  	    	 	  null;
    	  	    	 else
    	  	    	 	  raise FORM_TRIGGER_FAILURE;
    	  	    	 END IF;
    	  	    */
    	  	       fnd_message.show;
    	  	    else
    	  	    	  null;
    	  	    end if;
    	  END IF;
    END IF;

  if x_result <> 'Y' then
  	GO_BLOCK('PO_HEADERS');
  	 --message('Before raise');
  	 raise FORM_TRIGGER_FAILURE;
  	 GO_BLOCK('PO_HEADERS');
     --message('After raise');
  end if;


  Exception
  	When normal_order then
  	   null;
   When others then
     GO_BLOCK('PO_HEADERS');
  	 --message('Before raise');
  	 raise FORM_TRIGGER_FAILURE;
       null;
  END;

-- Cingular Enhancement CRP4.1: BOM Explosion
-- RELEASES
/*
 DECLARE
 	x_result varchar2(30);
 	x_rel_header_id number;
 	normal_order exception;
  BEGIN
    IF  form_name = 'POXPOERL' and block_name = 'PO_APPROVE' THEN
    	   IF    event_name = 'WHEN-VALIDATE-RECORD'  THEN 
    	  	    x_rel_header_id := name_in('PO_RELEASES.PO_RELEASE_ID');
    	  	    CCWPO_BOM_CUST_EXP.IS_RELEASE_VALID(X_rel_HEADER_ID, x_result);
    	  	    IF x_result = 'TOO_MANY_MODELS' then
    	  	    	 fnd_message.set_name ('CCWPO','CW_PO_INVALID_PO_MSG');
    	  	    	 fnd_message.set_token('INVALID_TEXT','Only one Network Model may be ordered per Release.  To order multiple Models, please create separate Releases.');
    	  	    Elsif x_result = 'INCOMPATIBLE_LINES' then
    	  	    	 fnd_message.set_name ('CCWPO','CW_PO_INVALID_PO_MSG');
    	  	    	 fnd_message.set_token('INVALID_TEXT','Models and standard Items can not be ordered together on the same Release.  Please create separate Releases.');
    	  	    Elsif x_result = 'INVALID_QUANTITY' then
    	  	    	 fnd_message.set_name ('CCWPO','CW_PO_INVALID_PO_MSG');
    	  	    	 fnd_message.set_token('INVALID_TEXT','Only one Network Model may be ordered per Release.  To order quantities greater than one, please create separate Releases.');
    	  	    Elsif x_result = 'INVALID_DOCUMENT' then
    	  	    	 fnd_message.set_name ('CCWPO','CW_PO_INVALID_PO_MSG');
    	  	    	 fnd_message.set_token('INVALID_TEXT','Invalid Release Document Type. Release status not Changed');
    	  	    Elsif x_result = 'INVALID_EXP_TYPE' then
    	  	    	fnd_message.set_name ('CCWPO','CW_PO_INVALID_PO_MSG');
    	  	    	fnd_message.set_token('INVALID_TEXT','Error: One or more of the Network Model Components do not have a default Expenditure Type.  Please  ask your system administrator to verify the Item setup for the BOM Components before re-submitting the Release for Approval.');
							Elsif x_result = 'INVALID_BOM' then
    	  	    	 fnd_message.set_name ('CCWPO','CW_PO_INVALID_PO_MSG');
    	  	    	 fnd_message.set_token('INVALID_TEXT','Error: The Network Model being ordered has not been properly defined in the Bill of Materials module.   Please ask your system administrator to  verify the BOM setup before re-submitting the Release for Approval.');
    	  	    Elsif x_result = 'INVALID_TASK_EXP' then
    	  	    	 fnd_message.set_name ('CCWPO','CW_PO_INVALID_PO_MSG');
    	  	    	 fnd_message.set_token('INVALID_TEXT','Error: Invalid Expenditure Type assigned to one of the component items. Please ask your system administrator to verify the BOM setup before re-submitting the Release for Approval.');
    	  	    END IF;
    	  	    --message('x_result: '||x_result);
    	  	    IF x_result = 'NON_BOM' THEN
    	  	    	 raise normal_order;
    	  	    end if;
    	  	    if x_result <> 'Y' then
    	  	    
    	  	       fnd_message.show;
    	  	    else
    	  	    	  null;
    	  	    end if;
    	  END IF;
    END IF;

  if x_result <> 'Y' then
  	GO_BLOCK('PO_RELEASES');
  	 --message('Before raise');
  	 raise FORM_TRIGGER_FAILURE;
  	 GO_BLOCK('PO_RELEASES');
     --message('After raise');
  end if;
    	   	
  Exception
  When normal_order then
     null;
   When others then
     GO_BLOCK('PO_RELEASES');
  	 --message('Before raise');
  	 raise FORM_TRIGGER_FAILURE;
  END;
*/  
  
/*  
declare
  	 X_format_mask varchar2(80);
  	 X_max_length number;
  BEGIN
    IF  form_name = 'POXPOEPO' and block_name = 'PO_SHIPMENTS' THEN
    	   IF    event_name = 'WHEN-NEW-BLOCK-INSTANCE'  THEN 
    	 	       message('In Block..');
    	   	     X_format_mask := 
           		fnd_currency.get_format_mask(name_in('po_shipments.currency_code'), 
                         get_item_property('PO_SHIPMENTS.AMOUNT',MAX_LENGTH));   
               x_max_length := get_item_property('PO_SHIPMENTS.AMOUNT',MAX_LENGTH);
  						 --message('Format Mask: '||x_format_mask);
           	IF X_format_mask is NOT null THEN 
              		--set_item_property('po_shipments.ship_total',FORMAT_MASK,X_format_mask);
              		set_item_property('po_shipments.ship_total',MAX_LENGTH,X_max_length);
           	END IF;
          END IF;
           	END IF;
   exception
   When others then
        message('Format: '||sqlerrm);        		 
END;       	
*/
           	
-- Cingular Enhancement CRP5: FA MASS TRANSFER
--If Item Number is entered (in DFF) on Mass Transfer form
--Location should be required.
--Jayashree R
 DECLARE
 	x_item VARCHAR2(200);
  x_frlocation VARCHAR2(200);
  x_tolocation VARCHAR2(200);
  --added these variable for CQ 2045
  x_seg2_from_high varchar2(240);
  x_seg2_from_low varchar2(240);
  x_seg2_to varchar2(240);
  x_seg3_from_high varchar2(240);
  x_seg3_from_low varchar2(240);
  x_seg3_to varchar2(240);
  x_seg5_from_high varchar2(240);
  x_seg5_from_low varchar2(240);
  x_seg5_to varchar2(240);
  x_seg6_from_high varchar2(240);
  x_seg6_from_low varchar2(240);
  x_seg6_to varchar2(240);
  x_acct_dff_success varchar2(1):='Y';--CQ 2164
  --addition for CQ2045 over
 BEGIN
 	 	      
    IF  form_name = 'FAXMAMTF' 
   	   and block_name = 'MASS_TRANSFERS'    	   
   	   and event_name IN( 'WHEN-NEW-ITEM-INSTANCE','WHEN-NEW-RECORD-INSTANCE')   	   
   	THEN 	
   	   IF event_name= 'WHEN-NEW-RECORD-INSTANCE'  THEN
   	      app_item_property2.set_property('MASS_TRANSFERS.PREVIEW',ENABLED,PROPERTY_ON);
   	      app_item_property2.set_property('MASS_TRANSFERS.FROM_LOCATION',REQUIRED,PROPERTY_FALSE);
   	      app_item_property2.set_property('MASS_TRANSFERS.TO_LOCATION',REQUIRED,PROPERTY_FALSE);
   	    ELSIF   event_name= 'WHEN-NEW-ITEM-INSTANCE' 
   	   	-- and item_name  IN('MASS_TRANSFERS.DESCRIPTION','MASS_TRANSFERS.FROM_GL_EXPENSE_ACCT_LOW','MASS_TRANSFERS.TO_LOCATION','MASS_TRANSFERS.FROM_LOCATION')
					--commented and replaced with below statement for CQ 2045
					and item_name  IN('MASS_TRANSFERS.DESCRIPTION','MASS_TRANSFERS.FROM_GL_EXPENSE_ACCT_LOW','MASS_TRANSFERS.FROM_GL_EXPENSE_ACCT_HIGH','MASS_TRANSFERS.TO_GL_EXPENSE_ACCT','MASS_TRANSFERS.TO_LOCATION','MASS_TRANSFERS.FROM_LOCATION')   	    	     
   	   	THEN   	    	
   	      x_item :=SUBSTR(name_in('MASS_TRANSFERS.DF'),1,200);
   	      x_frlocation :=SUBSTR(name_in('MASS_TRANSFERS.FROM_LOCATION'),1,200);	
   	      --added if condition for CQ 2045
   	      if item_name IN ('MASS_TRANSFERS.FROM_GL_EXPENSE_ACCT_HIGH','MASS_TRANSFERS.TO_GL_EXPENSE_ACCT','MASS_TRANSFERS.FROM_LOCATION')	   	        
   	      then
   	       	x_seg2_from_high:=substr(name_in('MASS_TRANSFERS.FROM_GL_EXPENSE_ACCT_HIGH'),6,4);
   	      	x_seg2_from_low:=substr(name_in('MASS_TRANSFERS.FROM_GL_EXPENSE_ACCT_LOW'),6,4);
   	      	x_seg2_to:=substr(name_in('MASS_TRANSFERS.TO_GL_EXPENSE_ACCT'),6,4);
   	      	x_seg3_from_high:=substr(name_in('MASS_TRANSFERS.FROM_GL_EXPENSE_ACCT_HIGH'),11,4);
   	      	x_seg3_from_low:=substr(name_in('MASS_TRANSFERS.FROM_GL_EXPENSE_ACCT_LOW'),11,4);
   	      	x_seg3_to:=substr(name_in('MASS_TRANSFERS.TO_GL_EXPENSE_ACCT'),11,4);
   	      	x_seg5_from_high:=substr(name_in('MASS_TRANSFERS.FROM_GL_EXPENSE_ACCT_HIGH'),23,4);
   	      	x_seg5_from_low:=substr(name_in('MASS_TRANSFERS.FROM_GL_EXPENSE_ACCT_LOW'),23,4);
   	      	x_seg5_to:=substr(name_in('MASS_TRANSFERS.TO_GL_EXPENSE_ACCT'),23,4);
   	      	x_seg6_from_high:=substr(name_in('MASS_TRANSFERS.FROM_GL_EXPENSE_ACCT_HIGH'),28,4);
   	      	x_seg6_from_low:=substr(name_in('MASS_TRANSFERS.FROM_GL_EXPENSE_ACCT_LOW'),28,4);
   	      	x_seg6_to:=substr(name_in('MASS_TRANSFERS.TO_GL_EXPENSE_ACCT'),28,4);
   	      	
   	      	-- Initialization 
   	      	x_acct_dff_success:='Y';
   	      	app_item_property2.set_property('MASS_TRANSFERS.PREVIEW',ENABLED,PROPERTY_ON);
   	      				
   	      	--Checking Account validation
   	      	if x_seg2_from_high <> x_seg2_from_low
   	      	then
   	      			x_acct_dff_success:='N';--CQ 2164
   	      			app_item_property2.set_property('MASS_TRANSFERS.PREVIEW',ENABLED,PROPERTY_OFF);
   	      			fnd_message.set_string('The Low/High Account Segment values in Transfer From field is not same. Please Re-Enter');
                fnd_message.show;
   	      	elsif
   	      		x_seg2_from_high <> x_seg2_to
   	        then
   	        	x_acct_dff_success:='N';--CQ 2164
   	      		 app_item_property2.set_property('MASS_TRANSFERS.PREVIEW',ENABLED,PROPERTY_OFF);
   	      		 fnd_message.set_string('The Account Segment values in Transfer To field is not same as the Transfer From Field. Please Re-Enter');
               fnd_message.show;
   	      	end if;
   	      	
   	      	--Checking Sub Account validation
   	      	if x_seg3_from_high <> x_seg3_from_low
   	      	then
   	      			x_acct_dff_success:='N';--CQ 2164
   	      			app_item_property2.set_property('MASS_TRANSFERS.PREVIEW',ENABLED,PROPERTY_OFF);
   	      			fnd_message.set_string('The Low/High Sub-Account Segment values in Transfer From field is not same. Please Re-Enter');
                fnd_message.show;
   	      	elsif
   	      		x_seg3_from_high <> x_seg3_to
   	        then
   	        	x_acct_dff_success:='N';--CQ 2164
   	      		 app_item_property2.set_property('MASS_TRANSFERS.PREVIEW',ENABLED,PROPERTY_OFF);
   	      		 fnd_message.set_string('The Sub-Account Segment values in Transfer To field is not same as the Transfer From Field. Please Re-Enter');
               fnd_message.show;
   	        	end if;
   	      	--Checking LOB Validation
   	      	if x_seg5_from_high <> x_seg5_from_low
   	      	then
   	      		x_acct_dff_success:='N';--CQ 2164
   	      			app_item_property2.set_property('MASS_TRANSFERS.PREVIEW',ENABLED,PROPERTY_OFF);
   	      			fnd_message.set_string('The Low/High LOB Segment values in Transfer From field is not same. Please Re-Enter');
                fnd_message.show;
   	      	elsif
   	      		x_seg5_from_high <> x_seg5_to
   	        then
   	        	x_acct_dff_success:='N';--CQ 2164
   	      		 app_item_property2.set_property('MASS_TRANSFERS.PREVIEW',ENABLED,PROPERTY_OFF);
   	      		 fnd_message.set_string('The LOB Segment values in Transfer To field is not same as the Transfer From Field. Please Re-Enter');
               fnd_message.show;
   	     
   	      	end if;
   	      	--Checking Future segment validation
   	      	if x_seg6_from_high <> x_seg6_from_low
   	      	then
   	      		x_acct_dff_success:='N';--CQ 2164
   	      			app_item_property2.set_property('MASS_TRANSFERS.PREVIEW',ENABLED,PROPERTY_OFF);
   	      			fnd_message.set_string('The Low/High Future Segment values in Transfer From field is not same. Please Re-Enter');
                fnd_message.show;
   	      	elsif
   	      		x_seg6_from_high <> x_seg6_to
   	        then
   	        	x_acct_dff_success:='N';--CQ 2164
   	      		 app_item_property2.set_property('MASS_TRANSFERS.PREVIEW',ENABLED,PROPERTY_OFF);
   	      		 fnd_message.set_string('The Future Segment values in Transfer To field is not same as the Transfer From Field. Please Re-Enter');
               fnd_message.show;

   	      	end if;
   	      	
   	      end if;
   	      
   	      --addition over for CQ 2045
   	   	 	        
   	      IF  item_name IN('MASS_TRANSFERS.DESCRIPTION','MASS_TRANSFERS.FROM_GL_EXPENSE_ACCT_LOW')
   	      THEN
   	        IF x_item is NOT NULL AND x_frlocation IS NULL THEN   	        	
   	        	app_item_property2.set_property('MASS_TRANSFERS.PREVIEW',ENABLED,PROPERTY_OFF);
   	        	app_item_property2.set_property('MASS_TRANSFERS.FROM_LOCATION',REQUIRED,PROPERTY_TRUE);
   	        	app_item_property2.set_property('MASS_TRANSFERS.TO_LOCATION',REQUIRED,PROPERTY_TRUE);
   	        ELSE
   	        	app_item_property2.set_property('MASS_TRANSFERS.PREVIEW',ENABLED,PROPERTY_ON);
   	        	app_item_property2.set_property('MASS_TRANSFERS.FROM_LOCATION',REQUIRED,PROPERTY_FALSE);
   	        	app_item_property2.set_property('MASS_TRANSFERS.TO_LOCATION',REQUIRED,PROPERTY_FALSE);
   	        END IF; 
   	     
   	      END IF;  
   	      
   	      IF item_name IN ('MASS_TRANSFERS.FROM_LOCATION') THEN
   	      	 x_tolocation :=SUBSTR(name_in('MASS_TRANSFERS.TO_LOCATION'),1,200);		   	       
   	         IF x_item is NOT NULL THEN         
           	   IF x_tolocation IS NOT NULL THEN
   	        	   app_item_property2.set_property('MASS_TRANSFERS.PREVIEW',ENABLED,PROPERTY_ON);
   	        	   fnd_message.set_string('dff success= ');
   	        	   fnd_message.show;
           	   ELSE
           	 	   app_item_property2.set_property('MASS_TRANSFERS.PREVIEW',ENABLED,PROPERTY_OFF);
           	   END IF;	
           	 ELSE
   	        	 app_item_property2.set_property('MASS_TRANSFERS.PREVIEW',ENABLED,PROPERTY_ON);		
   	        	 
           	 END IF;
              if x_acct_dff_success='N'
         		then
             app_item_property2.set_property('MASS_TRANSFERS.PREVIEW',ENABLED,PROPERTY_OFF);
         		else
         		app_item_property2.set_property('MASS_TRANSFERS.PREVIEW',ENABLED,PROPERTY_ON);
         		end if;
   	      END IF;   	     
   	      IF item_name IN ('MASS_TRANSFERS.TO_LOCATION') THEN   	     
   	         x_frlocation :=SUBSTR(name_in('MASS_TRANSFERS.FROM_LOCATION'),1,200);		   	       
             IF x_item IS NOT NULL THEN
           	   IF x_frlocation IS NOT NULL THEN
           	   	--fnd_message.set_string('dff success= '||x_acct_dff_success);
          	   	--fnd_message.show;
   	        	   app_item_property2.set_property('MASS_TRANSFERS.PREVIEW',ENABLED,PROPERTY_ON);
           	   ELSE
           	 	   app_item_property2.set_property('MASS_TRANSFERS.PREVIEW',ENABLED,PROPERTY_OFF);
           	   END IF;	
   	         ELSE
   	          	app_item_property2.set_property('MASS_TRANSFERS.PREVIEW',ENABLED,PROPERTY_ON);
   	         END IF; 	   	       
   	      END IF; 
   	       	
   	    END IF;  
 	       --fnd_message.set_name ('CCWFA','CCWFA_LOCATION');
         --fnd_message.set_token('VALUE','item name:'||item_name);
         --fnd_message.show; 
        
   END IF;	 
 END;  

-- Cingular Enhancement CRP5: NOTIFY USER WHEN REQUISITION EXCEEDS PROJECT BUDGET
--Jayashree R
-- 09/09/2010 by Salman Siddiqui. This code is being commented out due to changes done by Amod Joshi for R217. The new code is starting just after this commnted code. 
--commented by ss9085 on 01/31/11. New code below is from PROD
/*
  DECLARE
    x_req_header_id NUMBER;
    x_org_id        NUMBER;	
    x_errno         NUMBER;    
    x_actual        NUMBER; 
    x_commitment    NUMBER;
    x_budget        NUMBER; 
    x_req_amt       NUMBER;
    x_errmsg        VARCHAR2(3000);  
    
  BEGIN
    IF  form_name = 'POXRQERQ' 
   	   and block_name = 'PO_APPROVE'    	   
   	   and event_name IN( 'WHEN-NEW-BLOCK-INSTANCE')   	   
   	THEN 	
   	  x_req_header_id := NAME_IN('PO_REQ_HDR.REQUISITION_HEADER_ID');
   	  x_org_id        := FND_PROFILE.VALUE('ORG_ID');
   	  ccwpa_notify.req_exceed_projbudget(p_req_hdr_id  => x_req_header_id
                                         ,p_org_id     => x_org_id
                                         ,p_budget     => x_budget
                                         ,p_req_amt    => x_req_amt
                                         ,p_actual     => x_actual
                                         ,p_commitment => x_commitment
                                         ,p_errmsg     => x_errmsg 
                                         ,p_errno      => x_errno
                                         );
      IF x_errno=1 THEN
         FND_MESSAGE.SET_NAME('CCWPO','CW_PO_REQ_EXCEED_BUDGET');     
         FND_MESSAGE.SET_TOKEN('PROJECTS',x_errmsg);         
         FND_MESSAGE.SHOW;
      ELSIF  x_errno=2 THEN 
     	   FND_MESSAGE.SET_NAME('CCWPO','CW_PO_REQ_EXCEED_BUDGET_ERR');     
         FND_MESSAGE.SET_TOKEN('ERROR',x_errmsg);
         FND_MESSAGE.ERROR;               
      END IF;	       
      
    END IF;
  END;
*/  
-- new code for R217 from Amod Joshi. This replaces the above code for CRP5
--1/31/11
-- Cingular Enhancement CRP5: NOTIFY USER WHEN REQUISITION EXCEEDS PROJECT BUDGET
--Jayashree R


  DECLARE
    x_req_header_id NUMBER;
    x_org_id        NUMBER;
    x_errno         NUMBER;
    x_actual        NUMBER;
    x_commitment    NUMBER;
    x_budget        NUMBER;
    x_req_amt       NUMBER;
    x_errmsg        VARCHAR2(3000);

    v_active_status   VARCHAR2(1);
    v_inactive_status VARCHAR2(1);

  BEGIN

    v_active_status   := 'Y';
    v_inactive_status := 'N';

    IF  form_name = 'POXRQERQ'
    and block_name = 'PO_APPROVE'
    and event_name IN( 'WHEN-NEW-BLOCK-INSTANCE')
    THEN

      ---- Added by Amod Joshi on 28-Jul-10 - Rice 217

      BEGIN
              SELECT enabled_flag
              INTO   v_active_status
              FROM   fnd_lookup_values
              WHERE  upper(lookup_type) = 'CCW_SCM_POREQ_EXCD_BUDGET_CODE'
              AND    upper(lookup_code) = 'ACTIVE FLAG';
      EXCEPTION
        WHEN OTHERS THEN
              v_active_status := 'Y';
      END;

      BEGIN
              SELECT enabled_flag
              INTO   v_inactive_status
              FROM   fnd_lookup_values
              WHERE  upper(lookup_type) = 'CCW_SCM_POREQ_EXCD_BUDGET_CODE'
              AND    upper(lookup_code) = 'INACTIVE FLAG';
      EXCEPTION
        WHEN OTHERS THEN
              v_inactive_status := 'N';
      END;

      IF( (v_active_status = 'Y') and (v_inactive_status = 'N') ) OR
        ( (v_active_status = 'Y') and (v_inactive_status = 'Y') ) OR
        ( (v_active_status = 'N') and (v_inactive_status = 'N') )
       THEN

            x_req_header_id := NAME_IN('PO_REQ_HDR.REQUISITION_HEADER_ID');
            x_org_id        := FND_PROFILE.VALUE('ORG_ID');

            ccwpa_notify.req_exceed_projbudget(p_req_hdr_id  => x_req_header_id
                                               ,p_org_id     => x_org_id
                                               ,p_budget     => x_budget
                                               ,p_req_amt    => x_req_amt
                                               ,p_actual     => x_actual
                                               ,p_commitment => x_commitment
                                               ,p_errmsg     => x_errmsg
                                               ,p_errno      => x_errno
                                               );
            IF x_errno=1 THEN
               FND_MESSAGE.SET_NAME('CCWPO','CW_PO_REQ_EXCEED_BUDGET');
               FND_MESSAGE.SET_TOKEN('PROJECTS',x_errmsg);
               FND_MESSAGE.SHOW;
            ELSIF  x_errno=2 THEN
               FND_MESSAGE.SET_NAME('CCWPO','CW_PO_REQ_EXCEED_BUDGET_ERR');
               FND_MESSAGE.SET_TOKEN('ERROR',x_errmsg);
               FND_MESSAGE.ERROR;
            END IF;

        ELSE
            NULL;
      END IF;

      ----

    END IF;

  END; 
  
--- R217 code for Amod Joshi ends.

-- Cingular Enhancement CRP5: FMG.328 Project Transfers - Start
-- Vinay 10/23/2003
   DECLARE
     LC_Exp_Item_Id     VARCHAR2(255);
     LC_Project_Id      VARCHAR2(255);
     LC_Project_Number  VARCHAR2(255);
     LC_Task_Id         VARCHAR2(255);
     LC_From_Location   VARCHAR2(255);
     LC_Validation_Flag VARCHAR2(1);
     LC_Validation_Msg  VARCHAR2(1000);
     
   BEGIN
     -- Zoom event opens a new session of a form and 
     -- passes parameter values to the new session.  The parameters
     -- already exist in the form being opened.
     IF (form_name = 'PAXTRAPE' AND block_name = 'EXP_ITEMS') THEN
     	 --Set_Menu_Item_Property('SPECIAL.SPECIAL14',VISIBLE,PROPERTY_FALSE);
     	 Set_Menu_Item_Property('SPECIAL.SPECIAL15',VISIBLE,PROPERTY_FALSE);
       IF (event_name = 'ZOOM') THEN   
         LC_Exp_Item_Id      := NAME_IN('EXP_ITEMS.Expenditure_Item_Id');
         LC_Project_Id       := NAME_IN('EXP_ITEMS.Project_id');
         LC_Project_Number   := NAME_IN('EXP_ITEMS.Project_Number');
         LC_Task_Id          := NAME_IN('EXP_ITEMS.Task_id');
         LC_From_Location    := NAME_IN('EXP_ITEMS.Attribute9');
         
         CW_Manual_Project_Transfers.From_Parameters_Validate( P_Expenditure_Item_Id => TO_NUMBER(LC_Exp_Item_Id),
                                                               P_Project_Id          => TO_NUMBER(LC_Project_Id),
                                                               P_Location_Code       => LC_From_Location,
                                                               P_Validation_Flag     => LC_Validation_Flag,
                                                               P_Validation_Msg      => LC_Validation_Msg
                                                              );
         IF LC_Validation_Flag = 'Y' THEN
            FND_Function.Execute( FUNCTION_NAME => 'CCWPATRF_FUN',  
                                  OPEN_FLAG     => 'Y',  
                                  SESSION_FLAG  => 'Y',  
                                  OTHER_PARAMS  => 'EXPENDITURE_ITEM_ID="'||LC_Exp_Item_Id||
                                                   '" FROM_PROJECT_ID="'||LC_Project_Id||
                                                   '" FROM_PROJECT_NUMBER="'||LC_Project_Number||
                                                   '" FROM_TASK_ID="'||LC_Task_Id||
                                                   '" FROM_LOCATION="'||LC_From_Location||
                                                   '"'
                                 ); 
       	 ELSE 
       	 	 FND_MESSAGE.DEBUG('CUSTOM :'||LC_Validation_Msg);
         END IF;
       END IF;
     END IF;
   END;  
-- Cingular Enhancement CRP5: FMG.328 Project Transfers - End
 
-- Cingular Enhancement CRP5: FMG.318REV "Reverse Capitalization" begins
    IF  form_name = 'PAXCARVW' THEN
    	
    	 IF    event_name = 'WHEN-NEW-FORM-INSTANCE'  THEN 

             app_special2.instantiate('SPECIAL15', 'CW Reverse', NULL, TRUE, NULL);
    	 
    	 ELSIF event_name = 'SPECIAL15' AND block_name = 'ASSETS'  THEN
    	 
             -- The below code is copied from program unit ASSETS_CONTROL.REVERSE_BUTTON in
             -- PAXCARVW.fmb (called from ASSETS_CONTROL.REVERSE_BUTTON.When-Button-Pressed trigger)
             -- and then modified to suit the requirement

             -- Below IF is for instances where the row is empty (new record)
             IF  name_in('assets.project_asset_id') IS NULL  THEN
             
                 fnd_message.set_string('This function is not available here');
                 fnd_message.show;
                 RAISE form_trigger_failure;
             
             ELSIF  pa_debug.acquire_user_lock( 'PA_CAP_'||name_in('assets.project_id')) <> 0  THEN
             
                 fnd_message.set_name('PA','PA_CAP_CANNOT_ACQUIRE_LOCK');
                 fnd_message.error;
                 RAISE form_trigger_failure;
             
             END IF;

             IF  name_in('ASSETS.CAPITALIZED_FLAG') != 'Y'  THEN
                
                 fnd_message.set_name('PA','PA_CP_NO_REV_UNCAP_ASSET');
                 fnd_message.error;
             
             ELSE

                 -- CQ# ERP00001377: The form does not return time component of the capitalized and reversal dates;
                 -- so a record group needs to be created to retrieve these values
                 ccwpa_rev_cap_date_id := FIND_GROUP ('CCWPA_REV_CAP_DATE_RG');
          
                 IF NOT ID_NULL(ccwpa_rev_cap_date_id) THEN
     	              DELETE_GROUP(ccwpa_rev_cap_date_id);
                 END IF;

                 -- the query returns the capitalized and reversal dates
                 ccwpa_rev_cap_date_id := CREATE_GROUP_FROM_QUERY ('CCWPA_REV_CAP_DATE_RG',
                 'SELECT TO_CHAR(capitalized_date, ''dd-mon-yyyy hh24:mi:ss'') capitalized_date, ' ||
                 'TO_CHAR(reversal_date, ''dd-mon-yyyy hh24:mi:ss'') reversal_date FROM pa_project_assets ' ||
                 'WHERE project_asset_id = ' || name_in('assets.project_asset_id'));

                 ccwpa_rev_cap_date_error := POPULATE_GROUP(ccwpa_rev_cap_date_id);
        
                 -- 1403 implies that project asset is not found; it should be an error
                 IF ccwpa_rev_cap_date_error = 0 THEN
                    ccwpa_capitalized_date := GET_GROUP_CHAR_CELL ('CCWPA_REV_CAP_DATE_RG.capitalized_date', 1);
                    ccwpa_reversal_date := GET_GROUP_CHAR_CELL ('CCWPA_REV_CAP_DATE_RG.reversal_date', 1);
                 ELSE
                    fnd_message.set_string('Error in record group ' || ccwpa_rev_cap_date_error);
                    fnd_message.error;        
                 END IF;

                 -- see if the asset has been capitalized and then reversed
                 -- IF (:ASSETS.CAPITALIZED_DATE > :ASSETS.REVERSAL_DATE OR :ASSETS.REVERSAL_DATE IS NULL) THEN
                 IF (ccwpa_reversal_date IS NULL OR 
    	              TO_DATE(ccwpa_capitalized_date, 'dd-mon-yyyy hh24:mi:ss') > 
    	              TO_DATE(ccwpa_reversal_date, 'dd-mon-yyyy hh24:mi:ss')) THEN
                   
                    IF name_in('ASSETS.REVERSE_FLAG') = 'N' THEN

                       -- custom code that verifies that asset is not fully/partially retired (CR 327), and 
                       -- still at the same location in FA
                       ccwpa_rev_cap_id := FIND_GROUP ('CCWPA_REV_CAP_RG');
          
                       IF NOT ID_NULL(ccwpa_rev_cap_id) THEN
          	              DELETE_GROUP(ccwpa_rev_cap_id);
                       END IF;
        
                       -- the query returns the retired FA asset (if any) related to the project asset
                       ccwpa_rev_cap_id := CREATE_GROUP_FROM_QUERY ('CCWPA_REV_CAP_RG',
                       'SELECT fa.asset_number FROM ' ||
                       'fa_additions_b fa, fa_books fb ' ||
                       'WHERE fb.asset_id = (SELECT fai.asset_id FROM fa_asset_invoices fai, ' ||
                       'pa_project_asset_lines ppal WHERE ppal.project_asset_id = ' || 
                       name_in('assets.project_asset_id') ||
                       ' AND fai.project_asset_line_id = ppal.project_asset_line_id' ||
                       ' AND fai.date_ineffective IS NULL AND ROWNUM = 1)' ||
                       ' AND fb.book_type_code = ''CORP''' ||
                       ' AND fb.date_ineffective IS NULL' ||
                       ' AND fb.period_counter_fully_retired IS NOT NULL' ||
                       ' AND fa.asset_id = fb.asset_id');

                       ccwpa_rev_cap_error := POPULATE_GROUP(ccwpa_rev_cap_id);
        
                       -- 1403 is "record not found" which should also result in row count of 0
                       -- 1403 implies that asset has not been fully retired
                       IF ccwpa_rev_cap_error NOT IN (0, 1403) THEN
				                  fnd_message.set_string('Error in record group ' || ccwpa_rev_cap_error);
				                  fnd_message.error;        
                       END IF;

                       ccwpa_rev_cap_count := GET_GROUP_ROW_COUNT(ccwpa_rev_cap_id);
        
                       IF ccwpa_rev_cap_count > 0 THEN -- (1) -- fully retired
          	
                          -- asset has been fully retired, error out with a custom message
                          fnd_message.set_name('CCWPA', 'CCWPA_REV_CAP_RETIRED_ERROR');
                          fnd_message.set_token('ASSET_NUMBER', GET_GROUP_CHAR_CELL ('CCWPA_REV_CAP_RG.asset_number', 1));
                          fnd_message.error;
                              
                       ELSE

                       DELETE_GROUP(ccwpa_rev_cap_id);

                       -- the query returns the partially retired FA asset related to the project asset
                       -- and the Transaction Header ID (if any)
                       -- Note: Only Partial Retirement Transactions after 'TRANSFER IN' need to be considered
                       ccwpa_rev_cap_id := CREATE_GROUP_FROM_QUERY ('CCWPA_REV_CAP_RG',
                       'SELECT fa.asset_number, TO_CHAR(fth.transaction_header_id) th_id FROM ' ||
                       'fa_additions_b fa, fa_retirements fr, fa_transaction_headers fth ' ||
                       'WHERE fth.asset_id = (SELECT fai.asset_id FROM fa_asset_invoices fai, ' ||
                       'pa_project_asset_lines ppal WHERE ppal.project_asset_id = ' || 
                       name_in('assets.project_asset_id') ||
                       ' AND fai.project_asset_line_id = ppal.project_asset_line_id' ||
                       ' AND fai.date_ineffective IS NULL AND ROWNUM = 1)' ||
                       ' AND fth.book_type_code = ''CORP''' ||
                       ' AND fth.transaction_type_code = ''PARTIAL RETIREMENT''' ||
                       ' AND fth.date_effective >=' ||
                       ' (SELECT fth2.date_effective' ||
                       '  FROM   fa_transaction_headers fth2' ||
                       '  WHERE  fth2.asset_id = fth.asset_id' ||
                       '  AND    fth2.book_type_code = fth.book_type_code' ||
                       '  AND    fth2.transaction_type_code = ''TRANSFER IN''' ||
                       '  )' ||
                       ' AND fr.transaction_header_id_in = fth.transaction_header_id' ||
                       ' AND fr.book_type_code = fth.book_type_code' ||
                       ' AND fr.status <> ''DELETED''' ||
                       ' AND fa.asset_id = fth.asset_id' ||
                       ' AND ROWNUM = 1');

                       ccwpa_rev_cap_error := POPULATE_GROUP(ccwpa_rev_cap_id);
        
                       -- 1403 is "record not found" which should also result in row count of 0
                       -- 1403 implies that asset has not been partially retired
                       IF ccwpa_rev_cap_error NOT IN (0, 1403) THEN
				                  fnd_message.set_string('Error in record group ' || ccwpa_rev_cap_error);
				                  fnd_message.error;        
                       END IF;

                       ccwpa_rev_cap_count := GET_GROUP_ROW_COUNT(ccwpa_rev_cap_id);
        
                       IF ccwpa_rev_cap_count > 0 THEN -- (2) -- partially retired
          	
                          -- asset has been partially retired, error out with a custom message
                          fnd_message.set_name('CCWPA', 'CCWPA_REV_CAP_PARTIALRET_ERROR');
                          fnd_message.set_token('ASSET_NUMBER', GET_GROUP_CHAR_CELL ('CCWPA_REV_CAP_RG.asset_number', 1));
                          fnd_message.set_token('TRANSACTION_HEADER_ID',
                                                GET_GROUP_CHAR_CELL ('CCWPA_REV_CAP_RG.th_id', 1));
                          fnd_message.error;
                              
                       ELSE

                       DELETE_GROUP(ccwpa_rev_cap_id);

                       -- the query returns any locations of the asset that are not the same as the 
                       -- original location
                       ccwpa_rev_cap_id := CREATE_GROUP_FROM_QUERY ('CCWPA_REV_CAP_RG',
                       'SELECT fa.asset_number, flk.concatenated_segments new_location FROM ' ||
                       'fa_locations_kfv flk, fa_additions_b fa, fa_distribution_history fdh ' ||
                       'WHERE fdh.asset_id = (SELECT fai.asset_id FROM fa_asset_invoices fai, ' ||
                       'pa_project_asset_lines ppal WHERE ppal.project_asset_id = ' || 
                       name_in('assets.project_asset_id') ||
                       ' AND fai.project_asset_line_id = ppal.project_asset_line_id' ||
                       ' AND fai.date_ineffective IS NULL AND ROWNUM = 1)' ||
                       ' AND fdh.book_type_code = ''CORP''' ||
                       ' AND fdh.date_ineffective IS NULL' ||
                       ' AND fdh.units_assigned > 0' ||
                       ' AND fa.asset_id = fdh.asset_id' || 
                       ' AND flk.location_id = fdh.location_id AND flk.concatenated_segments <> ' || 
                       name_in('assets.location') || ' AND ROWNUM = 1');

                       ccwpa_rev_cap_error := POPULATE_GROUP(ccwpa_rev_cap_id);
        
                       -- 1403 is "record not found" which should also result in row count of 0
                       -- 1403 implies that asset is at the original location
                       IF ccwpa_rev_cap_error NOT IN (0, 1403) THEN
				                  fnd_message.set_string('Error in record group ' || ccwpa_rev_cap_error);
				                  fnd_message.error;        
                       END IF;

                       ccwpa_rev_cap_count := GET_GROUP_ROW_COUNT(ccwpa_rev_cap_id);
        
                       IF ccwpa_rev_cap_count > 0 THEN -- (3) -- location mismatch
          	
                          -- asset is in a different location, error out with a custom message
                          fnd_message.set_name('CCWPA', 'CCWPA_REV_CAP_LOCATION_ERROR');
                          fnd_message.set_token('ASSET_NUMBER', GET_GROUP_CHAR_CELL ('CCWPA_REV_CAP_RG.asset_number', 1));
                          fnd_message.set_token('NEW_LOCATION', GET_GROUP_CHAR_CELL ('CCWPA_REV_CAP_RG.new_location', 1));
                          fnd_message.set_token('OLD_LOCATION', name_in('assets.location'));
                          fnd_message.error;
                              
                       ELSE
                          
                          copy('Y', 'ASSETS.REVERSE_FLAG');
                          
                       END IF; -- IF ccwpa_rev_cap_count > 0 THEN -- (3) -- location mismatch

                       END IF; -- IF ccwpa_rev_cap_count > 0 THEN -- (2) -- partially retired

                       END IF; -- IF ccwpa_rev_cap_count > 0 THEN -- (1) -- fully retired
                       
                    ELSE

                       copy('N', 'ASSETS.REVERSE_FLAG');

                    END IF;
                   
                 ELSE
	                 
                    fnd_message.set_name('PA','PA_CP_NO_REV_ASSET_AGAIN');
                    fnd_message.error;
                   
                 END IF;
                
             END IF;
  
             IF  pa_debug.Release_user_lock( 'PA_CAP_'||name_in('assets.project_id')) <> 0 THEN

                 fnd_message.set_name('PA','PA_CAP_CANNOT_RELS_LOCK');
                 fnd_message.error;
                 RAISE form_trigger_failure;

             END IF;

             -- even if all goes well, SPECIAL code requires the trigger failure to avoid the
             -- "FRM-40700: No such Trigger: SPECIAL15" message coming up
             -- Also, for the 3 above error conditions of 'PA_CP_NO_REV_UNCAP_ASSET', 'PA_CP_NO_REV_ASSET_AGAIN',
             -- and 'CCWPA_REV_CAP_LOCATION_ERROR', the below RAISE is required here instead of above since the lock 
             -- gets released just prior to raising this failure
             RAISE form_trigger_failure;

       ELSIF event_name = 'SPECIAL15' THEN

             fnd_message.set_string('This function is not available here');
             fnd_message.show;
             RAISE form_trigger_failure;
                          	
       END IF;
       
    END IF;
-- Cingular Enhancement CRP5: FMG.318REV "Reverse Capitalization" ends

/*----------------------------------------------------------------------
   Code statrts for 'Restrict Ability to Change Cingular Company Project Classification and Auto Project Numbering'
   Kalyan Varanasi		06-Nov-2003
----------------------------------------------------------------------*/
   DECLARE
      lc_db_class_code   pa_project_classes.class_code%TYPE ;
      ln_project_id      NUMBER ;
   BEGIN
      IF (event_name = 'WHEN-VALIDATE-RECORD') THEN   
         IF (form_name = 'PAXPREPR' and block_name = 'CLASS') THEN 

            ln_project_id := to_number(name_in('CLASS.project_id')) ;

            BEGIN
               SELECT class_code
               INTO   lc_db_class_code 
               FROM   pa_project_classes   PAPC
               WHERE  PAPC.project_id = ln_project_id
               AND    PAPC.class_category = 'Cingular Company' ;
               IF ( lc_db_class_code IS NOT NULL ) AND ( lc_db_class_code != name_in('CLASS.CLASS_CODE') and name_in('CLASS.CLASS_CATEGORY') = 'Cingular Company') THEN
                  copy(lc_db_class_code, ':CLASS.CLASS_CODE') ;
                  fnd_message.debug('Update not allowed on class code, resetting the value back to '||lc_db_class_code) ;
               ELSE
                  -- allow the process to go ahead normally
                  NULL ;
               END IF ;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                  -- allow the update on the class_code
                  NULL ;
            END ;
         END  IF ; 
      END IF ; 
   END ;
/*----------------------------------------------------------------------
   Code ends for 'Restrict Ability to Change Cingular Company Project Classification and Auto Project Numbering'
----------------------------------------------------------------------*/
 
 /*-------------------------------------------------------------------------------------- 
 -- Validating expenditure type defaulted on distributions from preferences 
 -- validation occuring at line level
 -- Vineet Mukul 11_nov_2004 
 ----------------------------------------------------------------------------------------- */ 
 declare
 
  v_po_exp_type_derived varchar2(30) := NULL;
  v_item_id             number;
  v_org_id              number;
	v_po_exp_type_null    varchar2(30)    := NULL;
	v_iet_gcc_segment2    varchar2(30);
	v_exc_no_item_id      exception;
		
 begin
 
 --primarily for initializing 'global.v_prev_record_already_evaluated'
 if event_name = 'WHEN-NEW-FORM-INSTANCE' and 
 	(
 	(form_name = 'POXRQERQ') OR
 	--(form_name = 'POXPOEPO') OR
 	(form_name = 'POXPOEPO' AND NAME_IN('PO_HEADERS.ATTRIBUTE5') != 'WIRELINE-ESS') OR --Added by kavya for ESS
 	(form_name = 'POXPOERL')
 	)
 	then
 	  --fnd_message.DEBUG('WNFI-Record evaluation flag.');
 	  
 		copy('N','global.v_prev_record_already_evaluated');
 	  copy('DISPLAY','global.gv_iet_msg_ctr1');
 end if;
 
-- primarily for reseting the exp type msg display ctr every time a new line block instance is launched

 if event_name = 'WHEN-NEW-BLOCK-INSTANCE' and 
 	(
 	(form_name = 'POXRQERQ' and block_name = 'LINES') OR
 	--(form_name = 'POXPOEPO' and block_name = 'PO_LINES') OR
 	(form_name = 'POXPOEPO' and block_name = 'PO_LINES' and NAME_IN ('PO_HEADERS.ATTRIBUTE5') != 'WIRELINE-ESS') OR --Added by kavya for ESS
 	(form_name = 'POXPOERL' and block_name = 'PO_SHIPMENTS')
 	)
 	then
 	--fnd_message.DEBUG('WNBI-L-msg control.');
 	copy('DISPLAY','global.gv_iet_msg_ctr1');
 end if;
 

 if event_name = 'WHEN-VALIDATE-RECORD' and 
 	(
 	(form_name = 'POXRQERQ' and block_name = 'LINES') OR
 	--(form_name = 'POXPOEPO' and block_name = 'PO_LINES') OR
 	(form_name = 'POXPOEPO' and block_name = 'PO_LINES' and NAME_IN('PO_HEADERS.ATTRIBUTE5') != 'WIRELINE-ESS') OR --Added by kavya for ESS
 	(form_name = 'POXPOERL' and block_name = 'PO_SHIPMENTS')
 	)
 	then
    --fnd_message.DEBUG('WVR-L-Pref check.');
 -- the following is needed because the custom pll code shd never execute if all the preferences are not populated
 -- only if all the pref are populated will the distr be generated automatically if something is missing the user
 	-- has to navigate to the distr anyway  and that defeats the purpose of using the preferences
 if name_in('global.po_expenditure_type') is not null and 
 	  name_in('global.po_expenditure_organization') is NOT NULL and 
 	  name_in('global.po_expenditure_item_date') is NOT NULL and 
 	  name_in('global.po_project') is NOT NULL and 
 	  name_in('global.po_task') is NOT NULL 
 then
 
 copy(null,'global.gv_po_exp_type_derived');
 	
 	if form_name = 'POXRQERQ' and block_name = 'LINES' then
 		    --fnd_message.DEBUG('WVR-L-Pref check:Storing Ids.');
 	      v_item_id := name_in('LINES.ITEM_ID');
        v_org_id  := NAME_IN('LINES.DEST_ORGANIZATION_ID');
 	elsif form_name = 'POXPOEPO' and block_name = 'PO_LINES' then
 				v_item_id := name_in('PO_LINES.ITEM_ID');
        v_org_id  := NAME_IN('PO_HEADERS.SHIP_TO_ORG_ID');
 	elsif form_name = 'POXPOERL' and block_name = 'PO_SHIPMENTS' then
				v_item_id := name_in('PO_SHIPMENTS.ITEM_ID');
        v_org_id  := NAME_IN('PO_SHIPMENTS.SHIP_TO_ORGANIZATION_ID');
 	end if;
  
  -- need this validation here as users may hit the save button on the lines form itself and never go to distributions
  -- this may seem redundant as we are doing this validation on distriutions but this is required here
  -- does not allow users to go ahead with  non item based trx. if users update pref in the middle of the session
  -- they have to click in the header and exit it so that the header level WVR fires and pref are stored in old_gv_exp_type
  		
  if v_item_id is null then -- and name_in('global.po_project') is not null then
  	fnd_message.set_string('NON Item based transactions cannot be entered with Project Preferences. Cannot  proceed ahead unless PA defaults removed from preferences.');
  	fnd_message.show; 
  	raise form_trigger_failure;
  else
 -- run this select only if item_id is not null
  	 select nvl(msib.ATTRIBUTE12,'X'),
 	        gcc.segment2
          into 
          v_po_exp_type_derived,
          v_iet_gcc_segment2
          from 
          mtl_system_items_b msib,
          gl_code_combinations gcc
          where 
          msib.INVENTORY_ITEM_ID = v_item_id
          AND msib.organization_id = v_org_id
          and msib.expense_account = gcc.code_combination_id;
 	end if;
 	
 -- need this validation here as users may hit the save button on the lines form itself and never go to distributions
 if (v_iet_gcc_segment2 like '15%' or v_iet_gcc_segment2 like '16%' or v_iet_gcc_segment2 like '17%')  and v_po_exp_type_derived = 'X' then --Pranay 05/05/06 pg17_accum_dep_acc
 		fnd_message.set_string('Capital items cannot have null Expenditure Type assignment on Item Master. Cannot proceed ahead.');
  	fnd_message.show; 
 	raise form_trigger_failure;
 end if;
 
 if  v_iet_gcc_segment2 not like '15%' and 
 	   v_iet_gcc_segment2 not like '16%' and
		v_iet_gcc_segment2 not like '17%' and --Pranay 05/05/06 pg17_accum_dep_acc
		 v_po_exp_type_derived = 'X' and 
 	   name_in('global.gv_iet_msg_ctr1')= 'DISPLAY' then  
				    -- fnd_message.set_string('Expenditure type is not validated for expense items. Defaulted expenditure type may be incorrect, specially if you are using preferences. Navigate to Distributions to verify. This message appears only for the first expense item on a transaction');
	--ss9085 09/18/07			     fnd_message.set_string('You are charging an expense item to a project. If you are using preferences , the defaulted  exenditure type may be incorrect. Please go to the distributions to verify the project information. If you do not intend to charge a project for this item, delete the line , re-enter the item ( do not save the transaction), go to the distributions, clear the project field and enter the GL code manually.');
				--    fnd_message.show; 
				    copy('DO NOT DISPLAY AGAIN','global.gv_iet_msg_ctr1'); -- do not display till user navigates to lines block again 
 end if;
 
 -- 

if v_po_exp_type_derived != 'X'  then
   copy(v_po_exp_type_derived,'global.gv_po_exp_type_derived');
   copy(v_iet_gcc_segment2,'global.gv_iet_gcc_segment2');
   copy('N','global.v_prev_record_already_evaluated');
  else
 	 copy('X','global.v_prev_record_already_evaluated');
  end if;
  
  if name_in('global.gv_po_exp_type_derived') is not null and -- this will prevent this code trigerring for exp items
     name_in('global.gv_po_exp_type_derived') != name_in('GLOBAL.PO_EXPENDITURE_TYPE') then 
  
  		  if (v_iet_gcc_segment2 like '15%' or v_iet_gcc_segment2 like '16%' or v_iet_gcc_segment2 like '17%') then 	 -- capital items check (05/05/06 added Accumulated Depriciation Accounts check pg17_accum_dep_acc -Pranay)
		  	copy(name_in('global.gv_po_exp_type_derived'),'global.po_expenditure_type'); -- never make the ET pref null as the above code will not work for next line
		  end if;
  else
  	null; -- if the derived_et  and pref_et are the same do nto do anything
  end if;

 end if; -- checking to see whether all 5 preferences are populated or not

end if; -- end of WNR

-- WNII event for requisitions - purchase orders - releases

-- or 

 if (event_name = 'WHEN-NEW-RECORD-INSTANCE' and name_in(':system.record_status') = 'NEW' and
	 	    (
		 	    (form_name = 'POXRQERQ' and 
		 	     block_name = 'LINES' and
		 	     name_in('lines.line_num') > 1)
		 	    or
		 	    (form_name = 'POXPOEPO' and 
		 	     block_name = 'PO_LINES' and
		 	     NAME_IN('PO_HEADERS.ATTRIBUTE5') != 'WIRELINE-ESS' AND --Added by kavya for ESS
		 	     name_in('po_lines.line_num') > 1)
		 	    or
		 	    (form_name = 'POXPOERL' and 
		 	     block_name = 'PO_SHIPMENTS' and
		 	     name_in('system.cursor_record') > 1)
	 	    )
 	    )THEN  
 
  -- the following is needed because the custom pll code shd never execute if all the preferences are not populated
 -- only if all the pref are populated will the distr be generated automatically if something is missing the user
 	-- has to navigate to the distr anyway  and that defeats the purpose of using the preferences
			 --fnd_message.DEBUG('WNRI-Status:New-Pref check.');
			 
			 if name_in('global.po_expenditure_type') is not null and 
			 	  name_in('global.po_expenditure_organization') is NOT NULL and 
			 	  name_in('global.po_expenditure_item_date') is NOT NULL and 
			 	  name_in('global.po_project') is NOT NULL and 
			 	  name_in('global.po_task') is NOT NULL then
			
			 	    -- copy('N','global.gv_iet_msg_ctr1');
			 	    
						 	    if name_in('global.v_prev_record_already_evaluated') = 'N' then
						 	        PREVIOUS_RECORD;
-- Sue Gibson debug
--fnd_message.set_string('record status = ' || name_in(':system.record_status'));
--fnd_message.show;						          
								      if name_in(':system.record_status') = 'INSERT' then
								 	      copy('Y','global.v_prev_record_already_evaluated');
								 	      post; -- this will build the charge account on the distributions form..very critical
								 	      NEXT_RECORD;
								      else -- existing line has already been saved earlier
								       	copy('Y','global.v_prev_record_already_evaluated');
								      	NEXT_RECORD;
-- Sue Gibson debug 
--fnd_message.set_string('global.v_prev_record_already_evaluated = ' ||name_in('global.v_prev_record_already_evaluated'));
--fnd_message.show;								      	
								      	copy('Y','global.v_prev_record_already_evaluated');  -- Sue Gibson 11/15/06 prevents recursive looping
								      end if;
						      end if;
			      
			 end if; -- end of check to see if all 5 preferences are populated
								      
 end if; -- this is where WNII ends

EXCEPTION      	
  when v_exc_no_item_id then
  -- fnd_message.set_string('No Item used on transaction. Expenditure Type validation will not be performed');
  -- fnd_message.show;
  null;  	

WHEN NO_DATA_FOUND THEN
  fnd_message.set_string('Preference data may have to be removed to proceed ahead'); 
  fnd_message.show;

  RAISE FORM_TRIGGER_FAILURE;

WHEN OTHERS THEN
  RAISE;
 	
end;
-- additional validation for pa_trx_ctl 06-dec-2004
declare
	
	v_trx_ctl_pid number;
	v_trx_ctl_tid number;
	v_trx_ctl_et varchar2(60);
	v_trx_ctl_et2  varchar2(60);
	v2_item_id number;
	v2_org_id number;
	v2_po_exp_type_derived varchar2(60);
	v2_iet_gcc_segment2 varchar2(60);
	v_chk_ship_to_loc varchar2(60);

begin
	
if event_name = 'WHEN-VALIDATE-RECORD' 
	and  form_name = 'POXPOERL' 
	and block_name = 'PO_DISTRIBUTIONS' then

			v_trx_ctl_pid := name_in('PO_DISTRIBUTIONS.PROJECT_ID');
			v_trx_ctl_tid := name_in('PO_DISTRIBUTIONS.TASK_ID');
			v_trx_ctl_et := name_in('PO_DISTRIBUTIONS.EXPENDITURE_TYPE');
			v2_item_id := name_in('PO_SHIPMENTS.ITEM_ID');
      v2_org_id  := NAME_IN('PO_SHIPMENTS.SHIP_TO_ORGANIZATION_ID');
        
--
		if v2_item_id is NOT null then -- and name_in('global.po_project') is not null then
		  	  	 select nvl(msib.ATTRIBUTE12,'X'),
		 	        gcc.segment2
		          into 
		          v2_po_exp_type_derived,
		          v2_iet_gcc_segment2
		          from 
		          mtl_system_items_b msib,
		          gl_code_combinations gcc
		          where 
		          msib.INVENTORY_ITEM_ID = v2_item_id
		          AND msib.organization_id = v2_org_id
		          and msib.expense_account = gcc.code_combination_id;
			
				if  v2_iet_gcc_segment2 like '15%' or v2_iet_gcc_segment2 like '16%' or v2_iet_gcc_segment2 like '17%' then --Pranay 05/05/06 pg17_accum_dep_acc
				 	   
					select expenditure_type
					into 	v_trx_ctl_et2 
					from 
					pa_transaction_controls
					where
					project_id = 	v_trx_ctl_pid
					and task_id = 	v_trx_ctl_tid
					and expenditure_type = v_trx_ctl_et
					and CHARGEABLE_FLAG = 'Y'
					and end_date_active is NULL 
					and start_date_active <= sysdate;
				
									if sql%notfound then	
									fnd_message.set_string('Transaction Control Violation; Use a different expenditure type with this task');
									fnd_message.show;
									raise form_trigger_failure;
									end if;
				
				end if;
		
		end if;

end if;

exception
	when others then 
	fnd_message.set_string('Transaction Control Violation Exception. Corrected expenditure type was defaulted from item master. Task entered cannot be used with this expenditure type. Please use a different task.');
  fnd_message.show;
	raise form_trigger_failure;				      	
end;
-- 06-dec-2004  End of Vineet Mukul
-------------------------

-------------------------
-- Start of Cingular Enhancement PA Description Field Validation Maury Marcus Feb 2005
-------------------------
DECLARE
	cwpa_desc_in						varchar2(250) ;
	cwpa_desc_out						varchar2(250) ;
	cwpa_char								varchar2(1) ;
BEGIN 
	if	form_name =					'PAXPREPR'
			and	block_name =		'PROJECT_FOLDER'
			and (name_in('system.record_status') in ('INSERT','CHANGED')
			and	(nvl(name_in('project_folder.description_mir'),'X') !=	'X')
			 or	(event_name =		'WHEN-VALIDATE-RECORD'
			 and item_name in	 ('PROJECT_FOLDER.SEGMENT1_MIR', 'PROJECT_FOLDER.PROJECT_TYPE_MIR',
													'PROJECT_FOLDER.START_DATE_MIR', 'PROJECT_FOLDER.COMPLETION_DATE_MIR',
													'PROJECT_FOLDER.DESCRIPTION_MIR', 'PROJECT_FOLDER.PUBLIC_SECTOR_FLAG_MIR',
													'PROJECT_FOLDER.NAME_MIR', 'PROJECT_FOLDER.ORGANIZATION_NAME_MIR',
													'PROJECT_FOLDER.WF_IN_ROUTE_FLAG', 'PROJECT_FOLDER.TEMPLATE_FLAG_MIR',
													'PROJECT_FOLDER.DF_MIR')))
	then
			cwpa_desc_in :=			name_in('project_folder.description_mir') ;
			cwpa_desc_out :=		null ;
			cwpa_char :=				null ;
			for	i in 1..length(cwpa_desc_in)
			loop
					begin
							cwpa_char :=		substr(cwpa_desc_in,i,1) ;
							if	(
									cwpa_char in	(' ', '(', ')', '+', ',', '-', '.', '/', '[', '\', ']')
									or	cwpa_char	between '0' and '9'
									or	cwpa_char	between 'A' and 'Z'
									or	cwpa_char	between 'a' and 'z'
									)
							then
									cwpa_desc_out :=	cwpa_desc_out||cwpa_char ;
							end if ;
					exception
							when	no_data_found
							or		value_error
							then	null ;
					end ;
			end loop ;
			if	cwpa_desc_out is	null
			then
					cwpa_desc_out :=	'X' ;
			end if ;
			if	nvl(cwpa_desc_out,'x') !=	cwpa_desc_in
			then
					copy(cwpa_desc_out,'project_folder.description_mir') ;
					copy(cwpa_desc_out,'project_folder.description') ;
			end if ;
	end if ;

  if  form_name =				'PAXPREPR'
      and block_name =	'OVERRIDE'
      and event_name =	'WHEN-VALIDATE-RECORD'
      and name_in('override.field_name') =		'DESCRIPTION'
      and	nvl(name_in('override.field_value'),'X') !=	'X'
  then
			cwpa_desc_in :=			name_in('override.field_value') ;
      cwpa_desc_out :=  null ;
      cwpa_char :=      null ;
			for	i in 1..length(cwpa_desc_in)
			loop
					begin
							cwpa_char :=		substr(cwpa_desc_in,i,1) ;
							if	(
									cwpa_char in	(' ', '(', ')', '+', ',', '-', '.', '/', '[', '\', ']')
									or	cwpa_char	between '0' and '9'
									or	cwpa_char	between 'A' and 'Z'
									or	cwpa_char	between 'a' and 'z'
									)
							then
									cwpa_desc_out :=	cwpa_desc_out||cwpa_char ;
							end if ;
					exception
							when	no_data_found
							or		value_error
							then	null ;
					end ;
			end loop ;
			if	cwpa_desc_out is	null
			then
					cwpa_desc_out :=	'X' ;
			end if ;
			if	nvl(cwpa_desc_out,'x') !=	cwpa_desc_in
			then
					copy(cwpa_desc_out,'override.field_value') ;
      		copy(cwpa_desc_out,'hidden_project.description') ;
			end if ;
  end if ;
END ;
-------------------------
-- End of Cingular Enhancement PA Description Field Validation Maury Marcus Feb 2005
-------------------------

/*
------------------------
-- Start of PO Clarify ticket # 20041028_00690(Custom LOV for the Deliver_To_Location) Resley Cole  12/04
------------------------
DECLARE
	
form_name       VARCHAR2(30)  := name_in('system.current_form');
block_name      VARCHAR2(30)  := name_in('system.cursor_block');
item_name				VARCHAR2(90)  := name_in('system.cursor_item');
s_rg_query      VARCHAR2(2000):= 'SELECT * FROM CUSTOM_DELIVER_TO_LOV_V';                               
rq_rg_id        RECORDGROUP;                           
new_rq_rg_id    NUMBER;
rq_group_name   VARCHAR2(30)  := 'DELIVER_TO_LOCATION';

BEGIN

IF        (event_name = 'WHEN-NEW-ITEM-INSTANCE'      AND
          (form_name  = 'POXRQERQ'                    AND 
	         block_name = 'LINES'                       AND
	         item_name  = 'LINES.DELIVER_TO_LOCATION')) THEN 
	  
          rq_rg_id  := find_group('DELIVER_TO_LOCATION'); 	     	        
	        
          Delete_Group_Row(rq_rg_id ,ALL_ROWS);
              
          new_rq_rg_id  := POPULATE_GROUP_WITH_QUERY(rq_rg_id ,s_rg_query);
               
          SET_LOV_COLUMN_PROPERTY('DELIVER_TO_LOCATION',1,TITLE,'Location_Num');
          SET_LOV_COLUMN_PROPERTY('DELIVER_TO_LOCATION',1,WIDTH,1);
          
          SET_LOV_COLUMN_PROPERTY('DELIVER_TO_LOCATION',2,TITLE,'Location_ID');
          SET_LOV_COLUMN_PROPERTY('DELIVER_TO_LOCATION',2,WIDTH,0);
                                       
          SET_LOV_COLUMN_PROPERTY('DELIVER_TO_LOCATION',3,TITLE,'Comp_Code / Street Address  / Loc Type');         
          SET_LOV_COLUMN_PROPERTY('DELIVER_TO_LOCATION',3,WIDTH,100);  
    
          SET_LOV_PROPERTY('DELIVER_TO_LOCATION',AUTO_REFRESH,PROPERTY_FALSE);       
END IF; 
          	
END;
------------------------
-- END of PO Clarify ticket # 20041028_00690(Custom LOV for the Deliver_To_Location) Resley Cole  12/04
------------------------  
*/

------------------------
-- Start of PA Clarify ticket # 20041118_03140(Restricted form access to CW Project Manager) Resley Cole  12/04
-- changes from Brijesh Ravindra on 9/19/06 are added . Denoted by Brijesh
------------------------
DECLARE
-- Form PAXPREPR

 cur_itmb     VARCHAR2(80); 
 cur_block2   VARCHAR2(80) := 'PROJECT_FOLDER';
 cur_itm2     VARCHAR2(80) := 'COMPLETION_DATE_MIR'; --radio group name  
 v_userid     NUMBER       := apps.FND_PROFILE.VALUE('RESP_ID');
 v_appl_name  VARCHAR2(80) := apps.FND_PROFILE.VALUE('RESP_NAME'); 
 v_username   VARCHAR2(80) := apps.FND_PROFILE.VALUE('USERNAME');   --Brijesh 

BEGIN 

--Brijesh code starts:
IF v_appl_name = ('CW NTW Error Handling') THEN
		BEGIN
			SELECT resgrp.responsibility_id resp_id, resp.responsibility_name resp_name
				INTO v_userid,v_appl_name
			  FROM fnd_user fndusr,
			       fnd_user_resp_groups resgrp,
			       fnd_responsibility_vl resp
			 WHERE fndusr.user_name = v_username
			   AND fndusr.user_id = resgrp.user_id
			   AND resgrp.responsibility_id = resp.responsibility_id
			   AND resp.responsibility_name = 'CW Project Manager'
			   AND (resgrp.end_date IS NULL OR resgrp.end_date >= TRUNC (SYSDATE));
		EXCEPTION
			WHEN OTHERS THEN
				NULL;
		END;
	END IF;

--Brijesh code ends.


-- Form PAXPREPR  
IF     form_name   = ('PAXPREPR')           AND 
       v_userid    = ('50350')              OR
	     v_appl_name = ('CW Project Manager') THEN
	     
	     cur_itmb    := cur_block2||'.'||cur_itm2;    
-- commented as per Brijesh ---       v_userid    := apps.FND_PROFILE.VALUE('RESP_ID');
-- commented as per Brijesh ---       v_appl_name := apps.FND_PROFILE.VALUE('RESP_NAME');	

IF     v_userid    = '50350'                    OR
	     v_appl_name = 'CW Project Manager'       THEN
	     
IF     event_name in ('ZOOM','WHEN-NEW-BLOCK-INSTANCE','WHEN-NEW-ITEM-INSTANCE',
	                    'WHEN-NEW-RECORD-INSTANCE') THEN 
	                     
IF     form_name  =   'PAXPREPR'                THEN
	
IF     block_name in ('PROJECT_FOLDER') THEN	     
	     
       SET_MENU_ITEM_PROPERTY('FILE.NEW',ENABLED, PROPERTY_FALSE );
       SET_MENU_ITEM_PROPERTY('EDIT.DELETE',ENABLED, PROPERTY_FALSE );        
	     
	     SET_BLOCK_PROPERTY('PROJECT_FOLDER',DELETE_ALLOWED,PROPERTY_FALSE);	     
	     
	     --INSERT NOT ALLOWED
	     app_item_property2.set_property('PROJECT_FOLDER.PROJECT_TYPE_MIR',INSERT_ALLOWED,PROPERTY_FALSE);	     	     
       app_item_property2.set_property('PROJECT_FOLDER.START_DATE_MIR',INSERT_ALLOWED,PROPERTY_FALSE);      
       app_item_property2.set_property('PROJECT_FOLDER.PUBLIC_SECTOR_FLAG_MIR',INSERT_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('PROJECT_FOLDER.TEMPLATE_FLAG_MIR',INSERT_ALLOWED,PROPERTY_FALSE);      
       app_item_property2.set_property('PROJECT_FOLDER.WF_IN_ROUTE_FLAG',INSERT_ALLOWED,PROPERTY_FALSE);      
	     --UPDATE NOT ALLOWED 
	     app_item_property2.set_property('PROJECT_FOLDER.DF_MIR',DISPLAYED,PROPERTY_FALSE);	     	      
	     app_item_property2.set_property('PROJECT_FOLDER.PROJECT_TYPE_MIR',UPDATE_ALLOWED,PROPERTY_FALSE);	     	     
	     app_item_property2.set_property('PROJECT_FOLDER.START_DATE_MIR',UPDATE_ALLOWED,PROPERTY_FALSE);      
       app_item_property2.set_property('PROJECT_FOLDER.PUBLIC_SECTOR_FLAG_MIR',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('PROJECT_FOLDER.TEMPLATE_FLAG_MIR',UPDATE_ALLOWED,PROPERTY_FALSE);      
       app_item_property2.set_property('PROJECT_FOLDER.WF_IN_ROUTE_FLAG',UPDATE_ALLOWED,PROPERTY_FALSE); 

END IF;
END IF;
END IF;
END IF;

IF     v_userid    = '50350'                    OR
	     v_appl_name = 'CW Project Manager'       THEN
	     
IF     event_name in ('WHEN-NEW-BLOCK-INSTANCE','ZOOM','WHEN-NEW-RECORD-INSTANCE',
	                    'WHEN-NEW-ITEM-INSTANCE') THEN 
	                     
IF     form_name  =   'PAXPREPR'                THEN
       
IF     block_name in ('PROJECT_OPTIONS','TASKS','TASKS_CONTROL') THEN	     
	     
       SET_MENU_ITEM_PROPERTY('FILE.NEW',ENABLED, PROPERTY_FALSE );
       SET_MENU_ITEM_PROPERTY('EDIT.DELETE',ENABLED, PROPERTY_FALSE );
       
       SET_BLOCK_PROPERTY('PROJECT_OPTIONS',UPDATE_ALLOWED,PROPERTY_FALSE);	     
	     SET_BLOCK_PROPERTY('PROJECT_OPTIONS',DELETE_ALLOWED,PROPERTY_FALSE);	     
	     
	     SET_BLOCK_PROPERTY('TASKS',DELETE_ALLOWED,PROPERTY_FALSE);	     
	     
	     app_item_property2.set_property('PROJECT_OPTIONS.OPTION_NAME_DISP',UPDATE_ALLOWED,PROPERTY_FALSE);       
       --INSERT NOT ALLOWED      
       app_item_property2.set_property('TASKS.TASK_NUMBER_DISP',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.TASK_NUMBER',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.TASK_NAME',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.TASK_NAME2',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.TASK_MANAGER_NAME',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.ORGANIZATION_NAME',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.SERVICE_TYPE_M',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.WORK_TYPE_NAME',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.START_DATE',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.DESCRIPTION',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.CHARGEABLE_FLAG',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.BILLABLE_FLAG',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.ADDRESS1',INSERT_ALLOWED,PROPERTY_FALSE);               
       app_item_property2.set_property('TASKS.DESCRIPTION2',INSERT_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('TASKS.START_DATE2',INSERT_ALLOWED,PROPERTY_FALSE);              
       app_item_property2.set_property('TASKS.DF',DISPLAYED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.DF_MIR',DISPLAYED,PROPERTY_FALSE); 
       --UPDATE NOT ALLOWED
       app_item_property2.set_property('TASKS.TASK_NUMBER_DISP',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.TASK_NUMBER',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.TASK_NAME',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.TASK_NAME2',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.TASK_MANAGER_NAME',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.ORGANIZATION_NAME',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.SERVICE_TYPE_M',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.WORK_TYPE_NAME',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.START_DATE',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.DESCRIPTION',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.CHARGEABLE_FLAG',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.BILLABLE_FLAG',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.ADDRESS1',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS.DESCRIPTION2',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('TASKS.START_DATE2',UPDATE_ALLOWED,PROPERTY_FALSE);              
              
       app_item_property2.set_property('TASKS_CONTROL.CREATE_SUBTASK',ENABLED,PROPERTY_FALSE);
       app_item_property2.set_property('TASKS_CONTROL.CREATE_PEERTASK',ENABLED,PROPERTY_FALSE);
END IF;
END IF;
END IF;
END IF;

IF     v_userid    = '50350'                    OR
	     v_appl_name = 'CW Project Manager'       THEN
	     
IF     event_name in ('WHEN-NEW-BLOCK-INSTANCE','ZOOM','WHEN-NEW-RECORD-INSTANCE',
	                    'WHEN-NEW-ITEM-INSTANCE') THEN 
	                     
IF     form_name  =   'PAXPREPR'                THEN
                      	
	
IF     block_name in ('TXN_CONTROLS','ASSETS','ASSET_ASSIGNMENTS') THEN
	                    
	     Set_Menu_Item_Property('EDIT.DELETE',ENABLED, PROPERTY_FALSE );
	     Set_Menu_Item_Property('FILE.NEW',ENABLED, PROPERTY_FALSE ); 
	     Set_Menu_Item_Property('FILE.SAVE',ENABLED, PROPERTY_FALSE );           
	         
	     
	     set_block_property('TXN_CONTROLS_DUMMY',UPDATE_ALLOWED,PROPERTY_FALSE);
	     set_block_property('TXN_CONTROLS_DUMMY',INSERT_ALLOWED,PROPERTY_FALSE);	     
	     
	     set_block_property('TXN_CONTROLS',UPDATE_ALLOWED,PROPERTY_FALSE);
	     set_block_property('TXN_CONTROLS',INSERT_ALLOWED,PROPERTY_FALSE);
	     set_block_property('TXN_CONTROLS',DELETE_ALLOWED,PROPERTY_FALSE);	     
	     	      
	     set_block_property('ASSETS',UPDATE_ALLOWED,PROPERTY_FALSE);
	     --set_block_property('ASSETS',INSERT_ALLOWED,PROPERTY_FALSE);	     
	     set_block_property('ASSETS',DELETE_ALLOWED,PROPERTY_FALSE);	     
	     
	     set_block_property('ASSET_ASSIGNMENTS',UPDATE_ALLOWED,PROPERTY_FALSE);
	     set_block_property('ASSET_ASSIGNMENTS',INSERT_ALLOWED,PROPERTY_FALSE);
	     set_block_property('ASSET_ASSIGNMENTS',DELETE_ALLOWED,PROPERTY_FALSE);	             
       
       --INSERT NOT ALLOWED
       app_item_property2.set_property('TXN_CONTROLS.EXPENDITURE_CATEGORY',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TXN_CONTROLS.EXPENDITURE_TYPE',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TXN_CONTROLS.EMPLOYEE_NAME',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TXN_CONTROLS.CHARGEABLE_FLAG',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TXN_CONTROLS.BILLABLE_INDICATOR',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TXN_CONTROLS.START_DATE_ACTIVE',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TXN_CONTROLS.END_DATE_ACTIVE',INSERT_ALLOWED,PROPERTY_FALSE);       
       --UPDATE NOT ALLOWED
       app_item_property2.set_property('TXN_CONTROLS.EXPENDITURE_CATEGORY',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TXN_CONTROLS.EXPENDITURE_TYPE',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TXN_CONTROLS.EMPLOYEE_NAME',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TXN_CONTROLS.CHARGEABLE_FLAG',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TXN_CONTROLS.BILLABLE_INDICATOR',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TXN_CONTROLS.START_DATE_ACTIVE',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('TXN_CONTROLS.END_DATE_ACTIVE',UPDATE_ALLOWED,PROPERTY_FALSE);
       
       --INSERT NOT ALLOWED
       app_item_property2.set_property('ASSETS.ASSET_NAME',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.ASSET_NUMBER',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.ASSET_DESCRIPTION',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.ASSET_CATEGORY',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.ASSET_KEY_DISP',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.BOOK_TYPE_CODE',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.ESTIMATED_IN_SERVICE_DATE',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.LOCATION',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.ASSET_UNITS',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.FULL_NAME',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.EMPLOYEE_NUMBER',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.DEPRECIATE_FLAG',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.AMORTIZE_FLAG',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.EXPENSE_ACCOUNT',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.DESC_FLEX',INSERT_ALLOWED,PROPERTY_FALSE);
       --UPDATE NOT ALLOWED
       app_item_property2.set_property('ASSETS.ASSET_NAME',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.ASSET_NUMBER',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.ASSET_DESCRIPTION',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.ASSET_CATEGORY',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.ASSET_KEY_DISP',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.BOOK_TYPE_CODE',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.ESTIMATED_IN_SERVICE_DATE',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.LOCATION',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.ASSET_UNITS',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.FULL_NAME',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.EMPLOYEE_NUMBER',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.DEPRECIATE_FLAG',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.AMORTIZE_FLAG',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.EXPENSE_ACCOUNT',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.DESC_FLEX',UPDATE_ALLOWED,PROPERTY_FALSE);      
       
       --INSERT NOT ALLOWED
       app_item_property2.set_property('ASSET_ASSIGNMENTS.ASSET_NAME',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSET_ASSIGNMENTS.ASSET_DESCRIPTION',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSET_ASSIGNMENTS_CONTROL.GROUPING_LEVEL',INSERT_ALLOWED,PROPERTY_FALSE);
       --UPDATE NOT ALLOWED
       app_item_property2.set_property('ASSET_ASSIGNMENTS.ASSET_NAME',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSET_ASSIGNMENTS.ASSET_DESCRIPTION',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSET_ASSIGNMENTS_CONTROL.GROUPING_LEVEL',UPDATE_ALLOWED,PROPERTY_FALSE);        

END IF;
END IF;
END IF;
END IF;
END IF;
END;

DECLARE
-- Form PAXCARVW  
 v_userid     NUMBER       := apps.FND_PROFILE.VALUE('RESP_ID');
 v_appl_name  VARCHAR2(80) := apps.FND_PROFILE.VALUE('RESP_NAME'); 

BEGIN 
-- Form PAXCARVW  
IF     form_name   = ('PAXCARVW')           AND 
       v_userid    = ('50350')              OR
	     v_appl_name = ('CW Project Manager') THEN
	     
	        
       v_userid    := apps.FND_PROFILE.VALUE('RESP_ID');
       v_appl_name := apps.FND_PROFILE.VALUE('RESP_NAME');      
       	
       
IF     v_userid    = '50350'                  OR
	     v_appl_name = 'CW Project Manager'   THEN       

IF     event_name in ( 'WHEN-NEW-FORM-INSTANCE', 'WHEN-NEW-BLOCK-INSTANCE','WHEN-NEW-ITEM-INSTANCE',
	                     'WHEN-VALIDATE-RECORD','WHEN-VALIDATE-ITEM','WHEN-BUTTON-PRESSED')          THEN  
IF     form_name  =    'PAXCARVW'                                                 THEN
IF     block_name in ( 'CAPITAL_PROJECTS','ASSETS','ASSET_LINES')         THEN
--IF       (name_in('system.record_status') in ('NEW','INSERT','CHANGED'))	 THEN	
     
	     Set_Menu_Item_Property('EDIT.DELETE', ENABLED, PROPERTY_FALSE );
	     Set_Menu_Item_Property('FILE.NEW', ENABLED, PROPERTY_FALSE );
	     Set_Menu_Item_Property('FILE.SAVE', ENABLED, PROPERTY_FALSE );	     
	            
       set_block_property('CAPITAL_PROJECTS',UPDATE_ALLOWED,PROPERTY_FALSE);
       set_block_property('CAPITAL_PROJECTS',INSERT_ALLOWED,PROPERTY_FALSE);
       set_block_property('CAPITAL_PROJECTS',DELETE_ALLOWED,PROPERTY_FALSE);       
              
       set_block_property('ASSETS',UPDATE_ALLOWED,PROPERTY_FALSE);
       set_block_property('ASSETS',INSERT_ALLOWED,PROPERTY_FALSE);
       set_block_property('ASSETS',DELETE_ALLOWED,PROPERTY_FALSE);       
                     
       set_block_property('ASSET_LINES',UPDATE_ALLOWED,PROPERTY_FALSE); 
       set_block_property('ASSET_LINES',INSERT_ALLOWED,PROPERTY_FALSE);
       set_block_property('ASSET_LINES',DELETE_ALLOWED,PROPERTY_FALSE);  
       
      -- app_item_property2.set_property('ASSETS.CAPITAL_HOLD_FLAG',DISPLAYED,PROPERTY_FALSE);               
       
       app_item_property2.set_property('CAPITAL_PROJECTS.GENERATE_BUTTON',ENABLED,PROPERTY_FALSE);
       --INSERT NOT ALLOWED
       app_item_property2.set_property('CAPITAL_PROJECTS.PROJECT_NUMBER',INSERT_ALLOWED,PROPERTY_FALSE);	     
	     app_item_property2.set_property('CAPITAL_PROJECTS.PROJECT_NAME',INSERT_ALLOWED,PROPERTY_FALSE);	     
	     --app_item_property2.set_property('CAPITAL_PROJECTS.EXPENSED',INSERT_ALLOWED,PROPERTY_FALSE);	     
	     app_item_property2.set_property('CAPITAL_PROJECTS.CIP_COST',INSERT_ALLOWED,PROPERTY_FALSE);
	     app_item_property2.set_property('CAPITAL_PROJECTS.CAPITALIZED_COST',INSERT_ALLOWED,PROPERTY_FALSE);	     
	     app_item_property2.set_property('CAPITAL_PROJECTS.TOTAL_COSTS',INSERT_ALLOWED,PROPERTY_FALSE);
	     /* Mohan Commented to fix the errror reference to CQ# WUP00073691 of 11510 upgrade 
       --UPDATE NOT ALLOWED       
       app_item_property2.set_property('CAPITAL_PROJECTS.PROJECT_NUMBER',UPDATE_ALLOWED,PROPERTY_FALSE);	     
	     app_item_property2.set_property('CAPITAL_PROJECTS.PROJECT_NAME',UPDATE_ALLOWED,PROPERTY_FALSE);	     
	     app_item_property2.set_property('CAPITAL_PROJECTS.EXPENSED',UPDATE_ALLOWED,PROPERTY_FALSE);	     
	     app_item_property2.set_property('CAPITAL_PROJECTS.CIP_COST',UPDATE_ALLOWED,PROPERTY_FALSE);
	     app_item_property2.set_property('CAPITAL_PROJECTS.CAPITALIZED_COST',UPDATE_ALLOWED,PROPERTY_FALSE);	     
	     app_item_property2.set_property('CAPITAL_PROJECTS.TOTAL_COSTS',UPDATE_ALLOWED,PROPERTY_FALSE);
	      	     
	     --INSERT NOT ALLOWED
	     app_item_property2.set_property('ASSETS.ASSET_NAME',INSERT_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.ESTIMATED_IN_SERVICE_DATE',INSERT_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.DATE_PLACED_IN_SERVICE',INSERT_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.TOTAL_ASSET_COST',INSERT_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.BOOK_TYPE_CODE',INSERT_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.ASSET_CATEGORY',INSERT_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.ASSET_KEY',INSERT_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.ASSET_NUMBER',INSERT_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.ASSET_UNITS',INSERT_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.LOCATION',INSERT_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.FULL_NAME',INSERT_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.EMPLOYEE_NUMBER',INSERT_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.DEPRECIATE_FLAG',INSERT_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.EXPENSE_ACCOUNT',INSERT_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.AMORTIZE_FLAG',INSERT_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.ASSET_DESCRIPTION',INSERT_ALLOWED,PROPERTY_FALSE);
	     --UPDATE NOT ALLOWED            
       app_item_property2.set_property('ASSETS.ASSET_NAME',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.ESTIMATED_IN_SERVICE_DATE',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.DATE_PLACED_IN_SERVICE',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.TOTAL_ASSET_COST',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.BOOK_TYPE_CODE',UPDATE_ALLOWED,PROPERTY_FALSE);
       app_item_property2.set_property('ASSETS.ASSET_CATEGORY',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.ASSET_KEY',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.ASSET_NUMBER',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.ASSET_UNITS',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.LOCATION',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.FULL_NAME',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.EMPLOYEE_NUMBER',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.DEPRECIATE_FLAG',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.EXPENSE_ACCOUNT',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.AMORTIZE_FLAG',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSETS.ASSET_DESCRIPTION',UPDATE_ALLOWED,PROPERTY_FALSE);
       
       --INSERT NOT ALLOWED
       app_item_property2.set_property('ASSET_LINES.ASSET_NAME',INSERT_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSET_LINES.ASSET_CATEGORY',INSERT_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSET_LINES.DESCRIPTION',INSERT_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSET_LINES.TASK_NUMBER',INSERT_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSET_LINES.CURRENT_ASSET_COST',INSERT_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSET_LINES.ORIGINAL_ASSET_COST',INSERT_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSET_LINES.SPLIT_PERCENTAGE',INSERT_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSET_LINES.CIP_ACCOUNT',INSERT_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSET_LINES.TRANSFER_STATUS_M',INSERT_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSET_LINES.TRANSFER_REJECTION_REASON_M',INSERT_ALLOWED,PROPERTY_FALSE);       
       --UPDATE NOT ALLOWED
       app_item_property2.set_property('ASSET_LINES.ASSET_NAME',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSET_LINES.ASSET_CATEGORY',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSET_LINES.DESCRIPTION',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSET_LINES.TASK_NUMBER',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSET_LINES.CURRENT_ASSET_COST',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSET_LINES.ORIGINAL_ASSET_COST',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSET_LINES.SPLIT_PERCENTAGE',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSET_LINES.CIP_ACCOUNT',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSET_LINES.TRANSFER_STATUS_M',UPDATE_ALLOWED,PROPERTY_FALSE);       
       app_item_property2.set_property('ASSET_LINES.TRANSFER_REJECTION_REASON_M',UPDATE_ALLOWED,PROPERTY_FALSE);  
       */
       -- End of Mohan Commented to fix the errror reference to CQ# WUP00073691 of 11510 upgrade      	     	
END IF;
END IF;
END IF;
END IF;
END IF;

END; 
------------------------
-- End of PA Clarify ticket # 20041118_03140(Restricted form access to CW Project Manager) Resley Cole  12/04
-------------------------

------------------------
-- Beginning of PO Clarify ticket # 20050826_02720(Creating custom error message if the end user tries to use 
-- X as the company code for the GL string on the POXRQERQ form) Resley Cole  09/05
-------------------------
DECLARE
	
form_name             VARCHAR2(30):= name_in('system.current_form');
block_name            VARCHAR2(30):= name_in('system.cursor_block');
item_name	            VARCHAR2(90):= name_in('system.cursor_item');
v_code_combination    VARCHAR2(90);
v_item_num            VARCHAR2(90);
v_line_num            NUMBER;
V_SEGMENT1             VARCHAR2(90);
v_error_found	        boolean;
v_req_id            NUMBER;
v_count              NUMBER;
CURSOR  gl_code_string_cur is
               select  distinct
                       rla.LINE_NUM   v_line_num         
                      ,gcc.segment1   v_segment1                    
               from   po_requisition_headers_all rha
                     ,PO_REQUISITION_LINES_ALL   rla
                     ,PO_REQ_DISTRIBUTIONS_ALL   rda
                     ,gl_code_combinations       gcc
               where  rha.REQUISITION_HEADER_ID = v_req_id
               and    rha.REQUISITION_HEADER_ID = rla.REQUISITION_HEADER_ID
               and    rla.REQUISITION_LINE_ID   = rda.REQUISITION_LINE_ID
               and    rda.code_combination_id   = gcc.code_combination_id
               and    substr(gcc.SEGMENT1,1,1)  = 'X';
BEGIN

	v_error_found := false ;	  	                 
   	
 IF              (form_name  = 'POXRQERQ' AND 
	               (
	               ( -- Sriram S WUP00141934 07-Nov-2008 
	                 -- Added PO_APPRIOVE block to the IF condition to prevent approval
	               	 -- if item has 'X' account setup 
	                (block_name = 'PO_REQ_HDR' OR block_name = 'LINES') AND (event_name = 'WHEN-NEW-ITEM-INSTANCE')) OR 
		              (block_name = 'PO_APPROVE' AND event_name = 'WHEN-NEW-BLOCK-INSTANCE')
		              ) AND     -- OR  -- Sue Gibson 11/14/06 to prevent recursion 
--	               (event_name = 'WHEN-NEW-ITEM-INSTANCE' OR     -- sg1457
--	                event_name = 'ZOOM')           AND	         -- sg1457
	               NAME_IN('PO_REQ_HDR.REQUISITION_HEADER_ID') IS NOT NULL   AND          
	               name_in('LINES.CHARGE_ACCOUNT') IS NOT NULL  AND
	               name_in('LINES.LINE_NUM') >= 1 )     THEN 	  
	               
	               --fnd_message.DEBUG('WNII-X code check.');              
	               
	                v_req_id  := NAME_IN('PO_REQ_HDR.REQUISITION_HEADER_ID');
	                
	     open  gl_code_string_cur;
	     
	      FETCH gl_code_string_cur INTO v_line_num,v_segment1;
	      
	      close gl_code_string_cur;
	      
	      IF  v_segment1 = 'X'  then
	      	
	      	 fnd_message.set_string('X does not exist on any rule.'||'  '|| 
  			                               'You MUST change the GL string in Distributions on'||'  '||
  			                               'Line #'||' '||V_LINE_NUM||'.');
  	       FND_MESSAGE.ERROR; 	    
  	       
  	       -- Sriram S WUP00141934 07-Nov-2008 
  	       -- Raise Form Trigger failure if validation is called from PO_APPROVE block
  	       IF block_name = 'PO_APPROVE' THEN
             go_block('PO_REQ_HDR');  
           	 raise form_trigger_failure;
           END IF; 
  	    	   
  	    	       	       
	      END IF;
	      END IF;  

  END;
------------------------
-- End of PO Clarify ticket # 20050826_02720(Creating custom error message if the end user tries to use 
-- X as the company code for the GL string on the POXRQERQ form) Resley Cole  09/05
------------------------- 
 
------------------------
-- START of PO Clarify ticket # 20050826_02768(Creating custom LOV for the end user when they query information  
--  on requisitions on the POXRQERQ form) Resley Cole  09/05
-------------------------
DECLARE
	
form_name       VARCHAR2(30)  := name_in('system.current_form');
block_name      VARCHAR2(30)  := name_in('system.cursor_block');
item_name				VARCHAR2(90)  := name_in('system.cursor_item');
s2_rg_query     VARCHAR2(7000):= 'select  distinct
                                          rha.segment1
                                         ,rha.requisition_header_id 
                                         ,rha.TYPE_LOOKUP_CODE 
                                         ,rha.authorization_status
                                         ,rha.creation_date      
                                   from   po_requisition_headers_all rha
                                         ,PO_REQUISITION_LINES_ALL rla      
                                   where  rha.REQUISITION_HEADER_ID = rla.REQUISITION_HEADER_ID
                                   and    rla.LINE_LOCATION_ID      is null
                                   and    (rla.cancel_flag != ''Y'' or
                                           rla.cancel_flag = ''N'' or
                                           rla.cancel_flag IS NULL)
                                   and    rha.authorization_status  in (''INCOMPLETE'',''REJECTED'',''RETURNED'') 
                                   and    (rha.type_lookup_code = decode(''BOTH'',''BOTH'',rha.type_lookup_code,''BOTH'')
                                            or rha.type_lookup_code = ''INTERNAL'') 
                                   and    :po_startup_values.employee_id       = rha.preparer_id                                    
                                   and    :po_startup_values.internal_security = ''PUBLIC'''; 

/*'select distinct
        rhv.segment1
       ,rhv.requisition_header_id
       ,rhv.document_type_display 
       ,rhv.authorization_status_disp 
       ,rhv.creation_date 
from    po_requisition_headers_v rhv
       ,PO_REQUISITION_LINES_ALL rla
where   rhv.authorization_status in (''INCOMPLETE'', ''REJECTED'', ''RETURNED'')
and     rhv.REQUISITION_HEADER_ID = rla.REQUISITION_HEADER_ID
and     rla.LINE_LOCATION_ID is null
and     rla.cancel_flag != ''Y''
and     rhv.type_lookup_code = decode(''BOTH'', ''BOTH'', rhv.type_lookup_code, ''BOTH'') 
and     (:po_startup_values.employee_id = rhv.preparer_id 
          or(rhv.type_lookup_code = ''INTERNAL'' 
and     ((:po_startup_values.internal_security = ''PUBLIC'' 
and     :po_startup_values.internal_access != ''VIEW_ONLY'' ) 
          or (:po_startup_values.internal_security = ''PURCHASING'' 
and     :po_startup_values.internal_access != ''VIEW_ONLY'' 
and     exists (select ''this employee is an agent'' 
                from   po_agents poa 
                where  poa.agent_id = :po_startup_values.employee_id 
                and    sysdate between nvl(poa.start_date_active, sysdate) 
                and    nvl(poa.end_date_active, sysdate + 1)) ) 
                        or (:po_startup_values.internal_security = ''HIERARCHY'' 
                and :po_startup_values.internal_access != ''VIEW_ONLY'' 
and    :po_startup_values.employee_id in 
                 (select poeh.superior_id 
                  from   po_employee_hierarchies poeh 
                  where  poeh.employee_id = preparer_id 
                  and    poeh.position_structure_id = :po_startup_values.security_structure_id) ) ) ) 
                    or( type_lookup_code = ''PURCHASE'' 
and    ((:po_startup_values.purchase_security = ''PUBLIC'' 
and      :po_startup_values.purchase_access != ''VIEW_ONLY'' ) 
           or (:po_startup_values.purchase_security = ''PURCHASING'' 
and      :po_startup_values.purchase_access != ''VIEW_ONLY'' 
and     exists (select ''this employee is an agent'' 
                from   po_agents poa 
                where  poa.agent_id = :po_startup_values.employee_id 
                and    sysdate between nvl(poa.start_date_active, sysdate) 
                and    nvl(poa.end_date_active, sysdate + 1)) ) 
                         or (:po_startup_values.purchase_security = ''HIERARCHY'' 
                and    :po_startup_values.purchase_access != ''VIEW_ONLY'' 
                and    :po_startup_values.employee_id in 
                         (select poeh.superior_id 
                          from   po_employee_hierarchies poeh 
                          where  poeh.employee_id = preparer_id 
                          and    poeh.position_structure_id = :po_startup_values.security_structure_id) ) ) ) ) 
order by decode(:po_startup_values.manual_req_num_type,''NUMERIC'', null, segment1) 
        ,decode(:po_startup_values.manual_req_num_type,''NUMERIC'', to_number(segment1), null)'; */                                              

                                               
rq2_rg_id        RECORDGROUP;                           
new2_rq_rg_id    NUMBER;
rq2_group_name   VARCHAR2(30)  := 'REQ_HDR_QF';

BEGIN


IF        (form_name  = 'POXRQERQ' AND 
           block_name = 'PO_REQ_HDR' AND
           name_in('SYSTEM.RECORD_STATUS') IS NOT NULL AND
	         event_name = 'WHEN-NEW-ITEM-INSTANCE')   THEN
	         
	         --fnd_message.DEBUG('WNII-H-Status not null. Cole LOV');
	         
           rq2_rg_id  := find_group('REQ_HDR_QF'); 	     	        
	        
          Delete_Group_Row(rq2_rg_id ,ALL_ROWS);
             
          new2_rq_rg_id  := POPULATE_GROUP_WITH_QUERY(rq2_rg_id ,s2_rg_query);
               
                
END IF; 
          	
END;
------------------------
--END of PO Clarify ticket # 20050826_02768(Creating custom LOV for the end user when they query information  
--  on requisitions on the POXRQERQ form) Resley Cole  09/05
------------------------- 

------------------------
--       START of EPL 2.5 Project- Quote from po_requisition_headers_all attribute12 to 
--                                 po_headers_all attribute12 on the POXPOEPO form) Resley Cole  12/05
-------------------------
/*
DECLARE	
sys_work	         VARCHAR2(30)  := name_in('system.suppress_working');
v_sys_msglvl       NUMBER;        
form_name          VARCHAR2(30)  := name_in('system.current_form');
block_name         VARCHAR2(30)  := name_in('system.cursor_block');
item_name	         VARCHAR2(90)  := name_in('system.cursor_item');
v_po_header_id     NUMBER;                
v_req_quote        VARCHAR2(30)  :=NULL;
v_po_quote         VARCHAR2(30)  :=NULL;

CURSOR  copy_quote IS  select pha.attribute12
            
            from   po_requisition_headers_all pha
            where  pha.rowid =
            (
             select min(pha_sub.rowid)
             from   po_requisition_headers_all pha_sub,
                    po_requisition_lines_all pla,
                    po_req_distributions_all pda,
                    po_distributions_all poda
             where  pha_sub.requisition_header_id = pla.requisition_header_id
             and    pla.requisition_line_id       = pda.requisition_line_id
             and    pda.distribution_id           = poda.req_distribution_id
             and    poda.po_header_id             = v_po_header_id
            ); 
                       
BEGIN  
	
	IF        (form_name  = 'POXPOEPO'    AND
    	       block_name = 'PO_HEADERS'  AND 
    	       name_in('PO_HEADERS.ATTRIBUTE12')IS NULL) THEN
    	      
    	      v_po_header_id := NAME_IN('PO_HEADERS.PO_HEADER_ID');  
    	          
       	
	open  copy_quote;
	
   	fetch copy_quote into v_po_quote;
	
	close copy_quote;

	copy(v_po_quote,'PO_HEADERS.ATTRIBUTE12'); 	 

	END IF;	
	END;
	IF     (form_name  = 'POXPOEPO'          AND
    	      block_name = 'PO_HEADERS'        AND     	      
    	      name_in('PO_HEADERS.STATUS') != 'APPROVED'  AND
    	      event_name = 'WHEN-CREATE-RECORD') THEN
    	         	          	     
    	      
    	      set_block_property('PO_HEADERS',UPDATE_ALLOWED,PROPERTY_TRUE);
    	      set_block_property('PO_HEADERS',UPDATE_CHANGED_COLUMNS,PROPERTY_TRUE);
    	      
    	      v_po_header_id := name_in('PO_HEADERS.PO_HEADER_ID');                      
     
            select pha.attribute12
            into   v_po_quote
            from   po_requisition_headers_all pha
            where  pha.rowid =
            (
             select min(pha_sub.rowid)
             from   po_requisition_headers_all pha_sub,
                    po_requisition_lines_all pla,
                    po_req_distributions_all pda,
                    po_distributions_all poda
             where  pha_sub.requisition_header_id = pla.requisition_header_id
             and    pla.requisition_line_id       = pda.requisition_line_id
             and    pda.distribution_id           = poda.req_distribution_id
             and    poda.po_header_id             = v_po_header_id
            );   
          IF    v_po_quote IS NOT NULL THEN       
                copy(v_po_quote,'PO_HEADERS.ATTRIBUTE12');        
                                     
                   
      END IF;    
	     END IF; */   
------------------------
--       END of EPL 2.5 Project- Quote from po_requisition_headers_all attribute12 to 
--                               po_headers_all attribute12 on the POXPOEPO form) Resley Cole  12/05
-------------------------    

-------------------------
--       START of Clarify ticket 20051109_01466 - Manage buyer workload form: Enable "select all" menu item 
--       on the POXRQARQ form) Resley Cole  01/06
------------------------- 
DECLARE	
			
BEGIN 
 
     IF     (form_name  = 'POXRQARQ'   AND
            (block_name = 'ASSIGN' OR block_name = 'REQ_LINES'))   THEN                    
            
             Set_Menu_Item_Property('VIEW.ZOOM',ENABLED,PROPERTY_TRUE); 
                  
         IF      (form_name  = 'POXRQARQ'  AND
                  event_name = 'ZOOM')      THEN
                  
                  GO_BLOCK('REQ_LINES');
                 
                 FIRST_RECORD;                                                       
                 	
             BEGIN         	
         	
                 	WHILE  name_in('REQ_LINES.FOLDER_RECORD_SELECTOR') ='N' AND  
         	               name_in('SYSTEM.RECORD_STATUS') IS NOT NULL	
                     
                    LOOP 	
               				
							          copy('Y','REQ_LINES.FOLDER_RECORD_SELECTOR');
							          
                        GO_ITEM('REQ_LINES.FOLDER_RECORD_SELECTOR');
                      
                        Execute_Trigger('WHEN-CHECKBOX-CHANGED');  

                        NEXT_RECORD; 
                     
                    END LOOP;
                    
                        FIRST_RECORD; 
                 END;
           END IF;
             
     END IF;
     
END; 
--       END of Clarify ticket 20051109_01466 - Manage buyer workload form: Enable "select all" menu item 
--       on the POXRQARQ form) Resley Cole  01/06
------------------------- 

------------------------
--      START of TAXPAYER ID WARNING
--      Maury Marcus, 13-Jan-2006
------------------------- 
DECLARE

v_vendor_id       number ;
v_num_1099_mir    varchar2(30) ;
v_num_1099        varchar2(30) ;
v_dup_vendor_num  varchar2(30) ;
v_dup_vendor_name varchar2(80) ;

BEGIN

if (form_name = 'APXVDMVD') then
  if (block_name = 'VNDR') then
    if (event_name in ('WHEN-VALIDATE-RECORD','WHEN-NEW-RECORD-INSTANCE')) then
      
      v_vendor_id :=    nvl(name_in('VNDR.VENDOR_ID'),0) ;
      v_num_1099_mir := name_in('VNDR.NUM_1099_MIR') ;
      v_num_1099 :=     name_in('VNDR.NUM_1099') ;

      if v_num_1099_mir is not null
      or v_num_1099 is     not null then

        v_dup_vendor_num :=  null ;
        v_dup_vendor_name := null ;

        begin

        select segment1, vendor_name
        into   v_dup_vendor_num, v_dup_vendor_name
        from   po_vendors
        where  rowid =
        (
        select min(rowid)
        from   po_vendors
        where  vendor_id != v_vendor_id
        and    num_1099 =   nvl(v_num_1099_mir,v_num_1099)
        ) ;

        exception

        when others then
          v_dup_vendor_num :=  null ;
          v_dup_vendor_name := null ;

        end ;

        if v_dup_vendor_num is  not null
        or v_dup_vendor_name is not null then

        fnd_message.set_string
          (
          'Warning:  Supplier number '||v_dup_vendor_num||', name '||v_dup_vendor_name||
          ', already uses Taxpayer ID '||nvl(v_num_1099_mir,v_num_1099)||' !'
          ) ;
        fnd_message.show;
         --fnd_message.error ;
         --raise form_trigger_failure ;

        end if ;
      end if ;
    end if ;
  end if ;
end if ;

END ;
------------------------
--      END of TAXPAYER ID WARNING
------------------------- 

/*
-------------------------
--      START of Network Error Handling: quick hits   Resley Cole 03-21-2006
-------------------------
DECLARE
	
v_userid      NUMBER       := apps.FND_PROFILE.VALUE('RESP_ID');
v_appl_name   VARCHAR2(80) := apps.FND_PROFILE.VALUE('RESP_NAME');
v_org_name    varchar2(240) ;
v_action_code varchar2(240) ;
v_po_number   number;
v_line_number number;	
v_qty_recvd   number;
v_org_id      number;
v_inv_id      number; 
v_dwnld_flag      varchar2(240) ;

begin
	
--IF     v_userid    != '50350'                  OR
	     --v_appl_name != 'CW Project Manager'   THEN 	
	
IF        (
	          form_name  = 'POXPOVPO'     AND 
	         (block_name = 'LINES_FOLDER' OR 
	          block_name = 'PO_DOCON_CONTROL'   OR
	          block_name = 'SHIPMENTS_FOLDER' AND
	          event_name = 'SPECIAL9')        AND
	          item_name  = 'PO_DOCON_CONTROL.ACTION'
	        ) THEN	
	         
	         v_po_number  := name_in('LINES_FOLDER.PO_NUM');
	         v_line_number:= name_in('LINES_FOLDER.LINE_NUM');
	         v_inv_id     := name_in('LINES_FOLDER.ITEM_ID');	         
	         --v_org_id    := name_in('SHIPMENTS_FOLDER.SHIP_TO_ORGANIZATION');
           v_qty_recvd  := name_in('SHIPMENTS_FOLDER.QUANTITY_RECEIVED');          
          
         	
	           select pla.QUANTITY_RECEIVED qty_recvd      
                   --,msi.ORGANIZATION_ID
             into   v_qty_recvd
                   --,v_org_id   
             from   po_headers_all pha
                   ,po_lines_all pll
                   ,MTL_SYSTEM_ITEMS_B msb
                   ,MTL_SECONDARY_INVENTORIES msi
                   ,PO_LINE_LOCATIONS_ALL pla 
             where  pha.po_header_id      = pll.po_header_id             
             and    msb.ORGANIZATION_ID   = msi.ORGANIZATION_ID
             and    pla.PO_LINE_ID        = pll.PO_LINE_ID
             and    MSB.ATTRIBUTE8        IN('C','E','G','N')
             AND    msb.ORGANIZATION_ID   = '87'
             and    msb.INVENTORY_ITEM_ID = v_inv_id 
             and    pha.segment1          = v_po_number 
             and    pll.line_num          = v_line_number;
             
             IF v_qty_recvd   > 0   then 
       
                  fnd_message.set_string
                  (
                   'CATS Receipts are present.' ||'  '||'PO line cancellation is NOT ALLOWED.'
                  );
                   fnd_message.error ;
                   raise form_trigger_failure ;
               --end if;
          end if;
          end if;
end;
-------------------------
--      END of Network Error Handling: quick hits   Resley Cole 03-21-2006
-------------------------
*/

/*
-------------------------
-- START of Network Error Handling: quick hits   Resley Cole 03-21-2006     copied from DEVT on 6/5/06
-------------------------
--Purchase Order Summary Form
DECLARE
	
v_userid      NUMBER       := apps.FND_PROFILE.VALUE('RESP_ID');
v_appl_name   VARCHAR2(80) := apps.FND_PROFILE.VALUE('RESP_NAME');
v_org_name    varchar2(240) ;
v_action_code varchar2(240) ;
v_po_hdr_id   number;
v_po_num      number;
v_line_number number;	
v_qty_recvd   number;
v_org_id      number;
v_inv_id      number;
v_lnloc_id    number;
v_rcv_count   number; 
v_cat_count     varchar2(240) ;
--v_profile1    varchar2(240):= apps.FND_PROFILE.VALUE('CW CATS PO LINE CANCEL PRIVILEGE');
--v_profile2    varchar2(240):= apps.FND_PROFILE.VALUE('CW_CATS_ADMIN');
v_profile1    varchar2(240);
v_profile2    varchar2(240);
CURSOR  qty_rcvd IS  select pla.QUANTITY_RECEIVED               
                     from   po_lines_all pll  
                           ,mtl_system_items_b msi
                           ,po_line_locations_all pla       
                     where  pll.po_header_id      = v_po_hdr_id
                     and    pll.line_num          = v_line_number
                     and    pll.item_id           = v_inv_id
                     and    pll.item_id           = msi.inventory_item_id                     
                     and    pla.po_line_id        = pll.po_line_id                                        
                     and    msi.organization_id   = '87'
                     and    msi.attribute8       in ('C','E','G','N');
                     
                                        

begin            
	
IF         (
	          form_name  = 'POXPOVPO'     AND	           
	         (block_name = 'LINES_FOLDER' OR 
	          block_name = 'PO_DOCON_CONTROL'   OR
	          block_name = 'SHIPMENTS_FOLDER')	          
	          ) THEN	
	         
	         v_po_hdr_id  := name_in('LINES_FOLDER.PO_HEADER_ID');
	         v_po_num     := name_in('LINES_FOLDER.PO_NUM');
	         v_line_number:= name_in('LINES_FOLDER.LINE_NUM');
	         v_inv_id     := name_in('LINES_FOLDER.ITEM_ID');	         
	         --v_org_id    := name_in('SHIPMENTS_FOLDER.SHIP_TO_ORGANIZATION');
           --v_qty_recvd  := name_in('SHIPMENTS_FOLDER.QUANTITY_RECEIVED');
           
            select fov.profile_option_value
             into   v_profile1
             from   fnd_profile_option_values fov
                   ,fnd_profile_options fpo
             where  fov.profile_option_id = fpo.profile_option_id 
             and    fpo.profile_option_name = 'CW CATS PO LINE CANCEL PRIVILEGE';
             
              select fov.profile_option_value
             into   v_profile2
             from   fnd_profile_option_values fov
                   ,fnd_profile_options fpo
             where  fov.profile_option_id = fpo.profile_option_id 
             and    fpo.profile_option_name = 'CW_CATS_ADMIN'; 

                 
          IF (v_profile1 = 'N' OR v_profile2 = 'N') THEN 
                   
         	IF name_in('PO_DOCON_CONTROL.ACTION')= 'CANCEL PO LINE' THEN 
        	
	     
	             open  qty_rcvd;
	             
	             fetch qty_rcvd into v_qty_recvd ;
	             
	             close qty_rcvd;

             	  
             	  IF v_qty_recvd   > 0  then

                  fnd_message.set_string
                  (
                   'CATS Receipts are present.' ||'  '||'PO line cancellation is NOT ALLOWED.'
                  );
                   fnd_message.error ;
                   raise form_trigger_failure ;
                  
                  
             end if;      
             end if;
             end if;
          end if;
end;

--Receiving Form
DECLARE
v_userid        NUMBER       := apps.FND_PROFILE.VALUE('RESP_ID');
v_appl_name     VARCHAR2(80) := apps.FND_PROFILE.VALUE('RESP_NAME');
v_rcv_item_id   NUMBER;
v_rcv_qty_chk   VARCHAR2(1);
--v_profile1    varchar2(240):= apps.FND_PROFILE.VALUE('CW CATS PO LINE CANCEL PRIVILEGE');
--v_profile2    varchar2(240):= apps.FND_PROFILE.VALUE('CW_CATS_ADMIN');
v_profile1    varchar2(240);
v_profile2    varchar2(240);

BEGIN
	IF (form_name  = 'RCVRCERC'        AND
		  block_name = 'RCV_TRANSACTION' AND		 
		  name_in('RCV_TRANSACTION.LINE_CHKBOX') = 'Y')  THEN		  
		  
		   v_rcv_item_id := name_in('RCV_TRANSACTION.ITEM_ID');
		   
		      select fov.profile_option_value
             into   v_profile1
             from   fnd_profile_option_values fov
                   ,fnd_profile_options fpo
             where  fov.profile_option_id = fpo.profile_option_id 
             and    fpo.profile_option_name = 'CW CATS PO LINE CANCEL PRIVILEGE';
             
              select fov.profile_option_value
             into   v_profile2
             from   fnd_profile_option_values fov
                   ,fnd_profile_options fpo
             where  fov.profile_option_id = fpo.profile_option_id 
             and    fpo.profile_option_name = 'CW_CATS_ADMIN';
	
	   IF (v_profile1 = 'N' OR v_profile2 = 'N') THEN 
		   
		                    select count(1)
		                    into   v_rcv_qty_chk
                        from   mtl_system_items_b
                        where  attribute8 in ('C','E','G','N')
                        and    inventory_item_id = v_rcv_item_id
                        and    organization_id   = '87';
		   	
		   	IF  v_rcv_qty_chk > 0  THEN 
		          
                  fnd_message.set_string
                  (
                   'This is a CATS trackable item, receipts in Oracle can'
                    ||'  '||'only be performed by a CATS Admin.'  
                  );
                   fnd_message.error ;
                   raise form_trigger_failure ;           
	
		   end if;
		   
	end if;
	end if;
end;

DECLARE
v_userid      NUMBER       := apps.FND_PROFILE.VALUE('RESP_ID');
v_appl_name   VARCHAR2(80) := apps.FND_PROFILE.VALUE('RESP_NAME');
v_rcv_org_name    varchar2(240) ;
v_rcv_action_code varchar2(240) ;
v_rcv_po_number   number;
v_rcv_line_number number;	
v_rcv_qty_recvd   number;
v_rcv_tol_org_id      number;
v_rcv_tol_item_id  number;
v_rcv_tol_flg  number;
CURSOR  rcv_tol_dwnld_flag IS  select attribute8                
                               from   mtl_system_items_b
                               where  inventory_item_id = v_rcv_tol_item_id
                               and    organization_id   = '87';	
--v_profile1    varchar2(240):= apps.FND_PROFILE.VALUE('CW CATS PO LINE CANCEL PRIVILEGE');
--v_profile2    varchar2(240):= apps.FND_PROFILE.VALUE('CW_CATS_ADMIN');
v_profile1    varchar2(240);
v_profile2    varchar2(240);

BEGIN
	
		IF   (form_name = 'POXPOEPO' AND
	    	    (block_name = 'LINES'   OR
		    block_name = 'PO_SHIPMENTS') AND
		    item_name = 'PO_SHIPMENTS.QTY_RCV_TOLERANCE') THEN
		    
		    v_rcv_tol_item_id := name_in ('PO_LINES.ITEM_ID');
	
	          select fov.profile_option_value
             into   v_profile1
             from   fnd_profile_option_values fov
                   ,fnd_profile_options fpo
             where  fov.profile_option_id = fpo.profile_option_id 
             and    fpo.profile_option_name = 'CW CATS PO LINE CANCEL PRIVILEGE';
             
              select fov.profile_option_value
             into   v_profile2
             from   fnd_profile_option_values fov
                   ,fnd_profile_options fpo
             where  fov.profile_option_id = fpo.profile_option_id 
             and    fpo.profile_option_name = 'CW_CATS_ADMIN';  
             
          select count(1)
		      into  v_rcv_tol_flg
          from   mtl_system_items_b
          where  attribute8 in ('C','E','G','N')
          and    inventory_item_id = v_rcv_tol_item_id
          and    organization_id   = '87';                               

	
  	IF (v_profile1 = 'N' OR v_profile2 = 'N') THEN 
	    
		    
		    IF v_rcv_tol_flg > 0  THEN
		    
		  app_item_property2.set_property('PO_SHIPMENTS.QTY_RCV_TOLERANCE',UPDATE_ALLOWED,PROPERTY_FALSE); 
		  
		    END IF;
		   END IF; 
	END IF;
	END;
*/	 
-------------------------
--      END of Network Error Handling: quick hits   Resley Cole 03-21-2006
-------------------------

-------------------------
--      START of code for Order Entry form   Salman Siddiqui (Custom RMA Packing Slip ) 04-27-2006
-------------------------
/*	
--Form name is OEXOEORD.fmb
DECLARE
		OE_Ord_Num number; 
    OE_Ord_Eml varchar2(60); 

BEGIN	

      IF (form_name   = 'OEXOEORD' AND       	     
      	  block_name  = 'ORDER')   THEN      	          	    
      	     
      	   Set_Menu_Item_Property('VIEW.ZOOM',ENABLED,PROPERTY_TRUE); 
      	     
      IF (form_name  = 'OEXOEORD'                   AND               
          name_in('ORDER.ORDER_NUMBER') IS NOT NULL AND 
          event_name = 'ZOOM')                      THEN  
          
          OE_Ord_Num := NAME_IN('ORDER.ORDER_NUMBER');
          OE_Ord_Eml := NAME_IN('ORDER.ATTRIBUTE10');
          
         IF OE_Ord_Eml IS NULL THEN 
    	
    	   fnd_message.set_string
          ('There is no email address defined for this Order'||''''''||OE_Ord_Num) ;
        fnd_message.show;
   
        else
          
          fnd_message.set_string
          (
          'This is your order number '||OE_Ord_Num||'and '||OE_Ord_Eml||
          'is your email address ') ;
        fnd_message.show;
          
           	--param_to_pass1 := name_in('ORDER.order_number'); 
        		--param_to_pass2 := name_in('ORDER.attribute10');                         	     
      	    FND_Function.Execute( FUNCTION_NAME => 'CCWRMAPACK_FN',  
                                  OPEN_FLAG     => 'Y',  
                                  SESSION_FLAG  => 'Y',
																  OTHER_PARAMS  => 'ORDER_NUMBER="'||OE_Ord_Num|| 
                                                   '" EMAIL_ADDRESS="'||OE_Ord_Eml||'"'); 

   
       END IF;         
       END IF;  
       end if;	   
END;     
*/
-------------------------
--      END of code for Order Entry form   Salman Siddiqui 04-27-2006
-------------------------

------------------------
--Start of Project Location validation for the distribution block on PO Order Entry form (POXPOEPO) Salman Siddiqui
--START of DISTRIBUTION Validation
/*
DECLARE
		 v_pocharge					    	VARCHAR2(81) DEFAULT NULL;
		 v_project						    VARCHAR2(30) DEFAULT NULL;
		 v_project2					    	VARCHAR2(30) DEFAULT NULL;
		 v_item_desc					    VARCHAR2(81) DEFAULT NULL;		 
		 v_item_id					    	NUMBER;                     
		 v_org_id						    	NUMBER;                     
		 v_capital_item			    	VARCHAR2(1)  DEFAULT NULL;  
		 v_project_id             NUMBER;                     
		 v_project_id2            NUMBER;                     
		 v_location               VARCHAR2(30) DEFAULT NULL;  
		 v_valid_location         VARCHAR2(1)  DEFAULT NULL;		 
		 VV_HEADER_LOCTION_CODE		VARCHAR2(100);---
		 VV_PO_HDR_SEG1		        VARCHAR2(100);---
		 VV_PO_HDR_ID  	          NUMBER;
	   v_shp_proj_id            NUMBER;
     v_shp_proj               VARCHAR2(100);
     v_mesg_lvl               NUMBER;
     v_po_distribution_id						NUMBER;
     
     
     --Message_Level  NUMBER := NAME_IN('system.cursor_block'):= '20';  

CURSOR v_proj_shipment is    SELECT DISTINCT 
      	                            PROJECT_ID
      	                           ,SEGMENT1      	                
      	   	 			           FROM   pa_projects_all 
      	   	 			           WHERE  project_id in
      	   	 			                 (
      	   	 			                  select distinct 
      	   	 			                         pda.project_id 
                                    from   po_distributions_all pda
                                          ,po_headers_all poh
                                    where  pda.po_header_id = poh.po_header_id 
                                    and    poh.po_header_id = VV_PO_HDR_ID
                                   )
                                   and  rownum < 2;   
		           
BEGIN	

           IF (form_name  = 'POXPOEPO'     AND
	             (block_name = 'PO_DISTRIBUTIONS' OR  block_name = 'PO_APPROVE') AND
	            ----event_name = 'WHEN-NEW-BLOCK-INSTANCE'
	--					event_name in ('WHEN-NEW-BLOCK-INSTANCE','WHEN-NEW-RECORD-INSTANCE', 'WHEN-VALIDATE-RECORD')  --7/24/06
	
		event_name in ('WHEN-NEW-BLOCK-INSTANCE','WHEN-NEW-RECORD-INSTANCE', 'WHEN-VALIDATE-ITEM', 'WHEN-VALIDATE-RECORD') 
	           AND name_in ('SYSTEM.RECORD_STATUS') IS NOT NULL )THEN

	   	         	VV_PO_HDR_ID := NAME_IN('PO_DISTRIBUTIONS.PO_HEADER_ID');
	   	         	v_location   := NAME_IN('PO_DISTRIBUTIONS.DELIVER_TO_LOCATION');
	   	         		v_project_id   := NAME_IN('PO_DISTRIBUTIONS.PROJECT_ID');   ---08/14
	   					--	v_po_distribution_id := NAME_IN('PO_DSITRIBUTIONS.PO_DISTRIBUTION_ID');    ---added on 8/13/06
	   								         	
			select segment1 into v_project from pa_projects_all where project_id = v_project_id;

			

				v_valid_location := 'F';
      	for c1 in (SELECT DISTINCT PROJECT_ID, SEGMENT1
      	   	 						FROM pa_projects_all 
      	   	 						WHERE project_id in (select distinct pda.project_id 
                         from po_distributions_all pda, po_line_locations_all pol,
                         po_headers_all poh
                         where poh.po_header_id = pol.po_header_id
                         and pol.line_location_id = pda.line_location_id
                         and pol.po_line_id = pda.po_line_id
                         and pda.deliver_to_location_id in (select ship_to_location_id from hr_locations where
                         location_code = v_location) 
                         and pda.po_header_id = poh.po_header_id 
                         and poh.po_header_id = VV_PO_HDR_ID
                         ))		
						 LOOP

--							IF 
		--				CW_PO_POET_WF_PKG.VALID_LOCATION(c1.project_id,v_location,v_valid_location);
							CW_PO_POET_WF_PKG.VALID_LOCATION(v_project_id,v_location,v_valid_location);
		
					--	V_PROJECT := C1.SEGMENT1;
  			--		IF V_VALID_LOCATION = 'T' THEN
					--  EXIT ;
  			--ELSIF 
  		IF		v_valid_location = 'F' AND v_project IS NOT NULL THEN 
  			FND_MESSAGE.SET_STRING('Ship-To Location'||''''||v_location||''''||' is not valid for Project '||''''||v_project||
					                       ''''||''''||'  DO NOT PROCEED WITHOUT Correcting the Location.');
		    FND_MESSAGE.ERROR;
		   --- 	copy(NULL, 'PO_DISTRIBUTIONS.DELIVER_TO_LOCATION');	     	
		RAISE form_trigger_failure;
		
		END IF;
		
---		END LOOP;
    
	       	END IF;      
          
          
END; 


--END oF DISTRIBUTION Validation
*/

---START of SHIPMENT Validation   --working better  10/17/06  PO Form Only
-- 14-AUG-07 Sue Gibson Modified loop to handle no-data-found
-- 19-JUN-08 Sue Gibson CR 170450 change error to note and do not fail form when location/project do not match
--                                restructured block for readability
-- 29-JUL-08 Sue Gibson Modified code block to also validate project/location upon PO Header new record so that
--                                when PO is created by AUTOCREATE, user will immediately know if project/location
--                                match is no longer valid.	
-- 06-AUG-08 Sue Gibson           To stop approval without locking up form added check to final part of block
-- 11-AUG-08 Sue Gibson           when-new-record-instance for block PO_APPROVE, make sure all lines meet the
--                                project/location validation, not just current line; added cursors
-- 22-SEP-08 Salman Siddiqui     modified as per WUP00139002 -- ss9085 09/22/08
-- 12-DEC-08 Sue Gibson          modified as per WUP00154651 to not allow PO approval in any status when company = 'X'
-- 16-JUN-09 Udai Anjanaiah			Hard Stop to raise error when ship to location does not match
--															with Project location for a PO line. Refer WUP00200949
--

DECLARE
		 v_pocharge					    	VARCHAR2(81) DEFAULT NULL;
		 v_project						    VARCHAR2(30) DEFAULT NULL;
		 v_project2					    	VARCHAR2(30) DEFAULT NULL;
		 v_old_project            VARCHAR2(30) DEFAULT NULL;
		 v_item_desc					    VARCHAR2(81) DEFAULT NULL;		 
		 v_item_id					    	NUMBER;                     
		 v_org_id						    	NUMBER;                     
		 v_capital_item			    	VARCHAR2(1)  DEFAULT NULL;  
		 v_project_id             NUMBER;                     
		 v_project_id2            NUMBER;                     
		 v_location               VARCHAR2(30) DEFAULT NULL;  
		 v_valid_location         VARCHAR2(1)  DEFAULT NULL;		 
		 VV_HEADER_LOCATION_CODE		VARCHAR2(100);---
		 VV_PO_HDR_SEG1		        VARCHAR2(100);---
		 VV_PO_HDR_ID  	          NUMBER;
		 VV_PO_LINE_ID            NUMBER;  -- Sue Gibson 08-AUG-07
		 VV_PO_LINE_LOC_ID        NUMBER;  -- DITTO
	   v_shp_proj_id            NUMBER;
     v_shp_proj               VARCHAR2(100);
     v_mesg_lvl               NUMBER;
     v_ship_to_loc_id         number;  -- Sue Gibson 29-JUL-08 added next three
     v_val_rec_fired          number;
		 v_valid_companies        VARCHAR2(20);  -- 13-AUG-07 
     v_loc_company            VARCHAR2(20);
     v_proj_company           VARCHAR2(20);    
     v_output_error_msg       VARCHAR2(200);
     v_po_line_cancel					VARCHAR2(10);
     v_po_line_closed					VARCHAR2(40);
     lv_type_lkp_code po_headers_all.TYPE_LOOKUP_CODE%TYPE := 'X';							--Added for CQ WUP00827743 by Pratik on 14-JUN-2013
     
     --Message_Level  NUMBER := NAME_IN('system.cursor_block'):= '20';  
 
CURSOR find_proj_loc_c IS
      SELECT HRL.LOCATION_CODE    location_code,
            pda.project_id        project_id,
            ppa.segment1          project_code,
            pll.po_line_id        po_line_id,
            pol.LINE_NUM          line_num,
            pda.LINE_LOCATION_ID  line_location_id
           FROM pa_projects_all      ppa,
        	      po_distributions_all pda,
					      HR_LOCATIONS         hrl,
                po_lines_all         pol,
                po_line_locations_all pll
          WHERE ppa.project_id       = pda.project_id
					  AND pda.line_location_id = pll.line_location_id
					  AND pda.po_line_id       = pll.po_line_id
			      AND pda.po_header_id     = pll.po_header_id
					  AND hrl.location_id      = pll.ship_to_location_id
					  AND pll.po_line_id       = pol.po_line_id
					  AND pll.po_header_id     = pol.po_header_id
            AND pol.po_header_id     =  VV_PO_HDR_ID;
 
     
BEGIN	
     -- Work for WUP00200949 date 06-16-2009
     IF (form_name  = 'POXPOEPO'     AND
     	NAME_IN('PO_HEADERS.ATTRIBUTE5')!='WIRELINE-ESS' AND --Added by kavya for ESS
--       (block_name = 'PO_SHIPMENTS' OR block_name = 'PO_APPROVE' OR BLOCK_NAME = 'PO_DISTRIBUTIONS') AND  24-JUN-08 Sue Gibson
          ( ( block_name in ('PO_HEADERS','PO_LINES','PO_SHIPMENTS', 'PO_DISTRIBUTIONS') AND     --   24-JUN-08 Sue Gibson
	             name_in ('SYSTEM.RECORD_STATUS') IS NOT NULL                 AND
	            event_name in ( 'WHEN-VALIDATE-RECORD' ,'WHEN-NEW-RECORD-INSTANCE')  ) OR
	          ( block_name = 'PO_APPROVE' AND                                                      -- 06-AUG-08
	            event_name = 'WHEN-NEW-BLOCK-INSTANCE') )   )    THEN                              -- 06-AUG-08 
       
	     VV_PO_HDR_ID      := NAME_IN('PO_HEADERS.PO_HEADER_ID');  -- Changed from shipment to headers block
	   	 v_location        := NAME_IN('PO_SHIPMENTS.SHIP_TO_LOCATION_CODE');
	   	 v_valid_location  := 'T';
--	   	 v_valid_location  := 'F';  20-JUN-08
	   	 VV_PO_LINE_ID     := NAME_IN('PO_LINES.PO_LINE_ID');      -- Sue Gibson 15-AUG-07  -- Changed from shipment to lines block
	   	 VV_PO_LINE_LOC_ID := NAME_IN('PO_SHIPMENTS.LINE_LOCATION_ID');  -- ditto
	   	 v_project         := NAME_IN('PO_DISTRIBUTIONS.PROJECT');     --20-JUN-08
	   	 v_project_id      := NAME_IN('PO_DISTRIBUTIONS.PROJECT_ID');  --20-JUN-08
	   	 v_ship_to_loc_id  := NAME_IN('PO_SHIPMENTS.SHIP_TO_LOCATION_ID');  --29-JUL-08

       IF event_name = 'WHEN-NEW-RECORD-INSTANCE' THEN
       	 v_val_rec_fired := 0;
       END IF;
					
					lv_type_lkp_code := NAME_IN('PO_HEADERS.TYPE_LOOKUP_CODE');
					
					IF lv_type_lkp_code = 'STANDARD'
						THEN
						
       IF block_name  = 'PO_SHIPMENTS'  THEN -- Begin validations for PO_SHIPMENTS block 
       	 	 IF VV_PO_LINE_LOC_ID IS NULL  THEN  --new shipment record for line loc and proj validation
			       V_VALID_LOCATION := 'T';                 --  do not validate  
       	 	 ELSIF  VV_PO_LINE_LOC_ID IS NOT NULL AND v_project IS NULL  THEN 
       	 	 	-- existing shipment record for line loc and proj validation
 						-- new change by ss9085 09/22/08
 							select nvl(closed_code, 'OPEN') closed_flag, NVL(cancel_flag, 'N') cancel_flag into  
 							v_po_line_closed, v_po_line_cancel from po_lines_all
 							where po_line_id = vv_po_line_id;
 																		
 							IF v_po_line_closed in('CLOSED', 'FINALLY CLOSED') OR v_po_line_cancel = 'Y'
 							THEN  -- existing shipment record for CLOSED line status
 								 V_VALID_LOCATION := 'T';       	 	 	
       	 	 		ELSE  -- existing shipment record for OPEN line status
       	 	 	 	  BEGIN  -- get project_id   -- distirbution record may not queried yet
			     	      SELECT pda.project_id, ppa.segment1
			     	        INTO v_project_id,  v_project	
			     	        FROM pa_projects_all      ppa,
			       	           po_distributions_all pda
			       	     WHERE ppa.project_id       = pda.project_id
			       	       AND pda.po_header_id     = VV_PO_HDR_ID
			     	         AND pda.po_line_id       = VV_PO_LINE_ID
			     	         AND pda.line_location_id = VV_PO_LINE_LOC_ID 
			     	         AND ROWNUM               = 1;
			     	         
                  cw_po_poet_wf_pkg.valid_location (v_project_id,
                                                    v_location,
                                                    v_valid_location
                                                   );

                  -- Begin changes for WUP00200949
                  -- Hard Stop if there is mis match between Ship-To Location
                  -- and Project for a given PO Line
                  IF (    v_valid_location = 'F'
                      AND event_name = 'WHEN-VALIDATE-RECORD'
                      AND NAME_IN ('SYSTEM.RECORD_STATUS') = 'CHANGED'
                     )
                  THEN
                     fnd_message.set_string
                                    (   'Ship-To Location '
                                     || ''''
                                     || v_location
                                     || ''''
                                     || ' is not valid for Project '
                                     || ''''
                                     || v_project
                                     || '''. Please change the ship to location.'
                                    );
                     fnd_message.error;
                     RAISE form_trigger_failure;
                  END IF;  -- End changes for WUP00200949
			          EXCEPTION
			       	    WHEN NO_DATA_FOUND THEN
			       	      V_VALID_LOCATION := 'T';  -- no distribution row exists
			          END;
       	 	 		END IF;    -- ss9085 9/22/08
       	 	 ELSIF  VV_PO_LINE_LOC_ID IS NOT NULL AND v_project IS NOT NULL  THEN
       	 	 	 -- existing shipment record for line loc and proj validation
       	 	 	 -- new change by ss9085 09/22/08
            SELECT NVL (closed_code, 'OPEN') closed_flag,
                   NVL (cancel_flag, 'N') cancel_flag
              INTO v_po_line_closed,
                   v_po_line_cancel
              FROM po_lines_all
             WHERE po_line_id = vv_po_line_id;

            IF    v_po_line_closed IN ('CLOSED', 'FINALLY CLOSED')
               OR v_po_line_cancel = 'Y'
            THEN        -- existing shipment record for CLOSED line status
               v_valid_location := 'T';
            ELSE        -- existing shipment record for OPEN line status
               cw_po_poet_wf_pkg.valid_location (v_project_id,
                                                 v_location,
                                                 v_valid_location
                                                );

               -- Begin changes for WUP00200949
               -- Hard Stop if there is mismatch between Ship-To Location
               -- and Project for a given PO Line
               IF (    v_valid_location = 'F'
                   AND event_name = 'WHEN-VALIDATE-RECORD'
                   AND NAME_IN ('SYSTEM.RECORD_STATUS') = 'CHANGED'
                  )
               THEN
                  fnd_message.set_string
                                    (   'Ship-To Location '
                                     || ''''
                                     || v_location
                                     || ''''
                                     || ' is not valid for Project '
                                     || ''''
                                     || v_project
                                     || '''. Please change the ship to location.'
                                    );
                  fnd_message.error;
                  RAISE form_trigger_failure;
               END IF;  -- End changes for WUP00200949
            END IF;  -- ss9085 9/22/08 -- existing shipment record for  line status
         END IF;     -- end line loc and proj validation in PO_SHIPMENTS block
         -- This validation is for PO being auto-created from requisition  
         -- why is this executed twice?????? Known problem per Metalink
         --       ELSIF ( block_name IN ('PO_HEADERS', 'PO_LINES', 'PO_APPROVE' )) THEN --  AND
       ELSIF ( block_name =  'PO_LINES') THEN --  Begin validations for PO_LINES block
       	  --  AND  event_name   = 'WHEN-NEW-RECORD-INSTANCE')  THEN
           IF VV_PO_LINE_ID IS NULL THEN  -- new line, do not validate
               V_VALID_LOCATION := 'T';
           ELSE  -- existing line for loc and proj validation
           			 -- new change by ss9085 09/22/08
            SELECT NVL (closed_code, 'OPEN') closed_flag,
                   NVL (cancel_flag, 'N') cancel_flag
              INTO v_po_line_closed,
                   v_po_line_cancel
              FROM po_lines_all
             WHERE po_line_id = vv_po_line_id;

            IF    v_po_line_closed IN ('CLOSED', 'FINALLY CLOSED')
               OR v_po_line_cancel = 'Y'
            THEN            -- existing line validation for CLOSED line status
               v_valid_location := 'T';
            ELSE            -- existing line validation for OPEN line status
       	      BEGIN  -- get project_id                            
			     	      SELECT pda.project_id, ppa.segment1
			     	        INTO v_project_id,  v_project	
			     	        FROM pa_projects_all      ppa,
			       	           po_distributions_all pda
			       	     WHERE ppa.project_id       = pda.project_id
			       	       AND pda.po_header_id     = VV_PO_HDR_ID
			     	         AND pda.po_line_id       = VV_PO_LINE_ID
			     	         AND ROWNUM               = 1;

                   SELECT HRL.LOCATION_CODE
                     INTO v_location
                     from hr_locations hrl,
                          po_line_locations_all pll
                    where hrl.location_id         = pll.ship_to_location_id
--                      and pll.ship_to_location_id = v_ship_to_loc_id
                      and pll.po_header_id        =  VV_PO_HDR_ID
                      and pll.po_line_id          = VV_PO_LINE_ID
                      and rownum                  = 1;
                      
			     	      Cw_Po_Poet_Wf_Pkg.VALID_LOCATION(v_project_id,v_location,v_valid_location);
			     	      
			         EXCEPTION
			       	   WHEN NO_DATA_FOUND THEN
			       	      V_VALID_LOCATION := 'T';  -- no distribution row exists
			         END;
            END IF; --ss9085 09/22/08 -- existing line validation for line status
         END IF;         -- end line loc and proj validation in PO_LINES block
			 ELSIF ( (block_name = 'PO_HEADERS' --AND name_in('SYSTEM.RECORD_STATUS') = 'QUERY' -- sue gibson 12-dec-08
			 	    AND event_name = 'WHEN-NEW-RECORD-INSTANCE') OR
			          block_name = 'PO_APPROVE' )  THEN  --  Begin validations for PO_HEADERS block
				 -- validate project and location match
			   BEGIN
			 	    v_valid_location := 'T';
			 	    FOR p_l_match IN find_proj_loc_c
			 	    LOOP
			 	    -- new change by ss9085 09/22/08	
			 	    	select nvl(closed_code, 'OPEN') closed_flag, NVL(cancel_flag, 'N') cancel_flag into  
 							v_po_line_closed, v_po_line_cancel from po_lines_all
 							where po_line_id =  p_l_match.PO_LINE_ID;
 																		
               IF    v_po_line_closed IN ('CLOSED', 'FINALLY CLOSED')
                  OR v_po_line_cancel = 'Y'
               THEN          -- existing line validation for CLOSED line status
                  v_valid_location := 'T';
               ELSE          -- existing line validation for OPEN line status
                  cw_po_poet_wf_pkg.valid_location (p_l_match.project_id,
                                                    p_l_match.location_code,
                                                    v_valid_location
                                                   );
               END IF; --ss9085 09/22/08   -- existing line validation for line status

               IF v_valid_location = 'F' THEN
                 FND_MESSAGE.SET_STRING('Ship-To Location '||''''||p_l_match.location_code||''''||
                              ' on line ' || p_l_match.line_num || ' is not valid for Project '||'''' || p_l_match.project_code || '''');
 				         FND_MESSAGE.ERROR;
 				         v_val_rec_fired := 1;
 				         IF block_name = 'PO_APPROVE' THEN
 				         	 go_block('PO_HEADERS');
 				           raise form_trigger_failure;
 				         END IF;
 				       END IF;
            END LOOP;
 			   END;  -- end header block validation
       ELSIF block_name = 'PO_DISTRIBUTIONS' THEN -- Begin validations for PO_DISTRIBUTIONS block
         IF v_project IS NULL
         THEN
            v_valid_location := 'T';                      --  do not validate
         ELSE      -- validate ship-to-loc and project after change to project
            cw_po_poet_wf_pkg.valid_location (v_project_id,
                                              NAME_IN ('PO_DISTRIBUTIONS.DELIVER_TO_LOCATION'),  -- v_location,
                                              -- changed for WUP00200949  
                                              v_valid_location
                                             );
         END IF;
         -- Begin changes for WUP00200949
         -- Hard Stop if there is mismatch between Ship-To Location
         -- and Project for a given PO Line
         IF (    v_valid_location = 'F'
             AND event_name = 'WHEN-VALIDATE-RECORD'
             AND NAME_IN ('SYSTEM.RECORD_STATUS') = 'CHANGED'
            )
         THEN
            fnd_message.set_string
                              (   'Deliver-To Location '
                               || ''''
                               || NAME_IN ('PO_DISTRIBUTIONS.DELIVER_TO_LOCATION')
                               || ''''
                               || ' is not valid for Project '
                               || ''''
                               || v_project
                               || '''. Please change the deliver to location.'
                              );
            fnd_message.error;
            RAISE form_trigger_failure;
         END IF;  -- End changes for WUP00200949
      END IF;  -- End validations of PO blocks
-- end of blocks       
----------------       
			 IF v_valid_location = 'F' AND 
          v_val_rec_fired = 0 THEN
         -- If location and Project do not match raise error
         FND_MESSAGE.SET_STRING('Ship-To Location '||''''||v_location||''''||' is not valid for Project '||'''' || v_project || '''');
 				 FND_MESSAGE.ERROR;
				 -- Start 06-AUG-08 Sue Gibson
         IF block_name = 'PO_APPROVE' THEN
           go_block('PO_HEADERS');  
         	 raise form_trigger_failure;
         END IF;
				 -- End 06-AUG-08 Sue Gibson           
			 END IF;
			END IF; 
   END IF;                          -- end main IF for form POXPOEPO
END;   -- end project/location validation for PO Entry form POXPOEPO
------------------------
--End of Project Location validation for the shipment block on PO Order Entry form (POXPOEPO) Salman Siddiqui
---
------------------------
/* start Sue Gibson JUL-08

     IF    (form_name  = 'POXPOEPO'     AND
--         (block_name = 'PO_SHIPMENTS' OR block_name = 'PO_APPROVE') AND 
           (block_name = 'PO_SHIPMENTS' OR block_name = 'PO_APPROVE' OR BLOCK_NAME = 'PO_DISTRIBUTIONS') AND   --new
	       -- event_name = 'WHEN-NEW-BLOCK-INSTANCE'
-- start Sue Gibson 15-AUG-07	 how to only do when-new-item-instance when leaving ship_to_location_code or project?   
--	         event_name in ('WHEN-NEW-ITEM-INSTANCE', 'WHEN-VALIDATE-RECORD','WHEN-NEW-RECORD-INSTANCE', 'WHEN-NEW-BLOCK-INSTANCE') --7/24
	           event_name in ('WHEN-NEW-ITEM-INSTANCE', 'WHEN-VALIDATE-RECORD','WHEN-NEW-RECORD-INSTANCE', 'WHEN-NEW-BLOCK-INSTANCE') --7/24
	--           OR  ( event_name = 'WHEN-NEW-ITEM-INSTANCE' AND
	--                 (get_item_property(item_name,PREVIOUSITEM) = 'PO_SHIPMENTS.SHIP_TO_LOCATION_CODE' OR
	--                  get_item_property(item_name,PREVIOUSITEM) = 'PO_DISTRIBUTIONS.PROJECT') ))  doesn't work
-- end Sue Gibson 15-AUG-07 	                 
	          AND name_in ('SYSTEM.RECORD_STATUS') IS NOT NULL )       THEN    
-- sue gibson debug	            
--FND_MESSAGE.debug('event is ' || event_name || '  block is ' || block_name);


--  FND_MESSAGE.debug('form: ' || form_name||' block: ' || block_name || ' item: '|| name_in('system.cursor_item') || ' event: ' || event_name);
--if event_name = 'WHEN-NEW-ITEM-INSTANCE' THEN
--  FND_MESSAGE.debug('current item is ' || name_IN('SYSTEM.CURSOR_ITEM') || '  previous_item was ' ||  get_item_property(item_name,PREVIOUSITEM));        	         
--end if;
	     VV_PO_HDR_ID      := NAME_IN('PO_SHIPMENTS.PO_HEADER_ID');
	   	 v_location        := NAME_IN('PO_SHIPMENTS.SHIP_TO_LOCATION_CODE');
	   	 v_valid_location  := 'F';

	   	 VV_PO_LINE_ID     := NAME_IN('PO_SHIPMENTS.PO_LINE_ID');      -- Sue Gibson 15-AUG-07
	   	 VV_PO_LINE_LOC_ID := NAME_IN('PO_SHIPMENTS.LINE_LOCATION_ID');  -- ditto
	   	 
-- sue gibson debug
--	FND_MESSAGE.debug('pre-cursor v_location = ' || v_location || ' and po_header_id = ' || vv_po_hdr_id);	   
--  FND_MESSAGE.debug('location Values:  '||v_location);

	   	   --	v_location   := NAME_IN('PO_DISTRIBUTIONS.DELIVER_TO_LOCATION');

-- start Sue Gibson 15-AUG-07 
-- New PO
			 IF name_in('PO_HEADERS.PO_HEADER_ID') IS NULL THEN  
			   IF block_name = 'PO_SHIPMENTS' THEN
			     IF name_in('PO_DISTRIBUTIONS.PROJECT') IS NULL THEN
			       V_VALID_LOCATION := 'T';  --  do not validate  
			     ELSE     -- validate ship-to-loc and project after change to project
			     	 CW_PO_POET_WF_PKG.VALID_LOCATION(name_in('PO_DISTRIBUTIONS.PROJECT_ID'),v_location,v_valid_location);
				   	 V_PROJECT := name_in('PO_DISTRIBUTIONS.PROJECT');  --C1.SEGMENT1;
			     END IF;
         ELSE
--			 	 END IF;
--			   IF block_name = 'PO_DISTRIBUTIONS' THEN
			    	CW_PO_POET_WF_PKG.VALID_LOCATION(name_in('PO_DISTRIBUTIONS.PROJECT_ID'),v_location,v_valid_location);
					 	V_PROJECT := name_in('PO_DISTRIBUTIONS.PROJECT');  --C1.SEGMENT1;
			   END IF;
--		 	 ELSE  -- existing PO, change to location or project or is new record
--         IF block_name = 'PO_SHIPMENTS' THEN
--           IF name_in('PO_DISTRIBUTIONS.PROJECT') IS NULL THEN
--           	 V_VALID_LOCATION := 'T';  -- new record do not validate here
--           ELSE
           	 
 --          END IF;
       ELSE  
--  Existing PO
--	       V_VALID_LOCATION := 'T';  -- stub
         IF block_name = 'PO_SHIPMENTS' THEN
--fnd_message.debug('VV_PO_LINE_ID = ' || VV_PO_LINE_ID || ' AND VV_PO_LINE_LOC_ID = ' || VV_PO_LINE_LOC_ID 
--    ||  '  v_location = ' || v_location);     	
			       IF name_in('PO_DISTRIBUTIONS.PROJECT') IS NULL THEN  
			         BEGIN  -- get project_id
			     	      select pda.project_id, ppa.segment1
			     	        into v_project_id2,  v_project	
			     	        from pa_projects_all      ppa,
			       	           po_distributions_all pda
			       	     where ppa.project_id       = pda.project_id
			       	       and pda.po_header_id     = VV_PO_HDR_ID
			     	         and pda.po_line_id       = VV_PO_LINE_ID
			     	         and pda.line_location_id = VV_PO_LINE_LOC_ID
			     	         and rownum               = 1;
			     	      CW_PO_POET_WF_PKG.VALID_LOCATION(v_project_id2,v_location,v_valid_location);
			     	      
			         EXCEPTION
			       	   WHEN NO_DATA_FOUND THEN
			       	      V_VALID_LOCATION := 'T';  -- no distribution row exists
			       	 END;
			     	         
-- Sue Gibson debug
--FND_MESSAGE.DEBUG('after select v_project_id2 = ' || v_project_id2  || '  and 	v_project = ' || v_project);	     	         
--FND_MESSAGE.DEBUG('v_valid_location = ' || v_valid_location);			     	      

			     	   IF v_valid_location = 'F' THEN
FND_MESSAGE.DEBUG('ready to fail location');
			     	      FND_MESSAGE.SET_STRING('Project '||''''||v_project||''''||' is not valid for Ship To Location '||''''
 				 	             ||v_location ||  ''''||''''||'   You must change the location first.');
--			     	      FND_MESSAGE.SET_STRING('Ship-To Location '||''''||v_location||''''||' is not valid for Project '||''''
--	30-may		 	             ||v_project ||  ''''||''''||'   You must change the project first.');
 				 	             v_valid_location := 'T';
		              FND_MESSAGE.SHOW;
--		              FND_MESSAGE.ERROR;
--          		    RAISE form_trigger_failure;
			     	   END IF;
			       ELSE
			     	   CW_PO_POET_WF_PKG.VALID_LOCATION(name_in('PO_DISTRIBUTIONS.PROJECT_ID'),v_location,v_valid_location);
               V_PROJECT := name_in('PO_DISTRIBUTIONS.PROJECT'); 
			       END IF;
         ELSE   --  for distributions block etc
		     	 IF name_in('SYSTEM.RECORD_STATUS') = 'NEW' or name_in('PO_DISTRIBUTIONS.PROJECT') IS NULL THEN
		     	 	v_valid_location := 'T'; 
		     	 ELSE
		     	 	 CW_PO_POET_WF_PKG.VALID_LOCATION(name_in('PO_DISTRIBUTIONS.PROJECT_ID'),v_location,v_valid_location);
         	   V_PROJECT := name_in('PO_DISTRIBUTIONS.PROJECT');
         	 END IF;
			   END IF;  	   
       END IF;
 
 /*     	 for c1 in (SELECT DISTINCT PROJECT_ID, SEGMENT1
       	   	 		  		FROM pa_projects_all 
      	   	 				 WHERE project_id in 
                        ( select distinct  pda.project_id 
                            from po_distributions_all pda, 
                                 po_line_locations_all pol
                               , po_headers_all poh
                           where poh.po_header_id = pol.po_header_id
													   and pol.line_location_id = pda.line_location_id
                             and pol.po_line_id = pda.po_line_id
                             and pol.ship_to_location_id in 
                                 (select ship_to_location_id I
                                    from hr_locations
                                   where location_code = v_location)
                             and pda.po_header_id = poh.po_header_id 
                             and poh.po_header_id = VV_PO_HDR_ID))		
				 LOOP
						CW_PO_POET_WF_PKG.VALID_LOCATION(c1.project_id,v_location,v_valid_location);
						V_PROJECT := C1.SEGMENT1;
-- sue gibson debug
--	   FND_MESSAGE.debug('post-cursor v_valid_location = ' || v_valid_location|| ' and v_project = ' || v_project);  
						
  					IF V_VALID_LOCATION = 'T' THEN
				  	  EXIT ;
-- start SG 14-AUG-07				  	  
  					END IF;   
				 END LOOP;   
			 END IF;   -- is PO header id null	 

       				 
--	   FND_MESSAGE.debug('END LOOP with V_VALID_LOCATION = ' || V_VALID_LOCATION || '  post-loop v_project = ' || v_project);
--  					ELSIF v_valid_location = 'F' AND v_project IS NOT NULL THEN 

/*****************************************************************
         IF 
AND name_in('PO_DISTRIBUTIONS.PROJECT') is not null

******************************************************************

			 IF v_valid_location = 'F' and name_in('PO_SHIPMENTS.SHIP_TO_LOCATION_CODE') IS NOT NULL THEN  --AND v_project IS NOT NULL THEN  	-- no_data_found   
-- end  SG 14-AUG-07 
 			   FND_MESSAGE.SET_STRING('Ship-To Location '||''''||v_location||''''||' is not valid for Project '||''''
 				 	    ||nvl(v_project,name_in('PO_DISTRIBUTIONS.PROJECT')) ||  ''''||''''||'   DO NOT PROCEED WITHOUT Correcting the Location.');
		     FND_MESSAGE.ERROR;
		       --FND_MESSAGE.SHOW;
	     	 copy(NULL, 'PO_SHIPMENTS.SHIP_TO_LOCATION_CODE');  
		     RAISE form_trigger_failure;
--            	EXIT;  SG 14-AUg-07 (moved up)
       END IF;
--		     END LOOP;   SG 14-AUg-07 (moved up)
     END IF;
END;             
------------------------
--End of Project Location validation for the shipment block on PO Order Entry form (POXPOEPO) Salman Siddiqui
------------------------
End of code commented out by Sue Gibson JUL-08*/


--copied from old file as of 3/29
------------------------
--       START of EPL 2.5 Project- Quote from po_requisition_headers_all attribute12 to 
--                                 po_headers_all attribute12 on the POXPOEPO form) Resley Cole  12/05
-------------------------
/*
DECLARE	
sys_work	         VARCHAR2(30)  := name_in('system.suppress_working');
v_sys_msglvl       NUMBER;        
form_name          VARCHAR2(30)  := name_in('system.current_form');
block_name         VARCHAR2(30)  := name_in('system.cursor_block');
item_name	         VARCHAR2(90)  := name_in('system.cursor_item');
v_po_header_id     NUMBER;                
v_req_quote        VARCHAR2(30)  :=NULL;
v_po_quote         VARCHAR2(30)  :=NULL;

CURSOR  copy_quote IS  select pha.attribute12
        from   po_requisition_headers_all pha
        where  pha.rowid =
            (
             select min(pha_sub.rowid)
             from   po_requisition_headers_all pha_sub,
                    po_requisition_lines_all pla,
                    po_req_distributions_all pda,
                    po_distributions_all poda
             where  pha_sub.requisition_header_id = pla.requisition_header_id
             and    pla.requisition_line_id       = pda.requisition_line_id
             and    pda.distribution_id           = poda.req_distribution_id
             and    poda.po_header_id             = v_po_header_id
            ); 
                       
BEGIN  
	
	IF        (form_name  = 'POXPOEPO'    AND
    	       block_name = 'PO_HEADERS'  AND 
    	       name_in('PO_HEADERS.ATTRIBUTE12')IS NULL) THEN
    	       v_po_header_id := NAME_IN('PO_HEADERS.PO_HEADER_ID');  
    	          
       	
	open  copy_quote;
	
   	fetch copy_quote into v_po_quote;
	
--	close copy_quote;

	copy(v_po_quote,'PO_HEADERS.ATTRIBUTE12'); 	 

close copy_quote;
	END IF;	
END;
*/

/*
BEGIN
	IF     (form_name  = 'POXPOEPO'          AND
    	      block_name = 'PO_HEADERS'        AND     	      
    	      name_in('PO_HEADERS.STATUS') != 'APPROVED'  AND
    	      event_name = 'WHEN-CREATE-RECORD') THEN
   	         	          	        	      
    	      set_block_property('PO_HEADERS',UPDATE_ALLOWED,PROPERTY_TRUE);
    	      set_block_property('PO_HEADERS',UPDATE_CHANGED_COLUMNS,PROPERTY_TRUE);
    	      
    	      v_po_header_id := name_in('PO_HEADERS.PO_HEADER_ID');                      
     
            select pha.attribute12
            into   v_po_quote
            from   po_requisition_headers_all pha
            where  pha.rowid =
            (
             select min(pha_sub.rowid)
             from   po_requisition_headers_all pha_sub,
                    po_requisition_lines_all pla,
                    po_req_distributions_all pda,
                    po_distributions_all poda
             where  pha_sub.requisition_header_id = pla.requisition_header_id
             and    pla.requisition_line_id       = pda.requisition_line_id
             and    pda.distribution_id           = poda.req_distribution_id
             and    poda.po_header_id             = v_po_header_id
            );   
          IF    v_po_quote IS NOT NULL THEN       
                copy(v_po_quote,'PO_HEADERS.ATTRIBUTE12');        
                                     
                   
      END IF;    
	     END IF; 
END;	     
*/
------------------------
--       END of EPL 2.5 Project- Quote from po_requisition_headers_all attribute12 to 
--                               po_headers_all attribute12 on the POXPOEPO form) Resley Cole  12/05
-------------------------    

-------------------------
--      START of UPDATE PO NOTE-TO-VENDOR WHEN UPDATING ATTRIBUTE-12 (CURRENT QUOTATION NUMBER)
--			Maury Marcus, new revision on 24-May-06  
--      2.5 Project- Quote from po_requisition_headers_all attribute12 to 
--                   po_headers_all attribute12 on the POXPOEPO form) Resley Cole  12/05
--                   moved to this section by Maury Marcus, 05-Jul-2006
-------------------------
DECLARE

v_note_to_vendor varchar2(240) ;
v_orig_note      varchar2(240) ;
v_record_status  varchar2(100) ;
v_attribute12    varchar2(150) ;
v_po_header_id   integer ;
v_attribute12_db varchar2(150) ;
v_old_quote      varchar2(200) ;
i                integer ;
j                integer ;

BEGIN

if (form_name = 'POXPOEPO') then
  if (block_name = 'PO_HEADERS') then
  	v_note_to_vendor := name_in('PO_HEADERS.NOTE_TO_VENDOR') ;
    v_orig_note :=      v_note_to_vendor ;
    v_attribute12 :=    name_in('PO_HEADERS.ATTRIBUTE12') ;
    v_po_header_id :=   name_in('PO_HEADERS.PO_HEADER_ID') ;

    if v_attribute12 is null then
      begin
        select rh.attribute12
        into   v_attribute12
        from   po_requisition_headers_all rh
        where  rh.rowid =
        (
        select min(rh_sub.rowid)
        from   po_requisition_headers_all rh_sub,
               po_requisition_lines_all   rl,
               po_req_distributions_all   rd,
               po_distributions_all       d
        where  rh_sub.requisition_header_id = rl.requisition_header_id
        and    rl.requisition_line_id       = rd.requisition_line_id
        and    rd.distribution_id           = d.req_distribution_id
        and    d.po_header_id               = v_po_header_id
        and    rh_sub.attribute12 is          not null
        ) ;
      exception
        when others then
          v_attribute12 := null;
      end ;
      if v_attribute12 is not null then
        copy(v_attribute12,'PO_HEADERS.ATTRIBUTE12') ;
      end if ;
    end if ;

    if (event_name in ('WHEN-VALIDATE-RECORD','WHEN-NEW-RECORD-INSTANCE')) then
      v_record_status := name_in('SYSTEM.RECORD_STATUS') ;
      if v_record_status in ('INSERT','CHANGED') then
        if v_note_to_vendor is not null
        and (v_note_to_vendor like '%[%'
          or v_note_to_vendor like '%]%') then
          i := nvl(instr(v_note_to_vendor,'['),1) ;
          j := nvl(instr(v_note_to_vendor,']'),length(v_note_to_vendor)) ;
          v_old_quote := substr(v_note_to_vendor,i,j+1-i) ;
        else
        	v_old_quote := null ;
        end if ;
        
        if v_old_quote is not null and v_attribute12 is not null then
          v_note_to_vendor := substr(replace(v_note_to_vendor,v_old_quote,'[Quote '||v_attribute12||']'),1,240) ;
        elsif v_old_quote is not null and v_attribute12 is null then
        	v_note_to_vendor := substr(replace(v_note_to_vendor,v_old_quote,''),1,240) ;
        elsif v_old_quote is null and v_attribute12 is not null then
          v_note_to_vendor := substr(ltrim(v_note_to_vendor||' [Quote '||v_attribute12||']'),1,240) ;
        elsif v_old_quote is null and v_attribute12 is null then
        	v_attribute12_db := null ;
        	begin
        	  select attribute12
          	into   v_attribute12_db
          	from   po_headers
          	where  po_header_id = v_po_header_id ;
          exception
          	when others then
          	  v_attribute12_db := null ;
          end ;
          if v_attribute12_db is not null then
         	  v_note_to_vendor := substr(ltrim(v_note_to_vendor||' [no current quote]'),1,240) ;
        	else
        		null ;
        	end if ;
        end if ;
        if nvl(v_note_to_vendor,'x') != nvl(v_orig_note,'x') then
          copy(v_note_to_vendor,'PO_HEADERS.NOTE_TO_VENDOR') ;
        end if ;
      end if ;
    end if ;
  end if ;
end if ;

END ;


-------------------------
-- Start Bills of Materials Form validations
-- Chris Geray
-- August 22, 2006
-------------------------

DECLARE
  v_org_id          mtl_parameters.organization_id%TYPE;
  v_org_code        mtl_parameters.organization_code%TYPE;
  v_item            VARCHAR2(2000);
  v_item_status     mtl_system_items_b.inventory_item_status_code%TYPE;
  v_ext_sys_cd      mtl_system_items_b.attribute8%TYPE;
  v_sub_item        VARCHAR2(2000);
  v_sub_item_status mtl_system_items_b.inventory_item_status_code%TYPE;
  v_sub_ext_sys_cd  mtl_system_items_b.attribute8%TYPE;

BEGIN
  IF (event_name = 'WHEN-VALIDATE-RECORD') THEN
    IF (form_name = 'BOMFDBOM') AND (block_name = 'B_INV_COMPS') THEN
      v_org_id := NAME_IN('B_BILL_OF_MATLS.ORGANIZATION_ID');

      BEGIN
        SELECT organization_code
        INTO v_org_code
        FROM mtl_parameters
        WHERE organization_id = v_org_id;
      EXCEPTION
        WHEN OTHERS THEN
          FND_MESSAGE.SET_STRING('Problem getting organization code');
          FND_MESSAGE.SHOW;
          RAISE form_trigger_failure;
      END;

      IF (v_org_code = 'NTW') THEN
        v_item := NAME_IN('B_BILL_OF_MATLS.ITEM_MIR');

        BEGIN
          SELECT mi.inventory_item_status_code, mi.attribute8
          INTO v_item_status, v_ext_sys_cd
          FROM mtl_system_items_b mi,
               mtl_parameters mp
          WHERE mi.segment1||'.'||mi.segment3 = v_item
            AND mi.organization_id = mp.organization_id
            AND mp.organization_code = 'NTW';

        EXCEPTION
          WHEN OTHERS THEN
            FND_MESSAGE.SET_STRING('Problem validating Item '||v_item);
            FND_MESSAGE.SHOW;
            RAISE form_trigger_failure;
        END;

        v_sub_item := NAME_IN('B_INV_COMPS.COMPONENT_ITEM');

        BEGIN
          SELECT mi.inventory_item_status_code, mi.attribute8
          INTO v_sub_item_status, v_sub_ext_sys_cd
          FROM mtl_system_items_b mi,
               mtl_parameters mp
          WHERE mi.segment1||'.'||mi.segment3 = v_sub_item
            AND mi.organization_id = mp.organization_id
            AND mp.organization_code = 'NTW';

        EXCEPTION
          WHEN OTHERS THEN
            FND_MESSAGE.SET_STRING('Problem validating Component '||v_sub_item);
            FND_MESSAGE.SHOW;
            RAISE form_trigger_failure;
        END;            

        IF (v_item_status = 'Inactive') THEN
          IF (v_sub_item_status NOT IN ('Inactive','Active','Active NTW','Active RCL','Phase NTW','Phase RCL')) THEN
            FND_MESSAGE.SET_STRING('Component Item Status: '||v_sub_item_status||
                                   ' is not compatible with Parent Item Status: '||v_item_status);
            FND_MESSAGE.SHOW;
            RAISE form_trigger_failure;
          END IF;
        ELSIF (v_item_status IN ('Active','Active NTW','Active RCL')) THEN
          IF (v_sub_item_status NOT IN ('Active','Active NTW','Active RCL')) THEN
            FND_MESSAGE.SET_STRING('Component Item Status: '||v_sub_item_status||
                                   ' is not compatible with Parent Item Status: '||v_item_status);
            FND_MESSAGE.SHOW;
            RAISE form_trigger_failure;
          END IF;
        ELSIF (v_item_status IN ('Phase NTW','Phase RCL')) THEN
          IF (v_sub_item_status NOT IN ('Active','Active NTW','Active RCL','Phase NTW','Phase RCL')) THEN
            FND_MESSAGE.SET_STRING('Component Item Status: '||v_sub_item_status||
                                   ' is not compatible with Parent Item Status: '||v_item_status);
            FND_MESSAGE.SHOW;
            RAISE form_trigger_failure;
          END IF;
        END IF;

        IF (v_ext_sys_cd IN ('B','E','G')) AND (v_sub_ext_sys_cd NOT IN ('B','E','G')) THEN
          FND_MESSAGE.SET_STRING('Since the Parent Item External System Download Code is '||v_ext_sys_cd||
                                 ', all Component Item External System Download Codes must be B,E,or G');
          FND_MESSAGE.SHOW;
          RAISE form_trigger_failure;
        END IF;
      END IF;
    END IF;
  END IF;
END;
-------------------------
-- END Bills of Materials Form validations
-------------------------

-- Start Items Form validations
-- Chris Geray
-- August 24, 2006  --updated new version 11/3/06
-------------------------

DECLARE
  CURSOR c_components(p_bill NUMBER, p_org_id NUMBER) IS
    SELECT
      msi.inventory_item_status_code comp_status
    FROM
      bom_inventory_components bic,
      mtl_system_items_b msi
    WHERE bic.bill_sequence_id = p_bill
      AND TRUNC(sysdate) BETWEEN TRUNC(bic.effectivity_date) AND TRUNC(NVL(bic.disable_date,sysdate))
      AND msi.inventory_item_id = bic.component_item_id
      AND msi.organization_id = p_org_id;
	
  CURSOR c_bills(p_item_id NUMBER) IS
    SELECT
      msi.inventory_item_status_code bill_status,
      msi.attribute8 bill_flag
    FROM
      bom_inventory_components bic,
      bom_bill_of_materials bom,
      mtl_system_items_b msi
    WHERE
      bic.bill_sequence_id = bom.bill_sequence_id
      AND bom.assembly_item_id = msi.inventory_item_id
      AND bom.organization_id = msi.organization_id
      AND bic.component_item_id = p_item_id;

  v_inv_item_id    mtl_system_items.inventory_item_id%TYPE;
  v_item_cat_gr_id mtl_item_catalog_groups.item_catalog_group_id%TYPE;
  v_cat_group      mtl_item_catalog_groups.segment1%TYPE;  
  v_item_cat_desc  mtl_system_items.description%TYPE;
  v_descr1         mtl_descr_element_values_v.element_value%TYPE;
  v_mfg_part       mtl_descr_element_values_v.element_value%TYPE;
  v_oem            mtl_descr_element_values_v.element_value%TYPE;
  v_org_id         mtl_parameters.organization_id%TYPE;
  v_org_code       mtl_parameters.organization_code%TYPE;
  v_attribute8     mtl_system_items.attribute8%TYPE;
  v_item_status    mtl_system_items_b.inventory_item_status_code%TYPE;
  v_bill_seq_id    bom_bill_of_materials.bill_sequence_id%TYPE;
  v_comp_count     NUMBER := 0;
  v_form_error     BOOLEAN := FALSE;
  v_msg_string     VARCHAR2(2000) := NULL;
  v_warn           BOOLEAN := FALSE;
  v_item_check     NUMBER := 0;
  v_flag_mismatch  BOOLEAN := FALSE;

BEGIN
  IF (event_name = 'WHEN-VALIDATE-RECORD') THEN
    IF (form_name = 'INVIDITM') THEN
      --IF (block_name = 'ORG_ASSIGN') AND (NAME_IN('ORG_ASSIGN.ASSIGNED_FLAG_DSP') = 'Y') THEN
      	      	--Modified based 11i upgrade WUP00056545 Vijay
      	IF (block_name = 'ORG_ASSIGN') AND (NAME_IN('ORG_ASSIGN.ASSIGNED_FLAG') = 'Y') THEN
        v_attribute8 := NAME_IN('MTL_SYSTEM_ITEMS.ATTRIBUTE8');

        IF (NAME_IN('ORG_ASSIGN.ORGANIZATION_CODE') = 'NTW') THEN

          v_inv_item_id    := NAME_IN('MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID');
          v_item_cat_gr_id := NAME_IN('MTL_SYSTEM_ITEMS.ITEM_CATALOG_GROUP_ID');
          v_cat_group      := NAME_IN('MTL_SYSTEM_ITEMS.ITEM_CATALOG_GROUP');
          v_item_cat_desc  := NAME_IN('MTL_SYSTEM_ITEMS.ITEM_CATALOG_DESCRIPTION');
          v_item_status    := NAME_IN('MTL_SYSTEM_ITEMS.INVENTORY_ITEM_STATUS_CODE_MIR');
          v_org_id         := NAME_IN('MTL_SYSTEM_ITEMS.ORGANIZATION_ID');

          IF (v_cat_group IS NULL) OR (v_cat_group != 'Asset') THEN
            v_msg_string := 'For Network items: Catalog Group must be Asset';
            v_form_error := TRUE;
          END IF;

          BEGIN
            SELECT element_value
            INTO v_descr1
            FROM mtl_descr_element_values_v
            WHERE inventory_item_id = v_inv_item_id
            AND item_catalog_group_id = v_item_cat_gr_id 
            AND element_name = 'Description1';
          EXCEPTION
      	    WHEN OTHERS THEN
      	      v_descr1 := NULL;
          END;

          IF (v_descr1 IS NULL) THEN
            IF (v_msg_string IS NULL) THEN
              v_msg_string := 'For Network items: Description1 must be populated';
            ELSE
              v_msg_string := v_msg_string || ', Description1 must be populated';
            END IF;          	

            v_form_error := TRUE;
          END IF;

          BEGIN
            SELECT element_value
            INTO v_mfg_part
            FROM mtl_descr_element_values_v
            WHERE inventory_item_id = v_inv_item_id
            AND item_catalog_group_id = v_item_cat_gr_id 
            AND element_name = 'MFG Part';
          EXCEPTION
      	    WHEN OTHERS THEN
      	      v_mfg_part := NULL;
          END;
      
          IF (v_mfg_part IS NULL) THEN
            IF (v_msg_string IS NULL) THEN
              v_msg_string := 'For Network items: MFG Part must be populated';
            ELSE
              v_msg_string := v_msg_string || ', MFG Part must be populated';
            END IF; 
   	
            v_form_error := TRUE;
          END IF;
      
          BEGIN
            SELECT element_value
            INTO v_oem
            FROM mtl_descr_element_values_v
            WHERE inventory_item_id = v_inv_item_id
            AND item_catalog_group_id = v_item_cat_gr_id 
            AND element_name = 'OEM';
          EXCEPTION
      	    WHEN OTHERS THEN
      	      v_mfg_part := NULL;
          END;
 
          IF (v_oem IS NULL) THEN
            IF (v_msg_string IS NULL) THEN
              v_msg_string := 'For Network items: OEM must be populated';
            ELSE
              v_msg_string := v_msg_string || ', OEM must be populated';
            END IF;          	

            v_form_error := TRUE;
          END IF;

          IF (NVL(NAME_IN('MTL_SYSTEM_ITEMS.LIST_PRICE_PER_UNIT_MIR'),0) <= 0) THEN
            IF (v_msg_string IS NULL) THEN
              v_msg_string := 'For Network items: List Price must be greater than zero';
            ELSE
              v_msg_string := v_msg_string || ', List Price must be greater than zero';
             END IF;
         	  
            v_form_error := TRUE;
          END IF;          	
 
          IF (v_attribute8 NOT IN ('B','C','E','G','N','X')) OR (v_attribute8 IS NULL) THEN
            IF (v_msg_string IS NULL) THEN
              v_msg_string := 'External System Download Code must be B,C,E,G,N,or X for Network items';
            ELSE
              v_msg_string := v_msg_string || '. External System Download Code must be B,C,E,G,N,or X for Network items'; 
            END IF;

            v_form_error := TRUE;
          END IF;

          IF (v_msg_string IS NOT NULL) THEN
            v_msg_string := v_msg_string || '. Please uncheck the Assigned checkbox for the NTW org and fix any errors, as necessary.';
            FND_MESSAGE.SET_STRING(v_msg_string);
            FND_MESSAGE.SHOW;     
          END IF;

          IF (v_form_error) THEN
            RAISE form_trigger_failure;
          END IF;
        ELSIF (NAME_IN('ORG_ASSIGN.ORGANIZATION_CODE') != 'MST') THEN
          IF (v_attribute8 NOT IN ('R','W','X','F','O','M')) OR (v_attribute8 IS NULL) THEN                --js add for DF  -- (M) added on 11/6/09 by ss9085
           -- v_msg_string := 'External System Download Code must be R,W, or X for Retail items';
           v_msg_string := 'External System Download Code must be R,W,X,F,O or M for Retail items';
            v_msg_string := v_msg_string || '. Please uncheck the Assigned checkbox and fix any errors, as necessary.';
            FND_MESSAGE.SET_STRING(v_msg_string);
            FND_MESSAGE.SHOW;  
            RAISE form_trigger_failure;
          END IF;
        END IF;  -- org_code
      ELSIF (block_name = 'MTL_SYSTEM_ITEMS') THEN
        v_org_id      := NAME_IN('MTL_SYSTEM_ITEMS.ORGANIZATION_ID');
        v_item_status := NAME_IN('MTL_SYSTEM_ITEMS.INVENTORY_ITEM_STATUS_CODE_MIR');
        v_inv_item_id := NAME_IN('MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID');
        v_attribute8  := NAME_IN('MTL_SYSTEM_ITEMS.ATTRIBUTE8');

        BEGIN
          SELECT organization_code
          INTO v_org_code
          FROM mtl_parameters
          WHERE organization_id = v_org_id;
        EXCEPTION
          WHEN OTHERS THEN
            v_msg_string := 'Problem getting organization code';
            v_form_error := TRUE;
        END;

        IF (v_org_code = 'NTW') THEN
          IF (v_attribute8 NOT IN ('B','C','E','G','N','X')) OR (v_attribute8 IS NULL) THEN
            IF (v_msg_string IS NULL) THEN
              v_msg_string := 'External System Download code must be B,C,E,G,N,or X for Network items';
            ELSE
              v_msg_string := v_msg_string || '. External System Download code must be B,C,E,G,N,or X for Network items'; 
            END IF;
          	
            v_form_error := TRUE;
          END IF;
          
          IF (NVL(NAME_IN('MTL_SYSTEM_ITEMS.LIST_PRICE_PER_UNIT_MIR'),0) <= 0) THEN
            IF (v_msg_string IS NULL) THEN
              v_msg_string := 'Please enter a List Price value greater than zero';
            ELSE
              v_msg_string := v_msg_string || '. Please enter a List Price value greater than zero';
            END IF;

            v_form_error := TRUE;
          END IF;

          -- check for BOM bills
          BEGIN          	    
            SELECT bill_sequence_id
            INTO v_bill_seq_id
            FROM bom_bill_of_materials_v
            WHERE assembly_item_id = v_inv_item_id
            AND organization_id = v_org_id;
          EXCEPTION
            WHEN OTHERS THEN
              v_bill_seq_id := NULL;
          END;

          IF (v_bill_seq_id IS NOT NULL) THEN
            FOR comp IN c_components(v_bill_seq_id, v_org_id) LOOP
              IF (v_item_status = 'Inactive') THEN
                IF (comp.comp_status NOT IN ('Inactive','Active','Active NTW','Active RCL','Phase NTW','Phase RCL')) THEN
                  v_warn := TRUE;
                END IF;
              ELSIF (v_item_status IN ('Active','Active NTW','Active RCL')) THEN
                IF (comp.comp_status NOT IN ('Active','Active NTW','Active RCL')) THEN
                  v_warn := TRUE;
                END IF;
              ELSIF (v_item_status IN ('Phase NTW','Phase RCL')) THEN
                IF (comp.comp_status NOT IN ('Active','Active NTW','Active RCL','Phase NTW','Phase RCL')) THEN
                  v_warn := TRUE;
                END IF;
              END IF;
            END LOOP;
          END IF;

          IF (v_warn) THEN
            IF (v_msg_string IS NULL) THEN
              v_msg_string := 'Warning: This is a BOM Assembly item and now has a status mismatch with a Component item';
      	    ELSE
              v_msg_string := v_msg_string ||'. Warning: This is a BOM Assembly item and now has a status mismatch with a Component item';
      	    END IF;
          END IF;

          v_warn := FALSE;
     
          -- check for BOM components
          BEGIN
            SELECT COUNT(*)
            INTO v_comp_count
            FROM bom_inventory_components
            WHERE component_item_id = v_inv_item_id
            AND TRUNC(sysdate) BETWEEN TRUNC(effectivity_date) AND TRUNC(NVL(disable_date,sysdate));
          EXCEPTION
            WHEN OTHERS THEN
              v_comp_count := 0;
          END;

          IF (v_comp_count > 0) THEN
            FOR bill IN c_bills(v_inv_item_id) LOOP
              IF (bill.bill_status = 'Inactive') THEN
                IF (v_item_status NOT IN ('Inactive','Active','Active NTW','Active RCL','Phase NTW','Phase RCL')) THEN
                  v_warn := TRUE;
                END IF;
              ELSIF (bill.bill_status IN ('Active','Active NTW','Active RCL')) THEN
                IF (v_item_status NOT IN ('Active','Active NTW','Active RCL')) THEN
                  v_warn := TRUE;
                END IF;
              ELSIF (bill.bill_status IN ('Phase NTW','Phase RCL')) THEN
                IF (v_item_status NOT IN ('Active','Active NTW','Active RCL','Phase NTW','Phase RCL')) THEN
                  v_warn := TRUE;
                END IF;
              END IF;
              
              IF ((v_attribute8 NOT IN ('B','E','G')) AND (bill.bill_flag IN ('B','E','G'))) THEN
              	v_flag_mismatch := TRUE;
              END IF;
            END LOOP;
          END IF;

          IF (v_warn) THEN
            IF (v_msg_string IS NULL) THEN
              v_msg_string := 'Warning: This is a BOM Component item and now has a status mismatch with its Assembly item';
      	    ELSE
              v_msg_string := v_msg_string ||'. Warning: This is a BOM Component item and now has a status mismatch with its Assembly item';
      	    END IF;
          END IF;

	        IF (v_flag_mismatch) THEN        	
            IF (v_msg_string IS NULL) THEN
              v_msg_string := 'Warning: BOM Exists for this Item, please verify External System Download Code';
            ELSE
              v_msg_string := v_msg_string || '. Warning: BOM Exists for this Item, please verify External System Download Code';
            END IF;
          END IF;
        ELSIF (v_org_code = 'MST') THEN
          IF (NAME_IN('SYSTEM.RECORD_STATUS') = 'CHANGED') THEN
            v_inv_item_id := NAME_IN('MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID');	

            BEGIN	
              SELECT COUNT(*)
              INTO v_item_check
              FROM
                mtl_system_items_b msi,
                mtl_parameters mp
              WHERE
                msi.inventory_item_id = v_inv_item_id
                AND msi.organization_id = mp.organization_id
                AND mp.organization_code = 'NTW';
            EXCEPTION
            	WHEN OTHERS THEN
          	    v_item_check := 0;
            END;

            IF (v_item_check > 0) THEN
              v_cat_group      := NAME_IN('MTL_SYSTEM_ITEMS.ITEM_CATALOG_GROUP');

              IF (v_cat_group IS NULL) OR (v_cat_group != 'Asset') THEN
                v_msg_string := 'This item is assigned to the Network org: Catalog Group must be Asset';
                v_form_error := TRUE;
              END IF;
            END IF;  -- v_item_check
          END IF;  -- record_status check
        ELSE  -- org other than NTW or MST
        	
        	
          --/* NHI Salman */ Change added 'U' as below*/  IF (v_attribute8 NOT IN ('R','W','X','F','O')) OR (v_attribute8 IS NULL) THEN                      --js add for DF
        	IF (v_attribute8 NOT IN ('R','W','X','F','O','U','M')) OR (v_attribute8 IS NULL) THEN                      --js add for DF -- (M) added on 11/6/09 by ss9085
                            --js add for DF
            -- v_msg_string := 'External System Download code must be R,W,U or X for Retail items';  
            v_msg_string := 'External System Download code must be R,W,F,O,U,M,X for Retail items';        	
            v_form_error := TRUE;
          END IF;
        END IF;  -- org_code

        IF (v_msg_string IS NOT NULL) THEN
          v_msg_string := v_msg_string || '. Please fix any errors, as necessary, and resubmit.';
          IF (NAME_IN('SYSTEM.RECORD_STATUS') IN ('CHANGED','NEW')) THEN -- Added by Mayuri to resolve repeated display of message on 10-31-2006
              FND_MESSAGE.SET_STRING(v_msg_string);
              FND_MESSAGE.SHOW;     
          END IF;-- Added by Mayuri
        END IF;

        IF (v_form_error) THEN
          RAISE form_trigger_failure;
        END IF;
      ELSIF (block_name = 'MTL_DESCR_ELEMENT_VALUES') THEN
        v_org_id := NAME_IN('MTL_SYSTEM_ITEMS.ORGANIZATION_ID');

        BEGIN
          SELECT organization_code
          INTO v_org_code
          FROM mtl_parameters
          WHERE organization_id = v_org_id;
        EXCEPTION
          WHEN OTHERS THEN
            v_msg_string := 'Problem getting organization code';
            v_form_error := TRUE;
        END;

        IF (v_org_code = 'MST') THEN
          v_inv_item_id := NAME_IN('MTL_SYSTEM_ITEMS.INVENTORY_ITEM_ID');	

          BEGIN	
            SELECT COUNT(*)
            INTO v_item_check
            FROM
              mtl_system_items_b msi,
              mtl_parameters mp
            WHERE
              msi.inventory_item_id = v_inv_item_id
              AND msi.organization_id = mp.organization_id
              AND mp.organization_code = 'NTW';
          EXCEPTION
            WHEN OTHERS THEN
              v_item_check := 0;
          END;

          IF (v_item_check > 0) THEN
            v_item_cat_gr_id := NAME_IN('MTL_SYSTEM_ITEMS.ITEM_CATALOG_GROUP_ID');
            v_cat_group      := NAME_IN('MTL_SYSTEM_ITEMS.ITEM_CATALOG_GROUP');
            v_item_cat_desc  := NAME_IN('MTL_SYSTEM_ITEMS.ITEM_CATALOG_DESCRIPTION');

            IF (v_cat_group IS NULL) OR (v_cat_group != 'Asset') THEN
              v_msg_string := 'This item is assigned to the Network org: Catalog Group must be Asset';
              v_form_error := TRUE;
            END IF;

            IF (v_item_cat_desc IS NULL) THEN
              IF (v_msg_string IS NULL) THEN
                v_msg_string := 'This item is assigned to the Network org: Item Catalog Description must be populated';
              ELSE
            	v_msg_string := v_msg_string || ', Item Catalog Description must be populated';
              END IF;
          	
              v_form_error := TRUE;
            END IF;
          END IF;  -- v_item_check
        END IF;  -- org_code

        IF (v_msg_string IS NOT NULL) THEN
          v_msg_string := v_msg_string || '. Please fix any errors, as necessary, and resubmit.';
          FND_MESSAGE.SET_STRING(v_msg_string);
          FND_MESSAGE.SHOW;     
        END IF;

        IF (v_form_error) THEN
          RAISE form_trigger_failure;
        END IF;
      END IF;  -- block_name
    END IF;  -- form_name
  END IF;  -- event_name
END;
-------------------------
-- END Item Form validations
-------------------------
--End Code from Chris Geray



--Begin Code by Vijay Swaminathan 10/06/06
/*********************************************************************************

PROJECT   : NETWORK ERROR HANDLING 
ITEMS    : PO VALIDATION FOR CATS ITEMS
DESCRIPTION : VALIDATING THE PO/LINE/SHIPMNET CANCELATAION 
AUTHOR    : VIJAYARAJ SWAMINATHAN
DATE        : 06-OCT-2006    
*********************************************************************************/
DECLARE
v_po_cancel_profile VARCHAR2(100)   := FND_PROFILE.VALUE('PO_RESTRICT_PO_CANCEL_FOR_NETWORKS_ITEM_HAVING_RECEIPTS');
v_po_tolerane_profile VARCHAR2(100) := FND_PROFILE.VALUE('PO_RESTRICT_MODIFICATIONS_TO_NETWORK_ITEMS_RECEIPTS_TOLERANCES');

         
v_ponum      				VARCHAR2(90);
v_po_line_num   			varchar2(30);
v_item_id     				number;
v_item_num    				varchar2(30);
v_item_num1   			  	varchar2(30);
v_shipment_num  			varchar2(30);

v_shipment_num1  			varchar2(30);
 
v_po_hdr_id   				number;
v_po_line_id  				number;
v_line_qty   				varchar2(30);
v_rq_line_qty   			varchar2(30);

v_cancel_status 			varchar2(30);
v_return_status 			varchar2(50);
v_action_status 			varchar2(50);
v_ntw_count				    number;
v_ntw_count1				  number;
v_ship_ntw_count      number;
v_po_ntw_item_num			varchar2(50);
v_po_ntw_item_num1		varchar2(50);

v_inv_item_id				number;

v_poline_inv_item_id				number;
v_poship_inv_item_id			  number;
v_reqline_inv_item_id				number;
 
v_profile_porestrict  			varchar2(30);
v_profile_potolerance 			varchar2(30);

v_qty_rcv_tolerance		number;
v_qty_rcv_ex_code 		varchar2(50);
 
b_qty_rcv_tolerance		number;
b_qty_rcv_ex_code 		varchar2(50);
 
 
BEGIN
	
--Validation in PO summary form in PO Header Screen
  IF (form_name ='POXPOVPO' AND block_name = 'PO_DOCON_CONTROL'AND
      event_name = 'WHEN-VALIDATE-RECORD'  AND  name_in('PO_DOCON_CONTROL.ACTION')='CANCEL PO') THEN
                 v_ponum := name_in('HEADERS_FOLDER.PO_NUM');




		if upper(v_po_cancel_profile)='YES' THEN               
                 
                 --Verifying the PO receipts based on po number
                 v_return_status :=ccwpo_receipt_check(v_ponum,'','');
                 
                 if v_return_status = 'CANCELNOTALLOWED' then
                  copy('','PO_DOCON_CONTROL.ACTION');
                 FND_MESSAGE.SET_STRING('Cancel PO cannot be performed because of existing or pending receipts');
                 FND_MESSAGE.ERROR;
                 RAISE form_trigger_failure;
                 end if;
                 
		END IF;
   --Validation in PO summary form in PO Line Screen								
   ELSIF (form_name ='POXPOVPO' AND block_name = 'PO_DOCON_CONTROL'AND
          event_name = 'WHEN-VALIDATE-RECORD'  AND name_in('PO_DOCON_CONTROL.ACTION')='CANCEL PO LINE') THEN
          		   v_ponum := name_in('LINES_FOLDER.PO_NUM');
                 v_po_line_num := name_in('LINES_FOLDER.LINE_NUM');
                 v_item_id    := name_in('LINES_FOLDER.ITEM_ID');
                 v_item_num  := name_in('LINES_FOLDER.ITEM_NUMBER');
								 
								 
 		--Checking the Profile for po cancel
		if upper(v_po_cancel_profile)='YES' THEN   
								
		--Verifying the PO receipts based on po number and line num                 
  		v_return_status :=ccwpo_receipt_check(v_ponum,v_po_line_num,'');                 
                 if v_return_status = 'CANCELNOTALLOWED' then
                 copy('','PO_DOCON_CONTROL.ACTION'); 
                
                 FND_MESSAGE.SET_STRING('Cancel PO Line  cannot be performed because of existing or pending receipts');
                 FND_MESSAGE.ERROR;
                 RAISE form_trigger_failure;
                 end if;
		END IF;
  --Validation in PO summary form in PO Shipment Screen																
   ELSIF (form_name ='POXPOVPO' AND block_name = 'PO_DOCON_CONTROL' AND   event_name = 'WHEN-VALIDATE-RECORD'    
                 	AND name_in('PO_DOCON_CONTROL.ACTION')='CANCEL PO SHIPMENT') THEN
                 
                 v_ponum 	:= name_in('SHIPMENTS_FOLDER.PO_NUM');
                 v_po_line_num 	:= name_in('SHIPMENTS_FOLDER.LINE_NUM');
                 v_item_id    	:= name_in('LINES_FOLDER.ITEM_ID');
                 v_item_num  	:= name_in('LINES_FOLDER.ITEM_NUMBER');
                 v_shipment_num	:= name_in('SHIPMENTS_FOLDER.SHIPMENT_NUM');

		--Checking the Profile for po cancel
		if upper(v_po_cancel_profile)='YES' THEN                   

                 
                 if name_in('SHIPMENTS_FOLDER.SHIP_TO_ORGANIZATION_ID') =87 THEN
                 --Verifying the PO receipts based on po number and line num 
                 v_return_status :=ccwpo_receipt_check(v_ponum,v_po_line_num,'');                 
                 
                 if v_return_status = 'CANCELNOTALLOWED' then
                 copy('','PO_DOCON_CONTROL.ACTION');
                 FND_MESSAGE.SET_STRING('Cancel PO Shipment Line cannot be performed because of existing or pending receipts');
                 FND_MESSAGE.ERROR;
                 RAISE form_trigger_failure;
                 end if;
                 END IF;
                 END IF;
   END IF;

/************************PO LINE FRACTIONAL QUANTITY VALIDATION****************/
--Fractional Quantity Validation in PO Standard Form only NTW Org.
IF (form_name ='POXPOEPO' AND block_name = 'PO_LINES' AND    event_name = 'WHEN-VALIDATE-RECORD'
	and instr(name_in('PO_LINES.QUANTITY'),'.') !=0 )  THEN
                  
                v_po_ntw_item_num := substr(UPPER(name_in('PO_LINES.ITEM_NUMBER')),1,3)  ;
                v_po_hdr_id   	:= name_in('PO_LINES.PO_HEADER_ID');
         				v_po_line_id  	:= name_in('PO_LINES.PO_LINE_ID');
         				v_line_qty   	:= name_in('PO_LINES.QUANTITY');
         				v_poline_inv_item_id :=	name_in('PO_LINES.ITEM_ID');
								
								
								select COUNT(*) into v_ntw_count
								from mtl_system_items_b where organization_id=87 
								and INVENTORY_ITEM_ID=v_poline_inv_item_id
								and attribute8  in ('N','C','E','G');	 -- segment1=v_po_ntw_item_num;

                	if instr(v_line_qty,'.') !=0  and v_ntw_count !=0 then
                	FND_MESSAGE.SET_STRING('Line Quantity should be in Integer for Items belongs to CATS External System');
                	FND_MESSAGE.SHOW;
          		RAISE form_trigger_failure;
                	end if;
end if;

IF (form_name ='POXPOEPO' AND block_name = 'PO_SHIPMENTS'--) then
   AND  event_name = 'WHEN-VALIDATE-RECORD' and instr(name_in('PO_SHIPMENTS.QUANTITY'),'.') !=0 
   AND  name_in('PO_SHIPMENTS.SHIP_TO_ORGANIZATION_CODE') ='NTW' )THEN  
   
   							  v_poship_inv_item_id	:= name_in('PO_SHIPMENTS.ITEM_ID');
   							  
   							  		select COUNT(*) into v_ship_ntw_count
										  from mtl_system_items_b where organization_id=87 
										  and INVENTORY_ITEM_ID=v_poship_inv_item_id
											and attribute8  in ('N','C','E','G');
											
   							  if v_ship_ntw_count != 0 then
                	FND_MESSAGE.SET_STRING('Shipment Quantity should be in Integer for Items belongs to CATS External System');
                	FND_MESSAGE.SHOW;
          				RAISE form_trigger_failure;
          				end if;
end if;
 
--Fractional Quantity Validation in PO Requisition Form only NTW Org.
IF (form_name ='POXRQERQ' AND block_name = 'LINES' 
	AND   event_name = 'WHEN-VALIDATE-RECORD' 
	and	instr(name_in('LINES.QUANTITY'),'.') !=0 )  then 
                	            
                  --fnd_message.DEBUG('WVR-L-Line qty check.');
                  v_po_ntw_item_num1 :=substr(UPPER(name_in('LINES.ITEM_NUMBER')),1,3) ;
                  v_reqline_inv_item_id := name_in('LINES.ITEM_ID');
		Begin
		--select COUNT(DISTINCT SEGMENT1) into v_ntw_count1
		--from mtl_system_items_b where organization_id=87 and segment1=v_po_ntw_item_num1;
   							  		select COUNT(*) into v_ntw_count1
										  from mtl_system_items_b where organization_id=87 
										  and INVENTORY_ITEM_ID=v_reqline_inv_item_id
											and attribute8  in ('N','C','E','G');
		end;
									
		v_rq_line_qty   := name_in('LINES.QUANTITY');

                	if instr(v_rq_line_qty,'.') !=0 AND  v_ntw_count1 !=0 then
                	FND_MESSAGE.SET_STRING('Line Quantity should be in Integer for Items belongs to CATS External System');
                	FND_MESSAGE.SHOW;
          		RAISE form_trigger_failure;
                	end if;
end if;

/************************PO SHIPMENT TOLERANCE VALIDATION****************/

--Receiving Control Tolerance and code validation in PO Standard form in PO Shipment Screen

IF (form_name ='POXPOEPO' AND block_name = 'PO_SHIPMENTS'--) then
  -- AND (item_name ='QTY_RCV_TOLERANCE' OR item_name ='QTY_RCV_EXCEPTION_CODE' )
   AND  event_name = 'WHEN-VALIDATE-RECORD' 
   AND  name_in('PO_SHIPMENTS.SHIP_TO_ORGANIZATION_CODE') ='NTW' )THEN  
   
           v_po_hdr_id   	:= name_in('PO_SHIPMENTS.PO_HEADER_ID');
           v_po_line_id  	:= name_in('PO_SHIPMENTS.PO_LINE_ID');
           v_shipment_num1 	:= name_in('PO_SHIPMENTS.SHIPMENT_NUM');
           b_qty_rcv_tolerance	:= name_in('PO_SHIPMENTS.QTY_RCV_TOLERANCE');
	   b_qty_rcv_ex_code 	:= name_in('PO_SHIPMENTS.QTY_RCV_EXCEPTION_CODE');
	   v_inv_item_id	:= name_in('PO_SHIPMENTS.ITEM_ID');

                  
			Begin
			select COUNT(*) into v_ntw_count1
			from mtl_system_items_b 
			where organization_id=87 
			and inventory_item_id=v_inv_item_id	
			and attribute8  in ('N','C','E','G');	
			end;
														 
			  --if v_profile_potolerance='YES' THEN
			   if	upper(v_po_tolerane_profile) ='YES' and  v_ntw_count1 !=0 THEN
			  --Getting the existing trasaction based po number and shipment number
			  Begin
				select qty_rcv_tolerance,qty_rcv_exception_code  into v_qty_rcv_tolerance,v_qty_rcv_ex_code
				from po_line_locations_all
				where 
				po_header_id =v_po_hdr_id
				and po_line_id=v_po_line_id
				and shipment_num=v_shipment_num1;
				exception when others then
				null;
				end;
							  
          			if v_qty_rcv_tolerance is not null and v_qty_rcv_ex_code is not null then
          			 if (v_qty_rcv_tolerance != b_qty_rcv_tolerance) or (v_qty_rcv_ex_code !=b_qty_rcv_ex_code) then
  	              FND_MESSAGE.SET_STRING('Cannot change the receiving tolerance and code for External System Items');
                  FND_MESSAGE.SHOW;
                  RAISE form_trigger_failure;
          			 end if;
          			end if;
       END IF;
end if;

Exception
	when others then
	RAISE form_trigger_failure;
               
END;
/*********************************************************************************/	
--End code by Vijay Swaminathan	

/* Added for QC 3720 by Pratik(PM508N) on 02-SEP-2013 start */
DECLARE
   lv_po_cancel_profile VARCHAR2 (100)
         := FND_PROFILE.VALUE (
               'PO_RESTRICT_AMOUNT_BASED_PO_CANCEL_FOR_NETWORK'
            ) ;
   lv_ponum           VARCHAR2 (90);
   lv_po_line_num     VARCHAR2 (30);
   lv_shipment_num    VARCHAR2 (30);
   lv_return_status   VARCHAR2 (50);

   FUNCTION ccwpo_receipt_check_ntw (
      p_po_number     IN VARCHAR2,
      p_linenum       IN VARCHAR2 DEFAULT NULL ,
      p_shiplinenum   IN VARCHAR2 DEFAULT NULL
   )
      RETURN VARCHAR2
   IS
      lv_po_header_id          NUMBER;
      lv_po_line_id            NUMBER;
      lv_po_line_num           NUMBER;
      lv_prior_line_id         NUMBER;
      lv_line_loc_id           NUMBER;
      lv_line_loc_qty          NUMBER;
      lv_line_loc_qty_rcvd     NUMBER;
      lv_line_loc_qty_billed   NUMBER;
      lv_ntw_organization_id   NUMBER;

      CURSOR cur_po
      IS
           SELECT   h.po_header_id,
                    l.po_line_id,
                    l.line_num,
                    ll.line_location_id,
                    ll.quantity,
                    ll.quantity_received,
                    ll.quantity_billed
             FROM   po.po_headers_all h,
                    po.po_lines_all l,
                    po.po_line_locations_all ll
            WHERE   h.segment1 = p_po_number
                    AND l.line_num =
                          NVL (TO_NUMBER (TRIM (p_linenum)), l.line_num)
                    AND ll.shipment_num =
                          NVL (TO_NUMBER (TRIM (p_shiplinenum)),
                               ll.shipment_num)
                    AND l.po_header_id = h.po_header_id
                    AND ll.po_header_id = h.po_header_id
                    AND ll.po_line_id = l.po_line_id
                    AND ll.ship_to_organization_id = lv_ntw_organization_id
                    AND l.item_id IS NULL
                    AND l.line_type_id =
                          (SELECT   LINE_TYPE_ID
                             FROM   PO_LINE_TYPES_TL
                            WHERE   DESCRIPTION IN (SELECT   ffv.flex_value
        																							FROM   apps.fnd_flex_value_sets ffvs, apps.fnd_flex_values ffv
       																							 WHERE   flex_value_set_name = 'CW_NTW_PO_RESTRICT_LINETYPES_CANCEL'
               																				 AND   ffvs.flex_value_set_id = ffv.flex_value_set_id
																				               AND   NVL (enabled_flag, 'N') = 'Y'
																				               AND   (START_DATE_ACTIVE < SYSDATE OR START_DATE_ACTIVE IS NULL)
																				               AND   (END_DATE_ACTIVE >= SYSDATE OR END_DATE_ACTIVE IS NULL)) 
                            AND ROWNUM = 1)
         ORDER BY   l.po_line_id, ll.line_location_id;

      lv_check_status          VARCHAR2 (50);
      lv_interface_count       NUMBER;
      lv_stage_count           NUMBER;
      lv_hdr_id                NUMBER;
      lv_cnt_ntw               NUMBER;
   BEGIN
      lv_check_status := 'YES';
      lv_prior_line_id := -999;

      BEGIN
         SELECT   organization_id
           INTO   lv_ntw_organization_id
           FROM   inv.mtl_parameters
          WHERE   organization_code = 'NTW';
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;

      BEGIN
         SELECT   poh.po_header_id
           INTO   lv_hdr_id
           FROM   po_headers_all poh
          WHERE   poh.segment1 = p_po_number
                --  AND NVL (poh.attribute5, 'X') <> 'WIRELINE'--Changed for ESS kavya
                AND NVL (poh.attribute5, 'X') not in ('WIRELINE','WIRELINE-ESS')--Changed for ESS kavya
                  AND EXISTS
                        (SELECT   1
                           FROM   po_lines_all
                          WHERE   po_header_id = poh.po_header_id
                                  AND item_id IS NULL
                                  AND line_type_id =
                                        (SELECT   LINE_TYPE_ID
                                           FROM   PO_LINE_TYPES_TL
                                          WHERE   DESCRIPTION =
                                                     'Amount Based'
                                                  AND ROWNUM = 1));
      EXCEPTION
         WHEN OTHERS
         THEN
            lv_hdr_id := 0;
      END;

      IF NVL (lv_hdr_id, 0) <> 0
      THEN
         BEGIN
            SELECT   COUNT ( * )
              INTO   lv_cnt_ntw
              FROM   po_line_locations_all
             WHERE   po_header_id = lv_hdr_id
                     AND ship_to_organization_id =
                           (SELECT   organization_id
                              FROM   mtl_parameters
                             WHERE   ORGANIZATION_CODE = 'NTW');
         EXCEPTION
            WHEN OTHERS
            THEN
               lv_cnt_ntw := 0;
         END;

         IF lv_cnt_ntw <> 0
         THEN
            OPEN cur_po;

            LOOP
               FETCH cur_po
                  INTO
                            lv_po_header_id, lv_po_line_id, lv_po_line_num, lv_line_loc_id, lv_line_loc_qty, lv_line_loc_qty_rcvd, lv_line_loc_qty_billed;

               EXIT WHEN cur_po%NOTFOUND;

               IF NVL (lv_line_loc_qty_rcvd, 0) > 0
                  OR NVL (lv_line_loc_qty_billed, 0) > 0
               THEN
                  lv_check_status := 'NO';
               ELSIF lv_po_line_id != lv_prior_line_id
               THEN
                  BEGIN
                     SELECT   COUNT (1)
                       INTO   lv_interface_count
                       FROM   po.rcv_transactions_interface
                      WHERE   po_line_id = lv_po_line_id
                              AND po_header_id = lv_po_header_id;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        lv_interface_count := 0;
                  END;

                  IF lv_interface_count > 0
                  THEN
                     lv_check_status := 'NO';
                  ELSE
                     BEGIN
                        SELECT   COUNT (1)
                          INTO   lv_stage_count
                          FROM   ccwcats.ccw_cats_if_po_rcv c
                         WHERE   c.po_number = p_po_number
                                 AND c.po_line_number = lv_po_line_num
                                 AND EXISTS
                                       (SELECT   'cancel disallowed'
                                          FROM   applsys.fnd_flex_values v,
                                                 applsys.fnd_flex_value_sets vs
                                         WHERE   v.flex_value =
                                                    c.process_flag
                                                 AND v.enabled_flag = 'Y'
                                                 AND SYSDATE BETWEEN NVL (
                                                                        v.start_date_active,
                                                                        apps.hr_general.start_of_time
                                                                     )
                                                                 AND  NVL (
                                                                         v.end_date_active,
                                                                         apps.hr_general.end_of_time
                                                                      )
                                                 AND v.flex_value_set_id =
                                                       vs.flex_value_set_id
                                                 AND vs.flex_value_set_name =
                                                       'CUST_NONCANCELABLE_CATS_PROCESS_STATUSES');
                     EXCEPTION
                        WHEN OTHERS
                        THEN
                           lv_stage_count := 0;
                     END;

                     IF lv_stage_count > 0
                     THEN
                        lv_check_status := 'NO';
                     END IF;
                  END IF;
               END IF;

               lv_prior_line_id := lv_po_line_id;

               EXIT WHEN lv_check_status = 'NO';
            END LOOP;
         ELSE
            lv_check_status := 'YES';
         END IF;
      ELSE
         lv_check_status := 'YES';
      END IF;

      RETURN lv_check_status;
   END;
BEGIN                                            --Beginning of the main logic
   IF UPPER (lv_po_cancel_profile) = 'YES'
   THEN
      IF (    form_name = 'POXPOVPO'
          AND block_name = 'PO_DOCON_CONTROL'
          AND event_name = 'WHEN-VALIDATE-RECORD'
          AND UPPER (NAME_IN ('PO_DOCON_CONTROL.ACTION')) = 'CANCEL PO')
      THEN
         lv_ponum := NAME_IN ('HEADERS_FOLDER.PO_NUM');

         --Verifying the PO receipts based on po number
         lv_return_status := ccwpo_receipt_check_ntw (lv_ponum, '', '');

         IF lv_return_status = 'NO'
         THEN
            COPY ('', 'PO_DOCON_CONTROL.ACTION');
            FND_MESSAGE.SET_STRING('Cancel PO cannot be performed because of existing or pending receipts on PO Line.');
            FND_MESSAGE.ERROR;
            RAISE form_trigger_failure;
         END IF;
      --Validation in PO summary form in PO Line Screen
      ELSIF (form_name = 'POXPOVPO' AND block_name = 'PO_DOCON_CONTROL' AND event_name = 'WHEN-VALIDATE-RECORD' AND UPPER(NAME_IN('LINES_FOLDER.LINE_TYPE')) = 'AMOUNT BASED' AND UPPER(NAME_IN('PO_DOCON_CONTROL.ACTION')) = 'CANCEL PO LINE')
      THEN
         lv_ponum := NAME_IN ('LINES_FOLDER.PO_NUM');
         lv_po_line_num := NAME_IN ('LINES_FOLDER.LINE_NUM');

         --Verifying the PO receipts based on po number and line num
         lv_return_status :=
            ccwpo_receipt_check_ntw (lv_ponum, lv_po_line_num, '');

         IF lv_return_status = 'NO'
         THEN
            COPY ('', 'PO_DOCON_CONTROL.ACTION');

            FND_MESSAGE.SET_STRING('Cancel PO cannot be performed because of existing or pending receipts on PO Line.');
            FND_MESSAGE.ERROR;
            RAISE form_trigger_failure;
         END IF;
      --Validation in PO summary form in PO Shipment Screen
      ELSIF (form_name = 'POXPOVPO' AND block_name = 'PO_DOCON_CONTROL' AND event_name = 'WHEN-VALIDATE-RECORD' AND UPPER(NAME_IN('PO_DOCON_CONTROL.ACTION')) = 'CANCEL PO SHIPMENT')
      THEN
         lv_ponum := NAME_IN ('SHIPMENTS_FOLDER.PO_NUM');
         lv_po_line_num := NAME_IN ('SHIPMENTS_FOLDER.LINE_NUM');
         lv_shipment_num := NAME_IN ('SHIPMENTS_FOLDER.SHIPMENT_NUM');

         IF NAME_IN ('SHIPMENTS_FOLDER.SHIP_TO_ORGANIZATION_ID') = 87
         THEN
            lv_return_status := NULL;

            --Verifying the PO receipts based on po number and line num and shipment number
            lv_return_status :=
               ccwpo_receipt_check_ntw (lv_ponum,
                                        lv_po_line_num,
                                        lv_shipment_num);

            IF lv_return_status = 'NO'
            THEN
               COPY ('', 'PO_DOCON_CONTROL.ACTION');
               FND_MESSAGE.SET_STRING('Cancel PO cannot be performed because of existing or pending receipts on PO Line.');
               FND_MESSAGE.ERROR;
               RAISE form_trigger_failure;
            END IF;
         END IF;
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE form_trigger_failure;
END;
/* Added for QC 3720 by Pratik(PM508N) on 02-SEP-2013 end */



--Start code Mohan Padigela  10/13/06
DECLARE
v_resp_id number := fnd_profile.value('RESP_ID');	
v_vndr_id	number;

BEGIN	
IF (form_name = 'APXVDMVD') THEN
  IF (block_name = 'VNDR') THEN
  	IF NAME_IN('VNDR.END_DATE_ACTIVE_MIR') IS NOT NULL THEN
    IF (event_name in ('WHEN-VALIDATE-RECORD')) THEN
    	IF (NAME_IN('SYSTEM.RECORD_STATUS') = 'CHANGED') THEN
      		v_vndr_id :=    nvl(name_in('VNDR.VENDOR_ID'),0) ;
    ---  IF NAME_IN('VNDR.END_DATE_ACTIVE_MIR') IS NOT NULL THEN
          -- fnd_message.set_string('Calling Validation procedure');
          -- fnd_message.show;
         IF vnd_has_open_doc(v_vndr_id, v_resp_id) = 'Y' THEN
          fnd_message.set_string('Open Purchasing documents exist for the supplier, please contact Accounts Payable Manager');
          -- fnd_message.show;
          -- fnd_message.set_name('CCWPO', 'CWPO_DOC_OPEN_FOR_THIS_VNDR');
          -- fnd_message.set_token('VNDR_ID', v_vndr_id);
           fnd_message.error;
           --COPY (NULL, 'VNDR.END_DATE_ACTIVE_MIR');
           RAISE FORM_TRIGGER_FAILURE;
      	   END IF;
    			END IF;
   			 END IF;
   		END IF;
  	END IF;
  END IF;
  EXCEPTION
  	WHEN OTHERS THEN
  	--	fnd_message.set_string('After End Calling Validation procedure');
      --     fnd_message.show;
        RAISE FORM_TRIGGER_FAILURE;   
END;
--End Code by Mohan Padigela 10/13/06

--Start code Mayuri Agarwal  10/17/06
--Changes done for FA/PA Issue 269- Incorrect Tax Allocation in AP Invoice Workbench
BEGIN
   IF (form_name = 'APXALLOC' AND block_name = 'CHARGE_ALLOCATIONS')
   THEN
      IF (event_name IN ('WHEN-VALIDATE-RECORD', 'WHEN-NEW-ITEM-INSTANCE'))
      THEN
         IF     (NAME_IN ('CHARGE.CHARGE_TYPE_LOOKUP_CODE') = 'TAX')
            AND (NAME_IN ('CHARGE_ALLOCATIONS.ALLOCATION_FLAG') = 'Y')
            AND (NAME_IN ('CHARGE_ALLOCATIONS.LINE_TYPE_LOOKUP_CODE') <>
                                                                        'ITEM'
                )
         THEN
            fnd_message.set_string
                                ('Cannot Allocate Tax against Non-Item Lines');
            fnd_message.error;
            COPY ('N', 'CHARGE_ALLOCATIONS.ALLOCATION_FLAG');
            COPY (NULL, 'CHARGE_ALLOCATIONS.ALLOCATED_AMOUNT');
            RAISE form_trigger_failure;
         END IF;
      END IF;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      RAISE form_trigger_failure;
END;
--End Code by Mayuri Agarwal 10/17/06

--Code starts for Brijesh Ravindran 11/02/06
-- 02-Nov-2006 Error Handling Project.
-- Brijesh Code Starts here 
-- Code fix to disable 'New PO','New Release' and 'Copy Document' buttons if these functions are excluded for the user.
-- The user can open the PO Summary Form thru Error Correction Form, where EC Form resides in a diff responsibility then 
-- the POXPOVPO form.    
DECLARE
 v_resp_name  VARCHAR2(80) := apps.FND_PROFILE.VALUE('RESP_NAME'); 
 v_username   VARCHAR2(80) := apps.FND_PROFILE.VALUE('USERNAME');   
BEGIN 
IF v_resp_name = ('CW NTW Error Handling') THEN
	IF form_name   = ('POXPOVPO')  THEN
	   IF block_name in ('FIND','HEADERS_FOLDER_CONTROL','LINES_FOLDER_CONTROL',
	   	  			 	 'SHIPMENTS_FOLDER_CONTROL','DISTRIBUTIONS_FOLDER_CONTROL') THEN
			IF event_name in ('WHEN-NEW-BLOCK-INSTANCE','WHEN-NEW-RECORD-INSTANCE') THEN 
			  -- Custom procedure to check all the available menu, responsibilities and menu/function exclusions for the parameter user. 
			  -- Return value is TRUE or FALSE                  
			  IF CCW_NTW_GLOBAL_UTIL_PACKAGE.check_po_functions(v_username,v_resp_name,'PO_POXPOVPO_NEWPO') THEN
			      app_item_property2.set_property('FIND.NEW_PO',ENABLED, PROPERTY_TRUE);
			      app_item_property2.set_property('HEADERS_FOLDER_CONTROL.NEW_PO',ENABLED, PROPERTY_TRUE);
			      app_item_property2.set_property('LINES_FOLDER_CONTROL.NEW_PO',ENABLED, PROPERTY_TRUE);
			      app_item_property2.set_property('SHIPMENTS_FOLDER_CONTROL.NEW_PO',ENABLED, PROPERTY_TRUE);
			      app_item_property2.set_property('DISTRIBUTIONS_FOLDER_CONTROL.NEW_PO',ENABLED, PROPERTY_TRUE);
			  ELSE
			      app_item_property2.set_property('FIND.NEW_PO', ENABLED, PROPERTY_FALSE);
			      app_item_property2.set_property('HEADERS_FOLDER_CONTROL.NEW_PO', ENABLED, PROPERTY_FALSE);
			      app_item_property2.set_property('LINES_FOLDER_CONTROL.NEW_PO', ENABLED, PROPERTY_FALSE);
			      app_item_property2.set_property('SHIPMENTS_FOLDER_CONTROL.NEW_PO', ENABLED, PROPERTY_FALSE);
			      app_item_property2.set_property('DISTRIBUTIONS_FOLDER_CONTROL.NEW_PO', ENABLED, PROPERTY_FALSE);
			  END IF; 
			  -- Custom procedure to check all the available menu, responsibilities and menu/function exclusions for the parameter user. 
			  -- Return value is TRUE or FALSE			
			  IF CCW_NTW_GLOBAL_UTIL_PACKAGE.check_po_functions(v_username,v_resp_name,'PO_POXPOVPO_NEWREL') THEN
			      app_item_property2.set_property('FIND.NEW_REL', ENABLED, PROPERTY_TRUE);
			      app_item_property2.set_property('HEADERS_FOLDER_CONTROL.NEW_REL', ENABLED, PROPERTY_TRUE);
			      app_item_property2.set_property('LINES_FOLDER_CONTROL.NEW_REL', ENABLED, PROPERTY_TRUE);
			      app_item_property2.set_property('SHIPMENTS_FOLDER_CONTROL.NEW_REL', ENABLED, PROPERTY_TRUE);
			      app_item_property2.set_property('DISTRIBUTIONS_FOLDER_CONTROL.NEW_REL', ENABLED, PROPERTY_TRUE);
			  ELSE
			      app_item_property2.set_property('FIND.NEW_REL', ENABLED, PROPERTY_FALSE);
			      app_item_property2.set_property('HEADERS_FOLDER_CONTROL.NEW_REL', ENABLED, PROPERTY_FALSE);
			      app_item_property2.set_property('LINES_FOLDER_CONTROL.NEW_REL', ENABLED, PROPERTY_FALSE);
			      app_item_property2.set_property('SHIPMENTS_FOLDER_CONTROL.NEW_REL',ENABLED, PROPERTY_FALSE);
			      app_item_property2.set_property('DISTRIBUTIONS_FOLDER_CONTROL.NEW_REL', ENABLED, PROPERTY_FALSE);
			  END IF; 
			  -- Custom procedure to check all the available menu, responsibilities and menu/function exclusions for the parameter user. 
			  -- Return value is TRUE or FALSE
			  IF CCW_NTW_GLOBAL_UTIL_PACKAGE.check_po_functions(v_username,v_resp_name,'PO_POXCPDOC') THEN
			      Set_Menu_Item_Property('SPECIAL.SPECIAL12',VISIBLE,PROPERTY_TRUE);
			  ELSE
			      Set_Menu_Item_Property('SPECIAL.SPECIAL12',VISIBLE,PROPERTY_FALSE);	
			  END IF;
			END IF;
		END IF;
	END IF;
END IF;
END;

-- 02-Nov-2006 Error Handling Project.
-- Brijesh Code Ends here 
-- Code fix to disable 'New PO','New Release' and 'Copy Document' buttons if these functions are excluded for the user.
-- The user can open the PO Summary Form thru Error Correction Form, where EC Form resides in a diff responsibility then 
-- the POXPOVPO form.

--new code by Chris Geray 11/17/06 latest updated 11/21/06
-- Added extra code to restrict only at line level as per the CQ# WUP00068260 29-FEB-2008
---------------------------------------------------------
-- Start PO Receiving/Returns/Correction Form validations
-- Chris Geray
-- November 17, 2006
DECLARE
  v_po_receiving_profile  VARCHAR2(100) := UPPER(fnd_profile.VALUE('RESTRICT RECEIVING NETWORK ITEMS'));
  v_po_return_profile     VARCHAR2(100) := UPPER(fnd_profile.VALUE('RESTRICT RETURNING NETWORK ITEMS'));
  v_po_correction_profile VARCHAR2(100) := UPPER(fnd_profile.VALUE('RESTRICT CORRECTION NETWORK ITEMS'));
  v_catitem_id            mtl_system_items_b.inventory_item_id%TYPE := NULL;
  v_item_flag             VARCHAR2(10)  := NULL;
  v_org_id                mtl_parameters.organization_id%TYPE;

BEGIN
  IF (event_name = 'WHEN-VALIDATE-RECORD') THEN
    IF ((form_name = 'RCVRCERC') AND (block_name = 'RCV_TRANSACTION')) THEN
      IF (v_po_receiving_profile = 'YES') THEN
        v_org_id := NAME_IN('PO_STARTUP_VALUES.ORG_ID');
        v_catitem_id := NAME_IN('RCV_TRANSACTION.ITEM_ID');

        BEGIN
          SELECT msi.attribute8
          INTO v_item_flag
          FROM
            mtl_system_items_b msi,
            mtl_parameters mp
          WHERE
            msi.organization_id = mp.organization_id
            AND mp.organization_code = 'NTW'
            AND msi.organization_id = v_org_id
            AND msi.inventory_item_id = v_catitem_id;
        EXCEPTION 
          WHEN OTHERS THEN
            v_item_flag := NULL;
        END;	

        IF (v_item_flag IN ('C','E','G','N')) THEN
         IF NAME_IN('RCV_TRANSACTION.LINE_CHKBOX') = 'Y' THEN -- WUP00068260
          fnd_message.set_string('Item must be received in the external system as system download flag is: '||v_item_flag);
          fnd_message.show;
          RAISE FORM_TRIGGER_FAILURE;
         END IF; -- WUP00068260
        END IF;
      END IF;  -- profile

    ELSIF ((form_name = 'RCVTXERE') AND (block_name = 'RCV_TRANSACTION')) THEN
      IF (v_po_return_profile = 'YES') THEN
        v_org_id := NAME_IN('PO_STARTUP_VALUES.ORG_ID');
        v_catitem_id := NAME_IN('RCV_TRANSACTION.ITEM_ID');

        BEGIN
          SELECT msi.attribute8
          INTO v_item_flag
          FROM
            mtl_system_items_b msi,
            mtl_parameters mp
          WHERE
            msi.organization_id = mp.organization_id
            AND mp.organization_code = 'NTW'
            AND msi.organization_id = v_org_id
            AND msi.inventory_item_id = v_catitem_id;
        EXCEPTION 
          WHEN OTHERS THEN
            v_item_flag := NULL;
        END;	

        IF (v_item_flag IN ('C','E','G','N')) THEN
         IF NAME_IN('RCV_TRANSACTION.LINE_CHKBOX') = 'Y' THEN -- WUP00068260
          fnd_message.set_string('Item must be returned in the external system as system download flag is: '||v_item_flag);
          fnd_message.show;
          RAISE FORM_TRIGGER_FAILURE;
         END IF;  -- WUP00068260
        END IF;
      END IF;  -- profile

    ELSIF ((form_name = 'RCVTXECO') AND (block_name = 'RCV_TRANSACTION')) THEN
      IF (v_po_correction_profile = 'YES') THEN
        v_org_id := NAME_IN('PO_STARTUP_VALUES.ORG_ID');
        v_catitem_id := NAME_IN('RCV_TRANSACTION.ITEM_ID');

        BEGIN
          SELECT msi.attribute8
          INTO v_item_flag
          FROM
            mtl_system_items_b msi,
            mtl_parameters mp
          WHERE
            msi.organization_id = mp.organization_id
            AND mp.organization_code = 'NTW'
            AND msi.organization_id = v_org_id
            AND msi.inventory_item_id = v_catitem_id;
        EXCEPTION 
          WHEN OTHERS THEN
            v_item_flag := NULL;
        END;	

        IF (v_item_flag IN ('C','E','G','N')) THEN
         IF NAME_IN('RCV_TRANSACTION.LINE_CHKBOX') = 'Y' THEN  -- WUP00068260
          fnd_message.set_string('Item must be corrected in the external system as system download flag is: '||v_item_flag);
          fnd_message.show;
          RAISE FORM_TRIGGER_FAILURE;
         END IF;  -- WUP00068260
        END IF;
      END IF;  -- profile
    END IF;  -- form/block
  END IF;  -- event_name
END;

-- END PO Form validations
--------------------------
--End code by Chris Geray



-------------------------
--      END of UPDATE PO NOTE-TO-VENDOR WHEN UPDATING ATTRIBUTE-12 (CURRENT QUOTATION NUMBER)
-------------------------

-------------------------
--      START of FA/PA Issue #269 Incorrect Tax Allocation Enhancement
--      Sue Gibson, new revision on 30-MAY-2006
--      User will not be able to allocate tax accross a non-Item line,
--      such as a Freight line, alone without its associated Item line
-------------------------

DECLARE
  v_item_checked    varchar2(1) ;
  v_return_record   varchar2(10); 
  v_previous_block  varchar2(80);
  v_timer_id        timer;
  v_timer_time      number := 500;
BEGIN
  IF (form_name  = 'APXALLOC')           AND           -- A
     (block_name = 'CHARGE_ALLOCATIONS') AND
     (event_name = 'WHEN-VALIDATE-RECORD') THEN
    BEGIN 
      IF (name_in('CHARGE_ALLOCATIONS.LINE_TYPE_LOOKUP_CODE')  = 'ITEM') THEN   -- B
    	  NULL;
      ELSE  
        IF (name_in('CHARGE.CHARGE_TYPE') = 'Tax' AND            -- C
            name_in('CHARGE.TAX_CODE')    = 'Sales Tax')   THEN   
          v_timer_id := CREATE_TIMER('cwap_alloc_tax', v_timer_time, NO_REPEAT); 
        END IF;                                                  -- C
      END IF;                                                                   -- B
    END;
  END IF;                                              -- A

  IF (form_name  = 'APXALLOC')           AND           -- D
     (block_name = 'CHARGE_ALLOCATIONS') AND
     (event_name = 'WHEN-TIMER-EXPIRED')     THEN
    BEGIN
      v_return_record := name_in('system.cursor_record');  --capture starting place
      v_item_checked  := 'N';
    	FIRST_RECORD;                                        -- check for an allocated ITEM record 
    	WHILE name_in('CHARGE_ALLOCATIONS.INVOICE_ID') is not null LOOP     
    	  IF (name_in('CHARGE_ALLOCATIONS.LINE_TYPE_LOOKUP_CODE') = 'ITEM')AND
    	     (name_in('CHARGE_ALLOCATIONS.ALLOCATED_FLAG')        = 'Y')       THEN  -- E
    	    v_item_checked := 'Y';
    	  END IF;                                                                    -- E
    	  NEXT_RECORD;
    	END LOOP;
      GO_RECORD(v_return_record);
      IF (v_item_checked = 'N') THEN -- F
        FND_MESSAGE.SET_STRING('The associated item line must also be allocated.');
  	FND_MESSAGE.ERROR;
        RAISE form_trigger_failure;
      END IF;                        -- F
    END;
  END IF;                                             -- D
END;  

-------------------------
--     END of FA/PA Issue #269 Incorrect Tax Allocation enhancement
--     Sue Gibson
-------------------------
---new change by ss9085 to prevent expense items charging to capital projects --  WUP00047479:

DECLARE
	
v_expenditure_type varchar2(60);
v_item_id number;
v_project_num varchar2(40);
v_task_num	 varchar2(10);
v_org_id number;
v_po_charge varchar2(85);
v_gl_segment2 varchar2(10);
v_status varchar2(60);

BEGIN
	   /* Sriram.S - 24Oct2008 - WUP00141934
	   Added PO_LINES in the below IF condition to fire so that user is not allowed to save from Lines block w/o validating the pref setup.
	   If called from lines block of POXRQERQ, POXPOEPO forms, consider preference in the validation */
     IF (form_name = 'POXRQERQ' AND (block_name = 'DISTRIBUTIONS' OR block_name = 'LINES')    
    	                         AND  event_name = 'WHEN-VALIDATE-RECORD') OR
    	 (form_name = 'POXPOEPO' AND (block_name  = 'PO_DISTRIBUTIONS' OR block_name = 'PO_LINES') 
    	 										--		 AND event_name = 'WHEN-VALIDATE-RECORD') OR
    	 												 AND event_name = 'WHEN-VALIDATE-RECORD' and NAME_IN('PO_HEADERS.ATTRIBUTE5') != 'WIRELINE-ESS') OR--Added by kavya for ESS
    	 (form_name = 'POXPOERL' AND block_name  = 'PO_DISTRIBUTIONS' AND event_name = 'WHEN-VALIDATE-RECORD') OR
    	 (form_name = 'POXDOPRE' AND block_name  = 'PO_DEFAULTS'      AND event_name = 'WHEN-VALIDATE-RECORD') THEN
    	
       IF form_name = 'POXRQERQ' THEN
						
						--fnd_message.DEBUG('WVR-L/Distri-Save Pref Check.');
						
						IF (block_name = 'LINES') THEN
					
					             v_expenditure_type         := NVL(NAME_IN('DISTRIBUTIONS.EXPENDITURE_TYPE'), name_in('global.po_expenditure_type'));
					             v_item_id          	:= NAME_IN('LINES.ITEM_ID');
					          --   ccwpa_iet_item_number    := NAME_IN('LINES.ITEM_NUMBER');
					          --   ccwpa_iet_org_id         := NAME_IN('LINES.DEST_ORGANIZATION_ID');
					             v_project_num	        := NVL(name_in('DISTRIBUTIONS.PROJECT'), name_in('global.po_project'));
					             v_task_num			:= NVL(name_in('DISTRIBUTIONS.TASK'), name_in('global.po_task'));
					             v_po_charge		:= NVL(name_in('DISTRIBUTIONS.CHARGE_ACCOUNT_FLEX'), name_in('global.po_charge_account'));
					
						 ELSE
					
						     v_expenditure_type         := NAME_IN('DISTRIBUTIONS.EXPENDITURE_TYPE');
					             v_item_id          	:= NAME_IN('LINES.ITEM_ID');
					          --   ccwpa_iet_item_number    := NAME_IN('LINES.ITEM_NUMBER');
					          --   ccwpa_iet_org_id         := NAME_IN('LINES.DEST_ORGANIZATION_ID');
					             v_project_num	        := name_in('DISTRIBUTIONS.PROJECT');
					             v_task_num			:= name_in('DISTRIBUTIONS.TASK');
					             v_po_charge		:= name_in('DISTRIBUTIONS.CHARGE_ACCOUNT_FLEX');
						
						 END IF;
			       
       ELSIF form_name = 'POXPOEPO' THEN
       	
						IF (block_name = 'PO_LINES') THEN
					
					            v_expenditure_type		:= NVL(name_in('po_distributions.expenditure_type'), name_in('global.po_expenditure_type'));
					            v_item_id			:= name_in('po_lines.item_id');
					            -- ccwpa_iet_item_number      := name_in('po_lines.item_number');
					            -- ccwpa_iet_org_id           := NAME_IN('PO_HEADERS.SHIP_TO_ORG_ID'); --changed 07/05/06 PG
					            -- ccwpa_iet_org_id           := NAME_IN('PO_DISTRIBUTIONS.DESTINATION_ORGANIZATION_ID');
						    v_project_num		:= NVL(name_in('PO_DISTRIBUTIONS.PROJECT'), name_in('global.po_project'));
						    v_task_num			:= NVL(name_in('PO_DISTRIBUTIONS.TASK'),name_in('global.po_task'));
						    v_po_charge 		:= NVL(NAME_IN('PO_DISTRIBUTIONS.CHARGE_ACCOUNT_FLEX'), name_in('global.po_charge_account'));
						
						ELSE
					
					            v_expenditure_type		:= name_in('po_distributions.expenditure_type');
					            v_item_id			:= name_in('po_lines.item_id');
					            -- ccwpa_iet_item_number      := name_in('po_lines.item_number');
					            -- ccwpa_iet_org_id           := NAME_IN('PO_HEADERS.SHIP_TO_ORG_ID'); --changed 07/05/06 PG
					            -- ccwpa_iet_org_id           := NAME_IN('PO_DISTRIBUTIONS.DESTINATION_ORGANIZATION_ID');
						    v_project_num		:= name_in('PO_DISTRIBUTIONS.PROJECT');
						    v_task_num			:= name_in('PO_DISTRIBUTIONS.TASK');
						    v_po_charge 		:= NAME_IN('PO_DISTRIBUTIONS.CHARGE_ACCOUNT_FLEX');
						
						END IF;
			
       ELSIF form_name = 'POXPOERL' THEN
       	
             v_expenditure_type 	 := name_in('po_distributions.expenditure_type');
             v_item_id			 := name_in('po_shipments.item_id');
             -- ccwpa_iet_item_number    := name_in('po_shipments.item_num');
				     -- ccwpa_iet_org_id         := NAME_IN('PO_SHIPMENTS.SHIP_TO_ORGANIZATION_ID');
				     v_project_num		 := name_in('PO_DISTRIBUTIONS.PROJECT');
				     v_task_num	  		 := name_in('PO_DISTRIBUTIONS.task');
				     v_po_charge 			 := NAME_IN('PO_DISTRIBUTIONS.CHARGE_ACCOUNT_FLEX');
						 
		
       END IF;
 
--if (v_item_id is not null and v_project_num is not null and v_po_charge is not null) then
if (v_item_id is not null) THEN
	v_gl_segment2 := substr(v_po_charge,6,4);
v_status := ccw_exp_item_check(v_project_num, v_task_num, v_item_id, v_expenditure_type, v_gl_segment2);
---	insert into ss9085_debug(tax_date)values(v_project_num||'|'||v_task_num||'|'||v_item_id||'|'||v_expenditure_type||'|'||v_gl_segment2||'|'||v_status);

--if (v_status = 'CAP1-NO-ERROR') THEN
--	fnd_message.set_string('Project and Item type are capital and match');
--	fnd_message.show;
--elsif
if
	(v_status = 'CAP2-RAISE-ERROR') THEN
	fnd_message.set_string('Capital Item assigned to a task that does not allow capital Project. Please correct Project information.');	
--	fnd_message.show;
 					fnd_message.error;
          RAISE FORM_TRIGGER_FAILURE;
elsif
	(v_status = 'CAP4-RAISE-ERROR') THEN
	fnd_message.set_string('Capital Item assigned with Invalid Project.	Please correct Project information.');	
--	fnd_message.show;
 					fnd_message.error;
          RAISE FORM_TRIGGER_FAILURE;
elsif
	(v_status = 'EXP1-RAISE-ERROR') THEN
	fnd_message.set_string('Expense Item assigned with Capital Task. Please correct Item or Project information.');	
--	fnd_message.show;	
 					fnd_message.error;
          RAISE FORM_TRIGGER_FAILURE;
elsif
	(v_status = 'EXP4-RAISE-ERROR') THEN
	fnd_message.set_string('Account on Distribution does not match the Account on Item, Please correct the account on Distribution to match Account on Item.');	
--	fnd_message.show;
 					fnd_message.error;
          RAISE FORM_TRIGGER_FAILURE;		
elsif
	(v_status = 'EXP6-RAISE-ERROR') THEN
	fnd_message.set_string('Account on Distribution does not match the Account on Item, Please correct the account on Distribution to match Account on Item.');	
--	fnd_message.show;	
 					fnd_message.error;
          RAISE FORM_TRIGGER_FAILURE;
end if;
	end if;
	--
     
   --          IF (V_PROJECT_NUM IS NOT NULL AND V_ITEM_ID IS null ) THEN 
             --	  fnd_message.set_string('Project and Expenditure Type should be NULL for transactions which do not use inventory items');
              --  fnd_message.show;  	 
   --         	RAISE FORM_TRIGGER_FAILURE;
   ---          END IF;
             
       -- validate only if POET information is entered and it is an item-based line
---      IF V_expenditure_type IS NOT NULL AND v_item_id IS NOT NULL   THEN 
         --NULL;
---       END IF;
      
END IF;     
	EXCEPTION
   WHEN OTHERS
   THEN
      RAISE form_trigger_failure;
END;


---end new code

 
---------------------
/* New change by Abhishek Krishnan (ak731e) for Contractor PO Control*********************
********Custom Code Validations done on Requisiton Entry Form and Receipts Entry Form*****/
-- Changed on 22-OCT-2007 for Oracle Controls
/***********************************************************
*************Requisitions Entry Form************************
************************************************************/
DECLARE

-- VARIABLE THAT IS USED TO STORE THE FORM NAME (I.E. NAME OF THE CURRENT FORM THE CURSOR IS IN)
FORM_NAME   VARCHAR2 (30) := NAME_IN ('SYSTEM.CURRENT_FORM'); 

 -- VARIABLE THAT IS USED TO STORE THE BLOCK NAME (I.E. NAME OF THE CURRENT BLOCK THE CURSOR IS IN)
BLOCK_NAME  VARCHAR2 (30) := NAME_IN ('SYSTEM.CURSOR_BLOCK');  

ITEM_NAME   VARCHAR2 (30);
L_ATTR_CAT  PER_PEOPLE_F.ATTRIBUTE_CATEGORY%TYPE;
L_ATTR4     PER_PEOPLE_F.ATTRIBUTE4%TYPE;
--L_EMP_NO    PER_PEOPLE_F.EMPLOYEE_NUMBER%TYPE;
L_USER_NAME  FND_USER.USER_NAME%TYPE;
L_USER_ID number := FND_PROFILE.VALUE('USER_ID');
L_PREP_ID   NUMBER;

L_EMP_ID    FND_USER.EMPLOYEE_ID%TYPE;
L_VENDOR_NAME PO_VENDORS.VENDOR_NAME%TYPE;
 -- PARAMETER THAT SPECIFIES THE CURRENT RECORD STATUS  
L_RECORD_STATUS   VARCHAR2 (30);

 -- PARAMETER THAT SPECIFIES IF THE FORM IS OPENED IN THE QUERY MODE OR NOT 
L_QUERY_ONLY      VARCHAR2 (150);
L_SUPP_NAME       VARCHAR2 (150);
L_SUPP_NAME_R     VARCHAR2 (150);
--item_name1				varchar2(90) := name_in('system.cursor_item');
/***********************************************************************************
*************************MANDATORY SUPPLIER FIELD***********************************
************************************************************************************/
BEGIN
  IF FORM_NAME = 'POXRQERQ' 
  THEN --1
    	
    	--fnd_message.DEBUG('Form-Mandatory supplier check.');
    	
			L_QUERY_ONLY:= NAME_IN ('PARAMETER.QUERY_ONLY');
			L_RECORD_STATUS:= NAME_IN ('SYSTEM.RECORD_STATUS');

			IF  EVENT_NAME = 'WHEN-NEW-FORM-INSTANCE' OR
    	    EVENT_NAME = 'WHEN-NEW-RECORD-INSTANCE' 
    	THEN --2
    		  --AND L_RECORD_STATUS = 'NEW' THEN 

  			L_PREP_ID:= NAME_IN ('PO_REQ_HDR.PREPARER_ID');

		 		begin
		 			SELECT UPPER(ATTRIBUTE_CATEGORY), LTRIM(RTRIM(ATTRIBUTE4))
	        INTO L_ATTR_CAT, L_ATTR4
	        FROM PER_ALL_PEOPLE_F
	        WHERE PERSON_ID = L_PREP_ID
	          and trunc(sysdate) between effective_start_date and effective_end_date; -- Selecting the category and supplier number for the user/preparer
		 		exception
		 			when no_data_found then
		 			 null;
		 		end;
	 		
        IF L_ATTR_CAT = 'CONTRACTOR' 
        THEN --3
				 APP_ITEM_PROPERTY2.SET_PROPERTY ('LINES.SUGGESTED_VENDOR_NAME', REQUIRED, PROPERTY_TRUE);
         SET_ITEM_PROPERTY ('LINES.SUGGESTED_VENDOR_NAME', VALIDATE_FROM_LIST, PROPERTY_TRUE);
				 --GO_ITEM ('LINES.SUGGESTED_VENDOR_NAME');
      	ELSE 
			   APP_ITEM_PROPERTY2.SET_PROPERTY ('LINES.SUGGESTED_VENDOR_NAME', REQUIRED, PROPERTY_FALSE);    					
      	END IF;-- for 3

      END IF; -- 'WHEN-NEW-FORM-INSTANCE' OR 'WHEN-NEW-RECORD-INSTANCE' for 2
    
			/**********************
			L_QUERY_ONLY:= NAME_IN ('PARAMETER.QUERY_ONLY');
					L_RECORD_STATUS:= NAME_IN ('SYSTEM.RECORD_STATUS');
			
							IF  EVENT_NAME = 'WHEN-NEW-ITEM-INSTANCE' THEN
			
			  			L_PREP_ID:= NAME_IN ('PO_REQ_HDR.PREPARER_ID');
			
				 			SELECT UPPER(ATTRIBUTE_CATEGORY), LTRIM(RTRIM(ATTRIBUTE4))
			        INTO L_ATTR_CAT, L_ATTR4
			        FROM PER_ALL_PEOPLE_F
			        WHERE PERSON_ID = L_PREP_ID; -- Selecting the category and supplier number for the user/preparer
			
			              IF L_ATTR_CAT = 'CONTRACTOR' THEN --3
			
			    					SET_ITEM_PROPERTY ('LINES.SUGGESTED_VENDOR_NAME', VALIDATE_FROM_LIST, 
			PROPERTY_TRUE);
			
			    				
			            	END IF;-- for 3
			
							END IF;        -- 'WHEN-NEW-ITEM-INSTANCE' 
			
			/*************************CHECK IF SUPPLIER NAME ENTERED IN REQUISITION FORM **************** 
			*******************************IS ASSOCIATED WITH THE CONTRACTOR****************************
			********************************************************************************************/
     					IF (EVENT_NAME = 'WHEN-VALIDATE-RECORD') OR
     						 (EVENT_NAME = 'WHEN-NEW-ITEM-INSTANCE') 
     					THEN     --4 
     	 				--((EVENT_NAME = 'WHEN-NEW-ITEM-INSTANCE') AND (ITEM_NAME1 = 'LINES.SUGGESTED_VENDOR_NAME'))
     	 				  
 							L_PREP_ID:= NAME_IN ('PO_REQ_HDR.PREPARER_ID');-- For the Preparer Field
 							L_SUPP_NAME:= NAME_IN ('LINES.SUGGESTED_VENDOR_NAME'); 
							--FOR THE SUPPLIER FIELD
	            begin
		 						SELECT UPPER (ATTRIBUTE_CATEGORY), LTRIM(RTRIM(ATTRIBUTE4))
	              INTO L_ATTR_CAT, L_ATTR4
	              FROM PER_PEOPLE_F
	              WHERE PERSON_ID = L_PREP_ID
	              and trunc(sysdate) between effective_start_date and effective_end_date;
	            exception
	            	when others then
	            	 null;
	            end;
            	

							IF L_ATTR_CAT = 'CONTRACTOR' THEN --5
							SELECT VENDOR_NAME INTO L_VENDOR_NAME FROM PO_VENDORS WHERE SEGMENT1 = (L_ATTR4); -- for that supplier number identifying the vendor/supplier name
  									IF  (L_VENDOR_NAME) = (L_SUPP_NAME) THEN 
  										
  								/*	SELECT EMPLOYEE_NUMBER INTO L_EMP_NO 
										FROM PER_PEOPLE_F
										WHERE ATTRIBUTE4 = L_ATTR4;*/
										FND_PROFILE.GET 
										('USER_ID',L_USER_ID);
										SELECT USER_NAME 
										INTO L_USER_NAME
										FROM FND_USER
										WHERE USER_ID = L_USER_ID;
										FND_MESSAGE.SET_STRING ('User '|| L_USER_NAME ||' is associated with this supplier '|| L_SUPP_NAME  || ' : User is not permitted to create requisition for this supplier.' );
       							FND_MESSAGE.ERROR;
       							copy(NULL, 'LINES.SUGGESTED_VENDOR_NAME');
       							--GO_ITEM('LINES.SUGGESTED_VENDOR_NAME');
       							--CLEAR_ITEM;
         						RAISE FORM_TRIGGER_FAILURE;
         						--fnd_message.set_string('f');
         						--fnd_message.show;
            				END IF;--for 6
        			END IF;-- for5
      				END IF;-- for 4
  END IF;	   -- for 1
  
  --fnd_message.DEBUG('Form-Mandatory supplier check ends.');
  
	  /*      
	    IF (EVENT_NAME = 'WHEN-NEW-ITEM-INSTANCE') AND L_RECORD_STATUS = 'NEW' THEN
	
	    IF (BLOCK_NAME = 'LINES') THEN 
	
	    IF SYSTEM.CURRENT_ITEM = 'SUGGESTED_VENDOR_NAME' THEN 
	
		L_PREP_ID:= NAME_IN ('PO_REQ_HDR.PREPARER_ID');
	
	
		 SELECT UPPER (ATTRIBUTE_CATEGORY), LTRIM(RTRIM(ATTRIBUTE4))
	                 INTO L_ATTR_CAT, L_ATTR4
	                 FROM PER_ALL_PEOPLE_F
	               WHERE PERSON_ID = L_PREP_ID;
	
		   IF L_ATTR_CAT = 'CONTRACTOR' THEN 
	
	                IF NAME_IN ('LINES.SUGGESTED_VENDOR_NAME') IS NULL THEN 
	
	             FND_MESSAGE.SET_STRING ('PLEASE ENTER A VALUE FOR THE SUPPLIER FIELD YOU ARE A CONTRACTOR');
		FND_MESSAGE.SHOW;
	
	               END IF;
	           END IF;
	      END IF;
	   END IF;
	END IF;	 */                         
EXCEPTION
    	when no_data_found then 
    --	 fnd_message.DEBUG('Form-Mandatory supplier check: Loop 1: no_data_found.');
    	null;
    	WHEN OTHERS THEN raise form_trigger_failure;  
END;

/**********************RECEIPTS FORM MANDATORY SUPPLIER FIELD***********************************/  
  
DECLARE

-- VARIABLE THAT IS USED TO STORE THE FORM NAME (I.E. NAME OF THE CURRENT FORM THE CURSOR IS IN)
FORM_NAME   VARCHAR2 (30) := NAME_IN ('SYSTEM.CURRENT_FORM'); 

 -- VARIABLE THAT IS USED TO STORE THE BLOCK NAME (I.E. NAME OF THE CURRENT BLOCK THE CURSOR IS IN)
BLOCK_NAME  VARCHAR2 (30) := NAME_IN ('SYSTEM.CURSOR_BLOCK');  

ITEM_NAME   VARCHAR2 (30);


L_ATTR_CAT  PER_PEOPLE_F.ATTRIBUTE_CATEGORY%TYPE;
L_ATTR4     PER_PEOPLE_F.ATTRIBUTE4%TYPE;
--L_EMP_NO    PER_PEOPLE_F.EMPLOYEE_NUMBER%TYPE;
L_USER_NAME   FND_USER.USER_NAME%TYPE;
L_USER_ID number := FND_PROFILE.VALUE('USER_ID');
L_PREP_ID   NUMBER;
L_EMP_ID    FND_USER.EMPLOYEE_ID%TYPE;
L_VENDOR_NAME PO_VENDORS.VENDOR_NAME%TYPE;
 -- PARAMETER THAT SPECIFIES THE CURRENT RECORD STATUS  
L_RECORD_STATUS   VARCHAR2 (30);

 -- PARAMETER THAT SPECIFIES IF THE FORM IS OPENED IN THE QUERY MODE OR NOT 
L_QUERY_ONLY      VARCHAR2 (30);
L_SUPP_NAME       VARCHAR2 (30);
L_SUPP_NAME_R     VARCHAR2 (30);

BEGIN
 
 --fnd_message.DEBUG('Current form checks enter.');
 
 IF (FORM_NAME = 'RCVRCERC') 
 THEN --7
	 -- FND_MESSAGE.SET_STRING ('FORM FIRED');
	 -- FND_MESSAGE.SHOW;
     IF (EVENT_NAME = 'WHEN-NEW-FORM-INSTANCE') 
     THEN --8
		   --FND_MESSAGE.SET_STRING ('EVENT FIRED');
	 	   --FND_MESSAGE.SHOW;	
		    --OR (EVENT_NAME = 'WHEN-NEW-ITEM-INSTANCE') 
	     FND_PROFILE.GET ('USER_ID',L_USER_ID);
	     --FND_MESSAGE.SET_STRING (' USER: '|| L_USER_ID );
	     --FND_MESSAGE.SHOW; 
			 SELECT EMPLOYEE_ID INTO L_EMP_ID 
	     FROM FND_USER
	     WHERE USER_ID = L_USER_ID;
	     --FND_MESSAGE.SET_STRING (' USER: '|| L_USER_ID ||' EMP ' || L_EMP_ID);
	     --FND_MESSAGE.SHOW; 
	    begin 
	     SELECT ATTRIBUTE_CATEGORY, ATTRIBUTE4 INTO L_ATTR_CAT, L_ATTR4 
	     FROM PER_PEOPLE_F 
	     WHERE PERSON_ID = L_EMP_ID
	     and trunc(sysdate) between effective_start_date and effective_end_date;
	    exception
	    	when no_data_found then
	    	null;
	    end;
	     
	     --FND_MESSAGE.SET_STRING (' EMP: '|| L_EMP_ID ||' CATEGORY: '|| L_ATTR_CAT ||' SUPPLIER ' || L_ATTR4);
       --FND_MESSAGE.SHOW;
       
      IF UPPER(L_ATTR_CAT) = 'CONTRACTOR' THEN
		  --FND_MESSAGE.SET_STRING (' IF ATTR CATEGORY = CONTRACTOR - CONFIRMED');
			--FND_MESSAGE.SHOW;
			APP_ITEM_PROPERTY2.SET_PROPERTY ('FIND.SOURCE', REQUIRED, PROPERTY_TRUE);
			ELSE
			APP_ITEM_PROPERTY2.SET_PROPERTY ('FIND.SOURCE', REQUIRED, PROPERTY_FALSE);
  		END IF;
    END IF;--8
 END IF;--7

EXCEPTION
 	when no_data_found then null;
 	--- fnd_message.DEBUG('Current form checks: no_data_found.');
 	WHEN OTHERS THEN NULL;
END;

/* ***********************************************************************************************
  * Code to meet 11.5.10 Upgrade changes as per CQ#WUP00077120
  * Date : 22-JAN-2008
  * Author: Mohan P
  * PA Asset and Capital Asset form Changes.
  * 1. Disabling the Assign_asset, Copy Asset Buttons and removing the Capital Hold checkbox filed from Asset block
  * 2. Disabling the Split Line Button from Asset lines block
  * 3.Disable the Copy Asset Button in Asset Subform
 **************************************************************************************************
*/
 DECLARE
 	v_resp_name  VARCHAR2(80) := FND_PROFILE.VALUE('RESP_NAME');
 	v_status     VARCHAR2(15);
 	tb_pg_id1  TAB_PAGE;
 	tb_pg_id2  TAB_PAGE;
 BEGIN
 	IF	FORM_NAME	 = 'PAXCARVW'	THEN
 		--fnd_message.debug(v_resp_name);
 		IF (v_resp_name = 'CW Project Manager') OR (v_resp_name = 'CW Project Accountant') THEN
 		--	IF  (BLOCK_NAME = 'ASSETS') THEN
 				tb_pg_id1 := FIND_TAB_PAGE('ASSET_ADDTL_DETAILS');
 				tb_pg_id2 := FIND_TAB_PAGE('ASSET_IDENTIFICATION');
 		
 		    	app_item_property2.set_property('ASSETS_CONTROL.ASSIGN_ASSET_BUTTON',ENABLED,PROPERTY_OFF);
 			    app_item_property2.set_property('ASSETS_CONTROL.COPY_ASSET',ENABLED,PROPERTY_OFF);
 			    app_item_property2.set_property('ASSETS_CONTROL.ASSIGN_ASSET_MIR_BUTTON',ENABLED,PROPERTY_OFF);
 			    app_item_property2.set_property('ASSETS_CONTROL.COPY_ASSET_MIR_BUTTON',ENABLED,PROPERTY_OFF);
 			    -- ASSIGN_ASSET_MIR_BUTTON  COPY_ASSET_MIR_BUTTON
 		      set_tab_page_property(tb_pg_id1, VISIBLE, PROPERTY_FALSE);
 		      set_tab_page_property(tb_pg_id2, VISIBLE, PROPERTY_FALSE);
 		   IF (v_resp_name = 'CW Project Accountant') THEN
 		    set_block_property('ASSETS',UPDATE_ALLOWED,PROPERTY_FALSE);
 		   END IF;
 		--	END IF;
 		--	IF (BLOCK_NAME = 'ASSET_LINES') AND (EVENT_NAME = 'WHEN-NEW-BLOCK-INSTANCE') THEN
 			  app_item_property2.set_property('ASSET_LINES_CONTROL.SPLIT_LINE_BUTTON',ENABLED,PROPERTY_OFF);
 		--	END IF;
 		END IF;
 	END IF;
 	IF	FORM_NAME	 = 'PAXPREPR'	THEN
 		IF (v_resp_name = 'CW Project Manager') OR (v_resp_name = 'CW Project Accountant') THEN
 		--	IF (BLOCK_NAME = 'ASSETS')  AND (EVENT_NAME = 'WHEN-NEW-BLOCK-INSTANCE') THEN
 				app_item_property2.set_property('ASSETS.COPY_ASSET',ENABLED,PROPERTY_OFF);
 		--	END IF;
 		END IF;
 	END IF;
 	
 EXCEPTION
 	WHEN OTHERS THEN
 	NULL;
 END;
 --**************************************************************************************************
 --End of 11.5.10 upgrade code CQ#WUP00077120
-------------------------------------------------------------------------------------------- end code

---------------------------New Horizon project for Wireline-------------------------------
---------------------------VJ 04-Sep-2009-------------------------------------------------
-------------------------------RECEIVING RECEIPT FORM-------------------------------------
DECLARE
  vv_orgid                     mtl_parameters.organization_id%TYPE;
  VV_Receipt_record_grpid       RECORDGROUP;
  vv_group_name varchar2(100):='ATT_PORECEIPT_RG';
  vv_po_type						        varchar2(1000);
  vv_po_num1									   varchar2(100);
  vmsg varchar2(2000);
  VV_rg_error1 NUMBER; 
  v_record_count		number;
  v_po_segment1 varchar2(100);
BEGIN
  IF (form_name = 'RCVRCERC' ) THEN --and block_name = 'FIND' ) then --AND item_name='PO_NUM') then
  	if  event_name = 'WHEN-NEW-BLOCK-INSTANCE' THEN
--  	IF (item_name='FIND.PO_NUM') THEN
	     IF block_name = 'FIND'  THEN
    IF cwpo_nh_acct_gen_pkg.check_resp='WIRELINE' THEN
    --	message('inside condition');
    
     vv_po_num1 :=NAME_IN('FIND.PO_NUM');
     --MESSAGE('PO NUMBER' || vv_po_num1);
    
    	vv_orgid :=NAME_IN('PO_STARTUP_VALUES.ORG_ID'); 
    	vv_po_type:=NAME_IN('PO_STARTUP_VALUES.MANUAL_PO_NUM_TYPE');

    VV_Receipt_record_grpid := Find_Group( vv_group_name ); 
	  
		IF Id_Null(VV_Receipt_record_grpid) THEN 
		VV_Receipt_record_grpid := CREATE_GROUP_FROM_QUERY (vv_group_name,    
	  'select ph.segment1 , ph.po_header_id, ph.type_lookup_code, ph.displayed_field type, ph.vendor_name, ph.vendor_id, ph.full_name,''Vendor'' 
	  from CCW_PO_POS_VAL_V  ph where exists (select ''Valid PO Shipments'' from po_line_locations poll 
		where ph.po_header_id = poll.po_header_id and nvl(poll.approved_flag,''N'') = ''Y'' and nvl(poll.cancel_flag,''N'') = ''N'' 
		and poll.shipment_type in (''STANDARD'',''BLANKET'',''SCHEDULED'') and poll.ship_to_organization_id ='||	vv_orgid||
	  ') and rownum >= 1 and PH.attribute5=''WIRELINE'' order by decode ('||''''||vv_po_type||''''||',''NUMERIC'', null,ph.segment1),decode('||''''||vv_po_type||''''||',''NUMERIC'',to_number(ph.segment1),null)');

		end if;	  
  	Set_LOV_Property('FIND_PO_NUM_FOR_RECEIPT_OPEN',GROUP_NAME,VV_Receipt_record_grpid);
  	
    else
   	vv_orgid :=NAME_IN('PO_STARTUP_VALUES.ORG_ID'); 
   	vv_po_type:=NAME_IN('PO_STARTUP_VALUES.MANUAL_PO_NUM_TYPE');
   	
   	VV_Receipt_record_grpid := Find_Group( vv_group_name );
   	
 		IF Id_Null(VV_Receipt_record_grpid) THEN 
		VV_Receipt_record_grpid := CREATE_GROUP_FROM_QUERY ('ATT_PORECEIPT_RG',    
	  'select ph.segment1 , ph.po_header_id, ph.type_lookup_code, ph.displayed_field type, ph.vendor_name, ph.vendor_id, ph.full_name,''Vendor'' 
	  from CCW_PO_POS_VAL_V  ph where exists (select ''Valid PO Shipments'' from po_line_locations poll 
		where ph.po_header_id = poll.po_header_id and nvl(poll.approved_flag,''N'') = ''Y'' and nvl(poll.cancel_flag,''N'') = ''N'' 
		and poll.shipment_type in (''STANDARD'',''BLANKET'',''SCHEDULED'') and poll.ship_to_organization_id ='||	vv_orgid||
	  ') and rownum >= 1 and nvl(PH.attribute5,''NN'') !=''WIRELINE'' order by decode ('||''''||vv_po_type||''''||',''NUMERIC'', null,ph.segment1),decode('||''''||vv_po_type||''''||',''NUMERIC'',to_number(ph.segment1),null)');
 		end if;
   		
  	Set_LOV_Property('FIND_PO_NUM_FOR_RECEIPT_OPEN',GROUP_NAME,VV_Receipt_record_grpid);
    
    END IF;
    END IF;
  	END IF;
--**************************************  	
/*  	if  event_name = 'WHEN-NEW-RECORD-INSTANCE' THEN
	     IF block_name = 'RCV_TRANSACTION'  THEN
	     	v_po_segment1 :=NAME_IN('RCV_TRANSACTION.ORDER_NUMBER_DSP'); 
    			IF cwpo_nh_acct_gen_pkg.check_resp='WIRELINE'THEN
    			Begin
    			select count(*) into v_record_count from po_headers_all 
    			where segment1=v_po_segment1 and nvl(attribute5,'NN') = 'WIRELINE';
    			end;
       				if v_record_count = 0 then
       	        set_block_property('RCV_TRANSACTION',update_allowed,property_false);
       	        set_block_property('RCV_TRANSACTION',update_allowed,property_false);
       	        else 
       	        set_block_property('RCV_TRANSACTION',update_allowed,property_true);
       	        set_block_property('RCV_TRANSACTION',update_allowed,property_true);
       				end if;
	     		end if;
  	   end if;
  	end if;
  	*/
--**************************************


  	
  	END IF;
  	
  	
  	
  END;
  --------------------------------RECEIVING --- RETRUN FORM------------------------
  DECLARE
  vv_return_orgid                      mtl_parameters.organization_id%TYPE;
  VV_return_record_grpid       RECORDGROUP;
  vv_return_group_name varchar2(100)   :='ATT_PORETURNS_RG';
  vv_return_po_type						        varchar2(1000);
  vmsg varchar2(2000);
  VV_return_rg_error1 NUMBER; 
BEGIN
  IF (form_name = 'RCVTXERE' ) THEN 
  	if  event_name = 'WHEN-NEW-BLOCK-INSTANCE' THEN
    IF block_name = 'FIND'  THEN
    IF cwpo_nh_acct_gen_pkg.check_resp='WIRELINE' THEN
    	
    	--vv_return_orgid :=NAME_IN('PO_STARTUP_VALUES.ORG_ID'); 
    	vv_return_po_type:=NAME_IN('PO_STARTUP_VALUES.MANUAL_PO_NUM_TYPE');
    	
    VV_return_record_grpid := Find_Group( vv_return_group_name ); 	


		IF Id_Null(VV_return_record_grpid) THEN     	
		VV_return_record_grpid := CREATE_GROUP_FROM_QUERY (vv_return_group_name,    
	  'select distinct ph.segment1 , ph.po_header_id, ph.type_lookup_code, ph.displayed_field type,
	   ph.vendor_name, ph.vendor_id, ph.full_name, ''Vendor'' from CCW_PO_POS_VAL_V  ph,rcv_transactions rt  
	    where ph.type_lookup_code in (''BLANKET'',''STANDARD'',''PLANNED'')  
	    and rownum >= 1 and ph.po_header_id = rt.po_header_id 
	    and ph.authorization_status = ''APPROVED'' and  PH.attribute5=''WIRELINE'' 
	    order by decode ('||''''||vv_return_po_type||''''||',''NUMERIC'', null,ph.segment1),decode('||''''||vv_return_po_type||''''||',''NUMERIC'',to_number(ph.segment1),null)');
	
	 end if;
	--decode (:po_startup_values.manual_po_num_type,'NUMERIC', null,ph.segment1),decode(:po_startup_values.manual_po_num_type,'NUMERIC',to_number(ph.segment1),null)
  	Set_LOV_Property('FIND_PO_NUM_FOR_RET_CORR',GROUP_NAME,VV_return_record_grpid);
  	
    else
   	--vv_orgid :=NAME_IN('PO_STARTUP_VALUES.ORG_ID'); 
   	vv_return_po_type:=NAME_IN('PO_STARTUP_VALUES.MANUAL_PO_NUM_TYPE');
    VV_return_record_grpid := Find_Group( vv_return_group_name ); 	

		IF Id_Null(VV_return_record_grpid) THEN     	

		VV_return_record_grpid := CREATE_GROUP_FROM_QUERY (vv_return_group_name,    
	  'select distinct ph.segment1 , ph.po_header_id, ph.type_lookup_code, ph.displayed_field type,
	   ph.vendor_name, ph.vendor_id, ph.full_name, ''Vendor'' from CCW_PO_POS_VAL_V  ph,rcv_transactions rt  
	    where ph.type_lookup_code in (''BLANKET'',''STANDARD'',''PLANNED'')  
	    and rownum >= 1 and ph.po_header_id = rt.po_header_id 
	    and ph.authorization_status = ''APPROVED'' and  nvl(PH.attribute5,''NN'') !=''WIRELINE'' 
	    order by decode ('||''''||vv_return_po_type||''''||',''NUMERIC'', null,ph.segment1),decode('||''''||vv_return_po_type||''''||',''NUMERIC'',to_number(ph.segment1),null)');

 	end if;
	
  	Set_LOV_Property('FIND_PO_NUM_FOR_RET_CORR',GROUP_NAME,VV_return_record_grpid);
    
    END IF;
    END IF;
  	END IF;
  	END IF;
  	
END;

  --------------------------------RECEIVING --- CORRECTION FORM------------------------
  DECLARE
  vv_cor_orgid                      mtl_parameters.organization_id%TYPE;
  VV_cor_record_grpid       RECORDGROUP;
  vv_cor_group_name varchar2(100)   :='ATT_POCORRECTION_RG';
  vv_cor_po_type						        varchar2(1000);
  vmsg varchar2(2000);
  VV_cor_rg_error1 NUMBER; 
BEGIN
  IF (form_name = 'RCVTXECO' ) THEN 
  	if  event_name = 'WHEN-NEW-BLOCK-INSTANCE' THEN
    IF block_name = 'FIND'  THEN
    IF cwpo_nh_acct_gen_pkg.check_resp='WIRELINE' THEN
    	
    	--vv_return_orgid :=NAME_IN('PO_STARTUP_VALUES.ORG_ID'); 
    	vv_cor_po_type:=NAME_IN('PO_STARTUP_VALUES.MANUAL_PO_NUM_TYPE');

VV_cor_record_grpid := Find_Group(vv_cor_group_name ); 	


		IF Id_Null(VV_cor_record_grpid) THEN     	
    	
		VV_cor_record_grpid := CREATE_GROUP_FROM_QUERY (vv_cor_group_name,    
    'select distinct ph.segment1 , ph.po_header_id, ph.type_lookup_code, ph.displayed_field type, ph.vendor_name, ph.vendor_id, 
     ph.full_name, ''Vendor'' from CCW_PO_POS_VAL_V  ph,rcv_transactions rt where ph.type_lookup_code in (''BLANKET'',''STANDARD'',''PLANNED'') 
     and rownum >= 1 and ph.po_header_id = rt.po_header_id and ph.authorization_status = ''APPROVED'' and  PH.attribute5=''WIRELINE'' 
     order by decode ('||''''||vv_cor_po_type||''''||',''NUMERIC'', null,ph.segment1),decode('||''''||vv_cor_po_type||''''||',''NUMERIC'',to_number(ph.segment1),null)');

     end if;     
     --order by decode (:po_startup_values.manual_po_num_type,'NUMERIC', null,ph.segment1),decode(:po_startup_values.manual_po_num_type,'NUMERIC',to_number(ph.segment1),null)
  	Set_LOV_Property('FIND_PO_NUM_FOR_RET_CORR',GROUP_NAME,VV_cor_record_grpid);
  	
    else
   	--vv_orgid :=NAME_IN('PO_STARTUP_VALUES.ORG_ID'); 
   	vv_cor_po_type:=NAME_IN('PO_STARTUP_VALUES.MANUAL_PO_NUM_TYPE');

VV_cor_record_grpid := Find_Group(vv_cor_group_name ); 	


		IF Id_Null(VV_cor_record_grpid) THEN     	
		VV_cor_record_grpid := CREATE_GROUP_FROM_QUERY (vv_cor_group_name,    
    'select distinct ph.segment1 , ph.po_header_id, ph.type_lookup_code, ph.displayed_field type, ph.vendor_name, ph.vendor_id, 
     ph.full_name, ''Vendor'' from CCW_PO_POS_VAL_V ph,rcv_transactions rt where ph.type_lookup_code in (''BLANKET'',''STANDARD'',''PLANNED'') 
     and rownum >= 1 and ph.po_header_id = rt.po_header_id and ph.authorization_status = ''APPROVED''  and  nvl(PH.attribute5,''NN'') !=''WIRELINE''   
     order by decode ('||''''||vv_cor_po_type||''''||',''NUMERIC'', null,ph.segment1),decode('||''''||vv_cor_po_type||''''||',''NUMERIC'',to_number(ph.segment1),null)');

		end if;

  	Set_LOV_Property('FIND_PO_NUM_FOR_RET_CORR',GROUP_NAME,VV_cor_record_grpid);
    
    END IF;
    END IF;
  	END IF;
  	END IF;
  	
END;
--------------------------------END VJ------------------------------------------------


------------------------
-- 16-JUL-2008 Sue Gibson
-- Beginning of CR WUP116751(Creating custom error message if the end user tries to use 
-- X as the company code for the GL string on the POXPOEPO PO Entry form: Code is based on
-- PO requisition GL String validation written by Resley Cole  09/05
-- 06-AUG-08 Sue Gibson added form failure for block PO_APROVAL to prevent approval WUP116751
-- 11-AUG-08 Sue Gibson run all lines, not just current one; added cursor gl_check_all_gl_cur and
--                      split out header and po_approve blocks
-------------------------
DECLARE
	
form_name            VARCHAR2(30):= name_in('system.current_form');
block_name           VARCHAR2(30):= name_in('system.cursor_block');
item_name	           VARCHAR2(90):= name_in('system.cursor_item');
V_SEGMENT1           VARCHAR2(90);
v_error_found	       boolean;
v_line_num           NUMBER;
v_item_id            NUMBER;
v_ccid               NUMBER;
v_po_header_id       NUMBER;
v_po_line_id         NUMBER;
v_count              NUMBER;

CURSOR  gl_code_string_cur IS
 
              SELECT  pol.LINE_NUM           v_line_num         
                     ,gcc.segment1           v_segment1                    
               FROM   gl_code_combinations   gcc
				             ,PO_DISTRIBUTIONS_ALL   pod
				           	 ,po_lines_all           pol
               WHERE  SUBSTR(gcc.SEGMENT1,1,1)  = 'X'
               AND    gcc.code_combination_id   = pod.code_combination_id
               AND    pod.PO_LINE_ID            = pol.PO_LINE_ID
			         AND    pol.po_line_id            = v_po_line_id
               AND    pol.PO_HEADER_ID          = v_po_header_id;
               
CURSOR gl_check_all_gl_cur IS

              SELECT  pol.LINE_NUM           v_line_num         
                     ,gcc.segment1           v_segment1                    
               FROM   gl_code_combinations   gcc
				             ,PO_DISTRIBUTIONS_ALL   pod
				           	 ,po_lines_all           pol
               WHERE  SUBSTR(gcc.SEGMENT1,1,1)  = 'X'
               AND    gcc.code_combination_id   = pod.code_combination_id
               AND    pod.PO_LINE_ID            = pol.PO_LINE_ID
               AND    pol.PO_HEADER_ID          = v_po_header_id;
BEGIN

	v_error_found := false ;	  	                 
   	
  IF (form_name  = 'POXPOEPO' AND 
  	 NAME_IN('PO_HEADERS.ATTRIBUTE5') != 'WIRELINE-ESS' AND--Added by kavya for ESS
	   (
	    (block_name IN ('PO_LINES' ,
	                    'PO_SHIPMENTS',
	                    'PO_DISTRIBUTIONS') AND 
	     event_name = 'WHEN-NEW-ITEM-INSTANCE')       OR
	     
	    (block_name = 'PO_HEADERS' AND
	     event_name = 'WHEN-NEW-RECORD-INSTANCE' AND
	     name_in('SYSTEM.BLOCK_STATUS') = 'QUERY' )   OR     
	         
	    (block_name = 'PO_APPROVE' AND         -- added PO_APPROVE block 30-JUL-08
	     event_name = 'WHEN-NEW-BLOCK-INSTANCE'   )  
--	     event_name in ( 'WHEN-NEW-BLOCK-INSTANCE','WHEN-NEW-RECORD-INSTANCE', 'WHEN-VALIDATE-RECORD') )
	   )                                                                AND    
	    NAME_IN('PO_LINES.PO_HEADER_ID')   IS NOT NULL AND 
	    NAME_IN('PO_LINES.PO_LINE_ID')     IS NOT NULL AND  
	    -- Sriram S WUP00141934 07-Nov-2008 
	    -- Commented Charge Account NULL check condition as PO_LINES.Charge_Account is null when PO is saved from Shipments
	    -- block w/o clicking on Distributions. This prevents the validation from firing.
	    -- name_in('PO_LINES.CHARGE_ACCOUNT') IS NOT NULL AND
	    name_in('PO_LINES.LINE_NUM')        >= 1 )                  THEN 	                
	               
--fnd_message.debug('block is ' || block_name ||' trigger is ' || event_name);
	      v_po_header_id  := NAME_IN('PO_LINES.PO_HEADER_ID');
	      v_po_line_id    := NAME_IN('PO_LINES.PO_LINE_ID');
	      v_line_num      := NAME_IN('PO_LINES.LINE_NUM');
       
        IF block_name in ('PO_LINES' , 'PO_SHIPMENTS', 'PO_DISTRIBUTIONS') THEN
        	v_segment1 := null;
        	FOR cursor1_index in gl_code_string_cur
        	 LOOP
        	 	 if cursor1_index.v_segment1 = 'X' THEN
        	 	   v_segment1 := 'X';
        	 	 	 v_line_num := cursor1_index.v_line_num;
        	 	 	 EXIT;
             end if;        	 	 
        	 END LOOP;
        	
        ELSIF block_name in ('PO_HEADERS','PO_APPROVE') THEN
          FOR cursor2_index in gl_check_all_gl_cur
           LOOP
        	 	 if cursor2_index.v_segment1 = 'X' THEN
        	 	   v_segment1 := 'X';
        	 	 	 v_line_num := cursor2_index.v_line_num;
        	 	 	 EXIT;
             end if;        	 	 
           END LOOP;	 	 
        	
        END IF;
/*      	                
--	         open  gl_code_string_cur;
	         FETCH gl_code_string_cur INTO v_line_num,v_segment1;
	         close gl_code_string_cur;
        END IF;  
*/
	      
	      IF  v_segment1 = 'X'  then
	      	
  	        fnd_message.set_string('X does not exist on any rule.'||'  '|| 
  			                               'You MUST change the GL string in Distributions on'||'  '||
  			                               'Line #'||' '||V_LINE_NUM||'.');--||NAME_IN('system.cursor_block'));
  	       FND_MESSAGE.ERROR; 
  	           
-- Start 06-AUG-08 Sue Gibson
           IF block_name = 'PO_APPROVE' THEN
             go_block('PO_HEADERS');  
           	 raise form_trigger_failure;
           END IF;
-- End 06-AUG-08 Sue Gibson           
  	    	       	       
	      END IF;
	      END IF;  


/* this code is moved to cust_nhr2_119 section of the code		

    -- Added by Amod Joshi on 24-Jun-2010
		-- Rice 34 - R78 - Start
		
		IF form_name = 'APXPMTCH' and event_name = 'WHEN-NEW-FORM-INSTANCE' THEN
			DEFAULT_VALUE(0, 'GLOBAL.FRAC_STATUS');
			COPY(0,'GLOBAL.FRAC_STATUS');
			DEFAULT_VALUE(0, 'GLOBAL.DISP_MSG');
			COPY(0,'GLOBAL.DISP_MSG');
		END IF;
		
		IF form_name = 'APXPMTCH' and block_name = 'SHIPMENT_MATCH' and event_name = 'WHEN-NEW-RECORD-INSTANCE' THEN
			DEFAULT_VALUE(0, 'GLOBAL.OLD_QTY');
			COPY(NVL(NAME_IN('SHIPMENT_MATCH.QUANTITY_INVOICED'),0), 'GLOBAL.OLD_QTY');
		END IF;			
			
			
		IF form_name = 'APXPMTCH' and block_name = 'SHIPMENT_MATCH' and event_name = 'WHEN-VALIDATE-RECORD' THEN
			
			DEFAULT_VALUE(0, 'GLOBAL.FRAC_STATUS');
			
			-- old is non fractional and new is fractional
			IF  NAME_IN('SHIPMENT_MATCH.QUANTITY_INVOICED') <> NAME_IN('GLOBAL.OLD_QTY')
			AND INSTR(NAME_IN('SHIPMENT_MATCH.QUANTITY_INVOICED'),'.') <> 0 
			AND INSTR(NAME_IN('GLOBAL.OLD_QTY'),'.') = 0
			THEN
				COPY(NAME_IN('GLOBAL.FRAC_STATUS') + 1, 'GLOBAL.FRAC_STATUS');
			END IF;
			
			-- old is fractional and new is non fractional
			IF  NAME_IN('SHIPMENT_MATCH.QUANTITY_INVOICED') <> NAME_IN('GLOBAL.OLD_QTY')
			AND INSTR(NAME_IN('SHIPMENT_MATCH.QUANTITY_INVOICED'),'.') = 0 
			AND INSTR(NAME_IN('GLOBAL.OLD_QTY'),'.') <> 0
			THEN
				COPY(NAME_IN('GLOBAL.FRAC_STATUS') - 1, 'GLOBAL.FRAC_STATUS');
			END IF;
      
		END IF; --form_name = 'APXPMTCH'
		
		
		IF form_name = 'APXPMTCH' and block_name = 'SHIPMENT_MATCH_CONTROL' and event_name = 'WHEN-VALIDATE-RECORD' and NAME_IN('GLOBAL.FRAC_STATUS') > 0 THEN
			
			BEGIN
			  v_hold_status := NULL;
			  v_invoice_id  := NAME_IN('INVOICE.INVOICE_ID');
			  
				SELECT '1'
				INTO   v_hold_status
				FROM   ap_holds_all
				WHERE  invoice_id 		  = v_invoice_id
				AND    hold_lookup_code = 'CUST_AP_FRAC_QTY_HOLD'
				AND    release_lookup_code IS NULL;
		  EXCEPTION
		    WHEN OTHERS THEN
		    	NULL;
		  END;
		  
		  IF v_hold_status IS NULL and NAME_IN('GLOBAL.DISP_MSG') = 0 THEN
		  	
		  	COPY(1,'GLOBAL.DISP_MSG');
			
  		  fnd_message.set_string('One of the lines has fractional quantity, Press OK to apply hold, CANCEL to not apply hold.');
				v_button_selection := fnd_message.question('OK','CANCEL','',1, 2,'question');
				
				IF v_button_selection = 1 THEN
					
				  BEGIN
						SELECT description
						INTO   v_hold_description
						FROM   ap_hold_codes
						WHERE  hold_lookup_code = 'CUST_AP_FRAC_QTY_HOLD';
				  EXCEPTION
				  	WHEN OTHERS THEN
				  		NULL;
				  END;
				  
					ap_holds_pkg.insert_single_hold(x_invoice_id			 => NAME_IN('INVOICE.INVOICE_ID')
                               					 ,x_hold_lookup_code => 'CUST_AP_FRAC_QTY_HOLD'
                               					 ,x_hold_reason      => v_hold_description
			       														 );
					-- Populate CCWAP.CUST_AP_CFAS_INV_STAT_IMP_DTL
				  BEGIN
					  v_vendor_num 			 := NULL;
					  v_vendor_site_code := NULL;
					  v_vendor_site_id	 := NULL;
					  v_invoice_num 		 := NULL;
					  v_invoice_amount   := NULL;
					  v_vendor_id				 := NULL;
					  v_po_number				 := NULL;

  					v_vendor_id := NAME_IN('SHIPMENT_MATCH.VENDOR_ID');
  					v_po_number := NAME_IN('SHIPMENT_MATCH.PO_NUMBER');
					  
						SELECT POV.segment1
								  ,POVS.vendor_site_code
								  ,POVS.vendor_site_id
								  ,AIA.invoice_num
								  ,AIA.invoice_amount
						INTO   v_vendor_num
									,v_vendor_site_code
									,v_vendor_site_id
									,v_invoice_num
									,v_invoice_amount
					  FROM  po_vendors POV
					  		 ,po_vendor_sites_all POVS
					  		 ,ap_invoices_all AIA
					  WHERE POVS.vendor_id = POV.vendor_id
					  AND   AIA.vendor_site_id = POVS.vendor_site_id
					  AND   AIA.invoice_id = v_invoice_id
					  AND   POV.vendor_id	 = v_vendor_id;
				  EXCEPTION
				    WHEN OTHERS THEN
				      NULL;
				  END;
					
					BEGIN
				    INSERT INTO CCWAP.CUST_AP_CFAS_INV_STAT_IMP_DTL
				    								 (
													    VENDOR_NUM,                 --1      NOT NULL  VARCHAR2(30)
													    VENDOR_SITE_CODE,           --2      NOT NULL  VARCHAR2(15)
													    INVOICE_NUM,                --3      NOT NULL  VARCHAR2(50)
													    DISTRIBUTION_LINE_NUMBER,   --4                NUMBER
													    LINE_TYPE_LOOKUP_CODE,      --5                VARCHAR2(25)
													    INVOICE_AMOUNT       ,      --6                NUMBER
													    TRANSMISSION_DATE    ,      --7                DATE
													    SOURCE               ,      --8                VARCHAR2(50)
													    STATUS               ,      --9                VARCHAR2(10)
													    ERROR_CODE           ,      --10               VARCHAR2(250)
													    ERROR_MESSAGE        ,      --11               VARCHAR2(2000)
													    ERROR_DETAIL         ,      --12               VARCHAR2(250)
													    ERROR_DATE           ,      --13               DATE
													    EXTERNAL_SYSTEM_ID   ,      --14               VARCHAR2(50)
													    HOLD_LOOKUP_CODE     ,      --15               VARCHAR2(25)
													    HOLD_DATE            ,      --16               DATE
													    CREATED_BY_USER      ,      --17               VARCHAR2(30)
													    CREATION_DATE        ,      --18               DATE
													    LAST_UPDATE_USER     ,      --19               VARCHAR2(30)
													    LAST_UPDATE_DATE     ,      --20               DATE
													    RECORD_STATUS        ,      --21               VARCHAR2(1)
													    API_MESSAGE          ,      --22               VARCHAR2(480)
													    LOCAL_CODE_1         ,      --23               VARCHAR2(10)
													    LOCAL_CODE_2         ,      --24               VARCHAR2(10)
													    LOCAL_CODE_3         ,      --25               VARCHAR2(10)
													    LOCAL_CODE_4         ,      --26               VARCHAR2(10)
													    ATTRIBUTE1           ,      --27               VARCHAR2(150)
													    ATTRIBUTE2           ,      --28               VARCHAR2(150)
													    ATTRIBUTE3           ,      --29               VARCHAR2(150)
													    ATTRIBUTE4           ,      --30               VARCHAR2(150)
													    ATTRIBUTE5           ,      --31               VARCHAR2(150)
													    SCM_VENDOR_ID        ,      --32               NUMBER
													    SCM_VENDOR_SITE_ID   ,      --33               NUMBER
													    SCM_INVOICE_ID       ,      --34               NUMBER
													    SCM_INVOICE_DISTRIBUTION_ID, --35              NUMBER
													    PO_NUMBERS,                  --36              VARCHAR2(150)
													    FILE_NAME)                   --37              NOT NULL VARCHAR2(50)
													    VALUES
													    (
													    v_vendor_num            ,   --1
													    v_vendor_site_code      ,   --2
													    v_invoice_num           ,   --3
													    NULL                    ,   --4
													    NULL                    ,   --5  line type lookup code
													    v_invoice_amount        ,   --6
													    SYSDATE                 ,   --7
													    'MANUAL'        	 	    ,   --8 source
													    'FAILED'                ,   --9 status
													    'CUST_AP_FRAC_QTY_HOLD' ,   --10
													    v_hold_description , --'Custom Wireline Fractional Quantity Hold' ,  --11
													    v_hold_description , --'Custom Wireline Fractional Quantity Hold' ,  --12
													    SYSDATE                 ,   --13
													    NULL                    ,   --14
													    'CUST_AP_FRAC_QTY_HOLD' ,   --15
													    SYSDATE                 ,   --16
													    FND_GLOBAL.USER_ID      ,   --17
													    SYSDATE                 ,   --18
													    FND_GLOBAL.USER_ID      ,   --19
													    SYSDATE                 ,   --20
													    NULL                    ,   --21
													    NULL                    ,   --22
													    NULL                    ,   --23
													    NULL                    ,   --24
													    NULL                    ,   --25
													    NULL                    ,   --26
													    NULL                    ,   --27
													    NULL                    ,   --28
													    NULL                    ,   --29
													    NULL                    ,   --30
													    NULL                    ,   --31
													    v_vendor_id             ,   --32
													    v_vendor_site_id        ,   --33
													    v_invoice_id            ,   --34
													    NULL                    ,   --35
													    v_po_number             ,   --36
													    'MANUAL' 								    --37
													    );
			    EXCEPTION
			        WHEN OTHERS THEN
			          fnd_message.set_string('Error while inserting into table CCWAP.CUST_AP_CFAS_INV_STAT_IMP_DTL : ' || SQLERRM);
								fnd_message.error;
			    END;
			  	
				END IF; --v_button_selection = 1
			
		  END IF; --v_hold_status IS NULL
	  		  
		END IF; --form_name = 'APXPMTCH'
*/		
END;
-------------------------------
-- 16-JUL-2008 Sue Gibson
-- END of CR WUP116751
------------------------- 

/*
In Enter POs, in Approve block, fetch fax number from ap_supplier_sites.
See defect 2014-02 3994.  Maury Marcus, 2014.May.14.
Added fetch from ap.ap_supplier_contacts when site fax is null.
Maury Marcus, 2014.Jun.06.
Limit fetch from ap.ap_supplier_sitee to where supplier_notif_method is FAX.
Maury Marcus, 2014.Jun.10.
*/
declare
   x_vendor_site_id number;
   x_supplier_notif_method varchar2(25);
   x_fax_number varchar2(15);
   x_vendor_contact_id number;
begin
   if form_name = 'POXPOEPO'
   and block_name = 'PO_APPROVE'
   and event_name ='WHEN-NEW-BLOCK-INSTANCE' then
      x_vendor_site_id := to_number(name_in('PO_HEADERS.VENDOR_SITE_ID'));

		  begin
         select fax_area_code || fax,
         			  supplier_notif_method
         into   x_fax_number,
         			  x_supplier_notif_method
         from   ap.ap_supplier_sites_all
         where  vendor_site_id = x_vendor_site_id
         and    supplier_notif_method = 'FAX';
		  exception
         when others then
            x_fax_number := null;
            x_supplier_notif_method := null;
		  end;
		  
		  if nvl(x_supplier_notif_method,'zzz') != 'FAX' then
		  	 copy('', 'PO_APPROVE.FAX_NUMBER');
		  else		  
		     if x_fax_number is null then
		  	    x_vendor_contact_id := to_number(name_in('PO_HEADERS.VENDOR_CONTACT_ID'));
		  	 
            begin
               select fax_area_code || fax
               into   x_fax_number
               from   ap.ap_supplier_contacts
		           where  vendor_contact_id = x_vendor_contact_id;
            exception
		  	       when others then
		  	          x_fax_number := null;
		        end;
		     end if;	

         copy(x_fax_number, 'PO_APPROVE.FAX_NUMBER');
      end if;
   end if;
end;

/* Added for QC 4002 by Pratik(PM508N) on 06-SEP-2013 start */
declare
   lv_line_num number;
   lv_line_exst number;
   lv_max_line_num number;
   lv_cnt_line_num number;
   lv_header_id number;
   lv_po po_headers_all.segment1%type;
begin
   if  form_name =  'POXPOEPO' 
   and block_name = 'PO_LINES' 
   --and event_name = 'WHEN-CREATE-RECORD'
   and event_name = 'WHEN-NEW-RECORD-INSTANCE'
   and name_in('SYSTEM.RECORD_STATUS') = 'NEW'
   then
      begin
         select po_header_id
         into   lv_header_id
         from   po_headers_all
         where  segment1 = lv_po;
      exception
         when no_data_found then
            lv_header_id := 0;
         when others then
            fnd_message.set_string('Error in deriving the Header number for order number: ' || lv_po);
            fnd_message.show;
            raise form_trigger_failure;
      end;

      if nvl(lv_header_id, 0) <> 0 then
         begin
            select max(line_num)
            into   lv_max_line_num
            from   po_lines_all
            where  po_header_id = lv_header_id;
         exception
            when others then
               fnd_message.set_string('Error in deriving the max line number for PO: ' || lv_po);
               fnd_message.show;
               raise form_trigger_failure;
         end;

         begin
            select count(line_num)
            into   lv_cnt_line_num
            from   po_lines_all
            where  po_header_id = lv_header_id;
         exception
            when others then
               fnd_message.set_string('Error in deriving the count of line numbers for PO: ' || lv_po);
               fnd_message.show;
               raise form_trigger_failure;
         end;

         if nvl(lv_max_line_num, 0) <> nvl(lv_cnt_line_num, 0) then
            lv_line_num := 1;

            loop
               begin
                  select 1
                  into   lv_line_exst
                  from   po_lines_all
                  where  po_header_id = lv_header_id and line_num = lv_line_num;
               exception
                  when others then
                     lv_line_exst := 0;
               end;

               exit when lv_line_exst = 0;

               lv_line_num := lv_line_num + 1;
            end loop;
         end if;

         if lv_line_num <> 0 then
            copy(lv_line_num, 'PO_LINES.LINE_NUM');
         end if;
      end if;
   end if;
exception
   when others then
      raise form_trigger_failure;
end;
/* Added for QC 4002 by Pratik(PM508N) on 06-SEP-2013 end */

--R2.119 Changes  
cust_nhr2_119(event_name);
--R2.119 changes

end event; 

BEGIN
  --
  -- You should consider updating the version information listed below as you
  -- make any customizations to this library. This information will be 
  -- displayed in the 'About Oracle Applications' window in the Forms PL/SQL
  -- section. Only change the revision, date and time sections of this string.
  --
  fdrcsid('$Header: CUSTOM.pld 2008.8.04 2008/08/04 00:00:00 pkm ship $'); 

end custom;
