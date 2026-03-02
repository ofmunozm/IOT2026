# Reto 5: Capa de Aplicación — Lógica IoT

## Descripción

Plataforma de monitoreo IoT en tiempo real construida con Django. El sistema recibe datos de sensores vía MQTT, los almacena en PostgreSQL, muestra un dashboard web y envía alertas de vuelta a los dispositivos cuando los valores superan umbrales configurados.

---

## Arquitectura

El proyecto tiene tres aplicaciones Django independientes que trabajan en conjunto:

```
SENSOR (Arduino/ESP)
       │ publica MQTT
       ▼
 MQTT BROKER
  ┌────┴────┐
  │         │
  ▼         ▼
receiver  control           viewer
(escucha  (monitorea        (dashboard
  datos)   umbrales)          web)
  │         │                 │
  └────┬────┘                 │
       ▼                      ▼
   PostgreSQL  ◄──────────────┘
```

| App | Rol |
|-----|-----|
| `receiver` | Escucha mensajes MQTT y guarda datos en la BD |
| `control` | Cron cada 5 min que verifica umbrales y envía alertas a los dispositivos |
| `viewer` | Dashboard web para visualizar datos en tiempo real, mapa e histórico |

---

## Modelos de datos

- **City / State / Country / Location** — Geografía de las estaciones
- **Station** — Combinación única de usuario + ubicación
- **Measurement** — Variable medida (temperatura, humedad, etc.) con umbrales `min_value` / `max_value`
- **Data** — Almacenamiento tipo blob: múltiples lecturas por hora en arreglos `values[]` y `times[]`, con `avg_value`, `min_value`, `max_value`, `length` pre-calculados

---

## Formato del topic MQTT

```
{país}/{estado}/{ciudad}/{usuario}/out   ← sensor → servidor
{país}/{estado}/{ciudad}/{usuario}/in    ← servidor → sensor (alertas)
```

**Ejemplo payload del sensor:**
```json
{"temperatura": 22.5, "humedad": 65.0, "latitud": 4.6, "longitud": -74.0}
```

**Ejemplo alerta enviada al dispositivo:**
```
ALERT temperatura 15.0 35.0
```

---

## Requisitos

- Python 3.8+
- PostgreSQL con soporte para `ArrayField` (extensión `django.contrib.postgres`)
- Broker MQTT configurado

Instalar dependencias:
```bash
pip install django psycopg2 paho-mqtt requests schedule
```

---

## Configuración

En `IOTMonitoringServer/settings.py` ajustar:

```python
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME': '<nombre_bd>',
        'USER': '<usuario>',
        'PASSWORD': '<contraseña>',
        'HOST': '<host>',
        'PORT': '5432',
    }
}

MQTT_HOST = '<ip_broker>'
MQTT_PORT = 1883
MQTT_USER = '<usuario_mqtt>'
MQTT_PASSWORD = '<contraseña_mqtt>'
TOPIC = '#'   # suscripción a todos los topics
```

---

## Cómo correr

Cada componente corre en una terminal separada:

```bash
# 1. Crear tablas en la BD
python manage.py migrate

# 2. Crear superusuario para el panel web
python manage.py createsuperuser

# 3. Iniciar receptor MQTT (escucha datos de sensores)
python manage.py start_mqtt

# 4. Iniciar servicio de control y alertas
python manage.py start_control

# 5. Iniciar servidor web
python manage.py runserver 0.0.0.0:8000
```

---

## Simular un sensor (pruebas)

```bash
python simulador_sensor.py
```

Publica datos de temperatura aleatoria (15–25 °C) al broker MQTT cada 5 segundos usando el topic `Colombia/Bogota/Centro/Yuely/out`.

---

## Dashboard web — Rutas disponibles

| Ruta | Descripción | Acceso |
|------|-------------|--------|
| `/` | Página de inicio | Login requerido |
| `/realtime-data/` | Gráficas en tiempo real por ubicación | Login requerido |
| `/map/` | Mapa con datos agregados por ciudad | Login requerido |
| `/historic/` | Descarga de datos históricos | Login requerido |
| `/users/` | Gestión de usuarios | Solo superusuario |
| `/variables/` | Gestión de variables y umbrales | Solo superusuario |
| `/admin/` | Panel administrativo Django | Solo superusuario |

---

## Sistema de alertas

El servicio `control` ejecuta `analyze_data()` cada 5 minutos:

1. Consulta los datos de la última hora agrupados por estación y variable
2. Calcula el promedio de cada grupo
3. Compara contra `min_value` y `max_value` de cada `Measurement`
4. Si está fuera del rango, publica un mensaje al topic `*/in` del dispositivo

Los umbrales se configuran desde el dashboard en `/variables/<id>/`.
