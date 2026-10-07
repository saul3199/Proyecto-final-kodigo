# 🛒 Online Shop — Data Warehouse & Analytics

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-Data%20Warehouse-336791?logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-ETL-4479A1?logo=databricks&logoColor=white)
![Metabase](https://img.shields.io/badge/Metabase-BI-509EE3?logo=metabase&logoColor=white)
![Git](https://img.shields.io/badge/Git-Version%20Control-F05032?logo=git&logoColor=white)
![Status](https://img.shields.io/badge/Status-En%20desarrollo-yellow)

## 🎓 Proyecto Final — Kodigo

Proyecto académico enfocado en el diseño e implementación de una solución de **Data Warehouse y Data Mart** para el análisis de información proveniente de una tienda online.

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

Diseñar e implementar un **Data Warehouse orientado al análisis de ventas de una tienda online**, utilizando procesos ETL y un modelo dimensional tipo estrella que permita obtener información confiable para el análisis de ventas, clientes, productos, pagos y logística.

## Objetivos específicos

- Analizar la estructura y características de los datos transaccionales.
- Identificar las entidades y atributos relevantes para el análisis.
- Diseñar un modelo dimensional basado en un esquema estrella.
- Implementar dimensiones con claves subrogadas.
- Definir la granularidad de la tabla de hechos.
- Construir la tabla `fact_ventas`.
- Implementar las dimensiones de productos, clientes, pagos y tiempo.
- Realizar procesos de extracción, transformación y carga (ETL).
- Validar la integridad y calidad de los datos.
- Construir consultas para la generación de KPIs.
- Presentar los resultados mediante una herramienta de Business Intelligence.

---

# 🏗️ Arquitectura de la solución

La solución sigue un flujo de procesamiento de datos desde el sistema transaccional hasta la capa de análisis:

```text
┌─────────────────────────────┐
│     SISTEMA TRANSACCIONAL   │
│            OLTP             │
│                             │
│  Orders                     │
│  Order Items                │
│  Products                   │
│  Customers                  │
│  Payments                   │
│  Reviews                    │
│  Shipments                  │
└──────────────┬──────────────┘
               │
               │ Extract
               ▼
┌─────────────────────────────┐
│           STAGING           │
│                             │
│ Datos temporales            │
│ Validación                  │
│ Limpieza                    │
│ Estandarización             │
└──────────────┬──────────────┘
               │
               │ Transform / Load
               ▼
┌─────────────────────────────┐
│       DATA WAREHOUSE        │
│                             │
│ Modelo dimensional          │
│ Claves subrogadas           │
│ Integridad referencial      │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│          DATA MART          │
│                             │
│       ⭐ Star Schema        │
│                             │
│      fact_ventas            │
│      dim_productos          │
│      dim_clientes           │
│      dim_pagos              │
│      dim_tiempo             │
└──────────────┬──────────────┘
               │
               ▼
┌─────────────────────────────┐
│       BUSINESS INTELLIGENCE │
│                             │
│          Metabase           │
│                             │
│       KPIs / Dashboards     │
└─────────────────────────────┘
```

## Recursos del proyecto

### 📊 Base de datos
[Dataset de Online Shop 2024 - Kaggle](https://www.kaggle.com/datasets/marthadimgba/online-shop-2024?select=orders.csv)

### 📄 Documento del proyecto
[Tareas](https://docs.google.com/document/d/1OaAwFlGIGKgvpDtrQTtGTqhcQu067WGN2IBpY6JLOWA/edit?tab=t.0)

### 📁 Archivos del proyecto
[Esquema de relaciones](https://drive.google.com/file/d/1O42l3SSvMYu1Kf7ej7TM7rq_HPYuajGo/view)
