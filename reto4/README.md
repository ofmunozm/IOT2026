# Reto 4: Capa de Datos IoT - Análisis de Rendimiento Masivo

## Descripción
Este reto consistió en la implementación de un endpoint de análisis en una arquitectura Django/PostgreSQL desplegada en AWS. Se evaluó la capacidad de respuesta del sistema al realizar cálculos de promedios sobre un volumen de **500,001 registros** de telemetría bajo carga concurrente.

## Tecnologías Utilizadas
* **AWS EC2 (t2.micro)**: Servidor de aplicación y base de datos (IP: 44.206.254.92).
* **PostgreSQL 14.21**: Motor de persistencia para datos IoT masivos.
* **Django**: Framework para la exposición del endpoint JSON `/api/promedio/`.
* **Apache JMeter 5.6.3**: Ejecución de pruebas de carga (50 hilos).

## Resultados de la Prueba de Carga
Basado en las pruebas de JMeter, el sistema demostró alta estabilidad (0.00% de error), aunque con una latencia representativa del volumen de datos procesado.

| Métrica | Valor Obtenido |
| :--- | :--- |
| **Muestras (# Samples)** | 50 |
| **Latencia Promedio (Average)** | **739 ms** |
| **Rendimiento (Throughput)** | 18.9 msg/s |
| **Tasa de Error** | 0.00% |

## Conclusiones Técnicas
1. **Estabilidad**: El servidor en AWS resistió las peticiones concurrentes sin fallos de red o base de datos.
2. **Impacto del Volumen**: La latencia promedio de **739 ms** se debe al escaneo secuencial requerido por PostgreSQL para procesar medio millón de filas.
3. **Optimización**: Se identifica a **TimescaleDB** como la solución ideal para reducir esta latencia en producción, utilizando **Hypertables** para segmentar los datos por tiempo y evitar escaneos totales de tabla.
