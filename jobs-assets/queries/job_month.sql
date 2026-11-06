-- Jobs created per month
-- Jobs in the current view created in each of the last 36 months, by stage.
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
)
select to_char(date_trunc('month', createdat), 'YYYY-MM') as month, stage, count(*)::int as n
from f
where createdat >= date_trunc('month', current_date) - interval '35 months'
group by 1, 2 order by 1, 2;
