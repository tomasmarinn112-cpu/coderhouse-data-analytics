# coderhouse-data-analytics
RetailPro · Proyecto de Data Analytics

Proyecto integral de análisis de datos para RetailPro, una tienda minorista. Abarca el flujo completo: modelo relacional en SQL, consultas de negocio, ETL y limpieza en Power Query, y un modelo dimensional en estrella en Power BI con medidas DAX.

Proyecto desarrollado como entrega del curso de Data Analytics (Coderhouse).

📌 Descripción

El objetivo es responder preguntas clave del negocio y dejar los datos prontos para pasar a accionar, basándonos en datos reales a partir de lo que vamos desglosando, gracias a las tablas y las vinculaciones entre sí, que dejan entrever tendencias y nos hacen entender el negocio de mejor manera, para luego decidir con un criterio propio y ayudándonos con estadísticas reales.

Modelo relacional en SQL: creación de tablas (Clientes, Categorias, Productos, Ventas), claves e inserción de datos.
Consultas SQL de negocio: JOIN, agregaciones y rankings para responder las preguntas del Brief.
ETL y limpieza en Power Query: tipado, depuración y transformación de los datos.
Modelo en estrella en Power BI: medidas DAX de agregación, filtrado e inteligencia de tiempo.


🛠️ Herramientas utilizadas
Etapa	Herramienta
Base de datos y consultas	SQL Server (T-SQL) y SQL Server Management Studio (SSMS)
ETL y limpieza	Power Query
Modelado y visualización	Power BI Desktop
Medidas	DAX
Control de versiones	Git y GitHub
🚀 Cómo ejecutar los scripts SQL

1. Crear la base de datos

Abrí SSMS, conectate a tu instancia y ejecutá:

sql
CREATE DATABASE RetailPro;
GO
USE RetailPro;
GO
2. Ejecutar los scripts en orden

Abrí y ejecutá los archivos de la carpeta sql/ en este orden:

01_Ventas_Tech_DB.sql: crea las tablas e ingresa sus datos.
02_m4_consultas_negocio.sql: consultas básicas y cálculos en SQL para poder analizar estos datos.
03_m5_consultas_joins.sql: consultas para cruzar tablas de hechos y tablas descriptivas.
3. Verificar la carga
sql
SELECT COUNT(*) FROM dbo.Ventas;

Este proceso es el recomendado para crear una base de datos y a su vez verificar que el ingreso de los mismos sea correcto. Es un proceso adaptable a cualquier base de datos, modificando siempre los nombres y los conjuntos de datos a cada contexto.

👤 Autor

Nombre: [Tomás Marín] LinkedIn: [https://www.linkedin.com/in/tom%C3%A1s-mar%C3%ADn-8a2b98326/] Email: [tomasmarinn112@gmail.com] GitHub: tomasmarinn112-cpu
