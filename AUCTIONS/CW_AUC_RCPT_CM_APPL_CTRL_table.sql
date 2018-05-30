/*
****************************************************************
**  ATT CUSTOMIZATIONS
****************************************************************
**                                                      
**  FILE NAME: CW_AUC_RCPT_CM_APPL_CTRL_table.sql
**
**  THIS SCRIPT CREATES THE TABLE,SYNONYM AND SEQUENCE 
**  FOR THE CUSTOM AUCTION CUSTOMER CREATE/IMPORT PROGRAM 
**
**  MODIFICATION HISTORY:
**  08/05/2014 KAUSHIKI CHOWDHURY  INITIAL CREATION
**                        
****************************************************************
*/
SET SERVEROUTPUT ON SIZE 100000

------------Table Creation----------------------

CREATE TABLE CCWAR.CW_AUC_RCPT_CM_APPL_CTRL
(
RECORD_ID    NUMBER,
CW_RECEIPT_ID    NUMBER,
CUSTOMER_TRX_ID    NUMBER (15),
WT_RECEIPT_ID       NUMBER (15),
AMT_DUE_REMAINING    NUMBER,
AMT_OFFSET    NUMBER,
STATUS_CODE    VARCHAR2 (1 Byte),
PHASE_CODE    VARCHAR2 (50 Byte),
STATUS_DESC    VARCHAR2 (200 Byte),
OVERRIDE_FLAG    VARCHAR2 (1 Byte),
SOURCE_ID    NUMBER,
TRANSACTION_TYPE    VARCHAR2 (100 Byte),
TRANSACTION_NUMBER    VARCHAR2 (50 Byte),
CREDIT_AVAILABLE    NUMBER,
CREDIT_APPLIED    NUMBER,
ATTRIBUTE_CATEGORY    VARCHAR2 (30 Byte),
ATTRIBUTE1    VARCHAR2 (150 Byte),
ATTRIBUTE2    VARCHAR2 (150 Byte),
ATTRIBUTE3    VARCHAR2 (150 Byte),
ATTRIBUTE4    VARCHAR2 (150 Byte),
ATTRIBUTE5    VARCHAR2 (150 Byte),
ATTRIBUTE6    VARCHAR2 (150 Byte),
ATTRIBUTE7    VARCHAR2 (150 Byte),
ATTRIBUTE8    VARCHAR2 (150 Byte),
ATTRIBUTE9    VARCHAR2 (150 Byte),
ATTRIBUTE10    VARCHAR2 (150 Byte),
ATTRIBUTE11    VARCHAR2 (150 Byte),
ATTRIBUTE12    VARCHAR2 (150 Byte),
ATTRIBUTE13    VARCHAR2 (150 Byte),
ATTRIBUTE14    VARCHAR2 (150 Byte),
ATTRIBUTE15    VARCHAR2 (150 Byte),
APPLIED_PS_ID    NUMBER (15),
CREATION_DATE    DATE,
LAST_UPDATE_DATE    DATE,
CREATED_BY    NUMBER (15),
LAST_UPDATED_BY    NUMBER (15),
SLNO    NUMBER
);


-----------Synonym Creation for table--------------

CREATE SYNONYM APPS.CW_AUC_RCPT_CM_APPL_CTRL FOR CCWAR.CW_AUC_RCPT_CM_APPL_CTRL;

---------------Sequence creation-------------------

CREATE SEQUENCE CCWAR.CW_AUC_RCPT_CM_APPL_CTRL_S 
START WITH 1 
MAXVALUE 9999999999999999999999999999
MINVALUE 1; 

-----------Synonym Creation for Sequence------------

CREATE SYNONYM APPS.CW_AUC_RCPT_CM_APPL_CTRL_S FOR CCWAR.CW_AUC_RCPT_CM_APPL_CTRL_S;

EXIT;
/