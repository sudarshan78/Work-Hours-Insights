from pyspark.sql import SparkSession
from pyspark.sql.functions import col, regexp_extract, expr,from_json, coalesce, length, when, lit, max,min,count,to_json,struct,from_json,to_date,to_timestamp
from pyspark.sql import DataFrame
from pyspark.sql.types import StructType, StructField, StringType

spark = (
    SparkSession.builder
    .appName("whip")
    .config("spark.ui.showConsoleProgress", "false")    
    .config("spark.driver.extraJavaOptions",
                "-Dlog4j.configurationFile=file:///C:/pysparkloger/log4j2.properties")
    .config("spark.executor.extraJavaOptions",
                "-Dlog4j.configurationFile=file:///C:/pysparkloger/log4j2.properties")
    .getOrCreate()
) 
def readjson():

  df=spark.read.text("C:\DE\Projects\WHIP Own project\Data\chennai_swipe_dataset\it_dataset_chennai\swipe_records.json")
  return df

def jsontostring(df: DataFrame):

  schema = StructType([ 
    StructField("emp_id", StringType(), True),
    StructField("event_ts", StringType(), True),
    StructField("swipe_type", StringType(), True),
    StructField("office_id", StringType(), True)
    ])
  df2=df.withColumn("value",from_json("value",schema)).select("value.*")
  return df2

def transform(df: DataFrame):

  df=df.withColumn("eventdate",to_date(col("event_ts")))
  df1=df.filter(df.swipe_type=="IN").groupBy("emp_id","eventdate").agg(min(col("event_ts")).alias("start_time")).withColumnRenamed("emp_id", "empId").withColumnRenamed("eventdate","datevent")
  df2=df.filter(df.swipe_type=="OUT").groupBy("emp_id","eventdate").agg(max(col("event_ts")).alias("end_time"))
  finjoin=df1.join(df2,((df1.empId==df2.emp_id) & (df1.datevent==df2.eventdate )),"inner")
  df=finjoin.withColumn("total_hours",expr("timestampdiff(hour,to_timestamp(start_time),to_timestamp(end_time))"))
  dfin=df.select("empId","eventdate","total_hours")
  
  dfin.withColumn("empid", col("empid").cast("string"))\
      .withColumn("total_hours", col("total_hours").cast("string"))\
      .withColumn("eventdate", col("eventdate").cast("string"))

  return dfin

def processCuratedData():
  raw=readjson()
  jas=jsontostring(raw)
  curated=transform(jas)
  curated.show()
  return curated
cureate=processCuratedData()

path="hdfs://localhost:9000/WHIP/Curated3/"
cureate.write.mode("append")\
    .option("header", True).parquet(path)
