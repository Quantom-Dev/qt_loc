# Quantom Loc - Système de location de véhicules pour ESX Legacy

## Description
Quantom Loc est un système complet de location de véhicules pour votre serveur FiveM utilisant ESX Legacy. Il permet aux joueurs de louer des véhicules à différents points de location sur la carte avec une interface utilisateur moderne et intuitive.

## Caractéristiques
- Interface utilisateur moderne et responsive
- Points de location personnalisables sur la carte
- Système de catégories pour organiser les véhicules
- Choix de couleurs pour les véhicules loués
- Plusieurs méthodes de paiement (espèces/carte bancaire)
- Système de points de retour des véhicules
- PNJ interactifs aux points de location
- Blips personnalisables sur la carte
- Recherche et tri des véhicules
- Interface développée avec Vue.js pour une expérience fluide

## Dépendances
- ESX Legacy
- oxmysql

## Installation
1. Téléchargez les fichiers et placez-les dans votre dossier `resources`
2. Ajoutez `ensure Quantom_Loc` à votre fichier `server.cfg`
3. Redémarrez votre serveur

## Configuration
Le fichier `config.lua` vous permet de personnaliser entièrement le système de location:

### Options générales
```lua
Config.Locale = 'fr'
Config.DrawDistance = 10.0
Config.MarkerType = 25
Config.MarkerSize = {x = 1.0, y = 1.0, z = 1.0}
Config.MarkerColor = {r = 0, g = 150, b = 200, a = 100}
```

### Méthodes de paiement
```lua
Config.PaymentMethods = {
    {label = 'Espèces', value = 'money'},
    {label = 'Carte Bancaire', value = 'bank'}
}
```

### Points de location
Configurez facilement les points de location avec leurs propres véhicules:
```lua
Config.RentalPoints = {
    {
        name = "Location Centre-Ville",
        pos = vector3(-283.06, -891.13, 31.08),
        blip = {
            sprite = 480,
            color = 4,
            scale = 0.7,
            label = "Location de Véhicules"
        },
        ped = {
            model = "s_m_m_gentransport",
            heading = 175.0,
            scenario = "WORLD_HUMAN_CLIPBOARD"
        },
        returnPos = vector3(-292.97, -886.46, 30.44),
        spawnPos = vector4(-285.79, -887.69, 30.44, 167.37),
        vehicles = {
            {
                name = "Panto",
                model = "panto",
                price = 750,
                category = "Citadines",
                img = "panto.png"
            },
            // Ajoutez d'autres véhicules ici
        }
    },
    // Ajoutez d'autres points de location ici
}
```

### Options de couleurs
Personnalisez les couleurs disponibles pour les véhicules loués:
```lua
Config.Colors = {
    {name = "Noir", colorIndex = 0, rgb = {0, 0, 0}},
    {name = "Blanc", colorIndex = 111, rgb = {255, 255, 255}},
    {name = "Rouge", colorIndex = 27, rgb = {255, 0, 0}},
    // Ajoutez d'autres couleurs ici
}
```

## Fonctionnement
Le système de location fonctionne en trois étapes simples:

1. **Sélection du véhicule**: Les joueurs peuvent parcourir les véhicules disponibles, les filtrer par catégorie ou rechercher un modèle spécifique.

2. **Choix de la couleur**: Une fois le véhicule sélectionné, les joueurs peuvent choisir parmi plusieurs couleurs disponibles.

3. **Méthode de paiement**: Les joueurs choisissent entre payer en espèces ou par carte bancaire, puis confirment la location.

Le véhicule est ensuite spawné au point désigné et le joueur peut l'utiliser. Pour retourner le véhicule, le joueur doit simplement se rendre à un point de retour (marqué en rouge sur la carte) et suivre les instructions à l'écran.

## Personnalisation
### Images des véhicules
Placez les images des véhicules dans le dossier `ui/assets/images/` avec le nom correspondant défini dans la configuration (exemple: `panto.png`).

### Interface utilisateur
L'interface utilisateur est développée avec Vue.js et peut être facilement personnalisée en modifiant les fichiers:
- `ui/index.html` - Structure de l'interface
- `ui/style.css` - Styles et apparence visuelle
- `ui/app.js` - Logique de l'interface

## Développement et Support
Pour toute question ou problème concernant ce script, n'hésitez pas à me contacter.

## Licence
Ce script est distribué sous licence privée et ne peut être redistribué sans autorisation.

---

J'espère que vous apprécierez ce système de location de véhicules pour votre serveur! N'hésitez pas à me faire part de vos commentaires ou suggestions d'amélioration.
