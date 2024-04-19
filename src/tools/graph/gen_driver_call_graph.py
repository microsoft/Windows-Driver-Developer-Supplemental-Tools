


"""
This script generates a driver call graph by analyzing a codeql database and msbuild linker output.

Usage:

Arguments:
    --sln_file: The path to the driver project solution file. (A .vcxproj file can also be used)
    --database_path: The path to the codeql database or the path to create a new one.
    --source_root: The root directory of the source code. (Where the solution file/vcxproj file is located)
    --skip_codeql: Skip codeql database creation and analysis.
    --hide_by_default: Hide nodes by default.
    --show_all: Show all graphs generated.
    --show: Show graph when done
    
    

Example usage: python gen_driver_call_graph.py --sln_file event.vcxproj --database_path e:\databases\event_2 --source_root D:\Windows-driver-samples\genera
l\event\wdm --show
"""

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

driver_entry_points = {'FxDriverEntry':'KMDF', 'GsDriverEntry': 'WDM', '_DllMainCRTStartup':'dll' }
SYSTEM='OS_Manager_Component'
groups = ['DRIVER_ENTRY_POINT','FILE', 'DRIVER_FUNCTION', 'OTHER', 'IRP', 'DDI',  'LIB']
LEVELS = Enum('LEVELS', groups)

def libs_to_nodes(libs):
    """
    Converts libraries to nodes in the graph.

    Args:
        libs (dict): A dictionary containing libraries and their corresponding DDI (Device Driver Interface) functions.

    Returns:
        None
    """
    for lib in libs:
        for ddi in libs[lib]:
            ddi_list.append(ddi)

def get_lib_interface(lib):
    """
    Retrieves the interface of a library using the 'dumpbin' command.

    Args:
        lib (str): The path to the library file.

    Returns:
        list: A list of strings representing the interface of the library.
    """
    interface = []
    out = subprocess.run(['dumpbin', '/exports', lib], capture_output=True, shell=True)
    for line in out.stdout.decode('utf-8').split('\n'):
        interface.append(line.strip())
    return interface

def find_entry(source_root):
    """
    Finds the entry points in the source code.

    Args:
        source_root (str): The root directory of the source code.

    Returns:
        list: A list of strings representing the entry points found.
    """
    entry = []
    for root, dirs, files in os.walk(source_root):
        for file in files:
            if file == 'link.command.1.tlog':
                file_path = os.path.join(root, file)
                with open(file_path, 'r', encoding='UTF-16') as f:
                    lines = f.readlines()
                    for line in lines:
                        if '/ENTRY' in line and '.sys' in line.lower():
                            c = line.split()
                            for i in range(len(c)):
                                if '/entry' in c[i].lower():
                                    entry.append(c[i].split(':')[-1].replace('\"', ''))
                        elif '/ENTRY' in line and '.dll' in line.lower():
                            c = line.split()
                            for i in range(len(c)):
                                if '/entry' in c[i].lower():
                                    entry.append(c[i].split(':')[-1].replace('\"', ''))
                        if not '/ENTRY' in line and '/OUT' in line and '.exe' in line.lower():
                            c = line.split()
                            for i in range(len(c)):
                                if '/out' in c[i].lower():
                                    entry.append(c[i].split(':')[-1].split('\\')[-1].split('/')[-1].replace('\"', ''))
    entry = list(set(entry))
    if len(entry) == 0:
        return None
    return entry

def parse_libs(sln_file, source_root):
    """
    Parses the libraries in the solution file and retrieves their interfaces.

    Args:
        sln_file (str): The path to the solution file.
        source_root (str): The root directory of the source code.

    Returns:
        None
    """
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
    """
    Analyzes a codeql database with a given query.

    Args:
        db_path (str): The path to the codeql database.
        query (str): The path to the query file.

    Returns:
        None
    """
    print("Analyzing codeql database: ", db_path, " with query: ", query)
    out = subprocess.run(['codeql', 'database', 'analyze', db_path, '--format=dot', query,'--output=graph.dot', '--rerun'], shell=True)

