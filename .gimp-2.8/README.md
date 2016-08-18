# menurc

On Windows, `menurc` should be `mklink`'d to the following locations:

* "C:\\Program Files\\Git\\.gimp-2.8\\menurc" (or wherever Git Bash is installed, assuming it is installed)
* "_cygwinDirectory_\\home\\_userName_\\.gimp-2.8\\menurc" (assuming Cygwin is installed but the repo is not in ~/)
* "C:\\Program Files\\GIMP 2\_8\\etc\\gimp\\2.0\\menurc"
* "%USERPROFILE%\\.gimp-2.8\\menurc"

On Linux, it can be left where it is. If desired, it can also be presumably symlinked to:

* "/etc/gimp/_majorVersion_.0/menurc" e.g. "/etc/gimp/2.0/menurc"




# plugins

Unless GIMP is very strangely configured by the files in etc/, custom plugins should load fine where they are if you set up the migration repo right in "~/". If you didn't, you'll need to symlink .gimp*version*/ into your home-directory.

On both Windows (if Cygwin is installed) and Linux, GIMP seems to detect and add the home-directory's ".gimp*version*/"-folder just fine. If that isn't the case, there are two fixes for this below.



## Troubleshooting


### GUI-based fix:

Regardless of operating system, one way to fix the problem should be:

* simply check the values under **Edit** -> **Preferences** -> **Folders** -> **Plug-ins** and make sure the "plug-ins" directory from this repo is included in the list, then restart GIMP.


### Automated fix:

If you hop machines all the time and do not want to point GIMP to an additional plug-ins directory every time, a custom configuration can be added to "gimprc" that looks something like:

`
(plug-in-path "${gimp_dir}/plug-ins:${gimp_plug_in_dir}/plug-ins")
`
#### on Windows

On Windows, the something like the above line can be added to either of two files:

* "~/.gimp*version*/gimprc" 
* or "_gimpInstallDir_/etc/gimp/_majorVersion.0_/gimprc". 

Keep in mind that since the list is colon-separated, it may be necessary to escape volume-prefixes like 'C:' as 'C\:'.

#### on Linux

On Linux, another way of getting the system to recognize your plugins-folder is to place the line in:

* "/etc/gimp/_majorVersion_.0/gimprc"
