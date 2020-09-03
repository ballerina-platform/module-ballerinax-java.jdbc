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

function initializeDatabase(string database, string category, string script) {

    system:Process process = checkpanic system:exec(
            "java", {}, libPath, "-cp", "h2-1.4.200.jar", "org.h2.tools.RunScript",
            "-url", "jdbc:h2:" + dbPath + "/" + database,
            "-user", user,
            "-password", password,
            "-script", checkpanic filepath:build(scriptPath, category, script));
    int exitCode = checkpanic process.waitForExit();
    test:assertExactEquals(exitCode, 0, "H2 " + database + " database creation failed!");

    io:println("Finished initialising H2 '" + database + "' databases.");
}

@test:AfterSuite {}
function afterSuite() {
    system:Process process = checkpanic system:exec("rm", {}, ".", "-r", dbPath);
    int exitCode = checkpanic process.waitForExit();
    test:assertExactEquals(exitCode, 0, "Clean up of H2 databases failed!");
    io:println("Clean up databases.");
}
