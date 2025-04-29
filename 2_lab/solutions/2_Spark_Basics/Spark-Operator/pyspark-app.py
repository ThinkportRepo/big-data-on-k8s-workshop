##### simple tests ##################################################
'''
* test create Spark Context and Spark Session
* test serialisation of data to rdd
* test serialisation of data to df
* test basic sparkSQL functions and aggregations
* test if data can be collected to master (show, count, collect)
* test if data can be read from s3 bucket
'''
####################################################################
from pyspark import SparkContext, SparkConf
from pyspark.sql import SparkSession
from pyspark.sql import SQLContext
from pyspark.sql.types import *
import pyspark.sql.functions as f


if __name__ == "__main__":
    """
        Usage: basic_test
    """
    spark = SparkSession\
        .builder\
        .appName("spark-simple-app")\
        .getOrCreate()

    sc=spark.sparkContext

    sc.setLogLevel('WARN')
    
    print("-----------------------------------------------------")
    print("Spark App starting ...")
    print("-----------------------------------------------------")
    ##################################################################
    # create simple rdd
    ##################################################################


    print("++ create RDD and print sum")
    print("################################################")
    rdd = sc.parallelize(range(100000000))
    print(rdd.sum())
      
    ##################################################################
    # create simple dataframe
    ##################################################################
    simpleData = [
        ("James","Sales","NY",90000,34,10000),
        ("Michael","Sales","NY",86000,56,20000),
        ("Robert","Sales","CA",81000,30,23000),
        ("Maria","Finance","CA",90000,24,23000),
        ("Raman","Finance","CA",99000,40,24000),
        ("Scott","Finance","NY",83000,36,19000),
        ("Jen","Finance","NY",79000,53,15000),
        ("Jeff","Marketing","CA",80000,25,18000),
        ("Kumar","Marketing","NY",91000,50,21000)
        ]

    schema = ["employee_name","department","state","salary","age","bonus"]
    df = spark.createDataFrame(data=simpleData, schema = schema)
    print("++ create new dataframe and show schema and data")
    print("################################################")

    df.printSchema()
    df.show(truncate=False)

    print("++ show distinct departments")
    print("################################################")
    df.select("department").distinct().show()


    print("++ sum salery by department")
    print("################################################")
    df.groupBy("department").sum("salary").show(truncate=False)


    print("++ run complex aggregation")
    print("################################################")
    result=(df
        .groupBy("department")
        .agg(
            f.sum("salary").alias("sum_salary"),
            f.avg("salary").alias("avg_salary"),
            f.sum("bonus").alias("sum_bonus"),
            f.max("bonus").alias("max_bonus")
        )
    )
    result.show(truncate=False)

    print("################################################")
    print("Write csv file to s3")
    result.write.mode("overwrite").format("csv").save("s3a://test-alex/salery_by_department")

    print("-----------------------------------------------------")
    print("Spark App completed")
    print("-----------------------------------------------------")
    spark.stop()
