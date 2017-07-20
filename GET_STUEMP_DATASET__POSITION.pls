create or replace procedure get_stuemp_dataset__position(p0 in varchar2 default null, ref_cur_out out SYS_REFCURSOR)
as
-- p0 : person Id
-- ref_cur_out : out REF_CURSOR

begin
open ref_cur_out FOR
select a.JOB_TYPE position_type, a.POSN job_position
from bn.rtfiles r, payroll.TEST_JOBX_HIRE_IMPORT a
where r.id = a.STUID
and r.cur_term = 'Y'
and r.stst_code not in ('WD','GR','NS')
and r.id = p0
order by 2
;

end;