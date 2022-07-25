import sys
import os
import datetime
from argparse import ArgumentParser

# Invoke this script using CMD e.g.:
#
# python art_sort.py --dry-run=false D:\pictures D:\OneDrive\new_sorted_art
#
##

parser = ArgumentParser(
    description="""Commandline tool for sorting files.

    Specify a source directory containing files with one or more space-delimited
    tags in the filename. The leading tag (first string of characters before the
    first space, which must be present to sort by tag, as opposed to extension)
    will be used to place the file into any (nested) folders in the specified
    destination folder. Each directory-name under the destination folder will be
    interpreted as a tag by which files can be sorted.

    Files can also be sorted into folders by extension (by creating a folder
    somewhere within the destination-directory ("dest", say) named like
    "dest/.jpg/", "dest/.png/", or similar). Extensions are used as a secondary,
    fallback way to sort files which don't match any tags; files with matching tags
    will be sorted according to the tag, even if there is an extension-based
    destination for them also.

    Files that have no tags (including any file without a space in the name)
    which also don't match any extension specified in the destination folders
    will simply be left in place.

    This utility can be used to RE-SORT files when the top-level source and dest
    folders are actually the same directory.
    """
)

def boolifier(arg):
    """ string arg representing a boolean from commandline -> boolean """
    nolist = ["no","0","false","n","",False]
    yeslist = ["yes","true","1","y",True]
    if arg.lower() in nolist:
        return False
    elif arg.lower() in yeslist:
        return True
    else:
        parser.error(f"Valid choices for true/false flags: {nolist+yeslist}")


def logpathifier(arg):
    """ string arg representeing a path to a log-file -> path or None """
    if arg.lower() in ["None",""]:
        return None
    else:
        absolute_directory = os.path.join(*os.path.abspath(arg)[0:-1])
        if len(os.path.split(arg))==2 and os.path.split(arg)[0]=="":
            return arg
        else:
            if os.path.isdir(absolute_directory):
                return arg
            else:
                print(os.path.split(arg))
                parser.error(
                    f"Log folder \"{os.path.split(arg)[0]}\" does not exist"
                )

parser.add_argument(
    "source_dir",
    type=str,
    help="The folder to search for files to move"
)

parser.add_argument(
    "dest_dir",
    type=str,
    help="The folder into which matching files will be moved"
)

parser.add_argument(
    "--no-op-log", "-n",
    type=logpathifier,
    help="Log-destination for files NOT moved. Pass 'NONE' to skip logging",
    default="no_ops.log",
    required=False
)

parser.add_argument(
    "--move-log", "-l", "-m",
    type=logpathifier,
    help="Log-destination for files that were moved. Pass 'NONE' to skip logging",
    default="moves.log",
    required=False
)

parser.add_argument(
    "--quiet","-q",
    help="Supress messages about where files are being moved."
    " Logs will still be written unless 'NONE' is specified for log files.",
    action='store_const',
    const=True,
    required=False
)

parser.add_argument(
    "--dry-run",
    help="Only emit messages indicating that a moves would happen",
    action='store',
    type=boolifier,
    nargs='?',
    metavar="{true/false/yes/no}",
    default=True,
    required=False
)

parser.add_argument(
    "--ignore_dirs",
    type=str,
    help="Folders to skip when looking for files to move",
    nargs='+',
    metavar="IGNORE_DIR",
    default=[],
    required=False
)

args = parser.parse_args()
ignore_dirs = []

if not os.path.isdir(args.source_dir):
# if source_dir is invalid
    parser.error(f"source_dir {args.source_dir} is not a folder")
elif not [
    n for n in os.listdir(args.dest_dir) if os.path.isdir(os.path.join(args.dest_dir,n))
]:
# if dest_dir is empty (no subfolders, so therefore no tags)
    parser.error(f"dest_dir \"{args.dest_dir}\" has no tags")
elif not os.path.isdir(args.dest_dir):
    parser.error(f"dest_dir \"{args.dest_dir}\" is not a folder")
for d in args.ignore_dirs:
    if not os.path.isdir(d):
        parser.error(f"ignore_dir {d} is not a valid folder")
    ignore_dirs.append(os.path.abspath(d))

