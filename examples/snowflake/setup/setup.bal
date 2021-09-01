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

import ballerinax/java.jdbc;
import ballerina/sql;

configurable string jdbcUrlSF = ?;
configurable string dbUsernameSF = ?;
configurable string dbPasswordSF = ?;

jdbc:Options options = {
    requestGeneratedKeys: jdbc:NONE
};
jdbc:Client dbClient = check new (jdbcUrlSF, dbUsernameSF, dbPasswordSF, options = options);

public function main() returns error? {

    // Create database
    sql:ExecutionResult res = check dbClient->execute("CREATE OR REPLACE DATABASE CompanyDB");

    // Create warehouse
    _ = check dbClient->execute(`
        CREATE OR REPLACE WAREHOUSE TestWarehouse WITH
            warehouse_size = 'X-SMALL'
            auto_suspend = 180
            auto_resume = true
            initially_suspended = true;
    `);

    // Create table
    _ = check dbClient->execute("USE CompanyDB.PUBLIC");
    _ = check dbClient->execute(`
        CREATE OR REPLACE TABLE Employees (
            first_name STRING,
            last_name STRING,
            email STRING,
            address STRING,
            joined_date DATE,
            salary NUMBER
        );
    `);

    // Insert one row
    _ = check dbClient->execute(`
        INSERT INTO Employees (first_name, last_name, email, address, joined_date, salary)
        VALUES ('John', 'Smith', 'john@smith.com', 'No. 32, 1st Lane, SomeCity.', '2021-08-20', 50000);
    `);

    // Batch insert data
    var data = [
        {first_name:"Michael", last_name: "Scott", email: "michael1@scott.com", address: "address1", joined_date: "2021-05-01", salary: 60000},
        {first_name:"Michael", last_name: "Scott", email: "michael2@scott.com", address: "address2", joined_date: "2021-07-01", salary: 50000},
        {first_name:"Michael", last_name: "Scott", email: "michael3@scott.com", address: "address3", joined_date: "2021-09-01", salary: 40000}
    ];
    sql:ParameterizedQuery[] sqlQueries =
        from var row in data
        select `INSERT INTO Employees (first_name, last_name, email, address, joined_date, salary)
                VALUES (${row.first_name}, ${row.last_name}, ${row.email}, ${row.address}, ${row.joined_date}, ${row.salary})`;
    _ = check dbClient->batchExecute(sqlQueries);
    check dbClient.close();
}
