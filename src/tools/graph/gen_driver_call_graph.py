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

driver_entry_points = {'FxDriverEntry':'KMDF', 'GsDriverEntry': 'WDM', '_DllMainCRTStartup':'dll' }

groups = ['DRIVER_ENTRY_POINT','FILES', 'DRIVER_FUNCTIONS','FUNCTIONS', 'IRPS', 'LIBS', 'DDIS']
LEVELS = Enum('LEVELS', groups)

def libs_to_nodes(libs):
    for lib in libs:
        for ddi in libs[lib]:
            ddi_list.append(ddi)
def get_lib_interface(lib):
    interface = []
    out = subprocess.run(['dumpbin', '/exports', lib], capture_output=True, shell=True)
    for line in out.stdout.decode('utf-8').split('\n'):
        interface.append(line.strip())
    return interface
    
def find_entry(source_root):
    #this should run after parse_libs so that msbuild has run 
    entry = []
    for root, dirs, files in os.walk(source_root):
        for file in files:
            if file == 'link.command.1.tlog':
            # print('->', file)
                file_path = os.path.join(root, file)
                with open(file_path, 'r', encoding='UTF-16') as f:
                    lines = f.readlines()
                    #print(lines)
                    for line in lines:
                        #print(line)
                        if '/ENTRY' in line and '.sys' in line.lower():
                            c = line.split()
                            for i in range(len(c)):
                                if '/entry' in c[i].lower():
                                    entry.append(c[i].split(':')[-1].replace('\"', ''))
                        if not '/ENTRY' in line and '/OUT' in line and '.exe' in line.lower(): # for solutions that have an app and a driver, the app will have an exe but no entry in the link log
                            c = line.split()
                            for i in range(len(c)):
                                if '/out' in c[i].lower():
                                    entry.append(c[i].split(':')[-1].split('\\')[-1].split('/')[-1].replace('\"', ''))
                   
    entry = list(set(entry))                 
    if len(entry) == 0:
        return None
    return entry


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
            
def gen_graph(net, file, nodes, node_ids, links, entry=None):
    print('Generating graph for file: ', file)
    hidden = args.hide_by_default
    if entry is not None:
        for e in entry:
            if e in driver_entry_points:
                net.add_node("SYSTEM", label="SYSTEM", level=LEVELS.DRIVER_ENTRY_POINT.value, group='DRIVER_ENTRY_POINT', hidden=False, shape='ellipse')
                net.add_node(e, label=e, level=LEVELS.DRIVER_ENTRY_POINT.value, group='DRIVER_ENTRY_POINT', hidden=False, shape='ellipse')
                if(e, "SYSTEM") not in links:
                    links.append(("SYSTEM", e))
                if "DriverEntry" in nodes and (e, "DriverEntry") not in links:
                    net.add_node("DriverEntry", label="DriverEntry", level=LEVELS.DRIVER_ENTRY_POINT.value, group='DRIVER_ENTRY_POINT', hidden=False, shape='ellipse')
                    links.append((e, "DriverEntry"))
            else:
                net.add_node(e, label=e, level=LEVELS.DRIVER_ENTRY_POINT.value, group='DRIVER_ENTRY_POINT', hidden=False, shape='ellipse')
                if 'main' in nodes and (e, 'main') not in links:
                    net.add_node('main', label='main', level=LEVELS.FUNCTIONS.value, group='DRIVER_ENTRY_POINT', hidden=False, shape='ellipse')
                    links.append((e, 'main'))
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
                    net.add_node(lib, label=lib, level=LEVELS.LIBS.value, group='LIBS', hidden=False, shape='database')
                    net.add_node(name, label=name, level=LEVELS.DDIS.value, group='DDIS', hidden=hidden, shape='ellipse')      
                    links.append((lib,name))
                    
        if '.cpp' in name or '.c' in name or '.h' in name or '.hpp' in name:
            hidden= False
            level = LEVELS.FILES
            group = 'files'
            # name = name.split('.')[0]
            net.add_node(name, label=name, level=level.value, group=group, hidden=hidden, shape='ellipse')      
            continue
        elif 'IRP_' in name:
            level = LEVELS.IRPS
            group = 'irps'
            net.add_node(name, label=name, level=level.value, group=group, hidden=hidden, shape='ellipse')      
            continue
        else:
            level = LEVELS.FUNCTIONS
            group = 'FUNCTIONS'
            net.add_node(name, label=name, level=level.value, group=group, hidden=hidden, shape='ellipse')      
            
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
            if name.startswith('_'):
                # ignore internal functions
                ignore_ids.append(e[0].strip()+query)
                continue
            else:
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
            if e[0].strip()+query in ignore_ids or e[1].strip()+query in ignore_ids:
                continue
            from_node = node_ids[e[0].strip()+query]
            to_node = node_ids[e[1].strip()+query]
        
            if (from_node,to_node) not in links:
                links.append((from_node,to_node))
    return nodes, node_ids, links
  
