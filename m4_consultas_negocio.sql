SELECT * 
FROM dbo.Ventas;

-- consulta 1
SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes ASC;

--consulta 2
SELECT TOP 5
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_generado
FROM dbo.Ventas
GROUP BY id_producto
ORDER BY total_generado DESC;

--consulta 3
SELECT 
    id_cliente,
    COUNT(*) AS cantidad_compras,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM dbo.Ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY cantidad_compras DESC, total_gastado DESC;

--consulta 4
SELECT 
    MONTH(fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_mes,
    CASE 
        WHEN SUM(cantidad * precio_unitario) >= 644.400000 THEN 'Por encima'
        ELSE 'Por debajo'
    END AS rendimiento_vs_promedio
FROM dbo.Ventas
GROUP BY MONTH(fecha_venta)
ORDER BY mes ASC;

--El total de las ventas ha sido efectuado en Marzo, los demás meses no ha habido ventas de parte de la empresa.
--El producto número 1 ha generado el 55,86% de la facturación de la empresa (generó 3600 y el total de ventas fue de 6444).
--Todos los clientes que realizaron al menos 1 compra, repitieron la misma. 