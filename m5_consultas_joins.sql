-- =============================================================================
-- CONSULTA 1: Vista enriquecida de ventas (INNER JOIN)
-- =============================================================================
-- Objetivo de negocio:
-- Consolidar en una única salida analítica el detalle transaccional de ventas,
-- combinando la información de clientes, productos y categorías mediante INNER JOIN.
-- Esta consulta responde a las preguntas estratégicas planteadas en el Brief (M1)
-- sobre volumen de facturación por cliente y rendimiento por categoría de producto,
-- y sirve como base para la ingesta de datos en herramientas de visualización (Power BI).
--
-- Tablas relacionadas:
-- - ventas (tabla de hechos transaccional)
-- - clientes (dimensión cliente: nombre, email, ciudad)
-- - productos (dimensión producto: nombre_producto, precio)
-- - categorias (dimensión categoría: nombre_categoria)
-- =============================================================================
SELECT 
    v.id_venta,
    v.fecha_venta,
    c.nombre AS nombre_cliente,
    p.nombre_producto,
    cat.nombre_categoría,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta
FROM dbo.Ventas v
INNER JOIN dbo.Clientes c ON v.id_cliente = c.id_cliente
INNER JOIN dbo.Productos p ON v.id_producto = p.id_producto
INNER JOIN dbo.Categorias cat ON p.id_categoria = cat.id_categoria;

-- Hallazgo: Se consolidaron las 10 transacciones registradas vinculando clientes, productos y categorías, permitiendo analizar el detalle de facturación por línea de producto


-- =====================================================
-- Consulta 2: Clientes sin compras (LEFT JOIN)
-- Propósito: Identificar clientes registrados sin transacciones asociadas.
-- =====================================================
SELECT 
    c.id_cliente,
    c.nombre AS nombre_cliente,
    v.id_venta
FROM dbo.Clientes c
LEFT JOIN dbo.Ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;

-- Hallazgo: en mi empresa hay 2 clientes que se han registrado y nunca han realizado una transacción. ¿Que deberíamos hacer para
-- captar su atención?




-- =============================================================================
-- CONSULTA 3: Productos sin ventas (LEFT JOIN con filtro IS NULL)
-- =============================================================================
-- Propósito:
-- Detectar artículos del catálogo que no registran transacciones en la tabla de ventas.
-- Esta consulta permite al equipo de inventario y compras identificar productos sin rotación
-- (stock estancado) para definir estrategias comerciales (descuentos, promociones o liquidación).
--
-- Tablas relacionadas:
-- - productos (catálogo completo de artículos)
-- - categorias (para contextualizar la categoría del producto no vendido)
-- - ventas (tabla transaccional para verificar si hubo o no movimiento)
-- =============================================================================
SELECT 
    p.id_producto,
    p.nombre_producto,
    c.nombre_categoría,
    p.precio,
    p.stock
FROM productos p
LEFT JOIN categorias c 
    ON p.id_categoria = c.id_categoria
LEFT JOIN ventas v 
    ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;
-- Hallazgo:
-- Todos los productos cargados en el catálogo (Laptop, Mouse, Monitor, Auriculares,
-- SSD y Teclado) menos las placas de video, lo que nos hace replantearnos si quizás estan demasiado caras o no sea un producto tan atractivo.

-- =============================================================================
-- CONSULTA 4: Consolidación de ingresos por modalidad de cobro (UNION ALL)
-- =============================================================================
-- Propósito:
-- Consolidar mediante UNION ALL las operaciones de RetailPro, discriminando entre
-- cobros electrónicos (Tarjeta de Débito y Tarjeta de Crédito en hasta 3 cuotas) y
-- cobros directos en efectivo.
-- La columna modalidad_cobro se define como un literal en cada bloque SELECT para
-- unificar los registros y permitir una agregación global de ingresos y volumen
-- de operaciones por canal financiero.
--
-- Tablas relacionadas:
-- - Ventas (id_venta, cantidad, precio_unitario, fecha_venta)
-- - Pagos (id_pagos, id_clientes, id_venta, id_producto, metodo_de_pago, cuotas)
-- =============================================================================
SELECT 
    modalidad_cobro,
    COUNT(*) AS cantidad_operaciones,
    SUM(monto_total) AS total_recaudado
FROM (
    -- Bloque 1: Cobros electrónicos con Tarjetas (Débito y Crédito en 1, 2 o 3 cuotas)
    SELECT 
        v.id_venta,
        v.fecha_venta,
        (v.cantidad * v.precio_unitario) AS monto_total,
        p.cuotas,
        'Cobro Electrónico / Tarjeta' AS modalidad_cobro
    FROM Ventas v
    INNER JOIN Pagos p 
        ON v.id_venta = p.id_venta
    WHERE p.metodo_de_pago IN ('Tarjeta de Débito', 'Tarjeta de Crédito')
    UNION ALL
    -- Bloque 2: Cobros directos en Efectivo (1 cuota)
    SELECT 
        v.id_venta,
        v.fecha_venta,
        (v.cantidad * v.precio_unitario) AS monto_total,
        p.cuotas,
        'Cobro Directo / Efectivo' AS modalidad_cobro
    FROM Ventas v
    INNER JOIN Pagos p 
        ON v.id_venta = p.id_venta
    WHERE p.metodo_de_pago = 'Efectivo'
) AS consolidado_pagos
GROUP BY modalidad_cobro;

-- Hallazgo:
-- El cobro a través de tarjetas (débito y crédito financiado en 1, 2 y 3 cuotas)
-- concentra 7 de las 10 operaciones y la mayor parte del monto total facturado,
-- evidenciando que los clientes prefieren medios de pago electrónicos y financiamiento, por lo tanto podríamos crear 
-- promociones con las tarjetas de credito y debito más utilizados.
