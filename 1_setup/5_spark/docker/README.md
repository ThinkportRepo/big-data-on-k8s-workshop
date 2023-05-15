# Build Spark Images

## Build modified Spark Image

to build run

```
docker build -t thinkportgmbh/workshops:spark-3.3.1 -f Dockerfile.hive .
```

to push run

```
docker push  thinkportgmbh/workshops:spark-3.3.1
```

to build and push the arm64 image on a Mac Book with m1 chip (arm64) build the image via crossbuild

```
docker buildx build --push --platform linux/amd64,linux/arm64 --tag thinkportgmbh/workshops:spark-3.3.1  -f Dockerfile.spark .
```

## Official Docker image (since 2022)

as of 2022 there is now an official spark image available for each version

```
docker pull apache/spark-py:3.3.1
```

## Find all correkt Maven dependencies

The best way to get all the correct dependencies is either to use regular spark submit or the following online tool
We need the follwong dependecies
Check first Spark AND Scala Version that was downloaded
For Spark 3.3.1 default is Scala 2.12 and default Hadoop is 3.x

### Delta.io

The dependency matrix shows which Delta Version can be used for which Spark Version.
https://docs.delta.io/latest/releases.html

Go to maven (https://mvnrepository.com/artifact/io.delta/delta-core_2.12/2.1.1) search the jar and copy all dependency xmls

```
<!-- https://mvnrepository.com/artifact/io.delta/delta-core -->
<dependency>
    <groupId>io.delta</groupId>
    <artifactId>delta-core_2.12</artifactId>
    <version>2.1.1</version>
</dependency>

```

### Postgres JDBC

The latest jdbc driver should work

```
<!-- https://mvnrepository.com/artifact/org.postgresql/postgresql -->
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <version>42.5.0</version>
</dependency>
```

### s3 Driver / Cloud Storage Connectors

As Spark states on https://spark.apache.org/docs/latest/cloud-integration.html
Use the following dependency to download all
connectors

```
 <dependency>
    <groupId>org.apache.spark</groupId>
    <artifactId>spark-hadoop-cloud_2.12</artifactId>
    <version>${spark.version}</version>
    <scope>provided</scope>
  </dependency>
```

### Kafka connector

In order to connect to Spark we need to to add the Kafka dependencies

```
 <dependency>
    <groupId>org.apache.spark</groupId>
    <artifactId>spark-sql-kafka-0-10_2.12</artifactId>
    <version>3.3.1</version>
</dependency>
```

### Download Jars

Put all dependencies together and use the online tool https://jar-download.com/online-maven-download-tool.php
to download a zip that can be moved into the docker image.

```
<dependency>
    <groupId>io.delta</groupId>
    <artifactId>delta-core_2.12</artifactId>
    <version>2.3.0</version>
</dependency>
<dependency>
    <groupId>org.postgresql</groupId>
    <artifactId>postgresql</artifactId>
    <version>42.5.0</version>
</dependency>
 <dependency>
    <groupId>org.apache.spark</groupId>
    <artifactId>spark-hadoop-cloud_2.12</artifactId>
    <version>3.3.1</version>
    <scope>provided</scope>
  </dependency>
  <dependency>
    <groupId>org.apache.spark</groupId>
    <artifactId>spark-sql-kafka-0-10_2.12</artifactId>
    <version>3.3.1</version>
 </dependency>
  <dependency>
    <groupId>io.prometheus.jmx</groupId>
    <artifactId>jmx_prometheus_javaagent</artifactId>
    <version>0.17.2</version>
</dependency>
<!-- https://mvnrepository.com/artifact/org.apache.iceberg/iceberg-spark-runtime-3.2 -->
<dependency>
    <groupId>org.apache.iceberg</groupId>
    <artifactId>iceberg-spark-runtime-3.2_2.12</artifactId>
    <version>1.1.0</version>
</dependency>
<!-- https://mvnrepository.com/artifact/org.apache.hudi/hudi-spark3.3-bundle -->
<dependency>
    <groupId>org.apache.hudi</groupId>
    <artifactId>hudi-spark3.3-bundle_2.12</artifactId>
    <version>0.13.0</version>
</dependency>
<dependency>
    <groupId>org.apache.spark</groupId>
    <artifactId>spark-avro_2.12</artifactId>
    <version>3.3.1</version>
</dependency>
```
