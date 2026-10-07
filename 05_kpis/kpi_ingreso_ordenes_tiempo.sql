-- =====================================
-- Ingresos y ordenes a lo largo del tiempo
-- =====================================

-- CONSULTA ORIGINAL 
-- ####################################################
SELECT
    DATE_TRUNC('quarter', dt.fecha_orden) AS trimestre,
    SUM(fv.monto_total_item) AS ingresos,
    SUM(fv.cantidad) AS cantidad_productos,
    COUNT(DISTINCT fv.order_id) AS total_ordenes
FROM 
	pf_dw.fact_ventas fv
	INNER JOIN pf_dw.dim_tiempo dt ON fv.id_tiempo_dim = dt.id_tiempo_dim
GROUP BY
    DATE_TRUNC('quarter', dt.fecha_orden)
ORDER BY
    trimestre;

-- CONSULTA ORIGINAL - EXPLAIN ANALYZE
-- ####################################################
EXPLAIN ANALYZE
SELECT
    DATE_TRUNC('quarter', dt.fecha_orden) AS trimestre,
    SUM(fv.monto_total_item) AS ingresos,
    SUM(fv.cantidad) AS cantidad_productos,
    COUNT(DISTINCT fv.order_id) AS total_ordenes
FROM 
	pf_dw.fact_ventas fv
	INNER JOIN pf_dw.dim_tiempo dt ON fv.id_tiempo_dim = dt.id_tiempo_dim
GROUP BY
    DATE_TRUNC('quarter', dt.fecha_orden)
ORDER BY
    trimestre;
-- Planning Time: 0.656 ms
-- Execution Time: 38.157 ms

-- VISTA MATERIALIZADA - CREAR
-- ####################################################
-- DROP MATERIALIZED VIEW IF EXISTS pf_dw.mv_kpis_tiempo_ingresos_ordenes;
CREATE MATERIALIZED VIEW pf_dw.mv_kpis_tiempo_ingresos_ordenes as
SELECT
    DATE_TRUNC('quarter', dt.fecha_orden) AS trimestre,
    SUM(fv.monto_total_item) AS ingresos,
    SUM(fv.cantidad) AS cantidad_productos,
    COUNT(DISTINCT fv.order_id) AS total_ordenes
FROM 
	pf_dw.fact_ventas fv
	INNER JOIN pf_dw.dim_tiempo dt ON fv.id_tiempo_dim = dt.id_tiempo_dim
GROUP BY
    DATE_TRUNC('quarter', dt.fecha_orden)
ORDER BY
    trimestre;


-- VISTA MATERIALIZADA - EXPLAIN ANALYZE
-- ####################################################
EXPLAIN ANALYZE
SELECT
    trimestre,
    ingresos,
    cantidad_productos,
    total_ordenes
FROM pf_dw.mv_kpis_tiempo_ingresos_ordenes;
-- Planning Time: 0.032 ms
-- Execution Time: 0.020 ms


-- VISTA MATERIALIZADA - INDICE
-- ####################################################
-- DROP INDEX IF EXISTS pf_dw.idx_mv_kpis_ingresos_trimestre;
CREATE UNIQUE INDEX ux_mv_kpis_tiempo_ingresos_ordenes
ON pf_dw.mv_kpis_tiempo_ingresos_ordenes(trimestre);


-- VISTA MATERIALIZADA - INDEX UNICO - EXPLAIN ANALYZE 
-- ####################################################
EXPLAIN ANALYZE
SELECT
    trimestre,
    ingresos,
    cantidad_productos,
    total_ordenes
FROM pf_dw.mv_kpis_tiempo_ingresos_ordenes;
-- Planning Time: 2.493 ms
-- Execution Time: 0.027 ms

-- actualiza los datos de tu vista materializada usando nuevamente 
-- la consulta con la que fue creada.
-- ####################################################
REFRESH MATERIALIZED VIEW CONCURRENTLY 
pf_dw.mv_kpis_tiempo_ingresos_ordenes;