# Facebook Integration using Ballerina's JDBC Connector

## Overview

The example demonstrates how to use the Ballerina JDBC client to integrate with Facebook by using the [`CDATA Facebook JDBC Driver`](https://www.cdata.com/drivers/).

## Implementation

This is an HTTP RESTful service that is used to insert, create, and retrieve data of Facebook posts.

## Prerequisite

* *Adding the Facebook JDBC driver*

  * Download the [driver](https://www.cdata.com/drivers/facebook/jdbc/) and extract it.

  * Install the `setup.jar` file in the extracted folder by following the instructions in the `readme.txt` file.

  * Open the installed driver directory and activate the license by following the instructions in the `licensing.htm` file.

  * Set the driver JAR path in the `Ballerina.toml` file.
    ```
    [[platform.java11.dependency]]
    path = "PATH"
    ```
    Sample path format for macOS: `/Applications/CData/CData JDBC Driver for Facebook 2021/lib/cdata.jdbc.facebook.jar`

* *Updating Facebook Configurations in the `Config.toml`*
  
  * Creating an app on Facebook.
    * Log into Facebook and navigate to https://developers.facebook.com/apps.
    * Click `Add a New App` and define the name of your app.
    * Go to the created app, click `Settings` and find the app ID and app secret in the `Basic` section.

  * Obtaining a Page Access Token in Facebook
    * Create a page on Facebook.
    * Open the [Facebook Explorer](https://developers.facebook.com/tools/explorer) to get a page access token with
      permission for creating a post by using the created page. For more information about permissions, click [Access Tokens](https://developers.facebook.com/docs/pages/access-tokens/).

  * Updating the `Config.toml` file with the above configurations.

## Run the Example
To start the service, move into the `facebook/posts` folder and execute the command below.
It will build the posts of the Ballerina project and then run it.
 
```
$bal run
```

## Send Sample Requests

Run the following cURL request to manipulate the Facebook posts.

#### Create the New Post
```
curl -X POST "http://localhost:9092/facebook/posts" --data 'Message'
```

#### Delete the Post

```
curl -X DELETE "http://localhost:9092/facebook/posts/[ADD ID]"
```

#### Get the IDs of the Post

```
curl -X GET "http://localhost:9092/facebook/posts"
```

#### Get info of the specific Post

```
curl -X GET "http://localhost:9092/facebook/posts/[ADD ID]"
```
