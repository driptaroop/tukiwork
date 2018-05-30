PROCEDURE DO_ACTION 
IS
  l_status_c         VARCHAR2(1);
  l_text_s           VARCHAR2(2000);
  l_appcode_s        VARCHAR2(80);
  l_receipt_id_n     NUMBER;
  l_number_n         NUMBER;
  l_tang_id_s        VARCHAR2(80);
  l_merchant_id_s    VARCHAR2(80);
  l_string_s           VARCHAR2(2000);
  l_function_s       VARCHAR2(2000);
  l_parameter_s      VARCHAR2(2000);
BEGIN
    IF :PARAMETER.AUCTION_ORDER = 'N' THEN
        IF  :SYSTEM.FORM_STATUS = 'QUERY'
        AND :CWARCCPM.CW_RECEIPT_ID      IS NOT NULL
        THEN    
            IF :CWARCCPM.STATUS IN ('D','R') AND :CWARCCPM.AR_RECEIPT_ID IS NOT NULL     THEN
                CW_AR_CC_RECEIPT_PKG.GET_FUNCTION_VALUES(:CWARCCPM.STATUS,:CWARCCPM.AR_RECEIPT_ID,l_function_s,l_parameter_s);
                  IF l_function_s IS NOT NULL         THEN
                     FND_FUNCTION.EXECUTE(l_function_s,'Y','N',l_parameter_s);
                  ELSE
                      FND_MESSAGE.DEBUG(l_parameter_s);
                  END IF;    
                  NULL;
              ELSIF :CWARCCPM.STATUS IN ('N','E','X')      THEN
                IF     :CWARCCPM.STATUS IN ('N','E')       THEN
                  IF (:trx_type = 'AUTHCAPTURE')       THEN
                      l_string_s := 'This credit card will be refunded for '||ltrim(to_char(:receipt_amount,'$999,999,990.00'))||', Do you want to proceed?';     
                  ELSIF (:trx_type = 'AUTHONLY')        THEN    
                      l_string_s := 'This credit card will be charged for '||ltrim(to_char(:receipt_amount,'$999,999,990.00'))||', Do you want to proceed?';                       
                  END IF;    
                    fnd_message.set_string(l_string_s);
                        l_number_n := fnd_message.question('Yes','No',NULL,NULL,1);
                END IF;    
            
                 IF     l_number_n = 1
                 OR  :CWARCCPM.STATUS    = 'X'
                THEN
            
                    CW_AR_CC_RECEIPT_PKG.CW_AR_CC_ACTION(
                            in_ref_n             => :CWARCCPM.cw_receipt_id,
                            --p_net_auth_amount	=> 0,
                            p_crd_card_num    => :card_number, -- MHN
                            p_exp_date        => :expiry_date, -- MHN
                            p_cvv2            => :cvv2,         -- MHN
                            p_blng_zip        => :zip,         -- MHN
                            p_card_hldr_name  => :card_holder_name,-- MHN
                        --    p_cust_account_id => :cust_account_id,
                              out_status_c         => l_status_c,
                              out_text_s           => l_text_s,
                        out_appcode_s        => l_appcode_s,
                              out_receipt_id_n     => l_receipt_id_n,
                              out_tang_id_s        => l_tang_id_s,
                              out_merchant_id_s => l_merchant_id_s);
                              --
                        :status           := l_status_c;
                        :approval_message := l_text_s;
                        :approval_code    := l_appcode_s;
                        :CWARCCPM.ar_receipt_id    := l_receipt_id_n;
                        :tangible_id      := l_tang_id_s;
                        :merchant_id      := l_merchant_id_s;
                        
                        IF :CWARCCPM.status IN ('X','R','D')
                        THEN
                          APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CVV2',REQUIRED,PROPERTY_OFF);
                          APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_NUMBER',REQUIRED,PROPERTY_OFF);
                          APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.EXPIRY_DATE',REQUIRED,PROPERTY_OFF);
                          APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ZIP',REQUIRED,PROPERTY_OFF);
                          APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_HOLDER_NAME',REQUIRED,PROPERTY_OFF);
                            :CVV2 := NULL;
                            :CARD_NUMBER := NULL;
                            :EXPIRY_DATE := NULL;
                            :ZIP         := NULL;
                            :CARD_HOLDER_NAME := NULL; 
                        END IF; 
                    SAVE_RECORD;                    
                    ACTION_NEW_RECORD;    
                END IF;    
              END IF;
      ELSE
          FND_MESSAGE.DEBUG('Please save the information');          
        END IF;    
    END IF;
    
   IF :PARAMETER.AUCTION_ORDER = 'Y' THEN
        IF  :SYSTEM.FORM_STATUS = 'QUERY'
        AND :CWARCCPM.CW_RECEIPT_ID      IS NOT NULL
        THEN    
            IF :AUC_STATUS IN ('R') AND :CWARCCPM.AR_RECEIPT_ID IS NOT NULL     THEN -- AUC_STATUS in place of STATUS and  'S' in place of 'D'
                /*CW_AR_CC_RECEIPT_PKG.GET_FUNCTION_VALUES(:AUC_STATUS,:CWARCCPM.AR_RECEIPT_ID,l_function_s,l_parameter_s);
                  IF l_function_s IS NOT NULL         THEN
                     FND_FUNCTION.EXECUTE(l_function_s,'Y','N',l_parameter_s);
                  ELSE
                      --FND_MESSAGE.DEBUG(l_parameter_s);
                  END IF;    */
                  --fnd_message.debug('before act new record when auc status is R');
                  ACTION_NEW_RECORD;    
              ELSIF :AUC_STATUS IN ('N','E','X')      THEN
                IF     :AUC_STATUS IN ('N','E')       THEN
                  IF (:trx_type = 'AUTHCAPTURE')       THEN
                      l_string_s := 'This credit card will be refunded for '||ltrim(to_char(:CAL_NET_AMOUNT,'$999,999,990.00'))||', Do you want to proceed?'; -- CAL_NET_AMOUNT in place of : receipt_amount   
                  ELSIF (:trx_type = 'AUTHONLY')        THEN    
                  		IF :CAL_NET_AMOUNT > 0 THEN
                      	l_string_s := 'This credit card will be charged for '||ltrim(to_char(:CAL_NET_AMOUNT,'$999,999,990.00'))||', Do you want to proceed?';                       
                  		ELSE 
                  			l_string_s := 'No GCS Authorization required. Do you want to proceed?';
                  		END IF;
                  END IF;    
                    fnd_message.set_string(l_string_s);
                        l_number_n := fnd_message.question('Yes','No',NULL,NULL,1);
                        --FND_MESSAGE.DEBUG(l_number_n);
                END IF;    
            
                 IF     l_number_n = 1
                 OR  :AUC_STATUS    = 'X'
                THEN
            
                    CW_AR_CC_RECEIPT_PKG.CW_AR_CC_ACTION_AUCTION(
                            in_ref_n             => :CWARCCPM.cw_receipt_id,
                            p_net_auth_amount	 => :CWARCCPM.CAL_NET_AMOUNT,
                            p_crd_card_num    => :card_number, -- MHN
                            p_exp_date        => :expiry_date, -- MHN
                            p_cvv2            => :cvv2,         -- MHN
                            p_blng_zip        => :zip,         -- MHN
                            p_card_hldr_name  => :card_holder_name,-- MHN
                            p_order_number    => :CWARCCPM.ORDER_NUMBER,
                        --    p_cust_account_id => :cust_account_id,
                              out_status_c         => l_status_c,
                              out_text_s           => l_text_s,
                              out_appcode_s        => l_appcode_s,
                              out_receipt_id_n     => l_receipt_id_n,
                              out_tang_id_s        => l_tang_id_s,
                              out_merchant_id_s => l_merchant_id_s);
                              --
                        :auc_status         := l_status_c;
                        :approval_message   := l_text_s;
                        :approval_code      := l_appcode_s;
                        :CWARCCPM.ar_receipt_id      := l_receipt_id_n;
                        :tangible_id        := l_tang_id_s;
                        :merchant_id        := l_merchant_id_s;
                        
                        IF :AUC_STATUS IN ('X','R','D')
                        THEN
                          APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CVV2',REQUIRED,PROPERTY_OFF);
                          APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_NUMBER',REQUIRED,PROPERTY_OFF);
                          APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.EXPIRY_DATE',REQUIRED,PROPERTY_OFF);
                          APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ZIP',REQUIRED,PROPERTY_OFF);
                          APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_HOLDER_NAME',REQUIRED,PROPERTY_OFF);
                        	APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_NUMBER',ENABLED,PROPERTY_FALSE);
                      		APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.EXPIRY_DATE',ENABLED,PROPERTY_FALSE);
                          APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CVV2',ENABLED,PROPERTY_FALSE);
                          APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.CARD_HOLDER_NAME',ENABLED,PROPERTY_FALSE);
                          APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.ZIP',ENABLED,PROPERTY_FALSE);
                          
                            :CVV2 := NULL;
                            :CARD_NUMBER := NULL;
                            :EXPIRY_DATE := NULL;
                            :ZIP         := NULL;
                            :CARD_HOLDER_NAME := NULL; 
                        END IF; 
                    SAVE_RECORD;                    
                    ACTION_NEW_RECORD;    
                 END IF; 
                 --FND_MESSAGE.DEBUG('AUC STATUS ' ||:AUC_STATUS);
              END IF;
      ELSE
          FND_MESSAGE.DEBUG('Please save the information');          
        END IF;    
    END IF;
    
END;