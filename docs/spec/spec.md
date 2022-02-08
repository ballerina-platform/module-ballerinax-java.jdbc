# Specification: Ballerina JDBC Library

_Owners_: @daneshk @niveathika  
_Reviewers_: @daneshk  
_Created_: 2022/01/14   
_Updated_: 2022/02/08  
_Edition_: Swan Lake  
_Issue_: [#2290](https://github.com/ballerina-platform/ballerina-standard-library/issues/2290)

# Introduction

This is the specification for the JDBC standard library of [Ballerina language](https://ballerina.io/), which provides the functionality that is required to access and manipulate data stored in a relational database.

The JDBC library specification has evolved and may continue to evolve in the future. Released versions of the specification can be found under the relevant GitHub tag.

If you have any feedback or suggestions about the library, start a discussion via a [GitHub issue](https://github.com/ballerina-platform/ballerina-standard-library/issues) or in the [Slack channel](https://ballerina.io/community/). Based on the outcome of the discussion, specification and implementation can be updated. Community feedback is always welcome. Any accepted proposal which affects the specification is stored under `/docs/proposals`. Proposals under discussion can be found with the label `type/proposal` in GitHub.

Conforming implementation of the specification is released to Ballerina central. Any deviation from the specification is considered a bug.

# Contents

1. [Overview](#1-overview)
2. [Client](#2-client)  
   2.1. [Connection Pool Handling](#21-connection-pool-handling)  
   2.2. [Closing the Client](#22-closing-the-client)
3. [Queries and Values](#3-queries-and-values)  
4. [Database Operations](#4-database-operations)

# 1. Overview

This specification elaborates on usage of JDBC `Client` interface to interface with a relational database such as MySQL, 
MSSQL, Postgresql and OracleDB.

`Client` supports five database operations as follows,
1. Executes the query, which may return multiple results.
2. Executes the query, which is expected to return at most one row of the result.
3. Executes the SQL query. Only the metadata of the execution is returned.
4. Executes the SQL query with multiple sets of parameters in a batch. Only the metadata of the execution is returned.
5. Executes an SQL query, which calls a stored procedure. This can either return results or nil.

All the above operations make use of the sql:ParameterizedQuery` object and the string template surrounded by backticks to pass
SQL statements to the database. `sql:ParameterizedQuery` supports passing of Ballerina basic types or typed SQL values 
such as `sql:CharValue`, `sql:BigIntValue`, etc. to indicate parameter types in SQL statements.

# 2. Client

Each client represents a pool of connections to the database. The pool of connections is maintained throughout the
lifetime of the client.

**Initialisation of the Client:**
```ballerina
# Initializes the JDBC client.
#
# + url - The JDBC URL to be used for the database connection
# + user - If the database is secured, the username
# + password - The password of the database associated with the provided username
# + options - The JDBC client properties
# + connectionPool - The `sql:ConnectionPool` to be used for the connection. If there is no
#                    `connectionPool` provided, the global connection pool (shared by all clients) will be used
# + return - An `sql:Error` if the client creation fails
public isolated function init(string url, string? user = (), string? password = (),
  Options? options = (), sql:ConnectionPool? connectionPool = ()) returns sql:Error?;
```

**Configurations available for initializing the JDBC client:**
* Connection properties:
   ```ballerina
   # An additional set of configurations related to a database connection.
   #
   # + datasourceName - The driver class name to be used to get the connection
   # + properties - The database properties, which should be applied when getting the connection
   # + requestGeneratedKeys - The database operations for which auto-generated keys should be returned
   public type Options record {|
       string? datasourceName = ();
       map<anydata>? properties = ();
       Operations requestGeneratedKeys = ALL;
   |};
   ```

## 2.1. Connection Pool Handling

Connection pool handling is generic and implemented through the `sql` module. For more information, see the 
[SQL Specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#21-connection-pool-handling)

## 2.2. Closing the Client

Once all the database operations are performed, the client can be closed by invoking the `close()`
operation. This will close the corresponding connection pool if it is not shared by any other database clients.

   ```ballerina
   # Closes the JDBC client and shuts down the connection pool.
   #
   # + return - Possible error when closing the client
   public isolated function close() returns Error?;
   ```

# 3. Queries and Values

All the generic `sql` queries and values are supported. For more information, see the 
[SQL Specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#3-queries-and-values).

# 4. Database Operations

`Client` supports five database operations as follows,
1. Executes the query, which may return multiple results.
2. Executes the query, which is expected to return at most one row of the result.
3. Executes the SQL query. Only the metadata of the execution is returned.
4. Executes the SQL query with multiple sets of parameters in a batch. Only the metadata of the execution is returned.
5. Executes an SQL query, which calls a stored procedure. This can either return results or nil.

For more information on Database Operations see the [SQL Specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#4-database-operations)
