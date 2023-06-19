// Copyright (c) 2023, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.
//
// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein in any form is strictly forbidden, unless permitted by WSO2 expressly.
// You may not alter or remove any copyright or other notice from copies of this content.

import ballerinax/java.jdbc;

# sql:ConnectionPool parameter record with default optimized values
#
# + maxOpenConnections -   The maximum open connections
# + maxConnectionLifeTime - The maximum lifetime of a connection
# + minIdleConnections - The minimum idle time of a connection
type SqlConnectionPoolConfig record {|
    int maxOpenConnections = -10;
    decimal maxConnectionLifeTime = -180;
    int minIdleConnections = -5;
|};

# [Configurable] Allocation JDBC Database
#
# + url - url
# + user - database username
# + password - database password
# + connectionPool - sql:ConnectionPool configurations, type: SqlConnectionPoolConfig
type AllocationDatabase record {|
    string url;
    string user;
    string password;
    SqlConnectionPoolConfig connectionPool;
|};

configurable AllocationDatabase allocationDatabase = ?;

final jdbc:Client allocationDbClient = check new (
    url = allocationDatabase.url,
    user = allocationDatabase.user,
    password = allocationDatabase.password,
    connectionPool = {
        ...allocationDatabase.connectionPool
    }
);
