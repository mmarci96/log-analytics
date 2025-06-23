package com.codecool.hello_logger.interceptor;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Component;
import org.springframework.web.servlet.HandlerInterceptor;

import java.util.logging.Logger;

@Component
public class LoggingInterceptor implements HandlerInterceptor {

    private static final Logger LOGGER = Logger.getLogger(LoggingInterceptor.class.getName());

    @Override
    public boolean preHandle(
            HttpServletRequest request, HttpServletResponse response, Object handler) {
        LOGGER.info(
                () ->
                        String.format(
                                "Incoming Request: [%s] %s from %s",
                                request.getMethod(),
                                request.getRequestURI(),
                                request.getRemoteAddr()));
        return true;
    }

    @Override
    public void afterCompletion(
            HttpServletRequest request,
            HttpServletResponse response,
            Object handler,
            Exception ex) {
        LOGGER.info(
                () ->
                        String.format(
                                "Response: [%d] for %s %s",
                                response.getStatus(),
                                request.getMethod(),
                                request.getRequestURI()));

        if (ex != null) {
            LOGGER.severe(() -> String.format("Exception occurred: %s", ex.getMessage()));
        }
    }
}
