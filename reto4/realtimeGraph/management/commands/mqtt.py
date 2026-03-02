import paho.mqtt.client as mqtt
from django.core.management.base import BaseCommand
from realtimeGraph.views import get_or_create_location, get_or_create_measurement, get_or_create_user, get_or_create_station, create_data

class Command(BaseCommand):
    def handle(self, *args, **options):
        broker_address = "54.157.49.255"
        broker_port = 1883
        topic = "#"

        def on_message(client, userdata, message):
            # Aquí va tu lógica actual de procesamiento de mensajes
            print("Mensaje recibido en tópico: ", message.topic)

        print("MQTT Start")
        # Ajuste de compatibilidad para Paho 2.0
        client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION1)
        client.on_message = on_message
        client.connect(broker_address, broker_port, 60)
        client.subscribe(topic)
        client.loop_forever()
