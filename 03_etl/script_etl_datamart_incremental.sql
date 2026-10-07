-- ============================================================================
-- PROYECTO FINAL INTEGRADO: DATA MART ANALÍTICO DE ECOMMERCE
-- FASE 2: PROCESO ETL INCREMENTAL
-- MOTOR: PostgreSQL
-- ============================================================================
--
-- MODELO OBJETIVO:
--   dim_clientes
--   dim_productos
--   dim_tiempo
--   dim_pagos
--   fact_ventas
--
-- GRANULARIDAD DE fact_ventas:
--   Una fila representa un item vendido dentro de una orden (order_item_id).
--
-- ESTRATEGIA DE CARGA:
--   - No se utiliza TRUNCATE.
--   - Los registros nuevos se insertan.
--   - Los registros existentes se actualizan mediante ON CONFLICT DO UPDATE.
--   - Las claves subrogadas existentes se conservan.
-- ============================================================================

CREATE OR REPLACE PROCEDURE sp_poblar_data_mart()
LANGUAGE plpgsql
AS $$
BEGIN
    RAISE NOTICE 'Iniciando proceso ETL incremental del Data Mart...';

    -- ========================================================================
    -- VALIDACIÓN PREVIA
    -- Evita duplicar filas de fact_ventas si una orden tuviera más de un pago.
    -- El modelo actual requiere una única clasificación de pago por orden.
    -- ========================================================================
    IF EXISTS (
        SELECT 1
        FROM payment
        WHERE order_id IS NOT NULL
        GROUP BY order_id
        HAVING COUNT(*) > 1
    ) THEN
        RAISE EXCEPTION
            'Se detectaron órdenes con más de un pago. La carga se detiene para preservar la granularidad de fact_ventas.';
    END IF;

    -- ========================================================================
    -- PASO 1: CARGAR / ACTUALIZAR DIMENSIÓN TIEMPO
    -- ========================================================================
    RAISE NOTICE 'Cargando Dimensión Tiempo...';

    WITH limites AS (
        SELECT
            MIN(order_date)::DATE AS fecha_min,
            MAX(order_date)::DATE AS fecha_max
        FROM orders
    )
    INSERT INTO pf_dw.dim_tiempo (
        id_tiempo_dim,
        fecha_orden,
        dia,
        anio,
        mes,
        nombre_dia,
        nombre_mes,
        trimestre,
        dia_semana,
        anio_mes
    )
    SELECT
        TO_CHAR(gs.fecha_serie, 'YYYYMMDD')::INT AS id_tiempo_dim,
        gs.fecha_serie::DATE AS fecha_orden,
        EXTRACT(DAY FROM gs.fecha_serie)::INT AS dia,
        EXTRACT(YEAR FROM gs.fecha_serie)::INT AS anio,
        EXTRACT(MONTH FROM gs.fecha_serie)::INT AS mes,
        UPPER(TRIM(TO_CHAR(gs.fecha_serie, 'TMDay'))) AS nombre_dia,
        UPPER(TRIM(TO_CHAR(gs.fecha_serie, 'TMMonth'))) AS nombre_mes,
        EXTRACT(QUARTER FROM gs.fecha_serie)::INT AS trimestre,
        EXTRACT(ISODOW FROM gs.fecha_serie)::INT AS dia_semana,
        TO_CHAR(gs.fecha_serie, 'YYYY-MM') AS anio_mes
    FROM limites l
    CROSS JOIN LATERAL generate_series(
        l.fecha_min,
        l.fecha_max,
        INTERVAL '1 day'
    ) AS gs(fecha_serie)
    WHERE l.fecha_min IS NOT NULL
      AND l.fecha_max IS NOT NULL
    ON CONFLICT (id_tiempo_dim) DO UPDATE
    SET fecha_orden = EXCLUDED.fecha_orden,
        dia = EXCLUDED.dia,
        anio = EXCLUDED.anio,
        mes = EXCLUDED.mes,
        nombre_dia = EXCLUDED.nombre_dia,
        nombre_mes = EXCLUDED.nombre_mes,
        trimestre = EXCLUDED.trimestre,
        dia_semana = EXCLUDED.dia_semana,
        anio_mes = EXCLUDED.anio_mes;

    -- ========================================================================
    -- PASO 2: CARGAR / ACTUALIZAR DIMENSIÓN CLIENTES
    -- ========================================================================
    RAISE NOTICE 'Cargando Dimensión Clientes...';

    WITH clientes_origen_limpios AS (
        SELECT
            customer_id,
            UPPER(
                TRIM(
                    COALESCE(first_name, '') || ' ' || COALESCE(last_name, '')
                )
            ) AS nombre_completo,
            LOWER(TRIM(COALESCE(email, 'sin_correo@tienda.com'))) AS email,
            UPPER(TRIM(COALESCE(address, 'DIRECCIÓN NO REGISTRADA'))) AS direccion,
            TRIM(COALESCE(phone_number, '000-000-0000')) AS numero_telefono,
            ROW_NUMBER() OVER (
                PARTITION BY customer_id
                ORDER BY customer_id
            ) AS ranking_duplicados
        FROM customers
    )
    INSERT INTO pf_dw.dim_clientes (
        customer_id,
        nombre_completo,
        email,
        direccion,
        numero_telefono
    )
    SELECT
        customer_id,
        nombre_completo,
        email,
        direccion,
        numero_telefono
    FROM clientes_origen_limpios
    WHERE ranking_duplicados = 1
    ON CONFLICT (customer_id) DO UPDATE
    SET nombre_completo = EXCLUDED.nombre_completo,
        email = EXCLUDED.email,
        direccion = EXCLUDED.direccion,
        numero_telefono = EXCLUDED.numero_telefono;

    -- ========================================================================
    -- PASO 3: CARGAR / ACTUALIZAR DIMENSIÓN PRODUCTOS
    -- El proveedor permanece desnormalizado dentro de dim_productos para
    -- conservar el esquema estrella.
    -- ========================================================================
    RAISE NOTICE 'Cargando Dimensión Productos...';

    WITH productos_proveedores_consolidados AS (
        SELECT
            p.product_id,
            UPPER(TRIM(COALESCE(p.product_name, 'PRODUCTO GENÉRICO'))) AS nombre_producto,
            INITCAP(TRIM(COALESCE(p.category, 'General'))) AS categoria,
            CASE
                WHEN p.price IS NULL OR p.price < 0 THEN 0.00
                ELSE p.price
            END::NUMERIC(12, 2) AS precio_producto,
            COALESCE(p.supplier_id, 0) AS supplier_id,
            UPPER(
                TRIM(
                    COALESCE(s.supplier_name, 'PROVEEDOR NO ASIGNADO')
                )
            ) AS nombre_proveedor
        FROM products p
        LEFT JOIN suppliers s
            ON p.supplier_id = s.supplier_id
    )
    INSERT INTO pf_dw.dim_productos (
        product_id,
        nombre_producto,
        categoria,
        precio_producto,
        supplier_id,
        nombre_proveedor
    )
    SELECT
        product_id,
        nombre_producto,
        categoria,
        precio_producto,
        supplier_id,
        nombre_proveedor
    FROM productos_proveedores_consolidados
    ON CONFLICT (product_id) DO UPDATE
    SET nombre_producto = EXCLUDED.nombre_producto,
        categoria = EXCLUDED.categoria,
        precio_producto = EXCLUDED.precio_producto,
        supplier_id = EXCLUDED.supplier_id,
        nombre_proveedor = EXCLUDED.nombre_proveedor;

    -- ========================================================================
    -- PASO 4: CARGAR / ACTUALIZAR DIMENSIÓN PAGOS
    -- Clave natural compuesta: (metodo_pago, estado_pago).
    -- ========================================================================
    RAISE NOTICE 'Cargando Dimensión Pagos...';

    WITH metodos_pago_unicos AS (
        SELECT DISTINCT
            UPPER(TRIM(COALESCE(payment_method, 'NO ESPECIFICADO'))) AS metodo_pago,
            INITCAP(TRIM(COALESCE(transaction_status, 'DESCONOCIDO'))) AS estado_pago
        FROM payment

        UNION

        SELECT
            'NO ESPECIFICADO'::VARCHAR(50) AS metodo_pago,
            'DESCONOCIDO'::VARCHAR(50) AS estado_pago
    )
    INSERT INTO pf_dw.dim_pagos (
        metodo_pago,
        estado_pago
    )
    SELECT
        metodo_pago,
        estado_pago
    FROM metodos_pago_unicos
    ON CONFLICT (metodo_pago, estado_pago) DO UPDATE
    SET metodo_pago = EXCLUDED.metodo_pago,
        estado_pago = EXCLUDED.estado_pago;

    -- ========================================================================
    -- PASO 5: CARGAR / ACTUALIZAR TABLA DE HECHOS fact_ventas
    -- Granularidad: una fila por order_item_id.
    -- ========================================================================
    RAISE NOTICE 'Cargando Tabla de Hechos (fact_ventas)...';

    WITH recopilacion_transaccional AS (
        SELECT
            oi.order_id,
            oi.order_item_id,
            o.customer_id,
            oi.product_id,
            o.order_date::DATE AS order_date,
            UPPER(
                TRIM(
                    COALESCE(pay.payment_method, 'NO ESPECIFICADO')
                )
            ) AS payment_method_raw,
            INITCAP(
                TRIM(
                    COALESCE(pay.transaction_status, 'DESCONOCIDO')
                )
            ) AS transaction_status_raw,
            oi.quantity AS cantidad,
            oi.price_at_purchase::NUMERIC(12, 2) AS precio_unitario,
            (oi.quantity * oi.price_at_purchase)::NUMERIC(12, 2) AS monto_total_item
        FROM order_items oi
        JOIN orders o
            ON oi.order_id = o.order_id
        LEFT JOIN payment pay
            ON o.order_id = pay.order_id
    )
    INSERT INTO pf_dw.fact_ventas (
        id_cliente_dim,
        id_producto_dim,
        id_tiempo_dim,
        id_pago_dim,
        order_id,
        order_item_id,
        cantidad,
        precio_unitario,
        monto_total_item
    )
    SELECT
        dc.id_cliente_dim,
        dp.id_producto_dim,
        dt.id_tiempo_dim,
        dpag.id_pago_dim,
        rt.order_id,
        rt.order_item_id,
        rt.cantidad,
        rt.precio_unitario,
        rt.monto_total_item
    FROM recopilacion_transaccional rt
    JOIN pf_dw.dim_clientes dc
        ON rt.customer_id = dc.customer_id
    JOIN pf_dw.dim_productos dp
        ON rt.product_id = dp.product_id
    JOIN pf_dw.dim_tiempo dt
        ON rt.order_date = dt.fecha_orden
    JOIN pf_dw.dim_pagos dpag
        ON rt.payment_method_raw = dpag.metodo_pago
       AND rt.transaction_status_raw = dpag.estado_pago
    ON CONFLICT (order_item_id) DO UPDATE
    SET id_cliente_dim = EXCLUDED.id_cliente_dim,
        id_producto_dim = EXCLUDED.id_producto_dim,
        id_tiempo_dim = EXCLUDED.id_tiempo_dim,
        id_pago_dim = EXCLUDED.id_pago_dim,
        order_id = EXCLUDED.order_id,
        cantidad = EXCLUDED.cantidad,
        precio_unitario = EXCLUDED.precio_unitario,
        monto_total_item = EXCLUDED.monto_total_item;

    RAISE NOTICE 'Proceso ETL incremental finalizado correctamente.';
