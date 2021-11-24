# ELK

Suite ElasticSearch-Logstash-Kibana de la empresa Elastic Co.


## ElasticSearch ~ Google

Motor de búsqueda / Indexador
Usos:
    - Montar mi propio google
        Google maps
        Google analytics
        Gmail
        Monitorización: Google Sites
    - Sistema de Monitorización

### Motor de búsqueda / Indexador

Indexador = Indice < Bases de datos

Tabla papel: 10000 filas < Quiero encontrar algo:
Facturas: Columnas:
    Numero de factura
    Concepto
    Cliente
    Fecha
    Importe
    
¿Quiero todas las facturas del cliente XXXX?
Ir uno a uno mirando si cada factura es de el cliente XXXX o no > FULL SCAN
    Eficiente? NO

Si tengo los datos ordenados? Diccionario < BUSQUEDA BINARIA
Caseta
Abro el diccionario > M
    La palabra Caseta está en el conjunto de páginas anterio.
        He conseguido descartar muchas páginas
    Abro por algun lado de las que me quedan... J
        Me quedo con lo de Antes
        Abro: B
            Me quedo con lo de después
            
            
Cuando somos chicos, no tengo claro por donde abrir el diccionario 
para empezar a buscar.
Cuál sería la decisión más inteligente? El medio

Según nos hacemos más mayores, sabemos mejor por dónde interesa abrir el diccionario...
Zapato> Abro por el final < Estadísticas de la BBDD

10000 facturas < Quiero encontrar 1
Si los datos no están ordenados, necesito hacer 10000 operaciones
Si los datos están ordenados, en el peor escenario, necesito hacer?

10000
5000    1
2500    2
1250    3
625     4
320     5
160     6
80      7
40      8
20      9
10      10
5       11
3       12
2       13
1

10000 operaciones contra 13 

Pues está claro, antes de buscar, ordeno los datos
Qué tal decisión sería esta?
Qué tal se le da a un ordenador ordenar? FATAL, de las peores cosas que 
    sabe hacer un ordenador

Computadora
    Ordenador < Ordinateur < El que emite ordenes

Tener los datos preordenados > diccionario
Qué problemas tiene el preordenar los datos? Guardarlos ya ordenados
- Y las nuevas? En la informática igual.
  Tengo una tabla con 10000 cosas. Que implica insertar algo en la posición 300.
    Tengo que abrir el fichero de BBDD
    Me voy a la posicion de la ficla 300. Byte 23452 del fichero. 
    Mover los 9700 datos que hay detras a una nueva posición en el fichero
    Escribo el nuevo <
        REESCRIBIR EL FICHERO ENTERO DE LA BBDD
- Ordenarl los datos por qué concepto?
   A lo mejor quiero tenerlos datos ordenados por 6 cosas diferentes.

Libro de recetas <<<<<<          Indice
    1000 recetas
        Nombre
        Tipo de plato
        Ingrediente principal
        Dificultad
        Tiempo de realización

Índice?
    Copia ordenada de los datos
        dato ---> ubicación

Las BBDD Relaciones llevan años creando índices.
    Aprovechan esos índices para hacer búsquedas bien rápido.
    
Para qué necesito yo un indexador?
    Las bases de datos relacionales hacen GUAY este trabajo cuando tengo un 
        conjunto de datos bien estructurado y definido
        TABLA FACTURAS:
            Número
            Importe
            Fecha
            CIF
    Cuando los datos no tienen una estructura formal... las BBDD relaciones
        se hacen popo cuando tienen que hacer una búsqueda

CONCEPTO:        
    bolígrafos naranjas
    cuaderno A4 naranja
    ARCHIVADORES ANARANJADOS
    
    naranja
    
LIKE %naranja%.  < Qué implica? FULL SCAN
    Indeficiente NO. LO SIGUIENTE. RUINA TOTAL !!!!
        100.000: Nombre Completo: 250 caracteres FUERZA BRUTA CPUS.3.5Gz
            Y aún así... malamente.
            
    10.000.000: Documentos: 20 paginas 
        
Aquí es donde entra un indexador.
Un indexador va a crear índices especiales para hacer búsquedas bien 
rápido sobre contenetiro desesctructurado.

Google, opera sobre páginas WEB: Documentos
        
        
    
