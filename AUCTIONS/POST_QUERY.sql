DECLARE
	/*cursor curs is
	select * from CW_AUC_RCPT_CM_APPL_CTRL 
	where CW_RECEIPT_ID =:CWARCCPM.CW_RECEIPT_ID;*/
	--l_return_alert NUMBER :=0;
	--l_wire_transfer_balance NUMBER :=0;
BEGIN
	SELECT attribute4, attribute5, receipt_amount,attribute7
	INTO   :CWARCCPM.CREDIT_APPLIED, :CWARCCPM.ORDER_TOTAL, :CWARCCPM.CAL_NET_AMOUNT,:CWARCCPM.CM_BALANCE
	FROM   CW_AR_CC_POST_PAID_RECEIPTS
	WHERE  cw_receipt_id = :CWARCCPM.CW_RECEIPT_ID;
	
	
/*	SELECT acr.amount 
	INTO	 l_wire_transfer_balance
	FROM
	ar_receipt_methods arm,
	ar_cash_receipts_all acr,
	ar_payment_schedules_all ps,
	oe_order_headers_all oe,
	cw_ar_cc_post_paid_receipts cc
	where 1=1
	and arm.NAME='AUCTION WIRE'
	and acr.RECEIPT_METHOD_ID=arm.RECEIPT_METHOD_ID
	and ps.CUSTOMER_SITE_USE_ID=acr.CUSTOMER_SITE_USE_ID
	and ps.CLASS='PMT'
	and ps.STATUS='OP'
	and ps.customer_id = oe.sold_to_org_id
	and cc.status = 'N'
	and cc.applied_ps_id = -1
	and cc.source_id=oe.header_id 
	and cc.cw_receipt_id = :CWARCCPM.CW_RECEIPT_ID;
	
	IF l_wire_transfer_balance!=0 THEN
		l_return_alert:=SHOW_ALERT('POPUP_MSG');
	END IF;*/
	
	
	/*********** updating Control table***********/				
/*	FOR i IN curs
	LOOP
	      UPDATE   CW_AUC_RCPT_CM_APPL_CTRL
	      SET   AMT_OFFSET = CREDIT_AVAILABLE - CREDIT_APPLIED;
	      EXIT WHEN curs%NOTFOUND;
	END LOOP;
	COMMIT;*/
EXCEPTION
		WHEN OTHERS THEN
			fnd_message.debug('OTHERS exception');
END;