from pyspark import SparkContext, SparkConf
from pyspark.sql import SparkSession
from pyspark.sql import SQLContext
from pyspark.sql.types import *
import pyspark.sql.functions as f

import json
import os


# get application name from environment variables
APP_NAME=os.environ["app_name"] 


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

# read stream from topic
df_step_1 = (spark
      .readStream
      .format("kafka")
      .option("kafka.bootstrap.servers", "kafka-cp-kafka.kafka.svc.cluster.local:9092")
      .option("subscribe", "twitter-table")
      .option("startingOffsets", "earliest")
      .load()
     )

df_step_1.printSchema()


# schema des JSON Streams definieren
jsonSchema=StructType([
    StructField('tweet_id', StringType(), False),
    StructField('created_at', TimestampType(), False),
    StructField('tweet_message', StringType(), True),
    StructField('user_name', StringType(), True),
    StructField('user_location', StringType(), True),
    StructField('user_follower_count', IntegerType(), True),
    StructField('user_friends_count', IntegerType(), True),
    StructField('retweet_count', IntegerType(), True),
    StructField('language', StringType(), True),
    StructField('hashtags', ArrayType(StringType(), True), True)
])

df_step_2= (df_step_1
            # cast binary to string and string with json schema to json object
            .select(f.from_json(f.col("value").cast("string"),jsonSchema).alias("t"))
            # un nest via
            .select("t.*")
           )

df_step_2.printSchema()


s3_write_avro=(df_step_2
          .writeStream
          .format("avro")
          .outputMode("append")
          .option("path", "s3a://twitter/avro")
          .option("checkpointLocation", "/opt/spark/work-dir/")
          .trigger(processingTime='10 seconds')
          .start()
          .awaitTermination()
         )