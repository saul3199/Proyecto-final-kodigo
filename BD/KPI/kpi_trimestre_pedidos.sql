-- =====================================
-- Total de pedidos - trimestre
-- =====================================

-- CONSULTA ORIGINAL 
-- ####################################################
WITH ultimo_trimestre AS (
    SELECT
        dt.anio,
        dt.trimestre
    FROM 
    	pf_dw.fact_ventas fv
    	INNER JOIN pf_dw.dim_tiempo dt ON fv.id_tiempo_dim = dt.id_tiempo_dim
    GROUP BY
        dt.anio,
        dt.trimestre
    ORDER BY
        dt.anio DESC,
        dt.trimestre DESC
    LIMIT 1
)
SELECT
    CONCAT('T', dt.trimestre, ' ', dt.anio) AS trimestre,
    COUNT(DISTINCT fv.order_id) AS total_pedidos
FROM 
	pf_dw.fact_ventas fv
	INNER JOIN pf_dw.dim_tiempo dt ON fv.id_tiempo_dim = dt.id_tiempo_dim
	INNER JOIN ultimo_trimestre ut ON dt.anio = ut.anio AND dt.trimestre = ut.trimestre
	INNER JOIN pf_dw.dim_productos dp ON fv.id_producto_dim = dp.id_producto_dim
GROUP BY
    dt.anio,
    dt.trimestre
ORDER BY
    dt.anio,
    dt.trimestre;

-- CONSULTA ORIGINAL - EXPLAIN ANALYZE
-- ####################################################
EXPLAIN ANALYZE
WITH ultimo_trimestre AS (
    SELECT
        dt.anio,
        dt.trimestre
    FROM 
    	pf_dw.fact_ventas fv
    	INNER JOIN pf_dw.dim_tiempo dt ON fv.id_tiempo_dim = dt.id_tiempo_dim
    GROUP BY
        dt.anio,
        dt.trimestre
    ORDER BY
        dt.anio DESC,
        dt.trimestre DESC
    LIMIT 1
)
SELECT
    CONCAT('T', dt.trimestre, ' ', dt.anio) AS trimestre,
    COUNT(DISTINCT fv.order_id) AS total_pedidos
FROM 
	pf_dw.fact_ventas fv
	INNER JOIN pf_dw.dim_tiempo dt ON fv.id_tiempo_dim = dt.id_tiempo_dim
	INNER JOIN ultimo_trimestre ut ON dt.anio = ut.anio AND dt.trimestre = ut.trimestre
	INNER JOIN pf_dw.dim_productos dp ON fv.id_producto_dim = dp.id_producto_dim
GROUP BY
    dt.anio,
    dt.trimestre
ORDER BY
    dt.anio,
    dt.trimestre;
-- Planning Time: 0.915 ms
-- Execution Time: 24.705 ms



-- VISTA - CREAR
-- ####################################################
-- DROP VIEW IF EXISTS pf_dw.v_kpis_trimestre_pedidos;
CREATE VIEW pf_dw.v_kpis_trimestre_pedidos as
WITH ultimo_trimestre AS (
    SELECT
        dt.anio,
        dt.trimestre
    FROM 
    	pf_dw.fact_ventas fv
    	INNER JOIN pf_dw.dim_tiempo dt ON fv.id_tiempo_dim = dt.id_tiempo_dim
    GROUP BY
        dt.anio,
        dt.trimestre
    ORDER BY
        dt.anio DESC,
        dt.trimestre DESC
    LIMIT 1
)
SELECT
    CONCAT('T', dt.trimestre, ' ', dt.anio) AS trimestre,
    COUNT(DISTINCT fv.order_id) AS total_pedidos
FROM 
	pf_dw.fact_ventas fv
	INNER JOIN pf_dw.dim_tiempo dt ON fv.id_tiempo_dim = dt.id_tiempo_dim
	INNER JOIN ultimo_trimestre ut ON dt.anio = ut.anio AND dt.trimestre = ut.trimestre
	INNER JOIN pf_dw.dim_productos dp ON fv.id_producto_dim = dp.id_producto_dim
GROUP BY
    dt.anio,
    dt.trimestre
ORDER BY
    dt.anio,
    dt.trimestre;



-- VISTA - EXPLAIN ANALYZE
-- ####################################################
EXPLAIN ANALYZE
SELECT
    trimestre,
    total_pedidos
FROM pf_dw.v_kpis_trimestre_pedidos;
-- Planning Time: 0.586 ms
-- Execution Time: 20.742 ms
