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
-- - Ventas (tabla de hechos transaccional)
-- - Clientes (dimensión cliente: nombre, email, ciudad)
-- - Productos (dimensión producto: nombre_producto, precio)
-- - Categorias (dimensión categoría: nombre_categoria)
-- =============================================================================
SELECT
    v.id_venta,
    v.fecha_venta,
    c.nombre AS nombre_cliente,
    p.nombre_producto,
    cat.nombre_categoria,
    v.cantidad,
    v.precio_unitario,
    ROUND(v.cantidad * v.precio_unitario, 2) AS total_venta
FROM Ventas v
INNER JOIN Clientes c ON v.id_cliente = c.id_cliente
INNER JOIN Productos p ON v.id_producto = p.id_producto
INNER JOIN Categorias cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta, v.id_venta;
-- Hallazgo:
-- La consulta devuelve 10 filas, igual a los 10 registros de Ventas, por lo que el INNER JOIN
-- no descarta ninguna transacción (todas tienen cliente, producto y categoría asociados).
-- La facturación total consolidada es de 6.444 y la salida queda lista como base para Power BI.
-- =============================================================================
-- CONSULTA 2: Clientes sin compras (LEFT JOIN con filtro IS NULL)
-- =============================================================================
-- Propósito:
-- Identificar clientes registrados sin transacciones asociadas para diseñar
-- estrategias de reactivación comercial. Se incluyen email y fecha_registro para que
-- el equipo de marketing pueda contactar a cada cliente y segmentar por antigüedad.
--
-- Tablas relacionadas:
-- - Clientes (maestro de clientes registrados: id_cliente, nombre, email, fecha_registro)
-- - Ventas (transacciones históricas)
-- =============================================================================
SELECT
    c.id_cliente,
    c.nombre AS nombre_cliente,
    c.email,
    c.fecha_registro,
    v.id_venta
FROM Clientes c
LEFT JOIN Ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;
-- Hallazgo:
-- Con los datos actuales la consulta devuelve 0 filas: los 5 clientes registrados realizaron
-- al menos una compra (2 compras cada uno). Por ahora no hay clientes para reactivar; la consulta
-- queda lista para detectarlos cuando existan clientes registrados sin transacciones.
-- =============================================================================
-- CONSULTA 3: Productos sin ventas (LEFT JOIN con filtro IS NULL)
-- =============================================================================
-- Propósito:
-- Detectar artículos del catálogo que no registran transacciones en la tabla de ventas.
-- Esta consulta permite al equipo de inventario y compras identificar productos sin rotación
-- (stock estancado) para definir estrategias comerciales (descuentos, promociones o liquidación).
--
-- Tablas relacionadas:
-- - Productos (catálogo completo de artículos)
-- - Categorias (para contextualizar la categoría del producto no vendido)
-- - Ventas (tabla transaccional para verificar si hubo o no movimiento)
-- =============================================================================
SELECT
    p.id_producto,
    p.nombre_producto,
    c.nombre_categoria,
    p.precio,
    p.stock
FROM Productos p
LEFT JOIN Categorias c
    ON p.id_categoria = c.id_categoria
LEFT JOIN Ventas v
    ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;
-- Hallazgo:
-- Con los datos actuales la consulta devuelve 0 filas: los 6 productos del catálogo registran
-- al menos una venta entre el 05/03/2024 y el 15/03/2024, por lo que no hay productos sin rotación.
-- El producto con menor facturación es Auriculares BT Pro (360 en 3 unidades), el que conviene
-- monitorear si se repite una baja rotación en períodos más largos.
-- =============================================================================
-- CONSULTA 4: Consolidación de ventas por segmento de ticket (UNION ALL)
-- =============================================================================
-- Propósito:
-- Consolidar mediante UNION ALL dos bloques de ventas, discriminados por la columna
-- literal segmento_venta: ventas con ticket igual o superior al ticket promedio y ventas
-- con ticket inferior. Permite medir cuánto de la facturación depende de las ventas grandes.
-- La columna segmento_venta se define como un literal en cada bloque SELECT para unificar
-- los registros y permitir una agregación global de ingresos y volumen de operaciones.
-- Los dos bloques son excluyentes (>= y <), por lo que ninguna venta se cuenta dos veces.
--
-- Tablas relacionadas:
-- - Ventas (id_venta, cantidad, precio_unitario, fecha_venta)
-- =============================================================================
SELECT
    segmento_venta,
    COUNT(*) AS cantidad_operaciones,
    SUM(monto_total) AS total_recaudado
FROM (
    -- Bloque 1: Ventas con ticket igual o superior al promedio
    SELECT
        v.id_venta,
        v.fecha_venta,
        (v.cantidad * v.precio_unitario) AS monto_total,
        'Ticket igual o superior al promedio' AS segmento_venta
    FROM Ventas v
    WHERE (v.cantidad * v.precio_unitario) >= (SELECT AVG(cantidad * precio_unitario) FROM Ventas)
    UNION ALL
    -- Bloque 2: Ventas con ticket inferior al promedio
    SELECT
        v.id_venta,
        v.fecha_venta,
        (v.cantidad * v.precio_unitario) AS monto_total,
        'Ticket inferior al promedio' AS segmento_venta
    FROM Ventas v
    WHERE (v.cantidad * v.precio_unitario) < (SELECT AVG(cantidad * precio_unitario) FROM Ventas)
) AS consolidado_ventas
GROUP BY segmento_venta
ORDER BY total_recaudado DESC;
-- Hallazgo:
-- 3 de las 10 operaciones (30%) tienen un ticket igual o superior al promedio de 644,40 y suman
-- 4.500 de los 6.444 facturados (69,8%); las otras 7 operaciones suman 1.944 (30,2%).
-- La facturación depende de pocas ventas grandes, por lo que conviene proteger esas cuentas
-- y trabajar el ticket de las ventas menores (por ejemplo, con venta cruzada).
