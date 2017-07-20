create or replace PROCEDURE       get_stuaward_dataset (
   P0            IN     VARCHAR2 DEFAULT NULL,
   REF_CUR_OUT      OUT SYS_REFCURSOR)
AS
-- ref_cur_out : out REF_CURSOR

BEGIN
   OPEN REF_CUR_OUT FOR
      SELECT DISTINCT
             RTFILES.ID AS VASSAR_ID,
             GORADID.GORADID_ADDITIONAL_ID WORKDAY_EMPL_ID,
             (SELECT STVTERM_START_DATE
                FROM STVTERM
               WHERE     STVTERM_FA_PROC_YR =
                            (SELECT GTVSDAX_EXTERNAL_CODE AS AIDY_CODE
                               FROM GENERAL.GTVSDAX
                              WHERE     GTVSDAX_INTERNAL_CODE = 'AID_YEAR'
                                    AND GTVSDAX_INTERNAL_CODE_GROUP =
                                           'FIN AID YEAR')
                     AND STVTERM_CODE LIKE '%03')
                AS AWARD_PERIOD_START_DATE,
             (SELECT STVTERM_END_DATE
                FROM STVTERM
               WHERE     STVTERM_FA_PROC_YR =
                            (SELECT GTVSDAX_EXTERNAL_CODE AS AIDY_CODE
                               FROM GENERAL.GTVSDAX
                              WHERE     GTVSDAX_INTERNAL_CODE = 'AID_YEAR'
                                    AND GTVSDAX_INTERNAL_CODE_GROUP =
                                           'FIN AID YEAR')
                     AND STVTERM_CODE LIKE '%01')
                AS AWARD_PERIOD_END_DATE,
             DECODE (
                (SELECT DISTINCT RPRAWRD.RPRAWRD_FUND_CODE
                   FROM FAISMGR.RPRAWRD
                  WHERE     RPRAWRD_PIDM = RTFILES.PIDM
                        AND RPRAWRD_PIDM = SPERFL.PIDM
                        AND RPRAWRD_ACCEPT_AMT > 0
                        AND RPRAWRD_AIDY_CODE =
                               (SELECT GTVSDAX_EXTERNAL_CODE AS AIDY_CODE
                                  FROM GENERAL.GTVSDAX
                                 WHERE     GTVSDAX_INTERNAL_CODE = 'AID_YEAR'
                                       AND GTVSDAX_INTERNAL_CODE_GROUP =
                                              'FIN AID YEAR')
                        AND FAISMGR.RPRAWRD.RPRAWRD_FUND_CODE IN
                               ('CWS', 'ISEP')
                        AND FAISMGR.RPRAWRD.RPRAWRD_AWST_CODE IN ('A', 'B')),
                'CWS', 'CWS',
                'ISEP', 'ISEP',
                NULL, 'NONE',
                'NONE')
                AS AWARD_CATEGORY,
             (SELECT DISTINCT RPRAWRD_OFFER_AMT
                FROM FAISMGR.RPRAWRD
               WHERE     RPRAWRD_PIDM = RTFILES.PIDM
                     AND RPRAWRD_PIDM = SPERFL.PIDM
                     AND RPRAWRD_AIDY_CODE =
                            (SELECT GTVSDAX_EXTERNAL_CODE AS AIDY_CODE
                               FROM GENERAL.GTVSDAX
                              WHERE     GTVSDAX_INTERNAL_CODE = 'AID_YEAR'
                                    AND GTVSDAX_INTERNAL_CODE_GROUP =
                                           'FIN AID YEAR')
                     AND FAISMGR.RPRAWRD.RPRAWRD_FUND_CODE IN ('CWS', 'ISEP')
                     AND FAISMGR.RPRAWRD.RPRAWRD_AWST_CODE IN ('A', 'B'))
                AS AWARD_PERIOD_AMOUNT
        FROM BN.RTFILES, BN.SPERFL, GENERAL.GORADID
       WHERE     BN.RTFILES.STST_CODE IN ('AS',
                                          'EX',
                                          'JY',
                                          'JV')
             AND BN.SPERFL.PIDM = BN.RTFILES.PIDM
             AND BN.RTFILES.CUR_TERM = 'Y'
             AND BN.RTFILES.STYP_CODE NOT IN ('4', '6')
             AND BN.RTFILES.PIDM NOT IN
                    (SELECT DISTINCT H.PIDM
                       FROM PAYROLL.HRBIO H
                      WHERE H.EMPL_STATUS <> 'T' AND H.ECLS_CODE <> 'ST')
             AND GORADID.GORADID_PIDM(+) = RTFILES.PIDM
             AND GORADID_ADID_CODE(+) = 'WEID';
END;