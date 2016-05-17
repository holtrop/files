#!/usr/bin/env python3

import getopt
import glob
import mutagen.id3
import mutagen.mp3
import os
import sys

min_mp3s_for_album = 4

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
    if len(mp3s) < min_mp3s_for_album:
        return
    if len(jpgs) == 0:
        sys.stderr.write("No album artwork found in %s\n" % path)
        return
    if len(jpgs) > 1:
        sys.stderr.write("Multiple album artwork files found in %s\n" % path)
        return
    for mp3 in mp3s:
        add_artwork(mp3, jpgs[0])

def read_file(fname):
    f = open(fname, "rb")
    data = f.read()
    f.close()
    return data

def add_artwork(mp3_path, jpg_path):
    mp3 = mutagen.mp3.MP3(mp3_path)
    current_tags = mp3.tags
    apic_tags = [tag for tag in current_tags if tag == "APIC" or tag.startswith("APIC:")]
    if len(apic_tags) >= 1:
        return
    print("Adding APIC tag to %s..." % mp3_path)
    jpg_data = read_file(jpg_path)
    apic = mutagen.id3.APIC(0, "image/jpeg", 0, "", jpg_data)
    mp3.tags.add(apic)
    mp3.save()

def main(argv):
    base_dir = "."
    opts, args = getopt.getopt(argv, 'd:')
    for opt, val in opts:
        if opt == '-d':
            base_dir = val
    walk_tree(base_dir, process_dir)

if __name__ == "__main__":
    main(sys.argv[1:])
