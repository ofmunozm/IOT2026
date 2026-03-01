# Reto 3: Escalabilidad y Seguridad en Mensajería IoT (MQTT sobre TLS)

## Descripción

Este proyecto evalúa la capacidad de una arquitectura de mensajería IoT basada en el protocolo MQTT para gestionar ráfagas masivas de datos cifrados. Utilizando los resultados del Reto 2 como línea base, se validó si la infraestructura en la nube soporta el crecimiento de una Smart City (pasando de 21 a 1000 sensores) sin comprometer la seguridad ni la integridad de la telemetría de incendios.

## Tecnologías utilizadas

- **AWS EC2 (t2.micro)**: Servidor en la nube para el despliegue del broker en la región us-east-1.

- **Mosquitto Broker**: Servidor de mensajería MQTT configurado con persistencia y autenticación restringida.

- **Apache JMeter 5.6.3**: Herramienta utilizada para el diseño y ejecución de pruebas de carga y estrés.

- **SSL/TLS v1.2**: Protocolo de seguridad para el cifrado de datos en tránsito a través del puerto 8082.

- **Java JKS**: Truststore para la gestión de certificados de seguridad durante el apretón de manos (handshake).

## Estructura del repositorio

```
reto3/
├── MQTTScripts/
│   ├── Escalabilidad_MQTT_Reto3.jmx  # Plan de pruebas de JMeter
│   ├── broker_truststore.jks        # Certificados de seguridad
│   └── subscriber.py                # Script de validación de recepción
├── config/                          # Archivos de configuración del broker
├── results/                         # Capturas de pantalla y reportes (50, 250, 1000 hilos)
├── logs/                            # Registros de ejecución de las pruebas
├── incendios_cerros.cup             # Proyecto base de referencia
└── README.md                        # Este archivo
```

## Instrucciones de uso

1. **Infraestructura**: Asegurarse de que el broker en la instancia AWS (IP: 54.163.93.97) esté activo y el puerto 8082 abierto.

2. **Carga de Certificados**: En JMeter, verificar que el componente MQTT Connect apunte al archivo broker_truststore.jks.

3. **Ejecución de Escenarios**:

- Para cambiar la carga, ajustar el Number of Threads en el Thread Group (50, 250 o 1000) .

- Configurar el Ramp-up proporcional (180s a 300s) para evitar colapsos por handshakes SSL simultáneos.

4. **Resultados**: Limpiar los visualizadores antes de cada corrida y observar el Aggregate Report.
---

## Desempeño del Sistema

* El sistema demostró una escalabilidad lineal eficiente, manteniendo la estabilidad bajo condiciones de estrés extremo sin degradación del servicio.

| Escenario          | Usuarios | Latencia (Avg) | Throughput   | Error % |
|--------------------|----------|---------------|-------------|---------|
| A: Base            | 50       | 91 ms         | 8.6 msg/s   | 0.00%   |
| B: Escalabilidad   | 250      | 90 ms         | 42.5 msg/s  | 0.00%   |
| C: Estrés          | 1000     | 91 ms         | 101.8 msg/s | 0.00%   |

### 2. Conclusiones Técnicas

* Se implementó un Once Only Controller que garantizó sesiones persistentes y optimizó el uso de CPU en la instancia t2.micro, eliminando errores de reconexión redundante.

* El tiempo de respuesta no se degradó a pesar de aumentar la carga en un 2000% desde el escenario inicial, demostrando que el broker y la red de AWS manejan eficientemente el cifrado TLS.

* Esta arquitectura es apta para sistemas de respuesta ante emergencias en tiempo real, soportando densidades críticas de sensores sin comprometer la integridad de la telemetría.