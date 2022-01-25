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

import ballerina/cache;
import ballerina/sql;
import ballerinax/java.jdbc;

public isolated class Client {

    final jdbc:Client dbClient;
    final cache:Cache cache;

    public isolated function init(string url, string dbUsername, string dbPassword, cache:CacheConfig cacheConfig)
                            returns error? {
        self.dbClient = check new (url = url, user = dbUsername, password = dbPassword);
        self.cache = new (cacheConfig);
    }

    public isolated function addDetails(string customerName) returns error|int|string? {
        sql:ParameterizedQuery query = `INSERT INTO Customers (customerName) VALUES (${customerName})`;
        sql:ExecutionResult result = check self.dbClient->execute(query);
        int|string? id = result?.lastInsertId;
        if id is int {
            check self.put(id);
        }
        return id;
    }

    public isolated function getDetail(int id) returns string|error {
        any|error data = self.cache.get(id.toString());
        if data !is error {
            return data.toString();
        }
        stream<record {}, error?> resultStream = self.dbClient->query(
                                                                    `SELECT * FROM Customers WHERE customerId = ${id}`);
        any result = check resultStream.next();
        error? err = self.cache.put(id.toString(), result);
        check resultStream.close();
        return result.toString();
    }

    public isolated function updateDetail(int id, string customerName) returns error|int? {
        sql:ParameterizedQuery updateQuery =
            `UPDATE Customers SET customerName = ${customerName} WHERE customerId = ${id}`;
        sql:ExecutionResult result = check self.dbClient->execute(updateQuery);
        check self.put(id);
        return result.affectedRowCount;
    }

    public isolated function removeDetail(int id) returns error|string {
        sql:ParameterizedQuery query = `DELETE FROM Customers WHERE customerId = ${id}`;
        _ = check self.dbClient->execute(query);
        check self.cache.invalidate(id.toString());
        return "Customer details deleted successfully";
    }

    public isolated function deleteTable() returns error? {
        _ = check self.dbClient->execute(`DROP TABLE IF EXISTS Customers`);
    }

    public isolated function createTable() returns error? {
        _ = check self.dbClient->execute(`
            CREATE TABLE Customers (
                customerId SERIAL,
                customerName VARCHAR(300)
            );
        `);
    }

    isolated function put(int id) returns error? {
        stream<record {}, error?> resultStream = self.dbClient->query(`SELECT * FROM Customers WHERE customerId = ${id}`);
        any output = check resultStream.next();
        error? err = self.cache.put(id.toString(), output);
        check resultStream.close();
    }
}
