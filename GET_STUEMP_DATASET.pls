create or replace procedure get_stuemp_dataset(p0 in varchar2 default null, p1 in varchar2 default null, p2 in boolean default true, ref_cur_out out SYS_REFCURSOR)
as
-- p0 : person Id
-- p1 : query limiter ( value: [prehire] )
-- p2 : query filter (ie - ?ready_for_hire=true
-- ref_cur_out : out REF_CURSOR

v_sql varchar2(32000);

v_sql_prnt1               varchar2(32000);
v_sql_sub1                varchar2(32000);


begin

v_sql_sub1 :=
'
SELECT r.id student_id, r.email || ''@vassar.edu'' student_vassar_email, emp.GORADID_ADDITIONAL_ID workday_empl_id, app.GORADID_ADDITIONAL_ID workday_applicant_id, a.POSN, a.HIRE_START_DATE, a.HIRE_END_DATE,
b.spbpers_ssn student_ssn, to_char(b.spbpers_birth_date,''YYYY-MM-DD'') student_birth_date, '''' student_emergency_contact,
b.spbpers_ethn_code student_ethinicity, b.spbpers_sex student_gender, b.spbpers_citz_code student_usa_citizenship, a.hire_wage 
FROM bn.rtfiles r, spbpers b, general.goradid app, general.goradid emp,  payroll.JOBX_HIRE_IMPORT a
WHERE r.pidm = app.goradid_pidm and r.pidm = emp.goradid_pidm(+) and r.id = a.stuid(+)
and a.hire_start_date = 
(
select min(z.hire_start_date) from payroll.jobx_hire_import z
where z.stuid = a.stuid
)
and app.goradid_adid_code = ''WAID'' and emp.goradid_adid_code(+) = ''WEID''
and r.pidm = b.spbpers_pidm
and r.cur_term = ''Y''
and app.goradid_additional_id is not null and emp.goradid_additional_id is null and a.stuid is not null
';


v_sql_prnt1 := 
'
select y.student_id, y.student_vassar_email, y.workday_empl_id, y.workday_applicant_id, min(y.posn) posn, y.hire_start_date, y.hire_end_date, y.student_ssn, y.student_birth_date, y.student_emergency_contact, y.student_ethinicity, y.student_gender, y.student_usa_citizenship, y.hire_wage
from
( ' || v_sql_sub1 || 
') y
group by
y.student_id, y.student_vassar_email, y.workday_empl_id, y.workday_applicant_id, y.hire_start_date, y.hire_end_date, y.student_ssn, y.student_birth_date, y.student_emergency_contact, y.student_ethinicity, y.student_gender, y.student_usa_citizenship, y.hire_wage
'
;

/* ***************************************************** */
/*v_sql := 
'SELECT r.id student_id, r.email || ''@vassar.edu'' student_vassar_email, emp.GORADID_ADDITIONAL_ID workday_empl_id, app.GORADID_ADDITIONAL_ID workday_applicant_id, a.POSN, a.HIRE_START_DATE, a.HIRE_END_DATE,
b.spbpers_ssn student_ssn, to_char(b.spbpers_birth_date,''YYYY-MM-DD'') student_birth_date, '''' student_emergency_contact,
b.spbpers_ethn_code student_ethinicity, b.spbpers_sex student_gender, b.spbpers_citz_code student_usa_citizenship 
FROM bn.rtfiles r, spbpers b, general.goradid app, general.goradid emp,  payroll.JOBX_HIRE_IMPORT a
WHERE r.pidm = app.goradid_pidm and r.pidm = emp.goradid_pidm(+) and r.id = a.stuid(+)
and app.goradid_adid_code = ''WAID'' and emp.goradid_adid_code(+) = ''WEID''
and r.pidm = b.spbpers_pidm
and r.cur_term = ''Y''
';
*/

if (p1 = 'prehire' and p2 = false) then
v_sql_sub1 := v_sql_sub1 || ' and app.goradid_additional_id is not null and emp.goradid_additional_id is null'; 
end if;

if (p1 = 'prehire' and p2 = true) then
v_sql_sub1 := v_sql_sub1 || ' and app.goradid_additional_id is not null and emp.goradid_additional_id is null and a.stuid is not null'; 
end if;


open ref_cur_out FOR v_sql_prnt1;  
end;