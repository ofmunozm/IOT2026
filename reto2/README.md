# Reto 2: Simulación de redes de sensores IoT con CupCarbon

## Descripción

Este es un proyecto académico de simulación de redes de sensores IoT usando CupCarbon. Se realizaron 3 simulaciones comparando diferentes tecnologías de comunicación (**Zigbee**, **WiFi**, **LoRa**) para analizar el consumo energético en una red de detección de incendios forestales en los cerros orientales de Bogotá.

## Tecnologías utilizadas

- **CupCarbon**: Herramienta de simulación para redes de sensores inalámbricos (WSN) y IoT.
- **SenScript**: Lenguaje de scripting integrado en CupCarbon para programar el comportamiento de los nodos (sensores y estación base).
- **Java JDK 21**: Requerido para ejecutar CupCarbon (en macOS con Apple Silicon se usa la versión específica `cupcarbon_macm.command`).

## Estructura del repositorio

```
reto2/
├── incendios_cerros.cup          # Proyecto CupCarbon (mapa, nodos, conexiones)
├── config/
│   ├── markers.cfg               # Configuración de marcadores
│   ├── simulationParams.cfg      # Parámetros de simulación
│   ├── nodes/                    # Configuración de cada nodo (base + sensores + gas)
│   └── sensor_radios/            # Configuración de radios por nodo (Zigbee, WiFi, LoRa)
├── natevents/                    # Eventos naturales (temperaturas simuladas)
│   ├── evento1.evt
│   ├── evento2.evt
│   ├── evento3.evt
│   └── evento4.evt
├── scripts/                      # Scripts SenScript
│   ├── script_base.csc           # Script nodo base (sin monitoreo de batería)
│   ├── script_base_bateria.csc   # Script nodo base con gestión energética
│   ├── script_sensor.csc         # Script sensores (detección y envío de alertas)
│   └── script_sensor_bateria.csc # Script sensores con límite de mensajes y batería
├── logs/                         # Logs de ejecución
├── results/                      # Resultados y gráficas de consumo energético
│   └── wisen_simulation.csv
└── README.md                     # Este archivo
```

## Instrucciones de uso

