// Copyright (c) 2020 WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/io;
import ballerina/lang.'string as strings;
import ballerina/sql;
import ballerina/test;
import ballerina/time;

string executeParamsDb = "jdbc:h2:" + dbPath + "/" + "EXECUTE_PARAMS_DB";

@test:BeforeGroups {
    value: ["execute-params"]
}
isolated function initExecuteParamsDB() returns error? {
    initializeDatabase("EXECUTE_PARAMS_DB", "execute", "execute-params-test-data.sql");
}

@test:Config {
    groups: ["execute", "execute-params"]
}
function insertIntoDataTable() returns error? {
    int rowId = 4;
    int intType = 1;
    int longType = 9223372036854774807;
    float floatType = 123.34;
    int doubleType = 2139095039;
    boolean boolType = true;
    string stringType = "Hello";
    decimal decimalType = 23.45;

    sql:ParameterizedQuery sqlQuery =
      `INSERT INTO DataTable (row_id, int_type, long_type, float_type, double_type, boolean_type, string_type, decimal_type)
       VALUES(${rowId}, ${intType}, ${longType}, ${floatType}, ${doubleType}, ${boolType}, ${stringType}, ${decimalType})`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoDataTable]
}
function insertIntoDataTable2() returns error? {
    int rowId = 5;
    sql:ParameterizedQuery sqlQuery = `INSERT INTO DataTable (row_id) VALUES(${rowId})`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoDataTable2]
}
function insertIntoDataTable3() returns error? {
    int rowId = 6;
    int intType = 1;
    int longType = 9223372036854774807;
    float floatType = 123.34;
    int doubleType = 2139095039;
    boolean boolType = false;
    string stringType = "1";
    decimal decimalType = 23.45;

    sql:ParameterizedQuery sqlQuery =
      `INSERT INTO DataTable (row_id, int_type, long_type, float_type, double_type, boolean_type, string_type, decimal_type)
        VALUES(${rowId}, ${intType}, ${longType}, ${floatType}, ${doubleType}, ${boolType}, ${stringType}, ${decimalType})`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoDataTable3]
}
function insertIntoDataTable4() returns error? {
    sql:IntegerValue rowId = new (7);
    sql:IntegerValue intType = new (2);
    sql:BigIntValue longType = new (9372036854774807);
    sql:FloatValue floatType = new (124.34);
    sql:DoubleValue doubleType = new (29095039);
    sql:BooleanValue boolType = new (false);
    sql:VarcharValue stringType = new ("stringvalue");
    decimal decimalVal = 25.45;
    sql:DecimalValue decimalType = new (decimalVal);

    sql:ParameterizedQuery sqlQuery =
      `INSERT INTO DataTable (row_id, int_type, long_type, float_type, double_type, boolean_type, string_type, decimal_type)
        VALUES(${rowId}, ${intType}, ${longType}, ${floatType}, ${doubleType}, ${boolType}, ${stringType}, ${decimalType})`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoDataTable4]
}
function deleteDataTable1() returns error? {
    int rowId = 1;
    int intType = 1;
    int longType = 9223372036854774807;
    float floatType = 123.34;
    int doubleType = 2139095039;
    boolean boolType = true;
    string stringType = "Hello";
    decimal decimalType = 23.45;

    sql:ParameterizedQuery sqlQuery =
            `DELETE FROM DataTable where row_id=${rowId} AND int_type=${intType} AND long_type=${longType}
              AND float_type=${floatType} AND double_type=${doubleType} AND boolean_type=${boolType}
              AND string_type=${stringType} AND decimal_type=${decimalType}`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [deleteDataTable1]
}
function deleteDataTable2() returns error? {
    int rowId = 2;
    sql:ParameterizedQuery sqlQuery = `DELETE FROM DataTable where row_id = ${rowId}`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [deleteDataTable2]
}
function deleteDataTable3() returns error? {
    sql:IntegerValue rowId = new (3);
    sql:IntegerValue intType = new (1);
    sql:BigIntValue longType = new (9372036854774807);
    sql:FloatValue floatType = new (124.34);
    sql:DoubleValue doubleType = new (29095039);
    sql:BooleanValue boolType = new (false);
    sql:VarcharValue stringType = new ("1");
    decimal decimalVal = 25.45;
    sql:DecimalValue decimalType = new (decimalVal);

    sql:ParameterizedQuery sqlQuery =
            `DELETE FROM DataTable where row_id=${rowId} AND int_type=${intType} AND long_type=${longType}
              AND double_type=${doubleType} AND boolean_type=${boolType}
              AND string_type=${stringType} AND decimal_type=${decimalType}`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"]
}
function insertIntoComplexTable() returns error? {
    record {}? value = queryJDBCClient(`Select * from ComplexTypes where row_id = 1`);
    byte[] binaryData = <byte[]>getUntaintedData(value, "BLOB_TYPE");
    int rowId = 5;
    string stringType = "very long text";
    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO ComplexTypes (row_id, blob_type, clob_type, binary_type, var_binary_type) VALUES (
        ${rowId}, ${binaryData}, CONVERT(${stringType}, CLOB), ${binaryData}, ${binaryData})`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoComplexTable]
}
function insertIntoComplexTable2() returns error? {
    io:ReadableByteChannel blobChannel = getBlobColumnChannel();
    io:ReadableCharacterChannel clobChannel = getClobColumnChannel();
    io:ReadableByteChannel byteChannel = getByteColumnChannel();

    sql:BlobValue blobType = new (blobChannel);
    sql:ClobValue clobType = new (clobChannel);
    sql:BlobValue binaryType = new (byteChannel);
    int rowId = 6;

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO ComplexTypes (row_id, blob_type, clob_type, binary_type, var_binary_type) VALUES (
        ${rowId}, ${blobType}, CONVERT(${clobType}, CLOB), ${binaryType}, ${binaryType})`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoComplexTable2]
}
function insertIntoComplexTable3() returns error? {
    int rowId = 7;
    var nilType = ();
    sql:ParameterizedQuery sqlQuery =
            `INSERT INTO ComplexTypes (row_id, blob_type, clob_type, binary_type, var_binary_type) VALUES (
            ${rowId}, ${nilType}, CONVERT(${nilType}, CLOB), ${nilType}, ${nilType})`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoComplexTable3]
}
function deleteComplexTable() returns error? {
    record {}|error? value = queryJDBCClient(`Select * from ComplexTypes where row_id = 1`);
    byte[] binaryData = <byte[]>getUntaintedData(value, "BLOB_TYPE");

    int rowId = 2;
    sql:ParameterizedQuery sqlQuery =
            `DELETE FROM ComplexTypes where row_id = ${rowId} AND blob_type= ${binaryData}`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [deleteComplexTable]
}
function deleteComplexTable2() returns error? {
    sql:BlobValue blobType = new ();
    sql:ClobValue clobType = new ();
    sql:BinaryValue binaryType = new ();
    sql:VarBinaryValue varBinaryType = new ();

    int rowId = 4;
    sql:ParameterizedQuery sqlQuery =
            `DELETE FROM ComplexTypes where row_id = ${rowId} AND blob_type= ${blobType} AND clob_type=${clobType}`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 0);
}

