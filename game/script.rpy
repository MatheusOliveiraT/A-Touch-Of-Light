# Músicas

define musicaAnimada1 = "audio/music/Sketchbook 2024-01-24_02.ogg"
define musicaTensa1 = "audio/music/Sketchbook 2024-02-14_L01.ogg"
define musicaTensa2 = "audio/music/Sketchbook 2024-02-14_L02.ogg"
define musicaSoft = "audio/music/Sketchbook 2024-02-28_02.ogg"
define musicaMisteriosa1 = "audio/music/Sketchbook 2024-03-06_02.ogg"
define musicaTensaCuriosa = "audio/music/Sketchbook 2024-03-20_02.ogg"
define musicaMelancolica1 = "audio/music/Sketchbook 2024-04-24_03.ogg"
define musicaMisteriosa2 = "audio/music/Sketchbook 2024-05-01_01.ogg"
define musicaMelancolica2 = "audio/music/Sketchbook 2024-06-16.ogg"
define musicaLenta = "audio/music/Sketchbook 2024-07-19_L02.ogg"
define musicaTensaMisteriosa = "audio/music/Sketchbook 2024-08-13.ogg"
define musicaTensaMelancolica = "audio/music/Sketchbook 2024-10-13.ogg"
define musicaAnimada2 = "audio/music/Sketchbook 2024-10-26.ogg"
define musicaAnsiosa = "audio/music/Week 13 - Primordial Soup BASE.ogg"
define musicaFeliz1 = "audio/music/Week 15 - Sunburn BEACH HOUSE.ogg"
define musicaFeliz2 = "audio/music/Week 15 - Sunburn SPF 3000.ogg"
define musicaTranquila = "audio/music/Week 21 - Freefall WHAT A VIEW.ogg"
define musicaMelancolica3 = "audio/music/Week 24 - Pull Me Down GRAVITY.ogg"

# Sons

define whiteNoise = "audio/sfx/whiteNoise.ogg"
define ondaTensa = "audio/sfx/ondaTensa.ogg"
define campainha = "audio/sfx/campainha.ogg"
define explosao1 = "audio/sfx/explosao1.ogg"
define explosao2 = "audio/sfx/explosao2.ogg"
define energia = "audio/sfx/energia.ogg"
define portal = "audio/sfx/portal.ogg"
define chiado = "audio/sfx/chiado.ogg"
define elevador = "audio/sfx/elevador.ogg"
define sirene = "audio/sfx/sirene.ogg"
define alarme = "audio/sfx/alarme.ogg"
define ondaDescendo = "audio/sfx/ondaDescendo.ogg"

# Backgrounds

image bg white = Image("images/background/white.png")
image bg rua dia = Image("images/background/ruaDia.png")
image bg rua noite = Image("images/background/ruaNoite.png")
image bg estacionamento = Image("images/background/estacionamento.png")
image bg sala casa dia = Image("images/background/salaDia.png")
image bg sala casa noite = Image("images/background/salaNoite.png")
image bg banheiro casa dia = Image("images/background/banheiroDia.png")
image bg banheiro casa noite = Image("images/background/banheiroNoite.png")
image bg quarto casa dia = Image("images/background/quartoDia.png")
image bg quarto casa noite = Image("images/background/quartoNoite.png")
image bg cozinha casa dia = Image("images/background/cozinhaDia.png")
image bg cozinha casa noite = Image("images/background/cozinhaNoite.png")
image bg hall dia = Image("images/background/hallDia.png")
image bg hall noite = Image("images/background/hallNoite.png")
image bg laboratorio = Image("images/background/laboratorio.png")
image bg acelerador1 = Image("images/background/acelerador1.png")
image bg acelerador2 = Image("images/background/acelerador2.png")
image bg escombros = Image("images/background/escombros.png")
image bg padaria = Image("images/background/padaria.png")
image bg interrogatorio = Image("images/background/interrogatorio.png")
image bg mercado = Image("images/background/mercado.png")
image bg shopping = Image("images/background/shopping.png")

# Main menu

image main_menu:
    zoom 0.87
    "gui/mainmenu/1.png"
    linear 0.35
    "gui/mainmenu/2.png"
    linear 0.35
    "gui/mainmenu/3.png"
    linear 0.35
    "gui/mainmenu/4.png"
    linear 0.35
    "gui/mainmenu/5.png"
    linear 0.35
    "gui/mainmenu/6.png"
    linear 0.35
    repeat

# CGs

image icone bloqueado = Image("images/cg/ibloqueado.png")

# Escombros

default persistent.escombros = False
image icone escombros = Image("images/cg/iescombros.png")
image cg escombros1:
    zoom 0.87
    "images/cg/escombros1.png"
image cg escombros2:
    zoom 0.87
    "images/cg/escombros2.png"
image cg escombros3:
    zoom 0.87
    "images/cg/escombros3.png"

# Shopping

default persistent.shopping = False
image icone shopping = Image("images/cg/ishopping.png")
image cg shopping: 
    zoom 0.87
    "images/cg/shopping.png"