CONCEPTO:        
    DOC 1 - unos bolígrafos naranjas
    DOC 2 - un cuaderno A4 naranja
    DOC 3 - ARCHIVADORES ANARANJADOS
    
    naranja
    
1º Partir un texto en términos: blancos, parentesis, puntos, comas, símbolos
2º Eliminar palabras vacias: un la los de cuya .... StopWords < Dependen del idioma
3º Normalización de caracteres: mínuscula, quitar acentos
4º Quitar prefijos / sufijos |
5º Quitar tiempos verbales.  | Quedarme con la raiz de la palabra
-
ESTO ES LO QUE SE GUARDA
archivador.   DOC 3 (1) 
a4            DOC 2 (3)
boligrafo.    DOC 1 (2)
cuaderno.     DOC 2 (2)
naranja       DOC 1 (3), DOC 2 (4), DOC 3 (2)

Búsqueda: ARCHIVADORES -> El mismo proceso que al indexar
archivador -> DOC 3 (1)

Puede haber discrepancias entre lo que el indexador guarda y el documento 
que se indexó en su momento pero que está almacenado en otro sitio.

Google y ES permiten quedarse con una copia del documento en el 
    momento de la indexación. Esta copia puede quedarse obsoleta.
    
Donde está el dato válido, verdadero? En la BBDD, Disco duro, app de turno.
Hay casos especiales donde los documentos tengo garantía de que no van a cambiar
    en el futuro. En estos casos, puedo usar el indexador como BBDD (repositorio)
Ejemplo?
    Logs. Registros de eventos.
    En evento puede cambiar en el futuro?
        No... se podrá producir otro evento... pero un evento que ya pasó, pasó.
    
    Uso de CPU de mi servidor el juves 13 de Sep a las 17:45: 57%

ES sólo permite guardar documentos?
    Word  NO
    Excel NO
    PDF   NO
    CSV   NO
    XML   NO
    JSON  <<<<<<< SOLO 
    
    
JSON: Lenguaje de estructuración de información
    XML
    CSV
    YAML <<<< 

-----

{
    "nombre": "Ivan",
    "apellidos": "Osuna",
    "Edad": 43,
    "Estudios": ["", "", ""],
    "IP": 192.168.1.43,
    "Lugar de nacimiento": {
        "ciudad": "Madrid",
        "ubicación": {
            "lat": 1287638723487623 ,
            "lon": 2398283978293789
        }
    }
}

IP: 192.168.0.0/16
-----

Uber -> Fichero JSON: Posicion, ID (Evento)
Wallapop
    titulo
    importe
    vendedor
    descripcion
    fotos. -> JSON ES
    ubicación
FreeNow
MyTaxi
WEB < Mapa en tiempo real de los usuarios que están conectado
    access.log < (tomcat, nginx, weblogic) -> IP -> Geoposicionar (BBDD Geoposicionamiento)
                                                    MAPA  10 minutos 

ES:
    Permite generar índices para búsquedas complejas... muy complejas
    Solo permite trabajar con documentos JSON
    Cómo es su interfaz gráfica? WEB
                                 Escritorio
                                 Linea de comandos
                        NO TIENE
    La única manera de comunicarse con ES es mediante un API RESTful
    
API RESTful?
    API? Conjunto de funciones al que yo puedo llamar de un programa
        Indexa un documento
        Busca un documento
        Estás operativo?
    
    RESTful?
        REST: Protocolo basado en http, que se basa en la utilización de ficheros JSON
            HTTP:   Request
                    Response
                    Método de comunicación: GET, POST, PUT, HEAD, DELETE
        ful: Forma en la que ha construido el API
        
        Sistema que guarda libros (biblioteca)
        
        http://labiblioteca.com/libros
                                  GET Recupoerar el listado de libros disponibles
                                  PUT Modificar el contenido de un libro
                                  POST Dar de alta un libro
        http://labiblioteca.com/libros/17
                                  GET Recupero el detalle de ese libro
                                  DELETE Elimino un libro de la biblioteca
                                  HEAD para saber si ese libro existe
        http://labiblioteca.com/generos/ficcion
        http://labiblioteca.com/generos/novela/libros
                                  

Servidor WEB? URL
    URL:    protocolo.      http            https
            servidor        labiblioteca.com.  < DNS IP
            puerto          80              443
            ruta            /
            argumentos
        
