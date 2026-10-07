-- =====================================
-- Ingreso por proveedor y trimestre
-- =====================================

-- CONSULTA ORIGINAL 
-- ####################################################
SELECT
    dp.nombre_proveedor AS proveedor,
    'T' || dt.trimestre || ' ' || dt.anio AS periodo,
    SUM(fv.monto_total_item) AS ingresos
FROM 
	pf_dw.fact_ventas fv
	INNER JOIN pf_dw.dim_tiempo dt ON fv.id_tiempo_dim = dt.id_tiempo_dim
	INNER JOIN pf_dw.dim_productos dp ON fv.id_producto_dim = dp.id_producto_dim
GROUP BY
    dp.nombre_proveedor,
    dt.anio,
    dt.trimestre
ORDER BY
    dp.nombre_proveedor,
    dt.anio,
    dt.trimestre;

-- CONSULTA ORIGINAL - EXPLAIN ANALYZE
-- ####################################################
EXPLAIN ANALYZE
SELECT
    dp.nombre_proveedor AS proveedor,
    'T' || dt.trimestre || ' ' || dt.anio AS periodo,
    SUM(fv.monto_total_item) AS ingresos
FROM 
	pf_dw.fact_ventas fv
	INNER JOIN pf_dw.dim_tiempo dt ON fv.id_tiempo_dim = dt.id_tiempo_dim
	INNER JOIN pf_dw.dim_productos dp ON fv.id_producto_dim = dp.id_producto_dim
GROUP BY
    dp.nombre_proveedor,
    dt.anio,
    dt.trimestre
ORDER BY
    dp.nombre_proveedor,
    dt.anio,
    dt.trimestre;
-- Planning Time: 2.597 ms
-- Execution Time: 41.582 ms


-- VISTA MATERIALIZADA - CREAR
-- ####################################################
-- DROP MATERIALIZED VIEW IF EXISTS pf_dw.mv_kpis_trimestre_proveedor;
CREATE MATERIALIZED VIEW pf_dw.mv_kpis_trimestre_proveedor as
SELECT
    dp.nombre_proveedor AS proveedor,
    'T' || dt.trimestre || ' ' || dt.anio AS periodo,
    SUM(fv.monto_total_item) AS ingresos
FROM 
	pf_dw.fact_ventas fv
	INNER JOIN pf_dw.dim_tiempo dt ON fv.id_tiempo_dim = dt.id_tiempo_dim
	INNER JOIN pf_dw.dim_productos dp ON fv.id_producto_dim = dp.id_producto_dim
GROUP BY
    dp.nombre_proveedor,
    dt.anio,
    dt.trimestre
ORDER BY
    dp.nombre_proveedor,
    dt.anio,
    dt.trimestre;


-- VISTA MATERIALIZADA - EXPLAIN ANALYZE
-- ####################################################
EXPLAIN ANALYZE
SELECT
    proveedor,
    periodo,
    ingresos
FROM pf_dw.mv_kpis_trimestre_proveedor;
-- Planning Time: 5.327 ms
-- Execution Time: 0.035 ms

-- VISTA MATERIALIZADA - INDICE
-- ####################################################
-- DROP INDEX IF EXISTS pf_dw.ux_mv_kpis_trimestre_proveedor;
CREATE UNIQUE INDEX ux_mv_kpis_trimestre_proveedor
ON pf_dw.mv_kpis_trimestre_proveedor (proveedor,periodo);


-- VISTA MATERIALIZADA - INDEX UNICO - EXPLAIN ANALYZE 
-- ####################################################
EXPLAIN ANALYZE
SELECT
    proveedor,
    periodo,
    ingresos
FROM pf_dw.mv_kpis_trimestre_proveedor;
-- Planning Time: 7.428 ms
-- Execution Time: 0.035 ms

-- actualiza los datos de tu vista materializada usando 
-- nuevamente la consulta con la que fue creada.
-- ####################################################
REFRESH MATERIALIZED VIEW CONCURRENTLY 
pf_dw.mv_kpis_trimestre_proveedor;