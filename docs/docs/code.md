```plantuml
@startuml
title FitLife Context Diagram

!includeurl https://raw.githubusercontent.com/RicardoNiepel/C4-PlantUML/master/C4_Component.puml

Person(user, "Пользователь", "Клиент фитнес-клуба")
Person(admin, "Администратор", "Сотрудник, управляющий системой")

System(fitlife, "FitLife", "Система управления фитнес-клубом")

System_Ext(bank, "Банковская система", "Обработка платежей")
System_Ext(fitnessAPI, "Fitness API", "Внешний сервис фитнес-данных")

Rel(user, fitlife, "Использует", "Telegram Bot")
Rel(admin, fitlife, "Управляет", "Web UI")
Rel(fitlife, bank, "Отправляет платежи", "HTTPS/JSON")
Rel(fitlife, fitnessAPI, "Получает данные", "REST API")
@enduml