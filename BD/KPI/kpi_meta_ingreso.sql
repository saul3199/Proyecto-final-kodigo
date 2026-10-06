-- =====================================
-- Meta de ingresos para este trimestre
-- =====================================

-- CONSULTA ORIGINAL 
-- ####################################################
SELECT
    SUM(fv.monto_total_item) AS ingresos
FROM pf_dw.fact_ventas fv
INNER JOIN pf_dw.dim_tiempo dt
    ON fv.id_tiempo_dim = dt.id_tiempo_dim
WHERE (dt.anio, dt.trimestre) = (
    SELECT
        dt2.anio,
        dt2.trimestre
    FROM pf_dw.fact_ventas fv2
    INNER JOIN pf_dw.dim_tiempo dt2
        ON fv2.id_tiempo_dim = dt2.id_tiempo_dim
    ORDER BY
        dt2.anio DESC,
        dt2.trimestre DESC
    LIMIT 1
);

-- CONSULTA ORIGINAL - EXPLAIN ANALYZE
-- ####################################################
EXPLAIN ANALYZE
SELECT
    SUM(fv.monto_total_item) AS ingresos
FROM pf_dw.fact_ventas fv
INNER JOIN pf_dw.dim_tiempo dt
    ON fv.id_tiempo_dim = dt.id_tiempo_dim
WHERE (dt.anio, dt.trimestre) = (
    SELECT
        dt2.anio,
        dt2.trimestre
    FROM pf_dw.fact_ventas fv2
    INNER JOIN pf_dw.dim_tiempo dt2
        ON fv2.id_tiempo_dim = dt2.id_tiempo_dim
    ORDER BY
        dt2.anio DESC,
        dt2.trimestre DESC
    LIMIT 1
);
-- Planning Time: 0.429 ms
-- Execution Time: 21.986 ms


-- VISTA - CREAR
-- ####################################################
-- DROP VIEW IF EXISTS pf_dw.v_kpis_meta_ingreso;
CREATE VIEW pf_dw.v_kpis_meta_ingreso as
SELECT
    SUM(fv.monto_total_item) AS ingresos
FROM pf_dw.fact_ventas fv
INNER JOIN pf_dw.dim_tiempo dt
    ON fv.id_tiempo_dim = dt.id_tiempo_dim
WHERE (dt.anio, dt.trimestre) = (
    SELECT
        dt2.anio,
        dt2.trimestre
    FROM pf_dw.fact_ventas fv2
    INNER JOIN pf_dw.dim_tiempo dt2
        ON fv2.id_tiempo_dim = dt2.id_tiempo_dim
    ORDER BY
        dt2.anio DESC,
        dt2.trimestre DESC
    LIMIT 1
);


-- VISTA - EXPLAIN ANALYZE
-- ####################################################
EXPLAIN ANALYZE
SELECT
    ingresos
FROM pf_dw.v_kpis_meta_ingreso;
-- Planning Time: 0.703 ms
-- Execution Time: 22.367 ms