def merge_nets(networks):
    net_all = networks['call-graph-all']
    
    # Create reference for different groups
    net_all.add_node('blank', label='', hidden=True, shape='dot')
    for group in groups:
        net_all.add_node(group, level=LEVELS[group].value, group=group, hidden=False, shape='circle')
        net_all.add_edge(group, 'blank')
        
    # net_other = networks['file-functions-all']
    # other_nodes = net_other.get_nodes()
    # other_edges = net_other.get_edges()
    # for node in net_all.get_nodes():
    #     if node in other_nodes:
    #         for edge in other_edges:
    #             if node == edge['from'] and edge['to'] not in net_all.get_nodes():
    #                 print('to node not in net_all', edge['to'])
    #                 net_all.add_node(edge['to'], label=edge['to'], level=LEVELS.FILES.value, group='FILES', hidden=False, shape='ellipse')
    #                 net_all.add_edge(node, edge['to'])
    #             if edge['from'] in net_all.get_nodes() and edge['to'] in net_all.get_nodes():
    #                 if edge not in net_all.get_edges():
    #                     print('add edge', edge['from'], edge['to'])
    #                     net_all.add_edge(edge['from'], edge['to'])
                # if node == edge['to'] and edge['from'] not in net_all.get_nodes():
                #     print('to node not in net_all', edge['to'])
                #     net_all.add_node(edge['from'], label=edge['from'], level=LEVELS.FILES.value, group='FILES', hidden=False)
                #     print('add edge', node, edge['to'])
                #     net_all.add_edge(edge['from'], node)
    net_other = networks['file-functions-driver']
    other_nodes = net_other.get_nodes()
    other_edges = net_other.get_edges()
    for node in net_all.get_nodes():
        if node in other_nodes and not node in libs and node not in driver_entry_points and node != "SYSTEM" and '.exe' not in node.lower():
            net_all.get_node(node)['level'] = LEVELS.DRIVER_FUNCTIONS.value
            net_all.get_node(node)['group'] = 'DRIVER_FUNCTIONS'
    
    net_other = networks['file-functions-all']
    other_nodes = net_other.get_nodes()
    other_edges = net_other.get_edges()
    for node in net_all.get_nodes():
        if node in other_nodes:
            for edge in other_edges:
                if edge['to'] == node and ('.cpp' in edge['from'] or '.c' in edge['from'] or '.h' in edge['from'] or '.hpp' in edge['from']):
                    net_all.add_node(edge['from'], label=edge['from'], level=LEVELS.FILES.value, group='FILES', hidden=False, shape='box')
                    if edge not in net_all.get_edges():
                        net_all.add_edge(edge['from'], edge['to'])
                if edge['from'] == node and ('.cpp' in edge['to'] or '.c' in edge['to'] or '.h' in edge['to'] or '.hpp' in edge['to']):
                    #net_all.add_node(edge['from'], label=edge['from'], level=LEVELS.FILES.value, group='FILES', hidden=False, shape='box')
                    if edge not in net_all.get_edges():
                        #net_all.add_edge(edge['from'], edge['to'])
                        print(edge['to'], node)

    net_all.show('merged.html', notebook=False)
    
    
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Generate a call graph of driver functions')
    parser.add_argument('--sln_file', type=str, help='Create a codeql database for the driver given the solution file')
    parser.add_argument('--database_path', type=str, help='Path to the existing codeql database or the path to create a new one')
    parser.add_argument('--source_root', type=str, help='Directory containing the driver solution file')
    parser.add_argument('--skip_codeql', action='store_true', help='Skip codeql database creation and analysis')
    parser.add_argument('--hide_by_default', action='store_true', help='Hide files by default')
    parser.add_argument('--show_all', action='store_true', help='Show all nets')
    args = parser.parse_args()    
    
   
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
            net_temp = Network(directed=True, filter_menu=True, select_menu=True, notebook=False,neighborhood_highlight=True, height='1500px')
            #net_temp.barnes_hut(overlap=.001, spring_length=50)
            net_temp.show_buttons(False)    
            net_temp.toggle_physics(True)
            file_path = os.path.join(analyze_output_dir, filename)
            file = open(file_path, 'r')
            print("Parsing file: ", filename)
            _nodes, _node_ids, _links = parse_dot(file, filename.split('.')[0])
            parse_libs(args.sln_file, args.source_root)
            entry = find_entry(args.source_root) 
            if entry is None:
                print("entry none")
            networks[filename.split('.')[0]] = gen_graph(net_temp, filename.split('.')[0],  _nodes, _node_ids, _links, entry=entry)
            
    merge_nets(networks)
    
