package example.micronaut;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.GetMapping;

@RestController
@RequestMapping("/conferences/random")
public class ConferenceController {
    @Autowired
    private ConferenceService conferenceService;

    @GetMapping
    public Conference randomConf() {
        return conferenceService.randomConf();
    }
}