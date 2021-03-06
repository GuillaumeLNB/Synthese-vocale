##########################################
# script praat synthétiseur                                  				   #
# auteur : Guillaume LE NOÉ-BIENVENU					   #
#                  										   #
##########################################
clearinfo

selectObject: "Sound logatomes3"
zeroes = To PointProcess (zeroes): 1, "yes", "no"

#######################
form Choix du mot
	text sequence ordinateur
 		comment Voici la liste des mots que vous pouvez synthétiser :
		comment Noms : maison, chaise, lampe, casserole, cuisine, bouilloire, 
		comment .    	         bureau, ordinateur, stylo, tapis
		comment Articles : le, la, du, de
		comment Prépositions : dans, sur
		comment Verbes : se trouve
		comment Exemple : la bouilloire de la cuisine se trouve sur la table du bureau
		comment ________________________________________________________________
        choice modification_prosodique: 1
        	button oui
        	button non
	comment Ajouter une cible de f0 au début de phrase (en Hz) :
		real ajout_f0_en_debut 100.0
	comment Ajouter une cible de f0 en milieu de phrase (en Hz) :
		real ajout_f0_en_milieu 150.0
	comment Ajouter une cible de f0 en fin de phrase (en Hz) :
		real ajout_f0_en_fin 80.0
	comment  
	comment Nom du fichier en sortie : 
	text filename resultat
endform

writeInfoLine: "Vous avez choisis la phrase : ", sequence$, " || Modification prosodique : ", modification_prosodique$, ".", " Cible début de phrase : ", ajout_f0_en_debut, "  Hz", " Cible fin de phrase : ", ajout_f0_en_fin, " Hz", " Nom du fichier en sortie : ", filename$

sequence$=sequence$+" "
phrase$=sequence$
printline 
printline Calcul en cours...
#######################
#Lecture des paramètres
mon_son = Read from file: "l'adresse du fichier à lire."
# par ex : /home/Desktop/Phonetique/super_fichier.mp3
ma_segmentation = Read from file: "logatomes3.TextGrid"
select 'ma_segmentation'
fin = Get number of intervals: 1

#######################
fichiervide = Create Sound from formula: "sineWithNoise", 1, 0, 0.01, 44100, "0"
resultat$ = ""
#######################
#extraction de la phrase

while index(sequence$, " ")>0

	espace = index(sequence$, " ")
	mot$ = left$(sequence$, espace-1)
	dictionnaire = Read Table from tab-separated file: "/home/guillaume/Desktop/Cours/Informatique et Phonetique/Praat/dico.txt"
	Extract rows where column (text): "orthographe", "is equal to", mot$
	mot_phone$=Get value: 1, "phonetique"

	longueur = length(sequence$)
	sequence$ = right$(sequence$, longueur-espace)
	resultat$ = "'resultat$'" + "'mot_phone$'" 

endwhile

mot$="_"+"'resultat$'"

#######################
#recherche et concaténation des diphones

lenmot = length (mot$)

for j from 1 to  lenmot-1

	diphone1$ = mid$ (mot$ , j, 1)
	diphone2$ = mid$ (mot$, j+1, 1)

	for i from 1 to  fin -1
		select 'ma_segmentation'
		starttime = Get start time of interval: 1, i
		endtime = Get end time of interval: 1, i
		phoneme$ = Get label of interval: 1, i
		phonemesuivant$ = Get label of interval: 1, i+1
		endtimesuivant = Get end time of interval: 1, i+1

		if (phoneme$ = "'diphone1$'" and phonemesuivant$ = "'diphone2$'")
		
			milieuphoneme = (starttime+endtime)/2
			milieuphonemesuivant = (endtime+endtimesuivant)/2

			select 'zeroes'
			nearest_ind_1 = Get nearest index: milieuphoneme
			nearest_ind_2 = Get nearest index: milieuphonemesuivant

			index_time1 = Get time from index: nearest_ind_1
			index_time2 = Get time from index: nearest_ind_2

			select 'mon_son'

			sonextrait = Extract part: index_time1, index_time2, "rectangular", 1, "no"		
	
			selectObject: 'fichiervide'
			plusObject: 'sonextrait'
			fichiervide = Concatenate

			select 'ma_segmentation'

		endif
	endfor
endfor

printline
printline votre (très belle) phrase est prète !
printline 'phrase$'

#######################
# modification hauteur

if modification_prosodique$ = "oui"

printline modification prosodique : 'modification_prosodique$'

selectObject: "Sound chain"
fin_final = Get end time
manip = To Manipulation: 0.01, 75, 600
modif_pitch = Extract pitch tier
Remove points between... 0 fin_final
Add point... 0.01 ajout_f0_en_debut
Add point... fin_final*0.25 ajout_f0_en_milieu
Add point... fin_final*0.75 ajout_f0_en_fin

select 'manip'
plus 'modif_pitch'
Replace pitch tier

select 'manip'
fichierfinal = Get resynthesis (overlap-add)


################
#modification durée:

#selectObject: "Sound chain"
#manip = To Manipulation: Extract duration tier
#Add point... 0.1 1.5

endif
################
#affichage:
selectObject: "Sound chain"
s=Get total duration
printline durée de votre phrase :  's' secondes

################
#re nommage du fichier
selectObject: "Sound chain"
Rename: filename$

