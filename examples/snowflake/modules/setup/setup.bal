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