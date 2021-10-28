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
import ballerina/test;
import ballerina/file;

string libPath = check file:getAbsolutePath("lib");
string dbPath = check file:getAbsolutePath("target/databases");
string scriptPath = check file:getAbsolutePath("tests/resources/sql");

string user = "test";
string password = "Test123";

isolated function initializeDatabase(string database, string category, string script) {
    io:println("Finished initialising H2 '" + database + "' databases.");
}

@test:AfterSuite {}
isolated function afterSuite() {
    io:println("Clean up databases.");
}
