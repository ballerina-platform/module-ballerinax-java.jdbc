# Overview

Example for using Snowflake with the Ballerina JDBC connector.

## Prerequisites

### 1. Create an account on [Snowflake](https://signup.snowflake.com/).
Snowflake provides a 30-day free trial with $400 worth of free usage to test drive the platform. 
This configuration used for this example is as follows,
* Snowflake edition: `Standard`
* Cloud provider: `Amazon Web Services`
* Region: `Asia Pacific (Mumbai)`

### 2. Activate Snowflake Account
An activation email will be sent to the email used to sign up on snowflake. 
Click on the button/link in the email to activate your snowflake account.

### 3. Choose username and password
Choose a username and password. 
These will be the credentials that you will use to connect to snowflake. 

### 4. Creating database, warehouse and tables
Using either the Snowflake Web UI or using Ballerina, databases, warehouses and tables can be created.
An example of creating the above and populating the table is shown in the `modules/setup` example.

## Connecting to Snowflake Using the Ballerina JDBC connector

### 1. Add the Snowflake JDBC driver
Follow one of the following ways to add the Snowflake JDBC driver JAR in the `Ballerina.toml` file:
* Download the JAR and update the path
    ```
    [[platform.java11.dependency]]
    path = "PATH"
    ```

* Replace the above path with a maven dependency parameter
    ```
    [[platform.java11.dependency]]
    groupId = "net.snowflake"
    artifactId = "snowflake-jdbc"
    version = "3.13.5"
    ```

### 2. Setting the configuration variables
In the `Config.toml` file, set the configuration variables to correspond to your Snowflake account.
* `jdbcUrlSF`: "jdbc\:snowflake\://https://\<ACCOUNT_NAME>.snowflakecomputing.com"
  * The account name will appear in the URL when you log in to your snowflake account using the web interface. 
* `dbUsernameSF` = "\<SNOWFLAKE_USERNAME\>"
* `dbPasswordSF` = "\<SNOWFLAKE_PASSWORD\>"

### 3. Establishing the connection
The following options must be set when establishing the connection.
For additional connection parameters, visit [here](https://docs.snowflake.com/en/user-guide/jdbc-parameters.html).

The `requestGeneratedKeys` option must be set to `jdbc:NONE` as snowflake does not support the retrieval of auto-generated keys.
```
import ballerinax/java.jdbc

jdbc:Options options = {
    properties: {
        db: "CompanyDB",
        schema: "PUBLIC",
        warehouse: "TestWarehouse"
    },
    requestGeneratedKeys: jdbc:NONE // Must be set to JDBC:NONE
};

jdbc:Client dbClient = check new (jdbcUrlSF, dbUsernameSF, dbPasswordSF, options = options);
```

After establishing the connection, queries may be executed using the `dbClient` as usual.
```
_ = check dbClient->execute(`
    INSERT INTO Employees (first_name, last_name, email, address, joined_date, salary)
    VALUES ('John', 'Smith', 'john@smith.com', 'No. 32, 1st Lane, SomeCity.', '2021-08-20', 50000);
`);

stream<record{}, sql:Error?> streamData = dbClient->query("SELECT * FROM Employees");
_ = check streamData.forEach(function(record {} data) {
    io:println(data);
});
```

## Examples

### 1. Setup
This example illustrates the following
* How to establish a connection to your Snowflake account
* How to create a database, warehouse and table
* Populating the table

This example can be run by executing the command `bal run modules/setup`.

### 2. Service
This example creates an HTTP service with two endpoints
#### 2.1 `/findByEmail`, method:`GET`
* This would query the Employees table and fetch the first result with the provided email.
* E.g.: `https://localhost:9090/findByEmail/?email=john@smith.com`
  

#### 2.2 `/addEmployee`, method:`POST`
* Adds a new entry to the Employees table using the provided json data.
* Example CURL request:
  ```
  curl --location --request POST 'localhost:9090/addEmployee' \
  --header 'Content-Type: application/json' \
  --data-raw '{
      "first_name": "John",
      "last_name": "Smith",
      "email": "john@smith.com",
      "address": "No. 22, 1st Lane, Some City.",
      "joined_date": "2021-08-25",
      "salary": 20000
  }'
  ```
This example can be run by executing the command `bal run modules/service`.