/*<TOAD_FILE_CHUNK>*/
   /***************************************************************************
   *                   ATT Demantra Loader Program
   ***************************************************************************
   *
   * SCRIPT NAME ->            CUST_LOAD_FORECAST_DEMANTRA.sql
   *
   * DESCRIPTION->            To load Forecast Data into Demantra Staging tables
   *
   *
   * LAST UPDATE DATE:
   *
   * HISTORY:
   *
   * VERSION   DATE        AUTHOR            DESCRIPTION
   * --------- ----------- ---------------- -----------------------------------
   * 1.0      30-APR-2015  kc7381            initial development
   */
CREATE OR REPLACE PACKAGE APPS.CUST_LOAD_FORECAST_DEMANTRA
AS 
    gv_invalid_date_flag varchar2(10) DEFAULT 'N';
    procedure LOAD_FORECAST_DEMANTRA     (  p_ret_code      out         varchar2,
                                            p_errbuff       out         varchar2,
                                            p_file_name                 varchar2,
                                            p_forecast_type             varchar2
                                            );

    procedure prchs_frcst_validation     (  p_request_id_purchs_frcst   NUMBER,
                                            p_ret_code              OUT VARCHAR2,
                                            p_ret_msg               OUT varchar2
                                            );

    procedure cust_dmd_validation        (  p_request_id_cust_frcst     NUMBER,
                                            p_ret_code              OUT VARCHAR2,
                                            p_ret_msg               OUT varchar2
                                            );

    procedure insert_into_BIIO           (  p_request_id_cust_frcst     NUMBER,
                                            p_request_id_purchs_frcst   NUMBER,
                                            p_file_type                 varchar2,
                                            p_ret_code              OUT VARCHAR2,
                                            p_ret_msg               OUT varchar2
                                            );
                                            
                                                
    procedure handle_purchs_dmd_exception(  p_request_id_purchs_frcst   NUMBER,
                                            p_err_msg_name          IN  VARCHAR2,
                                            p_token_list            IN  VARCHAR2,
                                            p_value_list            IN  VARCHAR2,
                                            p_column                IN  VARCHAR2,
                                            p_col_value             IN  VARCHAR2,
                                            p_error_message         OUT VARCHAR2
                                            );
    
    procedure handle_custmr_dmd_exception(  p_request_id_cust_frcst     NUMBER,
                                            p_err_msg_name      IN      VARCHAR2,
                                            p_token_list        IN      VARCHAR2,
                                            p_value_list        IN      VARCHAR2,
                                            p_column            IN      VARCHAR2,
                                            p_col_value         IN      VARCHAR2,
                                            p_error_message     OUT     VARCHAR2
                                            );
                                            
   procedure send_err_notification (        p_ret_code  OUT VARCHAR2,
                                            p_ret_msg   OUT varchar2,
                                            p_forecast_type IN VARCHAR2,
                                            p_dest_dir  IN  VARCHAR2,
                                            p_file_name IN  VARCHAR2,
                                            p_err_file  IN  VARCHAR2,
                                            p_mail_id   IN  VARCHAR2,
                                            p_flag      IN  VARCHAR2
                                            );
                                            
    procedure send_upload_notifctn (        p_ret_code  OUT VARCHAR2,
                                            p_ret_msg   OUT varchar2,
                                            p_forecast_type IN VARCHAR2,
                                            p_dest_dir  IN  VARCHAR2,
                                            p_file_name IN  VARCHAR2,
                                            p_mail_id   IN  VARCHAR2,
                                            p_user      IN  VARCHAR2
                                        );
end CUST_LOAD_FORECAST_DEMANTRA;

/

/*******************************PACKAGE BODY************************************/

CREATE OR REPLACE PACKAGE BODY APPS.CUST_LOAD_FORECAST_DEMANTRA
AS
    
