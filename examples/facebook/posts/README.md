# Facebook Integration using Ballerina's JDBC Connector

## Overview

The example demonstrates how to use the Ballerina JDBC client to integrate with Facebook by using the [`CDATA Facebook JDBC Driver`](https://www.cdata.com/drivers/).

## Implementation

This is an HTTP RESTful service that is used to insert, create and retrieve posts' data from Facebook.

## Prerequisite

* *Adding the Facebook JDBC driver*

  * Download the driver from [here](https://www.cdata.com/drivers/facebook/jdbc/) and extract the zip.

  * Install the setup.jar in the extracted folder by following the instructions in the `readme.txt`.

  * Open the installed driver directory and activate the license by following the instructions in the `licensing.htm`. 

  * Set the driver jar path in the `Ballerina.toml`.
    ```
    [[platform.java11.dependency]]
    path = "PATH"
    ```
    Sample path format for macOS: `/Applications/CData/CData JDBC Driver for Facebook 2021/lib/cdata.jdbc.facebook.jar`

* *Updating Facebook Configurations in the `Config.toml`*
  
  * Creating an App in Facebook
    * Log into Facebook and navigate to https://developers.facebook.com/apps.
    *  Click `Add a New App` and define your app’s name.
    *  Go to the crated app, click `Setting` and find app ID and app secret in the `Basic`

  * Obtaining a Page Access Token in Facebook
    * Create a page in the Facebook.
    * Open the [Facebook Explorer](https://developers.facebook.com/tools/explorer) to get a page access token with 
      permission for creating a post by using the created page. For more information about permissions, click [here](https://developers.facebook.com/docs/pages/access-tokens/).

  * Updating `Config.toml` file with above configurations.

## Run the Example
To start the service, move into the `facebook/posts ` folder and execute the below command. 
It will build the posts Ballerina project and then run it.
 
```
$bal run
```

## Send Sample Requests

Run the following cURL request to manipulate facebook posts.

#### Create the New Post
```
curl -X POST "http://localhost:9092/facebook/posts/create" --data 'Message'
```

#### Delete the Post

```
curl -X DELETE "http://localhost:9092/facebook/posts/delete/[ADD ID]"
```

#### Get Posts' IDs

```
curl -X GET "http://localhost:9092/facebook/posts/getIds"
```
