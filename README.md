# Kafka Connect Demo

![Architecture](https://github.com/Stefen-Taime/Kafka-pipeline/blob/main/Kafka%20(1).png)


### Creating infrastructure...

    chmod a+x manage.sh
    sh manage.sh up
 
![Architecture](https://github.com/Stefen-Taime/Kafka-pipeline/blob/main/img/img.PNG)

#### Adminer => localhost:8085
[mysql]
Host: mysql
user: root
password: kafkademo
db: demo

![Architecture](https://github.com/Stefen-Taime/Kafka-pipeline/blob/main/img/img2.PNG)

Then run MySQL Source:

    http POST localhost:8083/connectors @connect/mysql-source.json
    ./bin/kafka-avro-console-consumer --topic mysql.demo.customers --from-beginning

![Architecture](https://github.com/Stefen-Taime/Kafka-pipeline/blob/main/img/img3.PNG)

Then run Postgres Sink:

    http POST localhost:8083/connectors @connect/postgres-sink.json
    
![Architecture](https://github.com/Stefen-Taime/Kafka-pipeline/blob/main/img/img4.PNG)

[postgres]
Host: postgres
user: postgres
password: kafkademo
db: demo
![Architecture](https://github.com/Stefen-Taime/Kafka-pipeline/blob/main/img/img5.PNG)

Then fill with data:

    docker exec -ti mongo mongo -u debezium -p dbz --authenticationDatabase admin localhost:27017/demo

    PRIMARY> show collections;
    PRIMARY> db.user_actions.insert({"userId": 2, "ts": new Date(), "ip": "192.168.0.8"}),
             db.user_actions.insert({"userId": 3, "ts": new Date(), "ip": "192.168.233.255"}),
             db.user_actions.insert({"userId": 4, "ts": new Date(), "ip": "192.168.0.0.1"}),
             db.user_actions.insert({"userId": 5, "ts": new Date(), "ip": "10.0.0.15"}),
             db.user_actions.insert({"userId": 6, "ts": new Date(), "ip": "10.20.33.4"}),
             db.user_actions.insert({"userId": 7, "ts": new Date(), "ip": "192.255.30.4"}),
             db.user_actions.insert({"userId": 8, "ts": new Date(), "ip": "10.0.0.182"}),
             db.user_actions.insert({"userId": 9, "ts": new Date(), "ip": "10.0.0.10"}),
             db.user_actions.insert({"userId": 10, "ts": new Date(), "ip": "168.0.0.1"}),
             db.user_actions.insert({"userId": 11, "ts": new Date(), "ip": "10.10.255.2"}),
             db.user_actions.insert({"userId": 12, "ts": new Date(), "ip": "168.255.3.4"})
	     
Finally, setup source and sink:

    http POST localhost:8083/connectors @connect/mongo-source.json 
    http POST localhost:8083/connectors @connect/postgres-mongo-sink.json
    
 ![Architecture](https://github.com/Stefen-Taime/Kafka-pipeline/blob/main/img/img7.PNG)
   

### Events + PII masking

    http POST localhost:8083/connectors @connect/postgres-mongo-sink-no-pii.json
    
    ![Architecture](https://github.com/Stefen-Taime/Kafka-pipeline/blob/main/img/img8.PNG)

### Elasticsearch

Setup connector:

    http POST localhost:8083/connectors @connect/elastic-sink.json

Check results:

    curl http://localhost:9200/mysql.demo.customers/_search?pretty=true&q=*:*


### KSQL processing

Connect to console:

    docker exec -ti ksql ksql

Add sample query

    set 'auto.offset.reset'='earliest';
create stream customers with(kafka_topic='mysql.demo.customers', value_format='AVRO');
create stream addressLine1_changed_notification with (value_format='JSON') as 
    select before->addressLine1 rcpt, concat('Your address was changed to ', after->addressLine1) message
from customers where before->addressLine1 <> after->addressLine1;

Check the data:

    ./bin/kafka-console-consumer --topic ADDRESSLINE1_CHANGED_NOTIFICATION --from-beginning
    
# Inspiration
https://github.com/szczeles/kafkaconnect-demo
