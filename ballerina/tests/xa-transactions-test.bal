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

import ballerina/test;
import ballerina/sql;

string xaDatasourceName = "org.h2.jdbcx.JdbcDataSource";

string xaTransactionDB1 = "jdbc:h2:" + dbPath + "/" + "XA_TRANSACTION_1";
string xaTransactionDB2 = "jdbc:h2:" + dbPath + "/" + "XA_TRANSACTION_2";

@test:BeforeGroups {
    value: ["xa-transaction"]
}
isolated function initXATransactionDB() {
    initializeDatabase("XA_TRANSACTION_1", "transaction", "xa-transaction-test-data-1.sql");
    initializeDatabase("XA_TRANSACTION_2", "transaction", "xa-transaction-test-data-2.sql");
}

type XAResultCount record {
    int COUNTVAL;
};

@test:Config {
    groups: ["transaction", "xa-transaction"]
}
function testXATransactionSuccess() returns error? {
    Client dbClient1 = check new (url = xaTransactionDB1, user = user, password = password,
    connectionPool = {maxOpenConnections: 1});
    Client dbClient2 = check new (url = xaTransactionDB2, user = user, password = password,
    connectionPool = {maxOpenConnections: 1});

    transaction {
        _ = check dbClient1->execute(`
            insert into Customers (customerId, name, creditLimit, country) values (1, 'Anne', 1000, 'UK')
        `);
        _ = check dbClient2->execute(`insert into Salary (id, amount) values (1, 1000)`);
        check commit;
    }

    int count1 = check getCustomerCount(dbClient1, "1");
    int count2 = check getSalaryCount(dbClient2, "1");
    test:assertEquals(count1, 1, "First transaction failed");
    test:assertEquals(count2, 1, "Second transaction failed");

    check dbClient1.close();
    check dbClient2.close();
}

@test:Config {
    groups: ["transaction", "xa-transaction"]
}
function testXATransactionSuccessWithDataSource() returns error? {
    Client dbClient1 = check new (url = xaTransactionDB1, user = user, password = password,
    options = {datasourceName: xaDatasourceName});
    Client dbClient2 = check new (url = xaTransactionDB2, user = user, password = password,
    options = {datasourceName: xaDatasourceName});

    transaction {
        _ = check dbClient1->execute(`
            insert into Customers (customerId, name, creditLimit, country) values (10, 'Anne', 1000, 'UK')
        `);
        _ = check dbClient2->execute(`insert into Salary (id, amount ) values (10, 1000)`);
        check commit;
    }

    int count1 = check getCustomerCount(dbClient1, "10");
    int count2 = check getSalaryCount(dbClient2, "10");
    test:assertEquals(count1, 1, "First transaction failed");
    test:assertEquals(count2, 1, "Second transaction failed");

    check dbClient1.close();
    check dbClient2.close();
}

isolated function getCustomerCount(Client dbClient, string id) returns int|error {
    stream<XAResultCount, sql:Error?> streamData = dbClient->query(`
        Select COUNT(*) as countval from Customers where customerId = ${id}
    `);
    return getResult(streamData);
}

isolated function getSalaryCount(Client dbClient, string id) returns int|error {
    stream<XAResultCount, sql:Error?> streamData = dbClient->query(`
        Select COUNT(*) as countval from Salary where id = ${id}
    `);
    return getResult(streamData);
}

isolated function getResult(stream<XAResultCount, sql:Error?> streamData) returns int|error {
    record {|XAResultCount value;|}? data = check streamData.next();
    check streamData.close();
    XAResultCount? value = data?.value;
    if value is XAResultCount {
        return value.COUNTVAL;
    }
    return 0;
}
