#!/usr/bin/python

import argparse
import json
import os.path
import sys

NAGIOS_STATE_OK             = 0
#NAGIOS_STATE_WARNING        = 1
NAGIOS_STATE_CRITICAL       = 2

def main():
    parser = argparse.ArgumentParser(description='Check the output of the image building process')
    parser.add_argument('-c', '--conf-file', dest='conf_file', help='Path to the configuration file', required=True)
    args = parser.parse_args()
    # does the log file exist?
    if not os.path.exists(args.conf_file):
        print("CRITICAL - Check configuration file " + args.conf_file + " does not exist")
        sys.exit(NAGIOS_STATE_CRITICAL)
    NAGIOS_STATE = NAGIOS_STATE_OK
    NAGIOS_OUTPUT = ""
    with open(args.conf_file, "r") as conf_file:
        config = json.load(conf_file)
        for environment in config["environments"]:
            for image in environment["images"]:
                log_file_path = config["base_path"] + "/" + environment["name"] + "/" + image + ".log"
                if not os.path.exists(log_file_path):
                    print("CRITICAL - Log file " + log_file_path + " does not exist")
                    sys.exit(NAGIOS_STATE_CRITICAL)
                with open(log_file_path, "r") as log_file:
                    for line in filter(lambda l : l.startswith("IMGBUILDER_OUTPUT"), log_file):
                        pass
                    # were there any IMGBUILDER_OUTPUT lines?                    
                    try:
                        line
                    except:
                        print("CRITICAL - Log file " + log_file_path + " does not contain any IMGBUILDER_OUTPUT line")
                        sys.exit(NAGIOS_STATE_CRITICAL)
                    # line is the last line filtered out
                    output_str = line.split(" ", 1)[1]
                    # add the outcome to the output message
                    NAGIOS_OUTPUT += output_str
                    # check the outcome
                    if output_str.startswith("FAIL"):
                        NAGIOS_STATE = NAGIOS_STATE_CRITICAL
    print(NAGIOS_OUTPUT)
    sys.exit(NAGIOS_STATE)


if __name__ == "__main__":
    main()
