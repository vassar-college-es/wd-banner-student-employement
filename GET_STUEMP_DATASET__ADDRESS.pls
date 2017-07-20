create or replace procedure get_stuemp_dataset__address(p0 in varchar2 default null, ref_cur_out out SYS_REFCURSOR)
as
-- p0 : person Id
-- ref_cur_out : out REF_CURSOR

begin
open ref_cur_out FOR
select
'Parent 1' address_type,
h.SPRADDR_STREET_LINE1 street_line_1, h.SPRADDR_STREET_LINE2 street_line_2, h.SPRADDR_STREET_LINE3 street_line_3,
h.SPRADDR_STAT_CODE state, h.SPRADDR_CITY city, h.SPRADDR_ZIP zip_code, nvl(h.SPRADDR_NATN_CODE,'USA') country, to_char(h.spraddr_activity_date,'DD-MM-YYYY') activity_date
from spraddr h, bn.rtfiles r
where r.pidm = h.spraddr_pidm(+)
and h.spraddr_status_ind(+) is null
and h.spraddr_atyp_code(+) = 'P1'
and r.cur_term = 'Y'
and r.stst_code not in ('WD','GR','NS')
and r.id = p0
UNION
select
'Parent 2' address_type,
c.SPRADDR_STREET_LINE1 street_line_1, c.SPRADDR_STREET_LINE2 street_line_2, c.SPRADDR_STREET_LINE3 street_line_3,
c.SPRADDR_STAT_CODE state, c.SPRADDR_CITY city, c.SPRADDR_ZIP zip_code, nvl(c.SPRADDR_NATN_CODE,'USA') country, to_char(c.spraddr_activity_date,'DD-MM-YYYY')  activity_date
from spraddr c, bn.rtfiles r
where r.pidm = c.spraddr_pidm(+)
and c.spraddr_status_ind(+) is null
and c.spraddr_atyp_code(+) = 'P2'
and r.cur_term = 'Y'
and r.stst_code not in ('WD','GR','NS')
and r.id = p0
UNION
select
'Permanent' address_type,
c.SPRADDR_STREET_LINE1 street_line_1, c.SPRADDR_STREET_LINE2 street_line_2, c.SPRADDR_STREET_LINE3 street_line_3,
c.SPRADDR_STAT_CODE state, c.SPRADDR_CITY city, c.SPRADDR_ZIP zip_code, nvl(c.SPRADDR_NATN_CODE,'USA') country, to_char(c.spraddr_activity_date,'DD-MM-YYYY')  activity_date
from spraddr c, bn.rtfiles r
where r.pidm = c.spraddr_pidm(+)
and c.spraddr_status_ind(+) is null
and c.spraddr_atyp_code(+) = 'PR'
and r.cur_term = 'Y'
and r.stst_code not in ('WD','GR','NS')
and r.id = p0
UNION
select
'Campus' address_type,
c.SPRADDR_STREET_LINE1 street_line_1, c.SPRADDR_STREET_LINE2 street_line_2, c.SPRADDR_STREET_LINE3 street_line_3,
c.SPRADDR_STAT_CODE state, c.SPRADDR_CITY city, c.SPRADDR_ZIP zip_code, nvl(c.SPRADDR_NATN_CODE,'USA') country, to_char(c.spraddr_activity_date,'DD-MM-YYYY')  activity_date
from spraddr c, bn.rtfiles r
where r.pidm = c.spraddr_pidm(+)
and c.spraddr_status_ind(+) is null
and c.spraddr_atyp_code(+) = 'AC'
and r.cur_term = 'Y'
and r.stst_code not in ('WD','GR','NS')
and r.id = p0
order by 1;
end;