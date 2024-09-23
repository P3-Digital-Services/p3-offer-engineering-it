package com.example.kubernetes.demo.service

import com.example.kubernetes.demo.entity.Message
import com.example.kubernetes.demo.repository.MessageRepository
import org.springframework.stereotype.Service
import org.springframework.transaction.annotation.Transactional

@Service
@Transactional
class MessageService(private val messageRepository: MessageRepository) {

    fun createMessage(content: String): Message {
        return messageRepository.save(Message(content = content))
    }

    fun getMessage(id: Long): Message? {
        return messageRepository.findById(id).orElse(null)
    }

    fun updateMessage(id: Long, newContent: String): Message? {
        val message = messageRepository.findById(id).orElse(null)
        message?.let {
            it.content = newContent
            return messageRepository.save(it)
        }
        return null
    }
}