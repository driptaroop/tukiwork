/********************************************************************************************
  *                   Credit Card Authorization API
  ********************************************************************************************
  *
  *
  *
  * PROGRAM NAME:        Credit Card Authorization
  *
  * DESCRIPTION:         This program validates the Credit Card Details entered.
  *
  *
  *
  *
  * USAGE:
  *     To Install:      Execute package
  *     To Run:          Execute package Credit Card Authorization
  *
  * PARAMETERS:          
  *
  * DEPENDENCIES:        NONE
  *
  * CALLED BY:           This package will be called by the Credit Card Zoom Form on the Sales Order form
  *
  * LAST UPDATE DATE:
  *
  * HISTORY:
  *
  * VERSION   DATE         AUTHOR                           DESCRIPTION
  * --------- ----------   --------------------			    ---------------
  *  1.0																	 Initial Version
  *  2.0       13-AUG-14   Kaushiki Chowdhury (KC7381)    Changes for Auctions project
  ****************************************************************************/
CREATE OR REPLACE PACKAGE APPS.CW_AR_CC_RECEIPT_PKG
AS
TYPE master_rec_type IS RECORD(
        child_rec       cw_ar_cc_post_paid_receipts_v%ROWTYPE,
        payee_id        VARCHAR2(30),
        merchant_id     VARCHAR2(30),
        method_id       NUMBER,
        org_id          NUMBER,
        app_id          NUMBER
        );

PROCEDURE CW_AR_CC_ACTION(in_ref_n          IN     NUMBER,
                          p_crd_card_num    IN  cw_ar_cc_post_paid_receipts.card_number%TYPE, -- MHN
                          p_exp_date        IN  cw_ar_cc_post_paid_receipts.expiry_date%TYPE, -- MHN
                          p_cvv2            IN  cw_ar_cc_post_paid_receipts.cvv2%TYPE,         -- MHN
                          p_blng_zip        IN  cw_ar_cc_post_paid_receipts.zip%TYPE,         -- MHN
                          p_card_hldr_name  IN  cw_ar_cc_post_paid_receipts.card_holder_name%TYPE, -- MHN
                          out_status_c      OUT    VARCHAR2,
                          out_text_s        OUT    VARCHAR2,
                          out_appcode_s     OUT    VARCHAR2,
                          out_receipt_id_n  OUT    NUMBER,
                          out_tang_id_s     OUT    VARCHAR2,
                          out_merchant_id_s OUT    VARCHAR2);


PROCEDURE CW_AR_CC_ACTION_AUCTION(in_ref_n          IN     NUMBER,
                          p_net_auth_amount IN        NUMBER,
                          p_crd_card_num    IN  cw_ar_cc_post_paid_receipts.card_number%TYPE, -- MHN
                          p_exp_date        IN  cw_ar_cc_post_paid_receipts.expiry_date%TYPE, -- MHN
                          p_cvv2            IN  cw_ar_cc_post_paid_receipts.cvv2%TYPE,         -- MHN
                          p_blng_zip        IN  cw_ar_cc_post_paid_receipts.zip%TYPE,         -- MHN
                          p_card_hldr_name  IN  cw_ar_cc_post_paid_receipts.card_holder_name%TYPE, -- MHN
                          p_order_number    IN     NUMBER,
                          out_status_c      OUT    VARCHAR2,
                          out_text_s        OUT    VARCHAR2,
                          out_appcode_s     OUT    VARCHAR2,
                          out_receipt_id_n  OUT    NUMBER,
                          out_tang_id_s     OUT    VARCHAR2,
                          out_merchant_id_s OUT    VARCHAR2);

FUNCTION GET_TANGIBLE_ID(in_source_s VARCHAR2) RETURN VARCHAR2;

PROCEDURE GET_FUNCTION_VALUES(in_status_s     IN  VARCHAR2,
                              in_id_n         IN  NUMBER,
                              out_function_s  OUT VARCHAR2,
                              out_parameter_s OUT VARCHAR2);

PROCEDURE CW_AR_CC_PREPAID_AUTO_APPLY(out_errbuf_s      OUT     VARCHAR2,
                                      out_errnum_n      OUT     NUMBER,
                                      in_customer_id_n  IN      NUMBER,
                                      in_debug_c        IN      VARCHAR2);
                                      
PROCEDURE CC_GET_WT_CREDIT_DET (io_data_rec   IN OUT master_rec_type,
                                X_OUT            OUT VARCHAR2);
                                
PROCEDURE CC_GET_ON_ACC_CM_DET (io_data_rec     IN OUT master_rec_type,
                                X_OUT            OUT VARCHAR2);
                                
PROCEDURE CW_AR_CC_RECEIPT(io_data_rec     IN OUT master_rec_type);

g_batch_source_rec      ra_batch_sources%ROWTYPE;
g_cust_trx_type_rec     ra_cust_trx_types%ROWTYPE;
g_memo_line_rec         ar_memo_lines_vl%ROWTYPE;

END CW_AR_CC_RECEIPT_PKG;
/
SHOW ERRORS PACKAGE CW_AR_CC_RECEIPT_PKG

/********************************************************************************************
  *                   Credit Card Authorization API
  ********************************************************************************************
  *
  *
  *
  * PROGRAM NAME:        Credit Card Authorization
  *
  * DESCRIPTION:         This program validates the Credit Card Details entered.
  *
  *
  *
  *
  * USAGE:
  *     To Install:      Execute package
  *     To Run:          Execute package Credit Card Authorization
  *
  * PARAMETERS:          
  *
  * DEPENDENCIES:        NONE
  *
  * CALLED BY:           This package will be called by the Credit Card Zoom Form on the Sales Order form
  *
  * LAST UPDATE DATE:
  *
  * HISTORY:
  *
  * VERSION   DATE         AUTHOR                           DESCRIPTION
  * --------- ----------   --------------------			    ---------------
  *  1.0																	 Initial Version
  *  2.0       13-AUG-14   Kaushiki Chowdhury (KC7381)    Changes for Auctions project
  ****************************************************************************/
set define off
CREATE OR REPLACE PACKAGE BODY APPS.CW_AR_CC_RECEIPT_PKG
AS

   -- Global declarations

   gv_request_id               NUMBER := FND_GLOBAL.CONC_REQUEST_ID;
   gv_login_id                 VARCHAR2 (20) := FND_GLOBAL.LOGIN_ID;
   gv_user_id                  VARCHAR2 (20) := FND_GLOBAL.USER_ID;
   gv_user_name                VARCHAR2 (50) := FND_GLOBAL.USER_NAME;
   gv_org_id                   NUMBER := FND_GLOBAL.ORG_ID;
   g_staging_table_id          NUMBER;
   gv_program_application_id   NUMBER;
   gv_program_id               NUMBER;
   gv_process_id               NUMBER;
   gv_debug_file               VARCHAR2 (10) := 'Y';
   lv_error_name               VARCHAR2 (200);


     ----STATISTICS OF RECORDS PROCESSED----
      ln_customer_created              NUMBER := 0;
      ln_customer_errored              NUMBER := 0;
      ln_total_bill_to                           NUMBER := 0;
      ln_total_ship_to                        NUMBER := 0;
      ln_total_bill_to_error              NUMBER := 0;
      ln_total_ship_to_error           NUMBER := 0;


   -- Procedure for logging messages
   -- ------------------------------
   PROCEDURE write_log (p_msg IN VARCHAR2)
   IS
   BEGIN
      IF gv_debug_file = 'Y'
      THEN
         fnd_file.put_line (fnd_file.LOG, p_msg);
      END IF;
   END;

   -- Procedure to log error messages
   -- -------------------------------

   PROCEDURE INSERT_ERROR (p_staging_table_id        IN     NUMBER,
                           p_record_identifier       IN     VARCHAR2,
                           p_proc_name               IN     VARCHAR2,
                           p_source_field_name       IN     VARCHAR2,
                           p_source_field_value      IN     VARCHAR2,
                           p_message_name            IN     VARCHAR2,
                           p_token_list              IN     VARCHAR2,
                           p_value_list              IN     VARCHAR2,
                           x_return_code             OUT VARCHAR2,
                           x_error                   OUT VARCHAR2)
   IS
      lv_request_id      VARCHAR2 (40);
      lv_return_status   VARCHAR2 (100);
      lv_error           VARCHAR2 (1000);
        p_error_level varchar2(10):= 'E';
        p_error_code    varchar2(10) := NULL;
        p_error_description varchar2(10):= NULL;
        p_originating_system_name varchar2(10):= 'O';
        p_err_type varchar2(10):= 'C';

   BEGIN
      ccw_mm_utility_package.ccw_set_error_active_flag (
         p_table_name          => 'CCW_GLBL_IF_ERR_TRX',
         p_interface_name      => 'ORA.AUC.CC.AUTH',
         p_record_identifier   => NVL (p_record_identifier, 0),
         p_user                => fnd_global.user_name,
         p_return_code         => lv_return_status
      );

      IF lv_return_status = 'FAILURE'
      THEN
         write_log ('Error when inactivating an error record in the error table');
      END IF;

      ccw_record_err_msg.ccw_build_err (
         p_procedure_name            => 'CW_AR_CC_RECEIPT_PKG',
         p_record_identifier         => NVL (p_record_identifier, 0),
         p_error_level               => p_error_level,
         p_ora_error_code            => p_error_code,
         p_ora_error_description     => p_error_description,
         p_source_field_name         => p_source_field_name,
         p_source_field_value        => p_source_field_value,
         p_error_table               => 'CCW_GLBL_IF_ERR_TRX',
         p_staging_table             => 'CW_AUC_RCPT_CM_APPL_CTRL',
         p_staging_table_id          => p_staging_table_id,
         p_interface_name            => 'ORA.AUC.CC.AUTH',
         p_originating_system_name   => p_originating_system_name,
         p_if_direction              => 'INBOUND',
         p_appl_short_name           => 'CCWAR',
         p_message_name              => p_message_name,
         p_token_list                => p_token_list,
         p_value_list                => p_value_list,
         p_err_type                  => p_err_type,
         p_org_code                  => NULL,
         p_process_level             => 'STG',
        p_attribute1                => NULL,
         p_attribute2                => NULL,
         p_attribute3                => NULL,
         p_attribute4                => NULL,
         p_attribute5                => NULL,
         p_attribute6                => NULL,
         p_attribute7                => NULL,
         p_attribute8                => NULL,
         p_request_id                => gv_request_id,
         p_process_id                => 0,
         p_user_name                 => NVL (gv_user_name, 'ANONYMOUS'),
         x_return_code               => lv_return_status,
         x_return_msg                => lv_error
      );

      IF lv_return_status != 'SUCCESSFUL'
      THEN
         FND_FILE.PUT_LINE (FND_FILE.LOG,'Error calling global error procedure: ' || lv_error);
         FND_FILE.put_line (FND_FILE.log,'Error calling global error procedure: ' || lv_error);
      END IF;
   END;

PROCEDURE cw_format_string(     io_msg_count_n  IN OUT NUMBER,
                                io_msg_data_s   IN OUT VARCHAR2)
IS
BEGIN
        IF (io_msg_count_n > 1)
        THEN
                FOR I IN 1..io_msg_count_n
                LOOP
                        io_msg_data_s := io_msg_data_s || TO_CHAR(I) || '. ' || SubStr(FND_MSG_PUB.Get(p_encoded => FND_API.G_FALSE ), 1, 255)||CHR(10);
                END LOOP;
        END IF;
EXCEPTION
WHEN OTHERS
THEN
    WRITE_CC_AUTH_DEBUG('Error in CW_format_String :'||sqlerrm,NULL);
END;

PROCEDURE CW_AR_CC_PREPAID_AUTO_APPLY(out_errbuf_s      OUT     VARCHAR2,
                                      out_errnum_n      OUT     NUMBER,
                                      in_customer_id_n  IN      NUMBER,
                                      in_debug_c        IN      VARCHAR2)
IS
        CURSOR  cw_ont_cc
        IS      SELECT  cc.account_number,
                        ps.cash_receipt_id,
                        ps.payment_schedule_id,
                        ABS(ps.amount_due_original)   amount_due_original,
                        ABS(ps.amount_due_remaining)  amount_due_remaining,
                        ps.trx_number,
                        ps.trx_date,
                        ps.customer_id,
                        cc.order_number,
                        cc.cust_po_number,
                        cc.row_id,
                        cc.applied_ps_id
                FROM    cw_ar_cc_post_paid_receipts_v cc,
                        ar_payment_schedules          ps
                WHERE   cc.source_code                = 'ONT'
                AND     cc.status                     = 'R'
                AND     cc.applied_ps_id              = -1
                AND     cc.receipt_amount             > 0
                AND     cc.cust_account_id            = NVL(in_customer_id_n,cc.cust_account_id)
                AND     cc.trx_type                   = 'AUTHONLY'
                AND     ps.cash_receipt_id            = cc.ar_receipt_id
                AND     ps.status                     = 'OP'
                AND     ps.class                      = 'PMT'
                AND     ps.amount_due_remaining       < 0;

        CURSOR  cw_ar_inv(in_po_num_s       VARCHAR2,
                          in_order_number_s VARCHAR2,
                          in_customer_id_n  NUMBER,
                          in_receipt_id_n   NUMBER)
        IS      SELECT  ps.payment_schedule_id,
                        ABS(ps.amount_due_original)     amount_due_original,
                        ABS(ps.amount_due_remaining)    amount_due_remaining,
                        ps.customer_trx_id,
                        ps.trx_number,
                        ps.trx_date,
                        ps.due_date
                FROM    ra_customer_trx                 trx,
                        ar_payment_schedules            ps
                WHERE   ps.customer_id                  = in_customer_id_n
                AND     ps.status                       = 'OP'
                AND     ps.class                        = 'INV'
                AND     ps.amount_due_remaining         > 0
                AND     trx.customer_trx_id             = ps.customer_trx_id
                AND     trx.batch_source_id             IN (SELECT batch_source_id
                                                            FROM   ra_batch_sources
                                                            WHERE  name = 'Order Management')
                AND     trx.interface_header_context    = 'ORDER ENTRY'
                AND     trx.interface_header_attribute1 = in_order_number_s
                AND     NOT EXISTS (SELECT 1
                                    FROM   ar_receivable_applications
                                    WHERE  cash_receipt_id         = in_receipt_id_n
                                    AND    applied_customer_trx_id = trx.customer_trx_id)
                ORDER BY ps.due_date;

        l_ar_inv_rec            cw_ar_inv%ROWTYPE;
        l_amount_n              NUMBER;
        x_return_status         VARCHAR2(2000);
        x_msg_count             NUMBER;
        x_msg_data              VARCHAR2(5000);
        p_api_version           NUMBER:=1.0;
        p_init_msg_list         VARCHAR2(2000):=FND_API.G_TRUE;
        p_commit                VARCHAR2(2000):=FND_API.G_FALSE;
        p_validation_level      NUMBER:=FND_API.G_VALID_LEVEL_FULL;
        l_sysdate_d             DATE:=TRUNC(SYSDATE);
        l_cnt_n                 NUMBER;
        l_userid_n              NUMBER:=FND_GLOBAL.USER_ID;
        l_loginid_n             NUMBER:=FND_GLOBAL.LOGIN_ID;

        PROCEDURE cw_output(in_text_s VARCHAR2)
        IS
        BEGIN
                FND_FILE.PUT_LINE(FND_FILE.OUTPUT,in_text_s);
        END;

        PROCEDURE cw_debug(in_text_s VARCHAR2)
        IS
        BEGIN
                IF in_debug_c = 'Y'
                THEN
                        FND_FILE.PUT_LINE(FND_FILE.LOG,in_text_s);
                END IF;
        END;
