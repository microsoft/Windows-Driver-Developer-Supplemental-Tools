import os
import sys
import subprocess

def walk_files(directory, extension):
    ql_files = []
    print(directory)
    for root, dirs, files in os.walk(directory):
        if "driver_snippet.c" in files:

            for file in files:
                if file.endswith(extension):
                    ql_files.append(os.path.join(root, file))
    return ql_files

# walk through files in the src directory and look for .ql files

def run_tests(ql_files):
    for query in ql_files:

        path = os.path.normpath(query)
        path = path.split(os.sep)

        ql_file = path[-1]
        ql_name = path[-2]
        di = path.index("drivers")
        ql_type = path[di+1]
        print(ql_file, ql_name, ql_type)
        template = ""
        if(ql_type == "general"):
            template = "WDMTestTemplate"
        elif(ql_type == "wdm"):
            template = "WDMTestTemplate"
        elif(ql_type == "kmdf"):
            template = "KMDFTestTemplate"
        else:
            continue

        ql_location = "/".join(path[path.index(ql_type)+1:path.index(ql_name)])
        print(ql_location)

        #TODO UseNTIFS parameter value
#@REM call :test <DriverName> <DriverTemplate> <DriverType> <DriverDirectory> <UseNTIFS parameter value>
        subprocess.run(["build_create_analyze_test.cmd", ql_name, template, ql_type,ql_location, "0"]) 

def usage():
    print("Usage: python build_create_analyze_test.py [-h] [-i <name>]")
    print("Options:")
    print("-h: help")
    print("-i <name>: run only the tests with <name> in the name")

if __name__ == "__main__":
    subprocess.run(["clean.cmd"]) 
    cwd = os.getcwd()
    path = os.path.normpath(cwd)
    path = path.split(os.sep)
    dir_to_search ="/".join(path[0:path.index("Windows-Driver-Developer-Supplemental-Tools")+1])

    ql_files = walk_files(dir_to_search, ".ql")

    if "-h" in sys.argv:
        usage()
    elif "-i" in sys.argv:
        name = sys.argv[sys.argv.index("-i")+1]
        ql_files = [x for x in ql_files if name in x]
        print(ql_files)
    
    elif len(sys.argv) > 1:
        print("Invalid argument")
        usage()
        exit(1)
    elif len(sys.argv) == 1:
        run_tests(ql_files)
    else:
        print("Invalid argument")
        usage()
        exit(1)