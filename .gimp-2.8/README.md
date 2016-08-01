On Windows, `menurc` should be `mklink`'d to the following locations:

* "C:\\Program Files\\Git\\.gimp-2.8\\menurc" (or wherever Git Bash is installed, assuming it is installed)
* "_cygwinDirectory_\\home\\_userName_\\.gimp-2.8\\menurc" (assuming Cygwin is installed but the repo is not in ~/)
* "C:\\Program Files\\GIMP 2\_8\\etc\\gimp\\2.0\\menurc"
* "%USERPROFILE%\\.gimp-2.8\\menurc"

On Linux, it can be left where it is. If desired, it can also be presumably symlinked to:

* "/etc/gimp/2.0/menurc"