BEGIN
        out_errbuf_s := NULL;
        out_errnum_n := 0;

        SELECT COUNT(*)
        INTO   l_cnt_n
        FROM   gl_period_statuses
        WHERE  application_id = 222
        AND    l_sysdate_d BETWEEN TRUNC(start_date) and TRUNC(end_date)
        AND    closing_status = 'O';

        IF l_cnt_n = 0
        THEN
                out_errbuf_s := 'GL Period is not open for the current date '||l_sysdate_d;
                out_errnum_n := 2;
                RETURN;
        END IF;

        cw_output('CW Prepaid CC Receipts Auto Application Exception Report');
        cw_output('--------------------------------------------------------');
        cw_output('');

        FOR l_ont_rec IN cw_ont_cc
        LOOP
                cw_debug('----------------------------------------------------------------------------------------');
                cw_debug('l_ont_rec.account_number  => ' || l_ont_rec.account_number);
                cw_debug('l_ont_rec.cust_po_number  => ' || l_ont_rec.cust_po_number);
                cw_debug('l_ont_rec.order_number    => ' || l_ont_rec.order_number);
                cw_debug('l_ont_rec.customer_id     => ' || l_ont_rec.customer_id);
                cw_debug('l_ont_rec.cash_receipt_id => ' || l_ont_rec.cash_receipt_id);
                cw_debug('l_ont_rec.cust_po_number  => ' || l_ont_rec.cust_po_number);

                FOR l_ar_inv_rec IN cw_ar_inv(l_ont_rec.cust_po_number,
                                              l_ont_rec.order_number,
                                              l_ont_rec.customer_id,
                                              l_ont_rec.cash_receipt_id)
                LOOP
                        IF l_ont_rec.amount_due_remaining > 0
                        THEN
                                IF l_ar_inv_rec.amount_due_remaining <= l_ont_rec.amount_due_remaining
                                THEN
                                        l_amount_n := l_ar_inv_rec.amount_due_remaining;
                                ELSE
                                        l_amount_n := l_ont_rec.amount_due_remaining;
                                END IF;

                                AR_RECEIPT_API_PUB.APPLY(
                                        p_api_version          => p_api_version,
                                        p_init_msg_list        => p_init_msg_list,
                                        p_commit               => p_commit,
                                        p_validation_level     => p_validation_level,
                                        x_return_status        => x_return_status,
                                        x_msg_count            => x_msg_count,
                                        x_msg_data             => x_msg_data,
                                        p_cash_receipt_id      => l_ont_rec.cash_receipt_id,
                                        p_customer_trx_id      => l_ar_inv_rec.customer_trx_id,
                                        p_amount_applied       => l_amount_n,
                                        p_apply_date           => l_sysdate_d,
                                        p_apply_gl_date        => l_sysdate_d);

                                cw_debug('');
                                cw_debug('Customer#               : ' || l_ont_rec.account_number);
                                cw_debug('Receipt#                : ' || l_ont_rec.trx_number);
                                cw_debug('Receipt Date            : ' || l_ont_rec.trx_date);
                                cw_debug('Receipt Original Amount : ' || l_ont_rec.amount_due_original);
                                cw_debug('Receipt Balance  Amount : ' || l_ont_rec.amount_due_remaining);
                                cw_debug('Customer Trx Id         : ' || l_ar_inv_rec.customer_trx_id);
                                cw_debug('Invoice#                : ' || l_ar_inv_rec.trx_number);
                                cw_debug('Invoice Date            : ' || l_ar_inv_rec.trx_date);
                                cw_debug('Invoice Original Amount : ' || l_ar_inv_rec.amount_due_original);
                                cw_debug('Invoice Balance  Amount : ' || l_ar_inv_rec.amount_due_remaining);
                                cw_debug('Auto Application Amount : ' || l_amount_n);
                                cw_debug('Auto Application Status : ' || x_return_status);

                                IF x_return_status = FND_API.G_RET_STS_SUCCESS
                                THEN
                                        l_ont_rec.amount_due_remaining := ABS(l_ont_rec.amount_due_remaining - l_amount_n);

                                        IF l_ont_rec.amount_due_remaining = 0
                                        THEN
                                                l_ont_rec.applied_ps_id := l_ar_inv_rec.payment_schedule_id;
                                        ELSE
                                                l_ont_rec.applied_ps_id := l_ont_rec.applied_ps_id;
                                        END IF;

                                        UPDATE  cw_ar_cc_post_paid_receipts
                                        SET     applied_ps_id     = l_ont_rec.applied_ps_id,
                                                last_update_date  = SYSDATE,
                                                last_updated_by   = l_userid_n,
                                                last_update_login = l_loginid_n
                                        WHERE   rowid             = l_ont_rec.row_id;
                                        FND_CONCURRENT.AF_COMMIT;
                                ELSE
                                        out_errbuf_s := 'One or more prepaid receipts not applied to open invoices due to error. Please review the concurrent program output for error details';
                                        out_errnum_n := 2;
                                        cw_format_string( io_msg_count_n => x_msg_count,
                                                          io_msg_data_s  => x_msg_data);
                                        cw_output('Customer#               : ' || l_ont_rec.account_number);
                                        cw_output('Receipt#                : ' || l_ont_rec.trx_number);
                                        cw_output('Receipt Date            : ' || l_ont_rec.trx_date);
                                        cw_output('Receipt Original Amount : ' || l_ont_rec.amount_due_original);
                                        cw_output('Receipt Balance  Amount : ' || l_ont_rec.amount_due_remaining);
                                        cw_output('Invoice#                : ' || l_ar_inv_rec.trx_number);
                                        cw_output('Invoice Date            : ' || l_ar_inv_rec.trx_date);
                                        cw_output('Invoice Original Amount : ' || l_ar_inv_rec.amount_due_original);
                                        cw_output('Invoice Balance  Amount : ' || l_ar_inv_rec.amount_due_remaining);
                                        cw_output('Auto Application Amount : ' || l_amount_n);
                                        cw_output('Auto Application Error  : ' || x_msg_data);
                                        cw_output('');
                                        FND_CONCURRENT.AF_ROLLBACK;
                                END IF;
                        END IF;
                END LOOP;
        END LOOP;
EXCEPTION
        WHEN OTHERS THEN
                out_errbuf_s := SQLERRM;
                out_errnum_n := 2;
                ROLLBACK;
END;

PROCEDURE GET_FUNCTION_VALUES(in_status_s     IN  VARCHAR2,
                              in_id_n         IN  NUMBER,
                              out_function_s  OUT VARCHAR2,
                              out_parameter_s OUT VARCHAR2)
IS
        l_trx_id_n      NUMBER;
BEGIN
        IF  (in_status_s = 'R')
        THEN
                out_function_s  := 'AR_ARXRWMAI_HEADER';
                out_parameter_s := 'FP_CASH_RECEIPT_ID='||in_id_n;
        ELSIF(in_status_s = 'D')
        THEN
                BEGIN
                        SELECT  pay.payment_schedule_id
                        INTO    l_trx_id_n
                        FROM    ra_customer_trx_lines    trx,
                                ar_payment_schedules     pay
                        WHERE   trx.customer_trx_line_id = in_id_n
                        AND     pay.customer_trx_id      = trx.customer_trx_id;

                        out_function_s  := 'AR_ARXCWMAI_QIT';
                        out_parameter_s := 'PAYMENT_SCHEDULE_ID='||l_trx_id_n;
                EXCEPTION
                        WHEN OTHERS THEN
                                out_function_s  := NULL;
                                out_parameter_s := 'Auto-Invoice process for debitmemo is not completed';
                END;
        END IF;
END;
-- Commented to replace the changes CQ# WUP00062366 changes DM dist CCID
/*
PROCEDURE CW_AR_CC_DEBITMEMO(io_data_rec   IN OUT  master_rec_type)
IS
        l_line_rec      ra_interface_lines_all%ROWTYPE;
        l_srep_rec      ra_interface_salescredits_all%ROWTYPE;
BEGIN
        SELECT  RA_CUSTOMER_TRX_LINES_S.nextval
        INTO    io_data_rec.child_rec.ar_receipt_id
        FROM    DUAL;

        SELECT  RA_CUST_TRX_LINE_SALESREPS_S.nextval
        INTO    l_srep_rec.INTERFACE_SALESCREDIT_ID
        FROM    DUAL;


        l_line_rec.INTERFACE_LINE_ID            := io_data_rec.child_rec.ar_receipt_id;
        l_line_rec.INTERFACE_LINE_CONTEXT       := g_batch_source_rec.name;
        l_line_rec.INTERFACE_LINE_ATTRIBUTE1    := TO_CHAR(io_data_rec.child_rec.cw_receipt_id);
        l_line_rec.INTERFACE_LINE_ATTRIBUTE2    := io_data_rec.child_rec.tangible_id;
        l_line_rec.BATCH_SOURCE_NAME            := g_batch_source_rec.name;
        l_line_rec.SET_OF_BOOKS_ID              := g_memo_line_rec.set_of_books_id;
        l_line_rec.LINE_TYPE                    := 'LINE';
        l_line_rec.DESCRIPTION                  := g_batch_source_rec.description;
        l_line_rec.CURRENCY_CODE                := 'USD';
        l_line_rec.AMOUNT                       := ABS(io_data_rec.child_rec.receipt_amount);
        l_line_rec.CUST_TRX_TYPE_NAME           := g_cust_trx_type_rec.name;
        l_line_rec.CUST_TRX_TYPE_ID             := g_cust_trx_type_rec.cust_trx_type_id;
        l_line_rec.TERM_ID                      := g_cust_trx_type_rec.default_term;
        l_line_rec.CONVERSION_TYPE              := 'User';
        l_line_rec.CONVERSION_DATE              := io_data_rec.child_rec.receipt_date;
        l_line_rec.CONVERSION_RATE              := 1;
        l_line_rec.TRX_DATE                     := io_data_rec.child_rec.receipt_date;
        l_line_rec.GL_DATE                      := io_data_rec.child_rec.receipt_date;
        l_line_rec.TRX_NUMBER                   := TO_CHAR(io_data_rec.child_rec.cw_receipt_id);
        l_line_rec.LINE_NUMBER                  := 1;
        l_line_rec.PRIMARY_SALESREP_ID          := io_data_rec.child_rec.salesrep_id;
        l_line_rec.MEMO_LINE_NAME               := g_memo_line_rec.name;
        l_line_rec.MEMO_LINE_ID                 := g_memo_line_rec.memo_line_id;
        l_line_rec.COMMENTS                     := io_data_rec.child_rec.comments;
        l_line_rec.INTERNAL_NOTES               := io_data_rec.child_rec.comments;
        l_line_rec.ORIG_SYSTEM_BILL_CUSTOMER_ID := io_data_rec.child_rec.cust_account_id;
        l_line_rec.ORIG_SYSTEM_BILL_ADDRESS_ID  := io_data_rec.child_rec.cust_acct_site_id;
        l_line_rec.org_id                       := io_data_rec.org_id;


        l_srep_rec.INTERFACE_LINE_ID            := l_line_rec.INTERFACE_LINE_ID;
        l_srep_rec.INTERFACE_LINE_CONTEXT       := l_line_rec.INTERFACE_LINE_CONTEXT;
        l_srep_rec.INTERFACE_LINE_ATTRIBUTE1    := l_line_rec.INTERFACE_LINE_ATTRIBUTE1;
        l_srep_rec.INTERFACE_LINE_ATTRIBUTE2    := l_line_rec.INTERFACE_LINE_ATTRIBUTE2;
        l_srep_rec.SALESREP_ID                  := l_line_rec.PRIMARY_SALESREP_ID;
        l_srep_rec.SALES_CREDIT_TYPE_ID         := 1;
        l_srep_rec.SALES_CREDIT_PERCENT_SPLIT   := 100;
        l_srep_rec.ORG_ID                       := l_line_rec.org_id;

        INSERT
        INTO    ra_interface_lines_all
        VALUES  l_line_rec;

        INSERT
        INTO    ra_interface_salescredits_all
        VALUES  l_srep_rec;
END;
*/
PROCEDURE CW_AR_CC_DEBITMEMO(io_data_rec   IN OUT  master_rec_type)
IS
        l_line_rec      ra_interface_lines_all%ROWTYPE;
        l_srep_rec      ra_interface_salescredits_all%ROWTYPE;
        l_dist_rec      ra_interface_distributions_all%ROWTYPE;
BEGIN
        SELECT  RA_CUSTOMER_TRX_LINES_S.nextval
        INTO    io_data_rec.child_rec.ar_receipt_id
        FROM    DUAL;

        SELECT  RA_CUST_TRX_LINE_SALESREPS_S.nextval
        INTO    l_srep_rec.INTERFACE_SALESCREDIT_ID
        FROM    DUAL;

        SELECT  RA_CUST_TRX_LINE_GL_DIST_S.nextval
        INTO    l_dist_rec.INTERFACE_DISTRIBUTION_ID
        FROM    DUAL;

        l_line_rec.INTERFACE_LINE_ID            := io_data_rec.child_rec.ar_receipt_id;
        l_line_rec.INTERFACE_LINE_CONTEXT       := g_batch_source_rec.name;
        l_line_rec.INTERFACE_LINE_ATTRIBUTE1    := TO_CHAR(io_data_rec.child_rec.cw_receipt_id);
        l_line_rec.INTERFACE_LINE_ATTRIBUTE2    := io_data_rec.child_rec.tangible_id;
        l_line_rec.BATCH_SOURCE_NAME            := g_batch_source_rec.name;
        l_line_rec.SET_OF_BOOKS_ID              := g_memo_line_rec.set_of_books_id;
        l_line_rec.LINE_TYPE                    := 'LINE';
        l_line_rec.DESCRIPTION                  := g_batch_source_rec.description;
        l_line_rec.CURRENCY_CODE                := 'USD';
        l_line_rec.AMOUNT                       := ABS(io_data_rec.child_rec.receipt_amount);
        l_line_rec.CUST_TRX_TYPE_NAME           := g_cust_trx_type_rec.name;
        l_line_rec.CUST_TRX_TYPE_ID             := g_cust_trx_type_rec.cust_trx_type_id;
        l_line_rec.TERM_ID                      := g_cust_trx_type_rec.default_term;
        l_line_rec.CONVERSION_TYPE              := 'User';
        l_line_rec.CONVERSION_DATE              := io_data_rec.child_rec.receipt_date;
        l_line_rec.CONVERSION_RATE              := 1;
        l_line_rec.TRX_DATE                     := io_data_rec.child_rec.receipt_date;
        l_line_rec.GL_DATE                      := io_data_rec.child_rec.receipt_date;
        l_line_rec.TRX_NUMBER                   := TO_CHAR(io_data_rec.child_rec.cw_receipt_id);
        l_line_rec.LINE_NUMBER                  := 1;
        l_line_rec.PRIMARY_SALESREP_ID          := io_data_rec.child_rec.salesrep_id;
        l_line_rec.MEMO_LINE_NAME               := g_memo_line_rec.name;
        l_line_rec.MEMO_LINE_ID                 := g_memo_line_rec.memo_line_id;
        l_line_rec.COMMENTS                     := io_data_rec.child_rec.comments;
        l_line_rec.INTERNAL_NOTES               := io_data_rec.child_rec.comments;
        l_line_rec.ORIG_SYSTEM_BILL_CUSTOMER_ID := io_data_rec.child_rec.cust_account_id;
        l_line_rec.ORIG_SYSTEM_BILL_ADDRESS_ID  := io_data_rec.child_rec.cust_acct_site_id;
        l_line_rec.org_id                       := io_data_rec.org_id;


        l_srep_rec.INTERFACE_LINE_ID            := l_line_rec.INTERFACE_LINE_ID;
        l_srep_rec.INTERFACE_LINE_CONTEXT       := l_line_rec.INTERFACE_LINE_CONTEXT;
        l_srep_rec.INTERFACE_LINE_ATTRIBUTE1    := l_line_rec.INTERFACE_LINE_ATTRIBUTE1;
        l_srep_rec.INTERFACE_LINE_ATTRIBUTE2    := l_line_rec.INTERFACE_LINE_ATTRIBUTE2;
        l_srep_rec.SALESREP_ID                  := l_line_rec.PRIMARY_SALESREP_ID;
        l_srep_rec.SALES_CREDIT_TYPE_ID         := 1;
        l_srep_rec.SALES_CREDIT_PERCENT_SPLIT   := 100;
        l_srep_rec.ORG_ID                       := l_line_rec.org_id;

        l_dist_rec.INTERFACE_LINE_ID            := l_line_rec.INTERFACE_LINE_ID;
        l_dist_rec.INTERFACE_LINE_CONTEXT       := l_line_rec.INTERFACE_LINE_CONTEXT;
        l_dist_rec.INTERFACE_LINE_ATTRIBUTE1    := l_line_rec.INTERFACE_LINE_ATTRIBUTE1;
        l_dist_rec.INTERFACE_LINE_ATTRIBUTE2    := l_line_rec.INTERFACE_LINE_ATTRIBUTE2;
        l_dist_rec.ACCOUNT_CLASS                := 'REV';
        l_dist_rec.PERCENT                      := 100;
        l_dist_rec.CODE_COMBINATION_ID          := g_memo_line_rec.GL_ID_REV;
        l_dist_rec.ORG_ID                       := l_line_rec.org_id;

        INSERT
        INTO    ra_interface_lines_all
        VALUES  l_line_rec;

        INSERT
        INTO    ra_interface_salescredits_all
        VALUES  l_srep_rec;

        INSERT
        INTO    ra_interface_distributions_all
        VALUES  l_dist_rec;
EXCEPTION
  WHEN OTHERS THEN
   NULL;
END;
--
FUNCTION GET_TANGIBLE_ID(in_source_s VARCHAR2) RETURN VARCHAR2
IS
        l_number_n              NUMBER;
        l_tang_id_s             VARCHAR2(80);
BEGIN
        SELECT cw_ar_cc_iby_tang_s.NEXTVAL
        INTO   l_number_n
        FROM   DUAL;

        SELECT TO_CHAR(l_number_n)||'_'||in_source_s
        INTO   l_tang_id_s
        FROM   DUAL;

        RETURN l_tang_id_s;
END;

PROCEDURE CW_AR_CC_AUTH (io_data_rec   IN OUT master_rec_type,
                         X_OUT            OUT VARCHAR2)
/*****************************************************************************************************
 R12 Changes added by Vk6774
 Created on  11/10/2012
 Description: This Proc will be called in the Custom form CWARCCPM.fmb for Credit card Authorization
              In R12 4 New API's are needed to Create Credit Card Authorization -- R12 QC 1884
 *****************************************************************************************************/
