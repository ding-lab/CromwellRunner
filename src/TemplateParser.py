#!/usr/bin/python

# Matthew Wyczalkowski
# m.wyczalkowski@wustl.edu
# Washington University School of Medicine

from __future__ import print_function
import sys

def eprint(*args, **kwargs):
# Portable printing to stderr, from https://stackoverflow.com/questions/5574702/how-to-print-to-stderr-in-python-2
    print(*args, file=sys.stderr, **kwargs)

def check_arg(line, key_vals, arg.warn):
    

def main():
    import argparse

    usage_text = """
        Read a template file and key/value pairs, evaluate for mandatory keys, 
        and replace keys with values in template file.

        Mandatory keys are defined in template as,
            require_arg:key
        If key is not specified, quit with error.
        """

    parser = argparse.ArgumentParser(description=usage_text)

    parser.add_argument('kv', metavar='key:value', type=str, nargs='+', help='List of key:value pairs')
    parser.add_argument('-t', '--template', type=str, required=True, help='Template input filename.')
    parser.add_argument('-o', '--output', type=str, help='Output filename. Create output dir if necessary. Default write to stderr')
    parser.add_argument('-o', '--debug', action="store_true", default=False, help='Print debugging information to stderr')
    parser.add_argument('-w', '--warn', action="store_true", default=False, help='Warn don\'t quit if required argument missing')

    args = parser.parse_args()

    # convert kv to key_vals

    if args.outfn == "stdout":
        o = sys.stdout
    else:
        o = open(argargs.outfn, "w")

    with open(args.template) as f:
        for line in f:
            # check to see if this line specifies required tokens
            req_token="require_arg:"
            if req_token in line:
                req_key=line[line.index(req_token)+len(req_token):]
                if debug:
                    eprint("Checking for required key %s" % req_key)
                if req_key not in key_vals.keys():
                    eprint("ERROR: required key %s not found" % req_key)
                    sys.exit(1)  # should do an exception, implement --warn
            # this is a regular line.  Replace keys with values                    
            else:
                for k, v in key_vals.iteritems():
                    line = line.replace(i, j)
                    o.write(line)

    o.close()

if __name__ == '__main__':
    main()

