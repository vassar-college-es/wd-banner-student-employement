create or replace procedure get_stuemp_changes(p0 in varchar2 default null, p1 in varchar2 default null, ref_cur_out out SYS_REFCURSOR)
as
-- p0 : person Id
-- p1 : change type
-- ref_cur_out : out REF_CURSOR

begin

if (p1 = 'address') then

open ref_cur_out FOR
select
r.id student_id,
g.GORADID_ADDITIONAL_ID workday_empl_id
from spraddr h, spraddr c, spraddr p, bn.rtfiles r, goradid g
where r.pidm = h.spraddr_pidm(+) and r.pidm = g.GORADID_PIDM
and h.spraddr_status_ind(+) is null
and h.spraddr_atyp_code(+) = 'P1'
and r.pidm = c.spraddr_pidm(+)
and c.spraddr_status_ind(+) is null
and c.spraddr_atyp_code(+) = 'P2'
and r.pidm = p.spraddr_pidm(+)
and p.spraddr_status_ind(+) is null
and p.spraddr_atyp_code(+) = 'PR'
and r.cur_term = 'Y'
and g.GORADID_PIDM(+) is not null
and g.GORADID_ADID_CODE = 'WEID'
and r.stst_code not in ('WD','GR','NS')
and (h.spraddr_activity_date >= sysdate-7 or c.SPRADDR_ACTIVITY_DATE >= sysdate-7 or p.SPRADDR_ACTIVITY_DATE >= sysdate-7)
order by 1;

end if;

/* ***************************************************** */
if (p1 = 'phone') then

open ref_cur_out FOR
select
r.id student_id,
g.GORADID_ADDITIONAL_ID workday_empl_id
from saturn.sprtele c, saturn.sprtele p,  bn.rtfiles r, goradid g
where r.pidm = p.sprtele_pidm(+) and r.pidm = g.GORADID_PIDM
and p.sprtele_tele_code(+) = 'PR'
and p.sprtele_status_ind(+) is null
and r.pidm = c.sprtele_pidm(+)
and c.sprtele_tele_code(+) = 'CP'
and c.sprtele_status_ind(+) is null
and r.cur_term = 'Y'
and g.GORADID_PIDM(+) is not null
and g.GORADID_ADID_CODE = 'WEID'
and r.stst_code not in ('WD','GR','NS')
and (p.sprtele_activity_date >= sysdate-7 or c.SPRTELE_ACTIVITY_DATE >= sysdate-7)
order by 1;

end if;

/* ***************************************************** */
if (p1 = 'email') then

open ref_cur_out FOR
select
r.id student_id,
g.GORADID_ADDITIONAL_ID workday_empl_id
from goremal c, goremal p,  bn.rtfiles r, goradid g
where r.pidm = p.goremal_pidm(+) and r.pidm = g.GORADID_PIDM
and p.goremal_emal_code(+) = 'PERS'
and p.GOREMAL_STATUS_IND = 'A'
and r.pidm = c.goremal_pidm(+)
and c.goremal_emal_code(+) = 'VASR'
and c.GOREMAL_STATUS_IND = 'A'
and r.cur_term = 'Y'
and g.GORADID_PIDM(+) is not null
and g.GORADID_ADID_CODE = 'WEID'
and r.stst_code not in ('WD','GR','NS')
and (p.goremal_activity_date >= sysdate-7 or c.GOREMAL_ACTIVITY_DATE >= sysdate-7)
order by 1;

end if;

/* ***************************************************** */
if (p1 = 'bio') then

open ref_cur_out FOR
select distinct
r.id student_id,
g.GORADID_ADDITIONAL_ID workday_empl_id
from spbpers c, spriden p,  bn.rtfiles r, goradid g
where r.pidm = p.spriden_pidm 
and r.pidm = g.GORADID_PIDM(+)
and r.pidm = c.spbpers_pidm
and p.spriden_change_ind is null
and r.cur_term = 'Y'
and g.GORADID_PIDM(+) is not null
and g.GORADID_ADID_CODE = 'WEID'
and r.stst_code not in ('WD','GR','NS')
and (p.spriden_activity_date >= sysdate-7 or c.SPBPERS_ACTIVITY_DATE >= sysdate-7)
order by 1;

end if;

  
end;