ArangoRB [![Gem Version](https://badge.fury.io/rb/arangorb.svg)](https://badge.fury.io/rb/arangorb)
===============================

[ArangoDatabase](https://www.arangodb.com/) is a native multi-model database with flexible data models for document, graphs, and key-values.
ArangoRB is a Gem to use ArangoDatabase with Ruby. ArangoRB is based on the [HTTP API of ArangoDB](https://docs.arangodb.com/3.0/HTTP/index.html).

ArangoRB 0.1.0 - 1.3.0 have been tested with ArangoDB 3.0  with Ruby 2.3.1</br>
ArangoRB 1.4.0 has been tested with ArangoDB 3.1 with Ruby 2.3.3</br>
ArangoRB 2.0.0 has been tested with ArangoDB 3.4 with Ruby 2.3.3</br>

It requires the gem "HTTParty"</br>

To install ArangoRB: `gem install arangorb`

To use it in your application: `require "arangorb"`

## Differences between version 1.4 and 2.0

ArangoRB 1.4 and ArangoRB 2.0 are not compatible.
The new version provide different improvements.
* Now all the instances are in a module Arango. This means that previous classes like Arango::Server will become Arango::Server.
* Arango::Server is now an instance. This means that ArangoRB 2.0 will permits to use different servers.

## Classes used

ArangoRB has the two type of classes.

Classes relative to ArangoDB elements:
* [Arango::Server](#Arango::Server): to manage a Server
* [Arango::Database](#ArangoDatabase): to manage a Database
* [Arango::Collection](#ArangoCollection): to manage a Collection
* [Arango::Document](#ArangoDocument): to manage a Document
* [Arango::Vertex](#ArangoVertex): to manage a Vertex
* [Arango::Edge](#ArangoEdge): to manage an Edge
* [Arango::Graph](#ArangoGraph): to manage a Graph
* [Arango::Traversal](#ArangoTraversal): to manage a Traversal operation
* [Arango::AQL](#arangoaql): to manage an AQL instances
* [Arango::User](#ArangoUser): to manage an User
* [Arango::Index](#ArangoIndex): to manage an Index
* [Arango::Task](#ArangoTask): to manage a Task
* [Arango::Transaction](#ArangoTransaction): to manage a Transaction
* [Arango::Replication](#ArangoReplication): to manage a Replication
* [Arango::Batch](#ArangoBatch): to manage a Batch of multiple requests
* [Arango::Foxx](#ArangoFoxx): to manage a Foxx instance
* [Arango::View](#ArangoView): to manage a View instance
* [Arango::Replication](#ArangoReplication): to manage a Replication

Classes relative to the Gem ArangoRB
* [Arango::Cache](#ArangoCache): to manage internal Cache
* [Arango::Error](#ArangoError): to handle ArangoRB errors

All the instances of these classes can be transformed in Hash with the method to_h.

<a name="Arango::Server"></a>
## Arango::Server

Arango::Server is used to manage the a single server.
It is used to provide your login credentials and it is the mandatory step to start your database.
Further it helps to manage the Server connected with ArangoDB.

To setup a server use the following way:

``` ruby
server = Arango::Server.new username: "MyUsername", password: "MyPassword",
  server: "localhost", port: "8529"
server.username = "MyOtherUsername"
server.password = "other_password"
server.server   = "127.0.0.1"
server.port     = "8765"
```

If not declared, the default values are user: "root", server: "localhost", port: "8529".
Password is a mandatory field.

### Verbose and warnings

For Debugging reasons the user can receive the original JSON file from the database by setting verbose on true.

``` ruby
server.verbose = true # Default false
```

Remember that verbose is only for testing reason: to work efficiently verbose should be false.
Some deprecated methods will return a warning. To silence this warnings use:

``` ruby
server.warning = false # Default true
```

### ConnectionPool

ArangoRB supports connection pool, to activate it you can define it at the initialization or during the proceedings.
To do so use:
``` ruby
server = Arango::Server.new username: "MyUsername", password: "MyPassword",
  server: "localhost", port: "8529", pool: true, size: 5, timeout: 5
# Default pool false, size 5, timeout 5
server.pool = true
server.size = 7
server.timeout = 10
server.restartPool # Restart pool with new size and timeout
```

### Cache

You can activate the ArangoRB cache by using:
``` ruby
server.active_cache = true # Default false
```

If active_cache is true, then a previous document or collection instance will be stored in the ArangoRB cache. In case a new instance of the same document is created, then a new instance will NOT be created but the old one will be used.

With an example:

``` ruby
server.active_cache = false
a = Arango::Document.new name: "test", collection: my_collection
b = Arango::Document.new name: "test", collection: my_collection
# In this case a and b are two different instances
```

``` ruby
server.active_cache = true
a = Arango::Document.new name: "test", collection: my_collection
b = Arango::Document.new name: "test", collection: my_collection
# In this case a and b are the same instance
```

Note that if you set server.active_cache to false, then the stored Cache will be emptied.
For more information about the cache, look at the section about Arango::Cache.

### Information

Basic informations can be retrieved with these command.

``` ruby
server.to_h # Return an hash of the instances

# server.graph   # Check name default Graph
# server.collection  # Check name default Collection
# server.user  # Check name default User
# server.address  # Check address used to connect with the server
# server.username  # Check name used to connect with the server
# server.verbose # Check if verbose is true or false
# server.async # Check the status of async
# server.request # Check the default request sent to the server
```

To retrieve lists

``` ruby
server.databases # Lists of available databases
server.endpoints # Lists of endpoints used
server.users # Lists of available users
server.tasks # Lists of available tasks
```

To monitoring the server you can use the following commands

``` ruby
server.log # Return log files
server.loglevel
server.updateLoglevel body: body
server.available? # Reloads the routing information from the collection routing.
server.reload # Reloads the routing information from the collection routing.
server.statistics # Returns the statistics information
server.statisticsDescription # Fetch descriptive info of statistics
server.status # Status of the server
server.role # Get to know whether this server is a Coordinator or DB-Server
server.serverData # Get server data
server.mode # Get server mode
server.updateMode(mode: "default") # Change mode of the server
```

### Manage Async

With Arango::Server you can manage Async results.

``` ruby
server.async = false # default
server.async = true # fire and forget
server.async = :store # fire and store
```

If Async is "store", then the commands of ArangoRB will return the id of the Async requests.
Arango::Server provides different methods to manage these Async requests.

``` ruby
server.fetchAsync    id: id # Fetches a job result and removes it from the queue
server.cancelAsync   id: id # Cancels an async job
server.destroyAsync  id: id # Deletes an async job result
server.retrieveAsync id: id # Returns the status of a specific job
server.retrieveAsyncByType type: type # Returns the ids of job results with a specific
# status. Type can be "done" or "pending"
server.retrieveDoneAsync # Equivalent to server.retrieveAsync type: "done"
server.retrievePendingAsync # Equivalent to server.retrieveAsync type: "pending"
server.destroyAsync type: type # Deletes async jobs with a specific status
# Type can be "all" or "expired"
server.destroyAllAsync # Equivalent to server.destroyAsync type: "all"
server.destroyExpiredAsync # Equivalent to server.destroyAsync type: "expired"
```

### Miscellaneous

``` ruby
server.version # Returns the server version number
server.engine # Returns the server engine
server.flushWAL # Flushes the write-ahead log
server.propertyWAL # Retrieves the configuration of the write-ahead log
server.changePropertyWAL # Configures the write-ahead log
server.transactions # Returns information about the currently running transactions
server.time # Get the current time of the system
server.echo # Return current request
server.databaseVersion # Return the required version of the database
server.shutdown # Initiate shutdown sequence
```

UNTESTED

``` ruby
server.test body: body # Runs tests on server
server.execute body: body # Execute a script on the server.
```

### Cluster (UNTESTED)

ArangoDB permits the sharding of the database. Although these methods has not been tested with ArangoRB.

``` ruby
server.clusterHealth port: port # Allows to check whether a given port is usable
server.serverId # Returns the id of a server in a cluster.
server.clusterStatistics dbserver: dbserver # Allows to query the statistics of a DBserver in the cluster
```

## Arango::Batch

To create a batch request, you can use ArangoRB::Batch object. This permit to do multiple requests with one single call to the API.

To create a batch use one of the following choice:
``` ruby
batch = server.batch
batch = Arango::Batch.new(server: server)
```

To add a queries to the batch request you can use the brutal way:

``` ruby
batch.queries = [
  {
    "type": "POST",
    "address": "/_db/MyDatabase/_api/collection",
    "body": {"name": "newCOLLECTION"},
    "id": "1"
  },
  {
    "type": "GET",
    "address": "/_api/database",
    "id": "2"
  }
]
```

Or the Ruby way (the id will be handled by the system, if not specified):

``` ruby
batch = server.batch
batch.addQuery(method: "POST", address: "/_db/MyDatabase/_api/collection",
  body: {"name": "newCOLLECTION"})
batch.addQuery(method: "GET", address: "/_api/database")
```

In both the cases the queries will be stored in an hash with key the id of the query and as value the query.
This query can be handled with the following methods:

``` ruby
batch.modifyQuery(id: "1", method: "GET", address: "/_db/MyDatabase/_api/collection/newCOLLECTION") # Modify the Query with id "1"
batch.removeQuery(id: "1") # Remove query
```

To execute the query use:
``` ruby
batch.execute
```

To manage how the server handle the batch, Arango::Server offers the following functions:

``` ruby
server.createDumpBatch ttl: 10 # Create a new dump batch with 10 second time-to-live (return id of the dumpBatch)
server.prolongDumpBatch id: idDumpBatch, ttl: 20 # Prolong the life of a batch for 20 seconds
server.destroyDumpBatch id: idDumpBatch # Delete a selected batch
```

<a name="ArangoDatabase"></a>
## Arango::Database

ArangoDatabase is used to manage your Database. You can create an instance in the following ways:

``` ruby
myDatabase = server.database name: "MyDatabase"
myDatabase = server["MyDatabase"]
myDatabase = Arango::Database.new database: "MyDatabase", server: server
```

### Create and Destroy a Database

``` ruby
myDatabase.create # Create a new Database
myDatabase.retrieve # Retrieve database
myDatabase.destroy # Delete the selected Database
```

### Retrieve information

``` ruby
server.databases # Obtain an Array with the available databases in the server
myDatabase.to_h # Hash of the instance
myDatabase.info # Obtain general info about the databases
myDatabase.collections # Obtain an Array with the available collections in the selected Database
myDatabase.graphs #  Obtain an Array with the available graphs in the selected Database
myDatabase.functions #  Obtain an Array with the available functions in the selected Database
```

## Arango::AQL

An AQL instance can be created by using one of the following way:

``` ruby
query = "FOR v,e,p IN 1..6 ANY 'Year/2016' GRAPH 'MyGraph' FILTER p.vertices[1].num == 6 && p.vertices[2].num == 22 && p.vertices[6]._key == '424028e5-e429-4885-b50b-007867208c71' RETURN [p.vertices[4].value, p.vertices[5].data]"
myQuery = myDatabase.aql query: query
myQuery = ArangoAQL.new database: myDatabase, query: query
```

To execute it use:

``` ruby
myQuery.execute
```

If the query is too big, you can divide the fetching in pieces, for example:

``` ruby
myQuery.size = 10
myQuery.execute # First 10 documents
myQuery.next # Next 10 documents
myQuery.next # Next 10 documents
```

Other useful methods are the following

``` ruby
myQuery.destroy # Destroy cursor to retrieve documents
myQuery.kill # Kill query request (if requires too much time)
myQuery.explain # Show data query
myQuery.parse # Parse query
```

### Query Properties

It is possible to handle generic properties of query by Arango::Database.

``` ruby
myQuery.properties  # Check Query properties
myQuery.current # Retrieve current running Query
myQuery.changeProperties maxSlowQueries: 65 # Change Properties
myQuery.slow # Retrieve slow Queries
myQuery.stopSlowQueries # Stop slow Queries
```

The cache of the query can handle in the following way:

``` ruby
myDatabase.retrieveQueryCache # Retrieve Query Cache
myDatabase.clearQueryCache # Clear Query Cache
myDatabase.propertyQueryCache # Check properties Cache
myDatabase.changePropertyQueryCache maxResults: 30 # Change properties Cache
```

### AQL Functions

AQL queries can be potentiate by providing javascript function as supports.

``` ruby
myDatabase.createAqlFunction code: "function(){return 1+1;}", name: "myFunction" # Create a new AQL Function
myDatabase.deleteFunction name: "myFunction" # Delete an AQL function
myDatabase.aqlFunctions # Retrieve a list of the available aql functions
```

<!-- ### User

You can manage the right of a user to access the database.

``` ruby
myDatabase.grant user: myUser # Grant access to database
myDatabase.revoke user: myUser # Revoke access to database
``` -->

<a name="ArangoCollection"></a>
## Arango::Collection

Arango::Collection is used to manage your Collections. You can create an Arango::Collection instance in one of the following way:

``` ruby
myCollection = myDatabase.collection name: "MyCollection"
myCollection = myDatabase["MyCollection"]
myCollection = Arango::Collection.new database: myDatabase, collection: "MyCollection"
```

A Collection can be of two types: "Document" and "Edge". If you want to specify it, uses:

``` ruby
myCollectionA = ArangoCollection.new collection: "MyCollectionA", type: :document # Default
myCollectionB = ArangoCollection.new collection: "MyCollectionB", type: :edge
```

### Main methods

``` ruby
myCollection.create
myCollection.destroy # Delete collection from database
myCollection.truncate # Delete all the Documents inside the selected Collection
myCollection.retrieve # Retrieve the selected Collection
```

### List methods

``` ruby
myCollection.indexes # Return a list of all used Indexes in the Collection
myCollection.documents # Return documents from the collection
myCollection.next # Return next documents if the method documents was not able
# to retrieve all the documents at once
myCollection.documents(type: "id") # Return all the documents by limiting on only the ids (similar if you use type "key" or "path")
```

### Info methods

``` ruby
myCollection.rotate # Rotate the collection
myCollection.data # Returns the whole content of one collection
myCollection.properties # Properties of the Collection
myCollection.count # Number of Documents in the Collection
myCollection.stats # Statistics of the Collection
myCollection.revision # Return collection revision id
myCollection.checksum # Return checksum for the Collection
```

### Modify the Collection

``` ruby
myCollection.load # Load the collection (preparing for retrieving documents)
myCollection.unload # Unload the collection (if you stop to work with it)
myCollection.loadIndexesIntoMemory # Load indexes in memory
myCollection.change(waitForSync: true) # Change some properties
myCollection.rename(newName: "myCollection2") # Change name (NB: This is not Arango::Cache compatible)
myCollection.rotate # Rotate journal of a collection
```

### Handle documents

To retrieve all the documents of a Collection you can use:

``` ruby
myCollection.documents
myCollection.allDocuments
```

These two functions are similar except for the fact that you can assign different variables.

``` ruby
myCollection.documents type: "path"
myCollection.next # Retrieve other documents if the first request is not finished
```

Type can be "path", "id" or "key" in relation what we wish to have. If not specified ArangoRB will return an array of Arango::Document instances.

``` ruby
myCollection.allDocuments skip: 3, limit: 100, batchSize: 10
```

It means that we skip the first three Documents, we can retrieve the next 100 Documents but we return only the first ten.

To retrieve specific Document you can use:

``` ruby
myCollection.documentsMatch match: {"value" => 4} # All Documents of the Collection with value equal to 4
myCollection.documentMatch match: {"value" => 4} # The first Document of the Collection with value equal to 4
myCollection.documentByKeys keys: ["4546", "4646"] # Documents of the Collection with the keys in the Array
myCollection.documentByName names: ["4546", "4646"] # Documents of the Collection with the name in the Array
myCollection.random # A random Document of the Collection
```

### Modifying multiple documents

``` ruby
myCollection.createDocuments document: 
myCollection.removeByKeys keys: ["4546", "4646"] # Documents of the Collection with the keys in the Array will be removed
myCollection.removeMatch match: {"value" => 4} # All Documents of the Collection with value equal to 4 will be removed
myCollection.replaceMatch match: {"value" => 4}, newValue: {"value" => 6} # All Documents of the Collection with value equal to 4 will be replaced with the new Value
myCollection.updateMatch match: {"value" => 4}, newValue: {"value" => 6} # All Documents of the Collection with value equal to 4 will be updated with the new Value
```


### Import and Export Documents

For the standard way to import one or more Documents (or Edges) we refer to the [dedicated ArangoDocument section](#create_doc).
However it is possible to import a huge quantity of documents in a Collection with only one requests with the command import.

<strong>Import one Document with Array</strong>
I import one document with the following structure {"value": "uno", "num": 1, "name": "ONE"}.
``` ruby
attributes = ["value", "num", "name"]
values = ["uno",1,"ONE"]
myCollection.import attributes: attributes, values: values
```

<strong>Import more Documents with Array</strong>
I import three Documents with the following structure {"value": "uno", "num": 1, "name": "ONE"}, {"value": "due", "num": 2, "name": "TWO"}, {"value": "tre", "num": 3, "name": "THREE"}.
``` ruby
attributes = ["value", "num", "name"]
values = [["uno",1,"ONE"],["due",2,"TWO"],["tre",3,"THREE"]]
myCollection.import attributes: attributes, values: values
```

<strong>Import more Documents with JSON</strong>
I import two Documents with the following structure {"value": "uno", "num": 1, "name": "ONE"}, {"value": "due", "num": 2, "name": "TWO"}.
``` ruby
body = [{"value": "uno", "num": 1, "name": "ONE"}, {"value": "due", "num": 2, "name": "DUE"}]
myCollection.importJSON body: body
```

As it is possible to import files, it is possible to export all the Document of a Collection with the following command.
``` ruby
myCollection.export
```

Alternatively it is possible to retrieve all the Documents in a Collection gradually.

``` ruby
myCollection.export batchSize: 3 # First three Documents of the Collection
myCollection.exportNext # Next three Documents
myCollection.exportNext # Next three Documents
```



<a name="ArangoDocument"></a>
## ArangoDocument

An Arango Document is an element of a Collection. Edges are documents with "\_from" and "\_to" in their body.
You can create an ArangoCollection instance in one of the following way:

``` ruby
myDocument = ArangoDocument.new database: "MyDatabase", collection: "MyCollection", key: "myKey"
myDocument = ArangoDocument.new collection: "MyCollection", key: "myKey"  # Using default Database
myDocument = ArangoDocument.new key: "myKey" # Using default Collection and Database
myDocument = ArangoDocument.new #  Using default Collection and Database and I don't want to define a key for my Instance
```

In the case you want to define a Edge, it is convenient to introduce the parameters "from" and "to" in the instance.

``` ruby
myEdge = ArangoDocument.new from: myDocA, to: myDocB
```

where myDocA and myDocB are the IDs of two Documents or are two ArangoDocument instances.
During the instance, it is possible to define a Body for the Document.

``` ruby
myDocument = ArangoDocument.new body: {"value" => 17}
```

<a name="create_doc"></a>
### Create one or more Documents

ArangoRB provides several way to create a single Document.

``` ruby
myDocument.create
myCollection.create_document document: myDocument # myDocument is an ArangoDocument instance or a Hash
ArangoDocument.create body: {"value" => 17}, collection: myDocument
```

Or more Documents.

``` ruby
myCollection.create_document document: [myDocumentA, myDocumentB, {"value" => 17}] # Array of ArangoDocument instances and Hashes
ArangoDocument.create body: [myDocumentA, {"value" => 18}, {"value" => 3}], collection: myDocument  # Array of ArangoDocument instances and Hash
```

### Create one or more Edges

ArangoRB has different way to create one or multiple edges. Here some example:

``` ruby
myEdge = ArangoDocument.new from: myDocA, to: myDocB; myEdge.create
myEdge.create_edge from: myDocA, to: myDocB # myDocA and myDocB are ArangoDocument ids or ArangoDocument instances
myEdgeCollection.create_edge document: myEdge, from: myDocA, to: myDocB
ArangoDocument.create_edge body: {"value" => 17}, from: myDocA, to: myDocB, collection: myEdgeCollection
```

Further we have the possibility to create different combination of Edges in only one line of code

One-to-one with one Edge class

 * [myDocA] --(myEdge)--> [myDocB]

``` ruby
myEdgeCollection.create_edge document: myEdge, from: myDocA, to: myDocB
```

One-to-more with one Edge class (and More-to-one with one Edge class)

 * [myDocA] --(myEdge)--> [myDocB]
 * [myDocA] --(myEdge)--> [myDocC]

 ``` ruby
myEdgeCollection.create_edge document: myEdge, from: myDocA, to: [myDocB, myDocC]
```

More-to-More with one Edge class

 * [myDocA] --(myEdge)--> [myDocC]
 * [myDocB] --(myEdge)--> [myDocC]
 * [myDocA] --(myEdge)--> [myDocD]
 * [myDocB] --(myEdge)--> [myDocD]

 ``` ruby
myEdgeCollection.create_edge document: myEdge, from: [myDocA, myDocB], to: [myDocC, myDocD]
```

More-to-More with more Edge classes

 * [myDocA] --(myEdge)--> [myDocC]
 * [myDocB] --(myEdge)--> [myDocC]
 * [myDocA] --(myEdge)--> [myDocD]
 * [myDocB] --(myEdge)--> [myDocD]
 * [myDocA] --(myEdge2)--> [myDocC]
 * [myDocB] --(myEdge2)--> [myDocC]
 * [myDocA] --(myEdge2)--> [myDocD]
 * [myDocB] --(myEdge2)--> [myDocD]

 ``` ruby
myEdgeCollection.create_edge document: [myEdge, myEdge2], from: [myDocA, myDocB], to: [myDocC, myDocD]
```

### Destroy a Document

``` ruby
myDocument.destroy
```

### Retrieve information

``` ruby
myDocument.retrieve # Retrieve Document
myDocument.collection # Retrieve Collection of the Document
myDocument.database # Retrieve Database of the Document
myDocument.retrieve_edges collection: myEdgeCollection  # Retrieve all myEdgeCollection edges connected with the Document
myDocument.any(myEdgeCollection) # Retrieve all myEdgeCollection edges connected with the Document
myDocument.in(myEdgeCollection)  # Retrieve all myEdgeCollection edges coming in the Document
myDocument.out(myEdgeCollection) # Retrieve all myEdgeCollection edges going out the Document
myEdge.from # Retrieve the document at the begin of the edge
myEdge.to # Retrieve the document at the end of the edge
```

#### Example: how to navigate the edges

Think for example that we have the following schema:
 * A --[class: a, name: aa]--> B
 * A --[class: a, name: bb]--> C
 * A --[class: b, name: cc]--> D
 * B --[class: a, name: dd]--> E

Then we have:

 * A.retrieve is A
 * A.retrieve_edges(collection: a) is [aa, bb]
 * B.any(a) is [aa, dd]
 * B.in(a) is [aa]
 * B.out(a) is [dd]
 * aa.from is A
 * aa.to is B

We can even do some combinations: for example A.out(a)[0].to.out(a)[0].to is E since:
 * A.out(a) is [aa]
 * A.out(a)[0] is aa
 * A.out(a)[0].to is B
 * A.out(a)[0].to.out(a) is [dd]
 * A.out(a)[0].to.out(a)[0] is dd
 * A.out(a)[0].to.out(a)[0].to is E

### Modify

``` ruby
myDocument.update body: {"value" => 3} # We update or add a value
myDocument.replace body: {"value" => 3} # We replace a value
```

<a name="ArangoGraph"></a>
## ArangoGraph

ArangoGraph are used to manage Graphs. You can create an ArangoGraph instance in one of the following way.

``` ruby
myGraph = ArangoGraph.new database: "MyDatabase", graph: "MyGraph"
myGraph = ArangoGraph.new graph: "MyGraph" # By using the default Database
myGraph = ArangoGraph.new # By using the defauly Database and Graph
```

### Create, Retrieve and Destroy a Graph

``` ruby
myGraph.create # create a new Graph
myGraph.retrieve # retrieve the Graph
myGraph.database # retrieve database of the Graph
myGraph.destroy # destroy the Graph
```

### Manage Vertex Collections

``` ruby
myGraph.vertexCollections # Retrieve all the vertexCollections of the Graph
myGraph.addVertexCollection collection: "myCollection"  # Add a Vertex Collection to our Graph
myGraph.removeVertexCollection collection: "myCollection"  # Remove a Vertex Collection to our Graph
```

### Manage Edge Collections

``` ruby
myGraph.edgeCollections # Retrieve all the edgeCollections of the Graph
myGraph.addEdgeCollections collection: "myEdgeCollection", from: "myCollectionA", to: "myCollectionB"  # Add an Edge Collection to our Graph
myGraph.replaceEdgeCollections collection: "myEdgeCollection", from: "myCollectionA", to: "myCollectionB"  # Replace an Edge Collection to our Graph
myGraph.removeEdgeCollections collection: "myEdgeCollection"  # Remove an Edge Collection to our Graph
```

<a name="ArangoVertex"></a><a name="ArangoEdge"></a>
## ArangoVertex and ArangoEdge

Both these two classes inherit the class ArangoDocument.
These two classes have been created since ArangoDatabase offers, in connection of the chosen graph, different HTTP requests to manage Vertexes and Edges. We recommend the reader to read carefully the section on [ArangoDocument instances](#ArangoDocument) before to start to use ArangoVertex and ArangoEdge instances.

### ArangoVertex methods

ArangoVertex inherit all the methods of ArangoDocument class. The following one works similar to the one of ArangoDocument Class but use different HTTP requests. For this reason the performance could be different.
To use ArangoVertex, the Collection of the Vertex needs to be added either to the VertexCollections or to the EdgeCollections of the chosen Graph.

``` ruby
myVertex = ArangoVertex.new key: "newVertex", body: {"value" => 3}, collection: "myCollection", graph: "myGraph", database: "myDatabase" # create a new instance
myVertex.create # create a new Document in the Graph
myVertex.retrieve  # retrieve a Document
myVertex.graph # Retrieve Graph  of the Document
myVertex.replace body: {"value" => 6} # replace the Document
myVertex.update body: {"value" => 6} # update the Document
myVertex.destroy # delete the Document
```

### ArangoEdge methods

ArangoEdge inherit all the methods of ArangoDocument class. The following one works similar to the one of ArangoDocument Class but use a different HTTP request. For this reason the performance could be different.
To use ArangoEdge, the Collection of the Edge needs to be added to the EdgeCollections of the chosen Graph.

``` ruby
myEdge = ArangoEdge.new key: "newVertex", body: {"value" => 3}, from: myArangoDocument, to: myArangoDocument, collection: "myCollection", graph: "myGraph", database: "myDatabase" # create a new instance
myEdge.create # create a new Document of type Edge in the Graph
myEdge.retrieve # retrieve a Document
myEdge.graph # Retrieve Graph  of the Document
myEdge.replace body: {"value" => 6} # replace the Document
myEdge.update body: {"value" => 6} # update the Document
myEdge.destroy # delete the Document
```

<a name="ArangoTraversal"></a>
## ArangoTraversal

ArangoTraversal is used to administrate the traversals.
ArangoTraversal needs to know the vertex from where the traversal starts, the direction the traversal is going and either the Graph or the EdgeCollection we want to analize.

``` ruby
myTraversal = ArangoTraversal.new # create new ArangoTraversal
myTraversal.vertex = myVertex # define starting Vertex
myTraversal.graph = myGraph  # define used Graph
myTraversal.edgeCollection = myEdgeCollection # define used Edge
myTraversal.in # Direction is in
myTraversal.out  # Direction is out
myTraversal.any  # Direction is in and out
myTraversal.min = 1 # Define how minimum deep we want to go with the traversal
myTraversal.max = 3 # Define how maximum deep we want to go with the traversal
```

After the traversal is setup, you can execute it:

``` ruby
myTraversal.execute
```

<a name="arangoaql"></a>
## ArangoAQL - ArangoDatabase Query Language

ArangoAQL is used to manage the ArangoDB query language. To instantiate a query

``` ruby
myQuery = ArangoAQL.new query: "FOR v,e,p IN 1..6 ANY 'Year/2016' GRAPH 'MyGraph' FILTER p.vertices[1].num == 6 && p.vertices[2].num == 22 && p.vertices[6]._key == '424028e5-e429-4885-b50b-007867208c71' RETURN [p.vertices[4].value, p.vertices[5].data]"
```

To execute it use:
``` ruby
myQuery.execute
```

If the query is too big, you can divide the fetching in pieces, for example:
``` ruby
myQuery.size = 10
myQuery.execute # First 10 documents
myQuery.next # Next 10 documents
myQuery.next # Next 10 documents
```

### Check property query

``` ruby
myQuery.explain # Show data query
myQuery.parse # Parse query
myQuery.properties;  # Check properties
myQuery.current; # Retrieve current Query
myQuery.slow; # Retrieve slow Queries
myQuery.changeProperties maxSlowQueries: 65 # Change Properties
```

### Delete query

``` ruby
myQuery.stopSlow; # Stop Slow query
myQuery.kill; # Kill Query
```

<a name="ArangoUser"></a>
## ArangoUser

ArangoUser manages the users.
To initialize an user:

``` ruby
myUser = ArangoUser.new user: "MyUser", password: "password"
```

### User management

``` ruby
myUser.retrieve # Retrieve User
myUser["MyDatabase"] # Retrieve database if the user can access it
myUser.create # Create a new User
myUser.replace active: false # Replace User
myUser.update active: false # Update User
myUser.destroy # Delete User
```

### Database management

``` ruby
myUser.databases # Check permission Databases
myUser.grant database: "MyDatabase" # Grant access to a database
myUser.revoke database: "MyDatabase" # Revoke access to a database
```

<a name="ArangoIndex"></a>
## ArangoIndex

ArangoIndex manages the indexes.
To initialize an index:

``` ruby
myIndex = ArangoIndex.new fields: "num", unique: false, id: "myIndex"
```

### Index management

``` ruby
myIndex.retrieve # Retrieve Index
myIndex.create # Create a new Index
ArangoIndex.indexes collection: "MyCollection" # List indexes
myIndex.destroy # Delete Index
```

Alternatively, you can create an Index of a Collection directly from its Collection.

``` ruby
myCollection.createIndex unique: false, fields: "num", type: "hash"
```

<a name="ArangoTransaction"></a>
## ArangoTransaction

Transactions are managed by ArangoTransaction. This class has only initialization and execution.

``` ruby
myArangoTransaction = ArangoTransaction.new action: "function(){ var db = require('@arangodb').db; db.MyCollection.save({}); return db.MyCollection.count(); }", write: myCollection # Or read
myArangoTransaction.execute # Return the result of the execution
```

<a name="ArangoTask"></a>
## ArangoTask

Tasks are managed by ArangoTask.

``` ruby
myArangoTask = ArangoTask.new id: "mytaskid", name: "MyTaskID", command: "(function(params) { require('@arangodb').print(params); })(params)", params: {"foo" => "bar", "bar" => "foo"}, period: 2 # Initialize a  Task Instance that will be alive for 2 seconds
myArangoTask.create # Create a new Task
ArangoTask.tasks # Retrieve a list of active tasks
myArangoTask.retrieve # Retrieve a Task
myArangoTask.destroy # Delete a Task
```

<a name="ArangoCache"></a>
## ArangoCache

ArangoCache helps you to manage your request to your Database by creating a cache.

``` ruby
myQuery = ArangoAQL.new query: "FOR v,e,p IN 1..6 ANY 'Year/2016' GRAPH 'MyGraph' FILTER p.vertices[1].num == 6 && p.vertices[2].num == 22 && p.vertices[6]._key == '424028e5-e429-4885-b50b-007867208c71' RETURN [p.vertices[4].value, p.vertices[5].data]"
myQuery.execute # Heavy computation
ArangoCache.cache data: myQuery # Cache these heavy query
ArangoCache.uncache data: myQuery # Retrieve cached ArangoAQL with same query request
ArangoCache.clear data: myQuery # Free the cache from these three documents
ArangoCache.clear type: "AQL" # Delete cache from AQL requests
ArangoCache.clear # Clear completely all the cache
```

Alternatively we can save, retrieve and delete multiple values

``` ruby
myQuery = ArangoAQL.new query: "FOR v,e,p IN 1..6 ANY 'Year/2016' GRAPH 'MyGraph' FILTER p.vertices[1].num == 6 && p.vertices[2].num == 22 && p.vertices[6]._key == '424028e5-e429-4885-b50b-007867208c71' RETURN [p.vertices[4].value, p.vertices[5].data]"
myQuery2 = ArangoAQL.new query: "FOR u IN Hour FILTER u._key == "2016-10-04T23" RETURN u"
myQuery.execute # Heavy computation
myQuery2.execute
ArangoCache.cache data: [myQuery, myQuery2] # Cache these heavy query
ArangoCache.uncache data: [myQuery, myQuery2] # Retrieve cached ArangoAQL
ArangoCache.clear data: [myQuery, myQuery2] # Free the cache from these request
```

If we need we can save with personalized ID.

``` ruby
ArangoCache.cache id: ["myFirstQuery", "mySecondQuery"] data: [myQuery, myQuery2] # Cache these heavy query
ArangoCache.uncache type: "AQL", id: ["myFirstQuery", "mySecondQuery"] # Retrieve cached ArangoAQL
ArangoCache.clear type: "AQL", id: ["myFirstQuery", "mySecondQuery"] # Free the cache from these request
```

The type and the quantity that you can save in the cache are the following: Database: 1, Collection: 20, Document: 200, Graph: 1, Vertex: 50, Edge: 100, Index: 20, AQL: 100, User: 50, Task: 20, Traversal: 20, Transaction: 20, Other: 100. For "Other" we mean all the values that are not included in the other categories.

To modify these limitations you can use the following command:
``` ruby
ArangoCache.max type: "Document", val: 100 # Change limits Document
```
NB: If you insert a max value higher than the quantity of elements in the Cache, then the first elements in excess will be removed from the Cache.

If the limit of the Cache for one type is reached, then the first element cached of that type will be deleted from the Cache.

<a name="ArangoReplication"></a>
## Replication

Replication is useful to create back up copy of your database or to have a master-slave relationship between two databases.

Remember: the used database is the one where the data will be written (the slave) and the remote database will be the master one.

Use with caution since the data in the slave database will be deleted.

To setup our Slave Server and Master Database use a similar command.

``` ruby
Arango::Server.default_server user: "root", password: "tretretre", server: "172.17.8.101", port: "8529" # Our Slave Server
myReplication = ArangoReplication.new endpoint: "tcp://10.10.1.97:8529", username: "root", password: "", database: "year" # Our Master Database
```

Than to do a simple syncronization uses;

``` ruby
myReplication.sync
```

To retrieve some information ArangoRB provides the following methods:

``` ruby
myDatabase = ArangoDatabase.new database: "year"
myCollection = myDatabase["MyCollection"]
myDatabase.inventory # Fetch Collection data
myCollection.dump # Fetch all the data in one class from one tick to another
myReplication.logger # Returns the current state of the server's replication logger
myReplication.loggerFollow # Returns data from the server's replication log.
myReplication.firstTick # Return the first available tick value from the server
myReplication.rangeTick # Returns the currently available ranges of tick values for all currently available WAL logfiles.
myReplication.serverId # Returns the servers id.
```

### Relation Master-Slave

To enslave a Server in relation to another Database use the following command:

``` ruby
myReplication.enslave
```

To manage the Configuration of a Master-Slave Replication you can use the following commands:

``` ruby
myReplication.configurationReplication # check the Configuration of the Replication
myReplication.stateReplication # check the status of the Replication
myReplication.stopReplication # stop the Replication
myReplication.modifyReplication  # modify the Configuration of the Replication (you can modify only a stopped Replication)
myReplication.startReplication # restart the replication
```
