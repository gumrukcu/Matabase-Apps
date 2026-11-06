-- Assets created per month
-- Assets in the current view created in each of the last 36 months, by job status.
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
)
select to_char(date_trunc('month', createdat), 'YYYY-MM') as month, status, count(*)::int as n
from f
where createdat >= date_trunc('month', current_date) - interval '35 months'
group by 1, 2 order by 1, 2;