IS
   p_api_version              NUMBER := 1.0;
   p_init_msg_list            VARCHAR2 (2000) := FND_API.G_TRUE;
   p_commit                   VARCHAR2 (2000) := FND_API.G_FALSE;
   p_validation_level         NUMBER := FND_API.G_VALID_LEVEL_FULL;
   p_ecapp_id                 NUMBER;

   p_payee_rec                IBY_PAYMENT_ADAPTER_PUB.Payee_rec_type;
   p_payer_rec                IBY_PAYMENT_ADAPTER_PUB.Payer_rec_type;
   p_pmtinstr_rec             IBY_PAYMENT_ADAPTER_PUB.PmtInstr_rec_type;
   x_return_status            VARCHAR2 (2000);
   x_msg_count                NUMBER;
   x_msg_data                 VARCHAR2 (5000);
   x_reqresp_rec              IBY_PAYMENT_ADAPTER_PUB.ReqResp_rec_type;

   -- Variables for Create the instrument
   l_return_status            VARCHAR2 (1000);
   l_msg_count                NUMBER;
   l_msg_data                 VARCHAR2 (4000);
   l_card_id                  NUMBER;
   l_response                 IBY_FNDCPT_COMMON_PUB.Result_rec_type;
   l_card_instrument          IBY_FNDCPT_SETUP_PUB.CreditCard_rec_type;
   l_party_site_id            NUMBER;
   v_party_id                 hz_parties.party_id%TYPE;

   -- Variables for Create the instrument assignment
   lv_return_status           VARCHAR2 (1000);
   lv_msg_count               NUMBER;
   lv_msg_data                VARCHAR2 (4000);
   l_assign_id                NUMBER;
   lv_response                IBY_FNDCPT_COMMON_PUB.Result_rec_type;
   l_payer                    iby_fndcpt_common_pub.PayerContext_rec_type;
   l_assignment_attribs       iby_fndcpt_setup_pub.PmtInstrAssignment_rec_type;
   l_party_site_use_id        NUMBER;
   l_cust_acct_id             hz_cust_accounts_all.cust_account_id%TYPE;
   l_org_id                   NUMBER;

   -- Variables for Transaction extension
   lv1_return_status          VARCHAR2 (1000);
   lv1_msg_count              NUMBER;
   lv1_msg_data               VARCHAR2 (4000);
   l_customer_context_rec     Iby_Fndcpt_Common_Pub.PayerContext_rec_type;
   l_TrxnExtension_rec_type   Iby_Fndcpt_Trxn_Pub.TrxnExtension_rec_type;
   l_Result_rec_type          Iby_Fndcpt_Common_Pub.Result_rec_type;
   l_trx_entity_id            NUMBER;
   v_msg_dummy                VARCHAR2 (5000);

   -- Variables for Credit Card Authorization API
   p_api_version              NUMBER := 1.0;
   p_init_msg_list            VARCHAR2 (2000) := FND_API.G_TRUE;

   lv2_return_status          VARCHAR2 (2000);
   lv2_msg_count              NUMBER;
   lv2_msg_data               VARCHAR2 (5000);

   p_payer_equivalency        VARCHAR2 (30);
   l_payee                    IBY_FNDCPT_TRXN_PUB.PayeeContext_rec_type;
   l_trxn_entity_id           iby_fndcpt_tx_extensions.trxn_extension_id%TYPE;
   p_auth_attribs             IBY_FNDCPT_TRXN_PUB.AuthAttribs_rec_type;
   p_amount                   IBY_FNDCPT_TRXN_PUB.Amount_rec_type;
   x_auth_result              IBY_FNDCPT_TRXN_PUB.AuthResult_rec_type;
   x_response                 IBY_FNDCPT_COMMON_PUB.Result_rec_type;
   t_output                   VARCHAR2 (5000);
   v_flag                     VARCHAR2 (1);
   v_application_id           fnd_application.application_id%type;

   -- Variables for OraPmtreq Package call
   l_ecapp_id         NUMBER;
   lv_payee           IBY_PAYMENT_ADAPTER_PUB.Payee_rec_type;
   lv_payer           IBY_PAYMENT_ADAPTER_PUB.Payer_rec_type;
   l_tangible         IBY_PAYMENT_ADAPTER_PUB.Tangible_rec_type;
   l_pmt_instr        IBY_PAYMENT_ADAPTER_PUB.PmtInstr_rec_type;
   l_pmt_trxn         IBY_PAYMENT_ADAPTER_PUB.PmtReqTrxn_rec_type;
   l_app_short_name   FND_APPLICATION.APPLICATION_SHORT_NAME%TYPE;
   l_order_id         IBY_FNDCPT_TX_EXTENSIONS.ORDER_ID%TYPE;
   l_trxn_ref1        IBY_FNDCPT_TX_EXTENSIONS.TRXN_REF_NUMBER1%TYPE;
   l_trxn_ref2        IBY_FNDCPT_TX_EXTENSIONS.TRXN_REF_NUMBER2%TYPE;
   l_encrypted        IBY_FNDCPT_TX_EXTENSIONS.ENCRYPTED%TYPE;
   l_code_segment_id  IBY_FNDCPT_TX_EXTENSIONS.INSTR_CODE_SEC_SEGMENT_ID%TYPE;
   l_sec_code_len     IBY_FNDCPT_TX_EXTENSIONS.INSTR_SEC_CODE_LENGTH%TYPE;
   l_single_use       IBY_FNDCPT_PAYER_ASSGN_INSTR_V.CARD_SINGLE_USE_FLAG%TYPE;
   l_reqresp          IBY_PAYMENT_ADAPTER_PUB.ReqResp_rec_type;
   l_fail_msg         VARCHAR2 (500);
   p_count            NUMBER;
   p_riskinfo_rec     IBY_PAYMENT_ADAPTER_PUB.RiskInfo_rec_type;
   v_payee_id         NUMBER;
   l_ext_not_found    BOOLEAN;
   l_rec_mth_id       NUMBER;
   lv_site_use_id     NUMBER;


   CURSOR cw_msg_rec (iby_tang_id_s VARCHAR2)
   IS
        SELECT   bepmessage
          FROM   iby_trxn_summaries_all
         WHERE   tangibleid = iby_tang_id_s
      ORDER BY   trxnmid DESC;

  -- This Cursor Logic is leveraged from IBY_FNDCPT_TRXN_PUB.Create_Authorization Where OraPmtReq API is internally called
  -- By adding this Logic from IBY_FNDCPT_TRXN_PUB.Create_Authorization  Issues related to Custom Servlet are resolved in R12
  -- Added the cursor c_extension by Vk6774  01/15/2013

   CURSOR c_extension    (ci_extension_id IN iby_fndcpt_tx_extensions.trxn_extension_id%TYPE,
                          ci_payer        IN IBY_FNDCPT_COMMON_PUB.PayerContext_rec_type
   )
    IS
      SELECT NVL(i.instrument_type,pc.instrument_type),
                NVL(i.instrument_id,0),
                x.origin_application_id, a.application_short_name,
                x.order_id, x.trxn_ref_number1, x.trxn_ref_number2,
                x.instrument_security_code, x.instr_code_sec_segment_id,
                x.instr_sec_code_length, x.encrypted,
                x.po_number, x.voice_authorization_flag, x.voice_authorization_code,
                x.voice_authorization_date, i.card_single_use_flag,
                NVL(x.instr_assignment_id,0), x.payment_channel_code
      FROM iby_fndcpt_tx_extensions x,
           iby_fndcpt_payer_assgn_instr_v i,
           iby_external_payers_all p, fnd_application a,
           iby_fndcpt_pmt_chnnls_b pc
      WHERE (x.instr_assignment_id = i.instr_assignment_id(+))
        AND (x.payment_channel_code = pc.payment_channel_code)
        AND (x.origin_application_id = a.application_id)-- can assume this assignment is for funds capture
        AND (x.ext_payer_id = p.ext_payer_id)
        AND (x.trxn_extension_id = ci_extension_id)
        AND (p.party_id = ci_payer.Party_Id);