def codeql_db_create(sln_file, source_root, output_dir):
    """
    Creates a codeql database for a solution file.

    Args:
        sln_file (str): The path to the solution file.
        source_root (str): The root directory of the source code.
        output_dir (str): The directory where the codeql database will be created.

    Returns:
        None
    """
    config = "Release"
    platform = "x64"
    print("Creating codeql database for solution file: ", sln_file, " in directory: ", source_root, " with output directory: ", output_dir)
    out = subprocess.run(['codeql', "database", "create", output_dir, "--overwrite", "-l", "cpp", "--source-root="+source_root,
                           "--command=msbuild "+ sln_file+ " -clp:Verbosity=m -t:clean,build -property:Configuration="+config+" -property:Platform="+platform + " -p:TargetVersion=Windows10 -p:SignToolWS=/fdws -p:DriverCFlagAddOn=/wd4996 -noLogo" ],
                        cwd=source_root,
                        capture_output=False,
                        shell=True)

def gen_graph(net, file, nodes, node_ids, macros, links, entry=None):
    """
    Generates a graph based on the given parameters.

    Args:
        net (Network): The network object used to create the graph.
        file (str): The name of the file for which the graph is generated.
        nodes (list): A list of strings representing the nodes in the graph.
        node_ids (dict): A dictionary mapping node IDs to their corresponding names.
        macros (list): A list of strings representing the macros in the graph.
        links (list): A list of tuples representing the links between nodes.
        entry (list, optional): A list of strings representing the entry points. Defaults to None.

    Returns:
        Network: The network object with the graph generated.
    """
    print('Generating graph for file: ', file)
    if entry is not None:
        for e in entry:
            if e in driver_entry_points:
                net.add_node(SYSTEM, label=SYSTEM, level=LEVELS.DRIVER_ENTRY_POINT.value, group='DRIVER_ENTRY_POINT', hidden=False, shape='ellipse')
                net.add_node(e, label=e, level=LEVELS.DRIVER_ENTRY_POINT.value, group='DRIVER_ENTRY_POINT', hidden=False, shape='ellipse')
                if(e, SYSTEM) not in links:
                    links.append((SYSTEM, e))
                if "DriverEntry" in nodes and (e, "DriverEntry") not in links:
                    net.add_node("DriverEntry", label="DriverEntry", level=LEVELS.DRIVER_ENTRY_POINT.value, group='DRIVER_ENTRY_POINT', hidden=False, shape='ellipse')
                    links.append((e, "DriverEntry"))
            else:
                net.add_node(e, label=e, level=LEVELS.DRIVER_ENTRY_POINT.value, group='DRIVER_ENTRY_POINT', hidden=False, shape='ellipse')
                if 'main' in nodes and (e, 'main') not in links:
                    net.add_node('main', label='main', level=LEVELS.DRIVER_FUNCTION.value, group='DRIVER_ENTRY_POINT', hidden=False, shape='ellipse')
                    links.append((e, 'main'))
    else:
        print('No entry points found!')
    for name in nodes:
        for lib in libs:
            val = libs[lib]
            for lib_func in val:
                if lib_func == name:
                    #update params for function node
                    net.add_node(lib, label=lib, level=LEVELS.LIB.value, group='LIB', hidden=args.hide_by_default, shape='database')
                    net.add_node(name, label=name, level=LEVELS.DDI.value, group='DDI', hidden=args.hide_by_default, shape='ellipse')      
                    links.append((name,lib))

        if '.cpp' in name or '.c' in name or '.h' in name or '.hpp' in name:
            level = LEVELS.FILE
            group = 'files'
            shape = 'ellipse'
        elif 'IRP_' in name:
            level = LEVELS.IRP
            group = 'irps'
            shape = 'ellipse'
        else:
            level = LEVELS.DDI
            group = 'DDI'
            shape = 'ellipse'
        net.add_node(name, label=name, level=level.value, group=group, hidden=args.hide_by_default, shape=shape)      
            
    # make edges
    for link in links:
        from_node = link[0]
        to_node = link[1]
        try:
            net.add_edge(from_node,to_node)
        except:
            print('error adding edge', from_node, to_node)
            continue 
    
    # if len(nodes) > 500:
    #     net.toggle_physics(False)
    if args.show_all:
        net.show(file+'.html', notebook=False)
    return net
        

def parse_dot(file, query):
    node_ids = {}
    ignore_ids = []
    nodes =[]
    links =[]
    lines = file.readlines()
    macros = []
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
            macro_target = None
            if '__macro__' in name:
                name_split = name.split('__macro__')
                name = name_split[0]
                macro_target = name_split[1]
                #node_ids[e[0].strip()+query] = macro_target
                macros.append(name)
              
            node_ids[e[0].strip()+query] = name
            nodes.append(name)
            if macro_target:
                nodes.append(macro_target) 
                links.append((name, macro_target))
                
        elif "->" not in e and "label=" not in e and '=' not in e and 'graph' not in e and '}' not in e and '{' not in e :
            print(e, "empty label")
            node_ids['error_empty_label'] = "ERROR EMPTY LABEL"
    for e in lines:
        e = e.replace('[', ' ').replace(']', ' ').replace(';', '').replace('\n', '')
        if "->" in e:
            e = e.split("->")
            if e[0].strip()+query in ignore_ids or e[1].strip()+query in ignore_ids:
                continue
            from_node = node_ids[e[0].strip()+query]
            to_node = node_ids[e[1].strip()+query]
        
            if (from_node,to_node) not in links:
                links.append((from_node,to_node))
    return nodes, node_ids, links, macros
  
  
