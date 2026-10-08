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

# Terno + bandagens (machucado)

image lucas ternob assustado1 = Image("images/sprites/lucas/ternob/assustado1.png")
image lucas ternob assustado2 = Image("images/sprites/lucas/ternob/assustado2.png")
image lucas ternob base = Image("images/sprites/lucas/ternob/base.png")
image lucas ternob bravo1 = Image("images/sprites/lucas/ternob/bravo1.png")
image lucas ternob bravo2 = Image("images/sprites/lucas/ternob/bravo2.png")
image lucas ternob bravo3 = Image("images/sprites/lucas/ternob/bravo3.png")
image lucas ternob chorando1 = Image("images/sprites/lucas/ternob/chorando1.png")
image lucas ternob chorando2 = Image("images/sprites/lucas/ternob/chorando2.png")
image lucas ternob chorando3 = Image("images/sprites/lucas/ternob/chorando3.png")
image lucas ternob chorando4 = Image("images/sprites/lucas/ternob/chorando4.png")
image lucas ternob chorando5 = Image("images/sprites/lucas/ternob/chorando5.png")
image lucas ternob duvida = Image("images/sprites/lucas/ternob/duvida.png")
image lucas ternob falando = Image("images/sprites/lucas/ternob/falando.png")
image lucas ternob ouvindo = Image("images/sprites/lucas/ternob/ouvindo.png")
image lucas ternob sorriso1 = Image("images/sprites/lucas/ternob/sorriso1.png")
image lucas ternob sorriso2 = Image("images/sprites/lucas/ternob/sorriso2.png")
image lucas ternob timido1 = Image("images/sprites/lucas/ternob/timido1.png")
image lucas ternob timido2 = Image("images/sprites/lucas/ternob/timido2.png")
image lucas ternob timido3 = Image("images/sprites/lucas/ternob/timido3.png")
image lucas ternob timido4 = Image("images/sprites/lucas/ternob/timido4.png")
image lucas ternob timido5 = Image("images/sprites/lucas/ternob/timido5.png")
image lucas ternob triste1 = Image("images/sprites/lucas/ternob/triste1.png")
image lucas ternob triste2 = Image("images/sprites/lucas/ternob/triste2.png")
image lucas ternob triste3 = Image("images/sprites/lucas/ternob/triste3.png")
image lucas ternob triste4 = Image("images/sprites/lucas/ternob/triste4.png")

# Terno

image lucas terno assustado1 = Image("images/sprites/lucas/terno/assustado1.png")
image lucas terno assustado2 = Image("images/sprites/lucas/terno/assustado2.png")
image lucas terno base = Image("images/sprites/lucas/terno/base.png")
image lucas terno bravo1 = Image("images/sprites/lucas/terno/bravo1.png")
image lucas terno bravo2 = Image("images/sprites/lucas/terno/bravo2.png")
image lucas terno bravo3 = Image("images/sprites/lucas/terno/bravo3.png")
image lucas terno chorando1 = Image("images/sprites/lucas/terno/chorando1.png")
image lucas terno chorando2 = Image("images/sprites/lucas/terno/chorando2.png")
image lucas terno chorando3 = Image("images/sprites/lucas/terno/chorando3.png")
image lucas terno chorando4 = Image("images/sprites/lucas/terno/chorando4.png")
image lucas terno chorando5 = Image("images/sprites/lucas/terno/chorando5.png")
image lucas terno duvida = Image("images/sprites/lucas/terno/duvida.png")
image lucas terno falando = Image("images/sprites/lucas/terno/falando.png")
image lucas terno ouvindo = Image("images/sprites/lucas/terno/ouvindo.png")
image lucas terno sorriso1 = Image("images/sprites/lucas/terno/sorriso1.png")
image lucas terno sorriso2 = Image("images/sprites/lucas/terno/sorriso2.png")
image lucas terno timido1 = Image("images/sprites/lucas/terno/timido1.png")
image lucas terno timido2 = Image("images/sprites/lucas/terno/timido2.png")
image lucas terno timido3 = Image("images/sprites/lucas/terno/timido3.png")
image lucas terno timido4 = Image("images/sprites/lucas/terno/timido4.png")
image lucas terno timido5 = Image("images/sprites/lucas/terno/timido5.png")
image lucas terno triste1 = Image("images/sprites/lucas/terno/triste1.png")
image lucas terno triste2 = Image("images/sprites/lucas/terno/triste2.png")
image lucas terno triste3 = Image("images/sprites/lucas/terno/triste3.png")
image lucas terno triste4 = Image("images/sprites/lucas/terno/triste4.png")

# Pijama + bandagens (machuado)

