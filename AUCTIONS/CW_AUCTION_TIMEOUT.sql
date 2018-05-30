PROCEDURE CW_AUCTION_TIMEOUT IS
    l_status_code_count NUMBER;
    l_last_update_date DATE;
    l_last_updated_by NUMBER;
    l_created_by NUMBER;
    l_min NUMBER;
    l_return_alert NUMBER;
BEGIN

    BEGIN
    SELECT count(1)
    INTO l_status_code_count
    FROM CW_AUC_RCPT_CM_APPL_CTRL
    WHERE CW_RECEIPT_ID = :CWARCCPM.CW_RECEIPT_ID
          and STATUS_CODE='X';
    EXCEPTION
        WHEN OTHERS THEN
            FND_MESSAGE.DEBUG('ERROR IN GETTING STATUS_CODE');
    END;

    IF l_status_code_count > 1 THEN
        
        BEGIN
        SELECT max(LAST_UPDATE_DATE)
        INTO   l_last_update_date
        FROM   CW_AUC_RCPT_CM_APPL_CTRL
        WHERE  CW_RECEIPT_ID = :CWARCCPM.CW_RECEIPT_ID;
        
        EXCEPTION
            WHEN OTHERS THEN
            FND_MESSAGE.DEBUG('ERROR IN GETTING LAST_UPDATE_DATE');
        END;
        
        BEGIN
        SELECT CREATED_BY,LAST_UPDATED_BY
        INTO   l_created_by,l_last_updated_by
        FROM   CW_AUC_RCPT_CM_APPL_CTRL
        WHERE  CW_RECEIPT_ID = :CWARCCPM.CW_RECEIPT_ID
                    AND ROWNUM=1;
        EXCEPTION
            WHEN OTHERS THEN
            FND_MESSAGE.DEBUG('ERROR IN GETTING LAST_UPDATE_DATE,CREATED_BY,LAST_UPDATED_BY');
        END;

        IF l_last_updated_by=l_created_by  THEN
            
            BEGIN
            SELECT   (SYSDATE-l_last_update_date) * 1440 
            INTO l_min 
            FROM DUAL;
            EXCEPTION
                WHEN OTHERS THEN
                FND_MESSAGE.DEBUG('ERROR IN GETTING THE TIME DIFFERENCE');
            END;

            IF l_min>3 THEN
                DELETE 
                FROM CW_AR_CC_POST_PAID_RECEIPTS
                WHERE cw_receipt_id = :CWARCCPM.CW_RECEIPT_ID;
                

                DELETE
                FROM CW_AUC_RCPT_CM_APPL_CTRL
                WHERE cw_receipt_id = :CWARCCPM.CW_RECEIPT_ID;
                COMMIT;

                l_return_alert := SHOW_ALERT ('LOCK_MSG');

                IF l_return_alert = ALERT_BUTTON1  THEN
                    EXIT_FORM(NO_VALIDATE);
                END IF;
            END IF;
        END IF;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RETURN;
END;