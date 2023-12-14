import os
import sys
import subprocess
import shutil
import threading
import time

no_output = False
override_template = ""

# Any attributes specific to a test should be added to this class
# This also allows for things to be conditionally added to the test call, such as the UseNTIFS parameter
class ql_test_attributes:
    def __init__(self, use_ntifs=False, template="", path="", ql_file="", ql_name="", ql_type="", ql_location=""):
        self.use_ntifs = use_ntifs
        self.template = template
        self.path = path
        self.ql_file = ql_file
        self.ql_name = ql_name
        self.ql_type = ql_type
        self.ql_location = ql_location

    def get_use_ntifs(self):
        return self.use_ntifs
    def get_template(self):
        return self.template
    def get_path(self):
        return self.path
    def get_ql_file(self):
        return self.ql_file
    def get_ql_name(self):
        return self.ql_name
    def get_ql_type(self):
        return self.ql_type
    def get_ql_location(self):
        return self.ql_location
    
    
def usage():
    print("Usage: python build_create_analyze_test.py [-h] [-i <name>] [-t] [-o]")
    print("Options:")
    print("-h: help")
    print("-i <name>: run only the tests with <name> in the name")
    print("-t: run multithreaded")
    print("-o: output off")

def check_use_ntifs(ds_file):
    file = open(ds_file, "r")
    lines = file.readlines()
    for line in lines:
        if "ntifs.h" in line:
            file.close()
            return True
    file.close()
    return False

# walk through files and look for .ql files
def walk_files(directory, extension):
    ql_files = {}
    print(directory)
    for root, dirs, files in os.walk(directory):
        if "driver_snippet.c" in files:
            use_ntifs = check_use_ntifs(os.path.join(root, "driver_snippet.c"))
            for file in files:
                if file.endswith(extension):
                    ql_obj = ql_test_attributes(use_ntifs)
                    ql_files[os.path.join(root, file)] = ql_obj
    return ql_files

def run_test(ql_test):
    print(ql_test.get_ql_name(), ql_test.get_template(), ql_test.get_ql_type(), ql_test.get_ql_location(), ql_test.get_use_ntifs())
    
    if os.path.exists(os.path.join(os.getcwd(), "working/"+ql_test.get_ql_name()+'/').strip()):
        shutil.rmtree(os.path.join(os.getcwd(), "working/"+ql_test.get_ql_name()+'/'))
    shutil.copytree(ql_test.get_template(), ".\\working\\"+ql_test.get_ql_name())
    
    for file in os.listdir(os.path.join(os.getcwd(),"..\\"+ql_test.get_ql_type()+"\\"+ql_test.get_ql_location()+"\\"+ql_test.get_ql_name())):
        shutil.copyfile(os.path.join(os.getcwd(),"..\\"+ql_test.get_ql_type()+"\\"+ql_test.get_ql_location()+"\\"+ql_test.get_ql_name(),file), os.path.join(os.getcwd(),"working\\"+ql_test.get_ql_name()+"\\driver\\",file))

    out1 = subprocess.run(["msbuild", "/t:rebuild", "/p:platform=x64", "/p:UseNTIFS="+ql_test.get_use_ntifs()+""],cwd=os.path.join(os.getcwd(),"working\\"+ql_test.get_ql_name()), shell=True, capture_output=no_output  ) 
    os.makedirs("TestDB", exist_ok=True) 
    if os.path.exists("TestDB\\"+ql_test.get_ql_name()):
        shutil.rmtree("TestDB\\"+ql_test.get_ql_name())
        
    out2 = subprocess.run(["codeql", "database", "create", "-l", "cpp", "-c", "msbuild /p:Platform=x64;UseNTIFS="+ql_test.get_use_ntifs()+ " /t:rebuild", "..\\..\\TestDB\\"+ql_test.get_ql_name()],
                    cwd=os.path.join(os.getcwd(),"working\\"+ql_test.get_ql_name()), 
                    shell=True, capture_output=no_output  ) 

    if not os.path.exists("AnalysisFiles\Test Samples"):
        os.makedirs("AnalysisFiles\Test Samples", exist_ok=True) 
  
    out3 = subprocess.run(["codeql", "database", "analyze", "TestDB\\"+ql_test.get_ql_name(), "--format=sarifv2.1.0", "--output=AnalysisFiles\\Test Samples\\"+ql_test.get_ql_name()+".sarif", "..\\"+ql_test.get_ql_type()+"\\"+ql_test.get_ql_location()+"\\"+ql_test.get_ql_name()+"\*.ql" ], 
                    shell=True, capture_output=no_output  ) 
    out4 = subprocess.run(["sarif", "diff", "-o", "diff\\"+ql_test.get_ql_name()+".sarif", "..\\"+ql_test.get_ql_type()+"\\"+ql_test.get_ql_location()+"\\"+ql_test.get_ql_name()+"\\"+ql_test.get_ql_name()+".sarif", "AnalysisFiles\Test Samples\\"+ql_test.get_ql_name()+".sarif"], 
                    shell=True, capture_output=no_output  ) 
    
    if(no_output):
        print(out1, out2, out3, out4)

def parse_attributes(query):
    
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
        pass
        
    if override_template:
        template = override_template

    if ql_files[query].get_use_ntifs():
        use_ntifs = "1" 
    else:
        use_ntifs = "0"
    
    ql_location = "/".join(path[path.index(ql_type)+1:path.index(ql_name)])
    return ql_test_attributes(use_ntifs, template, path, ql_file, ql_name, ql_type, ql_location)

def run_tests(ql_files):

    for query_path in ql_files:
        ql_test = parse_attributes(query_path)
        # subprocess.run(["build_create_analyze_test.cmd", ql_name, template, ql_type,ql_location, "0"]) 
        run_test(ql_test)
        
if __name__ == "__main__":
    start_time = time.time()
    subprocess.run(["clean.cmd"]) 
    cwd = os.getcwd()
    path = os.path.normpath(cwd)
    path = path.split(os.sep)
    dir_to_search ="/".join(path[0:path.index("Windows-Driver-Developer-Supplemental-Tools")+1])

    ql_files = walk_files(dir_to_search, ".ql")

    threads = []    
    if "-h" in sys.argv:
        usage()
    else:
        if "-o" in sys.argv:
            no_output = True
        if "--override_template" in sys.argv:
            override_template = sys.argv[sys.argv.index("--override_template")+1]
        if "-i" in sys.argv:
            name = sys.argv[sys.argv.index("-i")+1]
            ql_files_keys = [x for x in ql_files if name in x]

        elif "-t" in sys.argv:
            ql_files_keys = [x for x in ql_files]
        elif len(sys.argv) == 1:
            ql_files_keys = [x for x in ql_files]
        
        ql_files = {x:ql_files[x] for x in ql_files if x in ql_files_keys}

        if "-t" in sys.argv:
            no_output = True
            for q in ql_files:
                single_dict = {q:ql_files[q]}
                threads.append(threading.Thread(target=run_tests, args=((single_dict),), kwargs={}))

        if ql_files == []:
            print("Invalid argument")
            usage()
            exit(1)
        
    if threads:
        print("Running multithreaded")
        print("Live output disabled for multithreaded run")

        for thread in threads:
            print('Start thread ' + thread.name )
            thread.start()
        for thread in threads:
            thread.join()
    else:
        run_tests(ql_files)

    end_time = time.time()
    print("Total run time: " + str(end_time - start_time) + " seconds")