--------------------------/* START */---------------/*PRCHS_FRCST_VALIDATION*/---------------/* START */-----------------------------------------
/*This Procedure performs the validation for Purchase Forecast file type*/

    procedure prchs_frcst_validation ( p_request_id_purchs_frcst   NUMBER,
                                       p_ret_code OUT   VARCHAR2,
                                       p_ret_msg  OUT  varchar2)
    is
             l_err varchar2(500);
             l_err_flag VARCHAR2(3) DEFAULT 'N';
             l_count NUMBER;
             l_current_month NUMBER;
             l_dot_posn  VARCHAR2(10);
             l_ohb_date  DATE;
             l_backorder_date DATE;
             l_open_po_date   DATE;
             l_past_due_po    DATE;
             l_pur_fcst_date1  DATE;
             l_pur_fcst_date2  DATE;
             l_pur_fcst_date3  DATE;
             l_pur_fcst_date4  DATE;
             l_pur_fcst_date5  DATE;
             l_pur_fcst_date6  DATE;
             l_pur_fcst_date7  DATE;
             l_pur_fcst_date8  DATE;
             l_pur_fcst_date9  DATE;
             l_pur_fcst_date10  DATE;
             l_pur_fcst_date11  DATE;
             l_pur_fcst_date12  DATE;
             l_purchs_hist1     DATE;
             l_purchs_hist2     DATE;
             l_purchs_hist3     DATE;
             l_ph_avg             DATE;
             l_valid_date       DATE;
             l_qry  VARCHAR2(500);
             l_date   date;
             l_err_msg varchar2(500);
             l_null_item_cnt    NUMBER;
             l_null_oem_cnt    NUMBER;
             invalid_date_format1 EXCEPTION;
             invalid_date_format2 EXCEPTION;

             CURSOR prchs_frcst_hdr 
             IS
                  SELECT * FROM CUST_PURCHS_FORECAST_STG
                  WHERE REQUEST_ID = p_request_id_purchs_frcst
                          AND    upper(ITEM_COL) = 'ITEM'    ;

             CURSOR prchs_frcst_data 
             IS
                  SELECT * FROM CUST_PURCHS_FORECAST_STG
                  WHERE REQUEST_ID = p_request_id_purchs_frcst
                          AND    (upper(ITEM_COL) != 'ITEM' or ITEM_COL IS NULL ) AND (OHB_DATE != 'OHB' or OHB_DATE is null);

             PRAGMA EXCEPTION_INIT(invalid_date_format1,-1843);
             PRAGMA EXCEPTION_INIT(invalid_date_format2,-1858);
    BEGIN
    
        
              BEGIN
                     select  EXTRACT(month FROM sysdate)
                     into l_current_month
                     from dual; 
              EXCEPTION
              WHEN OTHERS THEN
                     fnd_file.put_line(fnd_file.log,'Error in getting current month'||SQLERRM);
              END;
            
              --------------------------------------/*** START ***/ DATE Validation /*** START ***/-----------------------------------------------
              FOR i IN prchs_frcst_hdr
              LOOP
                    /*CHECK IF ANY DATE FIELD IS NULL*/
                    IF i.OHB_DATE IS NULL OR i.BACKORDER_DATE IS NULL OR i.OPEN_PO_DATE IS NULL OR i.PAST_DUE_PO IS NULL 
                          OR i.PUR_FCST_DATE1 IS NULL OR i.PUR_FCST_DATE2 IS NULL OR i.PUR_FCST_DATE3 IS NULL OR i.PUR_FCST_DATE4 IS NULL 
                          OR i.PUR_FCST_DATE5 IS NULL OR i.PUR_FCST_DATE6 IS NULL OR i.PUR_FCST_DATE7 IS NULL OR i.PUR_FCST_DATE8 IS NULL 
                          OR i.PUR_FCST_DATE9 IS NULL OR i.PUR_FCST_DATE10 IS NULL OR i.PUR_FCST_DATE11 IS NULL OR i.PUR_FCST_DATE12 IS NULL
                          OR i.PUR_HIST_DATE1 IS NULL OR i.PUR_HIST_DATE2 IS NULL OR i.PUR_HIST_DATE3 IS NULL OR i.PH_AVG IS NULL OR i.PLANNER_COMMENTS IS NULL
                    THEN
                          handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                             'ERROR_DATE_DATA_0',
                                                             '',
                                                             '',
                                                             'ITEM_COL',
                                                             i.ITEM_COL,
                                                             l_err_msg);
                          fnd_file.put_line(fnd_file.log,l_err_msg);
                    END IF;

                    /***************  CHECK OHB_DATE RANGE   ***************/
                    BEGIN
                        l_ohb_date := TO_DATE(i.OHB_DATE,'mm/dd/yyyy');

                    EXCEPTION
                        WHEN invalid_date_format1 or invalid_date_format2 THEN
                          gv_invalid_date_flag := 'Y';
                          fnd_file.put_line(fnd_file.log,'gv_invalid_date_flag: '||gv_invalid_date_flag);
                          handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                             'ERROR_DATE_FORMAT_1',
                                                             'DATE',
                                                             'OHB DATE',
                                                             'ITEM_COL',
                                                             i.ITEM_COL,
                                                             l_err_msg);
                          fnd_file.put_line(fnd_file.log,l_err_msg);
                    END;
                    
                    IF (EXTRACT(month FROM l_ohb_date)) != l_current_month 
                    then
                          handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                             'ERROR_OHB_DATE_RANGE_0',
                                                             '',
                                                             '', 
                                                             'ITEM_COL',
                                                             i.ITEM_COL,
                                                             l_err_msg);
                          fnd_file.put_line(fnd_file.log,l_err_msg);
                                  
                    END IF;

                    /***************  CHECK BACKORDER_DATE RANGE   ***************/
                    BEGIN
                    l_backorder_date := TO_DATE(i.BACKORDER_DATE,'mm/dd/yyyy');
                    EXCEPTION
                    WHEN invalid_date_format1 or invalid_date_format2 THEN
                          gv_invalid_date_flag := 'Y';
                          handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                             'ERROR_DATE_FORMAT_1',
                                                             'DATE',
                                                             'BACKORDER DATE',
                                                             'ITEM_COL',
                                                             i.ITEM_COL,
                                                             l_err_msg);
                          fnd_file.put_line(fnd_file.log,l_err_msg);
                    END;

                    IF (EXTRACT(month FROM l_backorder_date)) != l_current_month
                    THEN
                          handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                             'ERROR_BCKORD_DATE_RANGE_0',
                                                             '',
                                                             '',
                                                             'ITEM_COL',
                                                             i.ITEM_COL,
                                                             l_err_msg);
                          fnd_file.put_line(fnd_file.log,l_err_msg);

                    END IF;
                    
                    /***************  CHECK OPEN_PO_DATE RANGE   ***************/
                    BEGIN
                        l_open_po_date := TO_DATE(i.OPEN_PO_DATE,'mm/dd/yyyy');
                    EXCEPTION
                        WHEN invalid_date_format1 or invalid_date_format2 THEN
                        gv_invalid_date_flag := 'Y';
                        handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                         'ERROR_DATE_FORMAT_1',
                                                         'DATE',
                                                         'OPEN PO DATE',
                                                         'ITEM_COL',
                                                         i.ITEM_COL,
                                                         l_err_msg);
                        fnd_file.put_line(fnd_file.log,l_err_msg);
                    END;

                    IF (EXTRACT(month FROM l_open_po_date)) != l_current_month
                    THEN
                        handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                             'ERROR_OPENPO_DATE_RANGE_0',
                                                             '',
                                                             '',
                                                             'ITEM_COL',
                                                             i.ITEM_COL,
                                                             l_err_msg);
                        fnd_file.put_line(fnd_file.log,l_err_msg);
                                                      
                    END IF;
                    
                    /***************  CHECK PAST_DUE_PO RANGE   ***************/
                    BEGIN
                        l_past_due_po := TO_DATE(i.PAST_DUE_PO,'mm/dd/yyyy');
                    EXCEPTION
                        WHEN invalid_date_format1 or invalid_date_format2 THEN
                          gv_invalid_date_flag := 'Y';
                          handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                             'ERROR_DATE_FORMAT_1',
                                                             'DATE',
                                                             'PAST DUE PO DATE',
                                                             'ITEM_COL',
                                                             i.ITEM_COL,
                                                             l_err_msg);
                          fnd_file.put_line(fnd_file.log,l_err_msg);
                    END;

                    IF (EXTRACT(month FROM l_past_due_po)) != l_current_month
                    THEN
                          handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                             'ERROR_PASTDUE_DATE_RANGE_0',
                                                             '',
                                                             '',
                                                             'ITEM_COL',
                                                             i.ITEM_COL,
                                                             l_err_msg);
                          fnd_file.put_line(fnd_file.log,l_err_msg);
                    END IF;

                    /***************  CHECK PH_AVG RANGE   ***************/
                    BEGIN
                        l_ph_avg := TO_DATE(i.PH_AVG,'mm/dd/yyyy');
                    EXCEPTION
                        WHEN invalid_date_format1 or invalid_date_format2 THEN
                          gv_invalid_date_flag := 'Y';
                          handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                             'ERROR_DATE_FORMAT_1',
                                                             'DATE',
                                                             'PH AVG DATE',
                                                             'ITEM_COL',
                                                             i.ITEM_COL,
                                                             l_err_msg);
                          fnd_file.put_line(fnd_file.log,l_err_msg);
                    END;

                    IF (EXTRACT(month FROM l_ph_avg)) != l_current_month
                    THEN
                         handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                             'ERROR_HIST_AVG_DATE_RANGE_0',
                                                             '',
                                                             '',
                                                             'ITEM_COL',
                                                             i.ITEM_COL,
                                                             l_err_msg);
                          fnd_file.put_line(fnd_file.log,l_err_msg);
                    END IF;
                    
                    /***************  CHECK PLANNER_COMMENTS RANGE   ***************/
                    BEGIN
                        l_ph_avg := TO_DATE(i.PLANNER_COMMENTS,'mm/dd/yyyy');
                    EXCEPTION
                        WHEN invalid_date_format1 or invalid_date_format2 THEN
                          gv_invalid_date_flag := 'Y';
                          handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                             'ERROR_DATE_FORMAT_1',
                                                             'DATE',
                                                             'PLANNER COMMENTS DATE',
                                                             'ITEM_COL',
                                                             i.ITEM_COL,
                                                             l_err_msg);
                          fnd_file.put_line(fnd_file.log,l_err_msg);
                    END;

                    IF (EXTRACT(month FROM l_ph_avg)) != l_current_month
                    THEN
                         handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                             'ERROR_COMMENTS_DATE_RANGE_0',
                                                             '',
                                                             '',
                                                             'ITEM_COL',
                                                             i.ITEM_COL,
                                                             l_err_msg);
                          fnd_file.put_line(fnd_file.log,l_err_msg);
                    END IF;

                    /***************  CHECK PURCHASE FORECAST RANGE   ***************/
                    BEGIN
                          l_pur_fcst_date1 := TO_DATE(i.PUR_FCST_DATE1,'mm/dd/yyyy');
                          l_pur_fcst_date2 := TO_DATE(i.PUR_FCST_DATE2,'mm/dd/yyyy');
                          l_pur_fcst_date3 := TO_DATE(i.PUR_FCST_DATE3,'mm/dd/yyyy');
                          l_pur_fcst_date4 := TO_DATE(i.PUR_FCST_DATE4,'mm/dd/yyyy');
                          l_pur_fcst_date5 := TO_DATE(i.PUR_FCST_DATE5,'mm/dd/yyyy');
                          l_pur_fcst_date6 := TO_DATE(i.PUR_FCST_DATE6,'mm/dd/yyyy');
                          l_pur_fcst_date7 := TO_DATE(i.PUR_FCST_DATE7,'mm/dd/yyyy');
                          l_pur_fcst_date8 := TO_DATE(i.PUR_FCST_DATE8,'mm/dd/yyyy');
                          l_pur_fcst_date9 := TO_DATE(i.PUR_FCST_DATE9,'mm/dd/yyyy');
                          l_pur_fcst_date10 := TO_DATE(i.PUR_FCST_DATE10,'mm/dd/yyyy');
                          l_pur_fcst_date11 := TO_DATE(i.PUR_FCST_DATE11,'mm/dd/yyyy');
                          l_pur_fcst_date12 := TO_DATE(i.PUR_FCST_DATE12,'mm/dd/yyyy');
                    EXCEPTION
                        WHEN invalid_date_format1 or invalid_date_format2 THEN
                          gv_invalid_date_flag := 'Y';
                          handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                             'ERROR_DATE_FORMAT_1',
                                                             'DATE',
                                                             'FORECAST DATE',
                                                             'ITEM_COL',
                                                             i.ITEM_COL,
                                                             l_err_msg);
                          fnd_file.put_line(fnd_file.log,l_err_msg);
                    END;

                    IF l_current_month < 12 
                    THEN
                          IF (EXTRACT(month FROM l_pur_fcst_date1)) != (l_current_month+1)
                          THEN    
                                         l_err_flag := 'Y';   
                          END IF;
                    ELSIF l_current_month = 12
                    THEN
                          IF (EXTRACT(month FROM l_pur_fcst_date1)) != 1
                          THEN    
                                         l_err_flag := 'Y';   
                          END IF;
                    END IF;

                    IF (EXTRACT(month FROM l_pur_fcst_date12)) != l_current_month
                    THEN
                                      l_err_flag := 'Y';
                    END IF;
                        
                    IF l_err_flag = 'Y'
                    THEN
                           handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                                     'ERROR_FCST_DATE_RANGE_0',
                                                                     '',
                                                                     '',
                                                                     'ITEM_COL',
                                                                     i.ITEM_COL,
                                                                     l_err_msg);
                           fnd_file.put_line(fnd_file.log,l_err_msg);
                    END IF;
                    l_err_flag := 'N';

                    /***************  CHECK PURCHASE HISTORY RANGE   ***************/
                    BEGIN
                          l_purchs_hist1 := TO_DATE(i.PUR_HIST_DATE1,'mm/dd/yyyy');
                          l_purchs_hist2 := TO_DATE(i.PUR_HIST_DATE2,'mm/dd/yyyy');
                          l_purchs_hist3 := TO_DATE(i.PUR_HIST_DATE3,'mm/dd/yyyy');
                    EXCEPTION
                        WHEN invalid_date_format1 or invalid_date_format2 THEN
                          gv_invalid_date_flag := 'Y';
                          handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                             'ERROR_DATE_FORMAT_1',
                                                             'DATE',
                                                             'PURCHASE HISTORY',
                                                             'ITEM_COL',
                                                             i.ITEM_COL,
                                                             l_err_msg);
                          fnd_file.put_line(fnd_file.log,l_err_msg);
                    END;

                    IF l_current_month = 1
                    THEN
                          IF (EXTRACT(month FROM l_purchs_hist1)) != 10 OR (EXTRACT(month FROM l_purchs_hist2)) != 11 OR (EXTRACT(month FROM l_purchs_hist3)) != 12
                          THEN
                                  l_err_flag := 'Y';
                          END IF;
                    ELSIF l_current_month = 2
                    THEN
                          IF (EXTRACT(month FROM l_purchs_hist1)) != 11 OR (EXTRACT(month FROM l_purchs_hist2)) != 12 OR (EXTRACT(month FROM l_purchs_hist3)) != 1
                          THEN
                                  l_err_flag := 'Y';
                          END IF;
                    ELSIF l_current_month = 3
                    THEN
                          IF (EXTRACT(month FROM l_purchs_hist1)) != 12 OR (EXTRACT(month FROM l_purchs_hist2)) != 1 OR (EXTRACT(month FROM l_purchs_hist3)) != 2
                          THEN
                                  l_err_flag := 'Y';
                          END IF;
                    ELSE
                          IF (EXTRACT(month FROM l_purchs_hist1)) != (l_current_month-3)  OR (EXTRACT(month FROM l_purchs_hist2)) != (l_current_month-2) OR (EXTRACT(month FROM l_purchs_hist3)) != (l_current_month-1)
                          THEN
                                  l_err_flag := 'Y';
                          END IF;
                    END IF;
                    
                    IF l_err_flag = 'Y'
                    THEN
                          handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                                     'ERROR_HIST_DATE_RANGE_0',
                                                                     '',
                                                                     '',
                                                                     'ITEM_COL',
                                                                     i.ITEM_COL,
                                                                     l_err_msg);
                          fnd_file.put_line(fnd_file.log,l_err_msg);
                                  
                    END IF;
                    l_err_flag := 'N';
                END LOOP;

        --------------------------------------/*** END ***/ DATE Validation /*** END ***/-----------------------------------------------


            FOR i IN prchs_frcst_data
            LOOP
                    /*CHECK FOR NULL ITEMS*/
                begin
                    SELECT COUNT(1)
                    INTO l_null_item_cnt
                    FROM CUST_PURCHS_FORECAST_STG
                    WHERE i.ITEM_COL is null
                      and REQUEST_ID = p_request_id_purchs_frcst;
                exception
                when others then
                fnd_file.put_line(fnd_file.log,'SQLERRM: ' ||SQLERRM);
                END;
                                          
                IF l_null_item_cnt > 0
                THEN
                handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                 'ERROR_ITEM_DATA_0',
                                                 '',
                                                 '',
                                                 'ITEM_COL',
                                                 i.ITEM_COL,
                                                 l_err_msg);
                fnd_file.put_line(fnd_file.log,l_err_msg);
                END IF;   
                                    
                /*CHECK FOR NULL OEMS*/  
                BEGIN  
                    SELECT COUNT(1)
                    INTO l_null_oem_cnt
                    FROM CUST_PURCHS_FORECAST_STG
                    WHERE i.OEM_COL is null
                      and REQUEST_ID = p_request_id_purchs_frcst;
                exception
                when others then
                fnd_file.put_line(fnd_file.log,'SQLERRM: ' ||SQLERRM);
                END;

                IF l_null_oem_cnt > 0
                THEN
                     handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                         'ERROR_OEM_DATA_0',
                                                         '',
                                                         '',
                                                         'OEM_COL',
                                                         i.OEM_COL,
                                                         l_err_msg);
                      fnd_file.put_line(fnd_file.log,l_err_msg);
                END IF;

                /*CHECK IF ITEM IS IN AAA.XXXXXX FORMAT*/
                  BEGIN
                      SELECT SUBSTR(i.ITEM_COL,4,1)
                      INTO l_dot_posn
                      FROM DUAL;
                  EXCEPTION
                      WHEN OTHERS THEN
                        fnd_file.put_line(fnd_file.log,'Failed to check Item format for Error: '||SQLERRM);
                  END;
                          
                  IF l_dot_posn!= '.'
                  THEN
                      handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                         'ERROR_ITEM_FORMAT_1',
                                                         'ITEM',
                                                         i.ITEM_COL,
                                                         'ITEM_COL',
                                                         i.ITEM_COL,
                                                         l_err_msg);
                      fnd_file.put_line(fnd_file.log,l_err_msg);
                              
                  END IF;
                                  
                  /*CHECK IF ITEM IS PRIME ITEM*/
                  IF i.ITEM_COL IS NOT NULL
                  THEN
                      BEGIN
                          select count(1) 
                          into l_count 
                          from CUST_PURCHS_FORECAST_STG
                          where i.ITEM_COL in (    SELECT DISTINCT ITEM_NAME 
                                                                                FROM MSC.MSC_SYSTEM_ITEMS MI, MSC.MSC_BOM_COMPONENTS MB
                                                                                WHERE MI.INVENTORY_ITEM_ID = MB.INVENTORY_ITEM_ID
                                                                                AND MB.PLANNING_FACTOR = 100 );
                      EXCEPTION
                          WHEN OTHERS THEN
                          fnd_file.put_line(fnd_file.log,'Filed to check if ITEM is Prime Item because of Error: '||SQLERRM);
                      END;
                          
                      IF l_count = 0
                      THEN
                              handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                                 'ERROR_PRIME_ITM_0',
                                                                 '',
                                                                 '',
                                                                 'ITEM_COL',
                                                                 i.ITEM_COL,
                                                                 l_err_msg);
                              fnd_file.put_line(fnd_file.log,l_err_msg);
                                  
                      END IF;
                   END IF;
                          
                  /*CHECK IF HISTORY DATA IS OF NUMBER DATA TYPE*/
                  IF       LENGTH(TRIM(TRANSLATE(i.PUR_HIST_DATE1, ' +-.0123456789',' '))) is not null 
                          or LENGTH(TRIM(TRANSLATE(i.PUR_HIST_DATE2, ' +-.0123456789',' '))) is not null 
                          or LENGTH(TRIM(TRANSLATE(i.PUR_HIST_DATE3, ' +-.0123456789',' '))) is not null 
                        THEN
                          handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                             'ERROR_HIST_DATA_0',
                                                             '',
                                                             '',
                                                             'ITEM_COL',
                                                             i.ITEM_COL,
                                                             l_err_msg);
                          fnd_file.put_line(fnd_file.log,l_err_msg);
                              
                  END IF;

                  /*CHECK IF FORECAST DATA IS OF NUMBER DATA TYPE*/
                  IF       LENGTH(TRIM(TRANSLATE(i.PUR_FCST_DATE1, ' +-.0123456789',' '))) is not null 
                          or LENGTH(TRIM(TRANSLATE(i.PUR_FCST_DATE2, ' +-.0123456789',' '))) is not null 
                          or LENGTH(TRIM(TRANSLATE(i.PUR_FCST_DATE3, ' +-.0123456789',' '))) is not null 
                          or LENGTH(TRIM(TRANSLATE(i.PUR_FCST_DATE4, ' +-.0123456789',' '))) is not null 
                          or LENGTH(TRIM(TRANSLATE(i.PUR_FCST_DATE5, ' +-.0123456789',' '))) is not null 
                          or LENGTH(TRIM(TRANSLATE(i.PUR_FCST_DATE6, ' +-.0123456789',' '))) is not null 
                          or LENGTH(TRIM(TRANSLATE(i.PUR_FCST_DATE7, ' +-.0123456789',' '))) is not null 
                          or LENGTH(TRIM(TRANSLATE(i.PUR_FCST_DATE8, ' +-.0123456789',' '))) is not null 
                          or LENGTH(TRIM(TRANSLATE(i.PUR_FCST_DATE9, ' +-.0123456789',' '))) is not null 
                          or LENGTH(TRIM(TRANSLATE(i.PUR_FCST_DATE10, ' +-.0123456789',' '))) is not null 
                          or LENGTH(TRIM(TRANSLATE(i.PUR_FCST_DATE11, ' +-.0123456789',' '))) is not null 
                          or LENGTH(TRIM(TRANSLATE(i.PUR_FCST_DATE12, ' +-.0123456789',' '))) is not null 
                  THEN
                          handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                             'ERROR_FCST_DATA_0',
                                                             '',
                                                             '',
                                                             'ITEM_COL',
                                                             i.ITEM_COL,
                                                             l_err_msg);
                          fnd_file.put_line(fnd_file.log,l_err_msg);
                             
                  END IF;

                  /*CHECK IF HISTORY AVERAGE DATA IS OF NUMBER DATA TYPE*/
                  IF LENGTH(TRIM(TRANSLATE(i.PH_AVG, ' +-.0123456789',' '))) is not null
                  THEN
                          handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                             'ERROR_HIST_AVG_DATA_0',
                                                             '',
                                                             '',
                                                             'ITEM_COL',
                                                             i.ITEM_COL,
                                                             l_err_msg);
                          fnd_file.put_line(fnd_file.log,l_err_msg);
                                  
                  END IF;

                  /*CHECK IF ON HAND BALANCE DATA IS OF NUMBER DATA TYPE*/
                  IF LENGTH(TRIM(TRANSLATE(i.OHB_DATE, ' +-.0123456789',' '))) is not null
                  THEN
                          handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                             'ERROR_OHB_DATA_0',
                                                             '',
                                                             '',
                                                             'ITEM_COL',
                                                             i.ITEM_COL,
                                                             l_err_msg);
                          fnd_file.put_line(fnd_file.log,l_err_msg);
                              
                  END IF;

                  /*CHECK IF BACK ORDER DATA IS OF NUMBER DATA TYPE*/
                  IF LENGTH(TRIM(TRANSLATE(i.BACKORDER_DATE, ' +-.0123456789',' '))) is not null
                  THEN
                          handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                             'ERROR_BCKORD_DATA_0',
                                                             '',
                                                             '',
                                                             'ITEM_COL',
                                                             i.ITEM_COL,
                                                             l_err_msg);
                          fnd_file.put_line(fnd_file.log,l_err_msg);
                              
                  END IF;

                  /*CHECK IF OPEN PO DATA IS OF NUMBER DATA TYPE*/
                  IF LENGTH(TRIM(TRANSLATE(i.OPEN_PO_DATE, ' +-.0123456789',' '))) is not null
                  THEN
                          handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                             'ERROR_OPENPO_DATA_0',
                                                             '',
                                                             '',
                                                             'ITEM_COL',
                                                             i.ITEM_COL,
                                                             l_err_msg);
                          fnd_file.put_line(fnd_file.log,l_err_msg);
                              
                  END IF;

                  /*CHECK IF PAST_DUE_PO DATA IS OF NUMBER DATA TYPE*/
                  IF LENGTH(TRIM(TRANSLATE(i.PAST_DUE_PO, ' +-.0123456789',' '))) is not null
                  THEN
                          handle_purchs_dmd_exception(p_request_id_purchs_frcst,
                                                             'ERROR_PASTDUE_DATA_0',
                                                             '',
                                                             '',
                                                             'ITEM_COL',
                                                             i.ITEM_COL,
                                                             l_err_msg);
                          fnd_file.put_line(fnd_file.log,l_err_msg);
                              
                  END IF;
            END LOOP;
            
            
    EXCEPTION
            WHEN OTHERS 
            THEN
                fnd_file.put_line(fnd_file.log,'Error is : '||SQLCODE||' - '||SQLERRM);

    END prchs_frcst_validation;

