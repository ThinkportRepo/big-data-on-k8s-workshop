from pyspark import SparkContext, SparkConf
from pyspark.sql import SparkSession
from pyspark.sql import SQLContext
from pyspark.sql.types import *
import pyspark.sql.functions as f

import json


# UDF to parse array stored as string using JSON
def parse_array_from_string(x):
    
    if x is not None:
        res = json.loads(x)
    else:
        res =[None]
    return res

hashtag_array = f.udf(parse_array_from_string, ArrayType(StringType()))


spark = SparkSession\
    .builder\
    .config(conf=conf) \
    .config('spark.sql.session.timeZone', 'Europe/Berlin') \
    .appName(appName)\
    .getOrCreate()


df = (spark
      .readStream
      .format("kafka")
      .option("kafka.bootstrap.servers", "kafka-cp-kafka.kafka.svc.cluster.local:9092")
      .option("subscribe", "twitter-json")
      .option("startingOffsets", "earliest")
      .load()
     )

df.printSchema()

df2 = (df
       # take only the value as String
       .selectExpr("CAST(value AS STRING)")
       # take only required fields
       .select(
           f.get_json_object(f.col("value"),"$.payload.CreatedAt").cast("long").alias("tweet_created"),
           f.get_json_object(f.col("value"),"$.payload.Id").cast("long").alias("tweet_id"),
           f.get_json_object(f.col("value"),"$.payload.Lang").alias("tweet_language"),
           f.get_json_object(f.col("value"),"$.payload.HashtagEntities[*].Text").alias("hashtag"),
           f.get_json_object(f.col("value"),"$.payload.Place.Country").alias("country"),
           f.get_json_object(f.col("value"),"$.payload.Place.CountryCode").alias("country_code"),
           f.get_json_object(f.col("value"),"$.payload.User.ScreenName").alias("user"),
           f.get_json_object(f.col("value"),"$.payload.User.Lang").alias("user_language"),   
           f.get_json_object(f.col("value"),"$.payload.User.Location").alias("user_location"),
           f.get_json_object(f.col("value"),"$.payload.User.StatusesCount").cast("int").alias("statuses_count"),
           f.get_json_object(f.col("value"),"$.payload.RetweetCount").cast("int").alias("retweet_count"),
           f.get_json_object(f.col("value"),"$.payload.Text").alias("tweet_text")    
       )
       # convert to timestamp (cast string to long --> convert from number to timestamp)
       .withColumn("tweet_created",f.from_unixtime(f.col("tweet_created")/1000))
       # using udf function to convert string to json array
       .withColumn("hashtag",hashtag_array(f.col("hashtag")))
     )

df2.printSchema()


kafka_write=(df2
             .selectExpr("to_json(struct(*)) AS value")
             .writeStream
             .format("kafka")
             .outputMode("append")
             .option("kafka.bootstrap.servers", "kafka-cp-kafka.kafka.svc.cluster.local:9092")
             .option("topic", "twitter-table")
             .option("checkpointLocation", "/opt/spark/work-dir")
             .start()
             .awaitTermination()
            )