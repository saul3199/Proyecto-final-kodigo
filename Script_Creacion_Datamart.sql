-- ============================================================================
-- PROYECTO FINAL INTEGRADO: DATA MART ANALÍTICO DE ECOMMERCE
-- FASE 1: SCRIPT DDL CON CLAVES SUBROGADAS E INTEGRIDAD REFERENCIAL
-- ============================================================================

-- Limpieza preventiva de estructuras previas para garantizar ejecución secuencial sin fallos
DROP TABLE IF EXISTS fact_ventas CASCADE;
DROP TABLE IF EXISTS dim_clientes CASCADE;
DROP TABLE IF EXISTS dim_productos CASCADE;
DROP TABLE IF EXISTS dim_tiempo CASCADE;
DROP TABLE IF EXISTS dim_pagos CASCADE;

-- ----------------------------------------------------------------------------
-- TABLA: dim_clientes
-- DESCRIPCIÓN: Almacena las entidades de contexto del cliente comprador.
-- ----------------------------------------------------------------------------
CREATE TABLE dim_clientes (
    id_cliente_dim SERIAL PRIMARY KEY, -- Clave subrogada artificial
    customer_id INT NOT NULL,         -- Clave natural del sistema OLTP
    nombre_completo VARCHAR(150) NOT NULL,
    email VARCHAR(100) NOT NULL,
    direccion TEXT NOT NULL,
    numero_telefono VARCHAR(20) NOT NULL,
    CONSTRAINT unq_customer_id UNIQUE (customer_id)
);

COMMENT ON TABLE dim_clientes IS 'Dimensión que contiene la información demográfica e identificativa de los clientes.';
COMMENT ON COLUMN dim_clientes.id_cliente_dim IS 'Llave subrogada primaria generada secuencialmente para el Data Mart.';

-- ----------------------------------------------------------------------------
-- TABLA: dim_productos
-- DESCRIPCIÓN: Detalles de los artículos vendidos junto con datos de sus proveedores.
-- ----------------------------------------------------------------------------
CREATE TABLE dim_productos (
    id_producto_dim SERIAL PRIMARY KEY,
    product_id INT NOT NULL,
    nombre_producto VARCHAR(150) NOT NULL,
    categoria VARCHAR(100) NOT NULL,
    precio_producto NUMERIC(12, 2) NOT NULL,
    nombre_proveedor VARCHAR(150) NOT NULL,
    CONSTRAINT unq_product_id UNIQUE (product_id)
);

COMMENT ON TABLE dim_productos IS 'Dimensión que consolida los datos del catálogo de productos y su relación con proveedores.';

-- ----------------------------------------------------------------------------
-- TABLA: dim_tiempo
-- DESCRIPCIÓN: Dimensión explícita temporal para el análisis dinámico de tendencias.
-- ----------------------------------------------------------------------------
CREATE TABLE dim_tiempo (
    id_tiempo_dim INT PRIMARY KEY, -- Formato numérico AAAAMMDD como PK fija
    fecha_orden DATE NOT NULL,
    anio INT NOT NULL,
    mes INT NOT NULL,
    nombre_mes VARCHAR(20) NOT NULL,
    trimestre INT NOT NULL,
    dia_semana INT NOT NULL,
    CONSTRAINT unq_fecha_orden UNIQUE (fecha_orden)
);

COMMENT ON TABLE dim_tiempo IS 'Dimensión de tiempo detallada para evitar cálculos sobre campos de fecha en agregaciones pesadas.';

-- ----------------------------------------------------------------------------
-- TABLA: dim_pagos
-- DESCRIPCIÓN: Clasificación contextual de las pasarelas de pago y sus estados.
-- ----------------------------------------------------------------------------
CREATE TABLE dim_pagos (
    id_pago_dim SERIAL PRIMARY KEY,
    payment_id INT NOT NULL,
    metodo_pago VARCHAR(50) NOT NULL,
    estatus_transaccion VARCHAR(50) NOT NULL,
    cantidad_pagada NUMERIC(12, 2) NOT NULL
);

COMMENT ON TABLE dim_pagos IS 'Dimensión que agrupa las transacciones por método y estado de confirmación del cobro.';

-- ----------------------------------------------------------------------------
-- TABLA DE HECHOS: fact_ventas
-- DESCRIPCIÓN: Tabla central que registra métricas cuantitativas a nivel de ítem por pedido.
-- ----------------------------------------------------------------------------
CREATE TABLE fact_ventas (
    id_ventas_dim SERIAL PRIMARY KEY,
    id_cliente_dim INT NOT NULL,
    id_producto_dim INT NOT NULL,
    id_tiempo_dim INT NOT NULL,
    id_pago_dim INT NOT NULL,
    order_id INT NOT NULL,
    order_item_id INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario NUMERIC(12, 2) NOT NULL,
    monto_total_item NUMERIC(12, 2) NOT NULL,
    estado_envio VARCHAR(50) NOT NULL,
    calificacion INT NOT NULL,
    transportista VARCHAR(50) NOT NULL,
    -- Restricciones de integridad referencial (Foreign Keys)
    CONSTRAINT fk_fact_cliente FOREIGN KEY (id_cliente_dim) REFERENCES dim_clientes(id_cliente_dim),
    CONSTRAINT fk_fact_producto FOREIGN KEY (id_producto_dim) REFERENCES dim_productos(id_producto_dim),
    CONSTRAINT fk_fact_tiempo FOREIGN KEY (id_tiempo_dim) REFERENCES dim_tiempo(id_tiempo_dim),
    CONSTRAINT fk_fact_pago FOREIGN KEY (id_pago_dim) REFERENCES dim_pagos(id_pago_dim)
);

COMMENT ON TABLE fact_ventas IS 'Tabla de hechos central. Mantiene las métricas transaccionales con granularidad por ítem de pedido.';



