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

public isolated client class Client {

    final cache:Cache cache;
    final jdbc:Client dbClient;

    public isolated function init(string url, jdbc:Options options, cache:CacheConfig cacheConfig) returns error? {
        self.dbClient = check new (url, options = options);
        self.cache = new cache:Cache(cacheConfig);
    }
 
    public isolated function addData(string msg) returns error|string {
        sql:ParameterizedQuery query = `INSERT INTO Posts (message) VALUES (${msg})`;
        sql:ExecutionResult result = check self.dbClient->execute(query);
        string id = result.lastInsertId.toString();
        _ = check self.getData(id);
        return result.lastInsertId.toString();
    }

    public isolated function getData(string id) returns record {}|error {
        any|error data = self.cache.get(id);
        if data !is error {
            return <PostInfo>data;
        }
        stream<PostInfo, error?> resultStream = self.dbClient->query(`SELECT * FROM Posts WHERE ID = ${id}`);
        any result = check resultStream.next();
        check resultStream.close();
        check self.cache.put(id, result);
        return <PostInfo>result;
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
