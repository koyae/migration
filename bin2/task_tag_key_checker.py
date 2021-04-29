#!/usr/bin/env python

# Simple script for check to see whether a glossary (also just called a 'key'
# in this file) of `task` tags (taskwarrior-item tags) actually has all of the
# tags defined that are in use.

import subprocess
import os
import re


# Exploit task's _tags subcommand to get all of the tags by themselves without
# having to do filtering and cleanup:
sp = subprocess.Popen(["task","_tags"], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
out, err = sp.communicate()
exitcode = sp.returncode


out = [v for v in out.split("\n") if v]
used_tags = set(out)

# 3: Check to see whether the path to the glossary was provided, and procede if we
# have a glossary to work with:
path_to_key = os.getenv("TASK_TAG_KEY_CHECKER_KEY_PATH")
if path_to_key:
    if os.path.exists(os.path.expanduser(path_to_key)): # :3
    # 7: Collect all of the tags found in the glossary so we can compare them
    # to the tags that are actually in use:
        tags_from_key = set()
        tagcapture = re.compile(r"^\s*([@a-z0-9_]+)")
        with open(path_to_key,"r") as rh:
            for l in rh:
                match = tagcapture.match(l)
                if match:
                    tags_from_key.add(match.groups(0)[0]) # :7
        undefined_tags = used_tags.difference(tags_from_key)
        if undefined_tags:
            print("Undefined tags: {}".format(", ".join(undefined_tags)))
        else:
            print("No undefined tags. Good job!")
    else:
        print("Nothing found at path {}. Exiting.".format(path_to_key))
else:
    print("TASK_TAG_KEY_CHECKER_KEY_PATH is not set. Exiting.")
    exit(1)

