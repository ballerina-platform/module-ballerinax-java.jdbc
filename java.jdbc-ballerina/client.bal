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

# Represents a JDBC client.
#
public isolated client class Client {
    *sql:Client;
    private boolean clientActive = true;

    # Initializes JDBC client.
    #
    # + url - The JDBC URL of the database
    # + user - If the database is secured, the username of the database
    # + password - The password of the provided username of the database
    # + options - The database-specific JDBC client properties
    # + connectionPool - The `sql:ConnectionPool` object to be used within the JDBC client.
    #                   If there is no `connectionPool` provided, the global connection pool will be used and it will
    #                   be shared by other clients, which have the same properties
    public isolated function init(string url, string? user = (), string? password = (),
        Options? options = (), sql:ConnectionPool? connectionPool = ()) returns sql:Error? {
        ClientConfiguration clientConf = {
            url: url,
            user: user,
            password: password,
            options: options,
            connectionPool: connectionPool
        };
        return createClient(self, clientConf, sql:getGlobalConnectionPool());
    }

    # Queries the database with the provided query and returns the result as a stream.
    #
    # + sqlQuery - The query, which needs to be executed as a `string` or an `sql:ParameterizedQuery` when the SQL
    #              query has params to be passed in
    # + rowType - The `typedesc` of the record that should be returned as a result. If this is not provided, the default
    #             column names of the query result set will be used for the record attributes
    # + return - Stream of records in the type of `rowType`
    remote isolated function query(@untainted string|sql:ParameterizedQuery sqlQuery, typedesc<record {}>? rowType = ())
    returns @tainted stream <record {}, sql:Error> {
        boolean active;
        lock {
            active = self.clientActive;
        }
        if (active) {
            return nativeQuery(self, sqlQuery, rowType);
        } else {
            return sql:generateApplicationErrorStream("JDBC Client is already closed, hence "
                + "further operations are not allowed");
        }
    }

    # Executes the provided DDL or DML SQL queries and returns a summary of the execution.
    #
    # + sqlQuery - The DDL or DML queries such as `INSERT`, `DELETE`, `UPDATE`, etc. as a `string` or an `sql:ParameterizedQuery`
    #              when the query has params to be passed in
    # + return - Summary of the SQL `UPDATE` query as an `sql:ExecutionResult` or an `sql:Error`
    #            if any error occurred when executing the query
    remote isolated function execute(@untainted string|sql:ParameterizedQuery sqlQuery) returns sql:ExecutionResult|sql:Error {
        boolean active;
        lock {
            active = self.clientActive;
        }
        if (active) {
            return nativeExecute(self, sqlQuery);
        } else {
            return error sql:ApplicationError("JDBC Client is already closed, hence further operations are not allowed");
        }
    }

    # Executes a provided batch of parameterized DDL or DML SQL queries
    # and returns the summary of the execution.
    #
    # + sqlQueries - The DDL or DML queries such as `INSERT`, `DELETE`, `UPDATE`, etc. as an `sql:ParameterizedQuery` with an array
    #                of values passed in
    # + return - Summary of the executed SQL queries as an `sql:ExecutionResult[]`, which includes details such as
    #            `affectedRowCount` and `lastInsertId`. If one of the commands in the batch fails, this function
    #            will return an `sql:BatchExecuteError`. However, the JDBC driver may or may not continue to process the
    #            remaining commands in the batch after a failure. The summary of the executed queries in case of an error
    #            can be accessed as `(<sql:BatchExecuteError> result).detail()?.executionResults`
    remote isolated function batchExecute(@untainted sql:ParameterizedQuery[] sqlQueries) returns sql:ExecutionResult[]|sql:Error {
        if (sqlQueries.length() == 0) {
            return error sql:ApplicationError(" Parameter 'sqlQueries' cannot be empty array");
        }
        boolean active;
        lock {
            active = self.clientActive;
        }
        if (active) {
            return nativeBatchExecute(self, sqlQueries);
        } else {
            return error sql:ApplicationError("JDBC Client is already closed, hence further operations are not allowed");
        }
    }

    # Executes a SQL stored procedure and returns the result as stream and execution summary.
    #
    # + sqlQuery - The query to execute the SQL stored procedure
    # + rowTypes - The array of `typedesc` of the records that should be returned as a result. If this is not provided,
    #               the default column names of the query result set will be used for the record attributes
    # + return - Summary of the execution is returned in an `sql:ProcedureCallResult` or an `sql:Error`
    remote isolated function call(@untainted string|sql:ParameterizedCallQuery sqlQuery, typedesc<record {}>[] rowTypes = [])
    returns sql:ProcedureCallResult|sql:Error {
        boolean active;
        lock {
            active = self.clientActive;
        }
        if (active) {
            return nativeCall(self, sqlQuery, rowTypes);
        } else {
            return error sql:ApplicationError("JDBC Client is already closed, hence further operations are not allowed");
        }
    }

    # Closes the JDBC client.
    #
    # + return - Possible error during closing the client
    public isolated function close() returns sql:Error? {
        lock {
            self.clientActive = false;
        }
        return close(self);
    }
}

# Provides a set of configuration related to database.
# 
# + datasourceName - The driver class name to be used to get the connection
# + properties - the properties of the database which should be applied when getting the connection
public type Options record {|
    string? datasourceName = ();
    map<anydata>? properties = ();
|};

# Provides a set of configurations for the JDBC Client to be passed internally within the module.
#
# + url - URL of the database to connect
# + user - Username for the database connection
# + password - Password for the database connection
# + options - A map of DB-specific `jdbc:Options`
# + connectionPool - Properties for the connection pool configuration. Refer the `sql:ConnectionPool` for more details
type ClientConfiguration record {|
    string? url;
    string? user;
    string? password;
    Options? options;
    sql:ConnectionPool? connectionPool;
|};

isolated function createClient(Client jdbcClient, ClientConfiguration clientConf,
    sql:ConnectionPool globalConnPool) returns sql:Error? = @java:Method {
    'class: "org.ballerinalang.jdbc.nativeimpl.ClientProcessor"
} external;

isolated function nativeQuery(Client sqlClient, string|sql:ParameterizedQuery sqlQuery, typedesc<record {}>? rowType)
returns stream <record {}, sql:Error> = @java:Method {
    'class: "org.ballerinalang.jdbc.nativeimpl.QueryProcessor"
} external;

isolated function nativeExecute(Client sqlClient, string|sql:ParameterizedQuery sqlQuery)
returns sql:ExecutionResult|sql:Error = @java:Method {
    'class: "org.ballerinalang.jdbc.nativeimpl.ExecuteProcessor"
} external;

isolated function nativeBatchExecute(Client sqlClient, sql:ParameterizedQuery[] sqlQueries)
returns sql:ExecutionResult[]|sql:Error = @java:Method {
    'class: "org.ballerinalang.jdbc.nativeimpl.ExecuteProcessor"
} external;

isolated function nativeCall(Client sqlClient, string|sql:ParameterizedCallQuery sqlQuery, typedesc<record {}>[] rowTypes)
returns sql:ProcedureCallResult|sql:Error = @java:Method {
    'class: "org.ballerinalang.jdbc.nativeimpl.CallProcessor"
} external;

isolated function close(Client jdbcClient) returns sql:Error? = @java:Method {
    'class: "org.ballerinalang.jdbc.nativeimpl.ClientProcessor"
} external;