--------------------------/* END */---------------/*PRCHS_FRCST_VALIDATION*/---------------/* END */-----------------------------------------



-----------------------------------------/*CUST_DMD_VALIDATION*/--------------------------------------------------------------------
/*This procedure performs validation for Customer Forecast file type*/
procedure cust_dmd_validation (  p_request_id_cust_frcst NUMBER,
                                 p_ret_code  OUT  VARCHAR2,
                                 p_ret_msg   OUT varchar2)
is    
    l_current_month number;
    l_err_flag varchar2(10) default 'N';
    l_count number:=0;
    l_dot_posn VARCHAR2(10);
    l_reg_len NUMBER;
    l_err varchar2(500);
    l_date1     DATE;
    l_date2     DATE;
    l_date3     DATE;
    l_date4     DATE;
    l_date5     DATE;
    l_date6     DATE;
    l_date7     DATE;
    l_date8     DATE;
    l_date9     DATE;
    l_date10    DATE;
    l_date11    DATE;
    l_date12    DATE;
    l_note_date DATE;
    l_null_item_cnt NUMBER;
    l_err_msg     VARCHAR2(500);
    invalid_date_format1 exception;
    invalid_date_format2 exception;
    
    CURSOR cust_dmd_hdr
    IS
        select * from CUST_CUSTMR_FORECAST_STG
          WHERE REQUEST_ID = p_request_id_cust_frcst
                        and upper(ITEM_COL) = 'ITEM';
    
    CURSOR cust_dmd_data
    IS
        select * from CUST_CUSTMR_FORECAST_STG
          WHERE REQUEST_ID = p_request_id_cust_frcst
                        and (upper(ITEM_COL) != 'ITEM' or ITEM_COL IS NULL ) and date1 != 'DMD FCST' ;
                        
     PRAGMA EXCEPTION_INIT(invalid_date_format1,-1843);
     PRAGMA EXCEPTION_INIT(invalid_date_format2,-1858);
