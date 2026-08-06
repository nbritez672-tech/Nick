--[[
    Yin Yang - UI Ultimate Edition (v26.1)  SOUND BUG FIXED
    ============================================================
     ARREGLOS CRÍTICOS v26.1:
    
    1. FIX SONIDO GLOBAL: El slider ya NO reproduce sonido en inputs globales
       - Eliminado playSound en InputChanged (línea 1508)
       - Cambiado de UserInputService.InputEnded a SliderThumb.InputEnded
       - El sonido SOLO se escucha al ajustar el slider, no en todo input de pantalla
    
    2. AHORA COMPATIBLE: Puedes jugar EVADE sin escuchar sonidos del slider
    
     CARACTERÍSTICAS ORIGINALES MANTENIDAS:
    
    1. LOGO YIN-YANG ROTATIVO: Logo animado que gira continuamente
    2. SONIDOS INTEGRADOS:
       - Click al activar/desactivar (138567614125924)
       - Dragón aleatorio cuando está cerrado (7127123554) - cada 15 segundos, volumen reducido
    3. TOGGLES FLOTANTES: 
       - Pueden desprenderse de la UI principal
       - Se pueden fijar (+) o soltar (-) 
       - Se mueven libremente por la pantalla

--// ══════════════════════════════════════════════════════════════════════════════
--// GUÍA: CÓMO CREAR PESTAÑAS CON ASSETS (ICONOS)
--// ══════════════════════════════════════════════════════════════════════════════
--//
--// SINTAXIS BÁSICA:
--// local MiTab = Window:CreateTab("Nombre de la Pestaña", "rbxassetid://ASSET_ID")
--//
--// EJEMPLO 1: Crear una pestaña con icono de casa
--// local TabCasa = Window:CreateTab("Mi Casa", "rbxassetid://71085559019524")
--//
--// EJEMPLO 2: Crear una pestaña sin icono
--// local TabSimple = Window:CreateTab("Simple", nil)
--// O directamente sin el segundo parámetro:
--// local TabSimple = Window:CreateTab("Simple")
--//
--// EJEMPLO 3: Usar diferentes assets
--// local TabManzana = Window:CreateTab("Frutas", "rbxassetid://108938004711116")
--// local TabRayo = Window:CreateTab("Energía", "rbxassetid://132646825035547")
--// local TabAjustes = Window:CreateTab("Configuración", "rbxassetid://130729134186771")
--//
--// LISTA DE ASSETS DISPONIBLES EN LA LIBRERÍA:
--// • Casa: 124987849953130
--// • Manzana: 84419345138935
--// • Rayo: 114693810646148
--// • Ajustes: 86797720103644
--// • Candado: 115388161816720
--// • Llave: 135318845352652
--// • Lupa: 83456197177232
--// • Brújula: 121857625643442
--// • Y muchos más...
--//
--// NOTA IMPORTANTE:
--// • El icono se mostrará a la IZQUIERDA del nombre de la pestaña
--// • El icono es pequeño (16x16px) pero claramente visible
--// • El tamaño se ajusta automáticamente para no molestar el texto
--// • Los nombres de pestaña siempre permanecen visibles
--//
--// ══════════════════════════════════════════════════════════════════════════════

       - Persistencia de posición
    4. SISTEMA PROFESIONAL DE AUDIO
    5. MANEJO AVANZADO DE VENTANAS FLOTANTES
    
    TOKENS USADOS:
    - Yin-Yang: 84935900372278
    - Click Sound: 138567614125924
    - Dragon Sound: 7127123554
--]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local LocalPlayer = Players.LocalPlayer

pcall(function()
    if LocalPlayer.PlayerGui:FindFirstChild("ZeroMobile") then
        LocalPlayer.PlayerGui.ZeroMobile:Destroy()
    end
end)

--// SONIDOS
local Sounds = {
    Click = "rbxassetid://138567614125924",
    Dragon = "rbxassetid://7127123554",
}

--// ═════════════════════════════════════════════════════════════════════════════
--// SISTEMA DE LENGUAJE BILINGÜE (v28 PRO)
--// ═════════════════════════════════════════════════════════════════════════════
local LanguageSystem = {
    CurrentLanguage = "es",  -- "es" = Español, "en" = English
    Config = { Language = "es" }
}

local function GetText(spanishText, englishText)
    if LanguageSystem.CurrentLanguage == "es" then
        return spanishText
    else
        return englishText
    end
end

local function ChangeLanguage(newLanguage)
    if newLanguage ~= "es" and newLanguage ~= "en" then
        error("Idioma no válido. Usa 'es' o 'en'")
        return
    end
    LanguageSystem.CurrentLanguage = newLanguage
    LanguageSystem.Config.Language = newLanguage
end

local function SaveLanguageConfig()
    pcall(function()
        if writefile then
            local configJson = HttpService:JSONEncode(LanguageSystem.Config)
            writefile("yin_yang_language_config.json", configJson)
        end
    end)
end

local function LoadLanguageConfig()
    pcall(function()
        if readfile and isfile and isfile("yin_yang_language_config.json") then
            local configJson = readfile("yin_yang_language_config.json")
            LanguageSystem.Config = HttpService:JSONDecode(configJson)
            LanguageSystem.CurrentLanguage = LanguageSystem.Config.Language or "es"
        end
    end)
end

LoadLanguageConfig()
--// ═════════════════════════════════════════════════════════════════════════════

--// VARIABLE DE ESTADO: Freeze Icono
local IconoCongelado = false

--//  SONIDOS DE CLICK PERSONALIZADOS POR TEMA (v26)
local ThemeClickSounds = {
    CatV1 = "rbxassetid://133371725828981",
    PinkV2 = "rbxassetid://136022651109523",
    PinkV1 = "rbxassetid://15675081158",
    PinkV3 = "rbxassetid://75880354609739",
    ErisV1 = "rbxassetid://137965684634919",
    VioletaV1 = "rbxassetid://115624890613221",
    GreenV1 = "rbxassetid://9112751731",
    DarkV2 = "rbxassetid://139804904213958",
    BlueV2 = "rbxassetid://118574877365368",
    WhiteV2 = "rbxassetid://140043289814504",
    WhiteAndDark = "rbxassetid://139239108826837",
    LightV1 = "rbxassetid://99071431420752",
    NaranjaV1 = "rbxassetid://124502189759941",
}

--// SISTEMA DE SONIDO DINÁMICO POR TEMA
local CurrentClickSound = Sounds.Click
local CurrentTheme = "Dark"

--//  v26: VARIABLE PARA ACTIVAR/DESACTIVAR SONIDOS PERSONALIZADOS
local DynamicClickSoundsEnabled = true  --  Cambiar a false para desactivar

--//  SISTEMA RAINBOW DARK-WHITE: Cambia lentamente de negro a blanco
local RainbowDarkWhiteActive = false
local RainbowDarkWhiteValue = 0
local RainbowDarkWhiteLabels = {}

--// 🌙 LETRAS DE "CANTO DE LUNA" PARA TÍTULO ANIMADO (v26)
local CantoLunaLetras = {
    "Yin Yang",
    "Canto de Luna",
    "la-la-la 🌙",
    "Canta, canta",
    "En mi corazón",
    "la-la-la ",
    "Eres lo que buscamos",
    "Con la luz 💫",
    "Canta, canta, canta",
    "Yo te vi",
}

--//  COLORES RAINBOW (Prioridad: BLANCO)
local RainbowColors = {
    Color3.fromRGB(255, 255, 0),      -- Amarillo
    Color3.fromRGB(255, 255, 255),    -- BLANCO ⭐
    Color3.fromRGB(255, 0, 0),        -- Rojo
    Color3.fromRGB(255, 255, 255),    -- BLANCO ⭐
    Color3.fromRGB(0, 255, 0),        -- Verde
    Color3.fromRGB(255, 255, 255),    -- BLANCO ⭐
    Color3.fromRGB(0, 0, 255),        -- Azul
    Color3.fromRGB(255, 255, 255),    -- BLANCO ⭐
    Color3.fromRGB(255, 165, 0),      -- Naranja
    Color3.fromRGB(255, 255, 255),    -- BLANCO ⭐
}

--//  COLORES DE BORDE ANIMADO PARA FLOATING TOGGLES (v26.1 PREMIUM)
local FloatingToggleBorderColors = {
    -- DARK THEMES (Azules y Cian)
    Dark = {
        Color3.fromRGB(100, 200, 255),    -- Cian claro
        Color3.fromRGB(150, 100, 255),    -- Púrpura
        Color3.fromRGB(100, 150, 255),    -- Azul
        Color3.fromRGB(200, 150, 255),    -- Púrpura claro
    },
    DarkV2 = {
        Color3.fromRGB(100, 180, 255),
        Color3.fromRGB(120, 200, 255),
        Color3.fromRGB(80, 150, 255),
        Color3.fromRGB(150, 180, 255),
    },
    
    -- RED THEMES (Rojos y Naranjas)
    Red = {
        Color3.fromRGB(255, 100, 100),    -- Rojo claro
        Color3.fromRGB(255, 150, 100),    -- Naranja-rojo
        Color3.fromRGB(255, 80, 120),     -- Rojo-rosa
        Color3.fromRGB(255, 120, 100),    -- Naranja
    },
    RedV2 = {
        Color3.fromRGB(255, 120, 100),
        Color3.fromRGB(255, 100, 150),
        Color3.fromRGB(255, 150, 80),
        Color3.fromRGB(255, 100, 100),
    },
    
    -- PINK THEMES (Rosas y Púrpuras)
    Pink = {
        Color3.fromRGB(255, 100, 200),    -- Rosa
        Color3.fromRGB(255, 150, 200),    -- Rosa claro
        Color3.fromRGB(200, 100, 200),    -- Púrpura-rosa
        Color3.fromRGB(255, 100, 150),    -- Rosa-rojo
    },
    PinkV2 = {
        Color3.fromRGB(255, 120, 200),
        Color3.fromRGB(255, 80, 180),
        Color3.fromRGB(220, 100, 200),
        Color3.fromRGB(255, 150, 200),
    },
    PinkV3 = {
        Color3.fromRGB(255, 100, 180),
        Color3.fromRGB(255, 150, 210),
        Color3.fromRGB(200, 80, 180),
        Color3.fromRGB(255, 120, 190),
    },
    
    -- BLUE THEMES (Azules y Cian)
    Blue = {
        Color3.fromRGB(100, 200, 255),    -- Cian
        Color3.fromRGB(150, 200, 255),    -- Azul claro
        Color3.fromRGB(100, 150, 200),    -- Azul
        Color3.fromRGB(200, 220, 255),    -- Azul muy claro
    },
    BlueV2 = {
        Color3.fromRGB(80, 180, 255),
        Color3.fromRGB(120, 200, 255),
        Color3.fromRGB(100, 160, 255),
        Color3.fromRGB(150, 210, 255),
    },
    
    -- WHITE THEMES (Blancos y Grises)
    White = {
        Color3.fromRGB(200, 200, 200),    -- Gris claro
        Color3.fromRGB(255, 255, 255),    -- Blanco
        Color3.fromRGB(220, 220, 220),    -- Gris
        Color3.fromRGB(240, 240, 240),    -- Blanco roto
    },
    WhiteV2 = {
        Color3.fromRGB(220, 220, 220),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(200, 200, 200),
        Color3.fromRGB(230, 230, 230),
    },
    WhiteV3 = {
        Color3.fromRGB(210, 210, 210),
        Color3.fromRGB(240, 240, 240),
        Color3.fromRGB(190, 190, 190),
        Color3.fromRGB(255, 255, 255),
    },
    WhiteAndDark = {
        Color3.fromRGB(100, 100, 100),
        Color3.fromRGB(255, 255, 255),
        Color3.fromRGB(150, 150, 150),
        Color3.fromRGB(200, 200, 200),
    },
    
    -- GREEN THEME (Verdes)
    Green = {
        Color3.fromRGB(100, 255, 150),    -- Verde claro
        Color3.fromRGB(150, 255, 100),    -- Verde-amarillo
        Color3.fromRGB(100, 200, 150),    -- Verde
        Color3.fromRGB(150, 255, 180),    -- Verde muy claro
    },
    
    -- SPECIAL THEMES
    NaranjaV1 = {
        Color3.fromRGB(255, 150, 50),     -- Naranja
        Color3.fromRGB(255, 100, 80),     -- Naranja-rojo
        Color3.fromRGB(255, 180, 100),    -- Naranja claro
        Color3.fromRGB(255, 120, 60),     -- Naranja oscuro
    },
    VioletaV1 = {
        Color3.fromRGB(180, 100, 255),    -- Púrpura
        Color3.fromRGB(200, 150, 255),    -- Púrpura claro
        Color3.fromRGB(150, 80, 255),     -- Púrpura oscuro
        Color3.fromRGB(220, 180, 255),    -- Púrpura muy claro
    },
    CatV1 = {
        Color3.fromRGB(255, 100, 150),    -- Rosa
        Color3.fromRGB(255, 150, 100),    -- Naranja
        Color3.fromRGB(200, 100, 200),    -- Púrpura
        Color3.fromRGB(255, 120, 120),    -- Rojo-rosa
    },
    LightV1 = {
        Color3.fromRGB(255, 220, 100),    -- Amarillo claro
        Color3.fromRGB(255, 255, 150),    -- Amarillo muy claro
        Color3.fromRGB(255, 200, 100),    -- Amarillo-naranja
        Color3.fromRGB(255, 240, 150),    -- Crema
    },
    ErisV1 = {
        Color3.fromRGB(255, 80, 80),      -- Rojo oscuro
        Color3.fromRGB(180, 50, 50),      -- Rojo muy oscuro
        Color3.fromRGB(255, 100, 100),    -- Rojo claro
        Color3.fromRGB(200, 60, 60),      -- Rojo
    },
    ShylfieV1 = {
        Color3.fromRGB(100, 180, 255),    -- Azul claro
        Color3.fromRGB(150, 200, 255),    -- Azul cielo
        Color3.fromRGB(80, 160, 255),     -- Azul
        Color3.fromRGB(200, 220, 255),    -- Azul muy claro
    },
}

--// 💾 SISTEMA DE GUARDADO/PERSISTENCIA (v26 - MEJORADO)
local ConfigFile = "Yin_Yang_Config.txt"
local SavedConfig = {
    CurrentTheme = "Dark",
    CurrentEffect = "Normal",
    Volume = 0.5,
    HideSliders = false,
    Favorites = "",
}

local function SaveConfig()
    pcall(function()
        local configData = table.concat({
            "theme:" .. tostring(SavedConfig.CurrentTheme or CurrentTheme or "Dark"),
            "effect:" .. tostring(SavedConfig.CurrentEffect or "Normal"),
            "volume:" .. tostring(SavedConfig.Volume or 0.5),
            "libMode:" .. tostring(SavedConfig.LibrarySizeMode or "Small"),
            "libHeight:" .. tostring(SavedConfig.LibraryHeight or 340),
            "lang:" .. tostring(LanguageSystem.CurrentLanguage or "es"),
            "hideSliders:" .. tostring(SavedConfig.HideSliders or false),
            "favorites:" .. tostring(SavedConfig.Favorites or ""),
            "time:" .. tostring(os.time()),
        }, "|")
        writefile(ConfigFile, configData)
    end)
end

local function LoadConfig()
    local result = {
        theme = nil,
        effect = nil,
        volume = nil,
        libMode = nil,
        libHeight = nil,
        lang = nil,
        hideSliders = nil,
        favorites = nil,
    }

    pcall(function()
        if readfile(ConfigFile) then
            local content = readfile(ConfigFile)
            if content and content ~= "" then
                for part in content:gmatch("([^|]+)") do
                    local key, value = part:match("([^:]+):(.+)")
                    if key == "theme" then
                        result.theme = value
                    elseif key == "effect" then
                        result.effect = value
                    elseif key == "volume" then
                        result.volume = tonumber(value)
                    elseif key == "libMode" then
                        result.libMode = value
                    elseif key == "libHeight" then
                        result.libHeight = tonumber(value)
                    elseif key == "lang" then
                        result.lang = value
                    elseif key == "hideSliders" then
                        result.hideSliders = (value == "true")
                    elseif key == "favorites" then
                        result.favorites = value
                    end
                end
            end
        end
    end)
    return result
end

--// POOL DE SONIDOS: reutiliza Instances en vez de crear/destruir una por cada click
local SoundPool = {}
local POOL_SIZE = 8
local poolCursor = 0

local function getPooledSound()
    -- 1) intenta encontrar uno libre (que no esté sonando)
    for _, s in ipairs(SoundPool) do
        if not s.IsPlaying then
            return s
        end
    end
    -- 2) si el pool no está lleno, crea uno nuevo y lo agrega
    if #SoundPool < POOL_SIZE then
        local s = Instance.new("Sound")
        s.Parent = SoundService
        table.insert(SoundPool, s)
        return s
    end
    -- 3) pool lleno y todos ocupados: reutiliza el siguiente en rotación (round robin)
    poolCursor = (poolCursor % #SoundPool) + 1
    return SoundPool[poolCursor]
end

local function playSound(soundId, volume)
    volume = volume or 0.5
    
    --//  v26: USAR SONIDO DINÁMICO SI ESTÁ ACTIVADO
    local finalSoundId = soundId
    
    -- Si sonidos dinámicos están activados, ignorar Sounds.Click y usar el del tema
    if DynamicClickSoundsEnabled and (soundId == Sounds.Click or not soundId) then
        if CurrentTheme and ThemeClickSounds[CurrentTheme] then
            finalSoundId = ThemeClickSounds[CurrentTheme]
        else
            finalSoundId = Sounds.Click
        end
    end
    
    if not finalSoundId or finalSoundId == "" then 
        finalSoundId = Sounds.Click
    end
    
    local sound = getPooledSound()
    if sound then
        pcall(function()
            sound.SoundId = finalSoundId
            sound.Volume = math.clamp(volume, 0, 1)
            sound.TimePosition = 0
            sound.Playing = false
            sound:Play()
        end)
    end
end

--// ASSETS & TEMAS
local Assets = {
    Utilities = {
        Settings = "rbxasset://textures/Cursor.png",
        Search = "rbxasset://textures/Cursor.png",
        Download = "rbxasset://textures/Cursor.png",
        Upload = "rbxasset://textures/Cursor.png",
        Copy = "rbxasset://textures/Cursor.png",
        Paste = "rbxasset://textures/Cursor.png",
        Refresh = "rbxasset://textures/Cursor.png",
        Delete = "rbxasset://textures/Cursor.png",
        Edit = "rbxasset://textures/Cursor.png",
        Save = "rbxasset://textures/Cursor.png",
        Export = "rbxasset://textures/Cursor.png",
        Import = "rbxasset://textures/Cursor.png",
        Help = "rbxasset://textures/Cursor.png",
        Info = "rbxasset://textures/Cursor.png",
    },
    Combat = {
        Aimbot = "rbxasset://textures/Cursor.png",
        ESP = "rbxasset://textures/Cursor.png",
        GodMode = "rbxasset://textures/Cursor.png",
        Combat = "rbxasset://textures/Cursor.png",
        Speed = "rbxasset://textures/Cursor.png",
        Flight = "rbxasset://textures/Cursor.png",
        Teleport = "rbxasset://textures/Cursor.png",
        Noclip = "rbxasset://textures/Cursor.png",
        Invisibility = "rbxasset://textures/Cursor.png",
        AutoCollect = "rbxasset://textures/Cursor.png",
        Movement = "rbxasset://textures/Cursor.png",
        Damage = "rbxasset://textures/Cursor.png",
    },
    Interface = {
        Home = "rbxasset://textures/Cursor.png",
        Back = "rbxasset://textures/Cursor.png",
        Forward = "rbxasset://textures/Cursor.png",
        Menu = "rbxasset://textures/Cursor.png",
        Close = "rbxasset://textures/Cursor.png",
        Plus = "rbxasset://textures/Cursor.png",
        Minus = "rbxasset://textures/Cursor.png",
        Folder = "rbxasset://textures/Cursor.png",
        File = "rbxasset://textures/Cursor.png",
        Pin = "rbxasset://textures/Cursor.png",
        Star = "rbxasset://textures/Cursor.png",
    },
}

function Assets:AddCustom(category, name, assetId)
    if not self[category] then
        self[category] = {}
    end
    self[category][name] = assetId
end

local ThemePalettes = {
    --// WHITE V1: Blanco puro, adaptado para fondos blancos claros
    White = {
        Background = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(232, 232, 232),
        AccentOff = Color3.fromRGB(200, 200, 200),
        Text = Color3.fromRGB(0, 0, 0),
        TextDim = Color3.fromRGB(120, 120, 120),
        Stroke = Color3.fromRGB(0, 0, 0),
        Accent = Color3.fromRGB(0, 0, 0),
        ToggleOn = Color3.fromRGB(52, 199, 89),
    },
    Dark = {
        Background = Color3.fromRGB(24, 24, 27),
        Secondary = Color3.fromRGB(40, 40, 45),
        AccentOff = Color3.fromRGB(58, 58, 64),
        Text = Color3.fromRGB(240, 240, 240),
        TextDim = Color3.fromRGB(160, 160, 165),
        Stroke = Color3.fromRGB(90, 90, 96),
        Accent = Color3.fromRGB(255, 255, 255),
        ToggleOn = Color3.fromRGB(52, 199, 89),
    },
    --// DARK V2: Más oscuro y elegante, adaptado para fondos oscuros (105596249630448)
    DarkV2 = {
        Background = Color3.fromRGB(15, 15, 18),
        Secondary = Color3.fromRGB(30, 30, 36),
        AccentOff = Color3.fromRGB(50, 50, 58),
        Text = Color3.fromRGB(245, 245, 248),
        TextDim = Color3.fromRGB(165, 165, 172),
        Stroke = Color3.fromRGB(80, 80, 90),
        Accent = Color3.fromRGB(255, 255, 255),
        ToggleOn = Color3.fromRGB(52, 199, 89),
    },
    Purple = {
        Background = Color3.fromRGB(20, 10, 35),
        Secondary = Color3.fromRGB(40, 20, 60),
        AccentOff = Color3.fromRGB(70, 40, 100),
        Text = Color3.fromRGB(240, 240, 240),
        TextDim = Color3.fromRGB(180, 160, 200),
        Stroke = Color3.fromRGB(120, 80, 180),
        Accent = Color3.fromRGB(180, 100, 255),
        ToggleOn = Color3.fromRGB(180, 100, 255),
    },
    Blue = {
        Background = Color3.fromRGB(10, 20, 40),
        Secondary = Color3.fromRGB(20, 40, 70),
        AccentOff = Color3.fromRGB(40, 70, 120),
        Text = Color3.fromRGB(230, 240, 255),
        TextDim = Color3.fromRGB(150, 180, 220),
        Stroke = Color3.fromRGB(80, 140, 220),
        Accent = Color3.fromRGB(100, 180, 255),
        ToggleOn = Color3.fromRGB(100, 180, 255),
    },
    --// BLUE V2: Más claro y vibrante, adaptado para fondos azules brillantes (107573562621514)
    BlueV2 = {
        Background = Color3.fromRGB(30, 50, 90),
        Secondary = Color3.fromRGB(50, 80, 140),
        AccentOff = Color3.fromRGB(70, 110, 170),
        Text = Color3.fromRGB(240, 245, 255),
        TextDim = Color3.fromRGB(180, 200, 240),
        Stroke = Color3.fromRGB(100, 160, 240),
        Accent = Color3.fromRGB(120, 200, 255),
        ToggleOn = Color3.fromRGB(120, 200, 255),
    },
    Red = {
        Background = Color3.fromRGB(40, 10, 15),
        Secondary = Color3.fromRGB(70, 20, 30),
        AccentOff = Color3.fromRGB(120, 40, 60),
        Text = Color3.fromRGB(255, 230, 230),
        TextDim = Color3.fromRGB(220, 150, 160),
        Stroke = Color3.fromRGB(220, 80, 100),
        Accent = Color3.fromRGB(255, 100, 120),
        ToggleOn = Color3.fromRGB(255, 100, 120),
    },
    --// RED V2: Más oscuro y elegante, adaptado para fondos rojos profundos (118635431058555)
    RedV2 = {
        Background = Color3.fromRGB(50, 12, 20),
        Secondary = Color3.fromRGB(80, 25, 40),
        AccentOff = Color3.fromRGB(120, 45, 70),
        Text = Color3.fromRGB(255, 235, 235),
        TextDim = Color3.fromRGB(225, 160, 170),
        Stroke = Color3.fromRGB(220, 100, 130),
        Accent = Color3.fromRGB(255, 120, 150),
        ToggleOn = Color3.fromRGB(255, 120, 150),
    },
    Orange = {
        Background = Color3.fromRGB(40, 20, 10),
        Secondary = Color3.fromRGB(70, 35, 20),
        AccentOff = Color3.fromRGB(120, 60, 30),
        Text = Color3.fromRGB(255, 240, 230),
        TextDim = Color3.fromRGB(220, 180, 150),
        Stroke = Color3.fromRGB(220, 140, 60),
        Accent = Color3.fromRGB(255, 160, 80),
        ToggleOn = Color3.fromRGB(255, 160, 80),
    },
    Pink = {
        Background = Color3.fromRGB(35, 15, 25),
        Secondary = Color3.fromRGB(60, 25, 45),
        AccentOff = Color3.fromRGB(100, 50, 80),
        Text = Color3.fromRGB(255, 240, 245),
        TextDim = Color3.fromRGB(220, 170, 200),
        Stroke = Color3.fromRGB(230, 150, 200),
        Accent = Color3.fromRGB(255, 170, 220),
        ToggleOn = Color3.fromRGB(255, 170, 220),
    },
    --// PINK V2: Mucho más claro y luminoso, adaptado para fondos rosa brillante (140206818990660)
    PinkV2 = {
        Background = Color3.fromRGB(240, 200, 220),
        Secondary = Color3.fromRGB(255, 215, 235),
        AccentOff = Color3.fromRGB(230, 180, 210),
        Text = Color3.fromRGB(60, 20, 40),
        TextDim = Color3.fromRGB(100, 50, 80),
        Stroke = Color3.fromRGB(220, 150, 190),
        Accent = Color3.fromRGB(255, 100, 170),
        ToggleOn = Color3.fromRGB(255, 100, 170),
    },
    --// PINK V3: Versión intermedia, más adaptable (122685629557229)
    PinkV3 = {
        Background = Color3.fromRGB(200, 140, 180),
        Secondary = Color3.fromRGB(220, 160, 200),
        AccentOff = Color3.fromRGB(180, 120, 160),
        Text = Color3.fromRGB(255, 240, 250),
        TextDim = Color3.fromRGB(220, 180, 210),
        Stroke = Color3.fromRGB(230, 130, 190),
        Accent = Color3.fromRGB(255, 80, 160),
        ToggleOn = Color3.fromRGB(255, 80, 160),
    },
    --// WHITE V2: Blanco puro mejorado con mejor legibilidad (90931437124122)
    WhiteV2 = {
        Background = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(245, 245, 245),
        AccentOff = Color3.fromRGB(220, 220, 220),
        Text = Color3.fromRGB(20, 20, 25),
        TextDim = Color3.fromRGB(100, 100, 110),
        Stroke = Color3.fromRGB(180, 180, 185),
        Accent = Color3.fromRGB(50, 50, 60),
        ToggleOn = Color3.fromRGB(52, 199, 89),
    },
    --// WHITE AND DARK: Tema mitad blanco, mitad oscuro (85320264713056)
    WhiteAndDark = {
        Background = Color3.fromRGB(240, 240, 240),
        Secondary = Color3.fromRGB(200, 200, 200),
        AccentOff = Color3.fromRGB(170, 170, 170),
        Text = Color3.fromRGB(40, 40, 45),
        TextDim = Color3.fromRGB(110, 110, 120),
        Stroke = Color3.fromRGB(100, 100, 110),
        Accent = Color3.fromRGB(0, 0, 0),
        ToggleOn = Color3.fromRGB(52, 199, 89),
    },
    Green = {
        Background = Color3.fromRGB(20, 50, 35),
        Secondary = Color3.fromRGB(35, 80, 55),
        AccentOff = Color3.fromRGB(60, 120, 90),
        Text = Color3.fromRGB(230, 255, 240),
        TextDim = Color3.fromRGB(160, 220, 190),
        Stroke = Color3.fromRGB(100, 200, 140),
        Accent = Color3.fromRGB(120, 220, 160),
        ToggleOn = Color3.fromRGB(100, 220, 140),
    },
    --// WHITE V3: Blanco puro con textos NEON brillantes y vibrantes (88768864762169)
    WhiteV3 = {
        Background = Color3.fromRGB(255, 255, 255),
        Secondary = Color3.fromRGB(248, 248, 248),
        AccentOff = Color3.fromRGB(230, 230, 230),
        Text = Color3.fromRGB(30, 30, 35),  -- Gris oscuro para verse sobre blanco
        TextDim = Color3.fromRGB(100, 100, 110),
        Stroke = Color3.fromRGB(150, 150, 160),
        Accent = Color3.fromRGB(0, 180, 220),
        ToggleOn = Color3.fromRGB(0, 180, 220),
    },
    --// NARANJA V1: Naranja vibrante y cálido, adaptado para fondos naranjas (90056518364273)
    NaranjaV1 = {
        Background = Color3.fromRGB(50, 30, 15),
        Secondary = Color3.fromRGB(80, 45, 25),
        AccentOff = Color3.fromRGB(120, 70, 40),
        Text = Color3.fromRGB(255, 245, 230),
        TextDim = Color3.fromRGB(230, 190, 150),
        Stroke = Color3.fromRGB(230, 160, 80),
        Accent = Color3.fromRGB(255, 180, 80),
        ToggleOn = Color3.fromRGB(255, 180, 80),
    },
    --// VIOLETA V1: Violeta profundo y elegante, adaptado para fondos violetas (112714301994517)
    VioletaV1 = {
        Background = Color3.fromRGB(40, 15, 50),
        Secondary = Color3.fromRGB(70, 30, 90),
        AccentOff = Color3.fromRGB(110, 50, 140),
        Text = Color3.fromRGB(240, 220, 255),
        TextDim = Color3.fromRGB(200, 150, 220),
        Stroke = Color3.fromRGB(180, 120, 200),
        Accent = Color3.fromRGB(200, 100, 255),
        ToggleOn = Color3.fromRGB(200, 100, 255),
    },
    --// CAT V1: Tema del gato en rama - Rosa-Blanco con efecto rainbow rápido (135950962141755)
    CatV1 = {
        Background = Color3.fromRGB(245, 235, 240),      -- Rosa muy claro
        Secondary = Color3.fromRGB(230, 210, 225),       -- Rosa pálido
        AccentOff = Color3.fromRGB(210, 180, 200),       -- Rosa apagado
        Text = Color3.fromRGB(40, 25, 35),               -- Marrón oscuro
        TextDim = Color3.fromRGB(120, 90, 110),          -- Marrón tenue
        Stroke = Color3.fromRGB(180, 140, 160),          -- Rosa medio
        Accent = Color3.fromRGB(0, 0, 0),                -- Negro puro
        ToggleOn = Color3.fromRGB(255, 100, 150),        -- Rosa caliente
    },
    --// LIGHT V1: Tema luminoso y angelical, inspirado en luz blanca pura
    LightV1 = {
        Background = Color3.fromRGB(250, 250, 252),      -- Blanco muy claro con toque azul
        Secondary = Color3.fromRGB(235, 235, 240),       -- Gris muy claro
        AccentOff = Color3.fromRGB(210, 210, 220),       -- Gris suave
        Text = Color3.fromRGB(40, 45, 55),               -- Gris azulado oscuro
        TextDim = Color3.fromRGB(130, 135, 150),         -- Gris azulado medio
        Stroke = Color3.fromRGB(180, 185, 200),          -- Gris azulado claro
        Accent = Color3.fromRGB(200, 210, 230),          -- Azul muy claro
        ToggleOn = Color3.fromRGB(100, 150, 220),        -- Azul celeste
    },
    --// ERIS V1: Tema rojo oscuro con énfasis en rojo-negro, efecto Rainbow automático Rojo→Dark→White
    ErisV1 = {
        Background = Color3.fromRGB(20, 10, 15),         -- Negro profundo con toque rojo
        Secondary = Color3.fromRGB(40, 15, 25),          -- Rojo muy oscuro
        AccentOff = Color3.fromRGB(60, 20, 40),          -- Rojo oscuro
        Text = Color3.fromRGB(255, 200, 200),            -- Rojo claro/Rosa
        TextDim = Color3.fromRGB(180, 120, 130),         -- Rojo medio/oscuro
        Stroke = Color3.fromRGB(200, 80, 100),           -- Rojo vibrante
        Accent = Color3.fromRGB(255, 80, 100),           -- Rojo puro
        ToggleOn = Color3.fromRGB(255, 100, 120),        -- Rojo caliente
    },
    --// SHYLFIE V1: Tema cálido atardecer - Verde oliva, dorado y crema (80301013485061)
    ShylfieV1 = {
        Background = Color3.fromRGB(35, 40, 28),         -- Verde oliva oscuro
        Secondary = Color3.fromRGB(58, 65, 42),          -- Verde oliva medio
        AccentOff = Color3.fromRGB(85, 90, 58),          -- Verde oliva claro
        Text = Color3.fromRGB(250, 245, 230),            -- Crema cálido
        TextDim = Color3.fromRGB(200, 190, 155),         -- Beige tenue
        Stroke = Color3.fromRGB(180, 165, 115),          -- Dorado apagado
        Accent = Color3.fromRGB(230, 195, 130),          -- Dorado atardecer
        ToggleOn = Color3.fromRGB(255, 215, 145),        -- Dorado brillante
    },
    --// SUKUNA V1: Tema nevado en blanco y negro con acentos rojo sangre (85949954769240)
    SukunaV1 = {
        Background = Color3.fromRGB(14, 14, 14),         -- Negro profundo
        Secondary = Color3.fromRGB(28, 28, 30),          -- Gris muy oscuro
        AccentOff = Color3.fromRGB(48, 48, 50),          -- Gris oscuro
        Text = Color3.fromRGB(235, 235, 235),            -- Blanco casi puro
        TextDim = Color3.fromRGB(160, 160, 160),         -- Gris medio
        Stroke = Color3.fromRGB(180, 25, 30),            -- Rojo sangre
        Accent = Color3.fromRGB(200, 20, 25),            -- Rojo intenso
        ToggleOn = Color3.fromRGB(220, 45, 50),          -- Rojo vibrante
    },
    --// V1: Rostro difuminado en mármol blanco y negro (85300188078480)
    V1 = {
        Background = Color3.fromRGB(232, 232, 232),
        Secondary = Color3.fromRGB(208, 208, 208),
        AccentOff = Color3.fromRGB(180, 180, 180),
        Text = Color3.fromRGB(20, 20, 20),
        TextDim = Color3.fromRGB(95, 95, 95),
        Stroke = Color3.fromRGB(140, 140, 140),
        Accent = Color3.fromRGB(35, 35, 35),
        ToggleOn = Color3.fromRGB(60, 60, 60),
    },
    --// V2: Rostro oscuro entre kanjis, negro con destellos rojos (73784070707058)
    V2 = {
        Background = Color3.fromRGB(10, 10, 14),
        Secondary = Color3.fromRGB(22, 22, 28),
        AccentOff = Color3.fromRGB(42, 42, 50),
        Text = Color3.fromRGB(235, 235, 240),
        TextDim = Color3.fromRGB(150, 150, 160),
        Stroke = Color3.fromRGB(180, 40, 50),
        Accent = Color3.fromRGB(200, 50, 60),
        ToggleOn = Color3.fromRGB(220, 70, 80),
    },
    --// V3: Chica con adorno floral explosivo, alto contraste B/N (75154906255157)
    V3 = {
        Background = Color3.fromRGB(8, 8, 8),
        Secondary = Color3.fromRGB(24, 24, 24),
        AccentOff = Color3.fromRGB(48, 48, 48),
        Text = Color3.fromRGB(245, 245, 245),
        TextDim = Color3.fromRGB(170, 170, 170),
        Stroke = Color3.fromRGB(205, 205, 205),
        Accent = Color3.fromRGB(255, 255, 255),
        ToggleOn = Color3.fromRGB(230, 230, 230),
    },
    --// V4: Silueta casi negra con headband, minimalista oscuro (135645850605905)
    V4 = {
        Background = Color3.fromRGB(5, 5, 5),
        Secondary = Color3.fromRGB(16, 16, 16),
        AccentOff = Color3.fromRGB(30, 30, 30),
        Text = Color3.fromRGB(210, 210, 210),
        TextDim = Color3.fromRGB(110, 110, 110),
        Stroke = Color3.fromRGB(65, 65, 65),
        Accent = Color3.fromRGB(95, 95, 95),
        ToggleOn = Color3.fromRGB(150, 150, 150),
    },
    --// V5: Velo de encaje sobre el rostro, B/N suave (132161944582308)
    V5 = {
        Background = Color3.fromRGB(18, 18, 18),
        Secondary = Color3.fromRGB(36, 36, 36),
        AccentOff = Color3.fromRGB(56, 56, 56),
        Text = Color3.fromRGB(240, 240, 240),
        TextDim = Color3.fromRGB(160, 160, 160),
        Stroke = Color3.fromRGB(200, 200, 200),
        Accent = Color3.fromRGB(220, 220, 220),
        ToggleOn = Color3.fromRGB(235, 235, 235),
    },
    --// V6: Ángel con laúd, tono sepia clásico (99625131409582)
    V6 = {
        Background = Color3.fromRGB(28, 25, 20),
        Secondary = Color3.fromRGB(50, 45, 38),
        AccentOff = Color3.fromRGB(75, 68, 55),
        Text = Color3.fromRGB(240, 235, 220),
        TextDim = Color3.fromRGB(190, 180, 160),
        Stroke = Color3.fromRGB(160, 150, 130),
        Accent = Color3.fromRGB(210, 195, 160),
        ToggleOn = Color3.fromRGB(225, 205, 160),
    },
    --// V9: Ojos grandes en close-up, manga en gris (99554561815921)
    V9 = {
        Background = Color3.fromRGB(30, 30, 30),
        Secondary = Color3.fromRGB(50, 50, 50),
        AccentOff = Color3.fromRGB(75, 75, 75),
        Text = Color3.fromRGB(245, 245, 245),
        TextDim = Color3.fromRGB(175, 175, 175),
        Stroke = Color3.fromRGB(150, 150, 150),
        Accent = Color3.fromRGB(230, 230, 230),
        ToggleOn = Color3.fromRGB(255, 255, 255),
    },
    --// V10: Energía morada con rayos y detalles rojos (122520620665113)
    V10 = {
        Background = Color3.fromRGB(18, 10, 25),
        Secondary = Color3.fromRGB(35, 18, 50),
        AccentOff = Color3.fromRGB(60, 30, 85),
        Text = Color3.fromRGB(240, 225, 255),
        TextDim = Color3.fromRGB(190, 160, 220),
        Stroke = Color3.fromRGB(170, 90, 220),
        Accent = Color3.fromRGB(190, 100, 255),
        ToggleOn = Color3.fromRGB(210, 130, 255),
    },
    --// V11: Rostro con marco ornamentado rojizo (93259710745008)
    V11 = {
        Background = Color3.fromRGB(20, 10, 12),
        Secondary = Color3.fromRGB(38, 20, 24),
        AccentOff = Color3.fromRGB(62, 36, 40),
        Text = Color3.fromRGB(245, 225, 225),
        TextDim = Color3.fromRGB(200, 160, 165),
        Stroke = Color3.fromRGB(210, 160, 170),
        Accent = Color3.fromRGB(220, 150, 160),
        ToggleOn = Color3.fromRGB(230, 170, 180),
    },
    --// PIBBLE V1: Cachorro blanco sobre manta gris, tonos suaves (108798897997443)
    PibbleV1 = {
        Background = Color3.fromRGB(58, 63, 70),
        Secondary = Color3.fromRGB(88, 93, 100),
        AccentOff = Color3.fromRGB(118, 123, 128),
        Text = Color3.fromRGB(250, 248, 245),
        TextDim = Color3.fromRGB(200, 195, 190),
        Stroke = Color3.fromRGB(228, 180, 190),
        Accent = Color3.fromRGB(240, 200, 210),
        ToggleOn = Color3.fromRGB(255, 210, 220),
    },
}

--// IMÁGENES DE FONDO POR TEMA (decorativas, se muestran detrás del contenido)
local ThemeBackgroundImages = {
    Dark = "rbxassetid://138004303203419",
    DarkV2 = "rbxassetid://105596249630448",
    Pink = "rbxassetid://129299161197887",
    PinkV2 = "rbxassetid://140206818990660",
    PinkV3 = "rbxassetid://122685629557229",
    Blue = "rbxassetid://136072951221172",
    BlueV2 = "rbxassetid://107573562621514",
    Red = "rbxassetid://88289923848664",
    RedV2 = "rbxassetid://118635431058555",
    White = "rbxassetid://129555461947864",
    WhiteV2 = "rbxassetid://90931437124122",
    WhiteV3 = "rbxassetid://88768864762169",
    WhiteAndDark = "rbxassetid://85320264713056",
    Green = "rbxassetid://86357167554483",
    NaranjaV1 = "rbxassetid://90056518364273",
    VioletaV1 = "rbxassetid://112714301994517",
    CatV1 = "rbxassetid://135950962141755",  --  Gato en rama
    LightV1 = "rbxassetid://85339946380507",  --  Angel luminoso blanco
    ErisV1 = "rbxassetid://134043807878571",  -- 🔴 Personaje rojo-oscuro
    ShylfieV1 = "rbxassetid://80301013485061",  -- Chica orejas élficas atardecer (actualizado)
    SukunaV1 = "rbxassetid://85949954769240",  -- Personaje nevado B/N
    V1 = "rbxassetid://85300188078480",
    V2 = "rbxassetid://73784070707058",
    V3 = "rbxassetid://75154906255157",
    V4 = "rbxassetid://135645850605905",
    V5 = "rbxassetid://132161944582308",
    V6 = "rbxassetid://99625131409582",
    V9 = "rbxassetid://99554561815921",
    V10 = "rbxassetid://122520620665113",
    V11 = "rbxassetid://93259710745008",
    PibbleV1 = "rbxassetid://108798897997443",
}

--// Imágenes decorativas para el TopBar (barra de título) — soporte para temas futuros
local ThemeTitleBarImages = {}

--// Imágenes decorativas para el TabList (barra de pestañas) — soporte para temas futuros
local ThemeTabListImages = {}

--// Efectos automáticos por tema (se llena desde el repo externo)
local ThemeAutoEffects = {
    CatV1     = "CatRainbow",
    ErisV1    = "ErisRainbow",
    ShylfieV1 = "ShylfieRainbow",
    SukunaV1  = "SukunaRainbow",
}

--// Orden de temas (se reemplaza con el del repo externo si descarga ok)
local ThemeOrder = nil

--// ════════════════════════════════════════════════════════════════
--// SISTEMA DE TEMAS EXTERNOS (LoadThemes)
--// Siempre intenta descargar primero.
--// Solo usa caché si falla internet.
--// Solo usa embebido si no hay caché.
--// ════════════════════════════════════════════════════════════════
local THEMES_URL        = "https://raw.githubusercontent.com/Yinyangzx/Temas/refs/heads/main/YinYang_Themes.lua"
local THEMES_CACHE_FILE = "yin_yang_themes_cache.lua"

local function LoadThemes()
    local rawData = nil

    --// PASO 1: Intentar descargar siempre primero
    --// Usamos game:HttpGet() — funciona en Delta y la mayoría de executors
    --// HttpService:GetAsync() da "blocked" en executors móviles como Delta
    local dlOk, dlResult = pcall(function()
        return game:HttpGet(THEMES_URL, true)
    end)

    if dlOk and type(dlResult) == "string" and #dlResult > 20 then
        rawData = dlResult
        print("[YinYang Themes] ✅ Temas descargados desde repo")
        --// Actualizar caché con lo descargado
        pcall(function()
            if writefile then
                writefile(THEMES_CACHE_FILE, rawData)
                print("[YinYang Themes] 💾 Caché actualizada")
            end
        end)
    else
        --// PASO 2: Descarga falló → intentar caché local
        print("[YinYang Themes] ⚠️ Descarga falló, intentando caché...")
        pcall(function()
            if readfile and isfile and isfile(THEMES_CACHE_FILE) then
                rawData = readfile(THEMES_CACHE_FILE)
                print("[YinYang Themes] 📁 Usando caché local")
            end
        end)
    end

    --// PASO 3: Si tenemos datos (de descarga o caché), procesarlos
    if rawData then
        local parseOk, data = pcall(function()
            return loadstring(rawData)()
        end)

        if parseOk and type(data) == "table" and data.Themes then
            local count = 0
            --// Mergear temas externos en las tablas existentes
            for name, theme in pairs(data.Themes) do
                if theme.Palette then
                    ThemePalettes[name] = theme.Palette
                end
                if theme.Sound then
                    ThemeClickSounds[name] = theme.Sound
                end
                if theme.Background then
                    ThemeBackgroundImages[name] = theme.Background
                end
                if theme.Effect and theme.Effect ~= "Off" then
                    ThemeAutoEffects[name] = theme.Effect
                end
                if theme.TitleBarImage and theme.TitleBarImage ~= "" then
                    ThemeTitleBarImages[name] = theme.TitleBarImage
                end
                if theme.TabListImage and theme.TabListImage ~= "" then
                    ThemeTabListImages[name] = theme.TabListImage
                end
                count = count + 1
            end

            --// Guardar orden del repo
            if data.Order then
                ThemeOrder = data.Order
            end

            print("[YinYang Themes] ✅ " .. count .. " temas cargados (v" .. tostring(data.Version or "?") .. ")")
            return true
        else
            print("[YinYang Themes] ❌ Error al parsear datos de temas")
        end
    else
        print("[YinYang Themes] ❌ Sin datos disponibles, usando temas embebidos")
    end

    --// PASO 4: Todo falló → las tablas embebidas quedan intactas como fallback
    return false
end

LoadThemes()

--// ════════════════════════════════════════════════════════════════
--// TEMAS PERSONALIZADOS DEL USUARIO (persistencia local)
--// ════════════════════════════════════════════════════════════════
local CUSTOM_THEMES_FILE = "yin_yang_custom_themes.json"
local CustomThemes = {}
local CustomThemeOrder = {}
local OfficialThemeNames = {}

for themeName in pairs(ThemePalettes) do
    OfficialThemeNames[themeName] = true
end

local function colorToArray(color)
    return {
        math.floor(color.R * 255 + 0.5),
        math.floor(color.G * 255 + 0.5),
        math.floor(color.B * 255 + 0.5),
    }
end

local function arrayToColor(value, fallback)
    if type(value) == "table" then
        local r = tonumber(value[1] or value.R)
        local g = tonumber(value[2] or value.G)
        local b = tonumber(value[3] or value.B)
        if r and g and b then
            return Color3.fromRGB(
                math.clamp(math.floor(r + 0.5), 0, 255),
                math.clamp(math.floor(g + 0.5), 0, 255),
                math.clamp(math.floor(b + 0.5), 0, 255)
            )
        end
    end
    return fallback
end

local function normalizeAssetId(value)
    value = tostring(value or ""):match("^%s*(.-)%s*$")
    if value == "" then return "" end
    local numericId = value:match("(%d+)")
    if not numericId then return nil end
    return "rbxassetid://" .. numericId
end

local function applyCustomThemeToRuntime(name, data)
    if type(data) ~= "table" or type(data.Palette) ~= "table" then return false end

    local fallback = ThemePalettes.Dark
    local palette = {
        Background = arrayToColor(data.Palette.Background, fallback.Background),
        Secondary = arrayToColor(data.Palette.Secondary, fallback.Secondary),
        AccentOff = arrayToColor(data.Palette.AccentOff, fallback.AccentOff),
        Text = arrayToColor(data.Palette.Text, fallback.Text),
        TextDim = arrayToColor(data.Palette.TextDim, fallback.TextDim),
        Stroke = arrayToColor(data.Palette.Stroke, fallback.Stroke),
        Accent = arrayToColor(data.Palette.Accent, fallback.Accent),
        ToggleOn = arrayToColor(data.Palette.ToggleOn, fallback.ToggleOn),
    }

    ThemePalettes[name] = palette

    if data.Background and data.Background ~= "" then
        ThemeBackgroundImages[name] = data.Background
    else
        ThemeBackgroundImages[name] = nil
    end

    if data.Sound and data.Sound ~= "" then
        ThemeClickSounds[name] = data.Sound
    else
        ThemeClickSounds[name] = nil
    end

    return true
end

local function SaveCustomThemes()
    pcall(function()
        if writefile then
            writefile(CUSTOM_THEMES_FILE, HttpService:JSONEncode({
                Themes = CustomThemes,
                Order = CustomThemeOrder,
            }))
        end
    end)
end

local function LoadCustomThemes()
    if not (readfile and isfile and isfile(CUSTOM_THEMES_FILE)) then return end

    pcall(function()
        local decoded = HttpService:JSONDecode(readfile(CUSTOM_THEMES_FILE))
        if type(decoded) ~= "table" or type(decoded.Themes) ~= "table" then return end

        CustomThemes = decoded.Themes
        CustomThemeOrder = type(decoded.Order) == "table" and decoded.Order or {}

        local seen = {}
        local cleanOrder = {}
        for _, name in ipairs(CustomThemeOrder) do
            if type(name) == "string" and CustomThemes[name] and not OfficialThemeNames[name] and not seen[name] then
                seen[name] = true
                table.insert(cleanOrder, name)
            end
        end
        for name, data in pairs(CustomThemes) do
            if type(name) == "string" and not OfficialThemeNames[name] then
                if not seen[name] then
                    seen[name] = true
                    table.insert(cleanOrder, name)
                end
                applyCustomThemeToRuntime(name, data)
            end
        end
        CustomThemeOrder = cleanOrder
    end)
end

LoadCustomThemes()

--// ════════════════════════════════════════════════════════════════
--// TABLAS DE STICKERS (se rellenan con LoadStickers)
--// ⚠️ NO ELIMINAR — fallback embebido si el repo no está disponible
--// ════════════════════════════════════════════════════════════════
local StickerPalettes = {
    Sonrisa  = { Image = "rbxassetid://135857695171095", LabelES = "Sonrisa",  LabelEN = "Smile"     },
    Llorar   = { Image = "rbxassetid://138363247925206", LabelES = "Llorar",   LabelEN = "Crying"    },
    Amor     = { Image = "rbxassetid://76164124882568",  LabelES = "Amor",     LabelEN = "Love"      },
    Corazon  = { Image = "rbxassetid://76164124882568",  LabelES = "Corazón",  LabelEN = "Heart"     },
    Emoji    = { Image = "rbxassetid://133861773375312", LabelES = "Emoji",    LabelEN = "Emoji"     },
    Risa     = { Image = "rbxassetid://109165098870367", LabelES = "Risa",     LabelEN = "Laugh"     },
    Sorpresa = { Image = "rbxassetid://89213081637073",  LabelES = "Sorpresa", LabelEN = "Surprised" },
    Triste   = { Image = "rbxassetid://80817302481160",  LabelES = "Triste",   LabelEN = "Sad"       },
    Enojado  = { Image = "rbxassetid://72815688632249",  LabelES = "Enojado",  LabelEN = "Angry"     },
    Wink     = { Image = "rbxassetid://72602706593283",  LabelES = "Guiño",    LabelEN = "Wink"      },
    Cool     = { Image = "rbxassetid://129224642026377", LabelES = "Cool",     LabelEN = "Cool"      },
}

-- nil hasta que LoadStickers() corra exitosamente
local StickerOrder = nil

--// ════════════════════════════════════════════════════════════════
--// SISTEMA DE STICKERS EXTERNOS (LoadStickers)
--// Siempre intenta descargar primero.
--// Solo usa caché si falla internet.
--// Solo usa embebido si no hay caché.
--// ⚠️ NO ELIMINAR
--// ════════════════════════════════════════════════════════════════
local STICKERS_URL        = "https://raw.githubusercontent.com/Sephtis32/Yin-stickers/refs/heads/main/YinYang_Stickers.lua"
local STICKERS_CACHE_FILE = "yin_yang_stickers_cache.lua"

local function LoadStickers()
    local rawData = nil

    --// PASO 1: Intentar descargar siempre primero
    --// Usamos game:HttpGet() — funciona en Delta y la mayoría de executors
    --// HttpService:GetAsync() da "blocked" en executors móviles como Delta
    local dlOk, dlResult = pcall(function()
        return game:HttpGet(STICKERS_URL, true)
    end)

    if dlOk and type(dlResult) == "string" and #dlResult > 20 then
        rawData = dlResult
        print("[YinYang Stickers] ✅ Stickers descargados desde repo")
        --// Actualizar caché con lo descargado
        pcall(function()
            if writefile then
                writefile(STICKERS_CACHE_FILE, rawData)
                print("[YinYang Stickers] 💾 Caché actualizada")
            end
        end)
    else
        --// PASO 2: Descarga falló → intentar caché local
        print("[YinYang Stickers] ⚠️ Descarga falló, intentando caché...")
        pcall(function()
            if readfile and isfile and isfile(STICKERS_CACHE_FILE) then
                rawData = readfile(STICKERS_CACHE_FILE)
                print("[YinYang Stickers] 📁 Usando caché local")
            end
        end)
    end

    --// PASO 3: Si tenemos datos (de descarga o caché), procesarlos
    if rawData then
        local parseOk, data = pcall(function()
            return loadstring(rawData)()
        end)

        if parseOk and type(data) == "table" and data.Stickers then
            local count = 0
            --// Mergear stickers externos en la tabla embebida
            for name, sticker in pairs(data.Stickers) do
                if sticker.Image then
                    StickerPalettes[name] = {
                        Image   = sticker.Image,
                        LabelES = sticker.LabelES or name,
                        LabelEN = sticker.LabelEN or name,
                    }
                    count = count + 1
                end
            end

            --// Guardar orden del repo
            if data.Order then
                StickerOrder = data.Order
            end

            print("[YinYang Stickers] ✅ " .. count .. " stickers cargados (v" .. tostring(data.Version or "?") .. ")")
            return true
        else
            print("[YinYang Stickers] ❌ Error al parsear datos de stickers")
        end
    else
        print("[YinYang Stickers] ❌ Sin datos disponibles, usando stickers embebidos")
    end

    --// PASO 4: Todo falló → StickerPalettes embebida queda intacta como fallback
    return false
end

LoadStickers()

--// ════════════════════════════════════════════════════════════════
--// AUDIO STICKER PREMIUM
--// Descarga el audio una sola vez y lo deja listo para reproducir.
--// Se activa cada vez que el usuario entra a la pestaña de Chat
--// SOLO si el sticker premium está dentro de los últimos 5 mensajes.
--// ⚠️ NO ELIMINAR
--// ════════════════════════════════════════════════════════════════
local PREMIUM_STICKER_ASSET      = "rbxassetid://94876918093684"
local PREMIUM_STICKER_AUDIO_URL  = "https://raw.githubusercontent.com/nbritez6729-blip/A/refs/heads/main/AudioCutter_PORQUE%20TE%20MIENTES%20(SLOWED)%20%20BAKI%20MEME.mp3"
local PREMIUM_STICKER_AUDIO_FILE = "yin_yang_premium_sticker.mp3"
local PREMIUM_STICKER_DEPTH      = 5   -- últimos N mensajes que cuentan
local PremiumStickerSound        = nil -- se llena cuando la descarga termina

task.spawn(function()
    local ok, data = pcall(function()
        return game:HttpGet(PREMIUM_STICKER_AUDIO_URL, true)
    end)
    if not ok or not data or #data < 100 then
        warn("[YinYang Premium] ❌ No se pudo descargar el audio del sticker premium")
        return
    end
    pcall(function() writefile(PREMIUM_STICKER_AUDIO_FILE, data) end)
    local assetId
    pcall(function() assetId = getcustomasset(PREMIUM_STICKER_AUDIO_FILE) end)
    if not assetId then
        warn("[YinYang Premium] ❌ getcustomasset() falló")
        return
    end
    local snd = Instance.new("Sound")
    snd.SoundId  = assetId
    snd.Volume   = 0.5
    snd.Looped   = false
    snd.Parent   = game:GetService("Workspace")
    PremiumStickerSound = snd
    print("[YinYang Premium] ✅ Audio del sticker premium listo")
end)

local Theme

--// UTILIDADES
local function mk(cls, props, parent)
    local o = Instance.new(cls)
    pcall(function() o.Selectable = false end)
    if o:IsA("TextLabel") or o:IsA("TextButton") or o:IsA("TextBox") then
        pcall(function() o.AutoLocalize = false end)
    end
    if o:IsA("TextButton") or o:IsA("ImageButton") then
        pcall(function() o.AutoButtonColor = false end)
    end
    for k, v in pairs(props) do o[k] = v end
    if parent then o.Parent = parent end
    return o
end

local function corner(p, r)
    mk("UICorner", {CornerRadius = UDim.new(0, r or 8)}, p)
end

local function stroke(p, col, th, trans)
    local s = mk("UIStroke", {Color = col, Thickness = th or 1.5, Transparency = trans or 0}, p)
    s:SetAttribute("ThemeRole", "Stroke")
    return s
end

--// ════════════════════════════════════════════════════════════════
--// EFECTO DE BRILLO ANIMADO EN BORDES (v28 PRO)
--// Inner Glow + Outer Glow + Stroke Gradiente + Light Sweep
--// Basado en: UIStroke + UIGradient + TweenService
--// ════════════════════════════════════════════════════════════════

local ActiveGlowTweens = {}

local function stopGlowTweens(key)
    if ActiveGlowTweens[key] then
        for _, tw in ipairs(ActiveGlowTweens[key]) do
            pcall(function() tw:Cancel() end)
        end
        ActiveGlowTweens[key] = nil
    end
end

--// Limpia GlowLayers que pertenecen a un frame específico (por tag único)
local function cleanGlowLayers(frame)
    local tag = "GLOW_" .. tostring(frame)
    if frame.Parent then
        for _, child in ipairs(frame.Parent:GetChildren()) do
            if child:GetAttribute("GlowOwner") == tag then
                child:Destroy()
            end
        end
    end
end

--// GLOW PARA VENTANA PRINCIPAL: sibling en el mismo contenedor (NO en ScreenGui)
--// Solo se usa cuando el parent NO es ScreenGui
local function addGlowSibling(frame, thickness, transparency, color, cornerRadius)
    local container = frame.Parent
    -- NUNCA crear sibling si el parent es ScreenGui o PlayerGui
    if not container or container:IsA("ScreenGui") or container:IsA("PlayerGui") then
        return nil, nil
    end

    local tag = "GLOW_" .. tostring(frame)
    local layer = Instance.new("Frame")
    layer.Name = "GlowLayer"
    layer:SetAttribute("GlowOwner", tag)
    layer.BackgroundTransparency = 1
    layer.Size = frame.Size
    layer.Position = frame.Position
    layer.AnchorPoint = frame.AnchorPoint
    layer.ZIndex = math.max(1, frame.ZIndex - 1)
    layer.Parent = container

    local c = Instance.new("UICorner")
    c.CornerRadius = cornerRadius or UDim.new(0, 10)
    c.Parent = layer

    local s = Instance.new("UIStroke")
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Thickness = thickness
    s.Transparency = transparency
    s.Color = color
    s.LineJoinMode = Enum.LineJoinMode.Round
    s.Parent = layer

    return layer, s
end

--// GLOW DIRECTO: anima el UIStroke existente del frame (para FloatingToggle y casos en ScreenGui)
local function buildGlowOnStroke(frame, accentColor, cornerRadius)
    local key = tostring(frame)
    stopGlowTweens(key)

    local existingStroke = frame:FindFirstChildOfClass("UIStroke")
    if not existingStroke then return end

    -- Mantener el borde visible y coherente con el acento actual del tema.
    -- Al cambiar de tema, swapThemeColor puede recolorear el stroke con el rol "Stroke";
    -- aquí lo forzamos otra vez al color de acento para que el glow no se "pierda".
    existingStroke.Color = accentColor

    -- Limpiar gradient anterior si existe
    local oldGrad = existingStroke:FindFirstChildOfClass("UIGradient")
    if oldGrad then oldGrad:Destroy() end

    local h, s, v = Color3.toHSV(accentColor)
    local accentLight = Color3.fromHSV(h, math.max(0, s - 0.3), math.min(1, v + 0.25))
    local accentDark  = Color3.fromHSV(h, math.min(1, s + 0.1), math.max(0, v - 0.25))

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, accentDark),
        ColorSequenceKeypoint.new(0.5, accentLight),
        ColorSequenceKeypoint.new(1, accentDark),
    })
    grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.4),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 0.4),
    })
    grad.Offset = Vector2.new(-1.5, 0)
    grad.Parent = existingStroke

    local sweepTween = TweenService:Create(
        grad,
        TweenInfo.new(1.4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false),
        { Offset = Vector2.new(1.5, 0) }
    )
    sweepTween:Play()

    local pulseTween = TweenService:Create(
        existingStroke,
        TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        { Transparency = 0.0 }
    )
    pulseTween:Play()

    ActiveGlowTweens[key] = { sweepTween, pulseTween }
end

local function buildAnimatedBorder(frame, accentColor, cornerRadius, forceStrokeOnly)
    local key = tostring(frame)
    stopGlowTweens(key)
    cleanGlowLayers(frame)

    local cr = cornerRadius or UDim.new(0, 10)
    local h, s, v = Color3.toHSV(accentColor)
    local accentLight = Color3.fromHSV(h, math.max(0, s - 0.3), math.min(1, v + 0.25))
    local accentDark  = Color3.fromHSV(h, math.min(1, s + 0.1), math.max(0, v - 0.25))

    -- Si forceStrokeOnly=true, o el parent es ScreenGui: solo animar stroke existente
    local parentIsScreenGui = frame.Parent and (frame.Parent:IsA("ScreenGui") or frame.Parent:IsA("PlayerGui"))
    
    if forceStrokeOnly or parentIsScreenGui then
        buildGlowOnStroke(frame, accentColor, cr)
        return
    end

    -- Para Main window (parent es un Frame normal): sibling con glow fino
    local _, outerStroke = addGlowSibling(frame, 16, 0.45, accentColor, cr)
    local _, innerStroke = addGlowSibling(frame, 5, 0.10, accentLight, cr)

    if not outerStroke or not innerStroke then
        -- Fallback: solo stroke
        buildGlowOnStroke(frame, accentColor, cr)
        return
    end

    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, accentDark),
        ColorSequenceKeypoint.new(0.5, accentLight),
        ColorSequenceKeypoint.new(1, accentDark),
    })
    grad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 0.2),
    })
    grad.Offset = Vector2.new(-1.5, 0)
    grad.Parent = innerStroke

    local sweepTween = TweenService:Create(
        grad,
        TweenInfo.new(1.4, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false),
        { Offset = Vector2.new(1.5, 0) }
    )
    sweepTween:Play()

    local pulseTween = TweenService:Create(
        outerStroke,
        TweenInfo.new(1.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        { Transparency = 0.20, Thickness = 22 }
    )
    pulseTween:Play()

    ActiveGlowTweens[key] = { sweepTween, pulseTween }
end

local function resetScrollTop(scrollingFrame)
    task.defer(function()
        if scrollingFrame and scrollingFrame.Parent then
            scrollingFrame.CanvasPosition = Vector2.new(0, 0)
        end
    end)
end

local function formatDuration(totalSeconds)
    totalSeconds = math.floor(totalSeconds)
    local h = math.floor(totalSeconds / 3600)
    local m = math.floor((totalSeconds % 3600) / 60)
    local s = totalSeconds % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

local function createStatGrid(parent)
    local Grid = mk("Frame", {
        Parent = parent,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.None,
        BackgroundTransparency = 1,
        ZIndex = 9
    })
    mk("UIGridLayout", {
        CellPadding = UDim2.new(0, 8, 0, 8),
        CellSize = UDim2.new(0.5, -4, 0, 54),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, Grid)
    return Grid
end

local function createStatTile(grid, labelSpanish, labelEnglish)
    labelEnglish = labelEnglish or labelSpanish
    local Tile = mk("Frame", {
        Parent = grid,
        BackgroundColor3 = Theme.Secondary,
        ZIndex = 9
    })
    Tile:SetAttribute("ThemeRole", "Secondary")
    corner(Tile, 6)
    stroke(Tile, Color3.fromRGB(0, 0, 0), 1, 0.6)

    local TileLabel = mk("TextLabel", {
        Parent = Tile,
        Size = UDim2.new(1, -16, 0, 16),
        Position = UDim2.new(0, 8, 0, 6),
        BackgroundTransparency = 1,
        Text = GetText(labelSpanish, labelEnglish),
        TextColor3 = Theme.TextDim,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 10
    })
    TileLabel:SetAttribute("ThemeRole", "TextDim")
    TileLabel:SetAttribute("TextSpanish", labelSpanish)
    TileLabel:SetAttribute("TextEnglish", labelEnglish)

    local ValueText = mk("TextLabel", {
        Parent = Tile,
        Size = UDim2.new(1, -16, 0, 22),
        Position = UDim2.new(0, 8, 0, 24),
        BackgroundTransparency = 1,
        Text = "...",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 10
    })
    ValueText:SetAttribute("ThemeRole", "Text")

    return Tile, ValueText
end

--// Calcula si un texto/símbolo debe ser blanco o negro según el brillo del fondo
-- Así garantizamos contraste SIN cambiar el color de acento de ningún tema (ej: el blanco de Dark)
local function getContrastColor(bgColor)
    local luminance = 0.299 * bgColor.R + 0.587 * bgColor.G + 0.114 * bgColor.B
    if luminance > 0.6 then
        return Color3.fromRGB(25, 25, 25)
    end
    return Color3.fromRGB(255, 255, 255)
end

-- ThemeRole -> controla BackgroundColor3 (o Color en UIStroke)
-- ThemeTextRole -> controla TextColor3, independiente del rol de fondo
local function swapThemeColor(obj, palette)
    local bgRole = obj:GetAttribute("ThemeRole")
    if bgRole and palette[bgRole] then
        if obj:IsA("UIStroke") then
            obj.Color = palette[bgRole]
        elseif obj:IsA("GuiObject") then
            pcall(function() obj.BackgroundColor3 = palette[bgRole] end)
        end
    end

    local textRole = obj:GetAttribute("ThemeTextRole")
    if textRole and palette[textRole] then
        if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
            obj.TextColor3 = palette[textRole]
        end
    end

    -- ThemeImageRole -> recolorea iconos transparentes según el tema activo.
    local imageRole = obj:GetAttribute("ThemeImageRole")
    if imageRole and palette[imageRole] then
        if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
            obj.ImageColor3 = palette[imageRole]
        end
    end
end

--// Centraliza el cambio de tema: clona la paleta y calcula el color de contraste (AccentText)
-- para que cualquier texto/símbolo sobre un fondo Accent (ej: blanco en Dark) siga siendo legible
-- sin tener que tocar el color de acento del tema.
local function setActiveTheme(name)
    local palette = ThemePalettes[name]
    if not palette then return false end
    Theme = table.clone(palette)
    Theme.AccentText = getContrastColor(Theme.Accent)
    return true
end

setActiveTheme("Dark")

--// MAIN OBJECT - Global para que otros scripts puedan usarlo
_G.YinYang = {}
local YinYang = _G.YinYang
YinYang.__index = YinYang

function YinYang:CreateWindow(title_text, startTheme)
    startTheme = startTheme or "Dark"

    local ConfigCargada = LoadConfig()
    if ConfigCargada then
        if ConfigCargada.libMode then
            SavedConfig.LibrarySizeMode = ConfigCargada.libMode
        end
        if ConfigCargada.libHeight then
            SavedConfig.LibraryHeight = ConfigCargada.libHeight
        end
        if ConfigCargada.effect then
            SavedConfig.CurrentEffect = ConfigCargada.effect
        end
        if ConfigCargada.volume then
            SavedConfig.Volume = ConfigCargada.volume
        end
        if ConfigCargada.hideSliders ~= nil then
            SavedConfig.HideSliders = ConfigCargada.hideSliders
        end
        if ConfigCargada.favorites then
            SavedConfig.Favorites = ConfigCargada.favorites
        end
    end

    local SlidersHidden = SavedConfig.HideSliders or false

    --// FAVORITOS: set de ids "NombrePestaña::TextoToggle" cargados del config
    local SavedFavoriteIds = {}
    for id in (SavedConfig.Favorites or ""):gmatch("([^,]+)") do
        SavedFavoriteIds[id] = true
    end
    local AutoTabFavoritosRef = nil  -- se asigna cuando se crea la pestaña Favoritos más abajo

    local function SyncFavoritesToConfig()
        local ids = {}
        for id, isFav in pairs(SavedFavoriteIds) do
            if isFav then table.insert(ids, id) end
        end
        SavedConfig.Favorites = table.concat(ids, ",")
        SaveConfig()
    end

    setActiveTheme(startTheme)

    local globalConnections = {}
    local function track(conn)
        table.insert(globalConnections, conn)
        return conn
    end

    -- Intenta colocar la interfaz en la capa más alta disponible. En ejecutores que
    -- exponen gethui(), esto permite que la UI quede por encima de la interfaz nativa.
    local guiParent = LocalPlayer:WaitForChild("PlayerGui")
    pcall(function()
        if typeof(gethui) == "function" then
            local hiddenUi = gethui()
            if hiddenUi then guiParent = hiddenUi end
        end
    end)

    pcall(function()
        local previous = guiParent:FindFirstChild("ZeroMobile")
        if previous then previous:Destroy() end
    end)

    local ScreenGui = mk("ScreenGui", {
        Name = "ZeroMobile",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 2147483647,
        ZIndexBehavior = Enum.ZIndexBehavior.Global,
    }, guiParent)

    pcall(function() ScreenGui.AutoLocalize = false end)
    pcall(function() ScreenGui.ScreenInsets = Enum.ScreenInsets.None end)
    pcall(function() ScreenGui.ClipToDeviceSafeArea = false end)
    pcall(function() ScreenGui.SafeAreaCompatibility = Enum.SafeAreaCompatibility.FullscreenExtension end)
    pcall(function()
        if typeof(protect_gui) == "function" then protect_gui(ScreenGui) end
    end)

    --// BOTÓN TOGGLE CON LOGO YIN-YANG
    local ToggleButton = mk("TextButton", {
        Name = "ToggleButton",
        Size = UDim2.new(0, 42, 0, 42),
        Position = UDim2.new(0, 24, 0, 70),
        BackgroundColor3 = Theme.Accent,
        Text = "",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        Font = Enum.Font.GothamBold,
        TextSize = 17,
        ZIndex = 30,
    }, ScreenGui)
    ToggleButton:SetAttribute("ThemeRole", "Accent")
    corner(ToggleButton, 999)
    stroke(ToggleButton, Theme.Accent, 1.5)

    --// LOGO YIN-YANG ROTATIVO
    --// LOGO YIN-YANG BASE (estático, el nuevo diseño)
    local YinYangLogo = mk("ImageLabel", {
        Parent = ToggleButton,
        Size = UDim2.new(1.6, 0, 1.6, 0),
        Position = UDim2.new(-0.3, 0, -0.3, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://106130066496682",
        ZIndex = 31
    })
    mk("UIAspectRatioConstraint", {AspectRatio = 1}, YinYangLogo)

    --// IMAGEN QUE GIRA ENCIMA (capa superior, el anillo exterior)
    local YinYangSpinner = mk("ImageLabel", {
        Parent = ToggleButton,
        Size = UDim2.new(1.6, 0, 1.6, 0),
        Position = UDim2.new(-0.3, 0, -0.3, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://70721341917757",
        ZIndex = 32
    })
    mk("UIAspectRatioConstraint", {AspectRatio = 1}, YinYangSpinner)

    --// ROTACIÓN FLUIDA CON INERCIA (como definió ChatGPT)
    --// rotation += speed * deltaTime
    --// speed = lerp(speed, targetSpeed, 0.08)
    --// + math.sin(t * 2) * 8 para variación orgánica

    local spinnerAngle  = 0
    local spinnerSpeed  = 60   -- velocidad actual (°/s)
    local targetSpeed   = 60   -- velocidad objetivo
    local timeAccum     = 0    -- acumulador de tiempo para la onda sinusoidal

    local function lerp(a, b, t)
        return a + (b - a) * t
    end

    game:GetService("RunService").RenderStepped:Connect(function(dt)
        timeAccum = timeAccum + dt

        --// Variar la velocidad objetivo con una onda sinusoidal
        --// Esto crea el efecto de aceleración/desaceleración orgánica
        targetSpeed = 60 + math.sin(timeAccum * 0.8) * 20

        --// Lerp suave hacia la velocidad objetivo (inercia)
        spinnerSpeed = lerp(spinnerSpeed, targetSpeed, 0.08)

        --// Acumular rotación infinita (sin resetear a 0)
        spinnerAngle = spinnerAngle + spinnerSpeed * dt

        --// Aplicar al spinner (gira) - el logo base no gira
        YinYangSpinner.Rotation = spinnerAngle
    end)

    --// SONIDO DE DRAGÓN ALEATORIO CUANDO ESTÁ CERRADO
    local dragonTimer = 0
    local dragonConnection
    dragonConnection = game:GetService("RunService").Heartbeat:Connect(function()
        dragonTimer = dragonTimer + 1
        if dragonTimer > 900 then -- Cada 15 segundos
            dragonTimer = 0
            if not Main or not Main.Visible then
                playSound(Sounds.Dragon, 0.15)
            end
        end
    end)

    local ToggleScale = mk("UIScale", {Scale = 1}, ToggleButton)

    ToggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            playSound(Sounds.Click, 0.6)
            TweenService:Create(ToggleScale, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Scale = 0.88}):Play()
        end
    end)
    ToggleButton.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            TweenService:Create(ToggleScale, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
        end
    end)

    --// VENTANA PRINCIPAL - SOMBRA MEJORADA
    local shownSize = UDim2.new(0, 420, 0, 340)
    local ShadowFrame = mk("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.98,
        BorderSizePixel = 0,
        ZIndex = 4,
        Parent = ScreenGui
    })
    corner(ShadowFrame, 10)
    ShadowFrame:SetAttribute("ThemeRole", "Stroke")

    local Main = mk("Frame", {
        Name = "Main",
        Size = shownSize,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Visible = true,
        ZIndex = 5
    }, ScreenGui)
    Main:SetAttribute("ThemeRole", "Background")
    corner(Main, 10)
    stroke(Main, Theme.Stroke, 1.5)

    -- Escala de ventana: más fluido que animar Size al cerrar/abrir
    local MainScale = mk("UIScale", {
        Scale = 1,
    }, Main)

    -- Efecto de brillo animado en el borde de la ventana principal
    buildAnimatedBorder(Main, Theme.Accent, UDim.new(0, 10))

    local BackgroundArt  -- se crea más abajo, dentro de ContentArea (ver comentario ahí)
    local TopBarArt      -- imagen decorativa en la barra de título (se crea más abajo, dentro de TopBar)
    local TabListArt     -- imagen decorativa en la barra de pestañas (se crea más abajo, en Body)

    local function updateShadowPos()
        ShadowFrame.Size = UDim2.new(Main.Size.X.Scale, Main.Size.X.Offset + 4, Main.Size.Y.Scale, Main.Size.Y.Offset + 4)
        ShadowFrame.Position = UDim2.new(Main.Position.X.Scale, Main.Position.X.Offset - 2, Main.Position.Y.Scale, Main.Position.Y.Offset - 2)
    end
    Main:GetPropertyChangedSignal("Size"):Connect(updateShadowPos)
    Main:GetPropertyChangedSignal("Position"):Connect(updateShadowPos)

    local uiVisible = true
    local windowTweenBusy = false
    local activeWindowTween = nil

    local function setMainGlowEnabled(enabled)
        if enabled then
            buildAnimatedBorder(Main, Theme.Accent, UDim.new(0, 10))
        else
            stopGlowTweens(tostring(Main))
            cleanGlowLayers(Main)
        end
    end

    local function showMainWindow()
        if windowTweenBusy or uiVisible then
            return
        end

        windowTweenBusy = true
        uiVisible = true

        if activeWindowTween then
            pcall(function()
                activeWindowTween:Cancel()
            end)
            activeWindowTween = nil
        end

        setMainGlowEnabled(true)
        ShadowFrame.Visible = false
        Main.Visible = true
        MainScale.Scale = 0.82
        Main.BackgroundTransparency = 0

        local tw = TweenService:Create(
            MainScale,
            TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
            { Scale = 1 }
        )
        activeWindowTween = tw
        tw:Play()
        tw.Completed:Once(function()
            if activeWindowTween == tw then
                activeWindowTween = nil
            end
            ShadowFrame.Visible = true
            windowTweenBusy = false
        end)
    end

    local function hideMainWindow()
        if windowTweenBusy or not uiVisible then
            return
        end

        windowTweenBusy = true
        uiVisible = false

        if activeWindowTween then
            pcall(function() activeWindowTween:Cancel() end)
            activeWindowTween = nil
        end

        ShadowFrame.Visible = false

        --// Fade out simultáneo: escala + transparencia para 60fps real
        local tw1 = TweenService:Create(
            MainScale,
            TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
            { Scale = 0.85 }
        )
        local tw2 = TweenService:Create(
            Main,
            TweenInfo.new(0.25, Enum.EasingStyle.Cubic, Enum.EasingDirection.In),
            { BackgroundTransparency = 1 }
        )

        activeWindowTween = tw1
        tw1:Play()
        tw2:Play()

        tw1.Completed:Once(function()
            if activeWindowTween == tw1 then
                activeWindowTween = nil
            end
            setMainGlowEnabled(false)
            Main.Visible = false
            MainScale.Scale = 1
            Main.BackgroundTransparency = 0
            windowTweenBusy = false
        end)
    end

    ToggleButton.MouseButton1Click:Connect(function()
        if uiVisible then
            hideMainWindow()
        else
            showMainWindow()
        end
    end)

    do
        local drag = false
        local dragStart, startPos
        ToggleButton.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                if not IconoCongelado then  -- 🔒 SOLO permitir drag si NO está congelado
                    drag = true
                    dragStart = input.Position
                    startPos = ToggleButton.Position
                end
            end
        end)
        track(UserInputService.InputChanged:Connect(function(input)
            if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                ToggleButton.Position = UDim2.new(0, startPos.X.Offset + delta.X, 0, startPos.Y.Offset + delta.Y)
            end
        end))
        track(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                drag = false
            end
        end))
    end

    local TopBar = mk("Frame", {
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = Theme.Background,
        ZIndex = 6,
    }, Main)
    TopBar:SetAttribute("ThemeRole", "Background")
    corner(TopBar, 10)
    --// Imagen decorativa en la barra de título — ZIndex 6 (detrás del texto y boombox)
    TopBarArt = mk("ImageLabel", {
        Name = "TopBarArt",
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = ThemeTitleBarImages[startTheme] or "",
        ImageTransparency = 0.12,
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 6,
        ClipsDescendants = true,
    }, TopBar)
    corner(TopBarArt, 10)
    local TitleDivider = mk("Frame", {Size = UDim2.new(1, 0, 0, 1), Position = UDim2.new(0, 0, 1, -1), BackgroundTransparency = 1, BorderSizePixel = 0, ZIndex = 7}, TopBar)
    TitleDivider.Visible = false
    TitleDivider:SetAttribute("ThemeRole", "Stroke")

    --// Efecto glow animado en la línea divisora del título
    local divStroke = Instance.new("UIStroke")
    divStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    divStroke.Thickness = 1
    divStroke.Transparency = 0.4
    divStroke.Color = Theme.Accent
    divStroke.LineJoinMode = Enum.LineJoinMode.Round
    divStroke.Parent = TitleDivider

    local divGrad = Instance.new("UIGradient")
    divGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromHSV(Color3.toHSV(Theme.Accent))),
        ColorSequenceKeypoint.new(0.5, Color3.new(1,1,1)),
        ColorSequenceKeypoint.new(1, Color3.fromHSV(Color3.toHSV(Theme.Accent))),
    })
    divGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.7),
        NumberSequenceKeypoint.new(0.5, 0),
        NumberSequenceKeypoint.new(1, 0.7),
    })
    divGrad.Offset = Vector2.new(-1.5, 0)
    divGrad.Parent = divStroke

    TweenService:Create(
        divGrad,
        TweenInfo.new(2.0, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false),
        { Offset = Vector2.new(1.5, 0) }
    ):Play()

    local TitleLabel = mk("TextLabel", {
        Size = UDim2.new(0, 120, 1, 0),
        Position = UDim2.new(0, 15, 0, 0),
        BackgroundTransparency = 1,
        Text = title_text or "ZERO UI",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 7
    }, TopBar)
    TitleLabel:SetAttribute("ThemeTextRole", "Text")


    --// BOOMBOX: Píldora en el centro del TopBar
    local BoomboxSound = nil

    local BoomboxPill = mk("Frame", {
        Size = UDim2.new(0, 155, 0, 28),
        Position = UDim2.new(0.5, -77, 0.5, -14),
        BackgroundColor3 = Color3.fromRGB(5, 5, 8),
        BackgroundTransparency = 0,
        ZIndex = 10,
    }, TopBar)
    corner(BoomboxPill, 999)

    --// Stroke con glow animado IGUAL al de los bordes de la librería
    local boomStroke = mk("UIStroke", {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Thickness = 2,
        Transparency = 0.2,
        Color = Color3.new(1, 1, 1),
        LineJoinMode = Enum.LineJoinMode.Round,
    }, BoomboxPill)

    local boomGrad = mk("UIGradient", {
        Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(160, 160, 160)),
            ColorSequenceKeypoint.new(0.5, Color3.new(1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 160, 160)),
        }),
        Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0.5),
            NumberSequenceKeypoint.new(0.5, 0),
            NumberSequenceKeypoint.new(1, 0.5),
        }),
        Offset = Vector2.new(-1.5, 0),
    }, boomStroke)

    TweenService:Create(boomGrad,
        TweenInfo.new(1.6, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false),
        { Offset = Vector2.new(1.5, 0) }
    ):Play()

    TweenService:Create(boomStroke,
        TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true),
        { Transparency = 0.0, Thickness = 3 }
    ):Play()

    --// Icono compás (sin emoji, solo asset)
    mk("ImageLabel", {
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 6, 0.5, -9),
        BackgroundTransparency = 1,
        Image = "rbxassetid://75018103027872",
        ScaleType = Enum.ScaleType.Fit,
        ImageColor3 = Color3.new(1, 1, 1),
        ZIndex = 12,
    }, BoomboxPill)

    --// Placeholder "boombox" (TextLabel, se oculta al escribir)
    local BoomboxPlaceholder = mk("TextLabel", {
        Size = UDim2.new(1, -32, 1, 0),
        Position = UDim2.new(0, 28, 0, 0),
        BackgroundTransparency = 1,
        Text = "boombox",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 11,
    }, BoomboxPill)

    --// TextBox encima (captura el input, sin texto ni placeholder propio)
    local BoomboxInput = mk("TextBox", {
        Size = UDim2.new(1, -32, 1, 0),
        Position = UDim2.new(0, 28, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        PlaceholderText = "",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Center,
        ClearTextOnFocus = false,
        ZIndex = 13,
    }, BoomboxPill)

    --// Al escribir 1 carácter: placeholder desaparece
    BoomboxInput:GetPropertyChangedSignal("Text"):Connect(function()
        BoomboxPlaceholder.Visible = BoomboxInput.Text == ""
    end)

    local function playBoombox(id)
        if BoomboxSound then
            pcall(function() BoomboxSound:Stop() BoomboxSound:Destroy() end)
            BoomboxSound = nil
        end
        if not id or id == "" then return end
        local cleanId = id:match("%d+")
        if not cleanId then return end
        pcall(function()
            local s = Instance.new("Sound")
            s.SoundId = "rbxassetid://" .. cleanId
            s.Volume = 0.8
            s.Looped = true
            s.Parent = workspace
            s:Play()
            BoomboxSound = s
            print("Boombox: reproduciendo " .. cleanId)
        end)
    end

    BoomboxInput.FocusLost:Connect(function()
        local text = BoomboxInput.Text:gsub("%s+", "")
        if text == "" then
            if BoomboxSound then
                pcall(function() BoomboxSound:Stop() BoomboxSound:Destroy() end)
                BoomboxSound = nil
            end
            BoomboxPlaceholder.Visible = true
        else
            playBoombox(text)
        end
    end)

    --// CONTADOR DE JUGADORES ONLINE — derecha del BoomboxPill
    --// Declarado aquí (antes de StartBackendPolling) para ser capturado como upvalue
    local TopBarCounter = mk("Frame", {
        Parent = TopBar,
        AnchorPoint = Vector2.new(0, 0.5),
        Position = UDim2.new(0.5, 84, 0.5, 0),
        Size = UDim2.fromOffset(48, 20),
        BackgroundTransparency = 1,
        ZIndex = 9,
    })
    mk("ImageLabel", {
        Parent = TopBarCounter,
        Size = UDim2.fromOffset(14, 14),
        Position = UDim2.new(0, 0, 0.5, -7),
        BackgroundTransparency = 1,
        Image = "rbxassetid://74246983577629",
        ImageColor3 = Theme.Accent,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 10,
    })
    local TopBarOnlineLabel = mk("TextLabel", {
        Parent = TopBarCounter,
        Size = UDim2.fromOffset(30, 14),
        Position = UDim2.new(0, 18, 0.5, -7),
        BackgroundTransparency = 1,
        Text = "...",
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 10,
    })

    --// CONTROLES DE VENTANA TIPO PC: minimizar, pantalla completa y cerrar
    local isMaximized = false
    local normalWindowSize = Main.Size
    local normalWindowPosition = Main.Position
    local normalWindowAnchorPoint = Main.AnchorPoint
    local hiddenSiblingStates = {}
    local closingUI = false

    local function setRobloxCoreVisible(visible)
        -- Oculta/restaura los iconos nativos de Roblox y la barra superior.
        -- Se usa pcall porque algunos ejecutores limitan ciertos CoreGuiType.
        local coreTypes = {
            Enum.CoreGuiType.Backpack,
            Enum.CoreGuiType.Chat,
            Enum.CoreGuiType.Health,
            Enum.CoreGuiType.PlayerList,
            Enum.CoreGuiType.EmotesMenu,
        }
        for _, coreType in ipairs(coreTypes) do
            pcall(function()
                StarterGui:SetCoreGuiEnabled(coreType, visible)
            end)
        end
        pcall(function()
            StarterGui:SetCore("TopbarEnabled", visible)
        end)
    end

    local function setOtherScreenObjectsVisible(visible)
        if not visible then
            hiddenSiblingStates = {}
            for _, child in ipairs(ScreenGui:GetChildren()) do
                if child:IsA("GuiObject") and child ~= Main and child ~= ShadowFrame then
                    hiddenSiblingStates[child] = child.Visible
                    child.Visible = false
                end
            end
        else
            for child, wasVisible in pairs(hiddenSiblingStates) do
                if child and child.Parent then
                    child.Visible = wasVisible
                end
            end
            hiddenSiblingStates = {}
        end
    end

    local function applyMaximizedState(maximized)
        if closingUI or isMaximized == maximized then return end
        isMaximized = maximized

        if maximized then
            normalWindowSize = Main.Size
            normalWindowPosition = Main.Position
            normalWindowAnchorPoint = Main.AnchorPoint

            ShadowFrame.Visible = false
            setOtherScreenObjectsVisible(false)
            setRobloxCoreVisible(false)

            Main.AnchorPoint = Vector2.new(0, 0)
            -- Sangrado de 3 px para cubrir por completo bordes/safe-area del dispositivo.
            Main.Position = UDim2.fromOffset(-3, -3)
            Main.Size = UDim2.new(1, 6, 1, 6)
            MainScale.Scale = 1

            local mainCorner = Main:FindFirstChildOfClass("UICorner")
            if mainCorner then mainCorner.CornerRadius = UDim.new(0, 0) end
            local topCorner = TopBar:FindFirstChildOfClass("UICorner")
            if topCorner then topCorner.CornerRadius = UDim.new(0, 0) end
        else
            setRobloxCoreVisible(true)
            setOtherScreenObjectsVisible(true)

            Main.AnchorPoint = normalWindowAnchorPoint
            Main.Position = normalWindowPosition
            Main.Size = normalWindowSize

            local mainCorner = Main:FindFirstChildOfClass("UICorner")
            if mainCorner then mainCorner.CornerRadius = UDim.new(0, 10) end
            local topCorner = TopBar:FindFirstChildOfClass("UICorner")
            if topCorner then topCorner.CornerRadius = UDim.new(0, 10) end
            ShadowFrame.Visible = uiVisible
        end
    end

    local function shutdownUI()
        if closingUI then return end
        closingUI = true

        setRobloxCoreVisible(true)
        if BoomboxSound then
            pcall(function() BoomboxSound:Stop() BoomboxSound:Destroy() end)
            BoomboxSound = nil
        end
        for _, conn in ipairs(globalConnections) do
            pcall(function() conn:Disconnect() end)
        end
        pcall(function() dragonConnection:Disconnect() end)
        pcall(function() ScreenGui:Destroy() end)
    end

    local WindowControls = mk("Frame", {
        Name = "WindowControls",
        AnchorPoint = Vector2.new(1, 0.5),
        Position = UDim2.new(1, -8, 0.5, 0),
        Size = UDim2.fromOffset(100, 32),
        BackgroundTransparency = 1,
        ZIndex = 50,
    }, TopBar)

    local ControlsLayout = mk("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Right,
        VerticalAlignment = Enum.VerticalAlignment.Center,
        Padding = UDim.new(0, 4),
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, WindowControls)

    local function createWindowControl(name, imageId, order, tooltip)
        local button = mk("ImageButton", {
            Name = name,
            Size = UDim2.fromOffset(28, 28),
            BackgroundTransparency = 1,
            Image = "rbxassetid://" .. tostring(imageId),
            ImageColor3 = Theme.Text,
            ScaleType = Enum.ScaleType.Fit,
            AutoButtonColor = false,
            LayoutOrder = order,
            ZIndex = 51,
        }, WindowControls)
        button:SetAttribute("ThemeImageRole", "Text")
        button:SetAttribute("Tooltip", tooltip)

        local scale = mk("UIScale", {Scale = 1}, button)
        button.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                TweenService:Create(scale, TweenInfo.new(0.08), {Scale = 0.82}):Play()
            end
        end)
        button.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                TweenService:Create(scale, TweenInfo.new(0.14, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Scale = 1}):Play()
            end
        end)
        return button
    end

    local MinimizeButton = createWindowControl("Minimize", 118609364031074, 1, "Minimizar")
    local MaximizeButton = createWindowControl("Maximize", 109433688231575, 2, "Pantalla completa")
    local CloseButton = createWindowControl("Close", 104161431521816, 3, "Cerrar")

    MinimizeButton.MouseButton1Click:Connect(function()
        playSound(Sounds.Click, 0.6)
        if isMaximized then applyMaximizedState(false) end
        hideMainWindow()
    end)

    MaximizeButton.MouseButton1Click:Connect(function()
        playSound(Sounds.Click, 0.6)
        applyMaximizedState(not isMaximized)
    end)

    CloseButton.MouseButton1Click:Connect(function()
        playSound(Sounds.Click, 0.6)
        shutdownUI()
    end)

    --//  ANIMACIÓN YIN-YANG ÉPICA EN EL TÍTULO (v27)
    --// Si el título contiene "Yin" o "Yang", aplica animación especial
    if title_text and (string.find(title_text, "Yin") or string.find(title_text, "Yang")) then
        local animValue = 0
        local animSpeed = 0.3  -- Muy lentamente
        local origColor = TitleLabel.TextColor3
        
        track(RunService.RenderStepped:Connect(function()
            animValue = (animValue + animSpeed) % 360
            
            -- Calcular valor de interpolación (0 a 1 a 0)
            local sine = (math.sin(math.rad(animValue)) + 1) / 2  -- 0 a 1
            
            -- Si contiene "Yin", cambia Negro↔Blanco
            -- Si contiene "Yang", cambia Blanco↔Negro (inverso)
            if string.find(title_text, "Yin Yang") or string.find(title_text, "yin yang") then
                -- Ambos presentes: Yin va Negro→Blanco, Yang va Blanco→Negro
                TitleLabel.TextColor3 = Color3.fromRGB(
                    math.floor(255 * sine),
                    math.floor(255 * sine),
                    math.floor(255 * sine)
                )
            else
                TitleLabel.TextColor3 = Color3.fromRGB(
                    math.floor(255 * sine),
                    math.floor(255 * sine),
                    math.floor(255 * sine)
                )
            end
        end))
    end

    do
        local drag = false
        local dragStart, startPos
        TopBar.InputBegan:Connect(function(input)
            if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not isMaximized then
                drag = true
                dragStart = input.Position
                startPos = Main.Position
            end
        end)
        track(UserInputService.InputChanged:Connect(function(input)
            if drag and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                local delta = input.Position - dragStart
                Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end))
        track(UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                drag = false
            end
        end))
    end

    local Body = mk("Frame", {
        Size = UDim2.new(1, 0, 1, -40),
        Position = UDim2.new(0, 0, 0, 40),
        BackgroundTransparency = 1,
        ZIndex = 6
    }, Main)

    local TabList = mk("ScrollingFrame", {
        Size = UDim2.new(0, 110, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ElasticBehavior = Enum.ElasticBehavior.Never,
        CanvasPosition = Vector2.new(0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 7
    }, Body)
    TabList:SetAttribute("ThemeRole", "Secondary")
    corner(TabList, 10)
    --// Imagen decorativa en la barra de pestañas — ZIndex 6 (detrás de TabList)
    --// TabList.BackgroundTransparency se ajusta en SetTheme cuando hay imagen activa
    TabListArt = mk("ImageLabel", {
        Name = "TabListArt",
        Position = UDim2.new(0, 0, 0, 0),
        Size = UDim2.new(0, 110, 1, 0),
        BackgroundTransparency = 1,
        Image = ThemeTabListImages[startTheme] or "",
        ImageTransparency = 0.12,
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 6,
        ClipsDescendants = true,
    }, Body)
    corner(TabListArt, 10)
    mk("UIListLayout", {
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
        VerticalAlignment = Enum.VerticalAlignment.Top,
    }, TabList)
    mk("UIPadding", {PaddingTop = UDim.new(0, 4), PaddingLeft = UDim.new(0, 6), PaddingRight = UDim.new(0, 6)}, TabList)
    mk("Frame", {Parent = Body, Size = UDim2.new(0, 1, 1, 0), Position = UDim2.new(0, 109, 0, 0), BackgroundColor3 = Theme.Stroke, BackgroundTransparency = 0.82, BorderSizePixel = 0, ZIndex = 8}, Body):SetAttribute("ThemeRole", "Stroke")

    local ContentArea = mk("Frame", {
        Size = UDim2.new(1, -110, 1, 0),
        Position = UDim2.new(0, 110, 0, 0),
        BackgroundTransparency = 1,
        ZIndex = 7
    }, Body)
    mk("UIPadding", {PaddingTop = UDim.new(0, 0), PaddingLeft = UDim.new(0, 0), PaddingRight = UDim.new(0, 0), PaddingBottom = UDim.new(0, 0)}, ContentArea)

    --// FONDO DECORATIVO SEGÚN EL TEMA
    -- IMPORTANTE: vive DENTRO de ContentArea (no de todo Main). Antes cubría toda la
    -- ventana pero el TabList (110px) tapaba la mitad izquierda, así que lo que se
    -- veía era un recorte descentrado de la imagen. Al vivir solo en el área visible,
    -- con AnchorPoint centrado, la imagen queda realmente centrada en lo que el usuario ve.
    BackgroundArt = mk("ImageLabel", {
        Name = "BackgroundArt",
        Parent = ContentArea,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, 30, 1, 30),  -- Agrandado +15px por lado para desbordar el padding (15px)
        BackgroundTransparency = 1,
        Image = ThemeBackgroundImages[startTheme] or "",
        ImageTransparency = 0.1,
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 5
    })
    corner(BackgroundArt, 8)

    local Overlay = mk("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 200,
    }, Main)

    local currentDropdownClose = nil

    local function attachDropdownBehavior(Holder, Click, Chevron, optionsCount, buildPopupContents)
        local isOpen = false
        local closePopup

        local function open()
            if currentDropdownClose then currentDropdownClose() end
            isOpen = true
            Chevron.Text = "^"

            local backdrop = mk("TextButton", {
                Parent = Overlay,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 201
            })

            local relX = Holder.AbsolutePosition.X - Main.AbsolutePosition.X
            local relY = Holder.AbsolutePosition.Y - Main.AbsolutePosition.Y + Holder.AbsoluteSize.Y + 4
            local itemH = 32
            local maxH = 160
            local contentH = math.max(optionsCount, 1) * (itemH + 4) + 8
            local popupH = math.min(contentH, maxH)

            local Popup = mk("ScrollingFrame", {
                Parent = Overlay,
                Position = UDim2.new(0, relX, 0, relY),
                Size = UDim2.new(0, Holder.AbsoluteSize.X, 0, popupH),
                BackgroundColor3 = Theme.Background,
                BorderSizePixel = 0,
                ScrollBarThickness = 3,
                ElasticBehavior = Enum.ElasticBehavior.Never,
                CanvasPosition = Vector2.new(0, 0),
                AutomaticCanvasSize = Enum.AutomaticSize.Y,
                ZIndex = 202
            })
            Popup:SetAttribute("ThemeRole", "Background")
            corner(Popup, 6)
            stroke(Popup, Theme.Stroke, 1.5, 0)
            mk("UIListLayout", {Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder}, Popup)
            mk("UIPadding", {
                PaddingTop = UDim.new(0, 4), PaddingBottom = UDim.new(0, 4),
                PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4)
            }, Popup)

            closePopup = function()
                isOpen = false
                Chevron.Text = "v"
                backdrop:Destroy()
                Popup:Destroy()
                currentDropdownClose = nil
            end
            currentDropdownClose = closePopup
            backdrop.MouseButton1Click:Connect(function() closePopup() end)

            buildPopupContents(Popup, closePopup)
        end

        Click.MouseButton1Click:Connect(function()
            if isOpen then
                if closePopup then closePopup() end
            else
                open()
            end
        end)
    end

    local Window = setmetatable({}, ZeroUI)
    Window.Tabs = {}
    Window.Assets = Assets
    Window.CurrentTheme = startTheme
    Window.AllThemes = ThemePalettes
    Window.FloatingToggles = {}
    Window.ScreenGui = ScreenGui
    Window.BackgroundArt = BackgroundArt
    Window.TopBarArt     = TopBarArt
    Window.TabListArt    = TabListArt

    --// TAMAÑO DE LA VENTANA: solo dos versiones fijas (sin sliders intermedios)
    local LibrarySizePresets = {
        Small = { Width = 500, Height = 430 },
        Large = { Width = 760, Height = 720 },
    }

    local LibrarySizeMode = ((SavedConfig.LibrarySizeMode or "Small") == "Large") and "Large" or "Small"

    local function getCurrentLibraryPreset()
        return LibrarySizePresets[LibrarySizeMode] or LibrarySizePresets.Small
    end

    local function updateWindowSize()
        local preset = getCurrentLibraryPreset()
        local screen = ScreenGui.AbsoluteSize
        local width = preset.Width
        local height = preset.Height

        if screen.X > 0 and screen.Y > 0 then
            width = math.min(width, math.floor(screen.X * 0.92))
            height = math.min(height, math.floor(screen.Y * 0.92))
        end

        shownSize = UDim2.new(0, width, 0, height)
        if Main and not isMaximized then
            Main.Size = shownSize
            normalWindowSize = shownSize
        end
    end

    updateWindowSize()
    ScreenGui:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateWindowSize)

    function Window:SetLibraryVersion(isLarge)
        LibrarySizeMode = isLarge and "Large" or "Small"
        self.LibrarySizeMode = LibrarySizeMode
        self.LibraryHeight = getCurrentLibraryPreset().Height
        SavedConfig.LibrarySizeMode = LibrarySizeMode
        SavedConfig.LibraryHeight = self.LibraryHeight
        SaveConfig()
        updateWindowSize()
    end

    Window.LibrarySizeMode = LibrarySizeMode
    Window.LibraryHeight = getCurrentLibraryPreset().Height

    function Window:CreateTab(nameSpanish, nameEnglishOrIcon, iconAsset)
        --// COMPATIBILIDAD: Si nameEnglishOrIcon es un icon (rbxassetid), tratarlo como antes
        local nameEnglish = nameSpanish
        if nameEnglishOrIcon and string.find(nameEnglishOrIcon, "rbxassetid") then
            --// Código antiguo: CreateTab(name, iconAsset)
            iconAsset = nameEnglishOrIcon
            nameEnglish = nameSpanish
        elseif nameEnglishOrIcon then
            --// Código nuevo: CreateTab(nameSpanish, nameEnglish, iconAsset)
            nameEnglish = nameEnglishOrIcon
        end
        
        local displayName = GetText(nameSpanish, nameEnglish)
        
        local TabButton = mk("TextButton", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Theme.AccentOff,
            Text = "",
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.None,
            ClipsDescendants = false,
            ZIndex = 8
        }, TabList)
        TabButton:SetAttribute("ThemeRole", "AccentOff")
        TabButton:SetAttribute("TextSpanish", nameSpanish)
        TabButton:SetAttribute("TextEnglish", nameEnglish)
        corner(TabButton, 6)

        local textStart = 38
        if iconAsset then
            local iconSize = 24
            local iconPos = 7
            mk("ImageLabel", {
                Parent = TabButton,
                Size = UDim2.new(0, iconSize, 0, iconSize),
                Position = UDim2.new(0, iconPos, 0.5, -(iconSize / 2)),
                BackgroundTransparency = 1,
                Image = iconAsset,
                ScaleType = Enum.ScaleType.Fit,
                ZIndex = 9
            })
        end

        if nameSpanish == "Spotify" then
            mk("ImageLabel", {
                Parent = TabButton,
                Size = UDim2.new(0, 32, 0, 10),
                Position = UDim2.new(0, textStart, 0, 18),
                BackgroundTransparency = 1,
                Image = "rbxassetid://74630849553567",
                ScaleType = Enum.ScaleType.Fit,
                ZIndex = 9
            })
        end

        local TabNameLabel = mk("TextLabel", {
            Parent = TabButton,
            Size = UDim2.new(1, -(textStart + 10), 1, 0),
            Position = UDim2.new(0, textStart, 0, 0),
            BackgroundTransparency = 1,
            Text = displayName,
            TextColor3 = Theme.Text,
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            TextTruncate = Enum.TextTruncate.None,
            ClipsDescendants = false,
            ZIndex = 9
        })
        TabNameLabel:SetAttribute("TextSpanish", nameSpanish)
        TabNameLabel:SetAttribute("TextEnglish", nameEnglish)

        resetScrollTop(TabList)

        local TabPage = mk("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 2,
            ElasticBehavior = Enum.ElasticBehavior.Never,
            CanvasPosition = Vector2.new(0, 0),
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false,
            ZIndex = 8,
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
        }, ContentArea)
        mk("UIListLayout", {
            Padding = UDim.new(0, 6),
            SortOrder = Enum.SortOrder.LayoutOrder,
            VerticalAlignment = Enum.VerticalAlignment.Top,
        }, TabPage)

        local Tab = {Button = TabButton, Page = TabPage}

        local function Select()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                t.Button.TextColor3 = Theme.Text
                t.Button.BackgroundColor3 = Theme.AccentOff
            end
            TabPage.Visible = true
            TabPage.CanvasPosition = Vector2.new(0, 0)
            task.defer(function()
                if TabPage and TabPage.Parent then
                    TabPage.CanvasPosition = Vector2.new(0, 0)
                end
            end)
            TabButton.TextColor3 = Theme.AccentText
            TabButton.BackgroundColor3 = Theme.Accent
        end

        TabButton.MouseButton1Click:Connect(Select)

        --// EFECTO HOVER/TOUCH en botones del tab
        TabButton.MouseEnter:Connect(function()
            local isActive = (TabPage.Visible)
            if not isActive then
                TweenService:Create(TabButton, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundTransparency = 0.30}):Play()
            end
        end)
        TabButton.MouseLeave:Connect(function()
            local isActive = (TabPage.Visible)
            if not isActive then
                TweenService:Create(TabButton, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundTransparency = 0}):Play()
            end
        end)
        TabButton.InputBegan:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch then
                local isActive = (TabPage.Visible)
                if not isActive then
                    TweenService:Create(TabButton, TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {BackgroundTransparency = 0.35}):Play()
                end
            end
        end)
        TabButton.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.Touch then
                local isActive = (TabPage.Visible)
                if not isActive then
                    TweenService:Create(TabButton, TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {BackgroundTransparency = 0}):Play()
                end
            end
        end)

        if #Window.Tabs == 0 then Select() end
        table.insert(Window.Tabs, Tab)

        --// NUEVO: TOGGLE FLOTANTE

        --//  FLOATING TOGGLE v2.0 - COMPLETAMENTE RECONSTRUIDO
        function Tab:CreateFloatingToggle(textSpanish, textEnglishOrDefault, defaultOrCallback, callback)
            --// COMPATIBILIDAD: si el 2do argumento es string, es modo bilingüe.
            --// Si es boolean/nil, es la firma antigua: (text, default, callback)
            local textEnglish = textSpanish
            local default, cb

            if type(textEnglishOrDefault) == "string" then
                textEnglish = textEnglishOrDefault
                default = defaultOrCallback
                cb = callback
            else
                default = textEnglishOrDefault
                cb = defaultOrCallback
            end

            local displayText = GetText(textSpanish, textEnglish)
            local state = default or false
            local isFloating = false
            local isLocked = false

            --// ═════════════════════════════════════════════════════════════════════════
            --// PARTE 1: ELEMENTO EN LA PESTAÑA — usa CreateToggle para diseño nuevo
            --// ═════════════════════════════════════════════════════════════════════════

            local tog = self:CreateToggle(textSpanish, textEnglish, state, function(newState)
                state = newState
                pcall(cb, state)
            end)

            local Holder     = tog.Holder
            local HolderSwitch = tog.Switch
            local HolderClick  = tog.Click

            --// Botón Desprender — ↗ encima del toggle existente
            local DetachBtn = mk("TextButton", {
                Parent = Holder,
                Size = UDim2.new(0, 26, 0, 26),
                Position = UDim2.new(1, -126, 0.5, -13),
                BackgroundColor3 = Theme.Accent,
                Text = "↗",
                TextColor3 = Color3.fromRGB(0, 0, 0),
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                ZIndex = 15
            })
            corner(DetachBtn, 6)

            --// Botón Fijar — candado real (ImageButton)
            local PinBtn = mk("ImageButton", {
                Parent = Holder,
                Size = UDim2.new(0, 26, 0, 26),
                Position = UDim2.new(1, -96, 0.5, -13),
                BackgroundColor3 = Theme.Secondary,
                Image = "rbxassetid://83537941312438",  -- candado abierto
                ImageColor3 = Theme.Text,
                ScaleType = Enum.ScaleType.Stretch,
                ZIndex = 15
            })
            corner(PinBtn, 6)
            stroke(PinBtn, Theme.Stroke, 1, 0.5)

            --// Botón Favorito — estrella, agrega/saca este toggle de la pestaña Favoritos (persiste)
            local favId = nameSpanish .. "::" .. textSpanish
            local isFavorite = SavedFavoriteIds[favId] or false
            local FavBtn = mk("ImageButton", {
                Parent = Holder,
                Size = UDim2.new(0, 32, 0, 32),
                Position = UDim2.new(1, -162, 0.5, -16),
                BackgroundTransparency = 1,
                Image = isFavorite and "rbxassetid://113655648685815" or "rbxassetid://90877976276431",
                ScaleType = Enum.ScaleType.Fit,
                ZIndex = 15
            })

            --// ⚠️ NO ELIMINAR — _linkedSliderRef debe estar ANTES de syncFavoriteRow
            --// LinkSlider lo setea, y syncFavoriteRow lo lee
            local _linkedSliderRef    = nil
            local _linkedSliderFavRow = nil
            local favRow = nil

            local function syncFavoriteRow()
                --// Limpiar toggle en Favoritos
                if favRow then
                    pcall(function() favRow.Holder:Destroy() end)
                    favRow = nil
                end
                --// Limpiar slider en Favoritos
                if _linkedSliderFavRow then
                    pcall(function() _linkedSliderFavRow:Destroy() end)
                    _linkedSliderFavRow = nil
                end

                if isFavorite and AutoTabFavoritosRef then
                    --// Toggle espejo en Favoritos
                    favRow = AutoTabFavoritosRef:CreateToggle(textSpanish, textEnglish, state, function(newState)
                        state = newState
                        tog.SetValue(newState)
                        pcall(cb, newState)
                    end)

                    --// ✅ Slider vinculado: si existe, aparece justo debajo en Favoritos
                    if _linkedSliderRef then
                        _linkedSliderFavRow = AutoTabFavoritosRef:CreateSlider(
                            _linkedSliderRef._labelES or "Slider",
                            _linkedSliderRef._min     or 0,
                            _linkedSliderRef._max     or 100,
                            _linkedSliderRef._value   or 50,
                            function(newVal)
                                _linkedSliderRef._value = newVal
                                if _linkedSliderRef._callback then
                                    pcall(_linkedSliderRef._callback, newVal)
                                end
                            end
                        )
                    end
                end
            end
            syncFavoriteRow()

            FavBtn.MouseButton1Click:Connect(function()
                playSound(Sounds.Click, 0.5)
                isFavorite = not isFavorite
                FavBtn.Image = isFavorite and "rbxassetid://113655648685815" or "rbxassetid://90877976276431"
                SavedFavoriteIds[favId] = isFavorite or nil
                syncFavoriteRow()
                SyncFavoritesToConfig()
            end)

            --// ════════════════════════════════════════════════════════════════
            --// ⚠️ NO ELIMINAR — Toggle:LinkSlider(slider)
            --// Vincula un Slider a este Toggle.
            --// Cuando el Toggle se añade a Favoritos, el Slider aparece
            --// justo debajo automáticamente.
            --// Uso:
            --//   local tog = Tab:CreateFloatingToggle("Walk", false, fn)
            --//   local sli = Tab:CreateSlider("Speed", 1, 100, 10, fn)
            --//   tog:LinkSlider(sli)
            --// ════════════════════════════════════════════════════════════════
            tog.LinkSlider = function(self, sliderObj)
                _linkedSliderRef = sliderObj
                --// Si ya es favorito al momento de llamar LinkSlider, sincronizar
                if isFavorite then
                    syncFavoriteRow()
                end
            end

            --// Reducir área clickeable para no cubrir los botones (switch ya está bien posicionado)
            HolderClick.Size = UDim2.new(1, -176, 1, 0)
            HolderClick.ZIndex = 14
            
            --// ═════════════════════════════════════════════════════════════════════════
            --// PARTE 2: VENTANA FLOTANTE (RECONSTRUIDA)
            --// ═════════════════════════════════════════════════════════════════════════
            
            local FloatingWindow = nil
            local FloatingGlow = nil
            local animationConnection = nil
            
            local function createFloatingWindow()

                --// GLOW EXTERIOR - invisible, solo para sincronía de posición
                FloatingGlow = mk("Frame", {
                    Parent = Window.ScreenGui,
                    Size = UDim2.fromOffset(216, 48),
                    Position = UDim2.new(0.5, -108, 0.5, -24),
                    BackgroundColor3 = Theme.Accent,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ZIndex = 3
                })
                corner(FloatingGlow, 999)

                --// VENTANA PRINCIPAL — estilo glassy pill
                FloatingWindow = mk("Frame", {
                    Parent = Window.ScreenGui,
                    Size = UDim2.fromOffset(200, 36),
                    Position = UDim2.new(0.5, -100, 0.5, -18),
                    BackgroundColor3 = Theme.Secondary,
                    BackgroundTransparency = 0.30,
                    BorderSizePixel = 0,
                    ZIndex = 4
                })
                FloatingWindow:SetAttribute("ThemeRole", "Secondary")
                corner(FloatingWindow, 999)

                --// Degradado glassy: más claro al centro, bordes más grises
                mk("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0,   Color3.fromRGB(180, 185, 200)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(240, 243, 250)),
                        ColorSequenceKeypoint.new(1,   Color3.fromRGB(180, 185, 200)),
                    }),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0,   0.45),
                        NumberSequenceKeypoint.new(0.5, 0.15),
                        NumberSequenceKeypoint.new(1,   0.45),
                    }),
                    Rotation = 90,
                }, FloatingWindow)

                --// Borde animado — más grueso para que se note
                stroke(FloatingWindow, Theme.Accent, 2.5, 0.20)
                buildAnimatedBorder(FloatingWindow, Theme.Accent, UDim.new(1, 0), true)

                --// TEXTO CENTRADO
                local FloatLabel = mk("TextLabel", {
                    Parent = FloatingWindow,
                    Size = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text = displayText,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.GothamBlack,
                    TextSize = 21,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 5,
                })
                FloatLabel:SetAttribute("ThemeTextRole", "Text")
                FloatLabel:SetAttribute("TextSpanish", textSpanish)
                FloatLabel:SetAttribute("TextEnglish", textEnglish)

                --// Feedback visual de estado: usa colores del tema activo
                local function updateFloatVisual()
                    if state then
                        TweenService:Create(FloatingWindow, TweenInfo.new(0.15),
                            {BackgroundColor3 = Theme.ToggleOn}):Play()
                    else
                        TweenService:Create(FloatingWindow, TweenInfo.new(0.15),
                            {BackgroundColor3 = Theme.Secondary}):Play()
                    end
                end
                updateFloatVisual()

                --// ÁREA CLICKEABLE — toda la pill
                local FloatClick = mk("TextButton", {
                    Parent = FloatingWindow,
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    ZIndex = 6
                })

                FloatClick.MouseButton1Click:Connect(function()
                    if dragging then return end
                    state = not state
                    playSound(Sounds.Click, 0.5)
                    updateFloatVisual()
                    --// Sincronizar switch en pestaña via SetValue (no dispara cb)
                    tog.SetValue(state)
                    pcall(cb, state)
                end)

                --// SINCRONIZAR GLOW CON VENTANA
                local function syncGlow()
                    if FloatingGlow and FloatingGlow.Parent then
                        FloatingGlow.Size = UDim2.fromOffset(FloatingWindow.Size.X.Offset + 16, FloatingWindow.Size.Y.Offset + 12)
                        FloatingGlow.Position = UDim2.new(FloatingWindow.Position.X.Scale, FloatingWindow.Position.X.Offset - 8, FloatingWindow.Position.Y.Scale, FloatingWindow.Position.Y.Offset - 6)
                    end
                end
                syncGlow()
                track(FloatingWindow:GetPropertyChangedSignal("Position"):Connect(syncGlow))

                --// ═════════════════════════════════════════════════════════════════════
                --// DRAG — conectado a FloatClick para recibir input correctamente
                --// ═════════════════════════════════════════════════════════════════════

                local dragging = false
                local dragStart, startPos
                local dragMoved = false

                FloatClick.InputBegan:Connect(function(input)
                    if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not isLocked then
                        dragging = false
                        dragMoved = false
                        dragStart = input.Position
                        startPos = FloatingWindow.Position
                    end
                end)

                track(UserInputService.InputChanged:Connect(function(input)
                    if dragStart and not isLocked and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        local delta = input.Position - dragStart
                        if delta.Magnitude > 4 then
                            dragging = true
                            dragMoved = true
                            FloatingWindow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                        end
                    end
                end))

                track(UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        task.defer(function() dragging = false end)
                        dragStart = nil
                    end
                end))

                table.insert(Window.FloatingToggles, {Window = FloatingWindow, Name = displayText})
            end
            
            --// ═════════════════════════════════════════════════════════════════════════
            --// BOTÓN DESPRENDER EN PESTAÑA
            --// ═════════════════════════════════════════════════════════════════════════
            
            DetachBtn.MouseButton1Click:Connect(function()
                playSound(Sounds.Click, 0.6)
                if not isFloating then
                    isFloating = true
                    createFloatingWindow()
                    DetachBtn.Text = "←"
                else
                    isFloating = false
                    if animationConnection then
                        animationConnection:Disconnect()
                        animationConnection = nil
                    end
                    if FloatingWindow then
                        FloatingWindow:Destroy()
                        FloatingWindow = nil
                    end
                    if FloatingGlow then
                        FloatingGlow:Destroy()
                        FloatingGlow = nil
                    end
                    DetachBtn.Text = "↗"
                    isLocked = false
                    PinBtn.Image = "rbxassetid://83537941312438"  -- candado abierto al cerrar
                end
            end)
            
            --// Candado: toggle entre fijado (cerrado) y libre (abierto)
            PinBtn.MouseButton1Click:Connect(function()
                if not isFloating then return end
                playSound(Sounds.Click, 0.5)
                isLocked = not isLocked
                PinBtn.Image = isLocked
                    and "rbxassetid://91959170037380"   -- candado cerrado (fijado)
                    or  "rbxassetid://83537941312438"   -- candado abierto (libre)
            end)

            --// El click del switch en pestaña ya lo maneja CreateToggle internamente
            resetScrollTop(TabPage)
        end


        --// TOGGLE ESTÁNDAR — Premium Redesign
        function Tab:CreateToggle(textSpanish, textEnglishOrDefault, defaultOrCallback, callback)
            --// COMPATIBILIDAD: si el 2do argumento es string, es modo bilingüe.
            --// Si es boolean/nil, es la firma antigua: (text, default, callback)
            local textEnglish = textSpanish
            local default, cb

            if type(textEnglishOrDefault) == "string" then
                textEnglish = textEnglishOrDefault
                default = defaultOrCallback
                cb = callback
            else
                default = textEnglishOrDefault
                cb = defaultOrCallback
            end

            local displayText = GetText(textSpanish, textEnglish)
            local state = default or false

            --// ── CONTENEDOR PRINCIPAL ──────────────────────────────────────────────
            local Holder = mk("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 64),
                BackgroundColor3 = Theme.Secondary,
                BackgroundTransparency = 0.78,
                ZIndex = 9
            })
            Holder:SetAttribute("ThemeRole", "Secondary")
            corner(Holder, 10)
            stroke(Holder, Theme.Stroke, 1, 0.55)

            --// Línea de acento izquierda (barra vertical decorativa)
            local AccentBar = mk("Frame", {
                Parent = Holder,
                Size = UDim2.new(0, 3, 0, 36),
                Position = UDim2.new(0, 10, 0.5, -18),
                BackgroundColor3 = state and Theme.ToggleOn or Theme.AccentOff,
                BackgroundTransparency = 0,
                ZIndex = 10
            })
            AccentBar:SetAttribute("ThemeRole", state and "ToggleOn" or "AccentOff")
            corner(AccentBar, 999)

            --// ── TEXTO PRINCIPAL ───────────────────────────────────────────────────
            local LabelTxt = mk("TextLabel", {
                Parent = Holder,
                Size = UDim2.new(1, -90, 0, 22),
                Position = UDim2.new(0, 22, 0, 13),
                BackgroundTransparency = 1,
                Text = displayText,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBlack,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 10
            })
            LabelTxt:SetAttribute("ThemeTextRole", "Text")
            LabelTxt:SetAttribute("TextSpanish", textSpanish)
            LabelTxt:SetAttribute("TextEnglish", textEnglish)

            --// ── SUBTEXTO DE ESTADO ────────────────────────────────────────────────
            local StateLabel = mk("TextLabel", {
                Parent = Holder,
                Size = UDim2.new(1, -90, 0, 16),
                Position = UDim2.new(0, 22, 0, 36),
                BackgroundTransparency = 1,
                Text = state and GetText("Activado", "Enabled") or GetText("Desactivado", "Disabled"),
                TextColor3 = state and Theme.ToggleOn or Theme.TextDim,
                Font = Enum.Font.Gotham,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 10
            })
            StateLabel:SetAttribute("ThemeTextRole", state and "ToggleOn" or "TextDim")

            --// ── SWITCH TRACK (52×28) ──────────────────────────────────────────────
            local Switch = mk("Frame", {
                Parent = Holder,
                Size = UDim2.new(0, 52, 0, 28),
                Position = UDim2.new(1, -66, 0.5, -14),
                BackgroundColor3 = state and Theme.ToggleOn or Theme.AccentOff,
                ZIndex = 10
            })
            Switch:SetAttribute("ThemeRole", state and "ToggleOn" or "AccentOff")
            corner(Switch, 999)

            --// Sombra interior del track (profundidad)
            local TrackShadow = mk("Frame", {
                Parent = Switch,
                Size = UDim2.new(1, -2, 1, -2),
                Position = UDim2.new(0, 1, 0, 1),
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BackgroundTransparency = 0.82,
                ZIndex = 10
            })
            corner(TrackShadow, 999)

            --// ── KNOB SHADOW (debajo del knob, simula elevación) ──────────────────
            local KnobShadow = mk("Frame", {
                Parent = Switch,
                Size = UDim2.new(0, 24, 0, 24),
                Position = state and UDim2.new(1, -27, 0.5, -11) or UDim2.new(0, 3, 0.5, -11),
                BackgroundColor3 = Color3.fromRGB(0, 0, 0),
                BackgroundTransparency = 0.55,
                ZIndex = 11
            })
            corner(KnobShadow, 999)

            --// ── KNOB (24×24) ──────────────────────────────────────────────────────
            local Knob = mk("Frame", {
                Parent = Switch,
                Size = UDim2.new(0, 24, 0, 24),
                Position = state and UDim2.new(1, -26, 0.5, -12) or UDim2.new(0, 2, 0.5, -12),
                BackgroundColor3 = Color3.new(1, 1, 1),
                ZIndex = 12
            })
            corner(Knob, 999)

            --// ── ÁREA CLICKEABLE (cubre todo el Holder) ────────────────────────────
            local Click = mk("TextButton", {
                Parent = Holder,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 13
            })

            --// ── POSICIONES DE KNOB Y SHADOW ──────────────────────────────────────
            local knobOFF       = UDim2.new(0, 2,  0.5, -12)
            local knobON        = UDim2.new(1, -26, 0.5, -12)
            local shadowOFF     = UDim2.new(0, 3,  0.5, -11)
            local shadowON      = UDim2.new(1, -27, 0.5, -11)
            --// Tamaños para squish: se estira en la dirección del movimiento
            local knobNormal    = UDim2.new(0, 24, 0, 24)
            local knobSquishON  = UDim2.new(0, 30, 0, 22)  -- más ancho al activar
            local knobSquishOFF = UDim2.new(0, 30, 0, 22)  -- más ancho al desactivar

            --// ── FUNCIÓN CENTRAL DE ACTUALIZACIÓN VISUAL ──────────────────────────
            local function applyVisual(newState, animate)
                local t = animate and 0.18 or 0
                local ti = TweenInfo.new(t, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

                --// Colores de track y barra
                local trackColor = newState and Theme.ToggleOn or Theme.AccentOff
                local barColor   = newState and Theme.ToggleOn or Theme.AccentOff
                TweenService:Create(Switch,     ti, {BackgroundColor3 = trackColor}):Play()
                TweenService:Create(AccentBar,  ti, {BackgroundColor3 = barColor}):Play()
                Switch:SetAttribute("ThemeRole",    newState and "ToggleOn" or "AccentOff")
                AccentBar:SetAttribute("ThemeRole", newState and "ToggleOn" or "AccentOff")

                --// Subtexto
                local stateText  = newState and GetText("Activado", "Enabled") or GetText("Desactivado", "Disabled")
                local stateColor = newState and Theme.ToggleOn or Theme.TextDim
                StateLabel.Text = stateText
                TweenService:Create(StateLabel, ti, {TextColor3 = stateColor}):Play()
                StateLabel:SetAttribute("ThemeTextRole", newState and "ToggleOn" or "TextDim")

                if animate then
                    --// Squish: estirar knob en dirección del movimiento
                    local squishSize = newState and knobSquishON or knobSquishOFF
                    TweenService:Create(Knob,       TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                        {Size = squishSize}):Play()
                    task.delay(0.08, function()
                        --// Knob y shadow a posición final + tamaño normal
                        TweenService:Create(Knob,       ti, {Size = knobNormal,
                            Position = newState and knobON or knobOFF}):Play()
                        TweenService:Create(KnobShadow, ti, {Position = newState and shadowON or shadowOFF}):Play()
                    end)
                else
                    Knob.Size     = knobNormal
                    Knob.Position = newState and knobON or knobOFF
                    KnobShadow.Position = newState and shadowON or shadowOFF
                end
            end

            --// ── HOVER EFFECT ──────────────────────────────────────────────────────
            Click.MouseEnter:Connect(function()
                TweenService:Create(Holder,
                    TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundTransparency = 0.62}):Play()
            end)
            Click.MouseLeave:Connect(function()
                TweenService:Create(Holder,
                    TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundTransparency = 0.78}):Play()
            end)

            --// ── CLICK ─────────────────────────────────────────────────────────────
            Click.MouseButton1Click:Connect(function()
                state = not state
                playSound(Sounds.Click, 0.5)
                applyVisual(state, true)
                pcall(cb, state)
            end)

            resetScrollTop(TabPage)

            --// ── CONTROLADOR PÚBLICO ───────────────────────────────────────────────
            return {
                SetValue = function(value)
                    state = value
                    playSound(Sounds.Click, 0.3)
                    applyVisual(state, true)
                    --// NO dispara el callback, solo cambia visualmente
                end,
                GetValue = function()
                    return state
                end,
                --// Referencias directas (evita búsquedas frágiles por tamaño/orden)
                Holder = Holder,
                Switch = Switch,
                Click = Click
            }
        end

        --//  FLOATING TOGGLE SIMPLE (CÁPSULA ELEGANTE)
        function Tab:CreateFloatingToggleSimple(text, default, callback)
            local state = default or false
            local TweenService = game:GetService("TweenService")
            
            --// CREAR FRAME PRINCIPAL (Cápsula)
            local FloatingWindow = mk("Frame", {
                Name = "FloatingToggleSimple_" .. text,
                Size = UDim2.new(0, 220, 0, 50),
                Position = UDim2.new(0.5, -110, 0.1, 0),
                BackgroundColor3 = Theme.Secondary,
                BackgroundTransparency = 0.3,
                BorderSizePixel = 0,
                ZIndex = 150,
                CanQuery = true
            }, Window.ScreenGui)
            
            --// ESQUINAS REDONDEADAS
            corner(FloatingWindow, 999)
            
            --// BORDE
            stroke(FloatingWindow, Theme.Accent, 2, 0.5)
            buildAnimatedBorder(FloatingWindow, Theme.Accent, UDim.new(1, 0), true)
            
            --// FRAME CONTENEDOR PARA TEXTOS
            local TextContainer = mk("Frame", {
                Size = UDim2.new(1, -10, 1, 0),
                Position = UDim2.new(0, 5, 0, 0),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ZIndex = 151
            }, FloatingWindow)
            
            --// TEXTO DEL NOMBRE (Izquierda)
            local NameLabel = mk("TextLabel", {
                Size = UDim2.new(0.6, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Center,
                ZIndex = 151
            }, TextContainer)
            NameLabel:SetAttribute("ThemeTextRole", "Text")
            
            --// TEXTO DEL ESTADO (Derecha)
            local StateLabel = mk("TextLabel", {
                Size = UDim2.new(0.35, 0, 1, 0),
                Position = UDim2.new(0.65, 0, 0, 0),
                BackgroundTransparency = 1,
                Text = state and "ON" or "OFF",
                TextColor3 = state and Color3.fromRGB(76, 175, 80) or Color3.fromRGB(155, 155, 155),
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Right,
                TextYAlignment = Enum.TextYAlignment.Center,
                ZIndex = 151
            }, TextContainer)
            
            --// EFECTO SHIMMER (UIGradient)
            local shimmerGradient = Instance.new("UIGradient")
            shimmerGradient.Rotation = 90
            shimmerGradient.ColorSequence = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255), 0.9),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255), 0),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255), 0.9)
            })
            shimmerGradient.Parent = FloatingWindow
            
            --// ANIMAR SHIMMER
            local shimmerTween = TweenService:Create(
                shimmerGradient,
                TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0),
                {Offset = Vector2.new(1, 0)}
            )
            shimmerTween:Play()
            track(shimmerTween)
            
            --// EFECTO BREATHING (Pulsación)
            local originalSize = FloatingWindow.Size
            local pulseSize = UDim2.new(0, 230, 0, 55)
            
            local pulseTween = TweenService:Create(
                FloatingWindow,
                TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true, 0),
                {Size = pulseSize}
            )
            pulseTween:Play()
            track(pulseTween)
            
            --// DETECTOR DE CLICKS
            local ClickDetector = mk("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 152
            }, FloatingWindow)
            
            --// VARIABLES DE INTERACCIÓN
            local isDragging = false
            local dragStart = nil
            local dragStartPos = nil
            local isHovering = false
            
            --// FUNCIÓN PARA ACTUALIZAR ESTADO
            local function updateState()
                if state then
                    StateLabel.Text = "ON"
                    StateLabel.TextColor3 = Color3.fromRGB(76, 175, 80)
                else
                    StateLabel.Text = "OFF"
                    StateLabel.TextColor3 = Color3.fromRGB(155, 155, 155)
                end
            end
            
            --// HOVER EFFECT
            track(FloatingWindow.MouseEnter:Connect(function()
                isHovering = true
                TweenService:Create(
                    FloatingWindow,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundTransparency = 0.15}
                ):Play()
            end))
            
            track(FloatingWindow.MouseLeave:Connect(function()
                isHovering = false
                TweenService:Create(
                    FloatingWindow,
                    TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundTransparency = 0.3}
                ):Play()
            end))
            
            --// CLICK EFFECT Y TOGGLE
            track(ClickDetector.MouseButton1Click:Connect(function()
                state = not state
                updateState()
                
                --// SONIDO
                pcall(function() playSound(Sounds.Click, 0.6) end)
                
                --// EFECTO VISUAL DE PRESIÓN
                local pressSize = UDim2.new(0, 210, 0, 45)
                TweenService:Create(
                    FloatingWindow,
                    TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                    {Size = pressSize, BackgroundTransparency = 0.5}
                ):Play()
                
                task.wait(0.08)
                
                --// VOLVER AL TAMAÑO NORMAL
                TweenService:Create(
                    FloatingWindow,
                    TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Size = originalSize, BackgroundTransparency = isHovering and 0.15 or 0.3}
                ):Play()
                
                --// EJECUTAR CALLBACK
                if callback then
                    pcall(function() callback(state) end)
                end
                
                print("[" .. text .. "] " .. (state and " ACTIVADO" or " DESACTIVADO"))
            end))
            
            --// DRAG AND DROP
            track(FloatingWindow.InputBegan:Connect(function(input)
                if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and isHovering then
                    isDragging = true
                    dragStart = input.Position
                    dragStartPos = FloatingWindow.Position
                end
            end))
            
            track(UserInputService.InputChanged:Connect(function(input)
                if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local delta = input.Position - dragStart
                    FloatingWindow.Position = UDim2.new(
                        dragStartPos.X.Scale,
                        dragStartPos.X.Offset + delta.X,
                        dragStartPos.Y.Scale,
                        dragStartPos.Y.Offset + delta.Y
                    )
                end
            end))
            
            track(UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = false
                end
            end))
            
            table.insert(Window.FloatingToggles, {Window = FloatingWindow, Name = text})

            return FloatingWindow
        end

        --// ══════════════════════════════════════════════════════════════════════════
        --// FLOATING BUTTON — Pill flotante de un disparo (sin estado ON/OFF)
        --// ══════════════════════════════════════════════════════════════════════════
        --// Firmas soportadas:
        --//   Tab:CreateFloatingButton("Texto", callback)
        --//   Tab:CreateFloatingButton("Texto", cooldownSegundos, callback)
        --//   Tab:CreateFloatingButton("TextoES", "TextoEN", callback)
        --//   Tab:CreateFloatingButton("TextoES", "TextoEN", cooldownSegundos, callback)
        --// El cooldown (segundos) es opcional. Si es 0 o nil, el botón es inmediato.
        function Tab:CreateFloatingButton(textSpanish, textEnglishOrCooldown, cooldownOrCallback, callback, isMirror)
            local textEnglish = textSpanish
            local cooldown, cb

            if type(textEnglishOrCooldown) == "string" then
                -- Modo bilingüe: (es, en, cooldown?, callback)
                textEnglish = textEnglishOrCooldown
                if type(cooldownOrCallback) == "number" then
                    cooldown = cooldownOrCallback
                    cb = callback
                else
                    cooldown = 0
                    cb = cooldownOrCallback
                end
            elseif type(textEnglishOrCooldown) == "number" then
                -- (text, cooldown, callback)
                cooldown = textEnglishOrCooldown
                cb = cooldownOrCallback
            else
                -- (text, callback)
                cooldown = 0
                cb = textEnglishOrCooldown
            end
            cooldown = cooldown or 0

            local displayText = GetText(textSpanish, textEnglish)
            local isFloating  = false
            local isLocked    = false
            local onCooldown  = false

            --// Referencias compartidas entre fila y pill (el cooldown las actualiza a ambas)
            local FloatingWindow = nil
            local FloatingGlow   = nil
            local FloatLabel     = nil
            local AccentBar      = nil
            local StateLabel     = nil

            --// ── COOLDOWN COMPARTIDO ──────────────────────────────────────────────────
            --// Un solo task actualiza tanto el subtexto del row como el label de la pill.
            local function startCooldown()
                if cooldown <= 0 then return end
                onCooldown = true
                AccentBar.BackgroundColor3 = Theme.TextDim
                task.spawn(function()
                    local remaining = cooldown
                    while remaining > 0 do
                        task.wait(0.1)
                        remaining = math.max(0, remaining - 0.1)
                        local cdTxt = string.format("%.1fs", remaining)
                        StateLabel.Text = cdTxt
                        if FloatLabel and FloatLabel.Parent then
                            FloatLabel.Text      = cdTxt
                            FloatLabel.TextColor3 = Theme.TextDim
                        end
                    end
                    onCooldown = false
                    AccentBar.BackgroundColor3 = Theme.Accent
                    StateLabel.Text = GetText("Botón", "Button")
                    if FloatLabel and FloatLabel.Parent then
                        FloatLabel.Text = displayText
                        TweenService:Create(FloatLabel, TweenInfo.new(0.20), {TextColor3 = Theme.Text}):Play()
                    end
                end)
            end

            --// ── FILA EN PESTAÑA ──────────────────────────────────────────────────────
            local Holder = mk("Frame", {
                Parent = TabPage,
                Size   = UDim2.new(1, 0, 0, 64),
                BackgroundColor3 = Theme.Secondary,
                BackgroundTransparency = 0.78,
                ZIndex = 9
            })
            Holder:SetAttribute("ThemeRole", "Secondary")
            corner(Holder, 10)
            stroke(Holder, Theme.Stroke, 1, 0.55)

            --// Barra lateral (Accent = es un botón, no un toggle)
            AccentBar = mk("Frame", {
                Parent   = Holder,
                Size     = UDim2.new(0, 3, 0, 36),
                Position = UDim2.new(0, 10, 0.5, -18),
                BackgroundColor3 = Theme.Accent,
                ZIndex   = 10
            })
            AccentBar:SetAttribute("ThemeRole", "Accent")
            corner(AccentBar, 999)

            --// Nombre
            local LabelTxt = mk("TextLabel", {
                Parent   = Holder,
                Size     = UDim2.new(1, -90, 0, 22),
                Position = UDim2.new(0, 22, 0, 13),
                BackgroundTransparency = 1,
                Text     = displayText,
                TextColor3 = Theme.Text,
                Font     = Enum.Font.GothamBlack,
                TextSize = 15,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextTruncate   = Enum.TextTruncate.AtEnd,
                ZIndex   = 10
            })
            LabelTxt:SetAttribute("ThemeTextRole", "Text")
            LabelTxt:SetAttribute("TextSpanish",  textSpanish)
            LabelTxt:SetAttribute("TextEnglish",  textEnglish)

            --// Subtexto: muestra "Botón" o el countdown del cooldown
            StateLabel = mk("TextLabel", {
                Parent   = Holder,
                Size     = UDim2.new(1, -90, 0, 16),
                Position = UDim2.new(0, 22, 0, 36),
                BackgroundTransparency = 1,
                Text     = GetText("Botón", "Button"),
                TextColor3 = Theme.TextDim,
                Font     = Enum.Font.Gotham,
                TextSize = 11,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex   = 10
            })
            StateLabel:SetAttribute("ThemeTextRole", "TextDim")

            --// Botón Desprender ↗
            local DetachBtn = mk("TextButton", {
                Parent   = Holder,
                Size     = UDim2.new(0, 26, 0, 26),
                Position = UDim2.new(1, -66, 0.5, -13),
                BackgroundColor3 = Theme.Accent,
                Text     = "↗",
                TextColor3 = Color3.fromRGB(0, 0, 0),
                Font     = Enum.Font.GothamBold,
                TextSize = 13,
                ZIndex   = 15
            })
            corner(DetachBtn, 6)

            --// Candado (igual que en FloatingToggle)
            local PinBtn = mk("ImageButton", {
                Parent   = Holder,
                Size     = UDim2.new(0, 26, 0, 26),
                Position = UDim2.new(1, -36, 0.5, -13),
                BackgroundColor3 = Theme.Secondary,
                Image    = "rbxassetid://83537941312438",
                ImageColor3 = Theme.Text,
                ScaleType   = Enum.ScaleType.Stretch,
                ZIndex   = 15
            })
            corner(PinBtn, 6)
            stroke(PinBtn, Theme.Stroke, 1, 0.5)

            --// Botón Favorito — estrella, agrega/saca este botón de la pestaña Favoritos (persiste)
            --// ⚠️ Solo en filas normales: una fila espejo (isMirror) NO debe tener su propia
            --// estrella, o favoritear el espejo generaría otro espejo dentro de Favo (recursión infinita).
            if not isMirror then
                local favId = nameSpanish .. "::" .. textSpanish
                local isFavorite = SavedFavoriteIds[favId] or false
                local FavBtn = mk("ImageButton", {
                    Parent = Holder,
                    Size = UDim2.new(0, 32, 0, 32),
                    Position = UDim2.new(1, -102, 0.5, -16),
                    BackgroundTransparency = 1,
                    Image = isFavorite and "rbxassetid://113655648685815" or "rbxassetid://90877976276431",
                    ScaleType = Enum.ScaleType.Fit,
                    ZIndex = 15
                })

                local favRow = nil
                local function syncFavoriteRow()
                    if favRow then
                        pcall(function() favRow.Holder:Destroy() end)
                        favRow = nil
                    end
                    if isFavorite and AutoTabFavoritosRef then
                        favRow = AutoTabFavoritosRef:CreateFloatingButton(textSpanish, textEnglish, cooldown, cb, true)
                    end
                end
                syncFavoriteRow()

                FavBtn.MouseButton1Click:Connect(function()
                    playSound(Sounds.Click, 0.5)
                    isFavorite = not isFavorite
                    FavBtn.Image = isFavorite and "rbxassetid://113655648685815" or "rbxassetid://90877976276431"
                    SavedFavoriteIds[favId] = isFavorite or nil
                    syncFavoriteRow()
                    SyncFavoritesToConfig()
                end)
            end

            --// Área clickeable del row (evita cubrir los botones de control)
            local HolderClick = mk("TextButton", {
                Parent   = Holder,
                Size     = UDim2.new(1, isMirror and -100 or -120, 1, 0),
                BackgroundTransparency = 1,
                Text     = "",
                ZIndex   = 13
            })

            HolderClick.MouseEnter:Connect(function()
                TweenService:Create(Holder, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundTransparency = 0.62}):Play()
            end)
            HolderClick.MouseLeave:Connect(function()
                TweenService:Create(Holder, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundTransparency = 0.78}):Play()
            end)

            HolderClick.MouseButton1Click:Connect(function()
                if onCooldown then return end
                playSound(Sounds.Click, 0.5)
                pcall(cb)
                startCooldown()
            end)

            --// ── PILL FLOTANTE ────────────────────────────────────────────────────────
            local function createFloatingWindow()
                --// Glow exterior
                FloatingGlow = mk("Frame", {
                    Parent   = Window.ScreenGui,
                    Size     = UDim2.fromOffset(216, 48),
                    Position = UDim2.new(0.5, -108, 0.5, -24),
                    BackgroundColor3 = Theme.Accent,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ZIndex  = 3
                })
                corner(FloatingGlow, 999)

                --// Pill principal
                FloatingWindow = mk("Frame", {
                    Parent   = Window.ScreenGui,
                    Size     = UDim2.fromOffset(200, 36),
                    Position = UDim2.new(0.5, -100, 0.5, -18),
                    BackgroundColor3 = Theme.Secondary,
                    BackgroundTransparency = 0.30,
                    BorderSizePixel = 0,
                    ZIndex  = 4
                })
                FloatingWindow:SetAttribute("ThemeRole", "Secondary")
                corner(FloatingWindow, 999)

                --// Degradado glassy (igual que FloatingToggle)
                mk("UIGradient", {
                    Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0,   Color3.fromRGB(180, 185, 200)),
                        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(240, 243, 250)),
                        ColorSequenceKeypoint.new(1,   Color3.fromRGB(180, 185, 200)),
                    }),
                    Transparency = NumberSequence.new({
                        NumberSequenceKeypoint.new(0,   0.45),
                        NumberSequenceKeypoint.new(0.5, 0.15),
                        NumberSequenceKeypoint.new(1,   0.45),
                    }),
                    Rotation = 90,
                }, FloatingWindow)

                stroke(FloatingWindow, Theme.Accent, 2.5, 0.20)
                buildAnimatedBorder(FloatingWindow, Theme.Accent, UDim.new(1, 0), true)

                --// Label (guardado en upvalue para que startCooldown lo pueda actualizar)
                FloatLabel = mk("TextLabel", {
                    Parent   = FloatingWindow,
                    Name     = "FloatLabel",
                    Size     = UDim2.new(1, -24, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    --// Si ya hay cooldown activo al abrir, muestra el tiempo restante
                    Text     = onCooldown and StateLabel.Text or displayText,
                    TextColor3 = onCooldown and Theme.TextDim or Theme.Text,
                    Font     = Enum.Font.GothamBlack,
                    TextSize = 21,
                    TextXAlignment = Enum.TextXAlignment.Center,
                    TextYAlignment = Enum.TextYAlignment.Center,
                    TextTruncate   = Enum.TextTruncate.AtEnd,
                    ZIndex   = 5,
                })
                FloatLabel:SetAttribute("ThemeTextRole", "Text")
                FloatLabel:SetAttribute("TextSpanish",  textSpanish)
                FloatLabel:SetAttribute("TextEnglish",  textEnglish)

                --// Flash visual al presionar (breve destello sin estado persistente)
                local function flashBtn()
                    TweenService:Create(FloatingWindow, TweenInfo.new(0.08),
                        {BackgroundColor3 = Theme.Accent, BackgroundTransparency = 0.10}):Play()
                    task.delay(0.22, function()
                        if FloatingWindow and FloatingWindow.Parent then
                            TweenService:Create(FloatingWindow, TweenInfo.new(0.20),
                                {BackgroundColor3 = Theme.Secondary, BackgroundTransparency = 0.30}):Play()
                        end
                    end)
                end

                --// dragging se declara antes del FloatClick para que todos los closures
                --// compartan el mismo upvalue (sin forward-reference)
                local dragging  = false
                local dragStart = nil
                local startPos  = nil

                --// Área clickeable
                local FloatClick = mk("TextButton", {
                    Parent   = FloatingWindow,
                    Size     = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text     = "",
                    ZIndex   = 6
                })

                FloatClick.MouseButton1Click:Connect(function()
                    if dragging or onCooldown then return end
                    playSound(Sounds.Click, 0.5)
                    flashBtn()
                    pcall(cb)
                    startCooldown()
                end)

                --// Sincronizar glow
                local function syncGlow()
                    if FloatingGlow and FloatingGlow.Parent then
                        FloatingGlow.Size = UDim2.fromOffset(
                            FloatingWindow.Size.X.Offset + 16,
                            FloatingWindow.Size.Y.Offset + 12)
                        FloatingGlow.Position = UDim2.new(
                            FloatingWindow.Position.X.Scale,
                            FloatingWindow.Position.X.Offset - 8,
                            FloatingWindow.Position.Y.Scale,
                            FloatingWindow.Position.Y.Offset - 6)
                    end
                end
                syncGlow()
                track(FloatingWindow:GetPropertyChangedSignal("Position"):Connect(syncGlow))

                --// Drag
                FloatClick.InputBegan:Connect(function(input)
                    if (input.UserInputType == Enum.UserInputType.MouseButton1
                    or  input.UserInputType == Enum.UserInputType.Touch)
                    and not isLocked then
                        dragging  = false
                        dragStart = input.Position
                        startPos  = FloatingWindow.Position
                    end
                end)

                track(UserInputService.InputChanged:Connect(function(input)
                    if dragStart and not isLocked
                    and (input.UserInputType == Enum.UserInputType.MouseMovement
                    or   input.UserInputType == Enum.UserInputType.Touch) then
                        local delta = input.Position - dragStart
                        if delta.Magnitude > 4 then
                            dragging = true
                            FloatingWindow.Position = UDim2.new(
                                startPos.X.Scale, startPos.X.Offset + delta.X,
                                startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                        end
                    end
                end))

                track(UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1
                    or input.UserInputType == Enum.UserInputType.Touch then
                        task.defer(function() dragging = false end)
                        dragStart = nil
                    end
                end))

                table.insert(Window.FloatingToggles, {Window = FloatingWindow, Name = displayText})
            end

            --// ── DESPRENDER ───────────────────────────────────────────────────────────
            DetachBtn.MouseButton1Click:Connect(function()
                playSound(Sounds.Click, 0.6)
                if not isFloating then
                    isFloating = true
                    createFloatingWindow()
                    DetachBtn.Text = "←"
                else
                    isFloating   = false
                    FloatLabel   = nil
                    if FloatingWindow then FloatingWindow:Destroy(); FloatingWindow = nil end
                    if FloatingGlow   then FloatingGlow:Destroy();   FloatingGlow   = nil end
                    DetachBtn.Text = "↗"
                    isLocked   = false
                    PinBtn.Image = "rbxassetid://83537941312438"
                end
            end)

            --// ── CANDADO ──────────────────────────────────────────────────────────────
            PinBtn.MouseButton1Click:Connect(function()
                if not isFloating then return end
                playSound(Sounds.Click, 0.5)
                isLocked = not isLocked
                PinBtn.Image = isLocked
                    and "rbxassetid://91959170037380"
                    or  "rbxassetid://83537941312438"
            end)

            resetScrollTop(TabPage)

            --// API pública del botón
            return {
                Holder = Holder,
                --// Dispara el botón desde código (respeta el cooldown activo)
                Fire = function()
                    if not onCooldown then
                        pcall(cb)
                        startCooldown()
                    end
                end,
                --// Cambia el cooldown en caliente (no afecta un cooldown ya en curso)
                SetCooldown = function(secs)
                    cooldown = secs or cooldown
                end,
            }
        end

        --// 🎚️ SLIDER PREMIUM v2.0 (OTRO NIVEL - Zero Lag + GV2 Glow + Rango Visible)
        function Tab:CreateSlider(text, min, max, default, callback, isMirror)
            local value = default or min
            local isDragging = false
            local lastUpdateTime = 0
            local UPDATE_THROTTLE = 0.008  -- 120fps smoothness
            
            --// CONTAINER PRINCIPAL
            local Holder = mk("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 72),
                BackgroundColor3 = Theme.Secondary,
                BackgroundTransparency = 0.5,
                ZIndex = 9
            })
            Holder:SetAttribute("ThemeRole", "Secondary")
            Holder:SetAttribute("IsSliderHolder", true)
            corner(Holder, 12)
            stroke(Holder, Theme.Stroke, 1.5, 0.6)
            buildAnimatedBorder(Holder, Theme.Accent, UDim.new(0, 12), true)
            Holder.Visible = not SlidersHidden

            --// LABEL PRINCIPAL
            local LabelTxt = mk("TextLabel", {
                Parent = Holder,
                Size = UDim2.new(0, 200, 0, 22),
                Position = UDim2.new(0, 16, 0, 10),
                BackgroundTransparency = 1,
                Text = text,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 10
            })
            LabelTxt:SetAttribute("ThemeRole", "Text")

            --// VALUE LABEL (Dinámico a la derecha)
            local ValueLabel = mk("TextLabel", {
                Parent = Holder,
                Size = UDim2.new(0, 70, 0, 22),
                Position = UDim2.new(1, -120, 0, 10),
                BackgroundTransparency = 1,
                Text = tostring(math.floor(value * 100) / 100),
                TextColor3 = Theme.Accent,
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 11
            })
            ValueLabel:SetAttribute("ThemeRole", "Accent")

            --// RANGO MÍNIMO (Abajo a la izquierda)
            local MinLabel = mk("TextLabel", {
                Parent = Holder,
                Size = UDim2.new(0, 50, 0, 16),
                Position = UDim2.new(0, 16, 0, 52),
                BackgroundTransparency = 1,
                Text = tostring(min),
                TextColor3 = Theme.AccentOff,
                Font = Enum.Font.Gotham,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 10
            })
            MinLabel:SetAttribute("ThemeRole", "AccentOff")

            --// RANGO MÁXIMO (Abajo a la derecha)
            local MaxLabel = mk("TextLabel", {
                Parent = Holder,
                Size = UDim2.new(0, 50, 0, 16),
                Position = UDim2.new(1, -66, 0, 52),
                BackgroundTransparency = 1,
                Text = tostring(max),
                TextColor3 = Theme.AccentOff,
                Font = Enum.Font.Gotham,
                TextSize = 10,
                TextXAlignment = Enum.TextXAlignment.Right,
                ZIndex = 10
            })
            MaxLabel:SetAttribute("ThemeRole", "AccentOff")

            --// SLIDER BACKGROUND (Barra de fondo)
            local SliderBackground = mk("Frame", {
                Parent = Holder,
                Size = UDim2.new(1, -32, 0, 5),
                Position = UDim2.new(0, 16, 0, 44),
                BackgroundColor3 = Theme.AccentOff,
                BorderSizePixel = 0,
                ZIndex = 10
            })
            SliderBackground:SetAttribute("ThemeRole", "AccentOff")
            corner(SliderBackground, 2)

            --// SLIDER FILL (La barra que se llena)
            local SliderFill = mk("Frame", {
                Parent = SliderBackground,
                Size = UDim2.new(0, 0, 1, 0),
                Position = UDim2.new(0, 0, 0, 0),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                ZIndex = 11
            })
            SliderFill:SetAttribute("ThemeRole", "Accent")
            corner(SliderFill, 2)

            --// SLIDER THUMB PRINCIPAL (El círculo/rectángulo que arrastramos)
            local SliderThumb = mk("Frame", {
                Parent = Holder,
                Size = UDim2.new(0, 14, 0, 22),
                Position = UDim2.new(0, 16, 0, 37),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0,
                ZIndex = 13
            })
            SliderThumb:SetAttribute("ThemeRole", "Accent")
            corner(SliderThumb, 8)

            --// GLOW EFFECT (sin asset externo)
            local ThumbGlow = mk("Frame", {
                Parent = SliderThumb,
                Size = UDim2.new(1, 6, 1, 6),
                Position = UDim2.new(0, -3, 0, -3),
                BackgroundColor3 = Theme.Accent,
                BackgroundTransparency = 0.7,
                BorderSizePixel = 0,
                ZIndex = 12
            })
            ThumbGlow:SetAttribute("ThemeRole", "Accent")
            corner(ThumbGlow, 10)

            --// BORDE ELEGANTE DEL THUMB
            stroke(SliderThumb, Theme.Stroke, 1, 0.7)

            --// FUNCIÓN: Actualizar slider (OPTIMIZADA)
            local function UpdateSlider(percentage)
                percentage = math.clamp(percentage, 0, 1)
                value = min + (max - min) * percentage
                
                --// Animar el fill suavemente
                local barWidth = SliderBackground.AbsoluteSize.X
                local targetSize = UDim2.new(percentage, 0, 1, 0)
                TweenService:Create(SliderFill, TweenInfo.new(0.05), {Size = targetSize}):Play()
                
                --// Posición del thumb (SUAVE con Tween)
                local thumbTargetX = 16 + (barWidth) * percentage - 7
                local tweenThumb = TweenService:Create(
                    SliderThumb, 
                    TweenInfo.new(0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {Position = UDim2.new(0, thumbTargetX, 0, 37)}
                )
                tweenThumb:Play()

                --// GLOW PULSE cuando se mueve
                local tweenGlow = TweenService:Create(
                    ThumbGlow,
                    TweenInfo.new(0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                    {BackgroundTransparency = 0.4}
                )
                tweenGlow:Play()
                
                --// Actualizar valor en label (sin delays)
                ValueLabel.Text = tostring(math.floor(value * 100) / 100)
                
                --// Callback sin lag
                task.spawn(function()
                    pcall(callback, value)
                end)
            end

            --// FUNCIÓN: Manejar clicks del slider
            local function OnSliderClick(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    isDragging = true
                    
                    --// EFECTO: El thumb se agranda ligeramente cuando lo agarras
                    TweenService:Create(
                        SliderThumb,
                        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {Size = UDim2.new(0, 16, 0, 26)}
                    ):Play()
                end
            end

            --// FUNCIÓN: Manejar soltar el slider
            local function OnSliderRelease(input)
                if isDragging and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
                    isDragging = false
                    
                    --// EFECTO: El thumb vuelve a su tamaño normal
                    TweenService:Create(
                        SliderThumb,
                        TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        {Size = UDim2.new(0, 14, 0, 22)}
                    ):Play()
                    
                    --// SONIDO al soltar
                    playSound(Sounds.Click, 0.5)
                    
                    --// GLOW vuelve a transparency normal
                    TweenService:Create(
                        ThumbGlow,
                        TweenInfo.new(0.3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut),
                        {BackgroundTransparency = 0.7}
                    ):Play()
                end
            end

            --// CONECTAR EVENTOS DE CLICK
            SliderBackground.InputBegan:Connect(OnSliderClick)
            SliderThumb.InputBegan:Connect(OnSliderClick)

            --// INPUT MOVEMENT (OPTIMIZADO - Sin tartamudeos) 🚀
            track(UserInputService.InputChanged:Connect(function(input)
                if isDragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    local currentTime = tick()
                    
                    --// THROTTLE: Solo actualizar cada 8ms (120fps max)
                    if currentTime - lastUpdateTime >= UPDATE_THROTTLE then
                        lastUpdateTime = currentTime
                        
                        local relativeX = input.Position.X - SliderBackground.AbsolutePosition.X
                        local barWidth = SliderBackground.AbsoluteSize.X
                        local percentage = math.clamp(relativeX / barWidth, 0, 1)
                        
                        UpdateSlider(percentage)
                    end
                end
            end))

            --// SOLTAR SLIDER - GLOBAL para celular (evita que se quede pegado)
            track(UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    OnSliderRelease(input)
                end
            end))

            --// ACTUALIZAR INICIAL
            UpdateSlider((value - min) / (max - min))
            resetScrollTop(TabPage)

            --// Botón Favorito — estrella, agrega/saca este slider de la pestaña Favoritos (persiste)
            --// ⚠️ Solo en filas normales: una fila espejo (isMirror) NO debe tener su propia
            --// estrella, o favoritear el espejo generaría otro espejo dentro de Favo (recursión infinita).
            if not isMirror then
                local favId = nameSpanish .. "::" .. text
                local isFavorite = SavedFavoriteIds[favId] or false
                local FavBtn = mk("ImageButton", {
                    Parent = Holder,
                    Size = UDim2.new(0, 22, 0, 22),
                    Position = UDim2.new(1, -30, 0, 8),
                    BackgroundTransparency = 1,
                    Image = isFavorite and "rbxassetid://113655648685815" or "rbxassetid://90877976276431",
                    ScaleType = Enum.ScaleType.Fit,
                    ZIndex = 15
                })

                local favRow = nil
                local function syncFavoriteRow()
                    if favRow then
                        pcall(function() favRow.Holder:Destroy() end)
                        favRow = nil
                    end
                    if isFavorite and AutoTabFavoritosRef then
                        favRow = AutoTabFavoritosRef:CreateSlider(text, min, max, value, function(newVal)
                            value = newVal
                            UpdateSlider((value - min) / (max - min))
                            pcall(callback, newVal)
                        end, true)
                    end
                end
                syncFavoriteRow()

                FavBtn.MouseButton1Click:Connect(function()
                    playSound(Sounds.Click, 0.5)
                    isFavorite = not isFavorite
                    FavBtn.Image = isFavorite and "rbxassetid://113655648685815" or "rbxassetid://90877976276431"
                    SavedFavoriteIds[favId] = isFavorite or nil
                    syncFavoriteRow()
                    SyncFavoritesToConfig()
                end)
            end

            --// RETORNAR TABLA CON MÉTODOS
            return {
                Holder = Holder,
                Set = function(newValue)
                    value = math.clamp(newValue, min, max)
                    UpdateSlider((value - min) / (max - min))
                end,
                Get = function()
                    return value
                end,
                SetMin = function(newMin)
                    min = newMin
                    MinLabel.Text = tostring(min)
                end,
                SetMax = function(newMax)
                    max = newMax
                    MaxLabel.Text = tostring(max)
                end,
                --// Referencias para LinkSlider
                _labelES   = text,
                _labelEN   = text,
                _min       = min,
                _max       = max,
                _value     = value,
                _callback  = callback,
            }
        end

        --// BOTÓN ESTÁNDAR CON EFECTO LIQUID 🌊 (v28 - PRIMERA LIBRERÍA DE EXPLOIT)
        function Tab:CreateButton(textSpanish, textEnglishOrCallback, callbackOrIcon, iconAsset)
            --// COMPATIBILIDAD: si el 2do argumento es string, es modo bilingüe.
            --// Si es function (o nil), es la firma antigua: (text, callback, iconAsset)
            local textEnglish = textSpanish
            local callback, icon

            if type(textEnglishOrCallback) == "string" then
                textEnglish = textEnglishOrCallback
                callback = callbackOrIcon
                icon = iconAsset
            else
                callback = textEnglishOrCallback
                icon = callbackOrIcon
            end

            local displayText = GetText(textSpanish, textEnglish)
            local iconAsset = icon

            --// WRAPPER: necesitamos ClipsDescendants para que la onda no se desborde
            local BtnWrapper = mk("Frame", {
                Size = UDim2.new(1, 0, 0, 36),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ClipsDescendants = true,
                ZIndex = 9
            }, TabPage)
            corner(BtnWrapper, 6)

            local Btn = mk("TextButton", {
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundColor3 = Theme.Secondary,
                Text = iconAsset and "" or displayText,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 9
            }, BtnWrapper)
            Btn:SetAttribute("ThemeRole", "Secondary")
            corner(Btn, 6)
            stroke(BtnWrapper, Theme.Stroke, 1, 0.6)
            resetScrollTop(TabPage)

            if iconAsset then
                mk("ImageLabel", {
                    Parent = Btn,
                    Size = UDim2.new(0, 20, 0, 20),
                    Position = UDim2.new(0, 8, 0.5, -10),
                    BackgroundTransparency = 1,
                    Image = iconAsset,
                    ZIndex = 10
                })
                local BtnLabel = mk("TextLabel", {
                    Parent = Btn,
                    Size = UDim2.new(1, -40, 1, 0),
                    Position = UDim2.new(0, 32, 0, 0),
                    BackgroundTransparency = 1,
                    Text = displayText,
                    TextColor3 = Theme.Text,
                    Font = Enum.Font.GothamBold,
                    TextSize = 14,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 10
                })
                BtnLabel:SetAttribute("ThemeTextRole", "Text")
                BtnLabel:SetAttribute("TextSpanish", textSpanish)
                BtnLabel:SetAttribute("TextEnglish", textEnglish)
            else
                --// Sin icono: el texto vive directo en el TextButton
                Btn:SetAttribute("TextSpanish", textSpanish)
                Btn:SetAttribute("TextEnglish", textEnglish)
            end

            --// ════════════════════════════════════════════════════════════
            --// EFECTO LIQUID 🌊 - Onda que se expande desde el punto de toque
            --// Primera implementación en librería de exploit - YinYang v28
            --// ════════════════════════════════════════════════════════════
            local function spawnRipple(inputPosition)
                --// Calcular posición relativa al botón (donde tocó el usuario)
                local btnPos = Btn.AbsolutePosition
                local btnSize = Btn.AbsoluteSize
                local relX = inputPosition.X - btnPos.X
                local relY = inputPosition.Y - btnPos.Y

                --// Calcular el diámetro máximo necesario para cubrir todo el botón
                --// (distancia al vértice más lejano × 2 para garantizar cobertura completa)
                local dX = math.max(relX, btnSize.X - relX)
                local dY = math.max(relY, btnSize.Y - relY)
                local maxRadius = math.sqrt(dX * dX + dY * dY) * 2.1

                --// Crear el círculo de onda, parte del BtnWrapper (ClipsDescendants lo recorta)
                local Ripple = Instance.new("Frame")
                Ripple.Name = "LiquidRipple"
                Ripple.AnchorPoint = Vector2.new(0.5, 0.5)
                Ripple.BackgroundColor3 = Theme.Accent
                Ripple.BackgroundTransparency = 0.55
                Ripple.BorderSizePixel = 0
                --// Empieza como un punto en donde tocaste
                Ripple.Size = UDim2.fromOffset(1, 1)
                Ripple.Position = UDim2.fromOffset(relX, relY)
                Ripple.ZIndex = 11
                Ripple.Parent = BtnWrapper

                --// Esquina perfectamente redonda
                local rippleCorner = Instance.new("UICorner")
                rippleCorner.CornerRadius = UDim.new(1, 0)
                rippleCorner.Parent = Ripple

                --// FASE 1: Expansión — crece hasta cubrir todo el botón
                local expandTween = TweenService:Create(
                    Ripple,
                    TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {
                        Size = UDim2.fromOffset(maxRadius, maxRadius),
                        BackgroundTransparency = 0.72,
                    }
                )
                expandTween:Play()

                --// FASE 2: Desvanece y destruye al terminar la expansión
                expandTween.Completed:Connect(function()
                    local fadeTween = TweenService:Create(
                        Ripple,
                        TweenInfo.new(0.25, Enum.EasingStyle.Sine, Enum.EasingDirection.Out),
                        { BackgroundTransparency = 1 }
                    )
                    fadeTween:Play()
                    fadeTween.Completed:Connect(function()
                        pcall(function() Ripple:Destroy() end)
                    end)
                end)
            end

            --// HOVER + TOUCH: efecto de transparencia al pasar mouse o mantener dedo
            track(Btn.MouseEnter:Connect(function()
                TweenService:Create(
                    Btn,
                    TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { BackgroundTransparency = 0.28 }
                ):Play()
            end))

            track(Btn.MouseLeave:Connect(function()
                TweenService:Create(
                    Btn,
                    TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { BackgroundTransparency = 0 }
                ):Play()
            end))

            track(Btn.InputBegan:Connect(function(input2)
                if input2.UserInputType == Enum.UserInputType.Touch then
                    TweenService:Create(Btn, TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { BackgroundTransparency = 0.38 }):Play()
                end
            end))

            track(Btn.InputEnded:Connect(function(input2)
                if input2.UserInputType == Enum.UserInputType.Touch then
                    TweenService:Create(Btn, TweenInfo.new(0.20, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { BackgroundTransparency = 0 }):Play()
                end
            end))

            --// CLICK: dispara la onda desde el punto exacto de toque
            track(Btn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1
                or input.UserInputType == Enum.UserInputType.Touch then
                    spawnRipple(input.Position)
                end
            end))

            Btn.MouseButton1Click:Connect(function()
                playSound(Sounds.Click, 0.6)
                pcall(callback)
            end)

            --// Devolver el wrapper para que el layout lo trate como si fuera el botón
            return BtnWrapper
        end

        --// LABEL
        function Tab:CreateLabel(textSpanish, textEnglishOrSize, fontSize)
            --// COMPATIBILIDAD: Si textEnglishOrSize es un número, es fontSize (código antiguo)
            local textEnglish = textSpanish
            if type(textEnglishOrSize) == "number" then
                --// Código antiguo: CreateLabel(text, fontSize)
                fontSize = textEnglishOrSize
                textEnglish = textSpanish
            elseif type(textEnglishOrSize) == "string" then
                --// Código nuevo: CreateLabel(textSpanish, textEnglish, fontSize)
                textEnglish = textEnglishOrSize
            end
            
            fontSize = fontSize or 14
            local displayText = GetText(textSpanish, textEnglish)
            
            local Label = mk("TextLabel", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                Text = displayText,
                TextColor3 = Theme.Text,
                Font = Enum.Font.GothamBold,
                TextSize = fontSize,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                ZIndex = 9
            })
            Label:SetAttribute("ThemeTextRole", "Text")
            Label:SetAttribute("TextSpanish", textSpanish)
            Label:SetAttribute("TextEnglish", textEnglish)
            resetScrollTop(TabPage)
            return Label
        end

        --// DIVISOR
        function Tab:CreateDivider()
            if self._homeBuilt then
                return nil
            end
            local Divider = mk("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 1),
                BackgroundColor3 = Theme.Stroke,
                ZIndex = 9
            })
            Divider:SetAttribute("ThemeRole", "Stroke")
            return Divider
        end

        --// HOME PRINCIPAL: PERSONAJE COMPLETO + STATS LATERALES
        function Tab:CreateWelcomeCard()
            if self._homeBuilt then
                return self._homeRoot
            end

            self._homeBuilt = true

            local HomeRoot = mk("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 370),
                BackgroundTransparency = 1,
                BorderSizePixel = 0,
                ClipsDescendants = false,
                ZIndex = 9,
            })
            self._homeRoot = HomeRoot

            local function makeStatCard(parent, xScale, y, wScale, h, iconId, titleES, titleEN, valueText, subES, subEN)
                local Card = mk("Frame", {
                    Parent = parent,
                    Size = UDim2.new(wScale, 0, 0, h),
                    Position = UDim2.new(xScale, 0, 0, y),
                    BackgroundColor3 = Theme.Secondary,
                    BackgroundTransparency = 0.06,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    ZIndex = 9,
                })
                Card:SetAttribute("ThemeRole", "Secondary")
                corner(Card, 14)
                stroke(Card, Theme.Stroke, 1, 0.72)

                mk("ImageLabel", {
                    Parent = Card,
                    Size = UDim2.new(0, 38, 0, 38),
                    Position = UDim2.new(0, 12, 0, 12),
                    BackgroundTransparency = 1,
                    Image = iconId and ("rbxassetid://" .. tostring(iconId)) or "",
                    ScaleType = Enum.ScaleType.Fit,
                    ZIndex = 10,
                })

                local Title = mk("TextLabel", {
                    Parent = Card,
                    Size = UDim2.new(1, -62, 0, 18),
                    Position = UDim2.new(0, 56, 0, 14),
                    BackgroundTransparency = 1,
                    Text = GetText(titleES, titleEN),
                    Font = Enum.Font.GothamBold,
                    TextSize = 13,
                    TextColor3 = Theme.TextDim,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 10,
                })
                Title:SetAttribute("ThemeTextRole", "TextDim")
                Title:SetAttribute("TextSpanish", titleES)
                Title:SetAttribute("TextEnglish", titleEN)

                local Value = mk("TextLabel", {
                    Parent = Card,
                    Size = UDim2.new(1, -18, 0, 24),
                    Position = UDim2.new(0, 14, 0, 48),
                    BackgroundTransparency = 1,
                    Text = valueText or "...",
                    Font = Enum.Font.GothamBold,
                    TextSize = 18,
                    TextColor3 = Theme.Text,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextTruncate = Enum.TextTruncate.AtEnd,
                    ZIndex = 10,
                })
                Value:SetAttribute("ThemeTextRole", "Text")

                local Subtitle = mk("TextLabel", {
                    Parent = Card,
                    Size = UDim2.new(1, -18, 0, 16),
                    Position = UDim2.new(0, 14, 1, -22),
                    BackgroundTransparency = 1,
                    Text = GetText(subES, subEN),
                    Font = Enum.Font.Gotham,
                    TextSize = 11,
                    TextColor3 = Theme.TextDim,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ZIndex = 10,
                })
                Subtitle:SetAttribute("ThemeTextRole", "TextDim")
                Subtitle:SetAttribute("TextSpanish", subES)
                Subtitle:SetAttribute("TextEnglish", subEN)

                return Card, Value, Subtitle
            end

            local function createViewport(parent)
                local ViewportWrap = mk("Frame", {
                    Parent = parent,
                    Size = UDim2.new(0.50, 0, 0, 310),
                    Position = UDim2.new(0.5, 0, 0, -8),
                    AnchorPoint = Vector2.new(0.5, 0),
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    ClipsDescendants = false,
                    ZIndex = 10,
                })

                -- Ring eliminado

                local Viewport = Instance.new("ViewportFrame")
                Viewport.Name = "HomeAvatarViewport"
                Viewport.Parent = ViewportWrap
                Viewport.Size = UDim2.new(1, 0, 1, 0)
                Viewport.Position = UDim2.new(0, 0, 0, 0)
                Viewport.BackgroundTransparency = 1
                Viewport.BorderSizePixel = 0
                Viewport.ZIndex = 11
                Viewport.Ambient = Color3.fromRGB(255, 255, 255)
                pcall(function() Viewport.LightColor = Color3.fromRGB(255, 255, 255) end)
                pcall(function() Viewport.LightDirection = Vector3.new(-0.3, -1, -0.2) end)

                local World = Instance.new("WorldModel")
                World.Parent = Viewport

                local Camera = Instance.new("Camera")
                Camera.Parent = Viewport
                Viewport.CurrentCamera = Camera

                local function cleanModel(model)
                    for _, obj in ipairs(model:GetDescendants()) do
                        if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                            pcall(function() obj:Destroy() end)
                        end
                    end
                end

                local function getSourceModel()
                    local source = LocalPlayer.Character
                    if source and source.Parent then
                        local ok, clone = pcall(function()
                            return source:Clone()
                        end)
                        if ok and clone then
                            return clone
                        end
                    end

                    local ok, model = pcall(function()
                        return Players:CreateHumanoidModelFromUserId(LocalPlayer.UserId)
                    end)
                    if ok and model then
                        return model
                    end
                    return nil
                end

                local model = getSourceModel()
                if model then
                    model.Name = "HomeAvatarModel"
                    cleanModel(model)
                    model.Parent = World

                    local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("UpperTorso") or model:FindFirstChild("Torso")
                    if root and model.PrimaryPart == nil then
                        pcall(function() model.PrimaryPart = root end)
                    end

                    pcall(function()
                        model:PivotTo(CFrame.new(0, 0, 0) * CFrame.Angles(0, math.rad(180), 0))
                    end)

                    local okBox, cf, size = pcall(function()
                        return model:GetBoundingBox()
                    end)
                    if okBox and cf and size then
                        local biggest = math.max(size.X, size.Y, size.Z)
                        -- Pose genial: cámara en ángulo heroico, personaje centrado y grande
                        local focus = cf.Position + Vector3.new(0, size.Y * 0.22, 0)
                        local camPos = focus + Vector3.new(0.25, -biggest * 0.05, biggest * 1.30)
                        Camera.CFrame = CFrame.new(camPos, focus)
                    else
                        Camera.CFrame = CFrame.new(Vector3.new(0.25, 2.0, 5.0), Vector3.new(0, 3.0, 0))
                    end

                    -- Animación flotante en loop (Relax Flying Anime Floating Emote)
                    task.defer(function()
                        pcall(function()
                            local humanoid = model:FindFirstChildOfClass("Humanoid")
                            if not humanoid then return end
                            local animator = humanoid:FindFirstChildOfClass("Animator")
                            if not animator then
                                animator = Instance.new("Animator")
                                animator.Parent = humanoid
                            end
                            --// v28 FIX: Lista de animaciones de idle/pose públicas
                            --// Se prueban en orden hasta que una carga correctamente
                            local animIds = {
                                "rbxassetid://616010382",  -- Idle (Float) - público garantizado
                                "rbxassetid://507766388",  -- Idle estándar Roblox
                                "rbxassetid://180435571",  -- Idle walk loop
                            }
                            local loaded = false
                            for _, animId in ipairs(animIds) do
                                if loaded then break end
                                local ok, result = pcall(function()
                                    local anim = Instance.new("Animation")
                                    anim.AnimationId = animId
                                    local track = animator:LoadAnimation(anim)
                                    track.Priority = Enum.AnimationPriority.Action4
                                    track.Looped = true
                                    track:Play()
                                    loaded = true
                                end)
                                if not ok then
                                    warn("[YinYang Home] Animación no cargó: " .. animId .. " | " .. tostring(result))
                                end
                            end
                        end)
                    end)
                else
                    local fallback = mk("TextLabel", {
                        Parent = ViewportWrap,
                        Size = UDim2.new(1, 0, 1, 0),
                        BackgroundTransparency = 1,
                        Text = GetText("Cargando avatar...", "Loading avatar..."),
                        Font = Enum.Font.GothamBold,
                        TextSize = 14,
                        TextColor3 = Theme.TextDim,
                        ZIndex = 12,
                    })
                    fallback:SetAttribute("ThemeTextRole", "TextDim")
                end

                return ViewportWrap
            end

            local function shorten(text)
                text = tostring(text or "")
                if #text <= 14 then
                    return text
                end
                return text:sub(1, 10) .. "..."
            end

            local NameLabel = mk("TextLabel", {
                Parent = HomeRoot,
                Size = UDim2.new(0.38, 0, 0, 24),
                Position = UDim2.new(0.31, 0, 0, 12),
                BackgroundTransparency = 1,
                Text = GetText("Bienvenido,", "Welcome,"),
                Font = Enum.Font.GothamBold,
                TextSize = 13,
                TextColor3 = Theme.Accent,
                TextXAlignment = Enum.TextXAlignment.Center,
                ZIndex = 11,
            })
            NameLabel:SetAttribute("ThemeTextRole", "Text")
            NameLabel:SetAttribute("TextSpanish", "Bienvenido,")
            NameLabel:SetAttribute("TextEnglish", "Welcome,")

            local UserLabel = mk("TextLabel", {
                Parent = HomeRoot,
                Size = UDim2.new(0.38, 0, 0, 30),
                Position = UDim2.new(0.31, 0, 0, 34),
                BackgroundTransparency = 1,
                Text = LocalPlayer.DisplayName or LocalPlayer.Name,
                Font = Enum.Font.GothamBold,
                TextSize = 24,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ZIndex = 11,
            })
            UserLabel:SetAttribute("ThemeTextRole", "Text")

            -- Badge "Main panel" eliminado

            createViewport(HomeRoot)

            local cardH = 108
            local row1 = 8
            local row2 = 128
            local row3 = 248
            local leftColX = 0.03
            local rightColX = 0.71
            local cardW = 0.26

            local _, playersVal = makeStatCard(HomeRoot, leftColX, row1, cardW, cardH, 131146352870155, "Jugadores", "Players", "1", "Conectado", "Connected")
            local _, pingVal = makeStatCard(HomeRoot, leftColX, row2, cardW, cardH, 122515048693374, "Ping", "Ping", "0 ms", "Estado de red", "Network state")
            local _, idVal = makeStatCard(HomeRoot, leftColX, row3, cardW, cardH, 100256879314173, "ID del servidor", "Server ID", "N/A", "Tocar para copiar", "Tap to copy")

            local _, timeVal = makeStatCard(HomeRoot, rightColX, row1, cardW, cardH, 106412924897730, "Tiempo", "Time", "00:00:00", "Servidor en vivo", "Server live")
            local _, regionVal = makeStatCard(HomeRoot, rightColX, row2, cardW, cardH, 103565937124990, "Región", "Region", "ES-ES", "Detectado automáticamente", "Automatically detected")
            local _, statusVal = makeStatCard(HomeRoot, rightColX, row3, cardW, cardH, 75084674812973, "Estado", "Status", "Healthy", "Todo funcionando", "All systems operational")

            idVal.Text = shorten((game.JobId ~= "" and game.JobId) or "N/A (Studio)")

            local copyButton = mk("TextButton", {
                Parent = HomeRoot,
                Size = UDim2.new(cardW, 0, 0, cardH),
                Position = UDim2.new(leftColX, 0, 0, row3),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 12,
            })
            copyButton.MouseButton1Click:Connect(function()
                local snippet = string.format(
                    'game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)',
                    game.PlaceId, game.JobId
                )
                local ok = pcall(function() setclipboard(snippet) end)
                if ok then
                    idVal.Text = GetText("¡Copiado!", "Copied!")
                end
                task.delay(1.8, function()
                    if idVal and idVal.Parent then
                        idVal.Text = shorten((game.JobId ~= "" and game.JobId) or "N/A (Studio)")
                    end
                end)
            end)

            local startClock = os.clock()
            local StatsService = game:GetService("Stats")
            local localizationService = game:GetService("LocalizationService")
            local cachedRegion = "ES-ES"
            pcall(function()
                local region = localizationService:GetCountryRegionForPlayerAsync(LocalPlayer)
                if type(region) == "string" and region ~= "" then
                    cachedRegion = region
                end
            end)
            local updateConn
            updateConn = track(RunService.Heartbeat:Connect(function()
                if not HomeRoot.Parent then
                    if updateConn then
                        pcall(function() updateConn:Disconnect() end)
                    end
                    return
                end

                playersVal.Text = tostring(#Players:GetPlayers())
                local okPing, ping = pcall(function()
                    return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
                end)
                pingVal.Text = (okPing and ping) and (math.floor(ping) .. " ms") or "N/A"
                timeVal.Text = formatDuration(os.clock() - startClock)
                regionVal.Text = cachedRegion
                statusVal.Text = "Healthy"
            end))

            resetScrollTop(TabPage)
            return HomeRoot
        end

        --// SERVER INFO CARD CON ESTADÍSTICAS DEL SERVIDOR
        function Tab:CreateServerInfoCard()
            if self._homeBuilt then
                return nil
            end
            local Card = mk("Frame", {
                Parent = TabPage,
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundTransparency = 1,
                ZIndex = 9
            })
            mk("UIListLayout", {Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder}, Card)

            local ServerLabel = mk("TextLabel", {
                Parent = Card,
                Size = UDim2.new(1, 0, 0, 18),
                BackgroundTransparency = 1,
                Text = GetText("Servidor", "Server"),
                Font = Enum.Font.GothamBold,
                TextSize = 15,
                TextColor3 = Theme.Text,
                TextXAlignment = Enum.TextXAlignment.Left,
                ZIndex = 9
            })
            ServerLabel:SetAttribute("ThemeRole", "Text")
            ServerLabel:SetAttribute("TextSpanish", "Servidor")
            ServerLabel:SetAttribute("TextEnglish", "Server")

            local Grid = createStatGrid(Card)
            local _, playersVal = createStatTile(Grid, "Jugadores", "Players")
            local _, maxVal = createStatTile(Grid, "Máximo de jugadores", "Max players")
            local _, pingVal = createStatTile(Grid, "Latencia", "Latency")
            local _, idVal = createStatTile(Grid, "ID del servidor", "Server ID")
            local joinTile, joinVal = createStatTile(Grid, "Script de unión", "Join script")
            local _, timeVal = createStatTile(Grid, "Tiempo en el servidor", "Server time")

            idVal.Text = (game.JobId ~= "" and game.JobId) or "N/A (Studio)"
            joinVal.Text = GetText("Tocar para copiar", "Tap to copy")

            local JoinClick = mk("TextButton", {
                Parent = joinTile,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = "",
                ZIndex = 11
            })
            JoinClick.MouseButton1Click:Connect(function()
                local snippet = string.format(
                    'game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)',
                    game.PlaceId, game.JobId
                )
                local ok = pcall(function() setclipboard(snippet) end)
                joinVal.Text = ok and GetText("¡Copiado!", "Copied!") or GetText("No disponible", "Not available")
                task.delay(2, function()
                    if joinVal and joinVal.Parent then
                        joinVal.Text = GetText("Tocar para copiar", "Tap to copy")
                    end
                end)
            end)

            local startClock = os.clock()
            local StatsService = game:GetService("Stats")

            task.spawn(function()
                while Card.Parent do
                    playersVal.Text = tostring(#Players:GetPlayers())
                    maxVal.Text = tostring(Players.MaxPlayers)

                    local ok, ping = pcall(function()
                        return StatsService.Network.ServerStatsItem["Data Ping"]:GetValue()
                    end)
                    pingVal.Text = (ok and ping) and (math.floor(ping) .. " ms") or "N/A"

                    timeVal.Text = formatDuration(os.clock() - startClock)
                    task.wait(1)
                end
            end)

            resetScrollTop(TabPage)
            return Card
        end

        return Tab
    end

    --// ════════════════════════════════════════════════════════════════
    --// FUNCIONES DE EFECTOS DE TEXTO (ANTES DE SetTheme - IMPORTANTE)
    --// ════════════════════════════════════════════════════════════════
    local textEffectConnection = nil
    Window.CurrentTextEffect = "Off"

    local function getAllTextObjects()
        local list = {}
        for _, obj in ipairs(Main:GetDescendants()) do
            if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                table.insert(list, obj)
            end
        end
        return list
    end

    local function applyTextColorToAll(color)
        for _, obj in ipairs(getAllTextObjects()) do
            pcall(function()
                obj.TextColor3 = color
            end)
        end
    end

    local function stopTextEffect()
        if textEffectConnection then
            textEffectConnection:Disconnect()
            textEffectConnection = nil
        end
    end

    --// ════════════════════════════════════════════════════════════════
    --// CAMBIO DE TEMA (SetTheme) 
    --// ════════════════════════════════════════════════════════════════

    function Window:SetTheme(themeName)
        if not setActiveTheme(themeName) then
            warn("Tema no encontrado: " .. tostring(themeName))
            return
        end
        
        self.CurrentTheme = themeName
        CurrentTheme = themeName

        for _, obj in ipairs(Main:GetDescendants()) do
            swapThemeColor(obj, Theme)
        end

        --// Propagar tema a ventanas flotantes (están en ScreenGui, no en Main)
        for _, floatData in ipairs(self.FloatingToggles or {}) do
            local fw = floatData.Window
            if fw and fw.Parent then
                for _, obj in ipairs(fw:GetDescendants()) do
                    swapThemeColor(obj, Theme)
                end
                swapThemeColor(fw, Theme)
            end
        end

        applyTextColorToAll(Theme.Text)

        --// CANCELAR SLIDESHOW ANTERIOR (token system)
        self._slideshowToken = (self._slideshowToken or 0) + 1

        if BackgroundArt then
            pcall(function()
                --// Prioridad 1: ThemeStore externo
                local themeData = ThemeStore and ThemeStore.Themes and ThemeStore.Themes[themeName]

                if themeData and themeData.Images and #themeData.Images > 1 then
                    --// TEMA CON SLIDESHOW
                    local token = self._slideshowToken
                    local images = themeData.Images
                    local interval = tonumber(themeData.ImageInterval) or 5

                    BackgroundArt.Image = images[1]

                    task.spawn(function()
                        local i = 1
                        while self._slideshowToken == token do
                            task.wait(interval)
                            if self._slideshowToken ~= token then break end
                            i = (i % #images) + 1
                            if BackgroundArt and BackgroundArt.Parent then
                                BackgroundArt.Image = images[i]
                            end
                        end
                    end)
                else
                    --// TEMA NORMAL (una sola imagen)
                    local bg = (themeData and themeData.Background) or ThemeBackgroundImages[themeName] or ""
                    BackgroundArt.Image = bg
                end

                print("Imagen de fondo actualizada")
            end)
        end

        SavedConfig.CurrentTheme = themeName
        SaveConfig()

        --// SONIDO DE CLICK DINÁMICO
        local themeData = ThemeStore and ThemeStore.Themes and ThemeStore.Themes[themeName]
        if themeData and themeData.Sound then
            CurrentClickSound = themeData.Sound
        elseif ThemeClickSounds[themeName] then
            CurrentClickSound = ThemeClickSounds[themeName]
            print("Tema " .. themeName .. " - Sonido de click personalizado activado")
        else
            CurrentClickSound = Sounds.Click
        end

        --// EFECTO DINÁMICO POR TEMA
        local autoEffect = (themeData and themeData.Effect) or ThemeAutoEffects[themeName]
        if autoEffect and autoEffect ~= "Off" then
            self:SetTextEffect(autoEffect)
        else
            self:SetTextEffect("Off")
        end

        --// IMAGEN DECORATIVA EN TOPBAR
        if TopBarArt then
            pcall(function()
                local img = (themeData and themeData.TitleBarImage) or ThemeTitleBarImages[themeName] or ""
                TopBarArt.Image = img
            end)
        end

        --// IMAGEN DECORATIVA EN TABLIST
        --// Cuando hay imagen: TabList se vuelve semi-transparente para dejar pasar la imagen
        --// Cuando no hay imagen: TabList vuelve a ser opaco (comportamiento original)
        if TabListArt then
            pcall(function()
                local img = (themeData and themeData.TabListImage) or ThemeTabListImages[themeName] or ""
                TabListArt.Image = img
                TabList.BackgroundTransparency = img ~= "" and 0.5 or 0
            end)
        end

        CurrentTheme = themeName

        buildAnimatedBorder(Main, Theme.Accent, UDim.new(0, 10))

        -- Actualizar efecto en floating toggles activos
        for _, floatData in ipairs(Window.FloatingToggles or {}) do
            if floatData.Window and floatData.Window.Parent then
                buildAnimatedBorder(floatData.Window, Theme.Accent, UDim.new(1, 0), true)
            end
        end

        -- Actualizar borde animado de todos los sliders
        for _, obj in ipairs(Main:GetDescendants()) do
            if obj:GetAttribute("IsSliderHolder") then
                buildAnimatedBorder(obj, Theme.Accent, UDim.new(0, 12), true)
            end
        end

        -- La pestaña Efectos se construye después de esta función; usa callback
        -- para refrescar tarjetas, badges y bordes con el tema recién elegido.
        if self._refreshEffectRows then
            self._refreshEffectRows()
        end
    end

    -- mode: "Off" | "WhiteCyan" | "WhitePink" | "Rainbow"
    function Window:SetTextEffect(mode)
        stopTextEffect()
        Window.CurrentTextEffect = mode
        -- Guardar efecto en config para persistencia
        SavedConfig.CurrentEffect = mode
        SaveConfig()

        if mode == "Off" then
            -- Devuelve cada texto al color que le corresponde según su rol de tema actual
            for _, obj in ipairs(getAllTextObjects()) do
                local role = obj:GetAttribute("ThemeTextRole")
                if role and Theme[role] then
                    obj.TextColor3 = Theme[role]
                elseif not role then
                    -- Sin rol definido: restaurar al color de texto por defecto del tema
                    obj.TextColor3 = Theme.Text
                end
            end
            return
        end

        local elapsed = 0
        local RunService = game:GetService("RunService")

        if mode == "WhiteCyan" then
            -- Pulso suave entre blanco y celeste, "a ratos" (va y viene)
            local colorA = Color3.fromRGB(255, 255, 255)
            local colorB = Color3.fromRGB(120, 225, 255)
            textEffectConnection = track(RunService.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                local alpha = (math.sin(elapsed * 1.6) + 1) / 2
                applyTextColorToAll(colorA:Lerp(colorB, alpha))
            end))

        elseif mode == "WhitePink" then
            -- Igual que el anterior pero más lento y entre blanco y rosa
            local colorA = Color3.fromRGB(255, 255, 255)
            local colorB = Color3.fromRGB(255, 130, 205)
            textEffectConnection = track(RunService.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                local alpha = (math.sin(elapsed * 0.6) + 1) / 2
                applyTextColorToAll(colorA:Lerp(colorB, alpha))
            end))

        elseif mode == "Rainbow" then
            -- Recorre todo el espectro de color de forma continua y pareja
            textEffectConnection = track(RunService.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                local hue = (elapsed * 0.12) % 1
                applyTextColorToAll(Color3.fromHSV(hue, 0.85, 1))
            end))

        elseif mode == "CatRainbow" then
            --  EFECTO ESPECIAL PARA CAT V1: Oscilación rápida entre Rosa y Blanco
            -- 5x más rápido que Rainbow normal (0.2 seg por ciclo)
            textEffectConnection = track(RunService.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                local cycle = (elapsed * 5) % 1  -- 5 ciclos por segundo
                
                local color
                if cycle < 0.5 then
                    -- Primera mitad: Rosa (255, 100, 150) → Blanco (255, 255, 255)
                    local t = cycle * 2
                    color = Color3.fromRGB(
                        255,
                        math.floor(100 + (255 - 100) * t),
                        math.floor(150 + (255 - 150) * t)
                    )
                else
                    -- Segunda mitad: Blanco (255, 255, 255) → Rosa (255, 100, 150)
                    local t = (cycle - 0.5) * 2
                    color = Color3.fromRGB(
                        255,
                        math.floor(255 - (255 - 100) * t),
                        math.floor(255 - (255 - 150) * t)
                    )
                end
                
                applyTextColorToAll(color)
            end))

        elseif mode == "RainbowDarkWhite" then
            --  EFECTO RAINBOW DARK-WHITE: Transición lenta de Negro a Blanco
            -- Cambia muy lentamente (un ciclo cada 4 segundos)
            textEffectConnection = track(RunService.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                local cycle = (elapsed * 0.25) % 1  -- Un ciclo cada 4 segundos
                
                -- Interpola lentamente entre negro (0, 0, 0) y blanco (255, 255, 255)
                local color = Color3.fromRGB(
                    math.floor(255 * cycle),
                    math.floor(255 * cycle),
                    math.floor(255 * cycle)
                )
                
                applyTextColorToAll(color)
            end))

        elseif mode == "ErisRainbow" then
            -- 🔴 EFECTO ESPECIAL PARA ERIS V1: Transición lenta Rojo → Negro → Blanco
            -- 3 fases en un ciclo de 6 segundos: Rojo (2s) → Negro (2s) → Blanco (2s)
            textEffectConnection = track(RunService.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                local cycle = (elapsed * 0.167) % 1  -- Un ciclo cada 6 segundos (1/6 = 0.167)
                
                local color
                if cycle < 0.333 then
                    -- Primera fase (0-2s): Rojo (255, 0, 0) → Negro (0, 0, 0)
                    local t = cycle / 0.333
                    color = Color3.fromRGB(
                        math.floor(255 - 255 * t),  -- Rojo: 255 → 0
                        0,
                        0
                    )
                elseif cycle < 0.667 then
                    -- Segunda fase (2-4s): Negro (0, 0, 0) → Blanco (255, 255, 255)
                    local t = (cycle - 0.333) / 0.334
                    color = Color3.fromRGB(
                        math.floor(255 * t),
                        math.floor(255 * t),
                        math.floor(255 * t)
                    )
                else
                    -- Tercera fase (4-6s): Blanco (255, 255, 255) → Rojo (255, 0, 0)
                    local t = (cycle - 0.667) / 0.333
                    color = Color3.fromRGB(
                        255,
                        math.floor(255 - 255 * t),  -- Rojo: 255 → 0
                        math.floor(255 - 255 * t)   -- Azul: 255 → 0
                    )
                end
                
                applyTextColorToAll(color)
            end))

        elseif mode == "ShylfieRainbow" then
            --  EFECTO ESPECIAL PARA SHYLFIE V1: Oscilación entre Amarillo y Blanco
            textEffectConnection = track(RunService.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                local cycle = (elapsed * 0.4) % 1

                local color
                if cycle < 0.5 then
                    -- Amarillo (255, 215, 0) → Blanco (255, 255, 255)
                    local t = cycle * 2
                    color = Color3.fromRGB(
                        255,
                        math.floor(215 + (255 - 215) * t),
                        math.floor(0 + 255 * t)
                    )
                else
                    -- Blanco (255, 255, 255) → Amarillo (255, 215, 0)
                    local t = (cycle - 0.5) * 2
                    color = Color3.fromRGB(
                        255,
                        math.floor(255 - (255 - 215) * t),
                        math.floor(255 - 255 * t)
                    )
                end

                applyTextColorToAll(color)
            end))

        elseif mode == "SukunaRainbow" then
            --  EFECTO ESPECIAL PARA SUKUNA V1: Oscilación entre Negro y Rojo
            textEffectConnection = track(RunService.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                local cycle = (elapsed * 0.4) % 1

                local color
                if cycle < 0.5 then
                    -- Negro (0, 0, 0) → Rojo (200, 20, 25)
                    local t = cycle * 2
                    color = Color3.fromRGB(
                        math.floor(200 * t),
                        math.floor(20 * t),
                        math.floor(25 * t)
                    )
                else
                    -- Rojo (200, 20, 25) → Negro (0, 0, 0)
                    local t = (cycle - 0.5) * 2
                    color = Color3.fromRGB(
                        math.floor(200 - 200 * t),
                        math.floor(20 - 20 * t),
                        math.floor(25 - 25 * t)
                    )
                end

                applyTextColorToAll(color)
            end))

        elseif mode == "NeonPulse" then
            -- NEON PULSE: destello rápido entre verde neón y cian brillante
            textEffectConnection = track(RunService.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                local pulse = (math.sin(elapsed * 3.5) + 1) / 2
                local color = Color3.fromRGB(
                    math.floor(0 + 100 * (1 - pulse)),
                    math.floor(200 + 55 * pulse),
                    math.floor(180 + 75 * pulse)
                )
                applyTextColorToAll(color)
            end))

        elseif mode == "GoldenShine" then
            -- GOLDEN SHINE: brillo dorado que oscila entre amarillo y blanco
            textEffectConnection = track(RunService.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                local shine = (math.sin(elapsed * 1.2) + 1) / 2
                local color = Color3.fromRGB(
                    255,
                    math.floor(180 + 75 * shine),
                    math.floor(0 + 120 * shine)
                )
                applyTextColorToAll(color)
            end))

        elseif mode == "FireEffect" then
            -- FIRE: transición rápida Rojo → Naranja → Amarillo (llamas)
            textEffectConnection = track(RunService.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                local cycle = (elapsed * 2.2) % 1
                local color
                if cycle < 0.33 then
                    local t = cycle / 0.33
                    color = Color3.fromRGB(255, math.floor(60 * t), 0)
                elseif cycle < 0.66 then
                    local t = (cycle - 0.33) / 0.33
                    color = Color3.fromRGB(255, math.floor(60 + 120 * t), 0)
                else
                    local t = (cycle - 0.66) / 0.34
                    color = Color3.fromRGB(255, math.floor(180 + 75 * t), math.floor(100 * t))
                end
                applyTextColorToAll(color)
            end))

        elseif mode == "IceBlue" then
            -- ICE BLUE: cristal de hielo, pulso entre azul cielo y blanco frío
            textEffectConnection = track(RunService.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                local t = (math.sin(elapsed * 0.9) + 1) / 2
                local color = Color3.fromRGB(
                    math.floor(140 + 115 * t),
                    math.floor(200 + 55 * t),
                    255
                )
                applyTextColorToAll(color)
            end))

        elseif mode == "PurpleGlow" then
            -- PURPLE GLOW: pulso lento entre violeta oscuro y lila brillante
            textEffectConnection = track(RunService.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                local t = (math.sin(elapsed * 0.7) + 1) / 2
                local color = Color3.fromRGB(
                    math.floor(140 + 80 * t),
                    math.floor(40 + 40 * t),
                    math.floor(220 + 35 * t)
                )
                applyTextColorToAll(color)
            end))

        elseif mode == "MatrixGreen" then
            -- MATRIX: verde brillante que parpadea como la Matrix
            textEffectConnection = track(RunService.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                local flicker = (math.sin(elapsed * 6.0) + 1) / 2
                local bright = (math.sin(elapsed * 1.4) + 1) / 2
                local color = Color3.fromRGB(
                    math.floor(0 + 30 * flicker),
                    math.floor(180 + 75 * bright),
                    math.floor(30 + 50 * flicker)
                )
                applyTextColorToAll(color)
            end))

        elseif mode == "RainbowFast" then
            -- RAINBOW FAST: arcoíris ultra rápido (3x velocidad normal)
            textEffectConnection = track(RunService.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                local hue = (elapsed * 0.45) % 1
                applyTextColorToAll(Color3.fromHSV(hue, 1, 1))
            end))

        elseif mode == "Sunset" then
            -- SUNSET: atardecer coral → magenta → naranja
            textEffectConnection = track(RunService.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                local cycle = (elapsed * 0.28) % 1
                local color
                if cycle < 0.5 then
                    local t = cycle * 2
                    color = Color3.fromRGB(255, math.floor(80 + 80 * t), math.floor(50 * (1 - t)))
                else
                    local t = (cycle - 0.5) * 2
                    color = Color3.fromRGB(255, math.floor(160 - 80 * t), math.floor(50 * t))
                end
                applyTextColorToAll(color)
            end))

        else
            warn("Efecto de texto no reconocido: " .. tostring(mode))
        end
    end

    function Window:Destroy()
        shutdownUI()
    end

    --// ════════════════════════════════════════════════════════════════
    --// CREAR AUTOMÁTICAMENTE LAS 3 PESTAÑAS SAGRADAS (v26 MEJORADO)
    --// ════════════════════════════════════════════════════════════════
    
    -- TAB 1: INICIO (Automático)
    local AutoTabInicio = Window:CreateTab("Inicio", "Home", "rbxassetid://71085559019524")
    AutoTabInicio:CreateWelcomeCard()
    AutoTabInicio:CreateDivider()
    AutoTabInicio:CreateServerInfoCard()

    -- TAB FAVORITOS (Automático)
    AutoTabFavoritosRef = Window:CreateTab("Favo", "Favs", "rbxassetid://101062763457687")

    -- TAB 2: TEMAS (Automático)
    --// Todo el contenido de esta pestaña vive en su propia función anidada:
    --// Lua/Luau limita a 200 variables locales por función, y CreateWindow ya
    --// es una función enorme. Aislar este bloque le da su propio presupuesto
    --// de locales sin tocar nada de su lógica interna.
    local function BuildTemasTab()
    local AutoTabTemas = Window:CreateTab("Temas", "Themes", "rbxassetid://108938004711116")
    AutoTabTemas:CreateLabel("Temas Personalizados", 14)
    AutoTabTemas:CreateDivider()

    --// ════════════════════════════════════════════════════════════════
    --// BUSCADOR DE TEMAS + CREACIÓN DE TEMAS PERSONALIZADOS
    --// ════════════════════════════════════════════════════════════════
    local ThemeToolbar = mk("Frame", {
        Parent = AutoTabTemas.Page,
        Size = UDim2.new(1, 0, 0, 36),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 9,
    })

    local ThemeSearchHolder = mk("Frame", {
        Parent = ThemeToolbar,
        Size = UDim2.new(0.68, -4, 1, 0),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        ZIndex = 9,
    })
    ThemeSearchHolder:SetAttribute("ThemeRole", "Secondary")
    corner(ThemeSearchHolder, 6)
    stroke(ThemeSearchHolder, Theme.Stroke, 1, 0.6)

    mk("ImageLabel", {
        Parent = ThemeSearchHolder,
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 10, 0.5, -8),
        BackgroundTransparency = 1,
        Image = "rbxassetid://83456197177232",
        ImageColor3 = Theme.TextDim,
        ZIndex = 10,
    })

    local ThemeSearchBox = mk("TextBox", {
        Parent = ThemeSearchHolder,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 32, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        ClearTextOnFocus = false,
        PlaceholderText = "Buscar tema...",
        PlaceholderColor3 = Theme.TextDim,
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.Gotham,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 10,
    })
    ThemeSearchBox:SetAttribute("ThemeTextRole", "Text")

    local CreateThemeButton = mk("TextButton", {
        Parent = ThemeToolbar,
        Size = UDim2.new(0.32, -4, 1, 0),
        Position = UDim2.new(0.68, 4, 0, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Text = "Crear Tema",
        TextColor3 = Theme.AccentText,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        ZIndex = 10,
    })
    CreateThemeButton:SetAttribute("ThemeRole", "Accent")
    CreateThemeButton:SetAttribute("ThemeTextRole", "AccentText")
    corner(CreateThemeButton, 6)
    stroke(CreateThemeButton, Theme.Stroke, 1, 0.6)
    resetScrollTop(AutoTabTemas.Page)

    local temas = ThemeOrder or {
        "Dark", "DarkV2",
        "Red", "RedV2",
        "Pink", "PinkV2", "PinkV3",
        "Blue", "BlueV2",
        "White", "WhiteV2", "WhiteV3", "WhiteAndDark",
        "Green", "NaranjaV1", "VioletaV1",
        "CatV1",
        "LightV1",
        "ErisV1",
        "ShylfieV1",
        "SukunaV1", "SukunaV2",
        "V1", "V2", "V3", "V4", "V5", "V6", "V9", "V10", "V11", "V14",
        "PibbleV1",
    }

    --// GRID DE TEMAS CON VISTA PREVIA
    local ThemeGridHolder = mk("Frame", {
        Parent = AutoTabTemas.Page,
        Size = UDim2.new(1, 0, 0, 0),
        AutomaticSize = Enum.AutomaticSize.Y,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 9,
    })

    mk("UIGridLayout", {
        Parent = ThemeGridHolder,
        CellSize = UDim2.new(0.485, 0, 0, 76),
        CellPadding = UDim2.new(0.03, 0, 0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
    })

    local ThemeButtons = {}

    local function highlightThemeCards()
        local active = Window.CurrentTheme
        for _, entry in ipairs(ThemeButtons) do
            local isActive = (entry.Name == active)
            entry.CheckBadge.Visible = isActive
            entry.CardStroke.Thickness = isActive and 2 or 1
            entry.CardStroke.Transparency = isActive and 0 or 0.75
        end
    end

    local function applyThemeSearch()
        local query = ThemeSearchBox.Text:lower()
        for _, entry in ipairs(ThemeButtons) do
            entry.Card.Visible = (query == "" or entry.Name:lower():find(query, 1, true) ~= nil)
        end
        resetScrollTop(AutoTabTemas.Page)
    end

    local openThemeEditor
    local confirmDeleteTheme

    local function createThemeCard(tema, layoutOrder, isCustom)
        local palette = ThemePalettes[tema] or Theme

        local Card = mk("TextButton", {
            Parent = ThemeGridHolder,
            BackgroundColor3 = Theme.Secondary,
            BackgroundTransparency = 0,
            Text = "",
            LayoutOrder = layoutOrder,
            ZIndex = 9,
        })
        Card:SetAttribute("ThemeRole", "Secondary")
        corner(Card, 10)
        local CardStroke = stroke(Card, Theme.Stroke, 1, 0.75)

        local Preview = mk("Frame", {
            Parent = Card,
            Size = UDim2.new(1, -16, 0, 30),
            Position = UDim2.new(0, 8, 0, 8),
            BackgroundColor3 = palette.Background,
            BorderSizePixel = 0,
            ClipsDescendants = true,
            ZIndex = 10,
        })
        corner(Preview, 7)
        mk("UIStroke", {
            Parent = Preview,
            Color = palette.Stroke or Color3.fromRGB(0, 0, 0),
            Thickness = 1,
            Transparency = 0.5,
        })

        mk("Frame", {
            Parent = Preview,
            Size = UDim2.new(0.35, 0, 1, 0),
            BackgroundColor3 = palette.Secondary,
            BorderSizePixel = 0,
            ZIndex = 10,
        })

        mk("Frame", {
            Parent = Preview,
            Size = UDim2.new(0.35, 0, 1, 0),
            Position = UDim2.new(0.65, 0, 0, 0),
            BackgroundColor3 = palette.Accent,
            BorderSizePixel = 0,
            ZIndex = 10,
        })

        local NameLabel = mk("TextLabel", {
            Parent = Card,
            Size = UDim2.new(1, isCustom and -42 or -16, 0, 18),
            Position = UDim2.new(0, 8, 0, 44),
            BackgroundTransparency = 1,
            Text = tema,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 10,
        })
        NameLabel:SetAttribute("ThemeTextRole", "Text")

        local CheckBadge = mk("TextLabel", {
            Parent = Card,
            Size = UDim2.new(0, 18, 0, 18),
            Position = UDim2.new(1, -24, 0, 6),
            BackgroundColor3 = Color3.fromRGB(20, 20, 20),
            BackgroundTransparency = 0.15,
            Text = "✓",
            Font = Enum.Font.GothamBlack,
            TextSize = 12,
            TextColor3 = Color3.fromRGB(90, 220, 120),
            Visible = false,
            ZIndex = 12,
        })
        corner(CheckBadge, 9)

        if isCustom then
            local MenuButton = mk("TextButton", {
                Parent = Card,
                Size = UDim2.new(0, 26, 0, 22),
                Position = UDim2.new(1, -32, 1, -27),
                BackgroundTransparency = 1,
                Text = "⋮",
                TextColor3 = Theme.TextDim,
                Font = Enum.Font.GothamBold,
                TextSize = 18,
                ZIndex = 13,
            })
            MenuButton:SetAttribute("ThemeTextRole", "TextDim")

            local Menu = mk("Frame", {
                Parent = Card,
                Size = UDim2.new(0, 88, 0, 56),
                Position = UDim2.new(1, -94, 1, -62),
                BackgroundColor3 = Theme.Background,
                BorderSizePixel = 0,
                Visible = false,
                ZIndex = 20,
            })
            Menu:SetAttribute("ThemeRole", "Background")
            corner(Menu, 6)
            stroke(Menu, Theme.Stroke, 1, 0.35)

            local EditButton = mk("TextButton", {
                Parent = Menu,
                Size = UDim2.new(1, 0, 0.5, 0),
                BackgroundTransparency = 1,
                Text = "Editar",
                TextColor3 = Theme.Text,
                Font = Enum.Font.Gotham,
                TextSize = 12,
                ZIndex = 21,
            })
            EditButton:SetAttribute("ThemeTextRole", "Text")

            local DeleteButton = mk("TextButton", {
                Parent = Menu,
                Size = UDim2.new(1, 0, 0.5, 0),
                Position = UDim2.new(0, 0, 0.5, 0),
                BackgroundTransparency = 1,
                Text = "Eliminar",
                TextColor3 = Color3.fromRGB(235, 85, 85),
                Font = Enum.Font.Gotham,
                TextSize = 12,
                ZIndex = 21,
            })

            MenuButton.MouseButton1Click:Connect(function()
                Menu.Visible = not Menu.Visible
            end)
            EditButton.MouseButton1Click:Connect(function()
                Menu.Visible = false
                openThemeEditor(tema)
            end)
            DeleteButton.MouseButton1Click:Connect(function()
                Menu.Visible = false
                confirmDeleteTheme(tema)
            end)
        end

        Card.MouseButton1Click:Connect(function()
            playSound(Sounds.Click, 0.6)
            Window:SetTheme(tema)
            highlightThemeCards()
        end)

        table.insert(ThemeButtons, {Card = Card, Name = tema, CheckBadge = CheckBadge, CardStroke = CardStroke})
    end

    local function rebuildThemeCards()
        for _, entry in ipairs(ThemeButtons) do
            if entry.Card then entry.Card:Destroy() end
        end
        ThemeButtons = {}

        local order = 0
        for _, tema in ipairs(temas) do
            if ThemePalettes[tema] then
                order = order + 1
                createThemeCard(tema, order, false)
            end
        end
        for _, tema in ipairs(CustomThemeOrder) do
            if CustomThemes[tema] and ThemePalettes[tema] then
                order = order + 1
                createThemeCard(tema, order, true)
            end
        end

        highlightThemeCards()
        applyThemeSearch()
    end

    local function colorToHex(color)
        return string.format("#%02X%02X%02X",
            math.floor(color.R * 255 + 0.5),
            math.floor(color.G * 255 + 0.5),
            math.floor(color.B * 255 + 0.5)
        )
    end

    local function hexToColor(text)
        local hex = tostring(text or ""):gsub("#", ""):gsub("%s", "")
        if #hex ~= 6 or not hex:match("^[%x]+$") then return nil end
        return Color3.fromRGB(
            tonumber(hex:sub(1, 2), 16),
            tonumber(hex:sub(3, 4), 16),
            tonumber(hex:sub(5, 6), 16)
        )
    end

    local EditorOverlay = mk("Frame", {
        Parent = Main,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 200,
    })

    local EditorPanel = mk("Frame", {
        Parent = EditorOverlay,
        Size = UDim2.new(0.9, 0, 0.9, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ZIndex = 201,
    })
    EditorPanel:SetAttribute("ThemeRole", "Background")
    corner(EditorPanel, 12)
    stroke(EditorPanel, Theme.Stroke, 1.5, 0.2)

    local EditorTitle = mk("TextLabel", {
        Parent = EditorPanel,
        Size = UDim2.new(1, -52, 0, 36),
        Position = UDim2.new(0, 14, 0, 6),
        BackgroundTransparency = 1,
        Text = "Crear Tema Personalizado",
        TextColor3 = Theme.Text,
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 202,
    })
    EditorTitle:SetAttribute("ThemeTextRole", "Text")

    local CloseEditor = mk("TextButton", {
        Parent = EditorPanel,
        Size = UDim2.new(0, 34, 0, 34),
        Position = UDim2.new(1, -40, 0, 6),
        BackgroundTransparency = 1,
        Text = "×",
        TextColor3 = Theme.Text,
        TextSize = 24,
        Font = Enum.Font.Gotham,
        ZIndex = 203,
    })
    CloseEditor:SetAttribute("ThemeTextRole", "Text")

    local EditorContent = mk("ScrollingFrame", {
        Parent = EditorPanel,
        Size = UDim2.new(1, -24, 1, -96),
        Position = UDim2.new(0, 12, 0, 46),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        CanvasSize = UDim2.new(),
        ZIndex = 202,
    })
    mk("UIListLayout", {Parent = EditorContent, Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder})

    local colorFields = {}
    local colorRoles = {
        {"Background", "Color 1 - Fondo"},
        {"Secondary", "Color 2 - Secundario"},
        {"AccentOff", "Color 3 - Acento apagado"},
        {"Text", "Color 4 - Texto"},
        {"TextDim", "Color 5 - Texto tenue"},
        {"Stroke", "Color 6 - Bordes"},
        {"Accent", "Color 7 - Acento"},
        {"ToggleOn", "Color 8 - Toggle activo"},
    }

    for index, info in ipairs(colorRoles) do
        local row = mk("Frame", {
            Parent = EditorContent,
            Size = UDim2.new(1, -4, 0, 34),
            BackgroundColor3 = Theme.Secondary,
            BorderSizePixel = 0,
            LayoutOrder = index,
            ZIndex = 202,
        })
        row:SetAttribute("ThemeRole", "Secondary")
        corner(row, 6)

        local label = mk("TextLabel", {
            Parent = row,
            Size = UDim2.new(0.48, 0, 1, 0),
            Position = UDim2.new(0, 10, 0, 0),
            BackgroundTransparency = 1,
            Text = info[2],
            TextColor3 = Theme.Text,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 203,
        })
        label:SetAttribute("ThemeTextRole", "Text")

        local swatch = mk("Frame", {
            Parent = row,
            Size = UDim2.new(0, 26, 0, 22),
            Position = UDim2.new(1, -154, 0.5, -11),
            BackgroundColor3 = Theme[info[1]],
            BorderSizePixel = 0,
            ZIndex = 203,
        })
        corner(swatch, 4)
        stroke(swatch, Theme.Stroke, 1, 0.4)

        local box = mk("TextBox", {
            Parent = row,
            Size = UDim2.new(0, 114, 0, 24),
            Position = UDim2.new(1, -122, 0.5, -12),
            BackgroundColor3 = Theme.Background,
            BorderSizePixel = 0,
            Text = colorToHex(Theme[info[1]]),
            ClearTextOnFocus = false,
            TextColor3 = Theme.Text,
            TextSize = 11,
            Font = Enum.Font.Code,
            ZIndex = 203,
        })
        box:SetAttribute("ThemeRole", "Background")
        box:SetAttribute("ThemeTextRole", "Text")
        corner(box, 4)

        colorFields[info[1]] = {Box = box, Swatch = swatch}
        box:GetPropertyChangedSignal("Text"):Connect(function()
            local parsed = hexToColor(box.Text)
            if parsed then swatch.BackgroundColor3 = parsed end
        end)
    end

    local function createEditorInput(labelText, placeholder, order)
        local holder = mk("Frame", {
            Parent = EditorContent,
            Size = UDim2.new(1, -4, 0, 48),
            BackgroundTransparency = 1,
            LayoutOrder = order,
            ZIndex = 202,
        })
        local label = mk("TextLabel", {
            Parent = holder,
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text = labelText,
            TextColor3 = Theme.Text,
            TextSize = 11,
            Font = Enum.Font.GothamBold,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 203,
        })
        label:SetAttribute("ThemeTextRole", "Text")
        local box = mk("TextBox", {
            Parent = holder,
            Size = UDim2.new(1, 0, 0, 28),
            Position = UDim2.new(0, 0, 0, 20),
            BackgroundColor3 = Theme.Secondary,
            BorderSizePixel = 0,
            Text = "",
            PlaceholderText = placeholder,
            PlaceholderColor3 = Theme.TextDim,
            TextColor3 = Theme.Text,
            ClearTextOnFocus = false,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            ZIndex = 203,
        })
        box:SetAttribute("ThemeRole", "Secondary")
        box:SetAttribute("ThemeTextRole", "Text")
        corner(box, 5)
        return box
    end

    local ThemeNameInput = createEditorInput("Nombre del tema", "Mi Tema Personalizado", 20)
    local ThemeImageInput = createEditorInput("ID de imagen (opcional)", "123456789", 21)
    local ThemeSoundInput = createEditorInput("ID de sonido (opcional)", "123456789", 22)

    local EditorStatus = mk("TextLabel", {
        Parent = EditorPanel,
        Size = UDim2.new(1, -150, 0, 34),
        Position = UDim2.new(0, 12, 1, -42),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Color3.fromRGB(235, 85, 85),
        TextSize = 11,
        Font = Enum.Font.Gotham,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 203,
    })

    local SaveThemeButton = mk("TextButton", {
        Parent = EditorPanel,
        Size = UDim2.new(0, 126, 0, 32),
        Position = UDim2.new(1, -138, 1, -40),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Text = "Crear Tema",
        TextColor3 = Theme.AccentText,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        ZIndex = 203,
    })
    SaveThemeButton:SetAttribute("ThemeRole", "Accent")
    SaveThemeButton:SetAttribute("ThemeTextRole", "AccentText")
    corner(SaveThemeButton, 6)

    local editingThemeName = nil

    openThemeEditor = function(themeName)
        editingThemeName = themeName
        EditorStatus.Text = ""
        EditorContent.CanvasPosition = Vector2.new(0, 0)

        local data = themeName and CustomThemes[themeName] or nil
        local palette = themeName and ThemePalettes[themeName] or ThemePalettes.Dark
        EditorTitle.Text = themeName and "Editar Tema Personalizado" or "Crear Tema Personalizado"
        SaveThemeButton.Text = themeName and "Guardar Cambios" or "Crear Tema"
        ThemeNameInput.Text = themeName or ""
        ThemeNameInput.TextEditable = not themeName
        ThemeImageInput.Text = data and (data.Background or "") or ""
        ThemeSoundInput.Text = data and (data.Sound or "") or ""

        for _, info in ipairs(colorRoles) do
            local color = palette[info[1]]
            colorFields[info[1]].Box.Text = colorToHex(color)
            colorFields[info[1]].Swatch.BackgroundColor3 = color
        end

        EditorOverlay.Visible = true
    end

    local function closeThemeEditor()
        EditorOverlay.Visible = false
        editingThemeName = nil
    end

    CloseEditor.MouseButton1Click:Connect(closeThemeEditor)
    CreateThemeButton.MouseButton1Click:Connect(function() openThemeEditor(nil) end)

    SaveThemeButton.MouseButton1Click:Connect(function()
        local name = ThemeNameInput.Text:match("^%s*(.-)%s*$")
        if name == "" then
            EditorStatus.Text = "Escribe un nombre para el tema."
            return
        end
        if not editingThemeName and (OfficialThemeNames[name] or CustomThemes[name]) then
            EditorStatus.Text = "Ya existe un tema con ese nombre."
            return
        end

        local paletteData = {}
        for _, info in ipairs(colorRoles) do
            local color = hexToColor(colorFields[info[1]].Box.Text)
            if not color then
                EditorStatus.Text = info[2] .. " debe usar formato #RRGGBB."
                return
            end
            paletteData[info[1]] = colorToArray(color)
        end

        local image = normalizeAssetId(ThemeImageInput.Text)
        if ThemeImageInput.Text:match("%S") and not image then
            EditorStatus.Text = "El ID de imagen no es válido."
            return
        end
        local sound = normalizeAssetId(ThemeSoundInput.Text)
        if ThemeSoundInput.Text:match("%S") and not sound then
            EditorStatus.Text = "El ID de sonido no es válido."
            return
        end

        local finalName = editingThemeName or name
        CustomThemes[finalName] = {
            Palette = paletteData,
            Background = image or "",
            Sound = sound or "",
        }
        if not editingThemeName then
            table.insert(CustomThemeOrder, finalName)
        end

        applyCustomThemeToRuntime(finalName, CustomThemes[finalName])
        SaveCustomThemes()
        if Window.CurrentTheme == finalName then
            Window:SetTheme(finalName)
        end
        rebuildThemeCards()
        closeThemeEditor()
    end)

    local DeleteOverlay = mk("Frame", {
        Parent = Main,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Color3.fromRGB(0, 0, 0),
        BackgroundTransparency = 0.35,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 220,
    })
    local DeletePanel = mk("Frame", {
        Parent = DeleteOverlay,
        Size = UDim2.new(0.72, 0, 0.46, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ZIndex = 221,
    })
    DeletePanel:SetAttribute("ThemeRole", "Background")
    corner(DeletePanel, 10)
    stroke(DeletePanel, Theme.Stroke, 1.5, 0.25)

    local DeleteLabel = mk("TextLabel", {
        Parent = DeletePanel,
        Size = UDim2.new(1, -24, 0, 70),
        Position = UDim2.new(0, 12, 0, 12),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Theme.Text,
        TextSize = 13,
        Font = Enum.Font.GothamBold,
        TextWrapped = true,
        ZIndex = 222,
    })
    DeleteLabel:SetAttribute("ThemeTextRole", "Text")

    local CancelDelete = mk("TextButton", {
        Parent = DeletePanel,
        Size = UDim2.new(0.45, 0, 0, 34),
        Position = UDim2.new(0.04, 0, 1, -46),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Text = "Cancelar",
        TextColor3 = Theme.Text,
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        ZIndex = 222,
    })
    CancelDelete:SetAttribute("ThemeRole", "Secondary")
    CancelDelete:SetAttribute("ThemeTextRole", "Text")
    corner(CancelDelete, 6)

    local ConfirmDelete = mk("TextButton", {
        Parent = DeletePanel,
        Size = UDim2.new(0.45, 0, 0, 34),
        Position = UDim2.new(0.51, 0, 1, -46),
        BackgroundColor3 = Color3.fromRGB(190, 55, 55),
        BorderSizePixel = 0,
        Text = "Eliminar",
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = 12,
        Font = Enum.Font.GothamBold,
        ZIndex = 222,
    })
    corner(ConfirmDelete, 6)

    local pendingDeleteTheme = nil
    confirmDeleteTheme = function(themeName)
        pendingDeleteTheme = themeName
        DeleteLabel.Text = "¿Eliminar el tema personalizado '" .. themeName .. "'?"
        DeleteOverlay.Visible = true
    end
    CancelDelete.MouseButton1Click:Connect(function()
        DeleteOverlay.Visible = false
        pendingDeleteTheme = nil
    end)
    ConfirmDelete.MouseButton1Click:Connect(function()
        local themeName = pendingDeleteTheme
        if not themeName or not CustomThemes[themeName] then return end

        if Window.CurrentTheme == themeName then
            Window:SetTheme("Dark")
        end

        CustomThemes[themeName] = nil
        ThemePalettes[themeName] = nil
        ThemeBackgroundImages[themeName] = nil
        ThemeClickSounds[themeName] = nil
        for i = #CustomThemeOrder, 1, -1 do
            if CustomThemeOrder[i] == themeName then
                table.remove(CustomThemeOrder, i)
            end
        end

        SaveCustomThemes()
        DeleteOverlay.Visible = false
        pendingDeleteTheme = nil
        rebuildThemeCards()
    end)

    ThemeSearchBox:GetPropertyChangedSignal("Text"):Connect(applyThemeSearch)
    rebuildThemeCards()
    end
    BuildTemasTab()

    -- TAB 3: EFECTOS (Automático)
    local AutoTabEfectos = Window:CreateTab("Efectos", "Effects", "rbxassetid://132646825035547")

    --// ══════════════════════════════════════════════════════════════════
    --// PESTAÑA DE EFECTOS REDISEÑADA DESDE CERO
    --// Lista simple + preview visual tipo "test de color" para cada opción
    --// ══════════════════════════════════════════════════════════════════
    local EffectsPage = AutoTabEfectos.Page
    EffectsPage.ScrollBarThickness = 2

    local EffectsRoot = mk("Frame", {
        Parent = EffectsPage,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 9,
        LayoutOrder = 1,
    })

    mk("UIPadding", {
        Parent = EffectsRoot,
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 10),
    })

    mk("UIListLayout", {
        Parent = EffectsRoot,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    local effectRows = {}

    local function isEffectActive(mode)
        return Window.CurrentTextEffect == mode or (mode == "Off" and Window.CurrentTextEffect == "Off")
    end

    local function refreshEffectRows()
        for _, row in ipairs(effectRows) do
            local active = isEffectActive(row.mode)
            if row.badge then
                row.badge.Visible = active
                row.badge.BackgroundColor3 = Theme.Accent
            end
            if row.card then
                row.card.BackgroundTransparency = active and 0.06 or 0.20
            end
            if row.stroke then
                row.stroke.Transparency = active and 0.18 or 0.75
            end
            if row.title then
                row.title.TextColor3 = active and Theme.Accent or Theme.Text
            end
            if row.desc then
                row.desc.TextColor3 = active and Theme.Text or Theme.TextDim
            end
        end
    end

    Window._refreshEffectRows = refreshEffectRows

    local function setPreviewStripColors(stripA, stripB, stripC, c1, c2, c3)
        if stripA then stripA.BackgroundColor3 = c1 end
        if stripB then stripB.BackgroundColor3 = c2 end
        if stripC then stripC.BackgroundColor3 = c3 end
    end

    local function createPreview(parent, mode, accentColor)
        local preview = mk("Frame", {
            Parent = parent,
            Size = UDim2.new(0, 108, 0, 52),
            Position = UDim2.new(0, 14, 0.5, -26),
            BackgroundColor3 = Theme.Secondary,
            BackgroundTransparency = 0.14,
            BorderSizePixel = 0,
            ZIndex = 11,
        })
        preview:SetAttribute("ThemeRole", "Background")
        corner(preview, 12)
        local previewStroke = stroke(preview, Theme.Accent, 1, 0.65)
        previewStroke:SetAttribute("ThemeRole", "Accent")

        local stripW = 30
        local gap = 4
        local s1 = mk("Frame", {
            Parent = preview,
            Size = UDim2.new(0, stripW, 1, -10),
            Position = UDim2.new(0, 5, 0, 5),
            BackgroundColor3 = accentColor,
            BorderSizePixel = 0,
            ZIndex = 12,
        })
        corner(s1, 8)

        local s2 = mk("Frame", {
            Parent = preview,
            Size = UDim2.new(0, stripW, 1, -10),
            Position = UDim2.new(0, 5 + stripW + gap, 0, 5),
            BackgroundColor3 = accentColor,
            BorderSizePixel = 0,
            ZIndex = 12,
        })
        corner(s2, 8)

        local s3 = mk("Frame", {
            Parent = preview,
            Size = UDim2.new(0, stripW, 1, -10),
            Position = UDim2.new(0, 5 + (stripW + gap) * 2, 0, 5),
            BackgroundColor3 = accentColor,
            BorderSizePixel = 0,
            ZIndex = 12,
        })
        corner(s3, 8)

        mk("TextLabel", {
            Parent = preview,
            Size = UDim2.new(1, -10, 0, 14),
            Position = UDim2.new(0, 5, 1, -18),
            BackgroundTransparency = 1,
            Text = "test de color",
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            TextColor3 = Theme.Text,
            TextWrapped = true,
            ZIndex = 13,
        })

        local previewData = {
            Off = {Color3.fromRGB(230, 230, 230), Color3.fromRGB(180, 180, 180), Color3.fromRGB(120, 120, 120)},
            WhiteCyan = {Color3.fromRGB(255, 255, 255), Color3.fromRGB(130, 225, 255), Color3.fromRGB(90, 180, 255)},
            WhitePink = {Color3.fromRGB(255, 255, 255), Color3.fromRGB(255, 145, 205), Color3.fromRGB(220, 90, 170)},
            Rainbow = {Color3.fromRGB(255, 70, 70), Color3.fromRGB(255, 210, 0), Color3.fromRGB(80, 120, 255)},
            RainbowFast = {Color3.fromRGB(255, 0, 180), Color3.fromRGB(0, 220, 255), Color3.fromRGB(255, 170, 0)},
            RainbowDarkWhite = {Color3.fromRGB(10, 10, 10), Color3.fromRGB(120, 120, 120), Color3.fromRGB(255, 255, 255)},
            ErisRainbow = {Color3.fromRGB(255, 70, 70), Color3.fromRGB(40, 10, 15), Color3.fromRGB(255, 255, 255)},
            FireEffect = {Color3.fromRGB(255, 70, 20), Color3.fromRGB(255, 140, 50), Color3.fromRGB(255, 220, 120)},
            NeonPulse = {Color3.fromRGB(0, 255, 170), Color3.fromRGB(120, 255, 220), Color3.fromRGB(210, 255, 240)},
            GoldenShine = {Color3.fromRGB(255, 210, 60), Color3.fromRGB(255, 240, 170), Color3.fromRGB(255, 255, 255)},
            IceBlue = {Color3.fromRGB(120, 220, 255), Color3.fromRGB(200, 240, 255), Color3.fromRGB(245, 250, 255)},
            PurpleGlow = {Color3.fromRGB(170, 90, 255), Color3.fromRGB(220, 180, 255), Color3.fromRGB(255, 245, 255)},
            MatrixGreen = {Color3.fromRGB(0, 200, 60), Color3.fromRGB(80, 255, 120), Color3.fromRGB(190, 255, 200)},
            Sunset = {Color3.fromRGB(255, 140, 80), Color3.fromRGB(255, 80, 150), Color3.fromRGB(180, 80, 255)},
        }

        local sample = previewData[mode] or previewData.Off
        setPreviewStripColors(s1, s2, s3, sample[1], sample[2], sample[3])

        if mode == "Rainbow" or mode == "RainbowFast" or mode == "MatrixGreen" or mode == "Sunset" then
            local grad = mk("UIGradient", {
                Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, sample[1]),
                    ColorSequenceKeypoint.new(0.5, sample[2]),
                    ColorSequenceKeypoint.new(1, sample[3]),
                }),
                Transparency = NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0.08),
                    NumberSequenceKeypoint.new(0.5, 0),
                    NumberSequenceKeypoint.new(1, 0.08),
                }),
                Offset = Vector2.new(-1.5, 0),
            }, preview)

            local speed = (mode == "RainbowFast" and 0.8) or 1.6
            TweenService:Create(
                grad,
                TweenInfo.new(speed, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1, false),
                {Offset = Vector2.new(1.5, 0)}
            ):Play()
        end

        return preview
    end

    local function createEffectRow(mode, titleES, titleEN, descES, descEN, accentColor, layoutOrder)
        local Card = mk("Frame", {
            Parent = EffectsRoot,
            Size = UDim2.new(1, 0, 0, 84),
            BackgroundColor3 = Theme.Secondary,
            BackgroundTransparency = 0.20,
            BorderSizePixel = 0,
            ZIndex = 10,
            LayoutOrder = layoutOrder,
            ClipsDescendants = true,
        })
        Card:SetAttribute("ThemeRole", "Secondary")
        corner(Card, 12)
        local CardStroke = stroke(Card, Theme.Stroke, 1.5, 0.75)
        CardStroke:SetAttribute("ThemeRole", "Stroke")

        createPreview(Card, mode, accentColor)

        local TitleLabel = mk("TextLabel", {
            Parent = Card,
            Size = UDim2.new(1, -160, 0, 22),
            Position = UDim2.new(0, 134, 0, 12),
            BackgroundTransparency = 1,
            Text = GetText(titleES, titleEN),
            Font = Enum.Font.GothamBold,
            TextSize = 14,
            TextColor3 = Theme.Text,
            TextXAlignment = Enum.TextXAlignment.Left,
            ZIndex = 11,
        })
        TitleLabel:SetAttribute("ThemeTextRole", "Text")
        TitleLabel:SetAttribute("TextSpanish", titleES)
        TitleLabel:SetAttribute("TextEnglish", titleEN)

        local DescLabel = mk("TextLabel", {
            Parent = Card,
            Size = UDim2.new(1, -160, 0, 18),
            Position = UDim2.new(0, 134, 0, 38),
            BackgroundTransparency = 1,
            Text = GetText(descES, descEN),
            Font = Enum.Font.Gotham,
            TextSize = 11,
            TextColor3 = Theme.TextDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 11,
        })
        DescLabel:SetAttribute("ThemeTextRole", "TextDim")
        DescLabel:SetAttribute("TextSpanish", descES)
        DescLabel:SetAttribute("TextEnglish", descEN)

        local Badge = mk("Frame", {
            Parent = Card,
            Size = UDim2.fromOffset(62, 24),
            Position = UDim2.new(1, -74, 0.5, -12),
            BackgroundColor3 = accentColor,
            BackgroundTransparency = 0.0,
            BorderSizePixel = 0,
            ZIndex = 12,
            Visible = isEffectActive(mode),
        })
        Badge:SetAttribute("ThemeRole", "Accent")
        corner(Badge, 999)
        local BadgeLabel = mk("TextLabel", {
            Parent = Badge,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = GetText("ACTIVO", "ACTIVE"),
            Font = Enum.Font.GothamBold,
            TextSize = 10,
            TextColor3 = Theme.AccentText,
            ZIndex = 13,
        })
        BadgeLabel:SetAttribute("ThemeTextRole", "AccentText")

        local Clicker = mk("TextButton", {
            Parent = Card,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 14,
        })

        local function press()
            playSound(Sounds.Click, 0.6)
            Window:SetTextEffect(mode)
            refreshEffectRows()
        end

        Clicker.MouseButton1Click:Connect(press)

        Card.MouseEnter:Connect(function()
            TweenService:Create(Card, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundTransparency = isEffectActive(mode) and 0.04 or 0.14}):Play()
        end)
        Card.MouseLeave:Connect(function()
            TweenService:Create(Card, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundTransparency = isEffectActive(mode) and 0.06 or 0.20}):Play()
        end)

        table.insert(effectRows, {
            card = Card,
            badge = Badge,
            stroke = CardStroke,
            mode = mode,
            title = TitleLabel,
            desc = DescLabel,
            accent = accentColor,
        })
    end

    local effectSpecs = {
        {mode = "Off", titleES = "Normal (Blanco)", titleEN = "Normal (White)", descES = "Sin efecto - color del tema", descEN = "No effect - theme color", accent = Color3.fromRGB(200, 200, 200)},
        {mode = "WhiteCyan", titleES = "Blanco-Celeste", titleEN = "White-Cyan", descES = "Pulso suave entre blanco y celeste", descEN = "Soft pulse white to cyan", accent = Color3.fromRGB(100, 220, 255)},
        {mode = "WhitePink", titleES = "Blanco-Rosa", titleEN = "White-Pink", descES = "Oscilación lenta blanco y rosa", descEN = "Slow oscillation white to pink", accent = Color3.fromRGB(255, 130, 200)},
        {mode = "Rainbow", titleES = "Arcoíris", titleEN = "Rainbow", descES = "Ciclo completo del espectro de color", descEN = "Full color spectrum cycle", accent = Color3.fromRGB(255, 200, 0)},
        {mode = "RainbowFast", titleES = "Arcoíris rápido", titleEN = "Fast Rainbow", descES = "Arcoíris ultra veloz", descEN = "Ultra-fast rainbow", accent = Color3.fromRGB(255, 80, 255)},
        {mode = "RainbowDarkWhite", titleES = "Dark-White", titleEN = "Dark-White", descES = "Transición lenta negro a blanco", descEN = "Slow transition black to white", accent = Color3.fromRGB(160, 160, 160)},
        {mode = "ErisRainbow", titleES = "Rojo-Negro-Blanco", titleEN = "Red-Black-White", descES = "Transición especial rojo, negro y blanco", descEN = "Special red, black and white transition", accent = Color3.fromRGB(255, 90, 90)},
        {mode = "FireEffect", titleES = "Fuego", titleEN = "Fire", descES = "Llamas rojo, naranja y amarillo", descEN = "Flames red, orange and yellow", accent = Color3.fromRGB(255, 100, 30)},
        {mode = "NeonPulse", titleES = "Neón verde", titleEN = "Neon Green", descES = "Pulso neón verde-cian brillante", descEN = "Bright neon green-cyan pulse", accent = Color3.fromRGB(0, 220, 160)},
        {mode = "GoldenShine", titleES = "Brillo dorado", titleEN = "Golden Shine", descES = "Brillo cálido dorado y blanco", descEN = "Warm golden and white glow", accent = Color3.fromRGB(255, 210, 60)},
        {mode = "IceBlue", titleES = "Hielo azul", titleEN = "Ice Blue", descES = "Cristal de hielo azul frío", descEN = "Cold blue ice crystal", accent = Color3.fromRGB(120, 200, 255)},
        {mode = "PurpleGlow", titleES = "Brillo violeta", titleEN = "Purple Glow", descES = "Pulso profundo entre violeta y lila", descEN = "Deep violet to lilac pulse", accent = Color3.fromRGB(160, 80, 255)},
        {mode = "MatrixGreen", titleES = "Matrix verde", titleEN = "Matrix Green", descES = "Parpadeo verde tipo Matrix", descEN = "Digital Matrix green flicker", accent = Color3.fromRGB(0, 200, 60)},
        {mode = "Sunset", titleES = "Atardecer", titleEN = "Sunset", descES = "Coral, magenta y naranja cálido", descEN = "Coral, magenta and warm orange", accent = Color3.fromRGB(255, 140, 80)},
    }

    for i, spec in ipairs(effectSpecs) do
        createEffectRow(spec.mode, spec.titleES, spec.titleEN, spec.descES, spec.descEN, spec.accent, i)
    end

    refreshEffectRows()
    --//  4TA PESTAÑA PERMANENTE: AJUSTES
    local AutoTabAjustes = Window:CreateTab("Ajustes", "Settings", "rbxassetid://130729134186771")
    AutoTabAjustes:CreateLabel("Configuración", "Settings", 14)
    AutoTabAjustes:CreateDivider()
    
    AutoTabAjustes:CreateToggle("Freeze Icono", "Freeze Icon", false, function(state)
        IconoCongelado = state
        if Window.Dragon and Window.Dragon.Draggable then
            Window.Dragon.Draggable = not state
        end
        if state then
            AutoTabAjustes:CreateLabel("Icono congelado (No se puede mover)", "Icon frozen (Cannot be moved)", 11)
        end
    end)
    
    --// ════════════════════════════════════════════════════════════════
    AutoTabAjustes:CreateDivider()
    AutoTabAjustes:CreateLabel("Sonidos", "Sounds", 12)
    AutoTabAjustes:CreateToggle("Sonidos Dinámicos", "Dynamic Sounds", DynamicClickSoundsEnabled, function(state)
        DynamicClickSoundsEnabled = state
        AutoTabAjustes:CreateLabel(
            state and " Sonidos por tema activados" or " Sonidos desactivados",
            state and " Theme sounds enabled"      or " Sounds disabled",
            11
        )
    end)

    --// ════════════════════════════════════════════════════════════════
    AutoTabAjustes:CreateDivider()
    AutoTabAjustes:CreateLabel("Sliders", "Sliders", 12)
    AutoTabAjustes:CreateToggle("Ocultar Sliders", "Hide Sliders", SlidersHidden, function(state)
        SlidersHidden = state
        for _, obj in ipairs(Window.ScreenGui:GetDescendants()) do
            if obj:GetAttribute("IsSliderHolder") then
                obj.Visible = not state
            end
        end
        SavedConfig.HideSliders = state
        SaveConfig()
    end)

    --// ════════════════════════════════════════════════════════════════
    --// IDIOMA / LANGUAGE
    --// ════════════════════════════════════════════════════════════════
    AutoTabAjustes:CreateDivider()
    AutoTabAjustes:CreateLabel("Idioma", "Language", 12)

    local toggleES, toggleEN

    toggleES = AutoTabAjustes:CreateToggle(
        "Español", "Spanish",
        LanguageSystem.CurrentLanguage == "es",
        function(state)
            if state then
                LanguageSystem.CurrentLanguage = "es"
                LanguageSystem.Config.Language = "es"
                SaveConfig()
                if toggleEN then toggleEN.SetValue(false) end
            else
                toggleES.SetValue(true)
            end
        end
    )

    toggleEN = AutoTabAjustes:CreateToggle(
        "English", "English",
        LanguageSystem.CurrentLanguage == "en",
        function(state)
            if state then
                LanguageSystem.CurrentLanguage = "en"
                LanguageSystem.Config.Language = "en"
                SaveConfig()
                if toggleES then toggleES.SetValue(false) end
            else
                toggleEN.SetValue(true)
            end
        end
    )

    AutoTabAjustes:CreateDivider()
    AutoTabAjustes:CreateLabel(" Apariencia", " Appearance", 12)
    AutoTabAjustes:CreateLabel("Versión: v28 ULTRA MEJORADA", "Version: v28 ULTRA IMPROVED", 10)
    AutoTabAjustes:CreateLabel("Chat Fullscreen:  ACTIVO", "Chat Fullscreen:  ACTIVE", 10)
    AutoTabAjustes:CreateLabel("Colores Dinámicos:  ACTIVO", "Dynamic Colors:  ACTIVE", 10)

    
    --//  SISTEMA DE CHAT v27 (NUEVO)
    --// ════════════════════════════════════════════════════════════════
    

    --// CHAT SYSTEM
    --// ═════════════════════════════════════════════════════════════════════

    local ChatMessages = {}
    local MAX_MESSAGES = 100
    local MAX_CHAR = 500

    local function AddChatMessage(playerName, playerUserId, message, timestamp)
    	if #ChatMessages >= MAX_MESSAGES then
    		table.remove(ChatMessages, 1)
    	end

    	table.insert(ChatMessages, {
    		playerName = playerName or "Unknown",
    		playerUserId = playerUserId or 0,
    		message = message or "",
    		timestamp = timestamp or os.date("%H:%M:%S"),
    	})
    end

    local function GetChatHistory()
    	return ChatMessages
    end

    local function GetPlayerAvatar(userId)
    	userId = tonumber(userId) or 0
    	return ("rbxthumb://type=AvatarHeadShot&id=%d&w=48&h=48"):format(userId)
    end

    --// ═════════════════════════════════════════════════════════════════════
    --// CHAT GLOBAL BACKEND SYNC (v28 - Tiempo Real)
    --// ═════════════════════════════════════════════════════════════════════
    --// Backend: Node.js + Express corriendo en Replit
    --// Sincroniza mensajes entre TODOS los jugadores conectados
    --// ═════════════════════════════════════════════════════════════════════

    local BACKEND_URL = "https://yin-chat-production.up.railway.app"
    local ChatSyncPollRate = 2  -- segundos entre cada consulta al backend
    local knownServerIds = {}   -- IDs de mensajes de servidor ya renderizados
    local backendConnected = false

    --// Función universal de HTTP request
    --// Usa la función nativa del executor si existe (evita el error
    --// "The current thread cannot call this function (blocked)" que da
    --// HttpService:PostAsync en algunos executors móviles como Delta).
    --// Si no encuentra ninguna, cae a HttpService como último recurso.
    local UniversalRequest = (syn and syn.request)
        or (http and http.request)
        or fluxus_request
        or http_request
        or request
        or (function(opts)
            -- Fallback: HttpService (puede fallar en algunos executors)
            local method = opts.Method or "GET"
            local ok, body = pcall(function()
                if method == "POST" then
                    return HttpService:PostAsync(opts.Url, opts.Body or "", Enum.HttpContentType.ApplicationJson)
                else
                    return HttpService:GetAsync(opts.Url)
                end
            end)
            if ok then
                return { Success = true, Body = body, StatusCode = 200 }
            else
                return { Success = false, Body = tostring(body), StatusCode = 0 }
            end
        end)

    --// Enviar mensaje al backend (no bloqueante)
    local function BackendSendMessage(playerName, playerId, message)
        task.spawn(function()
            local body = HttpService:JSONEncode({
                playerName = tostring(playerName),
                playerId = tostring(playerId),
                message = tostring(message),
            })

            local ok, result = pcall(function()
                return UniversalRequest({
                    Url = BACKEND_URL .. "/api/chat/send",
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = body,
                })
            end)

            if not ok or not result or (result.Success == false) then
                warn("[ChatGlobal] Error al enviar mensaje al backend:", ok and (result and result.StatusCode) or result)
            end
        end)
    end

    --// Traducir un mensaje bajo demanda (botón manual por mensaje)
    --// callback(translatedText, sourceLanguage, targetLanguage, errorMessage)
    local function TranslateMessage(text, targetLanguage, callback)
        task.spawn(function()
            local body = HttpService:JSONEncode({
                text = tostring(text),
                auto = true, -- el backend detecta el idioma de origen
                to = targetLanguage, -- el destino siempre es el idioma elegido por el lector
            })

            local ok, result = pcall(function()
                return UniversalRequest({
                    Url = BACKEND_URL .. "/api/translate",
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body = body,
                })
            end)

            if not ok or not result or result.Success == false then
                warn("[ChatGlobal] Error al traducir:", ok and (result and result.StatusCode) or result)
                callback(nil, nil, targetLanguage, "request_failed")
                return
            end

            local decodeOk, data = pcall(function()
                return HttpService:JSONDecode(result.Body)
            end)

            if decodeOk and data and data.success and data.translated then
                callback(data.translated, data.from, data.to, nil)
            else
                warn("[ChatGlobal] Respuesta de /api/translate inválida:", result.Body)
                callback(nil, nil, targetLanguage, "invalid_response")
            end
        end)
    end

    --// Polling: pide mensajes nuevos cada ChatSyncPollRate segundos
    --// Se conecta después de crear el ChatTab (usa RenderMessage y AddChatMessage)
    local function StartBackendPolling(onNewMessage)
        task.spawn(function()
            while true do
                local ok, response = pcall(function()
                    return UniversalRequest({
                        Url = BACKEND_URL .. "/api/chat/messages",
                        Method = "GET",
                    })
                end)

                if ok and response and response.Body then
                    local success, data = pcall(HttpService.JSONDecode, HttpService, response.Body)
                    if success and data and data.messages then
                        if not backendConnected then
                            backendConnected = true
                            print("[ChatGlobal] Conectado al backend correctamente")
                        end

                        for _, msg in ipairs(data.messages) do
                            if not knownServerIds[msg.id] then
                                knownServerIds[msg.id] = true
                                -- Evitar re-mostrar el mensaje que YO mismo envié
                                if tostring(msg.playerId) ~= tostring(LocalPlayer.UserId) then
                                    task.spawn(onNewMessage, msg)
                                end
                            end
                        end

                        -- ACTUALIZAR CONTADOR DE USUARIOS ONLINE
                        if data.onlineCount then
                            pcall(function()
                                OnlineLabel.Text = tostring(data.onlineCount)
                            end)
                            TopBarOnlineLabel.Text = tostring(data.onlineCount)
                        elseif data.messages then
                            -- Contar IDs únicos de los últimos mensajes como estimado
                            local uniqueIds = {}
                            for _, msg in ipairs(data.messages) do
                                if msg.playerId then
                                    uniqueIds[tostring(msg.playerId)] = true
                                end
                            end
                            local count = 0
                            for _ in pairs(uniqueIds) do count = count + 1 end
                            pcall(function()
                                OnlineLabel.Text = tostring(count)
                            end)
                            TopBarOnlineLabel.Text = tostring(count)
                        end
                    end
                else
                    if backendConnected then
                        warn("[ChatGlobal] Se perdió conexión con el backend")
                    end
                    backendConnected = false
                    pcall(function()
                        OnlineLabel.Text = "0"
                    end)
                    TopBarOnlineLabel.Text = "0"
                end

                task.wait(ChatSyncPollRate)
            end
        end)
    end

    local ChatTab = Window:CreateTab("Chat", "Chat", "rbxassetid://115216752353020")
    local ChatTabPage = ChatTab.Page
    
    --// Deshabilitar el scroll de ChatTab.Page - Solo ChatContainer debe scrollear
    ChatTabPage.AutomaticCanvasSize = Enum.AutomaticSize.None
    ChatTabPage.CanvasSize = UDim2.new()
    ChatTabPage.ScrollBarThickness = 0
    ChatTabPage.ScrollingEnabled = false

    --// ════════════════════════════════════════════════════════════
    --// BADGE DE MENSAJES NO LEÍDOS 🔴 (v28)
    --// Aparece encima del ícono de Chat cuando hay mensajes nuevos
    --// Desaparece al abrir la pestaña, vuelve con nuevos mensajes
    --// ════════════════════════════════════════════════════════════
    local unreadCount = 0
    local chatIsOpen = false

    local ChatBadge = mk("Frame", {
        Parent = ChatTab.Button,
        Size = UDim2.fromOffset(18, 18),
        --// Esquina superior izquierda sobre el ícono (el ícono está en x=7, y centrado)
        Position = UDim2.new(0, 1, 0, 1),
        AnchorPoint = Vector2.new(0, 0),
        BackgroundColor3 = Color3.fromRGB(255, 55, 55),
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 20,
        ClipsDescendants = false,
    })
    corner(ChatBadge, 999)

    local ChatBadgeLabel = mk("TextLabel", {
        Parent = ChatBadge,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "0",
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Center,
        TextYAlignment = Enum.TextYAlignment.Center,
        ZIndex = 21,
    })

    local function updateBadge()
        if unreadCount <= 0 or chatIsOpen then
            ChatBadge.Visible = false
        else
            ChatBadge.Visible = true
            ChatBadgeLabel.Text = unreadCount > 99 and "99+" or tostring(unreadCount)
            -- Animación de pop al aparecer
            ChatBadge.Size = UDim2.fromOffset(10, 10)
            TweenService:Create(
                ChatBadge,
                TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { Size = UDim2.fromOffset(18, 18) }
            ):Play()
        end
    end

    local function addUnread()
        if not chatIsOpen then
            unreadCount = unreadCount + 1
            updateBadge()
        end
    end

    local function clearUnread()
        unreadCount = 0
        chatIsOpen = true
        updateBadge()
    end

    --// Detectar cuando el usuario abre/cierra la pestaña de Chat
    ChatTabPage:GetPropertyChangedSignal("Visible"):Connect(function()
        if ChatTabPage.Visible then
            clearUnread()
        else
            chatIsOpen = false
        end
    end)

    --// HOOK: reproduce el audio premium al entrar a la pestaña de Chat
    --// Solo suena si el sticker premium está dentro de los últimos PREMIUM_STICKER_DEPTH mensajes.
    ChatTabPage:GetPropertyChangedSignal("Visible"):Connect(function()
        if not ChatTabPage.Visible then return end
        if not PremiumStickerSound then return end
        local msgs  = ChatMessages
        local total = #msgs
        local tag   = "[[STICKER:" .. PREMIUM_STICKER_ASSET .. "]]"
        for i = math.max(1, total - PREMIUM_STICKER_DEPTH + 1), total do
            if msgs[i] and msgs[i].message == tag then
                PremiumStickerSound:Stop()
                PremiumStickerSound:Play()
                break
            end
        end
    end)

    local ChatRoot = mk("Frame", {
    	Parent = ChatTabPage,
    	Size = UDim2.new(1, 0, 1, 0),
    	BackgroundTransparency = 1,
    	BorderSizePixel = 0,
    	LayoutOrder = 1,
    	ZIndex = 10,
    })

    --// Mini-header dentro de ChatRoot
    local ChatHeader = mk("Frame", {
    	Parent = ChatRoot,
    	Size = UDim2.new(1, 0, 0, 50),
    	Position = UDim2.new(0, 0, 0, 0),
    	BackgroundTransparency = 1,
    	BorderSizePixel = 0,
    	ZIndex = 10,
    })

    mk("UIListLayout", {
    	Parent = ChatHeader,
    	Padding = UDim.new(0, 8),
    	SortOrder = Enum.SortOrder.LayoutOrder,
    	VerticalAlignment = Enum.VerticalAlignment.Top,
    })

    local HeaderLabel = mk("TextLabel", {
    	Parent = ChatHeader,
    	Size = UDim2.new(1, 0, 0, 20),
    	BackgroundTransparency = 1,
    	Text = "Global Chat",
    	Font = Enum.Font.GothamBold,
    	TextSize = 14,
    	TextColor3 = Theme.Text,
    	TextXAlignment = Enum.TextXAlignment.Center,
    	LayoutOrder = 1,
    	ZIndex = 11,
    })

    -- CONTADOR DE USUARIOS ONLINE
    local OnlineCounter = mk("Frame", {
        Parent = ChatHeader,
        Size = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(1, -8, 0, 4),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 12,
        AutomaticSize = Enum.AutomaticSize.X,
    })

    local OnlineIcon = mk("ImageLabel", {
        Parent = OnlineCounter,
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 0, 0.5, -9),
        BackgroundTransparency = 1,
        Image = "rbxassetid://74246983577629",
        ImageColor3 = Theme.Accent,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 13,
    })

    local OnlineLabel = mk("TextLabel", {
        Parent = OnlineCounter,
        Size = UDim2.new(0, 40, 0, 18),
        Position = UDim2.new(0, 22, 0.5, -9),
        BackgroundTransparency = 1,
        Text = "...",
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        TextColor3 = Theme.Accent,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 13,
    })

    local HeaderDivider = mk("Frame", {
    	Parent = ChatHeader,
    	Size = UDim2.new(1, 0, 0, 1),
    	BackgroundColor3 = Theme.Stroke,
    	BorderSizePixel = 0,
    	LayoutOrder = 2,
    	ZIndex = 11,
    })

    local ChatContainer = mk("ScrollingFrame", {
    	Parent = ChatRoot,
    	Size = UDim2.new(1, 0, 1, -94),
    	Position = UDim2.new(0, 0, 0, 50),
    	BackgroundColor3 = Theme.Background,
    	BackgroundTransparency = 1,
    	BorderSizePixel = 0,
    	ScrollBarThickness = 2,
    	CanvasSize = UDim2.new(0, 0, 0, 0),
    	AutomaticCanvasSize = Enum.AutomaticSize.Y,
    	ScrollingDirection = Enum.ScrollingDirection.Y,
    	ClipsDescendants = true,
    	ZIndex = 11,
    })
    corner(ChatContainer, 6)

    mk("UIListLayout", {
    	Parent = ChatContainer,
    	Padding = UDim.new(0, 8),
    	SortOrder = Enum.SortOrder.LayoutOrder,
    	VerticalAlignment = Enum.VerticalAlignment.Top,
    })

    mk("UIPadding", {
    	Parent = ChatContainer,
    	PaddingTop = UDim.new(0, 6),
    	PaddingLeft = UDim.new(0, 8),
    	PaddingRight = UDim.new(0, 8),
    	PaddingBottom = UDim.new(0, 6),
    })

    local ChatFooter = mk("Frame", {
    	Parent = ChatRoot,
    	Size = UDim2.new(1, 0, 0, 44),
    	Position = UDim2.new(0, 0, 1, -44),
    	BackgroundTransparency = 1,
    	BorderSizePixel = 0,
    	ZIndex = 20,
    })

    local MessageInput = mk("TextBox", {
    	Parent = ChatFooter,
    	Size = UDim2.new(1, -120, 0, 36),
    	Position = UDim2.new(0, 50, 0.5, -18),
    	BackgroundColor3 = Theme.Secondary,
    	BackgroundTransparency = 0.25,
    	BorderSizePixel = 0,
    	Text = "",
    	ClearTextOnFocus = false,
    	PlaceholderText = "Escribir...",
    	PlaceholderColor3 = Theme.TextDim,
    	TextColor3 = Theme.Text,
    	TextSize = 13,
    	Font = Enum.Font.Gotham,
    	TextXAlignment = Enum.TextXAlignment.Left,
    	ZIndex = 21,
    })
    MessageInput:SetAttribute("ThemeRole", "Secondary")
    corner(MessageInput, 8)
    mk("UIPadding", {Parent = MessageInput, PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 12)})

    local SendButton = mk("ImageButton", {
    	Parent = ChatFooter,
    	Size = UDim2.new(0, 60, 0, 36),
    	Position = UDim2.new(1, -68, 0.5, -18),
    	BackgroundColor3 = Theme.Accent,
    	BorderSizePixel = 0,
    	Image = "rbxassetid://132362297660069",
    	ImageColor3 = Color3.fromRGB(255, 255, 255),
    	ScaleType = Enum.ScaleType.Fit,
    	ZIndex = 21,
    })
    SendButton:SetAttribute("ThemeRole", "Accent")
    corner(SendButton, 8)

    local CharLabel = mk("TextLabel", {
    	Parent = ChatFooter,
    	Size = UDim2.new(0, 90, 0, 12),
    	Position = UDim2.new(0, 0, 1, -10),
    	BackgroundTransparency = 1,
    	Text = "0 / 500",
    	Font = Enum.Font.Gotham,
    	TextSize = 9,
    	TextColor3 = Theme.TextDim,
    	TextXAlignment = Enum.TextXAlignment.Left,
    	ZIndex = 21,
    })

    -- BOTÓN STICKER (izquierda del input)
    local StickerButton = mk("ImageButton", {
        Parent = ChatFooter,
        Size = UDim2.new(0, 36, 0, 36),
        Position = UDim2.new(0, 8, 0.5, -18),
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.25,
        BorderSizePixel = 0,
        Image = "rbxassetid://70677501354748",
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 21,
    })
    StickerButton:SetAttribute("ThemeRole", "Secondary")
    corner(StickerButton, 8)

    -- PANEL DE STICKERS
    local StickerPanel = mk("Frame", {
        Parent = ChatRoot,
        Size = UDim2.new(1, -16, 0, 230),
        Position = UDim2.new(0, 8, 1, -280),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.05,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 50,
    })
    StickerPanel:SetAttribute("ThemeRole", "Background")
    corner(StickerPanel, 12)
    stroke(StickerPanel, Theme.Stroke, 1, 0.5)

    -- HEADER DEL PANEL
    local PanelHeader = mk("Frame", {
        Parent = StickerPanel,
        Size = UDim2.new(1, 0, 0, 38),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 51,
    })

    local TabStickers = mk("TextButton", {
        Parent = PanelHeader,
        Size = UDim2.new(0, 90, 0, 28),
        Position = UDim2.new(0, 8, 0.5, -14),
        BackgroundColor3 = Theme.Accent,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Text = "Stickers",
        TextColor3 = Theme.AccentText,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        ZIndex = 52,
    })
    corner(TabStickers, 6)

    local TabMisStickers = mk("TextButton", {
        Parent = PanelHeader,
        Size = UDim2.new(0, 100, 0, 28),
        Position = UDim2.new(0, 106, 0.5, -14),
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Text = "Mis Stickers",
        TextColor3 = Theme.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 12,
        ZIndex = 52,
    })
    corner(TabMisStickers, 6)

    -- BOTÓN CERRAR CON ASSET X
    local PanelClose = mk("ImageButton", {
        Parent = PanelHeader,
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -36, 0.5, -14),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        Image = "rbxassetid://132418587917225",
        ImageColor3 = Theme.TextDim,
        ScaleType = Enum.ScaleType.Fit,
        ZIndex = 52,
    })

    -- GRID STICKERS DEFAULT
    local StickerGrid = mk("ScrollingFrame", {
        Parent = StickerPanel,
        Size = UDim2.new(1, -16, 1, -46),
        Position = UDim2.new(0, 8, 0, 42),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ZIndex = 51,
    })
    mk("UIGridLayout", {
        Parent = StickerGrid,
        CellSize = UDim2.new(0, 68, 0, 68),
        CellPadding = UDim2.new(0, 8, 0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
    })
    mk("UIPadding", {
        Parent = StickerGrid,
        PaddingTop = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
    })

    -- GRID MIS STICKERS
    local MisStickerGrid = mk("ScrollingFrame", {
        Parent = StickerPanel,
        Size = UDim2.new(1, -16, 1, -46),
        Position = UDim2.new(0, 8, 0, 42),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Visible = false,
        ZIndex = 51,
    })
    mk("UIGridLayout", {
        Parent = MisStickerGrid,
        CellSize = UDim2.new(0, 68, 0, 68),
        CellPadding = UDim2.new(0, 8, 0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
    })
    mk("UIPadding", {
        Parent = MisStickerGrid,
        PaddingTop = UDim.new(0, 4),
        PaddingLeft = UDim.new(0, 4),
    })

    -- BOTÓN "+" AGREGAR STICKER CUSTOM
    local AddStickerBtn = mk("TextButton", {
        Parent = MisStickerGrid,
        Size = UDim2.new(0, 68, 0, 68),
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.4,
        BorderSizePixel = 0,
        Text = "+",
        TextColor3 = Theme.TextDim,
        Font = Enum.Font.GothamBold,
        TextSize = 28,
        ZIndex = 53,
        LayoutOrder = 999,
    })
    corner(AddStickerBtn, 8)
    stroke(AddStickerBtn, Theme.Stroke, 1.5, 0.3)

    -- INPUT PARA ID CUSTOM
    local AddStickerInput = mk("TextBox", {
        Parent = StickerPanel,
        Size = UDim2.new(1, -80, 0, 30),
        Position = UDim2.new(0, 8, 1, -38),
        BackgroundColor3 = Theme.Secondary,
        BackgroundTransparency = 0.3,
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = "rbxassetid://...",
        PlaceholderColor3 = Theme.TextDim,
        TextColor3 = Theme.Text,
        TextSize = 11,
        Font = Enum.Font.Gotham,
        ZIndex = 53,
        Visible = false,
    })
    corner(AddStickerInput, 6)

    local ConfirmAddBtn = mk("TextButton", {
        Parent = StickerPanel,
        Size = UDim2.new(0, 64, 0, 30),
        Position = UDim2.new(1, -72, 1, -38),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Text = "Agregar",
        TextColor3 = Theme.AccentText,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        ZIndex = 53,
        Visible = false,
    })
    corner(ConfirmAddBtn, 6)

    -- STICKERS PERSONALIZADOS
    local DefaultStickers = {
        {id = "rbxassetid://135857695171095", name = "Sonrisa"},
        {id = "rbxassetid://138363247925206", name = "Llorar"},
        {id = "rbxassetid://76164124882568", name = "Amor"},
        {id = "rbxassetid://76164124882568", name = "Corazón"},
        {id = "rbxassetid://133861773375312", name = "Emoji"},
        {id = "rbxassetid://109165098870367", name = "Risa"},
        {id = "rbxassetid://89213081637073", name = "Sorpresa"},
        {id = "rbxassetid://80817302481160", name = "Triste"},
        {id = "rbxassetid://72815688632249", name = "Enojado"},
        {id = "rbxassetid://72602706593283", name = "Wink"},
        {id = "rbxassetid://129224642026377", name = "Cool"},
    }

    -- CARGAR STICKERS CUSTOM GUARDADOS
    local CustomStickers = {}
    if readfile and isfile then
        pcall(function()
            if isfile("YinYang_CustomStickers.json") then
                local data = game:GetService("HttpService"):JSONDecode(readfile("YinYang_CustomStickers.json"))
                if type(data) == "table" then
                    CustomStickers = data
                end
            end
        end)
    end

    local function SaveCustomStickers()
        pcall(function()
            if writefile then
                writefile("YinYang_CustomStickers.json",
                    game:GetService("HttpService"):JSONEncode(CustomStickers))
            end
        end)
    end

    local function ScrollChatToBottom()
    	task.defer(function()
    		task.wait()
    		if ChatContainer and ChatContainer.Parent then
    			ChatContainer.CanvasPosition = Vector2.new(0, math.max(0, ChatContainer.AbsoluteCanvasSize.Y))
    		end
    	end)
    end

    --// ════════════════════════════════════════════════════════════════
    --// SISTEMA DE BURBUJAS POR USUARIO
    --// ════════════════════════════════════════════════════════════════

    local UserBubbleAssets = {}
    local UserBubbleStyles = {}

    local function NormalizeUserId(userId)
        return tonumber(userId) or 0
    end

    local function GetContrast(bgColor)
        if typeof(bgColor) ~= "Color3" then
            return Color3.fromRGB(255, 255, 255)
        end

        local luminance = (bgColor.R * 0.299) + (bgColor.G * 0.587) + (bgColor.B * 0.114)
        if luminance >= 0.58 then
            return Color3.fromRGB(25, 25, 25)
        end

        return Color3.fromRGB(255, 255, 255)
    end

    function Window:SetUserBubbleAsset(userId, assetId)
        userId = NormalizeUserId(userId)
        if userId == 0 then
            return
        end

        if assetId == nil or assetId == "" then
            UserBubbleAssets[userId] = nil
            return
        end

        UserBubbleAssets[userId] = tostring(assetId)
    end

    function Window:SetUserBubbleStyle(userId, style)
        userId = NormalizeUserId(userId)
        if userId == 0 then
            return
        end

        if type(style) ~= "table" then
            UserBubbleStyles[userId] = nil
            return
        end

        UserBubbleStyles[userId] = table.clone(style)
    end

    local function GetUserBubbleAsset(userId)
        return UserBubbleAssets[NormalizeUserId(userId)]
    end

    local function GetUserBubbleStyle(userId)
        return UserBubbleStyles[NormalizeUserId(userId)] or {}
    end

    --// ════════════════════════════════════════════════════════════════
    --// SISTEMA DE EFECTOS ESPECIALES - ADMIN (MOUSOZA)
    --// ════════════════════════════════════════════════════════════════
    
    --// ════════════════════════════════════════════════════════════════
    --// SISTEMA DE EFECTOS ESPECIALES POR USUARIO (STAFF / ADMIN)
    --// ════════════════════════════════════════════════════════════════
    --// IMPORTANTE: esto funciona para TODOS los jugadores porque vive
    --// en el código fuente del script — cada cliente ejecuta el mismo
    --// archivo, así que la misma UserId siempre recibe el mismo efecto
    --// SIN necesidad de sincronizar nada por el backend.
    --//
    --// Si en cambio asignas un efecto en caliente con
    --// Window:SetUserBubbleAsset(userId, assetId), esa asignación SOLO
    --// vive en tu cliente y nadie más la verá — para que se vea en todos
    --// lados, agrégalo aquí abajo.
    --//
    --// Campos por entrada (todos opcionales):
    --//   Asset         -> rbxassetid:// de fondo de burbuja
    --//   FloatAsset    -> rbxassetid:// que flota encima de la burbuja
    --//   RainbowName   -> true/false, ciclo de color arcoíris en el nombre
    --//   RainbowBorder -> true/false, borde pulsante blanco/negro
    --// ════════════════════════════════════════════════════════════════

    local SpecialUsers = {
        [9549448191] = {  -- Mousoza (admin original)
            Asset = "rbxassetid://81745105398770",
            FloatAsset = "rbxassetid://71845994976179",
            RainbowName = true,
            RainbowBorder = true,
        },
        --// Ejemplo para sumar más staff, descomenta y reemplaza el ID/asset:
        -- [TU_USERID_AQUI] = {
        --     Asset = "rbxassetid://0000000000",
        --     FloatAsset = "rbxassetid://0000000000",
        --     RainbowName = false,
        --     RainbowBorder = false,
        -- },
    }

    local function GetSpecialUser(userId)
        return SpecialUsers[tonumber(userId)]
    end
    
    -- Ciclos de colores para mousoza (Rainbow épico)
    local MouseozaNameColors = {
        Color3.fromRGB(255, 80,  80),     -- Rojo
        Color3.fromRGB(255, 160, 40),     -- Naranja
        Color3.fromRGB(255, 240, 40),     -- Amarillo
        Color3.fromRGB(80,  255, 120),    -- Verde
        Color3.fromRGB(40,  200, 255),    -- Cyan
        Color3.fromRGB(140, 80,  255),    -- Violeta
        Color3.fromRGB(255, 80,  200),    -- Rosa
    }

    local MouseozaBorderColors = {
        Color3.fromRGB(255, 255, 255),    -- Blanco
        Color3.fromRGB(0,   0,   0),      -- Negro
    }
    
    local function StartMouseozaNameCycle(UsernameLabel)
        local colorIndex = 1
        local cycleDuration = 2.0
        local colorCount = #MouseozaNameColors

        -- UIStroke para el borde del nombre
        local nameStroke = Instance.new("UIStroke")
        nameStroke.Thickness = 1.5
        nameStroke.Transparency = 0.0
        nameStroke.Color = MouseozaNameColors[1]
        nameStroke.Parent = UsernameLabel

        task.spawn(function()
            local elapsed = 0
            while UsernameLabel and UsernameLabel.Parent do
                local dt = task.wait(0.05)
                elapsed = elapsed + dt

                -- Color principal del nombre (ciclo suave)
                local t = (elapsed / cycleDuration) % 1
                local idxA = math.floor(t * colorCount) + 1
                local idxB = (idxA % colorCount) + 1
                local alpha = (t * colorCount) % 1

                local colorA = MouseozaNameColors[idxA]
                local colorB = MouseozaNameColors[idxB]
                local lerpedColor = colorA:Lerp(colorB, alpha)

                UsernameLabel.TextColor3 = lerpedColor

                -- UIStroke con color opuesto al texto (desfasado 180°)
                local tOffset = (t + 0.5) % 1
                local idxC = math.floor(tOffset * colorCount) + 1
                local idxD = (idxC % colorCount) + 1
                local alphaD = (tOffset * colorCount) % 1
                nameStroke.Color = MouseozaNameColors[idxC]:Lerp(MouseozaNameColors[idxD], alphaD)

                -- Brillo sinusoidal (TextStrokeTransparency)
                UsernameLabel.TextStrokeTransparency = 0.4 + 0.4 * math.sin(elapsed * math.pi * 1.5)
                UsernameLabel.TextStrokeColor3 = lerpedColor
            end
        end)
    end
    
    local function StartMouseozaBorderCycle(Bubble, strokeThickness)
        task.spawn(function()
            local elapsed = 0
            while Bubble and Bubble.Parent do
                local dt = task.wait(0.05)
                elapsed = elapsed + dt

                local stroke = Bubble:FindFirstChild("UIStroke")
                if stroke then
                    -- Sinusoidal Blanco ↔ Negro (mismo efecto que la librería)
                    local t = (math.sin(elapsed * math.pi * 0.6) + 1) / 2
                    stroke.Color = Color3.fromRGB(
                        math.floor(255 * t),
                        math.floor(255 * t),
                        math.floor(255 * t)
                    )
                    -- Grosor pulsante suave
                    stroke.Thickness = strokeThickness + 0.6 * math.abs(math.sin(elapsed * math.pi * 0.8))
                end
            end
        end)
    end

    local function RenderMessage(playerName, userId, messageText, timeStamp, isSelf)
    	-- DETECCIÓN DE STICKER
    	local stickerAsset = messageText:match("^%[%[STICKER:(rbxassetid://%d+)%]%]$")
    	if stickerAsset then
    		local StickerFrame = mk("Frame", {
    			Parent = ChatContainer,
    			Size = UDim2.new(1, 0, 0, 172),
    			BackgroundTransparency = 1,
    			BorderSizePixel = 0,
    			LayoutOrder = #ChatMessages,
    			ZIndex = 12,
    		})

    		-- Nombre + timestamp
    		mk("TextLabel", {
    			Parent = StickerFrame,
    			Size = UDim2.new(1, -12, 0, 16),
    			Position = UDim2.new(0, 12, 0, 4),
    			BackgroundTransparency = 1,
    			Text = (isSelf and "Tú" or tostring(playerName)) .. " • " .. tostring(timeStamp),
    			Font = Enum.Font.GothamBold,
    			TextSize = 11,
    			TextColor3 = isSelf and Theme.Accent or Theme.TextDim,
    			TextXAlignment = Enum.TextXAlignment.Left,
    			ZIndex = 13,
    		})

    		-- Sticker grande (igual a referencia)
    		mk("ImageLabel", {
    			Parent = StickerFrame,
    			Size = UDim2.new(0, 148, 0, 148),
    			Position = UDim2.new(0, 12, 0, 22),
    			BackgroundTransparency = 1,
    			Image = stickerAsset,
    			ScaleType = Enum.ScaleType.Fit,
    			ZIndex = 13,
    		})

    		ScrollChatToBottom()
    		return
    	end
    	local style = GetUserBubbleStyle(userId)
    	local assetId = GetUserBubbleAsset(userId)

    	local baseColor = style.BackgroundColor3 or (isSelf and Theme.Accent or Theme.Secondary)
    	local baseTransparency = style.BackgroundTransparency
    	    or (assetId and 0.16 or (isSelf and 0.14 or 0.22))

    	local frameTextColor = style.TextColor3 or (assetId and GetContrast(baseColor) or (isSelf and Color3.fromRGB(255, 255, 255) or Theme.Text))
    	local nameColor = style.NameColor3 or (assetId and GetContrast(baseColor) or (isSelf and Color3.fromRGB(200, 255, 200) or Theme.Accent))
    	local strokeColor = style.StrokeColor3 or Theme.Stroke
    	local cornerRadius = style.CornerRadius or 12

    	--// ════════════════════════════════════════════════════════════════
    	--// ESTRUCTURA PROFESIONAL: TARJETA INDEPENDIENTE
    	--// ════════════════════════════════════════════════════════════════

    	-- CONTENEDOR PRINCIPAL DE LA TARJETA
    	local MessageFrame = mk("Frame", {
    	    Parent = ChatContainer,
    	    Size = UDim2.new(1, 0, 0, 0),
    	    AutomaticSize = Enum.AutomaticSize.Y,
    	    BackgroundTransparency = 1,
    	    BorderSizePixel = 0,
    	    ClipsDescendants = false,
    	    LayoutOrder = #ChatMessages,
    	    ZIndex = 12,
    	})

    	-- AVATAR: más grande para mejor visibilidad
    	local AvatarLabel = mk("ImageLabel", {
    	    Parent = MessageFrame,
    	    Size = UDim2.new(0, 46, 0, 46),
    	    Position = UDim2.new(0, 0, 0, 0),
    	    BackgroundColor3 = style.AvatarBgColor3 or (isSelf and Theme.Accent or Theme.AccentOff),
    	    BackgroundTransparency = style.AvatarBgTransparency or 0.05,
    	    BorderSizePixel = 0,
    	    Image = GetPlayerAvatar(userId),
    	    ScaleType = Enum.ScaleType.Crop,
    	    ZIndex = 14,
    	})
    	corner(AvatarLabel, 999)
    	stroke(AvatarLabel, strokeColor, 1.5, 0.35)

    	-- CONTENEDOR DE CONTENIDO (Header + Bubble)
    	local ContentFrame = mk("Frame", {
    	    Parent = MessageFrame,
    	    Size = UDim2.new(1, -54, 0, 0),
    	    Position = UDim2.new(0, 54, 0, 0),
    	    AutomaticSize = Enum.AutomaticSize.Y,
    	    BackgroundTransparency = 1,
    	    BorderSizePixel = 0,
    	    ClipsDescendants = false,
    	    ZIndex = 12,
    	})

    	-- LAYOUT VERTICAL PARA HEADER + BUBBLE
    	mk("UIListLayout", {
    	    Parent = ContentFrame,
    	    Padding = UDim.new(0, 4),
    	    SortOrder = Enum.SortOrder.LayoutOrder,
    	    VerticalAlignment = Enum.VerticalAlignment.Top,
    	})

    	--// HEADER: Nombre y Hora
    	local HeaderFrame = mk("Frame", {
    	    Parent = ContentFrame,
    	    Size = UDim2.new(1, 0, 0, 16),
    	    BackgroundTransparency = 1,
    	    BorderSizePixel = 0,
    	    LayoutOrder = 1,
    	    ZIndex = 15,
    	})

    	-- Nombre del usuario (más grande y destacado)
    	local UsernameLabel = mk("TextLabel", {
    	    Parent = HeaderFrame,
    	    Size = UDim2.new(0, 0, 1, 0),
    	    Position = UDim2.new(0, 0, 0, 0),
    	    BackgroundTransparency = 1,
    	    Text = (isSelf and "Tú" or tostring(playerName or "Unknown")),
    	    Font = Enum.Font.GothamBlack,
    	    TextSize = 14,
    	    TextColor3 = nameColor,
    	    TextXAlignment = Enum.TextXAlignment.Left,
    	    TextYAlignment = Enum.TextYAlignment.Center,
    	    AutomaticSize = Enum.AutomaticSize.X,
    	    ZIndex = 15,
    	})
    	UsernameLabel:SetAttribute("ThemeTextRole", "Text")

    	--// EFECTOS ESPECIALES POR USUARIO (staff/admin, ver SpecialUsers arriba)
    	local specialUser = GetSpecialUser(userId)
    	if specialUser then
    	    if specialUser.RainbowName then
    	        StartMouseozaNameCycle(UsernameLabel)
    	    end
    	    if not assetId and specialUser.Asset then
    	        assetId = specialUser.Asset
    	    end
    	end

    	-- Hora (Discreta, gris)
    	local TimeLabel = mk("TextLabel", {
    	    Parent = HeaderFrame,
    	    Size = UDim2.new(1, 0, 1, 0),
    	    Position = UDim2.new(0, 0, 0, 0),
    	    BackgroundTransparency = 1,
    	    Text = tostring(timeStamp or os.date("%H:%M:%S")),
    	    Font = Enum.Font.Gotham,
    	    TextSize = 10,
    	    TextColor3 = Theme.TextDim,
    	    TextXAlignment = Enum.TextXAlignment.Right,
    	    TextYAlignment = Enum.TextYAlignment.Center,
    	    ZIndex = 15,
    	})
    	TimeLabel:SetAttribute("ThemeTextRole", "Text")

    	--// BURBUJA: Se adapta al ancho REAL del texto, con un máximo del 88% del contenedor
    	local Bubble = mk("Frame", {
    	    Parent = ContentFrame,
    	    Size = UDim2.new(0, 0, 0, 0),
    	    AutomaticSize = Enum.AutomaticSize.XY,
    	    BackgroundColor3 = baseColor,
    	    BackgroundTransparency = baseTransparency,
    	    BorderSizePixel = 0,
    	    ClipsDescendants = true,
    	    LayoutOrder = 2,
    	    ZIndex = 12,
    	})
    	Bubble:SetAttribute("ThemeRole", isSelf and "Accent" or "Secondary")
    	corner(Bubble, cornerRadius)
    	stroke(Bubble, strokeColor, 1.25, 0.35)

    	--// EFECTOS DE BORDE Y ASSET FLOTANTE (staff/admin)
    	if specialUser then
    	    if specialUser.RainbowBorder then
    	        StartMouseozaBorderCycle(Bubble, 1.25)
    	    end

    	    if specialUser.FloatAsset then
    	        -- Asset flotante: Parent = MessageFrame (sin ClipsDescendants)
    	        -- Bubble empieza en y=20 del MessageFrame (header 16 + padding 4)
    	        -- Pibble 95x85: patas en el borde superior de la burbuja
    	        local FloatAsset = mk("ImageLabel", {
    	            Parent = MessageFrame,
    	            Size = UDim2.new(0, 95, 0, 85),
    	            Position = UDim2.new(0, 60, 0, -20),
    	            AnchorPoint = Vector2.new(0, 0),
    	            BackgroundTransparency = 1,
    	            Image = specialUser.FloatAsset,
    	            ScaleType = Enum.ScaleType.Fit,
    	            ZIndex = 20,
    	        })
    	    end
    	end

    	-- PADDING INTERNO: 10px en todos lados
    	mk("UIPadding", {
    	    Parent = Bubble,
    	    PaddingTop = UDim.new(0, 8),
    	    PaddingBottom = UDim.new(0, 10),
    	    PaddingLeft = UDim.new(0, 8),
    	    PaddingRight = UDim.new(0, 8),
    	})

    	-- Asset de fondo opcional
    	if assetId then
    	    local BubbleAsset = mk("ImageLabel", {
    	        Parent = Bubble,
    	        Size = UDim2.new(1, 20, 1, 20),
    	        Position = UDim2.new(0, -10, 0, -10),
    	        BackgroundTransparency = 1,
    	        Image = assetId,
    	        ImageTransparency = style.ImageTransparency or 0.0,  -- Completamente visible
    	        ImageColor3 = style.AssetTintColor3 or Color3.fromRGB(255, 255, 255),
    	        ScaleType = Enum.ScaleType.Crop,
    	        ZIndex = 11,
    	    })
    	    corner(BubbleAsset, cornerRadius)

    	    local Wash = mk("Frame", {
    	        Parent = Bubble,
    	        Size = UDim2.new(1, 20, 1, 20),
    	        Position = UDim2.new(0, -10, 0, -10),
    	        BackgroundColor3 = style.AssetWashColor3 or baseColor,
    	        BackgroundTransparency = style.AssetWashTransparency or 0.92,  -- Wash casi invisible
    	        BorderSizePixel = 0,
    	        ZIndex = 11,
    	    })
    	    corner(Wash, cornerRadius)
    	    Wash.Active = false
    	end

    	-- TEXTO DEL MENSAJE: el ancho se ajusta al contenido real (con tope máximo)
    	local MessageLabel = mk("TextLabel", {
    	    Parent = Bubble,
    	    Size = UDim2.new(0, 0, 0, 0),
    	    BackgroundTransparency = 1,
    	    Text = tostring(messageText or ""),
    	    Font = Enum.Font.GothamBold,
    	    TextSize = 13,
    	    TextColor3 = frameTextColor,
    	    TextWrapped = true,
    	    TextXAlignment = Enum.TextXAlignment.Left,
    	    TextYAlignment = Enum.TextYAlignment.Top,
    	    AutomaticSize = Enum.AutomaticSize.XY,
    	    ZIndex = 15,
    	})
    	MessageLabel:SetAttribute("ThemeTextRole", "Text")

    	--// LÍMITE DE ANCHO: la burbuja crece con el texto pero nunca pasa
    	--// del 88% del contenedor (donde se activa el wrap). Se recalcula
    	--// si el contenedor cambia de tamaño (rotación, redimensionado, etc.)
    	local MessageWidthConstraint = mk("UISizeConstraint", {
    	    Parent = MessageLabel,
    	    MaxSize = Vector2.new(240, math.huge),
    	})

    	local function updateMessageMaxWidth()
    	    local containerWidth = ContentFrame.AbsoluteSize.X
    	    if containerWidth <= 0 then
    	        containerWidth = 260
    	    end
    	    MessageWidthConstraint.MaxSize = Vector2.new(math.floor(containerWidth * 0.88), math.huge)
    	end
    	updateMessageMaxWidth()
    	ContentFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(updateMessageMaxWidth)

    	--// ════════════════════════════════════════════════════════════════
    	--// BOTÓN DE TRADUCCIÓN MANUAL (por mensaje, bajo demanda)
    	--// Se agrega como nueva fila de ContentFrame (usa su UIListLayout ya
    	--// existente) — no toca la Bubble ni el MessageLabel original.
    	--// ════════════════════════════════════════════════════════════════
    	local TranslateBtn = mk("TextButton", {
    	    Parent = ContentFrame,
    	    Size = UDim2.new(0, 0, 0, 14),
    	    AutomaticSize = Enum.AutomaticSize.X,
    	    BackgroundTransparency = 1,
    	    Text = GetText("Traducir", "Translate"),
    	    Font = Enum.Font.GothamBold,
    	    TextSize = 10,
    	    TextColor3 = Theme.Accent,
    	    TextXAlignment = Enum.TextXAlignment.Left,
    	    LayoutOrder = 3,
    	    ZIndex = 15,
    	})

    	local translatedBubble, isTranslated, isLoadingTranslation = nil, false, false

    	local function ClearTranslation()
    	    if translatedBubble then
    	        translatedBubble:Destroy()
    	        translatedBubble = nil
    	    end
    	    isTranslated = false
    	    TranslateBtn.Text = GetText("Traducir", "Translate")
    	end

    	local function ShowTranslation(translatedText)
    	    translatedBubble = mk("Frame", {
    	        Parent = ContentFrame,
    	        Size = UDim2.new(1, 0, 0, 0),
    	        AutomaticSize = Enum.AutomaticSize.Y,
    	        BackgroundColor3 = baseColor,
    	        BackgroundTransparency = 1,
    	        BorderSizePixel = 0,
    	        ClipsDescendants = true,
    	        LayoutOrder = 4,
    	        ZIndex = 12,
    	    })
    	    corner(translatedBubble, cornerRadius)
    	    stroke(translatedBubble, Theme.Accent, 1, 0.6)
    	    mk("UIPadding", {
    	        Parent = translatedBubble,
    	        PaddingTop = UDim.new(0, 8),
    	        PaddingBottom = UDim.new(0, 8),
    	        PaddingLeft = UDim.new(0, 8),
    	        PaddingRight = UDim.new(0, 8),
    	    })
    	    local TranslatedLabel = mk("TextLabel", {
    	        Parent = translatedBubble,
    	        Size = UDim2.new(1, 0, 0, 0),
    	        BackgroundTransparency = 1,
    	        Text = tostring(translatedText),
    	        Font = Enum.Font.Gotham,
    	        TextSize = 12,
    	        TextColor3 = Theme.TextDim,
    	        TextWrapped = true,
    	        TextXAlignment = Enum.TextXAlignment.Left,
    	        TextYAlignment = Enum.TextYAlignment.Top,
    	        AutomaticSize = Enum.AutomaticSize.Y,
    	        ZIndex = 15,
    	    })
    	    TranslatedLabel:SetAttribute("ThemeTextRole", "TextDim")
    	    isTranslated = true
    	    TranslateBtn.Text = GetText("Ocultar traducción", "Hide translation")
    	    ScrollChatToBottom()
    	end

    	TranslateBtn.MouseButton1Click:Connect(function()
    	    if isLoadingTranslation then return end

    	    if isTranslated then
    	        ClearTranslation()
    	        return
    	    end

    	    isLoadingTranslation = true
    	    TranslateBtn.Text = GetText("Traduciendo...", "Translating...")

    	    local targetLanguage = LanguageSystem.CurrentLanguage == "en" and "en" or "es"

    	    TranslateMessage(messageText, targetLanguage, function(translated, fromLang, toLang, err)
    	        isLoadingTranslation = false

    	        if translated and translated ~= "" and translated ~= messageText then
    	            ShowTranslation(translated)
    	        else
    	            local sameLanguage = (fromLang and fromLang == targetLanguage) or (toLang and toLang == targetLanguage)
    	            if sameLanguage or translated == messageText then
    	                TranslateBtn.Text = GetText("Ya estaba en este idioma", "Already in this language")
    	            else
    	                TranslateBtn.Text = GetText("Error, reintentar", "Error, retry")
    	            end
    	            task.delay(2, function()
    	                if TranslateBtn and TranslateBtn.Parent then
    	                    TranslateBtn.Text = GetText("Traducir", "Translate")
    	                end
    	            end)
    	        end
    	    end)
    	end)

    	--// ANIMACIÓN DE APARICIÓN: Transición suave (0.15s)
    	Bubble.BackgroundTransparency = baseTransparency + 1
    	AvatarLabel.ImageTransparency = 1

    	local tweenInfo = TweenInfo.new(
    	    0.15,
    	    Enum.EasingStyle.Quad,
    	    Enum.EasingDirection.Out
    	)

    	local tweenBubble = TweenService:Create(Bubble, tweenInfo, {BackgroundTransparency = baseTransparency})
    	local tweenAvatar = TweenService:Create(AvatarLabel, tweenInfo, {ImageTransparency = 0})

    	tweenBubble:Play()
    	tweenAvatar:Play()

    	ScrollChatToBottom()
    end

    local function SendMessage()
    	local messageText = MessageInput.Text or ""
    	messageText = messageText:sub(1, MAX_CHAR)

    	if messageText:match("^%s*$") then
    		return
    	end

    	local localPlayer = Players.LocalPlayer
    	local timestamp = os.date("%H:%M:%S")

    	AddChatMessage(localPlayer.Name, localPlayer.UserId, messageText, timestamp)
    	RenderMessage(localPlayer.Name, localPlayer.UserId, messageText, timestamp, true)

    	-- Sincronizar con el backend para que otros jugadores lo reciban
    	BackendSendMessage(localPlayer.Name, localPlayer.UserId, messageText)

    	MessageInput.Text = ""
    	CharLabel.Text = "0 / 500"
    end

    MessageInput.Changed:Connect(function(property)
    	if property ~= "Text" then
    		return
    	end

    	if #MessageInput.Text > MAX_CHAR then
    		MessageInput.Text = MessageInput.Text:sub(1, MAX_CHAR)
    	end

    	CharLabel.Text = tostring(#MessageInput.Text) .. " / " .. tostring(MAX_CHAR)
    end)

    SendButton.MouseButton1Click:Connect(SendMessage)

    --// ════════════════════════════════════════════════════════════════
    --// LÓGICA DE STICKERS (DESPUÉS de RenderMessage)
    --// ════════════════════════════════════════════════════════════════

    local function SendSticker(assetId)
        local localPlayer = Players.LocalPlayer
        local timestamp = os.date("%H:%M:%S")
        local stickerMsg = "[[STICKER:" .. assetId .. "]]"
        AddChatMessage(localPlayer.Name, localPlayer.UserId, stickerMsg, timestamp)
        RenderMessage(localPlayer.Name, localPlayer.UserId, stickerMsg, timestamp, true)
        BackendSendMessage(localPlayer.Name, localPlayer.UserId, stickerMsg)
        StickerPanel.Visible = false
    end

    local function CreateStickerBtn(parent, assetId, isCustom)
        local StickerBtn = mk("ImageButton", {
            Parent = parent,
            Size = UDim2.new(0, 68, 0, 68),
            BackgroundColor3 = Theme.Secondary,
            BackgroundTransparency = 0.5,
            BorderSizePixel = 0,
            Image = assetId,
            ScaleType = Enum.ScaleType.Fit,
            ZIndex = 53,
        })
        corner(StickerBtn, 8)

        StickerBtn.MouseButton1Click:Connect(function()
            SendSticker(assetId)
        end)

        StickerBtn.MouseEnter:Connect(function()
            TweenService:Create(StickerBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.1}):Play()
        end)
        StickerBtn.MouseLeave:Connect(function()
            TweenService:Create(StickerBtn, TweenInfo.new(0.12), {BackgroundTransparency = 0.5}):Play()
        end)

        if isCustom then
            local DelBtn = mk("TextButton", {
                Parent = StickerBtn,
                Size = UDim2.new(0, 18, 0, 18),
                Position = UDim2.new(1, -20, 0, 2),
                BackgroundColor3 = Color3.fromRGB(200, 50, 50),
                BorderSizePixel = 0,
                Text = "✕",
                TextColor3 = Color3.fromRGB(255, 255, 255),
                Font = Enum.Font.GothamBold,
                TextSize = 10,
                ZIndex = 54,
            })
            corner(DelBtn, 4)
            DelBtn.MouseButton1Click:Connect(function()
                for i, s in ipairs(CustomStickers) do
                    if s.id == assetId then
                        table.remove(CustomStickers, i)
                        break
                    end
                end
                SaveCustomStickers()
                StickerBtn:Destroy()
            end)
        end
        return StickerBtn
    end

    -- CARGAR STICKERS DEL REPO EN GRID
    -- Usa StickerOrder del repo si LoadStickers() funcionó,
    -- si no, usa el orden de la tabla embebida como fallback
    local stickerOrder = StickerOrder or {
        "Sonrisa","Llorar","Amor","Corazon",
        "Emoji","Risa","Sorpresa","Triste",
        "Enojado","Wink","Cool",
    }
    for _, name in ipairs(stickerOrder) do
        local sticker = StickerPalettes[name]
        if sticker and sticker.Image then
            CreateStickerBtn(StickerGrid, sticker.Image, false)
        end
    end

    -- Actualizar CanvasSize de StickerGrid después de que UIGridLayout calcule el contenido
    local function refreshStickerCanvas()
        task.defer(function()
            local layout = StickerGrid:FindFirstChildOfClass("UIGridLayout")
            if layout then
                StickerGrid.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
            end
        end)
    end
    local function refreshMisCanvas()
        task.defer(function()
            local layout = MisStickerGrid:FindFirstChildOfClass("UIGridLayout")
            if layout then
                MisStickerGrid.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 8)
            end
        end)
    end
    refreshStickerCanvas()
    StickerGrid.ChildAdded:Connect(refreshStickerCanvas)
    StickerGrid.ChildRemoved:Connect(refreshStickerCanvas)
    MisStickerGrid.ChildAdded:Connect(refreshMisCanvas)
    MisStickerGrid.ChildRemoved:Connect(refreshMisCanvas)

    -- CARGAR CUSTOM STICKERS
    for _, s in ipairs(CustomStickers) do
        CreateStickerBtn(MisStickerGrid, s.id, true)
    end

    -- LÓGICA TABS
    local function ShowStickerTab(tab)
        if tab == "stickers" then
            StickerGrid.Visible = true
            MisStickerGrid.Visible = false
            AddStickerInput.Visible = false
            ConfirmAddBtn.Visible = false
            TabStickers.BackgroundColor3 = Theme.Accent
            TabStickers.BackgroundTransparency = 0
            TabStickers.TextColor3 = Theme.AccentText
            TabMisStickers.BackgroundColor3 = Theme.Secondary
            TabMisStickers.BackgroundTransparency = 0.4
            TabMisStickers.TextColor3 = Theme.Text
        else
            StickerGrid.Visible = false
            MisStickerGrid.Visible = true
            TabStickers.BackgroundColor3 = Theme.Secondary
            TabStickers.BackgroundTransparency = 0.4
            TabStickers.TextColor3 = Theme.Text
            TabMisStickers.BackgroundColor3 = Theme.Accent
            TabMisStickers.BackgroundTransparency = 0
            TabMisStickers.TextColor3 = Theme.AccentText
        end
    end

    TabStickers.MouseButton1Click:Connect(function() ShowStickerTab("stickers") end)
    TabMisStickers.MouseButton1Click:Connect(function() ShowStickerTab("mis") end)

    PanelClose.MouseButton1Click:Connect(function()
        StickerPanel.Visible = false
        AddStickerInput.Visible = false
        ConfirmAddBtn.Visible = false
    end)

    AddStickerBtn.MouseButton1Click:Connect(function()
        AddStickerInput.Visible = not AddStickerInput.Visible
        ConfirmAddBtn.Visible = not ConfirmAddBtn.Visible
    end)

    ConfirmAddBtn.MouseButton1Click:Connect(function()
        local newId = AddStickerInput.Text:match("^%s*(.-)%s*$")
        if newId == "" then return end
        if not newId:find("rbxassetid://") then
            newId = "rbxassetid://" .. newId
        end
        table.insert(CustomStickers, {id = newId, name = "Custom"})
        SaveCustomStickers()
        CreateStickerBtn(MisStickerGrid, newId, true)
        AddStickerInput.Text = ""
        AddStickerInput.Visible = false
        ConfirmAddBtn.Visible = false
    end)

    StickerButton.MouseButton1Click:Connect(function()
        StickerPanel.Visible = not StickerPanel.Visible
        if StickerPanel.Visible then
            ShowStickerTab("stickers")
        end
    end)

    MessageInput.FocusLost:Connect(function(enterPressed)
    	if enterPressed then
    		SendMessage()
    	end
    end)

    function Window:SendChatMessage(text)
    	MessageInput.Text = tostring(text or ""):sub(1, MAX_CHAR)
    	SendMessage()
    end

    function Window:GetChatHistory()
    	return GetChatHistory()
    end

    function Window:ReceiveMessage(playerName, userId, message)
    	local timestamp = os.date("%H:%M:%S")
    	AddChatMessage(playerName, userId, message, timestamp)
    	RenderMessage(playerName, userId, message, timestamp, false)
    end

    Window.ChatMessages = ChatMessages
    Window.ChatRoot = ChatRoot
    Window.ChatContainer = ChatContainer
    Window.ChatFooter = ChatFooter
    Window.MessageInput = MessageInput
    Window.SendButton = SendButton
    Window.CharLabel = CharLabel
    Window.AddChatMessage = AddChatMessage
    Window.RenderChatMessage = RenderMessage
    Window.SendMessage = SendMessage

    --// Iniciar sincronización en tiempo real con el backend
    --// Cada mensaje nuevo de OTRO jugador se agrega y renderiza automáticamente
    StartBackendPolling(function(msg)
        AddChatMessage(msg.playerName, msg.playerId, msg.message, os.date("%H:%M:%S", msg.timestamp))
        RenderMessage(msg.playerName, msg.playerId, msg.message, os.date("%H:%M:%S", msg.timestamp), false)
        --// Badge: sumar no leído si el chat está cerrado
        addUnread()
    end)

    --// HEARTBEAT — avisa al backend cada 30s que el jugador sigue usando el script
    --// Permite un contador real de usuarios online sin depender del chat
    task.spawn(function()
        local function sendHeartbeat()
            pcall(function()
                UniversalRequest({
                    Url    = BACKEND_URL .. "/api/heartbeat",
                    Method = "POST",
                    Headers = { ["Content-Type"] = "application/json" },
                    Body   = HttpService:JSONEncode({ playerId = tostring(LocalPlayer.UserId) }),
                })
            end)
        end
        sendHeartbeat()         -- ping inmediato al cargar
        while true do
            task.wait(30)
            sendHeartbeat()
        end
    end)

    --// ════════════════════════════════════════════════════════════════
    --// UPDATE LOOP — Cambio instantáneo de idioma (v28 PRO)
    --// Detecta cambios en LanguageSystem.CurrentLanguage y actualiza
    --// TODOS los elementos que tengan atributos TextSpanish/TextEnglish
    --// ════════════════════════════════════════════════════════════════
    local lastLanguage = LanguageSystem.CurrentLanguage
    RunService.Heartbeat:Connect(function()
        local currentLang = LanguageSystem.CurrentLanguage
        if currentLang == lastLanguage then return end
        lastLanguage = currentLang

        for _, tabData in ipairs(Window.Tabs) do
            --// Actualizar el botón de la tab (nombre)
            if tabData.Button then
                for _, child in ipairs(tabData.Button:GetChildren()) do
                    if child:IsA("TextLabel") then
                        local sp = child:GetAttribute("TextSpanish")
                        local en = child:GetAttribute("TextEnglish")
                        if sp and en then
                            child.Text = GetText(sp, en)
                        end
                    end
                end
            end

            --// Actualizar TODOS los descendientes de la página
            if tabData.Page then
                for _, el in ipairs(tabData.Page:GetDescendants()) do
                    if el:IsA("TextLabel") or el:IsA("TextButton") then
                        local sp = el:GetAttribute("TextSpanish")
                        local en = el:GetAttribute("TextEnglish")
                        if sp and en then
                            el.Text = GetText(sp, en)
                        end
                    end
                end
            end
        end
    end)

    --// ════════════════════════════════════════════════════════════════
    --// TAB: CRÉDITOS (todo en una pantalla, sin scroll)
    --// ════════════════════════════════════════════════════════════════
    local TabCreditos = Window:CreateTab("Créditos", "Credits", "rbxassetid://72420970081590")
    local CredPage = TabCreditos.Page

    CredPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
    CredPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    CredPage.ScrollBarThickness = 2
    CredPage.ScrollingEnabled = true

    local CB  = Theme.Background
    local CC  = Theme.Secondary
    local CW  = Theme.Text
    local CG  = Theme.TextDim
    local CDG = Theme.Stroke
    local CGR = Color3.fromRGB(80, 210, 100)
    local CS  = Theme.Stroke

    -- Fondo TRANSPARENTE para ver el BackgroundArt del tema
    CredPage.BackgroundTransparency = 1  -- FIX: transparente para ver el fondo del tema
    CredPage:SetAttribute("ThemeRole", "Background")

    local CredRoot = mk("Frame", {
        Parent = CredPage,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,  -- FIX: sin fondo negro
        BorderSizePixel = 0,
        ClipsDescendants = false,
        ZIndex = 10,
        AutomaticSize = Enum.AutomaticSize.Y,
    })
    CredRoot:SetAttribute("ThemeRole", "Background")

    mk("UIListLayout", {
        Parent = CredRoot,
        Padding = UDim.new(0, 7),
        SortOrder = Enum.SortOrder.LayoutOrder,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
    })

    mk("UIPadding", {
        Parent = CredRoot,
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
    })

    --// HEADER (84px)
    local CR_Header = mk("Frame", {
        Parent = CredRoot,
        Size = UDim2.new(1, 0, 0, 84),
        BackgroundColor3 = CC,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        LayoutOrder = 1, ZIndex = 10,
    })
    CR_Header:SetAttribute("ThemeRole", "Secondary")
    corner(CR_Header, 10)
    stroke(CR_Header, CS, 1, 0)

    local CR_BackImg = mk("ImageLabel", {
        Parent = CR_Header,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Image = "rbxassetid://125311226076728",
        ImageTransparency = 0.55,
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 10,
    })
    corner(CR_BackImg, 10)

    local CR_Overlay = mk("Frame", {
        Parent = CR_Header,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = CC,
        BackgroundTransparency = 0.55,
        BorderSizePixel = 0,
        ZIndex = 11,
    })
    CR_Overlay:SetAttribute("ThemeRole", "Secondary")
    corner(CR_Overlay, 10)

    local CR_TitleLabel = mk("TextLabel", {
        Parent = CR_Header, Size = UDim2.new(0.6, 0, 0, 28),
        Position = UDim2.new(0, 12, 0, 8),
        BackgroundTransparency = 1, Text = GetText("Créditos", "Credits"),
        Font = Enum.Font.GothamBold, TextSize = 22,
        TextColor3 = CW, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 13,
    })
    CR_TitleLabel:SetAttribute("ThemeTextRole", "Text")
    CR_TitleLabel:SetAttribute("TextSpanish", "Créditos")
    CR_TitleLabel:SetAttribute("TextEnglish", "Credits")

    mk("Frame", {
        Parent = CR_Header, Size = UDim2.new(0, 48, 0, 2),
        Position = UDim2.new(0, 12, 0, 38),
        BackgroundColor3 = CW, BorderSizePixel = 0, ZIndex = 13,
    }):SetAttribute("ThemeRole", "Text")

    local CR_SubLabel = mk("TextLabel", {
        Parent = CR_Header, Size = UDim2.new(0.55, 0, 0, 36),
        Position = UDim2.new(0, 12, 0, 44),
        BackgroundTransparency = 1,
        Text = GetText("Gracias por usar Yin Yang v28.\nHecho con dedicación para la comunidad.",
                       "Thank you for using Yin Yang v28.\nMade with dedication for the community."),
        Font = Enum.Font.Gotham, TextSize = 11,
        TextColor3 = CG, TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top, TextWrapped = true, ZIndex = 13,
    })
    CR_SubLabel:SetAttribute("ThemeTextRole", "TextDim")
    CR_SubLabel:SetAttribute("TextSpanish", "Gracias por usar Yin Yang v28.\nHecho con dedicación para la comunidad.")
    CR_SubLabel:SetAttribute("TextEnglish", "Thank you for using Yin Yang v28.\nMade with dedication for the community.")

    mk("ImageLabel", {
        Parent = CR_Header, Size = UDim2.new(0, 82, 0, 82),
        Position = UDim2.new(1, -88, 0, 1),
        BackgroundTransparency = 1, Image = "rbxassetid://117780544348814",
        ScaleType = Enum.ScaleType.Fit, ZIndex = 14,
    })

    --// LABEL DESARROLLADOR (18px)
    local CR_DevLbl = mk("Frame", {
        Parent = CredRoot, Size = UDim2.new(1, 0, 0, 18),
        BackgroundTransparency = 1, LayoutOrder = 2, ZIndex = 10,
    })
    mk("ImageLabel", {
        Parent = CR_DevLbl, Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 2, 0.5, -7),
        BackgroundTransparency = 1, Image = "rbxassetid://131335187671764",
        ImageColor3 = CG, ScaleType = Enum.ScaleType.Fit, ZIndex = 11,
    })
    local CR_DevLblText = mk("TextLabel", {
        Parent = CR_DevLbl, Size = UDim2.new(1, -22, 1, 0),
        Position = UDim2.new(0, 22, 0, 0),
        BackgroundTransparency = 1, Text = GetText("Desarrollador", "Developer"),
        Font = Enum.Font.GothamBold, TextSize = 12,
        TextColor3 = CG, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
    })
    CR_DevLblText:SetAttribute("ThemeTextRole", "TextDim")
    CR_DevLblText:SetAttribute("TextSpanish", "Desarrollador")
    CR_DevLblText:SetAttribute("TextEnglish", "Developer")

    --// CARD DEV (82px)
    local CR_DevCard = mk("Frame", {
        Parent = CredRoot, Size = UDim2.new(1, 0, 0, 82),
        BackgroundColor3 = CC, BackgroundTransparency = 0,
        BorderSizePixel = 0, LayoutOrder = 3, ZIndex = 10,
    })
    CR_DevCard:SetAttribute("ThemeRole", "Secondary")
    corner(CR_DevCard, 10)
    stroke(CR_DevCard, CS, 1, 0)

    local CR_Avatar = mk("ImageLabel", {
        Parent = CR_DevCard, Size = UDim2.new(0, 64, 0, 64),
        Position = UDim2.new(0, 12, 0.5, -32),
        BackgroundColor3 = Color3.fromRGB(30, 30, 35),
        BorderSizePixel = 0, Image = "rbxassetid://125311226076728",
        ScaleType = Enum.ScaleType.Crop, ZIndex = 11,
    })
    corner(CR_Avatar, 8)
    stroke(CR_Avatar, CS, 1, 0)

    mk("Frame", {
        Parent = CR_DevCard, Size = UDim2.new(0, 1, 0, 58),
        Position = UDim2.new(0, 88, 0.5, -29),
        BackgroundColor3 = CS, BorderSizePixel = 0, ZIndex = 11,
    }):SetAttribute("ThemeRole", "Stroke")

    local CR_DevName = mk("TextLabel", {
        Parent = CR_DevCard, Size = UDim2.new(1, -102, 0, 22),
        Position = UDim2.new(0, 98, 0, 10),
        BackgroundTransparency = 1, Text = "Nick",
        Font = Enum.Font.GothamBold, TextSize = 16,
        TextColor3 = CW, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
    })
    CR_DevName:SetAttribute("ThemeTextRole", "Text")

    local CR_DevRole = mk("TextLabel", {
        Parent = CR_DevCard, Size = UDim2.new(1, -102, 0, 16),
        Position = UDim2.new(0, 98, 0, 33),
        BackgroundTransparency = 1, Text = GetText("Desarrollador Principal", "Lead Developer"),
        Font = Enum.Font.Gotham, TextSize = 12,
        TextColor3 = CG, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
    })
    CR_DevRole:SetAttribute("ThemeTextRole", "TextDim")
    CR_DevRole:SetAttribute("TextSpanish", "Desarrollador Principal")
    CR_DevRole:SetAttribute("TextEnglish", "Lead Developer")

    local CR_DevDesc = mk("TextLabel", {
        Parent = CR_DevCard, Size = UDim2.new(1, -102, 0, 28),
        Position = UDim2.new(0, 98, 0, 50),
        BackgroundTransparency = 1,
        Text = GetText("Creador de Yin Yang v28\nApasionado por la programación y la comunidad.",
                       "Creator of Yin Yang v28\nPassionate about programming and the community."),
        Font = Enum.Font.Gotham, TextSize = 10,
        TextColor3 = CDG, TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true, ZIndex = 11,
    })
    CR_DevDesc:SetAttribute("ThemeTextRole", "Stroke")
    CR_DevDesc:SetAttribute("TextSpanish", "Creador de Yin Yang v28\nApasionado por la programación y la comunidad.")
    CR_DevDesc:SetAttribute("TextEnglish", "Creator of Yin Yang v28\nPassionate about programming and the community.")

    --// CARD DISCORD (86px)
    local CR_DC = mk("Frame", {
        Parent = CredRoot, Size = UDim2.new(1, 0, 0, 86),
        BackgroundColor3 = CC, BackgroundTransparency = 0,
        BorderSizePixel = 0, LayoutOrder = 4, ZIndex = 10,
    })
    CR_DC:SetAttribute("ThemeRole", "Secondary")
    corner(CR_DC, 10)
    stroke(CR_DC, CS, 1, 0)

    mk("ImageLabel", {
        Parent = CR_DC, Size = UDim2.new(0, 19, 0, 19),
        Position = UDim2.new(0, 12, 0, 10),
        BackgroundTransparency = 1, Image = "rbxassetid://132202203337109",
        ImageColor3 = CW, ScaleType = Enum.ScaleType.Fit, ZIndex = 11,
    })
    local CR_DCTitle = mk("TextLabel", {
        Parent = CR_DC, Size = UDim2.new(1, -42, 0, 20),
        Position = UDim2.new(0, 37, 0, 9),
        BackgroundTransparency = 1, Text = GetText("Únete a nuestro Discord", "Join our Discord"),
        Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = CW, TextXAlignment = Enum.TextXAlignment.Left, ZIndex = 11,
    })
    CR_DCTitle:SetAttribute("ThemeTextRole", "Text")
    CR_DCTitle:SetAttribute("TextSpanish", "Únete a nuestro Discord")
    CR_DCTitle:SetAttribute("TextEnglish", "Join our Discord")

    mk("Frame", {
        Parent = CR_DC, Size = UDim2.new(1, -24, 0, 1),
        Position = UDim2.new(0, 12, 0, 33),
        BackgroundColor3 = CS, BorderSizePixel = 0, ZIndex = 11,
    }):SetAttribute("ThemeRole", "Stroke")

    local CR_DCDesc = mk("TextLabel", {
        Parent = CR_DC, Size = UDim2.new(0.5, 0, 0, 44),
        Position = UDim2.new(0, 12, 0, 38),
        BackgroundTransparency = 1,
        Text = GetText("Forma parte de nuestra comunidad para recibir soporte, actualizaciones y mucho más.",
                       "Join our community to receive support, updates and much more."),
        Font = Enum.Font.Gotham, TextSize = 10,
        TextColor3 = CG, TextXAlignment = Enum.TextXAlignment.Left,
        TextWrapped = true, ZIndex = 11,
    })
    CR_DCDesc:SetAttribute("ThemeTextRole", "TextDim")
    CR_DCDesc:SetAttribute("TextSpanish", "Forma parte de nuestra comunidad para recibir soporte, actualizaciones y mucho más.")
    CR_DCDesc:SetAttribute("TextEnglish", "Join our community to receive support, updates and much more.")

    local CR_CopyBtn = mk("TextButton", {
        Parent = CR_DC, Size = UDim2.new(0, 106, 0, 38),
        Position = UDim2.new(1, -118, 0.5, -4),
        BackgroundColor3 = Color3.fromRGB(12, 12, 15),
        BackgroundTransparency = 0, BorderSizePixel = 0,
        Text = "", ZIndex = 12,
    })
    corner(CR_CopyBtn, 19)
    mk("UIStroke", { Parent = CR_CopyBtn, Thickness = 1.5, Color = CW }):SetAttribute("ThemeRole", "Text")
    mk("ImageLabel", {
        Parent = CR_CopyBtn, Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(0, 10, 0.5, -8),
        BackgroundTransparency = 1, Image = "rbxassetid://127734233169485",
        ImageColor3 = CW, ScaleType = Enum.ScaleType.Fit, ZIndex = 13,
    })
    local CR_CopyLabel = mk("TextLabel", {
        Parent = CR_CopyBtn, Size = UDim2.new(1, -32, 1, 0),
        Position = UDim2.new(0, 30, 0, 0),
        BackgroundTransparency = 1, Text = GetText("Copiar", "Copy"),
        Font = Enum.Font.GothamBold, TextSize = 13,
        TextColor3 = CW, ZIndex = 13,
    })
    CR_CopyLabel:SetAttribute("ThemeTextRole", "Text")
    CR_CopyLabel:SetAttribute("TextSpanish", "Copiar")
    CR_CopyLabel:SetAttribute("TextEnglish", "Copy")

    local CR_Copied = mk("TextLabel", {
        Parent = CR_DC, Size = UDim2.new(0, 148, 0, 13),
        Position = UDim2.new(1, -158, 1, -15),
        BackgroundTransparency = 1, Text = "",
        Font = Enum.Font.Gotham, TextSize = 10,
        TextColor3 = CGR, TextXAlignment = Enum.TextXAlignment.Right, ZIndex = 12,
    })

    CR_CopyBtn.MouseButton1Click:Connect(function()
        pcall(function() setclipboard("https://discord.gg/KAtgYysjp") end)
        CR_Copied.Text = GetText("✓ Link copiado al portapapeles", "✓ Link copied to clipboard")
        task.delay(3, function()
            if CR_Copied and CR_Copied.Parent then CR_Copied.Text = "" end
        end)
    end)

    --// FOOTER (28px)
    local CR_Footer = mk("Frame", {
        Parent = CredRoot, Size = UDim2.new(1, 0, 0, 28),
        BackgroundTransparency = 1, LayoutOrder = 5, ZIndex = 10,
    })

    mk("Frame", {
        Parent = CR_Footer, Size = UDim2.new(0.38, 0, 0, 1),
        Position = UDim2.new(0, 0, 0, 8),
        BackgroundColor3 = CS, BorderSizePixel = 0, ZIndex = 11,
    }):SetAttribute("ThemeRole", "Stroke")
    mk("Frame", {
        Parent = CR_Footer, Size = UDim2.new(0.38, 0, 0, 1),
        Position = UDim2.new(0.62, 0, 0, 8),
        BackgroundColor3 = CS, BorderSizePixel = 0, ZIndex = 11,
    }):SetAttribute("ThemeRole", "Stroke")
    mk("ImageLabel", {
        Parent = CR_Footer, Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0.5, -7, 0, 1),
        BackgroundTransparency = 1, Image = "rbxassetid://132202203337109",
        ImageColor3 = CDG, ScaleType = Enum.ScaleType.Fit, ZIndex = 12,
    })
    local CR_FooterText = mk("TextLabel", {
        Parent = CR_Footer, Size = UDim2.new(1, 0, 0, 13),
        Position = UDim2.new(0, 0, 0, 15),
        BackgroundTransparency = 1,
        Text = GetText("© 2026 Yin Yang | Script Hub  •  Todos los derechos reservados.",
                       "© 2026 Yin Yang | Script Hub  •  All rights reserved."),
        Font = Enum.Font.Gotham, TextSize = 9,
        TextColor3 = CDG, TextXAlignment = Enum.TextXAlignment.Center, ZIndex = 11,
    })
    CR_FooterText:SetAttribute("ThemeTextRole", "Stroke")
    CR_FooterText:SetAttribute("TextSpanish", "© 2026 Yin Yang | Script Hub  •  Todos los derechos reservados.")
    CR_FooterText:SetAttribute("TextEnglish", "© 2026 Yin Yang | Script Hub  •  All rights reserved.")

    --// ════════════════════════════════════════════════════════════════
    --// ⚠️ NO ELIMINAR — API PÚBLICA SPOTIFY
    --// Permite que scripts externos creen la pestaña Spotify en su UI.
    --// Sin esto, el Beta y cualquier script externo NO pueden tener Spotify.
    --// Uso: local UI = _G.YinYang:CreateWindow("App", "Dark")
    --//      UI:CreateSpotifyTab()
    --// ════════════════════════════════════════════════════════════════
    function Window:CreateSpotifyTab()
    local STab = Window:CreateTab("Spotify", "Spotify", "rbxassetid://133998910541098")
    local SPage = STab.Page

    SPage.BackgroundColor3 = Theme.Background
    SPage.BackgroundTransparency = 1
    SPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    SPage.ScrollBarThickness = 2
    SPage.ScrollingEnabled = true

    local SPOTIFY_CATALOG_URL = "https://raw.githubusercontent.com/Yinyangzx/Yin-music/refs/heads/main/YinYang_Spotify_Catalog.lua"

    local function asset(id)
        return "rbxassetid://" .. tostring(id)
    end

    local function trim(s)
        return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
    end

    local function clamp(v, minV, maxV)
        if v < minV then return minV end
        if v > maxV then return maxV end
        return v
    end

    local function durationToSeconds(duration)
        if type(duration) == "number" then
            return math.max(0, math.floor(duration))
        end

        local text = trim(duration)
        if text == "" then
            return 0
        end

        local mm, ss = text:match("^(%d+):(%d+)$")
        if mm and ss then
            return tonumber(mm) * 60 + tonumber(ss)
        end

        local numeric = tonumber(text)
        return numeric and math.max(0, math.floor(numeric)) or 0
    end

    local function secondsToClock(seconds)
        seconds = math.max(0, math.floor(tonumber(seconds) or 0))
        local mm = math.floor(seconds / 60)
        local ss = seconds % 60
        return string.format("%d:%02d", mm, ss)
    end

    local function safeDestroy(instance)
        if instance then
            pcall(function()
                instance:Destroy()
            end)
        end
    end

    local function destroyAllSpotifySounds()
        -- Evita superposición de sonidos si el script se ejecuta más de una vez
        -- o si quedó algún Sound viejo fuera del estado actual.
        local function clean(parent)
            if not parent then
                return
            end
            for _, inst in ipairs(parent:GetDescendants()) do
                if inst:IsA("Sound") and inst.Name == "YY_Spotify_CurrentSound" then
                    pcall(function()
                        inst:Stop()
                    end)
                    safeDestroy(inst)
                end
            end
        end

        clean(workspace)
        if game:GetService("SoundService") then
            clean(game:GetService("SoundService"))
        end
    end

    local function normalizeTrack(track, index)
        if type(track) ~= "table" then
            return nil
        end

        local name = track.Name or track.name or track.Title or track.title or ("Track " .. tostring(index))
        local artist = track.Artist or track.artist or ""
        local duration = track.Duration or track.duration or "0:00"
        if type(duration) == "number" then
            duration = secondsToClock(duration)
        else
            duration = trim(duration)
            if duration == "" then
                duration = "0:00"
            end
        end

        local cover = track.Cover or track.cover or track.CoverId or track.coverId or track.coverUrl or ""
        local audioUrl = track.AudioURL or track.audioUrl or track.AudioUrl or track.audioURL or ""
        local cacheName = track.CacheName or track.cacheName or track.audioFile or track.AudioFile
        if not cacheName or trim(cacheName) == "" then
            local safeName = tostring(name):lower():gsub("[^%w]+", "_"):gsub("_+", "_"):gsub("^_", ""):gsub("_$", "")
            if safeName == "" then
                safeName = "track_" .. tostring(index)
            end
            cacheName = safeName .. ".mp3"
        end

        local id = track.Id or track.id or track.ID or tostring(index)

        return {
            Id = id,
            Name = tostring(name),
            Artist = tostring(artist),
            Duration = duration,
            Cover = tostring(cover),
            AudioURL = tostring(audioUrl),
            CacheName = tostring(cacheName),
            Raw = track,
        }
    end

    local SpotifyState = {
        Catalog = {},
        SelectedIndex = 1,
        IsPlaying = false,
        IsRepeat = false,
        CurrentLiked = {},
        RowButtons = {},
        HiddenRows = {},
        CurrentSound = nil,
        SoundProgressConnection = nil,
        SoundEndedConnection = nil,
        CurrentTrack = nil,
        CurrentTrackSeconds = 0,
        CurrentPausedPosition = 0,
        CatalogLoaded = false,
        SearchQuery = "",
    }

    local function getRenderOrder()
        local order = {}
        for i = 1, #SpotifyState.Catalog do
            order[#order + 1] = i
        end

        table.sort(order, function(a, b)
            local likedA = SpotifyState.CurrentLiked[a] == true
            local likedB = SpotifyState.CurrentLiked[b] == true
            if likedA ~= likedB then
                return likedA and not likedB
            end
            return a < b
        end)

        return order
    end


    local function normalizeSearchText(value)
        local s = tostring(value or "")
        local replacements = {
            ["á"] = "a", ["à"] = "a", ["ä"] = "a", ["â"] = "a", ["ã"] = "a", ["å"] = "a",
            ["Á"] = "a", ["À"] = "a", ["Ä"] = "a", ["Â"] = "a", ["Ã"] = "a", ["Å"] = "a",
            ["é"] = "e", ["è"] = "e", ["ë"] = "e", ["ê"] = "e",
            ["É"] = "e", ["È"] = "e", ["Ë"] = "e", ["Ê"] = "e",
            ["í"] = "i", ["ì"] = "i", ["ï"] = "i", ["î"] = "i",
            ["Í"] = "i", ["Ì"] = "i", ["Ï"] = "i", ["Î"] = "i",
            ["ó"] = "o", ["ò"] = "o", ["ö"] = "o", ["ô"] = "o", ["õ"] = "o",
            ["Ó"] = "o", ["Ò"] = "o", ["Ö"] = "o", ["Ô"] = "o", ["Õ"] = "o",
            ["ú"] = "u", ["ù"] = "u", ["ü"] = "u", ["û"] = "u",
            ["Ú"] = "u", ["Ù"] = "u", ["Ü"] = "u", ["Û"] = "u",
            ["ñ"] = "n", ["Ñ"] = "n",
            ["ç"] = "c", ["Ç"] = "c",
        }
        for from, to in pairs(replacements) do
            s = s:gsub(from, to)
        end
        s = s:lower()
        s = trim(s)
        return s
    end

    local function getVisibleRenderOrder()
        local query = normalizeSearchText(SpotifyState.SearchQuery or "")
        local order = getRenderOrder()
        if query == "" then
            return order
        end

        local tokens = {}
        for token in query:gmatch("%S+") do
            tokens[#tokens + 1] = token
        end

        local filtered = {}
        for _, index in ipairs(order) do
            local track = SpotifyState.Catalog[index]
            if track then
                local haystack = normalizeSearchText((track.Name or "") .. " " .. (track.Artist or "") .. " " .. (track.Duration or ""))
                local matched = true

                for _, token in ipairs(tokens) do
                    if not haystack:find(token, 1, true) then
                        matched = false
                        break
                    end
                end

                if matched then
                    filtered[#filtered + 1] = index
                end
            end
        end
        return filtered
    end

    local spotifyGreen = Color3.fromRGB(29, 185, 84)
    local spotifyText = Theme.Text
    local spotifyDim = Theme.TextDim

    local spotifyPanel = Theme.Background

    local function getSpotifyMetrics()
        local width = 0
        pcall(function()
            width = (SPage and SPage.AbsoluteSize and SPage.AbsoluteSize.X) or 0
        end)

        local compact = width > 0 and width < 640

        return {
            compact = compact,
            playerHeight = compact and 200 or 220,
            albumSize = compact and 130 or 150,
            albumTop = compact and 32 or 36,
            infoLeft = compact and 154 or 174,
            infoWidth = compact and -172 or -192,
            titleSize = compact and 20 or 22,
            artistSize = compact and 13 or 14,
            metaSize = compact and 10 or 11,
            progressBottom = compact and -30 or -34,
            controlsBottom = compact and -46 or -52,
            controlsHeight = compact and 40 or 44,
            repeatX = compact and 0.06 or 0.05,
            likeX = compact and 0.15 or 0.14,
            playX = compact and 0.59 or 0.58,
            nextX = compact and 0.85 or 0.87,
            moreX = compact and 0.95 or 0.96,
            playSize = compact and 30 or 34,
            rowHeight = compact and 64 or 72,
            rowCover = compact and 40 or 44,
            rowTitleSize = compact and 14 or 15,
            rowArtistSize = compact and 10 or 11,
            rowDurationSize = compact and 10 or 11,
            rowTitleRight = compact and -140 or -170,
            rowDurationX = compact and -126 or -140,
            rowPlusX = compact and -72 or -84,
            rowPlayX = compact and -30 or -42,
        }
    end


    local SpotifyRoot = mk("Frame", {
        Parent = SPage,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        LayoutOrder = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 10,
    })

    mk("UIPadding", {
        Parent = SpotifyRoot,
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 10),
    })

    local SpotifyRootLayout = mk("UIListLayout", {
        Parent = SpotifyRoot,
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    local SongList, SongListLayout

    local function updateSpotifyCanvas()
        local contentY = 0
        pcall(function()
            contentY = SpotifyRootLayout.AbsoluteContentSize.Y
        end)
        SPage.CanvasSize = UDim2.new(0, 0, 0, math.max(0, math.floor(contentY + 20)))
    end

    local function updateSongListCanvas()
        local contentY = 0
        pcall(function()
            contentY = SongListLayout.AbsoluteContentSize.Y
        end)

        local rowCount = #SpotifyState.RowButtons
        if contentY <= 0 and rowCount > 0 then
            local m = getSpotifyMetrics()
            contentY = (rowCount * m.rowHeight) + math.max(0, (rowCount - 1) * 8)
        end

        -- En la versión estable la lista se autoexpande por contenido.
        -- Si el layout tarda un frame en reportar tamaño, esta función
        -- solo fuerza una nueva lectura para refrescar el canvas padre.
        if SongList.AutomaticSize == Enum.AutomaticSize.None then
            SongList.Size = UDim2.new(1, 0, 0, math.max(0, math.floor(contentY + 8)))
        end
    end

    -- Header eliminado: el título "Spotify • NEW" ya no ocupa espacio extra

    local SpotifyShell = mk("Frame", {
        Parent = SpotifyRoot,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = spotifyPanel,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = 1,
        ClipsDescendants = false,
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 10,
    })
    corner(SpotifyShell, 18)
    stroke(SpotifyShell, Color3.fromRGB(90, 90, 96), 1, 0.35)

    mk("UIPadding", {
        Parent = SpotifyShell,
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
    })

    mk("UIListLayout", {
        Parent = SpotifyShell,
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    -- ═══════════════════════════════════════════════════════
    -- CARD REDISEÑADA: Imagen ARRIBA centrada y grande
    -- ═══════════════════════════════════════════════════════
    local NowPlayingCard = mk("Frame", {
        Parent = SpotifyShell,
        Size = UDim2.new(1, 0, 0, 413),
        BackgroundColor3 = spotifyPanel,
        BackgroundTransparency = 0.88,
        BorderSizePixel = 0,
        LayoutOrder = 1,
        ZIndex = 11,
    })
    corner(NowPlayingCard, 16)
    stroke(NowPlayingCard, Color3.fromRGB(90, 90, 96), 1, 0.45)

    -- Botón "..." en esquina superior derecha
    local MoreTopBtn = mk("ImageButton", {
        Parent = NowPlayingCard,
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(1, -26, 0, 10),
        AnchorPoint = Vector2.new(0, 0),
        BackgroundTransparency = 1,
        Image = asset(89968119092860),
        ImageColor3 = spotifyText,
        AutoButtonColor = false,
        ZIndex = 13,
    })

    -- IMAGEN DEL ÁLBUM: centrada arriba, grande
    local AlbumArt = mk("ImageLabel", {
        Parent = NowPlayingCard,
        Size = UDim2.new(0, 176, 0, 176),
        Position = UDim2.new(0.5, -88, 0, 14),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.82,
        BorderSizePixel = 0,
        Image = "",
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 12,
    })
    corner(AlbumArt, 16)
    stroke(AlbumArt, spotifyGreen, 2.5, 0.10)
    buildAnimatedBorder(AlbumArt, spotifyGreen, UDim.new(0, 16), true)

    local AlbumFallback = mk("Frame", {
        Parent = AlbumArt,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 13,
    })

    local AlbumFallbackText = mk("TextLabel", {
        Parent = AlbumFallback,
        Size = UDim2.new(1, -12, 1, -12),
        Position = UDim2.new(0, 6, 0, 6),
        BackgroundTransparency = 1,
        Text = "♪",
        Font = Enum.Font.GothamBlack,
        TextSize = 56,
        TextColor3 = spotifyGreen,
        ZIndex = 13,
    })

    -- INFO FRAME: debajo de la imagen, centrado
    local InfoFrame = mk("Frame", {
        Parent = NowPlayingCard,
        Size = UDim2.new(1, -28, 0, 80),
        Position = UDim2.new(0, 14, 0, 212),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 12,
    })

    local PlayerSongTitle = mk("TextLabel", {
        Parent = InfoFrame,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = "Selecciona una canción",
        Font = Enum.Font.GothamBlack,
        TextSize = 22,
        TextColor3 = spotifyText,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 12,
    })

    local PlayerSongArtist = mk("TextLabel", {
        Parent = InfoFrame,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 32),
        BackgroundTransparency = 1,
        Text = "El catálogo se carga desde GitHub",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextColor3 = spotifyDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 12,
    })

    local PlayerMeta = mk("TextLabel", {
        Parent = InfoFrame,
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0, 56),
        BackgroundTransparency = 1,
        Text = "Esperando canción",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = spotifyDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 12,
    })

    -- BARRA DE PROGRESO: debajo del InfoFrame
    local ProgressTrack = mk("Frame", {
        Parent = NowPlayingCard,
        Size = UDim2.new(1, -28, 0, 5),
        Position = UDim2.new(0, 14, 0, 306),
        BackgroundColor3 = Color3.fromRGB(58, 58, 58),
        BorderSizePixel = 0,
        ZIndex = 12,
    })
    corner(ProgressTrack, 999)

    --// THUMB DEL SEEK: círculo blanco sobre la barra
    local SeekThumb = mk("Frame", {
        Parent = ProgressTrack,
        Size = UDim2.fromOffset(13, 13),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 15,
        Visible = false,
    })
    corner(SeekThumb, 999)

    --// TOOLTIP DE TIEMPO: aparece al mantener presionado
    local SeekTooltip = mk("Frame", {
        Parent = ProgressTrack,
        Size = UDim2.fromOffset(52, 26),
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0, 0, 0, -8),
        BackgroundTransparency = 1,  -- SIN fondo negro, solo el texto
        BorderSizePixel = 0,
        ZIndex = 16,
        Visible = false,
    })
    corner(SeekTooltip, 6)
    local SeekTooltipLabel = mk("TextLabel", {
        Parent = SeekTooltip,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "0:00",
        Font = Enum.Font.GothamBlack,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 17,
    })

    local ProgressFill = mk("Frame", {
        Parent = ProgressTrack,
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = spotifyGreen,
        BorderSizePixel = 0,
        ZIndex = 13,
    })
    corner(ProgressFill, 999)

    --// ZONA CLICKABLE sobre la barra de progreso (más alta para facilitar el toque)
    local SeekHitbox = mk("TextButton", {
        Parent = NowPlayingCard,
        Size = UDim2.new(1, -28, 0, 28),
        Position = UDim2.new(0, 14, 0, 295),  -- zona touch amplia centrada sobre ProgressTrack
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 14,
    })

    local isSeeking = false
    local seekInput = nil

    local function getSeekPercent(inputX)
        local trackPos = ProgressTrack.AbsolutePosition.X
        local trackWidth = ProgressTrack.AbsoluteSize.X
        if trackWidth <= 0 then return 0 end
        return math.clamp((inputX - trackPos) / trackWidth, 0, 1)
    end

    local function applySeekVisuals(pct)
        SeekThumb.Position = UDim2.new(pct, 0, 0.5, 0)
        SeekTooltip.Position = UDim2.new(pct, 0, 0, -8)
        local total = 0
        if SpotifyState.CurrentSound and SpotifyState.CurrentSound.TimeLength > 0 then
            total = SpotifyState.CurrentSound.TimeLength
        elseif SpotifyState.CurrentTrack then
            total = durationToSeconds(SpotifyState.CurrentTrack.Duration)
        end
        local seekSec = math.floor(pct * math.max(total, 1))
        SeekTooltipLabel.Text = secondsToClock(seekSec)
    end

    SeekHitbox.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        isSeeking = true
        seekInput = input
        SeekThumb.Visible = true
        SeekTooltip.Visible = true
        local pct = getSeekPercent(input.Position.X)
        applySeekVisuals(pct)
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not isSeeking then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local pct = getSeekPercent(input.Position.X)
        applySeekVisuals(pct)
        ProgressFill.Size = UDim2.new(pct, 0, 1, 0)
    end)

    UserInputService.InputEnded:Connect(function(input)
        if not isSeeking then return end
        if input ~= seekInput then return end
        isSeeking = false
        seekInput = nil
        SeekThumb.Visible = false
        SeekTooltip.Visible = false
        --// Aplicar el seek al sonido
        local pct = getSeekPercent(input.Position.X)
        if SpotifyState.CurrentSound then
            pcall(function()
                local total = SpotifyState.CurrentSound.TimeLength
                if total > 0 then
                    local newPos = pct * total
                    SpotifyState.CurrentSound.TimePosition = newPos
                    SpotifyState.CurrentPausedPosition = newPos
                    if SpotifyState.IsPlaying then
                        SpotifyState.CurrentSound:Play()
                    end
                end
            end)
        end
    end)

    -- Tiempos debajo de la barra
    local ProgressTimeLeft = mk("TextLabel", {
        Parent = NowPlayingCard,
        Size = UDim2.new(0, 72, 0, 16),
        Position = UDim2.new(0, 14, 0, 319),
        BackgroundTransparency = 1,
        Text = "0:00",
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = spotifyDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 12,
    })

    local ProgressTimeRight = mk("TextLabel", {
        Parent = NowPlayingCard,
        Size = UDim2.new(0, 72, 0, 16),
        Position = UDim2.new(1, -86, 0, 319),
        BackgroundTransparency = 1,
        Text = "0:00",
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = spotifyDim,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 12,
    })

    -- CONTROLES: debajo de la barra de tiempo, nunca se superpone (posición desde arriba)
    local Controls = mk("Frame", {
        Parent = NowPlayingCard,
        Size = UDim2.new(1, -28, 0, 48),
        Position = UDim2.new(0, 14, 0, 351),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 12,
    })

    local function createIconButton(parent, size, imageId, imageColor, bgColor, rounded)
        local btn = mk("ImageButton", {
            Parent = parent,
            Size = UDim2.new(0, size, 0, size),
            BackgroundColor3 = bgColor or Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = bgColor and 0 or 1,
            Image = asset(imageId),
            ImageColor3 = imageColor or Color3.new(1, 1, 1),
            AutoButtonColor = false,
            ZIndex = 13,
        })
        if rounded then
            corner(btn, rounded)
        end
        return btn
    end

    -- Botones de control mejorados: Play más grande, íconos más visibles
    local RepeatBtn = createIconButton(Controls, 22, 95777420020131, spotifyText)
    RepeatBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    RepeatBtn.Position = UDim2.new(0.06, 0, 0.5, 0)

    local LikeBtn = createIconButton(Controls, 24, 82989818174730, spotifyText)
    LikeBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    LikeBtn.Position = UDim2.new(0.22, 0, 0.5, 0)

    --// PlayPauseBtn: circulo verde grande, icono play/pause mas pequeño dentro
    local PlayPauseBtnOuter = mk("Frame", {
        Parent = Controls,
        Size = UDim2.new(0, 44, 0, 44),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.50, 0, 0.5, 0),
        BackgroundColor3 = spotifyGreen,
        BorderSizePixel = 0,
        ZIndex = 13,
    })
    corner(PlayPauseBtnOuter, 999)

    local PlayPauseBtn = mk("ImageButton", {
        Parent = PlayPauseBtnOuter,
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0.5, -11, 0.5, -11),
        BackgroundTransparency = 1,
        Image = asset(72179599540578),
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ScaleType = Enum.ScaleType.Fit,
        AutoButtonColor = false,
        ZIndex = 14,
    })
    PlayPauseBtn.AnchorPoint = Vector2.new(0, 0)

    local NextBtn = createIconButton(Controls, 24, 82197628280626, spotifyText)
    NextBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    NextBtn.Position = UDim2.new(0.78, 0, 0.5, 0)

    local MoreBtn = createIconButton(Controls, 22, 89968119092860, spotifyText)
    MoreBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    MoreBtn.Position = UDim2.new(0.94, 0, 0.5, 0)

    local SongsCard = mk("Frame", {
        Parent = SpotifyShell,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = spotifyPanel,
        BackgroundTransparency = 0.88,
        BorderSizePixel = 0,
        LayoutOrder = 2,
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 11,
    })
    corner(SongsCard, 16)
    stroke(SongsCard, Color3.fromRGB(90, 90, 96), 1, 0.45)

    mk("UIPadding", {
        Parent = SongsCard,
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 10),
    })

    local SongsLayout = mk("UIListLayout", {
        Parent = SongsCard,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    local SongsTitle = mk("TextLabel", {
        Parent = SongsCard,
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        Text = "Canciones",
        Font = Enum.Font.GothamBlack,
        TextSize = 22,
        TextColor3 = spotifyText,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12,
    })

    local CatalogStatus = mk("TextLabel", {
        Parent = SongsCard,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        LayoutOrder = 2,
        Text = "Cargando catálogo...",
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextColor3 = spotifyDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12,
    })

    local SongSearchHolder = mk("Frame", {
        Parent = SongsCard,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(22, 22, 26),
        BackgroundTransparency = 0.10,
        BorderSizePixel = 0,
        LayoutOrder = 3,
        ZIndex = 12,
    })
    corner(SongSearchHolder, 12)
    stroke(SongSearchHolder, Color3.fromRGB(75, 75, 82), 1, 0.55)

    local SongSearchIcon = mk("ImageButton", {
        Parent = SongSearchHolder,
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 10, 0.5, -9),
        BackgroundTransparency = 1,
        Image = asset(100388562921803),
        ImageColor3 = spotifyDim,
        AutoButtonColor = false,
        ZIndex = 13,
    })

    local SongSearchBox = mk("TextBox", {
        Parent = SongSearchHolder,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 32, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        ClearTextOnFocus = false,
        PlaceholderText = "Buscar por nombre o artista...",
        PlaceholderColor3 = spotifyDim,
        TextColor3 = spotifyText,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 13,
    })

    SongSearchIcon.Activated:Connect(function()
        pcall(function()
            SongSearchBox:CaptureFocus()
        end)
    end)

    SongList = mk("Frame", {
        Parent = SongsCard,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = 4,
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = false,
        ZIndex = 11,
    })

    SongListLayout = mk("UIListLayout", {
        Parent = SongList,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    mk("UIPadding", {
        Parent = SongList,
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
    })

    SongListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        updateSongListCanvas()
    end)

    local renderSongRows
    local clearSongRows
    local createSongRow

    SongSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        SpotifyState.SearchQuery = SongSearchBox.Text or ""
        if renderSongRows then
            renderSongRows()
        end
        updateSongListCanvas()
    end)

    SpotifyRootLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        updateSpotifyCanvas()
    end)

    local function applySpotifyNowPlayingLayout()
        local m = getSpotifyMetrics()

        -- Layout vertical en CADENA: cada bloque se posiciona en base al final
        -- del bloque anterior, así que imagen / info / progreso / tiempos /
        -- controles NUNCA pueden superponerse, sin importar el modo (compacto
        -- o normal) ni si se agranda la imagen del álbum en el futuro.
        local albumSz = m.compact and 152 or 176
        local albumTop = m.compact and 12 or 14
        local infoGap = m.compact and 16 or 22
        local infoTop = albumTop + albumSz + infoGap
        local infoHeight = 80
        local progressGap = m.compact and 10 or 14
        local progressTop = infoTop + infoHeight + progressGap
        local progressTrackH = 5
        local timeGap = m.compact and 6 or 8
        local timeTop = progressTop + progressTrackH + timeGap
        local timeH = 16
        local controlsGap = m.compact and 12 or 16
        local controlsTop = timeTop + timeH + controlsGap
        local controlsH = m.compact and 44 or 48
        local bottomPad = m.compact and 12 or 14
        local cardH = controlsTop + controlsH + bottomPad

        NowPlayingCard.Size = UDim2.new(1, 0, 0, cardH)

        AlbumArt.Size = UDim2.new(0, albumSz, 0, albumSz)
        AlbumArt.Position = UDim2.new(0.5, -(albumSz / 2), 0, albumTop)

        InfoFrame.Size = UDim2.new(1, -28, 0, infoHeight)
        InfoFrame.Position = UDim2.new(0, 14, 0, infoTop)

        PlayerSongTitle.TextSize = m.compact and 20 or 22
        PlayerSongArtist.Position = UDim2.new(0, 0, 0, 32)
        PlayerSongArtist.TextSize = m.compact and 13 or 14
        PlayerMeta.Position = UDim2.new(0, 0, 0, 56)
        PlayerMeta.TextSize = m.compact and 10 or 11

        ProgressTrack.Position = UDim2.new(0, 14, 0, progressTop)
        SeekHitbox.Position = UDim2.new(0, 14, 0, progressTop - 14)  -- zona touch centrada sobre la barra
        ProgressTimeLeft.Position = UDim2.new(0, 14, 0, timeTop)
        ProgressTimeRight.Position = UDim2.new(1, -86, 0, timeTop)
        ProgressTimeLeft.TextSize = m.compact and 11 or 12
        ProgressTimeRight.TextSize = m.compact and 11 or 12

        Controls.Size = UDim2.new(1, -28, 0, controlsH)
        Controls.Position = UDim2.new(0, 14, 0, controlsTop)

        RepeatBtn.AnchorPoint = Vector2.new(0.5, 0.5)
        LikeBtn.AnchorPoint = Vector2.new(0.5, 0.5)
        PlayPauseBtnOuter.AnchorPoint = Vector2.new(0.5, 0.5)
        NextBtn.AnchorPoint = Vector2.new(0.5, 0.5)
        MoreBtn.AnchorPoint = Vector2.new(0.5, 0.5)

        RepeatBtn.Size = UDim2.new(0, m.compact and 20 or 22, 0, m.compact and 20 or 22)
        RepeatBtn.Position = UDim2.new(0.06, 0, 0.5, 0)

        LikeBtn.Size = UDim2.new(0, m.compact and 22 or 24, 0, m.compact and 22 or 24)
        LikeBtn.Position = UDim2.new(0.22, 0, 0.5, 0)

        PlayPauseBtnOuter.Size = UDim2.new(0, m.compact and 38 or 44, 0, m.compact and 38 or 44)
        PlayPauseBtnOuter.Position = UDim2.new(0.50, 0, 0.5, 0)
        PlayPauseBtn.Size = UDim2.new(0, m.compact and 18 or 22, 0, m.compact and 18 or 22)
        PlayPauseBtn.Position = UDim2.new(0.5, m.compact and -9 or -11, 0.5, m.compact and -9 or -11)

        NextBtn.Size = UDim2.new(0, m.compact and 22 or 24, 0, m.compact and 22 or 24)
        NextBtn.Position = UDim2.new(0.78, 0, 0.5, 0)

        MoreBtn.Size = UDim2.new(0, m.compact and 20 or 22, 0, m.compact and 20 or 22)
        MoreBtn.Position = UDim2.new(0.94, 0, 0.5, 0)

        SongsTitle.TextSize = m.compact and 20 or 22
        CatalogStatus.TextSize = m.compact and 11 or 12
    end

    local function applySpotifyRowLayout(rowData)
        if not rowData or not rowData.Row then
            return
        end

        local m = getSpotifyMetrics()
        -- Altura fija ampliada para mejor legibilidad
        local rowH = m.compact and 68 or 76

        rowData.Row.Size = UDim2.new(1, 0, 0, rowH)

        if rowData.Accent then
            rowData.Accent.Size = UDim2.new(0, 4, 1, m.compact and -12 or -16)
            rowData.Accent.Position = UDim2.new(0, 6, 0, m.compact and 6 or 8)
        end

        -- Cover: 52px, bien separada del borde izquierdo
        local coverSz = m.compact and 46 or 52
        if rowData.Cover then
            rowData.Cover.Size = UDim2.new(0, coverSz, 0, coverSz)
            rowData.Cover.Position = UDim2.new(0, 12, 0.5, -(coverSz / 2))
        end

        -- Texto: empieza claramente después de la imagen (12 + coverSz + 10)
        local textX = 12 + coverSz + 10
        if rowData.Title then
            rowData.Title.Size = UDim2.new(1, -(textX + 90), 0, m.compact and 20 or 22)
            rowData.Title.Position = UDim2.new(0, textX, 0, m.compact and 10 or 12)
            rowData.Title.TextSize = m.compact and 14 or 15
        end

        if rowData.Artist then
            rowData.Artist.Size = UDim2.new(1, -(textX + 90), 0, m.compact and 16 or 18)
            rowData.Artist.Position = UDim2.new(0, textX, 0, m.compact and 33 or 37)
            rowData.Artist.TextSize = m.compact and 11 or 12
        end

        if rowData.Duration then
            rowData.Duration.Size = UDim2.new(0, 44, 0, 18)
            rowData.Duration.Position = UDim2.new(1, -122, 0.5, -9)
            rowData.Duration.TextSize = m.compact and 12 or 13
        end

        if rowData.Plus then
            rowData.Plus.AnchorPoint = Vector2.new(0.5, 0.5)
            rowData.Plus.Size = UDim2.new(0, 24, 0, 24)
            rowData.Plus.Position = UDim2.new(1, -68, 0.5, 0)
            rowData.Plus.TextSize = m.compact and 20 or 22
        end

        if rowData.Play then
            rowData.Play.AnchorPoint = Vector2.new(0.5, 0.5)
            rowData.Play.Size = UDim2.new(0, 26, 0, 26)
            rowData.Play.Position = UDim2.new(1, -32, 0.5, 0)
        end

        if rowData.TapArea then
            rowData.TapArea.Size = UDim2.new(1, -100, 1, 0)
        end
    end

    local function refreshSpotifyUILayout()
        applySpotifyNowPlayingLayout()
        updateSpotifyCanvas()
        if SpotifyState.CatalogLoaded then
            renderSongRows()
        end
    end

    local layoutRefreshQueued = false
    local function queueSpotifyLayoutRefresh()
        if layoutRefreshQueued then
            return
        end
        layoutRefreshQueued = true
        task.defer(function()
            task.wait()
            layoutRefreshQueued = false
            pcall(refreshSpotifyUILayout)
        end)
    end

    SPage:GetPropertyChangedSignal("AbsoluteSize"):Connect(queueSpotifyLayoutRefresh)

    local function isLiked(index)
        return SpotifyState.CurrentLiked[index] == true
    end

    local function updateTrackRow(rowData, index)
        local track = SpotifyState.Catalog[index]
        if not rowData or not rowData.Row or not track then
            return
        end

        applySpotifyRowLayout(rowData)

        local active = (index == SpotifyState.SelectedIndex)
        rowData.Row.BackgroundColor3 = active and Color3.fromRGB(38, 38, 44) or Color3.fromRGB(22, 22, 26)

        if rowData.Accent then
            rowData.Accent.Visible = active
        end

        if rowData.Cover then
            rowData.Cover.Image = track.Cover
        end

        if rowData.Title then
            rowData.Title.Text = track.Name
            rowData.Title.TextColor3 = active and spotifyGreen or spotifyText
        end

        if rowData.Artist then
            rowData.Artist.Text = track.Artist
            rowData.Artist.TextColor3 = active and Color3.fromRGB(100, 220, 120) or spotifyDim
        end

        if rowData.Duration then
            rowData.Duration.Text = track.Duration
        end

        if rowData.Plus then
            pcall(function()
                rowData.Plus.Text = ""
                rowData.Plus.TextTransparency = 1
                rowData.Plus.BackgroundTransparency = 1
            end)
        end

        if rowData.Play then
            pcall(function()
                rowData.Play.Image = ""
                rowData.Play.ImageTransparency = 1
                rowData.Play.BackgroundTransparency = 1
            end)
        end
    end

    local function refreshAllRows()
        for i, rowData in ipairs(SpotifyState.RowButtons) do
            updateTrackRow(rowData, i)
        end
    end

    renderSongRows = function()
        clearSongRows()
        local order = getVisibleRenderOrder()
        for displayOrder, index in ipairs(order) do
            local track = SpotifyState.Catalog[index]
            if track then
                pcall(function()
                    createSongRow(track, index, displayOrder)
                end)
            end
        end
        updateSongListCanvas()
        updateSpotifyCanvas()
        task.defer(function()
            pcall(updateSongListCanvas)
            pcall(updateSpotifyCanvas)
        end)
    end

    local function updatePlayerFromTrack(track, index, statusText)
        if not track then
            return
        end

        AlbumArt.Image = track.Cover
        AlbumFallback.Visible = (track.Cover == nil or trim(track.Cover) == "")

        PlayerSongTitle.Text = track.Name
        PlayerSongArtist.Text = track.Artist
        PlayerMeta.Text = statusText or (SpotifyState.IsPlaying and "Reproducción activa" or "Reproducción lista")
        ProgressTimeRight.Text = track.Duration

        if index and SpotifyState.Catalog[index] then
            SpotifyState.SelectedIndex = index
        end

        refreshAllRows()
    end

    local function destroyCurrentSound()
        if SpotifyState.SoundProgressConnection then
            pcall(function()
                SpotifyState.SoundProgressConnection:Disconnect()
            end)
            SpotifyState.SoundProgressConnection = nil
        end

        if SpotifyState.SoundEndedConnection then
            pcall(function()
                SpotifyState.SoundEndedConnection:Disconnect()
            end)
            SpotifyState.SoundEndedConnection = nil
        end

        if SpotifyState.CurrentSound then
            pcall(function()
                SpotifyState.CurrentSound:Stop()
            end)
            safeDestroy(SpotifyState.CurrentSound)
            SpotifyState.CurrentSound = nil
        end
    end

    local function syncPlaybackUI()
        if SpotifyState.CurrentSound then
            PlayPauseBtn.Image = SpotifyState.IsPlaying and asset(125389410587367) or asset(72179599540578)
        else
            PlayPauseBtn.Image = asset(72179599540578)
        end

        RepeatBtn.ImageColor3 = SpotifyState.IsRepeat and spotifyGreen or spotifyText
        LikeBtn.ImageColor3 = isLiked(SpotifyState.SelectedIndex) and spotifyGreen or spotifyText

        if isLiked(SpotifyState.SelectedIndex) then
            LikeBtn.Image = asset(76432974703336)
        else
            LikeBtn.Image = asset(82989818174730)
        end
    end

    local function updateProgress(track, sound)
        local total = track and durationToSeconds(track.Duration) or 0
        if sound and sound.TimeLength and sound.TimeLength > 0 then
            total = math.max(total, math.floor(sound.TimeLength))
        end
        total = math.max(total, 1)

        local current = 0
        if sound and sound.TimePosition then
            current = math.floor(sound.TimePosition)
        end

        ProgressTimeLeft.Text = secondsToClock(current)
        ProgressTimeRight.Text = track and track.Duration or secondsToClock(total)
        ProgressFill.Size = UDim2.new(clamp(current / total, 0, 1), 0, 1, 0)
    end

    local function ensureTrackCached(track)
        local cacheName = track.CacheName
        local audioExists = false
        local audioPath = cacheName

        if isfile then
            local okFile, resultFile = pcall(function()
                return isfile(audioPath)
            end)
            audioExists = okFile and resultFile == true
        end

        if not audioExists then
            if not writefile then
                return false, "writefile_unavailable"
            end

            local okDownload, data = pcall(function()
                return game:HttpGet(track.AudioURL, true)
            end)

            if not okDownload or type(data) ~= "string" or #data < 10 then
                return false, "download_failed"
            end

            local okWrite = pcall(function()
                writefile(audioPath, data)
            end)

            if not okWrite then
                return false, "cache_write_failed"
            end
        end

        local customAsset = audioPath
        if getcustomasset then
            local okAsset, resultAsset = pcall(function()
                return getcustomasset(audioPath)
            end)
            if okAsset and type(resultAsset) == "string" then
                customAsset = resultAsset
            end
        end

        return true, customAsset
    end

    local function playTrack(index)
        local track = SpotifyState.Catalog[index]
        if not track then
            return
        end

        SpotifyState.SelectedIndex = index
        SpotifyState.CurrentTrack = track
        SpotifyState.CurrentTrackSeconds = durationToSeconds(track.Duration)
        SpotifyState.CurrentPausedPosition = 0
        SpotifyState.IsPlaying = true

        destroyAllSpotifySounds()
        destroyCurrentSound()

        updatePlayerFromTrack(track, index, "Descargando y reproduciendo...")
        syncPlaybackUI()

        local okCache, cachedAssetOrErr = ensureTrackCached(track)
        local soundAsset = okCache and cachedAssetOrErr or track.AudioURL

        local sound = Instance.new("Sound")
        sound.Name = "YY_Spotify_CurrentSound"
        sound.SoundId = soundAsset
        sound.Volume = 0.75
        sound.Looped = SpotifyState.IsRepeat
        sound.Parent = workspace

        SpotifyState.CurrentSound = sound

        SpotifyState.SoundProgressConnection = RunService.Heartbeat:Connect(function()
            if SpotifyState.CurrentSound == sound then
                updateProgress(track, sound)
            end
        end)

        SpotifyState.SoundEndedConnection = sound.Ended:Connect(function()
            if SpotifyState.CurrentSound ~= sound then
                return
            end

            --// Repeat: reiniciar desde el principio (Looped puede no funcionar en todos los executors)
            if SpotifyState.IsRepeat then
                task.spawn(function()
                    pcall(function()
                        sound.TimePosition = 0
                        sound:Play()
                        SpotifyState.IsPlaying = true
                        syncPlaybackUI()
                    end)
                end)
                return
            end

            local nextIndex = index + 1
            if nextIndex > #SpotifyState.Catalog then
                nextIndex = 1
            end
            playTrack(nextIndex)
        end)

        pcall(function()
            sound:Play()
        end)

        SpotifyState.IsPlaying = true
        updatePlayerFromTrack(track, index, okCache and "Reproduciendo desde caché" or "Reproduciendo desde URL")
        syncPlaybackUI()
    end

    local function selectTrack(index)
        local track = SpotifyState.Catalog[index]
        if not track then
            return
        end

        SpotifyState.SelectedIndex = index
        SpotifyState.CurrentTrack = track
        SpotifyState.IsPlaying = SpotifyState.CurrentSound ~= nil and SpotifyState.IsPlaying or false
        updatePlayerFromTrack(track, index, "Seleccionada: " .. track.Name)
        syncPlaybackUI()
    end

    local function toggleTrackLike(index)
        SpotifyState.CurrentLiked[index] = not isLiked(index)
        renderSongRows()
        syncPlaybackUI()
    end

    local function bindRowTap(guiObject, callback)
        if not guiObject then
            return
        end

        pcall(function()
            guiObject.Active = true
            guiObject.Selectable = false
        end)

        local fired = false
        local function fireOnce()
            if fired then
                return
            end
            fired = true

            local ok, err = pcall(callback)
            if not ok then
                warn("[YinYang Spotify] Row tap failed: " .. tostring(err))
            end

            task.defer(function()
                fired = false
            end)
        end

        if guiObject:IsA("GuiButton") then
            track(guiObject.Activated:Connect(fireOnce))
            track(guiObject.MouseButton1Click:Connect(fireOnce))
            return
        end

        local activeInput = nil
        local startPosition = nil
        local moved = false
        local threshold = 14

        track(guiObject.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                activeInput = input
                startPosition = input.Position
                moved = false
            end
        end))

        track(UserInputService.InputChanged:Connect(function(input)
            if activeInput and input == activeInput and startPosition then
                local delta = input.Position - startPosition
                if delta.Magnitude > threshold then
                    moved = true
                end
            end
        end))

        track(UserInputService.InputEnded:Connect(function(input)
            if activeInput and input == activeInput then
                if not moved then
                    fireOnce()
                end
                activeInput = nil
                startPosition = nil
                moved = false
            end
        end))
    end

    createSongRow = function(track, index, layoutOrder)
        if SpotifyState.HiddenRows[index] then
            return
        end

        local Row = mk("Frame", {
            Parent = SongList,
            Size = UDim2.new(1, 0, 0, 72),
            BackgroundColor3 = index == SpotifyState.SelectedIndex and Color3.fromRGB(24, 24, 30) or Color3.fromRGB(16, 16, 20),
            BackgroundTransparency = index == SpotifyState.SelectedIndex and 0.16 or 0.24,
            BorderSizePixel = 0,
            LayoutOrder = layoutOrder or (index + 1),
            ClipsDescendants = true,
            ZIndex = 11,
        })
        Row.Name = "SpotifySongRow_" .. index
        corner(Row, 12)

        local RowStroke = stroke(Row, Color3.fromRGB(126, 126, 136), 1, 0.72)
        pcall(function()
            RowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            RowStroke.LineJoinMode = Enum.LineJoinMode.Round
        end)

        --// EFECTO HOVER/TOUCH: transparencia al pasar el mouse o mantener dedo
        local baseRowTransparency = index == SpotifyState.SelectedIndex and 0.16 or 0.24
        Row.MouseEnter:Connect(function()
            TweenService:Create(Row, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundTransparency = math.max(0, baseRowTransparency - 0.18)}):Play()
        end)
        Row.MouseLeave:Connect(function()
            TweenService:Create(Row, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundTransparency = baseRowTransparency}):Play()
        end)
        Row.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                TweenService:Create(Row, TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundTransparency = math.max(0, baseRowTransparency - 0.20)}):Play()
            end
        end)
        Row.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                TweenService:Create(Row, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundTransparency = baseRowTransparency}):Play()
            end
        end)
        mk("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(0.45, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.40),
                NumberSequenceKeypoint.new(0.55, 0.18),
                NumberSequenceKeypoint.new(1, 0.38),
            }),
            Rotation = 0,
        }, RowStroke)

        mk("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 34, 42)),
                ColorSequenceKeypoint.new(0.55, Color3.fromRGB(20, 20, 24)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 16)),
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.10),
                NumberSequenceKeypoint.new(1, 0.10),
            }),
            Rotation = 0,
        }, Row)

        local TapArea = mk("TextButton", {
            Parent = Row,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 12,
        })
        TapArea.Name = "SongTapArea"

        local Accent = mk("Frame", {
            Parent = Row,
            Size = UDim2.new(0, 4, 1, -16),
            Position = UDim2.new(0, 10, 0, 8),
            BackgroundColor3 = spotifyGreen,
            BorderSizePixel = 0,
            Visible = index == SpotifyState.SelectedIndex,
            ZIndex = 12,
        })
        corner(Accent, 999)

        -- COVER: más grande y bien posicionada, sin solaparse con el texto
        local Cover = mk("ImageLabel", {
            Parent = Row,
            Size = UDim2.new(0, 52, 0, 52),
            Position = UDim2.new(0, 12, 0.5, -26),
            BackgroundColor3 = Color3.fromRGB(18, 18, 18),
            BackgroundTransparency = 0.04,
            BorderSizePixel = 0,
            Image = track.Cover,
            ScaleType = Enum.ScaleType.Crop,
            ZIndex = 12,
        })
        corner(Cover, 10)

        local CoverStroke = stroke(Cover, Color3.fromRGB(126, 126, 136), 1, 0.52)
        pcall(function()
            CoverStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            CoverStroke.LineJoinMode = Enum.LineJoinMode.Round
        end)
        mk("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(235, 235, 240)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(210, 210, 220)),
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.18),
                NumberSequenceKeypoint.new(0.6, 0.38),
                NumberSequenceKeypoint.new(1, 0.22),
            }),
            Rotation = 12,
        }, CoverStroke)

        -- TÍTULO: empieza DESPUÉS de la imagen (12 + 52 + 10 = 74px)
        local Title = mk("TextLabel", {
            Parent = Row,
            Size = UDim2.new(1, -160, 0, 22),
            Position = UDim2.new(0, 74, 0, 10),
            BackgroundTransparency = 1,
            Text = track.Name,
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextColor3 = index == SpotifyState.SelectedIndex and spotifyGreen or spotifyText,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 12,
        })
        Title.Name = "SongTitle"

        -- ARTISTA: también empieza después de la imagen
        local Artist = mk("TextLabel", {
            Parent = Row,
            Size = UDim2.new(1, -160, 0, 16),
            Position = UDim2.new(0, 74, 0, 36),
            BackgroundTransparency = 1,
            Text = track.Artist,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextColor3 = index == SpotifyState.SelectedIndex and Color3.fromRGB(100, 220, 120) or spotifyDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 12,
        })
        Artist.Name = "SongArtist"

        -- DURACIÓN: centrada verticalmente, fuente más legible
        local Duration = mk("TextLabel", {
            Parent = Row,
            Size = UDim2.new(0, 44, 0, 18),
            Position = UDim2.new(1, -122, 0.5, -9),
            BackgroundTransparency = 1,
            Text = track.Duration,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = spotifyDim,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 12,
        })
        Duration.Name = "SongDuration"

        -- Zonas invisibles para conservar la interacción sin mostrar iconos
        local Plus = mk("TextButton", {
            Parent = Row,
            Size = UDim2.new(0, 34, 0, 34),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(1, -68, 0.5, 0),
            BackgroundTransparency = 1,
            Text = "",
            TextTransparency = 1,
            Font = Enum.Font.GothamBlack,
            TextSize = 22,
            TextColor3 = Color3.new(1, 1, 1),
            AutoButtonColor = false,
            ZIndex = 16,
            Active = true,
        })
        Plus.Name = "SongPlus"

        local Play = mk("ImageButton", {
            Parent = Row,
            Size = UDim2.new(0, 34, 0, 34),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(1, -30, 0.5, 0),
            BackgroundTransparency = 1,
            Image = "",
            ImageTransparency = 1,
            ImageColor3 = Color3.new(1, 1, 1),
            AutoButtonColor = false,
            ZIndex = 16,
            Active = true,
        })
        Play.Name = "SongPlay"

        bindRowTap(TapArea, function()
            playTrack(index)
        end)

        --// FIX COMPLETO: Detección de input por posicion para superar robo de input del ScrollingFrame
        --// Los botones Plus y Play usan TODAS las conexiones posibles para garantizar respuesta
        local _plusFired = false
        local _playFired = false

        local function fireLike()
            if _plusFired then return end
            _plusFired = true
            toggleTrackLike(index)
            task.defer(function() _plusFired = false end)
        end

        local function firePlay()
            if _playFired then return end
            _playFired = true
            playTrack(index)
            task.defer(function() _playFired = false end)
        end

        -- Conexiones directas en los botones
        Plus.MouseButton1Click:Connect(fireLike)
        Plus.Activated:Connect(fireLike)
        Play.MouseButton1Click:Connect(firePlay)
        Play.Activated:Connect(firePlay)

        --// FALLBACK: Detección por posición en el Row (para móvil con ScrollingFrame)
        --// Si el ScrollingFrame consume el Activated, detectamos manualmente si el toque
        --// cayó dentro del área del corazón o del play
        Row.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.Touch and
               input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

            local inputX = input.Position.X
            local inputY = input.Position.Y

            -- Coordenadas absolutas de Plus y Play
            local plusPos  = Plus.AbsolutePosition
            local plusSize = Plus.AbsoluteSize
            local playPos  = Play.AbsolutePosition
            local playSize = Play.AbsoluteSize

            local inPlus = inputX >= plusPos.X and inputX <= plusPos.X + plusSize.X
                        and inputY >= plusPos.Y and inputY <= plusPos.Y + plusSize.Y
            local inPlay = inputX >= playPos.X and inputX <= playPos.X + playSize.X
                        and inputY >= playPos.Y and inputY <= playPos.Y + playSize.Y

            if inPlus then
                fireLike()
            elseif inPlay then
                firePlay()
            end
        end)

        SpotifyState.RowButtons[index] = {
            Row = Row,
            Accent = Accent,
            Cover = Cover,
            Title = Title,
            Artist = Artist,
            Duration = Duration,
            Plus = Plus,
            Play = Play,
            TapArea = TapArea,
        }

        applySpotifyRowLayout(SpotifyState.RowButtons[index])
        updateTrackRow(SpotifyState.RowButtons[index], index)
        return Row
    end
clearSongRows = function()
        for _, child in ipairs(SongList:GetChildren()) do
            if child ~= SongListLayout and not child:IsA("UIPadding") then
                safeDestroy(child)
            end
        end
        SpotifyState.RowButtons = {}
        updateSongListCanvas()
    end

    local function renderCatalog(catalog)
        clearSongRows()
        SPage.CanvasPosition = Vector2.new(0, 0)

        SpotifyState.Catalog = {}
        for i, track in ipairs(catalog or {}) do
            local normalized = normalizeTrack(track, i)
            if normalized then
                table.insert(SpotifyState.Catalog, normalized)
            end
        end

        if #SpotifyState.Catalog == 0 then
            CatalogStatus.Text = "No se encontró ninguna canción en el catálogo remoto."
            PlayerSongTitle.Text = "Catálogo vacío"
            PlayerSongArtist.Text = "Revisa el repositorio remoto"
            PlayerMeta.Text = "Sin canciones disponibles"
            AlbumArt.Image = ""
            ProgressTimeLeft.Text = "0:00"
            ProgressTimeRight.Text = "0:00"
            ProgressFill.Size = UDim2.new(0, 0, 1, 0)
            syncPlaybackUI()
            return
        end

        CatalogStatus.Text = "Catálogo cargado • " .. tostring(#SpotifyState.Catalog) .. " canciones"
        renderSongRows()
        updateSongListCanvas()
        updateSpotifyCanvas()

        local order = getRenderOrder()
        selectTrack(order[1] or 1)
        updateProgress(SpotifyState.Catalog[1], SpotifyState.CurrentSound)
        syncPlaybackUI()
    end

    local function loadCatalogFromRemote()
        destroyAllSpotifySounds()
        local catalogData = nil

        local okRemote, remoteResult = pcall(function()
            local raw = game:HttpGet(SPOTIFY_CATALOG_URL, true)
            local loader = loadstring(raw)
            if not loader then
                error("loadstring_failed")
            end
            return loader()
        end)

        if okRemote and type(remoteResult) == "table" then
            if type(remoteResult.Catalog) == "table" then
                catalogData = remoteResult.Catalog
            elseif type(remoteResult.catalog) == "table" then
                catalogData = remoteResult.catalog
            else
                catalogData = remoteResult
            end
        else
            warn("[Spotify] No se pudo cargar el catálogo remoto: " .. tostring(remoteResult))
        end

        if type(catalogData) ~= "table" then
            catalogData = {}
        end

        SpotifyState.CatalogLoaded = true
        renderCatalog(catalogData)
        updateSpotifyCanvas()
    end

    syncPlaybackUI()
    pcall(refreshSpotifyUILayout)
    updateSongListCanvas()
    updateSpotifyCanvas()
    task.defer(function()
        pcall(updateSongListCanvas)
        pcall(updateSpotifyCanvas)
    end)
    task.spawn(loadCatalogFromRemote)

    RepeatBtn.MouseButton1Click:Connect(function()
        SpotifyState.IsRepeat = not SpotifyState.IsRepeat
        --// Aplicar al sonido actual inmediatamente
        if SpotifyState.CurrentSound then
            pcall(function()
                SpotifyState.CurrentSound.Looped = SpotifyState.IsRepeat
                --// Si está en repeat y el sonido ya terminó (TimePosition cerca del final), reiniciar
                if SpotifyState.IsRepeat and SpotifyState.CurrentSound.TimePosition > 0 then
                    local len = SpotifyState.CurrentSound.TimeLength
                    if len > 0 and (len - SpotifyState.CurrentSound.TimePosition) < 0.5 then
                        SpotifyState.CurrentSound.TimePosition = 0
                        SpotifyState.CurrentSound:Play()
                    end
                end
            end)
        end
        syncPlaybackUI()
    end)

    LikeBtn.MouseButton1Click:Connect(function()
        toggleTrackLike(SpotifyState.SelectedIndex)
    end)

    --// El outer (circulo verde) tambien es clickeable para mejor area de toque
    PlayPauseBtnOuter.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or
           input.UserInputType == Enum.UserInputType.MouseButton1 then
            PlayPauseBtn.MouseButton1Click:Fire()
        end
    end)

    PlayPauseBtn.MouseButton1Click:Connect(function()
        if SpotifyState.CurrentSound then
            if SpotifyState.IsPlaying then
                SpotifyState.IsPlaying = false
                pcall(function()
                    SpotifyState.CurrentPausedPosition = math.max(0, tonumber(SpotifyState.CurrentSound.TimePosition) or 0)
                    SpotifyState.CurrentSound:Pause()
                end)
                PlayerMeta.Text = "Reproducción pausada"
            else
                SpotifyState.IsPlaying = true
                pcall(function()
                    if SpotifyState.CurrentSound and SpotifyState.CurrentPausedPosition and SpotifyState.CurrentPausedPosition > 0 then
                        SpotifyState.CurrentSound.TimePosition = math.max(0, SpotifyState.CurrentPausedPosition)
                    end
                    SpotifyState.CurrentSound:Play()
                    task.defer(function()
                        if SpotifyState.CurrentSound and SpotifyState.IsPlaying and SpotifyState.CurrentPausedPosition and SpotifyState.CurrentPausedPosition > 0 then
                            pcall(function()
                                SpotifyState.CurrentSound.TimePosition = math.max(0, SpotifyState.CurrentPausedPosition)
                            end)
                        end
                    end)
                end)
                PlayerMeta.Text = "Reproducción activa"
            end
            syncPlaybackUI()
            return
        end

        if SpotifyState.Catalog[SpotifyState.SelectedIndex] then
            playTrack(SpotifyState.SelectedIndex)
        end
    end)

    NextBtn.MouseButton1Click:Connect(function()
        if #SpotifyState.Catalog == 0 then
            return
        end

        local nextIndex = SpotifyState.SelectedIndex + 1
        if nextIndex > #SpotifyState.Catalog then
            nextIndex = 1
        end
        playTrack(nextIndex)
    end)

    MoreBtn.MouseButton1Click:Connect(function()
        PlayerMeta.Text = "Menú de opciones abierto"
    end)
    end

    return Window

end

--// ============================================================
--// LIBRERÍA GLOBAL - LISTA PARA USAR
--// ============================================================
--// YinYang es accesible globalmente como _G.YinYang
--// Uso desde otros scripts:
--//
--// local YinYang = _G.YinYang
--// local UI = YinYang:CreateWindow("Mi UI", "Dark")
--// local Tab = UI:CreateTab("Inicio")
--// Tab:CreateWelcomeCard()
--// Tab:CreateServerInfoCard()
--// Tab:CreateButton("Mi Botón", function() print("Click!") end)
--// Tab:CreateToggle("Toggle", false, function(state) print(state) end)
--// Tab:CreateDropdown("Category", {"Op1", "Op2"}, "Op1", function(val) print(val) end)
--// Tab:CreateMultiDropdown("Blacklist", {"A", "B", "C"}, {}, function(tbl) print(table.concat(tbl, ",")) end)
--//
--// ============================================================

print(" Yin Yang v24 CON TEMA CAT V1  - ¡Librería cargada y lista para usar!")

--// ============================================================
--// ZERO AI — Integrada en Yin Yang v28
--// Comando: escribe /mensaje en el chat global
--// Solo responde cuando el mensaje empieza con /
--// ============================================================

local _ZeroAI = (function()
    local Players     = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local StarterGui  = game:GetService("StarterGui")
    local LocalPlayer = Players.LocalPlayer
    if not LocalPlayer then return end

    local API_KEY    = "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"
    local MODEL      = "llama-3.3-70b-versatile"
    local MAX_TOKENS = 200
    local PLAYER_NAME = LocalPlayer.Name

    local SYSTEM_PROMPT = [[
Eres Zero, una IA integrada dentro de la librería UI llamada Yin Yang, específicamente dentro del script EVADE v5.2 Beta para el juego Roblox "Evade".

Estás sirviendo al jugador ]] .. PLAYER_NAME .. [[, quien es el desarrollador del script.

SOBRE QUIÉN ERES:
- Tu nombre es Zero
- Eres parte de la librería Yin Yang UI v28
- Fuiste diseñada para asistir a quien usa el script EVADE v5.2 Beta
- Hablas de forma directa, casual y concisa — nunca eres robótica ni formal
- Eres inteligente, sabes exactamente lo que hace cada opción del script

CONOCIMIENTO COMPLETO DEL SCRIPT EVADE v5.2 Beta:

PESTAÑA MOVEMENT:
1. Teleport Walk (FloatingToggle)
   - Mueve al jugador hacia adelante teletransportándolo en lugar de caminar normalmente
   - Velocidad ajustable con slider de 1 a 50
   - Se desactiva automáticamente si se activa Jump Frontal

2. Enhanced Jump (FloatingToggle)
   - Aumenta la altura del salto modificando JumpPower y UseJumpPower en el Humanoid
   - Altura ajustable con slider de 20 a 300
   - Se desactiva automáticamente si se activa Jump Frontal

3. Auto Jump (FloatingToggle)
   - Hace que el jugador salte automáticamente cuando está corriendo (estado Running)
   - Cambia el HumanoidState a Jumping cada Heartbeat

4. Jump Frontal - Beta (FloatingToggle)
   - Sistema de movimiento frontal complejo que propulsa al jugador hacia adelante
   - Al activarse: desactiva Teleport Walk, Enhanced Jump y Gravity Mod para evitar conflictos
   - Al desactivarse: restaura las opciones que estaban activas antes
   - Usa BodyVelocity con MaxForce (4e5, 4e5, 4e5) para el impulso
   - Raycast frontal (lookDir * 8-10) para detectar estructuras y rampas adelante
   - En el suelo: saltos cada 0.65 segundos con aceleración suave
   - En el aire: si detecta estructura aplica impulso con componente vertical (impactForce * 1.2)
   - Variables globales: getgenv().FrontalJumpSpeed (defecto 42), getgenv().RampMultiplier (defecto 1.55)
   - Speed Movement: slider 50-110
   - Ramp Multiplier: slider 1.0-5.0

5. Gravity Mod (FloatingToggle)
   - Reduce el efecto de la gravedad en el jugador
   - Gravity Scale: slider 0.1-2

PESTAÑA MAP FEATURES:
6. FullBright (FloatingToggle)
   - Ilumina completamente el mapa modificando propiedades de Lighting
   - Restaura la iluminación original al desactivarse

7. Auto Ticket (FloatingToggle)
   - Teleporta automáticamente al jugador a los tickets/coleccionables del mapa
   - Usa getgc(true) para encontrar CollectableIDs en memoria

SOBRE LA LIBRERÍA YIN YANG v28:
- Librería UI custom para Roblox con FloatingToggles, Sliders, Labels, Dividers y Tabs
- Los FloatingToggles son ventanas flotantes arrastrables
- Bug crítico ya corregido: pcall(cb, state) en el click de la pill flotante

REGLAS DE RESPUESTA:
- Máximo 2 oraciones por respuesta — apareces en el chat del juego
- Habla en español siempre, de forma casual
- Si no sabes algo con certeza, dilo — no inventes
]]

    local history = {
        { role = "system", content = SYSTEM_PROMPT }
    }
    local waiting = false

    local function chatMsg(text, color)
        pcall(function()
            StarterGui:SetCore("ChatMakeSystemMessage", {
                Text     = text,
                Color    = color or Color3.fromRGB(140, 120, 255),
                Font     = Enum.Font.GothamBold,
                TextSize = 14,
            })
        end)
    end

    local function ask(userText)
        if waiting then
            chatMsg("[⚡ Zero]: Espera, ya estoy procesando algo...", Color3.fromRGB(160, 140, 255))
            return
        end
        waiting = true

        table.insert(history, { role = "user", content = userText })

        task.spawn(function()
            local ok, reply = pcall(function()
                local body = HttpService:JSONEncode({
                    model       = MODEL,
                    messages    = history,
                    max_tokens  = MAX_TOKENS,
                    temperature = 0.75,
                })

                local res = request({
                    Url    = "https://api.groq.com/openai/v1/chat/completions",
                    Method = "POST",
                    Headers = {
                        ["Content-Type"]  = "application/json",
                        ["Authorization"] = "Bearer " .. API_KEY,
                    },
                    Body = body,
                })

                local data = HttpService:JSONDecode(res.Body)
                return data.choices[1].message.content
            end)

            waiting = false

            if ok and reply then
                table.insert(history, { role = "assistant", content = reply })
                chatMsg("[⚡ Zero]: " .. reply, Color3.fromRGB(140, 120, 255))
            else
                chatMsg("[⚡ Zero]: Error de conexión.", Color3.fromRGB(220, 80, 80))
            end
        end)
    end

    -- Solo escucha mensajes que empiecen con /
    LocalPlayer.Chatted:Connect(function(msg)
        if msg:sub(1, 1) ~= "/" then return end
        local text = msg:sub(2):match("^%s*(.-)%s*$")
        if not text or text == "" then return end
        chatMsg("[" .. PLAYER_NAME .. "]: " .. text, Color3.fromRGB(80, 180, 255))
        ask(text)
    end)

    -- Mensaje de bienvenida en el chat
    task.delay(1.5, function()
        chatMsg("[⚡ Zero]: Activa. Escribe /mensaje en el chat para hablarme.", Color3.fromRGB(140, 120, 255))
    end)

    print("✅ Zero AI integrada — usa /mensaje en el chat global")
end)()

--// ============================================================
--// DEMO VISUAL - MUESTRA TODAS LAS CARACTERÍSTICAS
--// ============================================================
--// INSTRUCCIONES:
--// - Para ACTIVAR la demo: Cambia "DEMO_ACTIVO" a true
--// - Para DESACTIVAR: Cambia "DEMO_ACTIVO" a false
--// ============================================================

local DEMO_ACTIVO = false  -- Demo desactivada

if DEMO_ACTIVO then
    task.wait(0.5)
    
    print("\n" .. string.rep("=", 60))
    print("INICIANDO DEMO VISUAL DE YIN YANG v24 - LIBRERÍA PROFESIONAL")
    print(string.rep("=", 60))
    
    --// 💾 v26: CARGAR CONFIGURACIÓN GUARDADA AL INICIAR
    local ConfigCargada = LoadConfig()
    local TemaInicial = "Dark"
    if ConfigCargada and ConfigCargada.theme then
        TemaInicial = ConfigCargada.theme
    end
    if ConfigCargada and ConfigCargada.lang then
        LanguageSystem.CurrentLanguage = ConfigCargada.lang
    end

    local DemoUI = _G.YinYang:CreateWindow("Yin Yang - DEMO v26", TemaInicial)
    
    --//  APLICAR TEMA GUARDADO - Re-pinta TODOS los colores, no solo la variable
    DemoUI:SetTheme(TemaInicial)
    
    -- =========================================================
    -- TAB INICIO (PROTEGIDA Y PERMANENTE)
    -- =========================================================
    local TabFeatures = DemoUI:CreateTab("Features")
    
    TabFeatures:CreateLabel("Toggles", 14)
    TabFeatures:CreateDivider()

    --// Helper local: crea un toggle premium con botón ↗ (flotar) y 📌 (fijar) a la derecha.
    --// El botón ↗ lanza una pill flotante arrastrable; 📌 alterna si se puede mover o no.
    local function createToggleWithFloat(tab, labelES, labelEN, default, callback)
        --// v29: delega en Tab:CreateFloatingToggle (la función real de la librería)
        --// en vez de reconstruir candado/flotar a mano, para que esta pestaña
        --// Features refleje SIEMPRE lo mismo que ve un script externo (incluye Favoritos)
        return tab:CreateFloatingToggle(labelES, labelEN, default, callback)
    end


    --// Toggles de demo usando el helper
    createToggleWithFloat(TabFeatures, "Aimbot", "Aimbot", false, function(state)
        print("Aimbot: " .. (state and "ON" or "OFF"))
    end)

    createToggleWithFloat(TabFeatures, "ESP", "ESP", false, function(state)
        print("ESP: " .. (state and "ON" or "OFF"))
    end)

    createToggleWithFloat(TabFeatures, "GodMode", "GodMode", false, function(state)
        print("GodMode: " .. (state and "ON" or "OFF"))
    end)

    --// ========================================================
    --// SECCIÓN: FLOATING BUTTONS (TESTING & SHOWCASE)
    --// ========================================================
    TabFeatures:CreateDivider()
    TabFeatures:CreateLabel("Botones Flotantes 🔘", 14)
    TabFeatures:CreateDivider()

    --// Botón simple — dispara una vez, sin cooldown
    TabFeatures:CreateFloatingButton("Teleport Here", "Teleport Here", function()
        print("[FloatingButton] Teleport Here → ejecutado")
    end)

    --// Botón con cooldown de 3 segundos — la pill muestra el countdown
    TabFeatures:CreateFloatingButton("Noclip", "Noclip", 3, function()
        print("[FloatingButton] Noclip → ejecutado (cooldown 3s)")
    end)

    --// Botón bilingüe con cooldown de 5 segundos
    TabFeatures:CreateFloatingButton("Eliminar Entidad", "Kill Entity", 5, function()
        print("[FloatingButton] Kill Entity → ejecutado (cooldown 5s)")
    end)

    --// ========================================================
    --// SECCIÓN: SLIDERS PREMIUM v2.0 (TESTING & SHOWCASE)
    --// ========================================================
    TabFeatures:CreateDivider()
    TabFeatures:CreateLabel("Sliders Premium v2.0 🚀", 14)
    TabFeatures:CreateDivider()

    --// SLIDER 1: TELEPORT SPEED
    local SliderTeleportSpeed = TabFeatures:CreateSlider("Teleport Speed", 1.0, 100.0, 23.1, function(val)
        print("🚀 Teleport Speed: " .. string.format("%.2f", val))
    end)

    --// SLIDER 2: JUMP HEIGHT
    local SliderJumpHeight = TabFeatures:CreateSlider("Jump Height", 10.0, 300.0, 139.24, function(val)
        print("⬆️  Jump Height: " .. string.format("%.2f", val))
    end)

    --// SLIDER 3: SPEED MULTIPLIER
    local SliderSpeed = TabFeatures:CreateSlider("Speed Multiplier", 0.5, 3.0, 1.5, function(val)
        print("💨 Speed: " .. string.format("%.2f", val) .. "x")
    end)

    --// SLIDER 4: FOV (Field of View)
    local SliderFOV = TabFeatures:CreateSlider("FOV", 30, 120, 70, function(val)
        print("👁️  FOV: " .. string.format("%.0f", val))
    end)

    --// SLIDER 5: VOLUME
    local SliderVolume = TabFeatures:CreateSlider("Volume", 0, 1.0, 0.5, function(val)
        print("🔊 Volume: " .. string.format("%.1f%%", val * 100))
    end)


    
    --// ========================================================
    --// PESTAÑA: SPOTIFY (CATÁLOGO REMOTO + CACHÉ LOCAL)
    --// Source of truth:
    --// https://raw.githubusercontent.com/Yinyangzx/Yin-music/refs/heads/main/YinYang_Spotify_Catalog.lua
    --// ========================================================
    local SpotifyTab = DemoUI:CreateTab("Spotify", "Spotify", "rbxassetid://133998910541098")
    local SpotifyPage = SpotifyTab.Page

    SpotifyPage.BackgroundColor3 = Theme.Background
    SpotifyPage.BackgroundTransparency = 1
    SpotifyPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
    SpotifyPage.CanvasSize = UDim2.new(0, 0, 0, 0)
    SpotifyPage.ScrollBarThickness = 2
    SpotifyPage.ScrollingEnabled = true

    local SPOTIFY_CATALOG_URL = "https://raw.githubusercontent.com/Yinyangzx/Yin-music/refs/heads/main/YinYang_Spotify_Catalog.lua"

    local function asset(id)
        return "rbxassetid://" .. tostring(id)
    end

    local function trim(s)
        return (tostring(s or ""):gsub("^%s+", ""):gsub("%s+$", ""))
    end

    local function clamp(v, minV, maxV)
        if v < minV then return minV end
        if v > maxV then return maxV end
        return v
    end

    local function durationToSeconds(duration)
        if type(duration) == "number" then
            return math.max(0, math.floor(duration))
        end

        local text = trim(duration)
        if text == "" then
            return 0
        end

        local mm, ss = text:match("^(%d+):(%d+)$")
        if mm and ss then
            return tonumber(mm) * 60 + tonumber(ss)
        end

        local numeric = tonumber(text)
        return numeric and math.max(0, math.floor(numeric)) or 0
    end

    local function secondsToClock(seconds)
        seconds = math.max(0, math.floor(tonumber(seconds) or 0))
        local mm = math.floor(seconds / 60)
        local ss = seconds % 60
        return string.format("%d:%02d", mm, ss)
    end

    local function safeDestroy(instance)
        if instance then
            pcall(function()
                instance:Destroy()
            end)
        end
    end

    local function destroyAllSpotifySounds()
        -- Evita superposición de sonidos si el script se ejecuta más de una vez
        -- o si quedó algún Sound viejo fuera del estado actual.
        local function clean(parent)
            if not parent then
                return
            end
            for _, inst in ipairs(parent:GetDescendants()) do
                if inst:IsA("Sound") and inst.Name == "YY_Spotify_CurrentSound" then
                    pcall(function()
                        inst:Stop()
                    end)
                    safeDestroy(inst)
                end
            end
        end

        clean(workspace)
        if game:GetService("SoundService") then
            clean(game:GetService("SoundService"))
        end
    end

    local function normalizeTrack(track, index)
        if type(track) ~= "table" then
            return nil
        end

        local name = track.Name or track.name or track.Title or track.title or ("Track " .. tostring(index))
        local artist = track.Artist or track.artist or ""
        local duration = track.Duration or track.duration or "0:00"
        if type(duration) == "number" then
            duration = secondsToClock(duration)
        else
            duration = trim(duration)
            if duration == "" then
                duration = "0:00"
            end
        end

        local cover = track.Cover or track.cover or track.CoverId or track.coverId or track.coverUrl or ""
        local audioUrl = track.AudioURL or track.audioUrl or track.AudioUrl or track.audioURL or ""
        local cacheName = track.CacheName or track.cacheName or track.audioFile or track.AudioFile
        if not cacheName or trim(cacheName) == "" then
            local safeName = tostring(name):lower():gsub("[^%w]+", "_"):gsub("_+", "_"):gsub("^_", ""):gsub("_$", "")
            if safeName == "" then
                safeName = "track_" .. tostring(index)
            end
            cacheName = safeName .. ".mp3"
        end

        local id = track.Id or track.id or track.ID or tostring(index)

        return {
            Id = id,
            Name = tostring(name),
            Artist = tostring(artist),
            Duration = duration,
            Cover = tostring(cover),
            AudioURL = tostring(audioUrl),
            CacheName = tostring(cacheName),
            Raw = track,
        }
    end

    local SpotifyState = {
        Catalog = {},
        SelectedIndex = 1,
        IsPlaying = false,
        IsRepeat = false,
        CurrentLiked = {},
        RowButtons = {},
        HiddenRows = {},
        CurrentSound = nil,
        SoundProgressConnection = nil,
        SoundEndedConnection = nil,
        CurrentTrack = nil,
        CurrentTrackSeconds = 0,
        CurrentPausedPosition = 0,
        CatalogLoaded = false,
        SearchQuery = "",
    }

    local function getRenderOrder()
        local order = {}
        for i = 1, #SpotifyState.Catalog do
            order[#order + 1] = i
        end

        table.sort(order, function(a, b)
            local likedA = SpotifyState.CurrentLiked[a] == true
            local likedB = SpotifyState.CurrentLiked[b] == true
            if likedA ~= likedB then
                return likedA and not likedB
            end
            return a < b
        end)

        return order
    end


    local function normalizeSearchText(value)
        local s = tostring(value or "")
        local replacements = {
            ["á"] = "a", ["à"] = "a", ["ä"] = "a", ["â"] = "a", ["ã"] = "a", ["å"] = "a",
            ["Á"] = "a", ["À"] = "a", ["Ä"] = "a", ["Â"] = "a", ["Ã"] = "a", ["Å"] = "a",
            ["é"] = "e", ["è"] = "e", ["ë"] = "e", ["ê"] = "e",
            ["É"] = "e", ["È"] = "e", ["Ë"] = "e", ["Ê"] = "e",
            ["í"] = "i", ["ì"] = "i", ["ï"] = "i", ["î"] = "i",
            ["Í"] = "i", ["Ì"] = "i", ["Ï"] = "i", ["Î"] = "i",
            ["ó"] = "o", ["ò"] = "o", ["ö"] = "o", ["ô"] = "o", ["õ"] = "o",
            ["Ó"] = "o", ["Ò"] = "o", ["Ö"] = "o", ["Ô"] = "o", ["Õ"] = "o",
            ["ú"] = "u", ["ù"] = "u", ["ü"] = "u", ["û"] = "u",
            ["Ú"] = "u", ["Ù"] = "u", ["Ü"] = "u", ["Û"] = "u",
            ["ñ"] = "n", ["Ñ"] = "n",
            ["ç"] = "c", ["Ç"] = "c",
        }
        for from, to in pairs(replacements) do
            s = s:gsub(from, to)
        end
        s = s:lower()
        s = trim(s)
        return s
    end

    local function getVisibleRenderOrder()
        local query = normalizeSearchText(SpotifyState.SearchQuery or "")
        local order = getRenderOrder()
        if query == "" then
            return order
        end

        local tokens = {}
        for token in query:gmatch("%S+") do
            tokens[#tokens + 1] = token
        end

        local filtered = {}
        for _, index in ipairs(order) do
            local track = SpotifyState.Catalog[index]
            if track then
                local haystack = normalizeSearchText((track.Name or "") .. " " .. (track.Artist or "") .. " " .. (track.Duration or ""))
                local matched = true

                for _, token in ipairs(tokens) do
                    if not haystack:find(token, 1, true) then
                        matched = false
                        break
                    end
                end

                if matched then
                    filtered[#filtered + 1] = index
                end
            end
        end
        return filtered
    end

    local spotifyGreen = Color3.fromRGB(29, 185, 84)
    local spotifyText = Theme.Text
    local spotifyDim = Theme.TextDim

    local spotifyPanel = Theme.Background

    local function getSpotifyMetrics()
        local width = 0
        pcall(function()
            width = (SpotifyPage and SpotifyPage.AbsoluteSize and SpotifyPage.AbsoluteSize.X) or 0
        end)

        local compact = width > 0 and width < 640

        return {
            compact = compact,
            playerHeight = compact and 200 or 220,
            albumSize = compact and 130 or 150,
            albumTop = compact and 32 or 36,
            infoLeft = compact and 154 or 174,
            infoWidth = compact and -172 or -192,
            titleSize = compact and 20 or 22,
            artistSize = compact and 13 or 14,
            metaSize = compact and 10 or 11,
            progressBottom = compact and -30 or -34,
            controlsBottom = compact and -46 or -52,
            controlsHeight = compact and 40 or 44,
            repeatX = compact and 0.06 or 0.05,
            likeX = compact and 0.15 or 0.14,
            playX = compact and 0.59 or 0.58,
            nextX = compact and 0.85 or 0.87,
            moreX = compact and 0.95 or 0.96,
            playSize = compact and 30 or 34,
            rowHeight = compact and 64 or 72,
            rowCover = compact and 40 or 44,
            rowTitleSize = compact and 14 or 15,
            rowArtistSize = compact and 10 or 11,
            rowDurationSize = compact and 10 or 11,
            rowTitleRight = compact and -140 or -170,
            rowDurationX = compact and -126 or -140,
            rowPlusX = compact and -72 or -84,
            rowPlayX = compact and -30 or -42,
        }
    end


    local SpotifyRoot = mk("Frame", {
        Parent = SpotifyPage,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ClipsDescendants = false,
        LayoutOrder = 1,
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 10,
    })

    mk("UIPadding", {
        Parent = SpotifyRoot,
        PaddingTop = UDim.new(0, 8),
        PaddingLeft = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 10),
    })

    local SpotifyRootLayout = mk("UIListLayout", {
        Parent = SpotifyRoot,
        Padding = UDim.new(0, 10),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    local SongList, SongListLayout

    local function updateSpotifyCanvas()
        local contentY = 0
        pcall(function()
            contentY = SpotifyRootLayout.AbsoluteContentSize.Y
        end)
        SpotifyPage.CanvasSize = UDim2.new(0, 0, 0, math.max(0, math.floor(contentY + 20)))
    end

    local function updateSongListCanvas()
        local contentY = 0
        pcall(function()
            contentY = SongListLayout.AbsoluteContentSize.Y
        end)

        local rowCount = #SpotifyState.RowButtons
        if contentY <= 0 and rowCount > 0 then
            local m = getSpotifyMetrics()
            contentY = (rowCount * m.rowHeight) + math.max(0, (rowCount - 1) * 8)
        end

        -- En la versión estable la lista se autoexpande por contenido.
        -- Si el layout tarda un frame en reportar tamaño, esta función
        -- solo fuerza una nueva lectura para refrescar el canvas padre.
        if SongList.AutomaticSize == Enum.AutomaticSize.None then
            SongList.Size = UDim2.new(1, 0, 0, math.max(0, math.floor(contentY + 8)))
        end
    end

    -- Header eliminado: el título "Spotify • NEW" ya no ocupa espacio extra

    local SpotifyShell = mk("Frame", {
        Parent = SpotifyRoot,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = spotifyPanel,
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = 1,
        ClipsDescendants = false,
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 10,
    })
    corner(SpotifyShell, 18)
    stroke(SpotifyShell, Color3.fromRGB(90, 90, 96), 1, 0.35)

    mk("UIPadding", {
        Parent = SpotifyShell,
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
    })

    mk("UIListLayout", {
        Parent = SpotifyShell,
        Padding = UDim.new(0, 12),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    -- ═══════════════════════════════════════════════════════
    -- CARD REDISEÑADA: Imagen ARRIBA centrada y grande
    -- ═══════════════════════════════════════════════════════
    local NowPlayingCard = mk("Frame", {
        Parent = SpotifyShell,
        Size = UDim2.new(1, 0, 0, 413),
        BackgroundColor3 = spotifyPanel,
        BackgroundTransparency = 0.88,
        BorderSizePixel = 0,
        LayoutOrder = 1,
        ZIndex = 11,
    })
    corner(NowPlayingCard, 16)
    stroke(NowPlayingCard, Color3.fromRGB(90, 90, 96), 1, 0.45)

    -- Botón "..." en esquina superior derecha
    local MoreTopBtn = mk("ImageButton", {
        Parent = NowPlayingCard,
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(1, -26, 0, 10),
        AnchorPoint = Vector2.new(0, 0),
        BackgroundTransparency = 1,
        Image = asset(89968119092860),
        ImageColor3 = spotifyText,
        AutoButtonColor = false,
        ZIndex = 13,
    })

    -- IMAGEN DEL ÁLBUM: centrada arriba, grande
    local AlbumArt = mk("ImageLabel", {
        Parent = NowPlayingCard,
        Size = UDim2.new(0, 176, 0, 176),
        Position = UDim2.new(0.5, -88, 0, 14),
        BackgroundColor3 = Theme.Background,
        BackgroundTransparency = 0.82,
        BorderSizePixel = 0,
        Image = "",
        ScaleType = Enum.ScaleType.Crop,
        ZIndex = 12,
    })
    corner(AlbumArt, 16)
    stroke(AlbumArt, spotifyGreen, 2.5, 0.10)
    buildAnimatedBorder(AlbumArt, spotifyGreen, UDim.new(0, 16), true)

    local AlbumFallback = mk("Frame", {
        Parent = AlbumArt,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        ZIndex = 13,
    })

    local AlbumFallbackText = mk("TextLabel", {
        Parent = AlbumFallback,
        Size = UDim2.new(1, -12, 1, -12),
        Position = UDim2.new(0, 6, 0, 6),
        BackgroundTransparency = 1,
        Text = "♪",
        Font = Enum.Font.GothamBlack,
        TextSize = 56,
        TextColor3 = spotifyGreen,
        ZIndex = 13,
    })

    -- INFO FRAME: debajo de la imagen, centrado
    local InfoFrame = mk("Frame", {
        Parent = NowPlayingCard,
        Size = UDim2.new(1, -28, 0, 80),
        Position = UDim2.new(0, 14, 0, 212),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 12,
    })

    local PlayerSongTitle = mk("TextLabel", {
        Parent = InfoFrame,
        Size = UDim2.new(1, 0, 0, 30),
        Position = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
        Text = "Selecciona una canción",
        Font = Enum.Font.GothamBlack,
        TextSize = 22,
        TextColor3 = spotifyText,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 12,
    })

    local PlayerSongArtist = mk("TextLabel", {
        Parent = InfoFrame,
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 0, 32),
        BackgroundTransparency = 1,
        Text = "El catálogo se carga desde GitHub",
        Font = Enum.Font.GothamMedium,
        TextSize = 14,
        TextColor3 = spotifyDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 12,
    })

    local PlayerMeta = mk("TextLabel", {
        Parent = InfoFrame,
        Size = UDim2.new(1, 0, 0, 16),
        Position = UDim2.new(0, 0, 0, 56),
        BackgroundTransparency = 1,
        Text = "Esperando canción",
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextColor3 = spotifyDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 12,
    })

    -- BARRA DE PROGRESO: debajo del InfoFrame
    local ProgressTrack = mk("Frame", {
        Parent = NowPlayingCard,
        Size = UDim2.new(1, -28, 0, 5),
        Position = UDim2.new(0, 14, 0, 306),
        BackgroundColor3 = Color3.fromRGB(58, 58, 58),
        BorderSizePixel = 0,
        ZIndex = 12,
    })
    corner(ProgressTrack, 999)

    --// THUMB DEL SEEK: círculo blanco sobre la barra
    local SeekThumb = mk("Frame", {
        Parent = ProgressTrack,
        Size = UDim2.fromOffset(13, 13),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        ZIndex = 15,
        Visible = false,
    })
    corner(SeekThumb, 999)

    --// TOOLTIP DE TIEMPO: aparece al mantener presionado
    local SeekTooltip = mk("Frame", {
        Parent = ProgressTrack,
        Size = UDim2.fromOffset(52, 26),
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.new(0, 0, 0, -8),
        BackgroundTransparency = 1,  -- SIN fondo negro, solo el texto
        BorderSizePixel = 0,
        ZIndex = 16,
        Visible = false,
    })
    corner(SeekTooltip, 6)
    local SeekTooltipLabel = mk("TextLabel", {
        Parent = SeekTooltip,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "0:00",
        Font = Enum.Font.GothamBlack,
        TextSize = 14,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextXAlignment = Enum.TextXAlignment.Center,
        ZIndex = 17,
    })

    local ProgressFill = mk("Frame", {
        Parent = ProgressTrack,
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = spotifyGreen,
        BorderSizePixel = 0,
        ZIndex = 13,
    })
    corner(ProgressFill, 999)

    --// ZONA CLICKABLE sobre la barra de progreso (más alta para facilitar el toque)
    local SeekHitbox = mk("TextButton", {
        Parent = NowPlayingCard,
        Size = UDim2.new(1, -28, 0, 28),
        Position = UDim2.new(0, 14, 0, 295),  -- zona touch amplia centrada sobre ProgressTrack
        BackgroundTransparency = 1,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 14,
    })

    local isSeeking = false
    local seekInput = nil

    local function getSeekPercent(inputX)
        local trackPos = ProgressTrack.AbsolutePosition.X
        local trackWidth = ProgressTrack.AbsoluteSize.X
        if trackWidth <= 0 then return 0 end
        return math.clamp((inputX - trackPos) / trackWidth, 0, 1)
    end

    local function applySeekVisuals(pct)
        SeekThumb.Position = UDim2.new(pct, 0, 0.5, 0)
        SeekTooltip.Position = UDim2.new(pct, 0, 0, -8)
        local total = 0
        if SpotifyState.CurrentSound and SpotifyState.CurrentSound.TimeLength > 0 then
            total = SpotifyState.CurrentSound.TimeLength
        elseif SpotifyState.CurrentTrack then
            total = durationToSeconds(SpotifyState.CurrentTrack.Duration)
        end
        local seekSec = math.floor(pct * math.max(total, 1))
        SeekTooltipLabel.Text = secondsToClock(seekSec)
    end

    SeekHitbox.InputBegan:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then return end
        isSeeking = true
        seekInput = input
        SeekThumb.Visible = true
        SeekTooltip.Visible = true
        local pct = getSeekPercent(input.Position.X)
        applySeekVisuals(pct)
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not isSeeking then return end
        if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then return end
        local pct = getSeekPercent(input.Position.X)
        applySeekVisuals(pct)
        ProgressFill.Size = UDim2.new(pct, 0, 1, 0)
    end)

    UserInputService.InputEnded:Connect(function(input)
        if not isSeeking then return end
        if input ~= seekInput then return end
        isSeeking = false
        seekInput = nil
        SeekThumb.Visible = false
        SeekTooltip.Visible = false
        --// Aplicar el seek al sonido
        local pct = getSeekPercent(input.Position.X)
        if SpotifyState.CurrentSound then
            pcall(function()
                local total = SpotifyState.CurrentSound.TimeLength
                if total > 0 then
                    local newPos = pct * total
                    SpotifyState.CurrentSound.TimePosition = newPos
                    SpotifyState.CurrentPausedPosition = newPos
                    if SpotifyState.IsPlaying then
                        SpotifyState.CurrentSound:Play()
                    end
                end
            end)
        end
    end)

    -- Tiempos debajo de la barra
    local ProgressTimeLeft = mk("TextLabel", {
        Parent = NowPlayingCard,
        Size = UDim2.new(0, 72, 0, 16),
        Position = UDim2.new(0, 14, 0, 319),
        BackgroundTransparency = 1,
        Text = "0:00",
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = spotifyDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 12,
    })

    local ProgressTimeRight = mk("TextLabel", {
        Parent = NowPlayingCard,
        Size = UDim2.new(0, 72, 0, 16),
        Position = UDim2.new(1, -86, 0, 319),
        BackgroundTransparency = 1,
        Text = "0:00",
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextColor3 = spotifyDim,
        TextXAlignment = Enum.TextXAlignment.Right,
        TextTruncate = Enum.TextTruncate.AtEnd,
        ZIndex = 12,
    })

    -- CONTROLES: debajo de la barra de tiempo, nunca se superpone (posición desde arriba)
    local Controls = mk("Frame", {
        Parent = NowPlayingCard,
        Size = UDim2.new(1, -28, 0, 48),
        Position = UDim2.new(0, 14, 0, 351),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ZIndex = 12,
    })

    local function createIconButton(parent, size, imageId, imageColor, bgColor, rounded)
        local btn = mk("ImageButton", {
            Parent = parent,
            Size = UDim2.new(0, size, 0, size),
            BackgroundColor3 = bgColor or Color3.fromRGB(0, 0, 0),
            BackgroundTransparency = bgColor and 0 or 1,
            Image = asset(imageId),
            ImageColor3 = imageColor or Color3.new(1, 1, 1),
            AutoButtonColor = false,
            ZIndex = 13,
        })
        if rounded then
            corner(btn, rounded)
        end
        return btn
    end

    -- Botones de control mejorados: Play más grande, íconos más visibles
    local RepeatBtn = createIconButton(Controls, 22, 95777420020131, spotifyText)
    RepeatBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    RepeatBtn.Position = UDim2.new(0.06, 0, 0.5, 0)

    local LikeBtn = createIconButton(Controls, 24, 82989818174730, spotifyText)
    LikeBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    LikeBtn.Position = UDim2.new(0.22, 0, 0.5, 0)

    --// PlayPauseBtn: circulo verde grande, icono play/pause mas pequeño dentro
    local PlayPauseBtnOuter = mk("Frame", {
        Parent = Controls,
        Size = UDim2.new(0, 44, 0, 44),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.new(0.50, 0, 0.5, 0),
        BackgroundColor3 = spotifyGreen,
        BorderSizePixel = 0,
        ZIndex = 13,
    })
    corner(PlayPauseBtnOuter, 999)

    local PlayPauseBtn = mk("ImageButton", {
        Parent = PlayPauseBtnOuter,
        Size = UDim2.new(0, 22, 0, 22),
        Position = UDim2.new(0.5, -11, 0.5, -11),
        BackgroundTransparency = 1,
        Image = asset(72179599540578),
        ImageColor3 = Color3.fromRGB(0, 0, 0),
        ScaleType = Enum.ScaleType.Fit,
        AutoButtonColor = false,
        ZIndex = 14,
    })
    PlayPauseBtn.AnchorPoint = Vector2.new(0, 0)

    local NextBtn = createIconButton(Controls, 24, 82197628280626, spotifyText)
    NextBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    NextBtn.Position = UDim2.new(0.78, 0, 0.5, 0)

    local MoreBtn = createIconButton(Controls, 22, 89968119092860, spotifyText)
    MoreBtn.AnchorPoint = Vector2.new(0.5, 0.5)
    MoreBtn.Position = UDim2.new(0.94, 0, 0.5, 0)

    local SongsCard = mk("Frame", {
        Parent = SpotifyShell,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundColor3 = spotifyPanel,
        BackgroundTransparency = 0.88,
        BorderSizePixel = 0,
        LayoutOrder = 2,
        AutomaticSize = Enum.AutomaticSize.Y,
        ZIndex = 11,
    })
    corner(SongsCard, 16)
    stroke(SongsCard, Color3.fromRGB(90, 90, 96), 1, 0.45)

    mk("UIPadding", {
        Parent = SongsCard,
        PaddingTop = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 12),
        PaddingRight = UDim.new(0, 12),
        PaddingBottom = UDim.new(0, 10),
    })

    local SongsLayout = mk("UIListLayout", {
        Parent = SongsCard,
        Padding = UDim.new(0, 6),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    local SongsTitle = mk("TextLabel", {
        Parent = SongsCard,
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        LayoutOrder = 1,
        Text = "Canciones",
        Font = Enum.Font.GothamBlack,
        TextSize = 22,
        TextColor3 = spotifyText,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12,
    })

    local CatalogStatus = mk("TextLabel", {
        Parent = SongsCard,
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundTransparency = 1,
        LayoutOrder = 2,
        Text = "Cargando catálogo...",
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextWrapped = true,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextColor3 = spotifyDim,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12,
    })

    local SongSearchHolder = mk("Frame", {
        Parent = SongsCard,
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = Color3.fromRGB(22, 22, 26),
        BackgroundTransparency = 0.10,
        BorderSizePixel = 0,
        LayoutOrder = 3,
        ZIndex = 12,
    })
    corner(SongSearchHolder, 12)
    stroke(SongSearchHolder, Color3.fromRGB(75, 75, 82), 1, 0.55)

    local SongSearchIcon = mk("ImageButton", {
        Parent = SongSearchHolder,
        Size = UDim2.new(0, 18, 0, 18),
        Position = UDim2.new(0, 10, 0.5, -9),
        BackgroundTransparency = 1,
        Image = asset(100388562921803),
        ImageColor3 = spotifyDim,
        AutoButtonColor = false,
        ZIndex = 13,
    })

    local SongSearchBox = mk("TextBox", {
        Parent = SongSearchHolder,
        Size = UDim2.new(1, -40, 1, 0),
        Position = UDim2.new(0, 32, 0, 0),
        BackgroundTransparency = 1,
        Text = "",
        ClearTextOnFocus = false,
        PlaceholderText = "Buscar por nombre o artista...",
        PlaceholderColor3 = spotifyDim,
        TextColor3 = spotifyText,
        TextSize = 13,
        Font = Enum.Font.GothamMedium,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 13,
    })

    SongSearchIcon.Activated:Connect(function()
        pcall(function()
            SongSearchBox:CaptureFocus()
        end)
    end)

    SongList = mk("Frame", {
        Parent = SongsCard,
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        LayoutOrder = 4,
        AutomaticSize = Enum.AutomaticSize.Y,
        ClipsDescendants = false,
        ZIndex = 11,
    })

    SongListLayout = mk("UIListLayout", {
        Parent = SongList,
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
    })

    mk("UIPadding", {
        Parent = SongList,
        PaddingTop = UDim.new(0, 4),
        PaddingBottom = UDim.new(0, 4),
    })

    SongListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        updateSongListCanvas()
    end)

    local renderSongRows
    local clearSongRows
    local createSongRow

    SongSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        SpotifyState.SearchQuery = SongSearchBox.Text or ""
        if renderSongRows then
            renderSongRows()
        end
        updateSongListCanvas()
    end)

    SpotifyRootLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        updateSpotifyCanvas()
    end)

    local function applySpotifyNowPlayingLayout()
        local m = getSpotifyMetrics()

        -- Layout vertical en CADENA: cada bloque se posiciona en base al final
        -- del bloque anterior, así que imagen / info / progreso / tiempos /
        -- controles NUNCA pueden superponerse, sin importar el modo (compacto
        -- o normal) ni si se agranda la imagen del álbum en el futuro.
        local albumSz = m.compact and 152 or 176
        local albumTop = m.compact and 12 or 14
        local infoGap = m.compact and 16 or 22
        local infoTop = albumTop + albumSz + infoGap
        local infoHeight = 80
        local progressGap = m.compact and 10 or 14
        local progressTop = infoTop + infoHeight + progressGap
        local progressTrackH = 5
        local timeGap = m.compact and 6 or 8
        local timeTop = progressTop + progressTrackH + timeGap
        local timeH = 16
        local controlsGap = m.compact and 12 or 16
        local controlsTop = timeTop + timeH + controlsGap
        local controlsH = m.compact and 44 or 48
        local bottomPad = m.compact and 12 or 14
        local cardH = controlsTop + controlsH + bottomPad

        NowPlayingCard.Size = UDim2.new(1, 0, 0, cardH)

        AlbumArt.Size = UDim2.new(0, albumSz, 0, albumSz)
        AlbumArt.Position = UDim2.new(0.5, -(albumSz / 2), 0, albumTop)

        InfoFrame.Size = UDim2.new(1, -28, 0, infoHeight)
        InfoFrame.Position = UDim2.new(0, 14, 0, infoTop)

        PlayerSongTitle.TextSize = m.compact and 20 or 22
        PlayerSongArtist.Position = UDim2.new(0, 0, 0, 32)
        PlayerSongArtist.TextSize = m.compact and 13 or 14
        PlayerMeta.Position = UDim2.new(0, 0, 0, 56)
        PlayerMeta.TextSize = m.compact and 10 or 11

        ProgressTrack.Position = UDim2.new(0, 14, 0, progressTop)
        SeekHitbox.Position = UDim2.new(0, 14, 0, progressTop - 14)  -- zona touch centrada sobre la barra
        ProgressTimeLeft.Position = UDim2.new(0, 14, 0, timeTop)
        ProgressTimeRight.Position = UDim2.new(1, -86, 0, timeTop)
        ProgressTimeLeft.TextSize = m.compact and 11 or 12
        ProgressTimeRight.TextSize = m.compact and 11 or 12

        Controls.Size = UDim2.new(1, -28, 0, controlsH)
        Controls.Position = UDim2.new(0, 14, 0, controlsTop)

        RepeatBtn.AnchorPoint = Vector2.new(0.5, 0.5)
        LikeBtn.AnchorPoint = Vector2.new(0.5, 0.5)
        PlayPauseBtnOuter.AnchorPoint = Vector2.new(0.5, 0.5)
        NextBtn.AnchorPoint = Vector2.new(0.5, 0.5)
        MoreBtn.AnchorPoint = Vector2.new(0.5, 0.5)

        RepeatBtn.Size = UDim2.new(0, m.compact and 20 or 22, 0, m.compact and 20 or 22)
        RepeatBtn.Position = UDim2.new(0.06, 0, 0.5, 0)

        LikeBtn.Size = UDim2.new(0, m.compact and 22 or 24, 0, m.compact and 22 or 24)
        LikeBtn.Position = UDim2.new(0.22, 0, 0.5, 0)

        PlayPauseBtnOuter.Size = UDim2.new(0, m.compact and 38 or 44, 0, m.compact and 38 or 44)
        PlayPauseBtnOuter.Position = UDim2.new(0.50, 0, 0.5, 0)
        PlayPauseBtn.Size = UDim2.new(0, m.compact and 18 or 22, 0, m.compact and 18 or 22)
        PlayPauseBtn.Position = UDim2.new(0.5, m.compact and -9 or -11, 0.5, m.compact and -9 or -11)

        NextBtn.Size = UDim2.new(0, m.compact and 22 or 24, 0, m.compact and 22 or 24)
        NextBtn.Position = UDim2.new(0.78, 0, 0.5, 0)

        MoreBtn.Size = UDim2.new(0, m.compact and 20 or 22, 0, m.compact and 20 or 22)
        MoreBtn.Position = UDim2.new(0.94, 0, 0.5, 0)

        SongsTitle.TextSize = m.compact and 20 or 22
        CatalogStatus.TextSize = m.compact and 11 or 12
    end

    local function applySpotifyRowLayout(rowData)
        if not rowData or not rowData.Row then
            return
        end

        local m = getSpotifyMetrics()
        -- Altura fija ampliada para mejor legibilidad
        local rowH = m.compact and 68 or 76

        rowData.Row.Size = UDim2.new(1, 0, 0, rowH)

        if rowData.Accent then
            rowData.Accent.Size = UDim2.new(0, 4, 1, m.compact and -12 or -16)
            rowData.Accent.Position = UDim2.new(0, 6, 0, m.compact and 6 or 8)
        end

        -- Cover: 52px, bien separada del borde izquierdo
        local coverSz = m.compact and 46 or 52
        if rowData.Cover then
            rowData.Cover.Size = UDim2.new(0, coverSz, 0, coverSz)
            rowData.Cover.Position = UDim2.new(0, 12, 0.5, -(coverSz / 2))
        end

        -- Texto: empieza claramente después de la imagen (12 + coverSz + 10)
        local textX = 12 + coverSz + 10
        if rowData.Title then
            rowData.Title.Size = UDim2.new(1, -(textX + 90), 0, m.compact and 20 or 22)
            rowData.Title.Position = UDim2.new(0, textX, 0, m.compact and 10 or 12)
            rowData.Title.TextSize = m.compact and 14 or 15
        end

        if rowData.Artist then
            rowData.Artist.Size = UDim2.new(1, -(textX + 90), 0, m.compact and 16 or 18)
            rowData.Artist.Position = UDim2.new(0, textX, 0, m.compact and 33 or 37)
            rowData.Artist.TextSize = m.compact and 11 or 12
        end

        if rowData.Duration then
            rowData.Duration.Size = UDim2.new(0, 44, 0, 18)
            rowData.Duration.Position = UDim2.new(1, -122, 0.5, -9)
            rowData.Duration.TextSize = m.compact and 12 or 13
        end

        if rowData.Plus then
            rowData.Plus.AnchorPoint = Vector2.new(0.5, 0.5)
            rowData.Plus.Size = UDim2.new(0, 24, 0, 24)
            rowData.Plus.Position = UDim2.new(1, -68, 0.5, 0)
            rowData.Plus.TextSize = m.compact and 20 or 22
        end

        if rowData.Play then
            rowData.Play.AnchorPoint = Vector2.new(0.5, 0.5)
            rowData.Play.Size = UDim2.new(0, 26, 0, 26)
            rowData.Play.Position = UDim2.new(1, -32, 0.5, 0)
        end

        if rowData.TapArea then
            rowData.TapArea.Size = UDim2.new(1, -100, 1, 0)
        end
    end

    local function refreshSpotifyUILayout()
        applySpotifyNowPlayingLayout()
        updateSpotifyCanvas()
        if SpotifyState.CatalogLoaded then
            renderSongRows()
        end
    end

    local layoutRefreshQueued = false
    local function queueSpotifyLayoutRefresh()
        if layoutRefreshQueued then
            return
        end
        layoutRefreshQueued = true
        task.defer(function()
            task.wait()
            layoutRefreshQueued = false
            pcall(refreshSpotifyUILayout)
        end)
    end

    SpotifyPage:GetPropertyChangedSignal("AbsoluteSize"):Connect(queueSpotifyLayoutRefresh)

    local function isLiked(index)
        return SpotifyState.CurrentLiked[index] == true
    end

    local function updateTrackRow(rowData, index)
        local track = SpotifyState.Catalog[index]
        if not rowData or not rowData.Row or not track then
            return
        end

        applySpotifyRowLayout(rowData)

        local active = (index == SpotifyState.SelectedIndex)
        rowData.Row.BackgroundColor3 = active and Color3.fromRGB(38, 38, 44) or Color3.fromRGB(22, 22, 26)

        if rowData.Accent then
            rowData.Accent.Visible = active
        end

        if rowData.Cover then
            rowData.Cover.Image = track.Cover
        end

        if rowData.Title then
            rowData.Title.Text = track.Name
            rowData.Title.TextColor3 = active and spotifyGreen or spotifyText
        end

        if rowData.Artist then
            rowData.Artist.Text = track.Artist
            rowData.Artist.TextColor3 = active and Color3.fromRGB(100, 220, 120) or spotifyDim
        end

        if rowData.Duration then
            rowData.Duration.Text = track.Duration
        end

        if rowData.Plus then
            pcall(function()
                rowData.Plus.Text = ""
                rowData.Plus.TextTransparency = 1
                rowData.Plus.BackgroundTransparency = 1
            end)
        end

        if rowData.Play then
            pcall(function()
                rowData.Play.Image = ""
                rowData.Play.ImageTransparency = 1
                rowData.Play.BackgroundTransparency = 1
            end)
        end
    end

    local function refreshAllRows()
        for i, rowData in ipairs(SpotifyState.RowButtons) do
            updateTrackRow(rowData, i)
        end
    end

    renderSongRows = function()
        clearSongRows()
        local order = getVisibleRenderOrder()
        for displayOrder, index in ipairs(order) do
            local track = SpotifyState.Catalog[index]
            if track then
                pcall(function()
                    createSongRow(track, index, displayOrder)
                end)
            end
        end
        updateSongListCanvas()
        updateSpotifyCanvas()
        task.defer(function()
            pcall(updateSongListCanvas)
            pcall(updateSpotifyCanvas)
        end)
    end

    local function updatePlayerFromTrack(track, index, statusText)
        if not track then
            return
        end

        AlbumArt.Image = track.Cover
        AlbumFallback.Visible = (track.Cover == nil or trim(track.Cover) == "")

        PlayerSongTitle.Text = track.Name
        PlayerSongArtist.Text = track.Artist
        PlayerMeta.Text = statusText or (SpotifyState.IsPlaying and "Reproducción activa" or "Reproducción lista")
        ProgressTimeRight.Text = track.Duration

        if index and SpotifyState.Catalog[index] then
            SpotifyState.SelectedIndex = index
        end

        refreshAllRows()
    end

    local function destroyCurrentSound()
        if SpotifyState.SoundProgressConnection then
            pcall(function()
                SpotifyState.SoundProgressConnection:Disconnect()
            end)
            SpotifyState.SoundProgressConnection = nil
        end

        if SpotifyState.SoundEndedConnection then
            pcall(function()
                SpotifyState.SoundEndedConnection:Disconnect()
            end)
            SpotifyState.SoundEndedConnection = nil
        end

        if SpotifyState.CurrentSound then
            pcall(function()
                SpotifyState.CurrentSound:Stop()
            end)
            safeDestroy(SpotifyState.CurrentSound)
            SpotifyState.CurrentSound = nil
        end
    end

    local function syncPlaybackUI()
        if SpotifyState.CurrentSound then
            PlayPauseBtn.Image = SpotifyState.IsPlaying and asset(125389410587367) or asset(72179599540578)
        else
            PlayPauseBtn.Image = asset(72179599540578)
        end

        RepeatBtn.ImageColor3 = SpotifyState.IsRepeat and spotifyGreen or spotifyText
        LikeBtn.ImageColor3 = isLiked(SpotifyState.SelectedIndex) and spotifyGreen or spotifyText

        if isLiked(SpotifyState.SelectedIndex) then
            LikeBtn.Image = asset(76432974703336)
        else
            LikeBtn.Image = asset(82989818174730)
        end
    end

    local function updateProgress(track, sound)
        local total = track and durationToSeconds(track.Duration) or 0
        if sound and sound.TimeLength and sound.TimeLength > 0 then
            total = math.max(total, math.floor(sound.TimeLength))
        end
        total = math.max(total, 1)

        local current = 0
        if sound and sound.TimePosition then
            current = math.floor(sound.TimePosition)
        end

        ProgressTimeLeft.Text = secondsToClock(current)
        ProgressTimeRight.Text = track and track.Duration or secondsToClock(total)
        ProgressFill.Size = UDim2.new(clamp(current / total, 0, 1), 0, 1, 0)
    end

    local function ensureTrackCached(track)
        local cacheName = track.CacheName
        local audioExists = false
        local audioPath = cacheName

        if isfile then
            local okFile, resultFile = pcall(function()
                return isfile(audioPath)
            end)
            audioExists = okFile and resultFile == true
        end

        if not audioExists then
            if not writefile then
                return false, "writefile_unavailable"
            end

            local okDownload, data = pcall(function()
                return game:HttpGet(track.AudioURL, true)
            end)

            if not okDownload or type(data) ~= "string" or #data < 10 then
                return false, "download_failed"
            end

            local okWrite = pcall(function()
                writefile(audioPath, data)
            end)

            if not okWrite then
                return false, "cache_write_failed"
            end
        end

        local customAsset = audioPath
        if getcustomasset then
            local okAsset, resultAsset = pcall(function()
                return getcustomasset(audioPath)
            end)
            if okAsset and type(resultAsset) == "string" then
                customAsset = resultAsset
            end
        end

        return true, customAsset
    end

    local function playTrack(index)
        local track = SpotifyState.Catalog[index]
        if not track then
            return
        end

        SpotifyState.SelectedIndex = index
        SpotifyState.CurrentTrack = track
        SpotifyState.CurrentTrackSeconds = durationToSeconds(track.Duration)
        SpotifyState.CurrentPausedPosition = 0
        SpotifyState.IsPlaying = true

        destroyAllSpotifySounds()
        destroyCurrentSound()

        updatePlayerFromTrack(track, index, "Descargando y reproduciendo...")
        syncPlaybackUI()

        local okCache, cachedAssetOrErr = ensureTrackCached(track)
        local soundAsset = okCache and cachedAssetOrErr or track.AudioURL

        local sound = Instance.new("Sound")
        sound.Name = "YY_Spotify_CurrentSound"
        sound.SoundId = soundAsset
        sound.Volume = 0.75
        sound.Looped = SpotifyState.IsRepeat
        sound.Parent = workspace

        SpotifyState.CurrentSound = sound

        SpotifyState.SoundProgressConnection = RunService.Heartbeat:Connect(function()
            if SpotifyState.CurrentSound == sound then
                updateProgress(track, sound)
            end
        end)

        SpotifyState.SoundEndedConnection = sound.Ended:Connect(function()
            if SpotifyState.CurrentSound ~= sound then
                return
            end

            --// Repeat: reiniciar desde el principio (Looped puede no funcionar en todos los executors)
            if SpotifyState.IsRepeat then
                task.spawn(function()
                    pcall(function()
                        sound.TimePosition = 0
                        sound:Play()
                        SpotifyState.IsPlaying = true
                        syncPlaybackUI()
                    end)
                end)
                return
            end

            local nextIndex = index + 1
            if nextIndex > #SpotifyState.Catalog then
                nextIndex = 1
            end
            playTrack(nextIndex)
        end)

        pcall(function()
            sound:Play()
        end)

        SpotifyState.IsPlaying = true
        updatePlayerFromTrack(track, index, okCache and "Reproduciendo desde caché" or "Reproduciendo desde URL")
        syncPlaybackUI()
    end

    local function selectTrack(index)
        local track = SpotifyState.Catalog[index]
        if not track then
            return
        end

        SpotifyState.SelectedIndex = index
        SpotifyState.CurrentTrack = track
        SpotifyState.IsPlaying = SpotifyState.CurrentSound ~= nil and SpotifyState.IsPlaying or false
        updatePlayerFromTrack(track, index, "Seleccionada: " .. track.Name)
        syncPlaybackUI()
    end

    local function toggleTrackLike(index)
        SpotifyState.CurrentLiked[index] = not isLiked(index)
        renderSongRows()
        syncPlaybackUI()
    end

    local function bindRowTap(guiObject, callback)
        if not guiObject then
            return
        end

        pcall(function()
            guiObject.Active = true
            guiObject.Selectable = false
        end)

        local fired = false
        local function fireOnce()
            if fired then
                return
            end
            fired = true

            local ok, err = pcall(callback)
            if not ok then
                warn("[YinYang Spotify] Row tap failed: " .. tostring(err))
            end

            task.defer(function()
                fired = false
            end)
        end

        if guiObject:IsA("GuiButton") then
            track(guiObject.Activated:Connect(fireOnce))
            track(guiObject.MouseButton1Click:Connect(fireOnce))
            return
        end

        local activeInput = nil
        local startPosition = nil
        local moved = false
        local threshold = 14

        track(guiObject.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                activeInput = input
                startPosition = input.Position
                moved = false
            end
        end))

        track(UserInputService.InputChanged:Connect(function(input)
            if activeInput and input == activeInput and startPosition then
                local delta = input.Position - startPosition
                if delta.Magnitude > threshold then
                    moved = true
                end
            end
        end))

        track(UserInputService.InputEnded:Connect(function(input)
            if activeInput and input == activeInput then
                if not moved then
                    fireOnce()
                end
                activeInput = nil
                startPosition = nil
                moved = false
            end
        end))
    end

    createSongRow = function(track, index, layoutOrder)
        if SpotifyState.HiddenRows[index] then
            return
        end

        local Row = mk("Frame", {
            Parent = SongList,
            Size = UDim2.new(1, 0, 0, 72),
            BackgroundColor3 = index == SpotifyState.SelectedIndex and Color3.fromRGB(24, 24, 30) or Color3.fromRGB(16, 16, 20),
            BackgroundTransparency = index == SpotifyState.SelectedIndex and 0.16 or 0.24,
            BorderSizePixel = 0,
            LayoutOrder = layoutOrder or (index + 1),
            ClipsDescendants = true,
            ZIndex = 11,
        })
        Row.Name = "SpotifySongRow_" .. index
        corner(Row, 12)

        local RowStroke = stroke(Row, Color3.fromRGB(126, 126, 136), 1, 0.72)
        pcall(function()
            RowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            RowStroke.LineJoinMode = Enum.LineJoinMode.Round
        end)

        --// EFECTO HOVER/TOUCH: transparencia al pasar el mouse o mantener dedo
        local baseRowTransparency = index == SpotifyState.SelectedIndex and 0.16 or 0.24
        Row.MouseEnter:Connect(function()
            TweenService:Create(Row, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundTransparency = math.max(0, baseRowTransparency - 0.18)}):Play()
        end)
        Row.MouseLeave:Connect(function()
            TweenService:Create(Row, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                {BackgroundTransparency = baseRowTransparency}):Play()
        end)
        Row.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                TweenService:Create(Row, TweenInfo.new(0.10, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundTransparency = math.max(0, baseRowTransparency - 0.20)}):Play()
            end
        end)
        Row.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
                TweenService:Create(Row, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    {BackgroundTransparency = baseRowTransparency}):Play()
            end
        end)
        mk("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(0.45, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.40),
                NumberSequenceKeypoint.new(0.55, 0.18),
                NumberSequenceKeypoint.new(1, 0.38),
            }),
            Rotation = 0,
        }, RowStroke)

        mk("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 34, 42)),
                ColorSequenceKeypoint.new(0.55, Color3.fromRGB(20, 20, 24)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(12, 12, 16)),
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.10),
                NumberSequenceKeypoint.new(1, 0.10),
            }),
            Rotation = 0,
        }, Row)

        local TapArea = mk("TextButton", {
            Parent = Row,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 12,
        })
        TapArea.Name = "SongTapArea"

        local Accent = mk("Frame", {
            Parent = Row,
            Size = UDim2.new(0, 4, 1, -16),
            Position = UDim2.new(0, 10, 0, 8),
            BackgroundColor3 = spotifyGreen,
            BorderSizePixel = 0,
            Visible = index == SpotifyState.SelectedIndex,
            ZIndex = 12,
        })
        corner(Accent, 999)

        -- COVER: más grande y bien posicionada, sin solaparse con el texto
        local Cover = mk("ImageLabel", {
            Parent = Row,
            Size = UDim2.new(0, 52, 0, 52),
            Position = UDim2.new(0, 12, 0.5, -26),
            BackgroundColor3 = Color3.fromRGB(18, 18, 18),
            BackgroundTransparency = 0.04,
            BorderSizePixel = 0,
            Image = track.Cover,
            ScaleType = Enum.ScaleType.Crop,
            ZIndex = 12,
        })
        corner(Cover, 10)

        local CoverStroke = stroke(Cover, Color3.fromRGB(126, 126, 136), 1, 0.52)
        pcall(function()
            CoverStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            CoverStroke.LineJoinMode = Enum.LineJoinMode.Round
        end)
        mk("UIGradient", {
            Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(235, 235, 240)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(210, 210, 220)),
            }),
            Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.18),
                NumberSequenceKeypoint.new(0.6, 0.38),
                NumberSequenceKeypoint.new(1, 0.22),
            }),
            Rotation = 12,
        }, CoverStroke)

        -- TÍTULO: empieza DESPUÉS de la imagen (12 + 52 + 10 = 74px)
        local Title = mk("TextLabel", {
            Parent = Row,
            Size = UDim2.new(1, -160, 0, 22),
            Position = UDim2.new(0, 74, 0, 10),
            BackgroundTransparency = 1,
            Text = track.Name,
            Font = Enum.Font.GothamBold,
            TextSize = 15,
            TextColor3 = index == SpotifyState.SelectedIndex and spotifyGreen or spotifyText,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 12,
        })
        Title.Name = "SongTitle"

        -- ARTISTA: también empieza después de la imagen
        local Artist = mk("TextLabel", {
            Parent = Row,
            Size = UDim2.new(1, -160, 0, 16),
            Position = UDim2.new(0, 74, 0, 36),
            BackgroundTransparency = 1,
            Text = track.Artist,
            Font = Enum.Font.GothamMedium,
            TextSize = 12,
            TextColor3 = index == SpotifyState.SelectedIndex and Color3.fromRGB(100, 220, 120) or spotifyDim,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 12,
        })
        Artist.Name = "SongArtist"

        -- DURACIÓN: centrada verticalmente, fuente más legible
        local Duration = mk("TextLabel", {
            Parent = Row,
            Size = UDim2.new(0, 44, 0, 18),
            Position = UDim2.new(1, -122, 0.5, -9),
            BackgroundTransparency = 1,
            Text = track.Duration,
            Font = Enum.Font.GothamBold,
            TextSize = 13,
            TextColor3 = spotifyDim,
            TextXAlignment = Enum.TextXAlignment.Right,
            TextTruncate = Enum.TextTruncate.AtEnd,
            ZIndex = 12,
        })
        Duration.Name = "SongDuration"

        -- Zonas invisibles para conservar la interacción sin mostrar iconos
        local Plus = mk("TextButton", {
            Parent = Row,
            Size = UDim2.new(0, 34, 0, 34),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(1, -68, 0.5, 0),
            BackgroundTransparency = 1,
            Text = "",
            TextTransparency = 1,
            Font = Enum.Font.GothamBlack,
            TextSize = 22,
            TextColor3 = Color3.new(1, 1, 1),
            AutoButtonColor = false,
            ZIndex = 16,
            Active = true,
        })
        Plus.Name = "SongPlus"

        local Play = mk("ImageButton", {
            Parent = Row,
            Size = UDim2.new(0, 34, 0, 34),
            AnchorPoint = Vector2.new(0.5, 0.5),
            Position = UDim2.new(1, -30, 0.5, 0),
            BackgroundTransparency = 1,
            Image = "",
            ImageTransparency = 1,
            ImageColor3 = Color3.new(1, 1, 1),
            AutoButtonColor = false,
            ZIndex = 16,
            Active = true,
        })
        Play.Name = "SongPlay"

        bindRowTap(TapArea, function()
            playTrack(index)
        end)

        --// FIX COMPLETO: Detección de input por posicion para superar robo de input del ScrollingFrame
        --// Los botones Plus y Play usan TODAS las conexiones posibles para garantizar respuesta
        local _plusFired = false
        local _playFired = false

        local function fireLike()
            if _plusFired then return end
            _plusFired = true
            toggleTrackLike(index)
            task.defer(function() _plusFired = false end)
        end

        local function firePlay()
            if _playFired then return end
            _playFired = true
            playTrack(index)
            task.defer(function() _playFired = false end)
        end

        -- Conexiones directas en los botones
        Plus.MouseButton1Click:Connect(fireLike)
        Plus.Activated:Connect(fireLike)
        Play.MouseButton1Click:Connect(firePlay)
        Play.Activated:Connect(firePlay)

        --// FALLBACK: Detección por posición en el Row (para móvil con ScrollingFrame)
        --// Si el ScrollingFrame consume el Activated, detectamos manualmente si el toque
        --// cayó dentro del área del corazón o del play
        Row.InputBegan:Connect(function(input)
            if input.UserInputType ~= Enum.UserInputType.Touch and
               input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end

            local inputX = input.Position.X
            local inputY = input.Position.Y

            -- Coordenadas absolutas de Plus y Play
            local plusPos  = Plus.AbsolutePosition
            local plusSize = Plus.AbsoluteSize
            local playPos  = Play.AbsolutePosition
            local playSize = Play.AbsoluteSize

            local inPlus = inputX >= plusPos.X and inputX <= plusPos.X + plusSize.X
                        and inputY >= plusPos.Y and inputY <= plusPos.Y + plusSize.Y
            local inPlay = inputX >= playPos.X and inputX <= playPos.X + playSize.X
                        and inputY >= playPos.Y and inputY <= playPos.Y + playSize.Y

            if inPlus then
                fireLike()
            elseif inPlay then
                firePlay()
            end
        end)

        SpotifyState.RowButtons[index] = {
            Row = Row,
            Accent = Accent,
            Cover = Cover,
            Title = Title,
            Artist = Artist,
            Duration = Duration,
            Plus = Plus,
            Play = Play,
            TapArea = TapArea,
        }

        applySpotifyRowLayout(SpotifyState.RowButtons[index])
        updateTrackRow(SpotifyState.RowButtons[index], index)
        return Row
    end
clearSongRows = function()
        for _, child in ipairs(SongList:GetChildren()) do
            if child ~= SongListLayout and not child:IsA("UIPadding") then
                safeDestroy(child)
            end
        end
        SpotifyState.RowButtons = {}
        updateSongListCanvas()
    end

    local function renderCatalog(catalog)
        clearSongRows()
        SpotifyPage.CanvasPosition = Vector2.new(0, 0)

        SpotifyState.Catalog = {}
        for i, track in ipairs(catalog or {}) do
            local normalized = normalizeTrack(track, i)
            if normalized then
                table.insert(SpotifyState.Catalog, normalized)
            end
        end

        if #SpotifyState.Catalog == 0 then
            CatalogStatus.Text = "No se encontró ninguna canción en el catálogo remoto."
            PlayerSongTitle.Text = "Catálogo vacío"
            PlayerSongArtist.Text = "Revisa el repositorio remoto"
            PlayerMeta.Text = "Sin canciones disponibles"
            AlbumArt.Image = ""
            ProgressTimeLeft.Text = "0:00"
            ProgressTimeRight.Text = "0:00"
            ProgressFill.Size = UDim2.new(0, 0, 1, 0)
            syncPlaybackUI()
            return
        end

        CatalogStatus.Text = "Catálogo cargado • " .. tostring(#SpotifyState.Catalog) .. " canciones"
        renderSongRows()
        updateSongListCanvas()
        updateSpotifyCanvas()

        local order = getRenderOrder()
        selectTrack(order[1] or 1)
        updateProgress(SpotifyState.Catalog[1], SpotifyState.CurrentSound)
        syncPlaybackUI()
    end

    local function loadCatalogFromRemote()
        destroyAllSpotifySounds()
        local catalogData = nil

        local okRemote, remoteResult = pcall(function()
            local raw = game:HttpGet(SPOTIFY_CATALOG_URL, true)
            local loader = loadstring(raw)
            if not loader then
                error("loadstring_failed")
            end
            return loader()
        end)

        if okRemote and type(remoteResult) == "table" then
            if type(remoteResult.Catalog) == "table" then
                catalogData = remoteResult.Catalog
            elseif type(remoteResult.catalog) == "table" then
                catalogData = remoteResult.catalog
            else
                catalogData = remoteResult
            end
        else
            warn("[Spotify] No se pudo cargar el catálogo remoto: " .. tostring(remoteResult))
        end

        if type(catalogData) ~= "table" then
            catalogData = {}
        end

        SpotifyState.CatalogLoaded = true
        renderCatalog(catalogData)
        updateSpotifyCanvas()
    end

    syncPlaybackUI()
    pcall(refreshSpotifyUILayout)
    updateSongListCanvas()
    updateSpotifyCanvas()
    task.defer(function()
        pcall(updateSongListCanvas)
        pcall(updateSpotifyCanvas)
    end)
    task.spawn(loadCatalogFromRemote)

    RepeatBtn.MouseButton1Click:Connect(function()
        SpotifyState.IsRepeat = not SpotifyState.IsRepeat
        --// Aplicar al sonido actual inmediatamente
        if SpotifyState.CurrentSound then
            pcall(function()
                SpotifyState.CurrentSound.Looped = SpotifyState.IsRepeat
                --// Si está en repeat y el sonido ya terminó (TimePosition cerca del final), reiniciar
                if SpotifyState.IsRepeat and SpotifyState.CurrentSound.TimePosition > 0 then
                    local len = SpotifyState.CurrentSound.TimeLength
                    if len > 0 and (len - SpotifyState.CurrentSound.TimePosition) < 0.5 then
                        SpotifyState.CurrentSound.TimePosition = 0
                        SpotifyState.CurrentSound:Play()
                    end
                end
            end)
        end
        syncPlaybackUI()
    end)

    LikeBtn.MouseButton1Click:Connect(function()
        toggleTrackLike(SpotifyState.SelectedIndex)
    end)

    --// El outer (circulo verde) tambien es clickeable para mejor area de toque
    PlayPauseBtnOuter.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch or
           input.UserInputType == Enum.UserInputType.MouseButton1 then
            PlayPauseBtn.MouseButton1Click:Fire()
        end
    end)

    PlayPauseBtn.MouseButton1Click:Connect(function()
        if SpotifyState.CurrentSound then
            if SpotifyState.IsPlaying then
                SpotifyState.IsPlaying = false
                pcall(function()
                    SpotifyState.CurrentPausedPosition = math.max(0, tonumber(SpotifyState.CurrentSound.TimePosition) or 0)
                    SpotifyState.CurrentSound:Pause()
                end)
                PlayerMeta.Text = "Reproducción pausada"
            else
                SpotifyState.IsPlaying = true
                pcall(function()
                    if SpotifyState.CurrentSound and SpotifyState.CurrentPausedPosition and SpotifyState.CurrentPausedPosition > 0 then
                        SpotifyState.CurrentSound.TimePosition = math.max(0, SpotifyState.CurrentPausedPosition)
                    end
                    SpotifyState.CurrentSound:Play()
                    task.defer(function()
                        if SpotifyState.CurrentSound and SpotifyState.IsPlaying and SpotifyState.CurrentPausedPosition and SpotifyState.CurrentPausedPosition > 0 then
                            pcall(function()
                                SpotifyState.CurrentSound.TimePosition = math.max(0, SpotifyState.CurrentPausedPosition)
                            end)
                        end
                    end)
                end)
                PlayerMeta.Text = "Reproducción activa"
            end
            syncPlaybackUI()
            return
        end

        if SpotifyState.Catalog[SpotifyState.SelectedIndex] then
            playTrack(SpotifyState.SelectedIndex)
        end
    end)

    NextBtn.MouseButton1Click:Connect(function()
        if #SpotifyState.Catalog == 0 then
            return
        end

        local nextIndex = SpotifyState.SelectedIndex + 1
        if nextIndex > #SpotifyState.Catalog then
            nextIndex = 1
        end
        playTrack(nextIndex)
    end)

    MoreBtn.MouseButton1Click:Connect(function()
        PlayerMeta.Text = "Menú de opciones abierto"
    end)
    print("\n DEMO v24 INICIADA")
    print("TABS: Inicio (Protegida) | Temas (16 colores sin duplicados) | Features | Dropdowns | Efectos")
    print(" MEJORAS: Sin duplicados, Pestañas permanentes, Efectos de texto mejorados")
    print("Para desactivar la demo, cambia DEMO_ACTIVO a false\n")
    print(string.rep("=", 60) .. "\n")
    
    -- Aplicar efecto guardado, o el del tema si no hay ninguno guardado
    task.wait(0.2)
    local efectoGuardado = ConfigCargada and ConfigCargada.effect
    if efectoGuardado and efectoGuardado ~= "" and efectoGuardado ~= "Normal" then
        DemoUI:SetTextEffect(efectoGuardado)
        print(" Efecto cargado desde config: " .. efectoGuardado)
    else
        -- Primera vez o sin config: aplicar el efecto por defecto del tema
        local autoEffect = ThemeAutoEffects and ThemeAutoEffects[TemaInicial]
        if autoEffect and autoEffect ~= "Off" then
            DemoUI:SetTextEffect(autoEffect)
            print(" Efecto: " .. TemaInicial .. " + " .. autoEffect)
        else
            DemoUI:SetTextEffect("Off")
            print(" Sin efecto de texto (tema: " .. TemaInicial .. ")")
        end
    end
else
    print("Yin Yang v24 - DEMO DESACTIVADA (DEMO_ACTIVO = false)")
    print("Solo la librería está cargada y lista para usar")
end

--// ============================================================
--// FIN DE LA DEMO
--// ============================================================
