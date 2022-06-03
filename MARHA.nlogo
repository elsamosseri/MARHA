extensions [ gis ]

globals [
  clock ; horaire effectif
  heure-début-simul ; horaire auquel débute la simulation
  heure-fin-simul ; horaire auquel s'achève la simulation
  pas-de-temps ; pas de temps = 0.02 heure
  valeur-min ; valeur de départ (incluse) de la liste des horaires nécessitant un traitement spécifique
  valeur-max ; valeur de fin (non incluse) de la liste des horaires nécessitant un traitement spécifique
  cadre ; SIG - couche vecteur figurant l'emprise spatiale du modèle
  étangs-lagunes ; SIG - couche vecteur figurant les étangs et lagunes à proximité du PNM
  bathymétrie ; SIG - couche raster figurant la bathymétrie dans le périmètre du PNM
  richesses-naturelles ; SIG
  habitats ; SIG
  trait-de-côte ; SIG
  communes ; SIG
  un-mille ; SIG
  trois-cent-mètres ; SIG
  RNN-C-B ; SIG
  ZMEL ; SIG
  mouillages-forains ; SIG
  ports-plaisance ; SIG
  bouées-ZMEL ; SIG
  bouées-ZMO ; SIG
  sites-plongée ; SIG
  nb-btx-plaisance-simul ; nombre de bateaux de plaisance effectivement en jeu dans cette simulation
  nb-btx-plaisance-t ; nombre de bateaux de plaisance à l'instant t
  nb-btx-plongée-simul ; nombre de bateaux de plongée effectivement en jeu dans cette simulation
  nb-btx-plongée-t ; nombre de bateaux de plongée à l'instant t
  pic-horaire-départ-plaisance ; valeur moyenne de la distribution des horaires de départ des plaisanciers
  pic-horaire-départ-plongée ; horaire unique de départ des plongeurs
  horaires-possibles ; plage horaire possible pour la distribution des horaires de départ des plaisanciers
  bateaux-plaisance-amarrés-bouées ; somme permettant de calculer la part finale de bateaux de plaisance ayant pu s'amarrer à une bouée écologique
  bateaux-plongée-amarrés-bouées ; somme permettant de calculer la part finale de bateaux de plongée ayant pu s'amarrer à une bouée écologique
  bateaux-plaisance-amarrés-solo ; somme permettant de calculer la part finale de bateaux de plaisance ayant pu s'amarrer seuls
  bateaux-plaisance-amarrés-couple ; somme permettant de calculer la part finale de bateaux de plaisance ayant pu s'amarrer à couple
  bateaux-plongée-amarrés-solo ; somme permettant de calculer la part finale de bateaux de plongée ayant pu s'amarrer seuls
  bateaux-plongée-amarrés-couple ; somme permettant de calculer la part finale de bateaux de plongée ayant pu s'amarrer à couple
  bateaux-plaisance-ancrés ; somme permettant de calculer la part finale de bateaux de plaisance ayant ancré
  bateaux-plongée-ancrés ; somme permettant de calculer la part finale de bateaux de plongée ayant ancré
  bateaux-plaisance-cabotant ; somme permettant de calculer la part finale de bateaux de plaisance ayant caboté
  bateaux-plongée-cabotant ; somme permettant de calculer la part finale de bateaux de plongée ayant caboté
  liste-noms-secteurs ; liste des secteurs de ZMEL du PNM et de la RNN ordonnée du nord au sud
  liste-noms-ports ; liste des principaux ports d'origine des bateaux fréquentant le PNM ordonnée du nord au sud
  liste-taux-vacance-bouées-plaisance ; liste contenant pour chaque pas de temps le taux de vacance de l'ensemble des bouées destinées aux plaisanciers
  liste-taux-vacance-plongée ; liste contenant pour chaque pas de temps le taux de vacance de l'ensemble des bouées destinées aux plongeurs
  liste-horaires-effectifs ; liste enregistrant l'heure à chaque pas de temps, utilisée pour calculer la durée de saturation des bouées
  nombre-de-rotations ; décompte du nombre de rotations effectuées par les bateaux de plongée
]

turtles-own [ mobilité? ] ; "true" seulement pour les bateaux de plaisance et de plongée

breed [ bateaux-plaisance bateau-plaisance ]
breed [ bateaux-plongée bateau-plongée ]
breed [ ports port ]
breed [ secteurs-amarrage secteur-amarrage ]
breed [ secteurs-ancrage secteur-ancrage ]
breed [ bouées bouée ]
breed [ sites site ]
breed [ noms-communes nom-commune ]

bateaux-plaisance-own [
  origine ; l'un des ports
  destination ; l'un des patches correspondant à un secteur de ZMEL/ZMO ou de ZAA donné
  type-destination ; permet de distinguer la marche à suivre quand un même patch est à la fois ZMEL/ZMO et ZAA
  spot ; patch de pratique effective, que le bateau soit amarré, ancré ou cabote
  trajectoires-possibles ; sous-ensemble des patches voisins répondant à certains critères de navigation possible
  meilleure-trajectoire ; patch voisin permettant d'optimiser le déplacement
  liste-des-positions ; liste contenant les positions déjà occupées qu'il n'est pas permis de réemprunter pour atteindre sa destination
  changement-destination? ; "true" durant le pas de temps où le bateau change de destination
  amarré? ; "true" durant tout le temps où le bateau est amarré
  bouée-choisie ; bouée à laquelle le bateau est effectivement amarré
  solo/couple? ; "solo" ou "couple" selon que le bateau amarré est seul sur sa bouée ou qu'il la partage avec un autre
  ancré? ; "true" durant tout le temps où le bateau est ancré
  cabote? ; "true" durant tout le temps où le bateau cabote
  navigue? ; "true" durant tout le temps où le bateau navigue vers sa destination
  usage ; "Plaisance"
  caractéristique ; si l'usage est la plaisance, la caractéristique supplémentaire peut être "expérimenté" ou "non expérimenté"
  liste-des-destinations ; liste contenant la ou les destinations de pratique si le bateau a changé de destination
  durée-de-sortie-estimée ; hypothèse de travail concernant la durée moyenne sortie des plaisanciers à la journée
  durée-de-sortie-effective ; comptabilise la durée effective de sortie pour savoir quand déclencher le retour au port
  pratique? ; "true" durant tout le temps où le bateau pratique son activité, depuis le départ jusqu'au retour au port
  heure-début-acti ; heure de départ effective autour de la valeur moyenne
  heure-fin-acti ; heure correspondant à la fin de la sortie et au départ du spot vers le port d'origine
  heure-retour-port ; heure de retour au port
  détail-procédure ; texte permettant d'identifier l'arbitrage effectué par le bateau face à la ZMEL
]

bateaux-plongée-own [
  origine ; l'un des ports
  destination ; l'un des patches correspondant à un secteur de ZMEL/ZMO donné
  type-destination ; permet de distinguer la marche à suivre quand un même patch est à la fois ZMEL/ZMO et ZAA
  spot ; patch correspondant à la bouée d'amarrage
  trajectoires-possibles ; sous-ensemble des patches voisins répondant à certains critères de navigation possible
  meilleure-trajectoire ; patch voisin permettant d'optimiser le déplacement
  liste-des-positions ; liste contenant les positions déjà occupées qu'il n'est pas permis de réemprunter pour atteindre sa destination
  changement-destination? ; "true" durant le pas de temps où le bateau change de destination
  amarré? ; "true" durant tout le temps où le bateau est amarré
  bouée-choisie ; bouée à laquelle le bateau est effectivement amarré
  solo/couple? ; "solo" ou "couple" selon que le bateau amarré est seul sur sa bouée ou qu'il la partage avec un autre
  ancré? ; "true" durant tout le temps où le bateau est ancré
  cabote? ; "true" durant tout le temps où le bateau cabote
  navigue? ; "true" durant tout le temps où le bateau navigue vers sa destination
  usage ; "Plongée"
  caractéristique ; si l'usage est la plongée, la caractéristique supplémentaire peut être "professionnel" ou "associatif"
  liste-des-destinations ; liste contenant la ou les destinations de pratique si le bateau a changé de destination
  durée-de-sortie-estimée ; hypothèse de travail concernant la durée moyenne sortie des plongeurs par palanquée
  durée-de-sortie-effective ; comptabilise la durée effective de sortie pour savoir quand déclencher le retour au port
  pratique? ; "true" durant tout le temps où le bateau pratique son activité, depuis le départ jusqu'au retour au port
  heure-début-acti ; heure de départ effective autour de la valeur moyenne
  heure-fin-acti ; heure correspondant à la fin de la sortie et au départ du spot vers le port d'origine
  heure-retour-port ; heure de retour au port
  détail-procédure ; texte permettant d'identifier l'arbitrage effectué par le bateau face à la ZMEL
  liste-durée-de-sortie-effective ; liste renseignant la durée effective de chaque sortie d'un bateau de plongée effectuant plusieurs rotations
  liste-heure-retour-port ; liste renseignant chaque heure de retour au port d'un bateau de plongée effectuant plusieurs rotations
  liste-heure-fin-acti ; liste renseignant chaque heure de fin de sortie d'un bateau de plongée effectuant plusieurs rotations
]

ports-own [
  nom-port ; nom du port
  liste-destination-ZMEL-plaisance-bouée ; liste contenant le secteur de ZMEL/ZMO de destination de chaque bateau de plaisance amarré à une bouée
  liste-destination-ZMEL-plongée-bouée ; liste contenant le secteur de ZMEL/ZMO de destination de chaque bateau de plongée amarré à une bouée
  liste-destination-ZMEL-plaisance-ancre ; liste contenant le secteur de destination de chaque bateau de plaisance ancré dans la ZMEL/ZMO
  liste-destination-ZMEL-plongée-ancre ; liste contenant le secteur de destination de chaque bateau de plongée ancré dans la ZMEL/ZMO
  liste-destination-ZAA-plaisance ; liste contenant le secteur de destination de chaque bateau de plaisance ancré dans une ZAA
  liste-destination-ZAA-plongée ; liste contenant le secteur de destination de chaque bateau de plongée ancré dans une ZAA
]

secteurs-amarrage-own [
  nom-secteur ; nom du secteur de ZMEL/ZMO
  liste-provenance-plaisance-bouée ; liste contenant le port d'origine de chaque bateau de plaisance amarré à une bouée
  liste-provenance-plongée-bouée ; liste contenant le port d'origine de chaque bateau de plongée amarré à une bouée
  liste-provenance-plaisance-ancre ; liste contenant le port d'origine de chaque bateau de plaisance ancré
  liste-provenance-plongée-ancre ; liste contenant le port d'origine de chaque bateau de plongée ancré
  liste-horaire-critique ; liste contenant les horaires auxquels le taux d'occupation des bouées est supérieur à 95 % tout usage confondu
  liste-taux-occupation-plaisance ; liste contenant pour chaque pas de temps le taux d'occupation des bouées dont l'usage est la plaisance
  liste-taux-occupation-plongée ; liste contenant pour chaque pas de temps le taux d'occupation des bouées dont l'usage est la plongée
  liste-durée-taux-saturation-plaisance ; liste contenant les horaires auxquels le taux d'occupation des bouées destinées à la plaisance est supérieur ou égal à 100 %
  liste-durée-taux-saturation-plongée ; liste contenant les horaires auxquels le taux d'occupation des bouées destinées à la plongée est supérieur ou égal à 100 %
]

secteurs-ancrage-own [
  nom-secteur ; nom du secteur d'ancrage
  liste-provenance-plaisance ; liste contenant le port d'origine de chaque bateau de plaisance ancré
  liste-provenance-plongée ; liste contenant le port d'origine de chaque bateau de plongée ancré
]

bouées-own [
  usage-bouée ; destination de la bouée : "Plaisance" ou "Plongée"
  secteur-bouée ; nom du secteur de ZMEL/ZMO auquel appartient la bouée
  année-bouée ; année de mise en service de la bouée : 2011 ou 2022
  nombre-bateaux-possible ; nombre maximum de bateaux pouvant s'amarrer à la bouée
  nombre-bateaux-effectif ; nombre effectif de bateaux amarrés à la bouée à chaque pas de temps
  type-usager ; type d'usager effectivement amarré à la bouée : "Plaisance" ou "Plongée"
  caractéristique-usager ; caractéristique supplémentaire de l'usager effectivement amarré à la bouée
  identifiant-usager ; liste du/des identifiant(s) du/des usager(s) effectivement amarré(s) à la bouée
]

sites-own [ nom-site ] ; nom du site de plongée

patches-own [
  bathy ; profondeur
  richesse ; niveau de richesse naturelle
  biocénose ; type d'habitat "*"
  commune ; commune d'appartenance "*"
  mille ; = 1 si le patch est situé dans la bande des 1 milles nautiques
  trois-cent ; = 1 si le patch est situé dans la bande des 300 mètres
  RNN ; affiche "RNN" si le patch est inclus dans le périmètre de la Réserve Naturelle Marine de Cerbère-Banyuls
  secteur-ZMEL ; nom du secteur de ZMEL/ZMO auquel appartient le patch
  secteur-ZAA ; nom du secteur de ZAA auquel appartient le patch
  zone-ZAA ; situation "nord" ou "sud" du secteur de ZAA auquel appartient le patch
  nombre-bateaux-plaisance-ancrés ; pour vérifier à chaque pas de temps le temps le nombre de bateaux ancrés (ancré? = true)
  nombre-bateaux-plongée-ancrés ; pour vérifier à chaque pas de temps le temps le nombre de bateaux ancrés (ancré? = true)
  nombre-bateaux-plaisance-cabotant ; pour vérifier à chaque pas de temps le temps le nombre de bateaux cabotant (cabote? = true)
  nombre-bateaux-plongée-cabotant ; pour vérifier à chaque pas de temps le temps le nombre de bateaux cabotant (cabote? = true)
]

; Note sur les dimensions du modèle
; Si l'on veut expérimenter un pas de temps plus court/long d'un facteur p,
; donc diviser/multiplier le pas de temps actuel de 0.02 par p,
; il faut multiplier/diviser la valeur linéaire de la grille du même facteur.
; En langage Netlogo, cela revient à modifier les valeurs minimales et maximales
; des coordonnées de la grille, c'est-à-dire modifier la granularité spatiale, le nombre de patches.
; Dans les Settings, max-pxcor et max-pycor valent 159 par défaut, en cohérence avec
; la vitesse de déplacement minimale des bateaux : 5 nœuds.
; Pour obtenir la nouvelle valeur de max-pxcor et max-pycor, il faut effectuer le calcul suivant :
; nouveau max-pxcor = nouveau max-pycor = 0.02 / nouveau pas de temps * 159
; ex : 0.02 / 0.012  * 159 = 265

to setup

  clear-all

  setup-GIS
  setup-globals
  setup-bateaux
  setup-bouées
  setup-horaires-possibles
  setup-listes

  set clock heure-début-simul
  output-print clock

  reset-ticks

end

to setup-globals

  set heure-début-simul 7.00
  set heure-fin-simul 24.00
  set pic-horaire-départ-plaisance 11.00
  ; le pas de temps doit être défini comme 0.60 divisé par un entier
  set pas-de-temps 0.60 / 30 ; 0.60 / 30 = 0.02 ; 0.60 / 50 = 0.012
  set valeur-min 0.60 - pas-de-temps
  set valeur-max 24.00

end

to setup-bateaux

  if saison = "moyenne"
  [
  set nb-btx-plaisance-Leucate 5
  set nb-btx-plaisance-Barcares 5
  set nb-btx-plaisance-Sainte-marie-la-mer 5
  set nb-btx-plaisance-Canet-en-Roussillon 34
  set nb-btx-plaisance-Saint-Cyprien 141
  set nb-btx-plaisance-Argelès-sur-mer 170
  set nb-btx-plaisance-Collioure 10
  set nb-btx-plaisance-Port-vendres 58
  set nb-btx-plaisance-Banyuls-sur-mer 49
  set nb-btx-plaisance-Cerbere 10
  ]

  if saison = "haute"
  [
  set nb-btx-plaisance-Leucate 5
  set nb-btx-plaisance-Barcares 5
  set nb-btx-plaisance-Sainte-marie-la-mer 5
  set nb-btx-plaisance-Canet-en-Roussillon 36
  set nb-btx-plaisance-Saint-Cyprien 150
  set nb-btx-plaisance-Argelès-sur-mer 181
  set nb-btx-plaisance-Collioure 10
  set nb-btx-plaisance-Port-vendres 62
  set nb-btx-plaisance-Banyuls-sur-mer 52
  set nb-btx-plaisance-Cerbere 10
  ]

  set nombre-bateaux-plaisance
  nb-btx-plaisance-Leucate +
  nb-btx-plaisance-Barcares +
  nb-btx-plaisance-Sainte-marie-la-mer +
  nb-btx-plaisance-Canet-en-Roussillon +
  nb-btx-plaisance-Saint-Cyprien +
  nb-btx-plaisance-Argelès-sur-mer +
  nb-btx-plaisance-Collioure +
  nb-btx-plaisance-Port-vendres +
  nb-btx-plaisance-Banyuls-sur-mer +
  nb-btx-plaisance-Cerbere

  set-default-shape bateaux-plaisance "boat"
  create-bateaux-plaisance ( nombre-bateaux-plaisance ) [
    set usage "Plaisance"
    set origine nobody
    set destination nobody
    set type-destination ""
    set mobilité? true
    set changement-destination? false
    set ancré? false
    set cabote? false
    set navigue? false
    set color pink
    set pratique? false
    set durée-de-sortie-estimée 5.30
    set durée-de-sortie-effective 0.00
    set heure-retour-port 0.00
  ]

;  ask n-of x bateaux-plaisance [set caractéristique "expérimenté"]
;  ask bateaux-plaisance with [caractéristique != "expérimenté"] [set caractéristique "non expérimenté"]
  setup-origine-plaisance
  ask bateaux-plaisance [
    move-to origine
    set amarré? true
  ]

  setup-destination-plaisance
  ask bateaux-plaisance [
    set liste-des-destinations []
    set liste-des-destinations fput destination liste-des-destinations
    set liste-des-positions []
    set liste-des-positions fput patch-here liste-des-positions
  ]
  set nb-btx-plaisance-simul count bateaux-plaisance

  if saison = "moyenne"
  [
  set nb-btx-plongée-Leucate 0
  set nb-btx-plongée-Barcares 0
  set nb-btx-plongée-Sainte-marie-la-mer 0
  set nb-btx-plongée-Canet-en-Roussillon 0
  set nb-btx-plongée-Saint-Cyprien 1
  set nb-btx-plongée-Argelès-sur-mer 3
  set nb-btx-plongée-Collioure 0
  set nb-btx-plongée-Port-vendres 2
  set nb-btx-plongée-Banyuls-sur-mer 4
  set nb-btx-plongée-Cerbere 1
  ]

  if saison = "haute"
  [
  set nb-btx-plongée-Leucate 0
  set nb-btx-plongée-Barcares 0
  set nb-btx-plongée-Sainte-marie-la-mer 0
  set nb-btx-plongée-Canet-en-Roussillon 0
  set nb-btx-plongée-Saint-Cyprien 1
  set nb-btx-plongée-Argelès-sur-mer 5
  set nb-btx-plongée-Collioure 1
  set nb-btx-plongée-Port-vendres 3
  set nb-btx-plongée-Banyuls-sur-mer 6
  set nb-btx-plongée-Cerbere 2
  ]

  set nombre-bateaux-plongée
  nb-btx-plongée-Leucate +
  nb-btx-plongée-Barcares +
  nb-btx-plongée-Sainte-marie-la-mer +
  nb-btx-plongée-Canet-en-Roussillon +
  nb-btx-plongée-Saint-Cyprien +
  nb-btx-plongée-Argelès-sur-mer +
  nb-btx-plongée-Collioure +
  nb-btx-plongée-Port-vendres +
  nb-btx-plongée-Banyuls-sur-mer +
  nb-btx-plongée-Cerbere

  set-default-shape bateaux-plongée "boat"
    create-bateaux-plongée ( nombre-bateaux-plongée ) [
    set usage "Plongée"
    set origine nobody
    set destination nobody
    set type-destination ""
    set mobilité? true
    set changement-destination? false
    set ancré? false
    set cabote? false
    set navigue? false
    set color grey
    set pratique? false
    set durée-de-sortie-estimée 2.00
    set durée-de-sortie-effective 0.00
    set heure-retour-port 0.00
   ]

  ask n-of precision ( 64 * count bateaux-plongée / 100 ) 0 bateaux-plongée [ set caractéristique "professionnel" ]
  ask bateaux-plongée with [ caractéristique != "professionnel" ] [ set caractéristique "associatif" ]
  setup-origine-plongée
  ask bateaux-plongée [
    move-to origine
    set amarré? true
  ]

  setup-destination-plongée
  ask bateaux-plongée [
    set liste-des-destinations []
    set liste-des-destinations fput destination liste-des-destinations
    set liste-des-positions []
    set liste-des-positions fput patch-here liste-des-positions
    set liste-durée-de-sortie-effective []
    set liste-heure-retour-port []
    set liste-heure-fin-acti []
  ]
  set nb-btx-plongée-simul count bateaux-plongée

end

to setup-origine-plaisance

  ask n-of nb-btx-plaisance-Leucate bateaux-plaisance with [ origine = nobody ]
  [ set origine one-of ports with [ nom-port = "Leucate" ] ]
  ask n-of nb-btx-plaisance-Barcares bateaux-plaisance with [ origine = nobody ]
  [ set origine one-of ports with [ nom-port = "Barcares" ] ]
  ask n-of nb-btx-plaisance-Sainte-marie-la-mer bateaux-plaisance with [ origine = nobody ]
  [ set origine one-of ports with [ nom-port = "Sainte-marie-la-mer" ] ]
  ask n-of nb-btx-plaisance-Canet-en-Roussillon bateaux-plaisance with [ origine = nobody ]
  [ set origine one-of ports with [ nom-port = "Canet-en-Roussillon" ] ]
  ask n-of nb-btx-plaisance-Saint-Cyprien bateaux-plaisance with [ origine = nobody ]
  [ set origine one-of ports with [ nom-port = "Saint-Cyprien" ] ]
  ask n-of nb-btx-plaisance-Argelès-sur-mer bateaux-plaisance with [ origine = nobody ]
  [ set origine one-of ports with [ nom-port = "Argelès-sur-mer" ] ]
  ask n-of nb-btx-plaisance-Collioure bateaux-plaisance with [ origine = nobody ]
  [ set origine one-of ports with [ nom-port = "Collioure" ] ]
  ask n-of nb-btx-plaisance-Port-vendres bateaux-plaisance with [ origine = nobody ]
  [ set origine one-of ports with [ nom-port = "Port-vendres" ] ]
  ask n-of nb-btx-plaisance-Banyuls-sur-mer bateaux-plaisance with [ origine = nobody ]
  [ set origine one-of ports with [ nom-port = "Banyuls-sur-mer" ] ]
  ask n-of nb-btx-plaisance-Cerbere bateaux-plaisance with [ origine = nobody ]
  [ set origine one-of ports with [ nom-port = "Cerbere" ] ]

end

