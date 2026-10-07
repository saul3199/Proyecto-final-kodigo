-- =====================================
-- Ingresos por categoría de producto
-- =====================================

-- CONSULTA ORIGINAL 
-- ####################################################
SELECT
    DATE_TRUNC('month', dt.fecha_orden) AS fecha,
    dp.categoria,
    SUM(fv.monto_total_item) AS ingresos,
    AVG(fv.monto_total_item) AS promedio_venta,
    MAX(fv.monto_total_item) AS venta_maxima
FROM 
	pf_dw.fact_ventas fv
	INNER JOIN pf_dw.dim_tiempo dt ON fv.id_tiempo_dim = dt.id_tiempo_dim
	INNER JOIN pf_dw.dim_productos dp ON fv.id_producto_dim = dp.id_producto_dim
GROUP BY
    DATE_TRUNC('month', dt.fecha_orden),
    dp.categoria
ORDER BY
    fecha ASC,
    dp.categoria ASC;

-- CONSULTA ORIGINAL - EXPLAIN ANALYZE
-- ####################################################
EXPLAIN ANALYZE
SELECT
    DATE_TRUNC('month', dt.fecha_orden) AS fecha,
    dp.categoria,
    SUM(fv.monto_total_item) AS ingresos,
    AVG(fv.monto_total_item) AS promedio_venta,
    MAX(fv.monto_total_item) AS venta_maxima
FROM 
	pf_dw.fact_ventas fv
	INNER JOIN pf_dw.dim_tiempo dt ON fv.id_tiempo_dim = dt.id_tiempo_dim
	INNER JOIN pf_dw.dim_productos dp ON fv.id_producto_dim = dp.id_producto_dim
GROUP BY
    DATE_TRUNC('month', dt.fecha_orden),
    dp.categoria
ORDER BY
    fecha ASC,
    dp.categoria ASC;
-- Planning Time: 0.295 ms
-- Execution Time: 26.009 ms


-- VISTA MATERIALIZADA - CREAR
-- ####################################################
-- DROP MATERIALIZED VIEW IF EXISTS pf_dw.mv_kpis_categoria_productos;
CREATE MATERIALIZED VIEW pf_dw.mv_kpis_categoria_productos as
SELECT
    DATE_TRUNC('month', dt.fecha_orden) AS fecha,
    dp.categoria,
    SUM(fv.monto_total_item) AS ingresos,
    AVG(fv.monto_total_item) AS promedio_venta,
    MAX(fv.monto_total_item) AS venta_maxima
FROM 
	pf_dw.fact_ventas fv
	INNER JOIN pf_dw.dim_tiempo dt ON fv.id_tiempo_dim = dt.id_tiempo_dim
	INNER JOIN pf_dw.dim_productos dp ON fv.id_producto_dim = dp.id_producto_dim
GROUP BY
    DATE_TRUNC('month', dt.fecha_orden),
    dp.categoria
ORDER BY
    fecha ASC,
    dp.categoria ASC;


-- VISTA MATERIALIZADA - EXPLAIN ANALYZE
-- ####################################################
EXPLAIN ANALYZE
SELECT
    fecha,
    categoria,
    ingresos,
    promedio_venta,
    venta_maxima
FROM pf_dw.mv_kpis_categoria_productos;
-- Planning Time: 0.029 ms
-- Execution Time: 0.025 ms

-- VISTA MATERIALIZADA - INDICE
-- ####################################################
-- DROP INDEX IF EXISTS pf_dw.ux_mv_kpis_categoria_productos;
CREATE UNIQUE INDEX ux_mv_kpis_categoria_productos
ON pf_dw.mv_kpis_categoria_productos (fecha,categoria);


-- VISTA MATERIALIZADA - INDEX UNICO - EXPLAIN ANALYZE 
-- ####################################################
EXPLAIN ANALYZE
SELECT
    fecha,
    categoria,
    ingresos,
    promedio_venta,
    venta_maxima
FROM pf_dw.mv_kpis_categoria_productos;
-- Planning Time: 2.475 ms
-- Execution Time: 0.027 ms

-- actualiza los datos de tu vista materializada usando 
-- nuevamente la consulta con la que fue creada.
-- ####################################################
REFRESH MATERIALIZED VIEW CONCURRENTLY 
pf_dw.mv_kpis_categoria_productos;