begin
    --------------------------------------***START*** DATE VALIDATION ***START***-----------------------------------------------
        
    /*SELECT THE CURRENT MONTH*/
    BEGIN
      select  EXTRACT(month FROM sysdate)
      into l_current_month
      from dual; 
    EXCEPTION
    WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Error in getting current month');
    END;

    FOR i IN cust_dmd_hdr
    LOOP
        /*CHECK IF DATE NULL*/    
        IF  i.DATE1 IS NULL OR i.DATE2 IS NULL OR i.DATE3 IS NULL OR i.DATE4 IS NULL OR i.DATE5 IS NULL OR i.DATE6 IS NULL OR i.DATE7 IS NULL OR i.DATE8 IS NULL OR i.DATE9 IS NULL OR i.DATE10 IS NULL OR i.DATE11 IS NULL OR i.DATE12 IS NULL
        THEN
              handle_custmr_dmd_exception(p_request_id_cust_frcst,
                                                             'ERROR_DATE_DATA_0',
                                                             '',
                                                             '',
                                                             'ITEM_COL',
                                                             i.ITEM_COL,
                                                             l_err_msg);
              fnd_file.put_line(fnd_file.log,l_err_msg);
                             
         END IF;
                        
        /*CHECK FORECAST DATE FORMAT*/
        BEGIN
             l_date1 := TO_DATE(i.DATE1,'mm/dd/yyyy');
             l_date2 := TO_DATE(i.DATE2,'mm/dd/yyyy');
             l_date3 := TO_DATE(i.DATE3,'mm/dd/yyyy');
             l_date4 := TO_DATE(i.DATE4,'mm/dd/yyyy');
             l_date5 := TO_DATE(i.DATE5,'mm/dd/yyyy');
             l_date6 := TO_DATE(i.DATE6,'mm/dd/yyyy');
             l_date7 := TO_DATE(i.DATE7,'mm/dd/yyyy');
             l_date8 := TO_DATE(i.DATE8,'mm/dd/yyyy');
             l_date9 := TO_DATE(i.DATE9,'mm/dd/yyyy');
             l_date10 := TO_DATE(i.DATE10,'mm/dd/yyyy');
             l_date11 := TO_DATE(i.DATE11,'mm/dd/yyyy');
             l_date12 := TO_DATE(i.DATE12,'mm/dd/yyyy');
        EXCEPTION
            WHEN invalid_date_format1 or invalid_date_format2 THEN
                  gv_invalid_date_flag := 'Y';
                  handle_custmr_dmd_exception(p_request_id_cust_frcst,
                                                 'ERROR_DATE_FORMAT_1',
                                                 'DATE',
                                                 'FORECAST DATE',
                                                 'ITEM_COL',
                                                 i.ITEM_COL,
                                                 l_err_msg);
                  fnd_file.put_line(fnd_file.log,l_err_msg);
                  
         commit;
        END;

        /*CHECK THE DATE RANGE*/
        IF l_current_month < 12
        THEN
            IF (EXTRACT(month FROM l_date1)) != (l_current_month+1)
            THEN
            l_err_flag := 'Y';   
            END IF;
        ELSIF l_current_month = 12
        THEN
            IF (EXTRACT(month FROM l_date1)) != 1
            THEN
            l_err_flag := 'Y';   
            END IF;
        END IF;

        IF (EXTRACT(month FROM l_date12)) != l_current_month
        THEN
        l_err_flag := 'Y';
        END IF;

        IF l_err_flag = 'Y' 
        THEN
            handle_custmr_dmd_exception(p_request_id_cust_frcst,
                                                 'ERROR_FCST_DATE_RANGE_0',
                                                 '',
                                                 '',
                                                 'ITEM_COL',
                                                 i.ITEM_COL,
                                                 l_err_msg);
            fnd_file.put_line(fnd_file.log,l_err_msg);
         
        END IF;
        l_err_flag := 'N';
        
        /*CHECK THE NOTE DATE*/
        BEGIN
            l_note_date := TO_DATE(i.NOTE,'mm/dd/yyyy');
        EXCEPTION
            WHEN invalid_date_format1 or invalid_date_format2 THEN
              gv_invalid_date_flag := 'Y';
              handle_custmr_dmd_exception(p_request_id_cust_frcst,
                                             'ERROR_DATE_FORMAT_1',
                                             'DATE',
                                             'FORECAST DATE',
                                             'ITEM_COL',
                                             i.ITEM_COL,
                                             l_err_msg);
              fnd_file.put_line(fnd_file.log,l_err_msg);
                  
         commit;
        END;
        
        IF (EXTRACT(month FROM l_note_date)) != (l_current_month)
        THEN    
            handle_custmr_dmd_exception(p_request_id_cust_frcst,
                                                 'ERROR_NOTES_DATE_RANGE_0',
                                                 '',
                                                 '',
                                                 'ITEM_COL',
                                                 i.ITEM_COL,
                                                 l_err_msg);
            fnd_file.put_line(fnd_file.log,l_err_msg);
        
        END IF;
        END LOOP;
        
        --------------------------------------***START*** DATE VALIDATION ***START***-----------------------------------------------

      

   FOR i IN cust_dmd_data
   LOOP
            /*CHECK IF ITEM IS NULL*/
            --fnd_file.put_line(fnd_file.log,'CHECK IF ITEM IS NULL');
            BEGIN
            SELECT COUNT(1)
                         INTO l_null_item_cnt
                         FROM CUST_CUSTMR_FORECAST_STG
                         WHERE i.ITEM_COL is null 
                              and REQUEST_ID = p_request_id_cust_frcst;
            EXCEPTION
                 WHEN OTHERS THEN
                      FND_FILE.PUT_LINE(FND_FILE.LOG,'Failed to check for null ITEMS in CUST_CUSTMR_FORECAST_STG for Error: '||SQLERRM);
            END;
            
            if l_null_item_cnt > 0 
            then
                    handle_custmr_dmd_exception(p_request_id_cust_frcst,
                                                                             'ERROR_ITEM_DATA_0',
                                                                             '',
                                                                             '',
                                                                             'ITEM_COL',
                                                                             i.ITEM_COL,
                                                                             l_err_msg);
                    fnd_file.put_line(fnd_file.log,l_err_msg);
            end if;

        /*CHECK IF ITEM IS IN AAA.XXXXXX FORMAT*/
        --fnd_file.put_line(fnd_file.log,'CHECK IF ITEM IS IN AAA.XXXXXX FORMAT');
        BEGIN
            SELECT SUBSTR(i.ITEM_COL,4,1)
            INTO l_dot_posn
            FROM DUAL; 
        EXCEPTION
            WHEN OTHERS THEN
               fnd_file.put_line(fnd_file.log,'Failed to check the format of Item for Error: '||SQLERRM);
        END;        
                        
        IF l_dot_posn!= '.'
        THEN
        handle_custmr_dmd_exception(p_request_id_cust_frcst,
                                                     'ERROR_ITEM_FORMAT_1',
                                                     'ITEM',
                                                     i.ITEM_COL,
                                                     'ITEM_COL',
                                                     i.ITEM_COL,
                                                     l_err_msg);
        fnd_file.put_line(fnd_file.log,l_err_msg);
        END IF;
                            
        /*CHECK IF ITEM IS PRIME ITEM*/
        IF i.ITEM_COL IS NOT NULL
        THEN
            BEGIN
                select count(1) 
                into l_count 
                from CUST_CUSTMR_FORECAST_STG
                where i.ITEM_COL in (    SELECT DISTINCT ITEM_NAME 
                                  FROM MSC.MSC_SYSTEM_ITEMS MI, MSC.MSC_BOM_COMPONENTS MB
                                  WHERE MI.INVENTORY_ITEM_ID = MB.INVENTORY_ITEM_ID
                                  AND MB.PLANNING_FACTOR = 100 );
            EXCEPTION
                WHEN OTHERS THEN
                fnd_file.put_line(fnd_file.log,'Filed to check if ITEM is Prime Item because of Error: '||SQLERRM);
            END;
                
            if l_count = 0
            then
                handle_custmr_dmd_exception(p_request_id_cust_frcst,
                                                             'ERROR_PRIME_ITM_0',
                                                             '',
                                                             '',
                                                             'ITEM_COL',
                                                             i.ITEM_COL,
                                                             l_err_msg);
                fnd_file.put_line(fnd_file.log,l_err_msg);
                      
            END IF;
        END IF;

        /*CHECK IF ITEM IS OF NUMBER DATA TYPE*/
        --fnd_file.put_line(fnd_file.log,'CHECK IF ITEM IS OF NUMBER DATA TYPE');
        if LENGTH(TRIM(TRANSLATE(i.DATE1, ' +-.0123456789',' '))) is null and 
            LENGTH(TRIM(TRANSLATE(i.DATE2, ' +-.0123456789',' '))) is null and
            LENGTH(TRIM(TRANSLATE(i.DATE3, ' +-.0123456789',' '))) is null and
            LENGTH(TRIM(TRANSLATE(i.DATE4, ' +-.0123456789',' '))) is null and
            LENGTH(TRIM(TRANSLATE(i.DATE5, ' +-.0123456789',' '))) is null and
            LENGTH(TRIM(TRANSLATE(i.DATE6, ' +-.0123456789',' '))) is null and
            LENGTH(TRIM(TRANSLATE(i.DATE7, ' +-.0123456789',' '))) is null and
            LENGTH(TRIM(TRANSLATE(i.DATE8, ' +-.0123456789',' '))) is null and
            LENGTH(TRIM(TRANSLATE(i.DATE9, ' +-.0123456789',' '))) is null and
            LENGTH(TRIM(TRANSLATE(i.DATE10, ' +-.0123456789',' '))) is null and
            LENGTH(TRIM(TRANSLATE(i.DATE11, ' +-.0123456789',' '))) is null and
            LENGTH(TRIM(TRANSLATE(i.DATE12, ' +-.0123456789',' '))) is null 
        then
            null;
        else
            handle_custmr_dmd_exception(p_request_id_cust_frcst,
                                                         'ERROR_FCST_DATA_0',
                                                         '',
                                                         '',
                                                         'ITEM_COL',
                                                         i.ITEM_COL,
                                                         l_err_msg);
            fnd_file.put_line(fnd_file.log,l_err_msg);
                  
        END IF;
            
        /*CHECK REGION FORMAT*/
        --fnd_file.put_line(fnd_file.log,'CHECK REGION FORMAT');
        BEGIN
            SELECT length(i.REGION_COL)
            INTO l_reg_len
            FROM DUAL;
        EXCEPTION
            WHEN OTHERS THEN
            fnd_file.put_line(fnd_file.log,'Failed to check the length of region for Error: '||SQLERRM);
        END;

        IF l_reg_len is null or l_reg_len = 2
        THEN
            NULL;
        ELSE
            handle_custmr_dmd_exception(p_request_id_cust_frcst,
                                                         'ERROR_REG_FORMAT_1',
                                                         'REGION',
                                                         i.REGION_COL,
                                                         'REGION_COL',
                                                         i.REGION_COL,
                                                         l_err_msg);
            fnd_file.put_line(fnd_file.log,l_err_msg);
                  
        END IF;
    END LOOP;
    
    
 EXCEPTION
    WHEN OTHERS 
    THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG,'Error is : '||SQLCODE||' - '||SQLERRM);

 END cust_dmd_validation;

-----------/* START */---------INSERTING INTO DEMANTRA STAGING TABLE----------/* START */------------------------------
/*This Procedure inserts data from internal staging tables to Demantra staging table*/

