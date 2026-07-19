# Sons

define campainha = "audio/campainha.mp3"

# Background

image bg carro = Image("images/background/carro.jpeg")
image bg estacionamento = Image("images/background/estacionamento.jpeg")
image bg sala casa = Image("images/background/sala.jpeg")
image bg banheiro casa = Image("images/background/banheiro.jpeg")
image bg quarto casa = Image("images/background/quarto.jpeg")
image bg laboratorio = Image("images/background/laboratorio.jpg")
image bg acelerador1 = Image("images/background/acelerador1.jpg")
image bg acelerador2 = Image("images/background/acelerador2.jpg")
image bg white = Image("images/background/white.png")
image bg hall = Image("images/background/hall.png")
image bg escombros = Image("images/background/escombros.png")

# CGs

image cg escombros1 = Image("images/cg/escombros1.png")
image cg escombros2 = Image("images/cg/escombros2.png")

# Personagens

define v = Character("Você", color="#cfcfcf")
define seuNome = ""

# Personagens secundários

define vz = Character(name="Vizinho", color="#3d3d3d")
image vz = Image("images/sprite/@0.4/vizinho.svg")

define null = Character(name="???", color="#cfcfcf")

define e = Character(name="Erick", color="#01c901")

# Lucas

define l = Character("Lucas", color="#9900ff")

# Terno

image lucas terno assustado = Image("images/sprite/lucas/terno/assustado.png")
image lucas terno bravo1 = Image("images/sprite/lucas/terno/bravo1.png")
image lucas terno bravo2 = Image("images/sprite/lucas/terno/bravo2.png")
image lucas terno chocado = Image("images/sprite/lucas/terno/chocado.png")
image lucas terno chorando1 = Image("images/sprite/lucas/terno/chorando1.png")
image lucas terno chorando2 = Image("images/sprite/lucas/terno/chorando2.png")
image lucas terno falando = Image("images/sprite/lucas/terno/falando.png")
image lucas terno ouvindo = Image("images/sprite/lucas/terno/ouvindo.png")
image lucas terno rindo = Image("images/sprite/lucas/terno/rindo.png")
image lucas terno sorriso = Image("images/sprite/lucas/terno/sorriso.png")
image lucas terno timido1 = Image("images/sprite/lucas/terno/timido1.png")
image lucas terno timido2 = Image("images/sprite/lucas/terno/timido2.png")
image lucas terno triste = Image("images/sprite/lucas/terno/triste.png")

# Pijama + bandagens

image lucas pijamab assustado1 = Image("images/sprite/lucas/pijamab/assustado1.png")
image lucas pijamab assustado2 = Image("images/sprite/lucas/pijamab/assustado2.png")
image lucas pijamab duvida1 = Image("images/sprite/lucas/pijamab/duvida1.png")
image lucas pijamab duvida2 = Image("images/sprite/lucas/pijamab/duvida2.png")
image lucas pijamab falando = Image("images/sprite/lucas/pijamab/falando.png")
image lucas pijamab ouvindo = Image("images/sprite/lucas/pijamab/ouvindo.png")
image lucas pijamab sorriso1 = Image("images/sprite/lucas/pijamab/sorriso1.png")
image lucas pijamab sorriso2 = Image("images/sprite/lucas/pijamab/sorriso2.png")
image lucas pijamab timido1 = Image("images/sprite/lucas/pijamab/timido1.png")
image lucas pijamab timido2 = Image("images/sprite/lucas/pijamab/timido2.png")

# Assets

define flash = Fade(0.1, 0.0, 0.5, color="#fff")

# Começo

label start:

    jump prologo

    return