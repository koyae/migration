# Migration

## Setup

Git does not allow cloning directly into non-empty folders, so making files accessible in the home directory (`~`) can be a little bit tricky. There are two essetial ways of achieving this, covered in the next two sections.

### Environment variables

Some scripts (e.g. the [link.cmd](./.vs_code/link.cmd) script for VS Code) uses the `CYGHOME` environment variable. This should simply contain the Windows-style path to your Cygwin home (`~`) diretory e.g. 'C:\\cygwin\\home\\sammy'.

### Create a new repo in ~ then synch it to an upstream

1. Navigate to the home directory (`~`).
2. **`git init`** to start a new repo.
3. **`git remote add origin https://github.com/koyae/migration`** to define a remote source repo.
4. **`git remote set-url --push origin git@github.com:koyae/migration`** to allow push over SSH. (SSH is easiest for pushing whereas HTTPS is easiest for **pulling**).
5. **`git config core.sshCommand "ssh -i <path_to_ssh_key>"`**. If you're not using a generic SSH-key file like "id_rsa" in ~/.ssh, this is the easiest way to specify a custom location.
5. **`git pull origin main`** to pull from the main branch of that source.
6. **`git branch --set-upstream-to="origin/main"`** to allow **`git push`** to target `origin main` by default.
7. Perform the step listed in the **"Initialize submodules"** section below, and all following sections.

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
* socat - required by .vimrc's PipeToSocket() function
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
* gnupg2 (for `gpg2`)
* screen or tmux
* df
* rsync
* tr
* tidy (to clean up messy HTML)

### Check configuration

#### ssh-agent / askpass stuff

Once the above steps are complete, log back into Cygwin and `echo $SSH_ASKPASS`ensure that the SSH\_ASKPASS shell-variable points to one of the askpass executables which come with whichever package you chose e.g. "/usr/libexec/gnome-ssh-askpass". If it's incorrect, `export SSH_ASKPASS=<path>` in ~/export\_local

Once there, test whether this configuration is correct by running the "XWin Server" executable and then opening Cygwin. The icon to start the server should appear on the start-menu after installing the xinit and xorg-server packages. If it does not appear, you can launch the server from Cygwin with `startxwin` (/usr/bin/startxwin). If you wish to prevent the server from closing along with the Cygwin window, you'll need to add `exec sleep infinity` to the last line of `startxwin`, per superuser.com/questions/435768 and x.cygwin.com/docs/faq/cygwin-x-faq.html#q-startxwinrc-exit. Note that it is not secure to invoke Xwin.exe directly, because this skirts its permissions-mechanisms.

Running this server also allows certain GUI-applications to be run on a remote server. Enable this by passing `-XY` when connecting via `ssh`. `xeyes` and `xclock` are simple examples to try if you're testing.
