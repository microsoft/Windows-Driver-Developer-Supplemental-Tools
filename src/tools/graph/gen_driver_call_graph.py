# 

try:
    import pandas as pd
    import numpy as np
    import sys
    sys.path.insert(0, 'C:\\Code\\vis-network')
    sys.path.insert(0, 'C:\\Code\\pyvis')

    from pyvis.network import Network
    import graphviz
    import argparse
    import subprocess
    import os
    from enum import Enum
except ImportError as e:
    print("Import error: " + str(e) + "\nPlease install the required modules using pip")
    exit(1)


LEVELS = Enum('LEVELS', ['FILES', 'FUNCTIONS1','FUNCTIONS2' , 'IRPS', 'LIBS', 'DDIS'])

def libs_to_nodes(libs):
    for lib in libs:
        #nodes[lib] = lib
        # net.add_node(lib, label=lib, level=LEVELS.LIBS.value, group='libs', hidden=False)
        for ddi in libs[lib]:
            # if ddi in nodes:
            #     #nodes[ddi] = ddi
            #     # net.add_node(ddi, label=ddi, level=LEVELS.LIBS.value, group='libs', hidden=False)
            #     # net.add_edge(lib, ddi)
            #     links.append((lib,ddi))
            ddi_list.append(ddi)
def get_lib_interface(lib):
    interface = []
    out = subprocess.run(['dumpbin', '/exports', lib], capture_output=True, shell=True)
    for line in out.stdout.decode('utf-8').split('\n'):
        # print(line)
        interface.append(line.strip())
        
    return interface
    
def parse_libs(sln_file, source_root):
    config = "Release"
    platform = "x64"
    lib_list= []
    out = subprocess.run(['msbuild', sln_file, '/t:Rebuild', "-property:Configuration="+config, "-property:Platform="+platform,'/nologo','/v:d'], cwd=source_root, capture_output=True, shell=True)
    for line in out.stdout.decode('utf-8').split('\n'):
        if 'link.exe' in line:
            line = line.split('link.exe')[-1].strip()
            path = ''
            for e in line.split(' '):
                if '/' not in e:
                    path += e + ' '
                if '.lib' in e:
                    path = path.replace('\"', '').strip()
                    if path not in lib_list and path != '':
                        lib_list.append(path)
                    path = ''
    for lib in lib_list:
        l = lib.split('\\')[-1]
        libs[l] = get_lib_interface(lib)
    libs_to_nodes(libs)
    
def codeql_analyze_db(db_path, query):
    print("Analyzing codeql database: ", db_path, " with query: ", query)
    out = subprocess.run(['codeql', 'database', 'analyze', db_path, '--format=dot', query,'--output=graph.dot', '--rerun'],
                        shell=True  ) 
    
def codeql_db_create(sln_file, source_root, output_dir):
    config = "Release"
    platform = "x64"
    print("Creating codeql database for solution file: ", sln_file, " in directory: ", source_root, " with output directory: ", output_dir)
    out = subprocess.run(['codeql', "database", "create", output_dir, "--overwrite", "-l", "cpp", "--source-root="+source_root,
                           "--command=msbuild "+ sln_file+ " -clp:Verbosity=m -t:clean,build -property:Configuration="+config+" -property:Platform="+platform + " -p:TargetVersion=Windows10 -p:SignToolWS=/fdws -p:DriverCFlagAddOn=/wd4996 -noLogo" ], 
                        cwd=source_root,
                        capture_output=True,
                        shell=True  )
            
               
def gen_graph():
    hidden = args.hide_by_default
    # make nodes
    # for lib in libs:
    #     net.add_node(lib, label=lib, level=LEVELS.LIBS.value, group='libs', hidden=False)
     
    for name in nodes:
        node_id = ''
        for id in node_ids:
            if node_ids[id] == name:
                node_id = id
            
        if('.cpp' in name or '.c' in name or '.h' in name):
            hidden= False
            level = LEVELS.FILES
            group = 'files'
        elif 'IRP_' in name:
            level = LEVELS.IRPS
            group = 'irps'
        elif 'file-functions' in node_id:
            level = LEVELS.FUNCTIONS1
            group = 'functions1'
        elif 'file-functions' in node_id:
            level = LEVELS.FUNCTIONS2
            group = 'functions2'
        else:
            level = LEVELS.FUNCTIONS1
            group = 'other'
            
        #check if this function is from a library and add the library node
        for lib in libs:
            val = libs[lib]
            for ddi in val:
                if ddi == name:
                    level = LEVELS.LIBS
                    group = 'libs'
                    #update params for function node
                    group = "ddis"
                    level = LEVELS.DDIS
                    net.add_node(lib+name, label=lib, level=LEVELS.LIBS.value, group='libs', hidden=False)
                    links.append((name,lib+name))
                    print("Adding link: ", name, lib+name)
        net.add_node(name, label=name, level=level.value, group=group, hidden=hidden)      
        
    
    # make edges
    for link in links:
        from_node = link[0]
        to_node = link[1]
        try:
            print(from_node, to_node)
            net.add_edge(from_node,to_node)
        except:
            print("Error adding edge: ", from_node, to_node)
            continue    
                   
def parse_dot(file, query):
    lines = file.readlines()
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
          
            node_ids[e[0].strip()+query] = name
            nodes.append(name)
        elif "->" not in e and "label=" not in e and '=' not in e and 'graph' not in e and '}' not in e and '{' not in e :
            print(e, "empty label")
            node_ids['error_empty_label'] = "ERROR EMPTY LABEL"
            #net.add_node('error_empty_label', "ERROR EMPTY LABEL")
    for e in lines:
        e = e.replace('[', ' ').replace(']', ' ').replace(';', '').replace('\n', '')
        if "->" in e:
            e = e.split("->")
            from_node = node_ids[e[0].strip()+query]
            to_node = node_ids[e[1].strip()+query]
            if (from_node,to_node) not in links:
                links.append((from_node,to_node))
                #net.add_edge(from_node,to_node)
    
    # for node in nodes:
    #     print(node, nodes[node])
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate a call graph of driver functions')
    parser.add_argument('--sln_file', type=str, help='Create a codeql database for the driver given the solution file')
    parser.add_argument('--database_path', type=str, help='Path to the existing codeql database or the path to create a new one')
    parser.add_argument('--source_root', type=str, help='Directory containing the driver solution file')
    parser.add_argument('--skip_codeql', action='store_true', help='Skip codeql database creation and analysis')
    parser.add_argument('--hide_by_default', action='store_true', help='Hide files by default')
    args = parser.parse_args()    
    node_ids = {}
    nodes =[]
    links =[]
    libs = {}
    ddi_list = []
    net = Network(directed=True, filter_menu=True, select_menu=True, notebook=False,neighborhood_highlight=True, height='1500px')
    net.show_buttons(True)    
    net.toggle_physics(True)
    directory = "CallGraphQueries/"
    if not args.skip_codeql:
        if args.sln_file:
            codeql_db_create(args.sln_file, args.source_root, args.database_path)
        for filename in os.listdir(directory):
            if filename.endswith(".ql"):
                file_path = os.path.join(directory, filename)
                codeql_analyze_db(args.database_path, file_path)
                
   
    analyze_output_dir = 'graph.dot\\cpp\\drivers\\'
    for filename in os.listdir(analyze_output_dir):
        if filename.endswith(".dot"):
            file_path = os.path.join(analyze_output_dir, filename)
            file = open(file_path, 'r')
            parse_dot(file, filename.split('.')[0])
    parse_libs(args.sln_file, args.source_root)
    
    gen_graph()
    
    net.show('graph.html', notebook=False)