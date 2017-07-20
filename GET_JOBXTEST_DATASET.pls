create or replace PROCEDURE GET_JOBXTEST_DATASET (p0 in VARCHAR2 DEFAULT NULL,  p1 in varchar2 default null, p2 in varchar2 default null, REF_CUR_OUT OUT SYS_REFCURSOR)
AS
-- p0 : NA
-- p1 : id
-- p2 : posn
-- ref_cur_out : out REF_CURSOR

v_sql_prnt1    varchar2(32000);
v_sql_sub1     varchar2(32000);


BEGIN
v_sql_sub1 := 
'
select distinct a.stuid student_id, b.FIRST_NAME student_first_name, b.LAST_NAME student_last_name, 
d.spbpers_legal_name student_legal_name, trim(b.EMAIL)||''@vassar.edu'' vassar_email, app.goradid_additional_id workday_applicant_id, emp.goradid_additional_id workday_employee_id, 
nvl(c.SPRADDR_NATN_CODE,''USA'') student_nation,
a.posn hire_position_number,
to_char(to_date(a.HIRE_START_DATE,''MM-DD-YYYY''),''YYYY-MM-DD'') hire_start_date, to_char(to_date(a.HIRE_END_DATE,''MM-DD-YYYY''),''YYYY-MM-DD'') hire_end_date, a.hire_wage 
from payroll.JOBX_HIRE_IMPORT a, spraddr c, bn.rtfiles b, spbpers d, GORADID app, GORADID emp
where 
hire_start_date = 
(
select min(z.hire_start_date) from payroll.jobx_hire_import z
where z.stuid = a.stuid
)
and
posn = 
(
select min(z.posn) from payroll.jobx_hire_import z
where z.stuid = a.stuid and a.hire_start_date = z.hire_start_date
)
and b.pidm = c.spraddr_pidm
and b.pidm = d.spbpers_pidm
and b.pidm = emp.goradid_pidm(+)
and emp.goradid_adid_code(+) = ''WEID''
and b.pidm = app.goradid_pidm(+)
and app.goradid_adid_code(+) = ''WAID''
and a.stuid = b.ID and b.CUR_TERM = ''Y''
and c.spraddr_atyp_code = ''PR''
and c.spraddr_status_ind is null
and a.POSN is not null and a.STUID is not null
';

v_sql_prnt1 := 
'
select distinct y.student_id, y.student_first_name, y.student_last_name, y.student_legal_name, y.vassar_email, y.workday_applicant_id, y.workday_employee_id, 
y.student_nation, y.hire_position_number hire_position_number, y.hire_start_date, y.hire_end_date, y.hire_wage
from
( ' ||
v_sql_sub1 || '
) y';


if p1 is not null and p2 is not null then
    v_sql_sub1 := v_sql_sub1 || ' and a.stuid = ''' || p1 || ''' and a.posn = ''' || p2 || '''';
end if;


OPEN REF_CUR_OUT FOR v_sql_prnt1
;
END;