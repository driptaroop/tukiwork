PROCEDURE CW_OM_CC_ZOOM IS
                l_form_status		VARCHAR2(50):= NAME_IN('SYSTEM.FORM_STATUS');
                l_ordet_type_id		NUMBER:=NVL(TO_NUMBER(NAME_IN('ORDER.ORDER_TYPE_ID')),0);
                l_header_id_n		NUMBER:=NVL(TO_NUMBER(NAME_IN('ORDER.HEADER_ID')),0);
                l_total_n		NUMBER:=NVL(TO_NUMBER(NAME_IN('ORDER.TOTAL')),0);
                l_flag_c		VARCHAR2(1);
					 ln_order_type_count	NUMBER:=0;
					 l_payment_type      NUMBER:=0;
BEGIN
  	--FND_MESSAGE.DEBUG('Inside CW_OM_CC_ZOOM');
	IF l_form_status   <> 'QUERY'
  OR l_header_id_n   =  0
  OR l_ordet_type_id =  0
  THEN     
  		FND_MESSAGE.DEBUG('Please save the order information');
  ELSIF l_total_n  <= 0      
  THEN     
       FND_MESSAGE.DEBUG('Order total amount must be more than zero');
  ELSE
      BEGIN
				SELECT UPPER(SUBSTR(attribute4,1,1))
                                INTO   l_flag_c
                                FROM   oe_transaction_types
                                WHERE  transaction_type_id = l_ordet_type_id;
				EXCEPTION
					WHEN OTHERS THEN
						l_flag_c := NULL;
				END;
					
					-- Changes for Auctions project. If the order type is 'AUCTION ORDER' then pass the source code as AUC
					-- ---------------------------------------------------------------------------------------------------
					BEGIN
						SELECT   COUNT (1)
						INTO   ln_order_type_count
						FROM   oe_order_headers_all oeh, oe_transaction_types_tl ott
						WHERE       1 = 1
						AND oeh.header_id = l_header_id_n
						AND ott.TRANSACTION_TYPE_ID = oeh.ORDER_TYPE_ID
						AND EXISTS
						(SELECT   1
						FROM   fnd_flex_value_sets ffvs, fnd_flex_values_vl ffvv
						WHERE       ffvs.flex_value_set_id = ffvv.flex_value_set_id
						AND ffvs.flex_value_set_name = 'AUC_ORDER_TYPE'
						AND ENABLED_FLAG = 'Y'
						AND ( start_date_active IS NULL OR start_date_active <= TO_CHAR(SYSDATE,'DD-MON-YYYY' ))
						AND ( end_date_active IS NULL OR end_date_active >= TO_CHAR(SYSDATE,'DD-MON-YYYY') )
						AND ffvv.flex_value = ott.name);
					EXCEPTION
						WHEN OTHERS THEN
							ln_order_type_count := NULL;
					END;

					-- Changes for Auctions project. If the payment type is not 'Credit Card' then Zoom form will not open and error message will be shown
					-- ------------------------------------------------------------------------------------------------------------------------------------
					BEGIN
					SELECT COUNT(1)
					INTO   l_payment_type
					FROM   oe_order_headers_all
					WHERE  1=1
					AND    header_id  = l_header_id_n
					AND    ATTRIBUTE5 = 'Credit Card';
					EXCEPTION
						WHEN OTHERS THEN
							l_payment_type := NULL;
					END;

				  IF  l_flag_c =  'Y'
				  THEN 
							-- Changes for Auctions project. If the order type is 'AUCTION ORDER' then pass the source code as AUC
							-- ---------------------------------------------------------------------------------------------------
							IF ln_order_type_count > 0
							THEN
									IF l_payment_type = 0 THEN
										-- Changes for Auctions project. If the payment type is not 'Credit Card' then Zoom form will not open and error message will be shown
										-- ------------------------------------------------------------------------------------------------------------------------------------
										FND_MESSAGE.SET_NAME('CCWAR','CCW_PAYMENT_TYPE_CHECK');
										FND_MESSAGE.ERROR; 
										go_block('ORDER');
										--EXIT_FORM(NO_VALIDATE);
										--RAISE FORM_TRIGGER_FAILURE;
										ELSE
												--FND_MESSAGE.DEBUG('calling zoom with AUC');
										FND_FUNCTION.EXECUTE('CWARCCPM','Y','Y','P_SOURCE_CODE='||'AUC'||' P_SOURCE_ID='||l_header_id_n||' P_ORDER_AMOUNT='||l_total_n);
									END IF;
									
							ELSE
									FND_FUNCTION.EXECUTE('CWARCCPM','Y','Y','P_SOURCE_CODE='||'ONT'||' P_SOURCE_ID='||l_header_id_n||' P_ORDER_AMOUNT='||l_total_n);
							END IF;
						ELSE
					  FND_MESSAGE.DEBUG('This order type does not allow credit card pre payments');
				  END IF; 
    END IF; 
EXCEPTION
  	WHEN OTHERS THEN
       FND_MESSAGE.DEBUG(SQLERRM);
END;