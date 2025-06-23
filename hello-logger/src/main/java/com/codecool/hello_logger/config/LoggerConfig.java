package com.codecool.hello_logger.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.logging.Logger;

@Configuration
public class LoggerConfig {
    @Bean
    public Logger logger() {
        return Logger.getGlobal();
    }
}