BEGIN
   v_flag := 'N';

   IF (c_extension%ISOPEN) THEN CLOSE c_extension; END IF;
   WRITE_CC_AUTH_DEBUG('Start Processing the CC AUTH',io_data_rec.child_rec.tangible_id);

  BEGIN
   SELECT   application_id
     INTO   v_application_id
     FROM   fnd_application
    WHERE   application_short_name = 'AR';
  EXCEPTION
  WHEN OTHERS
  THEN
      v_application_id := null;
  END;

   BEGIN
      MO_GLOBAL.INIT ('IBY');
      MO_GLOBAL.set_policy_context('S',Fnd_Profile.VALUE ('ORG_ID'));
   END;
   
   IF io_data_rec.child_rec.source_code = 'AUC' THEN
    WRITE_CC_AUTH_DEBUG('inside auc :',io_data_rec.child_rec.tangible_id);
   BEGIN
    SELECT invoice_to_org_id
    INTO   lv_site_use_id
    FROM   oe_order_headers_all
    WHERE  header_id = io_data_rec.child_rec.source_id;
   EXCEPTION
    WHEN OTHERS THEN
        lv_site_use_id := 0;
   END;
   
   WRITE_CC_AUTH_DEBUG('site use :'||lv_site_use_id,io_data_rec.child_rec.tangible_id);
   
    BEGIN
        SELECT   ca.party_id, hps.party_site_id,CASU.SITE_USE_ID
          INTO   v_party_id, l_party_site_id, l_party_site_use_id
          FROM   hz_party_sites hps,
                 apps.hz_cust_acct_sites_all cas,
                 apps.hz_cust_site_uses_all casu,
                 APPS.HZ_CUST_ACCOUNTS CA,
                 hz_locations hl
         WHERE hps.location_id = hl.location_id
           AND hps.party_site_id = cas.party_site_id
           AND cas.cust_acct_site_id = casu.cust_acct_site_id
           AND CA.CUST_ACCOUNT_ID = io_data_rec.child_rec.cust_Account_id
           AND CA.CUST_ACCOUNT_ID = CAS.CUST_ACCOUNT_ID
           AND CA.PARTY_ID = HPS.PARTY_ID
           AND casu.site_use_code = 'BILL_TO'
           AND CASU.STATUS = 'A'
           AND casu.site_use_id = lv_site_use_id;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         l_party_site_id := 0;
         l_party_site_use_id :=0;
         v_party_id := 0;
      WHEN OTHERS
      THEN
         l_party_site_id := 0;
         l_party_site_use_id :=0;
         v_party_id := 0;
       WRITE_CC_AUTH_DEBUG('When Others 2 :'||sqlerrm,io_data_rec.child_rec.tangible_id);
   END;
    
   END IF;

   IF io_data_rec.child_rec.source_code != 'AUC' THEN

       BEGIN
            SELECT   ca.party_id, hps.party_site_id,CASU.SITE_USE_ID
              INTO   v_party_id, l_party_site_id, l_party_site_use_id
              FROM   hz_party_sites hps,
                     apps.hz_cust_acct_sites_all cas,
                     apps.hz_cust_site_uses_all casu,
                     APPS.HZ_CUST_ACCOUNTS CA,
                     hz_locations hl
             WHERE hps.location_id = hl.location_id
               AND hps.party_site_id = cas.party_site_id
               AND cas.cust_acct_site_id = casu.cust_acct_site_id
               AND CA.CUST_ACCOUNT_ID = io_data_rec.child_rec.cust_Account_id
               AND CA.CUST_ACCOUNT_ID = CAS.CUST_ACCOUNT_ID
               AND CA.PARTY_ID = HPS.PARTY_ID
               AND casu.site_use_code = 'BILL_TO'
               AND CASU.STATUS = 'A';
       EXCEPTION
          WHEN NO_DATA_FOUND
          THEN
             l_party_site_id := 0;
             l_party_site_use_id :=0;
             v_party_id := 0;
          WHEN OTHERS
          THEN
             l_party_site_id := 0;
             l_party_site_use_id :=0;
             v_party_id := 0;
           WRITE_CC_AUTH_DEBUG('When Others 1 :'||sqlerrm,io_data_rec.child_rec.tangible_id);
       END;
   
   END IF;
   --- Create Instrument  -- R12 QC 1884
   l_card_instrument.Owner_Id           := v_party_id;       -- party_id from hz_parties
   l_card_instrument.Card_Holder_Name   := io_data_rec.child_rec.card_holder_name; -- party_name from hz_parties
   l_card_instrument.Billing_Address_Id := l_party_site_id; -- party_site_id from hz_party_sites such as owner_id above is the party_id asociated to the party_site
   l_card_instrument.Card_Number        := io_data_rec.child_rec.card_number; --'4012888888881881';
   l_card_instrument.Expiration_Date    := io_data_rec.child_rec.expiry_Date; --'21-OCT-2013';
   l_card_instrument.Instrument_Type    := 'CREDITCARD';
   l_card_instrument.PurchaseCard_Flag  := 'N';
   l_card_instrument.Single_Use_Flag    := 'N';
   l_card_instrument.Info_Only_Flag     := 'N';
   l_card_instrument.Card_Purpose       := 'N';
   l_card_instrument.Card_Description   := 'Card for BW Corporate Purchases'; -- ask bsa for card description
   l_card_instrument.Active_Flag        := 'Y';

   WRITE_CC_AUTH_DEBUG('Calling create card API',io_data_rec.child_rec.tangible_id);
   IBY_FNDCPT_SETUP_PUB.Create_Card (p_api_version       => 1.0,
                                     p_commit            =>  FND_API.G_TRUE,
                                     x_return_status     => l_return_status,
                                     x_msg_count         => l_msg_count,
                                     x_msg_data          => l_msg_data,
                                     p_card_instrument   => l_card_instrument,
                                     x_card_id           => l_card_id,
                                     x_response          => l_response,
                                     p_init_msg_list     => FND_API.G_TRUE
                                     );


   IF l_return_status != FND_API.G_RET_STS_SUCCESS
   THEN
      FOR i IN 1 .. l_msg_count
      LOOP
         fnd_msg_pub.get (i,
                          FND_API.G_FALSE,
                          l_msg_data,
                          v_msg_dummy);
         t_output := ('Msg' || TO_CHAR (i) || ': ' || l_msg_data);
         X_OUT := t_output;
         io_data_rec.child_rec.status := 'E';-- add output error message
      END LOOP;
      WRITE_CC_AUTH_DEBUG('ERror create card API'||X_OUT,io_data_rec.child_rec.tangible_id);

      v_flag := 'Y';
   ELSE
      COMMIT;
      WRITE_CC_AUTH_DEBUG('CREATE CARD SUCCESS :'||l_return_status ,io_data_rec.child_rec.tangible_id);
      -- Below is as per 11i functionality
     IF io_data_rec.child_rec.trx_type = 'AUTHONLY'
     THEN
        io_data_rec.child_rec.status := 'X';
     ELSIF io_data_rec.child_rec.trx_type = 'AUTHCAPTURE'
     THEN
        io_data_rec.child_rec.status := 'D';
     END IF;
   END IF;

     WRITE_CC_AUTH_DEBUG('Calling format string 1',io_data_rec.child_rec.tangible_id);
     cw_format_string( io_msg_count_n => l_msg_count,
                      io_msg_data_s  => l_msg_data);

           WRITE_CC_AUTH_DEBUG('Opening the cursor cw_msg_rec #1 ',io_data_rec.child_rec.tangible_id);
           --WRITE_CC_AUTH_DEBUG('Tangible_id '||io_data_rec.child_rec.tangible_id, io_data_rec.child_rec.tangible_id);
            OPEN  cw_msg_rec(io_data_rec.child_rec.tangible_id);
            FETCH cw_msg_rec
            INTO  l_msg_data;
            CLOSE cw_msg_rec;
            WRITE_CC_AUTH_DEBUG('Message #1 :'||l_msg_data,io_data_rec.child_rec.tangible_id);


 io_data_rec.child_rec.approval_message := l_msg_data;

 WRITE_CC_AUTH_DEBUG('child_rec.approval_message #1 :'||io_data_rec.child_rec.approval_message,io_data_rec.child_rec.tangible_id);


   -----Create the instrument assignment
   IF v_flag = 'N'
   THEN

      l_payer.Payment_Function  := 'CUSTOMER_PAYMENT';
      l_payer.Party_Id          := v_party_id;
      l_payer.Cust_Account_Id   := io_data_rec.child_rec.cust_Account_id;   -- this is an account from HZ_CUST_ACCOUNTS_ALL such that the party_id is the same as above and the same as owner_id for the card
      l_payer.Account_Site_Id   := l_party_site_use_id; -- this is a site_USE_id (note param says account_site but it is account_site_use) asociated to the account above and the party_site from create_card
      l_payer.Org_Type          := 'OPERATING_UNIT';        -- should be operating_unit
      l_payer.Org_Id            := io_data_rec.org_id; -- the same org_id for the account, and account_site_use
      l_assignment_attribs.Instrument.instrument_Type := 'CREDITCARD';
      l_assignment_attribs.Instrument.instrument_id   := l_card_id; --Instrument_Id_returned_by_prior_API
      l_assignment_attribs.Priority  := 1; -- Is priority always 1 ask bsa

      -- Set Payer Instrument assignment -- R12 QC 1884
      WRITE_CC_AUTH_DEBUG('Calling set_payer_instr_assignment API',io_data_rec.child_rec.tangible_id);
      IBY_FNDCPT_SETUP_PUB.set_payer_instr_assignment (
         p_api_version          => 1.0,
         p_commit               => fnd_api.g_false,
         x_return_status        => lv_return_status,
         x_msg_count            => lv_msg_count,
         x_msg_data             => lv_msg_data,
         p_payer                => l_payer,
         p_assignment_attribs   => l_assignment_attribs,
         x_assign_id            => l_assign_id,
         x_response             => lv_response
      );



      IF lv_return_status != FND_API.G_RET_STS_SUCCESS
      THEN

         FOR i IN 1 .. lv_msg_count
         LOOP
            fnd_msg_pub.get (i,
                             FND_API.G_FALSE,
                             lv_msg_data,
                             v_msg_dummy);
            t_output := ('Msg' || TO_CHAR (i) || ': ' || lv_msg_data);
            X_OUT := t_output;
            io_data_rec.child_rec.status := 'E';-- add output error message
         END LOOP;

         WRITE_CC_AUTH_DEBUG('Error Occured In set_payer_instr_assignment '||X_OUT,io_data_rec.child_rec.tangible_id);

         v_flag := 'Y';
      ELSE
         COMMIT;
         -- Below is as per 11i functionality
         IF io_data_rec.child_rec.trx_type = 'AUTHONLY'
         THEN
            io_data_rec.child_rec.status := 'X';
         ELSIF io_data_rec.child_rec.trx_type = 'AUTHCAPTURE'
         THEN
            io_data_rec.child_rec.status := 'D';
         END IF;
         WRITE_CC_AUTH_DEBUG('Api Set_Payer_Instr_assignment is success',io_data_rec.child_rec.tangible_id);
      END IF;
      WRITE_CC_AUTH_DEBUG('Calling CW_format_String #2',io_data_rec.child_rec.tangible_id);
      cw_format_string( io_msg_count_n => lv_msg_count,
                          io_msg_data_s  => lv_msg_data);
          WRITE_CC_AUTH_DEBUG('Open Cursor cw_msg_rec  #2',io_data_rec.child_rec.tangible_id);
                OPEN  cw_msg_rec(io_data_rec.child_rec.tangible_id);
                FETCH cw_msg_rec
                INTO  lv_msg_data;
                CLOSE cw_msg_rec;
         WRITE_CC_AUTH_DEBUG('After Cursor :'|| lv_msg_data,io_data_rec.child_rec.tangible_id);
         WRITE_CC_AUTH_DEBUG('After Cursor cw_msg_rec  #2',io_data_rec.child_rec.tangible_id);

       io_data_rec.child_rec.approval_message := lv_msg_data;
       WRITE_CC_AUTH_DEBUG('io_data_rec.child_rec.approval_message #2'||io_data_rec.child_rec.approval_message,io_data_rec.child_rec.tangible_id);
   END IF;


   -- -- Create Transaction Extensions -- R12 QC 1884

   IF v_flag = 'N'
   THEN

      l_customer_context_rec.payment_function := 'CUSTOMER_PAYMENT';
      l_customer_context_rec.Party_Id         := v_party_id; --44726; -- all values same as above as they have to match the card and the assignment
      l_customer_context_rec.Org_Type         := 'OPERATING_UNIT';
      l_customer_context_rec.Org_Id           := io_data_rec.org_id;
      l_customer_context_rec.Cust_Account_Id  := io_data_rec.child_rec.cust_Account_id;
      l_customer_context_rec.Account_Site_Id  := l_party_site_use_id;
      l_TrxnExtension_rec_type.Originating_Application_Id := v_application_id;
      l_TrxnExtension_rec_type.Order_Id        := io_data_rec.child_rec.tangible_id; -- same as 11i code -- this is not validated but must be entered a unique number (use a sequence perhaps ?)
      l_TrxnExtension_rec_type.Trxn_Ref_Number1 := 'RECEIPT';
      l_TrxnExtension_rec_type.Trxn_Ref_Number2 := io_data_rec.child_rec.tangible_id; -- added by vk6774 for testing R12
      l_TrxnExtension_rec_type.Instrument_Security_Code := io_data_rec.child_rec.cvv2;
      l_TrxnExtension_rec_type.po_number := io_data_rec.merchant_id; -- added to user Oapfponum token as merchant id to be passed in custom servlet

     WRITE_CC_AUTH_DEBUG('Calling Create transaction Extension API :',io_data_rec.child_rec.tangible_id);

      IBY_FNDCPT_TRXN_PUB.Create_Transaction_Extension (
         p_api_version         => 1.0,
         p_init_msg_list       => Fnd_Api.G_TRUE,
         p_commit              => Fnd_Api.G_false,
         x_return_status       => lv1_return_status,
         x_msg_count           => lv1_msg_count,
         x_msg_data            => lv1_msg_data,
         p_payer               => l_customer_context_rec,
         p_payer_equivalency   => Iby_Fndcpt_Common_Pub.G_PAYER_EQUIV_FULL,
         p_pmt_channel         => 'CREDIT_CARD',
         p_instr_assignment    => l_assign_id, -- id derived from the Assign Instrument API
         p_trxn_attribs        => l_TrxnExtension_rec_type,
         x_entity_id           => l_trx_entity_id,
         x_response            => l_Result_rec_type
      );
        

      IF lv1_return_status != FND_API.G_RET_STS_SUCCESS
      THEN
         FOR i IN 1 .. lv1_msg_count
         LOOP
            fnd_msg_pub.get (i,
                             FND_API.G_FALSE,
                             lv1_msg_data,
                             v_msg_dummy);
            t_output := ('Msg' || TO_CHAR (i) || ': ' || lv1_msg_data);
            X_OUT := t_output;
            io_data_rec.child_rec.status := 'E';                    -- add output error message
         END LOOP;

         WRITE_CC_AUTH_DEBUG('Create transaction Extension API Error :'||X_OUT ,io_data_rec.child_rec.tangible_id);
         v_flag := 'Y';
      ELSE
         COMMIT;   -- Below is as per 11i functionality
         
         IF io_data_rec.child_rec.trx_type = 'AUTHONLY'
         THEN
            io_data_rec.child_rec.status := 'X';
         ELSIF io_data_rec.child_rec.trx_type = 'AUTHCAPTURE'
         THEN
            io_data_rec.child_rec.status := 'D';
         END IF;
      WRITE_CC_AUTH_DEBUG('Create transaction Extension API Success :'||X_OUT,io_data_rec.child_rec.tangible_id);
      END IF;
       WRITE_CC_AUTH_DEBUG('Calling cw_format_string # 3 ',io_data_rec.child_rec.tangible_id);
        cw_format_string( io_msg_count_n => lv1_msg_count,
                    io_msg_data_s  => lv1_msg_data);

        WRITE_CC_AUTH_DEBUG('Open Cursor cw_msg_rec # 3 ',io_data_rec.child_rec.tangible_id);
                 OPEN cw_msg_rec(io_data_rec.child_rec.tangible_id);
                FETCH cw_msg_rec
                 INTO lv1_msg_data;
                CLOSE cw_msg_rec;
       WRITE_CC_AUTH_DEBUG('Cursor cw_msg_rec # 3 message '|| lv1_msg_data,io_data_rec.child_rec.tangible_id);
       WRITE_CC_AUTH_DEBUG(' After Cursor # 3',io_data_rec.child_rec.tangible_id);

    io_data_rec.child_rec.approval_message := lv1_msg_data;
    WRITE_CC_AUTH_DEBUG('io_data_rec.child_rec.approval_message # 3'||io_data_rec.child_rec.approval_message,io_data_rec.child_rec.tangible_id);

   END IF;

   --- Calling IBY_PAYMENT_ADAPTER_PUB.OraPmtReq which will call the Oracle standard servlet and Custom servlet.Custom Servlet will pass back the information to this Process

     IF v_flag = 'N'  -- R12 QC 1884
     THEN
       BEGIN
          p_payer_equivalency := 'UPWARD';

          -- Payer context record
          l_customer_context_rec.Payment_Function   := 'CUSTOMER_PAYMENT';
          l_customer_context_rec.Party_Id           := v_party_id;
          l_customer_context_rec.Org_Type           := 'OPERATING_UNIT';
          l_customer_context_rec.Org_Id             := io_data_rec.org_id;
          l_customer_context_rec.Cust_Account_Id    := io_data_rec.child_rec.cust_Account_id;
          l_customer_context_rec.Account_Site_Id    := l_party_site_use_id;
          l_trxn_entity_id                          := l_trx_entity_id; -- iby_fndcpt_tx_extensions.trxn_extension_id
          p_auth_attribs.Payment_Factor_Flag        := NULL;
          p_auth_attribs.Memo                       := io_data_rec.child_rec.card_holder_name; --NULL;   was null but Memo will be used as Oafcustname Token value as per 11i card holder name is customer name this is maintained same in R12
          p_auth_attribs.Order_Medium               := io_data_rec.merchant_id||'-'||io_data_rec.child_rec.zip;--NULL;     Same reason as above for R12 Oadpostalcode
          p_auth_attribs.Tax_Amount.VALUE           := NULL;
          p_auth_attribs.ShipFrom_SiteUse_Id        := NULL;
          p_auth_attribs.ShipFrom_PostalCode        := NULL;
          p_auth_attribs.ShipTo_SiteUse_Id          := NULL;
          p_auth_attribs.ShipTo_PostalCode          := NULL;
          p_auth_attribs.RiskEval_Enable_Flag       := 'N';
          p_amount.VALUE                            := abs(io_data_rec.child_rec.receipt_amount); -- added this on 01/27/2013 for refunds
          p_amount.Currency_Code                    := 'USD';


          BEGIN
              SELECT p.payeeid into v_payee_id
                  FROM iby_payee p, iby_fndcpt_payee_appl a
                  WHERE (p.mpayeeid = a.mpayeeid)
                    AND ((a.org_type = 'OPERATING_UNIT') AND (a.org_id = io_data_rec.org_id));
          EXCEPTION
          WHEN OTHERS THEN
             v_payee_id := 0;
             X_OUT := 'No Payee Id found for :'||'OPERATING_UNIT'||' and '||io_data_rec.org_id||' :' || SUBSTR (SQLERRM, 1, 150);
             io_data_rec.child_rec.status := 'E';
            WRITE_CC_AUTH_DEBUG(' X_OUT in Step # 4 '||X_OUT,io_data_rec.child_rec.tangible_id);
          END;
                l_payer.party_id        := v_party_id;
             WRITE_CC_AUTH_DEBUG('Opening Cursor c_Extension :',io_data_rec.child_rec.tangible_id);
                OPEN c_extension(l_trx_entity_id,l_payer);
                  FETCH c_extension INTO l_pmt_instr.PmtInstr_Type,
                        l_pmt_instr.PmtInstr_Id, l_ecapp_id, l_app_short_name,
                        l_order_id, l_trxn_ref1, l_trxn_ref2,
                        l_pmt_trxn.CVV2, l_code_segment_id,
                        l_sec_code_len, l_encrypted,
                        l_pmt_trxn.PONum, l_pmt_trxn.VoiceAuthFlag,
                        l_pmt_trxn.AuthCode, l_pmt_trxn.DateOfVoiceAuthorization,
                        l_single_use,
                        l_pmt_instr.Pmtinstr_assignment_id,
                        l_pmt_trxn.payment_channel_code;
                  l_ext_not_found := c_extension%NOTFOUND;
                  CLOSE c_extension;

                   lv_payee.payee_id          := v_payee_id;
                   lv_payer.party_id          := v_party_id;
                   l_tangible.tangible_id     := io_data_rec.child_rec.tangible_id;
                   l_tangible.currency_code   := 'USD';
                   l_tangible.ordermedium     := io_data_rec.merchant_id||'-'||io_data_rec.child_rec.zip;
                   l_tangible.Tangible_Amount := abs(io_data_rec.child_rec.receipt_amount);
                   l_pmt_trxn.Auth_Type       := io_data_rec.child_rec.trx_type; -- for refunds modify to AUTHCAPTURE
                   l_pmt_Trxn.org_id          := io_data_rec.org_id;
                   l_pmt_trxn.org_type        := 'OPERATING_UNIT';
                   l_ecapp_id                 := v_application_id;
                   l_tangible.Tangible_Amount := p_amount.Value;
                   --      l_tangible.Tangible_Amount := 40;
                   l_pmt_trxn.TaxAmount       := p_auth_attribs.Tax_Amount.Value;
                   l_pmt_trxn.ShipFromZip     := p_auth_attribs.ShipFrom_PostalCode;
                   l_pmt_trxn.ShipToZip       := p_auth_attribs.ShipTo_PostalCode;
                   l_pmt_trxn.Payment_Factor_Flag := p_auth_attribs.Payment_Factor_Flag;
                   l_pmt_trxn.TrxnRef         := io_data_rec.merchant_id||'-'||io_data_rec.child_rec.zip; -- r12 Changes added by vk6774

                    IF (l_encrypted = 'Y') THEN
                     l_pmt_trxn.CVV2 := NULL;
                     l_pmt_trxn.Trxn_Extension_Id := l_trx_entity_id;
                     l_pmt_trxn.CVV2_Segment_id   := l_code_segment_id;
                     l_pmt_trxn.CVV2_Length       := l_sec_code_len;
                    END IF;

                    l_rec_mth_id := p_auth_attribs.Receipt_Method_Id;

                            WRITE_CC_AUTH_DEBUG('l_trxn_entity_id: ' || l_trxn_entity_id,io_data_rec.child_rec.tangible_id);
                            WRITE_CC_AUTH_DEBUG('l_tangible.Tangible_Amount ' || l_tangible.Tangible_Amount,io_data_rec.child_rec.tangible_id);


               IF (l_rec_mth_id IS NULL)
                 THEN
                BEGIN
                        SELECT   RECEIPT_METHOD_ID
                          INTO   l_rec_mth_id
                          FROM   ar_cash_receipts_all
                         WHERE   payment_trxn_extension_id = l_trxn_entity_id;

                EXCEPTION
                WHEN OTHERS THEN
                l_rec_mth_id := NULL;
                WRITE_CC_AUTH_DEBUG(' Receipt Method id is  errored as :'||SQLERRM,io_data_rec.child_rec.tangible_id);
                END;
               END IF;

                 l_pmt_trxn.Receipt_Method_Id := l_rec_mth_id;

                  WRITE_CC_AUTH_DEBUG('Now Calling IBY_PAYMENT_ADAPTER_PUB.ORAPMTREQ',io_data_rec.child_rec.tangible_id);
               APPS.IBY_PAYMENT_ADAPTER_PUB.OraPmtReq (
                                                  p_api_version        => 1.0,
                                                  p_init_msg_list      => FND_API.G_FALSE,
                                                  p_commit             => FND_API.G_TRUE,
                                                  p_validation_level   => FND_API.G_VALID_LEVEL_FULL,
                                                  p_ecapp_id           => l_ecapp_id,
                                                  p_payee_rec          => lv_payee,
                                                  p_payer_rec          => lv_payer,
                                                  p_pmtinstr_rec       => l_pmt_instr,
                                                  p_tangible_rec       => l_tangible,
                                                  p_pmtreqtrxn_rec     => l_pmt_trxn,
                                                  p_riskinfo_rec       => p_riskinfo_rec,
                                                  x_return_status      => x_return_status,
                                                  x_msg_count          => x_msg_count,
                                                  x_msg_data           => x_msg_data,
                                                  x_reqresp_rec        => l_reqresp
                                               );

          WRITE_CC_AUTH_DEBUG('BEPErrMessage :'||l_reqresp.BEPErrMessage,io_data_rec.child_rec.tangible_id);
          WRITE_CC_AUTH_DEBUG('BEPErrCode :'||l_reqresp.BEPErrCode,io_data_rec.child_rec.tangible_id);
          WRITE_CC_AUTH_DEBUG('ErrorLocation :'||l_reqresp.ErrorLocation,io_data_rec.child_rec.tangible_id);
          WRITE_CC_AUTH_DEBUG('Response_status :'|| l_reqresp.Response.status,io_data_rec.child_rec.tangible_id);
          WRITE_CC_AUTH_DEBUG('Response_ErrCode :'|| l_reqresp.Response.ErrCode,io_data_rec.child_rec.tangible_id);
          WRITE_CC_AUTH_DEBUG('Response_ErrMessage :'|| l_reqresp.Response.ErrMessage,io_data_rec.child_rec.tangible_id);

          IF x_return_status != FND_API.G_RET_STS_SUCCESS
          THEN
             FOR i IN 1 .. x_msg_count
             LOOP
                fnd_msg_pub.get (i,
                                 FND_API.G_FALSE,
                                 x_msg_data,
                                 v_msg_dummy);
                t_output := ('Msg' || TO_CHAR (i) || ': ' || x_msg_data);
                X_OUT := t_output;                     -- add output error message
                io_data_rec.child_rec.status := 'E';
             END LOOP;
            WRITE_CC_AUTH_DEBUG('Error in IBY_PAYMENT_ADAPTER_PUB.ORAPMTREQ',io_data_rec.child_rec.tangible_id);
            WRITE_CC_AUTH_DEBUG('Orapmtreq err :'||X_OUT,io_data_rec.child_rec.tangible_id);
             v_flag := 'Y';
          ELSE
             COMMIT;-- Below is as per 11i functionality
             IF io_data_rec.child_rec.trx_type = 'AUTHONLY'
             THEN
                io_data_rec.child_rec.status := 'X';
             ELSIF io_data_rec.child_rec.trx_type = 'AUTHCAPTURE'
             THEN
                io_data_rec.child_rec.status := 'D';
             END IF;
            WRITE_CC_AUTH_DEBUG('Sucess calling the orareqpmt API ',io_data_rec.child_rec.tangible_id);
          END IF; 

          WRITE_CC_AUTH_DEBUG('cw_format_string #4 ',io_data_rec.child_rec.tangible_id);
          cw_format_string( io_msg_count_n => x_msg_count,
                          io_msg_data_s  => x_msg_data);

             WRITE_CC_AUTH_DEBUG('Now Open Cursor # 4' ||io_data_rec.child_rec.tangible_id,io_data_rec.child_rec.tangible_id);
                OPEN  cw_msg_rec(io_data_rec.child_rec.tangible_id);
                FETCH cw_msg_rec
                INTO  lv2_msg_data;
                CLOSE cw_msg_rec;
             WRITE_CC_AUTH_DEBUG('Cursor # 4 Done',io_data_rec.child_rec.tangible_id);

          WRITE_CC_AUTH_DEBUG('After cursor 4 approvel message :'|| io_data_rec.child_rec.approval_message,io_data_rec.child_rec.tangible_id);
          io_data_rec.child_rec.approval_message := lv2_msg_data;
          WRITE_CC_AUTH_DEBUG('After assignment :'|| io_data_rec.child_rec.approval_message,io_data_rec.child_rec.tangible_id);
          io_data_rec.child_rec.approval_code    := l_reqresp.AuthCode; --x_auth_result.Auth_Code; QC 3284 Change by Vk6774 on 02/18/2013
          

       EXCEPTION
          WHEN OTHERS
          THEN
             X_OUT := 'Error is in Credi Auth API:' || SUBSTR (SQLERRM, 1, 150);
             io_data_rec.child_rec.status := 'E';
        WRITE_CC_AUTH_DEBUG('ERROR STATUS IN EXCEPTION :'|| io_data_rec.child_rec.status,io_data_rec.child_rec.tangible_id);
        WRITE_CC_AUTH_DEBUG('EXCEPTION IN THE PROCESS IS :'|| X_OUT,io_data_rec.child_rec.tangible_id);
       END;
     END IF;
EXCEPTION
WHEN OTHERS THEN
X_OUT := 'Other Error Occured In CC AUTH Process is :'||SQLERRM;
WRITE_CC_AUTH_DEBUG('OTHER ERROR OCCURED IN THE PROCESS IS:'||X_OUT,io_data_rec.child_rec.tangible_id);
END;

PROCEDURE CW_AR_CC_RECEIPT(io_data_rec     IN OUT master_rec_type)
IS
  x_return_status       VARCHAR2(2000);
  x_msg_count           NUMBER;
  x_msg_data            VARCHAR2(5000);
  lv_return_status           VARCHAR2 (1000);

  p_api_version         NUMBER := 1.0;
  p_init_msg_list       VARCHAR2(2000)  := FND_API.G_TRUE;
  p_commit              VARCHAR2(2000)  := FND_API.G_FALSE;
  p_validation_level    NUMBER  := FND_API.G_VALID_LEVEL_FULL;
