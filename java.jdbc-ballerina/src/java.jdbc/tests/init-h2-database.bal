// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/io;
import ballerina/system;
import ballerina/test;
import ballerina/filepath;

string libPath = checkpanic filepath:absolute("lib");
string dbPath = checkpanic filepath:absolute("target/databases");
string scriptPath = checkpanic filepath:absolute("src/java.jdbc/tests/resources/sql");

string user = "test";
string password = "Test123";

@test:BeforeSuite
function beforeSuite() returns @tainted error? {

    var testCaseDatabases = {
        connection: {
            CONNECT_DB: "connector-init-test-data.sql"
        },
        pool: {
            POOL_DB_1: "connection-pool-test-data.sql",
            POOL_DB_2: "connection-pool-test-data.sql"
        },
        execute: {
            EXECUTE_DB: "execute-test-data.sql",
            EXECUTE_PARAMS_DB: "execute-params-test-data.sql"
        },
        batchexecute: {
            BATCH_EXECUTE_DB: "batch-execute-test-data.sql"
        },
        query: {
            QUERY_PARAMS_DB: "simple-params-test-data.sql",
            NUMERIC_QUERY_DB: "numerical-test-data.sql",
            COMPLEX_QUERY_DB: "complex-test-data.sql"
        },
        'transaction: {
            LOCAL_TRANSACTION: "local-transaction-test-data.sql",
            XA_TRANSACTION_1: "xa-transaction-test-data-1.sql",
            XA_TRANSACTION_2: "xa-transaction-test-data-2.sql"
        }
    };

    system:Process process;
    int exitCode = 1;

    foreach var [category, testCases] in testCaseDatabases.entries() {
        foreach var [database, script] in testCases.entries() {
            process = checkpanic system:exec(
            "java", {}, libPath, "-cp", "h2-1.4.200.jar", "org.h2.tools.RunScript",
            "-url", "jdbc:h2:" + dbPath + "/" + database,
            "-user", user,
            "-password", password,
            "-script", checkpanic filepath:build(scriptPath, category, script));
            exitCode = checkpanic process.waitForExit();
            test:assertExactEquals(exitCode, 0, database + " test H2 database creation failed!");
        }
    }

    io:println("Finished initialising H2 databases.");
}

@test:AfterSuite {}
function afterSuite() {
    system:Process process = checkpanic system:exec("rm", {}, ".", "-r", dbPath);
    int exitCode = checkpanic process.waitForExit();
    test:assertExactEquals(exitCode, 0, "Clean up of H2 databases failed!");
    io:println("Clean up databases.");
}
