package ru.rein.tgbot.job;

import lombok.RequiredArgsConstructor;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;
import ru.rein.tgbot.service.botservice.SvetlolikiyTelegramBot;

@Component
@RequiredArgsConstructor
public class SvetlolikiyJob {

    private final SvetlolikiyTelegramBot bot;

    @Scheduled(cron = "0 0 13 * * *")
    public void sendSvetlolikiyMessage() {

    }
}
