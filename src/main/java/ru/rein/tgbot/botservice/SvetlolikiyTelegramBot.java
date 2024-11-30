package ru.rein.tgbot.botservice;

import org.springframework.stereotype.Component;
import org.telegram.telegrambots.bots.TelegramLongPollingBot;
import org.telegram.telegrambots.meta.api.objects.Update;
import ru.rein.tgbot.config.BotConfig;

import java.util.List;

@Component
public class SvetlolikiyTelegramBot extends TelegramLongPollingBot {

    private final BotConfig tgConfig;

    public SvetlolikiyTelegramBot(BotConfig tgConfig) {
        super(tgConfig.getToken());
        this.tgConfig = tgConfig;
    }

    @Override
    public void onUpdateReceived(Update update) {
        if(update.hasMessage() && update.getMessage().hasText()){
            String messageText = update.getMessage().getText();

            switch (messageText) {
                case "/start" -> System.out.println("It's working!!!");
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
}