En un sistema UNIX, qué es la / : ROOT RAIZ
Apache, Nginx, Tomcat, Weblogic
    Carpeta de mi ordenador: /home/ubuntu/miweb/programa.jsp <<<<< /programa.jsp
    
    
ES está concebido para operar en un CLUSTER.

CLUSTER? Conjunto, Grupo . Sinonimo de GROUP

            Servidor . Nos referimos a HW o a Software
CLUSTER DE MAQUINAS 
CLUSTER DE PROCESOS

Qué aporta un cluster de Servidores (Físicos, lógico)?
- Alta disponibilidad
- Escalabilidad

En los entornos de producción TODO se instala en un cluster

ES Siempre trabaja con el concepto de cluster. Lo que arrancamos es un CLUSTER DE ES
Aunque tenga 1 nodo único.

En la realidad al menos hemos de montar 3 nodos de ES.
Nos va a dejar hacer una instalación con un UNICO servidor... para jugar y pruebas

ES está preparada para manejar volumenes ingentes de datos.

Cada nodo de un cluster de ES asume una función dentro del cluster. 
    No todos los nodos hacen lo mismo: Sistema distribuido.
    Funciones de los nodos:
        master: Que controlan toda la actividad del cluster:
            Al menos me obliga a tener 3 nodos que puedan ejercer de maestro
                Porque en un momento dado, sólo tendremos un nodo maestro.
        data:   Estos son los que guardan datos y permiten hacer búsquedas
        coordinator:
        ingest:
        machine learning:
Un cluster al menos necesita 3 nodos que puedan ejercer de maestros
    y 2 nodos que puedan guardar datos
data: 


Cluster ES:
    Nodo 1 maestro + data
    Nodo 2 maestro + data
    Nodo 3 maestro
En un entorno real: MINIMA INSTALACION
    Nodo 1 data
    Nodo 2 data + maestro ( solo podrá votar, pero no ejercer)
    Nodo 3 maestro ***
    Nodo 4 maestro (queda a la espera)

El tipo de nodo más importante es el DATA:
    - Guardan 
    - Hacen búquedas
    
ES no sabe ni guardar datos(indexarlos) ni hacer búsquedas sobre ellos.
    APACHE Java LUCENE
ES Es un coordinador de Lucenes que tenemos distribuidos en varias nodos.

Los datos los guardan en última instancia los lucenes y los buscan los lucenes.
Lucene está desarrollado en JAVA... no lo quiero... quiero algo que pueda ser invocado
    desde cualquier lenguaje de programación: API REST (ES)
No quiero 1 lucene... quiero cientos/miles... COORDINAR LOS LUCENES (ES)


COMO SE GUARDAN LOS DATOS EN ES
--------------------------------
    INDICE(~TABLA) 
        Documentos ~FILA , REGISTRO
        Campos     ~COLUMNA
    
    Los índices en ES están dividos en FRAGMENTOS (SHARDS)
    Un índice almenos tendrá 1 SHARD PRIMARIO
    Tenemos 2 tipos de SHARDS: PRIMARIOS - REPLICACION
    
    Un SHARD DE REPLICACION es una copia de un shard PRIMARIO.

Habitación
    Estanterias < Indice
        Archivadores    < Shard
            Documentos      < JSON

----------------------
Estanteria: FACTURAS.  (INDICE)
Estanteria: PEDIDOS.   (INDICE)
Estanteria: CLIENTES.  (INDICE)
----------------------
Estanteria: USUARIOS.   (INDICE)
Estanteria: PRODUCTOS.  (INDICE)

Los usuarios los guardo en 4 archivadores (4 SHARDS PRIMARIOS), y no solo en 1. Porque ?
Ventajas:
    - Escalabilidad indexado
    - Escalabilidad búsquedas
    
De cada SHARD PRIMARIO puedo hacer replicas:
Ventajas:
    - Permite un indexado más rápido? NO... podría ser más lento o igual... nunca mejor
    - Escalabilidad en las búsquedas? SI
    - Alta disponibilidad: Si se quema un archivador... tengo otro... no pierdo los datos
    - Necesito Backups? SI... pero la frecuencia no es la misma.
    
Ejecutores: Hilos programa - Personas que trabajan en mi habitación

