# Jobs & Assets dashboard

A two-tab dashboard (Jobs, Assets) over Metabase data, built as a Claude Dashboard artifact.

## What it shows

- **Headline and tiles:** total jobs and assets in the current view, broken down by stage (Completed, Not scheduled, Open, Incomplete, Cancelled) and by asset job status (Closed, Open, No jobs).
- **Breakdown chart:** stacked bars by work order type, substatus, incomplete reason, validation status or year created (for assets: state, city, asset type or year). Shows the top 12 groups, with the rest grouped as Other. Toggle between count and share.
- **Click to drill in:** clicking a bar filters the whole tab to that group and moves the breakdown to the next dimension. A breadcrumb bar shows the path.
- **Monthly trend:** items created in each of the last 36 months, stacked by current stage.
- **Record table:** the 100 most recent matching jobs or assets.
- **Utility filter:** limits everything to one tenant.

## Files

| Path | What it is |
|---|---|
| `page.html` | Layout, styles and chart code (D3) |
| `queries/*.sql` | The 10 SQL queries the page runs, one per data source |

## How it runs

`page.html` is not a standalone web page. It runs inside the Claude Dashboard artifact runtime, which provides:

- `dash.data(name)`: the result of the query with that name (`queries/<name>.sql`)
- `dash.draw`, `dash.loader`, `dash.calc`: hooks for rendering, parsing query results and derived data
- `dash.params()` / `dash.setParams()`: the filters, substituted into the SQL as `{{utility}}`, `{{j_wot}}`, `{{a_state}}` and so on
- `d3`, the theme CSS variables (`--cds-*`, `--color-*`) and the chart colors

All queries except `utilities.sql` run against the **VPIE NEXTGEN BUSINESS** database in Metabase. `utilities.sql` runs against **VPIE NEXTGEN CORE**. An empty filter value means no filter.

To run it outside Claude, replace the `dash.*` calls with your own data layer, for example a small backend that runs these queries through the Metabase API, and load D3 yourself.
