# ELK

Suite ElasticSearch, Logstash y Kibana

# ElasticSearch

Motor de búsqueda / indexador

Una herramienta que permite:
- Recibir peticiones de indexado de documentos
- Atender busquedas sobre los documentos indexados

El proceso de indexación... era sencillo? No.. Muy complejo computacionalmente.
Requiere mucho tiempo y recursos

ES permite trabajar con qué tipo de documentos? solo JSON

Y donde los guarda, los documentos?
En un índice.

Los índices están divididos en shards o fragmentos

Los hay de dos tipos:
- primarios
- replicación

Cada shard, independientemente de su tipo, a bajo nivel es un: LUCENE

Lucene es un proyecto de Apache: Motor de busqueda / indexador escrito en JAVA

Para que servían los shards primarios: 
    Escalabilidad:
    - Repartir la carga al indexar documentos
    - Repartir la carga al buscar documentos

Para que servían los shards de replicación: 
    Alta disponibilidad: Replicación de datos en caso de falla
    Escalabilidad:
    - Repartir la carga al buscar documentos

La forma de hablar con un ES es mediante API REST: Peticiones por HTTP
- Mando un JSON
- Recibo a cambio un JSON

# Kibana

Un app web que ofrece una interfaz gráfica para explotar los datos almacenados en un ES

Usos:
    - Búsquedas sobre mis documentos
    - Cuadro de mando
    - Monitorizar/analizar:
        - logs
        - Servicios
        - Infraestructura

# Logstash

Herramienta de ingesta de datos.
Permite:
    - Filtrado
    - Transformación
    - Enriquecimiento de datos
    - Enrutamiento de datos
Datos que puede extraer de distintas fuentes:
    - de un fichero
    - Abriendo un puerto y atendiendo peticiones http
    - ...
    
###############################################################################

ElasticSearch:

Está diseñado para correr en un cluster (un grupo de nodos):
    - Alta disponibilidad
    - Escalabilidad
    
Y además es un sistema distribuido.
    - Las distintas funciones de la herramienta pueden realizarse en distintos sitios (nodos)
    
Funciones/Roles puede adquirir un nodo:
    - maestro: Al menos cuantos: 2 reales + 1 de mentira (solo puede votar)
        Esos 2 reales operan en modo activo/pasivo
    - data: Los que guardan(indexan) y hacen busquedas
            Al menos cuantos en prod? 2 por replicación de datos.
    - coordinador: Son los encargados de recibir peticiones de busqueda y consolidar resultados
        Es un rol especial. Cualquier nodo, es coordinador, sin posibilidad de desactivar esta función.
    - ingesta: Preprocesan los documentos antes de mandarlos a un data... para descargar el data
    - machile learning
    
############################################################################
Cluster de ES                                       INDICE FACTURAS-2021 (3 shards primarios  + 2 replicas)
    maestro1 ****        --- IP1:9200
    maestro 2 (backup)   --- IP2:9200
    data1                --- IP3:9200               S0            S1'     S2'
    data2                --- IP4:9200               S0'           S1                
    ....
    data n               --- IPN+2:9200                           S1'     S2
    data n+1             --- IPN+3:9200             S0'                   S2'
    ....
    coordinador1         --- IPN+4:9200
    coordinador2         --- IPN+5:9200
    ....
    ingesta1             --- IPN+4:9200
    ingesta2             --- IPN+5:9200
    
    busquedas.cluster.es.miempresa.es  <> IP de un Balanceador de carga 
                                    >    coordinador1
            proxy reverso con lb    >    coordinador2
                httpd
                nginx
                f5 
                haproxy
                
    indexacion.cluster.es.miempresa.es  <> IP de un Balanceador de carga 
                                    >    ingesta1
            proxy reverso con lb    >    ingesta2
    
    F17 -> data1 -> maestro1? donde? -> S2 -> datan S2 primario
                                              data1 replica
                                              datan+1 replica
    F15 -> S0 o S1, o S2
    F1928372 -> S0 o S1, o S2
    
    Cuando hago la petición puedo decir... oye, en cuanto esté guardado en 1, me das el ok.
        Espera 1: datan (OK)
            Que riesgo corro?
                Que pasa si en ese momento explota el cluster y el data n se le jode el HDD. Me quedo sin dato.
            Que ventaja tiene?
                más Rapido
        Espera a todos: datan (OK), datan+1 (OK), data2 (OK)
    
    Cluster de ES. Dame las facturas del 2021?
                   Dame los documentos del indice FACTURAS-*-2021
        De donde las saca ES?
        Tiene que hacer la busqueda en todos los S0, S1, y S2... Se elige un nodo que tenga una copia de cada shard
        Cada Shard es un LUCENE y devolverá sus datos de forma ordenada.
        Ya? O falta algo antes de mandarlo a quien lo pide?
            Consolidar los resultados del S0, S1, S2:
                -> REORDENAR
                    S0: 100k
                    S1: 50k
                    S2: 78k
                    --------
                        228k documentos... a ordenar.... Esto es ligerito para nuestra CPU? NO... MUY PESADO
                    quien hace esa consolidación? El nodo al que se solicito la busqueda.
                        El que recibe en primera instancia la peticion http.
                            Se quien es a priori? NO... depende del balanceador
        
        A priori tengo conocimiento de quien hace ese trabajo de consolidación?
            NO... es una decisión del balanceador.
        Me interesa que eso sea así? NO
            El maestro me interesa que esté ocupado haciendo este trabajo de consolidación? NO
            Los data me interesa que estén ocupados haciendo este trabajo de consolidación? NO
                Los data son para indexar y buscar.
            Este trabajo lo hacen los nodos de tipo COORDINATOR
        
        EL MAESTRO LE VOY A DEJAR TOTALMENTE TRANQUILO... Bastante tiene con lo suyo.
        Un maestro no quiero que haga nada de nada, mas que organizar.
            
            
            
            
        

    

