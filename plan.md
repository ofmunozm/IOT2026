# Plan para organizar credenciales y subir el proyecto a GitHub

Este documento describe los pasos necesarios para mover las credenciales sensibles a un archivo seguro, documentar el proyecto y subirlo a un repositorio en GitHub.

---

## 1. Mover credenciales a `secrets.h`

1. Abre el archivo `secrets.h` y agrega las credenciales correctas:
   ```cpp
   const char ssid[] = "APT 301";
   const char pass[] = "Nano2021";
   const char MQTT_USER[] = "of.munoz";
   const char MQTT_PASS[] = "202214164";
   ```

2. En el archivo `sketch_jan28a_copy_20260129080450.ino`, elimina las credenciales actuales y asegúrate de que las constantes sean referenciadas desde `secrets.h`.

---

## 2. Actualizar `.gitignore`

1. Verifica que el archivo `secrets.h` esté incluido en el archivo `.gitignore` para evitar que se suba al repositorio.
   ```
   reto1/sketch_jan28a_copy_20260129080450/secrets.h
   ```

2. Si el archivo `secrets.h` ya fue agregado al repositorio, elimínalo del índice con el siguiente comando:
   ```zsh
   git rm --cached reto1/sketch_jan28a_copy_20260129080450/secrets.h
   ```

---

## 3. Crear un archivo `secrets_example.h`

1. Crea un archivo llamado `secrets_example.h` con el siguiente contenido:
   ```cpp
   const char ssid[] = "YOUR_WIFI_SSID";
   const char pass[] = "YOUR_WIFI_PASSWORD";
   const char MQTT_USER[] = "YOUR_MQTT_USER";
   const char MQTT_PASS[] = "YOUR_MQTT_PASSWORD";
   ```

2. Este archivo se subirá al repositorio para que otros usuarios sepan cómo configurar sus credenciales.

---

## 4. Crear un archivo `README.md`

1. Crea un archivo `README.md` en la raíz del proyecto con el siguiente contenido:
   ```markdown
   # IoT Project

   Este proyecto contiene retos relacionados con IoT. Actualmente, incluye el reto1.

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

   - `reto1/`: Contiene el código fuente del primer reto.
   ```

---

## 5. Probar los cambios

1. Verifica que el proyecto funcione correctamente con el archivo `secrets.h` local.

---

## 6. Subir el proyecto a GitHub

1. Realiza un commit con los cambios (excluyendo `secrets.h`) y sube el proyecto al repositorio:
   ```zsh
   git add .
   git commit -m "Organiza credenciales y agrega documentación"
   git push -u origin main
   ```

---

## Consideraciones adicionales

1. **Seguridad**:
   - Asegúrate de que `secrets.h` no se suba accidentalmente al repositorio.

2. **Documentación clara**:
   - El archivo `README.md` debe ser claro para que otros usuarios puedan configurar el proyecto fácilmente.