# Personagens

define v = Character("Você", color="#ffffff")
define v_e = Character("You", color="#ffffff")
define seuNome = "Leonardo"

# Personagens secundários

define vz = Character(name="Vizinho", color="#ababab")
define vz_e = Character(name="Neighbour", color="#ababab")
image vz = Image("images/sprites/vizinho.png")

define null = Character(name="???", color="#ababab")

define ate = Character(name="Atendente", color="#ababab")
define ate_e = Character(name="Server", color="#ababab")

define r = Character(name="Rafael", color="#2f2f2f")

define e = Character(name="Erick", color="#01c901")

define seg = Character(name="Segurança", color="#2f2f2f")
define seg_e = Character(name="Security", color="#2f2f2f")

define cient1 = Character(name="Cientista 1", color="#1c4c00")
define cient1_e = Character(name="Scientist 1", color="#1c4c00")

define cient2 = Character(name="Cientista 2", color="#00264c")
define cient2_e = Character(name="Scientist 2", color="#00264c")

# Lucas

define l = Character("Lucas", color="#9900ff", image="lucas")

# Side icon

image side lucas = LayeredImageProxy("lucas", Transform(crop=(300, 0, 400, 350), zoom=0.65))

# Outfits

layeredimage lucas:

    zoom 0.8
    yanchor 1.0
    ypos 1.0
    xanchor 0.5
    xpos 0.5

    group outfit:

        # --- POSE BASE ---
        attribute base_naked default:
            "images/sprites/lucas/pose/lucas_pose_base_naked.png"
        attribute base_pijama:
            "images/sprites/lucas/pose/lucas_pose_base_pijama.png"
        attribute base_pijama_bandagens:
            "images/sprites/lucas/pose/lucas_pose_base_pijama_bandagens.png"
        attribute base_social:
            "images/sprites/lucas/pose/lucas_pose_base_social.png"
        attribute base_social_tie:
            "images/sprites/lucas/pose/lucas_pose_base_social_tie.png"
        attribute base_social_tie_vest:
            "images/sprites/lucas/pose/lucas_pose_base_social_tie_vest.png"

        # --- POSE BRAÇO NA CABEÇA ---
        attribute head_naked:
            "images/sprites/lucas/pose/lucas_pose_head_naked.png"
        attribute head_pijama:
            "images/sprites/lucas/pose/lucas_pose_head_pijama.png"
        attribute head_pijama_bandagens:
            "images/sprites/lucas/pose/lucas_pose_head_pijama_bandagens.png"
        attribute head_social:
            "images/sprites/lucas/pose/lucas_pose_head_social.png"
        attribute head_social_tie:
            "images/sprites/lucas/pose/lucas_pose_head_social_tie.png"
        attribute head_social_tie_vest:
            "images/sprites/lucas/pose/lucas_pose_head_social_tie_vest.png"

        # --- POSE PENSANDO ---
        attribute thinking_naked:
            "images/sprites/lucas/pose/lucas_pose_thinking_naked.png"
        attribute thinking_pijama:
            "images/sprites/lucas/pose/lucas_pose_thinking_pijama.png"
        attribute thinking_pijama_bandagens:
            "images/sprites/lucas/pose/lucas_pose_thinking_pijama_bandagens.png"
        attribute thinking_social:
            "images/sprites/lucas/pose/lucas_pose_thinking_social.png"
        attribute thinking_social_tie:
            "images/sprites/lucas/pose/lucas_pose_thinking_social_tie.png"
        attribute thinking_social_tie_vest:
            "images/sprites/lucas/pose/lucas_pose_thinking_social_tie_vest.png"

        # --- POSE BRAÇOS CRUZADOS ---
        attribute crossed_naked:
            "images/sprites/lucas/pose/lucas_pose_crossed_naked.png"
        attribute crossed_pijama:
            "images/sprites/lucas/pose/lucas_pose_crossed_pijama.png"
        attribute crossed_pijama_bandagens:
            "images/sprites/lucas/pose/lucas_pose_crossed_pijama_bandagens.png"
        attribute crossed_social:
            "images/sprites/lucas/pose/lucas_pose_crossed_social.png"
        attribute crossed_social_tie:
            "images/sprites/lucas/pose/lucas_pose_crossed_social_tie.png"
        attribute crossed_social_tie_vest:
            "images/sprites/lucas/pose/lucas_pose_crossed_social_tie_vest.png"

        # --- POSE ASSUSTADO ---
        attribute scared_naked:
            "images/sprites/lucas/pose/lucas_pose_scared_naked.png"
        attribute scared_pijama:
            "images/sprites/lucas/pose/lucas_pose_scared_pijama.png"
        attribute scared_pijama_bandagens:
            "images/sprites/lucas/pose/lucas_pose_scared_pijama_bandagens.png"
        attribute scared_social:
            "images/sprites/lucas/pose/lucas_pose_scared_social.png"
        attribute scared_social_tie:
            "images/sprites/lucas/pose/lucas_pose_scared_social_tie.png"
        attribute scared_social_tie_vest:
            "images/sprites/lucas/pose/lucas_pose_scared_social_tie_vest.png"

    group face:
        attribute neutro default:
            "images/sprites/lucas/face/base.png"
        attribute assustado:
            "images/sprites/lucas/face/assustado.png"
        attribute bravo1:
            "images/sprites/lucas/face/bravo1.png"
        attribute bravo2:
            "images/sprites/lucas/face/bravo2.png"
        attribute confuso:
            "images/sprites/lucas/face/confuso.png"
        attribute falando:
            "images/sprites/lucas/face/falando.png"
        attribute sorrindo1:
            "images/sprites/lucas/face/sorriso1.png"
        attribute sorrindo2:
            "images/sprites/lucas/face/sorriso2.png"
        attribute sorrindo3:
            "images/sprites/lucas/face/sorriso3.png"
        attribute sorrindoDeLado:
            "images/sprites/lucas/face/sorrisoDeLado.png"
        attribute sorrindoDesviandoOlhar:
            "images/sprites/lucas/face/sorrisoDesviandoOlhar.png"
        attribute triste1:
            "images/sprites/lucas/face/triste1.png"
        attribute triste2:
            "images/sprites/lucas/face/triste2.png"
        attribute triste3:
            "images/sprites/lucas/face/triste3.png"
        attribute triste4:
            "images/sprites/lucas/face/triste4.png"

    attribute face_bandage:
        "images/sprites/lucas/face_overlay/bandagem.png"

    attribute blush:
        "images/sprites/lucas/face_overlay/corado.png"

    attribute sweat:
        "images/sprites/lucas/face_overlay/suor.png"