programa que use ES para indexado:
    API REST -> ES (cualquier máquina)
    
    Oye, ES, please, indexa este documento [XXXXXXXXX] -> cluster.es.miempresa.es:9200
                     en tal INDICE
                     opcionalmente: Numero de shards donde se debe haber guardado el documento
                                    para recibir la confirmación
                                    En cuanto aquello se haya guardado en 1 shard, dame el ok
                                        Riesgo? 
    
    Cuando una maquina, la que sea, recibe esa petición:
        1º Esa petición es remitida al maestro. Para que?
            A qué data se lo manda. Para ello:
                Se mira: el INDICE. Y ese indice tendrá varias shards
                Se elige un fragmento primarios: S1, S8
                Para ello se utiliza un "algoritmo de routing"
                El algoritmo de routing por defecto.
                    Huella del ID del documento y calcular el resto al dividir entre 
                        el numero de shards primarios
                                                                            operador resto de la división entera
                                                        huella                 V
                    INDEXAR: factura-1897634527-2021 -> 1892871673781892178921 % 5 -> 0-4
                    0, 1, 2, 3 o el 4... A ese shard se manda
                Si decido hacer la huella sobre el cliente, que me aseguro:
                    Las facturas de un cliente se guardan en el mismo shard
        2º Se manda el documento al nodo que alberga el shard primario elegido
        3º Se manda el documento a los nodos que alberga las replicas de ese shard
            En todos esos nodos el documento es indexado y almacenado de forma independiente
        4º Se confirma el indexado del documento a quien hizo la solicitud        

# Algoritmo de huella: MD5, SHA
    Letra del DNI
        ENTRADA   SALIDA 
        2300023  | 23  -> LETRA
         000023  -------
                   100001
              0 <<<< RESTO -> T
              
        1º A la misma entrada siempre le toque la misma salida
        2º La salida sea un resumen de los datos de entrada



ES                      < Desarrollo : Infraestructura
OracleDB (DBA)
MySQL
Sistema Mensajería

################################################################################################
Instalación mínima:
    prueba 1 nodo
    
    real:
        al menos: 
            maestro1
            maestro2 y data1
            data2 y con permiso para votar 
    
        en la práctica: 
            maestro1
            maestro2 
            data1 y con permiso para votar   
            data2                            
            data3                            
            data4                            
            data5                            
            ??? Si los data hacen mucha coordinación o mucha ingesta
                Y en ese caso, separa una de esas funciones
            ingesta1
            ingesta2
            coordinador1
            coordinador2
            
            2 balanceadores de carga: Uno de coordinación (busquedas) + (carga)
                Los dos apuntando a los data1 y data2
                Esto me viene bien por si el dia de mañana quiero ampliar el cluster
                
            
Indice - Shards?
- documento en si?
- terminos
- ubicación

