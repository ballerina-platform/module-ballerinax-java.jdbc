CREATE TABLE DataTable(
  row_id       INTEGER,
  int_type     INTEGER,
  long_type    BIGINT,
  float_type   FLOAT,
  double_type  DOUBLE,
  boolean_type BOOLEAN,
  string_type  VARCHAR(50),
  decimal_type DECIMAL(20, 2),
  PRIMARY KEY (row_id)
);

INSERT INTO DataTable (row_id, int_type, long_type, float_type, double_type, boolean_type, string_type, decimal_type)
  VALUES(1, 1, 9223372036854774807, 123.34, 2139095039, TRUE, 'Hello', 23.45);

INSERT INTO DataTable (row_id) VALUES (2);

INSERT INTO DataTable (row_id, int_type, long_type, float_type, double_type, boolean_type, string_type, decimal_type)
  VALUES(3, 1, 9372036854774807, 124.34, 29095039, false, '1', 25.45);

CREATE TABLE ComplexTypes(
  row_id         INT NOT NULL,
  blob_type      BLOB(1024),
  clob_type      CLOB(1024),
  binary_type  BINARY(27),
  var_binary_type VARBINARY(27),
  PRIMARY KEY (row_id)
);

INSERT INTO ComplexTypes (row_id, blob_type, clob_type, binary_type, var_binary_type) VALUES
  (1, X'77736F322062616C6C6572696E6120626C6F6220746573742E', CONVERT('very long text', CLOB),
  X'77736F322062616C6C6572696E612062696E61727920746573742E', X'77736F322062616C6C6572696E612062696E61727920746573742E');

INSERT INTO ComplexTypes (row_id, blob_type, clob_type, binary_type, var_binary_type) VALUES
  (2, X'77736F322062616C6C6572696E6120626C6F6220746573742E', CONVERT('very long text', CLOB),
  X'77736F322062616C6C6572696E612062696E61727920746573742E', X'77736F322062616C6C6572696E612062696E61727920746573742E');

INSERT INTO ComplexTypes (row_id, blob_type, clob_type, binary_type, var_binary_type) VALUES
  (3, null, null, null, null);

CREATE TABLE NumericTypes (
   id INT AUTO_INCREMENT,
   int_type INT,
   bigint_type BIGINT,
   smallint_type SMALLINT,
   tinyint_type TINYINT  ,
   bit_type BIT ,
   decimal_type DECIMAL(10,3) ,
   numeric_type NUMERIC(10,3),
   float_type FLOAT ,
   real_type REAL ,
   PRIMARY KEY (id)
);

INSERT INTO NumericTypes (id, int_type, bigint_type, smallint_type, tinyint_type, bit_type, decimal_type, numeric_type,
    float_type, real_type) VALUES (1, 2147483647, 9223372036854774807, 32767, 127, 1, 1234.567, 1234.567, 1234.567,
    1234.567);

INSERT INTO NumericTypes (id, int_type, bigint_type, smallint_type, tinyint_type, bit_type, decimal_type, numeric_type,
    float_type, real_type) VALUES (2, 2147483647, 9223372036854774807, 32767, 127, 1, 1234, 1234, 1234,
    1234);

CREATE TABLE DateTimeTypes(
  row_id         INT,
  date_type      DATE,
  time_type      TIME,
  timestamp_type TIMESTAMP,
  datetime_type  DATETIME,
  PRIMARY KEY (row_id)
);

INSERT INTO DateTimeTypes (row_id, date_type, time_type, datetime_type, timestamp_type) VALUES
  (1,'2017-02-03', '11:35:45', '2017-02-03 11:53:00', '2017-02-03 11:53:00');

CREATE TABLE ArrayTypes(
  row_id        INT AUTO_INCREMENT,
  int_array     INT ARRAY,
  long_array    BIGINT ARRAY,
  float_array   FLOAT ARRAY,
  double_array  DOUBLE ARRAY,
  decimal_array DECIMAL ARRAY,
  boolean_array BOOLEAN ARRAY,
  string_array  VARCHAR ARRAY,
  blob_array    BLOB ARRAY,
  PRIMARY KEY (row_id)
);

INSERT INTO ArrayTypes (row_id, int_array, long_array, float_array, double_array, decimal_array, boolean_array, string_array, blob_array)
  VALUES (1, ARRAY [1, 2, 3], ARRAY [100000000, 200000000, 300000000], ARRAY[245.23, 5559.49, 8796.123],
  ARRAY[245.23, 5559.49, 8796.123], ARRAY[245.0, 5559.0, 8796.0], ARRAY[TRUE, FALSE, TRUE], ARRAY['Hello', 'Ballerina'],
  ARRAY[X'77736F322062616C6C6572696E6120626C6F6220746573742E']);

