init python:

    g = Gallery()

    # CG Escombros

    g.button("Escombros")
    g.condition("persistent.escombros")
    g.image("cg escombros1")
    g.image("cg escombros2")

    g.transition = dissolve

screen galeria:

    tag menu

    add gui.main_menu_background

    grid 3 3:

        xfill True
        yfill True

        add g.make_button("Escombros", "icone escombros", xalign=0.5, yalign=0.5)


    textbutton "Voltar" action Return() xalign 0.5 yalign 0.5