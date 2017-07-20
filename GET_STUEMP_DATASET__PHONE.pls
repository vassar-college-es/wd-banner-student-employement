create or replace procedure get_stuemp_dataset__phone(p0 in varchar2 default null, ref_cur_out out SYS_REFCURSOR)
as
-- p0 : person Id
-- ref_cur_out : out REF_CURSOR

begin
open ref_cur_out FOR
select
'Primary' phone_type,
decode(p.sprtele_phone_number, null, null, substr('('||p.sprtele_phone_area||') ' || substr(p.sprtele_phone_number,1,3) || '-' || substr(p.sprtele_phone_number,4,5),1,14)) formatted_phone_number,
p.sprtele_phone_area phone_number_area,
substr(p.sprtele_phone_number,1,3) phone_number_prefix,
substr(p.sprtele_phone_number,4,4) phone_number_line,
to_char(p.sprtele_activity_date,'DD-MM-YYYY') activity_date
from saturn.sprtele p,  bn.rtfiles r
where r.pidm = p.sprtele_pidm(+)
and p.sprtele_tele_code(+) = 'PR' and p.sprtele_atyp_code(+) = 'PR'
and p.sprtele_status_ind(+) is null
and r.cur_term = 'Y'
and r.stst_code not in ('WD','GR','NS')
and r.id = p0
and rownum <= 1
UNION
select
'Cell' phone_type,
decode(c.sprtele_phone_number, null, null, substr('('||c.sprtele_phone_area||') ' || substr(c.sprtele_phone_number,1,3) || '-' || substr(c.sprtele_phone_number,4,5),1,14)) formatted_phone_number,
c.sprtele_phone_area phone_number_area,
substr(c.sprtele_phone_number,1,3) phone_number_prefix,
substr(c.sprtele_phone_number,4,4) phone_number_line,
to_char(c.sprtele_activity_date,'DD-MM-YYYY') activity_date
from saturn.sprtele c, saturn.sprtele p,  bn.rtfiles r
where r.pidm = c.sprtele_pidm(+)
and c.sprtele_tele_code(+) = 'CP'
and c.sprtele_status_ind(+) is null
and r.cur_term = 'Y'
and r.stst_code not in ('WD','GR','NS')
and r.id = p0
and rownum <= 1
order by 1;

end;