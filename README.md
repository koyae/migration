# Migration

## Setup

Git does not allow cloning directly into non-empty folders, so making files accessible in the home directory (`~`) can be a little bit tricky. There are two essetial ways of achieving this, covered in the next two sections.

### Create a new repo in ~ then synch it to an upstream

1. Navigate to the home directory (`~`).
2. **`git init`** to start a new repo.
3. **`git remote add origin https://github.com/koyae/migration`** to define a remote source repo.
4. **`git pull origin master`** to pull from the master branch of that source.
5. **`git branch --set-upstream-to="origin/master"`** to allow **`git push`** to target `origin master` by default.
6. Perform the step listed in the **"Initialize submodules"** section below, and all following sections.

#### Advantages

* This approach is easier given that it does not require any decision-making as to which files to keep or leave in a subdirectory.
* This approach is best for virtual filesystems on which **`ln -s`** may not have the expected behavior.

#### Disadvantages

* Creating the repo in `~` will make the directory slightly more cluttered due to extra files such as this README. Though extra files *can* be simply be deleted, this creates some risk of committing the removal accidentally.
* **`git add .`** is generally not an option for adding a number of new files due to other things which will likely be present in `~/`

### Clone the repo into a new directory and then link files to ~

1. **`git clone https://github.com/koyae/migration`** [*`dirname`*] to clone the repo to a directory (this can be within `~` or elsewhere)
2. For each of the files you would like to use, do:
  * **``ln -s " `pwd -P`\``*`file`*`"` `realpath ~`** to add a symbolic link, making the file transparently accessible to `~`
3. Perform the step listed in the **"Initialize submodules"** section below, and all following sections.

#### Advantages

* This approach allows you to selectively link files to `~` in the case you don't want all of them.
* Reduces the amount of clutter you might get from files like `README.md` or `export_local__remove_my_tail` without creating the risk of committing removed files accidentally (as git can still find them)
* Allows **`git add .`** to be used from the subdirectory without extra files (such as `.ssh` or such) being added unintentionally.

#### Disadvantages

* It can be inconvenient to create these linkages, especially on non-Unix filesystems in the case of Cygwin, where symbolic links are essentially faked. Although this is fine for individual files, it does not seem to work nicely for directories, especially in a way that would be dually transparent to Explorer.

### Initialize submodules

This repo includes vim-plugins which are managed as git submodules. To initialize them, run: **`git submodule update --init --recursive`**

### Modify `.gitconfig`

This repo uses `.gitconfig1` to avoid conflicts with `.gitconfig` since it may be written to often which causes conflicts when committing or synching with the repo.

Run **`bin2/setup.sh`** to add the import lines to `.gitconfig` and then type `:q`, `<enter>` to exit vim or just do **`git config --global --add include.path <path to .gitconfig1>`**

### Modify `/etc/bashrc` or `export_local__remove_my_tail`

On Windows systems, the $HOME directory is not always set reliably, which can result in some VERY confusing behavior with regard to what `~` actually represents in the shell versus saved scripts. (In the worst case, it can point to two different places, making its meaning ambiguous in certain cases.)

To correct this for ALL Cygwin users on the system, add the below line to `/etc/bashrc`. To correct this only for yourself, add the same line instead to `export_local__remove_my_tail` (best if other Cygwin users on your system do not keep their `~` directories in the same spot as yours).

	HOME=$"<cygwin directory>/home/`whoami`"

You may need to adjust the above line depending on your system's configuration.

### Install additional packages

A few of the functions and scripts in this repo rely on additional packages. Others stand alone fine without script-wrappers but are nice to have.

#### Required-for-certain-things packages

* xinit - required to run XWin Server which allows `ssh-add -c` to work
* xorg-server - required to run XWin Server which allows `ssh-add -c` to work
* gnome-ssh-askpass or lxqt-openssh-askpass - required for displaying ssh-agent prompts
* vim – required by `xviml`, `sviml`, `jvimn`, and "setup.sh"
* grep – required by `grepr` function
* hexdump – required by `debom` script
* tail – required by `debom` script
* xmllint – required by `xviml` function
* python2 or python3 – required by `jvimn` function
* tar – required by `untar` function
* find – required by `shortfind` function
* dirname – required by `up`, `cdl`, `lcd`
* du – required by `duc` function
* readlink – required by `c_d` function
* zip – required by `toc` function
* sed – required by `prepend` and `wcd` functions
* awk – required by `s3cmd` and `ps` functions
* bc – required by `s3cmd` function
* find – required by `fnd` function

#### Nice-to-have packages

* dos2unix
* git
* ssh
* ssh-keygen
* openssl
* screen or tmux
* df
* rsync
* tr

### Check configuration

#### ssh-agent / askpass stuff

	Once the above steps are complete, ensure that the SSH\_ASKPASS shell-variable points to one of the askpass executables which come with whichever package you chose e.g. "/usr/libexec/gnome-ssh-askpass".
