package example.micronaut;

import io.micronaut.runtime.Micronaut;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
//java -Dserver.port=8081 -jar
// ./gradlew assemble
// native-image --no-server -cp build/libs/complete-all.jar
@SpringBootApplication
public class Application {

    public static void main(String[] args) {
         Micronaut.run(Application.class);
        //SpringApplication.run(Application.class, args);
    }

}
