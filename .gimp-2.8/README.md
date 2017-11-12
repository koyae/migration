Below, the precise directories used may need to change depending upon the version of GIMP that's installed on the host machine you're using. The following placeholders are used below:

* _majorVersion_ e.g. 2.0, 3.0, 4.0, etc.
* _version_ e.g. 2.8
* _cygwinDirectory_ the directory that Cygwin treats as "/"
* _gimpInstallDir_ the top-level directory into which GIMP was installed (only refers to Windows systems)
* `<your_cygwin_home>` the home (~) directory for the account you're currently using (only refers to Windows systems) e.g. "C:\\cygwin\\home\\koyae"

# menurc and sessionrc

On Windows, it's easiest just to link all preference-related stuff using `mklink` from an elevated Windows CMD-prompt:

```bat
cd %USERPROFILE%
mklink /D .gimp-2.8 "<your_cygwin_home>\.gimp-2.8"
```

Alternatively, "menurc" and "sessionrc" can be `mklink`'d to the following location(s):

* "C:\\Program Files\\Git\\.gimp-_version_\\\<whateverrc>" (or wherever Git Bash is installed, assuming it is installed)
* "_cygwinDirectory_\\home\\_userName_\\.gimp-_version_\\\<whateverrc>" (assuming Cygwin is installed but the repo is not in ~/)
* "_gimpInstallDir_\\etc\\gimp\\_majorVersion_\\\<whateverrc>"
* "%USERPROFILE%\\.gimp-_version_\\\<whateverrc>"

On Linux, it can be left where it is. If desired, it can also be presumably symlinked to:

* "/etc/gimp/_majorVersion_/menurc" e.g. "/etc/gimp/2.0/menurc"




# plugins

Unless GIMP is very strangely configured by the files in etc/, custom plugins should load fine where they are if you set up the migration repo right in "~/". If you didn't, you'll need to symlink .gimp*version*/ into your home-directory.

On both Windows (if Cygwin is installed) and Linux, GIMP seems to detect and add the home-directory's ".gimp*version*/"-folder just fine. If that isn't the case, there are two fixes for this below.



## Troubleshooting


### GUI-based fix:

Regardless of operating system, one way to fix the problem should be:

* simply check the values under **Edit** -> **Preferences** -> **Folders** -> **Plug-ins** and make sure the "plug-ins" directory from this repo is included in the list, then restart GIMP.


### Automated fix:

If you hop machines all the time and do not want to point GIMP to an additional plug-ins directory every time, a custom configuration can be added to "gimprc" that looks something like:

`(plug-in-path "${gimp_dir}/plug-ins:${gimp_plug_in_dir}/plug-ins")`
 
#### on Windows

On Windows, the something like the above line can be added to either of two files:

* "_cywinDirectory_\\home\\_userName_\\.gimp-_version_\\gimprc" 
* or "_gimpInstallDir_\\etc\\gimp\\_majorVersion_\\gimprc". 

Keep in mind that since the list is colon-separated, it may be necessary to escape volume-prefixes like 'C:' as 'C\\:'.

#### on Linux

On Linux, another way of getting the system to recognize your plugins-folder is to place the line in:

* "/etc/gimp/_majorVersion_/gimprc"
