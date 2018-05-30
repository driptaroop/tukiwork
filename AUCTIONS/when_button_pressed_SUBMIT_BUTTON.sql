DECLARE
	cursor curs is
	select * from CW_AUC_RCPT_CM_APPL_CTRL 
	where CW_RECEIPT_ID =:CWARCCPM.CW_RECEIPT_ID;
begin
	CW_AUCTION_TIMEOUT;
	CW_AUCTION_LOCK;
	IF :AUC_STATUS IN ('N','E') THEN 
	/*************Checking if total_credit_appiled is <= order total*********/
		IF :CREDIT_OVERRIDE.SUM_CREDIT_APPLIED>:CWARCCPM.ORDER_TOTAL THEN
			FND_MESSAGE.SET_NAME('CCWAR','CCW_SUM_CREDIT_APPLIED_CHECK');
    	FND_MESSAGE.ERROR; 
    	RAISE form_trigger_failure;	
		END IF;
	/***********Net Auth Amount calculation**********/
	:CWARCCPM.CREDIT_APPLIED := :CREDIT_OVERRIDE.SUM_CREDIT_APPLIED;
		IF 		:CWARCCPM.CREDIT_APPLIED = 0 THEN
					:CWARCCPM.CAL_NET_AMOUNT := :CWARCCPM.ORDER_TOTAL ;
					:PARAMETER.NET_AUTH_AMOUNT := 'Y';
		ELSIF :CWARCCPM.CREDIT_APPLIED = :CWARCCPM.ORDER_TOTAL THEN
					:CWARCCPM.CAL_NET_AMOUNT := 0 ;
					:PARAMETER.NET_AUTH_AMOUNT := 'N';
		ELSE
					:CWARCCPM.CAL_NET_AMOUNT := :CWARCCPM.ORDER_TOTAL - :CWARCCPM.CREDIT_APPLIED;
					:PARAMETER.NET_AUTH_AMOUNT := 'Y';
		END IF;
	save_record;		
	/*	IF :CWARCCPM.CAL_NET_AMOUNT=0 THEN
			--fnd_message.debug('net auth amt after override : '||:CWARCCPM.CAL_NET_AMOUNT);
			:PARAMETER.NET_AUTH_AMOUNT := 'N';
		END IF;*/
	/***********updating base table****************/
		/*UPDATE CW_AR_CC_POST_PAID_RECEIPTS
		SET
			RECEIPT_AMOUNT = :CWARCCPM.CAL_NET_AMOUNT,
			ATTRIBUTE4     = :CWARCCPM.CREDIT_APPLIED,
			ATTRIBUTE7     = :CREDIT_OVERRIDE.SUM_CREDIT_AVAILABLE
		WHERE cw_receipt_id=:CWARCCPM.CW_RECEIPT_ID;*/
		:CWARCCPM.ATTRIBUTE4     := :CWARCCPM.CREDIT_APPLIED;
	  :CWARCCPM.ATTRIBUTE7     := :CREDIT_OVERRIDE.SUM_CREDIT_AVAILABLE;
		--commit;
	--save_record;
	/*********** updating Control table***********/				
		FOR i IN curs
		LOOP
		      UPDATE   CW_AUC_RCPT_CM_APPL_CTRL
		      SET   AMT_OFFSET = CREDIT_APPLIED;
		      --OVERRIDE_FLAG = 'Y';	      			      				
		      EXIT WHEN curs%NOTFOUND;
		END LOOP;
		
		/*FOR i IN curs
   	LOOP
   			IF i.AMT_OFFSET =0 THEN
   				UPDATE   CW_AUC_RCPT_CM_APPL_CTRL
         	SET      STATUS_DESC = 'Unused',
         					 PHASE_CODE  = 'Unused';
        	COMMIT;
   			END IF;
		EXIT WHEN curs%NOTFOUND;
    END LOOP;*/

			
		save_record;	
		ELSE
			NULL;
	END IF;
			
	hide_window('CREDIT_OVERRIDE');
	go_block('CWARCCPM');
end;	