// Copyright (c) 2022 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
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

import ballerina/cache;
import ballerina/http;

configurable string dbHost = ?;
configurable string dbUsername = ?;
configurable string dbPassword = ?;
configurable string dbName = ?;
configurable int dbPort = ?;
configurable int capacity = ?;
configurable float evictionFactor = ?;

type Customer record {
    int customerId;
    string customerName;
};

cache:CacheConfig cacheConfig = {
    capacity: capacity,
    evictionFactor: evictionFactor
};

final Client cacheClient = check new ("jdbc:postgresql://" +  dbHost + "/" + dbName, dbUsername,
                                      dbPassword, cacheConfig);

public function main() returns error? {
    check cacheClient.deleteTable();
    check cacheClient.createTable();
    foreach var i in 1 ... 100 {
        _ = check cacheClient.addDetails();
    }
}

isolated service /customer on new http:Listener(9092) {
    resource isolated function get .(int id) returns string|error {
        return cacheClient.getDetail(id);
    }
}
