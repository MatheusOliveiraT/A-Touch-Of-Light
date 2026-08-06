init python:

    g = Gallery()

    g.locked_button = "icone bloqueado"

    # CG Escombros

    g.button("Escombros")
    g.condition("persistent.escombros")
    g.image("cg escombros1")
    g.image("cg escombros2")

    g.button("Shopping")
    g.condition("persistent.shopping")
    g.image("cg shopping")

    g.transition = dissolve

screen galeria():

    tag menu

    use game_menu(_("Galeria")):
        vpgrid:
            cols 3
            spacing 25              
            xalign 0.5             
            yalign 0.1              
            xfill False            
            yfill False

            add g.make_button("Escombros", "icone escombros", "icone bloqueado")
            add g.make_button("Shopping", "icone shopping", "icone bloqueado")