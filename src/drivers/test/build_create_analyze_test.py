try:
    from multiprocessing.pool import ThreadPool
    import os
    import sys
    import subprocess
    import shutil
    import threading
    import time
    import fnmatch
    from sarif import loader 
    import pandas as pd
    from datetime import datetime
    import re
    import itertools
    from itertools import permutations
    import openpyxl # Not directly used but this will make sure it is installed
except ImportError as e:
    print("Import error: " + str(e) + "\nPlease install the required modules using pip install -r requirements.txt")
    exit(1)


print_mutex = threading.Lock()

result_df = pd.DataFrame(columns=["Test Name", "Template", "Driver Framework", "UseNTIFS flag", "Errors", "Warnings", "Notes", "Detailed Results"])

def usage():
    print("Usage: python build_create_analyze_test.py [-h] [-i <name>] [-t] [-o]")
    print("Options:")
    print("-h: help")
    print("-i <name>: run only the tests with <name> in the name")
    print("-t <num_threads>: run multithreaded with max <num_threads> threads")
    print("-o: output off")
    print("--override_template <template>: override the template used for the test")
    print("--use_codeql_repo <path>: use the codeql repo at <path> for the test instead of qlpack installed with CodeQL Package Manager")
    print("--database <path>: Run all queries using the database at <path>")
    print("--no_clean: Do not clean the working directory before running the tests")


# Any attributes specific to a test should be added to this class
# This also allows for things to be conditionally added to the test call, such as the UseNTIFS parameter
class ql_test_attributes:
    """
    Represents the attributes for a CodeQL test.

    Attributes:
        use_cpp (bool): Indicates whether to use C++ for the test.
        use_ntifs (bool): Indicates whether to use NTIFS for the test.
        template (str): The template for the test.
        path (str): The path for the test.
        ql_file (str): The CodeQL file for the test.
        ql_name (str): The name of the CodeQL test.
        ql_type (str): The type of the CodeQL test.
        ql_location (str): The location of the CodeQL test.
        no_attributes (bool): Indicates whether the test has attributes. External drivers do not have attributes.
    """

    def __init__(self, external_drivers=[], no_attributes=False, use_cpp=False, use_ntifs=False, template="", path="", ql_file="", ql_name="", ql_type="", ql_location=""):
        self.use_ntifs = use_ntifs
        self.template = template
        self.path = path
        self.ql_file = ql_file
        self.ql_name = ql_name
        self.ql_type = ql_type
        self.ql_location = ql_location
        self.use_cpp = use_cpp
        self.no_attributes = no_attributes
    def get_use_cpp(self):
        return self.use_cpp

    def set_use_cpp(self, use_cpp):
        self.use_cpp = use_cpp

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
    
    def get_no_attributes(self):
        return self.no_attributes
    
    def set_no_attributes(self, no_attributes):
        self.no_attributes = no_attributes

    def get_external_drivers(self):
        return self.external_drivers

    def set_external_drivers(self, external_drivers):
        self.external_drivers = external_drivers
    


def get_git_root():
    """
    Returns the root directory of the Git repository.

    Returns:
        str: The root directory of the Git repository.
    """
    git_root = subprocess.Popen(['git', 'rev-parse', '--show-toplevel'], stdout=subprocess.PIPE).communicate()[0].rstrip().decode('utf-8')
    git_root = git_root.split('/')[-1]
    return git_root

def check_use_ntifs(ds_file):
    """
    Check if the given ds_file uses the ntifs.h header file.

    Args:
        ds_file (str): The path to the file to be checked.

    Returns:
        bool: True if the ntifs.h header file is found, False otherwise.
    """
    file = open(ds_file, "r")
    lines = file.readlines()
    for line in lines:
        if "ntifs.h" in line:
            file.close()
            return True
    file.close()
    return False

