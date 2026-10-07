-- =====================================
-- Los productos con mas ingreso y vendidos
-- =====================================

-- CONSULTA ORIGINAL 
-- ####################################################
SELECT
    dp.nombre_producto as producto,
    -- Total de unidades vendidas del producto en todas las órdenes.
    SUM(fv.cantidad) AS unidades_vendidas,
    SUM(fv.monto_total_item) AS ingresos
FROM 
	pf_dw.fact_ventas fv
	INNER JOIN pf_dw.dim_productos dp ON fv.id_producto_dim = dp.id_producto_dim
GROUP BY
    dp.nombre_producto;

-- CONSULTA ORIGINAL - EXPLAIN ANALYZE
-- ####################################################
EXPLAIN ANALYZE
SELECT
    dp.nombre_producto as producto,
    -- Total de unidades vendidas del producto en todas las órdenes.
    SUM(fv.cantidad) AS unidades_vendidas,
    SUM(fv.monto_total_item) AS ingresos
FROM 
	pf_dw.fact_ventas fv
	INNER JOIN pf_dw.dim_productos dp ON fv.id_producto_dim = dp.id_producto_dim
GROUP BY
    dp.nombre_producto;
-- Planning Time: 0.310 ms
-- Execution Time: 24.680 ms


-- VISTA - CREAR
-- ####################################################
-- DROP VIEW IF EXISTS pf_dw.v_kpis_producto_mas_vendidos;
CREATE VIEW pf_dw.v_kpis_producto_mas_vendidos as
SELECT
    dp.nombre_producto as producto,
    -- Total de unidades vendidas del producto en todas las órdenes.
    SUM(fv.cantidad) AS unidades_vendidas,
    SUM(fv.monto_total_item) AS ingresos
FROM 
	pf_dw.fact_ventas fv
	INNER JOIN pf_dw.dim_productos dp ON fv.id_producto_dim = dp.id_producto_dim
GROUP BY
    dp.nombre_producto;


-- VISTA - EXPLAIN ANALYZE 
-- Los 3 productos mas vendidos
-- ####################################################
EXPLAIN ANALYZE
SELECT
    producto,
    unidades_vendidas
FROM pf_dw.v_kpis_producto_mas_vendidos
order by unidades_vendidas DESC
LIMIT 3;
-- Planning Time: 0.200 ms
-- Execution Time: 17.639 ms


-- VISTA - EXPLAIN ANALYZE 
-- Los 3 productos mas ingresos
-- ####################################################
EXPLAIN ANALYZE
SELECT
    producto,
    ingresos
FROM pf_dw.v_kpis_producto_mas_vendidos
order by ingresos DESC
LIMIT 3;
-- Planning Time: 0.209 ms
-- Execution Time: 18.552 ms

-- VISTA - EXPLAIN ANALYZE 
-- Los 10 productos mas ingresos y cantidad
-- ####################################################
EXPLAIN ANALYZE
SELECT
    producto,
    unidades_vendidas,
    ingresos
FROM pf_dw.v_kpis_producto_mas_vendidos
order by ingresos DESC
LIMIT 10;
-- Planning Time: 0.210 ms
-- Execution Time: 14.093 ms
