package com.codecool.hello_logger.controller;

import com.codecool.hello_logger.service.HelloService;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {
    HelloService helloService;

    public HelloController(HelloService helloService) {
        this.helloService = helloService;
    }

    @GetMapping("/hello")
    public String sayHello() {
        return helloService.getHelloMsg();
    }
}
