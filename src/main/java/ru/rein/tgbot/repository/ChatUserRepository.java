package ru.rein.tgbot.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.rein.tgbot.entity.ChatUser;

public interface ChatUserRepository extends JpaRepository<ChatUser, Long> {
}