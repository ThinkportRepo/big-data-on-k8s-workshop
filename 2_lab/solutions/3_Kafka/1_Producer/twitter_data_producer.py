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

KAFKA_SERVER = os.environ["KAFKA_SERVER"] #"kafka.kafka.svc.cluster.local:9092"
KAFKA_TOPIC = os.environ["KAFKA_TOPIC"] #"twitter-raw"
GROUP_ID=str(uuid.uuid1())

print("+++ Kafka Server", KAFKA_SERVER)
print("+++ Kafka Topic", KAFKA_TOPIC)



# Initialize producer variable
producer = KafkaProducer(bootstrap_servers=KAFKA_SERVER,value_serializer=lambda x: json.dumps(x).encode('utf-8')) 


# create random data
# #################################
# country list
country_list=[
              {"country": "Germany","language": "DE"},
              {"country": "Germany","language": "DE"},
              {"country": "USA","language": "EN"},
              {"country": "United Kingdom","language": "EN"},
              {"country": "France","language": "FR"},
              {"country": "India","language": "EN"},
              {"country": "Spain","language": "ES"},
              {"country": "Brasil","language": "PT"},
              {"country": "USA","language": "EN"},
              {"country": "USA","language": "EN"},
              {"country": "USA","language": "EN"}
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
   
# add some non uniformity
user_country_list.extend(user_country_list[10:50])
user_country_list.extend(user_country_list[30:70])

# hasthag list
hastag_list=["BigData","DataScience","ML","AI","Data","BigData","DataEngineering","MachineLearning","BigData", "IoT","Analytics","BigData","DataAnlytics","Cloud"]


def create_random_message(counter):
    random_user=random.choice(user_country_list)
    message={
        "Id": str(uuid.uuid1()),
        "Counter": str(counter),
        "CreatedAt": time.time(),
        "Text": lorem.sentence(),
        "User": {
            "ScreenName": random_user["user_name"],
            "Location": random_user["user_location"],
            "FollowersCount": random_user["user_follower_count"],
            "FriendsCount": random_user["user_friends_count"]
        },
        "Lang": random_user["language"],
        "HashtagEntities": random.choices(hastag_list, k=random.randint(1, 5)),
        "RetweetCount": random.randint(0, 1000)
    }

    return message

starttime = time.time()
counter=0
looptime=1.0
while True:
    message=create_random_message(counter)
    counter=counter+1
    print("++ message nr: " + str(counter)+ " +++++++++++++++++++++++++++++++++++++++++++")
    print(json.dumps(message))
    print("+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
    #producer.send(KAFKA_TOPIC,key=message.get("Id"),value=message)
    producer.send(KAFKA_TOPIC,value=message)
    looptime=random.randint(1, 4)
    time.sleep(looptime)
               
               
producer.close()

