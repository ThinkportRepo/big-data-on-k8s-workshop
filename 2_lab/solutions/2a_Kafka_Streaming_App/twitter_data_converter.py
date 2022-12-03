# !pip install kafka-python

from kafka import KafkaConsumer
from kafka import KafkaProducer
import json
from datetime import datetime

KAFKA_SERVER = "kafka-cp-kafka.kafka.svc.cluster.local:9092"
KAFKA_SOURCE_TOPIC = "twitter-json"
KAFKA_TARGET_TOPIC = "twitter-table4"

# Initialize consumer variable
consumer = KafkaConsumer (KAFKA_SOURCE_TOPIC, group_id ='group15',bootstrap_servers = KAFKA_SERVER, value_deserializer=lambda m: json.loads(m.decode('utf-8')))

# Initialize producer variable
producer = KafkaProducer(bootstrap_servers=KAFKA_SERVER,value_serializer=lambda x: json.dumps(x).encode('utf-8')) 

# iterate forever over all new messages in consumer object
# pick relevant fields from json
# print result to console
# write result to new kafka topic
for message in consumer:
    result={
        "tweet_id": int(message.value["payload"]["Id"]),
        "created_at": datetime.fromtimestamp(int(message.value["payload"]["CreatedAt"])/1000).strftime('%Y-%m-%d %H:%M:%S'),
        "tweet_message": message.value["payload"]["Text"],
        "user_name": message.value["payload"]["User"]["ScreenName"],
        "user_location": message.value["payload"]["User"]["Location"],
        "user_follower_count": int(message.value["payload"]["User"]["FollowersCount"]),
        "user_friends_count": int(message.value["payload"]["User"]["FriendsCount"]),
        "retweet_count": int(message.value["payload"]["RetweetCount"]),
        "language": message.value["payload"]["Lang"],
        "hashtag": [hashtag["Text"] for hashtag in message.value["payload"]["HashtagEntities"]]
    }
    key=int(message.value["payload"]["Id"])
    print("##########################################################")
    print(json.dumps(result))
    producer.send(KAFKA_TARGET_TOPIC,value=result)