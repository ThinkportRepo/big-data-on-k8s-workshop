# !pip install kafka-python

from kafka import KafkaProducer
import json
import os
import uuid
from datetime import datetime
import datetime
import time
from lorem_text import lorem
import names
import random

KAFKA_SERVER = os.environ["KAFKA_SERVER"] #"kafka-cp-kafka.kafka.svc.cluster.local:9092"
KAFKA_SOURCE_TOPIC = os.environ["KAFKA_SOURCE_TOPIC"] #"twitter-raw"
KAFKA_TARGET_TOPIC = os.environ["KAFKA_TARGET_TOPIC"] #"twitter-table"
GROUP_ID=str(uuid.uuid1())


# Initialize producer variable
producer = KafkaProducer(bootstrap_servers=KAFKA_SERVER,value_serializer=lambda x: json.dumps(x).encode('utf-8')) 


# create random data
# #################################
# country list
country_list=[
              {"country": "Germany","language": "DE"},
              {"country": "USA","language": "EN"},
              {"country": "United Kingdom","language": "EN"},
              {"country": "France","language": "FR"},
              {"country": "India","language": "EN"},
              {"country": "Spain","language": "ES"},
              {"country": "Brasil","language": "PT"}
             ]

# create name list of 50 names
names_list=set()
for n in range(50):
    names_list.add(names.get_first_name())

# create unique set of name, country, language
user_country_list=[]
for name in names_list:
    random_country=random.choice(country_list)
    user_country_list.append({
        "user_name": name, 
        "user_location": random_country["country"], 
        "language": random_country["language"],
        "user_follower_count": random.randint(100, 5000),
        "user_friends_count": random.randint(1000, 50000)
    })
   

# hasthag list
hastag_list=["DataScience","ML","AI","Data","DataEngineering","machinelearning", "iot","analytics","dataanlytics","cloud"]



# iterate forever over all new messages in consumer object
# pick relevant fields from json
# print result to console
# write result to new kafka topic
print("##########################################################")
print("+++ starting twitter Stream...")
counter=0
for message in consumer:
    counter=counter+1
    result={
        "tweet_id": str(message.value["payload"]["Id"]),
        "created_at": datetime.fromtimestamp(int(message.value["payload"]["CreatedAt"])/1000).strftime('%Y-%m-%d %H:%M:%S'),
        "tweet_message": message.value["payload"]["Text"],
        "user_name": message.value["payload"]["User"]["ScreenName"],
        "user_location": message.value["payload"]["User"]["Location"],
        "user_follower_count": int(message.value["payload"]["User"]["FollowersCount"]),
        "user_friends_count": int(message.value["payload"]["User"]["FriendsCount"]),
        "retweet_count": int(message.value["payload"]["RetweetCount"]),
        "language": message.value["payload"]["Lang"],
        "hashtags": [hashtag["Text"] for hashtag in message.value["payload"]["HashtagEntities"]]
    }
    print("++ total: " + str(counter)+ "+++++++++++++++++++++++++++++++++++++++++++")
    print(json.dumps(result))
    producer.send(KAFKA_TARGET_TOPIC,value=result)