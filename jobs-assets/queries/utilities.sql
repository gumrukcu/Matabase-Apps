-- Utility names
-- Every tenant's id and name, from VPIE NEXTGEN CORE.
-- Metabase database: VPIE NEXTGEN CORE (id 35)
-- Filters: none (empty = no filter)

select id::text as id, name from tenant order by name;
