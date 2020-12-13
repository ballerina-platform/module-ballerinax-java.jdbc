## Module overview

This module provides the functionality required to access and manipulate data stored in any type of relational database 
that is accessible via Java Database Connectivity (JDBC). 

**Prerequisite:** Add the JDBC driver corresponding to the database you are trying to interact with
as a native library dependency in your Ballerina project. Then, once you build the project by executing the `ballerina build`
command, you should be able to run the resultant by executing the `ballerina run` command.

E.g., The `Ballerina.toml` content.
Change the path to the JDBC driver appropriately.

```toml
[package]
org = "sample"
name = "jdbc"
version= "0.1.0"

[[platform.java11.dependency]]
artafactId = "h2"
version = "1.4.200"
path = "/path/to/com.h2database.h2-1.4.200.jar"
groupId = "com.h2database"
modules = ["samplemodule"]
``` 

### Client
To access a database, you must first create a 
[jdbc:Client](https://ballerina.io/swan-lake/learn/api-docs/ballerina/#/jdbc/clients/Client) object. 
The examples for creating a JDBC client can be found below.

#### Creating a client
This example shows the different ways of creating the `jdbc:Client`. The client can be created by passing 
the JDBC URL, which is a mandatory property and all other fields are optional. 

The `dbClient1` receives only the database URL and the `dbClient2` receives the username and password in addition to the URL. 
If the properties are passed in the same order as it is defined in the `jdbc:Client`, you can pass it 
without named params.

The `dbClient3` uses the named params to pass all the attributes and provides the `options` property in the type of 
[jdbc:Options](https://ballerina.io/swan-lake/learn/api-docs/ballerina/#/jdbc/records/Options) 
and also uses the unshared connection pool in the type of 
[sql:ConnectionPool](https://ballerina.io/swan-lake/learn/api-docs/ballerina/#/sql/records/ConnectionPool). 
For more information about connection pooling, see [SQL Module](https://ballerina.io/swan-lake/learn/api-docs/ballerina/#/sql).

The `dbClient4` receives some custom properties within the 
[jdbc:Options](https://ballerina.io/swan-lake/learn/api-docs/ballerina/#/jdbc/records/Options)
and those properties will be used by the defined `datasourceName`. 
As per the provided example, the `org.h2.jdbcx.JdbcDataSource` datasource  will be configured with a `loginTimeout` 
of `2000` milli seconds.

```ballerina
jdbc:Client|sql:Error dbClient1 = new ("jdbc:h2:~/path/to/database");
jdbc:Client|sql:Error dbClient2 = new ("jdbc:h2:~/path/to/database", 
                            "root", "root");
jdbc:Client|sql:Error dbClient3 = new (url =  "jdbc:h2:~/path/to/database",
                             user = "root", password = "root",
                             options = {
                                 datasourceName: "org.h2.jdbcx.JdbcDataSource"
                             },
                             connectionPool = {
                                 maxOpenConnections: 5
                             });
jdbc:Client|sql:Error dbClient4 = new (url =  "jdbc:h2:~/path/to/database", 
                             user = "root", password = "root",
                             options = {
                                datasourceName: "org.h2.jdbcx.JdbcDataSource", 
                                properties: {"loginTimeout": "2000"}
                             });                          
```

You can find more details about each property in the
[jdbc:Client](https://ballerina.io/swan-lake/learn/api-docs/ballerina/#/jdbc/clients/Client) constructor. 

The [jdbc:Client](https://ballerina.io/swan-lake/learn/api-docs/ballerina/#/jdbc/clients/Client) references 
[sql:Client](https://ballerina.io/swan-lake/learn/api-docs/ballerina/#/sql/abstractObjects/Client) and 
all the operations defined by the `sql:Client` will be supported by the `jdbc:Client` as well. 

For more information on all the operations supported by the `jdbc:Client`, which include the below, see the
[SQL Module](https://ballerina.io/swan-lake/learn/api-docs/ballerina/#/jdbc/clients/Client).

1. Connection Pooling
2. Querying data
3. Inserting data
4. Updating data
5. Deleting data
6. Batch insert and update data
7. Execute stored procedures
8. Closing client
