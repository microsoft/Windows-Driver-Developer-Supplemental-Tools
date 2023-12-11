import os
import sys
import subprocess
import shutil

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
# @REM call :test <DriverName> <DriverTemplate> <DriverType> <DriverDirectory> <UseNTIFS parameter value>
def run_test(arg1, arg2, arg3, arg4, arg5):
    print(arg1, arg2, arg3, arg4, arg5)
    
    if os.path.exists(os.path.join(os.getcwd(), "working/"+arg1+'/').strip()):
        shutil.rmtree(os.path.join(os.getcwd(), "working/"+arg1+'/'))
    shutil.copytree(arg2, ".\\working\\"+arg1)
    
    for file in os.listdir(os.path.join(os.getcwd(),"..\\"+arg3+"\\"+arg4+"\\"+arg1)):
        shutil.copyfile(os.path.join(os.getcwd(),"..\\"+arg3+"\\"+arg4+"\\"+arg1,file), os.path.join(os.getcwd(),"working\\"+arg1+"\\driver\\",file))

    subprocess.run(["msbuild", "/t:rebuild", "/p:platform=x64", "/p:UseNTIFS="+arg5+""],cwd=os.path.join(os.getcwd(),"working\\"+arg1), shell=True) 
    os.makedirs("TestDB", exist_ok=True) 
    subprocess.run(["codeql", "database", "create", "-l", "cpp", "-c", "msbuild /p:Platform=x64;UseNTIFS="+arg5+ " /t:rebuild", "..\\..\\TestDB\\"+arg1],
                    cwd=os.path.join(os.getcwd(),"working\\"+arg1), 
                    shell=True) 

    os.makedirs("AnalysisFiles\Test Samples", exist_ok=True) 
  
    subprocess.run(["codeql", "database", "analyze", "TestDB\\"+arg1, "--format=sarifv2.1.0", "--output=AnalysisFiles\\Test Samples\\"+arg1+".sarif", "..\\"+arg3+"\\"+arg4+"\\"+arg1+"\*.ql" ], 
                    shell=True) 
    subprocess.run(["sarif", "diff", "-o", "diff\\"+arg1+".sarif", "..\\"+arg3+"\\"+arg4+"\\"+arg1+"\\"+arg1+".sarif", "AnalysisFiles\Test Samples\\"+arg1+".sarif"], 
                    shell=True)
    # sarif diff -o "diff\"+arg1+".sarif" "..\"+arg2+"\"+arg2+"\"+arg1+"\"+arg1+".sarif" "AnalysisFiles\Test Samples\"+arg1+".sarif"

def run_tests(ql_files):
    for query in ql_files:

        path = os.path.normpath(query)
        path = path.split(os.sep)

        ql_file = path[-1]
        ql_name = path[-2]
        di = path.index("drivers")
        ql_type = path[di+1]
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

        #TODO UseNTIFS parameter value
        # subprocess.run(["build_create_analyze_test.cmd", ql_name, template, ql_type,ql_location, "0"]) 
        run_test(ql_name, template, ql_type,ql_location, "0")
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
        run_tests(ql_files)
  

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