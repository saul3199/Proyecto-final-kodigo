-- ============================================================================
-- KPI: TICKET PROMEDIO POR CLIENTE
--
-- Objetivo:
-- Medir el valor promedio de las órdenes realizadas por cada cliente.
--
-- Fórmula:
--
--     Ticket promedio =
--         Ventas totales del cliente / Número de órdenes del cliente
--
-- Base técnica:
-- - fact_ventas tiene granularidad de 1 fila por item de una orden.
-- - Una orden puede contener varios items.
-- - Por esta razón NO debe utilizarse AVG(monto_total_item), ya que eso
--   calcularía el valor promedio de un item, no el ticket promedio de la orden.
-- - COUNT(DISTINCT order_id) evita contar varias veces una misma orden.
-- ============================================================================


-- ============================================================================
-- 1. CONSULTA BASE
-- ============================================================================
SELECT
    dc.customer_id,
    dc.nombre_completo,

    -- Ventas acumuladas del cliente.
    SUM(fv.monto_total_item) AS total_ventas,

    -- Una orden puede aparecer en múltiples filas debido a sus items.
    -- DISTINCT garantiza contar cada orden una sola vez.
    COUNT(DISTINCT fv.order_id) AS numero_ordenes,

    -- Ticket promedio real por orden del cliente.
    ROUND(
        SUM(fv.monto_total_item)
        / NULLIF(COUNT(DISTINCT fv.order_id), 0),
        2
    ) AS ticket_promedio

FROM pf_dw.fact_ventas fv

INNER JOIN pf_dw.dim_clientes dc
    ON fv.id_cliente_dim = dc.id_cliente_dim

GROUP BY
    dc.customer_id,
    dc.nombre_completo

ORDER BY
    ticket_promedio DESC;



-- ============================================================================
-- 2. ANÁLISIS DEL PLAN DE EJECUCIÓN
--
-- Permite evaluar:
-- - lectura de fact_ventas;
-- - costo del JOIN con dim_clientes;
-- - costo de SUM();
-- - costo adicional de COUNT(DISTINCT order_id);
-- - estrategia de agrupación utilizada por PostgreSQL.
-- ============================================================================
EXPLAIN ANALYZE
SELECT
    dc.customer_id,
    dc.nombre_completo,
    SUM(fv.monto_total_item) AS total_ventas,
    COUNT(DISTINCT fv.order_id) AS numero_ordenes,
    ROUND(
        SUM(fv.monto_total_item)
        / NULLIF(COUNT(DISTINCT fv.order_id), 0),
        2
    ) AS ticket_promedio
FROM pf_dw.fact_ventas fv
INNER JOIN pf_dw.dim_clientes dc
    ON fv.id_cliente_dim = dc.id_cliente_dim
GROUP BY
    dc.customer_id,
    dc.nombre_completo
ORDER BY
    ticket_promedio DESC;



-- ============================================================================
-- 3. VISTA MATERIALIZADA
--
-- Justificación:
-- El KPI requiere agregación sobre toda fact_ventas y un
-- COUNT(DISTINCT order_id), operación más costosa que un COUNT simple.
--
-- Materializar el resultado permite que se consulte directamente
-- las métricas ya calculadas por cliente.
--
-- Se conservan total_ventas y numero_ordenes para facilitar auditoría,
-- interpretación y reutilización analítica del KPI.
-- ============================================================================
CREATE MATERIALIZED VIEW pf_dw.mv_kpis_ticket_promedio_cliente AS
SELECT
    dc.customer_id,
    dc.nombre_completo,

    SUM(fv.monto_total_item) AS total_ventas,

    COUNT(DISTINCT fv.order_id) AS numero_ordenes,

    ROUND(
        SUM(fv.monto_total_item)
        / NULLIF(COUNT(DISTINCT fv.order_id), 0),
        2
    ) AS ticket_promedio

FROM pf_dw.fact_ventas fv

INNER JOIN pf_dw.dim_clientes dc
    ON fv.id_cliente_dim = dc.id_cliente_dim

GROUP BY
    dc.customer_id,
    dc.nombre_completo;



-- ============================================================================
-- 4. ÍNDICE ÚNICO
--
-- Cada cliente genera una única fila en la vista materializada.
--
-- El índice UNIQUE es necesario para poder ejecutar:
-- REFRESH MATERIALIZED VIEW CONCURRENTLY.
-- ============================================================================
CREATE UNIQUE INDEX ux_mv_kpis_ticket_promedio_cliente
ON pf_dw.mv_kpis_ticket_promedio_cliente (customer_id);



-- ============================================================================
-- 5. CONSULTA DEL KPI MATERIALIZADO
-- ============================================================================
EXPLAIN ANALYZE
SELECT
    customer_id,
    nombre_completo,
    total_ventas,
    numero_ordenes,
    ticket_promedio
FROM pf_dw.mv_kpis_ticket_promedio_cliente
ORDER BY ticket_promedio DESC;



-- ============================================================================
-- 6. ACTUALIZACIÓN
--
-- Ejecutar después del proceso ETL para incorporar nuevas órdenes,
-- modificaciones de ventas o cambios relevantes en clientes.
-- ============================================================================
REFRESH MATERIALIZED VIEW CONCURRENTLY
    pf_dw.mv_kpis_ticket_promedio_cliente;