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
        SUM(fv.cantidad) AS cantidad_real
    FROM 
    	pf_dw.fact_ventas fv
    	INNER JOIN pf_dw.dim_tiempo dt ON fv.id_tiempo_dim = dt.id_tiempo_dim
    WHERE dt.anio = 2024
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
        SUM(cantidad_real) AS sum_y,
        SUM(anio_mes * cantidad_real) AS sum_xy,
        SUM(anio_mes * anio_mes) AS sum_xx
    FROM mensual
),
factores AS (
    SELECT
        ((n * sum_xy - sum_x * sum_y)
         /
         NULLIF((n * sum_xx - sum_x * sum_x), 0)
        ) AS pendiente,
        (sum_y -((n * sum_xy - sum_x * sum_y)
          /
          NULLIF(
        (n * sum_xx - sum_x * sum_x),0)
        ) * sum_x
        ) / n AS interseccion
    FROM stats
),
proyeccion AS (
    SELECT
        11 AS anio_mes,
        'P_2024-11'::text AS periodo,
        ROUND((pendiente * 11) + interseccion, 0) AS cantidad_proyectada
    FROM factores
),
real AS (
    SELECT
        dt.anio_mes::text AS periodo,
        SUM(fv.cantidad) AS cantidad_real
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
    cantidad_real,
    NULL::numeric AS cantidad_proyectada
FROM mensual
UNION ALL
SELECT
    periodo,
    cantidad_real,
    NULL::numeric AS cantidad_proyectada
FROM real
UNION ALL
SELECT
    periodo,
    NULL::numeric AS cantidad_real,
    cantidad_proyectada
FROM proyeccion
ORDER BY periodo;