Cuantas personas pueden estar simultaneamente trabajando con un archivador? 1 por archivador
Si tengo 4 archivadores... puedo tener hasta 4 personas trabajando en paralelo:
Si tengo que hacer una carga de datos 4 personas que pueden hacer cargas en paralelo
Si tengo que recuperar información (busqueda)


Como desarrollador, voy a decidir, cuantos shards primarios y de 
    replicación voy a tener en cada indice

Cada SHARD sabeis que es en realidad? Cada archivador? Un LUCENE

Un índice es habitual que tenga varios shards y al menos 1 replica
    Habitual habitual en producción es tener al menos 2 replicas.

Cluster 2 nodos
    Nodo 1 CPU 50%
    Nodo 2 CPU 55%
En este escenario necesito escalar? Meter un tercer servidor o aun no?
AQUI ESTOY LOCO... tengo los pelos como escarpias...
    Que pasa si se cae un servidor? Se me ca el otro... No puede asumir la carga de trabajo
    4 weblogic 25% CPU. Si 3 se caen, pueda seguir dando servicio
    
WALLAPOP: 
    Indice USUARIOS
        10 replicas primarias: 2 copias: 30 shards... 30 lucenes
    Indice PRODUCTOS
        100 replicas primarias: 2 copias: 300 shards... 300 lucenes
    
La gestión de los indices en MUY COMPLEJA.
Los datos no dejan de venir...




CARGA WALLAPOP/SEGUNDAMANO, MILANUNCIOS:        
    DOC 1 - unos bolígrafos naranjas
    DOC 2 - un cuaderno A4 naranja
    DOC 3 - ARCHIVADORES ANARANJADOS
VVVVVV
archivador.   DOC 3 (1)
a4            DOC 2 (3)
boligrafo.    DOC 1 (2)
cuaderno.     DOC 2 (2)
naranja       DOC 1 (3), DOC 2 (4), DOC 3 (2)

VVVVVV
Fichero de texto en el disco duro: Segmento

Ahora vienen más datos...
    DOC 1 - unos bolígrafos verdes
    DOC 2 - un cuaderno A4 amarillo
    DOC 3 - ARCHIVADORES NEGRUZCOS
VVVVVV
archivador.   DOC 3 (1)
a4            DOC 2 (3)
boligrafo.    DOC 1 (2)
cuaderno.     DOC 2 (2)
verde         DOC 1 (3)
amarillo      DOC 2 (4)
negro         DOC 1 (2)
VVVVVV
Donde lo guardo? 
    En el mismo archivo/segmento
    En otro archivo/segmento.       <<<<<<<<<<<

Los datos... los fusiono con los anteriores... o los añado de forma independiente?
                        Ventaja                         Inconveniente
    - fusionar:         La busqueda irá bien rápida     Lo voy a flipar al generar el fichero....
    - independiente:    El guardado es directo/rapido   Lo voy a flipar cuando necesite buscar...
                                                        Esto se medio resuelve teniendo una cache en RAM

En un momento dado... me podría interesar CERRAR un indice: 
    Se que en ese indice no va a entrar ningun dato nuevo
Y por tanto, en este momento me planteo fusionar todos los datos en un unico archivo, 
    bien preparadito para busquedas

En ES lo normal no es crar un INDICE DE PRODUCTOS ... o DE USUARIOS....
Si no crear uno por dia o por semana, o mes...
PRODUCTOS-dia1-2011
PRODUCTOS-dia2-2011
PRODUCTOS-dia3-2011. < 4 shards... 2 replicas = 8 x 365= 2500 x 4 años : 10000 shards... 10000 lucenes


En wallapop, a dia de hoy, vendo algunos productos que se publicaron hace 1 año o 1 mes... que aun no se han vendido
Las busqeudas se hacen sobre indices
    PRODUCTOS-*

Hay un producto tambien de Apache equivalente a ES: SOLR

--------------------------------------------------------------------

MetricBeat  Monitorizando CPUs >>>>>
Filebeat.   Logs    >>>>                Ingesta de datos (Leer datos de algun sitio, transformarlos y mandarlos a ES)
            BBDD.   >>>>                Logstash. >  ELASTICSEARCH       <<<<<        KIBANA 
                                        Indexar documentos              (App WEB. Interfaz gráfica para explotar la info de un ES)
                                        Almacenar una copia de los mismos en bruto


