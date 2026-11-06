-- Job breakdowns
-- Jobs in the current view by stage within work order type, substatus, incomplete reason, validation status and year created.
-- Metabase database: VPIE NEXTGEN BUSINESS (id 34)
-- Filters: {{utility}}, {{j_wot}}, {{j_sub}}, {{j_reason}}, {{j_val}}, {{j_yr}} (empty = no filter)

with j as (
  select j.id, j.createdat, j.jobend, j.jobstatus,
         case when j.jobstatus in ('Scheduled','Assigned','EnRoute','InProgress','Paused') then 'Open'
              when j.jobstatus = 'NotScheduled' then 'Not scheduled'
              else j.jobstatus end as stage,
         coalesce(nullif(w.name, ''), '(none)') as wot,
         coalesce(nullif(j.substatus, ''), '(none)') as sub,
         coalesce(nullif(j.incompletereason, ''), '(none)') as reason,
         coalesce(nullif(j.validationstatus, ''), '(none)') as val,
         to_char(j.createdat, 'YYYY') as yr
  from job j left join workordertypeinfo w on w.id = j.workordertypeid
  where ('{{utility}}' = '' or j.tenantid = nullif('{{utility}}', '')::uuid)
), f as (
  select * from j
  where ('{{j_wot}}' = '' or wot = '{{j_wot}}')
    and ('{{j_sub}}' = '' or sub = '{{j_sub}}')
    and ('{{j_reason}}' = '' or reason = '{{j_reason}}')
    and ('{{j_val}}' = '' or val = '{{j_val}}')
    and ('{{j_yr}}' = '' or yr = '{{j_yr}}')
), g as (
  select 'Work order type' as dim, wot as label, stage, count(*) as n from f group by 2, 3
  union all select 'Substatus', sub, stage, count(*) from f group by 2, 3
  union all select 'Incomplete reason', reason, stage, count(*) from f where reason <> '(none)' group by 2, 3
  union all select 'Validation status', val, stage, count(*) from f group by 2, 3
  union all select 'Year created', yr, stage, count(*) from f group by 2, 3
), t as (
  select dim, label, row_number() over (partition by dim order by sum(n) desc, label) as rk from g group by dim, label
)
select g.dim, case when t.rk <= 12 or g.dim = 'Year created' then g.label else 'Other' end as label, g.stage, sum(g.n)::int as n
from g join t on t.dim = g.dim and t.label = g.label
group by 1, 2, 3 order by 1, 4 desc;
