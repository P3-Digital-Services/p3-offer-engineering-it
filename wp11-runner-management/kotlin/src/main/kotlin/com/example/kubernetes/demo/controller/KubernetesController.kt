package com.example.kubernetes.demo.controller

import com.example.kubernetes.demo.service.KubernetesService
import io.kubernetes.client.openapi.models.V1Pod
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.GetMapping
import org.springframework.web.bind.annotation.RequestMapping
import org.springframework.web.bind.annotation.RestController

@RestController
@RequestMapping("/api/pods")
class KubernetesController(private val kubernetesService: KubernetesService) {

    @GetMapping
    fun getPods(): ResponseEntity<List<V1Pod>> {
        return ResponseEntity.ok(kubernetesService.getAllPods())
    }
}