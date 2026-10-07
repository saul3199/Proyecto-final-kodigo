-- =====================================
-- Ingresos por  trimestres
-- =====================================

-- CONSULTA ORIGINAL 
-- ####################################################
SELECT
    DATE_TRUNC('quarter', dt.fecha_orden) AS trimestre,
    SUM(fv.monto_total_item) AS ingresos
FROM 
	pf_dw.fact_ventas fv
	INNER JOIN pf_dw.dim_tiempo dt ON fv.id_tiempo_dim = dt.id_tiempo_dim
INNER JOIN pf_dw.dim_productos dp ON fv.id_producto_dim = dp.id_producto_dim
WHERE
    dt.fecha_orden >= DATE_TRUNC(
        'quarter',
        CURRENT_DATE - INTERVAL '36 months'
    )
    AND dt.fecha_orden < DATE_TRUNC(
        'quarter',
        CURRENT_DATE + INTERVAL '3 months'
    )
GROUP BY
    DATE_TRUNC('quarter', dt.fecha_orden)
ORDER BY
    trimestre ASC;

-- CONSULTA ORIGINAL - EXPLAIN ANALYZE
-- ####################################################
EXPLAIN ANALYZE
SELECT
    DATE_TRUNC('quarter', dt.fecha_orden) AS trimestre,
    SUM(fv.monto_total_item) AS ingresos
FROM 
	pf_dw.fact_ventas fv
	INNER JOIN pf_dw.dim_tiempo dt ON fv.id_tiempo_dim = dt.id_tiempo_dim
INNER JOIN pf_dw.dim_productos dp ON fv.id_producto_dim = dp.id_producto_dim
WHERE
    dt.fecha_orden >= DATE_TRUNC(
        'quarter',
        CURRENT_DATE - INTERVAL '36 months'
    )
    AND dt.fecha_orden < DATE_TRUNC(
        'quarter',
        CURRENT_DATE + INTERVAL '3 months'
    )
GROUP BY
    DATE_TRUNC('quarter', dt.fecha_orden)
ORDER BY
    trimestre ASC;

-- Planning Time: 0.371 ms
-- Execution Time: 20.198 ms


-- VISTA MATERIALIZADA - CREAR
-- ####################################################
-- DROP MATERIALIZED VIEW IF EXISTS pf_dw.mv_kpis_ingresos_trimestre;
CREATE MATERIALIZED VIEW pf_dw.mv_kpis_ingresos_trimestre as
SELECT
    DATE_TRUNC('quarter', dt.fecha_orden) AS trimestre,
    SUM(fv.monto_total_item) AS ingresos
FROM 
	pf_dw.fact_ventas fv
	INNER JOIN pf_dw.dim_tiempo dt ON fv.id_tiempo_dim = dt.id_tiempo_dim
INNER JOIN pf_dw.dim_productos dp ON fv.id_producto_dim = dp.id_producto_dim
WHERE
    dt.fecha_orden >= DATE_TRUNC(
        'quarter',
        CURRENT_DATE - INTERVAL '36 months'
    )
    AND dt.fecha_orden < DATE_TRUNC(
        'quarter',
        CURRENT_DATE + INTERVAL '3 months'
    )
GROUP BY
    DATE_TRUNC('quarter', dt.fecha_orden)
ORDER BY
    trimestre ASC;


-- VISTA MATERIALIZADA - EXPLAIN ANALYZE
-- ####################################################
EXPLAIN ANALYZE
SELECT
    trimestre,
    ingresos
FROM pf_dw.mv_kpis_ingresos_trimestre;
-- Planning Time: 1.694 ms
-- Execution Time: 0.015 ms

-- VISTA MATERIALIZADA - INDICE
-- ####################################################
-- DROP INDEX IF EXISTS pf_dw.idx_mv_kpis_ingresos_trimestre;
CREATE UNIQUE INDEX ux_mv_kpis_ingresos_trimestre
ON pf_dw.mv_kpis_ingresos_trimestre (trimestre);


-- VISTA MATERIALIZADA - INDEX UNICO - EXPLAIN ANALYZE 
-- ####################################################
EXPLAIN ANALYZE
SELECT
    trimestre,
    ingresos
FROM pf_dw.mv_kpis_ingresos_trimestre;
-- Planning Time: 4.722 ms
-- Execution Time: 0.029 ms

-- actualiza los datos de tu vista materializada usando nuevamente la consulta con la que fue creada.
-- ####################################################
REFRESH MATERIALIZED VIEW CONCURRENTLY 
pf_dw.mv_kpis_ingresos_trimestrales;