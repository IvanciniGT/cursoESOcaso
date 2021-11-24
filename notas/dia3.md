Instalación de ES:

- Maestro 1
- Maestro 2
- Data 1 + maestro
- Data 2 

Indice:
    - terminos
    - ubicaciones
    - documento original?

Indice:
    Shard:  Fragmento ... Lucene
            Tipos:
                Primario
                Replicación
            ES nunca coloca 2 replicas de un shard en el mismo nodo
    Cómo decide ES el mandar un documento a un determninado shard?
        Algotimo routing:
            Configurable
            Por defecto ES usa una huella del id del documento
    Settings:
        Número de shards primarios
        Número de replicas
    Mappings:
        Estructura de los documentos a indexar
            Para cada campo se define su tipo de datos
            Y también cómo procesarlo
        Si no doy un mapping: ES genera uno por mi... pero normalmente no será bueno
    
    ES Quiere tener muchos índices o pocos índices?
        Muchos índices, asociados a fechas.
        Por qué? Por rendimiento
        Cuando en un índice ya no vamos a grabar más cosas, podemos optimizarlo para búsquedas
        Realmente puedo optimizarlo aunque se sigan guardando datos... pero no me compensa.
        Solo me compensa cuando ya no voy a meter nada nuevo
        Esto tiene que ver con cómo Lucene guarda los datos en disco?
            Lucene usa muchos ficheros para guardar los datos: SEGMENTOS
        En un momento dado puedo solicitar la unificación de los segmentos en un único fichero

App FACTURAS:
    Indice FACTURAS:
        4 shards primarios
    Analizar las consultas que hace mi app.
        La query más habitual es por cliente:
            - Me interesa que todas las facturas de un cliente vayan al mismo shard

API RESTful ES:

GET -> http://servidorES/INDICE-NO-EXISTE
// Da error

PUT -> http://servidorES/INDICE
{
    settings: {},
    mappings: {}
}

POST -> http://servidorES/INDICE/_doc/ID-OPCIONAL
{
    documento JSON
}

POST -> http://servidorES/INDICE-QUE-NO-EXISTE/_doc/ID-OPCIONAL
{
    documento JSON
}
// Crea el indice automaticamente

Clientes Tontos


http://servidorES/FURGON-dia1-2021/_doc
{
    "id": "",
    "posicion": {
        "lat": 121212,
        "lon": 211212
    }
}

Crear el indice tendría que dar de alta sus mappings y sus settings

ES permite definir Plantillas de indices
    FURGON-*
        settings
        mappings

Open        Puedo hacer busquedas e inserciones
    Freeze  Puedo hacer busquedas                 <<<<<< Merge
Close       No puedo hacer nada 



Apache
^^^^
Filebeat
VVVV
Logstash (Enriquecer)
VVVV
ES
^^^^
Kibana






Webserver1  FileBeat    >
Webserver2  FileBeat    >   Logstash   >    LS     > ES  MONITORIZACION
Webserver3  FileBeat    >
    
                                            LS     > ES Locuras QUERIES!!!
                                            
                                            
                                            
APACHE < FILEBEAT > KAFKA < LS > ES                                            



INDICE

80 Kb total   terms + ubicaciones
-----------------------------------
60 Kbs terms
20 kbs ubicaciones   DOC 17 (manzana) DOC 21(manzana)

Si divido este indice en 2 shards:

S1
    Total:      67Kb
    Term:       57Kb   manzana
    Ubicaciones  7Kb   DOC 17
S2
    Total:      65Kb
    Term:       55Kb   manzana
    Ubicaciones  7Kb   DOC 21
S2
    Total:      65Kb
    Term:       55Kb   manzana
    Ubicaciones  7Kb   DOC 28
            ---------
                190Kb



