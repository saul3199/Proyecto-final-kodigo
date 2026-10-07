-- =====================================
-- Los clientes con mas ingreso y compras
-- =====================================

-- CONSULTA ORIGINAL 
-- ####################################################
SELECT
	dc.customer_id,
	dc.nombre_completo as cliente,
	--SUM(fv.cantidad) AS total_cantidad,
	SUM(fv.monto_total_item) AS total_venta
FROM 
	pf_dw.fact_ventas fv
    INNER JOIN pf_dw.dim_clientes dc ON fv.id_cliente_dim = dc.id_cliente_dim
GROUP by
	dc.customer_id,
    dc.nombre_completo

-- CONSULTA ORIGINAL - EXPLAIN ANALYZE
-- ####################################################
EXPLAIN ANALYZE
SELECT
	dc.customer_id,
	dc.nombre_completo as cliente,
	--SUM(fv.cantidad) AS total_cantidad,
	SUM(fv.monto_total_item) AS total_venta
FROM 
	pf_dw.fact_ventas fv
    INNER JOIN pf_dw.dim_clientes dc ON fv.id_cliente_dim = dc.id_cliente_dim
GROUP by
	dc.customer_id,
    dc.nombre_completo
-- Planning Time: 0.175 ms
-- Execution Time: 53.443 ms


-- VISTA - CREAR
-- ####################################################
-- DROP VIEW IF EXISTS pf_dw.v_kpis_cliente_cantidad_ventas;
CREATE VIEW pf_dw.v_kpis_cliente_cantidad_ventas as
SELECT
	dc.customer_id,
	dc.nombre_completo as cliente,
	SUM(fv.cantidad) AS unidades_vendidas,
	SUM(fv.monto_total_item) AS total_venta
FROM 
	pf_dw.fact_ventas fv
    INNER JOIN pf_dw.dim_clientes dc ON fv.id_cliente_dim = dc.id_cliente_dim
GROUP by
	dc.customer_id,
    dc.nombre_completo


-- VISTA - EXPLAIN ANALYZE 
-- El cliente con mas ingreso
-- ####################################################
EXPLAIN ANALYZE
SELECT
    dc.nombre_completo AS cliente,
    SUM(fv.monto_total_item) AS total_venta,
    ROUND(
        SUM(fv.monto_total_item) * 100.0
        / SUM(SUM(fv.monto_total_item)) OVER (),
        2
    ) AS porcentaje_ventas
FROM pf_dw.fact_ventas fv
INNER JOIN pf_dw.dim_clientes dc
    ON fv.id_cliente_dim = dc.id_cliente_dim
GROUP BY
    dc.customer_id,
    dc.nombre_completo
ORDER BY
    total_venta desc
LIMIT 1;
-- Planning Time: 0.282 ms
-- Execution Time: 51.754 ms


-- VISTA - EXPLAIN ANALYZE 
-- El cliente con mas compras
-- ####################################################
EXPLAIN ANALYZE
SELECT
    dc.nombre_completo AS cliente,
    SUM(fv.cantidad) AS unidades_vendidas,
    ROUND(
        SUM(fv.cantidad) * 100.0
        / SUM(SUM(fv.cantidad)) OVER (),
        2
    ) AS porcentaje_unidades
FROM pf_dw.fact_ventas fv
INNER JOIN pf_dw.dim_clientes dc
    ON fv.id_cliente_dim = dc.id_cliente_dim
GROUP BY
    dc.customer_id,
    dc.nombre_completo
ORDER BY
    unidades_vendidas desc
LIMIT 1;
-- Planning Time: 0.212 ms
-- Execution Time: 38.877 ms

-- VISTA - EXPLAIN ANALYZE 
-- Los 10 productos mas ingresos y cantidad
-- ####################################################
EXPLAIN ANALYZE
SELECT
    cliente,
    unidades_vendidas,
    total_venta
FROM pf_dw.v_kpis_cliente_cantidad_ventas
order by total_venta DESC
LIMIT 5;
-- Planning Time: 0.332 ms
-- Execution Time: 74.133 ms
