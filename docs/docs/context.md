# Context Diagram

```plantuml
@startuml
title FitLife Context Diagram
top to bottom direction

!includeurl https://raw.githubusercontent.com/RicardoNiepel/C4-PlantUML/master/C4_Contex.puml

Person(user, "User", "A user of the fitness club system")
System(fitlife, "FitLife System", "Manages memberships and payments")
System_Ext(bank, "Bank System", "Processes payments")

Rel(user, fitlife, "Uses")
Rel(fitlife, bank, "Pays via")
@enduml
```