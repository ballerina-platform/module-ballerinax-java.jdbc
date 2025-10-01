// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/jballerina.java;
import ballerina/sql;
import ballerina/lang.'string as strings;

# JDBC database client that enables interaction with any SQL servers and supports standard SQL operations.
public isolated client class Client {
    *sql:Client;

    # Connects to a SQL database with the specified configuration.
    #
    # + url - The JDBC URL for the database connection
    # + user - Database username
    # + password - Database password
    # + options - The advanced connection options specific to the SQL database
    # + connectionPool - The `sql:ConnectionPool` object to be used within the client. If not provided, the global connection pool (shared by all clients) will be used
    # + return - An `sql:Error` if the client creation fails
    public isolated function init(string url, string? user = (), string? password = (),
            Options? options = (), sql:ConnectionPool? connectionPool = ()) returns sql:Error? {
        if strings:startsWith(url, "jdbc:sqlserver") && isRequestGeneratedKeysSupportsBatchExecute(options) {
            return error sql:ApplicationError("Unsupported `requestGeneratedKeys` option for MSSQL database, " +
                        "expected `jdbc:EXECUTE` or `jdbc:NONE`");
        }
        ClientConfiguration clientConf = {
            url: url,
            user: user,
            password: password,
            options: options,
            connectionPool: connectionPool
        };
        return createClient(self, clientConf, sql:getGlobalConnectionPool());
    }

    # Executes a SQL query and returns multiple results as a stream.
    #
    # + sqlQuery - The SQL query as `sql:ParameterizedQuery` (e.g., `` `SELECT * FROM users WHERE id=${userId}` ``)
    # + rowType - The `typedesc` of the record type to which the result needs to be mapped
    # + return - Stream of records containing the query results. Please ensure that the stream is fully consumed, or close the stream.
    remote isolated function query(sql:ParameterizedQuery sqlQuery, typedesc<record {}> rowType = <>)
    returns stream<rowType, sql:Error?> = @java:Method {
        'class: "io.ballerina.stdlib.java.jdbc.nativeimpl.QueryProcessor",
        name: "nativeQuery"
    } external;

    # Executes a SQL query that is expected to return a single row or value as the result.
    #
    # + sqlQuery - The SQL query as `sql:ParameterizedQuery` (e.g., `` `SELECT * from Album WHERE name=${albumName}` ``)
    # + returnType - The `typedesc` of the anydata (record or basic type) to which the result needs to be returned.
    #                It can be a basic type if the query result contains only one column
    # + return - The result of the query or an `sql:Error`.
    #           - If the query does not return any results, an `sql:NoRowsError` is returned.
    #           - If the query returns multiple rows, only the first row is returned.
    remote isolated function queryRow(sql:ParameterizedQuery sqlQuery, typedesc<anydata> returnType = <>)
    returns returnType|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.java.jdbc.nativeimpl.QueryProcessor",
        name: "nativeQueryRow"
    } external;

    # Executes a SQL query and returns execution metadata (not the actual query results).
    # This function is typically used for operations like `INSERT`, `UPDATE`, or `DELETE`.
    #
    # + sqlQuery - The SQL query as `sql:ParameterizedQuery` (e.g., `` `DELETE FROM Album WHERE artist=${artistName}` ``)
    # + return - The execution metadata as an `sql:ExecutionResult`, or an `sql:Error` if execution fails
    remote isolated function execute(sql:ParameterizedQuery sqlQuery)
    returns sql:ExecutionResult|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.java.jdbc.nativeimpl.ExecuteProcessor",
        name: "nativeExecute"
    } external;

    # Executes a SQL query with multiple sets of parameters in a single batch operation and returns execution metadata (not the actual query results).
    # This function is typically used for batch operations like `INSERT`, `UPDATE`, or `DELETE`.
    # If one of the commands in the batch fails, this will return an `sql:BatchExecuteError`. However, the driver may
    # or may not continue to process the remaining commands in the batch after a failure.
    #
    # + sqlQueries - The SQL query with multiple sets of parameters as an array of `sql:ParameterizedQuery`
    # + return - The execution metadata as an array of `sql:ExecutionResult` or an `sql:Error`.
    #          - If one of the commands in the batch fails, an `sql:BatchExecuteError` will be returned immediately.
    #           However, the driver may or may not continue to process the remaining commands in the batch after a failure.
    remote isolated function batchExecute(sql:ParameterizedQuery[] sqlQueries) returns sql:ExecutionResult[]|sql:Error {
        if sqlQueries.length() == 0 {
            return error sql:ApplicationError(" Parameter 'sqlQueries' cannot be empty array");
        }
        return nativeBatchExecute(self, sqlQueries);
    }

    # Calls a stored procedure with the given SQL query.
    #
    # + sqlQuery - The SQL query to call the procedure as `sql:ParameterizedQuery` (e.g., `` `CALL get_user(${id})` ``)
    # + rowTypes - An array of `typedesc` of the record type to which the result needs to be mapped
    # + return - The summary of the execution and results are returned in an `sql:ProcedureCallResult`, or an `sql:Error`.
    #           Once the results are processed, invoke the `close` method on the `sql:ProcedureCallResult`.
    remote isolated function call(sql:ParameterizedCallQuery sqlQuery, typedesc<record {}>[] rowTypes = [])
    returns sql:ProcedureCallResult|sql:Error = @java:Method {
        'class: "io.ballerina.stdlib.java.jdbc.nativeimpl.CallProcessor",
        name: "nativeCall"
    } external;

    # Closes the PostgreSQL client and shuts down the connection pool.
    # The client should be closed only at the end of the application lifetime, or when performing graceful stops in a service.
    #
    # + return - `sql:Error` if closing the client fails, else `()`
    public isolated function close() returns sql:Error? = @java:Method {
        'class: "io.ballerina.stdlib.java.jdbc.nativeimpl.ClientProcessor",
        name: "close"
    } external;
}