1. **Requisitos**: Java JDK 21 instalado. En macOS con Apple Silicon, descargar la versión de CupCarbon para Mac M-series desde el [sitio oficial de CupCarbon](https://cupcarbon.com/).

2. **Ejecutar CupCarbon**: Desde la carpeta de instalación, ejecutar `./cupcarbon_macm.command` (en macOS M-series). En macOS puede ser necesario autorizar la aplicación en Configuración del Sistema.

3. **Abrir el proyecto**: En CupCarbon, abrir el archivo `incendios_cerros.cup` de esta carpeta.

4. **Seleccionar tecnología**: En cada nodo, en "Radio Parameters", elegir el radio activo (Zigbee, WiFi o LoRa) haciendo clic en la lista de módulos. La flecha `<-` y el color de las conexiones en el mapa indican el protocolo activo.

5. **Configurar simulación**: En Simulation Parameters, activar "Results" si se desean gráficas de consumo energético. Los scripts ya configurados limitan la simulación a 1000 mensajes por sensor o agotamiento de batería (< 5%).

6. **Ejecutar**: Iniciar la simulación y dejar que termine. Los resultados y gráficas de "Energy Consumption" se pueden exportar o capturar para análisis.

---

## Resumen del proceso: Simulación IoT con CupCarbon

### 1. Instalación y configuración de CupCarbon en macOS

El proyecto inició con la instalación de CupCarbon en un Mac con chip Apple Silicon. Primero se instaló Java JDK 21 usando Homebrew, ya que CupCarbon requiere Java para ejecutarse. Luego se descargó la versión específica para macOS M-series desde el sitio oficial de CupCarbon y se configuró el ejecutable `cupcarbon_macm.command` con permisos de ejecución. Debido a restricciones de seguridad de macOS, fue necesario autorizar la aplicación en Configuración del Sistema. Finalmente, se logró ejecutar CupCarbon exitosamente desde la terminal con el comando `./cupcarbon_macm.command`.

### 2. Tutorial básico - Red de 4 sensores 

Siguiendo el tutorial, se implementó una red de sensores para detección de incendios forestales en los cerros orientales de Bogotá. Se creó un proyecto con 1 nodo base ubicado en el edificio GA de la Universidad, 4 nodos sensores distribuidos en el cerro, y 4 nodos de gas para simular temperaturas ambientales. Se generaron archivos de eventos naturales con temperaturas aleatorias (Mean: 35°C, Std: 8, Period: 5s, Size: 20) y se programaron dos scripts en SenScript: uno para el nodo base que recibe y muestra alertas, y otro para los sensores que detectan temperatura > 30°C y envían alertas a través de la red. La simulación se ejecutó exitosamente con la tecnología Zigbee por defecto, mostrando las alertas en consola con las coordenadas de ubicación de cada sensor.

### 3. Expansión a 21 sensores con monitoreo de batería

Para cumplir con los requisitos del taller, se expandió la red de 4 a 21 nodos sensores, agregando 17 sensores adicionales con sus respectivos nodos de gas para aumentar la cobertura del área de monitoreo. Se modificaron los scripts para implementar gestión energética: se agregó un contador de mensajes (`ite`) que se incrementa con cada transmisión, estableciendo un límite de 1000 mensajes por sensor; se configuró la batería inicial en 100 Joules y se implementó monitoreo continuo para detectar cuando cae por debajo de 5%; se programó la lógica para que la simulación termine automáticamente cuando el primer sensor llegue a 1000 mensajes o agote su batería. Además, se configuró cada sensor para transmitir cada 10 milisegundos (`wait 10`, `delay 10`) y se implementaron mensajes de tipo "critico" y "stop" para coordinar la detención de toda la red cuando se cumplan las condiciones de parada.

### 4. Optimización de tiempos de simulación

Durante las pruebas iniciales se detectó que las simulaciones tardaban 15-20 minutos debido a que solo 2-3 sensores detectaban temperaturas superiores a 30°C, dejando inactivos a los demás. Para resolver esto, se regeneraron los archivos de eventos con temperaturas más altas (Mean: 50°C, Std: 5) garantizando que todos los sensores detectaran constantemente temperaturas críticas y transmitieran alertas. Adicionalmente, se implementó un sistema de monitoreo en tiempo real modificando los scripts para que cada alerta muestre el progreso del sensor en formato "[X/1000]", permitiendo visualizar cuántos mensajes lleva cada sensor sin tener que esperar a que termine la simulación. También se redujo la frecuencia de verificación de 10 ms a 1 ms (`wait 1`, `delay 1`), acelerando 10 veces el envío de mensajes. Como alternativa, se ofreció reducir la batería inicial de 100 a 15-30 Joules para que se agotara más rápido. Con estas optimizaciones, las simulaciones pasaron de tardar 15-20 minutos a completarse en 1-3 minutos.

### 5. Configuración multi-tecnología (3 radios × 22 nodos)

Para realizar la comparación de consumo energético entre diferentes tecnologías de comunicación, se configuraron tres radios en cada uno de los 22 nodos (21 sensores + 1 base): **Radio 0** con Zigbee (802.15.4) a 100 m de alcance, **Radio 1** con WiFi a 400 m, y **Radio 2** con LoRa a 5000 m. Cada tecnología tiene parámetros predefinidos de consumo energético (E_Tx y E_Rx) que simulan el comportamiento real de estos protocolos. La configuración se realizó manualmente en cada nodo accediendo a "Radio Parameters", agregando los radios WiFi y LoRa (Zigbee venía por defecto), y estableciendo los radios de alcance correspondientes. Para cambiar de tecnología entre simulaciones, se selecciona el radio activo haciendo clic en la lista de módulos, lo que marca ese radio con una flecha `<-` y cambia el color de las conexiones en el mapa para indicar qué protocolo está activo.

### 6. Ejecución de 3 simulaciones comparativas

Se ejecutaron tres simulaciones idénticas cambiando únicamente la tecnología de comunicación activa, siguiendo un protocolo estandarizado: primero se verificó que todos los 22 nodos tuvieran el mismo radio activo (flechas del mismo color en el mapa), se activó el checkbox "Results" en Simulation Parameters para generar las gráficas de consumo energético, y se ejecutó cada simulación dejando que terminara automáticamente sin intervención manual. Para cada tecnología (Zigbee, WiFi, LoRa) se recolectaron los datos de la consola incluyendo tiempo simulado, número de mensajes enviados/recibidos/perdidos, y qué sensor causó la terminación de la simulación. Al finalizar cada ejecución, se capturaron las gráficas de "Energy Consumption" que muestran el consumo de batería de cada nodo a lo largo del tiempo. Los resultados se organizaron en carpetas separadas (results/zigbee, results/wifi, results/lora) con las capturas de gráficas y los resultados de consola para su posterior análisis comparativo.