def is_file_node(node):
    return '.cpp' in node or '.c' in node or '.h' in node or '.hpp' in node 
 
def merge_nets(networks):
    net_all =Network(directed=True, filter_menu=True, select_menu=True, notebook=False,neighborhood_highlight=True, height='1500px', cdn_resources=cnd_resources, layout=args.hierarchical )# networks['call-graph-driver']
    net_all.show_buttons(True)    

    # Create reference for different groups
    net_all.add_node('blank', label='Legend', hidden=False, shape='text')
    for group in groups:
        net_all.add_node(group, level=LEVELS[group].value, group=group, hidden=False, shape='dot')
        net_all.add_edge(group, 'blank', hidden=True)
        
    # add nodes for driver functions
    net_other = networks['file-functions-driver']
    other_nodes = net_other.get_nodes()
    other_edges = net_other.get_edges()
    for node in other_nodes:
        if not node in libs and node not in driver_entry_points and node != SYSTEM and '.exe' not in node.lower() and not is_file_node(node):
            net_all.add_node(node, label=node, level=LEVELS.DRIVER_FUNCTION.value, group='DRIVER_FUNCTION', hidden=args.hide_by_default, shape='ellipse')
        
    # add nodes for driver call graph
    call_nodes = networks['call-graph-driver'].get_nodes()
    call_edges = networks['call-graph-driver'].get_edges()
    file_nodes = networks['file-functions-all'].get_nodes()
    file_driver_nodes = networks['file-functions-driver'].get_nodes()
    ddis = []
    for node in call_nodes:
        if networks['call-graph-driver'].get_node(node)['group'] != "DDI" and networks['call-graph-driver'].get_node(node)['group'] != "DRIVER_FUNCTION":
            group = networks['call-graph-driver'].get_node(node)['group']
            level = networks['call-graph-driver'].get_node(node)['level']
            shape = networks['call-graph-driver'].get_node(node)['shape']
            net_all.add_node(node, label=node, level=level, group=group, hidden=args.hide_by_default, shape=shape)
        else:
            if node in file_nodes and node not in file_driver_nodes:
                net_all.add_node(node, label=node, level=LEVELS.DDI.value, group='DDI', hidden=args.hide_by_default, shape='ellipse')
                ddis.append(node)
            elif node in file_driver_nodes:
                net_all.add_node(node, label=node, level=LEVELS.DRIVER_FUNCTION.value, group='DRIVER_FUNCTION', hidden=args.hide_by_default, shape='ellipse')
            else:
                net_all.add_node(node, label=node, level=LEVELS.OTHER.value, group='OTHER', hidden=args.hide_by_default, shape='ellipse')
                
    for edge in call_edges:
        net_all.add_edge(edge['from'], edge['to'])
    ffd_net = networks['file-functions-driver']
    ffd_edges = ffd_net.get_edges()
    for edge in ffd_edges:
        if edge['from'] in net_all.get_nodes() and edge['to'] in net_all.get_nodes() and edge not in net_all.get_edges() and edge['from'] != edge['to']:
            net_all.add_edge(edge['from'], edge['to'])
            
            
    # add nodes for files and link function nodes to file nodes
    net_other = networks['file-functions-all']
    other_nodes = net_other.get_nodes()
    other_edges = net_other.get_edges()
    for node in net_all.get_nodes():
        if node in other_nodes:
            for edge in other_edges:
                if edge['to'] == node and ('.cpp' in edge['from'] or '.c' in edge['from'] or '.h' in edge['from'] or '.hpp' in edge['from']):
                    file_node = edge['from']
                    if (args.files_ddi_only and node in ddis) or (args.show_all_files):
                        net_all.add_node(file_node, label=file_node, level=LEVELS.FILE.value, group='FILE', hidden=args.hide_by_default, shape='box')
                        if edge not in net_all.get_edges():
                            print("adding edge", file_node, edge['to'])
                            net_all.add_edge(node, file_node)
    
    # add nodes for irps and link function nodes to irp nodes
    net_other = networks['irps-graph']
    other_nodes = net_other.get_nodes()
    other_edges = net_other.get_edges()
    for irp_node in other_nodes:
        if irp_node in net_all.get_nodes():
            for edge in other_edges:
                if edge['from'] == irp_node:
                    net_all.add_node(edge['to'], label=edge['to'], level=LEVELS.IRP.value, group='IRP', hidden=args.hide_by_default, shape='dot')
                    if edge not in net_all.get_edges():
                        net_all.add_edge(edge['from'], edge['to'])
                if edge['to'] == irp_node:
                    net_all.add_node(edge['from'], label=edge['from'], level=LEVELS.IRP.value, group='IRP', hidden=args.hide_by_default, shape='dot')
                    if edge not in net_all.get_edges():
                        net_all.add_edge(edge['from'], edge['to'])
    
    
    # add nodes for driver callbacks and link function nodes to driver callback nodes   
    net_other = networks['driver-callbacks']
    other_nodes = net_other.get_nodes()
    other_edges = net_other.get_edges()
    for edge in other_edges:
        if edge['to'] in net_all.get_nodes() and edge['to'] != 'DriverEntry': #driver entry covered earlier
            if edge not in net_all.get_edges():
                net_all.add_node(edge['from']+edge['to'], label="callback", level=LEVELS.DRIVER_ENTRY_POINT.value, group='DRIVER_ENTRY_POINT', hidden=False, shape='ellipse')
                net_all.add_edge(edge['from']+edge['to'], edge['to'])        
            
            
    if args.show:
        net_all.show('merged.html', notebook=False)
    else:
        net_all.write_html('merged.html', notebook=False)
    
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate a call graph of driver functions')
    parser.add_argument('--sln_file', type=str, help='Create a codeql database for the driver given the solution file')
    parser.add_argument('--database_path', type=str, help='Path to the existing codeql database or the path to create a new one')
    parser.add_argument('--source_root', type=str, help='Directory containing the driver solution file')
    parser.add_argument('--skip_codeql', action='store_true', help='Skip codeql database creation and analysis')
    parser.add_argument('--hide_by_default', action='store_true', help='Hide files by default')
    parser.add_argument('--show_all', action='store_true', help='Show all nets')
    parser.add_argument('--show', action='store_true', help='Show graph')
    parser.add_argument('--show_all_files', action='store_true', help='Skip file functions')
    parser.add_argument('--physics_off', action='store_true', help='Turn off physics')
    parser.add_argument('--hierarchical', action='store_true', help='Use hierarchical layout')
    parser.add_argument('--files_ddi_only', action='store_true', help='Show only files for DDI functions')
    parser.add_argument('--cdn_resources_remote', action='store_true', help='CDN resources')
    args = parser.parse_args()    
    cnd_resources = 'remote' if args.cdn_resources_remote else 'local'
   
    directory = "CallGraphQueries/"
    if not args.skip_codeql:
        if args.sln_file:
            codeql_db_create(args.sln_file, args.source_root, args.database_path)
        for filename in os.listdir(directory):
            if filename.endswith(".ql"):
                file_path = os.path.join(directory, filename)
                codeql_analyze_db(args.database_path, file_path)
                
    networks = {}
    libs = {}
    ddi_list = []
    
    
    analyze_output_dir = 'graph.dot\\cpp\\drivers\\'
    for filename in os.listdir(analyze_output_dir):
        if filename.endswith(".dot"):

            net_temp = Network(directed=True, filter_menu=True, select_menu=True, notebook=False,neighborhood_highlight=True, height='1500px', cdn_resources=cnd_resources, layout=args.hierarchical )
            #net_temp.barnes_hut(overlap=.001, spring_length=50)
            net_temp.show_buttons(True)    
            net_temp.toggle_physics(not args.physics_off)
            
            file_path = os.path.join(analyze_output_dir, filename)
            file = open(file_path, 'r')
            print("Parsing file: ", filename)
            _nodes, _node_ids, _links, _macros = parse_dot(file, filename.split('.')[0])
            parse_libs(args.sln_file, args.source_root)
            entry = find_entry(args.source_root) 
            if entry is None:
                print("entry none")
            networks[filename.split('.')[0]] = gen_graph(net_temp, filename.split('.')[0],  nodes=_nodes, node_ids=_node_ids, links=_links, macros=_macros,entry=entry)
            
    merge_nets(networks)
    
