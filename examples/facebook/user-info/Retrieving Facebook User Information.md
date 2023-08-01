# Facebook Integration using Ballerina's JDBC Connector

## Overview

The example demonstrates how to use the Ballerina JDBC client to integrate with Facebook by using the [`CDATA Facebook JDBC Driver`](https://www.cdata.com/drivers/).

## Implementation

It is a simple project, which shows how to get user info by using the username and password of Facebook.

## Prerequisite

* *Adding the Facebook JDBC driver*

    * Download the [driver](https://www.cdata.com/drivers/facebook/jdbc/) and extract it.
        
    * Install the `setup.jar` file in the extracted folder by following the instructions in the `readme.txt` file.

    * Open the installed driver directory and activate the license by following the instructions in the `licensing.htm` file.

    * Set the driver JAR path in the `Ballerina.toml` file.
      ```
      [[platform.java17.dependency]]
      path = "PATH"
      ```
      Sample path format for macOS: `/Applications/CData/CData JDBC Driver for Facebook 2021/lib/cdata.jdbc.facebook.jar`

* *Update username and password of Facebook in the `Config.toml`*


## Run the Example
To get user info, move into the `facebook/user-info ` folder and execute the below command. 
It will build the Ballerina project and then run it.
 
```
$bal run
```