to setup-origine-plongée

  ask n-of nb-btx-plongée-Leucate bateaux-plongée with [ origine = nobody ]
  [ set origine one-of ports with [ nom-port = "Leucate" ] ]
  ask n-of nb-btx-plongée-Barcares bateaux-plongée with [ origine = nobody ]
  [ set origine one-of ports with [ nom-port = "Barcares" ] ]
  ask n-of nb-btx-plongée-Sainte-marie-la-mer bateaux-plongée with [ origine = nobody ]
  [ set origine one-of ports with [ nom-port = "Sainte-marie-la-mer" ] ]
  ask n-of nb-btx-plongée-Canet-en-Roussillon bateaux-plongée with [ origine = nobody ]
  [ set origine one-of ports with [ nom-port = "Canet-en-Roussillon" ] ]
  ask n-of nb-btx-plongée-Saint-Cyprien bateaux-plongée with [ origine = nobody ]
  [ set origine one-of ports with [ nom-port = "Saint-Cyprien" ] ]
  ask n-of nb-btx-plongée-Argelès-sur-mer bateaux-plongée with [ origine = nobody ]
  [ set origine one-of ports with [ nom-port = "Argelès-sur-mer" ] ]
  ask n-of nb-btx-plongée-Collioure bateaux-plongée with [ origine = nobody ]
  [ set origine one-of ports with [ nom-port = "Collioure" ] ]
  ask n-of nb-btx-plongée-Port-vendres bateaux-plongée with [ origine = nobody ]
  [ set origine one-of ports with [ nom-port = "Port-vendres" ] ]
  ask n-of nb-btx-plongée-Banyuls-sur-mer bateaux-plongée with [ origine = nobody ]
  [ set origine one-of ports with [ nom-port = "Banyuls-sur-mer" ] ]
  ask n-of nb-btx-plongée-Cerbere bateaux-plongée with [ origine = nobody ]
  [ set origine one-of ports with [ nom-port = "Cerbere" ] ]

end

to setup-destination-plaisance

  if vent-dominant = "tramontane"
  [ if force-du-vent = "forte"
    [ ask n-of precision ( 50 * count bateaux-plaisance with [ destination = nobody ] / 100 ) 0
      bateaux-plaisance with [ destination = nobody ]
      [ die ]
      ask n-of precision ( 50 * count bateaux-plaisance with [ destination = nobody ] / 100 ) 0
      bateaux-plaisance with [ destination = nobody ]
      [ set destination one-of patches with [ secteur-ZMEL = "Bear" ]
        set type-destination "ZMEL/ZMO" ]
      ask bateaux-plaisance with [ destination = nobody ]
      [ set destination one-of patches with [
        secteur-ZAA = "Bear" and zone-ZAA = "nord" and secteur-ZMEL = 0 ]
        set type-destination "ZAA" ]
    ]
    if force-du-vent = "modérée"
    [ ask n-of precision ( 50 * count bateaux-plaisance with [ destination = nobody ] / 100 ) 0
      bateaux-plaisance with [ destination = nobody ]
      [ set destination one-of patches with [
        secteur-ZAA = "Bear" and zone-ZAA = "nord" and secteur-ZMEL = 0 ]
        set type-destination "ZAA" ]
      ask n-of precision ( 70 * count bateaux-plaisance with [ destination = nobody ] / 100 ) 0
      bateaux-plaisance with [ destination = nobody ]
      [ set destination one-of patches with [ secteur-ZMEL = "Bear" ]
        set type-destination "ZMEL/ZMO" ]
      ask bateaux-plaisance with [ destination = nobody ]
      [ set destination one-of patches with [ secteur-ZMEL = "Moulade"
        or secteur-ZMEL = "Mauresque" ]
        set type-destination "ZMEL/ZMO" ]
    ]
    if force-du-vent = "insignifiante"
    [ ask n-of precision ( 50 * count bateaux-plaisance with [ destination = nobody ] / 100 ) 0
      bateaux-plaisance with [ destination = nobody ]
      [ set destination one-of patches with [ secteur-ZAA = "Bear"
        or secteur-ZAA = "Mauresque" and secteur-ZMEL = 0 ]
        set type-destination "ZAA" ]
      ask n-of precision ( 70 * count bateaux-plaisance with [ destination = nobody and
        [ nom-port ] of origine != "Banyuls-sur-mer" and [ nom-port ] of origine != "Cerbere" ] / 100 ) 0
        bateaux-plaisance with [ destination = nobody and
        [ nom-port ] of origine != "Banyuls-sur-mer" and [ nom-port ] of origine != "Cerbere" ]
      [ set destination one-of patches with [ secteur-ZMEL = "Bear" ]
        set type-destination "ZMEL/ZMO" ]
      ask bateaux-plaisance with [ destination = nobody and
        [ nom-port ] of origine != "Banyuls-sur-mer" and [ nom-port ] of origine != "Cerbere" ]
      [ set destination one-of patches with [ secteur-ZMEL = "Mauresque" ]
        set type-destination "ZMEL/ZMO" ]
      ask n-of precision ( 90 * count bateaux-plaisance with [ destination = nobody ] / 100 ) 0
      bateaux-plaisance with [ destination = nobody ]
      [ set destination one-of patches with [ secteur-ZMEL = "Bear"
        or secteur-ZMEL = "Cerbere"
        or secteur-ZMEL = "Abeille"
        or secteur-ZMEL = "Peyrefite" ]
        set type-destination "ZMEL/ZMO" ]
      ask bateaux-plaisance with [ destination = nobody ]
      [ set destination one-of patches with [ secteur-ZMEL = "Moulade"
        or secteur-ZMEL = "Mauresque" ]
        set type-destination "ZMEL/ZMO" ]
    ]
  ]
  if vent-dominant = "marin"
  [ if force-du-vent = "forte"
    [ ask n-of precision ( 50 * count bateaux-plaisance with [ destination = nobody ] / 100 ) 0
      bateaux-plaisance with [ destination = nobody ]
      [ die ]
      ask n-of precision ( 50 * count bateaux-plaisance with [ destination = nobody ] / 100 ) 0
      bateaux-plaisance with [ destination = nobody ]
      [ set destination one-of patches with [ secteur-ZMEL = "Bear" ]
        set type-destination "ZMEL/ZMO" ]
      ask bateaux-plaisance with [ destination = nobody ]
      [ set destination one-of patches with [
        secteur-ZAA = "Bear" and zone-ZAA = "sud" and secteur-ZMEL = 0 ]
        set type-destination "ZAA" ]
    ]
    if force-du-vent = "modérée"
    [ ask n-of precision ( 50 * count bateaux-plaisance with [ destination = nobody ] / 100 ) 0
      bateaux-plaisance with [ destination = nobody ]
      [ set destination one-of patches with [
        secteur-ZAA = "Bear" and zone-ZAA = "sud" and secteur-ZMEL = 0 ]
        set type-destination "ZAA" ]
      ask n-of precision ( 70 * count bateaux-plaisance with [ destination = nobody ] / 100 ) 0
      bateaux-plaisance with [ destination = nobody ]
      [ set destination one-of patches with [ secteur-ZMEL = "Bear" ]
        set type-destination "ZMEL/ZMO" ]
      ask bateaux-plaisance with [ destination = nobody ]
      [ set destination one-of patches with [ secteur-ZMEL = "Moulade"
        or secteur-ZMEL = "Mauresque" ]
        set type-destination "ZMEL/ZMO" ]
    ]
    if force-du-vent = "insignifiante"
    [ ask n-of precision ( 50 * count bateaux-plaisance with [ destination = nobody ] / 100 ) 0
      bateaux-plaisance with [ destination = nobody ]
      [ set destination one-of patches with [ secteur-ZAA = "Bear"
        or secteur-ZAA = "Mauresque" and secteur-ZMEL = 0 ]
        set type-destination "ZAA" ]
      ask n-of precision ( 70 * count bateaux-plaisance with [ destination = nobody and
        [ nom-port ] of origine != "Banyuls-sur-mer" and [ nom-port ] of origine != "Cerbere" ] / 100 ) 0
      bateaux-plaisance with [ destination = nobody and
        [ nom-port ] of origine != "Banyuls-sur-mer" and [ nom-port ] of origine != "Cerbere" ]
      [ set destination one-of patches with [ secteur-ZMEL = "Bear" ]
        set type-destination "ZMEL/ZMO" ]
      ask bateaux-plaisance with [ destination = nobody and
        [ nom-port ] of origine != "Banyuls-sur-mer" and [ nom-port ] of origine != "Cerbere" ]
      [ set destination one-of patches with [ secteur-ZMEL = "Mauresque" ]
        set type-destination "ZMEL/ZMO" ]
      ask n-of precision ( 90 * count bateaux-plaisance with [ destination = nobody ] / 100 ) 0
      bateaux-plaisance with [ destination = nobody ]
      [ set destination one-of patches with [ secteur-ZMEL = "Bear"
        or secteur-ZMEL = "Cerbere"
        or secteur-ZMEL = "Abeille"
        or secteur-ZMEL = "Peyrefite" ]
        set type-destination "ZMEL/ZMO" ]
      ask bateaux-plaisance with [ destination = nobody ]
      [ set destination one-of patches with [ secteur-ZMEL = "Moulade"
        or secteur-ZMEL = "Mauresque" ]
        set type-destination "ZMEL/ZMO" ]
    ]
  ]

end

to setup-destination-plongée

  if vent-dominant = "tramontane" or vent-dominant = "marin"
  [ if force-du-vent = "forte"
    [ if saison = "haute"
      [ ask n-of precision ( 80 * count bateaux-plongée with [ destination = nobody and
        [ nom-port ] of origine = "Saint-Cyprien" or [ nom-port ] of origine = "Argelès-sur-mer" ] / 100 ) 0
        bateaux-plongée with [ destination = nobody and
          [ nom-port ] of origine = "Saint-Cyprien" or [ nom-port ] of origine = "Argelès-sur-mer" ]
        [ set destination one-of patches with [ secteur-ZMEL = "Bear" ]
          set type-destination "ZMEL/ZMO" ]
        ask bateaux-plongée with [ destination = nobody and
          [ nom-port ] of origine = "Saint-Cyprien" or [ nom-port ] of origine = "Argelès-sur-mer" ]
        [ die ]
      ]
      if saison = "moyenne"
      [ ask n-of precision ( 50 * count bateaux-plongée with [ destination = nobody and
        [ nom-port ] of origine = "Saint-Cyprien" or [ nom-port ] of origine = "Argelès-sur-mer" ] / 100 ) 0
        bateaux-plongée with [ destination = nobody and
          [ nom-port ] of origine = "Saint-Cyprien" or [ nom-port ] of origine = "Argelès-sur-mer" ]
        [ set destination one-of patches with [ secteur-ZMEL = "Bear" ]
          set type-destination "ZMEL/ZMO" ]
        ask bateaux-plongée with [ destination = nobody and
          [ nom-port ] of origine = "Saint-Cyprien" or [ nom-port ] of origine = "Argelès-sur-mer" ]
        [ die ]
      ]
      ask bateaux-plongée with [ destination = nobody and [ nom-port ] of origine = "Port-vendres" or
        [ nom-port ] of origine = "Banyuls-sur-mer" or [ nom-port ] of origine = "Collioure" ]
      [ set destination one-of patches with [ secteur-ZMEL = "Bear" ]
        set type-destination "ZMEL/ZMO" ]
      ask bateaux-plongée with [ destination = nobody and [ nom-port ] of origine = "Cerbere" ]
      [ set destination one-of patches with [ secteur-ZMEL = "Abeille"
        or secteur-ZMEL = "Peyrefite"
        or secteur-ZMEL = "Cerbere" ]
        set type-destination "ZMEL/ZMO" ]
    ]
    if force-du-vent = "modérée"
    [ ask n-of precision ( 50 * count bateaux-plongée with [ destination = nobody and
      [ nom-port ] of origine = "Saint-Cyprien" or [ nom-port ] of origine = "Argelès-sur-mer" ] / 100 ) 0
      bateaux-plongée with [ destination = nobody and
        [ nom-port ] of origine = "Saint-Cyprien" or [ nom-port ] of origine = "Argelès-sur-mer" ]
      [ set destination one-of patches with [ secteur-ZMEL = "Moulade" ]
        set type-destination "ZMEL/ZMO" ]
      ask bateaux-plongée with [ destination = nobody and
        [ nom-port ] of origine = "Saint-Cyprien" or [ nom-port ] of origine = "Argelès-sur-mer" ]
      [ set destination one-of patches with [ secteur-ZMEL = "Bear" ]
        set type-destination "ZMEL/ZMO" ]
      ask bateaux-plongée with [ destination = nobody and [ nom-port ] of origine = "Port-vendres" or
        [ nom-port ] of origine = "Banyuls-sur-mer" or [ nom-port ] of origine = "Collioure" ]
      [ set destination one-of patches with [ secteur-ZMEL = "Bear"
        or secteur-ZMEL = "Abeille"
        or secteur-ZMEL = "Peyrefite"
        or secteur-ZMEL = "Moulade" ]
        set type-destination "ZMEL/ZMO" ]
      ask bateaux-plongée with [ destination = nobody and [ nom-port ] of origine = "Cerbere" ]
      [ set destination one-of patches with [ secteur-ZMEL = "Abeille"
        or secteur-ZMEL = "Peyrefite"
        or secteur-ZMEL = "Cerbere" ]
        set type-destination "ZMEL/ZMO" ]
    ]
    if force-du-vent = "insignifiante"
    [ ask bateaux-plongée with [ destination = nobody and [ nom-port ] of origine = "Saint-Cyprien" ]
      [ set destination one-of patches with [ secteur-ZMEL = "Moulade"
        or secteur-ZMEL = "Mauresque" ]
        set type-destination "ZMEL/ZMO" ]
      ask n-of precision ( 40 * count bateaux-plongée with [ destination = nobody and
        [ nom-port ] of origine = "Argelès-sur-mer" ] / 100 ) 0
      bateaux-plongée with [ destination = nobody and
        [ nom-port ] of origine = "Argelès-sur-mer" ]
      [ set destination one-of patches with [ secteur-ZMEL = "Bear" ]
        set type-destination "ZMEL/ZMO" ]
      ask n-of precision ( 50 * count bateaux-plongée with [ destination = nobody and
        [ nom-port ] of origine = "Argelès-sur-mer" ] / 100 ) 0
      bateaux-plongée with [ destination = nobody and
        [ nom-port ] of origine = "Argelès-sur-mer" ]
      [ set destination one-of patches with [ secteur-ZMEL = "Abeille"
        or secteur-ZMEL = "Peyrefite" ]
        set type-destination "ZMEL/ZMO" ]
      ask bateaux-plongée with [ destination = nobody and
        [ nom-port ] of origine = "Argelès-sur-mer" ]
      [ set destination one-of patches with [ secteur-ZMEL = "Moulade"
        or secteur-ZMEL = "Mauresque" ]
        set type-destination "ZMEL/ZMO" ]
      ask n-of precision ( 50 * count bateaux-plongée with [ destination = nobody and
        [ nom-port ] of origine = "Port-vendres" or [ nom-port ] of origine = "Collioure" ] / 100 ) 0
      bateaux-plongée with [ destination = nobody and
        [ nom-port ] of origine = "Port-vendres" or [ nom-port ] of origine = "Collioure" ]
      [ set destination one-of patches with [ secteur-ZMEL = "Bear" ]
        set type-destination "ZMEL/ZMO" ]
      ask bateaux-plongée with [ destination = nobody and
        [ nom-port ] of origine = "Port-vendres" or [ nom-port ] of origine = "Collioure" ]
      [ set destination one-of patches with [ secteur-ZMEL = "Abeille"
        or secteur-ZMEL = "Peyrefite" ]
        set type-destination "ZMEL/ZMO" ]
      ask bateaux-plongée with [ destination = nobody and [ nom-port ] of origine = "Banyuls-sur-mer" ]
      [ set destination one-of patches with [ secteur-ZMEL = "Abeille"
        or secteur-ZMEL = "Peyrefite" ]
        set type-destination "ZMEL/ZMO" ]
      ask bateaux-plongée with [ destination = nobody and [ nom-port ] of origine = "Cerbere" ]
      [ set destination one-of patches with [ secteur-ZMEL = "Abeille"
        or secteur-ZMEL = "Peyrefite"
        or secteur-ZMEL = "Cerbere" ]
        set type-destination "ZMEL/ZMO" ]
    ]
  ]

end

to setup-bouées

  ask bouées with [ usage-bouée = "Plaisance" ] [ set nombre-bateaux-possible 1 ]
  ask bouées with [ usage-bouée = "Plongée" ] [ set nombre-bateaux-possible 2 ]
  ask bouées with [
    usage-bouée = "Plongée" or
    usage-bouée = "Plaisance" ]
  [ set nombre-bateaux-effectif 0 ]

; A activer uniquement pour faire tourner les scénarios contrefactuels, avant redimensionnement de la ZMEL
  ask bouées with [ année-bouée = 2022 ] [ die ]

end

to setup-horaires-possibles

  set horaires-possibles ( range heure-début-simul heure-fin-simul pas-de-temps )
  ( foreach horaires-possibles
    [ ? ->
      ifelse ( precision ? 2 - floor precision ? 2 ) > 0.59
      [ set horaires-possibles remove ? horaires-possibles ]
      [ set ? precision ? 2 ]
    ]
  )

  ask bateaux-plaisance
  [ set heure-début-acti random-normal-in-bounds pic-horaire-départ-plaisance 1 8.00 16.00 horaires-possibles ]

  ask bateaux-plongée
  [ set heure-début-acti 9.00 ]

end

to setup-listes

  set liste-noms-secteurs
  [ "Moulade" "Mauresque" "Bear" "Abeille" "Peyrefite" "Cerbere" ]
  set liste-noms-ports
  [ "Leucate" "Barcares" "Sainte-marie-la-mer" "Canet-en-Roussillon" "Saint-Cyprien"
    "Argelès-sur-mer" "Collioure" "Port-vendres" "Banyuls-sur-mer" "Cerbere" ]

  ask secteurs-amarrage
  [
    set liste-provenance-plaisance-bouée []
    set liste-provenance-plongée-bouée []
    set liste-provenance-plaisance-ancre []
    set liste-provenance-plongée-ancre []
    set liste-horaire-critique []
    set liste-taux-occupation-plaisance []
    set liste-taux-occupation-plongée []
    set liste-durée-taux-saturation-plaisance []
    set liste-durée-taux-saturation-plongée []
  ]

  ask secteurs-ancrage
  [
    set liste-provenance-plaisance []
    set liste-provenance-plongée []
  ]

  ask ports
  [
    set liste-destination-ZMEL-plaisance-bouée []
    set liste-destination-ZMEL-plongée-bouée []
    set liste-destination-ZMEL-plaisance-ancre []
    set liste-destination-ZMEL-plongée-ancre []
    set liste-destination-ZAA-plaisance []
    set liste-destination-ZAA-plongée []
  ]

  ask bouées
  [
    set identifiant-usager []
  ]

  set liste-taux-vacance-bouées-plaisance []
  set liste-taux-vacance-plongée []
  set liste-horaires-effectifs []

end

to go

;  no-display
  dérouler-le-temps
  initier-activité
  pratiquer-activité
  stocker-résultats
;  visualiser-résultats

  ifelse clock = 0.00
  [
;    display
    stop ]
  [ tick ]

end

to dérouler-le-temps

  clear-output
  ifelse member? clock ( range valeur-min valeur-max )
  ; 0.40 = variable utile à la conversion de la durée en heure
  [ set clock precision ( clock + 0.40 + pas-de-temps ) 2 ]
  [ set clock precision ( clock + pas-de-temps ) 2 ]
  if clock = valeur-max
  [ set clock 0.00 ]
  output-print clock

  set liste-horaires-effectifs lput clock liste-horaires-effectifs

end

to initier-activité

  ask turtles with [ mobilité? and heure-début-acti = clock ]
  [ set pratique? true
    set navigue? true ]

end

to pratiquer-activité

  ask turtles with [ mobilité? and pratique? ]
  [ ifelse member? durée-de-sortie-effective ( range valeur-min valeur-max )
    [ set durée-de-sortie-effective precision ( durée-de-sortie-effective + 0.40 + pas-de-temps ) 2 ]
    [ set durée-de-sortie-effective precision ( durée-de-sortie-effective + pas-de-temps ) 2 ]
    if durée-de-sortie-effective < durée-de-sortie-estimée and navigue?
    [ sortir-en-mer ]
    if durée-de-sortie-effective = durée-de-sortie-estimée
    [ set heure-fin-acti clock
      if navigue?
      [ set spot patch-here ]
      set destination origine
      set liste-des-positions []
    ]
    if durée-de-sortie-effective > durée-de-sortie-estimée
    [ if navigue? = false
      [ set navigue? true ]
      rentrer-au-port ]
  ]

end

to sortir-en-mer

  ifelse distance origine = 0 or changement-destination? = true
  [ naviguer-au-bord ]
  [ ifelse distance destination > 5
    [ repeat 3 ; pour simuler une vitesse de 15 noeuds
      [ naviguer-au-large ] ]
    [ if type-destination = "ZMEL/ZMO"
      [ ifelse distance destination > 1
        [ approcher-la-ZMEL ]
        [ évaluer-la-ZMEL ]
      ]
      if type-destination = "ZAA"
      [ ifelse distance destination > 1
        [ approcher-la-ZAA ] ; Zone d'Ancrage Autorisé
        [ évaluer-la-ZAA ]
      ]
    ]
  ]

end

to naviguer-au-bord

  set trajectoires-possibles neighbors with [ trois-cent = 1 ]
  set meilleure-trajectoire min-one-of trajectoires-possibles [ distance [ destination ] of myself ]
  move-to meilleure-trajectoire
  set liste-des-positions lput meilleure-trajectoire liste-des-positions
  if amarré? = true [ set amarré? false ]
  if changement-destination? = true [ set changement-destination? false ]
  set pen-size 0.1
  pen-down

end

; heuristique
to naviguer-au-large

  ifelse any? neighbors with
  [ mille = 1 and trois-cent != 1 and
    member? self [ liste-des-positions ] of myself = false and
    not any? neighbors with [ pcolor = 53 ] ] ; pcolor = 53 -> côte
  [ set trajectoires-possibles neighbors with
    [ mille = 1 and trois-cent != 1 and
      member? self [ liste-des-positions ] of myself = false and
      not any? neighbors with [ pcolor = 53 ] ] ] ; pcolor = 53 -> côte
  [ set trajectoires-possibles neighbors with
    [ trois-cent = 1 and
      member? self [ liste-des-positions ] of myself = false and
      not any? neighbors with [ pcolor = 53 ] ] ] ; pcolor = 53 -> côte
  set meilleure-trajectoire min-one-of trajectoires-possibles [ distance [ destination ] of myself ]
  if meilleure-trajectoire = nobody and any? neighbors with [ trois-cent = 1 ]
  [ set meilleure-trajectoire min-one-of neighbors with [ trois-cent = 1 ] [ distance [ destination ] of myself ] ]
  if meilleure-trajectoire = nobody and any? neighbors with [ pcolor = 103 ] ; pcolor = 103 -> "haute mer"
  [ set meilleure-trajectoire min-one-of neighbors with [ pcolor = 103 ] [ distance [ destination ] of myself ] ]
  move-to meilleure-trajectoire
  set liste-des-positions lput meilleure-trajectoire liste-des-positions
  set pen-size 0.1
  pen-down

end

to approcher-la-ZAA

  set trajectoires-possibles neighbors with [ mille = 1 ]
  set meilleure-trajectoire min-one-of trajectoires-possibles [ distance [ destination ] of myself ]
  move-to meilleure-trajectoire
  set liste-des-positions lput meilleure-trajectoire liste-des-positions
  set pen-size 0.1
  pen-down

end