que pesa más? los terminos o las ubicaciones?
Lo normal es que haya muchos mas ubicaciones que términos... 
    eso será algo a controlar y analizar

nara
naran
naranj

naranja

naranji
naranjit
naranjito
naranjete

Típico autocompletar de búsqueda:
nara....
me esté mostrando resultados



mapping ~ esquema json... modelo de datos de una bbdd tradicional
Se define los campos que puede haber en el JSON
Y como se debe tratar cada campo
En función del mapping que yo haga, mis búsquedas funcionarán o no

{
    "usuario": {
        "nombre": "Ivan Osuna",
        "email": "ivan.osuna@gmail.com",
        "ip": "192.168.1.192",
        "estudios": "He estudiado muchas cosas..."
    }
}

usuario.nombre = "Ivan Osuna" FUNCIONARÁ? SI
usuario.nombre = "osuna"      FUNCIONARÁ? DEPENDE del mapping
    De como haya dicho yo que debe procesarse el campo usuario.nombre
        keyword < "Ivan Osuna"
        text (con distinción de may/min)
usuario.ip="192.168.0.0/16"  FUNCIONARA? Depende del mapping
    usuario.ip < IP       SI
    usuario.ip < keyword  NO
    
CADA INDICE VA A TENER ASOCIADO UN MAPPING
    Un mapping le puedo cambiar a posteriori...pero:
        Los documentos indexados con un mapping... indexados quedan.
    Esto es crítico porque ES tiene la mala costumbre de tragarse cualquier cosa
        Si yo no he definido un mapping para un indice. ES lo genera por mi...
            Eso si.. como a el le viene bien
CADA INDICE TIENE ASOCIADO UNOS SETTINGS:
    número de primarios *** Otros no
    número de replicas  *** Algunos datos los puedo cambiar a posteriori
    
ID-PRODUCTO
    102-294875
        102
        294875
    102-294879
        102-294879
    
    102-294875?
        102-294876
        103-294875

ROTACION
log > FB > LT > ES 
                (no quiero guardar el documento... solo la indexación)
metricas de unos servicios:
    apache: numero de peticiones que ha atendido en los ultimos 1 seg
            numero de errores
            numero de usuarios distintos
            
            
                                    3           2
ES - Developer < Desarrolladores (mappings, busquedas) 30
ES - Engineer  < Admin           (configurar cluster, instalar, mnto, operac.) 30

                
                
{
    "nombre": "Ivan"
}

3 nodos:
    nodo 1 - master - data
    nodo 2 - master - data
    nodo 3 - master - data
kibana:
    Interfaz grafica -> Peticiones REST
cerebro: 
    No oficial, pero muy utilizada. Interfaz grafica ADMIN


Maestro1--|
          |
Maestro2--|
          |
Data1*  --|  maestro solo para votar
Data2   --|
DataN   --|

        seed_hosts: A todos los nodos: maestro1, maestro2
        initial_master_hosts: Solo en los nodos maestros: maestro1, maestro2

De antemano le digo al nodo1: Oye, tu eres amiguito del nodo2 y del nodo3
De antemano le digo al nodo2: Oye, tu eres amiguito del nodo1 y del nodo3
Si falla nodo 1 y no arranca... que pasa con nodo 2 y nodo 3


            INDICE FACTURAS (2 shards x 1 replica)
nodo 1       S0     S1 (200Gb)
nodo 2              --       PUFFFF
nodo 3       S0'    S1'

Que tendría que hacer ES? 
1º Nodo1 S1' -> S1 Hacerlo primario
2º Nodo3 hacer una copia del S1 del nodo 1
    Esto con bastante probabilidad en un entorno real de 
        producción me mata el cluster entero... Mas vale que no se haga


Esto es una medida de extrema gravedad y que la haré solamente en casos de extrema necesidad.



Nodo 1 - Contenedor                                         > LUN: 189713
Nodo 2 - Contenedor     >>>>> CABINA ALMACENAMIENTO         > LUN: 128937  -- PUFF 
Nodo 3 - Contenedor                                         > LUN: 218947
Nodo 2 - Contenedor en otra maquina                         > LUN: 128937

Kubernetes 2 seg
    VVV
10 maquinas con docker instalado


Nodo 2 ha hecho puf! se ha caido el proceso
Se ha ido la funete de alimentacion del ordenador donde ejecuto el nodo 2
Se cayo el switch