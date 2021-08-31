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

import ballerinax/java.jdbc;
import ballerina/sql;

configurable string jdbcUrlSF = ?;
configurable string dbUsernameSF = ?;
configurable string dbPasswordSF = ?;

public function main() returns error? {
    check createDatabase();
    check createTable();
    check createWarehouse();
    check insertData();
}

public function createDatabase() returns error? {
    jdbc:Options options = {
        requestGeneratedKeys: jdbc:NONE
    };
    jdbc:Client dbClient = check new (jdbcUrlSF, dbUsernameSF, dbPasswordSF, options = options);
    sql:ExecutionResult res = check dbClient->execute("CREATE OR REPLACE DATABASE CompanyDB");
    check dbClient.close();
}

public function createTable() returns error? {
    jdbc:Options options = {
        properties: {
            db: "CompanyDB",
            schema: "PUBLIC"
        },
        requestGeneratedKeys: jdbc:NONE
    };
    jdbc:Client dbClient = check new (jdbcUrlSF, dbUsernameSF, dbPasswordSF, options = options);
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
    check dbClient.close();
}

public function createWarehouse() returns error? {
    jdbc:Options options = {
        requestGeneratedKeys: jdbc:NONE
    };
    jdbc:Client dbClient = check new (jdbcUrlSF, dbUsernameSF, dbPasswordSF, options = options);
    _ = check dbClient->execute(`
        CREATE OR REPLACE WAREHOUSE TestWarehouse WITH
            warehouse_size = 'X-SMALL'
            auto_suspend = 180
            auto_resume = true
            initially_suspended = true;
    `);
    check dbClient.close();
}

public function insertData() returns error? {
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
        VALUES ('John', 'Smith', 'john@smith.com', 'No. 32, 1st Lane, SomeCity.', '2021-08-20', 50000);
    `);
    check dbClient.close();
}

public function batchInsertData() returns error? {
    jdbc:Options options = {
        properties: {
            db: "CompanyDB",
            schema: "PUBLIC",
            warehouse: "TestWarehouse"
        },
        requestGeneratedKeys: jdbc:NONE
    };
    var data = [
        {first_name:"Michael", last_name: "Scott", address: "address1", joined_date: "2021-01-01", salary: 60000},
        {first_name:"Michael", last_name: "Scott", address: "address1", joined_date: "2021-01-01", salary: 60000},
        {first_name:"Michael", last_name: "Scott", address: "address1", joined_date: "2021-01-01", salary: 60000}
    ];
    sql:ParameterizedQuery[] sqlQueries =
        from var row in data
        select `INSERT INTO Employees (first_name, last_name, address, joined_date, salary)
                VALUES (${row.first_name}, ${row.last_name}, ${row.address}, ${row.joined_date}, ${row.salary})`;
    jdbc:Client dbClient = check new (jdbcUrlSF, dbUsernameSF, dbPasswordSF, options = options);
    _ = check dbClient->batchExecute(sqlQueries);
    check dbClient.close();
}