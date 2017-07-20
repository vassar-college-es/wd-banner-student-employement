create or replace procedure get_stuemp_dataset__email(p0 in varchar2 default null, ref_cur_out out SYS_REFCURSOR)
as
-- p0 : person Id
-- ref_cur_out : out REF_CURSOR

begin
open ref_cur_out FOR
select
'Personal' email_type, p.goremal_email_address email_address, decode(p.goremal_status_ind,'A','Active','I','Inactive') email_status, to_char(p.goremal_activity_date,'DD-MM-YYYY') activity_date
from general.goremal p,  bn.rtfiles r
where r.pidm = p.goremal_pidm(+)
and p.goremal_emal_code(+) = 'PERS' and p.goremal_status_ind(+) = 'A'
and r.cur_term = 'Y'
and r.stst_code not in ('WD','GR','NS')
and r.id = p0
and rownum <= 1
UNION
select
'Vassar' email_type, p.goremal_email_address email_address, decode(p.goremal_status_ind,'A','Active','I','Inactive') email_status, to_char(p.goremal_activity_date,'DD-MM-YYYY') activity_date
from general.goremal p,  bn.rtfiles r
where r.pidm = p.goremal_pidm(+)
and p.goremal_emal_code(+) = 'VASR' and p.goremal_status_ind(+) = 'A'
and r.cur_term = 'Y'
and r.stst_code not in ('WD','GR','NS')
and r.id = p0
and rownum <= 1
order by 1;

end;