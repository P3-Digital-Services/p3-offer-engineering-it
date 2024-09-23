package com.example.kubernetes.demo.config

import io.kubernetes.client.openapi.ApiClient
import io.kubernetes.client.util.Config
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class K8sClientConfig {

    @Bean
    fun apiClient(): ApiClient {
        return Config.defaultClient()
    }
}