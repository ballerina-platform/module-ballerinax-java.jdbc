// Copyright (c) 2022 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/http;
import ballerina/sql;
import ballerinax/java.jdbc;

configurable string dbHost = ?;
configurable string dbUsername = ?;
configurable string dbPassword = ?;
configurable string dbName = ?;
configurable int dbPort = ?;

final jdbc:Client dbClient = check new (url = "jdbc:postgresql://" +  dbHost + "/" + dbName, user = dbUsername, password = dbPassword);

public function main() returns error? {
    check deleteTable();
    check createTable();
    foreach var i in 1 ... 100 {
        _ = check addDetails();
    }
}

isolated service /customer on new http:Listener(9092) {
    resource isolated function get .(int id) returns string|error {
        return getDetail(id);
    }
}

public isolated function deleteTable() returns error? {
    _ = check dbClient->execute(`DROP TABLE IF EXISTS Customers`);
}

public isolated function createTable() returns error? {
    _ = check dbClient->execute(`
        CREATE TABLE Customers (
            customerId SERIAL,
            firstName VARCHAR(300),
            lastName  VARCHAR(300),
            registrationID INT,
            creditLimit FLOAT,
            country  VARCHAR(300)
        );
    `);
}

public isolated function addDetails() returns error|int|string? {
    sql:ParameterizedQuery query = `INSERT INTO Customers(firstName, lastName, registrationID,
                                    creditLimit, country) VALUES ('Peter','Stuart', 1, 5000.75, 'USA')`;
    sql:ExecutionResult result = check dbClient->execute(query);
    return result?.lastInsertId;
}

public isolated function getDetail(int id) returns string|error {
    record{} value = check dbClient->queryRow(`SELECT * FROM Customers WHERE customerId = ${id}`);
    return value.toString();
}
