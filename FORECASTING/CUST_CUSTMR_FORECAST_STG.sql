/*
****************************************************************
**  ATT CUSTOMIZATIONS
****************************************************************
**                                                      
**  FILE NAME: CUST_CUSTMR_FORECAST_STG.sql
**
**  THIS SCRIPT TABLE
**
**  MODIFICATION HISTORY:
**  04/29/2015 KAUSHIKI CHOWDHURY  INITIAL CREATION
**                        
****************************************************************
*/
SET SERVEROUTPUT ON SIZE 100000

------------Table Creation----------------------

CREATE TABLE CUST_CUSTMR_FORECAST_STG
(
	 ITEM_COL        VARCHAR2(100),
    REGION_COL    VARCHAR2(100),
    DATE1        VARCHAR2(100),
    DATE2        VARCHAR2(100),
    DATE3        VARCHAR2(100),
    DATE4        VARCHAR2(100),
    DATE5        VARCHAR2(100),
    DATE6        VARCHAR2(100),
    DATE7        VARCHAR2(100),
    DATE8        VARCHAR2(100),
    DATE9        VARCHAR2(100),
    DATE10    VARCHAR2(100),
    DATE11    VARCHAR2(100),
    DATE12    VARCHAR2(100),
    NOTE        VARCHAR2(100),
    ERR           VARCHAR2(1500),
	 REQUEST_ID  NUMBER
 );
 
 EXIT;
 /
