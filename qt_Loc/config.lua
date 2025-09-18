Config = {}

Config.Locale = 'fr'
Config.DrawDistance = 10.0
Config.MarkerType = 25
Config.MarkerSize = {x = 1.0, y = 1.0, z = 1.0}
Config.MarkerColor = {r = 0, g = 150, b = 200, a = 100}

Config.PaymentMethods = {
    {label = 'Espèces', value = 'money'},
    {label = 'Carte Bancaire', value = 'bank'}
}

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
            {
                name = "Blista",
                model = "blista",
                price = 950,
                category = "Citadines",
                img = "blista.png"
            },
            {
                name = "Sultan",
                model = "sultan",
                price = 1500,
                category = "Sportives",
                img = "sultan.png"
            },
            {
                name = "Baller",
                model = "baller",
                price = 2200,
                category = "SUV",
                img = "baller.png"
            },
            {
                name = "Sanchez",
                model = "sanchez",
                price = 1100,
                category = "Motos",
                img = "sanchez.png"
            }
        }
    },
    {
        name = "Location Aéroport",
        pos = vector3(-1037.58, -2680.81, 14.06),
        blip = {
            sprite = 480,
            color = 4,
            scale = 0.7,
            label = "Location de Véhicules"
        },
        ped = {
            model = "s_m_y_airworker",
            heading = 59.29,
            scenario = "WORLD_HUMAN_CLIPBOARD"
        },
        returnPos = vector3(-1042.06, -2676.55, 13.83),
        spawnPos = vector4(-1038.81, -2678.42, 13.19, 327.11),
        vehicles = {
            {
                name = "Faggio",
                model = "faggio",
                price = 450,
                category = "Motos",
                img = "faggio.png"
            },
            {
                name = "Asea",
                model = "asea",
                price = 800,
                category = "Citadines",
                img = "asea.png"
            },
            {
                name = "Washington",
                model = "washington",
                price = 1200,
                category = "Berlines",
                img = "washington.png"
            },
            {
                name = "Bison",
                model = "bison",
                price = 1800,
                category = "Utilitaires",
                img = "bison.png"
            }
        }
    }
}

Config.Colors = {
    {name = "Noir", colorIndex = 0, rgb = {0, 0, 0}},
    {name = "Blanc", colorIndex = 111, rgb = {255, 255, 255}},
    {name = "Rouge", colorIndex = 27, rgb = {255, 0, 0}},
    {name = "Bleu", colorIndex = 64, rgb = {0, 0, 255}},
    {name = "Vert", colorIndex = 53, rgb = {0, 255, 0}},
    {name = "Jaune", colorIndex = 88, rgb = {255, 255, 0}},
    {name = "Orange", colorIndex = 38, rgb = {255, 128, 0}},
    {name = "Gris", colorIndex = 5, rgb = {128, 128, 128}},
    {name = "Rose", colorIndex = 135, rgb = {255, 0, 255}},
    {name = "Violet", colorIndex = 145, rgb = {128, 0, 128}}
}