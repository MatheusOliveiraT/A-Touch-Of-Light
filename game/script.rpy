# Sons

define campainha = ""

# Vozes

define voz_v = "audio/voice/voce.ogg"
define voz_l = "audio/voice/lucas.ogg"

init python:
    renpy.music.register_channel("vozes", mixer="voice", loop=True)

    def somDaFalaL(event, interact=True, **kwargs):
        if event == "show":
            renpy.sound.play(voz_l, channel="vozes", loop=True)
        elif event == "slow_done" or event == "end":
            renpy.sound.stop(channel="vozes")

    def somDaFalaV(event, interact=True, **kwargs):
        if event == "show":
            renpy.sound.play(voz_v, channel="vozes", loop=True)
        elif event == "slow_done" or event == "end":
            renpy.sound.stop(channel="vozes")

# Background

image bg white = Image("images/background/white.png")
image bg carro = Image("")
image bg estacionamento = Image("")
image bg sala casa = Image("images/background/sala.png")
image bg banheiro casa = Image("images/background/banheiro.png")
image bg quarto casa = Image("")
image bg laboratorio = Image("")
image bg acelerador1 = Image("")
image bg acelerador2 = Image("")
image bg hall = Image("")
image bg escombros = Image("")

# CGs

default persistent.escombros = False
image icone escombros = Image("")
image cg escombros1 = Image("")
image cg escombros2 = Image("")

# Personagens

define v = Character("Você", color="#cfcfcf", callback=somDaFalaV)
define v_e = Character("You", color="#cfcfcf", callback=somDaFalaV)
define seuNome = ""

# Personagens secundários

define vz = Character(name="Vizinho", color="#3d3d3d")
define vz_e = Character(name="Neighbour", color="#3d3d3d")
image vz = Image("images/sprites/vizinho.png")

define null = Character(name="???", color="#cfcfcf")

define e = Character(name="Erick", color="#01c901")

# Lucas

define null_l = Character(name="???", color="#cfcfcf", callback=somDaFalaL)
define l = Character("Lucas", color="#9900ff", callback=somDaFalaL)

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

# Assets

define flash = Fade(0.1, 0.0, 0.5, color="#fff")

# Portal

image portal:
    "images/assets/portal1.png"
    linear 1 alpha 0.25
    "images/assets/portal2.png"
    linear 1 alpha 0.75
    "images/assets/portal3.png"
    linear 1 alpha 0.5
    repeat

# Termos

define planeta_lucas = "Lumen"
define galaxia_lucas = "Andromeda"

# Posições sprites

transform noTapete:
    xalign 0.2

# Começo

label start:

    jump prologo

    return

label continua:

    scene black
    with fade

    "Continua..."

    return