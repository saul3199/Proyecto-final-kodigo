-- =====================================
-- Predictivo - ventas
-- =====================================

-- CONSULTA ORIGINAL 
-- ####################################################
WITH mensual AS (
    SELECT
        ROW_NUMBER() OVER (
            ORDER BY dt.anio, dt.mes
        ) AS anio_mes,
        dt.anio,
        dt.mes,
        dt.anio_mes::text AS periodo,
        SUM(fv.monto_total_item) AS ventas_reales
    FROM 
    	pf_dw.fact_ventas fv
    	INNER JOIN pf_dw.dim_tiempo dt ON fv.id_tiempo_dim = dt.id_tiempo_dim
    WHERE 
    	dt.anio = 2024
      	AND dt.mes BETWEEN 1 AND 10
    GROUP BY
        dt.anio,
        dt.mes,
        dt.anio_mes
),
stats AS (
    SELECT
        COUNT(*) AS n,
        SUM(anio_mes) AS sum_x,
        SUM(ventas_reales) AS sum_y,
        SUM(anio_mes * ventas_reales) AS sum_xy,
        SUM(anio_mes * anio_mes) AS sum_xx
    FROM mensual
),
factores AS (
    SELECT
        ((n * sum_xy - sum_x * sum_y)
         /
         NULLIF((n * sum_xx - sum_x * sum_x),0)
        ) AS pendiente,
        (sum_y -((n * sum_xy - sum_x * sum_y)
         /
         NULLIF((n * sum_xx - sum_x * sum_x),0)) * sum_x
        ) / n AS interseccion
    FROM stats
),
proyeccion AS (

    SELECT
        11 AS anio_mes,
        'P_2024-11'::text AS periodo,
        ROUND((pendiente * 11) + interseccion,2) AS ventas_proyectadas
    FROM factores
),
real AS (
    SELECT
        dt.anio_mes::text AS periodo,
        SUM(fv.monto_total_item) AS ventas_reales
    FROM pf_dw.fact_ventas fv
    INNER JOIN pf_dw.dim_tiempo dt
        ON fv.id_tiempo_dim = dt.id_tiempo_dim
    WHERE dt.anio = 2024
      AND dt.mes = 11
    GROUP BY
        dt.anio_mes
)
SELECT
    periodo,
    ventas_reales,
    NULL::numeric AS ventas_proyectadas
FROM mensual
UNION ALL
SELECT
    periodo,
    ventas_reales,
    NULL::numeric AS ventas_proyectadas
FROM real
UNION ALL
SELECT
    periodo,
    NULL::numeric AS ventas_reales,
    ventas_proyectadas
FROM proyeccion
ORDER BY 
	periodo;