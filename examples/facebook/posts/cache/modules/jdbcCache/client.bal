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
import ballerina/sql;
import ballerinax/java.jdbc;
 

public type PostInfo record {
    string FromId;
    string FromName;
    string FromPicture;
    string Message;
    string MessageTags;
};

public isolated class Client {

    final jdbc:Client dbClient;
    final cache:Cache cache;

    public isolated function init(string url, jdbc:Options options, cache:CacheConfig cacheConfig) returns error? {
        self.dbClient = check new (url, options = options);
        self.cache = new (cacheConfig);
    }
 
    public isolated function addData(string msg) returns error|string {
        sql:ParameterizedQuery query = `INSERT INTO Posts (message) VALUES (${msg})`;
        sql:ExecutionResult result = check self.dbClient->execute(query);
        string id = result.lastInsertId.toString();
        _ = check self.getData(id);
        return id;
    }

    public isolated function getData(string id) returns string|error {
        any|error data = self.cache.get(id);
        if data !is error {
            return data.toString();
        }
        stream<PostInfo, error?> resultStream = self.dbClient->query(`SELECT * FROM Posts WHERE ID = ${id}`);
        any result = check resultStream.next();
        check self.cache.put(id, result);
        check resultStream.close();
        return result.toString();
    }

    public isolated function removeData(string id) returns error|string {
        sql:ParameterizedQuery query = `DELETE FROM Posts WHERE ID = ${id}`;
        _ = check self.dbClient->execute(query);
        check self.cache.invalidate(id);
        return "Post deleted successfully";
    }

    public function getIds() returns string[]|error {
        string[] postIds = self.cache.keys();
        if postIds.length() < 1 {
            stream<record {}, error?> resultStream = self.dbClient->query(`SELECT * FROM Posts`);
            check resultStream.forEach(function(record {} result) {
                postIds.push(<string>result["ID"]);
            });
        }
        return postIds;
    }
}
