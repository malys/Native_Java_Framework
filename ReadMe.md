sdk use java 19.2.0-grl
gradle clean assemble
java -jar build/libs/micronaut-all.jar
native-image --no-server -cp build/libs/micronaut-all.jar

Docker  IDE
d run --rm -it --add-host=dbtransverses01.inte01.lbg:10.206.41.114 --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -p 8444:8443 -v "/D/Developpement/archi/:/home/coder/project" codercom/code-server --allow-http --no-auth
