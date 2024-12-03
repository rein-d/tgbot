package ru.rein.tgbot.service;

import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.telegram.telegrambots.meta.api.objects.User;
import ru.rein.tgbot.entity.ChatUser;
import ru.rein.tgbot.repository.ChatUserRepository;

import java.util.List;

@RequiredArgsConstructor
@Service
public class ChatUserService {
    private final ChatUserRepository chatUserRepository;

    @Transactional
    public void saveNewUser(User user, Long chatId) {
        var existingUser = chatUserRepository.findById(user.getId());
        if (existingUser.isEmpty()) {
            chatUserRepository.save(new ChatUser(user.getId(), user.getUserName(), chatId));
        }
    }

    public List<ChatUser> getUsers() {
        return chatUserRepository.findAll();
    }
}
