PROCEDURE CW_AUCTION_LOCK IS

    l_wt_count NUMBER := 0;
    l_return_alert_n  NUMBER:=0;
    l_cw_receipt_id NUMBER;
    v_wt_flag      VARCHAR2(1);
    v_cm_flag      VARCHAR2(1);
    l_cm_count  NUMBER;
    ln_update_rowcnt NUMBER := 0;
    l_status      VARCHAR2(1); 
    l_cnt_n   		NUMBER;
    
		CURSOR CW_WT_RCPT IS
				SELECT acr.CASH_RECEIPT_ID
				FROM   ar_receipt_methods arm,
						 ar_cash_receipts_all acr,
						 ar_payment_schedules_all ps,
						 oe_order_headers_all oe
				WHERE                                                             
					       arm.NAME = 'AUCTION WIRE'
						AND acr.RECEIPT_METHOD_ID = arm.RECEIPT_METHOD_ID
						AND acr.PAY_FROM_CUSTOMER = oe.sold_to_org_id
						AND ps.CUSTOMER_SITE_USE_ID = acr.CUSTOMER_SITE_USE_ID
						AND ps.CASH_RECEIPT_ID = acr.CASH_RECEIPT_ID
						AND ps.CLASS = 'PMT'
						AND ps.STATUS = 'OP'
						AND ps.customer_id = oe.sold_to_org_id
						AND acr.status = 'UNAPP'
						AND oe.header_id= :PARAMETER.P_SOURCE_ID;
		
		 CURSOR CW_CM_MEMO IS  
					SELECT   ps.CUSTOMER_TRX_ID
		         FROM   ra_customer_trx_all rt,
		               ar_payment_schedules_all ps,
		               oe_order_headers_all oe,
		               RA_CUST_TRX_TYPES_ALL rta
					WHERE    
								 ps.customer_trx_id = rt.customer_trx_id
		               AND rta.CUST_TRX_TYPE_ID = rt.CUST_TRX_TYPE_ID
		               AND rta.name IN ('Auction Credit Memo')
		               AND ps.customer_id = rt.bill_to_customer_id
		               AND ps.CLASS = 'CM'
		               AND ps.status = 'OP'
		               AND rt.complete_flag = 'Y'
		               AND ps.customer_id = oe.sold_to_org_id
		               AND oe.header_id= :PARAMETER.P_SOURCE_ID;
    
BEGIN
    
		SELECT   COUNT ( * )
	   INTO   l_cnt_n
	   FROM   cw_ar_cc_post_paid_receipts
      WHERE   source_code = :PARAMETER.P_SOURCE_CODE AND SOURCE_ID=:PARAMETER.P_SOURCE_ID;

		IF l_cnt_n = 0 THEN 
			FOR CW_WT_RCPT_L in CW_WT_RCPT
			 LOOP
				  SELECT COUNT(1)
				  INTO l_wt_count 
     			FROM CW_AUC_RCPT_CM_APPL_CTRL 
     			WHERE STATUS_CODE = 'X'
     						AND WT_RECEIPT_ID = CW_WT_RCPT_L.CASH_RECEIPT_ID;
				  
				  IF l_wt_count>0 THEN
						v_wt_flag:='Y';
				  END IF;
				 
				  EXIT WHEN CW_WT_RCPT%NOTFOUND;
			 END LOOP;
			 
			 FOR CW_CM_MEMO_L IN CW_CM_MEMO
			 LOOP
            SELECT COUNT(1) 
            INTO l_cm_count
            FROM CW_AUC_RCPT_CM_APPL_CTRL 
            WHERE STATUS_CODE = 'X' 
            AND CUSTOMER_TRX_ID =CW_CM_MEMO_L.CUSTOMER_TRX_ID;
				  
				  IF l_wt_count>0 THEN
						v_cm_flag:='Y';
				  END IF;
				  
				  EXIT WHEN CW_CM_MEMO%NOTFOUND;
			 END LOOP;
			 
			 IF v_wt_flag ='Y' or v_cm_flag='Y'  THEN
			 		l_return_alert_n := SHOW_ALERT ('LOCK_MSG');
					 IF l_return_alert_n = ALERT_BUTTON1  THEN
						  EXIT_FORM(NO_VALIDATE);
					 END IF;
			 END IF;
	   END IF;

EXCEPTION
    WHEN OTHERS THEN
        FND_MESSAGE.DEBUG('Caught in exception while applying the Lock');
END;