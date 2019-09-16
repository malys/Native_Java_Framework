mvn archetype:generate -DinteractiveMode=false \
    -DarchetypeGroupId=io.helidon.archetypes \
    -DarchetypeArtifactId=helidon-quickstart-mp \
    -DarchetypeVersion=1.3.0 \
    -DgroupId=io.helidon.examples \
    -DartifactId=helidon-quickstart-mp \
    -Dpackage=io.helidon.examples.quickstart.mp

sdk use java 19.2.0-grl
mvn clean package
java -jar target/rest-json.jar
#https://helidon.io/docs/latest/#/guides/36_graalnative
mvn package -Pnative
