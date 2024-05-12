from pyspark.sql import SparkSession
from pyspark import SparkConf
from pyspark.sql.types import *
from pyspark.sql.functions import *

from contextlib import contextmanager
import random
import os
import pandas as pd
from datetime import date, timedelta
import itertools

APP_NAME = os.environ["app_name"]


@contextmanager
def get_spark_session(app_name: str, enable_broadcast: bool = True):
    conf = SparkConf()
    conf.set("spark.sql.session.timeZone", "Europe/Berlin")
    if not enable_broadcast:
        conf.set("spark.sql.autoBroadcastJoinThreshold", -1)

    spark = SparkSession \
        .builder \
        .config(conf=conf) \
        .appName(app_name) \
        .getOrCreate()

    # also get the spark context
    sc = spark.sparkContext
    # change the log level to warning to see less output
    sc.setLogLevel('ERROR')

    try:
        yield spark
    finally:
        spark.stop()


def get_sample_df(spark, cols: list):
    if len(cols) == 0:
        return

    column_names = ["col" + str(x) for x in range(len(cols[0]))]
    return spark.createDataFrame(cols, column_names)


def broadcast_example(app_name: str, enable_broadcast: bool, auto: bool = False):
    with get_spark_session(app_name, enable_broadcast) as spark:
        small_df = get_sample_df(spark, list(
            zip(range(0, 100, 10), random.sample(range(100), 10), random.sample(range(100), 10))))
        big_df = get_sample_df(spark, list(
            zip(range(10000), random.sample(range(10000), 10000), random.sample(range(10000), 10000))))

        if auto or not enable_broadcast:
            joined_df_without_broadcast = big_df.join(small_df, big_df.col1 == small_df.col1, "left")
            joined_df_without_broadcast.show()

        if enable_broadcast:
            joined_df_with_broadcast = big_df.join(broadcast(small_df), big_df.col1 == small_df.col1, "left")
            joined_df_with_broadcast.show()


def cache_example(app_name: str):
    with (get_spark_session(app_name) as spark):
        src_df = spark.read.option("header", True).csv("s3a://data/bike-sharing/raw/day.csv")
        transformed_df = None
        if app_name.startswith("without_cache"):
            transformed_df = src_df \
                .groupBy(col("season"), col("workingday")) \
                .agg(avg(col("temp")).alias("avg_temp")) \
                .withColumn('orders', floor(100 * rand(seed=1234)))
        else:
            transformed_df = src_df \
                .groupBy(col("season"), col("workingday")) \
                .agg(avg(col("temp")).alias("avg_temp")) \
                .withColumn("orders", floor(100 * rand(seed=1234))) \
                .persist()

        season_df = spark.createDataFrame([(1, "spring"), (2, "summer"), (3, "fall"), (4, "winter")],
                                          ["season", "season_name"])
        dates = [date(2021, 1, 1) + timedelta(days=x) for x in range(0, 365)]
        dates_df = spark.createDataFrame(dates, DateType()).toDF('day')

        df_count = transformed_df.count()
        joined_df = transformed_df \
            .join(season_df, "season", "left") \
            .crossJoin(dates_df)

        if app_name.endswith("show"):
            joined_df.show()
        else:
            joined_df.count()

        if app_name == "with_cache":
            src_df.unpersist()


def repartition_example(app_name: str):
    with get_spark_session(app_name) as spark:
        src_df = spark.read.option("header", True).csv("s3a://data/cars/USA_cars_datasets.csv")
        year_df = spark.createDataFrame(list(itertools.product(list(range(1973, 2021)), ["A", "B"])), ["year", "letter"])
        src_df = src_df.filter(col("year").isin(list(range(2015, 2021))))

        if app_name == "with_repartition":
            rp_src_df = src_df.repartition(5, "year")
            rp_joined_df = rp_src_df.join(year_df, "year", "left")
            rp_joined_df.show()
        else:
            joined_df = src_df.join(year_df, "year", "left")
            joined_df.show()


if __name__ == "__main__":
    random.seed(1000)

    if APP_NAME == "with_broadcast":
        broadcast_example(APP_NAME, enable_broadcast=True)
    elif APP_NAME == "without_broadcast":
        broadcast_example(APP_NAME, enable_broadcast=False)
    elif APP_NAME == "auto_broadcast":
        broadcast_example(APP_NAME, enable_broadcast=True, auto=True)
    elif APP_NAME == "without_cache_count":
        cache_example(APP_NAME)
    elif APP_NAME == "with_cache_count":
        cache_example(APP_NAME)
    elif APP_NAME == "without_cache_show":
        cache_example(APP_NAME)
    elif APP_NAME == "with_cache_show":
        cache_example(APP_NAME)
    elif APP_NAME == "with_repartition":
        repartition_example(APP_NAME)
    elif APP_NAME == "without_repartition":
        repartition_example(APP_NAME)
    else:
        raise Exception("There doesn't exist an example for '{}'".format(APP_NAME))
