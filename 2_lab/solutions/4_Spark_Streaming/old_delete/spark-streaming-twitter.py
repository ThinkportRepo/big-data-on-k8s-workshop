##### Spark Streaming Ap ##################################################
'''
* read binary data from Kafka topic
* convert data to valid json
* select some attributes and convert to tabular dataframe
* clean up data
* write data back to a new Kafka topic
'''
####################################################################
from pyspark import SparkContext, SparkConf
from pyspark.sql import SparkSession
from pyspark.sql import SQLContext
from pyspark.sql.types import *
import pyspark.sql.functions as f

import json
import os

# get application name from environment variables
APP_NAME=os.environ["app_name"] 
# Set Kafka configs
KAFKA_SERVER="kafka-cp-kafka.kafka.svc.cluster.local:9092"
KAFKA_SOURCE_TOPIC="twitter-json"
KAFKA_TARGET_TOPIC="twitter-table"



###########################################################
# Python UDF (user defined function) to parse array stored as string using JSON
###########################################################
def parse_array_from_string(x):
    # always handel the case of Null values
    if x is not None:
        # convert to json object
        res = json.loads(x)
    else:
        res =[None]
    return res


###########################################################
# Main function
###########################################################
if __name__ == "__main__":
    """
        Main function for the Streaming Job
    """
    
    # create Spark session
    spark = (SparkSession
        .builder
        .appName(APP_NAME)
        .getOrCreate()
    )

    ################################################
    # read data stream from Kafka 
    ################################################
    df_step_1 = (spark
        .readStream
        .format("kafka")
        .option("kafka.bootstrap.servers",KAFKA_SERVER )
        .option("subscribe",KAFKA_SOURCE_TOPIC)
        .option("startingOffsets", "earliest")
        .load()
        )

    print("#########################################")
    print("raw schema from kafka topic")
    df_step_1.printSchema()

    ################################################
    # take value and convert into String
    ################################################
    df_step_2 = (df_step_1
       # take only the value and cast as string
       .selectExpr("CAST(value AS STRING)")
    )

    ################################################
    # select a subset of fields
    ################################################
    df_step_3 = (df_step_2
       .select(
           f.get_json_object(f.col("value"),"$.payload.CreatedAt").alias("tweet_created"),
           f.get_json_object(f.col("value"),"$.payload.Id").alias("tweet_id"),
           f.get_json_object(f.col("value"),"$.payload.Lang").alias("tweet_language"),
           f.get_json_object(f.col("value"),"$.payload.HashtagEntities[*].Text").alias("hashtag"),
           f.get_json_object(f.col("value"),"$.payload.Place.Country").alias("country"),
           f.get_json_object(f.col("value"),"$.payload.Place.CountryCode").alias("country_code"),
           f.get_json_object(f.col("value"),"$.payload.User.ScreenName").alias("user"),
           f.get_json_object(f.col("value"),"$.payload.User.Lang").alias("user_language"),   
           f.get_json_object(f.col("value"),"$.payload.User.Location").alias("user_location"),
           f.get_json_object(f.col("value"),"$.payload.User.StatusesCount").alias("statuses_count"),
           f.get_json_object(f.col("value"),"$.payload.RetweetCount").alias("retweet_count"),
           f.get_json_object(f.col("value"),"$.payload.Text").alias("tweet_text")    
       ) 

    )

    ################################################
    # cast and convert into correct data types
    ################################################

    # register Python function as Spark UDF
    hashtag_array = f.udf(parse_array_from_string, ArrayType(StringType()))

    df_step_4 = (df_step_3
        # cast to correct data types 
        # convert to timestamp (cast string to long --> convert from number to timestamp)
        .withColumn("tweet_created",f.from_unixtime((f.col("tweet_created").cast("long"))/1000))
        .withColumn("tweet_id",f.col("tweet_id").cast("long"))
        # using udf function to convert string to json array
        .withColumn("hashtag",hashtag_array(f.col("hashtag")))
        .withColumn("statuses_count",f.col("statuses_count").cast("int"))
        .withColumn("retweet_count",f.col("retweet_count").cast("int"))

    )
    
    print("#########################################")
    print("final schema of transformed data")
    df_step_4.printSchema()



    df_step_5=(df_step_4
        .selectExpr("to_json(struct(*)) AS value")
        .writeStream
        .format("kafka")
        .outputMode("append")
        .option("kafka.bootstrap.servers", "kafka-cp-kafka.kafka.svc.cluster.local:9092")
        .option("topic", KAFKA_TARGET_TOPIC)
        .option("checkpointLocation", "/opt/spark/work-dir/kafka-checkpoint")
        .start()
        .awaitTermination()
    )

