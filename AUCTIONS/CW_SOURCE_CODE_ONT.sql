PROCEDURE CW_SOURCE_CODE_ONT
IS
   l_cnt_n                         NUMBER :=0;
   l_user_id_n                     NUMBER;
   l_login_id_n                    NUMBER;
   l_receipt_id_n                  NUMBER;
   l_tangible_id_s                 VARCHAR2 (50);
   l_source_code_s                 VARCHAR2 (50) := :PARAMETER.P_SOURCE_CODE;
   l_source_id_n                   NUMBER := :PARAMETER.P_SOURCE_ID;


   ln_order_type_count             NUMBER := 0;
   l_cm_bal                        NUMBER := 0;
   l_order_total                   NUMBER := 0;
   l_cal_net_amount                NUMBER := 0;
   l_cm_applied                    NUMBER := 0;
   l_order_number                  NUMBER := 0;
   l_wire_transfer_balance         NUMBER := 0;
   l_total_wire_transfer_balance   NUMBER := 0;
   l_total_credit_memo             NUMBER := 0;
   l_return_alert                  NUMBER := 0;
   l_cntrl_cnt_n                   NUMBER := 0;
   l_status_code                   VARCHAR2 (1);
   l_phase_code                    VARCHAR2 (100);
   l_status_desc                   VARCHAR2 (100);
   l_amt                           NUMBER := 0;
   ln_sum_credit_applied           NUMBER := 0;
   ln_credit_applied               NUMBER := 0;
   ln_counter                      NUMBER := 0;
   v_flag                          VARCHAR2 (2) := 'N';
   v_flag_2                        VARCHAR2 (2) := 'N';
   ln_override_exists              NUMBER := 0;
   ln_override_exists_p            NUMBER := 0;
   l_rownum                        NUMBER := 0;
   l_customer_trx_id               NUMBER := 0;
   l_payment_schedule_id           NUMBER := 0;
   l_Transaction_Type              varchar2(100);
   l_trx_number                    varchar2(100);
   ln_total_wt_credit_applied      NUMBER := 0;
   ln_cm_credit_applied            NUMBER := 0;
   ln_cm_applied                   NUMBER := 0;
   ln_cm_counter                   NUMBER := 0;
   ln_cm_required                  NUMBER := 0;
   l_order_status                  VARCHAR2(50);
   ln_sl_no_cnt                    NUMBER := 0;
   l_exists_cw_receipt_id          NUMBER := 0;
   l_wt_hold_cnt_n                                 NUMBER;
   l_sum_wt_amt_offset                         NUMBER := 0;
   l_sum_cm_amt_offset                         NUMBER := 0;
   l_ac_wire_transfer_balance             NUMBER := 0;
   l_ac_cm_balance                                 NUMBER := 0;
   l_cm_bal_mod  NUMBER := 0;
   l_cm_applied_mod NUMBER := 0;

   /************ Cursor to calculate Wire Transfer Balance****************/
   CURSOR cw_wt_bal (p_receipt_id NUMBER )
   IS
      SELECT   rownum, acr.CASH_RECEIPT_ID
        FROM   ar_receipt_methods arm,
               ar_cash_receipts_all acr,
               ar_payment_schedules_all ps,
               oe_order_headers_all oe,
               cw_ar_cc_post_paid_receipts cc
       WHERE                                                             --1=1
            arm.NAME = 'AUCTION WIRE'
               AND acr.RECEIPT_METHOD_ID = arm.RECEIPT_METHOD_ID
               AND acr.PAY_FROM_CUSTOMER = oe.sold_to_org_id
               AND ps.CUSTOMER_SITE_USE_ID = acr.CUSTOMER_SITE_USE_ID
               AND ps.CASH_RECEIPT_ID = acr.CASH_RECEIPT_ID
               AND ps.CLASS = 'PMT'
               AND ps.STATUS = 'OP'
               AND ps.customer_id = oe.sold_to_org_id
               AND cc.status IN ('N','E')
               AND cc.applied_ps_id = -1
               AND cc.source_id = oe.header_id
               AND acr.status = 'UNAPP'
               AND ABS(PS.amount_due_remaining)>0
               AND cc.cw_receipt_id = p_receipt_id;


   /********** Cursor to update Amount_offset in Control table After Override*********/
   CURSOR cw_amt_ofset (p_receipt_id NUMBER)
   IS
      SELECT   *
        FROM   CW_AUC_RCPT_CM_APPL_CTRL
       WHERE   CW_RECEIPT_ID = p_receipt_id;

   /********** Cursor to Insert data into the Control table ***********/

      CURSOR cw_cm_bal (p_receipt_id NUMBER)
      IS
      SELECT   ROWNUM,
               ps.CUSTOMER_TRX_ID,
               ps.PAYMENT_SCHEDULE_ID,
               oe.header_id Source_ID,
               rta.name Transaction_Type,
               ps.trx_number Transaction_Number,
               ABS (ps.amount_due_remaining) CM_Credit_Available
        FROM   ra_customer_trx_all rt,
               ar_payment_schedules_all ps,
               cw_ar_cc_post_paid_receipts cc,
               oe_order_headers_all oe,
               RA_CUST_TRX_TYPES_ALL rta
       WHERE       ps.customer_trx_id = rt.customer_trx_id
               AND rta.CUST_TRX_TYPE_ID = rt.CUST_TRX_TYPE_ID
               AND rta.name IN ('Auction Credit Memo')
               AND ps.customer_id = rt.bill_to_customer_id
               AND ps.CLASS = 'CM'
               AND ps.status = 'OP'
               AND rt.complete_flag = 'Y'
               AND ps.customer_id = oe.sold_to_org_id
               AND cc.source_code = 'AUC'
               AND cc.status IN ('N','E')
               AND cc.applied_ps_id = -1
               AND oe.header_id = cc.source_id
               AND ABS(ps.amount_due_remaining)>0
               AND cc.cw_receipt_id = p_receipt_id;
               
    /*************Cursor to fecth any other CW_RECEIPT_ID existing in Control table with status as X *************/
    
      CURSOR cw_status_in_x  
      IS
                SELECT distinct ctrl1.CW_RECEIPT_ID, STATUS_CODE
                FROM CW_AUC_RCPT_CM_APPL_CTRL ctrl1
                WHERE  (sysdate-ctrl1.last_update_DATE)*1440 >3
                AND   ctrl1.STATUS_CODE = 'X';
                

