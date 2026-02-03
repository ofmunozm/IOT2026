# IoT MISO 2026

Este proyecto contiene retos relacionados con IoT. Actualmente, incluye los siguientes retos:

- [Reto 1: Sensor LDR](reto1/README.md)
- [Reto 2: Simulación de redes de sensores IoT con CupCarbon](reto2/README.md)

## Configuración de credenciales

Para configurar las credenciales necesarias para la conexión, sigue estos pasos:

1. Copia el archivo `secrets_example.h` y renómbralo como `secrets.h`.
2. Llena los valores de las credenciales en `secrets.h`:
   - `ssid`: Nombre de tu red WiFi.
   - `pass`: Contraseña de tu red WiFi.
   - `MQTT_USER`: Usuario para la conexión MQTT.
   - `MQTT_PASS`: Contraseña para la conexión MQTT.

**Nota:** El archivo `secrets.h` no se sube al repositorio por razones de seguridad.

## Estructura del proyecto

- `reto1/`: Código fuente del primer reto (sensor LDR con MQTT).
- `reto2/`: Proyecto de simulación de redes de sensores IoT con CupCarbon (Zigbee, WiFi, LoRa).