for log_path in [args.move_log, args.no_op_log]:
    if log_path:
        with open(log_path, "a") as wh:
            wh.write(datetime.datetime.now().strftime("Logs for %Y-%m-%d %H:%M:%S "))
            wh.write(datetime.datetime.now().strftime(f"| WORKING DIRECTORY: \"{sys.path[0]}\":\n"))

if not args.quiet:
    print(f"\nDRY RUN: {args.dry_run}", file=sys.stderr)

# Step 1: Go scan for the tags in the dest folder, and compile a mapping from
# tag to location

tags = {}

for n in os.walk(args.dest_dir):
    tag_name = os.path.split(n[0])[-1] # last component of path is tag
    if tag_name != "raw":
        if " " in tag_name:
            parser.error(f"Invalid tag \"{tag_name}\"; tags can't have spaces.")
        elif tag_name not in tags:
            tags[tag_name] = n[0]
            # each tag (key) maps to a specific location (value at key)
        else:
            raise Exception(f"{tag_name} appears more than once. Exiting.")

# Step 2: Go scan the pictures/source folder for files that match the criteria
# defined by what we picked up in step 1, moving files as we find them
# DO NOT OVERWRITE FILES OF THE SAME NAME IN THE DEST FOLDER

def move_file(f,dest,dry_run=None,if_conflict=None):
    """ file to move, destination directory, fake move -> None

    Source file and dest folder are always assumed to be valid. Be prepared to
    `catch` if you're not confident of this, caller!

        f           --  file to move. either an absolute path or path to valid
                        file relative to the current working directory
        dest        --  destination directory (folder)
        dry_run     --  whether to actually perform the move or just print what
                        the action would have been. If the default value is
                        received, `args` will be consulted for what to do
        if_conflict --  what to do if two files from the source directory
                        (including subdirectories) have the same name in the
                        same folder to which files are being copied.

    """
    if dry_run is None:
        dry_run = args.dry_run
    move_message = f"MOVE{int(dry_run)*' (FAKE)'}: \"{f}\" -> {dest}{os.path.sep}"
    if if_conflict is not None:
        raise NotImplemented("Overwrite-handling? You're on your own, buddy.")
    elif not move_file.emitted_warning and not args.quiet:
        print(
            "\nWARNING: file-collision handling not selected. May exit on conflict.",
            "\n(No files will be overwritten if collisions are encountered.)\n",
            file=sys.stderr
        )
        move_file.emitted_warning = True
    if not args.quiet:
        print(move_message,file=sys.stderr)
    if args.move_log:
        with open(args.move_log, "a") as wh: # UGLY
            wh.write(move_message+"\n")
    if not dry_run:
        os.rename(f, os.path.join(dest,os.path.basename(f)))
#
move_file.emitted_warning = False

# traverse source dir:
for n in os.walk(args.source_dir):
# ^ n will be 3-ples (dirpath,dirnames[],filenames[])
    if os.path.abspath(n[0]) not in ignore_dirs:
    # if current directory is not ignored
        for f in n[2]:
            if not os.path.abspath(f) == f:
            # if path is relative:
                f = os.path.join(n[0],f)
            filename_only = os.path.split(f)[-1]
        # for each file in current directory, perform DA MAGIX
            first_part = filename_only.split(" ")[0]
            if first_part in tags:
            # ^ if first part of filename before space is a tag, try to move
            # the file:
                move_file(f,tags[first_part])
            else:
                moved_by_extension=False
                exts = [e for e in tags if "." in e]
                exts.sort(key=len, reverse=True) # <- longest extensions first
                for ext in exts:
                # for any extension-based sorting we're doing, check for matches:
                    if filename_only.endswith(ext):
                        moved_by_extension = True
                        move_file(f,tags[ext])
                        break
                        # ^ break to avoid trying to move an already-moved file
                if not moved_by_extension and not args.quiet:
                # if there was no reason to move the file, and we're supposed
                # to emit helful info, print a notice
                    ff = os.path.join(args.source_dir,f)
                    no_op_message = f"No tags or target extensions found for {ff}"
                    if not args.quiet:
                        print(no_op_message,file=sys.stderr)
                    if args.no_op_log:
                        with open(args.no_op_log,"a") as wh:
                            wh.write(no_op_message + "\n")
    elif not args.quiet:
        print(f"Ignored dir {n[0]}", file=sys.stderr)

if not args.quiet:
    print("\n\nDONE :3", file=sys.stderr)

