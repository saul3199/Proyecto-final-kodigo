-- =====================================
-- Ordenes por categoría de producto
-- =====================================

-- CONSULTA ORIGINAL 
-- ####################################################
SELECT
    dp.categoria AS categoria,
    'T' || dt.trimestre || ' ' || dt.anio AS periodo,
    COUNT(DISTINCT fv.order_id) AS cantidad_pedidos
FROM 
	pf_dw.fact_ventas fv
	INNER JOIN pf_dw.dim_tiempo dt ON fv.id_tiempo_dim = dt.id_tiempo_dim
	INNER JOIN pf_dw.dim_productos dp ON fv.id_producto_dim = dp.id_producto_dim
GROUP BY
    dp.categoria,
    dt.anio,
    dt.trimestre
ORDER BY
    dp.categoria ASC,
    dt.anio ASC,
    dt.trimestre ASC;

-- CONSULTA ORIGINAL - EXPLAIN ANALYZE
-- ####################################################
EXPLAIN ANALYZE
SELECT
    dp.categoria AS categoria,
    'T' || dt.trimestre || ' ' || dt.anio AS periodo,
    COUNT(DISTINCT fv.order_id) AS cantidad_pedidos
FROM 
	pf_dw.fact_ventas fv
	INNER JOIN pf_dw.dim_tiempo dt ON fv.id_tiempo_dim = dt.id_tiempo_dim
	INNER JOIN pf_dw.dim_productos dp ON fv.id_producto_dim = dp.id_producto_dim
GROUP BY
    dp.categoria,
    dt.anio,
    dt.trimestre
ORDER BY
    dp.categoria ASC,
    dt.anio ASC,
    dt.trimestre ASC;
-- Planning Time: 0.731 ms
-- Execution Time: 53.693 ms


-- VISTA MATERIALIZADA - CREAR
-- ####################################################
-- DROP MATERIALIZED VIEW IF EXISTS pf_dw.mv_kpis_categoria_periodo_productos;
CREATE MATERIALIZED VIEW pf_dw.mv_kpis_categoria_periodo_productos as
SELECT
    dp.categoria AS categoria,
    'T' || dt.trimestre || ' ' || dt.anio AS periodo,
    COUNT(DISTINCT fv.order_id) AS cantidad_pedidos
FROM 
	pf_dw.fact_ventas fv
	INNER JOIN pf_dw.dim_tiempo dt ON fv.id_tiempo_dim = dt.id_tiempo_dim
	INNER JOIN pf_dw.dim_productos dp ON fv.id_producto_dim = dp.id_producto_dim
GROUP BY
    dp.categoria,
    dt.anio,
    dt.trimestre
ORDER BY
    dp.categoria ASC,
    dt.anio ASC,
    dt.trimestre ASC;


-- VISTA MATERIALIZADA - EXPLAIN ANALYZE
-- ####################################################
EXPLAIN ANALYZE
SELECT
    categoria,
    periodo,
    cantidad_pedidos
FROM pf_dw.mv_kpis_categoria_periodo_productos;
-- Planning Time: 0.028 ms
-- Execution Time: 0.019 ms

-- VISTA MATERIALIZADA - INDICE
-- ####################################################
-- DROP INDEX IF EXISTS pf_dw.ux_mv_kpis_categoria_periodo_productos;
CREATE UNIQUE INDEX ux_mv_kpis_categoria_periodo_productos
ON pf_dw.mv_kpis_categoria_periodo_productos (periodo,categoria);


-- VISTA MATERIALIZADA - INDEX UNICO - EXPLAIN ANALYZE 
-- ####################################################
EXPLAIN ANALYZE
SELECT
    categoria,
    periodo,
    cantidad_pedidos
FROM pf_dw.mv_kpis_categoria_periodo_productos;
-- Planning Time: 0.090 ms
-- Execution Time: 0.019 ms

-- actualiza los datos de tu vista materializada usando 
-- nuevamente la consulta con la que fue creada.
-- ####################################################
REFRESH MATERIALIZED VIEW CONCURRENTLY 
pf_dw.mv_kpis_categoria_periodo_productos;