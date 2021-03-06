PROCEDURE ACTION_NEW_RECORD 
IS
  l_label_s VARCHAR2(60):='GCS &Approval';
  l_phase_code VARCHAR2(50);
	l_api_out VARCHAR2(1000);
  /*TYPE master_rec_type IS RECORD(
        child_rec       cw_ar_cc_post_paid_receipts_v%ROWTYPE,
        payee_id        VARCHAR2(30),
        merchant_id     VARCHAR2(30),
        method_id       NUMBER,
        org_id          NUMBER,
        app_id          NUMBER
        );*/

	l_receipt_rec CW_AR_CC_RECEIPT_PKG.master_rec_type;
	l_status   VARCHAR2(1);
	l_approval_msg  VARCHAR2(100);
	l_ccas_rec    fnd_lookup_values%ROWTYPE;
	l_status_code VARCHAR2(10);
	l_phase_code_e  VARCHAR2(100);
	l_count_n    NUMBER;

  
BEGIN
--    fnd_message.debug('NEW RECORD INSTANCE '||:SYSTEM.FORM_STATUS||' - STATUS:'||:CWARCCPM.STATUS||'-'||:SYSTEM.CURSOR_BLOCK
--       ||'-'||:STATUS||'-'||ROUND(sysdate - :creation_date, 2));
		IF :PARAMETER.AUCTION_ORDER = 'Y' THEN
	    BEGIN
		    SELECT count(1)
		    INTO   l_count_n
		    FROM   CW_AUC_RCPT_CM_APPL_CTRL
		    WHERE  CW_RECEIPT_ID = :CWARCCPM.CW_RECEIPT_ID
		    			 AND STATUS_CODE = 'E'
		    			 AND PHASE_CODE IN ('CC DECLINED','GCS VALIDATION FAILED');
	    EXCEPTION
	    	WHEN OTHERS THEN
	    		FND_MESSAGE.DEBUG('ERROR IN ACTION_NEW_RECORD');
	    END;
	  END IF;
	

		IF :AUC_STATUS NOT IN ('N','E') THEN
		SET_BLOCK_PROPERTY ('CREDIT_OVERRIDE', INSERT_ALLOWED, PROPERTY_FALSE);
		APP_ITEM_PROPERTY.SET_PROPERTY('CREDIT_OVERRIDE.CREDIT_APPLIED',INSERT_ALLOWED, PROPERTY_FALSE);
		APP_ITEM_PROPERTY.SET_PROPERTY('CREDIT_OVERRIDE.CREDIT_APPLIED',ENABLED,PROPERTY_FALSE);
		END IF;
		
		IF :AUC_STATUS = 'E' AND l_count_n>0 THEN
			SET_BLOCK_PROPERTY ('CREDIT_OVERRIDE', INSERT_ALLOWED, PROPERTY_FALSE);
		  APP_ITEM_PROPERTY.SET_PROPERTY('CREDIT_OVERRIDE.CREDIT_APPLIED',INSERT_ALLOWED, PROPERTY_FALSE);
		  APP_ITEM_PROPERTY.SET_PROPERTY('CREDIT_OVERRIDE.CREDIT_APPLIED',ENABLED,PROPERTY_FALSE);
		END IF;	
		
	/*	IF :AUC_STATUS != 'N' AND :CWARCCPM.CAL_NET_AMOUNT=0.00 THEN
				APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_NUMBER',ENABLED,PROPERTY_FALSE);
    		APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.EXPIRY_DATE',ENABLED,PROPERTY_FALSE);
        APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CVV2',ENABLED,PROPERTY_FALSE);
        APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_HOLDER_NAME',ENABLED,PROPERTY_FALSE);
        APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ZIP',ENABLED,PROPERTY_FALSE);
        APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.COMMENTS',ENABLED,PROPERTY_FALSE);
				APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_NUMBER',UPDATE_ALLOWED,PROPERTY_OFF);
    		APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.EXPIRY_DATE',UPDATE_ALLOWED,PROPERTY_OFF);
        APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CVV2',UPDATE_ALLOWED,PROPERTY_OFF);
        APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_HOLDER_NAME',UPDATE_ALLOWED,PROPERTY_OFF);
        APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ZIP',UPDATE_ALLOWED,PROPERTY_OFF);
        APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.COMMENTS',UPDATE_ALLOWED,PROPERTY_OFF);
		END IF;*/
		
		IF :CWARCCPM.CM_BALANCE = 0.00 THEN
			
			:PARAMETER.VIEW_OVERRIDE:='N';
		END IF;

  IF :STATUS IN ('N','E') OR :AUC_STATUS IN ('N','E') THEN
         IF ROUND(sysdate - :CWARCCPM.creation_date, 2)    > 3 THEN
           --SET_RECORD_PROPERTY(:SYSTEM.CURSOR_RECORD,:SYSTEM.CURSOR_BLOCK,UPDATE_ALLOWED,PROPERTY_FALSE); 
           SET_BLOCK_PROPERTY(:SYSTEM.CURSOR_BLOCK,UPDATE_ALLOWED,PROPERTY_FALSE); 
           APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.BTN_ACTION',ENABLED,PROPERTY_FALSE);
         ELSE
           APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.BTN_ACTION',ENABLED,PROPERTY_TRUE); 
           --SET_RECORD_PROPERTY(:SYSTEM.CURSOR_RECORD,:SYSTEM.CURSOR_BLOCK,UPDATE_ALLOWED,PROPERTY_TRUE);
           SET_BLOCK_PROPERTY(:SYSTEM.CURSOR_BLOCK,UPDATE_ALLOWED,PROPERTY_TRUE);  
           --SET_RECORD_PROPERTY(:SYSTEM.CURSOR_RECORD,:SYSTEM.CURSOR_BLOCK, STATUS, CHANGED_STATUS);
         END IF;
          APP_MENU.SET_PROP('EDIT.DELETE', ENABLED, PROPERTY_ON);
          --SET_RECORD_PROPERTY(:SYSTEM.CURSOR_RECORD,:SYSTEM.CURSOR_BLOCK,DELETE_ALLOWED,PROPERTY_TRUE); -- MHN added as per PCI Data Encryption Change
    
             -- fnd_message.set_string('NEW RECORD INSTANCE IN N, E:'||:SYSTEM.FORM_STATUS||' - STATUS:'||:CWARCCPM.STATUS||'-'||:SYSTEM.CURSOR_BLOCK||'-'||:STATUS);
             -- fnd_message.show;
      
        IF :PARAMETER.AUCTION_ORDER = 'Y' THEN
                /********ADDED ON 17_7_2014(START) **************/
                

                IF :PARAMETER.VIEW_OVERRIDE='N' THEN
                	--FND_MESSAGE.DEBUG('WHEN STATUS IS N/E');
                    				APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.VIEW_OVERRIDE',ENABLED,PROPERTY_FALSE);
                    				
                END IF;
                IF :PARAMETER.NET_AUTH_AMOUNT='N' THEN
                						APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ACCOUNT_NUMBER',UPDATE_ALLOWED,PROPERTY_OFF);
                						APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_NUMBER',ENABLED,PROPERTY_FALSE);
                        		APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.EXPIRY_DATE',ENABLED,PROPERTY_FALSE);
                            APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CVV2',ENABLED,PROPERTY_FALSE);
                            APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_HOLDER_NAME',ENABLED,PROPERTY_FALSE);
                            APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ZIP',ENABLED,PROPERTY_FALSE);
                            APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.COMMENTS',ENABLED,PROPERTY_FALSE);
                						APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_NUMBER',UPDATE_ALLOWED,PROPERTY_OFF);
                        		APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.EXPIRY_DATE',UPDATE_ALLOWED,PROPERTY_OFF);
                            APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CVV2',UPDATE_ALLOWED,PROPERTY_OFF);
                            APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_HOLDER_NAME',UPDATE_ALLOWED,PROPERTY_OFF);
                            APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ZIP',UPDATE_ALLOWED,PROPERTY_OFF);
                            APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.COMMENTS',UPDATE_ALLOWED,PROPERTY_OFF);
                ELSE
                						
                        		
                 
                /********ADDED ON 17_7_2014(END) **************/        
                        
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ACCOUNT_NUMBER',UPDATE_ALLOWED,PROPERTY_OFF);
                    --    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.RECEIPT_DATE',UPDATE_ALLOWED,PROPERTY_ON);
                    --        APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.RECEIPT_AMOUNT',UPDATE_ALLOWED,PROPERTY_ON);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_NUMBER',UPDATE_ALLOWED,PROPERTY_ON);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_NUMBER',INSERT_ALLOWED,PROPERTY_ON);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_NUMBER',REQUIRED,PROPERTY_ON);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_NUMBER',CONCEAL_DATA,PROPERTY_OFF);
                    SET_ITEM_PROPERTY('CWARCCPM.CARD_NUMBER',NAVIGABLE,property_TRUE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.EXPIRY_DATE',UPDATE_ALLOWED,PROPERTY_ON);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.EXPIRY_DATE',INSERT_ALLOWED,PROPERTY_ON);
                    SET_ITEM_PROPERTY('CWARCCPM.EXPIRY_DATE',NAVIGABLE,property_TRUE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.EXPIRY_DATE',REQUIRED,PROPERTY_ON);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CVV2',UPDATE_ALLOWED,PROPERTY_ON);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CVV2',INSERT_ALLOWED,PROPERTY_ON);
                    SET_ITEM_PROPERTY('CWARCCPM.CVV2',NAVIGABLE,property_TRUE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CVV2',REQUIRED,PROPERTY_ON);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_HOLDER_NAME',UPDATE_ALLOWED,PROPERTY_ON);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_HOLDER_NAME',INSERT_ALLOWED,PROPERTY_ON);
                    SET_ITEM_PROPERTY('CWARCCPM.CARD_HOLDER_NAME',NAVIGABLE,property_TRUE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_HOLDER_NAME',REQUIRED,PROPERTY_ON);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ZIP',UPDATE_ALLOWED,PROPERTY_ON);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ZIP',INSERT_ALLOWED,PROPERTY_ON);
                    SET_ITEM_PROPERTY('CWARCCPM.ZIP',NAVIGABLE,property_TRUE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ZIP',REQUIRED,PROPERTY_ON);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.COMMENTS',UPDATE_ALLOWED,PROPERTY_ON);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.COMMENTS',INSERT_ALLOWED,PROPERTY_ON);
                    SET_ITEM_PROPERTY('CWARCCPM.COMMENTS',NAVIGABLE,property_TRUE);

                END IF;
                    
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.RECEIPT_AMOUNT',VISIBLE,PROPERTY_FALSE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ORDER_TOTAL',VISIBLE,PROPERTY_TRUE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CM_BALANCE',VISIBLE,PROPERTY_TRUE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CAL_NET_AMOUNT',VISIBLE,PROPERTY_TRUE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.AUC_STATUS',VISIBLE,PROPERTY_TRUE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.STATUS',VISIBLE,PROPERTY_FALSE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.VIEW_OVERRIDE',VISIBLE,PROPERTY_TRUE); 
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CREDIT_APPLIED',VISIBLE,PROPERTY_TRUE);
        ELSE
        
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ACCOUNT_NUMBER',UPDATE_ALLOWED,PROPERTY_ON);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ACCOUNT_NUMBER',REQUIRED,PROPERTY_ON);
                    --    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.RECEIPT_DATE',UPDATE_ALLOWED,PROPERTY_ON);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.RECEIPT_AMOUNT',UPDATE_ALLOWED,PROPERTY_ON);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.RECEIPT_AMOUNT',REQUIRED,PROPERTY_ON);
                    --        APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.RECEIPT_AMOUNT',VISIBLE,PROPERTY_FALSE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_NUMBER',UPDATE_ALLOWED,PROPERTY_ON);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.EXPIRY_DATE',UPDATE_ALLOWED,PROPERTY_ON);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CVV2',UPDATE_ALLOWED,PROPERTY_ON);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_HOLDER_NAME',UPDATE_ALLOWED,PROPERTY_ON);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ZIP',UPDATE_ALLOWED,PROPERTY_ON);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_NUMBER',CONCEAL_DATA,PROPERTY_OFF);    
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CVV2',REQUIRED,PROPERTY_ON);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.COMMENTS',UPDATE_ALLOWED,PROPERTY_ON);
                    --    fnd_message.set_string('AFTER SETTING THE DELETE PROPERTY');
                    --    fnd_message.show;
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_NUMBER',REQUIRED,PROPERTY_ON);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.EXPIRY_DATE',REQUIRED,PROPERTY_ON);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_HOLDER_NAME',REQUIRED,PROPERTY_ON);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ZIP',REQUIRED,PROPERTY_ON);
                    
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.RECEIPT_AMOUNT',VISIBLE,PROPERTY_TRUE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ORDER_TOTAL',VISIBLE,PROPERTY_FALSE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CM_BALANCE',VISIBLE,PROPERTY_FALSE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CAL_NET_AMOUNT',VISIBLE,PROPERTY_FALSE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.AUC_STATUS',VISIBLE,PROPERTY_FALSE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.STATUS',VISIBLE,PROPERTY_TRUE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.VIEW_OVERRIDE',VISIBLE,PROPERTY_FALSE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CREDIT_APPLIED',VISIBLE,PROPERTY_FALSE);
          END IF;  
 
     ELSE
 
                 IF :PARAMETER.AUCTION_ORDER = 'Y' THEN
                     /********ADDED ON 17_7_2014(START) **************/
		                /*IF :PARAMETER.VIEW_OVERRIDE='N' THEN
		                	--FND_MESSAGE.DEBUG('WHEN STATUS IS NOT N/E');
		                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.VIEW_OVERRIDE',ENABLED,PROPERTY_FALSE);
		                END IF;*/
		                IF :PARAMETER.NET_AUTH_AMOUNT='N' THEN
		                        APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_NUMBER',UPDATE_ALLOWED,PROPERTY_OFF);
                        		APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.EXPIRY_DATE',UPDATE_ALLOWED,PROPERTY_OFF);
                            APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CVV2',UPDATE_ALLOWED,PROPERTY_OFF);
                            APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_HOLDER_NAME',UPDATE_ALLOWED,PROPERTY_OFF);
                            APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ZIP',UPDATE_ALLOWED,PROPERTY_OFF);
                            APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.COMMENTS',UPDATE_ALLOWED,PROPERTY_OFF);
                        		APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_NUMBER',ENABLED,PROPERTY_FALSE);
                        		APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.EXPIRY_DATE',ENABLED,PROPERTY_FALSE);
                            APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CVV2',ENABLED,PROPERTY_FALSE);
                            APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_HOLDER_NAME',ENABLED,PROPERTY_FALSE);
                            APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ZIP',ENABLED,PROPERTY_FALSE);
                            APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.COMMENTS',ENABLED,PROPERTY_FALSE);
		                 ELSE
                /********ADDED ON 17_7_2014(END) **************/    
         
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.BTN_ACTION',ENABLED,PROPERTY_TRUE);
                    --SET_RECORD_PROPERTY(:SYSTEM.CURSOR_RECORD,:SYSTEM.CURSOR_BLOCK,DELETE_ALLOWED,PROPERTY_FALSE); -- MHN added 
                    APP_MENU.SET_PROP('EDIT.DELETE', ENABLED, PROPERTY_OFF);
                    --SET_RECORD_PROPERTY(:SYSTEM.CURSOR_RECORD,:SYSTEM.CURSOR_BLOCK,UPDATE_ALLOWED,PROPERTY_FALSE);
                    SET_BLOCK_PROPERTY(:SYSTEM.CURSOR_BLOCK,UPDATE_ALLOWED,PROPERTY_FALSE); 
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ACCOUNT_NUMBER',UPDATE_ALLOWED,PROPERTY_OFF);
                    --    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.RECEIPT_DATE',UPDATE_ALLOWED,PROPERTY_OFF);
                    --APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.RECEIPT_AMOUNT',UPDATE_ALLOWED,PROPERTY_OFF);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_NUMBER',UPDATE_ALLOWED,PROPERTY_OFF);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.EXPIRY_DATE',UPDATE_ALLOWED,PROPERTY_OFF);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CVV2',UPDATE_ALLOWED,PROPERTY_OFF);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_HOLDER_NAME',UPDATE_ALLOWED,PROPERTY_OFF);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ZIP',UPDATE_ALLOWED,PROPERTY_OFF);
                    --    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_NUMBER',CONCEAL_DATA,PROPERTY_ON);--MHN added as per PCI Data Encryption Change
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CVV2',REQUIRED,PROPERTY_OFF);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.COMMENTS',UPDATE_ALLOWED,PROPERTY_OFF);
		                END IF; 
		                 
		                 
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ORDER_TOTAL',VISIBLE,PROPERTY_TRUE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CM_BALANCE',VISIBLE,PROPERTY_TRUE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CAL_NET_AMOUNT',VISIBLE,PROPERTY_TRUE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CREDIT_APPLIED',VISIBLE,PROPERTY_TRUE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.AUC_STATUS',VISIBLE,PROPERTY_TRUE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.STATUS',VISIBLE,PROPERTY_FALSE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.RECEIPT_AMOUNT',VISIBLE,PROPERTY_FALSE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ORDER_TOTAL',UPDATE_ALLOWED,PROPERTY_OFF);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CM_BALANCE',UPDATE_ALLOWED,PROPERTY_OFF);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CAL_NET_AMOUNT',UPDATE_ALLOWED,PROPERTY_OFF);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.AUC_STATUS',UPDATE_ALLOWED,PROPERTY_OFF);
                    
            
        ELSE
        					   
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.BTN_ACTION',ENABLED,PROPERTY_TRUE);
                    --SET_RECORD_PROPERTY(:SYSTEM.CURSOR_RECORD,:SYSTEM.CURSOR_BLOCK,DELETE_ALLOWED,PROPERTY_FALSE); -- MHN added 
                    APP_MENU.SET_PROP('EDIT.DELETE', ENABLED, PROPERTY_OFF);
                    --SET_RECORD_PROPERTY(:SYSTEM.CURSOR_RECORD,:SYSTEM.CURSOR_BLOCK,UPDATE_ALLOWED,PROPERTY_FALSE);
                    SET_BLOCK_PROPERTY(:SYSTEM.CURSOR_BLOCK,UPDATE_ALLOWED,PROPERTY_FALSE); 
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ACCOUNT_NUMBER',UPDATE_ALLOWED,PROPERTY_OFF);
                    --    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.RECEIPT_DATE',UPDATE_ALLOWED,PROPERTY_OFF);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.RECEIPT_AMOUNT',UPDATE_ALLOWED,PROPERTY_OFF);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_NUMBER',UPDATE_ALLOWED,PROPERTY_OFF);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.EXPIRY_DATE',UPDATE_ALLOWED,PROPERTY_OFF);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CVV2',UPDATE_ALLOWED,PROPERTY_OFF);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_HOLDER_NAME',UPDATE_ALLOWED,PROPERTY_OFF);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ZIP',UPDATE_ALLOWED,PROPERTY_OFF);
                    --    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_NUMBER',CONCEAL_DATA,PROPERTY_ON);--MHN added as per PCI Data Encryption Change
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CVV2',REQUIRED,PROPERTY_OFF);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.COMMENTS',UPDATE_ALLOWED,PROPERTY_OFF);
                    
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ORDER_TOTAL',VISIBLE,PROPERTY_FALSE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CM_BALANCE',VISIBLE,PROPERTY_FALSE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CAL_NET_AMOUNT',VISIBLE,PROPERTY_FALSE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CREDIT_APPLIED',VISIBLE,PROPERTY_FALSE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.AUC_STATUS',VISIBLE,PROPERTY_FALSE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.STATUS',VISIBLE,PROPERTY_TRUE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.RECEIPT_AMOUNT',VISIBLE,PROPERTY_TRUE);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.STATUS',UPDATE_ALLOWED,PROPERTY_OFF);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.RECEIPT_AMOUNT',UPDATE_ALLOWED,PROPERTY_OFF);
                    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.VIEW_OVERRIDE',VISIBLE,PROPERTY_FALSE);
                    
    --    fnd_message.set_string('AFTER SETTING THE DELETE PROPERTY');
    --    fnd_message.show;
            END IF;
    