BEGIN
  -- FND_MESSAGE.DEBUG('P_SOURCE_CODE='||:PARAMETER.P_SOURCE_CODE||',P_SOURCE_ID='||:PARAMETER.P_SOURCE_ID||',P_ORDER_AMOUNT='||:PARAMETER.P_ORDER_AMOUNT);
        BEGIN
        SELECT flow_status_code
        INTO     l_order_status
        FROM     OE_ORDER_HEADERS_ALL
        WHERE        header_id=l_source_id_n;
        EXCEPTION
            WHEN OTHERS THEN
            fnd_message.debug('CAUGHT IN EXCEPTION TO FIND FLOW_STATUS_CODE');
        END;
        
         IF :CWARCCPM.CAL_NET_AMOUNT = 0
         THEN
            :PARAMETER.NET_AUTH_AMOUNT := 'N';
         END IF;
        
        /* IF l_order_status != 'ENTERED' THEN
             IF :PARAMETER.AUCTION_ORDER = 'Y' 
              THEN
            --:PARAMETER.VIEW_OVERRIDE := 'N';
            :PARAMETER.NET_AUTH_AMOUNT := 'N';
            EXECUTE_QUERY;
             ELSE
                 EXECUTE_QUERY;
             END IF;*/

       -- IF l_order_status = 'ENTERED' THEN
   /*****************Checking if the order is of Auction order Type**************/
           BEGIN
           SELECT   COUNT (1)
           INTO   ln_order_type_count
           FROM   oe_order_headers_all oeh, oe_transaction_types_tl ott
           WHERE       1 = 1
                    AND oeh.header_id = l_source_id_n
                    AND ott.TRANSACTION_TYPE_ID = oeh.ORDER_TYPE_ID
                    AND EXISTS
                          ( SELECT   1
                            FROM   fnd_flex_value_sets ffvs, fnd_flex_values_vl ffvv
                            WHERE   ffvs.flex_value_set_id = ffvv.flex_value_set_id
                                    AND ffvs.flex_value_set_name = 'AUC_ORDER_TYPE'
                                    AND ENABLED_FLAG = 'Y'
                                    AND (start_date_active IS NULL
                                         OR start_date_active <=
                                              TO_CHAR (SYSDATE, 'DD-MON-YYYY'))
                                    AND (end_date_active IS NULL
                                         OR end_date_active >=
                                              TO_CHAR (SYSDATE, 'DD-MON-YYYY'))
                                    AND ffvv.flex_value = ott.name);
           EXCEPTION
               WHEN OTHERS THEN
               fnd_message.debug('CAUGHT IN EXCEPTION TO FIND IF THE ORDER IS AUCTION ORDER');
           END;


       /***********Setting value to Global Parameter :PARAMETER.AUCTION_ORDER depending on order type **************/
           IF ln_order_type_count = 0
           THEN
              :PARAMETER.AUCTION_ORDER := 'N';
           ELSE
              :PARAMETER.AUCTION_ORDER := 'Y';
           END IF;
       
        /************Delete the records from control table which are in X status for more than 10 minutes**********/
           IF  :PARAMETER.AUCTION_ORDER = 'Y' THEN
                     
                FOR l_cw_status_in_x IN cw_status_in_x 
                LOOP
                delete from CW_AUC_RCPT_CM_APPL_CTRL
                where CW_RECEIPT_ID =l_cw_status_in_x.CW_RECEIPT_ID ;
                
                delete from CW_AR_CC_POST_PAID_RECEIPTS
                where CW_RECEIPT_ID = l_cw_status_in_x.CW_RECEIPT_ID;
                
                commit;
                EXIT WHEN cw_status_in_x%NOTFOUND; 
                END LOOP;
                
                CW_AUCTION_LOCK;
          END IF;  

       /***************    Checking if data already exists in the base table for the same CW_RECEIPT_ID***********/
           BEGIN
           SELECT   COUNT ( * )
           INTO   l_cnt_n
           FROM   cw_ar_cc_post_paid_receipts
           WHERE   source_code = l_source_code_s AND source_id = l_source_id_n;
           EXCEPTION
               WHEN OTHERS THEN
               fnd_message.debug('CAUGHT IN EXCEPTION TO FIND L_CNT_N');
           END;
           --fnd_message.debug('l_cnt_n: '|| l_cnt_n);
           
      /***********If GCS Validation fails inserting new record with RETRY GCS Approval Status*************/
         BEGIN
         SELECT   COUNT ( * )
            INTO   l_cntrl_cnt_n
            FROM   CW_AUC_RCPT_CM_APPL_CTRL
           WHERE       --CW_RECEIPT_ID = l_receipt_id_n
                            source_id = l_source_id_n
                   AND STATUS_CODE = 'E'
                   AND PHASE_CODE in ( 'GCS VALIDATION FAILED' , 'CC DECLINED');
          EXCEPTION
               WHEN OTHERS THEN
               fnd_message.debug('CAUGHT IN EXCEPTION TO FIND l_cntrl_cnt_n');
           END;
                   
           --fnd_message.debug('l_cntrl_cnt_n: ' || l_cntrl_cnt_n);    
           
           /********* fetching the value for ORDER_TOTAL********/
            
           BEGIN            
           SELECT   NVL(SUM (UNIT_SELLING_PRICE * ORDERED_QUANTITY),0)
             INTO   l_order_total
             FROM   apps.oe_order_lines_all
            WHERE   header_id = l_source_id_n;   
           EXCEPTION
               WHEN OTHERS THEN
               fnd_message.debug('CAUGHT IN EXCEPTION TO FIND ORDER TOTAL');
           END;   
            
          /************* selecting the order number for :source_id ****************/
           BEGIN
           SELECT   ORDER_NUMBER
           INTO   l_order_number
           FROM   OE_ORDER_HEADERS_ALL
           WHERE   HEADER_ID = l_source_id_n;
           EXCEPTION
               WHEN OTHERS THEN
               fnd_message.debug('CAUGHT IN EXCEPTION TO FIND ORDER_NUMBER');
           END;
           
              l_user_id_n := FND_GLOBAL.USER_ID;
              l_login_id_n := FND_GLOBAL.login_id;

           IF l_cnt_n = 0 THEN
              
                     BEGIN
           SELECT   cw_ar_cc_receipt_s.NEXTVAL INTO l_receipt_id_n FROM DUAL;
           EXCEPTION
               WHEN OTHERS THEN
               fnd_message.debug('CAUGHT IN EXCEPTION TO FIND CW_RECEIPT_ID');
           END;

           l_tangible_id_s :=
             CW_AR_CC_RECEIPT_PKG.GET_TANGIBLE_ID (:PARAMETER.P_SOURCE_CODE);

          /************inserting data into base table ******************/
                    --fnd_message.debug('ENTERING DATA INTO POST PAID RECEIPT TABLE ');
          INSERT INTO CW_AR_CC_POST_PAID_RECEIPTS (CW_RECEIPT_ID,
                                                   RECEIPT_DATE,
                                                   RECEIPT_AMOUNT,
                                                   STATUS,
                                                   CREATED_BY,
                                                   CREATION_DATE,
                                                   LAST_UPDATED_BY,
                                                   LAST_UPDATE_DATE,
                                                   LAST_UPDATE_LOGIN,
                                                   TANGIBLE_ID,
                                                   SOURCE_CODE,
                                                   SOURCE_ID,
                                                   TRX_TYPE,
                                                   ATTRIBUTE6)
            VALUES   (l_receipt_id_n,
                      TRUNC (SYSDATE),
                      :PARAMETER.P_ORDER_AMOUNT,
                      'N',
                      l_user_id_n,
                      SYSDATE,
                      l_user_id_n,
                      SYSDATE,
                      l_login_id_n,
                      l_tangible_id_s,
                      :PARAMETER.P_SOURCE_CODE,
                      :PARAMETER.P_SOURCE_ID,
                      'AUTHONLY',
                      l_order_number);

          --SAVE_RECORD;
          
              /********* fetching the value for ORDER_TOTAL********/
                       
                 /*SELECT   NVL(SUM (UNIT_SELLING_PRICE * ORDERED_QUANTITY),0)
                   INTO   l_order_total
                   FROM   apps.oe_order_lines_all
                  WHERE   header_id = l_source_id_n;*/

              IF :PARAMETER.AUCTION_ORDER = 'Y' 
              THEN
                  
                 IF l_cntrl_cnt_n = 0
                  THEN
                     /*l_status_code := 'X';
                     l_phase_code := 'RELEASED';
                     l_status_desc := 'User Enters/Exits without requesting GCS Approval '; */
                     
                     l_status_code := 'X';
                     l_phase_code := 'LOCKED';
                     l_status_desc := 'Records locked for GCS Approval';
                

                 /************* Calculating total wire transfer balance**************/
                 
                 --fnd_message.debug('ENTERING DATA INTO CONTROL TABLE FOR THE FIRST TIME');
                    FOR l_cw_wt_bal IN cw_wt_bal (l_receipt_id_n)
                     LOOP
                                     --ln_sl_no_cnt := ln_sl_no_cnt + 1;
                            /*BEGIN         
                            SELECT COUNT(1)
                            INTO   l_wt_hold_cnt_n
                            FROM   CW_AUC_RCPT_CM_APPL_CTRL
                            WHERE  WT_RECEIPT_ID = l_cw_wt_bal.CASH_RECEIPT_ID
                                   AND STATUS_CODE ='W';
                            EXCEPTION
                                WHEN OTHERS THEN
                                FND_MESSAGE.DEBUG('Caught in exception to calculate WT balance');
                            END;
                                   
                            IF l_wt_hold_cnt_n > 0 THEN
                                
                                SELECT  sum (AMT_OFFSET)
                                INTO   l_sum_amt_offset
                                FROM   CW_AUC_RCPT_CM_APPL_CTRL
                                WHERE  WT_RECEIPT_ID = l_cw_wt_bal.CASH_RECEIPT_ID
                                            AND STATUS_CODE ='W';
                                            
                                SELECT AMT_DUE_REMAINING - l_sum_amt_offset
                                INTO   l_wire_transfer_balance
                                FROM   CW_AUC_RCPT_CM_APPL_CTRL
                                WHERE  WT_RECEIPT_ID = l_cw_wt_bal.CASH_RECEIPT_ID
                                                 AND STATUS_CODE ='W';
                                            
                                            
                            ELSE*/
                                SELECT   distinct (NVL (abs(ps.AMOUNT_DUE_REMAINING), 0))
                                INTO   l_wire_transfer_balance
                                FROM   ar_receipt_methods arm,
                                       ar_cash_receipts_all acr,
                                       ar_payment_schedules_all ps,
                                       oe_order_headers_all oe,
                                       ar_receivable_applications_all ara,
                                       cw_ar_cc_post_paid_receipts cc
                                WHERE       1 = 1
                                       AND arm.NAME = 'AUCTION WIRE'
                                       AND acr.RECEIPT_METHOD_ID = arm.RECEIPT_METHOD_ID
                                       AND ara.CASH_RECEIPT_ID = acr.CASH_RECEIPT_ID
                                       AND acr.PAY_FROM_CUSTOMER = oe.sold_to_org_id
                                       AND ps.CUSTOMER_SITE_USE_ID = acr.CUSTOMER_SITE_USE_ID
                                       --AND ara.status in ( 'ACTIVITY')
                                       AND ps.CASH_RECEIPT_ID = acr.CASH_RECEIPT_ID
                                       AND ps.PAYMENT_SCHEDULE_ID = ara.PAYMENT_SCHEDULE_ID
                                       AND ps.CLASS = 'PMT'
                                       AND ps.STATUS = 'OP'
                                       AND ps.customer_id = oe.sold_to_org_id
                                       AND cc.status IN ('N','E')
                                       AND cc.applied_ps_id = -1
                                       AND cc.source_id = oe.header_id
                                       AND cc.cw_receipt_id = l_receipt_id_n
                                       AND acr.cash_receipt_id = l_cw_wt_bal.CASH_RECEIPT_ID
                                       AND acr.status = 'UNAPP';
                                       
                                BEGIN       
                                SELECT  nvl(sum(AMT_OFFSET),0)
                                INTO   l_sum_wt_amt_offset
                                FROM   CW_AUC_RCPT_CM_APPL_CTRL
                                WHERE  WT_RECEIPT_ID = l_cw_wt_bal.CASH_RECEIPT_ID
                                            AND STATUS_CODE ='W';
                                EXCEPTION
                                        WHEN OTHERS THEN
                                        FND_MESSAGE.DEBUG('Caught in exception to calculate WT balance');
                                    END;
                                            
                                l_ac_wire_transfer_balance := l_wire_transfer_balance -l_sum_wt_amt_offset;
                                --fnd_message.debug('l_ac_wire_transfer_balance : '||l_ac_wire_transfer_balance);
                            --END IF;

                              IF l_ac_wire_transfer_balance>0 THEN
                                   ln_sl_no_cnt := ln_sl_no_cnt + 1;
                                  SELECT   
                                           --acr.CASH_RECEIPT_ID,
                                           --cc.cw_receipt_id Receipt_ID,
                                           ps.CUSTOMER_TRX_ID,
                                           ps.PAYMENT_SCHEDULE_ID,
                                           arm.name Transaction_Type,
                                           ps.trx_number Transaction_Number
                                    INTO   
                                           l_customer_trx_id,
                                           l_payment_schedule_id,
                                           l_Transaction_Type,
                                           l_trx_number
                                    FROM   ar_receipt_methods arm,
                                           ar_cash_receipts_all acr,
                                           ar_payment_schedules_all ps,
                                           oe_order_headers_all oe,
                                           cw_ar_cc_post_paid_receipts cc
                                   WHERE                                                             --1=1
                                        arm    .NAME = 'AUCTION WIRE'
                                           AND acr.RECEIPT_METHOD_ID = arm.RECEIPT_METHOD_ID
                                           AND acr.PAY_FROM_CUSTOMER = oe.sold_to_org_id
                                           AND ps.CUSTOMER_SITE_USE_ID = acr.CUSTOMER_SITE_USE_ID
                                           AND ps.CASH_RECEIPT_ID = acr.CASH_RECEIPT_ID
                                           AND ps.CLASS = 'PMT'
                                           AND ps.STATUS = 'OP'
                                           AND ps.customer_id = oe.sold_to_org_id
                                           AND cc.status IN ('N','E')
                                           AND cc.applied_ps_id = -1
                                           AND cc.source_id = oe.header_id
                                           AND acr.status = 'UNAPP'
                                           AND cc.cw_receipt_id = l_receipt_id_n
                                           AND acr.cash_receipt_id = l_cw_wt_bal.CASH_RECEIPT_ID;

                                  IF v_flag = 'Y'
                                  THEN
                                     ln_credit_applied := 0;
                                  END IF;

                                  IF v_flag = 'N'
                                  THEN
                                     ln_sum_credit_applied :=
                                        ln_sum_credit_applied + l_ac_wire_transfer_balance;

                                     IF ln_sum_credit_applied < l_order_total
                                     THEN
                                        ln_credit_applied := l_ac_wire_transfer_balance;

                                     ELSE
                                        ln_credit_applied := l_order_total - ln_counter;
                                        v_flag := 'Y';
                                     END IF;
                                                    ln_total_wt_credit_applied := ln_total_wt_credit_applied + NVL (ln_credit_applied,0);
                                     ln_counter := ln_sum_credit_applied;
                                  END IF;

                                                        
                                  INSERT INTO CW_AUC_RCPT_CM_APPL_CTRL (RECORD_ID,
                                                                        CW_RECEIPT_ID,
                                                                        CUSTOMER_TRX_ID,
                                                                        WT_RECEIPT_ID,
                                                                        AMT_DUE_REMAINING,
                                                                        AMT_OFFSET,
                                                                        STATUS_CODE,
                                                                        PHASE_CODE,
                                                                        STATUS_DESC,
                                                                        OVERRIDE_FLAG,
                                                                        SOURCE_ID,
                                                                        TRANSACTION_TYPE,
                                                                        TRANSACTION_NUMBER,
                                                                        CREDIT_AVAILABLE,
                                                                        CREDIT_APPLIED,
                                                                        ATTRIBUTE_CATEGORY,
                                                                        ATTRIBUTE1,
                                                                        ATTRIBUTE2,
                                                                        ATTRIBUTE3,
                                                                        ATTRIBUTE4,
                                                                        ATTRIBUTE5,
                                                                        ATTRIBUTE6,
                                                                        ATTRIBUTE7,
                                                                        ATTRIBUTE8,
                                                                        ATTRIBUTE9,
                                                                        ATTRIBUTE10,
                                                                        ATTRIBUTE11,
                                                                        ATTRIBUTE12,
                                                                        ATTRIBUTE13,
                                                                        ATTRIBUTE14,
                                                                        ATTRIBUTE15,
                                                                        APPLIED_PS_ID,
                                                                        CREATION_DATE,
                                                                        LAST_UPDATE_DATE,
                                                                        CREATED_BY,
                                                                        LAST_UPDATED_BY,
                                                                        SLNO)
                                    VALUES   (CW_AUC_RCPT_CM_APPL_CTRL_S.NEXTVAL,
                                              l_receipt_id_n,
                                              l_customer_trx_id,
                                              l_cw_wt_bal.CASH_RECEIPT_ID,
                                              l_ac_wire_transfer_balance,
                                              ln_credit_applied,
                                              l_status_code,
                                              l_phase_code,
                                              l_status_desc,
                                              'N',
                                              l_source_id_n,
                                              l_Transaction_Type,
                                              l_trx_number,
                                              l_ac_wire_transfer_balance,
                                              ln_credit_applied,                        
                                              NULL,
                                              NULL,
                                              'CC',
                                              NULL,
                                              NULL,
                                              NULL,
                                              NULL,
                                              NULL,
                                              NULL,
                                              NULL,
                                              NULL,
                                              NULL,
                                              NULL,
                                              NULL,
                                              NULL,
                                              NULL,
                                              l_payment_schedule_id,
                                              SYSDATE,
                                              SYSDATE,
                                              l_user_id_n,
                                              l_user_id_n,
                                              ln_sl_no_cnt);



                                      l_total_wire_transfer_balance :=
                                         NVL (l_ac_wire_transfer_balance, 0) + l_total_wire_transfer_balance;
                              END IF;
                        EXIT WHEN cw_wt_bal%NOTFOUND;
                    END LOOP;
           
                    FOR l_cw_cm_bal IN cw_cm_bal (l_receipt_id_n)
                       LOOP  
                           
                           --ln_sl_no_cnt := ln_sl_no_cnt + 1;      
                                
                                BEGIN       
                                SELECT  nvl(sum(AMT_OFFSET),0)
                                INTO   l_sum_cm_amt_offset
                                FROM   CW_AUC_RCPT_CM_APPL_CTRL
                                WHERE  CUSTOMER_TRX_ID = l_cw_cm_bal.CUSTOMER_TRX_ID
                                            AND STATUS_CODE ='W';
                                EXCEPTION
                                        WHEN OTHERS THEN
                                        FND_MESSAGE.DEBUG('Caught in exception to calculate WT balance');
                                END;    
                                
                         l_ac_cm_balance := l_cw_cm_bal.CM_Credit_Available -l_sum_cm_amt_offset;    
                         
                         IF l_ac_cm_balance>0 THEN
                             ln_sl_no_cnt := ln_sl_no_cnt + 1;    
                          
                                IF v_flag_2 = 'Y'
                                  THEN
                                     ln_cm_applied := 0;
                                END IF;

                                  IF v_flag_2 = 'N'
                                  THEN
                                             IF ln_total_wt_credit_applied = l_order_total
                                             THEN
                                                ln_cm_applied := 0;
                                             ELSIF ln_total_wt_credit_applied < l_order_total
                                             THEN
                                                ln_cm_required := l_order_total - ln_total_wt_credit_applied;

                                                        IF ln_cm_required < l_ac_cm_balance
                                                        THEN
                                                           ln_cm_applied := ln_cm_required;
                                                           v_flag_2 := 'Y';
                                                        ELSIF ln_cm_required > l_ac_cm_balance
                                                        THEN
                                                           ln_cm_applied := l_ac_cm_balance;
                                                           ln_total_wt_credit_applied :=
                                                              ln_total_wt_credit_applied + ln_cm_applied;
                                                        ELSIF ln_cm_required = l_ac_cm_balance
                                                        THEN
                                                           ln_cm_applied := ln_cm_required;
                                                           v_flag_2 := 'Y';
                                                        END IF;

                                             END IF;
                                     END IF;
                              
                                      INSERT INTO CW_AUC_RCPT_CM_APPL_CTRL (RECORD_ID,
                                                                    CW_RECEIPT_ID,
                                                                    CUSTOMER_TRX_ID,
                                                                    AMT_DUE_REMAINING,
                                                                    AMT_OFFSET,
                                                                    STATUS_CODE,
                                                                    PHASE_CODE,
                                                                    STATUS_DESC,
                                                                    OVERRIDE_FLAG,
                                                                    SOURCE_ID,
                                                                    TRANSACTION_TYPE,
                                                                    TRANSACTION_NUMBER,
                                                                    CREDIT_AVAILABLE,
                                                                    CREDIT_APPLIED,
                                                                    ATTRIBUTE_CATEGORY,
                                                                    ATTRIBUTE1,
                                                                    ATTRIBUTE2,
                                                                    ATTRIBUTE3,
                                                                    ATTRIBUTE4,
                                                                    ATTRIBUTE5,
                                                                    ATTRIBUTE6,
                                                                    ATTRIBUTE7,
                                                                    ATTRIBUTE8,
                                                                    ATTRIBUTE9,
                                                                    ATTRIBUTE10,
                                                                    ATTRIBUTE11,
                                                                    ATTRIBUTE12,
                                                                    ATTRIBUTE13,
                                                                    ATTRIBUTE14,
                                                                    ATTRIBUTE15,
                                                                    APPLIED_PS_ID,
                                                                    CREATION_DATE,
                                                                    LAST_UPDATE_DATE,
                                                                    CREATED_BY,
                                                                    LAST_UPDATED_BY,
                                                                    SLNO)
                                VALUES   (CW_AUC_RCPT_CM_APPL_CTRL_S.NEXTVAL,
                                          l_receipt_id_n,
                                          l_cw_cm_bal.CUSTOMER_TRX_ID,
                                          l_ac_cm_balance,
                                          ln_cm_applied,
                                          l_status_code,
                                          l_phase_code,
                                          l_status_desc,
                                          'N',
                                          l_source_id_n,
                                          l_cw_cm_bal.Transaction_Type,
                                          l_cw_cm_bal.Transaction_Number,
                                          l_ac_cm_balance,
                                          ln_cm_applied,                         
                                          NULL,
                                          NULL,
                                          'CC',
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          NULL,
                                          l_cw_cm_bal.PAYMENT_SCHEDULE_ID,
                                          SYSDATE,
                                          SYSDATE,
                                          l_user_id_n,
                                          l_user_id_n,
                                          ln_sl_no_cnt);
                          END IF;
                          EXIT WHEN cw_cm_bal%NOTFOUND;
                        
                        END LOOP;
                 END IF;
              END IF;
           
           ELSIF l_cnt_n > 0 THEN
                           BEGIN
                   SELECT cw_receipt_id
                   INTO   l_receipt_id_n
                   FROM   cw_ar_cc_post_paid_receipts
                   WHERE  source_id = l_source_id_n;
                   EXCEPTION
                               WHEN OTHERS THEN
                               fnd_message.debug('CAUGHT IN EXCEPTION TO FIND cw_receipt_id');
                           END;
                   
                   --fnd_message.debug('l_receipt_id_n after select: ' || l_receipt_id_n);
                  
               IF :PARAMETER.AUCTION_ORDER = 'Y' THEN
                    IF l_cntrl_cnt_n > 0 THEN     
                    
                    /************when the zoom from is re-invoked deleting the records from control table which are in status E**************/
                    
                    DELETE FROM  CW_AUC_RCPT_CM_APPL_CTRL
                    WHERE CW_RECEIPT_ID =  l_receipt_id_n
                          AND  STATUS_CODE = 'E'
                          AND  PHASE_CODE in  ( 'GCS VALIDATION FAILED' , 'CC DECLINED');         
                    COMMIT;
                      
                    l_status_code := 'X';
                     l_phase_code := 'LOCKED';
                     l_status_desc := 'Records locked for GCS Approval';
                    /* l_status_code := 'P';
                     l_phase_code := 'RETRY GCS APPROVAL';
                     l_status_desc := 'GCS validation was Failed.Retry GCS Approval';*/
                     
                     
	
                        FOR l_cw_wt_bal IN cw_wt_bal (l_receipt_id_n)
                             LOOP
                                 --ln_sl_no_cnt := ln_sl_no_cnt + 1;
                                 SELECT   distinct (NVL (abs(ps.AMOUNT_DUE_REMAINING), 0))
                                INTO   l_wire_transfer_balance
                                FROM   ar_receipt_methods arm,
                                       ar_cash_receipts_all acr,
                                       ar_payment_schedules_all ps,
                                       oe_order_headers_all oe,
                                       ar_receivable_applications_all ara,
                                       cw_ar_cc_post_paid_receipts cc
                                WHERE       1 = 1
                                       AND arm.NAME = 'AUCTION WIRE'
                                       AND acr.RECEIPT_METHOD_ID = arm.RECEIPT_METHOD_ID
                                       AND ara.CASH_RECEIPT_ID = acr.CASH_RECEIPT_ID
                                       AND acr.PAY_FROM_CUSTOMER = oe.sold_to_org_id
                                       AND ps.CUSTOMER_SITE_USE_ID = acr.CUSTOMER_SITE_USE_ID
                                       --AND ara.status in ( 'ACTIVITY')
                                       AND ps.CASH_RECEIPT_ID = acr.CASH_RECEIPT_ID
                                       AND ps.PAYMENT_SCHEDULE_ID = ara.PAYMENT_SCHEDULE_ID
                                       AND ps.CLASS = 'PMT'
                                       AND ps.STATUS = 'OP'
                                       AND ps.customer_id = oe.sold_to_org_id
                                       AND cc.status IN ('N','E')
                                       AND cc.applied_ps_id = -1
                                       AND cc.source_id = oe.header_id
                                       AND cc.cw_receipt_id = l_receipt_id_n
                                       AND acr.cash_receipt_id = l_cw_wt_bal.CASH_RECEIPT_ID
                                       AND acr.status = 'UNAPP';
                                BEGIN       
                                SELECT  nvl(sum(AMT_OFFSET),0)
                                INTO   l_sum_wt_amt_offset
                                FROM   CW_AUC_RCPT_CM_APPL_CTRL
                                WHERE  WT_RECEIPT_ID = l_cw_wt_bal.CASH_RECEIPT_ID
                                            AND STATUS_CODE ='W';
                                EXCEPTION
                                        WHEN OTHERS THEN
                                        FND_MESSAGE.DEBUG('Caught in exception to calculate WT balance');
                                    END;
                                            
                                l_ac_wire_transfer_balance := l_wire_transfer_balance -l_sum_wt_amt_offset;
                            --END IF;

                               IF l_ac_wire_transfer_balance>0 THEN
                                  ln_sl_no_cnt := ln_sl_no_cnt + 1;
                                  SELECT   
                                           --acr.CASH_RECEIPT_ID,
                                           --cc.cw_receipt_id Receipt_ID,
                                           ps.CUSTOMER_TRX_ID,
                                           ps.PAYMENT_SCHEDULE_ID,
                                           arm.name Transaction_Type,
                                           ps.trx_number Transaction_Number
                                    INTO   
                                           l_customer_trx_id,
                                           l_payment_schedule_id,
                                           l_Transaction_Type,
                                           l_trx_number
                                    FROM   ar_receipt_methods arm,
                                           ar_cash_receipts_all acr,
                                           ar_payment_schedules_all ps,
                                           oe_order_headers_all oe,
                                           cw_ar_cc_post_paid_receipts cc
                                   WHERE                                                             --1=1
                                        arm    .NAME = 'AUCTION WIRE'
                                           AND acr.RECEIPT_METHOD_ID = arm.RECEIPT_METHOD_ID
                                           AND acr.PAY_FROM_CUSTOMER = oe.sold_to_org_id
                                           AND ps.CUSTOMER_SITE_USE_ID = acr.CUSTOMER_SITE_USE_ID
                                           AND ps.CASH_RECEIPT_ID = acr.CASH_RECEIPT_ID
                                           AND ps.CLASS = 'PMT'
                                           AND ps.STATUS = 'OP'
                                           AND ps.customer_id = oe.sold_to_org_id
                                           AND cc.status IN ('N','E')
                                           AND cc.applied_ps_id = -1
                                           AND cc.source_id = oe.header_id
                                           AND acr.status = 'UNAPP'
                                           AND cc.cw_receipt_id = l_receipt_id_n
                                           AND acr.cash_receipt_id = l_cw_wt_bal.CASH_RECEIPT_ID;

                                  IF v_flag = 'Y'
                                  THEN
                                     ln_credit_applied := 0;
                                  END IF;

                                  IF v_flag = 'N'
                                  THEN
                                     ln_sum_credit_applied :=
                                        ln_sum_credit_applied + l_ac_wire_transfer_balance;

                                     IF ln_sum_credit_applied < l_order_total
                                     THEN
                                        ln_credit_applied := l_ac_wire_transfer_balance;

                                     ELSE
                                        ln_credit_applied := l_order_total - ln_counter;
                                        v_flag := 'Y';
                                     END IF;
                                                    ln_total_wt_credit_applied := ln_total_wt_credit_applied + NVL (ln_credit_applied,0);
                                     ln_counter := ln_sum_credit_applied;
                                  END IF;

                                                        
                                  INSERT INTO CW_AUC_RCPT_CM_APPL_CTRL (RECORD_ID,
                                                                        CW_RECEIPT_ID,
                                                                        CUSTOMER_TRX_ID,
                                                                        WT_RECEIPT_ID,
                                                                        AMT_DUE_REMAINING,
                                                                        AMT_OFFSET,
                                                                        STATUS_CODE,
                                                                        PHASE_CODE,
                                                                        STATUS_DESC,
                                                                        OVERRIDE_FLAG,
                                                                        SOURCE_ID,
                                                                        TRANSACTION_TYPE,
                                                                        TRANSACTION_NUMBER,
                                                                        CREDIT_AVAILABLE,
                                                                        CREDIT_APPLIED,
                                                                        ATTRIBUTE_CATEGORY,
                                                                        ATTRIBUTE1,
                                                                        ATTRIBUTE2,
                                                                        ATTRIBUTE3,
                                                                        ATTRIBUTE4,
                                                                        ATTRIBUTE5,
                                                                        ATTRIBUTE6,
                                                                        ATTRIBUTE7,
                                                                        ATTRIBUTE8,
                                                                        ATTRIBUTE9,
                                                                        ATTRIBUTE10,
                                                                        ATTRIBUTE11,
                                                                        ATTRIBUTE12,
                                                                        ATTRIBUTE13,
                                                                        ATTRIBUTE14,
                                                                        ATTRIBUTE15,
                                                                        APPLIED_PS_ID,
                                                                        CREATION_DATE,
                                                                        LAST_UPDATE_DATE,
                                                                        CREATED_BY,
                                                                        LAST_UPDATED_BY,
                                                                        SLNO)
                                    VALUES   (CW_AUC_RCPT_CM_APPL_CTRL_S.NEXTVAL,
                                              l_receipt_id_n,
                                              l_customer_trx_id,
                                              l_cw_wt_bal.CASH_RECEIPT_ID,
                                              l_ac_wire_transfer_balance,
                                              ln_credit_applied,
                                              l_status_code,
                                              l_phase_code,
                                              l_status_desc,
                                              'N',
                                              l_source_id_n,
                                              l_Transaction_Type,
                                              l_trx_number,
                                              l_ac_wire_transfer_balance,
                                              ln_credit_applied,                        
                                              NULL,
                                              NULL,
                                              'CC',
                                              NULL,
                                              NULL,
                                              NULL,
                                              NULL,
                                              NULL,
                                              NULL,
                                              NULL,
                                              NULL,
                                              NULL,
                                              NULL,
                                              NULL,
                                              NULL,
                                              NULL,
                                              l_payment_schedule_id,
                                              SYSDATE,
                                              SYSDATE,
                                              l_user_id_n,
                                              l_user_id_n,
                                              ln_sl_no_cnt);

                                      l_total_wire_transfer_balance :=NVL (l_ac_wire_transfer_balance, 0) + l_total_wire_transfer_balance;
                              END IF;
                              EXIT WHEN cw_wt_bal%NOTFOUND;
                    END LOOP;
           
                        FOR l_cw_cm_bal IN cw_cm_bal (l_receipt_id_n)
                        LOOP  
                           
                           ln_sl_no_cnt := ln_sl_no_cnt + 1;      
                                
                                BEGIN       
                                SELECT  nvl(sum(AMT_OFFSET),0)
                                INTO   l_sum_cm_amt_offset
                                FROM   CW_AUC_RCPT_CM_APPL_CTRL
                                WHERE  CUSTOMER_TRX_ID = l_cw_cm_bal.CUSTOMER_TRX_ID
                                            AND STATUS_CODE ='W';
                                EXCEPTION
                                        WHEN OTHERS THEN
                                        FND_MESSAGE.DEBUG('Caught in exception to calculate WT balance');
                                END;    
                                
                         l_ac_cm_balance := l_cw_cm_bal.CM_Credit_Available -l_sum_cm_amt_offset;        
                          
                         IF l_ac_cm_balance>0 THEN
                            ln_sl_no_cnt := ln_sl_no_cnt + 1;
                            IF v_flag_2 = 'Y'
                              THEN
                                 ln_cm_applied := 0;
                            END IF;

                          IF v_flag_2 = 'N'
                          THEN
                                     IF ln_total_wt_credit_applied = l_order_total
                                     THEN
                                        ln_cm_applied := 0;
                                     ELSIF ln_total_wt_credit_applied < l_order_total
                                     THEN
                                        ln_cm_required := l_order_total - ln_total_wt_credit_applied;

                                                IF ln_cm_required < l_ac_cm_balance
                                                THEN
                                                   ln_cm_applied := ln_cm_required;
                                                   v_flag_2 := 'Y';
                                                ELSIF ln_cm_required > l_ac_cm_balance
                                                THEN
                                                   ln_cm_applied := l_ac_cm_balance;
                                                   ln_total_wt_credit_applied :=
                                                      ln_total_wt_credit_applied + ln_cm_applied;
                                                ELSIF ln_cm_required = l_ac_cm_balance
                                                THEN
                                                   ln_cm_applied := ln_cm_required;
                                                   v_flag_2 := 'Y';
                                                END IF;

                                     END IF;
                             END IF;
                      
                              INSERT INTO CW_AUC_RCPT_CM_APPL_CTRL (RECORD_ID,
                                                            CW_RECEIPT_ID,
                                                            CUSTOMER_TRX_ID,
                                                            AMT_DUE_REMAINING,
                                                            AMT_OFFSET,
                                                            STATUS_CODE,
                                                            PHASE_CODE,
                                                            STATUS_DESC,
                                                            OVERRIDE_FLAG,
                                                            SOURCE_ID,
                                                            TRANSACTION_TYPE,
                                                            TRANSACTION_NUMBER,
                                                            CREDIT_AVAILABLE,
                                                            CREDIT_APPLIED,
                                                            ATTRIBUTE_CATEGORY,
                                                            ATTRIBUTE1,
                                                            ATTRIBUTE2,
                                                            ATTRIBUTE3,
                                                            ATTRIBUTE4,
                                                            ATTRIBUTE5,
                                                            ATTRIBUTE6,
                                                            ATTRIBUTE7,
                                                            ATTRIBUTE8,
                                                            ATTRIBUTE9,
                                                            ATTRIBUTE10,
                                                            ATTRIBUTE11,
                                                            ATTRIBUTE12,
                                                            ATTRIBUTE13,
                                                            ATTRIBUTE14,
                                                            ATTRIBUTE15,
                                                            APPLIED_PS_ID,
                                                            CREATION_DATE,
                                                            LAST_UPDATE_DATE,
                                                            CREATED_BY,
                                                            LAST_UPDATED_BY,
                                                            SLNO)
                          VALUES   (CW_AUC_RCPT_CM_APPL_CTRL_S.NEXTVAL,
                                  l_receipt_id_n,
                                  l_cw_cm_bal.CUSTOMER_TRX_ID,
                                  l_ac_cm_balance,
                                  ln_cm_applied,
                                  l_status_code,
                                  l_phase_code,
                                  l_status_desc,
                                  'N',
                                  l_source_id_n,
                                  l_cw_cm_bal.Transaction_Type,
                                  l_cw_cm_bal.Transaction_Number,
                                  l_ac_cm_balance,
                                  ln_cm_applied,                         
                                  NULL,
                                  NULL,
                                  'CC',
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  NULL,
                                  l_cw_cm_bal.PAYMENT_SCHEDULE_ID,
                                  SYSDATE,
                                  SYSDATE,
                                  l_user_id_n,
                                  l_user_id_n,
                                  ln_sl_no_cnt);
                           END IF;
                           EXIT WHEN cw_cm_bal%NOTFOUND;
                        
                        END LOOP;
                    END IF;
               END IF;
           END IF;
        SAVE_RECORD;   
    --FND_message.debug('TOTAL WIRE TRANSFER BALANCE '||l_total_wire_transfer_balance);
             /*****Calculating Wire Transfer Balance and showing popup message*****/
             
         IF :PARAMETER.AUCTION_ORDER = 'Y' THEN
             IF l_total_wire_transfer_balance != 0
             THEN
                l_return_alert := SHOW_ALERT ('POPUP_MSG');
             END IF;


             /*************Calculating total CREDIT BALANCE **************/
           IF l_cnt_n = 0 THEN 
            SELECT   NVL(SUM (ABS (ps.amount_due_remaining)),0)
               INTO   l_total_credit_memo
               FROM   ra_customer_trx_all rt,
                      ar_payment_schedules_all ps,
                      cw_ar_cc_post_paid_receipts cc,
                      oe_order_headers_all oe,
                      RA_CUST_TRX_TYPES_ALL rta
              WHERE       ps.customer_trx_id = rt.customer_trx_id
                      AND rta.CUST_TRX_TYPE_ID = rt.CUST_TRX_TYPE_ID
                      AND rta.name IN ('Auction Credit Memo')
                      AND ps.customer_id = rt.bill_to_customer_id
                      AND ps.CLASS = 'CM'
                      AND ps.status = 'OP'
                      AND rt.complete_flag = 'Y'
                      AND ps.customer_id = oe.sold_to_org_id
                      AND cc.source_code = 'AUC'
                      AND cc.status in ('N','E')
                      AND cc.applied_ps_id = -1
                      AND oe.header_id = cc.source_id
                      AND cc.cw_receipt_id = l_receipt_id_n;
                      
             --fnd_message.debug('WT bal : '||l_total_wire_transfer_balance);
             --fnd_message.debug('CM bal : '||l_total_credit_memo);
             
           begin
               select NVL (sum(AMT_DUE_REMAINING),0)
               into l_cm_bal
               from CW_AUC_RCPT_CM_APPL_CTRL
               where cw_receipt_id = l_receipt_id_n;
           exception
               when others then
               fnd_message.debug('Caught in exception to find total credit balance');
           end;

             --l_cm_bal := l_total_wire_transfer_balance+ l_total_credit_memo;


             /**********  disabling VIEW/OVERRIDE*********/
             IF l_cm_bal = 0
             THEN
             --fnd_message.debug('VIEW/OVERRIDE DISABLE');
                --APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.VIEW_OVERRIDE',ENABLED,PROPERTY_FALSE);
                :PARAMETER.VIEW_OVERRIDE := 'N';
                
              /**************Inserting a row in control table when no credit balance exists for customer*************/
              
                INSERT INTO CW_AUC_RCPT_CM_APPL_CTRL (          RECORD_ID,
                                                                CW_RECEIPT_ID,
                                                                CUSTOMER_TRX_ID,
                                                                WT_RECEIPT_ID,
                                                                AMT_DUE_REMAINING,
                                                                AMT_OFFSET,
                                                                STATUS_CODE,
                                                                PHASE_CODE,
                                                                STATUS_DESC,
                                                                --OVERRIDE_FLAG,
                                                                SOURCE_ID,
                                                                --TRANSACTION_TYPE,
                                                                --TRANSACTION_NUMBER,
                                                                CREDIT_AVAILABLE,
                                                                CREDIT_APPLIED,
                                                                ATTRIBUTE_CATEGORY,
                                                                ATTRIBUTE1,
                                                                ATTRIBUTE2,
                                                                ATTRIBUTE3,
                                                                ATTRIBUTE4,
                                                                ATTRIBUTE5,
                                                                ATTRIBUTE6,
                                                                ATTRIBUTE7,
                                                                ATTRIBUTE8,
                                                                ATTRIBUTE9,
                                                                ATTRIBUTE10,
                                                                ATTRIBUTE11,
                                                                ATTRIBUTE12,
                                                                ATTRIBUTE13,
                                                                ATTRIBUTE14,
                                                                ATTRIBUTE15,
                                                                --APPLIED_PS_ID,
                                                                CREATION_DATE,
                                                                LAST_UPDATE_DATE,
                                                                CREATED_BY,
                                                                LAST_UPDATED_BY
                                                                --SLNO
                                                                )
                                          VALUES   (            CW_AUC_RCPT_CM_APPL_CTRL_S.NEXTVAL,
                                                                l_receipt_id_n,
                                                                NULL,
                                                                NULL,
                                                                0,
                                                                0,
                                                                'P',
                                                                'SUBMIT GCS APPROVAL',
                                                                'Records Submitted for GCS Approval',
                                                                l_source_id_n,
                                                                0,
                                                                0,
                                                                NULL,
                                                                NULL,
                                                                'CC',
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                SYSDATE,
                                                                SYSDATE,
                                                                l_user_id_n,
                                                                l_user_id_n);
                                           COMMIT;
             ELSE
                     :PARAMETER.VIEW_OVERRIDE := 'Y';
             END IF;


             /********** calculating value for CREDIT APPLIED********/
             IF l_cm_bal > l_order_total
             THEN
                l_cm_applied := l_order_total;
             ELSIF l_cm_bal <= l_order_total
             THEN
                l_cm_applied := l_cm_bal;
             ELSE
                l_cm_applied := 0;
             END IF;



             /*********Calulating value for NET AUTH AMOUNT****************/
             IF l_cm_bal = 0
             THEN
                l_cal_net_amount := l_order_total;
                :PARAMETER.NET_AUTH_AMOUNT := 'Y';
             ELSIF l_cm_bal >= l_order_total
             THEN
                l_cal_net_amount := 0;
                :PARAMETER.NET_AUTH_AMOUNT := 'N';
             ELSE
                l_cal_net_amount := l_order_total - l_cm_bal;
                :PARAMETER.NET_AUTH_AMOUNT := 'Y';
             END IF;

            /* IF l_cal_net_amount = 0
             THEN
                :PARAMETER.NET_AUTH_AMOUNT := 'N';
             END IF;*/

             /***********UPDATING DATA IN BASE TABLE******************/
             
             BEGIN
             SELECT NVL(SUM(CREDIT_APPLIED),0)
             INTO l_cm_applied_mod
             FROM CW_AUC_RCPT_CM_APPL_CTRL
             WHERE cw_receipt_id = l_receipt_id_n;
             EXCEPTION
             	WHEN OTHERS THEN
             		FND_MESSAGE.DEBUG('CAUGHT IN EXCEPTION TO FIND OUT l_cm_applied');
             END;
              
             UPDATE   CW_AR_CC_POST_PAID_RECEIPTS
                SET                                         
                   RECEIPT_AMOUNT = l_cal_net_amount,
                      ATTRIBUTE4 = l_cm_applied_mod,
                      ATTRIBUTE5 = l_order_total,
                      ATTRIBUTE7 = l_cm_bal
              WHERE   cw_receipt_id = l_receipt_id_n;
                            commit;
                            
              
             /**** updating AMOUNT OFFSET in Control table after override ****/
             FOR i IN cw_amt_ofset (l_receipt_id_n)
             LOOP
                UPDATE   CW_AUC_RCPT_CM_APPL_CTRL
                   SET   AMT_OFFSET = CREDIT_APPLIED,
                                LAST_UPDATE_DATE = sysdate,
                                LAST_UPDATED_BY = l_user_id_n;

                COMMIT;
                EXIT WHEN cw_amt_ofset%NOTFOUND;
             END LOOP;
             
             /*FOR l_cw_amt_ofset in cw_amt_ofset (l_receipt_id_n)
             LOOP
                         IF l_cw_amt_ofset.AMT_OFFSET =0 THEN
                             UPDATE   CW_AUC_RCPT_CM_APPL_CTRL
                       SET      STATUS_DESC = 'Unused',
                                        PHASE_CODE  = 'Unused';
                      COMMIT;
                         END IF;

                EXIT WHEN cw_amt_ofset%NOTFOUND;
             END LOOP;*/
                       
             /***********Updating status_code in control table as "Unsued" where amount_offset=0***********/
             
            
           ELSIF l_cnt_n> 0 AND l_cntrl_cnt_n> 0 THEN
            
               begin
               select NVL (sum(AMT_DUE_REMAINING),0)
               into l_cm_bal
               from CW_AUC_RCPT_CM_APPL_CTRL
               where cw_receipt_id = l_receipt_id_n
                     and l_status_code = 'X'
                     and l_phase_code = 'LOCKED';
                     /*and STATUS_CODE='P'
                     and l_phase_code = 'RETRY GCS APPROVAL'*/
                exception
               when others then
               fnd_message.debug('Caught in exception to find total credit balance');
               end;

             --l_cm_bal := l_total_wire_transfer_balance+ l_total_credit_memo;


             /**********  disabling VIEW/OVERRIDE*********/
             IF l_cm_bal = 0
             THEN
             --fnd_message.debug('VIEW/OVERRIDE DISABLE');
                --APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.VIEW_OVERRIDE',ENABLED,PROPERTY_FALSE);
                :PARAMETER.VIEW_OVERRIDE := 'N';
                
              /**************Inserting a row in control table when no credit balance exists for customer*************/
              
                INSERT INTO CW_AUC_RCPT_CM_APPL_CTRL (          RECORD_ID,
                                                                CW_RECEIPT_ID,
                                                                CUSTOMER_TRX_ID,
                                                                WT_RECEIPT_ID,
                                                                AMT_DUE_REMAINING,
                                                                AMT_OFFSET,
                                                                STATUS_CODE,
                                                                PHASE_CODE,
                                                                STATUS_DESC,
                                                                --OVERRIDE_FLAG,
                                                                SOURCE_ID,
                                                                --TRANSACTION_TYPE,
                                                                --TRANSACTION_NUMBER,
                                                                CREDIT_AVAILABLE,
                                                                CREDIT_APPLIED,
                                                                ATTRIBUTE_CATEGORY,
                                                                ATTRIBUTE1,
                                                                ATTRIBUTE2,
                                                                ATTRIBUTE3,
                                                                ATTRIBUTE4,
                                                                ATTRIBUTE5,
                                                                ATTRIBUTE6,
                                                                ATTRIBUTE7,
                                                                ATTRIBUTE8,
                                                                ATTRIBUTE9,
                                                                ATTRIBUTE10,
                                                                ATTRIBUTE11,
                                                                ATTRIBUTE12,
                                                                ATTRIBUTE13,
                                                                ATTRIBUTE14,
                                                                ATTRIBUTE15,
                                                                --APPLIED_PS_ID,
                                                                CREATION_DATE,
                                                                LAST_UPDATE_DATE,
                                                                CREATED_BY,
                                                                LAST_UPDATED_BY
                                                                --SLNO
                                                                )
                                          VALUES   (            CW_AUC_RCPT_CM_APPL_CTRL_S.NEXTVAL,
                                                                l_receipt_id_n,
                                                                NULL,
                                                                NULL,
                                                                0,
                                                                0,
                                                                'P',
                                                                'SUBMIT GCS APPROVAL',
                                                                'Records Submitted for GCS Approval',
                                                                l_source_id_n,
                                                                0,
                                                                0,
                                                                NULL,
                                                                NULL,
                                                                'CC',
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                NULL,
                                                                SYSDATE,
                                                                SYSDATE,
                                                                l_user_id_n,
                                                                l_user_id_n);
                                           COMMIT;
             ELSE
                     :PARAMETER.VIEW_OVERRIDE := 'Y';
             END IF;


             /********** calculating value for CREDIT APPLIED********/
             IF l_cm_bal > l_order_total
             THEN
                l_cm_applied := l_order_total;
             ELSIF l_cm_bal <= l_order_total
             THEN
                l_cm_applied := l_cm_bal;
             ELSE
                l_cm_applied := 0;
             END IF;



             /*********Calulating value for NET AUTH AMOUNT****************/
             IF l_cm_bal = 0
             THEN
                l_cal_net_amount := l_order_total;
                :PARAMETER.NET_AUTH_AMOUNT := 'Y';
             ELSIF l_cm_bal >= l_order_total
             THEN
                l_cal_net_amount := 0;
                :PARAMETER.NET_AUTH_AMOUNT := 'N';
             ELSE
                l_cal_net_amount := l_order_total - l_cm_bal;
                :PARAMETER.NET_AUTH_AMOUNT := 'Y';
             END IF;

            /* IF l_cal_net_amount = 0
             THEN
                :PARAMETER.NET_AUTH_AMOUNT := 'N';
             END IF;*/

             /***********UPDATING DATA IN BASE TABLE******************/
             
             BEGIN
             SELECT NVL(SUM(CREDIT_APPLIED),0)
             INTO l_cm_applied_mod
             FROM CW_AUC_RCPT_CM_APPL_CTRL
             WHERE cw_receipt_id = l_receipt_id_n;
             EXCEPTION
             	WHEN OTHERS THEN
             		FND_MESSAGE.DEBUG('CAUGHT IN EXCEPTION TO FIND OUT l_cm_applied');
             END;
             
             UPDATE   CW_AR_CC_POST_PAID_RECEIPTS
                SET                                         
                   RECEIPT_AMOUNT = l_cal_net_amount,
                      ATTRIBUTE4 = l_cm_applied_mod,
                      ATTRIBUTE5 = l_order_total,
                      ATTRIBUTE7 = l_cm_bal
              WHERE   cw_receipt_id = l_receipt_id_n;
                            commit;
             /**** updating AMOUNT OFFSET in Control table after override ****/
             FOR i IN cw_amt_ofset (l_receipt_id_n)
             LOOP
                UPDATE   CW_AUC_RCPT_CM_APPL_CTRL
                   SET   AMT_OFFSET = CREDIT_APPLIED,
                                LAST_UPDATE_DATE = sysdate,
                                LAST_UPDATED_BY = l_user_id_n;

                COMMIT;
                EXIT WHEN cw_amt_ofset%NOTFOUND;
             END LOOP;
            --FND_MESSAGE.DEBUG('REQUERYING'); 
                /*SELECT   NVL(SUM (AMT_OFFSET),0)
                INTO     l_total_credit_memo
                FROM     CW_AUC_RCPT_CM_APPL_CTRL
                WHERE    cc.cw_receipt_id = l_receipt_id_n
                         AND TRANSACTION_TYPE 'Auction Credit Memo';
                         
                         
                SELECT NVL(SUM (AMT_OFFSET),0)
                INTO   l_total_wire_transfer_balance
                FROM     CW_AUC_RCPT_CM_APPL_CTRL
                WHERE    cc.cw_receipt_id = l_receipt_id_n
                         AND TRANSACTION_TYPE = 'AUCTION WIRE';
                         
                l_cm_bal := l_total_wire_transfer_balance+ l_total_credit_memo;
                
                
                IF l_cm_bal = 0
                    THEN
                    fnd_message.debug('VIEW/OVERRIDE DISABLE');
                --APP_ITEM_PROPERTY.SET_PROPERTY('CWARCCPM.VIEW_OVERRIDE',ENABLED,PROPERTY_FALSE);
                    :PARAMETER.VIEW_OVERRIDE := 'N';
                ELSE
                     :PARAMETER.VIEW_OVERRIDE := 'Y';
                END IF;*/
                
                EXECUTE_QUERY;
             ELSE
             	/*:CWARCCPM.CREDIT_APPLIED := :CREDIT_OVERRIDE.SUM_CREDIT_APPLIED;
             	--save_record;
             	 UPDATE   CW_AR_CC_POST_PAID_RECEIPTS
                SET
                   ATTRIBUTE4 = :CREDIT_OVERRIDE.SUM_CREDIT_APPLIED
              WHERE   cw_receipt_id = l_receipt_id_n;
                            commit;*/
            EXECUTE_QUERY;
            
           END IF;
         END IF;
                

            
             
             

    


   SET_BLOCK_PROPERTY (
      'CWARCCPM',
      DEFAULT_WHERE,
         'SOURCE_CODE = '
      || ''''
      || l_source_code_s
      || ''''
      || ' AND SOURCE_ID = '
      || l_source_id_n
   );
   SET_BLOCK_PROPERTY ('CWARCCPM', INSERT_ALLOWED, PROPERTY_FALSE);
   EXECUTE_QUERY;

   GO_ITEM ('CWARCCPM.CARD_NUMBER');

   IF :PARAMETER.AUCTION_ORDER = 'N'
   THEN
      IF :status IN ('N', 'E') OR :AUC_STATUS IN ('N', 'E')
      THEN
         :receipt_date := TRUNC (SYSDATE);
         :receipt_amount := :PARAMETER.P_ORDER_AMOUNT;
      END IF;
   END IF;
END;