BEGIN

  AR_RECEIPT_API_PUB.CREATE_CASH(
        p_api_version          => p_api_version,
        p_init_msg_list        => p_init_msg_list,
        p_commit               => p_commit,
        p_validation_level     => p_validation_level,
        x_return_status        => x_return_status,
        x_msg_count            => x_msg_count,
        x_msg_data             => x_msg_data,
        p_currency_code        => 'USD',
        p_comments             => io_data_rec.child_rec.comments,
        p_amount               => ABS(io_data_rec.child_rec.receipt_amount),--changes
        p_receipt_number       => io_data_rec.child_rec.cw_receipt_id,
        p_receipt_date         => io_data_rec.child_rec.receipt_date,
        p_gl_date              => io_data_rec.child_rec.receipt_date,
        p_customer_id          => io_data_rec.child_rec.cust_account_id,
        p_customer_site_use_id => io_data_rec.child_rec.site_use_id,
        p_receipt_method_id    => io_data_rec.method_id,
        p_cr_id                => io_data_rec.child_rec.ar_receipt_id);

  cw_format_string( io_msg_count_n => x_msg_count,
                    io_msg_data_s  => x_msg_data);

  IF x_return_status = FND_API.G_RET_STS_SUCCESS
  THEN
      io_data_rec.child_rec.status := 'R';
      io_data_rec.child_rec.approval_message := 'APPROVED';
      UPDATE cw_ar_cc_post_paid_receipts
      SET    APPROVAL_MESSAGE = 'APPROVED',
             STATUS           = 'R',
             AR_RECEIPT_ID    = io_data_rec.child_rec.ar_receipt_id
      WHERE  CW_RECEIPT_ID = io_data_rec.child_rec.cw_receipt_id;

     UPDATE ar_cash_receipts
     SET    payment_server_order_num = io_data_rec.child_rec.tangible_id,
            approval_code            = io_data_rec.child_rec.approval_code
     WHERE  cash_receipt_id          = io_data_rec.child_rec.ar_receipt_id;
  ELSE
     io_data_rec.child_rec.status := 'X';
     io_data_rec.child_rec.approval_message := 'Receipt Creation failed for Net Auth Amount';
     commit;
  END IF;
END;

/****************************************************   KC7381(START)   **************************************************/
PROCEDURE CC_GET_ON_ACC_CM_DET (io_data_rec     IN OUT master_rec_type,
                                X_OUT            OUT VARCHAR2)
IS

    p_api_version           NUMBER := 1.0;
    p_init_msg_list         VARCHAR2 (2000) := FND_API.G_TRUE;
    p_commit                VARCHAR2(2000):=FND_API.G_FALSE;
    p_validation_level      NUMBER:=FND_API.G_VALID_LEVEL_FULL;
    x_return_status         VARCHAR2(2000);
    x_msg_count             NUMBER;
    x_msg_data              VARCHAR2(5000);
    l_sysdate_d             DATE:=TRUNC(SYSDATE);
    p_receipt_date          DATE := io_data_rec.child_rec.receipt_date;
    ln_COUNT                NUMBER;
    lv_return_status           VARCHAR2 (1000);
    l_cm_flag               VARCHAR2(10);

    CURSOR    cw_ar_cm_cur IS
    SELECT    CREDIT_APPLIED,
              --CW_RECEIPT_ID,
              CUSTOMER_TRX_ID
    FROM      CW_AUC_RCPT_CM_APPL_CTRL
    WHERE     CW_RECEIPT_ID = io_data_rec.child_rec.cw_receipt_id
              AND TRANSACTION_TYPE = 'Auction Credit Memo'
              AND AMT_OFFSET>0;
              --AND STATUS_CODE!='S';

BEGIN
    FOR l_cw_ar_cm_cur IN cw_ar_cm_cur
    LOOP
            AR_RECEIPT_API_PUB.APPLY(
                                     p_api_version          => p_api_version,
                                     p_init_msg_list        => p_init_msg_list,
                                     p_commit               => p_commit,
                                     p_validation_level     => p_validation_level,
                                     x_return_status        => x_return_status,
                                     x_msg_count            => x_msg_count,
                                     x_msg_data             => x_msg_data,
                                     p_cash_receipt_id      => io_data_rec.child_rec.ar_receipt_id,
                                     p_customer_trx_id      => l_cw_ar_cm_cur.customer_trx_id,
                                     p_amount_applied       => -1*l_cw_ar_cm_cur.credit_applied, --CHANGES
                                     p_apply_date           => p_receipt_date,
                                     p_apply_gl_date        => p_receipt_date);

            ln_COUNT := 0;

            IF x_msg_count = 1 THEN
                WRITE_CC_AUTH_DEBUG('X_MSG_DATA '|| x_msg_data,io_data_rec.child_rec.tangible_id);
                ELSIF x_msg_count > 1 THEN
                LOOP
                            ln_COUNT := ln_COUNT + 1;
                            x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_NEXT,FND_API.G_FALSE);
                            IF x_msg_data IS NULL THEN
                                            EXIT;
                            END IF;
                            WRITE_CC_AUTH_DEBUG('MESSAGE ' || ln_COUNT ||'. '||x_msg_data,io_data_rec.child_rec.tangible_id);
                END LOOP;
            END IF;

             IF x_return_status = FND_API.G_RET_STS_SUCCESS
               THEN

                 io_data_rec.child_rec.approval_message := 'APPROVED & CREDIT APPLIED';
                 io_data_rec.child_rec.status:='R';
                 COMMIT;
                 UPDATE cw_ar_cc_post_paid_receipts
                 SET    APPROVAL_MESSAGE = 'APPROVED & CREDIT APPLIED',
                        STATUS = 'R'
                 WHERE  CW_RECEIPT_ID = io_data_rec.child_rec.cw_receipt_id;
                 COMMIT;

                WRITE_CC_AUTH_DEBUG('SUCCESSFULLY APPLIED CREDIT MEMO:',io_data_rec.child_rec.tangible_id);
                
                UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
                SET       STATUS_CODE        = 'S',
                          PHASE_CODE         = 'CM APPLIED SUCCESSFULLY',
                          STATUS_DESC        = 'Credit Memo applied successfully'
                WHERE     CW_RECEIPT_ID      = io_data_rec.child_rec.CW_RECEIPT_ID
                      AND CUSTOMER_TRX_ID    = l_cw_ar_cm_cur.customer_trx_id;
                COMMIT;
            ELSE

                io_data_rec.child_rec.approval_message := 'CREDIT MEMO APPLICATION FAILED';
                COMMIT;
                WRITE_CC_AUTH_DEBUG('FAILED TO APPLY CREDIT MEMO:',io_data_rec.child_rec.tangible_id);
                 insert_error (
                                p_staging_table_id => io_data_rec.child_rec.cw_receipt_id,
                                p_record_identifier => io_data_rec.child_rec.cw_receipt_id,
                                p_proc_name => 'CC_GET_ON_ACC_CM_DET',
                                p_source_field_name => 'Applying credit MEMO balance',
                                p_source_field_value => io_data_rec.child_rec.cw_receipt_id,
                                p_message_name => 'CC_GET_ON_ACC_CM_DET_0',
                                p_token_list => 'CW_RECEIPT_ID',
                                p_value_list => io_data_rec.child_rec.cw_receipt_id,
                                x_return_code => lv_return_status,
                                x_error => lv_error_name
                                );

                UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
                SET       STATUS_CODE       = 'W',
                          PHASE_CODE        = 'CM APPLICATION FAILED',
                          STATUS_DESC       = 'Credit Memo application failed'
                WHERE     CW_RECEIPT_ID     = io_data_rec.child_rec.CW_RECEIPT_ID
                      AND CUSTOMER_TRX_ID    = l_cw_ar_cm_cur.customer_trx_id;
                COMMIT;
                l_cm_flag:= 'Y';
            END IF;   

    EXIT WHEN cw_ar_cm_cur%NOTFOUND;
    END LOOP;

      /*IF l_cm_flag is NULL 
   THEN
      --io_data_rec.child_rec.status := 'R';
      io_data_rec.child_rec.approval_message := 'APPROVED';
      COMMIT;
      UPDATE cw_ar_cc_post_paid_receipts
      SET    APPROVAL_MESSAGE = 'APPROVED',
             STATUS = 'S'
      WHERE  CW_RECEIPT_ID = io_data_rec.child_rec.cw_receipt_id;
      COMMIT;

      WRITE_CC_AUTH_DEBUG('SUCCESSFULLY APPLIED CREDIT MEMO:',io_data_rec.child_rec.tangible_id);
    ELSE*/
    IF l_cm_flag ='Y' THEN
         --io_data_rec.child_rec.status := 'X';
         io_data_rec.child_rec.approval_message := 'CREDIT MEMO APPLICATION FAILED';
         io_data_rec.child_rec.status:='R';
         UPDATE cw_ar_cc_post_paid_receipts
         SET    APPROVAL_MESSAGE = 'CREDIT MEMO APPLICATION FAILED',
                STATUS = 'R'
         WHERE  CW_RECEIPT_ID = io_data_rec.child_rec.cw_receipt_id;

         COMMIT;
         WRITE_CC_AUTH_DEBUG('FAILED TO APPLY CREDIT MEMO:',io_data_rec.child_rec.tangible_id);
    END IF;


EXCEPTION
    WHEN OTHERS THEN
    X_OUT := 'Error Occured In Applying the Credit Memo to Receipt :'||SQLERRM;
     insert_error (
                    p_staging_table_id => io_data_rec.child_rec.cw_receipt_id,
                    p_record_identifier => io_data_rec.child_rec.cw_receipt_id,
                    p_proc_name => 'CC_GET_ON_ACC_CM_DET',
                    p_source_field_name => 'Applying credit MEMO balance',
                    p_source_field_value => io_data_rec.child_rec.cw_receipt_id,
                    p_message_name => 'CC_GET_ON_ACC_CM_DET_0',
                    p_token_list => 'CW_RECEIPT_ID',
                    p_value_list => io_data_rec.child_rec.cw_receipt_id,
                    x_return_code => lv_return_status,
                    x_error => lv_error_name
                    );
    WRITE_CC_AUTH_DEBUG('OTHER ERROR OCCURED IN THE PROCESS IS:'||X_OUT,io_data_rec.child_rec.tangible_id);
END CC_GET_ON_ACC_CM_DET;
/****************************************************   KC7381(END)   **************************************************/




/****************************************************   KC7381(START)   **************************************************/
PROCEDURE CC_GET_WT_CREDIT_DET (io_data_rec   IN OUT master_rec_type,
                                X_OUT            OUT VARCHAR2)
IS
   x_return_status               VARCHAR2 (2000);
   x_msg_count                   NUMBER;
   x_msg_data                    VARCHAR2 (5000);

   p_api_version                 NUMBER := 1.0;
   p_init_msg_list               VARCHAR2 (2000) := FND_API.G_TRUE;
   p_commit                      VARCHAR2 (2000) := FND_API.G_FALSE;
   p_validation_level            NUMBER := FND_API.G_VALID_LEVEL_FULL;

   x_application_ref_num         NUMBER;
   x_receivable_application_id   NUMBER;
   x_applied_rec_app_id          NUMBER;
   x_acctd_amount_applied_from   VARCHAR2 (100);
   x_acctd_amount_applied_to     VARCHAR2 (100);


   l_sum_wt_cr                   NUMBER := 0;
   l_cc_receipt_id               NUMBER := io_data_rec.child_rec.ar_receipt_id ;
   l_cc_receipt_number           VARCHAR2 (100);
   l_wt_receipt_id               NUMBER := 0;
   l_open_receipt_number         VARCHAR2 (100);
   l_closed_receipt_number       VARCHAR2 (100);
   ln_COUNT                      NUMBER :=0;
   lv_return_status           VARCHAR2 (1000);
   l_cm_flag               VARCHAR2(10);

   CURSOR cw_wt_bal
   IS
        SELECT  wt_receipt_id, nvl((-1*AMT_OFFSET),0) AMT_OFFSET
        FROM CW_AUC_RCPT_CM_APPL_CTRL
        WHERE TRANSACTION_TYPE = 'AUCTION WIRE'
                       AND cw_receipt_id = io_data_rec.child_rec.cw_receipt_id
                       AND AMT_OFFSET>0;
                       --AND STATUS_CODE!='S';
BEGIN
   BEGIN
      select RECEIPT_NUMBER
      into l_open_receipt_number
        from ar_cash_receipts_all
        where CASH_RECEIPT_ID = io_data_rec.child_rec.ar_receipt_id ;
   EXCEPTION
      WHEN OTHERS THEN
    X_OUT := 'Error Occured In finding the open receipt number :';
    WRITE_CC_AUTH_DEBUG(' ERROR OCCURED IN THE PROCESS IS:'||X_OUT,io_data_rec.child_rec.tangible_id);
   END;


   FOR l_cw_wt_bal IN cw_wt_bal
   LOOP


      BEGIN
         SELECT   RECEIPT_NUMBER
           INTO   l_closed_receipt_number
           FROM   ar_cash_receipts_all
          WHERE   CASH_RECEIPT_ID = l_cw_wt_bal.wt_receipt_id;
      EXCEPTION
         WHEN OTHERS
         THEN
            X_OUT := 'Error Occured In finding the WT receipt number :';
         WRITE_CC_AUTH_DEBUG(' ERROR OCCURED IN THE PROCESS IS:'||X_OUT,io_data_rec.child_rec.tangible_id);
      END;


      AR_RECEIPT_API_PUB.APPLY_OPEN_RECEIPT (
         P_API_VERSION                 => 1.0,
         P_INIT_MSG_LIST               => FND_API.G_TRUE,
         P_COMMIT                      => FND_API.G_TRUE,
         p_validation_level            => FND_API.G_VALID_LEVEL_FULL,
         X_RETURN_STATUS               => X_RETURN_STATUS,
         X_MSG_COUNT                   => X_MSG_COUNT,
         X_MSG_DATA                    => X_MSG_DATA,
         --p_cash_receipt_id      => l_cw_wt_bal.CASH_RECEIPT_ID,
         p_receipt_number              => l_open_receipt_number,
         --p_open_rec_app_id   => io_data_rec.child_rec.ar_receipt_id,
         p_open_receipt_number         => l_closed_receipt_number,
         p_amount_applied              => l_cw_wt_bal.AMT_OFFSET,
         P_ORG_ID                      => io_data_rec.org_id,
         x_application_ref_num         => x_application_ref_num,
         x_receivable_application_id   => x_receivable_application_id,
         x_applied_rec_app_id          => x_applied_rec_app_id,
         x_acctd_amount_applied_from   => x_acctd_amount_applied_from,
         x_acctd_amount_applied_to     => x_acctd_amount_applied_to
      );

         ln_COUNT := 0;

            IF x_msg_count = 1 THEN
                WRITE_CC_AUTH_DEBUG('X_MSG_DATA '|| x_msg_data,io_data_rec.child_rec.tangible_id);
                     /*insert_error (
                                        p_staging_table_id => in_ref_n,
                                        p_record_identifier => in_ref_n,
                                        p_proc_name => 'CC_GET_WT_CREDIT_DET',
                                        p_source_field_name => 'Applying WIRE TRANSFER balance on receipt',
                                        p_source_field_value => in_ref_n,
                                        p_message_name => 'CC_GET_WT_CREDIT_DET_0',
                                        p_token_list => 'CW_RECEIPT_ID',
                                        p_value_list => in_ref_n,
                                        x_return_code => lv_return_status,
                                        x_error => lv_error_name
                    );*/
                ELSIF x_msg_count > 1 THEN
                LOOP
                            ln_COUNT := ln_COUNT + 1;
                            x_msg_data := FND_MSG_PUB.GET(FND_MSG_PUB.G_NEXT,FND_API.G_FALSE);
                            IF x_msg_data IS NULL THEN
                                            EXIT;
                            END IF;
                            WRITE_CC_AUTH_DEBUG('MESSAGE ' || ln_COUNT ||'. '||x_msg_data,io_data_rec.child_rec.tangible_id);
                END LOOP;
            END IF;

      EXIT WHEN cw_wt_bal%NOTFOUND;
      
      IF x_return_status = FND_API.G_RET_STS_SUCCESS
               THEN

                 io_data_rec.child_rec.approval_message := 'APPROVED & CREDIT APPLIED';
                 io_data_rec.child_rec.status:='R';
                 COMMIT;
                 UPDATE cw_ar_cc_post_paid_receipts
                 SET    APPROVAL_MESSAGE = 'APPROVED & CREDIT APPLIED',
                        STATUS = 'R'
                 WHERE  CW_RECEIPT_ID = io_data_rec.child_rec.cw_receipt_id;
                 COMMIT;

                WRITE_CC_AUTH_DEBUG('SUCCESSFULLY APPLIED WIRE TRANSFER BALANCE',io_data_rec.child_rec.tangible_id);

                UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
                SET       STATUS_CODE       = 'S',
                          PHASE_CODE        = 'WT CREDIT APPLIED SUCCESSFULLY',
                          STATUS_DESC       = 'WT CREDIT Has been applied successfully'
                WHERE     CW_RECEIPT_ID     = io_data_rec.child_rec.CW_RECEIPT_ID
                          AND WT_RECEIPT_ID = l_cw_wt_bal.wt_receipt_id;
                COMMIT;
            ELSE

                io_data_rec.child_rec.approval_message := 'WIRE TRANSFER APPLICATION FAILED';
                COMMIT;
                WRITE_CC_AUTH_DEBUG('FAILED TO APPLY WIRE TRANSFER BALANCE:',io_data_rec.child_rec.tangible_id);
                     insert_error (
                        p_staging_table_id => io_data_rec.child_rec.cw_receipt_id,
                        p_record_identifier => io_data_rec.child_rec.cw_receipt_id,
                        p_proc_name => 'CC_GET_WT_CREDIT_DET',
                        p_source_field_name => 'Applying WIRE TRANSFER balance on receipt',
                        p_source_field_value => io_data_rec.child_rec.cw_receipt_id,
                        p_message_name => 'CC_GET_WT_CREDIT_DET_0',
                        p_token_list => 'CW_RECEIPT_ID',
                        p_value_list => io_data_rec.child_rec.cw_receipt_id,
                        x_return_code => lv_return_status,
                        x_error => lv_error_name
                    );

                UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
                SET       STATUS_CODE        = 'W',
                          PHASE_CODE        = 'WT CREDIT APPLICATION FAILED',
                          STATUS_DESC        = 'WT CREDIT APPLICATION FAILED'
                WHERE     CW_RECEIPT_ID    = io_data_rec.child_rec.CW_RECEIPT_ID
                          AND WT_RECEIPT_ID = l_cw_wt_bal.wt_receipt_id;
                COMMIT;
                l_cm_flag:= 'Y';
            END IF;   
            
   END LOOP;



   cw_format_string (io_msg_count_n   => x_msg_count,
                     io_msg_data_s    => x_msg_data);



   /*IF l_cm_flag IS NULL 
   THEN
      --io_data_rec.child_rec.status := 'R';
      io_data_rec.child_rec.approval_message := 'APPROVED';
      UPDATE cw_ar_cc_post_paid_receipts
      SET    APPROVAL_MESSAGE = 'APPROVED',
             STATUS = 'S'
      WHERE  CW_RECEIPT_ID = io_data_rec.child_rec.cw_receipt_id;
      COMMIT;
   ELSE*/
   IF l_cm_flag = 'Y' THEN
      --io_data_rec.child_rec.status := 'X';
      --COMMIT;
        io_data_rec.child_rec.approval_message := 'WIRE TRANSFER APPLICATION FAILED';
        io_data_rec.child_rec.status:='R';
        UPDATE cw_ar_cc_post_paid_receipts
        SET    APPROVAL_MESSAGE = 'WIRE TRANSFER APPLICATION FAILED',
        STATUS = 'R'
        WHERE  CW_RECEIPT_ID = io_data_rec.child_rec.cw_receipt_id;
      COMMIT;

   END IF;

   EXCEPTION
      WHEN OTHERS THEN
    X_OUT := 'Error Occured In applying receipt on recipt for Wire Transfer Balance :';
     insert_error (
                    p_staging_table_id => io_data_rec.child_rec.cw_receipt_id,
                    p_record_identifier => io_data_rec.child_rec.cw_receipt_id,
                    p_proc_name => 'CC_GET_WT_CREDIT_DET',
                    p_source_field_name => 'Applying WIRE TRANSFER balance on receipt',
                    p_source_field_value => io_data_rec.child_rec.cw_receipt_id,
                    p_message_name => 'CC_GET_WT_CREDIT_DET_0',
                    p_token_list => 'CW_RECEIPT_ID',
                    p_value_list => io_data_rec.child_rec.cw_receipt_id,
                    x_return_code => lv_return_status,
                    x_error => lv_error_name
                    );
    WRITE_CC_AUTH_DEBUG(' ERROR OCCURED IN THE PROCESS IS:'||X_OUT,io_data_rec.child_rec.tangible_id);