to évaluer-la-ZAA

  move-to destination
  set liste-des-positions lput destination liste-des-positions
  mouillage-forain

end

to approcher-la-ZMEL

  set trajectoires-possibles neighbors with [ mille = 1 ]
  set meilleure-trajectoire min-one-of trajectoires-possibles [ distance [ destination ] of myself ]
  move-to meilleure-trajectoire
  set liste-des-positions lput meilleure-trajectoire liste-des-positions
  set pen-size 0.1
  pen-down

end

to évaluer-la-ZMEL

  move-to destination
  set liste-des-positions lput destination liste-des-positions
  if usage = "Plongée" [ évaluer-la-ZMEL-plongée ]
  if usage = "Plaisance" [ évaluer-la-ZMEL-plaisance ]

end

to évaluer-la-ZMEL-plongée

  ifelse any? bouées with [
    secteur-bouée = [ secteur-ZMEL ] of [ destination ] of myself and
    usage-bouée = [ usage ] of myself and
    nombre-bateaux-effectif = 0
  ]
    [ amarrer-bouée-dédiée-au-hasard ]
    [ ifelse any? bouées with [
      secteur-bouée = [ secteur-ZMEL ] of [ destination ] of myself and
      nombre-bateaux-effectif = 0
      ]
      [ amarrer-bouée-autre-usage-proche-bouée-dédiée ]
      [ ifelse caractéristique = "professionnel"
      [ ifelse any? bouées with [
        secteur-bouée = [ secteur-ZMEL ] of [ destination ] of myself and
        usage-bouée = [ usage ] of myself and
        nombre-bateaux-effectif < nombre-bateaux-possible and
        caractéristique-usager = [ caractéristique ] of myself ]
        [ mise-à-couple ]
        [ changement-de-destination ]
        ]
      [ ifelse random 100 < 70
        [ ifelse any? bouées with [
          secteur-bouée = [ secteur-ZMEL ] of [ destination ] of myself and
          usage-bouée = [ usage ] of myself and
          nombre-bateaux-effectif < nombre-bateaux-possible and
          caractéristique-usager = [ caractéristique ] of myself ]
          [ mise-à-couple ]
          [ changement-de-destination ]
        ]
        [ changement-de-destination ]
        ]
      ]
    ]

end

to évaluer-la-ZMEL-plaisance

  ifelse length liste-des-destinations = 1
  [ ifelse any? bouées with [
    secteur-bouée = [ secteur-ZMEL ] of [ destination ] of myself and
    usage-bouée = [ usage ] of myself and
    nombre-bateaux-effectif = 0
    ]
    [ amarrer-bouée-dédiée-proche-côte ]
    [ ifelse random 100 < 70
      [ ifelse any? bouées with [
        secteur-bouée = [ secteur-ZMEL ] of [ destination ] of myself and
        nombre-bateaux-effectif = 0
        ]
        [ amarrer-bouée-autre-usage-proche-bouée-dédiée ]
        [ ifelse random 100 < 80
          [ mouillage-forain ]
          [ changement-de-destination ]
        ]
      ]
      [ ifelse random 100 < 80
        [ mouillage-forain ]
        [ changement-de-destination ]
      ]
    ]
  ]
  [ ifelse any? bouées with [
    secteur-bouée = [ secteur-ZMEL ] of [ destination ] of myself and
    usage-bouée = [ usage ] of myself and
    nombre-bateaux-effectif = 0
  ]
    [ amarrer-bouée-dédiée-proche-côte ]
    [ ifelse random 100 < 70
      [ mouillage-forain ]
      [ cabotage ]
    ]
  ]

end

to amarrer-bouée-dédiée-au-hasard

  let bouées-possibles bouées with [
    secteur-bouée = [ secteur-ZMEL ] of [ destination ] of myself and
    usage-bouée = [ usage ] of myself and
    nombre-bateaux-effectif = 0
  ]
  set bouée-choisie one-of bouées-possibles
  move-to bouée-choisie
  set amarré? true
  set solo/couple? "solo"
  if usage = "Plongée"
  [ set bateaux-plongée-amarrés-bouées bateaux-plongée-amarrés-bouées + 1
    set bateaux-plongée-amarrés-solo bateaux-plongée-amarrés-solo + 1 ]
; cas de figure inexistant ici
;  if usage = "Plaisance"
;  [ set bateaux-plaisance-amarrés-bouées bateaux-plaisance-amarrés-bouées + 1
;    set bateaux-plaisance-amarrés-solo bateaux-plaisance-amarrés-solo + 1 ]
  set navigue? false
  ask bouée-choisie
  [ set nombre-bateaux-effectif nombre-bateaux-effectif + 1
    set caractéristique-usager [ caractéristique ] of myself
    set type-usager [ usage ] of myself
    set identifiant-usager lput [ who ] of myself identifiant-usager ]
  set spot bouée-choisie
  set détail-procédure "procédure : amarrer-bouée-dédiée-au-hasard"
  sauver-infos
  set pen-size 0.1
  pen-down

end

to amarrer-bouée-autre-usage-proche-bouée-dédiée

  let bouées-espérées bouées with [
    secteur-bouée = [ secteur-ZMEL ] of [ destination ] of myself and
    usage-bouée = [ usage ] of myself
  ]
  let bouées-possibles bouées with [
    secteur-bouée = [ secteur-ZMEL ] of [destination] of myself and
    nombre-bateaux-effectif = 0
  ]
  ifelse count bouées-espérées != 0
  [ set bouée-choisie min-one-of bouées-possibles [ distance one-of bouées-espérées ] ]
  [ set bouée-choisie one-of bouées-possibles ]
  move-to bouée-choisie
  set amarré? true
  set solo/couple? "solo"
  if usage = "Plongée"
  [ set bateaux-plongée-amarrés-bouées bateaux-plongée-amarrés-bouées + 1
    set bateaux-plongée-amarrés-solo bateaux-plongée-amarrés-solo + 1 ]
  if usage = "Plaisance"
  [ set bateaux-plaisance-amarrés-bouées bateaux-plaisance-amarrés-bouées + 1
    set bateaux-plaisance-amarrés-solo bateaux-plaisance-amarrés-solo + 1 ]
  set navigue? false
  ask bouée-choisie
  [ set nombre-bateaux-effectif nombre-bateaux-effectif + 1
    set caractéristique-usager [ caractéristique ] of myself
    set type-usager [ usage ] of myself
    set identifiant-usager lput [ who ] of myself identifiant-usager ]
  set spot bouée-choisie
  set détail-procédure "procédure : amarrer-bouée-autre-usage-proche-bouée-dédiée"
  sauver-infos
  set pen-size 0.1
  pen-down

end

to mise-à-couple

  let bouées-possibles bouées with [
    secteur-bouée = [ secteur-ZMEL ] of [ destination ] of myself and
    usage-bouée = [ usage ] of myself and
    nombre-bateaux-effectif < nombre-bateaux-possible and
    caractéristique-usager = [ caractéristique ] of myself
  ]
  set bouée-choisie one-of bouées-possibles
  move-to bouée-choisie
  set amarré? true
  set solo/couple? "couple"
  if usage = "Plongée"
  [ set bateaux-plongée-amarrés-bouées bateaux-plongée-amarrés-bouées + 1
    set bateaux-plongée-amarrés-couple bateaux-plongée-amarrés-couple + 2
    set bateaux-plongée-amarrés-solo bateaux-plongée-amarrés-solo - 1
    ask bateaux-plongée with [ bouée-choisie = [ bouée-choisie ] of myself ]
    [ set solo/couple? "couple" ]
  ]
; cas de figure inexistant ici
;  if usage = "Plaisance"
;  [ set bateaux-plaisance-amarrés-bouées bateaux-plaisance-amarrés-bouées + 1
;    set bateaux-plaisance-amarrés-couple bateaux-plaisance-amarrés-couple + 2
;    set bateaux-plaisance-amarrés-solo bateaux-plaisance-amarrés-solo - 1
;    ask bateaux-plaisance with [ bouée-choisie = [ bouée-choisie ] of myself ]
;    [ set solo/couple? "couple" ]
;  ]
  set navigue? false
  ask bouée-choisie
  [ set nombre-bateaux-effectif nombre-bateaux-effectif + 1
    set identifiant-usager lput [ who ] of myself identifiant-usager ]
  set spot bouée-choisie
  set détail-procédure "procédure : mise-à-couple"
  sauver-infos
  set pen-size 0.1
  pen-down

end

to changement-de-destination

  let bouées-possibles bouées with [
    secteur-bouée != [ secteur-ZMEL ] of [ destination ] of myself and
    usage-bouée = [ usage ] of myself
  ]
  let destinations-possibles patches with [
    member? secteur-ZMEL [ secteur-bouée ] of bouées-possibles = true
  ]
  set destination min-one-of destinations-possibles [ distance myself ]
  set liste-des-destinations lput destination liste-des-destinations
  set changement-destination? true
  set liste-des-positions []
  set liste-des-positions lput patch-here liste-des-positions

end

to amarrer-bouée-dédiée-proche-côte

  let bouées-possibles bouées with [
    secteur-bouée = [ secteur-ZMEL ] of [ destination ] of myself and
    usage-bouée = [ usage ] of myself and
    nombre-bateaux-effectif = 0
  ]
  set bouée-choisie min-one-of bouées-possibles [ distance one-of patches with [ pcolor = 53 ] ]
  move-to bouée-choisie
  set amarré? true
  set solo/couple? "solo"
  if usage = "Plaisance"
  [ set bateaux-plaisance-amarrés-bouées bateaux-plaisance-amarrés-bouées + 1
    set bateaux-plaisance-amarrés-solo bateaux-plaisance-amarrés-solo + 1 ]
; cas de figure inexistant ici
;  if usage = "Plongée"
;  [ set bateaux-plongée-amarrés-bouées bateaux-plongée-amarrés-bouées + 1
;    set bateaux-plongée-amarrés-solo bateaux-plongée-amarrés-solo + 1 ]
  set navigue? false
  ask bouée-choisie
  [ set nombre-bateaux-effectif nombre-bateaux-effectif + 1
    set caractéristique-usager [ caractéristique ] of myself
    set type-usager [ usage ] of myself
    set identifiant-usager lput [ who ] of myself identifiant-usager ]
  set spot bouée-choisie
  set détail-procédure "procédure : amarrer-bouée-dédiée-proche-côte"
  sauver-infos
  set pen-size 0.1
  pen-down

end

to mouillage-forain

  set ancré? true
  set navigue? false
  set color violet
  set spot patch-here
  if usage = "Plaisance"
  [ ask spot [ set nombre-bateaux-plaisance-ancrés nombre-bateaux-plaisance-ancrés + 1 ]
    set bateaux-plaisance-ancrés bateaux-plaisance-ancrés + 1 ]
  if usage = "Plongée"
  [ ask spot [ set nombre-bateaux-plongée-ancrés nombre-bateaux-plongée-ancrés + 1 ]
    set bateaux-plongée-ancrés bateaux-plongée-ancrés + 1 ]
  set détail-procédure "procédure : mouillage-forain"
  sauver-infos
  set pen-size 0.1
  pen-down

end

to cabotage

  set cabote? true
  set navigue? false
  set color yellow
  set spot patch-here
  if usage = "Plaisance"
  [ ask spot [ set nombre-bateaux-plaisance-cabotant nombre-bateaux-plaisance-cabotant + 1 ]
    set bateaux-plaisance-cabotant bateaux-plaisance-cabotant + 1 ]
  if usage = "Plongée"
  [ ask spot [ set nombre-bateaux-plongée-cabotant nombre-bateaux-plongée-cabotant + 1 ]
    set bateaux-plongée-cabotant bateaux-plongée-cabotant + 1 ]
  set détail-procédure "procédure : cabotage"
  set pen-size 0.1
  pen-down

end

to sauver-infos

  if amarré? = true
  [ if usage = "Plaisance"
    [ ask secteurs-amarrage with [ nom-secteur = [ secteur-bouée ] of [ bouée-choisie ] of myself ]
      [ set liste-provenance-plaisance-bouée
        lput [ nom-port ] of [ origine ] of myself liste-provenance-plaisance-bouée ]
      ask origine
      [ set liste-destination-ZMEL-plaisance-bouée
        lput [ secteur-bouée ] of [ bouée-choisie ] of myself liste-destination-ZMEL-plaisance-bouée ]
    ]
    if usage = "Plongée"
    [ ask secteurs-amarrage with [ nom-secteur = [ secteur-bouée ] of [ bouée-choisie ] of myself ]
      [ set liste-provenance-plongée-bouée
        lput [ nom-port ] of [ origine ] of myself liste-provenance-plongée-bouée ]
      ask origine
      [ set liste-destination-ZMEL-plongée-bouée
        lput [ secteur-bouée ] of [ bouée-choisie ] of myself liste-destination-ZMEL-plongée-bouée ]
    ]
  ]

  if ancré? = true and type-destination = "ZMEL/ZMO"
  [ if usage = "Plaisance"
    [ ask secteurs-amarrage with [ nom-secteur = [ secteur-ZMEL ] of [ destination ] of myself ]
      [ set liste-provenance-plaisance-ancre
        lput [ nom-port ] of [ origine ] of myself liste-provenance-plaisance-ancre ]
      ask origine
      [ set liste-destination-ZMEL-plaisance-ancre
        lput [ secteur-ZMEL ] of [ destination ] of myself liste-destination-ZMEL-plaisance-ancre ]
    ]
    if usage = "Plongée"
    [ ask secteurs-amarrage with [ nom-secteur = [ secteur-ZMEL ] of [ destination ] of myself ]
      [ set liste-provenance-plongée-ancre
        lput [ nom-port ] of [ origine ] of myself liste-provenance-plongée-ancre ]
      ask origine
      [ set liste-destination-ZMEL-plongée-ancre
        lput [ secteur-ZMEL ] of [ destination ] of myself liste-destination-ZMEL-plongée-ancre ]
    ]
  ]

  if ancré? = true and type-destination = "ZAA"
  [ if usage = "Plaisance"
    [ ask secteurs-ancrage with [ nom-secteur = [ secteur-ZAA ] of [ destination ] of myself ]
      [ set liste-provenance-plaisance
        lput [ nom-port ] of [ origine ] of myself liste-provenance-plaisance ]
      ask origine
      [ set liste-destination-ZAA-plaisance
        lput [ secteur-ZAA ] of [ destination ] of myself liste-destination-ZAA-plaisance ]
    ]
    if usage = "Plongée"
    [ ask secteurs-ancrage with [ nom-secteur = [ secteur-ZAA ] of [ destination ] of myself ]
      [ set liste-provenance-plongée
        lput [ nom-port ] of [ origine ] of myself liste-provenance-plongée ]
      ask origine
      [ set liste-destination-ZAA-plongée
        lput [ secteur-ZAA ] of [ destination ] of myself liste-destination-ZAA-plongée ]
    ]
  ]

end

to rentrer-au-port

  ifelse distance spot = 0
  [ entamer-retour ]
  [ ifelse distance destination > 5
    [ repeat 3 ; pour simuler une vitesse de 15 noeuds
      [ naviguer-au-large ] ]
    [ ifelse distance destination > 1
      [ approcher-le-port ]
      [ move-to destination
        set liste-des-positions lput destination liste-des-positions
        set navigue? false
        set amarré? true
        set pratique? false
        set heure-retour-port clock
        if usage = "Plongée"
        [ effectuer-nouvelle-rotation ]
      ]
    ]
  ]

end

to entamer-retour

  ifelse [ trois-cent ] of patch-here = 1
  [ ifelse any? neighbors with [ trois-cent = 1 ]
    [ set trajectoires-possibles neighbors with [ trois-cent = 1 ]
      set meilleure-trajectoire min-one-of trajectoires-possibles [ distance [ destination ] of myself ]
    ]
    [ set trajectoires-possibles neighbors with [ mille = 1 ]
      set meilleure-trajectoire min-one-of trajectoires-possibles [ distance [ destination ] of myself ]
    ]
  ]
  [ set trajectoires-possibles neighbors with [ mille = 1 ]
    set meilleure-trajectoire min-one-of trajectoires-possibles [ distance [ destination ] of myself ]
  ]
  set meilleure-trajectoire min-one-of trajectoires-possibles [ distance [ destination ] of myself ]
  move-to meilleure-trajectoire
  set liste-des-positions lput meilleure-trajectoire liste-des-positions
  if amarré?
  [ ask bouée-choisie
    [ set nombre-bateaux-effectif nombre-bateaux-effectif - 1
      if nombre-bateaux-effectif = 0
      [ set caractéristique-usager 0
        set type-usager 0 ]
    ]
  ]
  if ancré?
  [ if usage = "Plaisance"
    [ ask spot [ set nombre-bateaux-plaisance-ancrés nombre-bateaux-plaisance-ancrés - 1 ] ]
    if usage = "Plongée"
    [ ask spot [ set nombre-bateaux-plongée-ancrés nombre-bateaux-plongée-ancrés - 1 ] ]
  ]
  if cabote?
  [ if usage = "Plaisance"
    [ ask spot [ set nombre-bateaux-plaisance-cabotant nombre-bateaux-plaisance-cabotant - 1 ] ]
    if usage = "Plongée"
    [ ask spot [ set nombre-bateaux-plongée-cabotant nombre-bateaux-plongée-cabotant - 1 ] ]
  ]
  set amarré? false
  set solo/couple? ""
  set ancré? false
  set cabote? false
  set pen-size 0.1
  pen-down

end

to approcher-le-port

  set trajectoires-possibles neighbors with [ mille = 1 ]
  set meilleure-trajectoire min-one-of trajectoires-possibles [ distance [ destination ] of myself ]
  move-to meilleure-trajectoire
  set liste-des-positions lput meilleure-trajectoire liste-des-positions
  set pen-size 0.1
  pen-down

end

to effectuer-nouvelle-rotation

  set nombre-de-rotations nombre-de-rotations + 1
  set color grey
  set liste-durée-de-sortie-effective lput durée-de-sortie-effective liste-durée-de-sortie-effective
  set liste-heure-retour-port lput heure-retour-port liste-heure-retour-port
  set liste-heure-fin-acti lput heure-fin-acti liste-heure-fin-acti
  set durée-de-sortie-effective 0.00
  set heure-retour-port 0.00
  set heure-fin-acti 0.00
  set destination first liste-des-destinations
  set liste-des-positions []
  set liste-des-positions lput patch-here liste-des-positions
  if heure-début-acti = 9.00
  [ set heure-début-acti 14.00 ]
  if length liste-durée-de-sortie-effective = 2 and (
    [ nom-port ] of origine = "Banyuls-sur-mer" or
    [ nom-port ] of origine = "Port-vendres" or
    [ nom-port ] of origine = "Argelès-sur-mer" )
  [ set heure-début-acti last liste-heure-retour-port + 0.16 ]

end

to stocker-résultats

  remplir-listes-taux-occupation
  remplir-listes-taux-vacance
  remplir-listes-durée-saturation

end

to visualiser-résultats

  print "\n \n"

  print clock

  print "\n \n"

  print "PLAISANCE"
  print "navigue?"
  print count bateaux-plaisance with [ navigue? ]
  print "amarré?"
  print count bateaux-plaisance with [ amarré? ]
  print "mouillage-forrain?"
  print count bateaux-plaisance with [ ancré? ]
  print "cabotage?"
  print count bateaux-plaisance with [ cabote? ]

;  print "PLAISANCE"
;  set nb-btx-plaisance-t
;  count bateaux-plaisance with [ navigue? ] +
;  count bateaux-plaisance with [ amarré? ] +
;  count bateaux-plaisance with [ ancré? ] +
;  count bateaux-plaisance with [ cabote? ]
;  ifelse nb-btx-plaisance-t = nb-btx-plaisance-simul
;  [ print "ok" ]
;  [ print "pb"
;    print nb-btx-plaisance-t - nb-btx-plaisance-simul
;  ]
;
;  ifelse count bateaux-plaisance with [ amarré? and distance origine != 0 ] =
;  sum [ nombre-bateaux-effectif ] of bouées with [ type-usager = "Plaisance" ]
;  [ print "ok amarrés bouées" ]
;  [ print "pas ok amarrés bouées" ]
;
;  ifelse count bateaux-plaisance with [ amarré? and distance origine = 0 ] =
;  count bateaux-plaisance with [ amarré? ] -
;  sum [ nombre-bateaux-effectif ] of bouées with [ type-usager = "Plaisance" ]
;  [ print "ok amarrés ports" ]
;  [ print "pas ok amarrés ports" ]
;
;  ifelse count bateaux-plaisance with [ ancré? ] =
;  sum [ nombre-bateaux-plaisance-ancrés ] of patches
;  [ print "ok ancrés" ]
;  [ print "pas ok ancrés" ]
;
;  ifelse count bateaux-plaisance with [ cabote? ] =
;  sum [ nombre-bateaux-plaisance-cabotant ] of patches
;  [ print "ok cabotent" ]
;  [ print "pas ok cabotent" ]

  print "\n \n"

  print "PLONGEE"
  print "navigue?"
  print count bateaux-plongée with [ navigue? ]
  print "amarré?"
  print count bateaux-plongée with [ amarré? ]
  print "mouillage-forrain?"
  print count bateaux-plongée with [ ancré? ]
  print "cabotage?"
  print count bateaux-plongée with [ cabote? ]