@test:Config {
    groups: ["execute", "execute-params"]
}
function insertIntoNumericTable() returns error? {
    sql:BitValue bitType = new (1);
    int rowId = 3;
    int intType = 2147483647;
    int bigIntType = 9223372036854774807;
    int smallIntType = 32767;
    int tinyIntType = 127;
    decimal decimalType = 1234.567;

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO NumericTypes (int_type, bigint_type, smallint_type, tinyint_type, bit_type, decimal_type,
        numeric_type, float_type, real_type) VALUES(${intType},${bigIntType},${smallIntType},${tinyIntType},
        ${bitType},${decimalType},${decimalType},${decimalType},${decimalType})`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1, 2);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoNumericTable]
}
function insertIntoNumericTable2() returns error? {
    int rowId = 4;
    var nilType = ();
    sql:ParameterizedQuery sqlQuery =
            `INSERT INTO NumericTypes (int_type, bigint_type, smallint_type, tinyint_type, bit_type, decimal_type,
            numeric_type, float_type, real_type) VALUES(${nilType},${nilType},${nilType},${nilType},
            ${nilType},${nilType},${nilType},${nilType},${nilType})`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1, 2);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoNumericTable2]
}
function insertIntoNumericTable3() returns error? {
    sql:IntegerValue id = new (5);
    sql:IntegerValue intType = new (2147483647);
    sql:BigIntValue bigIntType = new (9223372036854774807);
    sql:SmallIntValue smallIntType = new (32767);
    sql:SmallIntValue tinyIntType = new (127);
    sql:BitValue bitType = new (1);
    decimal decimalVal = 1234.567;
    sql:DecimalValue decimalType = new (decimalVal);
    sql:NumericValue numbericType = new (1234.567);
    sql:FloatValue floatType = new (1234.567);
    sql:RealValue realType = new (1234.567);

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO NumericTypes (int_type, bigint_type, smallint_type, tinyint_type, bit_type, decimal_type,
        numeric_type, float_type, real_type) VALUES(${intType},${bigIntType},${smallIntType},${tinyIntType},
        ${bitType},${decimalType},${numbericType},${floatType},${realType})`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1, 2);
}

