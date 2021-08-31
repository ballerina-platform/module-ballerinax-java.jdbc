#
# Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
#
# WSO2 Inc. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

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

listener http:Listener snowflakeListener = new(9090);

service on snowflakeListener {

    resource function get findByEmail(http:Caller caller, http:Request req, string email) returns sql:Error|error? {
        http:Response response = new;

        jdbc:Options options = {
           properties: {
               db: "CompanyDB",
               schema: "PUBLIC",
               warehouse: "TestWarehouse"
           },
           requestGeneratedKeys: jdbc:NONE
        };
        jdbc:Client dbClient = check new (jdbcUrlSF, dbUsernameSF, dbPasswordSF, options = options);

        Employee data = check dbClient->queryRow(`
            SELECT * FROM Employees WHERE email = ${email};
        `);

        response.setJsonPayload(<json> data);

        check dbClient.close();
        check caller->respond(response);
    }

    resource function post addEmployee(http:Caller caller, http:Request req) returns error? {
        json payload = check req.getJsonPayload();
        map<json> employeeJson = check payload.ensureType();

        Employee newEmployee = {
            first_name: check employeeJson.first_name,
            last_name: check employeeJson.last_name,
            email: check employeeJson.email,
            address: check employeeJson.address,
            joined_date: <string> check employeeJson.joined_date,
            salary: check employeeJson.salary
        };
        
        jdbc:Options options = {
            properties: {
                db: "CompanyDB",
                schema: "PUBLIC",
                warehouse: "TestWarehouse"
            },
            requestGeneratedKeys: jdbc:NONE
        };
        jdbc:Client dbClient = check new (jdbcUrlSF, dbUsernameSF, dbPasswordSF, options = options);
        _ = check dbClient->execute(`
            INSERT INTO Employees (first_name, last_name, email, address, joined_date, salary)
            VALUES (${newEmployee.first_name}, ${newEmployee.last_name}, ${newEmployee.email}, 
                    ${newEmployee.address}, ${newEmployee?.joined_date}, ${newEmployee.salary});
        `);
        check dbClient.close();

        http:Response response = new;
        response.statusCode = 200;
        
        check caller->respond(response);
    }
}