--    fnd_message.set_string('AFTER SETTING THE DELETE PROPERTY');
--    fnd_message.show;
END IF;


		

IF (:SOURCE_CODE = 'ONT')
THEN
    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ACCOUNT_NUMBER',UPDATE_ALLOWED,PROPERTY_OFF);
    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.RECEIPT_DATE',UPDATE_ALLOWED,PROPERTY_OFF);
    APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.RECEIPT_AMOUNT',UPDATE_ALLOWED,PROPERTY_OFF);
END IF;    
--
APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.BTN_ACTION',LABEL,l_label_s);        

IF :PARAMETER.AUCTION_ORDER = 'N' THEN
	IF :SYSTEM.FORM_STATUS = 'QUERY' AND :CWARCCPM.CW_RECEIPT_ID IS NOT NULL
	THEN 
	    IF :STATUS IN ('N','E') 
	    THEN
	      l_label_s := 'GCS &Approval';
	    ELSIF :STATUS = 'X'
	    THEN    
	      l_label_s := '&AutoCreate Receipt';
	    ELSIF :STATUS = 'D'
	    THEN    
	      l_label_s := 'DebitMemo &Applications';
	    ELSIF :STATUS = 'R'
	    THEN    
	      l_label_s := 'Receipt &Applications';        
	    END IF;
	  APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.BTN_ACTION',LABEL,l_label_s);    
	END IF;

