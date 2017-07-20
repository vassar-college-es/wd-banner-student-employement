create or replace PROCEDURE       map_grp_positions_for_nextgen (
   p0            IN     VARCHAR2 DEFAULT NULL,
   p1            IN     VARCHAR2 DEFAULT NULL,
   p2            IN     VARCHAR2 DEFAULT NULL,
   p3            IN     VARCHAR2 DEFAULT NULL,
   p4            IN     VARCHAR2 DEFAULT NULL,
   p5            IN     VARCHAR2 DEFAULT NULL,
   p6            IN     VARCHAR2 DEFAULT NULL,
   p7            IN     VARCHAR2 DEFAULT NULL,
   REF_CUR_OUT      OUT SYS_REFCURSOR)
AS
   -- p0 : NA
   -- p1 : method
   -- p2 : title
   -- p3 : wd_posn
   -- p4 : available
   -- p5 : supervisory title
   -- p6 : hire freeze
   -- p7 : wd location
   -- ref_cur_out : out REF_CURSOR

   rtn_code_1          NUMBER := 200;                 -- success (new id/pidm)
   rtn_mess_1          VARCHAR2 (75) := 'position sync complete';
   rtn_action_1        VARCHAR2 (10) := '';

   rtn_code_2          NUMBER := 400;                                  -- fail
   rtn_mess_2          VARCHAR2 (75) := 'invalid request';
   rtn_action_2        VARCHAR2 (10) := '';

   rtn_code_3          NUMBER := 200;                -- success (valid lookup)
   rtn_mess_3          VARCHAR2 (75) := 'success';
   rtn_action_3        VARCHAR2 (10) := '';

   posn_detail_match   VARCHAR2 (1) := 'N';
   sup_org_found       VARCHAR2 (1) := 'N';

   dept_code_match     VARCHAR2 (10);
