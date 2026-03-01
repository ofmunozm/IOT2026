# Reto 1: Sensor LDR - Luminosidad

## Descripción

En este reto, se implementó un sensor LDR para medir la luminosidad y transmitir los datos a través de MQTT. El sensor está conectado al pin analógico `A0` de la placa, y los valores se convierten a lux aproximados antes de ser enviados.

## Funcionamiento

1. **Lectura del LDR**:
   - El sensor LDR genera un valor analógico proporcional a la intensidad de luz.
   - Este valor se encuentra en el rango de 0 a 1023.

2. **Conversión a lux**:
   - Se utiliza la función `map` para escalar el valor analógico a un rango aproximado de 0 a 1000 lux:
     ```cpp
     int lux = map(ldrValue, 0, 1023, 0, 1000);
     ```

3. **Transmisión de datos**:
   - Los datos se envían en formato JSON al servidor MQTT en el tópico `luminosidad/bogota/of.munoz`:
     ```json
     {"value": (valor en lux)}
     ```

4. **Impresión en el monitor serie**:
   - Los valores también se imprimen en el monitor serie para verificar su funcionamiento:
     ```
     luminosidad/bogota/of.munoz -> {"value": 500}
     ```

## Conexión del hardware

- **LDR**:
  - Un pin conectado a 3.3V.
  - El otro pin conectado al nodo de lectura (A0) y a una resistencia de 10kΩ que va a GND.

## Resultados esperados

- Los valores de luminosidad se envían al servidor MQTT y se imprimen en el monitor serie.
- Los valores en lux varían según la intensidad de luz que incide sobre el sensor.

## Configuración de credenciales

Para configurar las credenciales necesarias para la conexión, sigue estos pasos:

1. Copia el archivo `secrets_example.h` y renómbralo como `secrets.h`.
2. Llena los valores de las credenciales en `secrets.h`:
   - `ssid`: Nombre de tu red WiFi.
   - `pass`: Contraseña de tu red WiFi.
   - `MQTT_USER`: Usuario para la conexión MQTT.
   - `MQTT_PASS`: Contraseña para la conexión MQTT.

**Nota:** El archivo `secrets.h` no se sube al repositorio por razones de seguridad.