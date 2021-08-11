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
import ballerina/sql;
import ballerina/time;
import ballerina/test;

string simpleParamsDb = "jdbc:h2:" + dbPath + "/" + "QUERY_SIMPLE_PARAMS_DB";

@test:BeforeGroups {
    value: ["query-simple-params"]
}
isolated function initQuerySimpleParamsDB() {
    initializeDatabase("QUERY_SIMPLE_PARAMS_DB", "query", "simple-params-test-data.sql");
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function querySingleIntParam() {
    int rowId = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE row_id = ${rowId}`;
    validateDataTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryDoubleIntParam() {
    int rowId = 1;
    int intType = 1;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE row_id = ${rowId} AND int_type =  ${intType}`;
    validateDataTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryIntAndLongParam() {
    int rowId = 1;
    int longType = 9223372036854774807;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE row_id = ${rowId} AND long_type = ${longType}`;
    validateDataTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryStringParam() {
    string stringType = "Hello";
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE string_type = ${stringType}`;
    validateDataTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryIntAndStringParam() {
    string stringType = "Hello";
    int rowId =1;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE string_type = ${stringType} AND row_id = ${rowId}`;
    validateDataTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryDoubleParam() {
    float doubleType = 2139095039.0;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE double_type = ${doubleType}`;
    validateDataTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryFloatParam() {
    float floatType = 123.34;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE float_type = ${floatType}`;
    validateDataTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryDoubleAndFloatParam() {
    float floatType = 123.34;
    float doubleType = 2139095039.0;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE float_type = ${floatType}
                                                                    and double_type = ${doubleType}`;
    validateDataTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryDecimalParam() {
    decimal decimalValue = 23.45;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE decimal_type = ${decimalValue}`;
    validateDataTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryDecimalAnFloatParam() {
    decimal decimalValue = 23.45;
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE decimal_type = ${decimalValue}
                                                                    and double_type = 2139095039.0`;
    validateDataTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeVarcharStringParam() {
    sql:VarcharValue typeVal = new ("Hello");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE string_type = ${typeVal}`;
    validateDataTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeCharStringParam() {
    sql:CharValue typeVal = new ("Hello");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE string_type = ${typeVal}`;
    validateDataTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeNCharStringParam() {
    sql:NCharValue typeVal = new ("Hello");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE string_type = ${typeVal}`;
    validateDataTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeNVarCharStringParam() {
    sql:NVarcharValue typeVal = new ("Hello");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE string_type = ${typeVal}`;
    validateDataTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeVarCharIntegerParam() {
    int intVal = 1;
    sql:NCharValue typeVal = new (intVal.toString());
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE string_type = ${typeVal}`;

    decimal decimalVal = 25.45;
    record {}? returnData = queryJdbcClient(sqlQuery);
    test:assertNotEquals(returnData, ());
    if (returnData is ()) {
        test:assertFail("Query returns ()");
    } else {
        test:assertEquals(returnData["INT_TYPE"], 1);
        test:assertEquals(returnData["LONG_TYPE"], 9372036854774807);
        test:assertEquals(returnData["DOUBLE_TYPE"], <float> 29095039);
        test:assertEquals(returnData["BOOLEAN_TYPE"], false);
        test:assertEquals(returnData["DECIMAL_TYPE"], decimalVal);
        test:assertEquals(returnData["STRING_TYPE"], "1");
        test:assertTrue(returnData["FLOAT_TYPE"] is float);
        test:assertEquals(returnData["ROW_ID"], 3);
    }
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypBooleanBooleanParam() {
    sql:BooleanValue typeVal = new (true);
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE boolean_type = ${typeVal}`;
    validateDataTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypBitIntParam() {
    sql:BitValue typeVal = new (1);
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE boolean_type = ${typeVal}`;
    validateDataTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypBitStringParam() {
    sql:BitValue typeVal = new (true);
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE boolean_type = ${typeVal}`;
    validateDataTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypBitInvalidIntParam() {
    sql:BitValue typeVal = new (12);
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE boolean_type = ${typeVal}`;
    record{}|error? returnVal = trap queryJdbcClient(sqlQuery);
    test:assertTrue(returnVal is error);
    error dbError = <error> returnVal;
    test:assertEquals(dbError.message(), "Only 1 or 0 can be passed for BitValue SQL Type, but found :12");
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryRowWitoutReturntype() returns sql:Error? {
    int rowId = 1;
    Client dbClient = check new (url = simpleParamsDb, user = user, password = password);
    sql:ParameterizedQuery sqlQuery = `SELECT * from DataTable WHERE row_id = ${rowId}`;
    record {} queryResult = check dbClient->queryRow(sqlQuery);
    validateDataTableResult(queryResult);
    sql:ParameterizedQuery sqlQuery2 = `SELECT COUNT(*) FROM DataTable`;
    int count = check dbClient->queryRow(sqlQuery2);
    check dbClient.close();
    test:assertEquals(count, 3);
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeIntIntParam() {
    sql:IntegerValue typeVal = new (2147483647);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE int_type = ${typeVal}`;
    validateNumericTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeTinyIntIntParam() {
    sql:SmallIntValue typeVal = new (127);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE tinyint_type = ${typeVal}`;
    validateNumericTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeSmallIntIntParam() {
    sql:SmallIntValue typeVal = new (32767);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE smallint_type = ${typeVal}`;
    validateNumericTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeBigIntIntParam() {
    sql:BigIntValue typeVal = new (9223372036854774807);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE bigint_type = ${typeVal}`;
    validateNumericTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeDoubleDoubleParam() {
    sql:DoubleValue typeVal = new (1234.567);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE float_type = ${typeVal}`;
    validateNumericTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeDoubleIntParam() {
    sql:DoubleValue typeVal = new (1234);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE float_type = ${typeVal}`;
    record{}? returnData = queryJdbcClient(sqlQuery);

    if (returnData is ()) {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(returnData.length(), 10);
        test:assertEquals(returnData["ID"], 2);
        test:assertEquals(returnData["REAL_TYPE"], 1234.0);
    }

}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeDoubleDecimalParam() {
    decimal decimalVal = 1234.567;
    sql:DoubleValue typeVal = new (decimalVal);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE float_type = ${typeVal}`;
    validateNumericTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeFloatDoubleParam() {
    sql:DoubleValue typeVal = new (1234.567);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE float_type = ${typeVal}`;
    validateNumericTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    enable: false,
    groups: ["query","query-simple-params"]
}
function queryTypeRealDoubleParam() {
    sql:RealValue typeVal = new (1234.567);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE real_type = ${typeVal}`;
    validateNumericTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeNumericDoubleParam() {
    sql:NumericValue typeVal = new (1234.567);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE numeric_type = ${typeVal}`;
    validateNumericTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeNumericIntParam() {
    sql:NumericValue typeVal = new (1234);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE numeric_type = ${typeVal}`;
    record{}? returnData = queryJdbcClient(sqlQuery);

    if (returnData is ()) {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(returnData.length(), 10);
        test:assertEquals(returnData["ID"], 2);
        test:assertEquals(returnData["REAL_TYPE"], 1234.0);
    }
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeNumericDecimalParam() {
    decimal decimalVal = 1234.567;
    sql:NumericValue typeVal = new (decimalVal);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE numeric_type = ${typeVal}`;
    validateNumericTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeDecimalDoubleParam() {
    sql:DecimalValue typeVal = new (1234.567);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE decimal_type = ${typeVal}`;
    validateNumericTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeDecimalDecimalParam() {
    decimal decimalVal = 1234.567;
    sql:DecimalValue typeVal = new (decimalVal);
    sql:ParameterizedQuery sqlQuery = `SELECT * from NumericTypes WHERE decimal_type = ${typeVal}`;
    validateNumericTableResult(queryJdbcClient(sqlQuery));
}


@test:Config {
    groups: ["query","query-simple-params"]
}
function queryByteArrayParam() {
    record {}|error? value = queryJdbcClient("Select * from ComplexTypes where row_id = 1");
    byte[] binaryData = <byte[]>getUntaintedData(value, "BINARY_TYPE");
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE binary_type = ${binaryData}`;
    validateComplexTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeBinaryByteParam() {
    record {}|error? value = queryJdbcClient("Select * from ComplexTypes where row_id = 1");
    byte[] binaryData = <byte[]>getUntaintedData(value, "BINARY_TYPE");
    sql:BinaryValue typeVal = new (binaryData);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE binary_type = ${typeVal}`;
    validateComplexTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeBinaryReadableByteChannelParam() {
    io:ReadableByteChannel byteChannel = getByteColumnChannel();
    sql:BinaryValue typeVal = new (byteChannel);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE binary_type = ${typeVal}`;
    validateComplexTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeVarBinaryReadableByteChannelParam() {
    io:ReadableByteChannel byteChannel = getByteColumnChannel();
    sql:VarBinaryValue typeVal = new (byteChannel);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE var_binary_type = ${typeVal}`;
    validateComplexTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeTinyBlobByteParam() {
    record {}|error? value = queryJdbcClient("Select * from ComplexTypes where row_id = 1");
    byte[] binaryData = <byte[]>getUntaintedData(value, "BLOB_TYPE");
    sql:BinaryValue typeVal = new (binaryData);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE blob_type = ${typeVal}`;
    validateComplexTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeBlobReadableByteChannelParam() {
    io:ReadableByteChannel byteChannel = getBlobColumnChannel();
    sql:BlobValue typeVal = new (byteChannel);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE blob_type = ${typeVal}`;
    validateComplexTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeClobStringParam() {
    sql:ClobValue typeVal = new ("very long text");
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE clob_type = ${typeVal}`;
    validateComplexTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeClobReadableCharChannelParam() {
    io:ReadableCharacterChannel clobChannel = getClobColumnChannel();
    sql:ClobValue typeVal = new (clobChannel);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE clob_type = ${typeVal}`;
    validateComplexTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTypeNClobReadableCharChannelParam() {
    io:ReadableCharacterChannel clobChannel = getClobColumnChannel();
    sql:NClobValue typeVal = new (clobChannel);
    sql:ParameterizedQuery sqlQuery = `SELECT * from ComplexTypes WHERE clob_type = ${typeVal}`;
    validateComplexTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryDateStringParam() {
    sql:DateValue typeVal = new ("2017-02-03");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE date_type = ${typeVal}`;
    validateDateTimeTypesTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryDateString2Param() {
    sql:DateValue typeVal = new ("2017-2-3");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE date_type = ${typeVal}`;
    validateDateTimeTypesTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryDateStringInvalidParam() {
    sql:DateValue typeVal = new ("2017/2/3");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE date_type = ${typeVal}`;
    record{}|error? result = trap queryJdbcClient(sqlQuery);
    test:assertTrue(result is error);

    if (result is sql:ApplicationError) {
        test:assertTrue(result.message().startsWith("Error while executing SQL query: SELECT * from " +
                "DateTimeTypes WHERE date_type =  ? . java.lang.IllegalArgumentException"));
    } else {
        test:assertFail("ApplicationError Error expected.");
    }
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryDateTimeRecordParam() {
    time:Date date = {year: 2017, month:2, day: 3};
    sql:DateValue typeVal = new (date);
    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE date_type = ${typeVal}`;
    validateDateTimeTypesTableResult(queryJdbcClient(sqlQuery));
}

//@test:Config {
//    groups: ["query","query-simple-params"]
//}
//function queryDateTimeRecordWithTimeZoneParam() {
//    time:Time date = checkpanic time:parse("2017-02-03T09:46:22.444-0500", "yyyy-MM-dd'T'HH:mm:ss.SSSZ");
//    sql:DateValue typeVal = new (date);
//    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE date_type = ${typeVal}`;
//    validateDateTimeTypesTableResult(queryJdbcClient(sqlQuery));
//}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTimeStringParam() {
    sql:TimeValue typeVal = new ("11:35:45");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE time_type = ${typeVal}`;
    validateDateTimeTypesTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTimeStringInvalidParam() {
    sql:TimeValue typeVal = new ("11-35-45");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE time_type = ${typeVal}`;
    record{}|error? result = trap queryJdbcClient(sqlQuery);
    test:assertTrue(result is error);

    if (result is sql:DatabaseError) {
        test:assertTrue(result.message().startsWith("Error while executing SQL query: SELECT * from DateTimeTypes " +
        "WHERE time_type =  ? . Cannot parse \"TIME\" constant \"11-35-45\""));
    } else {
        test:assertFail("DatabaseError Error expected.");
    }}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTimeTimeRecordParam() {
    time:TimeOfDay date = {hour: 11, minute: 35, second:45};
    sql:TimeValue typeVal = new (date);
    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE time_type = ${typeVal}`;
    validateDateTimeTypesTableResult(queryJdbcClient(sqlQuery));
}

//@test:Config {
//    groups: ["query","query-simple-params"]
//}
//function queryTimeTimeRecordWithTimeZoneParam() {
//    time:Time date = checkpanic time:parse("2017-02-03T11:35:45", "yyyy-MM-dd'T'HH:mm:ss");
//    sql:TimeValue typeVal = new (date);
//    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE time_type = ${typeVal}`;
//    validateDateTimeTypesTableResult(queryJdbcClient(sqlQuery));
//}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTimestampStringParam() {
    sql:TimestampValue typeVal = new ("2017-02-03 11:53:00");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE timestamp_type = ${typeVal}`;
    validateDateTimeTypesTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTimestampStringInvalidParam() {
    sql:TimestampValue typeVal = new ("2017/02/03 11:53:00");
    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE timestamp_type = ${typeVal}`;
    record{}|error? result = trap queryJdbcClient(sqlQuery);
    test:assertTrue(result is error);

    if (result is sql:DatabaseError) {
        test:assertTrue(result.message().startsWith("Error while executing SQL query: SELECT * from DateTimeTypes" +
        " WHERE timestamp_type =  ? . Cannot parse \"TIMESTAMP\" constant \"2017/02/03 11:53:00\""));
    } else {
        test:assertFail("DatabaseError Error expected.");
    }}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTimestampTimeRecordParam() {
    time:Utc date = checkpanic time:utcFromString("2017-02-03T11:53:00.00Z");
    sql:TimestampValue typeVal = new (date);
    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE timestamp_type = ${typeVal}`;
    validateDateTimeTypesTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryTimestampTimeRecordWithTimeZoneParam() {
    time:Utc date = checkpanic time:utcFromString("2017-02-03T11:53:00.00Z");
    sql:TimestampValue typeVal = new (date);
    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE timestamp_type = ${typeVal}`;
    validateDateTimeTypesTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryDateTimeTimeRecordWithTimeZoneParam() {
    time:Civil date = {year: 2017, month:2, day: 3, hour: 11, minute: 53, second:0};
    sql:DateTimeValue typeVal = new (date);
    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE datetime_type = ${typeVal}`;
    validateDateTimeTypesTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    enable: false,
    groups: ["query","query-simple-params"]
}
function queryTimestampTimeRecordWithTimeZone2Param() {
    time:Utc date = checkpanic time:utcFromString("2008-08-08T20:08:08+08:00");
    sql:TimestampValue typeVal = new (date);
    sql:ParameterizedQuery sqlQuery = `SELECT * from DateTimeTypes WHERE timestamp_type2 = ${typeVal}`;
    validateDateTimeTypesTableResult(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryArrayBasicParams() {
    int[] dataint = [1, 2, 3];
    int[] datalong = [100000000, 200000000, 300000000];
    float[] datafloat = [245.23, 5559.49, 8796.123];
    float[] datadouble = [245.23, 5559.49, 8796.123];
    decimal[] datadecimal = [245, 5559, 8796];
    string[] datastring = ["Hello", "Ballerina"];
    boolean[] databoolean = [true, false, true];
    sql:ArrayValue paraInt = new (dataint);
    sql:ArrayValue paraLong = new (datalong);
    sql:ArrayValue paraFloat = new (datafloat);
    sql:ArrayValue paraDecimal = new (datadecimal);
    sql:ArrayValue paraDouble = new (datadouble);
    sql:ArrayValue paraString = new (datastring);
    sql:ArrayValue paraBool = new (databoolean);

    sql:ParameterizedQuery sqlQuery =
    `SELECT * from ArrayTypes WHERE int_array = ${paraInt}
                                AND long_array = ${paraLong}
                                AND float_array = ${paraFloat}
                                AND double_array = ${paraDouble}
                                AND decimal_array = ${paraDecimal}
                                AND string_array = ${paraString}
                                AND boolean_array = ${paraBool}`;
    record{}? returnData = queryJdbcClient(sqlQuery);
    if (returnData is record{}) {
        test:assertEquals(returnData["INT_ARRAY"], [1, 2, 3]);
        test:assertEquals(returnData["LONG_ARRAY"], [100000000, 200000000, 300000000]);
        test:assertEquals(returnData["BOOLEAN_ARRAY"], [true, false, true]);
        test:assertEquals(returnData["STRING_ARRAY"], ["Hello", "Ballerina"]);
        test:assertNotEquals(returnData["FLOAT_ARRAY"], ());
        test:assertNotEquals(returnData["DECIMAL_ARRAY"], ());
        test:assertNotEquals(returnData["DOUBLE_ARRAY"], ());
    } else {
        test:assertFail("Empty row returned.");
    }
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryArrayBasicNullParams() {
    sql:ParameterizedQuery sqlQuery =
        `SELECT * from ArrayTypes WHERE int_array is null AND long_array is null AND float_array
         is null AND double_array is null AND decimal_array is null AND string_array is null
         AND boolean_array is null`;

    record{}? returnData = queryJdbcClient(sqlQuery);
    if (returnData is record{}) {
        test:assertEquals(returnData["INT_ARRAY"], ());
        test:assertEquals(returnData["LONG_ARRAY"], ());
        test:assertEquals(returnData["FLOAT_ARRAY"], ());
        test:assertEquals(returnData["DECIMAL_ARRAY"], ());
        test:assertEquals(returnData["DOUBLE_ARRAY"], ());
        test:assertEquals(returnData["BOOLEAN_ARRAY"], ());
        test:assertEquals(returnData["STRING_ARRAY"], ());
        test:assertEquals(returnData["BLOB_ARRAY"], ());
    } else {
        test:assertFail("Empty row returned.");
    }
}

type UUIDResult record {|
    int id;
    string data;
|};

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryUUIDParam() {
    sql:ParameterizedQuery sqlQuery = `SELECT * from UUIDTable WHERE id = 1`;
    record {}? result = queryJdbcClient(sqlQuery, resultType = UUIDResult);
    if (result is record {}) {
        UUIDResult uuid =  <UUIDResult> result;
        sql:ParameterizedQuery sqlQuery2 = `SELECT * from UUIDTable WHERE data = ${uuid.data}`;
        record{}? returnData = queryJdbcClient(sqlQuery2, resultType = UUIDResult);
        if (returnData is record {}) {
            test:assertEquals(returnData["id"], 1);
            test:assertNotEquals(returnData["data"], ());
        } else {
            test:assertFail("Querying UUID data was failure.");   
        }
    } else {
        test:assertFail("Querying UUID data was failure.");
    }
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryEnumStringParam() {
    string enumVal = "doctor";
    sql:ParameterizedQuery sqlQuery = `SELECT * from ENUMTable where enum_type= ${enumVal}`;
    validateEnumTable(queryJdbcClient(sqlQuery));
}

type EnumResult record {|
    int id;
    string enum_type;
|};

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryEnumStringParam2() {
    string enumVal = "doctor";
    sql:ParameterizedQuery sqlQuery = `SELECT * from ENUMTable where enum_type= ${enumVal}`;
    validateEnumTable(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryGeoParam() {
    sql:ParameterizedQuery sqlQuery = `SELECT * from GEOTable`;
    validateGeoTable(queryJdbcClient(sqlQuery));
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryGeoParam2() {
    string geoParam = "POINT (7 52)";
    sql:ParameterizedQuery sqlQuery = `SELECT * from GEOTable where geom = ${geoParam}`;
    validateGeoTable(queryJdbcClient(sqlQuery));
}

@test:Config {
    enable: false,
    groups: ["query","query-simple-params"]
}
function queryJsonParam() {
    sql:ParameterizedQuery sqlQuery = `SELECT * from JsonTable`;
    validateJsonTable(queryJdbcClient(sqlQuery));
}

type JsonResult record {|
    int id;
    json json_type;
|};

@test:Config {
    enable: false,
    groups: ["query","query-simple-params"]
}
function queryJsonParam2() {
    sql:ParameterizedQuery sqlQuery = `SELECT * from JsonTable`;
    record{}? returnData = queryJdbcClient(sqlQuery, resultType = JsonResult);
    if (returnData is ()) {
        test:assertFail("Query returns nil result");
    } else {
        JsonResult expectedData = {
            id: 1,
            json_type: {
                id: 100,
                name: "Joe",
                groups: [2,5]
            }
        };
        test:assertEquals(returnData, expectedData);
    }
}

@test:Config {
    enable: false,
    groups: ["query","query-simple-params"]
}
function queryJsonParam3() {
    json jsonType = {"id": 100, "name": "Joe", "groups": [2, 5]};
    int id = 100;
    string name = "Joe";
    string arrayVal = "[2, 5]";
    sql:ParameterizedQuery sqlQuery =
            `SELECT * from JsonTable where json_type=JSON_OBJECT('id': ${id}, 'name':${name}, 'groups': ${arrayVal}FORMAT JSON)`;
    record{}? returnData = queryJdbcClient(sqlQuery, resultType = JsonResult);

    if (returnData is ()) {
        test:assertFail("Query returns nil result");
    } else {
        JsonResult expectedData = {
            id: 1,
            json_type: {
                id: 100,
                name: "Joe",
                groups: [2,5]
            }
        };
        test:assertEquals(returnData, expectedData);
    }
}

@test:Config {
    groups: ["query","query-simple-params"]
}
function queryIntervalParam() {
    sql:ParameterizedQuery sqlQuery = `SELECT * from IntervalTable`;
    record{}? returnData = queryJdbcClient(sqlQuery);
    if (returnData is ()) {
        test:assertFail("Empty row returned.");
    } else {
        test:assertEquals(returnData["ID"], 1);
        test:assertEquals(returnData["INTERVAL_TYPE"], "INTERVAL '2:00' HOUR TO MINUTE");
    }
}

function queryJdbcClient(string|sql:ParameterizedQuery sqlQuery,
 typedesc<record {}>? resultType = ())
returns record {}? {
    Client dbClient = checkpanic new (url = simpleParamsDb, user = user, password = password);
    stream<record {}, error?> streamData;
    if resultType is () {
        streamData = dbClient->query(sqlQuery);
    } else {
        streamData = dbClient->query(sqlQuery, resultType);
    }
    record {|record {} value;|}? data = checkpanic streamData.next();
    checkpanic streamData.close();
    record {}? value = data?.value;
    checkpanic dbClient.close();
    return value;
}

isolated function validateDataTableResult(record{}? returnData) {
    decimal decimalVal = 23.45;
    if (returnData is ()) {
        test:assertFail("Empty row returned.");
    } else {
        test:assertEquals(returnData["ROW_ID"], 1);
        test:assertEquals(returnData["INT_TYPE"], 1);
        test:assertEquals(returnData["LONG_TYPE"], 9223372036854774807);
        test:assertEquals(returnData["DOUBLE_TYPE"], <float> 2139095039);
        test:assertEquals(returnData["BOOLEAN_TYPE"], true);
        test:assertEquals(returnData["DECIMAL_TYPE"], decimalVal);
        test:assertEquals(returnData["STRING_TYPE"], "Hello");
        test:assertTrue(returnData["FLOAT_TYPE"] is float);   
    } 
}

isolated function validateNumericTableResult(record{}? returnData) {
    if (returnData is ()) {
        test:assertFail("Empty row returned.");
    } else {
        test:assertEquals(returnData["ID"], 1);
        test:assertEquals(returnData["INT_TYPE"], 2147483647);
        test:assertEquals(returnData["BIGINT_TYPE"], 9223372036854774807);
        test:assertEquals(returnData["SMALLINT_TYPE"], 32767);
        test:assertEquals(returnData["TINYINT_TYPE"], 127);
        test:assertEquals(returnData["BIT_TYPE"], true);
        test:assertTrue(returnData["REAL_TYPE"] is float);
        test:assertTrue(returnData["DECIMAL_TYPE"] is decimal);
        test:assertTrue(returnData["NUMERIC_TYPE"] is decimal);
        test:assertTrue(returnData["FLOAT_TYPE"] is float);   
    }
}

isolated function validateComplexTableResult(record{}? returnData) {
    if (returnData is ()) {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(returnData.length(), 5);
        test:assertEquals(returnData["ROW_ID"], 1);
        test:assertEquals(returnData["CLOB_TYPE"], "very long text");
    }
}

isolated function validateDateTimeTypesTableResult(record{}? returnData) {
    if (returnData is ()) {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(returnData.length(), 5);
        test:assertEquals(returnData["ROW_ID"], 1);
        test:assertTrue(returnData["DATE_TYPE"].toString().startsWith("2017-02-03"));
    }
}

isolated function validateEnumTable(record{}? returnData) {
    if (returnData is ()) {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(returnData.length(), 2);
        test:assertEquals(returnData["ID"], 1);
        test:assertEquals(returnData["ENUM_TYPE"].toString(), "doctor");
    }
}

isolated function validateGeoTable(record{}? returnData) {
    if (returnData is ()) {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(returnData.length(), 2);
        test:assertEquals(returnData["ID"], 1);
        test:assertEquals(returnData["GEOM"].toString(), "POINT (7 52)");
    }
}

isolated function validateJsonTable(record{}? returnData) {
    if (returnData is ()) {
        test:assertFail("Returned data is nil");
    } else {
        test:assertEquals(returnData.length(), 2);
        test:assertEquals(returnData["ID"], 1);
        test:assertEquals(returnData["JSON_TYPE"], "{\"id\": 100, \"name\": \"Joe\", \"groups\": \"[2,5]\"}");
    }
}