# Assets

define flash = Fade(0.1, 0.0, 0.5, color="#fff")

# Portal

image portal:
    yanchor 0.5 ypos 0.5
    "images/assets/portal1.png"
    linear 0.5 alpha 0.4 zoom 0.95
    "images/assets/portal2.png"
    linear 0.5 alpha 0.6 zoom 1.0
    "images/assets/portal3.png"
    linear 0.5 alpha 0.5 zoom 0.975
    repeat

# Overlay de sangue

image sangue:
    "images/assets/sangue.png"
    linear 1 alpha 0.4
    "images/assets/sangue.png"
    linear 1 alpha 0.50
    "images/assets/sangue.png"
    linear 1 alpha 0.6
    repeat

# Overlay de vapor

image vapor:
    alpha 0.4
    "images/assets/vapor1.png"
    linear 1
    "images/assets/vapor2.png"
    linear 1
    "images/assets/vapor3.png"
    linear 1
    repeat

# Overlay de poeira

image poeira:
    alpha 0.4
    "images/assets/poeira1.png"
    linear 1
    "images/assets/poeira2.png"
    linear 1
    "images/assets/poeira3.png"
    linear 1
    repeat

# Overlay de alarme

image red_alarm_overlay = Solid("#ff0000")

transform alarm_flash:
    blend "add"
    
    block:
        alpha 0.0
        easein 0.15 alpha 0.45
        easeout 0.25 alpha 0.05 
        pause 0.1               
        repeat

# Carro

image carro = Image("images/assets/carro.png")

# Termos

define planeta_lucas = "Lumen"
define galaxia_lucas = "Andromeda"
define pais_lucas = "Jhormthyr"
define agencia_pt_sigla = "ANEGEA"
define agencia_pt = "Administração Nacional Extragalacxial, Espacial e Aeronáutica"
define agencia_en_allas = "NEGASA"
define agencia_en = "National Extragalaxial, Aeronautics and Spacial Administration"
define nome_implante = "PlaceHolder"

# Posições sprites

transform bancoPassageiro:
    xalign 1.1
    yoffset 250
    xzoom 0.85
    yzoom 0.85

transform ladoEsquerdo:
    xalign 0.2

# Transições side icon

transform change_transform(old, new):
    old with Dissolve(0.1, alpha=True)
    new with Dissolve(0.1, alpha=True)

transform same_transform(old, new):
    old
    new with Dissolve(0.2, alpha=True)

define config.side_image_change_transform = change_transform
define config.side_image_same_transform = same_transform

# Outros transforms

transform metadeTamanho:
    xalign 0.5
    yalign 0.5
    zoom 0.5

transform earthquake_loop:
    anchor (0.5, 0.5)
    pos (0.5, 0.5)
    zoom 1.05

    block:
        choice:
            ease 0.04 xoffset -12 yoffset 8
        choice:
            ease 0.04 xoffset 15 yoffset -10
        choice:
            ease 0.04 xoffset -8 yoffset -12
        choice:
            ease 0.04 xoffset 10 yoffset 14
        repeat

transform stop_earthquake:
    easein 0.1 xoffset 0 yoffset 0 zoom 1.0

# Começo

label start:

    with fade
    stop music fadeout 2.0

    jump prologo

    return

label continua:

    scene black
    with fade

    show text "Continua..." with dissolve
    pause 5.0

    return