image lucas pijamab assustado1 = Image("images/sprites/lucas/pijamab/assustado1.png")
image lucas pijamab assustado2 = Image("images/sprites/lucas/pijamab/assustado2.png")
image lucas pijamab base = Image("images/sprites/lucas/pijamab/base.png")
image lucas pijamab bravo1 = Image("images/sprites/lucas/pijamab/bravo1.png")
image lucas pijamab bravo2 = Image("images/sprites/lucas/pijamab/bravo2.png")
image lucas pijamab bravo3 = Image("images/sprites/lucas/pijamab/bravo3.png")
image lucas pijamab chorando1 = Image("images/sprites/lucas/pijamab/chorando1.png")
image lucas pijamab chorando2 = Image("images/sprites/lucas/pijamab/chorando2.png")
image lucas pijamab chorando3 = Image("images/sprites/lucas/pijamab/chorando3.png")
image lucas pijamab chorando4 = Image("images/sprites/lucas/pijamab/chorando4.png")
image lucas pijamab chorando5 = Image("images/sprites/lucas/pijamab/chorando5.png")
image lucas pijamab duvida = Image("images/sprites/lucas/pijamab/duvida.png")
image lucas pijamab falando = Image("images/sprites/lucas/pijamab/falando.png")
image lucas pijamab ouvindo = Image("images/sprites/lucas/pijamab/ouvindo.png")
image lucas pijamab sorriso1 = Image("images/sprites/lucas/pijamab/sorriso1.png")
image lucas pijamab sorriso2 = Image("images/sprites/lucas/pijamab/sorriso2.png")
image lucas pijamab timido1 = Image("images/sprites/lucas/pijamab/timido1.png")
image lucas pijamab timido2 = Image("images/sprites/lucas/pijamab/timido2.png")
image lucas pijamab timido3 = Image("images/sprites/lucas/pijamab/timido3.png")
image lucas pijamab timido4 = Image("images/sprites/lucas/pijamab/timido4.png")
image lucas pijamab timido5 = Image("images/sprites/lucas/pijamab/timido5.png")
image lucas pijamab triste1 = Image("images/sprites/lucas/pijamab/triste1.png")
image lucas pijamab triste2 = Image("images/sprites/lucas/pijamab/triste2.png")
image lucas pijamab triste3 = Image("images/sprites/lucas/pijamab/triste3.png")
image lucas pijamab triste4 = Image("images/sprites/lucas/pijamab/triste4.png")

# Side Icons

# Lucas

image side lucas assustado1 = Image("images/sideIcon/lucas/assustado1.png")
image side lucas assustado2 = Image("images/sideIcon/lucas/assustado2.png")
image side lucas base = Image("images/sideIcon/lucas/base.png")
image side lucas bravo1 = Image("images/sideIcon/lucas/bravo1.png")
image side lucas bravo2 = Image("images/sideIcon/lucas/bravo2.png")
image side lucas bravo3 = Image("images/sideIcon/lucas/bravo3.png")
image side lucas chorando1 = Image("images/sideIcon/lucas/chorando1.png")
image side lucas chorando2 = Image("images/sideIcon/lucas/chorando2.png")
image side lucas chorando3 = Image("images/sideIcon/lucas/chorando3.png")
image side lucas chorando4 = Image("images/sideIcon/lucas/chorando4.png")
image side lucas chorando5 = Image("images/sideIcon/lucas/chorando5.png")
image side lucas duvida = Image("images/sideIcon/lucas/duvida.png")
image side lucas falando = Image("images/sideIcon/lucas/falando.png")
image side lucas ouvindo = Image("images/sideIcon/lucas/ouvindo.png")
image side lucas sorriso1 = Image("images/sideIcon/lucas/sorriso1.png")
image side lucas sorriso2 = Image("images/sideIcon/lucas/sorriso2.png")
image side lucas timido1 = Image("images/sideIcon/lucas/timido1.png")
image side lucas timido2 = Image("images/sideIcon/lucas/timido2.png")
image side lucas timido3 = Image("images/sideIcon/lucas/timido3.png")
image side lucas timido4 = Image("images/sideIcon/lucas/timido4.png")
image side lucas timido5 = Image("images/sideIcon/lucas/timido5.png")
image side lucas triste1 = Image("images/sideIcon/lucas/triste1.png")
image side lucas triste2 = Image("images/sideIcon/lucas/triste2.png")
image side lucas triste3 = Image("images/sideIcon/lucas/triste3.png")
image side lucas triste4 = Image("images/sideIcon/lucas/triste4.png")

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

transform noTapete:
    xalign 0.3

transform bancoPassageiro:
    xalign 1.1
    yoffset 250
    xzoom -0.85
    yzoom 0.85

transform emBaixo:
    yoffset 200

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

transform metadeTamanho: # Imagem fica no meio da tela
    xalign 0.5
    yalign 0.5
    zoom 0.5

# Tremor em loop aleatório contínuo
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

# Para o tremor suavemente resetando a posição
transform stop_earthquake:
    easein 0.1 xoffset 0 yoffset 0 zoom 1.0

# Começo

label start:

    # Transição inicial
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