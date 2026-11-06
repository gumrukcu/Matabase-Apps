-- Jobs by stage
-- Count and share of jobs in the current view in each stage, plus the total.
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
), s as (select stage, count(*) as n from f group by 1)
select stage, n::int as n, round(n::numeric / nullif((select sum(n) from s), 0), 4)::float as share from s
union all select 'All', coalesce((select sum(n) from s), 0)::int, 1.0
order by n desc;
