package com.example.kubernetes.demo.controller

import com.example.kubernetes.demo.entity.Message
import com.example.kubernetes.demo.service.MessageService
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.web.bind.annotation.*

@RestController
@RequestMapping("/api/messages")
class MessageController(private val messageService: MessageService) {

    @PostMapping
    fun createMessage(@RequestBody content: String): ResponseEntity<Message> {
        val message = messageService.createMessage(content)
        return ResponseEntity.ok(message)
    }

    @GetMapping("/{id}")
    fun getMessage(@PathVariable id: Long): ResponseEntity<Message> {
        val message = messageService.getMessage(id)
        return if (message != null) ResponseEntity(message, HttpStatus.OK)
        else ResponseEntity(HttpStatus.NOT_FOUND)
    }

    @PutMapping("/{id}")
    fun updateMessage(@PathVariable id: Long, @RequestBody content: String): ResponseEntity<Message> {
        val updatedMessage = messageService.updateMessage(id, content)
        return updatedMessage?.let { ResponseEntity.ok(it) } ?: ResponseEntity.notFound().build()
    }
}