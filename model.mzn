% Conjuntos
set of int: ORDERS;
set of int: ITEMS;
set of int: WAREHOUSES;
set of int: WEEKDAYS = 1..7;

% Parámetros
array[ITEMS] of int: price; % entre 100
array[ORDERS] of int: loaday;
array[ORDERS,WAREHOUSES] of 0..1: available_warehouses;
array[ORDERS, ITEMS] of int: demand;
array[ORDERS, WAREHOUSES] of int: travel_cost;
array[WAREHOUSES, ITEMS, WEEKDAYS] of int: deltaQ;

% Variables de decisión
array[ORDERS, WAREHOUSES] of var 0..1: assign; % 1 si la orden se asigna al almacén, 0 en caso contrario
array[WAREHOUSES, ITEMS, WEEKDAYS] of var int: stock; % unidades de cada ítem en cada almacén para cada día de la semana
array[WAREHOUSES, ITEMS, WEEKDAYS] of var int: PCI;
array[WAREHOUSES, WEEKDAYS] of var int: PC;
% Restricciones

% Cada orden debe ser asignada a un almacén disponible
constraint forall(o in ORDERS)(
    sum(w in WAREHOUSES)(assign[o, w]) == 1
);


% Cada orden debe ser asignada a un almacén disponible
constraint forall(o in ORDERS , w in WAREHOUSES)(
  if assign[o, w] == 1 then
    available_warehouses[o,w] == 1
  endif
);

% Actualización del stock en el resto de almacenes
constraint forall(w in WAREHOUSES, i in ITEMS, t in WEEKDAYS)(
  stock[w, i, t] == deltaQ[w,i,t] + (stock[w, i, t-1] * (t != 1)) -  sum(o in ORDERS)(demand[o,i] * (loaday[o] == t /\ available_warehouses[o,w] == 1))

);

%PCI
constraint forall(w in WAREHOUSES, i in ITEMS, t in WEEKDAYS)(
  PCI[w,i,t] == (abs(stock[w, i, t]) * price[i]) * (stock[w, i, t] < 0)
);

%PC
constraint forall(w in WAREHOUSES, t in WEEKDAYS)(
  PC[w,t] == sum(i in ITEMS)(PCI[w,i,t])
);

% Función objetivo
%  Minimizar la función de costo total
var int: total_cost = sum(o in ORDERS, w in WAREHOUSES)(assign[o, w] * travel_cost[o, w]);
%  Minimizar la función de costo total
var int: stock_cost = sum(w in WAREHOUSES, t in WEEKDAYS)(PC[w,t]);
% Solución óptima
solve minimize total_cost + stock_cost;

%output ["total_cost=",show(total_cost/100), "\n"];
%output ["stock_cost=",show(stock_cost/100), "\n"];
%output ["OF =",show(total_cost/100+stock_cost/100), "\n"];
%output ["assign=",show(assign), "\n"];
%output ["stock=",show(stock), "\n"];
%output ["price=",show(price), "\n"];
%output ["pc=",show(PC), "\n"];