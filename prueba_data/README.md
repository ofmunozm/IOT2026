# Reto 4 — Comparación de modelos de almacenamiento IoT: PostgreSQL vs TimescaleDB

## Descripción

Este reto implementa y compara dos estrategias de almacenamiento para datos IoT en tiempo real, usando la aplicación **REMA (Realtime Monitoring Web App)**:

| Carpeta | Base de datos | Modelo de datos |
|---------|--------------|-----------------|
| `postgres/` | PostgreSQL puro | **Esquema estrella** — una fila por medición |
| `timescale/` | TimescaleDB (extensión de PostgreSQL) | **Patrón Blob** — múltiples mediciones por fila con valores pre-agregados |

El endpoint implementado en ambas versiones es:

```
GET /topStations?measurement=<nombre>&start=<fecha>&end=<fecha>&top=<n>
```

Retorna las `top N` estaciones con mayor promedio de una variable en un rango de fechas.

---

## Estructura

```
prueba_data/
├── postgres/              # App Django con esquema estrella (PostgreSQL)
│   └── realtimeMonitoring/
│       └── realtimeGraph/
│           ├── views.py   # Contiene top_stations()
│           └── urls.py    # Ruta /topStations
├── timescale/             # App Django con patrón Blob (TimescaleDB)
│   └── realtimeMonitoring/
│       └── realtimeGraph/
│           ├── views.py   # Contiene top_stations()
│           └── urls.py    # Ruta /topStations
└── Pruebas de carga.jmx   # Script JMeter — 60 usuarios simultáneos
```

---

## Despliegue en AWS (EC2 vía CloudFormation)

### Paso 1 — Crear las instancias EC2

Desde la terminal del laboratorio AWS con AWS CLI:

```bash
wget https://raw.githubusercontent.com/SELF-Software-Evolution-Lab/Realtime-Monitoring-webApp/main/tutoriales/Capa%20de%20Datos/IOT-Capa-Datos.template.json -O template --no-check-certificate

aws cloudformation create-stack \
  --stack-name iot \
  --template-body file://template \
  --capabilities "CAPABILITY_IAM"
```

Esperar el estado **CREATE_COMPLETE** en la consola de CloudFormation y anotar las **2 IPs públicas**.

Credenciales preconfiguradas:
- **PostgreSQL** — Puerto: `5432` | BD: `iot_data` | Usuario: `dbadmin` | Contraseña: `uniandesIOT1234*`
- **TimescaleDB** — Puerto: `5432` | BD: `timescale_iot` | Usuario: `tsadmin` | Contraseña: `timescaleIOT1234*`

---

### Paso 2 — Configurar la EC2 de PostgreSQL

Entrar a la instancia vía **EC2 Instance Connect** en la consola AWS.

```bash
git clone https://github.com/ofmunozm/IOT2026.git
cd IOT2026/prueba_data/postgres/realtimeMonitoring

# Instalar dependencias
pip3 install Django Django-crontab psycopg2 ldap3 django_cron requests python-dateutil

# Crear tablas
python3 manage.py migrate

# Generar datos de prueba (~500 000 registros, tarda varios minutos)
python3 manage.py generate_data

# Levantar el servidor
python3 manage.py runserver 0.0.0.0:8000
```

> `generate_data` solo se corre una vez. Si la base ya tiene datos, el comando termina inmediatamente.

---

### Paso 3 — Configurar la EC2 de TimescaleDB

Entrar a la instancia vía **EC2 Instance Connect** en la consola AWS.

```bash
git clone https://github.com/ofmunozm/IOT2026.git
cd IOT2026/prueba_data/timescale/realtimeMonitoring

# Instalar dependencias
pip3 install Django Django-crontab psycopg2 ldap3 django_cron requests python-dateutil

# Editar settings.py con las credenciales de TimescaleDB
nano realtimeMonitoring/settings.py
# Cambiar: NAME → timescale_iot | USER → tsadmin | PASSWORD → timescaleIOT1234*

# Crear tablas
python3 manage.py migrate

# Generar datos de prueba
python3 manage.py generate_data

# Levantar el servidor
python3 manage.py runserver 0.0.0.0:8000
```

---

### Paso 4 — Verificar el endpoint

Desde tu máquina local, reemplazando las IPs correspondientes:

```bash
# PostgreSQL
curl "http://<IP-postgres>:8000/topStations?measurement=Temperatura&start=2021-07-01&end=2021-07-31&top=5"

# TimescaleDB
curl "http://<IP-timescale>:8000/topStations?measurement=Temperatura&start=2021-07-01&end=2021-07-31&top=5"
```

**Respuesta esperada** — array JSON con las top 5 estaciones:

```json
[
  {
    "station_id": 1,
    "station_name": "usuario_estacion",
    "city": "Bogotá",
    "measurement": "Temperatura",
    "avg_value": 25.43,
    "min_value": 18.10,
    "max_value": 31.90,
    "sample_count": 12840
  },
  ...
]
```

> El nombre de la variable es **case-sensitive**. Usar `Temperatura` (con T mayúscula) tal como está guardado en la BD.

---

## Prueba de carga con JMeter

### Requisitos
- Apache JMeter instalado localmente
- Ambas EC2 corriendo y con datos generados

### Pasos

1. Abrir `prueba_data/Pruebas de carga.jmx` en JMeter
2. En **User Defined Variables**, cambiar:
   - `ip_postgres` → IP pública de la EC2 con PostgreSQL
   - `ip_timescale` → IP pública de la EC2 con TimescaleDB
3. Ejecutar el plan de prueba
4. Ver resultados en **Summary Report** y **View Results Tree**

### Configuración del plan de prueba

- **60 hilos** (usuarios simultáneos) por servidor
- **Ramp-up:** 1 segundo
- **1 loop** por hilo
- **URL probada:** `/topStations?measurement=Temperatura&start=2021-07-01&end=2021-07-31&top=5`

### Qué esperar en los resultados

| Métrica | Descripción |
|---------|-------------|
| **Throughput** | Solicitudes por segundo que cada servidor puede manejar |
| **Average / Median** | Tiempo de respuesta promedio y mediana en ms |
| **90th / 95th / 99th %ile** | Tiempo máximo para el 90%, 95% y 99% de las solicitudes |
| **Error %** | Porcentaje de solicitudes que fallaron |

**Diferencias esperadas entre modelos:**

- **PostgreSQL (esquema estrella):** mayor tiempo de respuesta por las múltiples operaciones de JOIN y agregación sobre filas individuales.
- **TimescaleDB (patrón Blob):** menor tiempo de respuesta porque los valores `avg`, `min`, `max` y `length` están pre-calculados por fila, reduciendo el trabajo de agregación en la consulta.

---

## Notas

- Si las EC2 se reinician, las IPs cambian. Actualizar en JMeter antes de correr las pruebas.
- `generate_data` se corre **una sola vez** por instancia.
- Asegurarse de que el puerto `8000` esté abierto en el Security Group de cada EC2.
- El modelo blob (TimescaleDB) agrupa múltiples lecturas por hora en una sola fila con arreglos, mientras que el esquema estrella guarda una fila por cada lectura individual.
