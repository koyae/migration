from gimpfu import *

def invert_foreground( ):
    fg = gimp.get_foreground()
    gimp.set_foreground( 255 - fg[0],
                         255 - fg[1],
                         255 - fg[2] )
    return

register("context_foreground_invert",
         N_("Invert the foreground swatch's color."),
         "Bind to a key for easy access.",
         "Needthistool",
         "Needthistool",
         "February 2014",
         N_("_Invert foreground"),
         "",
         [],
         [],
         invert_foreground,
         menu="<Toolbox>/Tools/",
         domain=("gimp20-python", gimp.locale_directory)
         )

# gimp.pdb.gimp_message("invert_forground loaded")

main()