@test:Config {
    groups: ["execute", "execute-params"]
}
function insertIntoDateTimeTable() returns error? {
    int rowId = 2;
    string dateType = "2017-02-03";
    string timeType = "11:35:45";
    string dateTimeType = "2017-02-03 11:53:00";
    string timeStampType = "2017-02-03 11:53:00";

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO DateTimeTypes (row_id, date_type, time_type, datetime_type, timestamp_type)
        VALUES(${rowId}, ${dateType}, ${timeType}, ${dateTimeType}, ${timeStampType})`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoDateTimeTable]
}
function insertIntoDateTimeTable2() returns error? {
    sql:DateValue dateVal = new ("2017-02-03");
    sql:TimeValue timeVal = new ("11:35:45");
    sql:DateTimeValue dateTimeVal =  new ("2017-02-03 11:53:00");
    sql:TimestampValue timestampVal = new ("2017-02-03 11:53:00");
    int rowId = 3;

    sql:ParameterizedQuery sqlQuery =
            `INSERT INTO DateTimeTypes (row_id, date_type, time_type, datetime_type, timestamp_type)
            VALUES(${rowId}, ${dateVal}, ${timeVal}, ${dateTimeVal}, ${timestampVal})`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoDateTimeTable2]
}
function insertIntoDateTimeTable3() returns error? {
    sql:DateValue dateVal = new ();
    sql:TimeValue timeVal = new ();
    sql:DateTimeValue dateTimeVal =  new ();
    sql:TimestampValue timestampVal = new ();
    int rowId = 4;

    sql:ParameterizedQuery sqlQuery =
                `INSERT INTO DateTimeTypes (row_id, date_type, time_type, datetime_type, timestamp_type)
                VALUES(${rowId}, ${dateVal}, ${timeVal}, ${dateTimeVal}, ${timestampVal})`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoDateTimeTable3]
}
function insertIntoDateTimeTable4() returns error? {
    int rowId = 5;
    var nilType = ();

    sql:ParameterizedQuery sqlQuery =
            `INSERT INTO DateTimeTypes (row_id, date_type, time_type, datetime_type, timestamp_type)
            VALUES(${rowId}, ${nilType}, ${nilType}, ${nilType}, ${nilType})`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"]
}
function insertIntoArrayTable() returns error? {
    int[] paraInt = [1, 2, 3];
    int[] paraLong = [100000000, 200000000, 300000000];
    float[] paraFloat = [245.23, 5559.49, 8796.123];
    float[] paraDouble = [245.23, 5559.49, 8796.123];
    decimal[] paraDecimal = [245, 5559, 8796];
    string[] paraString = ["Hello", "Ballerina"];
    boolean[] paraBool = [true, false, true];

    record {}? value = queryJDBCClient(`Select * from ComplexTypes where row_id = 1`);
    byte[][] dataBlob = [<byte[]>getUntaintedData(value, "BLOB_TYPE")];

    sql:ArrayValue paraBlob = new (dataBlob);
    int rowId = 5;

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO ArrayTypes (row_id, int_array, long_array, float_array, double_array, decimal_array, boolean_array,
         string_array, blob_array) VALUES(${rowId}, ${paraInt}, ${paraLong}, ${paraFloat}, ${paraDouble}, ${paraDecimal},
         ${paraBool}, ${paraString}, ${paraBlob})`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"],
    dependsOn: [insertIntoArrayTable]
}
function insertIntoArrayTable2() returns error? {
    int[] paraInt = [];
    int[] paraLong = [];
    float[] paraFloat = [];
    decimal[] paraDecimal = [];
    float[] paraDouble = [];
    string[] paraString = [];
    boolean[] paraBool = [];
    byte[][] paraBlob = [];
    int rowId = 6;

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO ArrayTypes (row_id, int_array, long_array, float_array, double_array, decimal_array, boolean_array,
         string_array, blob_array) VALUES(${rowId}, ${paraInt}, ${paraLong}, ${paraFloat}, ${paraDouble}, ${paraDecimal},
         ${paraBool}, ${paraString}, ${paraBlob})`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"]
}
function insertIntoArrayTable13() returns error? {
    int[] paraInt = [1, 2, 3];
    int[] paraLong = [100000000, 200000000, 300000000];
    float[] paraFloat = [245.23, 5559.49, 8796.123];
    float[] paraDouble = [245.23, 5559.49, 8796.123];
    decimal[] paraDecimal = [245, 5559, 8796];
    string[] paraString = ["Hello", "Ballerina"];
    boolean[] paraBool = [true, false, true];

    int rowId = 5;

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO ArrayTypes2 (row_id, int_array) VALUES (${rowId}, ${paraInt})`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"]
}
function insertIntoArrayTable3() returns error? {
    float float1 = 19.21;
    float float2 = 492.98;
    sql:SmallIntArrayValue paraSmallint = new([1211, 478]);
    sql:IntegerArrayValue paraInt = new([121, 498]);
    sql:BigIntArrayValue paraLong = new ([121, 498]);
    float[] paraFloat = [19.21, 492.98];
    sql:DoubleArrayValue paraDouble = new ([float1, float2]);
    sql:RealArrayValue paraReal = new ([float1, float2]);
    sql:DecimalArrayValue paraDecimal = new ([<decimal> 12.245, <decimal> 13.245]);
    sql:NumericArrayValue paraNumeric = new ([float1, float2]);
    sql:CharArrayValue paraChar = new (["Char value", "Character"]);
    sql:VarcharArrayValue paraVarchar = new (["Varchar value", "Varying Char"]);
    sql:NVarcharArrayValue paraNVarchar = new (["NVarchar value", "Varying NChar"]);
    string[] paraString = ["Hello", "Ballerina"];
    sql:BooleanArrayValue paraBool = new ([true, false]);
    sql:BitArrayValue paraBit = new ([true, false]);
    sql:DateArrayValue paraDate = new (["2021-12-18", "2021-12-19"]);
    time:TimeOfDay time = {hour: 20, minute: 8, second: 12};
    sql:TimeArrayValue paraTime = new ([time, time]);
    time:Civil datetime = {year: 2021, month: 12, day: 18, hour: 20, minute: 8, second: 12};
    sql:DateTimeArrayValue paraDatetime = new ([datetime, datetime]);
    time:Utc timestampUtc = [12345600, 12];
    sql:TimestampArrayValue paraTimestamp = new ([timestampUtc, timestampUtc]);
    byte[] byteArray1 = [1, 2, 3];
    byte[] byteArray2 = [4, 5, 6];
    sql:BinaryArrayValue paraBinary = new ([byteArray1, byteArray2]);
    sql:VarBinaryArrayValue paraVarBinary = new ([byteArray1, byteArray2]);
    io:ReadableByteChannel byteChannel = getByteColumnChannel();
    record {}? value = queryJDBCClient(`Select * from ComplexTypes where row_id = 1`);
    byte[][] paraBlob = [<byte[]>getUntaintedData(value, "BLOB_TYPE")];
    int rowId = 7;

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO ArrayTypes2 (row_id, int_array, long_array, float_array, double_array, decimal_array, boolean_array,
         string_array, smallint_array, numeric_array, real_array, char_array, varchar_array, nvarchar_array, date_array, time_array, datetime_array, timestamp_array, binary_array, varbinary_array, blob_array) VALUES(${rowId}, ${paraInt}, ${paraLong}, ${paraFloat}, ${paraDouble}, ${paraDecimal},
         ${paraBool}, ${paraString}, ${paraSmallint}, ${paraNumeric}, ${paraReal}, ${paraChar}, ${paraVarchar}, ${paraNVarchar}, ${paraDate}, ${paraTime}, ${paraDatetime}, ${paraTimestamp}, ${paraBinary}, ${paraVarBinary}, ${paraBlob})`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"]
}
function insertIntoArrayTable4() returns error? {
    sql:SmallIntArrayValue paraSmallint = new ([]);
    sql:IntegerArrayValue paraInt = new ([]);
    sql:BigIntArrayValue paraLong = new ([]);
    sql:FloatArrayValue paraFloat = new (<int?[]>[]);
    sql:RealArrayValue paraReal = new (<int?[]>[]);
    sql:DecimalArrayValue paraDecimal = new (<int?[]>[]);
    sql:NumericArrayValue paraNumeric = new (<int?[]>[]);
    sql:DoubleArrayValue paraDouble = new (<int?[]>[]);
    sql:CharArrayValue paraChar = new ([]);
    sql:VarcharArrayValue paraVarchar = new ([]);
    sql:NVarcharArrayValue paraNVarchar = new ([]);
    string?[] paraString = [];
    sql:BooleanArrayValue paraBool = new ([]);
    sql:DateArrayValue paraDate = new (<string?[]>[]);
    sql:TimeArrayValue paraTime = new (<string?[]>[]);
    sql:DateTimeArrayValue paraDatetime = new (<string?[]>[]);
    sql:TimestampArrayValue paraTimestamp = new (<string?[]>[]);
    sql:BinaryArrayValue paraBinary = new (<byte[]?[]>[]);
    sql:VarBinaryArrayValue paraVarBinary = new (<byte[]?[]>[]);
    byte[]?[] paraBlob = [];
    int rowId = 8;

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO ArrayTypes2 (row_id, int_array, long_array, float_array, double_array, decimal_array, boolean_array,
         string_array, smallint_array, numeric_array, real_array, char_array, varchar_array, nvarchar_array, date_array, time_array, datetime_array, timestamp_array, binary_array, varbinary_array, blob_array) VALUES(${rowId}, ${paraInt}, ${paraLong}, ${paraFloat}, ${paraDouble}, ${paraDecimal},
         ${paraBool}, ${paraString}, ${paraSmallint}, ${paraNumeric}, ${paraReal}, ${paraChar}, ${paraVarchar}, ${paraNVarchar}, ${paraDate}, ${paraTime}, ${paraDatetime}, ${paraTimestamp}, ${paraBinary}, ${paraVarBinary}, ${paraBlob})`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"]
}
function insertIntoArrayTable5() returns error? {
    sql:SmallIntArrayValue paraSmallint = new ([null, null]);
    sql:IntegerArrayValue paraInt = new ([null, null]);
    sql:BigIntArrayValue paraLong = new ([null, null]);
    sql:FloatArrayValue paraFloat = new (<int?[]>[null, null]);
    sql:RealArrayValue paraReal = new (<int?[]>[null, null]);
    sql:DecimalArrayValue paraDecimal = new (<int?[]>[null, null]);
    sql:NumericArrayValue paraNumeric = new (<int?[]>[null, null]);
    sql:DoubleArrayValue paraDouble = new (<int?[]>[null, null]);
    sql:CharArrayValue paraChar = new ([null, null]);
    sql:VarcharArrayValue paraVarchar = new ([(), ()]);
    sql:NVarcharArrayValue paraNVarchar = new ([null, null]);
    sql:BooleanArrayValue paraBool = new ([null, null]);
    sql:DateArrayValue paraDate = new (<string?[]>[null, null]);
    sql:TimeArrayValue paraTime = new (<string?[]>[null, null]);
    sql:DateTimeArrayValue paraDatetime = new (<string?[]>[null, null]);
    sql:TimestampArrayValue paraTimestamp = new (<string?[]>[null, null]);
    sql:BinaryArrayValue paraBinary = new (<byte[]?[]>[null, null]);
    sql:VarBinaryArrayValue paraVarBinary = new (<byte[]?[]>[null, null]);
    int rowId = 9;

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO ArrayTypes2 (row_id, int_array, long_array, float_array, double_array, decimal_array, boolean_array,
         smallint_array, numeric_array, real_array, char_array, varchar_array, nvarchar_array, date_array, time_array, datetime_array, timestamp_array, binary_array, varbinary_array) VALUES(${rowId}, ${paraInt}, ${paraLong}, ${paraFloat}, ${paraDouble}, ${paraDecimal},
         ${paraBool}, ${paraSmallint}, ${paraNumeric}, ${paraReal}, ${paraChar}, ${paraVarchar}, ${paraNVarchar}, ${paraDate}, ${paraTime}, ${paraDatetime}, ${paraTimestamp}, ${paraBinary}, ${paraVarBinary})`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"]
}
function insertIntoArrayTable6() returns error? {
    decimal decimal1 = 19.21;
    decimal decimal2 = 492.98;
    int int1 = 1;
    int int2 = 4;
    sql:FloatArrayValue paraFloat = new ([int1, int2]);
    sql:RealArrayValue paraReal = new ([decimal1, decimal2]);
    sql:DecimalArrayValue paraDecimal = new ([decimal1, decimal2]);
    sql:NumericArrayValue paraNumeric = new ([decimal1, decimal2]);
    sql:DoubleArrayValue paraDouble = new ([decimal1, decimal2]);
    sql:DateArrayValue paraDate = new (["2021-12-18", "2021-12-19"]);
    sql:TimeArrayValue paraTime = new (["20:08:59", "21:18:59"]);
    sql:DateTimeArrayValue paraDatetime = new (["2008-08-08 20:08:08", "2009-09-09 23:09:09"]);
    sql:TimestampArrayValue paraTimestamp = new (["2008-08-08 20:08:08", "2008-08-08 20:08:09"]);
    io:ReadableByteChannel byteChannel1 = getByteColumnChannel();
    io:ReadableByteChannel byteChannel2 = getByteColumnChannel();
    sql:BinaryArrayValue paraBinary = new ([byteChannel1, byteChannel2]);
    io:ReadableByteChannel varbinaryChannel1 = getBlobColumnChannel();
    io:ReadableByteChannel varbinaryChannel2 = getBlobColumnChannel();
    sql:VarBinaryArrayValue paraVarBinary = new ([varbinaryChannel1, varbinaryChannel2]);
    int rowId = 10;

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO ArrayTypes2 (row_id,float_array, double_array, decimal_array,
         numeric_array, real_array, date_array, time_array, datetime_array, timestamp_array, binary_array, varbinary_array) VALUES(${rowId}, ${paraFloat}, ${paraDouble}, ${paraDecimal},
         ${paraNumeric}, ${paraReal}, ${paraDate}, ${paraTime}, ${paraDatetime}, ${paraTimestamp}, ${paraBinary}, ${paraVarBinary})`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"]
}
function insertIntoArrayTable7() returns error? {
    int int1 = 19;
    int int2 = 492;
    sql:DoubleArrayValue paraReal = new ([int1, int2]);
    sql:RealArrayValue paraDecimal = new ([int1, int2]);
    sql:DecimalArrayValue paraNumeric = new ([int1, int2]);
    sql:NumericArrayValue paraDouble = new ([int1, int2]);
    int rowId = 11;

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO ArrayTypes2 (row_id, double_array, decimal_array,
         numeric_array, real_array) VALUES(${rowId}, ${paraDouble}, ${paraDecimal},
         ${paraNumeric}, ${paraReal})`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"]
}
function insertIntoArrayTable8() returns error? {
    sql:DateArrayValue paraDate = new (["2021-12-18+8.00", "2021-12-19+8.00"]);
    sql:TimeArrayValue paraTime = new (["20:08:59+8.00", "21:18:59+8.00"]);
    sql:DateTimeArrayValue paraDatetime = new (["2008-08-08 20:08:08+8.00", "2009-09-09 23:09:09+8.00"]);
    sql:TimestampArrayValue paraTimestamp = new (["2008-08-08 20:08:08+8.00", "2008-08-08 20:08:09+8.00"]);
    int rowId = 12;

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO ArrayTypes2 (row_id, date_array) VALUES(${rowId}, ${paraDate})`;
    sql:ExecutionResult|error result = executeQueryJDBCClient(sqlQuery);
    test:assertTrue(result is error, "Error Expected for date array");
    test:assertTrue(strings:includes((<error>result).message(), "Unsupported String Value"));

    sqlQuery =
        `INSERT INTO ArrayTypes2 (row_id, time_array) VALUES(${rowId}, ${paraTime})`;
    result = executeQueryJDBCClient(sqlQuery);
    test:assertTrue(result is error, "Error Expected for time array");
    test:assertTrue(strings:includes((<error>result).message(), "Unsupported String Value"));

    sqlQuery =
        `INSERT INTO ArrayTypes2 (row_id, datetime_array) VALUES(${rowId}, ${paraDatetime})`;
    result = executeQueryJDBCClient(sqlQuery);
    test:assertTrue(result is error, "Error Expected for datetime array");
    test:assertTrue(strings:includes((<error>result).message(), "Unsupported String Value"));

    sqlQuery =
        `INSERT INTO ArrayTypes2 (row_id, timestamp_array) VALUES(${rowId}, ${paraTimestamp})`;
    result = executeQueryJDBCClient(sqlQuery);
    test:assertTrue(result is error, "Error Expected for timestamp array");
    test:assertTrue(strings:includes((<error>result).message(), "Unsupported String Value"));
}