;  print "PLONGEE"
;  set nb-btx-plongée-t
;  count bateaux-plongée with [ navigue? ] +
;  count bateaux-plongée with [ amarré? ] +
;  count bateaux-plongée with [ ancré? ] +
;  count bateaux-plongée with [ cabote? ]
;  ifelse nb-btx-plongée-t = nb-btx-plongée-simul
;  [ print "ok" ]
;  [ print "pb"
;    print nb-btx-plongée-t - nb-btx-plongée-simul
;  ]
;
;  ifelse count bateaux-plongée with [ amarré? and distance origine != 0 ] =
;  sum [ nombre-bateaux-effectif ] of bouées with [ type-usager = "Plongée" ]
;  [ print "ok amarrés bouées" ]
;  [ print "pas ok amarrés bouées" ]
;
;  ifelse count bateaux-plongée with [ amarré? and distance origine = 0 ] =
;  count bateaux-plongée with [ amarré? ] -
;  sum [ nombre-bateaux-effectif ] of bouées with [ type-usager = "Plongée" ]
;  [ print "ok amarrés ports" ]
;  [ print "pas ok amarrés ports" ]
;
;  ifelse count bateaux-plongée with [ ancré? ] =
;  sum [ nombre-bateaux-plongée-ancrés ] of patches
;  [ print "ok ancrés" ]
;  [ print "pas ok ancrés" ]
;
;  ifelse count bateaux-plongée with [ cabote? ] =
;  sum [ nombre-bateaux-plongée-cabotant ] of patches
;  [ print "ok cabotent" ]
;  [ print "pas ok cabotent" ]

  print "\n \n"

  print "taux d'occupation des bouées / secteur de ZMEL"
  ( foreach liste-noms-secteurs [ ? -> print ? print taux-occupation ? ] )

  print "\n \n"

  print "horaires critiques en termes de taux d'occupation des bouées / secteur de ZMEL"
  horaire-critique

  print "\n \n"

  if clock = 0.00
  [
    print "PLAISANCE"
    print "durée moyenne de sortie"
    print durée-moyenne-sortie->plaisance
    print "durée moyenne du trajet retour"
    print durée-moyenne-trajet-retour->plaisance
    print "% de bateaux ayant pu accéder à leur destination initiale"
    print %-accès-destination-initiale->plaisance
    print "% de bateaux ayant dû changer au moins une fois de destination"
    print %-changement-destination->plaisance
    print "% de bateaux ayant pu s'amarrer à une bouée écologique"
    print %-amarrage-bouée->plaisance
    print "% de bateaux ayant pu s'amarrer à une bouée écologique, solo"
    print %-amarrage-bouée-solo->plaisance
    print "% de bateaux ayant pu s'amarrer à une bouée écologique, à couple"
    print %-amarrage-bouée-couple->plaisance
    print "% de bateaux ayant caboté"
    print %-cabotage->plaisance
    print "% de bateaux ayant procédé à un mouillage forain"
    print %-ancrage->plaisance
    print "provenance des bateaux amarrés / secteur de ZMEL"
    port-origine/amarrage-secteur-ZMEL->plaisance
    print "provenance des bateaux ancrés / secteur de ZMEL"
    port-origine/ancrage-secteur-ZMEL->plaisance
    print "provenance des bateaux / secteur de ZAA"
    port-origine/ancrage-secteur-ZAA->plaisance
    print "ZMEL destination des bateaux amarrés / port d'origine"
    ZMEL-amarrage/port-origine->plaisance
    print "ZMEL destination des bateaux ancrés / port d'origine"
    ZMEL-ancrage/port-origine->plaisance
    print "ZAA destination des bateaux / port d'origine"
    ZAA-ancrage/port-origine->plaisance
    print "taux d'occupation moyen / secteur de ZMEL"
    sortir-taux-moyen-saturation->plaisance
    print "taux d'occupation maximum / secteur de ZMEL"
    sortir-taux-max-saturation->plaisance
    print "durée de saturation / secteur de ZMEL"
    sortir-durée-saturation->plaisance

    print "\n \n"

    print "PLONGEE"
    print "durée moyenne de sortie"
    print durée-moyenne-sortie->plongée
    print "durée moyenne du trajet retour"
    print durée-moyenne-trajet-retour->plongée
    print "% de bateaux ayant pu accéder à leur destination initiale"
    print %-accès-destination-initiale->plongée
    print "% de bateaux ayant dû changer au moins une fois de destination"
    print %-changement-destination->plongée
    print "% de bateaux ayant pu s'amarrer à une bouée écologique"
    print %-amarrage-bouée->plongée
    print "% de bateaux ayant pu s'amarrer à une bouée écologique, solo"
    print %-amarrage-bouée-solo->plongée
    print "% de bateaux ayant pu s'amarrer à une bouée écologique, à couple"
    print %-amarrage-bouée-couple->plongée
    print "% de bateaux ayant caboté"
    print %-cabotage->plongée
    print "% de bateaux ayant procédé à un mouillage forain"
    print %-ancrage->plongée
    print "provenance des bateaux amarrés / secteur de ZMEL"
    port-origine/amarrage-secteur-ZMEL->plongée
    print "provenance des bateaux ancrés / secteur de ZMEL"
    port-origine/ancrage-secteur-ZMEL->plongée
    print "provenance des bateaux / secteur de ZAA"
    port-origine/ancrage-secteur-ZAA->plongée
    print "ZMEL destination des bateaux amarrés / port d'origine"
    ZMEL-amarrage/port-origine->plongée
    print "ZMEL destination des bateaux ancrés / port d'origine"
    ZMEL-ancrage/port-origine->plongée
    print "ZAA destination des bateaux / port d'origine"
    ZAA-ancrage/port-origine->plongée
    print "taux d'occupation moyen / secteur de ZMEL"
    sortir-taux-moyen-saturation->plongée
    print "taux d'occupation maximum / secteur de ZMEL"
    sortir-taux-max-saturation->plongée
    print "durée de saturation / secteur de ZMEL"
    sortir-durée-saturation->plongée
  ]

end

to-report durée-moyenne-sortie->plaisance

  report precision mean [ durée-de-sortie-effective ] of bateaux-plaisance 2

end

to-report durée-moyenne-trajet-retour->plaisance

  report precision ( mean [ heure-retour-port ] of bateaux-plaisance - mean [ heure-fin-acti ] of bateaux-plaisance ) 2

end

to-report %-accès-destination-initiale->plaisance

  report precision ( count bateaux-plaisance with [ length liste-des-destinations = 1 ] / count bateaux-plaisance * 100 ) 2

end

to-report %-changement-destination->plaisance

  report precision ( count bateaux-plaisance with [ length liste-des-destinations > 1 ] / count bateaux-plaisance * 100 ) 2

end

to-report %-amarrage-bouée->plaisance

  report precision ( bateaux-plaisance-amarrés-bouées / count bateaux-plaisance * 100 ) 2

end

to-report %-amarrage-bouée-solo->plaisance

  report precision ( bateaux-plaisance-amarrés-solo / count bateaux-plaisance * 100 ) 2

end

to-report %-amarrage-bouée-couple->plaisance

  report precision ( bateaux-plaisance-amarrés-couple / count bateaux-plaisance * 100 ) 2

end

to-report %-cabotage->plaisance

  report precision ( bateaux-plaisance-cabotant / count bateaux-plaisance * 100 ) 2

end

to-report %-ancrage->plaisance

  report precision ( bateaux-plaisance-ancrés / count bateaux-plaisance * 100 ) 2

end

to port-origine/amarrage-secteur-ZMEL->plaisance

  ( foreach liste-noms-secteurs [ ? ->
    provenance/secteur ? [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = ? ] ] )

end

to port-origine/ancrage-secteur-ZMEL->plaisance

  ( foreach liste-noms-secteurs [ ? ->
    provenance/secteur ? [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = ? ] ] )

end

to port-origine/ancrage-secteur-ZAA->plaisance

  ( foreach [ who ] of secteurs-ancrage with [ nom-secteur = "Mauresque" or nom-secteur = "Bear" ] [ ? ->
    provenance/secteur ? [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ who = ? ] ] )

end

to ZMEL-amarrage/port-origine->plaisance

  ( foreach liste-noms-ports [ ? ->
    destination/port ? [ liste-destination-ZMEL-plaisance-bouée ] of one-of ports with [ nom-port = ? ] ] )

end

to ZMEL-ancrage/port-origine->plaisance

  ( foreach liste-noms-ports [ ? ->
    destination/port ? [ liste-destination-ZMEL-plaisance-ancre ] of one-of ports with [ nom-port = ? ] ] )

end

to ZAA-ancrage/port-origine->plaisance

  ( foreach liste-noms-ports [ ? ->
    destination/port ? [ liste-destination-ZAA-plaisance ] of one-of ports with [ nom-port = ? ] ] )

end

to-report durée-moyenne-sortie->plongée

  report precision mean [ mean liste-durée-de-sortie-effective ] of bateaux-plongée 2

end

to-report durée-moyenne-trajet-retour->plongée

  report precision ( mean [ mean liste-heure-retour-port ] of bateaux-plongée - mean [ mean liste-heure-fin-acti ] of bateaux-plongée ) 2

end

to-report %-accès-destination-initiale->plongée

  report precision ( count bateaux-plongée with [ length liste-des-destinations = 1 ] / count bateaux-plongée * 100 ) 2

end

to-report %-changement-destination->plongée

  report precision ( count bateaux-plongée with [ length liste-des-destinations > 1 ] / count bateaux-plongée * 100 ) 2

end

to-report %-amarrage-bouée->plongée

  report precision ( bateaux-plongée-amarrés-bouées / nombre-de-rotations * 100 ) 2

end

to-report %-amarrage-bouée-solo->plongée

  report precision ( bateaux-plongée-amarrés-solo / nombre-de-rotations * 100 ) 2

end

to-report %-amarrage-bouée-couple->plongée

  report precision ( bateaux-plongée-amarrés-couple / nombre-de-rotations * 100 ) 2

end

to-report %-cabotage->plongée

  report precision ( bateaux-plongée-cabotant / nombre-de-rotations * 100 ) 2

end

to-report %-ancrage->plongée

  report precision ( bateaux-plongée-ancrés / nombre-de-rotations * 100 ) 2

end

to port-origine/amarrage-secteur-ZMEL->plongée

  ( foreach liste-noms-secteurs [ ? ->
    provenance/secteur ? [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = ? ] ] )

end

to port-origine/ancrage-secteur-ZMEL->plongée

  ( foreach liste-noms-secteurs [ ? ->
    provenance/secteur ? [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = ? ] ] )

end

to port-origine/ancrage-secteur-ZAA->plongée

  ( foreach [ who ] of secteurs-ancrage with [ nom-secteur = "Mauresque" or nom-secteur = "Bear" ] [ ? ->
    provenance/secteur ? [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ who = ? ] ] )

end

to ZMEL-amarrage/port-origine->plongée

  ( foreach liste-noms-ports [ ? ->
    destination/port ? [ liste-destination-ZMEL-plongée-bouée ] of one-of ports with [ nom-port = ? ] ] )

end

to ZMEL-ancrage/port-origine->plongée

  ( foreach liste-noms-ports [ ? ->
    destination/port ? [ liste-destination-ZMEL-plongée-ancre ] of one-of ports with [ nom-port = ? ] ] )

end

to ZAA-ancrage/port-origine->plongée

  ( foreach liste-noms-ports [ ? ->
    destination/port ? [ liste-destination-ZAA-plongée ] of one-of ports with [ nom-port = ? ] ] )

end

to provenance/secteur [ secteur liste-p ]

  ( foreach liste-noms-ports [ x ->
    print x
    print secteur
    if secteur != "*" [ print [ nom-secteur ] of secteurs-ancrage with [ who = secteur ] ]
    ( ifelse length liste-p != 0
      [ print "effectif"
        print length filter [ i -> i = x ] liste-p
        print "%"
        print precision ( length filter [ i -> i = x ] liste-p / length liste-p * 100 ) 2 ]
      [ print 0 ] )
    ]
  )

end

to destination/port [ départ liste-d ]

  ( foreach liste-noms-secteurs [ x ->
    print x
    print départ
    ( ifelse length liste-d != 0
      [ print "effectif"
        print length filter [ i -> i = x ] liste-d
        print "%"
        print precision ( length filter [ i -> i = x ] liste-d / length liste-d * 100 ) 2 ]
      [ print 0 ] )
    ]
  )

end

to horaire-critique

  print "Moulade"
  print horaire-critique-Moulade

  print "Mauresque"
  print horaire-critique-Mauresque

  print "Bear"
  print horaire-critique-Bear

  print "Cerbere"
  print horaire-critique-Cerbere

  print "Abeille"
  print horaire-critique-Abeille

  print "Peyrefite"
  print horaire-critique-Peyrefite

end

to-report horaire-critique-Moulade

  ifelse clock != 0.00
  [ ifelse taux-occupation "Moulade" > 95
    [ ask secteurs-amarrage with [ nom-secteur = "Moulade" ]
      [ set liste-horaire-critique lput clock liste-horaire-critique ]
      report precision ( mean [ liste-horaire-critique ] of
        one-of secteurs-amarrage with [ nom-secteur = "Moulade" ] ) 0 ]
    [ report 0 ]
  ]
  [ ifelse [ liste-horaire-critique ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ] != []
    [ report precision ( mean [ liste-horaire-critique ] of
      one-of secteurs-amarrage with [ nom-secteur = "Moulade" ] ) 0 ]
    [ report 0 ]
  ]

end

to-report horaire-critique-Mauresque

  ifelse clock != 0.00
  [ ifelse taux-occupation "Mauresque" > 95
    [ ask secteurs-amarrage with [ nom-secteur = "Mauresque" ]
      [ set liste-horaire-critique lput clock liste-horaire-critique ]
      report precision ( mean [ liste-horaire-critique ] of
        one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ] ) 0 ]
    [ report 0 ]
  ]
  [ ifelse [ liste-horaire-critique ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ] != []
    [ report precision ( mean [ liste-horaire-critique ] of
      one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ] ) 0 ]
    [ report 0 ]
  ]

end

to-report horaire-critique-Bear

  ifelse clock != 0.00
  [ ifelse taux-occupation "Bear" > 95
    [ ask secteurs-amarrage with [ nom-secteur = "Bear" ]
      [ set liste-horaire-critique lput clock liste-horaire-critique ]
      report precision ( mean [ liste-horaire-critique ] of
        one-of secteurs-amarrage with [ nom-secteur = "Bear" ] ) 0 ]
    [ report 0 ]
  ]
  [ ifelse [ liste-horaire-critique ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ] != []
    [ report precision ( mean [ liste-horaire-critique ] of
      one-of secteurs-amarrage with [ nom-secteur = "Bear" ] ) 0 ]
    [ report 0 ]
  ]

end

to-report horaire-critique-Cerbere

  ifelse clock != 0.00
  [ ifelse taux-occupation "Cerbere" > 95
    [ ask secteurs-amarrage with [ nom-secteur = "Cerbere" ]
      [ set liste-horaire-critique lput clock liste-horaire-critique ]
      report precision ( mean [ liste-horaire-critique ] of
        one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ] ) 0 ]
    [ report 0 ]
  ]
  [ ifelse [ liste-horaire-critique ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ] != []
    [ report precision ( mean [ liste-horaire-critique ] of
      one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ] ) 0 ]
    [ report 0 ]
  ]

end

to-report horaire-critique-Abeille

  ifelse clock != 0.00
  [ ifelse taux-occupation "Abeille" > 95
    [ ask secteurs-amarrage with [ nom-secteur = "Abeille" ]
      [ set liste-horaire-critique lput clock liste-horaire-critique ]
      report precision ( mean [ liste-horaire-critique ] of
        one-of secteurs-amarrage with [ nom-secteur = "Abeille" ] ) 0 ]
    [ report 0 ]
  ]
  [ ifelse [ liste-horaire-critique ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ] != []
    [ report precision ( mean [ liste-horaire-critique ] of
      one-of secteurs-amarrage with [ nom-secteur = "Abeille" ] ) 0 ]
    [ report 0 ]
  ]

end

to-report horaire-critique-Peyrefite

  ifelse clock != 0.00
  [ ifelse taux-occupation "Peyrefite" > 95
    [ ask secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
      [ set liste-horaire-critique lput clock liste-horaire-critique ]
      report precision ( mean [ liste-horaire-critique ] of
        one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ] ) 0 ]
    [ report 0 ]
  ]
  [ ifelse [ liste-horaire-critique ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ] != []
    [ report precision ( mean [ liste-horaire-critique ] of
      one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ] ) 0 ]
    [ report 0 ]
  ]

end

to-report taux-occupation [ secteur ]

  report precision ( count bouées with
    [ nombre-bateaux-effectif > 0 and
      secteur-bouée = secteur ]
    / count bouées with
    [ secteur-bouée = secteur ]
    * 100 ) 2

end

; Rapport du nombre de bateaux de plaisance/plongée effectivement amarrés
; au nombre de bateaux possiblement amarrés aux bouées destinées à la plaisance/plongée
; dans un secteur de ZMEL donné
; Le résultat peut être > 100 du fait qu'en pratique
; les différents types de bateaux peuvent accéder aux bouées
; initialement destinées aux autres catégories d'usagers.
; Comme les bateaux peuvent se diriger vers des secteurs de ZMEL
; qui ne comprennent pourtant aucune bouée dédiée à leur usage,
; conformément aux destinations-types définies avec les gestionnaires,
; le cas échéant, le nombre de bateaux effectivement amarrés est rapporté à 1,
; ce qui revient à saturer le secteur par ce type d'usager dès le premier bateau.
; Ce cas de figure concerne les bateaux de plongée qui s'orientent vers
; les secteurs de ZMEL "Moulade", "Cerbere" et "Peyrefite".
to remplir-listes-taux-occupation

  ( foreach liste-noms-secteurs [ ? ->
    ask secteurs-amarrage with [ nom-secteur = ? ]
    [
      ifelse any? bouées with
      [ secteur-bouée = ? and
        usage-bouée = "Plaisance" ]
      [
        set liste-taux-occupation-plaisance lput
        precision ( sum [ nombre-bateaux-effectif ] of bouées with
          [ secteur-bouée = ? and
            type-usager = "Plaisance" ]
          / sum [ nombre-bateaux-possible ] of bouées with
          [ secteur-bouée = ? and
            usage-bouée = "Plaisance" ] * 100 ) 2
        liste-taux-occupation-plaisance
      ]
      [
        set liste-taux-occupation-plaisance lput
        precision ( sum [ nombre-bateaux-effectif ] of bouées with
          [ secteur-bouée = ? and
            type-usager = "Plaisance" ]
          / 1 * 100 ) 2
        liste-taux-occupation-plaisance
      ]

      ifelse any? bouées with
      [ secteur-bouée = ? and
        usage-bouée = "Plongée" ]
      [
        set liste-taux-occupation-plongée lput
        precision ( sum [ nombre-bateaux-effectif ] of bouées with
          [ secteur-bouée = ? and
            type-usager = "Plongée" ]
          / sum [ nombre-bateaux-possible ] of bouées with
          [ secteur-bouée = ? and
            usage-bouée = "Plongée" ] * 100 ) 2
        liste-taux-occupation-plongée
      ]
      [
        set liste-taux-occupation-plongée lput
        precision ( sum [ nombre-bateaux-effectif ] of bouées with
          [ secteur-bouée = ? and
            type-usager = "Plongée" ]
          / 1 * 100 ) 2
        liste-taux-occupation-plongée
      ]
    ]
    ]
  )

end

to sortir-taux-moyen-saturation->plaisance

  ( foreach liste-noms-secteurs [ ? ->
    ask one-of secteurs-amarrage with [ nom-secteur = ? ]
    [ print ?
      print precision mean liste-taux-occupation-plaisance 2 ] ] )

end

to sortir-taux-moyen-saturation->plongée

  ( foreach liste-noms-secteurs [ ? ->
    ask one-of secteurs-amarrage with [ nom-secteur = ? ]
    [ print ?
      print precision mean liste-taux-occupation-plongée 2 ] ] )

end

to sortir-taux-max-saturation->plaisance

  ( foreach liste-noms-secteurs [ ? ->
    ask one-of secteurs-amarrage with [ nom-secteur = ? ]
    [ print ?
      print max liste-taux-occupation-plaisance ] ] )

end

to sortir-taux-max-saturation->plongée

  ( foreach liste-noms-secteurs [ ? ->
    ask one-of secteurs-amarrage with [ nom-secteur = ? ]
    [ print ?
      print max liste-taux-occupation-plongée ] ] )

end

to remplir-listes-taux-vacance

  set liste-taux-vacance-bouées-plaisance lput
  precision ( 100 - ( sum [ nombre-bateaux-effectif ] of bouées with
    [ type-usager = "Plaisance" ]
    / sum [ nombre-bateaux-possible ] of bouées with
        [ usage-bouée = "Plaisance" ] * 100 ) ) 2
  liste-taux-vacance-bouées-plaisance

  set liste-taux-vacance-plongée lput
  precision ( 100 - ( sum [ nombre-bateaux-effectif ] of bouées with
    [ type-usager = "Plongée" ]
    / sum [ nombre-bateaux-possible ] of bouées with
        [ usage-bouée = "Plongée" ] * 100 ) ) 2
  liste-taux-vacance-plongée

end

to remplir-listes-durée-saturation

  ( foreach liste-noms-secteurs [ ? ->
    ask secteurs-amarrage with [ nom-secteur = ? ]
    [ set liste-durée-taux-saturation-plaisance durée-saturation liste-taux-occupation-plaisance
      set liste-durée-taux-saturation-plongée durée-saturation liste-taux-occupation-plongée
    ] ] )

end

to-report durée-saturation [ liste-taux ]

  let liste []
  ( foreach liste-taux liste-horaires-effectifs [ [ ?1 ?2 ] ->
    if ?1 >= 100 [ set liste lput ?2 liste ] ] )
  report liste

end

to sortir-durée-saturation->plaisance

  ( foreach liste-noms-secteurs [ ? ->
    ask one-of secteurs-amarrage with [ nom-secteur = ? ]
    [ print ?
      print precision ( length liste-durée-taux-saturation-plaisance / 30 ) 0 ] ] )
   ; / 30 -> unité = heure (ici chaque heure est divisée en 30 pas de temps)

end

to sortir-durée-saturation->plongée

  ( foreach liste-noms-secteurs [ ? ->
    ask one-of secteurs-amarrage with [ nom-secteur = ? ]
    [ print ?
       print precision ( length liste-durée-taux-saturation-plongée / 30 ) 0 ] ] )
   ; / 30 -> unité = heure (ici chaque heure est divisée en 30 pas de temps)

end

