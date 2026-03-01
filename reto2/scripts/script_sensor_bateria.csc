set ant 999
set ite 0
battery set 100

atget id id
getpos2 lonSen latSen

loop
wait 3
read mens
rdata mens tipo valor

if((tipo=="hola") && (ant == 999))
   set ant valor
   data mens tipo id
   send mens * valor
end

if(tipo=="alerta")
   send mens ant
end

if(tipo=="stop")
   data mens "stop"
   send mens * valor
   cprint "Para sensor: " id
   wait 1000
   stop
end

delay 3

areadsensor tempSen
rdata tempSen SensTipo idSens temp

if( temp>30)
   inc ite
   print ite
   data mens "alerta" id ite lonSen latSen
   send mens ant
   
   if (ite >= 1000)
      data mens "stop" id
      send mens * valor
      cprint "Sensor " id " llego a 1000 mensajes"
      wait 1000
      stop
   end
end

battery bat
if(bat<0.5)
   data mens "critico" id 0 lonSen latSen
   send mens ant
   wait 1000
   stop
end