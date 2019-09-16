# Performance comparison of Native Java framework 

See [GraalVM 19.2](https://www.graalvm.org/)

## Test plateform

**docker run --rm -it --cap-add=SYS_PTRACE --security-opt seccomp=unconfined -p 8444:8443 -v "/D/Developpement/archi/:/home/coder/project" codercom/code-server --allow-http --no-auth**

## Frameworks

### Micronaut 1.2

```
sdk use java 19.2.0-grl
gradle clean assemble
java -jar build/libs/micronaut-all.jar
native-image --no-server -cp build/libs/micronaut-all.jar
```

### Spring with Micronaut 1.1 
See GIT branch.

### Spring with Micronaut 1.2
See GIT branch.

### Quarkus 0.22
See GIT branch.

### Spring with Quarkus 0.22
See GIT branch.

### Spring boot 1.2
See GIT branch.

### Script

We have generate fatjar and binaries for each branch and launch *graalvm.sh framework* to make tests and take results.

## Results

[Table](https://docs.google.com/spreadsheets/d/e/2PACX-1vTlum2-EkQbcQiR0xuJAatsmiub8ky3MH8ZIjfVT-ZI6Iw2rwisZ9yolP1HPWhLX22afu22EVUUVLOd/pubhtml?gid=2096152561&single=true)

[Graph](https://docs.google.com/spreadsheets/d/e/2PACX-1vTlum2-EkQbcQiR0xuJAatsmiub8ky3MH8ZIjfVT-ZI6Iw2rwisZ9yolP1HPWhLX22afu22EVUUVLOd/pubchart?oid=1667786&format=interactive)