procedure insert_into_BIIO(p_request_id_cust_frcst NUMBER,
                                                p_request_id_purchs_frcst  NUMBER,
                                                p_file_type varchar2,
                                                p_ret_code  OUT  VARCHAR2,
                                                p_ret_msg  OUT  varchar2)
    IS    
        l_attribute3 varchar2(100);
        l_attribute5 varchar2(100);
        l_attribute7 varchar2(100);
        l_attribute8 varchar2(100);
        lv_date varchar2(100);
        l_ohb_date   date;
        l_ohb varchar2(100);
        lv_date_date date;
        lv_value varchar2(100);
        qry_to_fetch_date varchar2(500);
        qry_to_fetch_value varchar2(500);
                
        CURSOR cust_dmd_data
         IS
              select * from CUST_CUSTMR_FORECAST_STG
              WHERE REQUEST_ID = p_request_id_cust_frcst
                            and upper(ITEM_COL) != 'ITEM';


        CURSOR prchs_frcst_hdr 
          IS
                  SELECT * FROM CUST_PURCHS_FORECAST_STG
                  WHERE REQUEST_ID = p_request_id_purchs_frcst
                                    and upper(ITEM_COL) != 'ITEM';

    BEGIN
        BEGIN
            select ATTRIBUTE3,ATTRIBUTE5,ATTRIBUTE7,ATTRIBUTE8
            into l_attribute3,l_attribute5,l_attribute7,l_attribute8
            from fnd_flex_value_sets ffvs,fnd_flex_values_vl ffvv
            where 1=1
            and     ffvs.FLEX_VALUE_SET_ID = ffvv.FLEX_VALUE_SET_ID
            and    ffvs.FLEX_VALUE_SET_NAME = 'CUST_DEM_FCST_TYPE'
            and    ffvv.FLEX_VALUE =  p_file_type;
        EXCEPTION
            WHEN OTHERS THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Failed to fetch the Demantra Staging tables to update for Error: '||SQLERRM);
        END;
        
        l_attribute3 := 'CCWDMP.'||l_attribute3;
        l_attribute5 := 'CCWDMP.'||l_attribute5;

        IF p_file_type like 'Customer%'
        THEN       
          for d IN cust_dmd_data
          loop
                for k in 1..12
                loop    
                qry_to_fetch_date :=  'SELECT DATE'
                             || k
                             || ' FROM CUST_CUSTMR_FORECAST_STG WHERE REQUEST_ID=:new_value and upper(ITEM_COL) = ''ITEM''';
                EXECUTE IMMEDIATE qry_to_fetch_date into lv_date using p_request_id_cust_frcst ;
                
                lv_date_date := TO_DATE(lv_date,'mm/dd/yyyy');
                    if d.REGION_COL is not null
                    then
                        qry_to_fetch_value := 'SELECT DATE'||k||' FROM CUST_CUSTMR_FORECAST_STG WHERE  ITEM_COL=:new_value1 AND REGION_COL=:new_value2 and REQUEST_ID=:new_value3' ;
                        EXECUTE IMMEDIATE  qry_to_fetch_value into lv_value using d.ITEM_COL,d.REGION_COL,p_request_id_cust_frcst;
                               
                        EXECUTE IMMEDIATE 'insert into '||upper(l_attribute3)||'(SDATE,LEVEL1,LEVEL2,'||upper(l_attribute7)||') values('''||lv_date_date||''','''||d.ITEM_COL||''','''||d.REGION_COL||''','''||lv_value||''')';
                                   
                    else
                        qry_to_fetch_value := 'SELECT DATE'||k||' FROM CUST_CUSTMR_FORECAST_STG WHERE  ITEM_COL=:new_value1 AND REGION_COL is null and REQUEST_ID=:new_value3' ;
                        EXECUTE IMMEDIATE  qry_to_fetch_value into lv_value using d.ITEM_COL,p_request_id_cust_frcst;
                                
                        EXECUTE IMMEDIATE 'insert into '||upper(l_attribute5)||'(SDATE,LEVEL1,'||upper(l_attribute7)||') values('''||lv_date_date||''','''||d.ITEM_COL||''','''||lv_value||''')';
                                
                    end if;
                    COMMIT;
               end loop;
                qry_to_fetch_date := null;
                lv_date := NULL;
                lv_date_date := NULL;
                qry_to_fetch_date := 'SELECT NOTE  FROM CUST_CUSTMR_FORECAST_STG WHERE REQUEST_ID=:new_value and upper(ITEM_COL) = ''ITEM''';
                EXECUTE IMMEDIATE qry_to_fetch_date into lv_date using p_request_id_cust_frcst ;
                lv_date_date := TO_DATE(lv_date,'mm/dd/yyyy');
                
                IF d.REGION_COL IS NOT NULL
                then
                    EXECUTE IMMEDIATE 'insert into '||upper(l_attribute3)||'(SDATE,LEVEL1,LEVEL2,'||upper(l_attribute8)||') values('''||lv_date_date||''','''||d.ITEM_COL||''','''||d.REGION_COL||''','''||d.NOTE||''')';
                ELSE
                    EXECUTE IMMEDIATE 'insert into '||upper(l_attribute5)||'(SDATE,LEVEL1,'||upper(l_attribute8)||') values('''||lv_date_date||''','''||d.ITEM_COL||''','''||d.NOTE||''')';
                END IF;                                                     
               COMMIT;
            end loop;
                            
        
        ELSE
            for d in prchs_frcst_hdr
            loop
                select OHB_DATE 
                into l_ohb FROM CUST_PURCHS_FORECAST_STG WHERE REQUEST_ID=p_request_id_purchs_frcst and upper(ITEM_COL) = 'ITEM'; 
                l_ohb_date := to_date(l_ohb,'mm/dd/yyyy');
                EXECUTE IMMEDIATE 'insert into '||upper(l_attribute3)||'(SDATE,LEVEL1,LEVEL2,PUR_FCST_BO,PUR_FCST_OHB,PUR_FCST_PO,PUR_FCST_DUE_PO,PUR_FCST_NOTES,PUR_HIST_AVG) values ('''
                                             ||l_ohb_date||''','''||d.ITEM_COL||''','''||d.OEM_COL||''','''||d.BACKORDER_DATE||''','''||d.OHB_DATE||''','''||d.OPEN_PO_DATE||''','''||d.PAST_DUE_PO||''','''||d.PLANNER_COMMENTS||''','''||d.PH_AVG||''')';
                commit;                             
                for k in 1..12
                loop    
                    qry_to_fetch_date :=  'SELECT PUR_FCST_DATE'
                                 || k
                                 || ' FROM CUST_PURCHS_FORECAST_STG WHERE REQUEST_ID=:new_value and upper(ITEM_COL) = ''ITEM''';
                     EXECUTE IMMEDIATE qry_to_fetch_date into lv_date using p_request_id_purchs_frcst ;
                     lv_date_date := TO_DATE(lv_date,'mm/dd/yyyy');
                         
                     qry_to_fetch_value := 'SELECT PUR_FCST_DATE'||k||' FROM CUST_PURCHS_FORECAST_STG WHERE  ITEM_COL=:new_value1 AND OEM_COL=:new_value2 and REQUEST_ID=:new_value3' ;
                     EXECUTE IMMEDIATE  qry_to_fetch_value into lv_value using d.ITEM_COL,d.OEM_COL,p_request_id_purchs_frcst;
                         
                     EXECUTE IMMEDIATE 'insert into '||upper(l_attribute3)||'(SDATE,LEVEL1,LEVEL2,PUR_FCST) values ('''
                                            ||lv_date_date||''','''||d.ITEM_COL||''','''||d.OEM_COL||''','''||lv_value||''')';
                     commit;         
                end loop;
                 qry_to_fetch_date := null;
                 lv_date := null;
                 lv_date_date := null;
                 qry_to_fetch_value := null;
                 lv_value := null;
                for i in 1..3
                loop
                    qry_to_fetch_date := 'SELECT PUR_HIST_DATE'||i||' FROM CUST_PURCHS_FORECAST_STG WHERE  REQUEST_ID=:new_value and upper(ITEM_COL) = ''ITEM''' ;
                    EXECUTE IMMEDIATE  qry_to_fetch_date into lv_date using p_request_id_purchs_frcst;
                    lv_date_date := TO_DATE(lv_date,'mm/dd/yyyy');

                    qry_to_fetch_value := 'SELECT PUR_HIST_DATE'||i||' FROM CUST_PURCHS_FORECAST_STG WHERE  ITEM_COL=:new_value1 AND OEM_COL=:new_value2 and REQUEST_ID=:new_value3' ;
                    EXECUTE IMMEDIATE  qry_to_fetch_value into lv_value using d.ITEM_COL,d.OEM_COL,p_request_id_purchs_frcst;

                    EXECUTE IMMEDIATE 'insert into '||upper(l_attribute3)||'(SDATE,LEVEL1,LEVEL2,PUR_HIST) values ('''
                                            ||lv_date_date||''','''||d.ITEM_COL||''','''||d.OEM_COL||''','''||lv_value||''')';
                    commit;
                end loop;
                 /*qry_to_fetch_date := null;
                 lv_date := null;
                 lv_date_date := null;
                 
                 qry_to_fetch_date := 'SELECT PLANNER_COMMENTS FROM CUST_PURCHS_FORECAST_STG WHERE REQUEST_ID=:new_value and upper(ITEM_COL) = ''ITEM''';
                 EXECUTE IMMEDIATE qry_to_fetch_date into lv_date using p_request_id_purchs_frcst ;
                 lv_date_date := TO_DATE(lv_date,'mm/dd/yyyy');
                 
                 EXECUTE IMMEDIATE 'insert into '||upper(l_attribute3)||'(SDATE,LEVEL1,LEVEL2,PUR_FCST_NOTES) values ('''||lv_date_date||''','''||d.ITEM_COL||''','''||d.OEM_COL||''','''||d.PLANNER_COMMENTS||''')';
                 COMMIT;     */               
             end loop;
         END IF;

END insert_into_BIIO;
-----------/* END */---------INSERTING INTO DEMANTRA STAGING TABLE----------/* END */------------------------------


/*This procedure handles the error caught during Puchase Forecast file type validation*/
    procedure handle_purchs_dmd_exception(p_request_id_purchs_frcst NUMBER,
                                                        p_err_msg_name    IN     VARCHAR2,
                                                        p_token_list      IN     VARCHAR2,
                                                        p_value_list      IN     VARCHAR2,
                                                        p_column             IN     VARCHAR2,
                                                        p_col_value         IN        VARCHAR2,
                                                        p_error_message      OUT VARCHAR2)
   IS
        l_msg           VARCHAR2 (50);
        l_msg_number    VARCHAR2 (30);
        l_return_code   VARCHAR2 (50);
        l_return_msg    VARCHAR2 (256);
        qry                 VARCHAR2(500);
   BEGIN
        fnd_message.set_name('CCWDMP',p_err_msg_name);
        IF p_token_list IS NOT NULL AND p_value_list  IS NOT NULL
        THEN
        fnd_message.set_token(p_token_list,p_value_list);
        END IF;
        
        p_error_message := '['||fnd_message.get ()||']';
        
        IF p_col_value IS NULL
          THEN 
          fnd_file.put_line(fnd_file.log,'here1 ');
          qry := 'update CUST_PURCHS_FORECAST_STG
                          set err = err||:new_value
                          WHERE REQUEST_ID = :new_value2 
                                     AND "'||p_column||'" IS NULL AND upper(PUR_FCST_DATE1) != ''PUR FCST''' ;
          execute immediate qry using p_error_message,p_request_id_purchs_frcst;
          commit;
        ELSE  
          fnd_file.put_line(fnd_file.log,'here2 ');                 
          qry := 'update CUST_PURCHS_FORECAST_STG
                          set err = err||:new_value
                          WHERE REQUEST_ID = :new_value2 
                                     AND "'||p_column||'" = :new_value3' ;
          execute immediate qry using p_error_message,p_request_id_purchs_frcst,p_col_value;
          commit;
        END IF;

   END handle_purchs_dmd_exception;

