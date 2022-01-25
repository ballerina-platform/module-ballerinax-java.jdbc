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
        _ = check addDetails("Stuart");
    }
}

isolated service /customer on new http:Listener(9092) {
    resource isolated function post .(int id, string customerName) returns string|error {
        _ = check updateDetail(id, customerName);
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
            customerName VARCHAR(300)
        );
    `);
}

public isolated function addDetails(string customerName) returns error|int|string? {
    sql:ParameterizedQuery query = `INSERT INTO Customers (customerName) VALUES (${customerName})`;
    sql:ExecutionResult result = check dbClient->execute(query);
    return result?.lastInsertId;
}

public isolated function getDetail(int id) returns string|error {
    stream<record {}, error?> resultStream = dbClient->query(`SELECT * FROM Customers WHERE customerId = ${id}`);
    any result = check resultStream.next();
    check resultStream.close();
    return result.toString();
}

public isolated function updateDetail(int id, string customerName) returns error|int? {
    sql:ParameterizedQuery updateQuery =
        `UPDATE Customers SET customerName = ${customerName} WHERE customerId = ${id}`;
    sql:ExecutionResult result = check dbClient->execute(updateQuery);
    return result.affectedRowCount;
}
