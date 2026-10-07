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

# 🎯 Objetivos

## Objetivo general

Diseñar e implementar un **Data Mart de ventas** que permita transformar datos transaccionales en información confiable, estructurada y optimizada para el análisis empresarial, utilizando técnicas de modelado dimensional, procesos ETL, optimización SQL y herramientas de visualización.


## Objetivos específicos

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

# 🏗️ Arquitectura de la solución

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
### 📁 Estructura de Archivos

```text
online-shop-datawarehouse/
│
├── README.md
│
├── docs/
│   ├── modelo-transaccional.png
│   ├── modelo-estrella.png
│   ├── arquitectura.md
│   ├── granularidad.md
│   ├── claves-subrogadas.md
│   └── kpis.md
│
├── sql/
│   ├── 01_source/
│   ├── 02_staging/
│   ├── 03_dimensions/
│   ├── 04_facts/
│   ├── 05_constraints/
│   └── 06_kpis/
│
├── etl/
│   ├── extract/
│   ├── transform/
│   └── load/
│
├── tests/
│
└── dashboard/
    └── screenshots/
```
## Recursos del proyecto

### 📊 Base de datos
[Dataset de Online Shop 2024 - Kaggle](https://www.kaggle.com/datasets/marthadimgba/online-shop-2024?select=orders.csv)

### 📄 Documento del proyecto
[Tareas](https://docs.google.com/document/d/1OaAwFlGIGKgvpDtrQTtGTqhcQu067WGN2IBpY6JLOWA/edit?tab=t.0)

### 📁 Archivos del proyecto
[Esquema de relaciones](https://drive.google.com/file/d/1O42l3SSvMYu1Kf7ej7TM7rq_HPYuajGo/view)


