package ru.rein.tgbot.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import ru.rein.tgbot.entity.ChatUser;

import java.util.Optional;

public interface ChatUserRepository extends JpaRepository<ChatUser, Long> {
    Optional<ChatUser> findChatUserByTgUserIdAndChatId(Long tgUserId, Long chatId);
}