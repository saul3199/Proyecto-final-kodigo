-- ============================================================================
-- KPI: TOP 10 CLIENTES POR VENTAS
--
-- Objetivo:
-- Identificar los 10 clientes que generan mayor ingreso acumulado.
--
-- Base técnica:
-- - fact_ventas tiene granularidad de 1 fila por item de una orden.
-- - monto_total_item es una medida aditiva, por lo que SUM() permite obtener
--   correctamente las ventas acumuladas por cliente.
-- - No es necesario agrupar primero por orden: sumar todos los items del cliente
--   produce directamente su volumen total de ventas.
-- ============================================================================


-- ============================================================================
-- 1. CONSULTA BASE
-- ============================================================================
SELECT
    dc.customer_id,
    dc.nombre_completo,

    -- Suma de todos los items comprados por el cliente.
    -- Como cada fila representa un item distinto, no existe doble conteo.
    SUM(fv.monto_total_item) AS total_ventas

FROM pf_dw.fact_ventas fv

    -- La FK id_cliente_dim permite resolver la clave subrogada de la fact
    -- hacia los atributos descriptivos almacenados en dim_clientes.
    INNER JOIN pf_dw.dim_clientes dc
        ON fv.id_cliente_dim = dc.id_cliente_dim

GROUP BY
    dc.customer_id,
    dc.nombre_completo

-- Ranking descendente: el cliente con mayores ventas aparece primero.
ORDER BY
    total_ventas DESC

-- El KPI requiere únicamente los 10 clientes con mayor facturación.
LIMIT 10;



-- ============================================================================
-- 2. ANÁLISIS DEL PLAN DE EJECUCIÓN
--
-- Permite evaluar:
-- - costo del JOIN fact_ventas -> dim_clientes;
-- - estrategia de agregación utilizada por PostgreSQL;
-- - costo del ordenamiento requerido para obtener el Top 10;
-- - filas procesadas y tiempo real de ejecución.
-- ============================================================================
EXPLAIN ANALYZE
SELECT
    dc.customer_id,
    dc.nombre_completo,
    SUM(fv.monto_total_item) AS total_ventas
FROM pf_dw.fact_ventas fv
INNER JOIN pf_dw.dim_clientes dc
    ON fv.id_cliente_dim = dc.id_cliente_dim
GROUP BY
    dc.customer_id,
    dc.nombre_completo
ORDER BY
    total_ventas DESC
LIMIT 10;



-- ============================================================================
-- 3. VISTA MATERIALIZADA
--
-- Justificación:
-- El KPI requiere recorrer fact_ventas, agrupar por cliente, calcular SUM(),
-- ordenar los resultados y seleccionar el Top 10.
--
-- Una vista materializada persiste el resultado ya calculado, reduciendo el
-- trabajo necesario cuando Power BI u otros consumidores consultan el KPI
-- repetidamente.
--
-- Consideración:
-- Los datos representan el estado existente en el último REFRESH.
-- ============================================================================
CREATE MATERIALIZED VIEW pf_dw.mv_kpis_top_10_clientes AS
SELECT
    dc.customer_id,
    dc.nombre_completo,
    SUM(fv.monto_total_item) AS total_ventas
FROM pf_dw.fact_ventas fv
INNER JOIN pf_dw.dim_clientes dc
    ON fv.id_cliente_dim = dc.id_cliente_dim
GROUP BY
    dc.customer_id,
    dc.nombre_completo
ORDER BY
    total_ventas DESC
LIMIT 10;



-- ============================================================================
-- 4. ÍNDICE ÚNICO
--
-- customer_id identifica de forma única cada cliente dentro del resultado.
--
-- PostgreSQL requiere al menos un índice UNIQUE válido sobre la vista
-- materializada para utilizar REFRESH MATERIALIZED VIEW CONCURRENTLY.
-- ============================================================================
CREATE UNIQUE INDEX ux_mv_kpis_top_10_clientes
ON pf_dw.mv_kpis_top_10_clientes (customer_id);



-- ============================================================================
-- 5. CONSULTA DEL KPI MATERIALIZADO
--
-- Esta consulta ya no necesita realizar JOIN ni agregación sobre fact_ventas.
-- El ORDER BY se conserva para garantizar la presentación del ranking.
-- ============================================================================
EXPLAIN ANALYZE
SELECT
    customer_id,
    nombre_completo,
    total_ventas
FROM pf_dw.mv_kpis_top_10_clientes
ORDER BY total_ventas DESC;



-- ============================================================================
-- 6. ACTUALIZACIÓN DEL KPI
--
-- CONCURRENTLY permite mantener disponible la vista para consultas mientras
-- PostgreSQL genera la nueva versión del resultado.
--
-- Debe ejecutarse después de completar una carga ETL que modifique fact_ventas
-- o los datos relevantes de dim_clientes.
-- ============================================================================
REFRESH MATERIALIZED VIEW CONCURRENTLY
    pf_dw.mv_kpis_top_10_clientes;