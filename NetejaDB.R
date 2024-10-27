library("dplyr")

activitatsSharedID = data.frame(read.csv("activitats_with_shared.csv", header = T, sep = ","))
notes = data.frame(read.csv("notes.csv", header = T, sep = ";"))
trameses = data.frame(read.csv("trameses_arreglat.csv", header = T, sep = ","))


############ ACTIVITATS ############



####################################



############## NOTES ###############

# Treure les files en que no hi ha nota final d'assignatura (taula NOTES)
#notes = notes[, c("userid", "aula_id", "P_Grade", "F_Grade", "R_Grade")]
#notes = notes[notes$P_Grade != "" | notes$F_Grade != "", ]

#notes$P_Grade = gsub(",", ".", notes$P_Grade)
#notes$F_Grade = gsub(",", ".", notes$F_Grade)


# CREAR COLUMNA NOTA FINAL
#notes$notaFinal = rep(-99, length(notes$userid))
#notes$notaProblemes = rep(-99, length(notes$userid))
#notes$notaExamens = rep(-99, length(notes$userid))


#for (i in 1:length(notes$notaFinal)) {
#   resultat = notaFinal(notes$userid[i], i, notes$aula_id[i])
#    notes$notaFinal[i] = resultat[1]
#    notes$notaExamens[i] = resultat[2]
#    notes$notaProblemes[i] = resultat[3]
#}

####################################



############### TRAMESES ###########

# Les columnes "grader" i "dategraded" de la taula TRAMESES és inútil
#trameses = trameses[, c("id", "activitat_id", "userid", "datesubmitted", "grade", "nevaluations")]


# Treure els grade == NULL per als casos en què nevaluations > 0 (no té sentit)
#trameses = trameses[trameses$grade != "NULL" | trameses$nevaluations == 0, ]

# Per als "NULL" que queden, convertirlos a zeros.
#for (i in 1:length(trameses$grade)) {
#  if (trameses$grade[i] == "NULL") trameses$grade[i] = "0.00000"
#}

# Convertir la columna "grade" a numeric
#trameses$grade = as.numeric(trameses$grade)

# Eliminar les entrades repetides, y quedarnos només amb la nota més alta.
#trameses = trameses %>%
#  group_by(activitat_id, userid) %>%
#  slice_max(grade, with_ties = FALSE) %>%  # Selecciona el valor máximo
#  ungroup()

#trameses = as.data.frame(trameses)


# Treure les files tals que "userid" no aparegui en la taula NOTES
#trameses = trameses[trameses$userid %in% unique(notes$userid), ]


####################################


# FUNCIÓ PER ASSIGNAR NOTES (DE PROBLEMES, D'EXÀMENS I DE FINALS)

notaFinal = function(userid, index, aula) {
  
  notaExamens = 0
  
  if (notes$P_Grade[index] == "") notaExamens = notaExamens + 0.6*as.numeric(notes$F_Grade[index])
  else {
    if (notes$F_Grade[index] == "") notaExamens = notaExamens + 0.6*as.numeric(notes$P_Grade[index])
    else notaExamens = notaExamens + 0.3*as.numeric(notes$P_Grade[index]) + 0.3*as.numeric(notes$F_Grade[index])
  }
  
  notaExamens = round(notaExamens, 3)
  
  llistaActivitats = activitatsSharedID[activitatsSharedID$label %in% c(1, 5) & activitatsSharedID$aula_id == aula, ]
  
  notaProblemes = 0
  
  for (i in 1:length(llistaActivitats$grade)) {
    if (length(trameses$grade[(trameses$activitat_id == llistaActivitats$activitat_id[i]) & (trameses$userid == userid)]) != 0) {
      notaProblemes = notaProblemes + trameses$grade[(trameses$activitat_id == llistaActivitats$activitat_id[i]) & (trameses$userid == userid)]
    }
  }
  notaProblemes = ((notaProblemes / length(llistaActivitats$grade)) / 10 ) * 0.4
  notaProblemes = round(notaProblemes, 3)

  notaFinal = notaExamens + notaProblemes
  
  return(c(notaFinal, notaExamens, notaProblemes))
}



#CORRELACIÓ ENTRE VARIABLES (NOTES DE LES ACTIVITATS) I LA NOTA FINAL!!!!!!!!!!!!

