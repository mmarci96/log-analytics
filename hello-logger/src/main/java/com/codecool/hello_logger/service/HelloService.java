package com.codecool.hello_logger.service;

import org.springframework.stereotype.Service;

import java.util.logging.Level;
import java.util.logging.Logger;

@Service
public class HelloService {
    private final Logger logger;

    public HelloService(Logger logger) {
        this.logger = logger;
    }

    public String getHelloMsg() {
        System.out.println("Hello from console!");
        logger.log(Level.INFO, "Sending hello to client!");
        return "Hello!";
    }
}
