# Sons

define campainha = ""

# Background

image bg white = Image("images/background/white.png")
image bg carro = Image("")
image bg estacionamento = Image("")
image bg sala casa = Image("")
image bg banheiro casa = Image("")
image bg quarto casa = Image("")
image bg laboratorio = Image("")
image bg acelerador1 = Image("")
image bg acelerador2 = Image("")
image bg hall = Image("")
image bg escombros = Image("")

# CGs

image cg escombros1 = Image("")
image cg escombros2 = Image("")

# Personagens

define v = Character("Você", color="#cfcfcf")
define seuNome = ""

# Personagens secundários

define vz = Character(name="Vizinho", color="#3d3d3d")
image vz = Image("")

define null = Character(name="???", color="#cfcfcf")

define e = Character(name="Erick", color="#01c901")

# Lucas

define l = Character("Lucas", color="#9900ff")

# Terno

image lucas terno assustado = Image("")
image lucas terno bravo1 = Image("")
image lucas terno bravo2 = Image("")
image lucas terno chocado = Image("")
image lucas terno chorando1 = Image("")
image lucas terno chorando2 = Image("")
image lucas terno duvida1 = Image("")
image lucas terno duvida2 = Image("")
image lucas terno falando = Image("")
image lucas terno ouvindo = Image("")
image lucas terno rindo = Image("")
image lucas terno sorriso1 = Image("")
image lucas terno sorriso2 = Image("")
image lucas terno timido1 = Image("")
image lucas terno timido2 = Image("")
image lucas terno triste = Image("")

# Pijama + bandagens (machuado)

image lucas pijamab assustado = Image("")
image lucas pijamab duvida1 = Image("")
image lucas pijamab duvida2 = Image("")
image lucas pijamab falando = Image("")
image lucas pijamab ouvindo = Image("")
image lucas pijamab sorriso1 = Image("")
image lucas pijamab sorriso2 = Image("")
image lucas pijamab timido1 = Image("")
image lucas pijamab timido2 = Image("")
image lucas pijamab triste = Image("")

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

# Começo

label start:

    jump prologo

    return