BEGIN

   DBMS_OUTPUT.PUT_LINE('p1:'|| p1);
   DBMS_OUTPUT.PUT_LINE('p2:'|| p2);
   DBMS_OUTPUT.PUT_LINE('p3:'|| p3);
   DBMS_OUTPUT.PUT_LINE('p4:'|| p4);
   DBMS_OUTPUT.PUT_LINE('p5:'|| p5);
   DBMS_OUTPUT.PUT_LINE('p6:'|| p6);
   DBMS_OUTPUT.PUT_LINE('P7:'|| p7);
    
   IF p1 = 'detection'
   THEN
      /* match supervisory org title to a JobX department code*/
      BEGIN
         SELECT deptid
           INTO dept_code_match
           FROM DAIES.JOBX_EMPLOYERS
          WHERE TRIM (p5) like TRIM (employername) || '%';
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            SELECT deptid
              INTO dept_code_match
              FROM DAIES.JOBX_EMPLOYERS
             WHERE TRIM (employername) = TRIM ('Student Financial Services');
      END;

      IF posn_detail_match = 'N'
      THEN
         /* match title and wd_posn and available == false [ freeze ] */
         BEGIN
            SELECT DISTINCT 'Y'
              INTO posn_detail_match
              FROM daies.wd_jx_posn_mgmt
             WHERE     TRIM (wd_posn_title) = TRIM (p2)
                   AND wd_posn = p3
                   AND p4 = 'false'
                   AND p6 = 'true'
                 ;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               posn_detail_match := 'N';
         END;

         IF posn_detail_match = 'Y'
         THEN
            rtn_action_1 := 'freeze';

            BEGIN
               UPDATE WD_JX_POSN_MGMT
                  SET AVAILABLE = 'N', act_date = SYSDATE
                WHERE WD_POSN = p3;
            END;

            COMMIT;

            BEGIN
               OPEN REF_CUR_OUT FOR
                  SELECT WD_POSN wd_position,
                         WD_POSN_TITLE wd_position_title,
                         available wd_position_available,
                         EMPLOYER_NAME wd_supervisory_title,
                         LOCATION wd_location,
                         dept_code_match dept_code,
                         sysdate wd_eff_date,
                         rtn_code_1 return_code,
                         rtn_mess_1 return_message,
                         rtn_action_1 return_action
                    FROM WD_JX_POSN_MGMT
                   WHERE WD_POSN = p3;
            END;
         END IF;
      END IF;


      IF posn_detail_match = 'N'
      THEN
         /* (match title and wd_posn and available (p4) == true ) [ REOPEN ] */
         BEGIN
            SELECT DISTINCT 'Y'
              INTO posn_detail_match
              FROM daies.wd_jx_posn_mgmt
             WHERE     TRIM (wd_posn_title) = TRIM (p2)
                   AND wd_posn = p3
                   AND p4 = 'true'
                   AND p6 = 'false'
                   AND available = 'N';
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               posn_detail_match := 'N';
         END;

         IF posn_detail_match = 'Y'
         THEN
            rtn_action_1 := 'reopen';

            BEGIN
               UPDATE WD_JX_POSN_MGMT
                  SET AVAILABLE = DECODE (p4, 'true', 'Y', 'N'),
                      WD_POSN_TITLE = p2,
                      act_date = SYSDATE
                WHERE WD_POSN = p3;
            END;

            COMMIT;

            BEGIN
               OPEN REF_CUR_OUT FOR
                  SELECT WD_POSN wd_position,
                         WD_POSN_TITLE wd_position_title,
                         available wd_position_available,
                         EMPLOYER_NAME wd_supervisory_title,
                         LOCATION wd_location,
                         dept_code_match dept_code,
                         sysdate wd_eff_date,
                         rtn_code_1 return_code,
                         rtn_mess_1 return_message,
                         rtn_action_1 return_action
                    FROM WD_JX_POSN_MGMT
                   WHERE WD_POSN = p3;
            END;
         END IF;
      END IF;
      
      
      
      IF posn_detail_match = 'N'
      THEN
         /* (match title and wd_posn and available (p4) == true ) [ FILL ] */
         BEGIN
            SELECT DISTINCT 'Y'
              INTO posn_detail_match
              FROM daies.wd_jx_posn_mgmt
             WHERE     TRIM (wd_posn_title) = TRIM (p2)
                   AND wd_posn = p3
                   AND p4 = 'false'
                   AND p6 = 'false'
                   AND available = 'Y';
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               posn_detail_match := 'N';
         END;

         IF posn_detail_match = 'Y'
         THEN
            rtn_action_1 := 'fill';

            BEGIN
               UPDATE WD_JX_POSN_MGMT
                  SET AVAILABLE = DECODE (p4, 'true', 'Y', 'N'),
                      WD_POSN_TITLE = p2,
                      act_date = SYSDATE
                WHERE WD_POSN = p3;
            END;

            COMMIT;

            BEGIN
               OPEN REF_CUR_OUT FOR
                  SELECT WD_POSN wd_position,
                         WD_POSN_TITLE wd_position_title,
                         available wd_position_available,
                         EMPLOYER_NAME wd_supervisory_title,
                         LOCATION wd_location,
                         dept_code_match dept_code,
                         sysdate wd_eff_date,
                         rtn_code_1 return_code,
                         rtn_mess_1 return_message,
                         rtn_action_1 return_action
                    FROM WD_JX_POSN_MGMT
                   WHERE WD_POSN = p3;
            END;
         END IF;
      END IF;


      IF posn_detail_match = 'N'
      THEN
         /*  match wd_posn and no match on title and available == true [ MODIFY ] */
         BEGIN
            SELECT DISTINCT 'Y'
              INTO posn_detail_match
              FROM daies.wd_jx_posn_mgmt
             WHERE   TRIM (wd_posn_title) != TRIM (p2) 
                   AND wd_posn = p3;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               posn_detail_match := 'N';
         END;

         IF posn_detail_match = 'Y'
         THEN
            rtn_action_1 := 'modify';

            BEGIN
               UPDATE WD_JX_POSN_MGMT
                  SET AVAILABLE = DECODE (p4, 'true', 'Y', 'N'),
                      WD_POSN_TITLE = p2,
                      act_date = SYSDATE
                WHERE WD_POSN = p3;
            END;

            COMMIT;

            BEGIN
               OPEN REF_CUR_OUT FOR
                  SELECT WD_POSN wd_position,
                         WD_POSN_TITLE wd_position_title,
                         available wd_position_available,
                         EMPLOYER_NAME wd_supervisory_title,
                         LOCATION wd_location,
                         dept_code_match dept_code,
                         sysdate wd_eff_date,
                         rtn_code_1 return_code,
                         rtn_mess_1 return_message,
                         rtn_action_1 return_action
                    FROM WD_JX_POSN_MGMT
                   WHERE WD_POSN = p3;
            END;
         END IF;
      END IF;

      IF posn_detail_match = 'N'
      THEN
         /* no match title and no match wd_posn and available == true [ add position ] */
         BEGIN
            SELECT DISTINCT 'N'
              INTO posn_detail_match
              FROM daies.wd_jx_posn_mgmt b
             WHERE  wd_posn = p3;
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               posn_detail_match := 'Y';
         END;

         IF posn_detail_match = 'Y'
         THEN
            rtn_action_1 := 'add';

            BEGIN
               INSERT INTO WD_JX_POSN_MGMT
                  (SELECT p3,
                          p2,
                          p5,
                          dept_code_match,
                          p7,
                          DECODE (p4, 'true', 'Y', 'N'),
                          SYSDATE
                     FROM DUAL);
            END;

            COMMIT;

            BEGIN
               OPEN REF_CUR_OUT FOR
                  SELECT WD_POSN wd_position,
                         WD_POSN_TITLE wd_position_title,
                         available wd_position_available,
                         EMPLOYER_NAME wd_supervisory_title,
                         LOCATION wd_location,
                         dept_code_match dept_code,
                         sysdate wd_eff_date,
                         rtn_code_1 return_code,
                         rtn_mess_1 return_message,
                         rtn_action_1 return_action
                    FROM WD_JX_POSN_MGMT
                   WHERE WD_POSN = p3;
            END;
         END IF;
      END IF;


      IF posn_detail_match = 'N'
      THEN
         rtn_action_2 := 'no action';

         BEGIN
            OPEN REF_CUR_OUT FOR
               SELECT p3 wd_position,
                      p2 wd_position_title,
                      p4 wd_position_available,
                      p5 wd_supervisory_title,
                      p7 wd_location,
                      dept_code_match dept_code,
                      sysdate wd_eff_date,
                         rtn_code_1 return_code,
                         rtn_mess_1 return_message,
                         rtn_action_2 return_action
                 FROM DUAL;
         END;
      END IF;
   END IF;

   /* ==================== */

   IF p1 = 'lookup'
   THEN
      BEGIN
         OPEN REF_CUR_OUT FOR
            SELECT WD_POSN wd_position,
                   WD_POSN_TITLE wd_position_title,
                   available wd_position_available,
                   EMPLOYER_NAME wd_supervisory_title,
                   LOCATION wd_location,
                   SYSDATE wd_eff_date,
                   dept_code_match dept_code,
                   sysdate wd_eff_date,
                   rtn_code_3 return_code,
                   rtn_mess_3 return_message,
                   rtn_action_3 return_action
              FROM WD_JX_POSN_MGMT
             WHERE WD_POSN = p3;
      EXCEPTION
         WHEN NO_DATA_FOUND
         THEN
            OPEN REF_CUR_OUT FOR
               SELECT '' wd_position,
                      '' wd_position_title,
                      '' wd_position_available,
                      '' wd_supervisory_id,
                      '' wd_supervisory_title,
                      '' wd_location,
                      '' dept_code_match,
                      sysdate wd_eff_date,
                      rtn_code_2 return_code,
                      rtn_mess_2 return_message,
                      rtn_action_2 return_action 
                 FROM DUAL;
      END;
   END IF;

   /* ==================== */



   IF p1 != 'detection' AND p1 != 'lookup'
   THEN
      BEGIN
         OPEN REF_CUR_OUT FOR
            SELECT '' wd_position,
                   '' wd_position_title,
                   '' wd_position_available,
                   '' wd_supervisory_organization,
                   '' wd_supervisory_id,
                   '' wd_supervisory_title,
                   '' dept_code_match,
                   '' wd_location,
                   sysdate wd_eff_date,
                   rtn_code_2 return_code,
                   rtn_mess_2 return_message,
                   rtn_action_2 return_action
              FROM DUAL;
      END;
   END IF;
END;