END;
$$;

-- ============================================================================
-- EJECUCIÓN
-- ============================================================================
-- CALL sp_poblar_data_mart();

-- ============================================================================
-- VALIDACIONES POST-CARGA
-- ============================================================================

-- 1. Validar granularidad: un único registro por order_item_id.
/*
SELECT order_item_id, COUNT(*)
 FROM pf_dw.fact_ventas
 GROUP BY order_item_id
 HAVING COUNT(*) > 1;
*/
-- 2. Validar ventas totales.
/*
 SELECT SUM(monto_total_item) AS ventas_totales
 FROM pf_dw.fact_ventas;
*/
-- 3. Validar número de órdenes.
/*
 SELECT COUNT(DISTINCT order_id) AS numero_ordenes
 FROM pf_dw.fact_ventas;
*/
-- 4. Validar participación de ventas por método de pago.
/*
 SELECT
     dp.metodo_pago,
     SUM(fv.monto_total_item) AS ventas,
     ROUND(
         100.0 * SUM(fv.monto_total_item)
         / NULLIF(SUM(SUM(fv.monto_total_item)) OVER (), 0),
         2
     ) AS participacion_pct
 FROM pf_dw.fact_ventas fv
 JOIN pf_dw.dim_pagos dp
     ON fv.id_pago_dim = dp.id_pago_dim
 GROUP BY dp.metodo_pago
 ORDER BY ventas DESC;
*/
/*
 -- Conteo de registros para verificar que no haya duplicados entre ejecuciones incrementales.
 -- Se espera que los conteos sean consistentes entre ejecuciones.
 select
	 (select count(*) from pf_dw.dim_clientes) as clientes,
	 (select count(*) from pf_dw.dim_pagos) as pagos,
	 (select count(*) from pf_dw.dim_productos) as productos,
	 (select count(*) from pf_dw.dim_tiempo) as tiempo,
	 (select count(*) from pf_dw.fact_ventas) as ventas
 ;
 */
-- ejecución 1: 10000	4	2000	366	20000
-- ejecución 2: 10000	4	2000	366	20000   -- ok no duplica
