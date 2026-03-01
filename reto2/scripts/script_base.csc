atget id id

data p "hola" id id
send p

loop
read mens
rdata mens tipo sensorId valor1 valor2

if( tipo == "alerta")
   cprint "ALERTA desde SENSOR #" sensorId " - Long:" valor1 " Lat:" valor2
end

wait 100