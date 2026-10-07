-- =====================================
-- Total de ordenes por categoría de producto
-- =====================================

-- CONSULTA ORIGINAL 
-- ####################################################
SELECT
    dp.categoria AS categoria,
    COUNT(DISTINCT fv.order_id) AS total_pedidos
FROM 
	pf_dw.fact_ventas fv
	INNER JOIN pf_dw.dim_productos dp ON fv.id_producto_dim = dp.id_producto_dim
GROUP BY
    dp.categoria
ORDER BY
    total_pedidos DESC;

-- CONSULTA ORIGINAL - EXPLAIN ANALYZE
-- ####################################################
EXPLAIN ANALYZE
SELECT
    dp.categoria AS categoria,
    COUNT(DISTINCT fv.order_id) AS total_pedidos
FROM 
	pf_dw.fact_ventas fv
	INNER JOIN pf_dw.dim_productos dp ON fv.id_producto_dim = dp.id_producto_dim
GROUP BY
    dp.categoria
ORDER BY
    total_pedidos DESC;
-- Planning Time: 0.419 ms
-- Execution Time: 32.077 ms

-- VISTA - CREAR
-- ####################################################
-- DROP VIEW IF EXISTS pf_dw.v_kpis_categoria_ordenes;
CREATE VIEW pf_dw.v_kpis_categoria_ordenes as
SELECT
    dp.categoria AS categoria,
    COUNT(DISTINCT fv.order_id) AS total_pedidos
FROM 
	pf_dw.fact_ventas fv
	INNER JOIN pf_dw.dim_productos dp ON fv.id_producto_dim = dp.id_producto_dim
GROUP BY
    dp.categoria
ORDER BY
    total_pedidos DESC;


-- VISTA - EXPLAIN ANALYZE
-- ####################################################
EXPLAIN ANALYZE
SELECT
    categoria,
    total_pedidos
FROM pf_dw.v_kpis_categoria_ordenes;
-- Planning Time: 0.342 ms
-- Execution Time: 32.178 ms

