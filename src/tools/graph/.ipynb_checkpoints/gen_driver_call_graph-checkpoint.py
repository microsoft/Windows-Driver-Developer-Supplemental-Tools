# 

try:
    import pandas as pd
    import numpy as np
    import sys
    from pyvis.network import Network
    import graphviz
    import argparse
    import subprocess
    import os
    
except ImportError as e:
    print("Import error: " + str(e) + "\nPlease install the required modules using pip")
    exit(1)
    
def codeql_analyze_db(db_path, query):
    out = subprocess.run(['codeql', 'database', 'analyze', db_path, '--format=dot', query,'--output=graph.dot', '--rerun'],
                        shell=True  ) 
    
def codeql_db_create(sln_file, path):
    config = "Release"
    platform = "x64"
    out = subprocess.run(['codeql', "database", "create", "./", "--overwrite", "-l", "cpp", "--source-root="+path,
                           "--command=msbuild "+ sln_file+ " -clp:Verbosity=m -t:clean,build -property:Configuration="+config+" -property:Platform="+platform + " -p:TargetVersion=Windows10 -p:SignToolWS=/fdws -p:DriverCFlagAddOn=/wd4996 -noLogo" ], 
            cwd=path, 
            shell=True  )
def gen_graph(file, query):
    lines = file.readlines()
    id = 0
    for e in lines:
        e = e.replace(' ', '') # replace spaces for file paths
        e = e.replace('declarationof','')
        e = e.replace('definitionof','')
        e = e.replace('[', ' ').replace(']', ' ').replace(';', '').replace('\n', '').replace('\"', '')
        if "label=" in e and not '->' in e:
            e = e.replace('label=', '')
            e = e.split()
            e[1] = e[1].split('/')[-1]
            name = e[1].strip()
            if('.cpp' in name or '.c' in name or '.h' in name):
                level = 1
                group = 'files'
            elif 'irps' in query:
                level = 3
                group = 'irps'
            else:
                level = 2
                group = 'functions'
            net.add_node(name, label=name, level=level, group=group)
            nodes[e[0].strip()+query] = name
        elif "->" not in e and "label=" not in e and '=' not in e and 'graph' not in e and '}' not in e and '{' not in e :
            print(e, "empty label")
            nodes['error_empty_label'] = "ERROR EMPTY LABEL"
            net.add_node('error_empty_label', "ERROR EMPTY LABEL")
        id += 1
    for e in lines:
        e = e.replace('[', ' ').replace(']', ' ').replace(';', '').replace('\n', '')
        if "->" in e:
            e = e.split("->")
            from_node = nodes[e[1].strip()+query]
            to_node = nodes[e[0].strip()+query]
            
            if (from_node,to_node) not in links:
                links.append((from_node,to_node))
                net.add_edge(from_node,to_node)
    
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate a call graph of driver functions')
    parser.add_argument('--create_codeql_db', type=str, help='Create a codeql database for the driver given the solution file')
    parser.add_argument('--database_path', type=str, help='Path to the codeql database')
    parser.add_argument('--source_root', type=str, help='Directory containing the driver solution file')
    parser.add_argument('--skip_codeql', action='store_true', help='Skip codeql database creation and analysis')
    args = parser.parse_args()    

    net = Network(directed=True, filter_menu=True, notebook=False,neighborhood_highlight=True, height='1500px')
    net.show_buttons(True)    
    
    if args.create_codeql_db:
        codeql_db_create(args.create_codeql_db, args.source_root)
    
    directory = "CallGraphQueries/"
    if not args.skip_codeql:
        for filename in os.listdir(directory):
            if filename.endswith(".ql"):
                file_path = os.path.join(directory, filename)
                codeql_analyze_db(args.database_path, file_path)
                
    nodes ={}
    links =[]
    analyze_output_dir = 'graph.dot\\cpp\\drivers\\'
    for filename in os.listdir(analyze_output_dir):
        if filename.endswith(".dot"):
            file_path = os.path.join(analyze_output_dir, filename)
            file = open(file_path, 'r')
            gen_graph(file, filename.split('.')[0])
    
    net.show('graph.html', notebook=False)