# Represent an additional set of configurations related to a database connection.
#
# + datasourceName - The driver class name to be used to get the connection
# + properties - The database properties, which should be applied when getting the connection
# + requestGeneratedKeys - The database operations for which auto-generated keys should be returned.
#                          Some databases have limitations to support this. This should be configured
#                          based on the database type.
public type Options record {|
    string datasourceName?;
    map<anydata> properties?;
    Operations requestGeneratedKeys = ALL;
|};

# Constants to represent database operations.
public enum Operations {
    NONE,
    EXECUTE,
    BATCH_EXECUTE,
    ALL
}

# Represents the configurations for the JDBC client to be passed internally within the module.
#
# + url - The JDBC URL for the database connection
# + user - Database username
# + password - Database password
# + options - The advanced connection options specific to the SQL database
# + connectionPool - The `sql:ConnectionPool` object to be used within the client. If not provided,
#                    the global connection pool (shared by all clients) will be used
type ClientConfiguration record {|
    string? url;
    string? user;
    string? password;
    Options? options;
    sql:ConnectionPool? connectionPool;
|};

isolated function createClient(Client jdbcClient, ClientConfiguration clientConf,
    sql:ConnectionPool globalConnPool) returns sql:Error? = @java:Method {
    'class: "io.ballerina.stdlib.java.jdbc.nativeimpl.ClientProcessor"
} external;

isolated function nativeBatchExecute(Client sqlClient, string[]|sql:ParameterizedQuery[] sqlQueries)
returns sql:ExecutionResult[]|sql:Error = @java:Method {
    'class: "io.ballerina.stdlib.java.jdbc.nativeimpl.ExecuteProcessor"
} external;

isolated function isRequestGeneratedKeysSupportsBatchExecute(Options? options) returns boolean {
    return !(options is Options && (options.requestGeneratedKeys == EXECUTE ||
        options.requestGeneratedKeys == NONE));
}
