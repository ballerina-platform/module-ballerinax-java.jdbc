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
    // cache:Cache cache = new (capacity = 50, evictionFactor = 0.2);
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
