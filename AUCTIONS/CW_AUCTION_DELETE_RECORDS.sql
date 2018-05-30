/***************THIS PROCEDURE WILL DELETE THE RECORDS FROM POT_PAID_RECEIPT TABLE AND COLNTROL TABLE IF USER CLOSES THE ZOOM FORM****************/

PROCEDURE CW_AUCTION_DELETE_RECORDS IS
	l_cnt_n NUMBER :=0;
	l_cnt_n_p NUMBER :=0;
BEGIN
	IF :PARAMETER.AUCTION_ORDER = 'Y' THEN
		SELECT COUNT(1)
		INTO   l_cnt_n
		FROM	 CW_AUC_RCPT_CM_APPL_CTRL
		WHERE	 CW_RECEIPT_ID   = :CWARCCPM.CW_RECEIPT_ID
					 AND STATUS_CODE = 'X';
		SELECT COUNT(1)
		INTO   l_cnt_n_p
		FROM	 CW_AUC_RCPT_CM_APPL_CTRL
		WHERE	 CW_RECEIPT_ID   = :CWARCCPM.CW_RECEIPT_ID
					 AND STATUS_CODE = 'P'
					 AND PHASE_CODE = 'SUBMIT GCS APPROVAL';
		
		IF l_cnt_n>0 OR l_cnt_n_p>0 THEN
		  DELETE FROM CW_AUC_RCPT_CM_APPL_CTRL
		  WHERE  CW_RECEIPT_ID = :CWARCCPM.CW_RECEIPT_ID;
		  
		  DELETE FROM CW_AR_CC_POST_PAID_RECEIPTS
		  WHERE  CW_RECEIPT_ID = :CWARCCPM.CW_RECEIPT_ID;
		  
		  COMMIT;
		END IF;
	END IF;
END;