@test:Config {
    groups: ["execute", "execute-params"]
}
function insertIntoArrayTable9() returns error? {
     time:TimeOfDay timeRecord = {hour: 14, minute: 15, second:23};
     sql:TimeArrayValue paraTime = new ([timeRecord]);

     time:Date dateRecord = {year: 2017, month: 5, day: 23};
     sql:DateArrayValue paraDate = new ([dateRecord]);

     time:Utc timestampRecord = time:utcNow();
     sql:TimestampArrayValue paraTimestamp = new ([timestampRecord]);

    int rowId = 13;

    sql:ParameterizedQuery sqlQuery =
        `INSERT INTO ArrayTypes2 (row_id, time_array, date_array, timestamp_array) VALUES(${rowId},
                ${paraTime}, ${paraDate}, ${paraTimestamp})`;
    validateResult(check executeQueryJDBCClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"]
}
function insertIntoArrayTable10() returns error? {
     time:TimeOfDay timeWithTzRecord = {utcOffset: {hours: 6, minutes: 30}, hour: 16, minute: 33, second: 55, "timeAbbrev": "+06:30"};
     sql:TimeArrayValue paraTimeWithTZ = new ([timeWithTzRecord]);
     int rowId = 14;
     sql:ParameterizedQuery sqlQuery =
        `INSERT INTO ArrayTypes2 (row_id, time_tz_array) VALUES(${rowId},
                ${paraTimeWithTZ})`;
     validateResult(check executeQueryJDBCClient(sqlQuery), 1);
}

@test:Config {
    groups: ["execute", "execute-params"]
}
function insertIntoArrayTable11() returns error? {
     time:Civil timestampWithTzRecord = {utcOffset: {hours: -8, minutes: 0}, timeAbbrev: "-08:00", year:2017,
                                            month:1, day:25, hour: 16, minute: 33, second:55};
     sql:DateTimeArrayValue paraDatetimeWithTZ = new ([timestampWithTzRecord]);
     int rowId = 14;
     sql:ParameterizedQuery sqlQuery =
        `INSERT INTO ArrayTypes2 (row_id, timestamp_tz_array) VALUES(${rowId},
                ${paraDatetimeWithTZ})`;
     sql:ExecutionResult|error result = executeQueryJDBCClient(sqlQuery);
     test:assertTrue(result is error, "Error Expected for timestamp array");
}

function executeQueryJDBCClient(sql:ParameterizedQuery sqlQuery) returns sql:ExecutionResult|error {
    Client dbClient = check new (url = executeParamsDb, user = user, password = password);
    sql:ExecutionResult result = check dbClient->execute(sqlQuery);
    check dbClient.close();
    return result;
}

function queryJDBCClient(sql:ParameterizedQuery sqlQuery) returns record {}? {
    Client dbClient = checkpanic new (url = executeParamsDb, user = user, password = password);
    stream<record{}, error?> streamData = dbClient->query(sqlQuery);
    record {|record {} value;|}? data = checkpanic streamData.next();
    checkpanic streamData.close();
    record {}? value = data?.value;
    checkpanic dbClient.close();
    return value;
}

isolated function validateResult(sql:ExecutionResult result, int rowCount, int? lastId = ()) {
    test:assertExactEquals(result.affectedRowCount, rowCount, "Affected row count is different.");

    if (lastId is ()) {
        test:assertEquals(result.lastInsertId, (), "Last Insert Id is not nil.");
    } else {
        int|string? lastInsertIdVal = result.lastInsertId;
        if (lastInsertIdVal is int) {
            test:assertTrue(lastInsertIdVal > 1, "Last Insert Id is nil.");
        } else {
            test:assertFail("The last insert id should be an integer found type '" + lastInsertIdVal.toString());
        }
    }
}
