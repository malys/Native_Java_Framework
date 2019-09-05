package example.micronaut;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;

@RestController
public class ConferenceController {
    @Autowired
    private ConferenceService conferenceService;


    @RequestMapping("/conferences/random")
    public Conference randomConf() {
        return conferenceService.randomConf();
    }
}
