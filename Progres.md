# Treure les files en que no hi ha nota final d'assignatura (taula NOTES)
notes = notes[notes$F_Grade != "", ]

# Treure les files tals que aula_id no es correspon a cap aula en el dataset NOTES 
activitats = activitats[activitats$aula_id %in% c(92, 143, 87, 141), ]

# Les columnes "grader" i "dategraded" de la taula TRAMESES és inútil
trameses = trameses[, c("id", "activitat_id", "userid", "datesubmitted", "grade", "nevaluations")]

# Separem les activitats per grups (aula_id)
activitats87 = activitats[activitats$aula_id == 87, ]
activitats92 = activitats[activitats$aula_id == 92, ]
activitats141 = activitats[activitats$aula_id == 141, ]
activitats143 = activitats[activitats$aula_id == 143, ]

# Arreglem la columna ID per a les noves taules...
activitats87$activitat_id = seq(1, length(activitats87[, 1]), by = 1)
activitats92$activitat_id = seq(1, length(activitats92[, 1]), by = 1)
activitats141$activitat_id = seq(1, length(activitats141[, 1]), by = 1)
activitats143$activitat_id = seq(1, length(activitats143[, 1]), by = 1)


# Treure els grade == NULL per als casos en què nevaluations > 0 (no té sentit)
trameses = trameses[trameses$grade != "NULL" | trameses$nevaluations == 0, ]