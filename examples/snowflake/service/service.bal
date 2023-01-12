// Copyright (c) 2021 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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
import ballerinax/java.jdbc;
import ballerina/time;
import ballerina/sql;

configurable string jdbcUrlSF = ?;
configurable string dbUsernameSF = ?;
configurable string dbPasswordSF = ?;

type Employee record {|
    string first_name;
    string last_name;
    string email;
    string address;
    time:Date|string joined_date?;
    int salary;
|};

type EmployeeCreated record {|
    *http:Created;
|};

type EmployeeNotFound record {|
    *http:BadRequest;
|};

jdbc:Options options = {
    properties: {
        db: "CompanyDB",
        schema: "PUBLIC",
        warehouse: "TestWarehouse"
    },
    requestGeneratedKeys: jdbc:NONE
};
final jdbc:Client dbClient = check new (jdbcUrlSF, dbUsernameSF, dbPasswordSF, options = options);

isolated service /employee on new http:Listener(9090) {

    isolated resource function get [string email]() returns Employee|EmployeeNotFound|error {
        Employee|sql:Error data = dbClient->queryRow(`
            SELECT * FROM Employees WHERE email = ${email};
        `);
        if data is sql:NoRowsError {
            return {body: {status: "Employee " + email + " does not exist."}};
        }
        return data;
    }

    isolated resource function post .(@http:Payload Employee employee) returns EmployeeCreated|error {
        _ = check dbClient->execute(`
            INSERT INTO Employees (first_name, last_name, email, address, joined_date, salary)
            VALUES (${employee.first_name}, ${employee.last_name}, ${employee.email}, 
                    ${employee.address}, ${employee?.joined_date}, ${employee.salary});
        `);
        return {
            body: {status: "New employee " + employee.email + " created."}
        };
    }
}