END;
/****************************************************   KC7381(END)   **************************************************/


/*********************This procedure is called from ZOOM FORM when Order type is NON-Auction order**************************/

     PROCEDURE CW_AR_CC_ACTION(in_ref_n          IN   NUMBER,
                          p_crd_card_num    IN  cw_ar_cc_post_paid_receipts.card_number%TYPE, -- MHN
                          p_exp_date        IN  cw_ar_cc_post_paid_receipts.expiry_date%TYPE, -- MHN
                          p_cvv2            IN  cw_ar_cc_post_paid_receipts.cvv2%TYPE,         -- MHN
                          p_blng_zip        IN  cw_ar_cc_post_paid_receipts.zip%TYPE,         -- MHN
                          p_card_hldr_name  IN  cw_ar_cc_post_paid_receipts.card_holder_name%TYPE, -- MHN
                          out_status_c      OUT  VARCHAR2,
                          out_text_s        OUT  VARCHAR2,
                          out_appcode_s     OUT  VARCHAR2,
                          out_receipt_id_n  OUT  NUMBER,
                          out_tang_id_s     OUT  VARCHAR2,
                          out_merchant_id_s OUT  VARCHAR2)
IS
  l_receipt_rec master_rec_type;
  l_ccas_rec    fnd_lookup_values%ROWTYPE;
  l_org_id_n    NUMBER:=FND_PROFILE.VALUE('ORG_ID');
  l_app_id_n    NUMBER:=FND_GLOBAL.resp_appl_id;
  l_cnt_n       NUMBER;
  l_api_out     VARCHAR2(1000);
BEGIN

  BEGIN
        SELECT *
        INTO   l_receipt_rec.child_rec
        FROM   cw_ar_cc_post_paid_receipts_v
        WHERE  cw_receipt_id = in_ref_n;
  EXCEPTION
        WHEN OTHERS THEN
                out_status_c := 'E';
                out_text_s   := 'Receipt Select : '||SQLERRM;
                RETURN;
  END;
  --Assign incoming parameters to the following record data -- MHN 10/22/06
  l_receipt_rec.child_rec.card_number :=  p_crd_card_num;
  l_receipt_rec.child_rec.expiry_date :=  p_exp_date;
  l_receipt_rec.child_rec.cvv2        :=  p_cvv2;
  l_receipt_rec.child_rec.zip         :=  p_blng_zip;
  l_receipt_rec.child_rec.card_holder_name := p_card_hldr_name;
  --
  out_status_c     := l_receipt_rec.child_rec.status;
  out_text_s       := l_receipt_rec.child_rec.approval_message;
  out_appcode_s    := l_receipt_rec.child_rec.approval_code;
  out_receipt_id_n := l_receipt_rec.child_rec.ar_receipt_id;
  out_tang_id_s    := l_receipt_rec.child_rec.tangible_id;

  l_receipt_rec.org_id := l_org_id_n;
  l_receipt_rec.app_id := l_app_id_n;

  SELECT COUNT(*)
  INTO   l_cnt_n
  FROM   gl_period_statuses
  WHERE  application_id = 222
  AND    TRUNC(l_receipt_rec.child_rec.receipt_date)  BETWEEN TRUNC(start_date) and TRUNC(end_date)
  AND    closing_status = 'O';

  IF l_cnt_n = 0
  THEN
        out_status_c := 'E';
        out_text_s := 'GL Period is not open for the date input date '||TRUNC(l_receipt_rec.child_rec.receipt_date);
        RETURN;
  END IF;

  BEGIN
        SELECT  lt.*
        INTO    l_ccas_rec
        FROM    ra_territories          rt,
                fnd_flex_value_sets     vs,
                fnd_flex_values_vl      fv,
                fnd_lookup_values       lt
        WHERE   rt.territory_id         = l_receipt_rec.child_rec.territory_id
        AND     vs.flex_value_set_name  = 'CW_MARKET'
        AND     fv.flex_value_set_id    = vs.flex_value_set_id
        AND     fv.flex_value           = rt.segment3
        AND     TRUNC(l_receipt_rec.child_rec.receipt_date) BETWEEN TRUNC (NVL (fv.start_date_active, TRUNC(l_receipt_rec.child_rec.receipt_date)))
                                                            AND     TRUNC (NVL (fv.end_date_active,   TRUNC(l_receipt_rec.child_rec.receipt_date)))
        AND     fv.enabled_flag         = 'Y'
        AND     lt.lookup_type          = 'CW_CCAS_GCS_MERCHANTS'
        AND     TRUNC(l_receipt_rec.child_rec.receipt_date) BETWEEN TRUNC (NVL (lt.start_date_active, TRUNC(l_receipt_rec.child_rec.receipt_date)))
                                                            AND     TRUNC (NVL (lt.end_date_active,   TRUNC(l_receipt_rec.child_rec.receipt_date)))
        AND     lt.enabled_flag         = 'Y'

        AND     fv.attribute3           = lt.lookup_code;
  EXCEPTION
        WHEN OTHERS THEN
                out_status_c := 'E';
                out_text_s := 'Not able to get CCAS/GCS Merchant Id values. SQL Error : '||SQLERRM;
                RETURN;
  END;

  IF l_ccas_rec.attribute1 IS NULL
  THEN
        out_status_c := 'E';
        out_text_s := 'No Payment Method Information Available';
        RETURN;
  END IF;

  IF l_ccas_rec.attribute2 IS NULL
  THEN
        out_status_c := 'E';
        out_text_s := 'No Payee Id Information Available';
        RETURN;
  END IF;

  IF l_ccas_rec.attribute3 IS NULL
  THEN
        out_status_c := 'E';
        out_text_s := 'No Merchant Id Information Available';
        RETURN;
  END IF;


  l_receipt_rec.method_id   := TO_NUMBER(l_ccas_rec.attribute1);
  l_receipt_rec.payee_id    := TO_NUMBER(l_ccas_rec.attribute2);
  l_receipt_rec.merchant_id := l_ccas_rec.attribute3;

  IF l_receipt_rec.child_rec.trx_type = 'AUTHCAPTURE'
  THEN
        BEGIN
                SELECT  *
                INTO    g_batch_source_rec
                FROM    ra_batch_sources
                WHERE   name   = 'CWDOC CC REFUNDS'
                AND     status = 'A'
                AND     TRUNC(l_receipt_rec.child_rec.receipt_date) BETWEEN TRUNC(NVL(START_DATE,l_receipt_rec.child_rec.receipt_date))
                                                                    AND     TRUNC(NVL(END_DATE,l_receipt_rec.child_rec.receipt_date));
        EXCEPTION
                WHEN OTHERS THEN
                        out_status_c := 'E';
                        out_text_s := 'No Refund Batch source Available';
                        RETURN;
        END;

        IF g_batch_source_rec.default_inv_trx_type IS NULL
        THEN
                out_status_c := 'E';
                out_text_s := 'No Refund Transaction Type Available';
                RETURN;
        END IF;

        BEGIN
                SELECT  *
                INTO    g_cust_trx_type_rec
                FROM    ra_cust_trx_types
                WHERE   cust_trx_type_id = g_batch_source_rec.default_inv_trx_type
                AND     NVL(status,'A')  = 'A'
                AND     TYPE             = 'DM'
                AND     TRUNC(l_receipt_rec.child_rec.receipt_date) BETWEEN TRUNC(NVL(START_DATE,l_receipt_rec.child_rec.receipt_date))
                                                                    AND     TRUNC(NVL(END_DATE,l_receipt_rec.child_rec.receipt_date));
        EXCEPTION
                WHEN OTHERS THEN
                        out_status_c := 'E';
                        out_text_s := 'No Refund Transaction Type Available';
                        RETURN;
        END;

        IF g_cust_trx_type_rec.default_term IS NULL
        THEN
                out_status_c := 'E';
                out_text_s := 'No Refund Payemnt Term Available';
                RETURN;
        END IF;

        BEGIN
                SELECT  *
                INTO    g_memo_line_rec
                FROM    ar_memo_lines_vl
                WHERE   name      = g_batch_source_rec.NAME
                AND     line_type = 'LINE'
                AND     TRUNC(l_receipt_rec.child_rec.receipt_date) BETWEEN TRUNC(NVL(START_DATE,l_receipt_rec.child_rec.receipt_date))
                                                                    AND     TRUNC(NVL(END_DATE,l_receipt_rec.child_rec.receipt_date));
        EXCEPTION
                WHEN OTHERS THEN
                        out_status_c := 'E';
                        out_text_s := 'No Refund Memo Line Available';
                        RETURN;
        END;

        /*

        SELECT  COUNT(*)
        INTO    l_cnt_n
        FROM    cw_ar_cc_post_paid_receipts
        WHERE   card_number = l_receipt_rec.child_rec.card_number
        AND     expiry_date = l_receipt_rec.child_rec.expiry_date
        AND     zip         = l_receipt_rec.child_rec.zip
        AND     trx_type    = 'AUTHONLY'
        AND     status      IN ('R','X');

        IF (l_cnt_n = 0)
        THEN
                out_status_c := 'E';
                out_text_s := 'No charge has been made on this credit card to issue refund';
                RETURN;
        END IF;
        */
  END IF;

  IF (l_receipt_rec.child_rec.status = 'E')
  THEN
        l_receipt_rec.child_rec.tangible_id := GET_TANGIBLE_ID(l_receipt_rec.child_rec.source_code);
  END IF;

  IF  l_receipt_rec.child_rec.trx_type IN ('AUTHONLY','AUTHCAPTURE')
  AND l_receipt_rec.child_rec.status   IN ('N','E')
  THEN
       WRITE_CC_AUTH_DEBUG(' Before calling CW_AR_CC_AUTH Procedure:',l_receipt_rec.child_rec.TANGIBLE_ID);
        CW_AR_CC_AUTH(io_data_rec   => l_receipt_rec,
                      X_OUT         => l_api_out);

         WRITE_CC_AUTH_DEBUG(' X_OUT Msg :'|| l_api_out,l_receipt_rec.child_rec.TANGIBLE_ID);
         WRITE_CC_AUTH_DEBUG(' Done  calling CW_AR_CC_AUTH Procedure:',l_receipt_rec.child_rec.TANGIBLE_ID);
  END IF;

  IF  l_receipt_rec.child_rec.trx_type = 'AUTHONLY'
  AND l_receipt_rec.child_rec.status   = 'X'
  THEN
        CW_AR_CC_RECEIPT(io_data_rec     => l_receipt_rec);
  END IF;

  IF  l_receipt_rec.child_rec.trx_type = 'AUTHCAPTURE'
  AND l_receipt_rec.child_rec.status   = 'D'
  THEN
        CW_AR_CC_DEBITMEMO(io_data_rec   => l_receipt_rec);
  END IF;

  out_status_c      := l_receipt_rec.child_rec.status;
  out_text_s        := l_receipt_rec.child_rec.approval_message;
  out_appcode_s     := l_receipt_rec.child_rec.approval_code;
  out_receipt_id_n  := l_receipt_rec.child_rec.ar_receipt_id;
  out_tang_id_s     := l_receipt_rec.child_rec.tangible_id;
  out_merchant_id_s := l_receipt_rec.merchant_id;
END;

/*********************This procedure is called from ZOOM FORM when Order type is Auction order**************************/
PROCEDURE CW_AR_CC_ACTION_AUCTION(in_ref_n          IN   NUMBER,
                          p_net_auth_amount IN    NUMBER,
                          p_crd_card_num    IN  cw_ar_cc_post_paid_receipts.card_number%TYPE, -- MHN
                          p_exp_date        IN  cw_ar_cc_post_paid_receipts.expiry_date%TYPE, -- MHN
                          p_cvv2            IN  cw_ar_cc_post_paid_receipts.cvv2%TYPE,         -- MHN
                          p_blng_zip        IN  cw_ar_cc_post_paid_receipts.zip%TYPE,         -- MHN
                          p_card_hldr_name  IN  cw_ar_cc_post_paid_receipts.card_holder_name%TYPE, -- MHN
                          p_order_number    IN     NUMBER,
                          out_status_c      OUT  VARCHAR2,
                          out_text_s        OUT  VARCHAR2,
                          out_appcode_s     OUT  VARCHAR2,
                          out_receipt_id_n  OUT  NUMBER,
                          out_tang_id_s     OUT  VARCHAR2,
                          out_merchant_id_s OUT  VARCHAR2)
IS
  l_receipt_rec master_rec_type;
  l_ccas_rec    fnd_lookup_values%ROWTYPE;
  l_org_id_n    NUMBER:=FND_PROFILE.VALUE('ORG_ID');
  l_app_id_n    NUMBER:=FND_GLOBAL.resp_appl_id;
  l_cnt_n       NUMBER;
  l_api_out     VARCHAR2(1000);
  l_total_credit_balance        NUMBER := 0;
  l_total_wire_transfer_balance number :=0;
  lv_return_status           VARCHAR2 (1000);
  l_con         NUMBER;
  lb_complete   BOOLEAN;
    lc_phase           VARCHAR2 (100);
    lc_status           VARCHAR2 (100);
    lc_dev_phase   VARCHAR2 (100);
    lc_dev_status   VARCHAR2 (100);
    lc_message      VARCHAR2 (100);
    l_aprvl_msg     VARCHAR2(100);
    l_aprvl_msg_flag     VARCHAR2(10);
    l_cm_failed_flag     VARCHAR2(10);
    
CURSOR cw_records_in_ctrl_table
IS
    SELECT * 
    FROM CW_AUC_RCPT_CM_APPL_CTRL
    WHERE cw_receipt_id = in_ref_n;
    
BEGIN

  BEGIN
        SELECT *
        INTO   l_receipt_rec.child_rec
        FROM   cw_ar_cc_post_paid_receipts_v
        WHERE  cw_receipt_id = in_ref_n;
  EXCEPTION
        WHEN OTHERS THEN
                out_status_c := 'E';
                out_text_s   := 'Receipt Select : '||SQLERRM;
                RETURN;
  END;

  /*************************************KC7381(START)[CALCULATING TOTAL CREDIT MEMO BALANCE FOR AUCTION ORDER]****************************************/
 BEGIN

        SELECT NVL(SUM(AMT_OFFSET),0)
        INTO l_total_credit_balance
        FROM
        CW_AUC_RCPT_CM_APPL_CTRL
        WHERE
        CW_RECEIPT_ID=in_ref_n
        AND TRANSACTION_TYPE = 'Auction Credit Memo';
   EXCEPTION
        WHEN OTHERS THEN
        WRITE_CC_AUTH_DEBUG('caught in exception for total CM balance' || l_receipt_rec.child_rec.receipt_amount,l_receipt_rec.child_rec.tangible_id);
                l_total_credit_balance :=0 ;
                RETURN;
   END;

  /*************************************KC7381(END)[CALCULATING TOTAL CREDIT MEMO BALANCE FOR AUCTION ORDER]****************************************/


  /*************************************KC7381(START)[CALCULATING TOTAL WIRE TRANSFER BALANCE FOR AUCTION ORDER]************************************/
    BEGIN
        SELECT NVL(SUM(AMT_OFFSET),0)
        INTO l_total_wire_transfer_balance
        FROM
        CW_AUC_RCPT_CM_APPL_CTRL
        WHERE
        CW_RECEIPT_ID=in_ref_n
        AND TRANSACTION_TYPE = 'AUCTION WIRE';
    EXCEPTION
        WHEN OTHERS THEN
        WRITE_CC_AUTH_DEBUG('caught in exception for total WT balance' || l_receipt_rec.child_rec.receipt_amount,l_receipt_rec.child_rec.tangible_id);
                l_total_wire_transfer_balance :=0 ;
                RETURN;
   END;

