// Copyright (c) 2021, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/file;
import ballerina/sql;
import ballerinax/java.jdbc;
import ballerina/http;

public function main() returns error? {
    jdbc:Client dbClient = check new ("jdbc:h2:" + check file:getAbsolutePath("target/databases") + "/BATCH_EXECUTE_DB");
    _ = check dbClient->query(``);
    _ = check dbClient->queryRow(``);
    _ = check dbClient->execute(``);
    check invokeQuery(dbClient);
    check dbClient.close();

    http:Client httpclient = check new ("adasdsasd");
    _ = check httpclient->get("/sdfsdf");
}

function invokeQuery(jdbc:Client dbClient) returns error? {
    _ = check dbClient->query(``);
}