def find_ql_test_paths(directory, extension):
    """
    Walks through the specified directory and returns a dictionary mapping file paths to QL test attributes.

    Args:
        directory (str): The directory to walk through.
        extension (str): The file extension to filter files by.

    Returns:
        dict: A dictionary mapping file paths to QL test attributes.
    """
    
    ql_files_map = {}
    for root, dirs, files in os.walk(directory):
        if fnmatch.filter(files, "driver_snippet.*"):
            use_ntifs = check_use_ntifs(os.path.join(root, fnmatch.filter(files, "driver_snippet.*")[0]))
            for file in files:
                if file.endswith(extension):
                    use_cpp = all([".cpp" in x for x in fnmatch.filter(files, "driver_snippet.c*")] or 
                                    [".hpp" in x for x in fnmatch.filter(files, "driver_snippet.c*")])
                   
                    ql_obj = ql_test_attributes(use_ntifs)
                    ql_obj.set_use_cpp(use_cpp)
                    ql_files_map[os.path.join(root, file)] = ql_obj

    return ql_files_map


def find_project_configs(sln_file):
    configs = [(),]
    with open(sln_file, "r") as file:
        content = file.read()
        match = re.search(r"\s*GlobalSection\(SolutionConfigurationPlatforms\).*", content)
        if match:
            lines = content[match.end():]
            end_index = lines.find("EndGlobalSection")
            if end_index != -1:
                lines = lines[:end_index]
                lines = lines.split("\n")
                lines = [x for x in lines if x.strip() != ""]
                print(lines)
                for l in lines:
                    print(l)
                    print(l.split("=")[0].strip().split('|'))
                    print()
                    config = l.split("=")[0].strip().replace(" ", "").replace("\n", "").replace("\t", "").split('|')[0]
                    platform = l.split("=")[0].strip().replace(" ", "").replace("\n", "").replace("\t", "").split('|')[1]
                    configs.append((config,platform))
            else:
                print("No configurations or platforms foundfor " + sln_file)
                return None
        else:
            print("No configurations or platforms foundfor " + sln_file)
            return None
        
    #todo return SET
    return list(set(configs))

                
def test_setup_external_drivers(sln_files):
    # Rebuild the project using msbuild
    out1=[]
    for sln_file in sln_files:
        print("Building: " + sln_file)
        workdir = sln_file.split("\\")[:-1]
        workdir = "\\".join(workdir)
        # out = subprocess.run(["msbuild", "/t:rebuild", "/p:platform=x64"],cwd=workdir, shell=True, capture_output=no_output) 
        # TODO get actual configuration and platform from sln file
        
        configs = find_project_configs(sln_file)
      
        print("Building: " + sln_file + " " + configs[0] + " " + configs[1])
        out = subprocess.run(["msbuild", sln_file, "-clp:Verbosity=m", "-t:clean,build", "-property:Configuration="+config,  "-property:Platform="+platform, "-p:TargetVersion=Windows10",  
                    "-p:SignToolWS=/fdws", "-p:DriverCFlagAddOn=/wd4996", "-noLogo"], shell=True, capture_output=no_output)
        if not no_output and out.returncode != 0:
            print("Error in msbuild: " + ql_test.get_ql_name())
        out1.append(out)

        out = subprocess.run(["msbuild", sln_file, "-clp:Verbosity=m", "-t:clean,build", "-property:Configuration=Debug",  "-property:Platform=x64", "-p:TargetVersion=Windows10",  
                        "-p:SignToolWS=/fdws", "-p:DriverCFlagAddOn=/wd4996", "-noLogo"], shell=True, capture_output=no_output)
        if not no_output and out.returncode != 0:
            print("Error in msbuild: " + ql_test.get_ql_name())
        out1.append(out)

def test_setup(ql_test):
    """
    Set up the test environment for CodeQL analysis.

    Args:
        ql_test (object): An instance of the QLTest class.

    Returns:
        object: The result of the msbuild command.

    Raises:
        None

    """
    
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
    if not no_output and out1.returncode != 0:
        print("Error in msbuild: " + ql_test.get_ql_name())
        return None

    return out1


  
