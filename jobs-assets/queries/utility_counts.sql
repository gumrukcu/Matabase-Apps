-- Jobs and assets per utility
-- Job and asset counts for each tenant id.
-- Metabase database: VPIE NEXTGEN BUSINESS (id 34)
-- Filters: none (empty = no filter)

select tenantid::text as tenantid, sum(jobs)::int as jobs, sum(assets)::int as assets
from (
  select tenantid, count(*) as jobs, 0 as assets from job group by 1
  union all
  select tenantid, 0, count(*) from asset group by 1
) x
group by 1 order by 2 desc;
