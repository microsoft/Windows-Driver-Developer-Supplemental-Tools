from multiprocessing.pool import ThreadPool
import os
import sys
import subprocess
import shutil
import threading
import time
import os
import sys
import subprocess
import shutil
import threading
import time
from multiprocessing.pool import ThreadPool

no_output = False
override_template = ""

print_mutex = threading.Lock()

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
    def set_use_ntifs(self, use_ntifs):
        self.use_ntifs = use_ntifs

    def get_template(self):
        return self.template
    def set_template(self, template):
        self.template = template

    def get_path(self):
        return self.path
    def set_path(self, path):
        self.path = path

    def get_ql_file(self):
        return self.ql_file
    def set_ql_file(self, ql_file):
        self.ql_file = ql_file

    def get_ql_name(self):
        return self.ql_name
    def set_ql_name(self, ql_name):
        self.ql_name = ql_name

    def get_ql_type(self):
        return self.ql_type
    def set_ql_type(self, ql_type):
        self.ql_type = ql_type

    def get_ql_location(self):
        return self.ql_location
    def set_ql_location(self, ql_location):
        self.ql_location = ql_location
    
def usage():
    print("Usage: python build_create_analyze_test.py [-h] [-i <name>] [-t] [-o]")
    print("Options:")
    print("-h: help")
    print("-i <name>: run only the tests with <name> in the name")
    print("-t <num_threads>: run multithreaded with max <num_threads> threads")
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
    ql_files_map = {}
    # print(directory)
    for root, dirs, files in os.walk(directory):
        if "driver_snippet.c" in files:
            use_ntifs = check_use_ntifs(os.path.join(root, "driver_snippet.c"))
            for file in files:
                if file.endswith(extension):
                    ql_obj = ql_test_attributes(use_ntifs)
                    ql_files_map[os.path.join(root, file)] = ql_obj
    return ql_files_map



# Function to run a test using system calls
def run_test(ql_test):
    # Print test attributes
    print_mutex.acquire()
    print(ql_test.get_ql_name(), "\n",  
          "Template: ", ql_test.get_template(), "\n",  
          "Driver Framework: ", ql_test.get_ql_type(), "\n",  
          "Query location: ", ql_test.get_ql_location(), "\n",  
          "UseNTIFS flag: ", ql_test.get_use_ntifs(),"\n")
    print_mutex.release()
    # Remove existing working directory
    if os.path.exists(os.path.join(os.getcwd(), "working/"+ql_test.get_ql_name()+'/').strip()):
        shutil.rmtree(os.path.join(os.getcwd(), "working/"+ql_test.get_ql_name()+'/'))
    
    # Copy template to working directory
    shutil.copytree(ql_test.get_template(), ".\\working\\"+ql_test.get_ql_name())
    
    # Copy files to driver directory
    for file in os.listdir(os.path.join(os.getcwd(),"..\\"+ql_test.get_ql_type()+"\\"+ql_test.get_ql_location()+"\\"+ql_test.get_ql_name())):
        shutil.copyfile(os.path.join(os.getcwd(),"..\\"+ql_test.get_ql_type()+"\\"+ql_test.get_ql_location()+"\\"+ql_test.get_ql_name(),file), os.path.join(os.getcwd(),"working\\"+ql_test.get_ql_name()+"\\driver\\",file))

    # Rebuild the project using msbuild
    out1 = subprocess.run(["msbuild", "/t:rebuild", "/p:platform=x64", "/p:UseNTIFS="+ql_test.get_use_ntifs()+""],cwd=os.path.join(os.getcwd(),"working\\"+ql_test.get_ql_name()), shell=True, capture_output=no_output  ) 
    
    # Create the CodeQL database
    os.makedirs("TestDB", exist_ok=True) 
    if os.path.exists("TestDB\\"+ql_test.get_ql_name()):
        shutil.rmtree("TestDB\\"+ql_test.get_ql_name())
    out2 = subprocess.run(["codeql", "database", "create", "-l", "cpp", "-c", "msbuild /p:Platform=x64;UseNTIFS="+ql_test.get_use_ntifs()+ " /t:rebuild", "..\\..\\TestDB\\"+ql_test.get_ql_name()],
                    cwd=os.path.join(os.getcwd(),"working\\"+ql_test.get_ql_name()), 
                    shell=True, capture_output=no_output  ) 

    # Analyze the CodeQL database
    if not os.path.exists("AnalysisFiles\Test Samples"):
        os.makedirs("AnalysisFiles\Test Samples", exist_ok=True) 
    out3 = subprocess.run(["codeql", "database", "analyze", "TestDB\\"+ql_test.get_ql_name(), "--format=sarifv2.1.0", "--output=AnalysisFiles\\Test Samples\\"+ql_test.get_ql_name()+".sarif", "..\\"+ql_test.get_ql_type()+"\\"+ql_test.get_ql_location()+"\\"+ql_test.get_ql_name()+"\*.ql" ], 
                    shell=True, capture_output=no_output  ) 
    
    # Perform SARIF diff
    out4 = subprocess.run(["sarif", "diff", "-o", "diff\\"+ql_test.get_ql_name()+".sarif", "..\\"+ql_test.get_ql_type()+"\\"+ql_test.get_ql_location()+"\\"+ql_test.get_ql_name()+"\\"+ql_test.get_ql_name()+".sarif", "AnalysisFiles\Test Samples\\"+ql_test.get_ql_name()+".sarif"], 
                    shell=True, capture_output=no_output  ) 
    
    # Check for errors
    if(no_output):
        print_mutex.acquire()
        if(out1.returncode != 0 or out2.returncode != 0 or out3.returncode != 0 or out4.returncode != 0):
            print("Error in test: " + ql_test.get_ql_name())

            if(out1.returncode != 0):
                print("Error in msbuild: " + ql_test.get_ql_name())
                print(out1.stderr.decode())
            if(out2.returncode != 0):
                print("Error in codeql database create: " + ql_test.get_ql_name())
                print(out2.stderr.decode())
            if(out3.returncode != 0):
                print("Error in codeql database analyze: " + ql_test.get_ql_name())
                print(out3.stderr.decode())
            if(out4.returncode != 0):
                print("Error in sarif diff: " + ql_test.get_ql_name())
                print(out4.stderr.decode())
        else:
            print("Test complete: " + ql_test.get_ql_name())
        print_mutex.release()

