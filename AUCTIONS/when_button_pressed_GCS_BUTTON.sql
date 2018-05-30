DECLARE
    cursor curs is
    select * from CW_AUC_RCPT_CM_APPL_CTRL 
    where CW_RECEIPT_ID =:CWARCCPM.CW_RECEIPT_ID;
    l_count_n NUMBER;
    
    l_label_s VARCHAR2(60):='GCS &Approval';
    l_phase_code VARCHAR2(50);
    l_api_out VARCHAR2(1000);
    l_approval_message VARCHAR2(100);
    l_receipt_rec CW_AR_CC_RECEIPT_PKG.master_rec_type;
    l_total_credit_balance NUMBER:=0;
    l_ccas_rec    fnd_lookup_values%ROWTYPE;
    l_total_wire_transfer_balance NUMBER:=0;
    l_receipt_failure_cnt        NUMBER:=0;
    l_cm_failure_cnt          NUMBER:=0;
    l_wt_failure_cnt          NUMBER:=0;
    l_count_null_n            NUMBER:=0;
    l_count_cc_auth_fail_n    NUMBER:=0;
BEGIN
    

    IF :PARAMETER.AUCTION_ORDER = 'Y'THEN
                CW_AUCTION_TIMEOUT;
                    CW_AUCTION_LOCK;
        --DO_ACTION;
        IF :PARAMETER.RECEIPT_APPLICATION='Y' THEN
                 --FND_MESSAGE.DEBUG('INSIDE credit APPLICATION');
                        BEGIN
                            SELECT COUNT(1) 
                                                        INTO l_receipt_failure_cnt 
                                                        FROM CW_AUC_RCPT_CM_APPL_CTRL 
                                                        WHERE PHASE_CODE = 'RECEIPT CREATION FAILED'
                                                                    AND cw_receipt_id = :CWARCCPM.CW_RECEIPT_ID;
                                                        SELECT COUNT(1) 
                                                        INTO l_cm_failure_cnt 
                                                        FROM CW_AUC_RCPT_CM_APPL_CTRL 
                                                        WHERE PHASE_CODE = 'CM APPLICATION FAILED'
                                                             AND cw_receipt_id = :CWARCCPM.CW_RECEIPT_ID;
                                                        SELECT COUNT(1) 
                                                        INTO l_wt_failure_cnt 
                                                        FROM CW_AUC_RCPT_CM_APPL_CTRL 
                                                        WHERE PHASE_CODE = 'WT CREDIT APPLICATION FAILED'
                                                                AND cw_receipt_id = :CWARCCPM.CW_RECEIPT_ID;
                                                            
                        EXCEPTION
                            WHEN OTHERS
                            THEN
                            FND_MESSAGE.DEBUG ('EROOR IN GETTING PHASE CODE ');
                            l_phase_code := NULL;
                        END;

                        BEGIN
                            SELECT   *
                            INTO   l_receipt_rec.child_rec
                            FROM   cw_ar_cc_post_paid_receipts_v
                            WHERE   cw_receipt_id = :CWARCCPM.CW_RECEIPT_ID;
                        EXCEPTION
                            WHEN OTHERS
                            THEN
                            FND_MESSAGE.DEBUG ('EROOR IN GETTING l_receipt_rec.child_rec ');
                            l_receipt_rec.child_rec := NULL;
                        END;
                        
                        BEGIN
                            SELECT   lt.*
                            INTO   l_ccas_rec
                            FROM   ra_territories rt,
                            fnd_flex_value_sets vs,
                            fnd_flex_values_vl fv,
                            fnd_lookup_values lt
                            WHERE   rt.territory_id =
                            l_receipt_rec.child_rec.territory_id
                            AND vs.flex_value_set_name = 'CW_MARKET'
                            AND fv.flex_value_set_id = vs.flex_value_set_id
                            AND fv.flex_value = rt.segment3
                            AND TRUNC (l_receipt_rec.child_rec.receipt_date) BETWEEN TRUNC(NVL (
                                                                                    fv.start_date_active,
                                                                                    TRUNC(l_receipt_rec.child_rec.receipt_date)
                                                                                 ))
                                                                       AND  TRUNC(NVL (
                                                                                     fv.end_date_active,
                                                                                     TRUNC(l_receipt_rec.child_rec.receipt_date)
                                                                                  ))
                            AND fv.enabled_flag = 'Y'
                            AND lt.lookup_type = 'CW_CCAS_GCS_MERCHANTS'
                            AND TRUNC (l_receipt_rec.child_rec.receipt_date) BETWEEN TRUNC(NVL (
                                                                                    lt.start_date_active,
                                                                                    TRUNC(l_receipt_rec.child_rec.receipt_date)
                                                                                 ))
                                                                       AND  TRUNC(NVL (
                                                                                     lt.end_date_active,
                                                                                     TRUNC(l_receipt_rec.child_rec.receipt_date)
                                                                                  ))
                            AND lt.enabled_flag = 'Y'
                            AND fv.attribute3 = lt.lookup_code;
                        EXCEPTION
                            WHEN OTHERS
                            THEN
                            FND_MESSAGE.DEBUG ('EROOR IN GETTING l_ccas_rec ');
                            l_ccas_rec := NULL;
                        END;

            l_receipt_rec.method_id := TO_NUMBER (l_ccas_rec.attribute1);
            l_receipt_rec.payee_id := TO_NUMBER (l_ccas_rec.attribute2);
            l_receipt_rec.merchant_id := l_ccas_rec.attribute3;

             --fnd_message.debug('l_phase_code: ' || l_phase_code);
             /*fnd_message.debug('method_id: ' || l_receipt_rec.method_id);
             fnd_message.debug('payee_id: ' || l_receipt_rec.payee_id);
             fnd_message.debug('merchant_id: ' || l_receipt_rec.merchant_id);*/

            l_receipt_rec.org_id := FND_PROFILE.VALUE ('ORG_ID');
            l_receipt_rec.app_id := FND_GLOBAL.resp_appl_id;
                        
                        IF l_receipt_failure_cnt >0 THEN
                            --fnd_message.debug('calling receipt creation');
                                CW_AR_CC_RECEIPT_PKG.CW_AR_CC_RECEIPT(io_data_rec     => l_receipt_rec);
                                BEGIN
                            SELECT APPROVAL_MESSAGE
                            INTO   l_approval_message
                            FROM   cw_ar_cc_post_paid_receipts
                            WHERE  CW_RECEIPT_ID = :CWARCCPM.CW_RECEIPT_ID;
                            EXCEPTION
                            WHEN OTHERS
                            THEN
                            FND_MESSAGE.DEBUG ('ERROR in getting APPROVAL_MESSAGE');
                            l_ccas_rec := NULL;
                                END;

                            IF l_approval_message = 'APPROVED' THEN
						                    UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
						                    SET       STATUS_CODE        = 'S',
						                              PHASE_CODE        = 'RECEIPT CREATED',
						                              STATUS_DESC        = 'Receipt Creation Successful'
						                    WHERE     CW_RECEIPT_ID    = l_receipt_rec.child_rec.CW_RECEIPT_ID
						                              AND AMT_OFFSET   !=0;
                                COMMIT;
                            END IF;
                                
                            BEGIN
                                SELECT NVL(SUM(AMT_OFFSET),0)
                                INTO l_total_credit_balance
                                FROM
                                CW_AUC_RCPT_CM_APPL_CTRL
                                WHERE
                                CW_RECEIPT_ID=:CWARCCPM.CW_RECEIPT_ID
                                AND TRANSACTION_TYPE = 'Auction Credit Memo';
                            EXCEPTION
                                WHEN OTHERS THEN
                                fnd_message.debug('caught in exception for total CM balance');
                                        l_total_credit_balance :=0 ;
                                        RETURN;
                            END;
                            
                            BEGIN
                                  SELECT NVL(SUM(AMT_OFFSET),0)
                                  INTO l_total_wire_transfer_balance
                                  FROM
                                  CW_AUC_RCPT_CM_APPL_CTRL
                                  WHERE
                                  CW_RECEIPT_ID=:CWARCCPM.CW_RECEIPT_ID
                                  AND TRANSACTION_TYPE = 'AUCTION WIRE';
                            EXCEPTION
                                WHEN OTHERS THEN
                                fnd_message.debug('caught in exception for total WT balance');
                                        l_total_wire_transfer_balance :=0 ;
                                        RETURN;
                            END;
                            
                            IF l_total_credit_balance!=0 and l_approval_message = 'APPROVED'THEN
                                --fnd_message.debug('applying CM');
                                CW_AR_CC_RECEIPT_PKG.CC_GET_ON_ACC_CM_DET (
                                                                              io_data_rec   => l_receipt_rec,
                                                                              X_OUT         => l_api_out
                                                                        );
                                 /*BEGIN
                               SELECT APPROVAL_MESSAGE
                               INTO   l_approval_message
                               FROM   cw_ar_cc_post_paid_receipts
                               WHERE  CW_RECEIPT_ID = :CWARCCPM.CW_RECEIPT_ID;
                               EXCEPTION
                                        WHEN OTHERS
                                        THEN
                                        FND_MESSAGE.DEBUG ('ERROR in getting APPROVAL_MESSAGE');
                                        l_ccas_rec := NULL;
                                        END;
                       
                               IF l_approval_message = 'APPROVED' THEN
                                           UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
                                      SET       STATUS_CODE        = 'S',
                                                PHASE_CODE         = 'CM APPLIED SUCCESSFULLY',
                                                STATUS_DESC        = 'Credit Memo applied successfully'
                                      WHERE     CW_RECEIPT_ID      = l_receipt_rec.child_rec.CW_RECEIPT_ID;
                                      COMMIT;
                                END IF;*/
                            END IF;
                            
                          
                            
                            IF l_total_wire_transfer_balance!=0 and l_approval_message = 'APPROVED' THEN
                                --fnd_message.debug('applying WT');
                              CW_AR_CC_RECEIPT_PKG.CC_GET_WT_CREDIT_DET (
                                                                          io_data_rec   => l_receipt_rec,
                                                                          X_OUT         => l_api_out
                                                                        );
                              /* BEGIN                                         
                              SELECT APPROVAL_MESSAGE
                              INTO   l_approval_message
                              FROM   cw_ar_cc_post_paid_receipts
                              WHERE  CW_RECEIPT_ID = :CWARCCPM.CW_RECEIPT_ID;
                              EXCEPTION
                                        WHEN OTHERS
                                        THEN
                                        FND_MESSAGE.DEBUG ('ERROR in getting APPROVAL_MESSAGE');
                                        l_ccas_rec := NULL;
                                        END;
                                    
                                IF l_approval_message = 'APPROVED' THEN
                                        UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
                                        SET       STATUS_CODE       = 'S',
                                        PHASE_CODE        = 'WT Credit APPLIED SUCCESSFULLY',
                                        STATUS_DESC       = 'WT Credit Has been applied successfully'
                                        WHERE     CW_RECEIPT_ID     = l_receipt_rec.child_rec.CW_RECEIPT_ID;
                                        COMMIT;
                                END IF;   */ 
                            END IF;
                        EXECUTE_QUERY;
                        
                        ELSIF l_cm_failure_cnt > 0
                        THEN
                   -- fnd_message.debug('calling CC_GET_ON_ACC_CM_DET upon failure');
                       CW_AR_CC_RECEIPT_PKG.CC_GET_ON_ACC_CM_DET (
                                                                  io_data_rec   => l_receipt_rec,
                                                                  X_OUT         => l_api_out
                                                                 );
                       /*BEGIN
                       SELECT APPROVAL_MESSAGE
                       INTO   l_approval_message
                       FROM   cw_ar_cc_post_paid_receipts
                       WHERE  CW_RECEIPT_ID = :CWARCCPM.CW_RECEIPT_ID;
                       EXCEPTION
                                        WHEN OTHERS
                                        THEN
                                        FND_MESSAGE.DEBUG ('ERROR in getting APPROVAL_MESSAGE');
                                        l_ccas_rec := NULL;
                                        END;
                       --fnd_message.debug('DONE calling CC_GET_ON_ACC_CM_DET upon failure');
                       IF l_approval_message = 'APPROVED' THEN
                              UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
                              SET       STATUS_CODE        = 'S',
                                        PHASE_CODE         = 'CM APPLIED SUCCESSFULLY',
                                        STATUS_DESC        = 'Credit Memo applied successfully'
                              WHERE     CW_RECEIPT_ID      = l_receipt_rec.child_rec.CW_RECEIPT_ID;
                              COMMIT;
                       END IF;*/
                       
                      /* BEGIN
                                SELECT NVL(SUM(AMT_OFFSET),0)
                                INTO l_total_wire_transfer_balance
                                FROM
                                CW_AUC_RCPT_CM_APPL_CTRL
                                WHERE
                                CW_RECEIPT_ID=:CWARCCPM.CW_RECEIPT_ID
                                AND TRANSACTION_TYPE = 'AUCTION WIRE';
                       EXCEPTION
                                WHEN OTHERS THEN
                                fnd_message.debug('caught in exception for total WT balance');
                                        l_total_wire_transfer_balance :=0 ;
                                        RETURN;
                        END;
                            
                       IF l_total_wire_transfer_balance!=0 and l_approval_message = 'APPROVED' THEN
                                  CW_AR_CC_RECEIPT_PKG.CC_GET_WT_CREDIT_DET (
                                                                              io_data_rec   => l_receipt_rec,
                                                                              X_OUT         => l_api_out
                                                                            );
                                    BEGIN                                        
                                    SELECT APPROVAL_MESSAGE
                                    INTO   l_approval_message
                                    FROM   cw_ar_cc_post_paid_receipts
                                    WHERE  CW_RECEIPT_ID = :CWARCCPM.CW_RECEIPT_ID;
                                    EXCEPTION
                                            WHEN OTHERS
                                            THEN
                                            FND_MESSAGE.DEBUG ('ERROR in getting APPROVAL_MESSAGE');
                                            l_ccas_rec := NULL;
                                                    END;
                                
                                    IF l_approval_message = 'APPROVED' THEN
                                            UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
                                            SET       STATUS_CODE       = 'S',
                                            PHASE_CODE        = 'WT Credit APPLIED SUCCESSFULLY',
                                            STATUS_DESC       = 'WT Credit Has been applied successfully'
                                            WHERE     CW_RECEIPT_ID     = l_receipt_rec.child_rec.CW_RECEIPT_ID;
                                            COMMIT;
                                    END IF;    
                       END IF;*/
                       
                       EXECUTE_QUERY;
                              
            ELSIF l_wt_failure_cnt >0 
            THEN
                   CW_AR_CC_RECEIPT_PKG.CC_GET_WT_CREDIT_DET (
                                                              io_data_rec   => l_receipt_rec,
                                                              X_OUT         => l_api_out
                                                               );
                                /* BEGIN                              
                                SELECT APPROVAL_MESSAGE
                                INTO   l_approval_message
                                FROM   cw_ar_cc_post_paid_receipts
                                WHERE  CW_RECEIPT_ID = :CWARCCPM.CW_RECEIPT_ID;
                                EXCEPTION
                                        WHEN OTHERS
                                        THEN
                                        FND_MESSAGE.DEBUG ('ERROR in getting APPROVAL_MESSAGE');
                                        l_ccas_rec := NULL;
                                        END;
                                
                                IF l_approval_message = 'APPROVED' THEN
                                        UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
                                        SET       STATUS_CODE       = 'S',
                                        PHASE_CODE        = 'WT Credit APPLIED SUCCESSFULLY',
                                        STATUS_DESC       = 'WT Credit Has been applied successfully'
                                        WHERE     CW_RECEIPT_ID     = l_receipt_rec.child_rec.CW_RECEIPT_ID;
                                        COMMIT;
                                END IF;*/
                           EXECUTE_QUERY;
            ELSE 
                  NULL;    
            END IF;

         END IF;
    
        BEGIN
        SELECT COUNT(1)
        INTO   l_count_n
        FROM      CW_AUC_RCPT_CM_APPL_CTRL
        WHERE  CW_RECEIPT_ID =:CWARCCPM.CW_RECEIPT_ID
                     AND STATUS_CODE = 'X';
                     
        SELECT COUNT(1)
        INTO   l_count_null_n
        FROM      CW_AUC_RCPT_CM_APPL_CTRL
        WHERE  CW_RECEIPT_ID =:CWARCCPM.CW_RECEIPT_ID
               AND STATUS_CODE = 'P'
               AND PHASE_CODE ='SUBMIT GCS APPROVAL';
               
        SELECT COUNT(1)
        INTO   l_count_cc_auth_fail_n
        FROM      CW_AUC_RCPT_CM_APPL_CTRL
        WHERE  CW_RECEIPT_ID =:CWARCCPM.CW_RECEIPT_ID
               AND STATUS_CODE = 'E'
               AND PHASE_CODE ='CC DECLINED';
        EXCEPTION
        	WHEN OTHERS THEN
        	fnd_message.debug('Caught in exception to count the status');
        END;
        	
               
        IF l_count_n>0 THEN
        /*********** updating Control table***********/        
            FOR i IN curs
            LOOP
                  UPDATE   CW_AUC_RCPT_CM_APPL_CTRL
                  SET   
                              STATUS_CODE = 'P',
                              PHASE_CODE  = 'SUBMIT GCS APPROVAL',
                              STATUS_DESC = 'Records Submitted for GCS Approval'
                              WHERE CW_RECEIPT_ID =:CWARCCPM.CW_RECEIPT_ID;
                              
                  EXIT WHEN curs%NOTFOUND;
            END LOOP;            
            save_record;    
            DO_ACTION;

       ELSIF l_count_null_n !=0 THEN
                DO_ACTION;
           
       ELSIF l_count_cc_auth_fail_n!=0 THEN
                    DO_ACTION;
       ELSE
              NULL;
       END IF;
       
    ELSIF :PARAMETER.AUCTION_ORDER = 'N'THEN
     DO_ACTION;  
    END IF;
    
END;

