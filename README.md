# Diversification-des-Donnees-pour-l-Identification-d-Empreinte-RF
Diversification des Données pour l’Identification d’Empreinte RF


L'objectif de ce git est de reproduire une partie des resultats présentés dans l'article "Diversification des Données pour l’Identification d’Empreinte RF" soumis au GRETSI 2025. 

Le script Pluto Fig1.jl permet de reproduire la figure 1 de l'article, et le script Fig3.jl permet d'obtenir une partie des résultats du tableau 3 et génère le tableau 4.

La Figure 1 est obtenue à partir de données virtuelles généré par l'outil RiFyFi. Cet outils génère des base de données virtuelles de signaux RF (OFDM ici) complexe avec des imperfections RF. L'ajout d'imperfection est basé sur des modélisations d'imperfection de la litérature. Les bases de données crées sont composé de 5 emetteurs (parametrage des imperfections différents pour chaque emetteur) et le pourcentage indique la similarité des imperfections. Plus le pourcentage est faible plus les emetteurs sont similaires.

Chaque point de la courbe correspond à un entrainement sur une base de données avec une grande ou une faible similartité entre les émetteurs (couleur de la courbe) et un plus ou moins grand nombre de réalisation de cannaux de propagation (en abscisse) en ordonné on présente le score F1 obtenu en phase de teste avec d'autre réalisation de cannaux de propagation que celles utilisé en entrainements.


Dans le dossier Configurations des fichiers définissent les paramétrages des empreintes RF (défaut RF) des différents emetteurs pour les différentes configuration possible (5\%, 7\% et 10\%)

Pour obtenir la Figure 1, vous devrez disposer de Julia 1.8 cloner ce projet git dans votre espace de travail. 
Se déplacer dans le Dossier "Diversification ..." qui a été créé activer le package puis lancer la commande 
include("Fig1.jl")
Ensuite vous n''aurez plus qu'a attendre (assurer vous d'avoir un GPU pour permettre de réduire le temps d'execution qui est déjà assez long sur GPU plusieurs dizaine d'heure.)
Le script latex de la Figure se trouvera dans le dossier "run" créer à la racine du dossier "Diversification..."

Pour la Table 3, on propose de reproduire seulement une partie. 
Celle-ci a été généré à partir de données réelles enregistré dans nos Labo. Ces données doivent être téléchargées ICI et mise à la racine du dossier "Diversification..." 

Les dossiers intitulé Run1 servent à l'entrainement et au test et les dossier Run5 servent seulement en test.
Dans ces dossier il a plusieurs fichiers, des fichier intulé bigLabels contiennent les labels des transmetteurs pour chaque séquence des fichier bigMat. Pour chaque intitulé on retrouve l'ensemble d'entrainement et de test. 
Dans les dossiers on trouve également l'information Preamble ou Payload dans le nom des fichiers permettant de savoir de quel scénario il s'agit.

Ici nous proposons d'entrainer le réseau avec le mode préambule avec 2 tailles de bases de données 9000 signaux par transmetteurs et 45000 signaux par transmetteur et de tester ces performance grace au scenario 1 (le même qu'en entrainement) et le scenario 4 (ici run 5). Ce qui correspond 


![Texte alternatif](Image/img.png "Le titre de mon image")