/*************************************KC7381(END)[CALCULATING TOTAL WIRE TRANSFER BALANCE FOR AUCTION ORDER]**************************************/



  --Assign incoming parameters to the following record data -- MHN 10/22/06
  l_receipt_rec.child_rec.card_number :=  p_crd_card_num;
  l_receipt_rec.child_rec.expiry_date :=  p_exp_date;
  l_receipt_rec.child_rec.cvv2        :=  p_cvv2;
  l_receipt_rec.child_rec.zip         :=  p_blng_zip;
  l_receipt_rec.child_rec.card_holder_name := p_card_hldr_name;
  --
  out_status_c     := l_receipt_rec.child_rec.status;
  out_text_s       := l_receipt_rec.child_rec.approval_message;
  out_appcode_s    := l_receipt_rec.child_rec.approval_code;
  out_receipt_id_n := l_receipt_rec.child_rec.ar_receipt_id;
  out_tang_id_s    := l_receipt_rec.child_rec.tangible_id;

  l_receipt_rec.org_id := l_org_id_n;
  l_receipt_rec.app_id := l_app_id_n;

  SELECT COUNT(*)
  INTO   l_cnt_n
  FROM   gl_period_statuses
  WHERE  application_id = 222
  AND    TRUNC(l_receipt_rec.child_rec.receipt_date)  BETWEEN TRUNC(start_date) and TRUNC(end_date)
  AND    closing_status = 'O';

  IF l_cnt_n = 0
  THEN
        out_status_c := 'E';
        UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
        SET       STATUS_CODE        = 'E',
                  PHASE_CODE        = 'GCS VALIDATION FAILED',
                  STATUS_DESC        = 'GCS Validation Error Prior approval'
        WHERE     CW_RECEIPT_ID    = in_ref_n;
        COMMIT;
        out_text_s := 'GL Period is not open for the date input date '||TRUNC(l_receipt_rec.child_rec.receipt_date);
        RETURN;
  END IF;


  BEGIN
        SELECT  lt.*
        INTO    l_ccas_rec
        FROM    ra_territories          rt,
                fnd_flex_value_sets     vs,
                fnd_flex_values_vl      fv,
                fnd_lookup_values       lt
        WHERE   rt.territory_id         = l_receipt_rec.child_rec.territory_id
        AND     vs.flex_value_set_name  = 'CW_MARKET'
        AND     fv.flex_value_set_id    = vs.flex_value_set_id
        AND     fv.flex_value           = rt.segment3
        AND     TRUNC(l_receipt_rec.child_rec.receipt_date) BETWEEN TRUNC (NVL (fv.start_date_active, TRUNC(l_receipt_rec.child_rec.receipt_date)))
                                                            AND     TRUNC (NVL (fv.end_date_active,   TRUNC(l_receipt_rec.child_rec.receipt_date)))
        AND     fv.enabled_flag         = 'Y'
        AND     lt.lookup_type          = 'CW_CCAS_GCS_MERCHANTS'
        AND     TRUNC(l_receipt_rec.child_rec.receipt_date) BETWEEN TRUNC (NVL (lt.start_date_active, TRUNC(l_receipt_rec.child_rec.receipt_date)))
                                                            AND     TRUNC (NVL (lt.end_date_active,   TRUNC(l_receipt_rec.child_rec.receipt_date)))
        AND     lt.enabled_flag         = 'Y'
        AND     fv.attribute3           = lt.lookup_code;
  EXCEPTION
        WHEN OTHERS THEN
                out_status_c := 'E';
                UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
                SET       STATUS_CODE        = 'E',
                          PHASE_CODE        = 'GCS VALIDATION FAILED',
                          STATUS_DESC        = 'GCS Validation Error Prior approval'
                WHERE     CW_RECEIPT_ID    = in_ref_n;
                COMMIT;
                     insert_error (
                                                    p_staging_table_id => in_ref_n,
                                                    p_record_identifier => in_ref_n,
                                                    p_proc_name => 'CW_AR_CC_ACTION_AUCTION',
                                                    p_source_field_name => 'GCS Approval',
                                                    p_source_field_value => in_ref_n,
                                                    p_message_name => 'CW_AR_CC_ACTION_AUCTION_0',
                                                    p_token_list => 'CW_RECEIPT_ID',
                                                    p_value_list => in_ref_n,
                                                    x_return_code => lv_return_status,
                                                    x_error => lv_error_name
                                                    );
                out_text_s := 'Not able to get CCAS/GCS Merchant Id values. SQL Error : '||SQLERRM;
                RETURN;
  END;

  IF l_ccas_rec.attribute1 IS NULL
  THEN
        out_status_c := 'E';
        UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
        SET       STATUS_CODE        = 'E',
                  PHASE_CODE        = 'GCS VALIDATION FAILED',
                  STATUS_DESC        = 'GCS Validation Error Prior approval'
        WHERE     CW_RECEIPT_ID    = in_ref_n;
        COMMIT;
          insert_error (
                                                    p_staging_table_id => in_ref_n,
                                                    p_record_identifier => in_ref_n,
                                                    p_proc_name => 'CW_AR_CC_ACTION_AUCTION',
                                                    p_source_field_name => 'GCS Approval',
                                                    p_source_field_value => in_ref_n,
                                                    p_message_name => 'CW_AR_CC_ACTION_AUCTION_0',
                                                    p_token_list => 'CW_RECEIPT_ID',
                                                    p_value_list => in_ref_n,
                                                    x_return_code => lv_return_status,
                                                    x_error => lv_error_name
                                                    );
        out_text_s := 'No Payment Method Information Available';
        RETURN;
  END IF;

  IF l_ccas_rec.attribute2 IS NULL
  THEN
        out_status_c := 'E';
        UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
        SET       STATUS_CODE        = 'E',
                  PHASE_CODE        = 'GCS VALIDATION FAILED',
                  STATUS_DESC        = 'GCS Validation Error Prior approval'
        WHERE     CW_RECEIPT_ID    = in_ref_n;
        COMMIT;
          insert_error (
                                                    p_staging_table_id => in_ref_n,
                                                    p_record_identifier => in_ref_n,
                                                    p_proc_name => 'CW_AR_CC_ACTION_AUCTION',
                                                    p_source_field_name => 'GCS Approval',
                                                    p_source_field_value => in_ref_n,
                                                    p_message_name => 'CW_AR_CC_ACTION_AUCTION_0',
                                                    p_token_list => 'CW_RECEIPT_ID',
                                                    p_value_list => in_ref_n,
                                                    x_return_code => lv_return_status,
                                                    x_error => lv_error_name
                                                    );
        out_text_s := 'No Payee Id Information Available';
        RETURN;
  END IF;

  IF l_ccas_rec.attribute3 IS NULL
  THEN
        out_status_c := 'E';
        UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
        SET       STATUS_CODE        = 'E',
                  PHASE_CODE        = 'GCS VALIDATION FAILED',
                  STATUS_DESC        = 'GCS Validation Error Prior approval'
        WHERE     CW_RECEIPT_ID    = in_ref_n;
        COMMIT;
          insert_error (
                                                    p_staging_table_id => in_ref_n,
                                                    p_record_identifier => in_ref_n,
                                                    p_proc_name => 'CW_AR_CC_ACTION_AUCTION',
                                                    p_source_field_name => 'GCS Approval',
                                                    p_source_field_value => in_ref_n,
                                                    p_message_name => 'CW_AR_CC_ACTION_AUCTION_0',
                                                    p_token_list => 'CW_RECEIPT_ID',
                                                    p_value_list => in_ref_n,
                                                    x_return_code => lv_return_status,
                                                    x_error => lv_error_name
                                                    );
        out_text_s := 'No Merchant Id Information Available';
        RETURN;
  END IF;


  l_receipt_rec.method_id   := TO_NUMBER(l_ccas_rec.attribute1);
  l_receipt_rec.payee_id    := TO_NUMBER(l_ccas_rec.attribute2);
  l_receipt_rec.merchant_id := l_ccas_rec.attribute3;

  /*IF out_status_c := 'E' THEN
        UPDATE CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
        SET        STATUS_CODE        = 'E',
                    PHASE_CODE        = 'VALIDATION FAILED',
                    STATUS_DESC        = 'Non GCS Validation Error Prior approval'
        WHERE        CW_RECEIPT_ID    = in_ref_n;
    END IF;*/

  IF l_receipt_rec.child_rec.trx_type = 'AUTHCAPTURE'
  THEN
        BEGIN
                SELECT  *
                INTO    g_batch_source_rec
                FROM    ra_batch_sources
                WHERE   name   = 'CWDOC CC REFUNDS'
                AND     status = 'A'
                AND     TRUNC(l_receipt_rec.child_rec.receipt_date) BETWEEN TRUNC(NVL(START_DATE,l_receipt_rec.child_rec.receipt_date))
                                                                    AND     TRUNC(NVL(END_DATE,l_receipt_rec.child_rec.receipt_date));
        EXCEPTION
                WHEN OTHERS THEN
                        out_status_c := 'E';
                        out_text_s := 'No Refund Batch source Available';
                        RETURN;
        END;

        IF g_batch_source_rec.default_inv_trx_type IS NULL
        THEN
                out_status_c := 'E';
                out_text_s := 'No Refund Transaction Type Available';
                RETURN;
        END IF;

        BEGIN
                SELECT  *
                INTO    g_cust_trx_type_rec
                FROM    ra_cust_trx_types
                WHERE   cust_trx_type_id = g_batch_source_rec.default_inv_trx_type
                AND     NVL(status,'A')  = 'A'
                AND     TYPE             = 'DM'
                AND     TRUNC(l_receipt_rec.child_rec.receipt_date) BETWEEN TRUNC(NVL(START_DATE,l_receipt_rec.child_rec.receipt_date))
                                                                    AND     TRUNC(NVL(END_DATE,l_receipt_rec.child_rec.receipt_date));
        EXCEPTION
                WHEN OTHERS THEN
                        out_status_c := 'E';
                        out_text_s := 'No Refund Transaction Type Available';
                        RETURN;
        END;

        IF g_cust_trx_type_rec.default_term IS NULL
        THEN
                out_status_c := 'E';
                out_text_s := 'No Refund Payemnt Term Available';
                RETURN;
        END IF;

        BEGIN
                SELECT  *
                INTO    g_memo_line_rec
                FROM    ar_memo_lines_vl
                WHERE   name      = g_batch_source_rec.NAME
                AND     line_type = 'LINE'
                AND     TRUNC(l_receipt_rec.child_rec.receipt_date) BETWEEN TRUNC(NVL(START_DATE,l_receipt_rec.child_rec.receipt_date))
                                                                    AND     TRUNC(NVL(END_DATE,l_receipt_rec.child_rec.receipt_date));
        EXCEPTION
                WHEN OTHERS THEN
                        out_status_c := 'E';
                        out_text_s := 'No Refund Memo Line Available';
                        RETURN;
        END;

        /*

        SELECT  COUNT(*)
        INTO    l_cnt_n
        FROM    cw_ar_cc_post_paid_receipts
        WHERE   card_number = l_receipt_rec.child_rec.card_number
        AND     expiry_date = l_receipt_rec.child_rec.expiry_date
        AND     zip         = l_receipt_rec.child_rec.zip
        AND     trx_type    = 'AUTHONLY'
        AND     status      IN ('R','X');

        IF (l_cnt_n = 0)
        THEN
                out_status_c := 'E';
                out_text_s := 'No charge has been made on this credit card to issue refund';
                RETURN;
        END IF;
        */
  END IF;
    /****************************************************   KC7381(START)   **************************************************/
                       IF out_status_c = 'E' THEN
                            UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
                            SET       STATUS_CODE        = 'E',
                                      PHASE_CODE        = 'GCS VALIDATION FAILED',
                                      STATUS_DESC        = 'GCS Validation Error Prior approval'
                            WHERE     CW_RECEIPT_ID    = in_ref_n;
                            COMMIT;
                                insert_error (
                                                    p_staging_table_id => in_ref_n,
                                                    p_record_identifier => in_ref_n,
                                                    p_proc_name => 'CW_AR_CC_ACTION_AUCTION',
                                                    p_source_field_name => 'GCS Approval',
                                                    p_source_field_value => in_ref_n,
                                                    p_message_name => 'CW_AR_CC_ACTION_AUCTION_0',
                                                    p_token_list => 'CW_RECEIPT_ID',
                                                    p_value_list => in_ref_n,
                                                    x_return_code => lv_return_status,
                                                    x_error => lv_error_name
                                                    );
                        ELSE
                            UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
                            SET       STATUS_CODE        = 'P',
                                      PHASE_CODE        = 'GCS AUTHORIZED',
                                      STATUS_DESC        = 'GCS Authorization Successful'
                            WHERE     CW_RECEIPT_ID    = in_ref_n;
                            COMMIT;
                        END IF;
    /****************************************************   KC7381(END)   **************************************************/
  IF (l_receipt_rec.child_rec.status = 'E')
  THEN
        l_receipt_rec.child_rec.tangible_id := GET_TANGIBLE_ID(l_receipt_rec.child_rec.source_code);
  END IF;


    IF  l_receipt_rec.child_rec.trx_type IN ('AUTHONLY','AUTHCAPTURE')
      AND l_receipt_rec.child_rec.status   IN ('N','E')-- AND p_net_auth_amount!=0
    THEN
          WRITE_CC_AUTH_DEBUG('Calling CC Auth procedure, Net Auth Amount: ' || p_net_auth_amount,l_receipt_rec.child_rec.TANGIBLE_ID);
          IF p_net_auth_amount!=0 THEN
           WRITE_CC_AUTH_DEBUG(' Before calling CW_AR_CC_AUTH Procedure:',l_receipt_rec.child_rec.TANGIBLE_ID);
            CW_AR_CC_AUTH(io_data_rec   => l_receipt_rec,
                          X_OUT         => l_api_out);

              /****************************************************   KC7381(START)   **************************************************/
                        IF l_receipt_rec.child_rec.status = 'E' THEN
                        WRITE_CC_AUTH_DEBUG('CC auth declined',l_receipt_rec.child_rec.TANGIBLE_ID);
                              UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
                              SET       STATUS_CODE       = 'E',
                                        PHASE_CODE        = 'CC DECLINED',
                                        STATUS_DESC       = 'CC Auth Declined'
                              WHERE     CW_RECEIPT_ID     = l_receipt_rec.child_rec.CW_RECEIPT_ID;
                              COMMIT;
                                      insert_error (
                                                        p_staging_table_id => in_ref_n,
                                                        p_record_identifier => in_ref_n,
                                                        p_proc_name => 'CW_AR_CC_AUTH',
                                                        p_source_field_name => 'CC Authorization',
                                                        p_source_field_value => in_ref_n,
                                                        p_message_name => 'CW_AR_CC_AUTH_0',
                                                        p_token_list => 'CW_RECEIPT_ID',
                                                        p_value_list => in_ref_n,
                                                        x_return_code => lv_return_status,
                                                        x_error => lv_error_name
                                                        );

                         ELSE
                              UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
                              SET       STATUS_CODE        = 'P',
                                        PHASE_CODE         = 'CC AUTHORIZED',
                                        STATUS_DESC        = 'CC Authorized Succesfully. Order eligible for releasing CC Hold'
                              WHERE     CW_RECEIPT_ID      = l_receipt_rec.child_rec.CW_RECEIPT_ID;
                              COMMIT;

                         END IF;
         /****************************************************   KC7381(END)   **************************************************/

           /****************************************************   KC7381(START)   **************************************************/

            --setting status in post paid receipt as R for Auc order upon successful CC authorizatio
                        If l_receipt_rec.child_rec.status = 'X' then
                        WRITE_CC_AUTH_DEBUG('updating status with R',l_receipt_rec.child_rec.TANGIBLE_ID);
                            l_receipt_rec.child_rec.status := 'R';
                            l_receipt_rec.child_rec.approval_message := 'APPROVED';

                            UPDATE CW_AR_CC_POST_PAID_RECEIPTS
                            SET     STATUS='R',
                                    APPROVAL_MESSAGE='APPROVED'
                            WHERE   CW_RECEIPT_ID=l_receipt_rec.child_rec.CW_RECEIPT_ID;
                            COMMIT;
                        END IF;

          ELSE
                        WRITE_CC_AUTH_DEBUG(' CC Auth procedure not called: ' || p_net_auth_amount,l_receipt_rec.child_rec.TANGIBLE_ID);

                        l_receipt_rec.child_rec.status := 'R';
                        l_receipt_rec.child_rec.approval_message := 'APPROVED';

                            UPDATE CW_AR_CC_POST_PAID_RECEIPTS
                            SET     STATUS='R',
                                    APPROVAL_MESSAGE='APPROVED'
                            WHERE   CW_RECEIPT_ID=l_receipt_rec.child_rec.CW_RECEIPT_ID;

                        
                            COMMIT;

              END IF;

            --Calling CC hold release concurrent program to release hold
            

            IF l_receipt_rec.child_rec.trx_type = 'AUTHONLY'
              AND l_receipt_rec.child_rec.approval_message = 'APPROVED' and l_receipt_rec.child_rec.status = 'R' THEN
              
                    l_con := fnd_request.submit_request
                                (
                                application => 'CCWONT',
                                program => 'CUST_AUCTION_CC_HOLD_RELEASE',
                                start_time => SYSDATE,
                                sub_request => FALSE,
                                argument1 => p_order_number
                                );
                                commit;
                    IF l_con=0 THEN
                        insert_error (
                                         p_staging_table_id => in_ref_n,
                                         p_record_identifier => in_ref_n,
                                         p_proc_name => 'CUST_AUCTION_CC_HOLD_RELEASE CONCURRENT PROGRAM',
                                         p_source_field_name => 'CALLING CONCUREENT PROGRAM CUST_AUCTION_CC_HOLD_RELEASE TO RELEASE CC HOLD',
                                         p_source_field_value => in_ref_n,
                                         p_message_name => 'CUST_AUCTION_CC_HOLD_RELEASE_0',
                                         p_token_list => 'CW_RECEIPT_ID',
                                         p_value_list => in_ref_n,
                                         x_return_code => lv_return_status,
                                         x_error => lv_error_name
                                         );
                        WRITE_CC_AUTH_DEBUG(' Failed to run the concurrent program CUST_AUCTION_CC_HOLD_RELEASE',l_receipt_rec.child_rec.TANGIBLE_ID);
                    ELSE
                        WRITE_CC_AUTH_DEBUG(' Successfully ran the concurrent program CUST_AUCTION_CC_HOLD_RELEASE FOR REQUEST_ID : '||l_con,l_receipt_rec.child_rec.TANGIBLE_ID);
                    END IF;

              


              ------------------Updating status back for the order to OMS and Oracle staging tables-------------------------
              UPDATE genco_auction_stg@ORAFDC.DB.ATT.COM
              SET    CC_AUTHORIZATION_STATUS = 'Y'
              WHERE  ORACLE_ORDER_NUMBER = p_order_number;
              COMMIT;

              UPDATE CUST_AUCTION_STG
              SET    CC_AUTHORIZATION_STATUS = 'Y'
              WHERE  ORACLE_ORDER_NUMBER = p_order_number;
              COMMIT;
             END IF;
             
        /****************************************************   KC7381(END)   **************************************************/


          /****************************************************   KC7381(END)   **************************************************/

             WRITE_CC_AUTH_DEBUG(' X_OUT Msg :'|| l_api_out,l_receipt_rec.child_rec.TANGIBLE_ID);
             WRITE_CC_AUTH_DEBUG(' Done  calling CW_AR_CC_AUTH Procedure:',l_receipt_rec.child_rec.TANGIBLE_ID);
         /****************************************************   KC7381(START)   **************************************************/

    ELSE
        l_receipt_rec.child_rec.status   := 'E';
    END IF;

  IF  l_receipt_rec.child_rec.trx_type = 'AUTHONLY'
  AND l_receipt_rec.child_rec.status   ='R' AND l_receipt_rec.child_rec.approval_message = 'APPROVED'--AND (l_total_credit_balance!=0 OR p_net_auth_amount!=0)
  THEN
        CW_AR_CC_RECEIPT(io_data_rec     => l_receipt_rec);

        --Calling the CUST_AUCTION_CC_HOLD_RELEASE Concurrent program to book the order once receipt gets created


      /****************************************************   KC7381(START)   **************************************************/
      
            IF l_receipt_rec.child_rec.approval_message = 'APPROVED' THEN
               
   
                    UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
                    SET       STATUS_CODE        = 'S',
                              PHASE_CODE        = 'RECEIPT CREATED',
                              STATUS_DESC        = 'Receipt Creation Successful'
                    WHERE     CW_RECEIPT_ID    = l_receipt_rec.child_rec.CW_RECEIPT_ID
                              AND AMT_OFFSET   !=0;
                    COMMIT;
                    UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
                    SET       STATUS_CODE        = 'S',
                              PHASE_CODE        = 'Unused',
                              STATUS_DESC        = 'Unused'
                    WHERE     CW_RECEIPT_ID    = l_receipt_rec.child_rec.CW_RECEIPT_ID
                              AND AMT_OFFSET   =0;
                    COMMIT;

            ELSE   

                    UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
                    SET       STATUS_CODE        = 'W',
                              PHASE_CODE        = 'RECEIPT CREATION FAILED',
                              STATUS_DESC       = 'Reprocess from receipt Creation'
                    WHERE     CW_RECEIPT_ID    = l_receipt_rec.child_rec.CW_RECEIPT_ID
                              AND AMT_OFFSET   !=0;
                    COMMIT;

                    UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
                    SET       STATUS_CODE        = 'S',
                              PHASE_CODE        = 'Unused',
                              STATUS_DESC        = 'Unused'
                    WHERE     CW_RECEIPT_ID    = l_receipt_rec.child_rec.CW_RECEIPT_ID
                              AND AMT_OFFSET   =0;

                    insert_error (
                                                    p_staging_table_id => in_ref_n,
                                                    p_record_identifier => in_ref_n,
                                                    p_proc_name => 'CW_AR_CC_RECEIPT',
                                                    p_source_field_name => 'Receipt Creation for Net Auth Amount',
                                                    p_source_field_value => in_ref_n,
                                                    p_message_name => 'CW_AR_CC_RECEIPT_0',
                                                    p_token_list => 'CW_RECEIPT_ID',
                                                    p_value_list => in_ref_n,
                                                    x_return_code => lv_return_status,
                                                    x_error => lv_error_name
                                                    );
            END IF;
            
            
            
                   /* IF l_receipt_rec.child_rec.approval_message = 'APPROVED' THEN
                            UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
                            SET       STATUS_CODE        = 'S',
                                      PHASE_CODE        = 'RECEIPT CREATED',
                                      STATUS_DESC        = 'Receipt Creation Successful'
                            WHERE     CW_RECEIPT_ID    = l_receipt_rec.child_rec.CW_RECEIPT_ID;
                            COMMIT;

                    ELSE
                            UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
                            SET       STATUS_CODE       = 'W',
                                      PHASE_CODE        = 'RECEIPT CREATION FAILED',
                                      STATUS_DESC       = 'Reprocess from receipt Creation'
                            WHERE     CW_RECEIPT_ID     = l_receipt_rec.child_rec.CW_RECEIPT_ID;
                            COMMIT;
                                     insert_error (
                                                    p_staging_table_id => in_ref_n,
                                                    p_record_identifier => in_ref_n,
                                                    p_proc_name => 'CW_AR_CC_RECEIPT',
                                                    p_source_field_name => 'Receipt Creation for Net Auth Amount',
                                                    p_source_field_value => in_ref_n,
                                                    p_message_name => 'CW_AR_CC_RECEIPT_0',
                                                    p_token_list => 'CW_RECEIPT_ID',
                                                    p_value_list => in_ref_n,
                                                    x_return_code => lv_return_status,
                                                    x_error => lv_error_name
                                                    );

                    END IF;*/
      /****************************************************   KC7381(END)   **************************************************/


 /* IF l_con<>0 THEN
        lb_complete :=fnd_concurrent.wait_for_request (request_id      => l_con
                                                             ,interval            => 1
                                                             ,max_wait        => 60
                                                             -- out arguments
                                                             ,phase              => lc_phase
                                                             ,status              => lc_status
                                                             ,dev_phase      => lc_dev_phase
                                                             ,dev_status      => lc_dev_status
                                                             ,message         => lc_message
                                            );
         WRITE_CC_AUTH_DEBUG(' return message l_con : '||l_con,l_receipt_rec.child_rec.TANGIBLE_ID);
         WRITE_CC_AUTH_DEBUG(' return message lc_phase : '||lc_phase,l_receipt_rec.child_rec.TANGIBLE_ID);
         WRITE_CC_AUTH_DEBUG(' return message lc_status : '||lc_status,l_receipt_rec.child_rec.TANGIBLE_ID);
         WRITE_CC_AUTH_DEBUG(' return message lc_dev_phase : '||lc_dev_phase,l_receipt_rec.child_rec.TANGIBLE_ID);
         WRITE_CC_AUTH_DEBUG(' return message lc_dev_status : '||lc_dev_status,l_receipt_rec.child_rec.TANGIBLE_ID);
         WRITE_CC_AUTH_DEBUG(' return message lc_message : '||lc_message,l_receipt_rec.child_rec.TANGIBLE_ID);
         COMMIT;
         IF UPPER (lc_dev_phase) IN ('COMPLETE')
         THEN*/

    END IF;

          IF l_receipt_rec.child_rec.trx_type = 'AUTHONLY'
          AND l_receipt_rec.child_rec.approval_message = 'APPROVED' AND l_total_credit_balance!=0 AND l_receipt_rec.child_rec.status   = 'R'
          THEN
                CC_GET_ON_ACC_CM_DET (io_data_rec     => l_receipt_rec,
                                        X_OUT         => l_api_out);
            /****************************************************   KC7381(START)   **************************************************/
                            /*IF l_receipt_rec.child_rec.approval_message = 'APPROVED' THEN
                                    UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
                                    SET       STATUS_CODE        = 'S',
                                              PHASE_CODE         = 'CM APPLIED SUCCESSFULLY',
                                              STATUS_DESC        = 'Credit Memo applied successfully'
                                    WHERE     CW_RECEIPT_ID      = l_receipt_rec.child_rec.CW_RECEIPT_ID;
                                    COMMIT;
                            ELSE
                                    UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
                                    SET       STATUS_CODE       = 'W',
                                              PHASE_CODE        = 'CM APPLICATION FAILED',
                                              STATUS_DESC       = 'Credit Memo application failed'
                                    WHERE     CW_RECEIPT_ID     = l_receipt_rec.child_rec.CW_RECEIPT_ID;
                                    COMMIT;
                                             insert_error (
                                                            p_staging_table_id => in_ref_n,
                                                            p_record_identifier => in_ref_n,
                                                            p_proc_name => 'CC_GET_ON_ACC_CM_DET',
                                                            p_source_field_name => 'Applying credit MEMO balance',
                                                            p_source_field_value => in_ref_n,
                                                            p_message_name => 'CC_GET_ON_ACC_CM_DET_0',
                                                            p_token_list => 'CW_RECEIPT_ID',
                                                            p_value_list => in_ref_n,
                                                            x_return_code => lv_return_status,
                                                            x_error => lv_error_name
                                                            );
                            END IF;*/
                            
                            /*SELECT COUNT(1)
                            INTO    l_aprvl_msg
                            FROM   CW_AUC_RCPT_CM_APPL_CTRL
                            WHERE   CW_RECEIPT_ID=l_receipt_rec.child_rec.cw_receipt_id
                                    AND PHASE_CODE = 'CM APPLICATION FAILED';
                            
                                        
                            IF  l_aprvl_msg>0 THEN
                                l_receipt_rec.child_rec.approval_message := 'CREDIT MEMO APPLICATION FAILED';
                                UPDATE CW_AR_CC_POST_PAID_RECEIPTS
                                SET    APPROVAL_MESSAGE ='CREDIT MEMO APPLICATION FAILED'
                                WHERE CW_RECEIPT_ID=l_receipt_rec.child_rec.cw_receipt_id;
                            END IF;*/
                            
                IF p_net_auth_amount=0 AND l_receipt_rec.child_rec.approval_message='APPROVED & CREDIT APPLIED'THEN
                 l_receipt_rec.child_rec.approval_message := 'CREDIT APPLIED';
                 l_receipt_rec.child_rec.status:='R';
                 COMMIT;
                 UPDATE cw_ar_cc_post_paid_receipts
                 SET    APPROVAL_MESSAGE = 'CREDIT APPLIED',
                        STATUS = 'R'
                 WHERE  CW_RECEIPT_ID = l_receipt_rec.child_rec.cw_receipt_id;
                 COMMIT;
                END IF;
            /****************************************************   KC7381(END)   **************************************************/
          END IF;
          
           IF  l_receipt_rec.child_rec.trx_type = 'AUTHONLY' 
           AND l_total_wire_transfer_balance!=0 AND l_receipt_rec.child_rec.status='R' and (l_receipt_rec.child_rec.approval_message = 'APPROVED' or l_receipt_rec.child_rec.approval_message ='APPROVED & CREDIT APPLIED' or l_receipt_rec.child_rec.approval_message='CREDIT APPLIED' or l_receipt_rec.child_rec.approval_message='CREDIT MEMO APPLICATION FAILED')
           THEN 
                IF l_receipt_rec.child_rec.approval_message='CREDIT MEMO APPLICATION FAILED' THEN
                    l_cm_failed_flag:='Y';
                END IF;
                CC_GET_WT_CREDIT_DET(io_data_rec     => l_receipt_rec,
                                        X_OUT         => l_api_out);
               
              /****************************************************   KC7381(START)   **************************************************/
                                /* IF l_receipt_rec.child_rec.approval_message = 'APPROVED' THEN
                                    UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
                                    SET       STATUS_CODE       = 'S',
                                              PHASE_CODE        = 'WT Credit APPLIED SUCCESSFULLY',
                                              STATUS_DESC       = 'WT Credit Has been applied successfully'
                                    WHERE     CW_RECEIPT_ID     = l_receipt_rec.child_rec.CW_RECEIPT_ID;
                                    COMMIT;
                                 ELSE
                                    UPDATE    CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
                                    SET       STATUS_CODE        = 'W',
                                              PHASE_CODE        = 'WT Credit APPLICATION FAILED',
                                              STATUS_DESC        = 'WT Credit APPLICATION FAILED'
                                    WHERE     CW_RECEIPT_ID    = l_receipt_rec.child_rec.CW_RECEIPT_ID;
                                    COMMIT;
                                             insert_error (
                                                            p_staging_table_id => in_ref_n,
                                                            p_record_identifier => in_ref_n,
                                                            p_proc_name => 'CC_GET_WT_CREDIT_DET',
                                                            p_source_field_name => 'Applying WIRE TRANSFER balance on receipt',
                                                            p_source_field_value => in_ref_n,
                                                            p_message_name => 'CC_GET_WT_CREDIT_DET_0',
                                                            p_token_list => 'CW_RECEIPT_ID',
                                                            p_value_list => in_ref_n,
                                                            x_return_code => lv_return_status,
                                                            x_error => lv_error_name
                                                            );
                                END IF;*/
            /****************************************************   KC7381(END)   **************************************************/
            
                            /*SELECT COUNT(1)
                            INTO    l_aprvl_msg
                            FROM   CW_AUC_RCPT_CM_APPL_CTRL
                            WHERE   CW_RECEIPT_ID=l_receipt_rec.child_rec.cw_receipt_id
                                    AND PHASE_CODE = 'WT CREDIT APPLICATION FAILED';
                            
                                        
                            IF  l_aprvl_msg>0 THEN
                                l_receipt_rec.child_rec.approval_message := 'WIRE TRANSFER APPLICATION FAILED';
                                UPDATE CW_AR_CC_POST_PAID_RECEIPTS
                                SET    APPROVAL_MESSAGE ='WIRE TRANSFER APPLICATION FAILED'
                                WHERE CW_RECEIPT_ID=l_receipt_rec.child_rec.cw_receipt_id;
                            END IF;*/
               /* IF p_net_auth_amount=0 THEN
                 l_receipt_rec.child_rec.approval_message := 'CREDIT APPLIED';
                 l_receipt_rec.child_rec.status:='R';
                 COMMIT;
                 UPDATE cw_ar_cc_post_paid_receipts
                 SET    APPROVAL_MESSAGE = 'CREDIT APPLIED',
                        STATUS = 'R'
                 WHERE  CW_RECEIPT_ID = l_receipt_rec.child_rec.cw_receipt_id;
                 COMMIT;
                END IF;*/
                
                IF l_cm_failed_flag = 'Y' THEN
                     l_receipt_rec.child_rec.approval_message  := 'CREDIT MEMO APPLICATION FAILED';
                     l_receipt_rec.child_rec.status:='R';
                     
                     UPDATE cw_ar_cc_post_paid_receipts
                     SET    APPROVAL_MESSAGE = 'CREDIT MEMO APPLICATION FAILED',
                            STATUS = 'R'
                     WHERE  CW_RECEIPT_ID = l_receipt_rec.child_rec.cw_receipt_id;

                     COMMIT; 
                ELSIF p_net_auth_amount=0 AND l_receipt_rec.child_rec.approval_message='APPROVED & CREDIT APPLIED' THEN  
                     l_receipt_rec.child_rec.approval_message := 'CREDIT APPLIED';
                     l_receipt_rec.child_rec.status:='R';
                     COMMIT;
                     UPDATE cw_ar_cc_post_paid_receipts
                     SET    APPROVAL_MESSAGE = 'CREDIT APPLIED',
                            STATUS = 'R'
                     WHERE  CW_RECEIPT_ID = l_receipt_rec.child_rec.cw_receipt_id;
                     COMMIT;
            
                END IF;
            END IF;
  /****************************************************   KC7381(START)   **************************************************/
  /*IF l_receipt_rec.child_rec.trx_type = 'AUTHONLY'
  AND l_receipt_rec.child_rec.approval_message = 'APPROVED' THEN
        l_con := fnd_request.submit_request
                    (
                    application => 'CCWONT',
                    program => 'CUST_AUCTION_CC_HOLD_RELEASE',
                    start_time => SYSDATE,
                    sub_request => FALSE,
                    argument1 => p_order_number
                    );
                    commit;
        IF l_con=0 THEN
            insert_error (
                             p_staging_table_id => in_ref_n,
                             p_record_identifier => in_ref_n,
                             p_proc_name => 'CUST_AUCTION_CC_HOLD_RELEASE CONCURRENT PROGRAM',
                             p_source_field_name => 'CALLING CONCUREENT PROGRAM CUST_AUCTION_CC_HOLD_RELEASE TO RELEASE CC HOLD',
                             p_source_field_value => in_ref_n,
                             p_message_name => 'CUST_AUCTION_CC_HOLD_RELEASE_0',
                             p_token_list => 'CW_RECEIPT_ID',
                             p_value_list => in_ref_n,
                             x_return_code => lv_return_status,
                             x_error => lv_error_name
                             );
            WRITE_CC_AUTH_DEBUG(' Failed to run the concurrent program CUST_AUCTION_CC_HOLD_RELEASE',l_receipt_rec.child_rec.TANGIBLE_ID);
        ELSE
            WRITE_CC_AUTH_DEBUG(' Successfully ran the concurrent program CUST_AUCTION_CC_HOLD_RELEASE FOR REQUEST_ID : '||l_con,l_receipt_rec.child_rec.TANGIBLE_ID);
        END IF;
  END IF;*/
    /****************************************************   KC7381(END)   **************************************************/
    --END IF;
  --END IF;

  IF  l_receipt_rec.child_rec.trx_type = 'AUTHCAPTURE'
  AND l_receipt_rec.child_rec.status   = 'D'
  THEN
        CW_AR_CC_DEBITMEMO(io_data_rec   => l_receipt_rec);
  END IF;

  out_status_c      := l_receipt_rec.child_rec.status;
  out_text_s        := l_receipt_rec.child_rec.approval_message;
  out_appcode_s     := l_receipt_rec.child_rec.approval_code;
  out_receipt_id_n  := l_receipt_rec.child_rec.ar_receipt_id;
  out_tang_id_s     := l_receipt_rec.child_rec.tangible_id;
  out_merchant_id_s := l_receipt_rec.merchant_id;
END;

END CW_AR_CC_RECEIPT_PKG;
/



show errors;
prompt;

SELECT TO_CHAR(sysdate,'DD-MON-RRRR HH:MI:SS')
FROM sys.dual;
  
SET PAGESIZE 30
SET LINESIZE 200
col object_name format a30

SELECT object_name,object_type,timestamp,status
  FROM dba_objects
 WHERE object_name = upper('CW_AR_CC_RECEIPT_PKG')
   AND object_type like 'PACKAGE%';
EXIT