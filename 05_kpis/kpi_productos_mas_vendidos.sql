-- ============================================================================
-- KPI: PRODUCTOS MÁS VENDIDOS
--
-- Objetivo:
-- Identificar y ordenar los productos según la cantidad total de unidades
-- vendidas.
--
-- Base técnica:
-- - fact_ventas tiene granularidad de 1 fila por item de una orden.
-- - cantidad representa las unidades del producto contenidas en cada item.
-- - SUM(cantidad) es una medida aditiva y permite obtener correctamente
--   las unidades vendidas acumuladas por producto.
--
-- Importante:
-- "Producto más vendido" se define por volumen de unidades.
-- No debe utilizarse monto_total_item, ya que eso mediría ingresos por producto.
-- ============================================================================


-- ============================================================================
-- 1. CONSULTA BASE
-- ============================================================================
SELECT
    dp.product_id,
    dp.nombre_producto,

    -- Total de unidades vendidas del producto en todas las órdenes.
    SUM(fv.cantidad) AS unidades_vendidas

FROM pf_dw.fact_ventas fv

INNER JOIN pf_dw.dim_productos dp
    ON fv.id_producto_dim = dp.id_producto_dim

GROUP BY
    dp.product_id,
    dp.nombre_producto

-- Mayor volumen vendido primero.
ORDER BY
    unidades_vendidas DESC;



-- ============================================================================
-- 2. ANÁLISIS DEL PLAN DE EJECUCIÓN
--
-- Permite evaluar principalmente:
-- - lectura de fact_ventas;
-- - costo del JOIN con dim_productos;
-- - estrategia utilizada para GROUP BY;
-- - costo del ordenamiento final.
-- ============================================================================
EXPLAIN ANALYZE
SELECT
    dp.product_id,
    dp.nombre_producto,
    SUM(fv.cantidad) AS unidades_vendidas
FROM pf_dw.fact_ventas fv
INNER JOIN pf_dw.dim_productos dp
    ON fv.id_producto_dim = dp.id_producto_dim
GROUP BY
    dp.product_id,
    dp.nombre_producto
ORDER BY
    unidades_vendidas DESC;



-- ============================================================================
-- 3. VISTA MATERIALIZADA
--
-- Justificación:
-- El cálculo requiere recorrer fact_ventas y agregar todas las ventas por
-- producto. Materializar el resultado evita repetir esta agregación en cada
-- consulta realizada desde Metabase u otros consumidores analíticos.
--
-- No se aplica LIMIT, permitiendo que la capa BI determine si desea mostrar
-- Top 5, Top 10, Top 20, etc.
-- ============================================================================
CREATE MATERIALIZED VIEW pf_dw.mv_kpis_productos_mas_vendidos AS
SELECT
    dp.product_id,
    dp.nombre_producto,
    SUM(fv.cantidad) AS unidades_vendidas

FROM pf_dw.fact_ventas fv

INNER JOIN pf_dw.dim_productos dp
    ON fv.id_producto_dim = dp.id_producto_dim

GROUP BY
    dp.product_id,
    dp.nombre_producto;



-- ============================================================================
-- 4. ÍNDICE ÚNICO
--
-- product_id identifica unívocamente cada producto en el resultado agregado.
--
-- El índice UNIQUE permite utilizar:
-- REFRESH MATERIALIZED VIEW CONCURRENTLY
-- ============================================================================
CREATE UNIQUE INDEX ux_mv_kpis_productos_mas_vendidos
ON pf_dw.mv_kpis_productos_mas_vendidos (product_id);



-- ============================================================================
-- 5. CONSULTA DEL KPI MATERIALIZADO
--
-- La vista ya contiene las unidades agregadas por producto.
-- Solo es necesario ordenar para obtener el ranking.
-- ============================================================================
EXPLAIN ANALYZE
SELECT
    product_id,
    nombre_producto,
    unidades_vendidas
FROM pf_dw.mv_kpis_productos_mas_vendidos
ORDER BY unidades_vendidas DESC;



-- ============================================================================
-- 6. ACTUALIZACIÓN DEL KPI
--
-- Debe ejecutarse después del ETL cuando existan nuevas ventas o cambios
-- relevantes en fact_ventas.
--
-- CONCURRENTLY mantiene disponible la versión anterior mientras PostgreSQL
-- genera el nuevo resultado.
-- ============================================================================
REFRESH MATERIALIZED VIEW CONCURRENTLY
    pf_dw.mv_kpis_productos_mas_vendidos;



-- ============================================================================
-- 7. VALIDACIÓN
--
-- Ambas consultas deben devolver la misma cantidad total de unidades.
-- Esto verifica que la agregación por producto no pierda ni duplique ventas.
-- ============================================================================

SELECT SUM(cantidad) AS unidades_fact
FROM pf_dw.fact_ventas;

SELECT SUM(unidades_vendidas) AS unidades_kpi
FROM pf_dw.mv_kpis_productos_mas_vendidos;