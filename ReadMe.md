sdk use java 19.2.0-grl
gradle clean assemble
java -jar build/libs/micronaut-all.jar
native-image --no-server -cp build/libs/micronaut-all.jar