to setup-GIS

  set cadre gis:load-dataset "cadre.shp"
  set étangs-lagunes gis:load-dataset "étangs_lagunes.shp"
  set bathymétrie gis:load-dataset "bathymétrie.asc"
  set richesses-naturelles gis:load-dataset "richesses_naturelles.shp"
  set habitats gis:load-dataset "habitats.shp"
  set trait-de-côte gis:load-dataset "trait_de_côte.shp"
  set communes gis:load-dataset "communes.shp"
  set un-mille gis:load-dataset "1_mille.shp"
  set trois-cent-mètres gis:load-dataset "300_mètres.shp"
  set RNN-C-B gis:load-dataset "RNN_Cerbère_Banyuls.shp"
  set mouillages-forains gis:load-dataset "mouillages_forains.shp"
  set ZMEL gis:load-dataset "ZMEL.shp"
  set ports-plaisance gis:load-dataset "ports_plaisance_plg.shp"
  set bouées-ZMEL gis:load-dataset "bouées_plg_2022.shp"
  set bouées-ZMO gis:load-dataset "bouées_RNN_plg.shp"
  set sites-plongée gis:load-dataset "sites_plongée_plg.shp"

  gis:set-world-envelope ( gis:envelope-union-of
    ( gis:envelope-of cadre )
    ( gis:envelope-of étangs-lagunes )
    ( gis:envelope-of bathymétrie )
    ( gis:envelope-of richesses-naturelles )
    ( gis:envelope-of habitats )
    ( gis:envelope-of trait-de-côte )
    ( gis:envelope-of communes )
    ( gis:envelope-of un-mille )
    ( gis:envelope-of trois-cent-mètres )
    ( gis:envelope-of RNN-C-B )
    ( gis:envelope-of mouillages-forains )
    ( gis:envelope-of ZMEL )
    ( gis:envelope-of ports-plaisance )
    ( gis:envelope-of bouées-ZMEL )
    ( gis:envelope-of bouées-ZMO )
    ( gis:envelope-of sites-plongée ))

  ask patches gis:intersecting gis:find-features cadre
  "ID" "1" [ set pcolor 103 ]

  ask patches gis:intersecting gis:find-features étangs-lagunes
  "Object_ID" "*" [ set pcolor 103 ]

  ask patches gis:intersecting gis:find-features trait-de-côte
  "REGION" "*" [ set pcolor 53 ]

  gis:apply-coverage communes "NOM" commune

  gis:apply-raster bathymétrie bathy

  gis:apply-coverage richesses-naturelles "TABLE_SENS" richesse

  gis:apply-coverage habitats "LIB_EBQI" biocénose

  gis:apply-coverage un-mille "ID" mille
  ask patches gis:intersecting gis:find-features un-mille
  "ID" "*" [ set pcolor 93 ]

  gis:apply-coverage trois-cent-mètres "ID" trois-cent
  ask patches gis:intersecting gis:find-features trois-cent-mètres
  "ID" "*" [ set pcolor 83 ]

  gis:apply-coverage RNN-C-B "CODE_R_ENP" RNN
  ask patches with [ RNN = "RNN" ] [ set pcolor 133 ]

  gis:apply-coverage mouillages-forains "SECTEUR" secteur-ZAA
  ask patches with [
    secteur-ZAA = "Mauresque" or
    secteur-ZAA = "Bear"
  ]
  [ set pcolor 13 ]

    ask patches with [
    secteur-ZAA != "Mauresque" and
    secteur-ZAA != "Bear"
  ]
  [ set secteur-ZAA 0 ]

  gis:apply-coverage mouillages-forains "ZONE" zone-ZAA
  ask patches with [
    zone-ZAA != "nord" and
    zone-ZAA != "sud"
  ]
  [ set zone-ZAA 0 ]

  foreach gis:feature-list-of mouillages-forains [ vector-feature ->
    create-secteurs-ancrage 1
    [ set nom-secteur gis:property-value vector-feature "SECTEUR"
      set mobilité? false
      set color 103
    ]
  ]

  gis:apply-coverage ZMEL "SECTEUR" secteur-ZMEL
  ask patches with [
    secteur-ZMEL = "Moulade" or
    secteur-ZMEL = "Mauresque" or
    secteur-ZMEL = "Bear" or
    secteur-ZMEL = "Cerbere" or
    secteur-ZMEL = "Abeille" or
    secteur-ZMEL = "Peyrefite" ]
  [ set pcolor 23 ]

  ask patches with [
    secteur-ZMEL != "Moulade" and
    secteur-ZMEL != "Mauresque" and
    secteur-ZMEL != "Bear" and
    secteur-ZMEL != "Cerbere" and
    secteur-ZMEL != "Abeille" and
    secteur-ZMEL != "Peyrefite" ]
  [ set secteur-ZMEL 0 ]

  foreach gis:feature-list-of ZMEL [ vector-feature ->
    create-secteurs-amarrage 1
    [ set nom-secteur gis:property-value vector-feature "SECTEUR"
      set mobilité? false
      set color 103
    ]
  ]

  foreach gis:feature-list-of bouées-ZMEL [ vector-feature ->
      let centroid gis:location-of gis:centroid-of vector-feature
      if not empty? centroid
      [ create-bouées 1
        [ set xcor item 0 centroid
          set ycor item 1 centroid
          set shape "dot"
          set size 0.5
          set color white
          set usage-bouée gis:property-value vector-feature "TYPE"
          set secteur-bouée gis:property-value vector-feature "SECTEUR"
          set année-bouée gis:property-value vector-feature "ANNEE"
          set mobilité? false
        ]
      ]
    ]

   foreach gis:feature-list-of bouées-ZMO [ vector-feature ->
      let centroid gis:location-of gis:centroid-of vector-feature
      if not empty? centroid
      [ create-bouées 1
        [ set xcor item 0 centroid
          set ycor item 1 centroid
          set shape "dot"
          set size 0.5
          set color white
          set usage-bouée gis:property-value vector-feature "TYPE"
          set secteur-bouée gis:property-value vector-feature "SECTEUR"
          set mobilité? false
        ]
      ]
    ]

  foreach gis:feature-list-of sites-plongée [ vector-feature ->
      let centroid gis:location-of gis:centroid-of vector-feature
      if not empty? centroid
      [ create-sites 1
        [ set xcor item 0 centroid
          set ycor item 1 centroid
          set shape "dot"
          set size 0.5
          set color black
          set nom-site gis:property-value vector-feature "NOM"
          set mobilité? false
        ]
      ]
    ]

  foreach gis:feature-list-of ports-plaisance [ vector-feature ->
      let centroid gis:location-of gis:centroid-of vector-feature
      if not empty? centroid
      [ create-ports 1
        [ set xcor item 0 centroid
          set ycor item 1 centroid
          set shape "flag"
          set color black
          set nom-port gis:property-value vector-feature "NOM"
          set mobilité? false
        ]
      ]
    ]

end

to display-communes

  ask noms-communes [ die ]
  gis:set-drawing-color white
  gis:draw communes 1
  foreach gis:feature-list-of communes [ vector-feature ->
      let centroid gis:location-of gis:centroid-of vector-feature
      if not empty? centroid
      [ create-noms-communes 1
        [ set xcor item 0 centroid
          set ycor item 1 centroid
          set size 0
          set label gis:property-value vector-feature "NOM"
          set mobilité? false
        ]
      ]
    ]

end

to display-bathymétrie

  gis:paint bathymétrie 0
  let min-bathy gis:minimum-of bathymétrie
  let max-bathy gis:maximum-of bathymétrie
  ask patches
  [ if ( bathy <= 0 ) or ( bathy >= 0 )
    [ set pcolor scale-color black bathy min-bathy max-bathy ] ]

end

to display-richesses-naturelles

  ask patches with [ richesse >= 0 ] [ set pcolor scale-color red richesse 25 0 ]

end

to display-habitats

 ask patches gis:intersecting gis:find-features habitats
  "lib_EBQI" "pas de cor" [
    set biocénose "pas de cor"
    set pcolor white ]
  ask patches gis:intersecting gis:find-features habitats
  "lib_EBQI" "vase" [
    set biocénose "vase"
    set pcolor brown ]
  ask patches gis:intersecting gis:find-features habitats
  "lib_EBQI" "sable" [
    set biocénose "sable"
    set pcolor yellow ]
  ask patches gis:intersecting gis:find-features habitats
  "lib_EBQI" "rock" [
    set biocénose "rock"
    set pcolor grey ]
  ask patches gis:intersecting gis:find-features habitats
  "lib_EBQI" "phanerogam" [
    set biocénose "phanerogam"
    set pcolor 53 ]
  ask patches gis:intersecting gis:find-features habitats
  "lib_EBQI" "coral" [
    set biocénose "coral"
    set pcolor red ]

end

to display-trame

  ask patches [
    sprout 1 [
      set shape "contour"
      set color grey
      __set-line-thickness 0.01
    ]
  ]

end

;Based on https://stackoverflow.com/
;NetLogo : How to make sure a variable stays in a defined range?
to-report random-normal-in-bounds [ mid dev mmin mmax hor-poss ]

  let result random-normal mid dev
  ifelse result < mmin or result > mmax
  [ report random-normal-in-bounds mid dev mmin mmax hor-poss ]
  [ set result precision result 2
    ifelse member? result hor-poss = false
    [ report random-normal-in-bounds mid dev mmin mmax hor-poss ]
    [ report precision result 2 ]
  ]

end

;;; BEHAVIORSPACE EXPERIMENT

to-report nombre-de-rotations-bateaux-de-plongée
 report nombre-de-rotations
end

;;; PLAISANCE

