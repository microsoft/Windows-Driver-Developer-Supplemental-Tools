import os
import sys
import subprocess
import shutil
import threading
import time

no_output = False
override_template = ""
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

    out1 = subprocess.run(["msbuild", "/t:rebuild", "/p:platform=x64", "/p:UseNTIFS="+arg5+""],cwd=os.path.join(os.getcwd(),"working\\"+arg1), shell=True, capture_output=no_output  ) 
    os.makedirs("TestDB", exist_ok=True) 
    if os.path.exists("TestDB\\"+arg1):
        shutil.rmtree("TestDB\\"+arg1)
        
    out2 = subprocess.run(["codeql", "database", "create", "-l", "cpp", "-c", "msbuild /p:Platform=x64;UseNTIFS="+arg5+ " /t:rebuild", "..\\..\\TestDB\\"+arg1],
                    cwd=os.path.join(os.getcwd(),"working\\"+arg1), 
                    shell=True, capture_output=no_output  ) 

    if not os.path.exists("AnalysisFiles\Test Samples"):
        os.makedirs("AnalysisFiles\Test Samples", exist_ok=True) 
  
    out3 = subprocess.run(["codeql", "database", "analyze", "TestDB\\"+arg1, "--format=sarifv2.1.0", "--output=AnalysisFiles\\Test Samples\\"+arg1+".sarif", "..\\"+arg3+"\\"+arg4+"\\"+arg1+"\*.ql" ], 
                    shell=True, capture_output=no_output  ) 
    out4 = subprocess.run(["sarif", "diff", "-o", "diff\\"+arg1+".sarif", "..\\"+arg3+"\\"+arg4+"\\"+arg1+"\\"+arg1+".sarif", "AnalysisFiles\Test Samples\\"+arg1+".sarif"], 
                    shell=True, capture_output=no_output  ) 
    
    print(out1, out2, out3, out4)

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
            
        if override_template:
            template = override_template

        ql_location = "/".join(path[path.index(ql_type)+1:path.index(ql_name)])

        #TODO UseNTIFS parameter value
        # subprocess.run(["build_create_analyze_test.cmd", ql_name, template, ql_type,ql_location, "0"]) 
        run_test(ql_name, template, ql_type,ql_location, "0")
def usage():
    print("Usage: python build_create_analyze_test.py [-h] [-i <name>] [-t] [-o]")
    print("Options:")
    print("-h: help")
    print("-i <name>: run only the tests with <name> in the name")
    print("-t: run multithreaded")
    print("-o: output off")
if __name__ == "__main__":
    start_time = time.time()
    subprocess.run(["clean.cmd"]) 
    cwd = os.getcwd()
    path = os.path.normpath(cwd)
    path = path.split(os.sep)
    dir_to_search ="/".join(path[0:path.index("Windows-Driver-Developer-Supplemental-Tools")+1])

    ql_files = walk_files(dir_to_search, ".ql")
    
    threads = False    
    if "-h" in sys.argv:
        usage()
    else:
        if "-o" in sys.argv:
            no_output = True
        if "--override_template" in sys.argv:
            override_template = sys.argv[sys.argv.index("--override_template")+1]
        if "-i" in sys.argv:
            name = sys.argv[sys.argv.index("-i")+1]
            ql_files_final = [x for x in ql_files if name in x]
        elif "-t" in sys.argv:
            ql_files_final = ql_files
        elif len(sys.argv) == 1:
            ql_files_final = ql_files
       
        if "-t" in sys.argv:
            threads = [threading.Thread(target=run_tests, args=([q],), kwargs={}) for q in ql_files_final]

        if ql_files_final == []:
            print("Invalid argument")
            usage()
            exit(1)
        
    if threads:
        for thread in threads:
            print('Start thread ' + thread.name )
            thread.start()
        for thread in threads:
            thread.join()
        
    else:
        run_tests(ql_files_final)
    end_time = time.time()
    print("Total run time: " + str(end_time - start_time) + " seconds")