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

import ballerina/io;
import ballerinax/java.jdbc;

configurable string jdbcFBUrl = ?;
configurable string InitiateOAuth = ?;
configurable string fbUserName = ?;
configurable string fbPassword = ?;

jdbc:Options options = {
    properties: { InitiateOAuth: InitiateOAuth }
};

public type User record {
    string ID;
    string Picture;
    string Name;
    string FirstName;
    string MiddleName;
    string Email;
    string LastName;
};

jdbc:Client dbClient = check new (jdbcFBUrl, fbUserName, fbPassword, options = options);

public function main () returns error? {
    stream<User, error?> resultStream = dbClient->query(`SELECT * FROM Users`);
    io:println("User Info: ", check resultStream.next());
    _ = check resultStream.close();
}
