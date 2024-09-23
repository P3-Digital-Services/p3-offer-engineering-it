package com.example.kubernetes.demo.service

import io.kubernetes.client.openapi.ApiClient
import io.kubernetes.client.openapi.apis.CoreV1Api
import io.kubernetes.client.openapi.models.V1Pod
import org.springframework.scheduling.annotation.Scheduled
import org.springframework.stereotype.Service

@Service
class KubernetesService(apiClient: ApiClient, private val messageService: MessageService) {

    private val api = CoreV1Api(apiClient)

    fun getAllPods(): List<V1Pod> {
        return api.listPodForAllNamespaces(null, null, null, null, null, null, null, null, null, null).items
    }

    @Scheduled(fixedRate = 10000)
    fun updatePodStates() {
        val pods = getAllPods()
        pods.forEach { pod ->
            val status = pod.status?.phase
            val message = "Pod ${pod.metadata?.name} is in $status state."
            messageService.createMessage(message)
        }
    }
}