;;; taux-moyen-saturation/secteur-ZMEL
to-report taux-moyen-saturation/secteur-ZMEL=Moulade->plaisance
  report [ precision mean liste-taux-occupation-plaisance 2 ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report taux-moyen-saturation/secteur-ZMEL=Mauresque->plaisance
  report [ precision mean liste-taux-occupation-plaisance 2 ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report taux-moyen-saturation/secteur-ZMEL=Bear->plaisance
  report [ precision mean liste-taux-occupation-plaisance 2 ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report taux-moyen-saturation/secteur-ZMEL=Abeille->plaisance
  report [ precision mean liste-taux-occupation-plaisance 2 ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report taux-moyen-saturation/secteur-ZMEL=Peyrefite->plaisance
  report [ precision mean liste-taux-occupation-plaisance 2 ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report taux-moyen-saturation/secteur-ZMEL=Cerbere->plaisance
  report [ precision mean liste-taux-occupation-plaisance 2 ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end

;;; taux-max-saturation/secteur-ZMEL
to-report taux-max-saturation/secteur-ZMEL=Moulade->plaisance
  report [ max liste-taux-occupation-plaisance ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report taux-max-saturation/secteur-ZMEL=Mauresque->plaisance
  report [ max liste-taux-occupation-plaisance ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report taux-max-saturation/secteur-ZMEL=Bear->plaisance
  report [ max liste-taux-occupation-plaisance ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report taux-max-saturation/secteur-ZMEL=Abeille->plaisance
  report [ max liste-taux-occupation-plaisance ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report taux-max-saturation/secteur-ZMEL=Peyrefite->plaisance
  report [ max liste-taux-occupation-plaisance ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report taux-max-saturation/secteur-ZMEL=Cerbere->plaisance
  report [ max liste-taux-occupation-plaisance ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end

;;; durée-saturation/secteur-ZMEL
to-report durée-saturation/secteur-ZMEL=Moulade->plaisance
  report [ precision ( length liste-durée-taux-saturation-plaisance / 30 ) 0 ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report durée-saturation/secteur-ZMEL=Mauresque->plaisance
  report [ precision ( length liste-durée-taux-saturation-plaisance / 30 ) 0 ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report durée-saturation/secteur-ZMEL=Bear->plaisance
  report [ precision ( length liste-durée-taux-saturation-plaisance / 30 ) 0 ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report durée-saturation/secteur-ZMEL=Abeille->plaisance
  report [ precision ( length liste-durée-taux-saturation-plaisance / 30 ) 0 ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report durée-saturation/secteur-ZMEL=Peyrefite->plaisance
  report [ precision ( length liste-durée-taux-saturation-plaisance / 30 ) 0 ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report durée-saturation/secteur-ZMEL=Cerbere->plaisance
  report [ precision ( length liste-durée-taux-saturation-plaisance / 30 ) 0 ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end

;;; amarrage-secteur-ZMEL=Moulade->plaisance
to-report port-origine=Leucate/amarrage-secteur-ZMEL=Moulade->plaisance
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Barcares/amarrage-secteur-ZMEL=Moulade->plaisance
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Sainte-marie-la-mer/amarrage-secteur-ZMEL=Moulade->plaisance
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Canet-en-Roussillon/amarrage-secteur-ZMEL=Moulade->plaisance
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Saint-Cyprien/amarrage-secteur-ZMEL=Moulade->plaisance
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Argelès-sur-mer/amarrage-secteur-ZMEL=Moulade->plaisance
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Collioure/amarrage-secteur-ZMEL=Moulade->plaisance
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Port-vendres/amarrage-secteur-ZMEL=Moulade->plaisance
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Banyuls-sur-mer/amarrage-secteur-ZMEL=Moulade->plaisance
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Cerbere/amarrage-secteur-ZMEL=Moulade->plaisance
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
;;; amarrage-secteur-ZMEL=Mauresque->plaisance
to-report port-origine=Leucate/amarrage-secteur-ZMEL=Mauresque->plaisance
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Barcares/amarrage-secteur-ZMEL=Mauresque->plaisance
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Sainte-marie-la-mer/amarrage-secteur-ZMEL=Mauresque->plaisance
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Canet-en-Roussillon/amarrage-secteur-ZMEL=Mauresque->plaisance
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Saint-Cyprien/amarrage-secteur-ZMEL=Mauresque->plaisance
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Argelès-sur-mer/amarrage-secteur-ZMEL=Mauresque->plaisance
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Collioure/amarrage-secteur-ZMEL=Mauresque->plaisance
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Port-vendres/amarrage-secteur-ZMEL=Mauresque->plaisance
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Banyuls-sur-mer/amarrage-secteur-ZMEL=Mauresque->plaisance
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Cerbere/amarrage-secteur-ZMEL=Mauresque->plaisance
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
;;; amarrage-secteur-ZMEL=Bear->plaisance
to-report port-origine=Leucate/amarrage-secteur-ZMEL=Bear->plaisance
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Barcares/amarrage-secteur-ZMEL=Bear->plaisance
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Sainte-marie-la-mer/amarrage-secteur-ZMEL=Bear->plaisance
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Canet-en-Roussillon/amarrage-secteur-ZMEL=Bear->plaisance
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Saint-Cyprien/amarrage-secteur-ZMEL=Bear->plaisance
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Argelès-sur-mer/amarrage-secteur-ZMEL=Bear->plaisance
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Collioure/amarrage-secteur-ZMEL=Bear->plaisance
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Port-vendres/amarrage-secteur-ZMEL=Bear->plaisance
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Banyuls-sur-mer/amarrage-secteur-ZMEL=Bear->plaisance
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Cerbere/amarrage-secteur-ZMEL=Bear->plaisance
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
;;; amarrage-secteur-ZMEL=Abeille->plaisance
to-report port-origine=Leucate/amarrage-secteur-ZMEL=Abeille->plaisance
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Barcares/amarrage-secteur-ZMEL=Abeille->plaisance
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Sainte-marie-la-mer/amarrage-secteur-ZMEL=Abeille->plaisance
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Canet-en-Roussillon/amarrage-secteur-ZMEL=Abeille->plaisance
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Saint-Cyprien/amarrage-secteur-ZMEL=Abeille->plaisance
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Argelès-sur-mer/amarrage-secteur-ZMEL=Abeille->plaisance
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Collioure/amarrage-secteur-ZMEL=Abeille->plaisance
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Port-vendres/amarrage-secteur-ZMEL=Abeille->plaisance
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Banyuls-sur-mer/amarrage-secteur-ZMEL=Abeille->plaisance
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Cerbere/amarrage-secteur-ZMEL=Abeille->plaisance
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
;;; amarrage-secteur-ZMEL=Peyrefite->plaisance
to-report port-origine=Leucate/amarrage-secteur-ZMEL=Peyrefite->plaisance
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Barcares/amarrage-secteur-ZMEL=Peyrefite->plaisance
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Sainte-marie-la-mer/amarrage-secteur-ZMEL=Peyrefite->plaisance
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Canet-en-Roussillon/amarrage-secteur-ZMEL=Peyrefite->plaisance
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Saint-Cyprien/amarrage-secteur-ZMEL=Peyrefite->plaisance
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Argelès-sur-mer/amarrage-secteur-ZMEL=Peyrefite->plaisance
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Collioure/amarrage-secteur-ZMEL=Peyrefite->plaisance
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Port-vendres/amarrage-secteur-ZMEL=Peyrefite->plaisance
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Banyuls-sur-mer/amarrage-secteur-ZMEL=Peyrefite->plaisance
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Cerbere/amarrage-secteur-ZMEL=Peyrefite->plaisance
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
;;; amarrage-secteur-ZMEL=Cerbere->plaisance
to-report port-origine=Leucate/amarrage-secteur-ZMEL=Cerbere->plaisance
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Barcares/amarrage-secteur-ZMEL=Cerbere->plaisance
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Sainte-marie-la-mer/amarrage-secteur-ZMEL=Cerbere->plaisance
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Canet-en-Roussillon/amarrage-secteur-ZMEL=Cerbere->plaisance
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Saint-Cyprien/amarrage-secteur-ZMEL=Cerbere->plaisance
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Argelès-sur-mer/amarrage-secteur-ZMEL=Cerbere->plaisance
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Collioure/amarrage-secteur-ZMEL=Cerbere->plaisance
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Port-vendres/amarrage-secteur-ZMEL=Cerbere->plaisance
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Banyuls-sur-mer/amarrage-secteur-ZMEL=Cerbere->plaisance
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Cerbere/amarrage-secteur-ZMEL=Cerbere->plaisance
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plaisance-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end

;;; ancrage-secteur-ZMEL=Moulade->plaisance
to-report port-origine=Leucate/ancrage-secteur-ZMEL=Moulade->plaisance
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Barcares/ancrage-secteur-ZMEL=Moulade->plaisance
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Sainte-marie-la-mer/ancrage-secteur-ZMEL=Moulade->plaisance
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Canet-en-Roussillon/ancrage-secteur-ZMEL=Moulade->plaisance
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Saint-Cyprien/ancrage-secteur-ZMEL=Moulade->plaisance
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Argelès-sur-mer/ancrage-secteur-ZMEL=Moulade->plaisance
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Collioure/ancrage-secteur-ZMEL=Moulade->plaisance
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Port-vendres/ancrage-secteur-ZMEL=Moulade->plaisance
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Banyuls-sur-mer/ancrage-secteur-ZMEL=Moulade->plaisance
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Cerbere/ancrage-secteur-ZMEL=Moulade->plaisance
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
;;; ancrage-secteur-ZMEL=Mauresque->plaisance
to-report port-origine=Leucate/ancrage-secteur-ZMEL=Mauresque->plaisance
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Barcares/ancrage-secteur-ZMEL=Mauresque->plaisance
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Sainte-marie-la-mer/ancrage-secteur-ZMEL=Mauresque->plaisance
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Canet-en-Roussillon/ancrage-secteur-ZMEL=Mauresque->plaisance
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Saint-Cyprien/ancrage-secteur-ZMEL=Mauresque->plaisance
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Argelès-sur-mer/ancrage-secteur-ZMEL=Mauresque->plaisance
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Collioure/ancrage-secteur-ZMEL=Mauresque->plaisance
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Port-vendres/ancrage-secteur-ZMEL=Mauresque->plaisance
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Banyuls-sur-mer/ancrage-secteur-ZMEL=Mauresque->plaisance
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Cerbere/ancrage-secteur-ZMEL=Mauresque->plaisance
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
;;; ancrage-secteur-ZMEL=Bear->plaisance
to-report port-origine=Leucate/ancrage-secteur-ZMEL=Bear->plaisance
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Barcares/ancrage-secteur-ZMEL=Bear->plaisance
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Sainte-marie-la-mer/ancrage-secteur-ZMEL=Bear->plaisance
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Canet-en-Roussillon/ancrage-secteur-ZMEL=Bear->plaisance
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Saint-Cyprien/ancrage-secteur-ZMEL=Bear->plaisance
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Argelès-sur-mer/ancrage-secteur-ZMEL=Bear->plaisance
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Collioure/ancrage-secteur-ZMEL=Bear->plaisance
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Port-vendres/ancrage-secteur-ZMEL=Bear->plaisance
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Banyuls-sur-mer/ancrage-secteur-ZMEL=Bear->plaisance
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Cerbere/ancrage-secteur-ZMEL=Bear->plaisance
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
;;; ancrage-secteur-ZMEL=Abeille->plaisance
to-report port-origine=Leucate/ancrage-secteur-ZMEL=Abeille->plaisance
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Barcares/ancrage-secteur-ZMEL=Abeille->plaisance
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Sainte-marie-la-mer/ancrage-secteur-ZMEL=Abeille->plaisance
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Canet-en-Roussillon/ancrage-secteur-ZMEL=Abeille->plaisance
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Saint-Cyprien/ancrage-secteur-ZMEL=Abeille->plaisance
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Argelès-sur-mer/ancrage-secteur-ZMEL=Abeille->plaisance
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Collioure/ancrage-secteur-ZMEL=Abeille->plaisance
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Port-vendres/ancrage-secteur-ZMEL=Abeille->plaisance
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Banyuls-sur-mer/ancrage-secteur-ZMEL=Abeille->plaisance
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Cerbere/ancrage-secteur-ZMEL=Abeille->plaisance
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
;;; ancrage-secteur-ZMEL=Peyrefite->plaisance
to-report port-origine=Leucate/ancrage-secteur-ZMEL=Peyrefite->plaisance
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Barcares/ancrage-secteur-ZMEL=Peyrefite->plaisance
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Sainte-marie-la-mer/ancrage-secteur-ZMEL=Peyrefite->plaisance
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Canet-en-Roussillon/ancrage-secteur-ZMEL=Peyrefite->plaisance
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Saint-Cyprien/ancrage-secteur-ZMEL=Peyrefite->plaisance
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Argelès-sur-mer/ancrage-secteur-ZMEL=Peyrefite->plaisance
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Collioure/ancrage-secteur-ZMEL=Peyrefite->plaisance
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Port-vendres/ancrage-secteur-ZMEL=Peyrefite->plaisance
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Banyuls-sur-mer/ancrage-secteur-ZMEL=Peyrefite->plaisance
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Cerbere/ancrage-secteur-ZMEL=Peyrefite->plaisance
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
;;; ancrage-secteur-ZMEL=Cerbere->plaisance
to-report port-origine=Leucate/ancrage-secteur-ZMEL=Cerbere->plaisance
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Barcares/ancrage-secteur-ZMEL=Cerbere->plaisance
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Sainte-marie-la-mer/ancrage-secteur-ZMEL=Cerbere->plaisance
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Canet-en-Roussillon/ancrage-secteur-ZMEL=Cerbere->plaisance
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Saint-Cyprien/ancrage-secteur-ZMEL=Cerbere->plaisance
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Argelès-sur-mer/ancrage-secteur-ZMEL=Cerbere->plaisance
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Collioure/ancrage-secteur-ZMEL=Cerbere->plaisance
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Port-vendres/ancrage-secteur-ZMEL=Cerbere->plaisance
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Banyuls-sur-mer/ancrage-secteur-ZMEL=Cerbere->plaisance
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Cerbere/ancrage-secteur-ZMEL=Cerbere->plaisance
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plaisance-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end

;;; ancrage-secteur-ZAA=Moulade->plaisance
to-report port-origine=Leucate/ancrage-secteur-ZAA=Moulade->plaisance
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Barcares/ancrage-secteur-ZAA=Moulade->plaisance
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Sainte-marie-la-mer/ancrage-secteur-ZAA=Moulade->plaisance
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Canet-en-Roussillon/ancrage-secteur-ZAA=Moulade->plaisance
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Saint-Cyprien/ancrage-secteur-ZAA=Moulade->plaisance
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Argelès-sur-mer/ancrage-secteur-ZAA=Moulade->plaisance
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Collioure/ancrage-secteur-ZAA=Moulade->plaisance
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Port-vendres/ancrage-secteur-ZAA=Moulade->plaisance
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Banyuls-sur-mer/ancrage-secteur-ZAA=Moulade->plaisance
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Cerbere/ancrage-secteur-ZAA=Moulade->plaisance
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Moulade" ]
end
;;; ancrage-secteur-ZAA=Mauresque->plaisance
to-report port-origine=Leucate/ancrage-secteur-ZAA=Mauresque->plaisance
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Barcares/ancrage-secteur-ZAA=Mauresque->plaisance
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Sainte-marie-la-mer/ancrage-secteur-ZAA=Mauresque->plaisance
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Canet-en-Roussillon/ancrage-secteur-ZAA=Mauresque->plaisance
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Saint-Cyprien/ancrage-secteur-ZAA=Mauresque->plaisance
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Argelès-sur-mer/ancrage-secteur-ZAA=Mauresque->plaisance
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Collioure/ancrage-secteur-ZAA=Mauresque->plaisance
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Port-vendres/ancrage-secteur-ZAA=Mauresque->plaisance
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Banyuls-sur-mer/ancrage-secteur-ZAA=Mauresque->plaisance
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Cerbere/ancrage-secteur-ZAA=Mauresque->plaisance
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Mauresque" ]
end
;;; ancrage-secteur-ZAA=Bear->plaisance
to-report port-origine=Leucate/ancrage-secteur-ZAA=Bear->plaisance
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Barcares/ancrage-secteur-ZAA=Bear->plaisance
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Sainte-marie-la-mer/ancrage-secteur-ZAA=Bear->plaisance
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Canet-en-Roussillon/ancrage-secteur-ZAA=Bear->plaisance
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Saint-Cyprien/ancrage-secteur-ZAA=Bear->plaisance
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Argelès-sur-mer/ancrage-secteur-ZAA=Bear->plaisance
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Collioure/ancrage-secteur-ZAA=Bear->plaisance
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Port-vendres/ancrage-secteur-ZAA=Bear->plaisance
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Banyuls-sur-mer/ancrage-secteur-ZAA=Bear->plaisance
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Cerbere/ancrage-secteur-ZAA=Bear->plaisance
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Bear" ]
end
;;; ancrage-secteur-ZAA=Abeille->plaisance
to-report port-origine=Leucate/ancrage-secteur-ZAA=Abeille->plaisance
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Barcares/ancrage-secteur-ZAA=Abeille->plaisance
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Sainte-marie-la-mer/ancrage-secteur-ZAA=Abeille->plaisance
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Canet-en-Roussillon/ancrage-secteur-ZAA=Abeille->plaisance
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Saint-Cyprien/ancrage-secteur-ZAA=Abeille->plaisance
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Argelès-sur-mer/ancrage-secteur-ZAA=Abeille->plaisance
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Collioure/ancrage-secteur-ZAA=Abeille->plaisance
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Port-vendres/ancrage-secteur-ZAA=Abeille->plaisance
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Banyuls-sur-mer/ancrage-secteur-ZAA=Abeille->plaisance
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Cerbere/ancrage-secteur-ZAA=Abeille->plaisance
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Abeille" ]
end
;;; ancrage-secteur-ZAA=Peyrefite->plaisance
to-report port-origine=Leucate/ancrage-secteur-ZAA=Peyrefite->plaisance
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Barcares/ancrage-secteur-ZAA=Peyrefite->plaisance
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Sainte-marie-la-mer/ancrage-secteur-ZAA=Peyrefite->plaisance
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Canet-en-Roussillon/ancrage-secteur-ZAA=Peyrefite->plaisance
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Saint-Cyprien/ancrage-secteur-ZAA=Peyrefite->plaisance
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Argelès-sur-mer/ancrage-secteur-ZAA=Peyrefite->plaisance
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Collioure/ancrage-secteur-ZAA=Peyrefite->plaisance
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Port-vendres/ancrage-secteur-ZAA=Peyrefite->plaisance
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Banyuls-sur-mer/ancrage-secteur-ZAA=Peyrefite->plaisance
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Cerbere/ancrage-secteur-ZAA=Peyrefite->plaisance
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Peyrefite" ]
end
;;; ancrage-secteur-ZAA=Cerbere->plaisance
to-report port-origine=Leucate/ancrage-secteur-ZAA=Cerbere->plaisance
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Barcares/ancrage-secteur-ZAA=Cerbere->plaisance
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Sainte-marie-la-mer/ancrage-secteur-ZAA=Cerbere->plaisance
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Canet-en-Roussillon/ancrage-secteur-ZAA=Cerbere->plaisance
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Saint-Cyprien/ancrage-secteur-ZAA=Cerbere->plaisance
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Argelès-sur-mer/ancrage-secteur-ZAA=Cerbere->plaisance
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Collioure/ancrage-secteur-ZAA=Cerbere->plaisance
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Port-vendres/ancrage-secteur-ZAA=Cerbere->plaisance
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Banyuls-sur-mer/ancrage-secteur-ZAA=Cerbere->plaisance
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Cerbere/ancrage-secteur-ZAA=Cerbere->plaisance
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plaisance ] of one-of secteurs-ancrage with [ nom-secteur = "Cerbere" ]
end

;;; PLONGÉE

;;; taux-moyen-saturation/secteur-ZMEL
to-report taux-moyen-saturation/secteur-ZMEL=Moulade->plongée
  report [ precision mean liste-taux-occupation-plongée 2 ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report taux-moyen-saturation/secteur-ZMEL=Mauresque->plongée
  report [ precision mean liste-taux-occupation-plongée 2 ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report taux-moyen-saturation/secteur-ZMEL=Bear->plongée
  report [ precision mean liste-taux-occupation-plongée 2 ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report taux-moyen-saturation/secteur-ZMEL=Abeille->plongée
  report [ precision mean liste-taux-occupation-plongée 2 ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report taux-moyen-saturation/secteur-ZMEL=Peyrefite->plongée
  report [ precision mean liste-taux-occupation-plongée 2 ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report taux-moyen-saturation/secteur-ZMEL=Cerbere->plongée
  report [ precision mean liste-taux-occupation-plongée 2 ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end

;;; taux-max-saturation/secteur-ZMEL
to-report taux-max-saturation/secteur-ZMEL=Moulade->plongée
  report [ max liste-taux-occupation-plongée ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report taux-max-saturation/secteur-ZMEL=Mauresque->plongée
  report [ max liste-taux-occupation-plongée ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report taux-max-saturation/secteur-ZMEL=Bear->plongée
  report [ max liste-taux-occupation-plongée ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report taux-max-saturation/secteur-ZMEL=Abeille->plongée
  report [ max liste-taux-occupation-plongée ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report taux-max-saturation/secteur-ZMEL=Peyrefite->plongée
  report [ max liste-taux-occupation-plongée ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report taux-max-saturation/secteur-ZMEL=Cerbere->plongée
  report [ max liste-taux-occupation-plongée ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end

;;; durée-saturation/secteur-ZMEL
to-report durée-saturation/secteur-ZMEL=Moulade->plongée
  report [ precision ( length liste-durée-taux-saturation-plongée / 30 ) 0 ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report durée-saturation/secteur-ZMEL=Mauresque->plongée
  report [ precision ( length liste-durée-taux-saturation-plongée / 30 ) 0 ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report durée-saturation/secteur-ZMEL=Bear->plongée
  report [ precision ( length liste-durée-taux-saturation-plongée / 30 ) 0 ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report durée-saturation/secteur-ZMEL=Abeille->plongée
  report [ precision ( length liste-durée-taux-saturation-plongée / 30 ) 0 ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report durée-saturation/secteur-ZMEL=Peyrefite->plongée
  report [ precision ( length liste-durée-taux-saturation-plongée / 30 ) 0 ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report durée-saturation/secteur-ZMEL=Cerbere->plongée
  report [ precision ( length liste-durée-taux-saturation-plongée / 30 ) 0 ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end

;;; amarrage-secteur-ZMEL=Moulade->plongée
to-report port-origine=Leucate/amarrage-secteur-ZMEL=Moulade->plongée
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Barcares/amarrage-secteur-ZMEL=Moulade->plongée
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Sainte-marie-la-mer/amarrage-secteur-ZMEL=Moulade->plongée
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Canet-en-Roussillon/amarrage-secteur-ZMEL=Moulade->plongée
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Saint-Cyprien/amarrage-secteur-ZMEL=Moulade->plongée
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Argelès-sur-mer/amarrage-secteur-ZMEL=Moulade->plongée
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Collioure/amarrage-secteur-ZMEL=Moulade->plongée
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Port-vendres/amarrage-secteur-ZMEL=Moulade->plongée
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Banyuls-sur-mer/amarrage-secteur-ZMEL=Moulade->plongée
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Cerbere/amarrage-secteur-ZMEL=Moulade->plongée
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
;;; amarrage-secteur-ZMEL=Mauresque->plongée
to-report port-origine=Leucate/amarrage-secteur-ZMEL=Mauresque->plongée
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Barcares/amarrage-secteur-ZMEL=Mauresque->plongée
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Sainte-marie-la-mer/amarrage-secteur-ZMEL=Mauresque->plongée
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Canet-en-Roussillon/amarrage-secteur-ZMEL=Mauresque->plongée
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Saint-Cyprien/amarrage-secteur-ZMEL=Mauresque->plongée
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Argelès-sur-mer/amarrage-secteur-ZMEL=Mauresque->plongée
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Collioure/amarrage-secteur-ZMEL=Mauresque->plongée
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Port-vendres/amarrage-secteur-ZMEL=Mauresque->plongée
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Banyuls-sur-mer/amarrage-secteur-ZMEL=Mauresque->plongée
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Cerbere/amarrage-secteur-ZMEL=Mauresque->plongée
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
;;; amarrage-secteur-ZMEL=Bear->plongée
to-report port-origine=Leucate/amarrage-secteur-ZMEL=Bear->plongée
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Barcares/amarrage-secteur-ZMEL=Bear->plongée
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Sainte-marie-la-mer/amarrage-secteur-ZMEL=Bear->plongée
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Canet-en-Roussillon/amarrage-secteur-ZMEL=Bear->plongée
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Saint-Cyprien/amarrage-secteur-ZMEL=Bear->plongée
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Argelès-sur-mer/amarrage-secteur-ZMEL=Bear->plongée
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Collioure/amarrage-secteur-ZMEL=Bear->plongée
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Port-vendres/amarrage-secteur-ZMEL=Bear->plongée
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Banyuls-sur-mer/amarrage-secteur-ZMEL=Bear->plongée
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Cerbere/amarrage-secteur-ZMEL=Bear->plongée
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
;;; amarrage-secteur-ZMEL=Abeille->plongée
to-report port-origine=Leucate/amarrage-secteur-ZMEL=Abeille->plongée
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Barcares/amarrage-secteur-ZMEL=Abeille->plongée
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Sainte-marie-la-mer/amarrage-secteur-ZMEL=Abeille->plongée
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Canet-en-Roussillon/amarrage-secteur-ZMEL=Abeille->plongée
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Saint-Cyprien/amarrage-secteur-ZMEL=Abeille->plongée
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Argelès-sur-mer/amarrage-secteur-ZMEL=Abeille->plongée
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Collioure/amarrage-secteur-ZMEL=Abeille->plongée
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Port-vendres/amarrage-secteur-ZMEL=Abeille->plongée
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Banyuls-sur-mer/amarrage-secteur-ZMEL=Abeille->plongée
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Cerbere/amarrage-secteur-ZMEL=Abeille->plongée
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
;;; amarrage-secteur-ZMEL=Peyrefite->plongée
to-report port-origine=Leucate/amarrage-secteur-ZMEL=Peyrefite->plongée
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Barcares/amarrage-secteur-ZMEL=Peyrefite->plongée
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Sainte-marie-la-mer/amarrage-secteur-ZMEL=Peyrefite->plongée
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Canet-en-Roussillon/amarrage-secteur-ZMEL=Peyrefite->plongée
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Saint-Cyprien/amarrage-secteur-ZMEL=Peyrefite->plongée
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Argelès-sur-mer/amarrage-secteur-ZMEL=Peyrefite->plongée
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Collioure/amarrage-secteur-ZMEL=Peyrefite->plongée
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Port-vendres/amarrage-secteur-ZMEL=Peyrefite->plongée
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Banyuls-sur-mer/amarrage-secteur-ZMEL=Peyrefite->plongée
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Cerbere/amarrage-secteur-ZMEL=Peyrefite->plongée
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
;;; amarrage-secteur-ZMEL=Cerbere->plongée
to-report port-origine=Leucate/amarrage-secteur-ZMEL=Cerbere->plongée
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Barcares/amarrage-secteur-ZMEL=Cerbere->plongée
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Sainte-marie-la-mer/amarrage-secteur-ZMEL=Cerbere->plongée
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Canet-en-Roussillon/amarrage-secteur-ZMEL=Cerbere->plongée
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Saint-Cyprien/amarrage-secteur-ZMEL=Cerbere->plongée
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Argelès-sur-mer/amarrage-secteur-ZMEL=Cerbere->plongée
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Collioure/amarrage-secteur-ZMEL=Cerbere->plongée
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Port-vendres/amarrage-secteur-ZMEL=Cerbere->plongée
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Banyuls-sur-mer/amarrage-secteur-ZMEL=Cerbere->plongée
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Cerbere/amarrage-secteur-ZMEL=Cerbere->plongée
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plongée-bouée ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end

;;; ancrage-secteur-ZMEL=Moulade->plongée
to-report port-origine=Leucate/ancrage-secteur-ZMEL=Moulade->plongée
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Barcares/ancrage-secteur-ZMEL=Moulade->plongée
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Sainte-marie-la-mer/ancrage-secteur-ZMEL=Moulade->plongée
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Canet-en-Roussillon/ancrage-secteur-ZMEL=Moulade->plongée
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Saint-Cyprien/ancrage-secteur-ZMEL=Moulade->plongée
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Argelès-sur-mer/ancrage-secteur-ZMEL=Moulade->plongée
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Collioure/ancrage-secteur-ZMEL=Moulade->plongée
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Port-vendres/ancrage-secteur-ZMEL=Moulade->plongée
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Banyuls-sur-mer/ancrage-secteur-ZMEL=Moulade->plongée
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Cerbere/ancrage-secteur-ZMEL=Moulade->plongée
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Moulade" ]
end
;;; ancrage-secteur-ZMEL=Mauresque->plongée
to-report port-origine=Leucate/ancrage-secteur-ZMEL=Mauresque->plongée
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Barcares/ancrage-secteur-ZMEL=Mauresque->plongée
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Sainte-marie-la-mer/ancrage-secteur-ZMEL=Mauresque->plongée
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Canet-en-Roussillon/ancrage-secteur-ZMEL=Mauresque->plongée
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Saint-Cyprien/ancrage-secteur-ZMEL=Mauresque->plongée
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Argelès-sur-mer/ancrage-secteur-ZMEL=Mauresque->plongée
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Collioure/ancrage-secteur-ZMEL=Mauresque->plongée
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Port-vendres/ancrage-secteur-ZMEL=Mauresque->plongée
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Banyuls-sur-mer/ancrage-secteur-ZMEL=Mauresque->plongée
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Cerbere/ancrage-secteur-ZMEL=Mauresque->plongée
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Mauresque" ]
end
;;; ancrage-secteur-ZMEL=Bear->plongée
to-report port-origine=Leucate/ancrage-secteur-ZMEL=Bear->plongée
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Barcares/ancrage-secteur-ZMEL=Bear->plongée
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Sainte-marie-la-mer/ancrage-secteur-ZMEL=Bear->plongée
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Canet-en-Roussillon/ancrage-secteur-ZMEL=Bear->plongée
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Saint-Cyprien/ancrage-secteur-ZMEL=Bear->plongée
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Argelès-sur-mer/ancrage-secteur-ZMEL=Bear->plongée
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Collioure/ancrage-secteur-ZMEL=Bear->plongée
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Port-vendres/ancrage-secteur-ZMEL=Bear->plongée
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Banyuls-sur-mer/ancrage-secteur-ZMEL=Bear->plongée
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Cerbere/ancrage-secteur-ZMEL=Bear->plongée
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Bear" ]
end
;;; ancrage-secteur-ZMEL=Abeille->plongée
to-report port-origine=Leucate/ancrage-secteur-ZMEL=Abeille->plongée
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Barcares/ancrage-secteur-ZMEL=Abeille->plongée
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Sainte-marie-la-mer/ancrage-secteur-ZMEL=Abeille->plongée
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Canet-en-Roussillon/ancrage-secteur-ZMEL=Abeille->plongée
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Saint-Cyprien/ancrage-secteur-ZMEL=Abeille->plongée
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Argelès-sur-mer/ancrage-secteur-ZMEL=Abeille->plongée
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Collioure/ancrage-secteur-ZMEL=Abeille->plongée
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Port-vendres/ancrage-secteur-ZMEL=Abeille->plongée
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Banyuls-sur-mer/ancrage-secteur-ZMEL=Abeille->plongée
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Cerbere/ancrage-secteur-ZMEL=Abeille->plongée
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Abeille" ]
end
;;; ancrage-secteur-ZMEL=Peyrefite->plongée
to-report port-origine=Leucate/ancrage-secteur-ZMEL=Peyrefite->plongée
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Barcares/ancrage-secteur-ZMEL=Peyrefite->plongée
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Sainte-marie-la-mer/ancrage-secteur-ZMEL=Peyrefite->plongée
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Canet-en-Roussillon/ancrage-secteur-ZMEL=Peyrefite->plongée
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Saint-Cyprien/ancrage-secteur-ZMEL=Peyrefite->plongée
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Argelès-sur-mer/ancrage-secteur-ZMEL=Peyrefite->plongée
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Collioure/ancrage-secteur-ZMEL=Peyrefite->plongée
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Port-vendres/ancrage-secteur-ZMEL=Peyrefite->plongée
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Banyuls-sur-mer/ancrage-secteur-ZMEL=Peyrefite->plongée
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Cerbere/ancrage-secteur-ZMEL=Peyrefite->plongée
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Peyrefite" ]
end
;;; ancrage-secteur-ZMEL=Cerbere->plongée
to-report port-origine=Leucate/ancrage-secteur-ZMEL=Cerbere->plongée
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Barcares/ancrage-secteur-ZMEL=Cerbere->plongée
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Sainte-marie-la-mer/ancrage-secteur-ZMEL=Cerbere->plongée
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Canet-en-Roussillon/ancrage-secteur-ZMEL=Cerbere->plongée
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Saint-Cyprien/ancrage-secteur-ZMEL=Cerbere->plongée
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Argelès-sur-mer/ancrage-secteur-ZMEL=Cerbere->plongée
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Collioure/ancrage-secteur-ZMEL=Cerbere->plongée
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Port-vendres/ancrage-secteur-ZMEL=Cerbere->plongée
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Banyuls-sur-mer/ancrage-secteur-ZMEL=Cerbere->plongée
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Cerbere/ancrage-secteur-ZMEL=Cerbere->plongée
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plongée-ancre ] of one-of secteurs-amarrage with [ nom-secteur = "Cerbere" ]
end

;;; ancrage-secteur-ZAA=Moulade->plongée
to-report port-origine=Leucate/ancrage-secteur-ZAA=Moulade->plongée
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Barcares/ancrage-secteur-ZAA=Moulade->plongée
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Sainte-marie-la-mer/ancrage-secteur-ZAA=Moulade->plongée
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Canet-en-Roussillon/ancrage-secteur-ZAA=Moulade->plongée
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Saint-Cyprien/ancrage-secteur-ZAA=Moulade->plongée
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Argelès-sur-mer/ancrage-secteur-ZAA=Moulade->plongée
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Collioure/ancrage-secteur-ZAA=Moulade->plongée
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Port-vendres/ancrage-secteur-ZAA=Moulade->plongée
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Banyuls-sur-mer/ancrage-secteur-ZAA=Moulade->plongée
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Moulade" ]
end
to-report port-origine=Cerbere/ancrage-secteur-ZAA=Moulade->plongée
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Moulade" ]
end
;;; ancrage-secteur-ZAA=Mauresque->plongée
to-report port-origine=Leucate/ancrage-secteur-ZAA=Mauresque->plongée
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Barcares/ancrage-secteur-ZAA=Mauresque->plongée
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Sainte-marie-la-mer/ancrage-secteur-ZAA=Mauresque->plongée
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Canet-en-Roussillon/ancrage-secteur-ZAA=Mauresque->plongée
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Saint-Cyprien/ancrage-secteur-ZAA=Mauresque->plongée
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Argelès-sur-mer/ancrage-secteur-ZAA=Mauresque->plongée
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Collioure/ancrage-secteur-ZAA=Mauresque->plongée
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Port-vendres/ancrage-secteur-ZAA=Mauresque->plongée
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Banyuls-sur-mer/ancrage-secteur-ZAA=Mauresque->plongée
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Mauresque" ]
end
to-report port-origine=Cerbere/ancrage-secteur-ZAA=Mauresque->plongée
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Mauresque" ]
end
;;; ancrage-secteur-ZAA=Bear->plongée
to-report port-origine=Leucate/ancrage-secteur-ZAA=Bear->plongée
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Barcares/ancrage-secteur-ZAA=Bear->plongée
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Sainte-marie-la-mer/ancrage-secteur-ZAA=Bear->plongée
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Canet-en-Roussillon/ancrage-secteur-ZAA=Bear->plongée
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Saint-Cyprien/ancrage-secteur-ZAA=Bear->plongée
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Argelès-sur-mer/ancrage-secteur-ZAA=Bear->plongée
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Collioure/ancrage-secteur-ZAA=Bear->plongée
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Port-vendres/ancrage-secteur-ZAA=Bear->plongée
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Banyuls-sur-mer/ancrage-secteur-ZAA=Bear->plongée
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Cerbere/ancrage-secteur-ZAA=Bear->plongée
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Bear" ]
end
;;; ancrage-secteur-ZAA=Abeille->plongée
to-report port-origine=Leucate/ancrage-secteur-ZAA=Abeille->plongée
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Barcares/ancrage-secteur-ZAA=Abeille->plongée
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Sainte-marie-la-mer/ancrage-secteur-ZAA=Abeille->plongée
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Canet-en-Roussillon/ancrage-secteur-ZAA=Abeille->plongée
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Saint-Cyprien/ancrage-secteur-ZAA=Abeille->plongée
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Argelès-sur-mer/ancrage-secteur-ZAA=Abeille->plongée
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Collioure/ancrage-secteur-ZAA=Abeille->plongée
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Port-vendres/ancrage-secteur-ZAA=Abeille->plongée
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Abeille" ]
end
to-report port-origine=Banyuls-sur-mer/ancrage-secteur-ZAA=Abeille->plongée
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Bear" ]
end
to-report port-origine=Cerbere/ancrage-secteur-ZAA=Abeille->plongée
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Abeille" ]
end
;;; ancrage-secteur-ZAA=Peyrefite->plongée
to-report port-origine=Leucate/ancrage-secteur-ZAA=Peyrefite->plongée
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Barcares/ancrage-secteur-ZAA=Peyrefite->plongée
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Sainte-marie-la-mer/ancrage-secteur-ZAA=Peyrefite->plongée
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Canet-en-Roussillon/ancrage-secteur-ZAA=Peyrefite->plongée
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Saint-Cyprien/ancrage-secteur-ZAA=Peyrefite->plongée
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Argelès-sur-mer/ancrage-secteur-ZAA=Peyrefite->plongée
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Collioure/ancrage-secteur-ZAA=Peyrefite->plongée
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Port-vendres/ancrage-secteur-ZAA=Peyrefite->plongée
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Banyuls-sur-mer/ancrage-secteur-ZAA=Peyrefite->plongée
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Peyrefite" ]
end
to-report port-origine=Cerbere/ancrage-secteur-ZAA=Peyrefite->plongée
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Peyrefite" ]
end
;;; ancrage-secteur-ZAA=Cerbere->plaisance
to-report port-origine=Leucate/ancrage-secteur-ZAA=Cerbere->plongée
  report length filter [ i -> i = "Leucate" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Barcares/ancrage-secteur-ZAA=Cerbere->plongée
  report length filter [ i -> i = "Barcares" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Sainte-marie-la-mer/ancrage-secteur-ZAA=Cerbere->plongée
  report length filter [ i -> i = "Sainte-marie-la-mer" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Canet-en-Roussillon/ancrage-secteur-ZAA=Cerbere->plongée
  report length filter [ i -> i = "Canet-en-Roussillon" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Saint-Cyprien/ancrage-secteur-ZAA=Cerbere->plongée
  report length filter [ i -> i = "Saint-Cyprien" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Argelès-sur-mer/ancrage-secteur-ZAA=Cerbere->plongée
  report length filter [ i -> i = "Argelès-sur-mer" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Collioure/ancrage-secteur-ZAA=Cerbere->plongée
  report length filter [ i -> i = "Collioure" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Port-vendres/ancrage-secteur-ZAA=Cerbere->plongée
  report length filter [ i -> i = "Port-vendres" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Banyuls-sur-mer/ancrage-secteur-ZAA=Cerbere->plongée
  report length filter [ i -> i = "Banyuls-sur-mer" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Cerbere" ]
end
to-report port-origine=Cerbere/ancrage-secteur-ZAA=Cerbere->plongée
  report length filter [ i -> i = "Cerbere" ] [ liste-provenance-plongée ] of one-of secteurs-ancrage with [ nom-secteur = "Cerbere" ]
end

to-report détails-dest-plais

  let dest []
  if clock = 0.00
  [
    if any? bateaux-plaisance with [ détail-procédure = 0 ]
    [ set dest lput ( [ last liste-des-destinations ] of bateaux-plaisance with [ détail-procédure = 0 ] ) dest ]
  ]
  report dest

end

to-report détails-orig-plais

  let orig []
  if clock = 0.00
  [
    if any? bateaux-plaisance with [ détail-procédure = 0 ]
    [ set orig lput ( [ [ nom-port ] of origine ] of bateaux-plaisance with [ détail-procédure = 0 ] ) orig ]
  ]
  report orig

end

to-report détails-dest-plong

  let dest []
  if clock = 0.00
  [
    if any? bateaux-plongée with [ détail-procédure = 0 ]
    [ set dest lput ( [ last liste-des-destinations ] of bateaux-plongée with [ détail-procédure = 0 ] ) dest ]
  ]
  report dest

end

to-report détails-orig-plong

  let orig []
  if clock = 0.00
  [
    if any? bateaux-plongée with [ détail-procédure = 0 ]
    [ set orig lput ( [ [ nom-port ] of origine ] of bateaux-plongée with [ détail-procédure = 0 ] ) orig ]
  ]
  report orig

end
@#$#@#$#@
GRAPHICS-WINDOW
236
21
687
473
-1
-1
1.39
1
10
1
1
1
0
0
0
1
-159
159
-159
159
0
0
1
ticks
30.0

SLIDER
25
362
222
395
nombre-bateaux-plaisance
nombre-bateaux-plaisance
0
600
516.0
1
1
NIL
HORIZONTAL

SLIDER
25
406
223
439
nombre-bateaux-plongée
nombre-bateaux-plongée
0
600
18.0
1
1
NIL
HORIZONTAL

BUTTON
23
304
115
337
go-forever
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
25
194
88
227
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
23
247
86
280
go
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

OUTPUT
704
43
788
88
11

TEXTBOX
709
22
752
40
Heure
11
0.0
1

PLOT
29
507
490
825
distribution heure début plaisance
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"clear-plot \nset-plot-pen-interval pas-de-temps \nset-plot-x-range 8.00 16.00\nhistogram [ heure-début-acti ] of bateaux-plaisance" ""
PENS
"pen-0" 1.0 0 -7500403 true "" ""

SLIDER
701
113
891
146
nb-btx-plaisance-Leucate
nb-btx-plaisance-Leucate
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
700
153
895
186
nb-btx-plaisance-Barcares
nb-btx-plaisance-Barcares
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
698
195
953
228
nb-btx-plaisance-Sainte-marie-la-mer
nb-btx-plaisance-Sainte-marie-la-mer
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
698
234
955
267
nb-btx-plaisance-Canet-en-Roussillon
nb-btx-plaisance-Canet-en-Roussillon
0
100
36.0
1
1
NIL
HORIZONTAL

SLIDER
699
273
920
306
nb-btx-plaisance-Saint-Cyprien
nb-btx-plaisance-Saint-Cyprien
0
100
150.0
1
1
NIL
HORIZONTAL

SLIDER
699
312
934
345
nb-btx-plaisance-Argelès-sur-mer
nb-btx-plaisance-Argelès-sur-mer
0
100
181.0
1
1
NIL
HORIZONTAL

SLIDER
699
351
893
384
nb-btx-plaisance-Collioure
nb-btx-plaisance-Collioure
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
698
388
917
421
nb-btx-plaisance-Port-vendres
nb-btx-plaisance-Port-vendres
0
100
62.0
1
1
NIL
HORIZONTAL

SLIDER
699
426
935
459
nb-btx-plaisance-Banyuls-sur-mer
nb-btx-plaisance-Banyuls-sur-mer
0
100
52.0
1
1
NIL
HORIZONTAL

SLIDER
699
464
891
497
nb-btx-plaisance-Cerbere
nb-btx-plaisance-Cerbere
0
100
10.0
1
1
NIL
HORIZONTAL

SLIDER
998
120
1182
153
nb-btx-plongée-Leucate
nb-btx-plongée-Leucate
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
998
159
1186
192
nb-btx-plongée-Barcares
nb-btx-plongée-Barcares
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
998
196
1246
229
nb-btx-plongée-Sainte-marie-la-mer
nb-btx-plongée-Sainte-marie-la-mer
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
998
233
1248
266
nb-btx-plongée-Canet-en-Roussillon
nb-btx-plongée-Canet-en-Roussillon
0
100
0.0
1
1
NIL
HORIZONTAL

SLIDER
998
269
1213
302
nb-btx-plongée-Saint-Cyprien
nb-btx-plongée-Saint-Cyprien
0
100
1.0
1
1
NIL
HORIZONTAL

SLIDER
998
306
1226
339
nb-btx-plongée-Argelès-sur-mer
nb-btx-plongée-Argelès-sur-mer
0
100
5.0
1
1
NIL
HORIZONTAL

SLIDER
998
343
1185
376
nb-btx-plongée-Collioure
nb-btx-plongée-Collioure
0
100
1.0
1
1
NIL
HORIZONTAL

SLIDER
997
381
1209
414
nb-btx-plongée-Port-vendres
nb-btx-plongée-Port-vendres
0
100
3.0
1
1
NIL
HORIZONTAL

SLIDER
996
420
1225
453
nb-btx-plongée-Banyuls-sur-mer
nb-btx-plongée-Banyuls-sur-mer
0
100
6.0
1
1
NIL
HORIZONTAL

SLIDER
996
458
1181
491
nb-btx-plongée-Cerbere
nb-btx-plongée-Cerbere
0
100
2.0
1
1
NIL
HORIZONTAL

PLOT
497
507
953
824
taux d'occupation des secteurs de ZMEL
secteurs de ZMEL
taux d'occupation
0.0
5.5
0.0
100.0
false
true
"" "  clear-plot\n  set-plot-pen-interval 0.5\n  let secteurs-de-ZMEL [ \"Moulade\" \"Mauresque\" \"Bear\" \"Cerbere\" \"Abeille\" \"Peyrefite\" ]\n  let pen-color [ 5 15 25 35 45 55 ]\n  ( foreach secteurs-de-ZMEL pen-color [ [ ?1 ?2 ] ->\n  set-plot-pen-mode 1\n  set-plot-pen-color ?2\n  plot-pen-down plotxy \n  position ?1 secteurs-de-ZMEL\n  taux-occupation ?1 ] )"
PENS
"Moulade" 1.0 0 -7500403 true "" ""
"Mauresque" 1.0 0 -2674135 true "" ""
"Bear" 1.0 0 -955883 true "" "  "
"Cerbere" 1.0 0 -6459832 true "" ""
"Abeille" 1.0 0 -1184463 true "" ""
"Peyrefite" 1.0 0 -10899396 true "" ""

MONITOR
975
514
1121
559
horaire critique Moulade
horaire-critique-Moulade
17
1
11

MONITOR
975
568
1136
613
horaire critique Mauresque
horaire-critique-Mauresque
17
1
11

MONITOR
976
622
1101
667
horaire critique Bear
horaire-critique-Bear
17
1
11

MONITOR
976
674
1123
719
horaire critique Cerbere
horaire-critique-Cerbere
17
1
11

PLOT
166
833
821
1168
plage horaire critique
heure
taux d'occupation
7.0
24.0
0.0
100.0
false
true
"clear-plot\nset-plot-pen-interval pas-de-temps \nset-plot-x-range heure-début-simul heure-fin-simul\n" ""
PENS
"Moulade" 1.0 0 -7500403 true "" "if liste-horaires-effectifs != [] \n[ plotxy last liste-horaires-effectifs taux-occupation \"Moulade\" ]"
"Mauresque" 1.0 0 -2674135 true "" "if liste-horaires-effectifs != []\n[ plotxy last liste-horaires-effectifs taux-occupation \"Mauresque\" ]"
"Bear" 1.0 0 -955883 true "" "if liste-horaires-effectifs != []\n[ plotxy last liste-horaires-effectifs taux-occupation \"Bear\" ]"
"Cerbere" 1.0 0 -6459832 true "" "if liste-horaires-effectifs != []\n[ plotxy last liste-horaires-effectifs taux-occupation \"Cerbere\" ]"
"Abeille" 1.0 0 -1184463 true "" "if liste-horaires-effectifs != []\n[ plotxy last liste-horaires-effectifs taux-occupation \"Abeille\" ]"
"Peyrefite" 1.0 0 -10899396 true "" "if liste-horaires-effectifs != []\n[ plotxy last liste-horaires-effectifs taux-occupation \"Peyrefite\" ]"

CHOOSER
24
75
162
120
vent-dominant
vent-dominant
"tramontane" "marin"
0

CHOOSER
24
129
162
174
force-du-vent
force-du-vent
"forte" "modérée" "insignifiante"
2

CHOOSER
25
24
163
69
saison
saison
"moyenne" "haute"
1

MONITOR
976
725
1111
770
horaire critique Abeille
horaire-critique-Abeille
17
1
11

MONITOR
975
775
1125
820
horaire critique Peyrefite
horaire-critique-Peyrefite
17
1
11

TEXTBOX
981
831
1131
943
Ici, est considéré comme \"critique\" tout horaire auquel le % de bouées occupées est supérieur à 95 %, tous types d'usagers et de bouées confondus.\nLe résultat affiché correspond à l'horaire critique moyen.
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

boat
false
0
Polygon -1 true false 63 162 90 207 223 207 290 162
Rectangle -6459832 true false 150 32 157 162
Polygon -13345367 true false 150 34 131 49 145 47 147 48 149 49
Polygon -7500403 true true 158 33 230 157 182 150 169 151 157 156
Polygon -7500403 true true 149 55 88 143 103 139 111 136 117 139 126 145 130 147 139 147 146 146 149 55

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

contour
false
0
Rectangle -16777216 false false 0 0 300 300

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="haute-tramontane-insignifiante" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>nombre-de-rotations-bateaux-de-plongée</metric>
    <metric>taux-moyen-saturation/secteur-ZMEL=Moulade-&gt;plaisance</metric>
    <metric>taux-moyen-saturation/secteur-ZMEL=Mauresque-&gt;plaisance</metric>
    <metric>taux-moyen-saturation/secteur-ZMEL=Bear-&gt;plaisance</metric>
    <metric>taux-moyen-saturation/secteur-ZMEL=Abeille-&gt;plaisance</metric>
    <metric>taux-moyen-saturation/secteur-ZMEL=Peyrefite-&gt;plaisance</metric>
    <metric>taux-moyen-saturation/secteur-ZMEL=Cerbere-&gt;plaisance</metric>
    <metric>taux-max-saturation/secteur-ZMEL=Moulade-&gt;plaisance</metric>
    <metric>taux-max-saturation/secteur-ZMEL=Mauresque-&gt;plaisance</metric>
    <metric>taux-max-saturation/secteur-ZMEL=Bear-&gt;plaisance</metric>
    <metric>taux-max-saturation/secteur-ZMEL=Abeille-&gt;plaisance</metric>
    <metric>taux-max-saturation/secteur-ZMEL=Peyrefite-&gt;plaisance</metric>
    <metric>taux-max-saturation/secteur-ZMEL=Cerbere-&gt;plaisance</metric>
    <metric>durée-saturation/secteur-ZMEL=Moulade-&gt;plaisance</metric>
    <metric>durée-saturation/secteur-ZMEL=Mauresque-&gt;plaisance</metric>
    <metric>durée-saturation/secteur-ZMEL=Bear-&gt;plaisance</metric>
    <metric>durée-saturation/secteur-ZMEL=Abeille-&gt;plaisance</metric>
    <metric>durée-saturation/secteur-ZMEL=Peyrefite-&gt;plaisance</metric>
    <metric>durée-saturation/secteur-ZMEL=Cerbere-&gt;plaisance</metric>
    <metric>port-origine=Leucate/amarrage-secteur-ZMEL=Moulade-&gt;plaisance</metric>
    <metric>port-origine=Barcares/amarrage-secteur-ZMEL=Moulade-&gt;plaisance</metric>
    <metric>port-origine=Sainte-marie-la-mer/amarrage-secteur-ZMEL=Moulade-&gt;plaisance</metric>
    <metric>port-origine=Canet-en-Roussillon/amarrage-secteur-ZMEL=Moulade-&gt;plaisance</metric>
    <metric>port-origine=Saint-Cyprien/amarrage-secteur-ZMEL=Moulade-&gt;plaisance</metric>
    <metric>port-origine=Argelès-sur-mer/amarrage-secteur-ZMEL=Moulade-&gt;plaisance</metric>
    <metric>port-origine=Collioure/amarrage-secteur-ZMEL=Moulade-&gt;plaisance</metric>
    <metric>port-origine=Port-vendres/amarrage-secteur-ZMEL=Moulade-&gt;plaisance</metric>
    <metric>port-origine=Banyuls-sur-mer/amarrage-secteur-ZMEL=Moulade-&gt;plaisance</metric>
    <metric>port-origine=Cerbere/amarrage-secteur-ZMEL=Moulade-&gt;plaisance</metric>
    <metric>port-origine=Leucate/amarrage-secteur-ZMEL=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Barcares/amarrage-secteur-ZMEL=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Sainte-marie-la-mer/amarrage-secteur-ZMEL=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Canet-en-Roussillon/amarrage-secteur-ZMEL=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Saint-Cyprien/amarrage-secteur-ZMEL=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Argelès-sur-mer/amarrage-secteur-ZMEL=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Collioure/amarrage-secteur-ZMEL=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Port-vendres/amarrage-secteur-ZMEL=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Banyuls-sur-mer/amarrage-secteur-ZMEL=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Cerbere/amarrage-secteur-ZMEL=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Leucate/amarrage-secteur-ZMEL=Bear-&gt;plaisance</metric>
    <metric>port-origine=Barcares/amarrage-secteur-ZMEL=Bear-&gt;plaisance</metric>
    <metric>port-origine=Sainte-marie-la-mer/amarrage-secteur-ZMEL=Bear-&gt;plaisance</metric>
    <metric>port-origine=Canet-en-Roussillon/amarrage-secteur-ZMEL=Bear-&gt;plaisance</metric>
    <metric>port-origine=Saint-Cyprien/amarrage-secteur-ZMEL=Bear-&gt;plaisance</metric>
    <metric>port-origine=Argelès-sur-mer/amarrage-secteur-ZMEL=Bear-&gt;plaisance</metric>
    <metric>port-origine=Collioure/amarrage-secteur-ZMEL=Bear-&gt;plaisance</metric>
    <metric>port-origine=Port-vendres/amarrage-secteur-ZMEL=Bear-&gt;plaisance</metric>
    <metric>port-origine=Banyuls-sur-mer/amarrage-secteur-ZMEL=Bear-&gt;plaisance</metric>
    <metric>port-origine=Cerbere/amarrage-secteur-ZMEL=Bear-&gt;plaisance</metric>
    <metric>port-origine=Leucate/amarrage-secteur-ZMEL=Abeille-&gt;plaisance</metric>
    <metric>port-origine=Barcares/amarrage-secteur-ZMEL=Abeille-&gt;plaisance</metric>
    <metric>port-origine=Sainte-marie-la-mer/amarrage-secteur-ZMEL=Abeille-&gt;plaisance</metric>
    <metric>port-origine=Canet-en-Roussillon/amarrage-secteur-ZMEL=Abeille-&gt;plaisance</metric>
    <metric>port-origine=Saint-Cyprien/amarrage-secteur-ZMEL=Abeille-&gt;plaisance</metric>
    <metric>port-origine=Argelès-sur-mer/amarrage-secteur-ZMEL=Abeille-&gt;plaisance</metric>
    <metric>port-origine=Collioure/amarrage-secteur-ZMEL=Abeille-&gt;plaisance</metric>
    <metric>port-origine=Port-vendres/amarrage-secteur-ZMEL=Abeille-&gt;plaisance</metric>
    <metric>port-origine=Banyuls-sur-mer/amarrage-secteur-ZMEL=Abeille-&gt;plaisance</metric>
    <metric>port-origine=Cerbere/amarrage-secteur-ZMEL=Abeille-&gt;plaisance</metric>
    <metric>port-origine=Leucate/amarrage-secteur-ZMEL=Peyrefite-&gt;plaisance</metric>
    <metric>port-origine=Barcares/amarrage-secteur-ZMEL=Peyrefite-&gt;plaisance</metric>
    <metric>port-origine=Sainte-marie-la-mer/amarrage-secteur-ZMEL=Peyrefite-&gt;plaisance</metric>
    <metric>port-origine=Canet-en-Roussillon/amarrage-secteur-ZMEL=Peyrefite-&gt;plaisance</metric>
    <metric>port-origine=Saint-Cyprien/amarrage-secteur-ZMEL=Peyrefite-&gt;plaisance</metric>
    <metric>port-origine=Argelès-sur-mer/amarrage-secteur-ZMEL=Peyrefite-&gt;plaisance</metric>
    <metric>port-origine=Collioure/amarrage-secteur-ZMEL=Peyrefite-&gt;plaisance</metric>
    <metric>port-origine=Port-vendres/amarrage-secteur-ZMEL=Peyrefite-&gt;plaisance</metric>
    <metric>port-origine=Banyuls-sur-mer/amarrage-secteur-ZMEL=Peyrefite-&gt;plaisance</metric>
    <metric>port-origine=Cerbere/amarrage-secteur-ZMEL=Peyrefite-&gt;plaisance</metric>
    <metric>port-origine=Leucate/amarrage-secteur-ZMEL=Cerbere-&gt;plaisance</metric>
    <metric>port-origine=Barcares/amarrage-secteur-ZMEL=Cerbere-&gt;plaisance</metric>
    <metric>port-origine=Sainte-marie-la-mer/amarrage-secteur-ZMEL=Cerbere-&gt;plaisance</metric>
    <metric>port-origine=Canet-en-Roussillon/amarrage-secteur-ZMEL=Cerbere-&gt;plaisance</metric>
    <metric>port-origine=Saint-Cyprien/amarrage-secteur-ZMEL=Cerbere-&gt;plaisance</metric>
    <metric>port-origine=Argelès-sur-mer/amarrage-secteur-ZMEL=Cerbere-&gt;plaisance</metric>
    <metric>port-origine=Collioure/amarrage-secteur-ZMEL=Cerbere-&gt;plaisance</metric>
    <metric>port-origine=Port-vendres/amarrage-secteur-ZMEL=Cerbere-&gt;plaisance</metric>
    <metric>port-origine=Banyuls-sur-mer/amarrage-secteur-ZMEL=Cerbere-&gt;plaisance</metric>
    <metric>port-origine=Cerbere/amarrage-secteur-ZMEL=Cerbere-&gt;plaisance</metric>
    <metric>port-origine=Leucate/ancrage-secteur-ZMEL=Moulade-&gt;plaisance</metric>
    <metric>port-origine=Barcares/ancrage-secteur-ZMEL=Moulade-&gt;plaisance</metric>
    <metric>port-origine=Sainte-marie-la-mer/ancrage-secteur-ZMEL=Moulade-&gt;plaisance</metric>
    <metric>port-origine=Canet-en-Roussillon/ancrage-secteur-ZMEL=Moulade-&gt;plaisance</metric>
    <metric>port-origine=Saint-Cyprien/ancrage-secteur-ZMEL=Moulade-&gt;plaisance</metric>
    <metric>port-origine=Argelès-sur-mer/ancrage-secteur-ZMEL=Moulade-&gt;plaisance</metric>
    <metric>port-origine=Collioure/ancrage-secteur-ZMEL=Moulade-&gt;plaisance</metric>
    <metric>port-origine=Port-vendres/ancrage-secteur-ZMEL=Moulade-&gt;plaisance</metric>
    <metric>port-origine=Banyuls-sur-mer/ancrage-secteur-ZMEL=Moulade-&gt;plaisance</metric>
    <metric>port-origine=Cerbere/ancrage-secteur-ZMEL=Moulade-&gt;plaisance</metric>
    <metric>port-origine=Leucate/ancrage-secteur-ZMEL=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Barcares/ancrage-secteur-ZMEL=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Sainte-marie-la-mer/ancrage-secteur-ZMEL=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Canet-en-Roussillon/ancrage-secteur-ZMEL=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Saint-Cyprien/ancrage-secteur-ZMEL=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Argelès-sur-mer/ancrage-secteur-ZMEL=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Collioure/ancrage-secteur-ZMEL=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Port-vendres/ancrage-secteur-ZMEL=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Banyuls-sur-mer/ancrage-secteur-ZMEL=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Cerbere/ancrage-secteur-ZMEL=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Leucate/ancrage-secteur-ZMEL=Bear-&gt;plaisance</metric>
    <metric>port-origine=Barcares/ancrage-secteur-ZMEL=Bear-&gt;plaisance</metric>
    <metric>port-origine=Sainte-marie-la-mer/ancrage-secteur-ZMEL=Bear-&gt;plaisance</metric>
    <metric>port-origine=Canet-en-Roussillon/ancrage-secteur-ZMEL=Bear-&gt;plaisance</metric>
    <metric>port-origine=Saint-Cyprien/ancrage-secteur-ZMEL=Bear-&gt;plaisance</metric>
    <metric>port-origine=Argelès-sur-mer/ancrage-secteur-ZMEL=Bear-&gt;plaisance</metric>
    <metric>port-origine=Collioure/ancrage-secteur-ZMEL=Bear-&gt;plaisance</metric>
    <metric>port-origine=Port-vendres/ancrage-secteur-ZMEL=Bear-&gt;plaisance</metric>
    <metric>port-origine=Banyuls-sur-mer/ancrage-secteur-ZMEL=Bear-&gt;plaisance</metric>
    <metric>port-origine=Cerbere/ancrage-secteur-ZMEL=Bear-&gt;plaisance</metric>
    <metric>port-origine=Leucate/ancrage-secteur-ZMEL=Abeille-&gt;plaisance</metric>
    <metric>port-origine=Barcares/ancrage-secteur-ZMEL=Abeille-&gt;plaisance</metric>
    <metric>port-origine=Sainte-marie-la-mer/ancrage-secteur-ZMEL=Abeille-&gt;plaisance</metric>
    <metric>port-origine=Canet-en-Roussillon/ancrage-secteur-ZMEL=Abeille-&gt;plaisance</metric>
    <metric>port-origine=Saint-Cyprien/ancrage-secteur-ZMEL=Abeille-&gt;plaisance</metric>
    <metric>port-origine=Argelès-sur-mer/ancrage-secteur-ZMEL=Abeille-&gt;plaisance</metric>
    <metric>port-origine=Collioure/ancrage-secteur-ZMEL=Abeille-&gt;plaisance</metric>
    <metric>port-origine=Port-vendres/ancrage-secteur-ZMEL=Abeille-&gt;plaisance</metric>
    <metric>port-origine=Banyuls-sur-mer/ancrage-secteur-ZMEL=Abeille-&gt;plaisance</metric>
    <metric>port-origine=Cerbere/ancrage-secteur-ZMEL=Abeille-&gt;plaisance</metric>
    <metric>port-origine=Leucate/ancrage-secteur-ZMEL=Peyrefite-&gt;plaisance</metric>
    <metric>port-origine=Barcares/ancrage-secteur-ZMEL=Peyrefite-&gt;plaisance</metric>
    <metric>port-origine=Sainte-marie-la-mer/ancrage-secteur-ZMEL=Peyrefite-&gt;plaisance</metric>
    <metric>port-origine=Canet-en-Roussillon/ancrage-secteur-ZMEL=Peyrefite-&gt;plaisance</metric>
    <metric>port-origine=Saint-Cyprien/ancrage-secteur-ZMEL=Peyrefite-&gt;plaisance</metric>
    <metric>port-origine=Argelès-sur-mer/ancrage-secteur-ZMEL=Peyrefite-&gt;plaisance</metric>
    <metric>port-origine=Collioure/ancrage-secteur-ZMEL=Peyrefite-&gt;plaisance</metric>
    <metric>port-origine=Port-vendres/ancrage-secteur-ZMEL=Peyrefite-&gt;plaisance</metric>
    <metric>port-origine=Banyuls-sur-mer/ancrage-secteur-ZMEL=Peyrefite-&gt;plaisance</metric>
    <metric>port-origine=Cerbere/ancrage-secteur-ZMEL=Peyrefite-&gt;plaisance</metric>
    <metric>port-origine=Leucate/ancrage-secteur-ZMEL=Cerbere-&gt;plaisance</metric>
    <metric>port-origine=Barcares/ancrage-secteur-ZMEL=Cerbere-&gt;plaisance</metric>
    <metric>port-origine=Sainte-marie-la-mer/ancrage-secteur-ZMEL=Cerbere-&gt;plaisance</metric>
    <metric>port-origine=Canet-en-Roussillon/ancrage-secteur-ZMEL=Cerbere-&gt;plaisance</metric>
    <metric>port-origine=Saint-Cyprien/ancrage-secteur-ZMEL=Cerbere-&gt;plaisance</metric>
    <metric>port-origine=Argelès-sur-mer/ancrage-secteur-ZMEL=Cerbere-&gt;plaisance</metric>
    <metric>port-origine=Collioure/ancrage-secteur-ZMEL=Cerbere-&gt;plaisance</metric>
    <metric>port-origine=Port-vendres/ancrage-secteur-ZMEL=Cerbere-&gt;plaisance</metric>
    <metric>port-origine=Banyuls-sur-mer/ancrage-secteur-ZMEL=Cerbere-&gt;plaisance</metric>
    <metric>port-origine=Cerbere/ancrage-secteur-ZMEL=Cerbere-&gt;plaisance</metric>
    <metric>port-origine=Leucate/ancrage-secteur-ZAA=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Barcares/ancrage-secteur-ZAA=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Sainte-marie-la-mer/ancrage-secteur-ZAA=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Canet-en-Roussillon/ancrage-secteur-ZAA=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Saint-Cyprien/ancrage-secteur-ZAA=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Argelès-sur-mer/ancrage-secteur-ZAA=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Collioure/ancrage-secteur-ZAA=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Port-vendres/ancrage-secteur-ZAA=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Banyuls-sur-mer/ancrage-secteur-ZAA=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Cerbere/ancrage-secteur-ZAA=Mauresque-&gt;plaisance</metric>
    <metric>port-origine=Leucate/ancrage-secteur-ZAA=Bear-&gt;plaisance</metric>
    <metric>port-origine=Barcares/ancrage-secteur-ZAA=Bear-&gt;plaisance</metric>
    <metric>port-origine=Sainte-marie-la-mer/ancrage-secteur-ZAA=Bear-&gt;plaisance</metric>
    <metric>port-origine=Canet-en-Roussillon/ancrage-secteur-ZAA=Bear-&gt;plaisance</metric>
    <metric>port-origine=Saint-Cyprien/ancrage-secteur-ZAA=Bear-&gt;plaisance</metric>
    <metric>port-origine=Argelès-sur-mer/ancrage-secteur-ZAA=Bear-&gt;plaisance</metric>
    <metric>port-origine=Collioure/ancrage-secteur-ZAA=Bear-&gt;plaisance</metric>
    <metric>port-origine=Port-vendres/ancrage-secteur-ZAA=Bear-&gt;plaisance</metric>
    <metric>port-origine=Banyuls-sur-mer/ancrage-secteur-ZAA=Bear-&gt;plaisance</metric>
    <metric>port-origine=Cerbere/ancrage-secteur-ZAA=Bear-&gt;plaisance</metric>
    <metric>taux-moyen-saturation/secteur-ZMEL=Moulade-&gt;plongée</metric>
    <metric>taux-moyen-saturation/secteur-ZMEL=Mauresque-&gt;plongée</metric>
    <metric>taux-moyen-saturation/secteur-ZMEL=Bear-&gt;plongée</metric>
    <metric>taux-moyen-saturation/secteur-ZMEL=Abeille-&gt;plongée</metric>
    <metric>taux-moyen-saturation/secteur-ZMEL=Peyrefite-&gt;plongée</metric>
    <metric>taux-moyen-saturation/secteur-ZMEL=Cerbere-&gt;plongée</metric>
    <metric>taux-max-saturation/secteur-ZMEL=Moulade-&gt;plongée</metric>
    <metric>taux-max-saturation/secteur-ZMEL=Mauresque-&gt;plongée</metric>
    <metric>taux-max-saturation/secteur-ZMEL=Bear-&gt;plongée</metric>
    <metric>taux-max-saturation/secteur-ZMEL=Abeille-&gt;plongée</metric>
    <metric>taux-max-saturation/secteur-ZMEL=Peyrefite-&gt;plongée</metric>
    <metric>taux-max-saturation/secteur-ZMEL=Cerbere-&gt;plongée</metric>
    <metric>durée-saturation/secteur-ZMEL=Moulade-&gt;plongée</metric>
    <metric>durée-saturation/secteur-ZMEL=Mauresque-&gt;plongée</metric>
    <metric>durée-saturation/secteur-ZMEL=Bear-&gt;plongée</metric>
    <metric>durée-saturation/secteur-ZMEL=Abeille-&gt;plongée</metric>
    <metric>durée-saturation/secteur-ZMEL=Peyrefite-&gt;plongée</metric>
    <metric>durée-saturation/secteur-ZMEL=Cerbere-&gt;plongée</metric>
    <metric>port-origine=Leucate/amarrage-secteur-ZMEL=Moulade-&gt;plongée</metric>
    <metric>port-origine=Barcares/amarrage-secteur-ZMEL=Moulade-&gt;plongée</metric>
    <metric>port-origine=Sainte-marie-la-mer/amarrage-secteur-ZMEL=Moulade-&gt;plongée</metric>
    <metric>port-origine=Canet-en-Roussillon/amarrage-secteur-ZMEL=Moulade-&gt;plongée</metric>
    <metric>port-origine=Saint-Cyprien/amarrage-secteur-ZMEL=Moulade-&gt;plongée</metric>
    <metric>port-origine=Argelès-sur-mer/amarrage-secteur-ZMEL=Moulade-&gt;plongée</metric>
    <metric>port-origine=Collioure/amarrage-secteur-ZMEL=Moulade-&gt;plongée</metric>
    <metric>port-origine=Port-vendres/amarrage-secteur-ZMEL=Moulade-&gt;plongée</metric>
    <metric>port-origine=Banyuls-sur-mer/amarrage-secteur-ZMEL=Moulade-&gt;plongée</metric>
    <metric>port-origine=Cerbere/amarrage-secteur-ZMEL=Moulade-&gt;plongée</metric>
    <metric>port-origine=Leucate/amarrage-secteur-ZMEL=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Barcares/amarrage-secteur-ZMEL=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Sainte-marie-la-mer/amarrage-secteur-ZMEL=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Canet-en-Roussillon/amarrage-secteur-ZMEL=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Saint-Cyprien/amarrage-secteur-ZMEL=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Argelès-sur-mer/amarrage-secteur-ZMEL=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Collioure/amarrage-secteur-ZMEL=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Port-vendres/amarrage-secteur-ZMEL=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Banyuls-sur-mer/amarrage-secteur-ZMEL=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Cerbere/amarrage-secteur-ZMEL=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Leucate/amarrage-secteur-ZMEL=Bear-&gt;plongée</metric>
    <metric>port-origine=Barcares/amarrage-secteur-ZMEL=Bear-&gt;plongée</metric>
    <metric>port-origine=Sainte-marie-la-mer/amarrage-secteur-ZMEL=Bear-&gt;plongée</metric>
    <metric>port-origine=Canet-en-Roussillon/amarrage-secteur-ZMEL=Bear-&gt;plongée</metric>
    <metric>port-origine=Saint-Cyprien/amarrage-secteur-ZMEL=Bear-&gt;plongée</metric>
    <metric>port-origine=Argelès-sur-mer/amarrage-secteur-ZMEL=Bear-&gt;plongée</metric>
    <metric>port-origine=Collioure/amarrage-secteur-ZMEL=Bear-&gt;plongée</metric>
    <metric>port-origine=Port-vendres/amarrage-secteur-ZMEL=Bear-&gt;plongée</metric>
    <metric>port-origine=Banyuls-sur-mer/amarrage-secteur-ZMEL=Bear-&gt;plongée</metric>
    <metric>port-origine=Cerbere/amarrage-secteur-ZMEL=Bear-&gt;plongée</metric>
    <metric>port-origine=Leucate/amarrage-secteur-ZMEL=Abeille-&gt;plongée</metric>
    <metric>port-origine=Barcares/amarrage-secteur-ZMEL=Abeille-&gt;plongée</metric>
    <metric>port-origine=Sainte-marie-la-mer/amarrage-secteur-ZMEL=Abeille-&gt;plongée</metric>
    <metric>port-origine=Canet-en-Roussillon/amarrage-secteur-ZMEL=Abeille-&gt;plongée</metric>
    <metric>port-origine=Saint-Cyprien/amarrage-secteur-ZMEL=Abeille-&gt;plongée</metric>
    <metric>port-origine=Argelès-sur-mer/amarrage-secteur-ZMEL=Abeille-&gt;plongée</metric>
    <metric>port-origine=Collioure/amarrage-secteur-ZMEL=Abeille-&gt;plongée</metric>
    <metric>port-origine=Port-vendres/amarrage-secteur-ZMEL=Abeille-&gt;plongée</metric>
    <metric>port-origine=Banyuls-sur-mer/amarrage-secteur-ZMEL=Abeille-&gt;plongée</metric>
    <metric>port-origine=Cerbere/amarrage-secteur-ZMEL=Abeille-&gt;plongée</metric>
    <metric>port-origine=Leucate/amarrage-secteur-ZMEL=Peyrefite-&gt;plongée</metric>
    <metric>port-origine=Barcares/amarrage-secteur-ZMEL=Peyrefite-&gt;plongée</metric>
    <metric>port-origine=Sainte-marie-la-mer/amarrage-secteur-ZMEL=Peyrefite-&gt;plongée</metric>
    <metric>port-origine=Canet-en-Roussillon/amarrage-secteur-ZMEL=Peyrefite-&gt;plongée</metric>
    <metric>port-origine=Saint-Cyprien/amarrage-secteur-ZMEL=Peyrefite-&gt;plongée</metric>
    <metric>port-origine=Argelès-sur-mer/amarrage-secteur-ZMEL=Peyrefite-&gt;plongée</metric>
    <metric>port-origine=Collioure/amarrage-secteur-ZMEL=Peyrefite-&gt;plongée</metric>
    <metric>port-origine=Port-vendres/amarrage-secteur-ZMEL=Peyrefite-&gt;plongée</metric>
    <metric>port-origine=Banyuls-sur-mer/amarrage-secteur-ZMEL=Peyrefite-&gt;plongée</metric>
    <metric>port-origine=Cerbere/amarrage-secteur-ZMEL=Peyrefite-&gt;plongée</metric>
    <metric>port-origine=Leucate/amarrage-secteur-ZMEL=Cerbere-&gt;plongée</metric>
    <metric>port-origine=Barcares/amarrage-secteur-ZMEL=Cerbere-&gt;plongée</metric>
    <metric>port-origine=Sainte-marie-la-mer/amarrage-secteur-ZMEL=Cerbere-&gt;plongée</metric>
    <metric>port-origine=Canet-en-Roussillon/amarrage-secteur-ZMEL=Cerbere-&gt;plongée</metric>
    <metric>port-origine=Saint-Cyprien/amarrage-secteur-ZMEL=Cerbere-&gt;plongée</metric>
    <metric>port-origine=Argelès-sur-mer/amarrage-secteur-ZMEL=Cerbere-&gt;plongée</metric>
    <metric>port-origine=Collioure/amarrage-secteur-ZMEL=Cerbere-&gt;plongée</metric>
    <metric>port-origine=Port-vendres/amarrage-secteur-ZMEL=Cerbere-&gt;plongée</metric>
    <metric>port-origine=Banyuls-sur-mer/amarrage-secteur-ZMEL=Cerbere-&gt;plongée</metric>
    <metric>port-origine=Cerbere/amarrage-secteur-ZMEL=Cerbere-&gt;plongée</metric>
    <metric>port-origine=Leucate/ancrage-secteur-ZMEL=Moulade-&gt;plongée</metric>
    <metric>port-origine=Barcares/ancrage-secteur-ZMEL=Moulade-&gt;plongée</metric>
    <metric>port-origine=Sainte-marie-la-mer/ancrage-secteur-ZMEL=Moulade-&gt;plongée</metric>
    <metric>port-origine=Canet-en-Roussillon/ancrage-secteur-ZMEL=Moulade-&gt;plongée</metric>
    <metric>port-origine=Saint-Cyprien/ancrage-secteur-ZMEL=Moulade-&gt;plongée</metric>
    <metric>port-origine=Argelès-sur-mer/ancrage-secteur-ZMEL=Moulade-&gt;plongée</metric>
    <metric>port-origine=Collioure/ancrage-secteur-ZMEL=Moulade-&gt;plongée</metric>
    <metric>port-origine=Port-vendres/ancrage-secteur-ZMEL=Moulade-&gt;plongée</metric>
    <metric>port-origine=Banyuls-sur-mer/ancrage-secteur-ZMEL=Moulade-&gt;plongée</metric>
    <metric>port-origine=Cerbere/ancrage-secteur-ZMEL=Moulade-&gt;plongée</metric>
    <metric>port-origine=Leucate/ancrage-secteur-ZMEL=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Barcares/ancrage-secteur-ZMEL=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Sainte-marie-la-mer/ancrage-secteur-ZMEL=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Canet-en-Roussillon/ancrage-secteur-ZMEL=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Saint-Cyprien/ancrage-secteur-ZMEL=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Argelès-sur-mer/ancrage-secteur-ZMEL=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Collioure/ancrage-secteur-ZMEL=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Port-vendres/ancrage-secteur-ZMEL=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Banyuls-sur-mer/ancrage-secteur-ZMEL=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Cerbere/ancrage-secteur-ZMEL=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Leucate/ancrage-secteur-ZMEL=Bear-&gt;plongée</metric>
    <metric>port-origine=Barcares/ancrage-secteur-ZMEL=Bear-&gt;plongée</metric>
    <metric>port-origine=Sainte-marie-la-mer/ancrage-secteur-ZMEL=Bear-&gt;plongée</metric>
    <metric>port-origine=Canet-en-Roussillon/ancrage-secteur-ZMEL=Bear-&gt;plongée</metric>
    <metric>port-origine=Saint-Cyprien/ancrage-secteur-ZMEL=Bear-&gt;plongée</metric>
    <metric>port-origine=Argelès-sur-mer/ancrage-secteur-ZMEL=Bear-&gt;plongée</metric>
    <metric>port-origine=Collioure/ancrage-secteur-ZMEL=Bear-&gt;plongée</metric>
    <metric>port-origine=Port-vendres/ancrage-secteur-ZMEL=Bear-&gt;plongée</metric>
    <metric>port-origine=Banyuls-sur-mer/ancrage-secteur-ZMEL=Bear-&gt;plongée</metric>
    <metric>port-origine=Cerbere/ancrage-secteur-ZMEL=Bear-&gt;plongée</metric>
    <metric>port-origine=Leucate/ancrage-secteur-ZMEL=Abeille-&gt;plongée</metric>
    <metric>port-origine=Barcares/ancrage-secteur-ZMEL=Abeille-&gt;plongée</metric>
    <metric>port-origine=Sainte-marie-la-mer/ancrage-secteur-ZMEL=Abeille-&gt;plongée</metric>
    <metric>port-origine=Canet-en-Roussillon/ancrage-secteur-ZMEL=Abeille-&gt;plongée</metric>
    <metric>port-origine=Saint-Cyprien/ancrage-secteur-ZMEL=Abeille-&gt;plongée</metric>
    <metric>port-origine=Argelès-sur-mer/ancrage-secteur-ZMEL=Abeille-&gt;plongée</metric>
    <metric>port-origine=Collioure/ancrage-secteur-ZMEL=Abeille-&gt;plongée</metric>
    <metric>port-origine=Port-vendres/ancrage-secteur-ZMEL=Abeille-&gt;plongée</metric>
    <metric>port-origine=Banyuls-sur-mer/ancrage-secteur-ZMEL=Abeille-&gt;plongée</metric>
    <metric>port-origine=Cerbere/ancrage-secteur-ZMEL=Abeille-&gt;plongée</metric>
    <metric>port-origine=Leucate/ancrage-secteur-ZMEL=Peyrefite-&gt;plongée</metric>
    <metric>port-origine=Barcares/ancrage-secteur-ZMEL=Peyrefite-&gt;plongée</metric>
    <metric>port-origine=Sainte-marie-la-mer/ancrage-secteur-ZMEL=Peyrefite-&gt;plongée</metric>
    <metric>port-origine=Canet-en-Roussillon/ancrage-secteur-ZMEL=Peyrefite-&gt;plongée</metric>
    <metric>port-origine=Saint-Cyprien/ancrage-secteur-ZMEL=Peyrefite-&gt;plongée</metric>
    <metric>port-origine=Argelès-sur-mer/ancrage-secteur-ZMEL=Peyrefite-&gt;plongée</metric>
    <metric>port-origine=Collioure/ancrage-secteur-ZMEL=Peyrefite-&gt;plongée</metric>
    <metric>port-origine=Port-vendres/ancrage-secteur-ZMEL=Peyrefite-&gt;plongée</metric>
    <metric>port-origine=Banyuls-sur-mer/ancrage-secteur-ZMEL=Peyrefite-&gt;plongée</metric>
    <metric>port-origine=Cerbere/ancrage-secteur-ZMEL=Peyrefite-&gt;plongée</metric>
    <metric>port-origine=Leucate/ancrage-secteur-ZMEL=Cerbere-&gt;plongée</metric>
    <metric>port-origine=Barcares/ancrage-secteur-ZMEL=Cerbere-&gt;plongée</metric>
    <metric>port-origine=Sainte-marie-la-mer/ancrage-secteur-ZMEL=Cerbere-&gt;plongée</metric>
    <metric>port-origine=Canet-en-Roussillon/ancrage-secteur-ZMEL=Cerbere-&gt;plongée</metric>
    <metric>port-origine=Saint-Cyprien/ancrage-secteur-ZMEL=Cerbere-&gt;plongée</metric>
    <metric>port-origine=Argelès-sur-mer/ancrage-secteur-ZMEL=Cerbere-&gt;plongée</metric>
    <metric>port-origine=Collioure/ancrage-secteur-ZMEL=Cerbere-&gt;plongée</metric>
    <metric>port-origine=Port-vendres/ancrage-secteur-ZMEL=Cerbere-&gt;plongée</metric>
    <metric>port-origine=Banyuls-sur-mer/ancrage-secteur-ZMEL=Cerbere-&gt;plongée</metric>
    <metric>port-origine=Cerbere/ancrage-secteur-ZMEL=Cerbere-&gt;plongée</metric>
    <metric>port-origine=Leucate/ancrage-secteur-ZAA=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Barcares/ancrage-secteur-ZAA=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Sainte-marie-la-mer/ancrage-secteur-ZAA=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Canet-en-Roussillon/ancrage-secteur-ZAA=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Saint-Cyprien/ancrage-secteur-ZAA=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Argelès-sur-mer/ancrage-secteur-ZAA=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Collioure/ancrage-secteur-ZAA=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Port-vendres/ancrage-secteur-ZAA=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Banyuls-sur-mer/ancrage-secteur-ZAA=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Cerbere/ancrage-secteur-ZAA=Mauresque-&gt;plongée</metric>
    <metric>port-origine=Leucate/ancrage-secteur-ZAA=Bear-&gt;plongée</metric>
    <metric>port-origine=Barcares/ancrage-secteur-ZAA=Bear-&gt;plongée</metric>
    <metric>port-origine=Sainte-marie-la-mer/ancrage-secteur-ZAA=Bear-&gt;plongée</metric>
    <metric>port-origine=Canet-en-Roussillon/ancrage-secteur-ZAA=Bear-&gt;plongée</metric>
    <metric>port-origine=Saint-Cyprien/ancrage-secteur-ZAA=Bear-&gt;plongée</metric>
    <metric>port-origine=Argelès-sur-mer/ancrage-secteur-ZAA=Bear-&gt;plongée</metric>
    <metric>port-origine=Collioure/ancrage-secteur-ZAA=Bear-&gt;plongée</metric>
    <metric>port-origine=Port-vendres/ancrage-secteur-ZAA=Bear-&gt;plongée</metric>
    <metric>port-origine=Banyuls-sur-mer/ancrage-secteur-ZAA=Bear-&gt;plongée</metric>
    <metric>port-origine=Cerbere/ancrage-secteur-ZAA=Bear-&gt;plongée</metric>
    <metric>%-accès-destination-initiale-&gt;plaisance</metric>
    <metric>%-changement-destination-&gt;plaisance</metric>
    <metric>%-amarrage-bouée-&gt;plaisance</metric>
    <metric>%-amarrage-bouée-solo-&gt;plaisance</metric>
    <metric>%-amarrage-bouée-couple-&gt;plaisance</metric>
    <metric>%-cabotage-&gt;plaisance</metric>
    <metric>%-ancrage-&gt;plaisance</metric>
    <metric>%-accès-destination-initiale-&gt;plongée</metric>
    <metric>%-changement-destination-&gt;plongée</metric>
    <metric>%-amarrage-bouée-&gt;plongée</metric>
    <metric>%-amarrage-bouée-solo-&gt;plongée</metric>
    <metric>%-amarrage-bouée-couple-&gt;plongée</metric>
    <metric>%-cabotage-&gt;plongée</metric>
    <metric>%-ancrage-&gt;plongée</metric>
    <metric>détails-dest-plais</metric>
    <metric>détails-orig-plais</metric>
    <metric>détails-dest-plong</metric>
    <metric>détails-orig-plong</metric>
    <enumeratedValueSet variable="nb-btx-plongée-Argelès-sur-mer">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-btx-plongée-Sainte-marie-la-mer">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-btx-plaisance-Canet-en-Roussillon">
      <value value="36"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-btx-plaisance-Barcares">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-btx-plongée-Collioure">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-btx-plongée-Banyuls-sur-mer">
      <value value="6"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-btx-plaisance-Sainte-marie-la-mer">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-btx-plaisance-Saint-Cyprien">
      <value value="150"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-btx-plongée-Barcares">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-btx-plongée-Saint-Cyprien">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-btx-plaisance-Cerbere">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="vent-dominant">
      <value value="&quot;tramontane&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-btx-plongée-Cerbere">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="saison">
      <value value="&quot;haute&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-btx-plaisance-Leucate">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-btx-plaisance-Banyuls-sur-mer">
      <value value="52"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-btx-plaisance-Collioure">
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nombre-bateaux-plaisance">
      <value value="516"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-btx-plaisance-Argelès-sur-mer">
      <value value="181"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-btx-plongée-Port-vendres">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-btx-plongée-Leucate">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-btx-plongée-Canet-en-Roussillon">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nb-btx-plaisance-Port-vendres">
      <value value="62"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="nombre-bateaux-plongée">
      <value value="18"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="force-du-vent">
      <value value="&quot;insignifiante&quot;"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
