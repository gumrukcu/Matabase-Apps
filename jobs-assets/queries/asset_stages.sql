-- Assets by job status
-- Count and share of assets in the current view by job status, plus the total.
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
), s as (select status, count(*) as n from f group by 1)
select status, n::int as n, round(n::numeric / nullif((select sum(n) from s), 0), 4)::float as share from s
union all select 'All', coalesce((select sum(n) from s), 0)::int, 1.0
order by n desc;