Kibana:
    Busquedas tipo GOOGLE
    Generar cuadros de mando: Indicadores
    Generar informes: PDF
                      Proyectar en un monitor
    Realizar monitorización en tiempo real de servicios, logs, maquinas
Logstash:
    Transformación de datos
    Enriquecimiento de datos
    Filtrado de datos
    Router (A donde mando los datos)

Beats:
    Programitas muy ligeros que permiten mandar datos a un ES o Logstash de cosas muy estandarizadas
        Filebeat
        Heartbeat
        Winlogbeat
        auditbeat
        Metricbeat
    
App movil >>> Weblogic >>>>API REST >>>  ES              <<<< API REST <<<<< Java, JS App wallapop WEB, Android, Iphone
                                            productos
                                            usuarios
    
                                CATAPUM !!!!
Apache 1                            VV
     log    > Filebeat
Apache 2                    > Logstash.  >              Logstash         >       ES (todos los log) Sistemas    <<<< Kibana 
     log    > Filebeat          (geop, IP).  >          Logstash2        >       ES (todos los log) Propietario <<<< Kibana
Apache 3
     log    > Filebeat
                        >>>>
                        Síncrona
                        
                        Sistema de mensajería
                            KAFKA
                        Asíncrona

Lleno los logs y todo explota
Para evitar esto, en los apache configuro rotación de log....
Que los datos se pierdan por sobreescritura

-----------------------------------------------------------------

CONTENEDORES:
Forma de distribuir e instalar aplicaciones. estandar de facto en la industria.
Imagenes de contenedor. Softeare ya instalado por alguien
    Ficherito cutre con un ZIP que incluye un programa ya instalado.
    Configuraciones por defecto para arrancar el programa que venga
    Algo de información adicional para el que lo vaya a usar.
        Puerto
        Directorio se guardan los datos importantes

Contenedor:
    Es un entorno aislado donde ejecutar procesos dentro de un SO Kernel Linux®.
    
    UNIX... tampoco puedo correr contenedores de forma nativa
        MacOS (UNIX), HP-UX, AIX, SOLARIS
        
    Está estandarizado
    
Docker
    Docker funciona en windows? SI.  ---> hyperV MV Linux < contenedores
    Docker funciona en MacOS?   SI.  ---> mv linux.       < contenedores 
puedo ejecutar contenedores en Windows? NO
puedo ejecutar contenedores en MacOS?   NO

Algo para ejecutar un servicio...  No me evita tener un weblogic.... Puedo poner un weblogic dentro de un contenedor
Algo parecido a una maquina virtual... Si bien los usamos para lo mismo


App1  |  WS + Java1.8 
-------------
 C1   |  C2
-------------
  Ejecutor de contenedores
-------------
   SO Linux
-------------
    HIERRO


MV: Generar entornos aislados donde ejecutar mis aplicaciones / mis procesos

Esto tiene problemas importantes.... que muchos sufris en vuestro dia a dia...
Y que en un entorno de producción no me puedo ni plantear.


Bigdata <<<<< Manejar grandes cantidades de información de forma que no me sirvan las 
              formas de trabajo que he venido usando tradicionalmente:
                Analitica de datos
                Machine Learning
                Transmitir información
                Almacenarlo
--------------------
Segmentación
Analytics

Descargue una pelicula 5 Gbs.  ---> pincho usb 16 gbs que esta vacio?
Depende de como este formateado
FAT16? Ni de coña
FAT 32? NASTI
NTFS? ext4? SI

1 fichero 1 Pb? NTFS? ext4? se hacen popo

Tabla con 10000 datos < EXCEL
         100000 datos < access
         500000 datos < mysql
        3000000 datos < sqlserver
       15000000 datos < oracle
     1000000000 datos < oracle popo 
     
     
INFRAESTRUCTURA BIGDATA: Decenas/cientos de maquinas (Commodity hardware muy baratas y cutres)
                         Trabajando como si fuesen 1 sola
                         


debian - ubuntu
apt      apt-get

rh -centos -fedora
yum

maven

Los procesos que corren dentro de un contenedor están en un entorno aislado:
    - Puedo limitarles su uso de CPU, Memoria
    - Tienen su propia configuracion de red independiente del del host y del de otros contenedores
    - Tiene su propio sistemas de archivos independiente del del host y del de otros contenedores
    
    
    