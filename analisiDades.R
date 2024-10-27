library(ggplot2)
library(dplyr)

notes = read.csv("notes_arreglat.csv")
trameses = read.csv("trameses_arreglat.csv")
activitats = read.csv("activitats_with_shared.csv")


# Correlació entre variables i nota final

# Exercics d'aula (com que són poques, les fiquem al mateix sac)
exercicisAula = activitats[activitats$label %in% c(1, 2, 5), ]
#exercicisAula = exercicisAula[!grepl("Recupera", exercicisAula$activitat), ]

idAlumne = c()
gradeActivitatsOpcionals = c()
notaFinal = c()

for (i in 1:length(exercicisAula$activitat_id)) {
  idActivitat = exercicisAula$activitat_id[i]
  for (j in 1:length(trameses$grade[trameses$activitat_id == idActivitat])) {
    idAlumne = c(idAlumne, trameses$userid[j])
    gradeActivitatsOpcionals = c(gradeActivitatsOpcionals, trameses$grade[j])
    notaFinal = c(notaFinal, notes$notaFinal[notes$userid == trameses$userid[j]])
  }
}


finalIDAlumne = c()
finalMeanGrade = c()
finalNotaFinal = c()
for (i in 1:length(unique(idAlumne))) {
  id = unique(idAlumne)[i]
  notesAPromitjar = c()
  finalGrade = -99
  for (j in 1:length(idAlumne)){
    if (idAlumne[j] == id) {
      notesAPromitjar = c(notesAPromitjar, gradeActivitatsOpcionals[j])
      finalGrade = notaFinal[j]
    }
  }
  promig = mean(notesAPromitjar)
  
  finalIDAlumne = c(finalIDAlumne, id)
  finalMeanGrade = c(finalMeanGrade, promig)
  finalNotaFinal = c(finalNotaFinal, finalGrade)
}

x_notesALesEntregues = finalMeanGrade
y_notaFinalAssignatura = finalNotaFinal

plot(x_notesALesEntregues, y_notaFinalAssignatura)




problemesIEntregues = activitats[activitats$label %in% c(1, 2), ]
activitatsOpcionals = activitats[activitats$label == 3, ]



# Labels 
# 1. Problema
# 2. Entrega / Pràctica
# 3. (Opcional)
# 4. Exercici d'exàmen
# 5. Exercici d'aula


# Com influeix la nota dels problemes/lliuraments???

notes$FactorNotaProblemes = rep(-99, length(notes$notaProblemes))
for (i in 1:length(notes$notaProblemes)) {
  factor = -99
  if (notes$notaProblemes[i] < 0.5) factor = 1
  else if (notes$notaProblemes[i] < 1.5) factor = 2
  else if (notes$notaProblemes[i] < 2.5) factor = 3
  else if (notes$notaProblemes[i] < 3.5) factor = 4
  else factor = 5
  notes$FactorNotaProblemes[i] = factor
}


summary(notes$notaFinal[notes$notaProblemes > 3])
summary(notes$notaFinal[notes$notaProblemes < 3 & notes$notaProblemes > 2])
summary(notes$notaFinal[notes$notaProblemes < 2 & notes$notaProblemes > 1])
summary(notes$notaFinal[notes$notaProblemes < 1])


cor(notes$FactorNotaProblemes, notes$notaFinal)
pairwise.t.test(notes$notaFinal, notes$FactorNotaProblemes)

anova = aov(notes$notaFinal ~ notes$FactorNotaProblemes)
summary(anova)

for (i in 1:length(notes$FactorNotaProblemes)) {
  factorCategoric = ""
  if (notes$notaProblemes[i] < 0.5) factorCategoric = "0 - 1.25"
  else if (notes$notaProblemes[i] < 1.5) factorCategoric = "1.25 - 3.75"
  else if (notes$notaProblemes[i] < 2.5) factorCategoric = "3.75 - 6.25"
  else if (notes$notaProblemes[i] < 3.5) factorCategoric = "6.25 - 8.75"
  else factorCategoric = "8.75 - 10"
  notes$FactorNotaProblemes[i] = factorCategoric
}

boxplot(notes$notaFinal ~ notes$FactorNotaProblemes, xlab = "Nota Problemes i Lliuraments (Factor)", ylab = "Nota Final Assignatura")

#######################################

# Com influeix el parcial???

notesHiHaParcial = notes[!is.na(notes$P_Grade), ]

cor(notesHiHaParcial$P_Grade, notesHiHaParcial$notaFinal)

notesHiHaParcial$FactorNotaParcial = rep("", length(notesHiHaParcial$P_Grade))
for (i in 1:length(notesHiHaParcial$P_Grade)) {
  factor = ""
  if (notesHiHaParcial$P_Grade[i] < 2) factor = "0 - 2"
  else if (notesHiHaParcial$P_Grade[i] < 4) factor = "2 - 4"
  else if (notesHiHaParcial$P_Grade[i] < 6) factor = "4 - 6"
  else if (notesHiHaParcial$P_Grade[i] < 8) factor = "6 - 8"
  else factor = "8 - 10"
  notesHiHaParcial$FactorNotaParcial[i] = factor
}


boxplot(notesHiHaParcial$notaFinal ~ notesHiHaParcial$FactorNotaParcial, xlab = "Nota Exàmen Parcial (Factor)", ylab = "Nota Final Assignatura")

pairwise.t.test(notesHiHaParcial$notaFinal, notesHiHaParcial$FactorNotaParcial)

#######################################


