# Specification: Ballerina JDBC Library

_Owners_: @niveathika @aashikam @shafreenAnfar  
_Reviewers_:  
_Created_: 2022/01/14  
_Updated_: 2026/11/26  
_Edition_: Swan Lake  

## Introduction

This is the specification for the generic JDBC connector of the [Ballerina language](https://ballerina.io/), `ballerinax/java.jdbc`, which provides a client for any relational database that has a JDBC driver, built on the `ballerina/sql` library.

This specification is the contract of the library. It defines the observable behaviour of the connector: the configuration it accepts, how it loads the driver and connects to the database, how it uses the connector contract of the `ballerina/sql` library, the errors it returns, and what it rejects at compile time. The behaviour that the connector takes unchanged from `ballerina/sql` is specified in the [SQL specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md) and is not repeated here. A behaviour of the implementation that differs from this specification is a bug in the implementation. A behaviour that this specification does not define is a gap in the specification, and is also reported as a bug. Signatures and per-symbol documentation are part of the [API documentation](https://central.ballerina.io/ballerinax/java.jdbc/latest), and usage examples are part of [Ballerina by Example](https://ballerina.io/learn/by-example/). Neither is repeated here.

The released versions of the specification can be found under the relevant GitHub tag. Changes to the specification follow the proposal process described in the [library development process](https://github.com/ballerina-platform/ballerina-library/blob/main/docs/library-development-process.md). If you have any feedback or suggestions about the library, start a discussion via a [GitHub issue](https://github.com/ballerina-platform/ballerina-library/issues) or in the [Discord server](https://discord.gg/ballerinalang).

### Notation

- The key words MUST, MUST NOT, REQUIRED, SHALL, SHALL NOT, SHOULD, SHOULD NOT, RECOMMENDED, MAY and OPTIONAL are interpreted as described in [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) and [RFC 8174](https://www.rfc-editor.org/rfc/rfc8174) when, and only when, they appear in all capitals. Other statements of behaviour in the present tense are also normative.
- Examples and notes are informative.
- "SQL §*n*" refers to section *n* of the [SQL specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md). A table row of the SQL specification is identified by the value of its first cell, as described in [SQL §17.1](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#171-description).
- _Implementation-defined_ behaviour is chosen and documented by the implementation; _unspecified_ behaviour must not be relied on. _Driver-defined_ behaviour is that of the JDBC driver, or the data source class, that the program provides, and of its database.

## Contents

- [1. Overview](#1-overview)
- [2. Terminology](#2-terminology)
- [3. Client](#3-client)
    - [3.1. Description](#31-description)
    - [3.2. Configuration](#32-configuration)
    - [3.3. Initialization](#33-initialization)
    - [3.4. Driver](#34-driver)
    - [3.5. Connection URL](#35-connection-url)
    - [3.6. Operations](#36-operations)
    - [3.7. Compile-time validation](#37-compile-time-validation)
    - [3.8. Errors](#38-errors)
    - [3.9. Interactions](#39-interactions)
- [4. Connection options](#4-connection-options)
    - [4.1. Description](#41-description)
    - [4.2. Configuration](#42-configuration)
    - [4.3. Properties](#43-properties)
    - [4.4. Data source](#44-data-source)
    - [4.5. Generated keys](#45-generated-keys)
    - [4.6. Errors](#46-errors)
    - [4.7. Interactions](#47-interactions)
- [5. Connector contract](#5-connector-contract)
    - [5.1. Description](#51-description)
    - [5.2. Obligations](#52-obligations)
    - [5.3. Override points](#53-override-points)
- [6. Observability](#6-observability)
    - [6.1. Description](#61-description)
    - [6.2. Metric tags](#62-metric-tags)
- [7. Security considerations](#7-security-considerations)
- [8. Planned changes](#8-planned-changes)
- [References](#references)

## 1. Overview

The `jdbc:Client` class includes `sql:Client`. It connects to a database through a JDBC driver, or a JDBC data source class, that the program provides, and a connection pool of the `ballerina/sql` library, and executes the operations of `sql:Client` (`query`, `queryRow`, `execute`, `batchExecute`, `call` and `close`) as specified in the SQL specification.

The connector is generic: it does not know the database it connects to. It passes the JDBC URL, the credentials and the properties it is given to the driver without interpreting them, and it changes none of the default binding, result mapping or procedure call behaviour of the SQL specification. Behaviour that the SQL specification leaves to the driver is therefore determined by the driver the program provides. This specification states how the client is configured, how the driver or data source is selected, which operations request generated keys, and what the connector checks at initialization and at compile time.

## 2. Terminology

The terms of [SQL §2](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#2-terminology) apply. In addition:

| Term | Meaning |
|---|---|
| Driver | A JDBC driver (`java.sql.Driver`) on the program's class path, registered with the JDBC `DriverManager`. |
| Data source class | The class named by `datasourceName`, an implementation of `javax.sql.DataSource` or `javax.sql.XADataSource` provided by the program ([§4.4](#44-data-source)). |
| Property | An entry of the `properties` field of `jdbc:Options`, given to the driver or the data source ([§4.3](#43-properties)). |
| String form | The string a property value is given as: `value:toString` of an `int`, `float`, `decimal`, `boolean` or `string` value; for example `5` gives `"5"`, `5.0` and `5.0d` give `"5.0"`, `1.0e20` gives `"1.0E20"` and `1e20d` gives `"1E+20"`. |

## 3. Client

### 3.1. Description

`jdbc:Client` is a client of a database reached through a JDBC URL. Its initializer checks the URL and the options, and creates the client through the `sql` library ([SQL §3.3.1](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#331-creation)).

### 3.2. Configuration

The initializer takes the following parameters.

| Parameter | Type | Default | Meaning |
|---|---|---|---|
| `url` | `string` | Required | JDBC URL of the database ([§3.5](#35-connection-url)). |
| `user` | `string?` | `()` | User name. `()` means no user is given to the driver ([§4.3](#43-properties) rule 4). |
| `password` | `string?` | `()` | Password. `()` means no password is given to the driver ([§4.3](#43-properties) rule 4). |
| `options` | `jdbc:Options?` | `()` | Connection options ([§4](#4-connection-options)). `()` has the same effect as `{}`: no data source class, no properties, and the default `requestGeneratedKeys` ([§4.5](#45-generated-keys) rule 2). |
| `connectionPool` | `sql:ConnectionPool?` | `()` | Pool configuration ([SQL §4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#4-connection-pool)). `()` means the global pool configuration ([SQL §4.5](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#45-global-pool-configuration)). |

### 3.3. Initialization

The initializer performs the following steps. A failing step makes the initializer return the error it states, and no client is created.

1. If `url` starts with `jdbc:sqlserver`, compared case-sensitively and without removing white space, `requestGeneratedKeys` defaults to `jdbc:EXECUTE`, and a `requestGeneratedKeys` given as `jdbc:ALL` or `jdbc:BATCH_EXECUTE` makes the initializer return an `sql:ApplicationError` ([§4.5](#45-generated-keys) rule 2).
2. The URL is checked as specified in [§3.5](#35-connection-url) rule 1.
3. The connector derives no pool property from the options; the pool configuration alone sets the pool's connection wait ([§4.3](#43-properties) rule 6).
4. The connector gives the URL, `user`, `password`, `datasourceName`, `properties` and the pool configuration to the `sql` library, which selects or creates the pool and verifies the connection as specified in [SQL §3.3.1](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#331-creation) and [SQL §4.7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#47-pool-creation).

### 3.4. Driver

1. The connector does not contain a driver. The program MUST provide the driver, or the data source class, on its class path, for example as a platform dependency in `Ballerina.toml` or by importing a driver package such as `ballerinax/h2.driver`.
2. When `datasourceName` is absent or `""`, the pool obtains the driver from the JDBC `DriverManager` by the URL: the driver used is a registered driver that accepts the URL. Which driver is used when several registered drivers accept the URL is _unspecified_.
3. When no registered driver accepts the URL, pool creation fails as specified in [SQL §4.7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#47-pool-creation) step 5.
4. When `datasourceName` is given and is not `""`, the pool connects through the data source class instead, as specified in [§4.4](#44-data-source).

### 3.5. Connection URL

1. After leading and trailing white space is removed, the URL MUST start with `jdbc:`, compared case-sensitively. Otherwise, including for `""`, the initializer returns an `sql:ApplicationError` without creating a pool.
2. The connector does not otherwise validate, parse or change the URL. It is given to the driver as given, including any leading or trailing white space. Whether the driver accepts it is driver-defined.
3. The pool key of the client ([SQL §4.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#46-pool-selection)) is its URL and its `properties` map, together with its `user` and `password`, its data source class and whether its pool is an XA pool ([§4.4](#44-data-source) rule 4), as specified in [SQL §4.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#46-pool-selection) rule 6. Clients whose `user`, `password` or `datasourceName` differ therefore never share a pool ([§7](#7-security-considerations)). `requestGeneratedKeys` is not part of the pool key; it applies to each client separately ([SQL §4.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#46-pool-selection) rule 7). An absent `properties` field, including `options` `()`, and `properties: {}` are different pool keys.

### 3.6. Operations

1. `query`, `queryRow`, `execute`, `batchExecute`, `call` and `close` behave as specified in [SQL §3](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#3-client) and [SQL §8](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#8-query) to [SQL §13](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#13-transactions), with the default binding ([SQL §6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#6-parameter-binding)), result mapping ([SQL §7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#7-result-mapping)) and OUT parameter handling ([SQL §12](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#12-stored-procedure-calls)) of the SQL specification.
2. Generated keys are requested as configured by `requestGeneratedKeys` ([§4.5](#45-generated-keys)).
3. Outcomes that the SQL specification states as driver-defined, such as the JDBC type a column is reported with, the generated keys a statement produces, and whether a database accepts a parameter's SQL type, are those of the driver in use.

### 3.7. Compile-time validation

The `ballerinax/java.jdbc` compiler plugin checks each `new` expression whose type is `jdbc:Client`, or a union containing it. It checks the `connectionPool` argument when it is a mapping constructor, given as a named argument or as the fifth positional argument of a call with five arguments. For each field whose value is a numeric literal, optionally preceded by a unary `-`, it reports `SQL_101`, `SQL_102` and `SQL_103` under the conditions of the table of [SQL §4.9](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#49-compile-time-validation). A literal is checked by its value whatever its form, including a hexadecimal literal and a value outside the 32-bit integer range.

1. Field values that are not literals are not checked.
2. A spread field (`...p`) of the mapping constructor is not checked.
3. Only the diagnostics of the table make the build fail; a field value that is not checked, including a spread field, does not make the build fail.
4. The plugin does not check a module whose compilation already has errors.
5. The `options` argument is not checked.

The runtime checks of [SQL §4.7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#47-pool-creation) step 3 apply to values the plugin does not check. The message texts of the diagnostics are _unspecified_.

> **Note:** A `sql:ConnectionPool` variable declaration is checked by the `sql` compiler plugin ([SQL §4.9](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#49-compile-time-validation)).

### 3.8. Errors

| Condition | Error |
|---|---|
| A URL starting with `jdbc:sqlserver` with `requestGeneratedKeys` given as `jdbc:ALL` or `jdbc:BATCH_EXECUTE` | `sql:ApplicationError`, returned by the initializer |
| A URL that does not start with `jdbc:` ([§3.5](#35-connection-url) rule 1) | `sql:ApplicationError`, returned by the initializer |
| A driver or data source failure of [§3.4](#34-driver) or [§4.4](#44-data-source) | As specified in [§4.6](#46-errors) and [SQL §4.10](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#410-errors) |
| Pool creation or the verification connection fails, including an unreachable database and failed authentication | As specified in [SQL §3.5](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#35-errors) and [SQL §4.10](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#410-errors) |
| Any other failure | As specified in [SQL §15](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#15-errors) |

The message of the `jdbc:sqlserver` error starts with ``Unsupported `requestGeneratedKeys` option``. The messages of the errors the initializer returns do not contain the URL as given: they omit it, or include it with every credential written in it masked ([§7](#7-security-considerations)). Which of the two forms is used, and the rest of the message texts, are _unspecified_.

### 3.9. Interactions

- A client given no `connectionPool` uses the global pool configuration, so clients with equal pool keys share one pool ([SQL §4.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#46-pool-selection)), also when their `requestGeneratedKeys` differ; clients whose `user`, `password` or `datasourceName` differ get separate pools ([§3.5](#35-connection-url) rule 3).
- Two clients whose `properties` differ use different pools. Values are compared by type and representation, not with `==`: `{"a": 1}`, `{"a": "1"}`, `{"a": 1.0}` and `{"a": 1.0d}` are different keys, and so are `{"a": 1.0d}` and `{"a": 1.00d}`. An absent `properties` field and `properties: {}` are different keys ([§3.5](#35-connection-url) rule 3).

### 3.10. Example: Client creation

```ballerina
import ballerinax/h2.driver as _;
import ballerinax/java.jdbc;

# Creates a client of an in-memory H2 database with a pool of its own.
#
# + return - The client, or an error if it cannot be created
function createOrdersClient() returns jdbc:Client|error {
    return new ("jdbc:h2:mem:orders", "sa", "", connectionPool = {maxOpenConnections: 5});
}
```

The H2 driver provided by `ballerinax/h2.driver` accepts the URL ([§3.4](#34-driver) rule 2), and the client gets a pool of its own because its pool configuration is written inline ([SQL §4.6](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#46-pool-selection)). `execute` and `batchExecute` request generated keys, because `options` is `()` ([§3.2](#32-configuration)).

## 4. Connection options

### 4.1. Description

`jdbc:Options` selects a data source class, gives properties to the driver or data source, and selects the operations that request generated keys.

### 4.2. Configuration

`jdbc:Options` is a closed record.

| Field | Type | Default | Meaning |
|---|---|---|---|
| `datasourceName` | `string` | absent | Fully qualified name of the data source class ([§4.4](#44-data-source)). Absent and `""` mean the driver is obtained by the URL ([§3.4](#34-driver) rule 2). |
| `properties` | `map<anydata>` | absent | Properties given to the driver or the data source ([§4.3](#43-properties)). Absent and `{}` mean no properties, but are different pool keys ([§3.5](#35-connection-url) rule 3). |
| `requestGeneratedKeys` | `jdbc:Operations` | `jdbc:ALL`; `jdbc:EXECUTE` for a `jdbc:sqlserver` URL | The operations that request generated keys ([§4.5](#45-generated-keys)). |

`jdbc:Operations` is an enumeration with the members `NONE`, `EXECUTE`, `BATCH_EXECUTE` and `ALL`.

### 4.3. Properties

1. Each entry of `properties` is given to the driver, or set on the data source, as a property with the entry's key as its name ([SQL §4.7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#47-pool-creation) rule 7).
2. Without a data source class, the value of each entry is given to the driver as its string form ([§2](#2-terminology)), for example `true` as `"true"` and `5` as `"5"`. Whether the driver uses, ignores or rejects a property is driver-defined.
3. With a data source class, each entry sets the JavaBeans property of the same name of the data source. Outside an XA pool ([§4.4](#44-data-source) rule 4), the string form of the value is converted to the property's type when that type is `int`, `long` or `short`, and used as is when it is `String`; for example, both `5` and `"5"` set an `int` property to `5`, and `5.0d` cannot be converted. A `boolean` property is set to `true` when the string form is `true`, ignoring case, and to `false` otherwise. The conversion to any other property type, and every conversion in an XA pool, is _implementation-defined_. A property that the class does not have, or a value that cannot be converted, makes the initializer return an error ([§4.6](#46-errors)).
4. When `user` is not `()`, it is the user given to the driver or data source, and an entry named `user` does not replace it; the same holds for `password`. When `user` or `password` is `()`, an entry with that name is given like any other property.
5. With a data source class, an entry named `url` is set as the data source's URL instead of the client's `url` ([SQL §4.7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#47-pool-creation) rule 7); the client's `url` remains the pool key. Without a data source class, an entry named `url` is a property like any other, and the driver connects to the client's `url`.
6. The connector derives no pool property from the properties. A property such as `connectTimeout` or `connectionTimeout` is given to the driver or data source like any other property (rules 1–3), and the pool's connection wait is set by the `connectionTimeout` field of the pool configuration alone ([SQL §4.7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#47-pool-creation)). Such a property makes the initializer fail only when the driver or data source rejects it.
7. The connector sets no property of its own. Outside an XA pool, the pool sets the data source property `loginTimeout` from the `connectionTimeout` of the pool configuration after the properties are set, so a `loginTimeout` property has no effect, and login is bounded by the pool's `connectionTimeout` ([SQL §4.7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#47-pool-creation)). The defaults of the driver or data source apply to every other property not given.
8. A property whose value is `()`, a `byte` value or a structured value, such as an array, a map or an XML value, makes the initializer return an `sql:ApplicationError` ([§4.6](#46-errors)); it never makes the initializer panic.

#### 4.3.1. Example: Data source with properties

```ballerina
import ballerinax/h2.driver as _;
import ballerinax/java.jdbc;

# Creates a client that connects through the H2 data source class.
#
# + return - The client, or an error if it cannot be created
function createDataSourceClient() returns jdbc:Client|error {
    return new ("jdbc:h2:mem:inventory", "sa", "", {
        datasourceName: "org.h2.jdbcx.JdbcDataSource",
        properties: {"loginTimeout": 5}
    });
}
```

The pool creates an `org.h2.jdbcx.JdbcDataSource`, sets its `url` to the client's URL and its `user` and `password` properties ([SQL §4.7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#47-pool-creation) rule 7), and sets its `int` property `loginTimeout` to `5` ([§4.3](#43-properties) rule 3), which the pool then replaces with its connection timeout ([§4.3](#43-properties) rule 7). With `properties: {"loginTimeOut": 5}`, which the class does not have, the initializer returns an `sql:ApplicationError`.

### 4.4. Data source

1. When `datasourceName` is given and is not `""`, the pool loads the named class, creates an instance with its public no-argument constructor, and sets the URL, the user, the password and the properties on it as specified in [SQL §4.7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#47-pool-creation) rule 7 and [§4.3](#43-properties).
2. A class that cannot be loaded fails pool creation as specified in [SQL §4.7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#47-pool-creation) step 5.
3. Outside an XA pool (rule 4), the class MUST implement `javax.sql.DataSource`; a class that does not, such as a driver class (`java.sql.Driver`), makes the initializer return an `sql:ApplicationError`.
4. An XA pool is created as specified in [SQL §4.7](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#47-pool-creation) step 1 and [SQL §4.8](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#48-xa-data-sources). When the transaction manager is not enabled, a class that implements `javax.sql.XADataSource` but not `javax.sql.DataSource` makes the initializer return an `sql:ApplicationError` (rule 3). In an XA pool, the class is instantiated and its properties are set when the verification connection is opened ([SQL §3.3.1](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#331-creation) step 3).
5. The URL, user and password are set as the data source properties `url`, `user` and `password`, so a class that has no such property makes the initializer return an `sql:ApplicationError` when the value is set.

### 4.5. Generated keys

`requestGeneratedKeys` selects the operations for which the client requests generated keys ([SQL §17.2](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#172-connector-obligations) rule 4):

| Value | `execute` | `batchExecute` |
|---|---|---|
| `NONE` | not requested | not requested |
| `EXECUTE` | requested | not requested |
| `BATCH_EXECUTE` | not requested | requested |
| `ALL` | requested | requested |

1. `lastInsertId` follows [SQL §10.4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#104-generated-keys) and [SQL §11.3](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#113-results) for the requested operations; the setting is per client ([SQL §10.4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#104-generated-keys) rule 6).
2. For a URL that starts with `jdbc:sqlserver` ([§3.3](#33-initialization) step 1), the default is `EXECUTE` instead of `ALL`, and a `requestGeneratedKeys` given as `ALL` or `BATCH_EXECUTE` makes the initializer return an `sql:ApplicationError`. For every other URL the default is `ALL`.
3. The connector does not offer the `sql:GeneratedKeysMode` option of [SQL §10.4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#104-generated-keys) rule 7: for a requested operation, keys are requested as SQL §10.4 rules 1–6 state, and `requestGeneratedKeys` cannot limit the requests to `INSERT` statements.

#### 4.5.1. Example: Generated keys for execute only

```ballerina
import ballerina/sql;
import ballerinax/h2.driver as _;
import ballerinax/java.jdbc;

# Inserts one row with `execute` and two rows with `batchExecute`.
#
# + url - JDBC URL of an H2 database
# + return - The `lastInsertId` of the `execute` call and of each batch statement
function insertItems(string url) returns [string|int?, (string|int?)[]]|error {
    jdbc:Client db = check new (url, "sa", "", {requestGeneratedKeys: jdbc:EXECUTE});
    _ = check db->execute(`CREATE TABLE items (id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(20))`);
    sql:ExecutionResult one = check db->execute(`INSERT INTO items (name) VALUES ('a')`);
    string[] names = ["b", "c"];
    sql:ExecutionResult[] many = check db->batchExecute(from string name in names
        select `INSERT INTO items (name) VALUES (${name})`);
    check db.close();
    return [one.lastInsertId, from sql:ExecutionResult r in many select r.lastInsertId];
}
```

For an H2 database URL such as `jdbc:h2:mem:items`, the function returns `[1, [(), ()]]`: `execute` requests generated keys and returns the generated `INTEGER` key as an `int` ([SQL §10.4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#104-generated-keys) rule 2), and `batchExecute` does not request them ([SQL §11.3](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#113-results) rule 3).

### 4.6. Errors

| Condition | Error |
|---|---|
| The data source class cannot be loaded, or is not a data source ([§4.4](#44-data-source) rules 2–3) | `sql:ApplicationError`, returned by the initializer |
| The data source class cannot be instantiated, because it has no public no-argument constructor or the constructor throws | `sql:ApplicationError`, returned by the initializer, also in an XA pool |
| A property that the data source class does not have, or a value that cannot be converted to the property's type | `sql:ApplicationError`, returned by the initializer, also in an XA pool |
| A property whose value is `()`, a `byte` value or a structured value ([§4.3](#43-properties) rule 8) | `sql:ApplicationError`, returned by the initializer |
| `requestGeneratedKeys` given as `ALL` or `BATCH_EXECUTE` for a `jdbc:sqlserver` URL | `sql:ApplicationError`, returned by the initializer |
| A property that the driver rejects | As specified in [SQL §3.5](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#35-errors) and [SQL §4.10](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#410-errors) |

### 4.7. Interactions

- `properties` and `datasourceName` are part of the pool key ([§3.5](#35-connection-url) rule 3); `requestGeneratedKeys` is not.
- Transactions over an XA data source follow [SQL §13](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#13-transactions).

## 5. Connector contract

### 5.1. Description

This section states how the connector meets the connector obligations of [SQL §17.2](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#172-connector-obligations), and lists the override points of [SQL §17.4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#174-override-points) that it uses.

### 5.2. Obligations

| [SQL §17.2](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#172-connector-obligations) rule | How the connector meets it |
|---|---|
| 1 | `jdbc:Client` includes `sql:Client` and delegates every operation to the library ([§3.6](#36-operations)). |
| 2 | It gives the URL, the user and password, `datasourceName` as the data source class name, `properties` as the driver options map, and the pool configuration. |
| 3 | When `connectionPool` is `()`, it gives `sql:getGlobalConnectionPool()`. |
| 4 | Generated keys are requested as configured by `requestGeneratedKeys`, by default for both `execute` and `batchExecute`, and for `execute` only with a `jdbc:sqlserver` URL ([§4.5](#45-generated-keys)). |
| 5 | `batchExecute` with an empty array behaves as [SQL §11.2](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#112-behaviour) rule 2. |
| 6 | The connector defines no typed value, OUT parameter or INOUT parameter class. |
| 7 | The connector provides no `sql:SchemaClient`. |
| 8 | The override points are listed in [§5.3](#53-override-points). |

### 5.3. Override points

| [SQL §17.4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#174-override-points) area | Used | Delta |
|---|---|---|
| Binding of basic types, `time` values and arrays | No | |
| Binding of typed values | No | |
| Connector-defined typed values | No | |
| Record parameters | No | |
| Nil parameters | No | |
| OUT parameter registration | No | |
| Result conversion | No | |
| OUT and INOUT values | No | |
| Result iteration | No | |
| Pool properties | No | No pool property is derived from the options ([§4.3](#43-properties) rule 6). |
| Metric tags | No | No tags are added ([§6.2](#62-metric-tags)). |
| Data source | Yes | The driver accepting the URL, or the class named by `datasourceName` ([§3.4](#34-driver), [§4.4](#44-data-source)). |

Every other behaviour of the client is the default behaviour of the SQL specification.

## 6. Observability

### 6.1. Description

The pools of the client report the metrics of [SQL §16](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#16-observability).

### 6.2. Metric tags

The connector adds none of the tags `db_host`, `db_port` and `db_name` ([SQL §16.4](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#164-tags) rule 3), so the metrics of a pool have only the tag `pool_name`.

> **Note:** The connector does not parse the URL, whose format differs between drivers, so it cannot derive these tags.

## 7. Security considerations

1. The security considerations of [SQL §18](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md#18-security-considerations) apply, including rule 2 on clients that share a pool. The pool key contains the user, the password and the data source class ([§3.5](#35-connection-url) rule 3), so a client never uses a pool created with other credentials or another data source class. A client given its own `sql:ConnectionPool` value does not share a pool.
2. The connector does not restrict the URL, the driver, the data source class or the properties. They select the database, the transport and every driver feature, including driver features that read or write local files or execute statements when a connection is opened. A URL, `datasourceName` or property derived from untrusted input can therefore change the database the client connects to and the code that runs in the program.
3. The connector does not configure transport encryption. Whether the connection to the database is encrypted, and whether the server is authenticated, is determined by the URL, the properties and the driver.
4. The messages of the errors the initializer returns do not contain credentials written in the URL ([§3.8](#38-errors)).

## 8. Planned changes

This section is informative. It lists behaviour changes planned for the next major version; the rest of this specification describes the current release.

| Change | Affected rule | Current behaviour | Planned behaviour | How to keep the current behaviour |
|---|---|---|---|---|
| Pool keys compare `properties` with Ballerina equality | [§3.5](#35-connection-url) rule 3, [§3.9](#39-interactions) | An absent `properties` field and `properties: {}` are different keys, and values are compared by type and representation, so `{"a": 1.0d}` and `{"a": 1.00d}` get separate pools. | An absent `properties` field and `properties: {}` are equal keys, and values are compared with `==`, so such clients share one pool. | Give each client that needs a pool of its own its own `sql:ConnectionPool` value. |
| The URL is trimmed once and the SQL Server check ignores case | [§3.3](#33-initialization) step 1, [§3.5](#35-connection-url) rules 1–2, [§4.5](#45-generated-keys) rule 2 | White space is removed only for the `jdbc:` check; the driver and the pool key get the URL as given; the `jdbc:sqlserver` check is case-sensitive and skips a URL with leading white space. | Leading and trailing white space is removed before every check and before the URL is given to the driver and used in the pool key; the `jdbc:sqlserver` check ignores case. | Write the URL without surrounding white space, and for a SQL Server URL give `requestGeneratedKeys` as `NONE` or `EXECUTE`. |

## References

- [SQL specification](https://github.com/ballerina-platform/module-ballerina-sql/blob/master/docs/spec/spec.md)
- [JDBC 4.3 Specification (JSR 221)](https://jcp.org/en/jsr/detail?id=221)
- [`javax.sql.DataSource`](https://docs.oracle.com/en/java/javase/21/docs/api/java.sql/javax/sql/DataSource.html)
- [`java.sql.DriverManager`](https://docs.oracle.com/en/java/javase/21/docs/api/java.sql/java/sql/DriverManager.html)
- [RFC 2119: Key words for use in RFCs to Indicate Requirement Levels](https://www.rfc-editor.org/rfc/rfc2119)
- [RFC 8174: Ambiguity of Uppercase vs Lowercase in RFC 2119 Key Words](https://www.rfc-editor.org/rfc/rfc8174)