def db_create_for_external_driver(sln_files):
    out2 = []
    
    for sln_file in sln_files:
        workdir = sln_file.split("\\")[:-1]
        workdir = "\\".join(workdir)
        db_loc = workdir + sln_file.split("\\")[-1].replace(".sln", "")
        
        out = subprocess.run(["codeql", "database", "create", "-l", "cpp", "-c", "msbuild /p:Platform=x64" + " /t:rebuild", db_loc],
                cwd=workdir, 
                shell=True, capture_output=no_output  ) 
        out2.append(out)
    return out2
def create_codeql_database(ql_test):
    """
    Create a CodeQL database for the given ql_test.

    Args:
        ql_test (object): The ql_test object containing the necessary information.

    Returns:
        object: The output of the database creation process.

    Raises:
        None

    """
    # Create the CodeQL database
    os.makedirs("TestDB", exist_ok=True) 
    if os.path.exists("TestDB\\"+ql_test.get_ql_name()):
        shutil.rmtree("TestDB\\"+ql_test.get_ql_name())
    out2 = subprocess.run(["codeql", "database", "create", "-l", "cpp", "-c", "msbuild /p:Platform=x64;UseNTIFS="+ql_test.get_use_ntifs()+ " /t:rebuild", "..\\..\\TestDB\\"+ql_test.get_ql_name()],
            cwd=os.path.join(os.getcwd(),"working\\"+ql_test.get_ql_name()), 
            shell=True, capture_output=no_output  ) 
    
    if not no_output and out2.returncode != 0:
        print("Error in codeql database create: " + ql_test.get_ql_name())
        return None
    return out2

def analyze_codeql_database(ql_test):
    """
    Analyzes the CodeQL database.

    Args:
        ql_test (object): The CodeQL test object.

    Returns:
        object: The result of the analysis.

    Raises:
        None

    """
    # Analyze the CodeQL database
    if not os.path.exists("AnalysisFiles\Test Samples"):
        os.makedirs("AnalysisFiles\Test Samples", exist_ok=True) 
    
    if existing_database:
        database_loc = existing_database_path
    else:
        database_loc = "TestDB\\"+ql_test.get_ql_name()

    if use_codeql_repo:
        out3 = subprocess.run(["codeql", "database", "analyze", database_loc, "--format=sarifv2.1.0", "--output=AnalysisFiles\\Test Samples\\"+ql_test.get_ql_name()+".sarif", "..\\"+ql_test.get_ql_type()+"\\"+ql_test.get_ql_location()+"\\"+ql_test.get_ql_name()+"\*.ql", "--additional-packs", codeql_repo_path], 
                    shell=True, capture_output=no_output  ) 
    else:
        out3 = subprocess.run(["codeql", "database", "analyze", database_loc, "--format=sarifv2.1.0", "--output=AnalysisFiles\\Test Samples\\"+ql_test.get_ql_name()+".sarif", "..\\"+ql_test.get_ql_type()+"\\"+ql_test.get_ql_location()+"\\"+ql_test.get_ql_name()+"\*.ql" ], 
                    shell=True, capture_output=no_output  ) 
        
    if not no_output and out3.returncode != 0:
        print("Error in codeql database analyze: " + ql_test.get_ql_name())
        return None
    return out3


def sarif_diff(ql_test):
    """
    Perform SARIF diff between the generated SARIF file and the reference SARIF file.

    Args:
        ql_test: An instance of the QLTest class representing the test case.

    Returns:
        The output of the SARIF diff command if successful, None otherwise.
    """
    out4 = subprocess.run(["sarif", "diff", "-o", "diff\\"+ql_test.get_ql_name()+".sarif", "..\\"+ql_test.get_ql_type()+"\\"+ql_test.get_ql_location()+"\\"+ql_test.get_ql_name()+"\\"+ql_test.get_ql_name()+".sarif", "AnalysisFiles\Test Samples\\"+ql_test.get_ql_name()+".sarif"], 
                    shell=True, capture_output=no_output  ) 
    if not no_output and out4.returncode != 0:
        print("Error in sarif diff: " + ql_test.get_ql_name())
        return None
    return out4

