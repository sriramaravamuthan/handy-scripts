WITH allR AS (
    SELECT id,
           driver_id,
           started,
           lead(started AT TIME ZONE 'UTC', 1, now()) OVER w AS ended
    FROM hos_ruleset where started > '2019-06-01 00:00:00' WINDOW w AS (PARTITION BY driver_id ORDER BY started)
), min_maxed AS (
    SELECT driver_id,
           min(started) AS started,
           max(ended) AS ended
    FROM allR
    --WHERE id IN () -- for ids
    --and ended < '2019-12-31 23:59:59'
    GROUP BY driver_id
), formatted AS (
    SELECT driver_id,
           date_trunc('week', started) AS started,
           date_trunc('week', ended + interval '1 week') AS ended
    FROM min_maxed
)
SELECT driver_id, started::date || 'T00:00:00', ended::date || 'T23:59:59'
FROM formatted
group by driver_id, started, ended

