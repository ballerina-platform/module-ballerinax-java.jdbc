// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/lang.'string as strings;
import ballerina/test;
import ballerina/sql;

string jdbcErrorTestUrl = "jdbc:h2:" + dbPath + "/" + "ERROR_DB";

@test:BeforeGroups {
    value: ["error"]
}
isolated function initErrorDB() {
    initializeDatabase("ERROR_DB", "error", "error-test-data.sql");
}

@test:Config {
    groups: ["error"]
}
function TestAuthenticationError() {
    Client|error dbClient = new (jdbcErrorTestUrl, "asd", "asd");
    test:assertTrue(dbClient is sql:ApplicationError);
    error sqlerror = <error>dbClient;
    test:assertTrue(strings:includes(sqlerror.message(), "Error in SQL connector configuration: Failed to " +
                "initialize pool: Wrong user name or password [28000-212] Caused by :Wrong user name or password " +
                "[28000-212]"), sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestLinkFailure() {
    Client|error dbClient = new ("jdbc:h2:dbPa/" + "ERROR_DB", user, password);
    test:assertTrue(dbClient is sql:ApplicationError);
    sql:ApplicationError sqlerror = <sql:ApplicationError>dbClient;
    test:assertTrue(strings:includes(sqlerror.message(), "A file path that is implicitly relative to the current working directory is not " +
            "allowed in the database URL \"jdbc:h2:dbPa/ERROR_DB\""), sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestInvalidDB() {
    Client|error dbClient = new ("jdbc:h2:" + dbPath + "/", user, password);
    test:assertTrue(dbClient is sql:ApplicationError);
    error sqlerror = <error>dbClient;
    test:assertTrue(strings:includes(sqlerror.message(), "Invalid database name"), sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestConnectionClose() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from DataTable WHERE row_id = 1`;
    Client dbClient = check new (jdbcErrorTestUrl, user, password);
    check dbClient.close();
    string|error stringVal = dbClient->queryRow(sqlQuery);
    test:assertTrue(stringVal is sql:ApplicationError);
    sql:ApplicationError sqlerror = <sql:ApplicationError>stringVal;
    test:assertEquals(sqlerror.message(), "SQL Client is already closed, hence further operations are not allowed",
                sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestInvalidTableName() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from Data WHERE row_id = 1`;
    Client dbClient = check new (jdbcErrorTestUrl, user, password);
    string|error stringVal = dbClient->queryRow(sqlQuery);
    check dbClient.close();
    test:assertTrue(stringVal is sql:DatabaseError);
    error sqlerror = <error>stringVal;
    test:assertTrue(strings:includes(sqlerror.message(), "Error while executing SQL query: SELECT string_type from " +
                "Data WHERE row_id = 1. Table \"DATA\" not found; SQL statement:"), sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestInvalidFieldName() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from DataTable WHERE id = 1`;
    Client dbClient = check new (jdbcErrorTestUrl, user, password);
    string|error stringVal = dbClient->queryRow(sqlQuery);
    check dbClient.close();
    test:assertTrue(stringVal is sql:DatabaseError);
    sql:DatabaseError sqlerror = <sql:DatabaseError>stringVal;
    test:assertTrue(strings:includes(sqlerror.message(), "Error while executing SQL query: SELECT string_type from DataTable" +
                " WHERE id = 1. Column \"ID\" not found;"), sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestInvalidColumnType() returns error? {
    Client dbClient = check new (jdbcErrorTestUrl, user, password);
    sql:ExecutionResult|error result = dbClient->execute(
                                                    `CREATE TABLE TestCreateTable(studentID Point,LastName string)`);
    check dbClient.close();
    sql:DatabaseError sqlerror = <sql:DatabaseError>result;
    test:assertTrue(strings:includes(sqlerror.message(), "Error while executing SQL query: CREATE TABLE TestCreateTable(studentID Point,LastName string). " +
            "Unknown data type: \"POINT\""), sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestNullValue() returns error? {
    Client dbClient = check new (jdbcErrorTestUrl, user, password);
    _ = check dbClient->execute(`CREATE TABLE TestCreateTable(studentID int not null, LastName VARCHAR(50))`);
    sql:ParameterizedQuery insertQuery = `Insert into TestCreateTable (studentID, LastName) values (null,'asha')`;
    sql:ExecutionResult|error insertResult = dbClient->execute(insertQuery);
    check dbClient.close();
    test:assertTrue(insertResult is sql:DatabaseError);
    sql:DatabaseError sqlerror = <sql:DatabaseError>insertResult;
    test:assertTrue(strings:includes(sqlerror.message(), "Error while executing SQL query: Insert into TestCreateTable " +
                "(studentID, LastName) values (null,'asha'). NULL not allowed for column \"STUDENTID\"; SQL statement:"),
            sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestNoDataRead() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from DataTable WHERE row_id = 5`;
    Client dbClient = check new (jdbcErrorTestUrl, user, password);
    record {}|error queryResult = dbClient->queryRow(sqlQuery);
    test:assertTrue(queryResult is sql:NoRowsError);
    sql:NoRowsError sqlerror = <sql:NoRowsError>queryResult;
    test:assertEquals(sqlerror.message(), "Query did not retrieve any rows.", sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestUnsupportedTypeValue() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from DataTable WHERE row_id = 1`;
    Client dbClient = check new (jdbcErrorTestUrl, user, password);
    json|error stringVal = dbClient->queryRow(sqlQuery);
    check dbClient.close();
    test:assertTrue(stringVal is sql:ConversionError);
    sql:ConversionError sqlerror = <sql:ConversionError>stringVal;
    test:assertEquals(sqlerror.message(), "Retrieved column 1 result '{\"\"q}' could not be converted to 'JSON', " +
            "expected ':' at line: 1 column: 4.", sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestConversionError() returns error? {
    sql:DateValue value = new ("hi");
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from DataTable WHERE row_id = ${value}`;
    Client dbClient = check new (jdbcErrorTestUrl, user, password);
    string|error stringVal = dbClient->queryRow(sqlQuery);
    check dbClient.close();
    test:assertTrue(stringVal is sql:ConversionError);
    sql:ConversionError sqlError = <sql:ConversionError>stringVal;
    test:assertEquals(sqlError.message(), "Unsupported value: hi for Date Value", sqlError.message());
}

@test:Config {
    groups: ["error"]
}
function TestConversionError1() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from DataTable WHERE row_id = 1`;
    Client dbClient = check new (jdbcErrorTestUrl, user, password);
    json|error queryResult = dbClient->queryRow(sqlQuery);
    test:assertTrue(queryResult is sql:ConversionError);
    sql:ConversionError sqlError = <sql:ConversionError>queryResult;
    test:assertTrue(strings:includes(sqlError.message(), "Retrieved column 1 result '{\"\"q}' could not be converted"),
                sqlError.message());
}

type data record {|
    int row_id;
    int string_type;
|};

@test:Config {
    groups: ["error"]
}
function TestTypeMismatchError() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from DataTable WHERE row_id = 1`;
    Client dbClient = check new (jdbcErrorTestUrl, user, password);
    data|error queryResult = dbClient->queryRow(sqlQuery);
    test:assertTrue(queryResult is sql:TypeMismatchError);
    sql:TypeMismatchError sqlError = <sql:TypeMismatchError>queryResult;
    test:assertEquals(sqlError.message(), "The field 'string_type' of type int cannot be mapped to the column " +
                    "'STRING_TYPE' of SQL type 'CHARACTER VARYING'", sqlError.message());
}

type stringValue record {|
    int row_id1;
    string string_type1;
|};

@test:Config {
    groups: ["error"]
}
function TestFieldMismatchError() returns error? {
    sql:ParameterizedQuery sqlQuery = `SELECT string_type from DataTable WHERE row_id = 1`;
    Client dbClient = check new (jdbcErrorTestUrl, user, password);
    stringValue|error queryResult = dbClient->queryRow(sqlQuery);
    test:assertTrue(queryResult is sql:FieldMismatchError);
    sql:FieldMismatchError sqlError = <sql:FieldMismatchError>queryResult;
    test:assertTrue(strings:includes(sqlError.message(), "No mapping field found for SQL table column " +
                "'STRING_TYPE' in the record type 'stringValue'"), sqlError.message());
}

@test:Config {
    groups: ["error"]
}
function TestIntegrityConstraintViolation() returns error? {
    Client dbClient = check new (jdbcErrorTestUrl, user, password);
    _ = check dbClient->execute(`CREATE TABLE employees( employee_id int not null,
                                                         employee_name varchar (75) not null,supervisor_name varchar(75),
                                                         CONSTRAINT employee_pk PRIMARY KEY (employee_id))`);
    _ = check dbClient->execute(`CREATE TABLE departments( department_id int not null,employee_id int not
                                        null,CONSTRAINT fk_employee FOREIGN KEY (employee_id)
                                        REFERENCES employees (employee_id))`);
    sql:ExecutionResult|error result = dbClient->execute(
                                    `INSERT INTO departments(department_id, employee_id) VALUES (250, 600)`);
    check dbClient.close();
    sql:DatabaseError sqlerror = <sql:DatabaseError>result;
    test:assertTrue(strings:includes(sqlerror.message(), "Referential integrity constraint violation: \"FK_EMPLOYEE: " +
            "PUBLIC.DEPARTMENTS FOREIGN KEY(EMPLOYEE_ID) REFERENCES PUBLIC.EMPLOYEES(EMPLOYEE_ID) (600)\""),
            sqlerror.message());
}

@test:Config {
    groups: ["error"]
}
function TestDuplicateKey() returns error? {
    Client dbClient = check new (jdbcErrorTestUrl, user, password);
    _ = check dbClient->execute(`CREATE TABLE Details(id INT AUTO_INCREMENT, age INT, PRIMARY KEY (id))`);
    sql:ParameterizedQuery insertQuery = `Insert into Details (id, age) values (1,10)`;
    sql:ExecutionResult|error insertResult = dbClient->execute(insertQuery);
    insertResult = dbClient->execute(insertQuery);
    check dbClient.close();
    test:assertTrue(insertResult is sql:DatabaseError);
    sql:DatabaseError sqlerror = <sql:DatabaseError>insertResult;
    test:assertTrue(strings:includes(sqlerror.message(), "Error while executing SQL query: Insert into Details " +
                "(id, age) values (1,10). Unique index or primary key violation: \"PRIMARY KEY ON PUBLIC.DETAILS(ID) " +
                "( /* key:1 */ 1, 10)\""), sqlerror.message());
}