/*This procedure handles the error caught during Customer Demand Forecast file type validation*/
  procedure handle_custmr_dmd_exception(p_request_id_cust_frcst NUMBER,
                                                        p_err_msg_name    IN     VARCHAR2,
                                                        p_token_list      IN     VARCHAR2,
                                                        p_value_list      IN     VARCHAR2,
                                                        p_column             IN     VARCHAR2,
                                                        p_col_value         IN        VARCHAR2,
                                                        p_error_message      OUT VARCHAR2)
   IS
        l_msg           VARCHAR2 (50);
        l_msg_number    VARCHAR2 (30);
        l_return_code   VARCHAR2 (50);
        l_return_msg    VARCHAR2 (256);
        qry                 VARCHAR2(1000);
   BEGIN

        fnd_message.set_name('CCWDMP',p_err_msg_name);
        IF p_token_list IS NOT NULL AND p_value_list  IS NOT NULL
        THEN
        fnd_message.set_token(p_token_list,p_value_list);
        END IF;
                
        p_error_message := '['||fnd_message.get ()||']';
                  
        IF p_col_value IS NULL
        THEN 
          qry := 'update CUST_CUSTMR_FORECAST_STG
                          set err = err||:new_value  
                          WHERE REQUEST_ID = :new_value2 
                                     AND "'||p_column||'" IS NULL AND upper(DATE1) != ''DMD FCST''' ;
                            
          execute immediate qry using p_error_message,p_request_id_cust_frcst;
          commit;
        ELSE                      
          qry := 'update CUST_CUSTMR_FORECAST_STG
                          set err = err||:new_value 
                          WHERE REQUEST_ID = :new_value2 
                                     AND "'||p_column||'" = :new_value3' ;
                                                 
          execute immediate qry using p_error_message,p_request_id_cust_frcst,p_col_value;
                      
          commit;
        END IF;

   END handle_custmr_dmd_exception;
   
/*This procedure sends mail to the user depending on the flag value*/
   procedure send_err_notification (        p_ret_code  OUT VARCHAR2,
                                            p_ret_msg   OUT varchar2,
                                            p_forecast_type IN VARCHAR2,
                                            p_dest_dir  IN  VARCHAR2,
                                            p_file_name IN  VARCHAR2,
                                            p_err_file  IN  VARCHAR2,
                                            p_mail_id   IN  VARCHAR2,
                                            p_flag      IN  VARCHAR2
                                        )
    IS
        l_subject       VARCHAR2(500):= null;
        ln_request_id   NUMBER;
        l_database      VARCHAR2(100);
        l_sender        VARCHAR2(100);
        
        
            
    BEGIN
    
        begin
            select name 
            into l_database
            from v$database;
        exception
            when others then
            fnd_file.put_line(fnd_file.log,'Error occured to fetch database name :'||SQLERRM);
        end;
             
        l_sender :=   l_database||'@maillennium.att.com';
         
        IF p_flag = 'VLDTN_FAIL' 
        THEN
            fnd_file.put_line(fnd_file.log,'SENDING ERROR NOTIFICATION MAIL TO USER');
            l_subject := p_forecast_type||' Upload Process Failed Validation';
             
            ln_request_id := FND_REQUEST.SUBMIT_REQUEST (
                                                        application   => 'CCWDMP', -- Application Short Code
                                                        program       => 'CUST_SEND_ERR_EMAIL', -- Concurrent Program Short NAme
                                                        description   => 'Custom Forecast Error Mail', -- Concurrent Program Description
                                                        start_time    => SYSDATE,
                                                        sub_request   => FALSE,
                                                        argument1     =>  p_mail_id,
                                                        argument2      => p_err_file,
                                                        argument3      => p_dest_dir,
                                                        argument4      => l_subject,
                                                        argument5      => l_sender,
                                                        argument6      => 'VLDTN_FAIL'
                                                      );
            commit;
        ELSIF p_flag = 'UPLD_SUCC'
        THEN  
            fnd_file.put_line(fnd_file.log,'SENDING SUCCESSFUL UPLOAD NOTIFICATION MAIL TO USER');
            l_subject := p_file_name||' upload process completed Successfully';
             
            ln_request_id := FND_REQUEST.SUBMIT_REQUEST (
                                                        application   => 'CCWDMP', -- Application Short Code
                                                        program       => 'CUST_SEND_ERR_EMAIL', -- Concurrent Program Short NAme
                                                        description   => 'Custom Forecast Error Mail', -- Concurrent Program Description
                                                        start_time    => SYSDATE,
                                                        sub_request   => FALSE,
                                                        argument1     =>  p_mail_id,
                                                        argument2      => p_err_file,
                                                        argument3      => p_dest_dir,
                                                        argument4      => l_subject,
                                                        argument5      => l_sender,
                                                        argument6      => 'UPLD_SUCC'
                                                      );
            commit;
            
        ELSE
            fnd_file.put_line(fnd_file.log,'SENDING UPLOAD ERROR MAIL TO USER');
            l_subject := p_file_name||' upload process completed with ERROR';
             
            ln_request_id := FND_REQUEST.SUBMIT_REQUEST (
                                                        application   => 'CCWDMP', -- Application Short Code
                                                        program       => 'CUST_SEND_ERR_EMAIL', -- Concurrent Program Short NAme
                                                        description   => 'Custom Forecast Error Mail', -- Concurrent Program Description
                                                        start_time    => SYSDATE,
                                                        sub_request   => FALSE,
                                                        argument1     =>  p_mail_id,
                                                        argument2      => p_err_file,
                                                        argument3      => p_dest_dir,
                                                        argument4      => l_subject,
                                                        argument5      => l_sender,
                                                        argument6      => 'UPLD_FAIL'
                                                      );
            commit;
       END IF;
    END send_err_notification;
   
/*This procedure calls the standard Workflow prgram "CCWDMTRA_WF" and checks the Demantra Error table for data */
    procedure send_upload_notifctn (        p_ret_code  OUT VARCHAR2,
                                            p_ret_msg   OUT varchar2,
                                            p_forecast_type IN VARCHAR2,
                                            p_dest_dir  IN  VARCHAR2,
                                            p_file_name  IN  VARCHAR2,
                                            p_mail_id   IN  VARCHAR2,
                                            p_user      IN  VARCHAR2
                                        )
    is
        ln_request_id_validtn   number;
        ln_request_id_notifctn  number;
        l_attribute4            varchar2(300);
        l_attribute6            varchar2(300);
        l_attribute9            varchar2(300);
        l_attribute10           varchar2(300);
        l_attribute4_cnt        number;
        l_attribute6_cnt        number;
        lv_line_txt             varchar2(1000);
        lv_filetype             UTL_FILE.file_type;
        l_ret_code              varchar2(500);
        l_ret_msg               varchar2(500);
        l_email_id              varchar2(100);
        lv_file_name_txt        varchar2(100);
        l_req_return_status     BOOLEAN;
        lc_phase                VARCHAR2(50);
        lc_status               VARCHAR2(50);
        lc_dev_phase            VARCHAR2(50);
        lc_dev_status           VARCHAR2(50);
        lc_message              VARCHAR2(50);
        stmt                    VARCHAR2(500);
        l_dest_dir              VARCHAR2(100);
        l_forecast_type         VARCHAR2(100);
        l_user                  VARCHAR2(100);
        qry                     VARCHAR2(500);
        l_file_name             VARCHAR2(100);
        l_err_message           CCWDMP.BIIO_ATT_CUST1_FCST_ERR.ERR_MESSAGE%TYPE;
        l_sdate                 CCWDMP.BIIO_ATT_CUST1_FCST_ERR.SDATE%TYPE;
        l_level1                CCWDMP.BIIO_ATT_CUST1_FCST_ERR.LEVEL1%TYPE;
        l_level2                CCWDMP.BIIO_ATT_CUST1_FCST_ERR.LEVEL2%TYPE;
        l_cust1_fcst_notes      CCWDMP.BIIO_ATT_CUST1_FCST_ERR.CUST1_FCST_NOTES%TYPE;
        l_cust1_fcst            CCWDMP.BIIO_ATT_CUST1_FCST_ERR.CUST1_FCST%TYPE;
        l_pur_fcst_bo           CCWDMP.BIIO_ATT_PUR_FCST_ERR.PUR_FCST_BO%TYPE;
        l_pur_fcst_ohb          CCWDMP.BIIO_ATT_PUR_FCST_ERR.PUR_FCST_OHB%TYPE;
        l_pur_fcst_po           CCWDMP.BIIO_ATT_PUR_FCST_ERR.PUR_FCST_PO%TYPE;
        l_pur_fcst_due_po       CCWDMP.BIIO_ATT_PUR_FCST_ERR.PUR_FCST_DUE_PO%TYPE;
        l_pur_fcst_notes        CCWDMP.BIIO_ATT_PUR_FCST_ERR.PUR_FCST_NOTES%TYPE;
        l_pur_fcst              CCWDMP.BIIO_ATT_PUR_FCST_ERR.PUR_FCST%TYPE;
        l_pur_hist              CCWDMP.BIIO_ATT_PUR_FCST_ERR.PUR_HIST%TYPE;
        l_pur_hist_avg          CCWDMP.BIIO_ATT_PUR_FCST_ERR.PUR_HIST_AVG%TYPE;
        
        type err_data_ref IS REF CURSOR;
        
        err_data err_data_ref;
                
        
    begin
        l_dest_dir := p_dest_dir;
        l_forecast_type := p_forecast_type;
        l_email_id := p_mail_id;
        l_user := p_user;
        l_file_name := p_file_name;
        BEGIN
            select ATTRIBUTE4,ATTRIBUTE6,ATTRIBUTE9,ATTRIBUTE10
            into l_attribute4,l_attribute6,l_attribute9,l_attribute10
            from fnd_flex_value_sets ffvs,fnd_flex_values_vl ffvv
            where 1=1
            and     ffvs.FLEX_VALUE_SET_ID = ffvv.FLEX_VALUE_SET_ID
            and    ffvs.FLEX_VALUE_SET_NAME = 'CUST_DEM_FCST_TYPE'
            and    ffvv.FLEX_VALUE =  p_forecast_type;
        EXCEPTION
            WHEN OTHERS THEN
                FND_FILE.PUT_LINE(FND_FILE.LOG,'Failed to fetch the Demantra Staging tables to update for Error: '||SQLERRM);
        END;
        
        l_attribute4 := 'CCWDMP.'||l_attribute4;
        if l_attribute6 is not null
        then
            l_attribute6 := 'CCWDMP.'||l_attribute6;
        end if;
        
        
        fnd_file.put_line(fnd_file.log,'CALLING STANDARD VALIDATION WORKFLOW PROCESS TO VALIDATE DATA IN DEMANTRA BIIO STAGING TABLE');
        
        ln_request_id_validtn := FND_REQUEST.SUBMIT_REQUEST (
                                                                application   => 'CCWMSC', -- Application Short Code
                                                                program       => 'CCWDMTRA_WF', -- Concurrent Program Short NAme
                                                                description   => 'Custom Demantra Workflow', -- Concurrent Program Description
                                                                start_time    => SYSDATE,
                                                                sub_request   => FALSE,
                                                                argument1     =>  l_attribute9,
                                                                argument2      => NULL,
                                                                argument3      => l_attribute10
                                                              );
        commit;
        
        IF ln_request_id_validtn = 0
        THEN
            fnd_file.put_line(fnd_file.log,'The Validation program failed to validate data in Demantra BIIO Staging table.');
        ELSE
            LOOP
                --To make process execution to wait for 1st program to complete
                l_req_return_status :=
                fnd_concurrent.wait_for_request (  request_id      => ln_request_id_validtn
                                                  ,interval        => 2
                                                  ,max_wait        => 60
                                                  ,phase           => lc_phase
                                                  ,status          => lc_status
                                                  ,dev_phase       => lc_dev_phase
                                                  ,dev_status      => lc_dev_status
                                                  ,message         => lc_message
                                                  );                        
            EXIT WHEN UPPER (lc_phase) = 'COMPLETED' OR UPPER (lc_status) IN ('CANCELLED', 'ERROR', 'TERMINATED');
            END LOOP;
                     
            IF lc_status = 'ERROR'
            THEN
                fnd_file.put_line(fnd_file.log,'The Validation program failed to validate data in Demantra BIIO Staging table.');
            ELSE
                             
                fnd_file.put_line(fnd_file.log,'The loader program successfully validated data in Demantra BIIO Staging table.');
            END IF;
        END IF;
        

        begin
            qry := ' begin select count(*)  into :into_bind from '||l_attribute4||'; end;' ;
            EXECUTE IMMEDIATE qry USING OUT l_attribute4_cnt;
            
            qry := NULL;
            IF l_attribute6 is not null 
            THEN
            qry := ' begin select count(*)  into :into_bind from '||l_attribute6||'; end;' ;
            EXECUTE IMMEDIATE qry USING OUT l_attribute6_cnt;
            END IF;
            
        exception
            when others then 
            fnd_file.put_line(fnd_file.log,'Error to fetch the count of data in Demantra Error table is : '||sqlerrm);
        end;
        
        IF l_attribute4_cnt> 0 
        THEN
            fnd_file.put_line(fnd_file.log,'Data is present in Demantra error table '||l_attribute4);
        end if;
        
        if l_attribute6_cnt> 0
        then
            fnd_file.put_line(fnd_file.log,'Data is present in Demantra error table '||l_attribute6);
        end if;
        
        if p_forecast_type like 'Cust%' and (l_attribute4_cnt >0 or l_attribute6_cnt >0)
        then
            lv_file_name_txt := l_attribute4||'_'||l_user||'.csv';
            lv_filetype      := UTL_FILE.fopen (l_dest_dir, lv_file_name_txt, 'w','32767');
            
            lv_line_txt := RPAD('ERROR MESSAGE',15,' ')
            ||','||RPAD('SDATE',15,' ')
            ||','||RPAD('LEVEL1',15,' ')
            ||','||RPAD('LEVEL2',15,' ')
            ||','||RPAD('CUST FSCT NOTES',30,' ')
            ||','||RPAD('CUST FSCT',15,' ');
            
            UTL_FILE.put_line (lv_filetype, lv_line_txt);
            lv_line_txt := NULL;
            
            open err_data for 'SELECT * FROM '||l_attribute4||' order by 3,4,2' ; 
            loop
                exit when err_data%notfound;
                fetch err_data into l_err_message,l_sdate,l_level1,l_level2,l_cust1_fcst_notes,l_cust1_fcst;
                lv_line_txt := '"'||replace(replace(l_err_message,CHR(13),''),chr(10),'')||'",'||replace(replace(l_sdate,CHR(13),''),chr(10),'')||','||replace(replace(l_level1,CHR(13),''),chr(10),'')
                ||','||replace(replace(l_level2,CHR(13),''),chr(10),'')||',"'||replace(replace(l_cust1_fcst_notes,CHR(13),''),chr(10),'')||'",'||replace(replace(l_cust1_fcst,CHR(13),''),chr(10),'');
                UTL_FILE.put_line (lv_filetype, lv_line_txt);
                lv_line_txt := NULL;
                l_err_message := null;l_sdate := null;l_level1:=null; l_level2 := null; l_cust1_fcst_notes := null; l_cust1_fcst := null;
            end loop;
  
            lv_line_txt := chr(13)||chr(10)||chr(13)||chr(10)||chr(13)||chr(10)||chr(13)||chr(10)||chr(13)||chr(10)||chr(13)||chr(10)||
                            chr(13)||chr(10)||chr(13)||chr(10)||chr(13)||chr(10)||chr(13)||chr(10)||chr(13)||chr(10)||chr(13)||chr(10);
            UTL_FILE.put_line (lv_filetype, lv_line_txt);
            lv_line_txt := NULL;
            l_err_message := NULL;
            l_sdate := NULL;
            l_level1 := NULL;
            l_level2 := NULL;
            l_cust1_fcst_notes := NULL;
            l_cust1_fcst := NULL;
                        
            open err_data for 'SELECT * FROM '||l_attribute6||'  order by 3,2' ; 
            loop
                exit when err_data%notfound;
                fetch err_data into l_err_message,l_sdate,l_level1,l_cust1_fcst_notes,l_cust1_fcst;
                lv_line_txt := '"'||replace(replace(l_err_message,CHR(13),''),chr(10),'')||'",'||replace(replace(l_sdate,CHR(13),''),chr(10),'')||','||replace(replace(l_level1,CHR(13),''),chr(10),'')
                ||','||''||',"'||replace(replace(l_cust1_fcst_notes,CHR(13),''),chr(10),'')||'",'||replace(replace(l_cust1_fcst,CHR(13),''),chr(10),'');
                UTL_FILE.put_line (lv_filetype, lv_line_txt);
                lv_line_txt := NULL;
                l_err_message := null;l_sdate := null; l_level1:= null;l_level2:=null;l_cust1_fcst_notes := null; l_cust1_fcst := null;
            end loop;
            UTL_FILE.fclose (lv_filetype);
            
            send_err_notification ( l_ret_code,l_ret_msg,l_forecast_type,l_dest_dir,l_file_name,lv_file_name_txt,l_email_id,'UPLD_FAIL' );
            
        elsif p_forecast_type like 'Pur%' and l_attribute4_cnt >0
        then
            
            lv_file_name_txt := l_attribute4||'_'||l_user||'.csv';
            
            lv_filetype      := UTL_FILE.fopen (p_dest_dir, lv_file_name_txt, 'w','32767');
            
            lv_line_txt := RPAD('ERROR MESSAGE',15,' ')
            ||','||RPAD('SDATE',15,' ')
            ||','||RPAD('LEVEL1',15,' ')
            ||','||RPAD('LEVEL2',15,' ')
            ||','||RPAD('PUR FCST BO',30,' ')
            ||','||RPAD('PUR FCST OHB',15,' ')
            ||','||RPAD('PUR FCST PO',15,' ')
            ||','||RPAD('PUR FCST DUE PO',15,' ')
            ||','||RPAD('PUR FCST NOTES',15,' ')
            ||','||RPAD('PUR FCST',15,' ')
            ||','||RPAD('PUR HIST',15,' ')
            ||','||RPAD('PUR HIST AVG',15,' ');
            
            UTL_FILE.put_line (lv_filetype, lv_line_txt);
            lv_line_txt := NULL;
                        
            open err_data for 'SELECT * FROM '||l_attribute4|| 'order by 3,4,2' ; 
            loop
                exit when err_data%notfound;
                fetch err_data into l_err_message,l_sdate,l_level1,l_level2,l_pur_fcst_bo,l_pur_fcst_ohb,l_pur_fcst_po,l_pur_fcst_due_po,l_pur_fcst_notes,l_pur_fcst,l_pur_hist,l_pur_hist_avg;
                lv_line_txt := '"'||replace(replace(l_err_message,CHR(13),''),chr(10),'')||'",'||replace(replace(l_sdate,CHR(13),''),chr(10),'')||','||replace(replace(l_level1,CHR(13),''),chr(10),'')||','||replace(replace(l_level2,CHR(13),''),chr(10),'')
                ||','||replace(replace(l_pur_fcst_bo,CHR(13),''),chr(10),'')||','||replace(replace(l_pur_fcst_ohb,CHR(13),''),chr(10),'')||','||replace(replace(l_pur_fcst_po,CHR(13),''),chr(10),'')||','||replace(replace(l_pur_fcst_due_po,CHR(13),''),chr(10),'')||',"'||replace(replace(l_pur_fcst_notes,CHR(13),''),chr(10),'')||
                                '",'||replace(replace(l_pur_fcst,CHR(13),''),chr(10),'')||','||replace(replace(l_pur_hist,CHR(13),''),chr(10),'')||','||replace(replace(l_pur_hist_avg,CHR(13),''),chr(10),'');
                UTL_FILE.put_line (lv_filetype, lv_line_txt);
                lv_line_txt := NULL;
                l_err_message :=null; l_sdate := null;l_level1:= null;l_level2:= null;l_pur_fcst_bo:= null;l_pur_fcst_ohb:= null;l_pur_fcst_po:= null;l_pur_fcst_due_po:= null;l_pur_fcst_notes:= null;l_pur_fcst:= null;l_pur_hist:= null;l_pur_hist_avg:= null;
                
            end loop;
            UTL_FILE.fclose (lv_filetype);
           
            send_err_notification ( l_ret_code,l_ret_msg,l_forecast_type,l_dest_dir,l_file_name,lv_file_name_txt,l_email_id,'UPLD_FAIL' );
        else
            send_err_notification ( l_ret_code,l_ret_msg,l_forecast_type,null,l_file_name,null,l_email_id,'UPLD_SUCC' );
        end if;
        
        if l_attribute4_cnt >0 
        then
            fnd_file.put_line(fnd_file.log,'Truncating Demantra Error table: '||l_attribute4);
            EXECUTE IMMEDIATE 'Truncate table '|| l_attribute4||'' ;
        end if;
        
        if  l_attribute6_cnt>0
        then
            fnd_file.put_line(fnd_file.log,'Truncating Demantra Error table: '||l_attribute6);
            EXECUTE IMMEDIATE 'Truncate table '|| l_attribute6||'' ;
        else
            null;
        end if;
    end send_upload_notifctn;

/*This is the main procedure*/
procedure LOAD_FORECAST_DEMANTRA(    
                                                    p_ret_code    out    varchar2,
                                                    p_errbuff     out varchar2,
                                                    p_file_name varchar2,
                                                    p_forecast_type varchar2)
    is
            l_ret_code                    varchar2(500);
            l_ret_msg                     varchar2(500);
            ln_request_id_cust_frcst      number;
            ln_request_id_purchs_frcst    number;
            l_status_code                 VARCHAR2(20);
            l_req_return_status           BOOLEAN;
            lc_phase                      VARCHAR2(50);
            lc_status                     VARCHAR2(50);
            lc_dev_phase                  VARCHAR2(50);
            lc_dev_status                 VARCHAR2(50);
            lc_message                    VARCHAR2(50);
            l_cust_dmd_count              number;
            l_purchs_frcst_count          number;
            l_err_count                   number;
            l_profile_value               VARCHAR2(500);
            lv_file_name_txt              VARCHAR2(500);
            lv_filetype                   UTL_FILE.file_type;
            lv_dest_dir                   VARCHAR2(500);
            lv_line_txt                   VARCHAR2(10000);
            l_email_id                    VARCHAR2(100);
            l_database                    VARCHAR2(100); 
            l_dot_posn                    NUMBER; 
            l_user_id_n                   NUMBER; 
            l_login_id_n                  NUMBER; 
            l_user_name                   VARCHAR2(100);

            
            CURSOR cust_dmd_data (p_request_id_cust_frcst NUMBER)
            IS
            select * from CUST_CUSTMR_FORECAST_STG
            WHERE REQUEST_ID = p_request_id_cust_frcst;


            CURSOR prchs_frcst_hdr (p_request_id_purchs_frcst NUMBER)
            IS
            SELECT * FROM CUST_PURCHS_FORECAST_STG
            WHERE REQUEST_ID = p_request_id_purchs_frcst; 
                
    begin
            
            BEGIN
                select  PROFILE_OPTION_VALUE
                into    l_profile_value
                from    FND_PROFILE_OPTIONS fpo,
                        FND_PROFILE_OPTION_VALUES fpov
                where   1=1
                    and fpo.PROFILE_OPTION_ID = fpov.PROFILE_OPTION_ID
                    and fpo.PROFILE_OPTION_NAME = 'CUST_DEM_FCST_UPLOAD_DIR';
            EXCEPTION
                WHEN OTHERS THEN
                    fnd_file.put_line(fnd_file.log,'Error to get the Profile path for Data loading because od Error' || SQLERRM);
            END;
            
                BEGIN
                    l_user_id_n := FND_GLOBAL.USER_ID;
                    l_login_id_n := FND_GLOBAL.login_id;
                    
                    SELECT user_name
                    into l_user_name
                    FROM fnd_user
                    WHERE user_id = l_user_id_n;
                    
                EXCEPTION
                    WHEN OTHERS THEN
                        fnd_file.put_line(fnd_file.log,'Error in getting user_id and login_id : '||SQLERRM);
                END;
            
            fnd_file.put_line(fnd_file.log,'STARTING LOADER PROGRAM');
            fnd_file.put_line(fnd_file.log,'File Name: '||p_file_name);
            fnd_file.put_line(fnd_file.log,'Forecast Type: '||p_forecast_type);
                
                
            BEGIN
            select count(1)
            into l_cust_dmd_count
            FROM   fnd_flex_value_sets ffvs, fnd_flex_values_vl ffvv
                    WHERE       ffvs.flex_value_set_id = ffvv.flex_value_set_id
                    AND ffvs.flex_value_set_name = 'CUST_DEM_FCST_TYPE'
                    and p_forecast_type like 'Customer%';
            EXCEPTION
                    WHEN OTHERS THEN
                    fnd_file.put_line(fnd_file.log,'Failed to check file type because of error :'||SQLERRM);
            END;
                    

           /************START****************CALLING THE LOADER PROGRAM***************START***************/
            IF l_cust_dmd_count > 0 
            THEN    
                    fnd_file.put_line(fnd_file.log,'CALLING LOADER PROGRAM FOR CUSTOMER FORECAST');
                    ln_request_id_cust_frcst :=FND_REQUEST.SUBMIT_REQUEST (
                                                                                application   => 'CCWMSC', -- Application Short Code
                                                                                program       => 'CCW_COMM_LOAD', -- Concurrent Program Short NAme
                                                                                description   => 'CCW Common Loader', -- Concurrent Program Description
                                                                                start_time    => SYSDATE,
                                                                                sub_request   => FALSE,
                                                                                argument1     =>  l_profile_value,
                                                                                argument2      => 'CUST_CUSTMR_FORECAST_STG.ctl',
                                                                                argument3      => 'CUST_CUSTMR_FORECAST_STG',
                                                                                argument4      => '$CCWDMP_TOP/bin',
                                                                                argument5      => p_file_name,
                                                                                argument6      => 'Y',
                                                                                argument7      => '$CCWDMP_TOP/data/hist'
                                                                              );
                                                                              commit;
                    IF ln_request_id_cust_frcst = 0
                    THEN
                        fnd_file.put_line(fnd_file.log,'The loader program failed to insert data in CUST_CUSTMR_FORECAST_STG.');
                    ELSE
                        LOOP
                            --To make process execution to wait for 1st program to complete
                            l_req_return_status :=
                            fnd_concurrent.wait_for_request (request_id      => ln_request_id_cust_frcst
                                                                          ,interval        => 2
                                                                          ,max_wait        => 60
                                                                          ,phase           => lc_phase
                                                                          ,status          => lc_status
                                                                          ,dev_phase       => lc_dev_phase
                                                                          ,dev_status      => lc_dev_status
                                                                          ,message         => lc_message
                                                                          );                        
                        EXIT WHEN UPPER (lc_phase) = 'COMPLETED' OR UPPER (lc_status) IN ('CANCELLED', 'ERROR', 'TERMINATED');
                        END LOOP;
                     
                        IF lc_status = 'ERROR'
                        THEN
                            fnd_file.put_line(fnd_file.log,'The loader program failed to insert data in CUST_CUSTMR_FORECAST_STG.');
                        ELSE
                             UPDATE CUST_CUSTMR_FORECAST_STG
                             SET REQUEST_ID = ln_request_id_cust_frcst
                                         where REQUEST_ID is null;
                             COMMIT;

                            fnd_file.put_line(fnd_file.log,'The loader program successfully inserted data in CUST_CUSTMR_FORECAST_STG.');
                        END IF;
                    END IF;
            ELSE 
                    fnd_file.put_line(fnd_file.log,'CALLING LOADER PROGRAM FOR PURCHASE FORECAST');
                    ln_request_id_purchs_frcst :=FND_REQUEST.SUBMIT_REQUEST (
                                                                                application   => 'CCWMSC', -- Application Short Code
                                                                                program       => 'CCW_COMM_LOAD', -- Concurrent Program Short NAme
                                                                                description   => 'CCW Common Loader', -- Concurrent Program Description
                                                                                start_time    => SYSDATE,
                                                                                sub_request   => FALSE,
                                                                                argument1     => l_profile_value,
                                                                                argument2      => 'CUST_PURCHS_FORECAST_STG.ctl',
                                                                                argument3      => 'CUST_PURCHS_FORECAST_STG',
                                                                                argument4      => '$CCWDMP_TOP/bin',
                                                                                argument5      => p_file_name,
                                                                                argument6      => 'Y',
                                                                                argument7      => '$CCWDMP_TOP/data/hist'
                                                                              );
                                                                              commit;
                    if ln_request_id_purchs_frcst = 0
                    then
                        fnd_file.put_line(fnd_file.log,'The loader program failed to insert data in CUST_PURCHS_FORECAST_STG.');
                    else

                        LOOP
                        --To make process execution to wait for 1st program to complete
                            l_req_return_status :=
                                fnd_concurrent.wait_for_request (request_id      => ln_request_id_purchs_frcst
                                                                          ,INTERVAL        => 2
                                                                          ,max_wait        => 60
                                                                          ,phase           => lc_phase
                                                                          ,STATUS          => lc_status
                                                                          ,dev_phase       => lc_dev_phase
                                                                          ,dev_status      => lc_dev_status
                                                                          ,message         => lc_message
                                                                          );                        
                         EXIT
                         WHEN UPPER (lc_phase) = 'COMPLETED' OR UPPER (lc_status) IN ('CANCELLED', 'ERROR', 'TERMINATED');
                         END LOOP;
                            
                                 IF lc_status = 'ERROR'
                                 THEN
                                        fnd_file.put_line(fnd_file.log,'The loader program failed to insert data in CUST_PURCHS_FORECAST_STG.');
                                 ELSE
                                        UPDATE CUST_PURCHS_FORECAST_STG
                                        SET REQUEST_ID = ln_request_id_purchs_frcst
                                        where REQUEST_ID is null;
                                        COMMIT;

                              fnd_file.put_line(fnd_file.log,'The loader program successfully inserted data in CUST_PRCHS_FRCST_HEADER_STG.');

                         END IF;
                      END IF;
                 END IF;
            /************END****************CALLING THE LOADER PROGRAM***************END***************/


            /************START****************CALLING THE VALIDATION API***************START***************/
            fnd_file.put_line(fnd_file.log,'PERFORMING DATA VALIDATION: ');
            
            IF l_cust_dmd_count > 0
            THEN
              fnd_file.put_line(fnd_file.log,'CALLING CUSTOMER FORECAST DATA VALIDATION API');
               BEGIN
                    UPDATE CUST_CUSTMR_FORECAST_STG
                    SET ERR = 'ERROR_MSG'
                    WHERE REQUEST_ID = ln_request_id_cust_frcst AND date1 = 'DMD FCST';
                    commit;
                EXCEPTION
                    WHEN OTHERS THEN
                    fnd_file.put_line(fnd_file.log,'Exception Caught : '||SQLERRM);
                END;
              cust_dmd_validation(ln_request_id_cust_frcst,l_ret_code,l_ret_msg);
            ELSE 
              fnd_file.put_line(fnd_file.log,'CALLING PURCHASE FORECAST DATA VALIDATION API');
               BEGIN
                    UPDATE CUST_PURCHS_FORECAST_STG
                    SET ERR = 'ERROR_MSG'
                    WHERE REQUEST_ID = ln_request_id_purchs_frcst AND OHB_DATE = 'OHB';
                    commit;
                EXCEPTION
                    WHEN OTHERS THEN
                    fnd_file.put_line(fnd_file.log,'Exception Caught : '||SQLERRM);
                END;
              prchs_frcst_validation (ln_request_id_purchs_frcst,l_ret_code,l_ret_msg);
            END IF;
            /************END****************CALLING THE VALIDATION API***************END***************/
                
            COMMIT;
            fnd_file.put_line(fnd_file.log,'DONE VALIDATION');
                
            IF l_cust_dmd_count > 0
            THEN
                select count(1)
                into l_err_count
                from CUST_CUSTMR_FORECAST_STG
                where ERR is NOT NULL and ERR!='ERROR_MSG'
                        AND REQUEST_ID = ln_request_id_cust_frcst;
            ELSE
                select count(1)
                into l_err_count
                from CUST_PURCHS_FORECAST_STG
                where ERR is NOT NULL and ERR!='ERROR_MSG'
                        AND REQUEST_ID = ln_request_id_purchs_frcst;
            END IF;
            fnd_file.put_line(fnd_file.log,'Number of Validation Error occured: '||l_err_count);
            
            begin
                    select name 
                    into l_database
                    from v$database;
            exception
                    when others then
                    fnd_file.put_line(fnd_file.log,'Error occured to fetch database name :'||SQLERRM);
            end;
                
           lv_dest_dir := '/opt/app/nfs_share/'||l_database||'/tmp';
           l_email_id := l_user_name||'@att.com';
                
            IF l_err_count = 0
            THEN
                insert_into_BIIO(ln_request_id_cust_frcst,ln_request_id_purchs_frcst,p_forecast_type,l_ret_code,l_ret_msg);
                fnd_file.put_line(fnd_file.log,'DATA ARE VALID.FORECAST DATA INSERTED INTO DEMANTRA STAGING TABLE');
                
                send_upload_notifctn(l_ret_code,l_ret_msg,p_forecast_type,lv_dest_dir,p_file_name,l_email_id,l_user_name);
            ELSE
                fnd_file.put_line(fnd_file.log,'DATA FAILED VALIDATION');
                                   
                -- Updating the error column name with error_msg--
                
                l_dot_posn := INSTR(p_file_name,'.',1);
                lv_file_name_txt := SUBSTR(p_file_name,1,l_dot_posn-1)||'_ERR.csv';
                
                
                fnd_file.put_line(fnd_file.log,'Email id to send data: '||l_email_id);
                fnd_file.put_line(fnd_file.log,'Destination directory to pick file :'||lv_dest_dir);
                
                lv_filetype      := UTL_FILE.fopen (lv_dest_dir, lv_file_name_txt, 'w','32767');
                
                IF l_cust_dmd_count > 0
                THEN
                    --l_email_id := SUBSTR(p_file_name,17,6)||'@att.com';
                    
                    FOR i IN cust_dmd_data(ln_request_id_cust_frcst)
                    LOOP
                        lv_line_txt :=  i.ITEM_COL||','||i.REGION_COL||','||i.DATE1||','
                                      ||i.DATE2||','||i.DATE3||','||i.DATE4||','||i.DATE5||','||i.DATE6||','
                                      ||i.DATE7||','||i.DATE8||','||i.DATE9||','||i.DATE10||','
                                      ||i.DATE11||','||i.DATE12||',"'||i.NOTE||'",'||i.ERR;
                                     
                        UTL_FILE.put_line (lv_filetype, lv_line_txt);
                        lv_line_txt := NULL;
                    END LOOP;
                    
                    UTL_FILE.fclose (lv_filetype);
                ELSE
                    --l_email_id := SUBSTR(p_file_name,19,6)||'@att.com';
                    
                    FOR i IN prchs_frcst_hdr(ln_request_id_purchs_frcst)
                    LOOP
                        lv_line_txt :=  i.ITEM_COL||','||i.OEM_COL||','||i.OHB_DATE||','||i.BACKORDER_DATE||','||i.OPEN_PO_DATE||','||i.PAST_DUE_PO||','
                                      ||i.PUR_FCST_DATE1||','||i.PUR_FCST_DATE2||','||i.PUR_FCST_DATE3||','||i.PUR_FCST_DATE4||','||i.PUR_FCST_DATE5||','
                                      ||i.PUR_FCST_DATE6||','||i.PUR_FCST_DATE7||','||i.PUR_FCST_DATE8||','||i.PUR_FCST_DATE9||','||i.PUR_FCST_DATE10||','
                                      ||i.PUR_FCST_DATE11||','||i.PUR_FCST_DATE12||','||i.PUR_HIST_DATE1||','||i.PUR_HIST_DATE2||','||i.PUR_HIST_DATE3||','
                                      ||i.PH_AVG||',"'||i.PLANNER_COMMENTS||'",'||i.ERR;
                        
                                     
                        UTL_FILE.put_line (lv_filetype, lv_line_txt);
                        lv_line_txt := NULL;
                    
                    END LOOP;
                    
                    UTL_FILE.fclose (lv_filetype);
                END IF;

                begin
                    send_err_notification   ( l_ret_code,l_ret_msg,p_forecast_type,lv_dest_dir,p_file_name,lv_file_name_txt,l_email_id,'VLDTN_FAIL' );
                exception
                    when others then
                    fnd_file.put_line(fnd_file.log,'error sending mail: '||SQLERRM);
                end;
                
            END IF;
            
            
            
    EXCEPTION
            WHEN OTHERS THEN
            fnd_file.put_line(fnd_file.log,'Error occured: '||SQLERRM);

    end LOAD_FORECAST_DEMANTRA;


END CUST_LOAD_FORECAST_DEMANTRA;
/
/*<TOAD_FILE_CHUNK>*/

SHOW ERRORS PACKAGE BODY CUST_LOAD_FORECAST_DEMANTRA;

SET PAGESIZE 30
SET LINESIZE 180
SET FEEDBACK OFF
SET tab OFF

COL current_date FORMAT a19

SELECT TO_CHAR (SYSDATE, 'YYYY-MM-DD HH24:MI:SS') CURRENT_DATE FROM SYS.DUAL;

COL object_name FORMAT a29
COL object_type FORMAT a12

SELECT OBJECT_NAME,
       OBJECT_TYPE,
       TIMESTAMP,
       STATUS
  FROM DBA_OBJECTS
 WHERE     OBJECT_NAME = 'CUST_LOAD_FORECAST_DEMANTRA'
       AND OBJECT_TYPE LIKE 'PACKAGE%';

EXIT;
/

