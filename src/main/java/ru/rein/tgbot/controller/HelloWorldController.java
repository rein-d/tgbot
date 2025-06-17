package ru.rein.tgbot.controller;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;

@RestController
@RequestMapping("/")
public class HelloWorldController {

    @GetMapping("hello")
    public ResponseEntity<String> getTest() {
        return ResponseEntity.ok("Hello world");
    }

}

