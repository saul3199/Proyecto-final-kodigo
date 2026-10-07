# 🛒 Tienda en Linea — Data Warehouse & Analytics

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Data%20Warehouse-336791?logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-ETL-4479A1?logo=databricks&logoColor=white)
![Metabase](https://img.shields.io/badge/Metabase-BI-509EE3?logo=metabase&logoColor=white)
![Git](https://img.shields.io/badge/Git-Version%20Control-F05032?logo=git&logoColor=white)
![Status](https://img.shields.io/badge/Status-En%20desarrollo-yellow)

## 🎓 Proyecto Final — Kodigo

Proyecto académico enfocado en el diseño e implementación de una solución de **ETL, Data Mart y Visualizacion de datos ** para el análisis de información proveniente de una tienda online.

El proyecto parte de un **modelo transaccional (OLTP)** y desarrolla un proceso de transformación mediante **ETL**, con el objetivo de construir un **modelo dimensional tipo estrella (Star Schema)** orientado al análisis y generación de indicadores de negocio.

---

## 📌 Descripción del proyecto

Este proyecto tiene como objetivo diseñar e implementar una solución de
**Business Intelligence** para una tienda online, transformando datos
transaccionales en un **Data Warehouse / Data Mart dimensional** orientado
al análisis estratégico de las ventas y al apoyo en la toma de decisiones.

El proyecto parte de un conjunto de datos transaccionales que contiene
información relacionada con órdenes, productos, clientes, pagos, envíos
y calificaciones. A partir de estos datos se desarrolla un proceso
integral que comprende **modelado dimensional, transformación y carga de
datos, optimización de consultas y visualización de indicadores
estratégicos**.

La solución se estructura bajo un enfoque de **Modelo de Estrella
(Star Schema)**, donde una tabla de hechos concentra las métricas de
ventas y se relaciona directamente con dimensiones de análisis como
productos, clientes, pagos y tiempo.

El proyecto no se limita a la construcción del modelo de datos, sino que
incluye controles de calidad, reglas de transformación, optimización del
rendimiento y un Dashboard Ejecutivo orientado al análisis de resultados.

---

## 🎯 Objetivos

### Objetivo general

Diseñar e implementar un **Data Mart de ventas** que permita transformar datos transaccionales en información confiable, estructurada y optimizada para el análisis empresarial, utilizando técnicas de modelado dimensional, procesos ETL, optimización SQL y herramientas de visualización.


### Objetivos específicos

- Diseñar un **Modelo de Estrella** con una tabla de hechos y al menos
  tres dimensiones.
- Definir claramente la **granularidad** de la tabla de hechos.
- Implementar **claves subrogadas** independientes de los identificadores
  del sistema transaccional.
- Garantizar la **integridad referencial** mediante claves primarias,
  claves foráneas y restricciones de integridad.
- Desarrollar un proceso ETL para limpiar, transformar y cargar los
  datos hacia el Data Mart.
- Aplicar reglas de **limpieza y estandarización** sobre los datos
  transaccionales.
- Utilizar **CTEs (Common Table Expressions)** para estructurar las
  transformaciones SQL de manera modular y reutilizable.
- Analizar y mejorar el rendimiento de consultas mediante
  `EXPLAIN ANALYZE`.
- Implementar índices y otras técnicas de optimización justificadas
  mediante evidencia de rendimiento.
- Construir un **Dashboard Ejecutivo** con cinco KPIs estratégicos.
- Incorporar filtros dinámicos que permitan explorar la información
  desde diferentes perspectivas.
- Interpretar los resultados obtenidos mediante técnicas de
  **Data Storytelling**.

---

## 🏗️ Arquitectura de la solución

La solución sigue un flujo de procesamiento de datos desde el sistema transaccional hasta la capa de análisis:

```text

┌──────────────────────────────┐
│     FUENTE TRANSACCIONAL     │
│                              │
│  orders                      │
│  order_items                 │
│  products                    │
│  customers                   │
│  payments                    │
│  shipments                   │
│  reviews                     │
└──────────────┬───────────────┘
               │
               │ Extracción
               ▼
┌──────────────────────────────┐
│       PROCESO ETL / SQL      │
│                              │
│  • Limpieza de datos         │
│  • Tratamiento de NULL       │
│  • Estandarización           │
│  • Transformaciones          │
│  • CTEs                      │
│  • Generación de SK          │
│  • Validaciones              │
└──────────────┬───────────────┘
               │
               │ Carga
               ▼
┌──────────────────────────────┐
│       DATA MART DE VENTAS    │
│       ⭐ STAR SCHEMA          │
│                              │
│        fact_ventas           │
│             │                │
│     ┌───────┼────────┐       │
│     ▼       ▼        ▼       │
│ dim_productos dim_clientes   │
│     │       │                │
│     └───────┼────────┐       │
│             ▼        ▼       │
│         dim_pagos dim_tiempo │
└──────────────┬───────────────┘
               │
               │ Consulta
               ▼
┌──────────────────────────────┐
│      BUSINESS INTELLIGENCE   │
│                              │
│       Dashboard Ejecutivo    │
│                              │
│  • 5 KPIs                    │
│  • Filtros                   │
│  • Gráficos                  │
│  • Data Storytelling         │
└──────────────────────────────┘

```

---
## 📁 Estructura de Archivos

```text
proyecto_final_kodigo/
│
├── README.md
│
├── 📂 01_trasaccional/
│   ├── diagrama_transaccional.png
│   ├── script_creacion_tablas_transaccionales.sql
│   ├── backup_tablas_transaccionales.backup
│   └── 📂 dataset/
│       ├── 📂 csv/
│       |   ├── customers.csv
|       │   ├── orders.csv
|       │   ├── order_items.csv
|       │   ├── products.csv
|       │   ├── payments.csv
|       │   ├── shipments.csv
|       │   └── reviews.csv
│       |
|       └── 📂 sql/
|           ├── customers.sql
|           ├── orders.sql
|           ├── order_items.sql
|           ├── products.sql
|           ├── payments.sql
|           ├── shipments.sql
|           └── reviews.sql
│
│
├── 📂 02_data_mart/
│   ├── diagrama_datamart.png
│   └── script_creacion_datamart.sql
│
├── 📂 03_etl/
│   └── script_etl_datamart_incremental.sql
│
├── 📂 04_optimizacion/
│
├── 📂 05_kpis/
|   ├── ordenes_por_categoria.sql
|   ├── ventas_totales.sql
|   ├── numero_ordenes.sql
|   ├── unidades_vendidas.sql
|   ├── ticket_promedio.sql
|   ├── crecimiento_ventas.sql
|   ├── ventas_por_categoria.sql
|   ├── top_productos.sql
|   ├── top_clientes.sql
|   ├── ventas_por_metodo_pago.sql
|   └── rating_promedio.sql
│
└── 📂 06_docs/
    └── screenshots/
```
---
## 🚀 Guía de ejecución

#### 📝 Requisitos

Antes de ejecutar el proyecto se requiere:

- PostgreSQL 14 o superior
- Git
- DBeaver, pgAdmin o psql
- Acceso a una base de datos PostgreSQL

---

### 1. Clonar el repositorio

```bash
git clone https://github.com/saul3199/Proyecto-final-kodigo.git
cd Proyecto-final-kodigo

```
### 2. Tablas transaccionales

* Crear un esquema dedicado a la data transaccional llamado *pf_org* en postgres
* La obtencion de la data para estas tablas puede crearse de dos formas
  1. Por medio de un backup
    - Restaurar el backup en el esquema creado anteriormente alojado en la ruta: 01_transacciones/backup_tablas_transaccionales.backup
  2. Creando las tablas y populando sus datos
    - Ejecutar el script que se encuentra en la ruta -> 01_transaccional / script_creacion_tablas_transaccionales.sql
    - Ejecutar cada uno de los sql de populacion de la data que se encuentran dentro de la carpeta sql en la ruta -> 01_transaccional / dataset / sql

### 3. Creacion de tablas datamart

  * Crear un esquema dedicado al datamart llamado *pf_dw* en postgres
  * Ejecutar el script que se encuentra en la ruta -> 02_data_mart / script_creacion_datamart.sql

### 4. ETL para la transformacion de la data de transaccional al datamart

  * Ejecutar el script que se encuentra en la ruta -> 03_etl / script_etl_datamart_incremental.sql
  * Ejecutar la funcion creada y validar la data.

### 5. Replica de KPI's

  * Ejecutar cada una de las consultas dentro de la ruta -> 05_kpis

---

## 📝 Recursos del proyecto

### 📊 Base de datos
[Dataset de Online Shop 2024 - Kaggle](https://www.kaggle.com/datasets/marthadimgba/online-shop-2024?select=orders.csv)

### 📄 Documento del proyecto
[Tareas](https://docs.google.com/document/d/1OaAwFlGIGKgvpDtrQTtGTqhcQu067WGN2IBpY6JLOWA/edit?tab=t.0)

### 📁 Archivos del proyecto
[Esquema de relaciones](https://drive.google.com/file/d/1O42l3SSvMYu1Kf7ej7TM7rq_HPYuajGo/view)


