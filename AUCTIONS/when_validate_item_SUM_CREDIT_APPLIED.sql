BEGIN
	IF :CREDIT_OVERRIDE.SUM_CREDIT_APPLIED>:CWARCCPM.ORDER_TOTAL THEN
		FND_MESSAGE.SET_NAME('CCWAR','CCW_SUM_CREDIT_APPLIED_CHECK');
    FND_MESSAGE.ERROR; 
    RAISE form_trigger_failure;	
	END IF;
END;