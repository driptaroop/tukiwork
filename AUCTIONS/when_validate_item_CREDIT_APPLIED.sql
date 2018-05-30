DECLARE
--	btn NUMBER := 0;
BEGIN
	IF :CREDIT_OVERRIDE.CREDIT_APPLIED > :CREDIT_OVERRIDE.CREDIT_AVAILABLE THEN
			FND_MESSAGE.SET_NAME('CCWAR','CCW_CREDIT_APPLIED_CHECK');
      FND_MESSAGE.ERROR; 
      RAISE FORM_TRIGGER_FAILURE;
	END IF;	
	
	IF :CREDIT_OVERRIDE.CREDIT_APPLIED <> GET_ITEM_PROPERTY('CREDIT_OVERRIDE.CREDIT_APPLIED',DATABASE_VALUE) THEN		
		:CREDIT_OVERRIDE.OVERRIDE_FLAG := 'Y';
	END IF;
END;