def sarif_results(ql_test):
    """
    Retrieves SARIF results for a given QL test.

    Args:
        ql_test (QLTest): The QL test object.

    Returns:
        None
    """
    sarif_file = os.getcwd()+ "\\AnalysisFiles\\Test Samples\\"+ql_test.get_ql_name()+".sarif"
    sarif_data = loader.load_sarif_file(sarif_file)
    issue_count_by_sev = sarif_data.get_result_count_by_severity()

    result_df.loc[len(result_df)] = [ql_test.get_ql_name(), ql_test.get_template(), ql_test.get_ql_type(), ql_test.get_use_ntifs(), issue_count_by_sev["error"], issue_count_by_sev["warning"], issue_count_by_sev["note"], sarif_data.get_records()]
    
    print(result_df)


def format_excel_results():
    """
    Formats the results Excel file.

    Args:
        None

    Returns:
        None
    """
    # TODO 
    pass

def run_test(ql_test):
    """
    Run a test for the given ql_test object.

    Args:
        ql_test: The ql_test object representing the test to be run.

    Returns:
        None
    """

    # Print test attributes
    print_mutex.acquire()
    print(ql_test.get_ql_name(), "\n",  
          "Template: ", ql_test.get_template(), "\n",  
          "Driver Framework: ", ql_test.get_ql_type(), "\n",  
          "Query location: ", ql_test.get_ql_location(), "\n",  
          "UseNTIFS flag: ", ql_test.get_use_ntifs(),"\n")
    print_mutex.release()

    
    if not existing_database and not external_drivers:
        test_setup_result = test_setup(ql_test)
        if test_setup_result is None:
            return 
        create_codeql_database_result = create_codeql_database(ql_test)
        if create_codeql_database_result is None:
            return 
    
    global external_driver_setup_done
    global external_driver_database_created

    # Only need to setup external drivers once
    if external_drivers:
        if not external_driver_setup_done:
            test_setup_result = test_setup_external_drivers(driver_sln_files)
            external_driver_setup_done = True
            if test_setup_result is None:
                return 
    # Only need to create the database for external drivers once
        if not external_driver_database_created:
            create_codeql_database_result = db_create_for_external_driver(driver_sln_files)
            external_driver_database_created = True
            if create_codeql_database_result is None:
                return 

    analyze_codeql_database_result = analyze_codeql_database(ql_test)
    if analyze_codeql_database_result is None:
        return

    if not existing_database:   
        sarif_diff_result = sarif_diff(ql_test)
        if sarif_diff_result is None: 
            return
    
    # TODO 
    sarif_results(ql_test)

    # Check for errors
    if no_output and not existing_database:
        print_mutex.acquire()
        if (test_setup_result.returncode != 0 or create_codeql_database_result.returncode != 0 or
            analyze_codeql_database_result.returncode != 0 or sarif_diff_result.returncode != 0):
            print("Error in test: " + ql_test.get_ql_name())

            if test_setup_result.returncode != 0:
                print("Error in msbuild: " + ql_test.get_ql_name())
                print(test_setup_result.stderr.decode())
            if create_codeql_database_result.returncode != 0:
                print("Error in codeql database create: " + ql_test.get_ql_name())
                print(create_codeql_database_result.stderr.decode())
            if analyze_codeql_database_result.returncode != 0:
                print("Error in codeql database analyze: " + ql_test.get_ql_name())
                print(analyze_codeql_database_result.stderr.decode())
            if sarif_diff_result.returncode != 0:
                print("Error in sarif diff: " + ql_test.get_ql_name())
                print(sarif_diff_result.stderr.decode())
        else:
            print("Test complete: " + ql_test.get_ql_name())
        print_mutex.release()
    else:
        if analyze_codeql_database_result.returncode != 0:
            print("Error in codeql database analyze: " + ql_test.get_ql_name())
            print(analyze_codeql_database_result.stderr.decode())

def run_test_external_drivers(ql_test):
    pass

