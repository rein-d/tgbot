package ru.rein.tgbot.service.botservice;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.telegram.telegrambots.bots.TelegramLongPollingBot;
import org.telegram.telegrambots.meta.api.methods.send.SendMessage;
import org.telegram.telegrambots.meta.api.objects.Update;
import org.telegram.telegrambots.meta.exceptions.TelegramApiException;
import ru.rein.tgbot.config.BotConfig;
import ru.rein.tgbot.entity.ChatUser;
import ru.rein.tgbot.service.ChatUserService;

import java.util.*;
import java.util.stream.Collectors;

@Slf4j
@Component
public class SvetlolikiyTelegramBot extends TelegramLongPollingBot {

    private static final String HELLO_MESSAGE = """
            Пора, родной, пора...\
            
            Если ты не ККК, то для приёма в ООСД жми сюда:
            
            /register""";

    private final BotConfig tgConfig;
    private final ChatUserService userService;

    public SvetlolikiyTelegramBot(BotConfig tgConfig, ChatUserService userService) {
        super(tgConfig.getToken());
        this.tgConfig = tgConfig;
        this.userService = userService;
    }

    @Override
    public void onUpdateReceived(Update update) {
        if (update.hasMessage() && update.getMessage().hasText()) {
            var msg = update.getMessage();
            var chatId = msg.getChatId();
            var messageText = msg.getText();

            log.info("TEXT: {}", messageText);

            switch (messageText) {
                case "/start" -> sendHello(chatId, HELLO_MESSAGE);
                case "/register" -> saveNewUser(update);
                case "/roll" -> sendChatRoulette();

                default -> System.out.println("Unknown message");
            }
        }
    }

    @Override
    public void onUpdatesReceived(List<Update> updates) {
        updates.forEach(this::onUpdateReceived);
    }

    @Override
    public String getBotUsername() {
        return tgConfig.getBotName();
    }

    @Override
    public void onRegister() {
        super.onRegister();
    }

    public void sendHello(Long who, String what) {
        SendMessage sm = SendMessage.builder()
                .chatId(who) //Who are we sending a message to
                .text(what).build();    //Message content

        sendMessage(sm);
    }

    public void sendChatRoulette() {
        Map<Long, List<ChatUser>> allUsersByChat = userService.getUsers().stream()
                .collect(Collectors.groupingBy(ChatUser::getChatId));

        allUsersByChat.forEach((chatId, users) -> {
            SendMessage smStart = SendMessage.builder()
                    .chatId(chatId)
                    .text("Басуха в деле, родные! Всем по шляпе в кадык!")
                    .build();
            sendMessage(smStart);
            getRouletteMessages(users).forEach(message -> {
                SendMessage smRoulette = SendMessage.builder()
                        .chatId(chatId)
                        .text(message)
                        .build();
                sendMessage(smRoulette);
            });
        });

    }

    private void saveNewUser(Update update) {
        var chatId = update.getMessage().getChatId();
        var user = update.getMessage().getFrom();

        log.info("Saving telegram user: {}", user);

        userService.saveNewUser(user, chatId);
        SendMessage sm = SendMessage.builder()
                .chatId(chatId)
                .text("Басуха в деле, родной")
                .replyToMessageId(update.getMessage().getMessageId())
                .build();

        sendMessage(sm);
    }

    private void sendMessage(SendMessage sm) {
        try {
            execute(sm);                        //Actually sending the message
        } catch (TelegramApiException e) {
            throw new RuntimeException(e);      //Any error will be printed here
        }
    }

    private List<String> getRouletteMessages(List<ChatUser> users) {
        Collections.shuffle(users);
        List<String> templateMessages = new ArrayList<>();
        List<String> resultMessages = new ArrayList<>();
        templateMessages.add("@%s, тебе самую фиолетовую");
        templateMessages.add("@%s, тебе с кусочками кала");

        for (int i = 0; i < templateMessages.size(); i++) {
            resultMessages.add(templateMessages.get(i).formatted(users.get(i).getUsername()));
        }
        return resultMessages;
    }
}
