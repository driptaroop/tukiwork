
/********************************************************************************************
  *                   CUST_ORDER_INTERFACE_PROGRAM TO CREATE/IMPORT CUSTOMER FOR AUCTION
  *******************************************************************************************
  *
  *
  *
  * PROGRAM NAME:        CUST AUCTION CUSTOMER INTERFACE PROGRAM
  *
  * DESCRIPTION:         This file creates the error messages that are logged by the package apps.CW_AR_CC_RECEIPT_PKG
  *
  *
  *
  *
  * USAGE:
  *     To Install:      Execute package
  *     To Run:          Execute package apps.CW_AR_CC_RECEIPT_PKG
  *
  * PARAMETERS:          NONE
  *
  * DEPENDENCIES:        NONE
  *
  * CALLED BY:           This message file is used by apps.CW_AR_CC_RECEIPT_PKG package
  *
  * LAST UPDATE DATE:
  * 
  *
  * HISTORY:
  *
  * VERSION   DATE             AUTHOR                           DESCRIPTION
  * --------- ----------    --------------------         ---------------
  *  1.0      4-AUG-2014   KAUSHIKI CHOWDHURY (KC7381)        Initial Version
  *****************************************************************************/

set define off;
set serveroutput on;

DECLARE
   lv_num_appl_id   NUMBER := NULL;
BEGIN
   BEGIN
      SELECT   application_id
        INTO   lv_num_appl_id
        FROM   fnd_application_vl
       WHERE   application_name =
                  'Custom Cingular Wireless Accounts Receivable';
   EXCEPTION
      WHEN OTHERS
      THEN
         lv_num_appl_id := NULL;
   END;

   IF lv_num_appl_id IS NOT NULL
   THEN
      FOR i
      IN (SELECT   'CW_AR_CC_ACTION_AUCTION_0' message_name,
                   'ERROR IN GCS APPROVAL'
                      MESSAGE_TEXT
            FROM   DUAL
          UNION
          SELECT   'CW_AR_CC_AUTH_0' message_name,
                   'ERROR IN CC AUTHORIZATION'
                      MESSAGE_TEXT
            FROM   DUAL
          UNION
          SELECT   'CW_AR_CC_RECEIPT_0' message_name,
                   'ERROR IN CREATING CREATING CREDIT CARD FOR NET AUTH AMOUNT'
                      MESSAGE_TEXT
            FROM   DUAL
          UNION
          SELECT   'CC_GET_ON_ACC_CM_DET_0' message_name,
                   'ERROR IN APPLYING CREDIT MEMO BALANCE'
                      MESSAGE_TEXT
            FROM   DUAL
          UNION
          SELECT   'CC_GET_WT_CREDIT_DET_0' message_name,
                   'ERROR IN APPLYING WIRE TRANSFER BALANCE'
                      MESSAGE_TEXT
            FROM   DUAL
	  UNION
          SELECT   'CUST_AUCTION_CC_HOLD_RELEASE_0' message_name,
                   'ERROR IN CONCURRENT PROGRAM CUST_AUCTION_CC_HOLD_RELEASE'
                      MESSAGE_TEXT
            FROM   DUAL
          UNION
          SELECT   'CCW_PAYMENT_TYPE_CHECK' message_name,
                   'This functionality is not available for Wire Transfer payment type Orders.'
                      MESSAGE_TEXT
            FROM   DUAL
          UNION
          SELECT   'CCW_CREDIT_APPLIED_CHECK' message_name,
                   'Credit Applied should always be less than Credit Available.'
                      MESSAGE_TEXT
            FROM   DUAL
          UNION
          SELECT   'CCW_SUM_CREDIT_APPLIED_CHECK' message_name,
                   'Total Credit Applied should be less than Order Total'
                      MESSAGE_TEXT
            FROM   DUAL
          )
      LOOP
         fnd_new_messages_pkg.load_row (
            x_application_id     => lv_num_appl_id,
            x_message_name       => i.message_name,
            x_message_number     => NULL,
            x_message_text       => i.MESSAGE_TEXT,
            x_description        => 'Messages for AUC CUSTOMER IMPORT',
            x_type               => 'AUC_CUSTOMER_IMPORT',
            --'30_PCT_EXPANSION_PROMPT',
            x_max_length         => NULL,
            x_category           => NULL,
            x_severity           => NULL,
            x_fnd_log_severity   => NULL,
            x_owner              => NULL,
            x_custom_mode        => NULL,
            x_last_update_date   => NULL
         );
         COMMIT;
      END LOOP;
   END IF;

   COMMIT;
END;
/


SHOW ERROR
EXIT;