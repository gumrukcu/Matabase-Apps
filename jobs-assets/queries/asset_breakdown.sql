-- Asset breakdowns
-- Assets in the current view by job status within state, city, asset type and year created.
-- Metabase database: VPIE NEXTGEN BUSINESS (id 34)
-- Filters: {{utility}}, {{a_state}}, {{a_city}}, {{a_type}}, {{a_yr}} (empty = no filter)

with a as (
  select a.id, a.createdat, a.code,
         case a.assetstatus when 'OpenJobs' then 'Open jobs' when 'ClosedJobs' then 'Closed jobs' when 'NoJobs' then 'No jobs' else coalesce(a.assetstatus, '(none)') end as status,
         coalesce(nullif(upper(trim(a.state)), ''), '(none)') as state,
         coalesce(nullif(initcap(lower(trim(a.city))), ''), '(none)') as city,
         coalesce(nullif(t.name, ''), '(none)') as atype,
         to_char(a.createdat, 'YYYY') as yr
  from asset a left join assettypeinfo t on t.id = a.assettypeid
  where ('{{utility}}' = '' or a.tenantid = nullif('{{utility}}', '')::uuid)
), f as (
  select * from a
  where ('{{a_state}}' = '' or state = '{{a_state}}')
    and ('{{a_city}}' = '' or city = '{{a_city}}')
    and ('{{a_type}}' = '' or atype = '{{a_type}}')
    and ('{{a_yr}}' = '' or yr = '{{a_yr}}')
), g as (
  select 'State' as dim, state as label, status, count(*) as n from f group by 2, 3
  union all select 'City', city, status, count(*) from f group by 2, 3
  union all select 'Asset type', atype, status, count(*) from f group by 2, 3
  union all select 'Year created', yr, status, count(*) from f group by 2, 3
), t as (
  select dim, label, row_number() over (partition by dim order by sum(n) desc, label) as rk from g group by dim, label
)
select g.dim, case when t.rk <= 12 or g.dim = 'Year created' then g.label else 'Other' end as label, g.status, sum(g.n)::int as n
from g join t on t.dim = g.dim and t.label = g.label
group by 1, 2, 3 order by 1, 4 desc;
