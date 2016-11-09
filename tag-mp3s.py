#!/usr/bin/env python3

import getopt
import glob
import mutagen.id3
import mutagen.mp3
import os
import sys
import re

min_mp3s_for_album = 4
dry_run = False

def walk_tree(base_dir, visit_function):
    visit_function(base_dir)
    for ent in os.listdir(base_dir):
        if ent.startswith("."):
            next
        path = "%s/%s" % (base_dir, ent)
        if os.path.isdir(path):
            walk_tree(path, visit_function)

def process_dir(path):
    mp3s = glob.glob("%s/*.mp3" % path)
    jpgs = glob.glob("%s/*.jpg" % path)
    artwork_path = choose_artwork(mp3s, jpgs)
    for mp3 in mp3s:
        process_mp3(mp3, artwork_path)

def choose_artwork(mp3s, jpgs):
    if len(mp3s) < min_mp3s_for_album:
        return None
    if len(jpgs) == 0:
        sys.stderr.write("No album artwork found in %s\n" % path)
        return None
    if len(jpgs) > 1:
        sys.stderr.write("Multiple album artwork files found in %s\n" % path)
        return None
    return jpgs[0]


def read_file(fname):
    f = open(fname, "rb")
    data = f.read()
    f.close()
    return data

def clean_title(title):
    new_title = re.sub(r'[\[\(]((explicit\s+)?album\s+version|explicit|clean)[\]\)]', '', title, flags = re.IGNORECASE)
    new_title = re.sub(r'\s\s+', ' ', new_title)
    return new_title.strip()

def clean_tag(mp3, tagname):
    if tagname in mp3:
        tag = mp3[tagname]
        if tag is not None:
            orig_text = tag.text[0]
            new_text = clean_title(orig_text)
            if new_text != orig_text:
                sys.stdout.write("Changing %s from \"%s\" to \"%s\"\n" % (tagname, orig_text, new_text))
                tag.text = [new_text]
                return True
    return False

def process_mp3(mp3_path, artwork_path):
    mp3 = mutagen.mp3.MP3(mp3_path)
    current_tags = mp3.tags
    changed = False
    changed = clean_tag(mp3, "TIT2") or changed
    changed = clean_tag(mp3, "TALB") or changed
    if artwork_path is not None:
        apic_tags = [tag for tag in current_tags if tag == "APIC" or tag.startswith("APIC:")]
        if len(apic_tags) < 1:
            print("Adding APIC tag to %s..." % mp3_path)
            jpg_data = read_file(artwork_path)
            apic = mutagen.id3.APIC(0, "image/jpeg", 0, "", jpg_data)
            mp3.tags.add(apic)
            changed = True
    if changed and not dry_run:
        sys.stdout.write("Writing %s\n" % mp3_path)
        mp3.save()

def main(argv):
    base_dir = "."
    opts, args = getopt.getopt(argv, 'd:n')
    for opt, val in opts:
        if opt == '-d':
            base_dir = val
        elif opt == '-n':
            global dry_run
            dry_run = True
    if len(args) > 0:
        sys.stderr.write("Usage: %s\n" % (sys.argv[0]))
        return
    walk_tree(base_dir, process_dir)

if __name__ == "__main__":
    main(sys.argv[1:])
