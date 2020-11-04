// Copyright (c) 2020, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied. See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/io;
import ballerina/sql;
import ballerina/test;

string taintQueryDb = "jdbc:h2:" + dbPath + "/" + "QUERY_TAINT_DB";

@test:BeforeGroups {
    value: ["query-taint-analysis"]
}
function initTaintQueryDB() {
    initializeDatabase("QUERY_TAINT_DB", "query", "query-taint-analysis-data.sql");
}

type Person record {|
    int id;
    string name;
    int age;
|};

@test:Config {
    groups: ["query","query-taint-analysis"]
}
public function main() returns @tainted error? {
    boolean testPassed = true;
    string[] nicknameList = [<@tainted>"Matty", <@tainted>"Tom"];
    Person p1 = {id: 17, name: "Matty", age: 23};
    Person p2 = {id: 29, name: "Tom", age: 46};

    Person[] personList = [p1, p2];

    Client dbClient = check new (url = taintQueryDb, user = user, password = password);
    sql:ParameterizedQuery[] sqlQuery1 = from var person in personList
                                         from var nickname in nicknameList
                                         where person.name == nickname
                                         select `INSERT INTO Person VALUES (${person.id}, ${nickname},
                                         ${person.age})`;
    sql:ExecutionResult[]? result1 = check dbClient->batchExecute(<@untainted>sqlQuery1);

    stream<record{}, error> streamData1 = dbClient->query("SELECT * FROM Person WHERE age=46");
    record {|record {} value;|}? data1 = check streamData1.next();
    check streamData1.close();
    record {}? value1 = data1?.value;

    sql:ParameterizedQuery[] sqlQuery2 = from var person in personList
                                         from var nickname in <@untainted>nicknameList
                                         where person.name == nickname
                                         select `INSERT INTO Person VALUES (${person.id}, ${nickname}, 59)`;
    sql:ExecutionResult[]? result2 = check dbClient->batchExecute(sqlQuery2);

    stream<record{}, error> streamData2 = dbClient->query("SELECT * FROM Person WHERE name='Matty' AND age=59");
    record {|record {} value;|}? data2 = check streamData2.next();
    check streamData2.close();
    record {}? value2 = data2?.value;

    sql:ParameterizedQuery[] sqlQuery3 = from var person in personList
                                         select `INSERT INTO Person VALUES (${person.id}, 'Maththew', ${person
                                         .age})`;
    sql:ExecutionResult[]? result3 = check dbClient->batchExecute(sqlQuery3);

    stream<record{}, error> streamData3 = dbClient->query("SELECT * FROM Person WHERE name='Maththew'");
    record {|record {} value;|}? data3 = check streamData3.next();
    check streamData3.close();
    record {}? value3 = data3?.value;
    check dbClient.close();

    io:println(value1);
    io:println(value2);
    io:println(value3);
}
