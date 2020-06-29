#!/usr/bin/python
# Python 2.7.12

# Matthew Wyczalkowski
# m.wyczalkowski@wustl.edu
# Washington University School of Medicine

from __future__ import print_function
import sys

def eprint(*args, **kwargs):
# Portable printing to stderr, from https://stackoverflow.com/questions/5574702/how-to-print-to-stderr-in-python-2
    print(*args, file=sys.stderr, **kwargs)

def main():
    import argparse

    usage_text = """
        Read a template file and key/value pairs, evaluate for mandatory keys, 
        and replace keys with values in template file.

        Mandatory keys are defined in template as, "# require_arg:key";
        if key is not specified, quit with error.
        """

    parser = argparse.ArgumentParser(description=usage_text)

    parser.add_argument('kv', metavar='key:value', type=str, nargs='+', help='List of key:value pairs')
    parser.add_argument('-t', '--template', type=str, required=True, help='Template input filename.')
    parser.add_argument('-o', '--output', type=str, default="stdout", help='Output filename. Create output dir if necessary. Default write to stderr')
    parser.add_argument('-d', '--debug', action="store_true", default=False, help='Print debugging information to stderr')
#    parser.add_argument('-w', '--warn', action="store_true", default=False, help='Warn don\'t quit if required argument missing')

    args = parser.parse_args()

    key_vals={}
    # convert kv to key_vals
    for kv in args.kv:
        t = kv.split(':')
        if len(t) != 2:
            eprint("ERROR: bad format of key:value pair %s" % kv)
        key_vals[t[0]] = t[1] 
        if args.debug:
            eprint("Key = %s Value = %s" % (t[0], t[1]))

    if args.output == "stdout":
        o = sys.stdout
        if args.debug:
            eprint("Writing to stdout")
    else:
        o = open(args.output, "w")
        if args.debug:
            eprint("Writing to %s" % args.output)

    with open(args.template) as f:
        for line in f:
            line=line.rstrip()
#            if args.debug:
#                eprint("Processing", line)
            # check to see if this line specifies required tokens
            req_token="require_arg:"
            if req_token in line:
                req_key=line[line.index(req_token)+len(req_token):].strip()
                if args.debug:
                    eprint("Checking for required key %s" % req_key)
                if req_key not in key_vals.keys():
                    eprint("ERROR: required key %s not found" % req_key)
                    sys.exit(1)  # should do an exception, implement --warn
            # this is a regular line.  Replace keys with values                    
            else:
                for k, v in key_vals.iteritems():
                    line = line.replace(k, v)
                o.write(line + "\n")

    o.close()

if __name__ == '__main__':
    main()