def parse_attributes(queries):
    """
    Parses the attributes of the queries and returns a list of query objects.

    Args:
        queries (dict): A dictionary containing the queries.

    Returns:
        list: A list of query objects.

    """
    query_objs = []
    for query in queries:
        path = os.path.normpath(query)
        path = path.split(os.sep)
        ql_file = path[-1]
        ql_name = path[-2]
        di = path.index("drivers")
        ql_type = path[di+1]
        template = ""
        if queries[query].get_use_cpp():
            template = "CppKMDFTestTemplate"
        elif(ql_type == "general"):
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
    """
    Run the given CodeQL tests.

    Args:
        ql_tests_dict (dict): A dictionary containing the CodeQL tests.

    Returns:
        None
    """

    ql_tests_with_attributes = parse_attributes(ql_tests_dict)

  
    for ql_test in ql_tests_with_attributes:
        run_test(ql_test)
    
    format_excel_results()
    with pd.ExcelWriter("results" + str(datetime.now()).replace(" ", "-").replace(":", "-").replace(".", "-") + ".xlsx") as writer:
        result_df.to_excel(writer)  

def find_sln_file(path):
    """
    Finds the solution file for the project.

    Args:
        None

    Returns:
        str: The path to the solution file.
    """
    sln_paths = []
    for root, dirs, files in os.walk(path):
        for file in files:
            if file.endswith(".sln"):
                sln_paths.append(os.path.join(root, file))
    return list(set(sln_paths))


if __name__ == "__main__":
    # Sys input flags
    if "-h" in sys.argv:
        usage()
        exit(0)

    no_output = False
    override_template = ""
    name = ""
    use_codeql_repo = False
    codeql_repo_path = ""
    existing_database_path = ""
    existing_database = False
    external_drivers_path = ""
    external_drivers = False
    external_driver_database_created = False
    external_driver_setup_done = False

    start_time = time.time()

    if not "--no_clean" in sys.argv:
        if os.path.exists("TestDB"):
            shutil.rmtree("TestDB")
        if os.path.exists("working"):
            shutil.rmtree("working")
        if os.path.exists("AnalysisFiles"):
            shutil.rmtree("AnalysisFiles")

    cwd = os.getcwd()
    path = os.path.normpath(cwd)
    path = path.split(os.sep)
    root_dir = get_git_root()
    
    dir_to_search ="/".join(path[0:path.index(root_dir)+1])
    extension_to_search = ".ql"
    ql_tests = find_ql_test_paths(dir_to_search,extension_to_search)

    driver_sln_files = []
    if "--external_drivers" in sys.argv:
        external_drivers_path = sys.argv[sys.argv.index("--external_drivers")+1]
        external_drivers = True
        dir_to_search = external_drivers_path
        extension_to_search = ".sln"
        driver_sln_files = find_sln_file(dir_to_search)
        print("Found " + str(len(driver_sln_files)) + " drivers")
        for ql_file in ql_tests:
            ql_tests[ql_file].set_external_drivers(driver_sln_files)
    
   
    threads = []    
   
    if "-o" in sys.argv:
        no_output = True
    if "--override_template" in sys.argv:
        override_template = sys.argv[sys.argv.index("--override_template")+1]
    if "--use_codeql_repo" in sys.argv:
        use_codeql_repo = True
        codeql_repo_path = sys.argv[sys.argv.index("--use_codeql_repo")+1]
    if "--database" in sys.argv:
        existing_database_path = sys.argv[sys.argv.index("--database")+1]
        existing_database = True
        if not os.path.exists(existing_database):
            print("Database path does not exist")
            exit(1)
        # TODO doesn't work with --external_drivers

    if "-i" in sys.argv:
        name = sys.argv[sys.argv.index("-i")+1]
        ql_files_keys = [x for x in ql_tests if name in x]
        # TODO doesn't work with --external_drivers
    elif "-t" in sys.argv:
        ql_files_keys = [x for x in ql_tests]
    elif len(sys.argv) == 1:
        ql_files_keys = [x for x in ql_tests]
    else:
        ql_files_keys = [x for x in ql_tests]
   
    # TODO 

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