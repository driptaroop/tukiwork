
CREATE OR REPLACE FORCE VIEW APPS.CW_AR_CC_POST_PAID_RECEIPTS_V
(
   ACCOUNT_NUMBER,
   PARTY_NAME,
   LOCATION,
   ADDRESS,
   RECEIPT_DATE,
   RECEIPT_AMOUNT,
   CARD_NUMBER,
   EXPIRY_DATE,
   CVV2,
   ZIP,
   CARD_HOLDER_NAME,
   APPROVAL_CODE,
   STATUS,
   APPROVAL_MESSAGE,
   TANGIBLE_ID,
   ROW_ID,
   CW_RECEIPT_ID,
   AR_RECEIPT_ID,
   CUST_ACCOUNT_ID,
   SITE_USE_ID,
   CREATED_BY,
   CREATION_DATE,
   LAST_UPDATED_BY,
   LAST_UPDATE_DATE,
   LAST_UPDATE_LOGIN,
   SALESREP_ID,
   SOURCE_CODE,
   SOURCE_ID,
   ORDER_NUMBER,
   TRX_TYPE,
   COMMENTS,
   APPLIED_PS_ID,
   CUST_PO_NUMBER,
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
   CUST_ACCT_SITE_ID,
   MERCHANT_ID,
   TERRITORY_ID
)
AS
   SELECT   cust.account_number,
            prty.party_name,
            uses.location,
               locn.address1
            || ','
            || locn.address2
            || ','
            || locn.address3
            || ','
            || locn.address4
            || ','
            || locn.city
            || ','
            || locn.state
            || ','
            || locn.postal_code
            || ','
            || locn.country
               address,
            cc.receipt_date,
            cc.receipt_amount,
            cc.card_number,
            cc.expiry_date,
            cc.cvv2,
            cc.zip,
            cc.card_holder_name,
            cc.approval_code,
            cc.status,
            cc.approval_message,
            cc.tangible_id,
            cc.ROWID row_id,
            cc.cw_receipt_id,
            cc.ar_receipt_id,
            cc.cust_account_id,
            cc.site_use_id,
            cc.created_by,
            cc.creation_date,
            cc.last_updated_by,
            cc.last_update_date,
            cc.last_update_login,
            uses.primary_salesrep_id salesrep_id,
            cc.source_code,
            cc.source_id,
            NULL order_number,
            cc.trx_type,
            cc.comments,
            cc.applied_ps_id,
            NULL cust_po_number,
            cc.attribute_category,
            cc.attribute1,
            cc.attribute2,
            cc.attribute3,
            cc.attribute4,
            cc.attribute5,
            cc.attribute6,
            cc.attribute7,
            cc.attribute8,
            cc.attribute9,
            cc.attribute10,
            cc.attribute11,
            cc.attribute12,
            cc.attribute13,
            cc.attribute14,
            cc.attribute15,
            addr.cust_acct_site_id,
            cc.merchant_id,
            uses.territory_id
     FROM   cw_ar_cc_post_paid_receipts cc,
            hz_cust_accounts cust,
            hz_parties prty,
            hz_cust_site_uses uses,
            hz_cust_acct_sites addr,
            hz_party_sites psite,
            hz_locations locn
    WHERE       cc.source_code = 'CCW'
            AND cust.cust_account_id = cc.cust_account_id
            AND prty.party_id = cust.party_id
            AND uses.site_use_id = cc.site_use_id
            AND addr.cust_acct_site_id = uses.cust_acct_site_id
            AND psite.party_site_id = addr.party_site_id
            AND locn.location_id = psite.location_id
   UNION ALL
   SELECT   cust.account_number,
            prty.party_name,
            uses.location,
               locn.address1
            || ','
            || locn.address2
            || ','
            || locn.address3
            || ','
            || locn.address4
            || ','
            || locn.city
            || ','
            || locn.state
            || ','
            || locn.postal_code
            || ','
            || locn.country
               address,
            cc.receipt_date,
            cc.receipt_amount,
            cc.card_number,
            cc.expiry_date,
            cc.cvv2,
            cc.zip,
            cc.card_holder_name,
            cc.approval_code,
            cc.status,
            cc.approval_message,
            cc.tangible_id,
            cc.ROWID row_id,
            cc.cw_receipt_id,
            cc.ar_receipt_id,
            cust.cust_account_id,
            uses.site_use_id,
            cc.created_by,
            cc.creation_date,
            cc.last_updated_by,
            cc.last_update_date,
            cc.last_update_login,
            oe.salesrep_id,
            cc.source_code,
            cc.source_id,
            oe.order_number,
            cc.trx_type,
            cc.comments,
            cc.applied_ps_id,
            oe.cust_po_number,
            cc.attribute_category,
            cc.attribute1,
            cc.attribute2,
            cc.attribute3,
            cc.attribute4,
            cc.attribute5,
            cc.attribute6,
            cc.attribute7,
            cc.attribute8,
            cc.attribute9,
            cc.attribute10,
            cc.attribute11,
            cc.attribute12,
            cc.attribute13,
            cc.attribute14,
            cc.attribute15,
            addr.cust_acct_site_id,
            cc.merchant_id,
            uses.territory_id
     FROM   cw_ar_cc_post_paid_receipts cc,
            oe_order_headers oe,
            hz_cust_accounts cust,
            hz_parties prty,
            hz_cust_site_uses uses,
            hz_cust_acct_sites addr,
            hz_party_sites psite,
            hz_locations locn
    WHERE       cc.source_code = 'ONT'
            AND oe.header_id = cc.source_id
            AND uses.site_use_id = oe.invoice_to_org_id
            AND addr.cust_acct_site_id = uses.cust_acct_site_id
            AND psite.party_site_id = addr.party_site_id
            AND locn.location_id = psite.location_id
            AND cust.cust_account_id = addr.cust_account_id
            AND prty.party_id = cust.party_id
