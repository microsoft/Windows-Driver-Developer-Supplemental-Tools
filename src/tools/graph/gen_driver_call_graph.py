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

entry_points = {'FxDriverEntry':'KMDF', 'GsDriverEntry': 'WDM', '_DllMainCRTStartup':'dll' }


LEVELS = Enum('LEVELS', ['DRIVER_ENTRY','FILES', 'DRIVER_FUNCTIONS','WDK_FUNCTIONS' , 'IRPS', 'LIBS', 'DDIS'])

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
    
def find_entry(source_root):
    #this should run after parse_libs so that msbuild has run 
    for root, dirs, files in os.walk(source_root):
        for file in files:
            if file == 'link.command.1.tlog':
            # print('->', file)
                file_path = os.path.join(root, file)
            # print(file_path)
                with open(file_path, 'r', encoding='UTF-16') as f:
                    lines = f.readlines()
                    #print(lines)
                    for line in lines:
                        #print(line)
                        if '/ENTRY' in line:

                            #print(file_path, line)
                            c = line.split()
                            for i in range(len(c)):
                                if '/entry' in c[i].lower():
                                    return c[i].split(':')[-1]
    return None
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
            
        
# def sort_functions():
#     wdk_functions = []
#     driver_functions = []
#     other = []
#     for name in nodes:        
#         ids = []
#         for id in node_ids:
#             if node_ids[id] == name:
#                 ids.append(id)
#         for id in ids:    
#             if 'file-functions-driver' in id:
#                 if name not in driver_functions:
#                     driver_functions.append(name)
#             elif 'file-functions-all' in id:
#                 if name not in wdk_functions:
#                     wdk_functions.append(name)  
#             elif 'call-graph-all' in id:
#                 continue
#             elif 'call-graph-driver' in id:
#                 continue
#             else:
#               if name not in other:
#                     other.append(name)
#     return wdk_functions, driver_functions, other
               
def gen_graph(net, file, nodes, node_ids, links, entry=None):
    hidden = args.hide_by_default
    if entry is not None:
        net.add_node("SYSTEM", label="SYSTEM", level=LEVELS.DRIVER_ENTRY.value, group='entry', hidden=False)
        net.add_node(entry, label=entry, level=LEVELS.DRIVER_ENTRY.value, group='entry', hidden=False)
        net.add_edge("SYSTEM", entry)
    for name in nodes:
        ids = []
        for id in node_ids:
            if node_ids[id] == name:
                ids.append(id)
        for lib in libs:
            val = libs[lib]
            for ddi in val:
                if ddi == name:
                    #update params for function node
                    net.add_node(lib, label=lib, level=LEVELS.LIBS.value, group='libs', hidden=False)
                    net.add_node(name, label=name, level=LEVELS.DDIS.value, group='ddis', hidden=hidden)      
                    links.append((name,lib))
                    

        if '.cpp' in name or '.c' in name or '.h' in name or '.hpp' in name:
            hidden= False
            level = LEVELS.FILES
            group = 'files'
            name = name.split('.')[0]
            net.add_node(name, label=name, level=level.value, group=group, hidden=hidden)      
            continue
        elif 'IRP_' in name:
            level = LEVELS.IRPS
            group = 'irps'
            net.add_node(name, label=name, level=level.value, group=group, hidden=hidden)      
            continue
        else:
            level = LEVELS.DRIVER_FUNCTIONS
            group = 'driver_functions'
            net.add_node(name, label=name, level=level.value, group=group, hidden=hidden)      
            
    # make edges
    if entry is not None and "DriverEntry" in nodes:
        net.add_edge(entry, "DriverEntry")
    for link in links:
        from_node = link[0]
        to_node = link[1]
        try:
            #if (from_node in ddi_list or from_node in driver_functions) or (to_node in ddi_list or to_node in driver_functions):
            net.add_edge(from_node,to_node)
        except:
            continue 
    
    if len(nodes) > 500:
        net.toggle_physics(False)
    net.show(file+'.html', notebook=False)
        
def parse_dot(file, query):
    node_ids = {}
    nodes =[]
    links =[]
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
            #if '.cpp' in name or '.c' in name or '.h' in name or '.hpp' in name:
          
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
            if '.cpp' in from_node or '.c' in from_node or '.h' in from_node or '.hpp' in from_node:
                from_node = from_node.split('.')[0] 
            if '.cpp' in to_node or '.c' in to_node or '.h' in to_node or '.hpp' in to_node:
                to_node = to_node.split('.')[0]
                
            if (from_node,to_node) not in links:
                links.append((from_node,to_node))
                #net.add_edge(from_node,to_node)
    return nodes, node_ids, links
  
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate a call graph of driver functions')
    parser.add_argument('--sln_file', type=str, help='Create a codeql database for the driver given the solution file')
    parser.add_argument('--database_path', type=str, help='Path to the existing codeql database or the path to create a new one')
    parser.add_argument('--source_root', type=str, help='Directory containing the driver solution file')
    parser.add_argument('--skip_codeql', action='store_true', help='Skip codeql database creation and analysis')
    parser.add_argument('--hide_by_default', action='store_true', help='Hide files by default')
    args = parser.parse_args()    
    
   
    directory = "CallGraphQueries/"
    if not args.skip_codeql:
        if args.sln_file:
            codeql_db_create(args.sln_file, args.source_root, args.database_path)
        for filename in os.listdir(directory):
            if filename.endswith(".ql"):
                file_path = os.path.join(directory, filename)
                codeql_analyze_db(args.database_path, file_path)
                
    networks = []
   
    libs = {}
    ddi_list = []
    
    
    analyze_output_dir = 'graph.dot\\cpp\\drivers\\'
    for filename in os.listdir(analyze_output_dir):
        if filename.endswith(".dot"):
            net_temp = Network(directed=True, filter_menu=True, select_menu=True, notebook=False,neighborhood_highlight=True, height='1500px')
            net_temp.show_buttons(False)    
            net_temp.toggle_physics(True)
            file_path = os.path.join(analyze_output_dir, filename)
            file = open(file_path, 'r')
            print("Parsing file: ", filename)
            _nodes, _node_ids, _links = parse_dot(file, filename.split('.')[0])
            parse_libs(args.sln_file, args.source_root)
            entry = find_entry(args.source_root) 
            #wdk_functions, driver_functions, other = sort_functions()
            gen_graph(net_temp, filename.split('.')[0],  _nodes, _node_ids, _links, entry=entry)
    
    
