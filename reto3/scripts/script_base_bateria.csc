atget id id

data p "hola" id id
send p

loop
read mens
rdata mens tipo sensorId contador valor1 valor2

if( tipo == "alerta")
   cprint "ALERTA - SENSOR #" sensorId " [" contador "/1000] - Long:" valor1 " Lat:" valor2
end

if(tipo == "critico")
   cprint "BATERIA AGOTADA - SENSOR #" sensorId " en: Long " valor1 " Lat " valor2
   data p "stop"	
   send p
   wait 1000
   stop
end

if(tipo == "stop")
   cprint "SIMULACION TERMINADA - Sensor " sensorId " llego a 1000 mensajes"
   wait 1000
   stop
end

wait 10