UNION ALL
   SELECT   cust.account_number,
            prty.party_name,
            uses.location,
               locn.address1
            || ','
            || locn.address2
            || ','
            || locn.address3
            || ','
            || locn.address4
            || ','
            || locn.city
            || ','
            || locn.state
            || ','
            || locn.postal_code
            || ','
            || locn.country
               address,
            cc.receipt_date,
            cc.receipt_amount,
            cc.card_number,
            cc.expiry_date,
            cc.cvv2,
            cc.zip,
            cc.card_holder_name,
            cc.approval_code,
            cc.status,
            cc.approval_message,
            cc.tangible_id,
            cc.ROWID row_id,
            cc.cw_receipt_id,
            cc.ar_receipt_id,
            cust.cust_account_id,
            uses.site_use_id,
            cc.created_by,
            cc.creation_date,
            cc.last_updated_by,
            cc.last_update_date,
            cc.last_update_login,
            oe.salesrep_id,
            cc.source_code,
            cc.source_id,
            oe.order_number,
            cc.trx_type,
            cc.comments,
            cc.applied_ps_id,
            oe.cust_po_number,
            cc.attribute_category,
            cc.attribute1,
            cc.attribute2,
            cc.attribute3,
            cc.attribute4,
            cc.attribute5,
            cc.attribute6,
            cc.attribute7,
            cc.attribute8,
            cc.attribute9,
            cc.attribute10,
            cc.attribute11,
            cc.attribute12,
            cc.attribute13,
            cc.attribute14,
            cc.attribute15,
            addr.cust_acct_site_id,
            cc.merchant_id,
            uses.territory_id
     FROM   cw_ar_cc_post_paid_receipts cc,
            oe_order_headers oe,
            hz_cust_accounts cust,
            hz_parties prty,
            hz_cust_site_uses uses,
            hz_cust_acct_sites addr,
            hz_party_sites psite,
            hz_locations locn
    WHERE       cc.source_code = 'AUC'
            AND oe.header_id = cc.source_id
            AND uses.site_use_id = oe.invoice_to_org_id
            AND addr.cust_acct_site_id = uses.cust_acct_site_id
            AND psite.party_site_id = addr.party_site_id
            AND locn.location_id = psite.location_id
            AND cust.cust_account_id = addr.cust_account_id
            AND prty.party_id = cust.party_id;

EXIT;