ELSE -- auction_order = 'Y'
				

	IF :SYSTEM.FORM_STATUS = 'QUERY' AND :CWARCCPM.CW_RECEIPT_ID IS NOT NULL
	   THEN
	      IF :AUC_STATUS IN ('N', 'E')
	      THEN
	         l_label_s := 'GCS &Approval';
	      /*ELSIF :AUC_STATUS = 'X'
	      THEN
	         l_label_s := '&AutoCreate Receipt';
					 :PARAMETER.RECEIPT_CREATION := 'Y';*/
	         
	      ELSIF :AUC_STATUS = 'D'
	      THEN
	         l_label_s := 'DebitMemo &Applications';
	      ELSIF :AUC_STATUS IN ('R','X')
	      	THEN
	      		l_label_s := 'Receipt &Applications';
	          :PARAMETER.RECEIPT_APPLICATION := 'Y';
	      /*ELSIF :AUC_STATUS = 'R'
	      THEN
	         l_label_s := 'Receipt &Applications';
	         :PARAMETER.RECEIPT_APPLICATION := 'Y';
	         
	         BEGIN
	         SELECT STATUS, APPROVAL_MESSAGE
	         INTO		l_status,l_approval_msg
	         FROM   CW_AR_CC_POST_PAID_RECEIPTS
	         WHERE  CW_RECEIPT_ID = :CWARCCPM.CW_RECEIPT_ID;
	         EXCEPTION WHEN OTHERS THEN
	         	fnd_message.debug('Getting error for receipt creation');
	         END;
	         
	         IF l_status = 'R' AND l_approval_msg = 'Receipt Creation failed for Net Auth Amount' THEN
	         		:CWARCCPM.AUC_STATUS := 'X';
	         		fnd_message.debug('setting value');
	         END IF;*/
	         
	      END IF;
	
	      APP_ITEM_PROPERTY.SET_PROPERTY ('CWARCCPM.BTN_ACTION',
	                                      LABEL,
	                                      l_label_s);
	   END IF;
	 END IF;
END;