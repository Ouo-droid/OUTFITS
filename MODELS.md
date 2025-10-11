# Modèles de données - OUTFITS

## Vue d'ensemble
Ce document décrit les modèles de données utilisés dans l'application OUTFITS, une application de gestion de garde-robe développée en SwiftUI.

## 1. Modèle Item

### Propriétés
- **id**: Identifiant unique généré automatiquement
- **name**: Nom de l'article
- **brand**: Marque de l'article
- **category**: Catégorie de l'article (voir énumération ci-dessous)
- **color**: Couleur de l'article
- **size**: Taille de l'article
- **season**: Saison appropriée (voir énumération ci-dessous)
- **imageData**: Données de l'image (optionnel)
- **dateAdded**: Date d'ajout de l'article
- **notes**: Notes personnelles sur l'article

## 2. Énumération ItemCategory

### Valeurs possibles
- **top**: "Haut" - Icône: "tshirt"
- **bottom**: "Bas" - Icône: "figure.walk"
- **dress**: "Robe" - Icône: "figure.dress.line.vertical.figure"
- **outerwear**: "Veste/Manteau" - Icône: "jacket"
- **shoes**: "Chaussures" - Icône: "shoe.2"
- **accessories**: "Accessoires" - Icône: "bag"
- **underwear**: "Sous-vêtements" - Icône: "figure.arms.open"
- **sportswear**: "Sport" - Icône: "figure.run"

## 3. Énumération Season

### Valeurs possibles
- **spring**: "Printemps" - Couleur: Vert
- **summer**: "Été" - Couleur: Jaune
- **autumn**: "Automne" - Couleur: Orange
- **winter**: "Hiver" - Couleur: Bleu
- **all**: "Toutes saisons" - Couleur: Gris

## 4. Modèle Outfit

### Propriétés
- **id**: Identifiant unique généré automatiquement
- **name**: Nom de la tenue
- **items**: Liste des articles composant la tenue
- **season**: Saison appropriée pour la tenue
- **occasion**: Occasion pour laquelle la tenue est destinée
- **rating**: Note de 1 à 5 étoiles
- **dateCreated**: Date de création de la tenue
- **lastWorn**: Date de dernière utilisation (optionnel)
- **notes**: Notes personnelles sur la tenue
- **isFavorite**: Indique si la tenue est en favori

### Propriétés calculées
- **totalItems**: Nombre total d'articles dans la tenue
- **hasCompleteOutfit**: Indique si la tenue est complète (haut + bas + chaussures)

## 5. Énumération Occasion

### Valeurs possibles
- **casual**: "Décontracté" - Icône: "person.crop.circle" - Couleur: Bleu
- **work**: "Travail" - Icône: "briefcase" - Couleur: Gris
- **formal**: "Formel" - Icône: "suit.heart" - Couleur: Noir
- **party**: "Soirée" - Icône: "party.popper" - Couleur: Violet
- **sport**: "Sport" - Icône: "figure.run" - Couleur: Vert
- **travel**: "Voyage" - Icône: "airplane" - Couleur: Orange
- **date**: "Rendez-vous" - Icône: "heart" - Couleur: Rose
- **home**: "Maison" - Icône: "house" - Couleur: Marron

## 6. Logique métier

### Validation de tenue complète
La propriété hasCompleteOutfit vérifie qu'une tenue contient :
- Un haut (top) OU une robe (dress)
- Un bas (bottom) OU une robe (dress)
- Des chaussures (shoes)

### Conformité aux protocoles
- **Identifiable**: Pour l'utilisation dans les listes SwiftUI
- **Codable**: Pour la sérialisation/désérialisation
- **Hashable**: Pour l'utilisation dans les collections et comparaisons

## 7. Utilisation dans l'interface

### Icônes
Les énumérations ItemCategory et Occasion fournissent des icônes SF Symbols pour l'affichage dans l'interface utilisateur.

### Couleurs
Les énumérations Season et Occasion fournissent des couleurs SwiftUI pour l'affichage visuel et la catégorisation.

## 8. Persistance des données

Les modèles implémentent Codable, permettant leur sauvegarde et chargement depuis le stockage local de l'appareil via WardrobeManager.

