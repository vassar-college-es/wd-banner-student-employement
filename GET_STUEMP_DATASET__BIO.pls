create or replace procedure get_stuemp_dataset__bio(p0 in varchar2 default null, ref_cur_out out SYS_REFCURSOR)
as
-- p0 : person Id
-- ref_cur_out : out REF_CURSOR

begin
open ref_cur_out FOR
select a.SPRIDEN_FIRST_NAME first_name, a.spriden_last_name last_name, a.spriden_mi middle_name,
to_char(b.spbpers_birth_date,'MM/DD/YYYY') birth_date, b.spbpers_ssn ssn, b.spbpers_ethn_code ethnicity, b.spbpers_mrtl_code marital_status, b.spbpers_sex gender, b.spbpers_dead_ind deceased_indicator,
b.spbpers_citz_ind citiizenship_status,
to_char(a.spriden_activity_date,'DD-MM-YYYY') identification_activity_date, 
to_char(b.spbpers_activity_date,'DD-MM-YYYY') bio_activity_date
from spriden a, spbpers b, bn.rtfiles r
where r.pidm = a.spriden_pidm
and a.spriden_change_ind is null
and r.pidm = spbpers_pidm
and r.cur_term = 'Y'
and r.stst_code not in ('WD','GR','NS')
and r.id = p0
order by 1;

end;