INSERT INTO ArrayTypes (row_id, int_array, long_array, float_array, double_array,  decimal_array, boolean_array, string_array, blob_array)
  VALUES (2, ARRAY[NULL, 2, 3], ARRAY[100000000, NULL, 300000000], ARRAY[NULL, 5559.49, NULL],
  ARRAY[NULL, NULL, 8796.123], ARRAY[NULL, NULL, 8796], ARRAY[NULL , NULL, TRUE], ARRAY[NULL, 'Ballerina'],
  ARRAY[NULL, X'77736F322062616C6C6572696E6120626C6F6220746573742E']);

INSERT INTO ArrayTypes (row_id, int_array, long_array, float_array, double_array, decimal_array, boolean_array, string_array, blob_array)
  VALUES (3, NULL, NULL, NULL, NULL,NULL , NULL, NULL, NULL);

INSERT INTO ArrayTypes (row_id, int_array, long_array, float_array, double_array, decimal_array, boolean_array, string_array, blob_array)
  VALUES (4, ARRAY[NULL, NULL, NULL], ARRAY[NULL, NULL, NULL], ARRAY[NULL, NULL, NULL],
  ARRAY[NULL, NULL, NULL], ARRAY[NULL , NULL, NULL], ARRAY[NULL , NULL, NULL], ARRAY[NULL, NULL], ARRAY[NULL, NULL]);

CREATE TABLE IF NOT EXISTS ArrayTypes2 (
  row_id INT NOT NULL,
  smallint_array SMALLINT ARRAY,
  int_array INT ARRAY,
  long_array BIGINT ARRAY,
  float_array FLOAT ARRAY,
  double_array DOUBLE ARRAY,
  real_array REAL ARRAY,
  decimal_array  DECIMAL ARRAY,
  numeric_array NUMBER ARRAY,
  boolean_array BOOLEAN ARRAY,
  bit_array BIT ARRAY,
  char_array CHAR ARRAY,
  varchar_array VARCHAR ARRAY,
  binary_array BINARY(30) ARRAY,
  varbinary_array VARBINARY ARRAY,
  nvarchar_array NVARCHAR ARRAY,
  string_array VARCHAR ARRAY,
  blob_array BLOB ARRAY,
  date_array DATE ARRAY,
  time_array TIME ARRAY,
  datetime_array DATETIME ARRAY,
  timestamp_array TIMESTAMP ARRAY,
  time_tz_array TIME WITH TIME ZONE ARRAY,
  timestamp_tz_array TIMESTAMP WITH TIME ZONE ARRAY,
  PRIMARY KEY (row_id)
);

INSERT INTO ArrayTypes2 (row_id, int_array, long_array, float_array, double_array, real_array, decimal_array, boolean_array, varchar_array, date_array, time_array, datetime_array, timestamp_array, time_tz_array, timestamp_tz_array) 
VALUES (1, ARRAY[1, 2, 3], ARRAY[100000000, 200000000, 300000000], ARRAY[245.23, 5559.49, 8796.123], ARRAY[245.23, 5559.49, 8796.123], ARRAY[245.12, 5559.12, 8796.92], ARRAY[245.12, 5559.12, 8796.92], ARRAY[TRUE, FALSE, TRUE], ARRAY['Hello', 'Ballerina'], ARRAY['2017-02-03', '2017-02-03'], ARRAY['11:22:42', '12:23:45'], ARRAY['2017-02-03 11:53:00', '2019-04-05 12:33:10'], ARRAY['2017-02-03 11:53:00', '2019-04-05 12:33:10'], ARRAY['16:33:55+6:30', '16:33:55+4:30'], ARRAY['2017-01-25 16:33:55-8:00', '2017-01-25 16:33:55-5:00']);

INSERT INTO ArrayTypes2 (row_id, int_array, long_array, float_array, double_array, real_array, decimal_array, boolean_array, char_array, date_array, time_array, datetime_array, timestamp_array, time_tz_array, timestamp_tz_array) VALUES (2, ARRAY[NULL, NULL], ARRAY[NULL, NULL], ARRAY[NULL, NULL], ARRAY[NULL, NULL], ARRAY[NULL, NULL], ARRAY[NULL, NULL], ARRAY[NULL, NULL], ARRAY[NULL, NULL], ARRAY[NULL, NULL], ARRAY[NULL, NULL], ARRAY[NULL, NULL], ARRAY[NULL, NULL], ARRAY[NULL, NULL], ARRAY[NULL, NULL]);
