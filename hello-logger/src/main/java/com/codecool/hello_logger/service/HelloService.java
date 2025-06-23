package com.codecool.hello_logger.service;

import org.springframework.stereotype.Service;

@Service
public class HelloService {
    public String getHelloMsg() {
        // System.out.println("Hello from console!");
        return "Hello!";
    }
}