def parse_attributes(queries):
    query_objs = []
    for query in queries:
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

        if queries[query].get_use_ntifs():
            use_ntifs = "1" 
        else:
            use_ntifs = "0"
        
        ql_location = "/".join(path[path.index(ql_type)+1:path.index(ql_name)])
        queries[query].set_use_ntifs(use_ntifs)
        queries[query].set_template(template)
        queries[query].set_path(path)
        queries[query].set_ql_file(ql_file)
        queries[query].set_ql_name(ql_name)
        queries[query].set_ql_type(ql_type)
        queries[query].set_ql_location(ql_location)
        query_objs.append(queries[query])
    return query_objs

def run_tests(ql_tests_dict):
    ql_tests_with_attributes = parse_attributes(ql_tests_dict)
    for ql_test in ql_tests_with_attributes:
        run_test(ql_test)
        
if __name__ == "__main__":
    start_time = time.time()
    subprocess.run(["clean.cmd"]) 
    cwd = os.getcwd()
    path = os.path.normpath(cwd)
    path = path.split(os.sep)
    dir_to_search ="/".join(path[0:path.index("Windows-Driver-Developer-Supplemental-Tools")+1])

    ql_tests = walk_files(dir_to_search, ".ql")

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
            ql_files_keys = [x for x in ql_tests if name in x]

        elif "-t" in sys.argv:
            ql_files_keys = [x for x in ql_tests]
        elif len(sys.argv) == 1:
            ql_files_keys = [x for x in ql_tests]
        
        ql_tests = {x:ql_tests[x] for x in ql_tests if x in ql_files_keys}

        if "-t" in sys.argv:
            num_threads = int(sys.argv[sys.argv.index("-t")+1])
            print("Running multithreaded")
            print("Live output disabled for multithreaded run")
            print("\n\n\n !!! MULTITHREADED MODE IS NOT FULLY TESTED DO NOT USE FOR OFFICIAL TESTS !!! \n\n\n")
            no_output = True
            thread_count = 0
            for q in ql_tests:
                single_dict = {q:ql_tests[q]}
                threads.append(single_dict)
            pool = ThreadPool(processes=num_threads)
            for result in pool.map(run_tests, threads):
                print(result)
        if ql_tests == []:
            print("Invalid argument")
            usage()
            exit(1)
    
    if threads:
       pass
    else:
        run_tests(ql_tests)

    end_time = time.time()
    print("Total run time: " + str(end_time - start_time) + " seconds")