/*
****************************************************************
**  ATT CUSTOMIZATIONS
****************************************************************
**                                                      
**  FILE NAME: CUST_PURCHS_FORECAST_STG.sql
**
**  THIS SCRIPT CREATES TABLE
**
**  MODIFICATION HISTORY:
**  04/13/2015 KAUSHIKI CHOWDHURY  INITIAL CREATION
**                        
****************************************************************
*/
SET SERVEROUTPUT ON SIZE 100000

------------Table Creation----------------------

CREATE TABLE CUST_PURCHS_FORECAST_STG
(
	 ITEM_COL						VARCHAR2(100),
    OEM_COL						VARCHAR2(100),
    OHB_DATE				VARCHAR2(100),
    BACKORDER_DATE		VARCHAR2(100),        
    OPEN_PO_DATE			VARCHAR2(100),        
    PAST_DUE_PO			VARCHAR2(100),        
    PUR_FCST_DATE1		VARCHAR2(100),        
    PUR_FCST_DATE2		VARCHAR2(100),
	 PUR_FCST_DATE3		VARCHAR2(100),
    PUR_FCST_DATE4		VARCHAR2(100),
	 PUR_FCST_DATE5		VARCHAR2(100),
	 PUR_FCST_DATE6		VARCHAR2(100),
	 PUR_FCST_DATE7		VARCHAR2(100),
	 PUR_FCST_DATE8		VARCHAR2(100),
	 PUR_FCST_DATE9		VARCHAR2(100),
	 PUR_FCST_DATE10		VARCHAR2(100),
	 PUR_FCST_DATE11		VARCHAR2(100),
	 PUR_FCST_DATE12		VARCHAR2(100),
	 PUR_HIST_DATE1		VARCHAR2(100),
	 PUR_HIST_DATE2		VARCHAR2(100),
	 PUR_HIST_DATE3		VARCHAR2(100),
	 PH_AVG					VARCHAR2(100),
	 PLANNER_COMMENTS		VARCHAR2(100),
	 ERR					VARCHAR2(1500),
	 REQUEST_ID				NUMBER
);
EXIT;
/