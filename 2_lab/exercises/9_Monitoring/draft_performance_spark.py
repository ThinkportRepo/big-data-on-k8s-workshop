
Ingress für SparkUI von Jupyter
Service and ServiceMonitor für Juypter



nRow = 4
nCol = 4
numPartitions = 4 #(sc.defaultParalellism)
seed = 7;
rdd1 = RandomRDDs.normalVectorRDD(spark, nRow, nCol, numPartitions, seed);
seed = 3;
rdd2 = RandomRDDs.normalVectorRDD(spark, nRow, nCol, numPartitions, seed);

# convert each tuple in the rdd to a row
randomNumberRDD1=rdd1.map(lambda: x:Row(A=float(x[0]),B=float(x[1]),C=float(x[2]),D=float(x[3])))
randomNumberRDD2=rdd2.map(lambda: x:Row(E=float(x[0]),F=float(x[1]),C=float(x[2]),D=float(x[3])))

# create dataframe from rdd
schemaRandomNumberDF1=spark.createDataFrame(randomNumberRDD1)
schemaRandomNumberDF2=spark.createDataFrame(randomNumberRDD2)

crossDF=schemaRandomNumberDF1.crossJoin(schemaRandomNumberDF2)
print("Count Cross Join",crossDF.count())
# aggregate
results = schemaRandomNumberDF1.groupBy("A").agg(f.max("B"),f.sum("C"))
results.shown(n=100)