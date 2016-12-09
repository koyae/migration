# Migration

## Setup

Git does not allow cloning directly into non-empty folders, so making files accessible in the home directory (`~`) can be a little bit tricky. There are two essetial ways of achieving this, covered in the next two sections.

### Create a new repo in ~ then synch it to an upstream

1. Navigate to the home directory (`~`).
2. **`git init`** to start a new repo.
3. **`git remote add origin https://github.com/koyae/migration`** to define a remote source repo. 
4. **`git pull origin master`** to pull from the master branch of that source.
5. **`git --set-upstream-to origin master`** to allow **`git push`** to target `origin master` by default.

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

#### Advantages

* This approach allows you to selectively link files to `~` in the case you don't want all of them. 
* Reduces the amount of clutter you might get from files like `README.md` or `export_local__remove_my_tail` without creating the risk of committing removed files accidentally (as git can still find them)
* Allows **`git add .`** to be used from the subdirectory without extra files (such as `.ssh` or such) being added unintentionally.

#### Disadvantages

* It can be inconvenient to create these linkages, especially on non-Unix filesystems in the case of Cygwin, where symbolic links are essentially faked. Although this is fine for individual files, it does not seem to work nicely for directories, especially in a way that would be dually transparent to Explorer.

### Initialize submodules

This repo includes vim-plugins which are managed as git submodules. To initialize them, run: **`git submodule update --init --recursive`** 
 
### Modify `/etc/bashrc` or `export_local__remove_my_tail`

On Windows systems, the $HOME directory is not always set reliably, which can result in some VERY confusing behavior with regard to what `~` actually represents the shell versus saved scripts. (In the worst case, it can point to two different places, making its meaning ambiguous in certain cases.) 

To correct this for ALL Cygwin users on the system, add the below line to `/etc/bashrc`. To correct this only for yourself, add the same line instead to `export_local__remove_my_tail` (best if other Cygwin users on your system do not keep their `~` directories in the same spot as yours).

	HOME=$"<cygwin directory>/home/`whoami`"

You may need to adjust the above line depending on your system's configuration.

