create or replace PROCEDURE POST_WID (p0 in VARCHAR2 DEFAULT NULL, p1 in varchar2 default null, p2 in varchar2 default null, REF_CUR_OUT OUT SYS_REFCURSOR)
AS
-- p0 : student worker vassar email
-- p1 : WD applicant id
-- p2:  WD empl_id
-- ref_cur_out : out REF_CURSOR

student_pidm bn.rtfiles.pidm%TYPE := '';
student_id bn.rtfiles.id%TYPE := '';

BEGIN

begin
select distinct pidm, id INTO student_pidm, student_id
from bn.rtfiles
where email = p0 and cur_term = 'Y'
;
exception when no_data_found then
   student_pidm := '';
end;

if student_pidm is not null then
    if p1 is not null then
    -- create goradid entry WAID
    begin
    insert into goradid(goradid_pidm, goradid_additional_id, goradid_adid_code, goradid_user_id, goradid_activity_date, goradid_data_origin)
    values
    (student_pidm, p1, 'WAID', 'WD_APP_ID', sysdate, 'WORKDAY')
    ;
    end;

    OPEN REF_CUR_OUT FOR select 'success' req_state, 'WD Applicant ID created in Banner' req_message, p0 || '@vassar.edu' student_email_address, student_pidm student_pidm, student_id student_id, p1 student_wd_app_id from dual;
    end if;
    
    if p2 is not null then
    -- create goradid entry WEID
    begin
    insert into goradid(goradid_pidm, goradid_additional_id, goradid_adid_code, goradid_user_id, goradid_activity_date, goradid_data_origin)
    values
    (student_pidm, p2, 'WEID', 'WD_EMPL_ID', sysdate, 'WORKDAY')
    ;
    end;

    OPEN REF_CUR_OUT FOR select 'success' req_state, 'WD Employee ID created in Banner' req_message, p0 || '@vassar.edu' student_email_address, student_pidm student_pidm, student_id student_id, p2 student_wd_empl_id  from dual;
    end if;
    
    
else
    OPEN REF_CUR_OUT FOR select 'invalid' req_state, '' student_email_address, student_pidm student_pidm from dual;
    
end if;

END;