# Facebook Integration using Ballerina's JDBC Connector

## Overview

The example demonstrates how to use the Ballerina JDBC client to integrate with Facebook by using the [`CDATA Facebook JDBC Driver`](https://www.cdata.com/drivers/).

## Implementation

It is a simple project, which shows how to get user info by using username and password of Facebook.

## Prerequisite

* *Adding the Facebook JDBC driver*

    * Download the driver from [here](https://www.cdata.com/drivers/facebook/jdbc/) and extract the zip.
    
    * Install the setup.jar in the extracted folder by following the instructions in the `readme.txt`.
    
    * Open the installed driver directory and activate the license by following the instructions in the `licensing.htm`. 
    
    * Set the driver jar path in the `Ballerina.toml`
        ```
        [[platform.java11.dependency]]
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
