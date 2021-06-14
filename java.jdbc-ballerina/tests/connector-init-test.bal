// Copyright (c) 2020, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/sql;
import ballerina/test;

string jdbcUrl = "jdbc:h2:" + dbPath + "/" + "CONNECT_DB";

@test:BeforeGroups {
    value: ["connection"]
}
isolated function initConnectionDB() {
    initializeDatabase("CONNECT_DB", "connection", "connector-init-test-data.sql");
}

@test:Config {
    groups: ["connection"]
}
function testConnection1() {
    Client testDB = checkpanic new (url = jdbcUrl, user = user, password = password);
    test:assertEquals(testDB.close(), (), "JDBC connection failure.");
}

@test:Config {
    groups: ["connection"]
}
function testConnection2() {
    Client testDB = checkpanic new (jdbcUrl, user, password);
    test:assertEquals(testDB.close(), (), "JDBC connection failure.");
}


@test:Config {
    groups: ["connection"]
}
isolated function testConnectionInvalidUrl() {
    string invalidUrl = "jdbc:h3:";
    Client|sql:Error dbClient = new (invalidUrl);
    if (!(dbClient is sql:Error)) {
        checkpanic dbClient.close();
        test:assertFail("Invalid does not throw DatabaseError");
    }
}

@test:Config {
    groups: ["connection"]
}
function testConnectionNoUserPassword() {
    Client|sql:Error dbClient = new (jdbcUrl);
    if (!(dbClient is sql:Error)) {
        checkpanic dbClient.close();
        test:assertFail("No username does not throw DatabaseError");
    }
}

@test:Config {
    groups: ["connection"]
}
function testConnectionWithValidDriver() {
    Client|sql:Error dbClient = new (jdbcUrl, user, password, {datasourceName: "org.h2.jdbcx.JdbcDataSource"});
    if (dbClient is sql:Error) {
        test:assertFail("Valid driver throws DatabaseError");
    } else {
        checkpanic dbClient.close();
    }
}

@test:Config {
    groups: ["connection"]
}
function testConnectionWithInvalidDriver() {
    Client|sql:Error dbClient = new (jdbcUrl, user, password,
        {datasourceName: "org.h2.jdbcx.JdbcDataSourceInvalid"});
    if (!(dbClient is sql:Error)) {
        checkpanic dbClient.close();
        test:assertFail("Invalid driver does not throw DatabaseError");
    }
}

@test:Config {
    groups: ["connection"]
}
function testConnectionWithDatasourceOptions() {
    Options options = {
        datasourceName: "org.h2.jdbcx.JdbcDataSource",
        properties: {"loginTimeout": 5000}
    };
    Client|sql:Error dbClient = new (jdbcUrl, user, password, options);
    if (dbClient is sql:Error) {
        test:assertFail("Datasource options throws DatabaseError");
    } else {
        checkpanic dbClient.close();
    }
}

@test:Config {
    groups: ["connection"]
}
function testConnectionWithDatasourceInvalidProperty() {
    Options options = {
        datasourceName: "org.h2.jdbcx.JdbcDataSource",
        properties: {"invalidProperty": 109}
    };
    Client|sql:Error dbClient = new (jdbcUrl, user, password, options);
    if (dbClient is sql:Error) {
        test:assertEquals(dbClient.message(),
        "Error in SQL connector configuration: Property invalidProperty does not exist on target class org.h2.jdbcx.JdbcDataSource");
    } else {
        checkpanic dbClient.close();
        test:assertFail("Invalid driver does not throw DatabaseError");
    }
}

@test:Config {
    groups: ["connection"]
}
function testWithConnectionPool() {
    sql:ConnectionPool connectionPool = {
        maxOpenConnections: 25
    };
    Client dbClient = checkpanic new (url = jdbcUrl, user = user,
        password = password, connectionPool = connectionPool);
    error? err = dbClient.close();
    if (err is error) {
        test:assertFail("DB connection not created properly.");
    } else {
        test:assertEquals(connectionPool.maxConnectionLifeTime, <decimal> 2000.5);
        test:assertEquals(connectionPool.minIdleConnections, 5);
    }
}

@test:Config {
    groups: ["connection"]
}
function testWithSharedConnPool() {
    sql:ConnectionPool connectionPool = {
        maxOpenConnections: 25
    };
    Client dbClient1 = checkpanic new (url = jdbcUrl, user = user,
        password = password, connectionPool = connectionPool);
    Client dbClient2 = checkpanic new (url = jdbcUrl, user = user,
        password = password, connectionPool = connectionPool);
    Client dbClient3 = checkpanic new (url = jdbcUrl, user = user,
        password = password, connectionPool = connectionPool);

    test:assertEquals(dbClient1.close(), (), "JDBC connection failure.");
    test:assertEquals(dbClient2.close(), (), "JDBC connection failure.");
    test:assertEquals(dbClient3.close(), (), "JDBC connection failure.");
}

@test:Config {
    groups: ["connection"]
}
function testWithAllParams() {
    Options options = {
        datasourceName: "org.h2.jdbcx.JdbcDataSource",
        properties: {"loginTimeout": 5000}
    };
    sql:ConnectionPool connectionPool = {
        maxOpenConnections: 25
    };
    Client dbClient = checkpanic new (jdbcUrl, user, password, options, connectionPool);
    test:assertEquals(dbClient.close(), (), "JDBC connection failure.");
}
