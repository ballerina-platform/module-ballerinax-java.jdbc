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

import ballerina/http;
import ballerinax/java.jdbc;
import ballerina/cache;
import cache.jdbcCache;

configurable string jdbcFBUrl = ?;
configurable string pageId = ?;
configurable string InitiateOAuth = ?;
configurable string appId = ?;
configurable string appSecret = ?;
configurable string pageAccessToken = ?;
configurable int capacity = ?;
configurable float evictionFactor = ?;
configurable decimal defaultMaxAge = ?;
configurable decimal cleanupInterval = ?;

jdbc:Options options = {
    properties: {
        InitiateOAuth: InitiateOAuth,
        AuthenticateAsPage: pageId,
        OAuthClientId: appId,
        OAuthClientSecret: appSecret,
        OAuthAccessToken: pageAccessToken
    }
};

cache:CacheConfig cacheConfig = {
    capacity: capacity,
    evictionFactor: evictionFactor,
    defaultMaxAge: defaultMaxAge,
    cleanupInterval: cleanupInterval
};

public type PostInfo record {
    string FromId;
    string FromName;
    string FromPicture;
    string Message;
    string MessageTags;
};

final jdbcCache:Client cacheClient = check new (jdbcFBUrl, options, cacheConfig);

listener http:Listener fbListener = new (9092);

service /facebook on fbListener {

    resource function get posts() returns string[]|error {
        return cacheClient.getIds();
    }

    isolated resource function get posts/[string id]() returns string|error {
        return cacheClient.getData(id);
    }

    isolated resource function post posts(@http:Payload string msg) returns string|error {
        return cacheClient.addData(msg);
    }

    isolated resource function delete posts/[string id]() returns string|error {
        return cacheClient.removeData(id);
    }
}
