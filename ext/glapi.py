import xml.etree.ElementTree as et
from argparse import ArgumentParser
from datetime import datetime

#---------------------------------------------------------------
#NOTE: get args
#---------------------------------------------------------------

parser = ArgumentParser()
parser.add_argument("-d", "--directory")

args = parser.parse_args()

apiName = 'glapi'
loaderName = 'glloader'

apiPath = args.directory + '/' + apiName + '.h'
loaderHeaderPath = args.directory + '/' + loaderName + '.h'
loaderCPath = args.directory + '/' + loaderName + '.c'

#---------------------------------------------------------------
#NOTE: gather all GL functions in OpenGL 4.3
#---------------------------------------------------------------

def gather_api(tree, api, version):
	procs = []
	for	feature in tree.iterfind('feature[@api="'+ api +'"]'):
		if float(feature.get('number')) > version:
			break

		for require in feature.iter('require'):
			for command in require.iter('command'):
				procs.append(command.get('name'))

		for remove in feature.iter('remove'):
			for command in remove.iter('command'):
				procs.remove(command.get('name'))
	return(procs)

tree = et.parse('gl.xml')

gl41 = gather_api(tree, 'gl', 4.1)
gl43 = gather_api(tree, 'gl', 4.3)
gles31 = gather_api(tree, 'gles2', 3.1)
gles32 = gather_api(tree, 'gles2', 3.2)

glall = list(set().union(gl41, gl43, gles31, gles32))


#---------------------------------------------------------------
# helpers
#---------------------------------------------------------------

def emit_doc(f, name, ext):
	f.write("/********************************************************\n")
	f.write("*\n")
	f.write("*\t@file: " + name + ext + '\n')
	f.write("*\t@note: auto-generated by glapi.py from gl.xml\n")
	f.write("*\t@date: %s\n" % datetime.now().strftime("%d/%m%Y"))
	f.write("*\n")
	f.write("/********************************************************/\n")


def emit_begin_guard(f, name):
	guard = '__' + name.upper() + '_H__'
	f.write("#ifndef " + guard + "\n")
	f.write("#define " + guard + "\n\n")

def emit_end_guard(f, name):
	guard = '__' + name.upper() + '_H__'
	f.write("#endif // " + guard + "\n")

def remove_prefix(s, prefix):
	if s.startswith(prefix):
		return s[len(prefix):]

#---------------------------------------------------------------
# Generate GL API header file
#---------------------------------------------------------------

f = open(apiPath, 'w')

emit_doc(f, apiName, '.h')
emit_begin_guard(f, apiName)

f.write('#include"GL/glcorearb.h"\n')
f.write('#include"GLES3/gl32.h"\n\n')

# generate interface struct
f.write('typedef struct mg_gl\n{\n')

for func in glall:
	f.write('\t' + 'PFN' + func.upper() + 'PROC ' + remove_prefix(func, 'gl') + ';\n')

f.write('} mg_gl;\n\n')
f.write('extern mp_thread_local mg_gl* __mgGLAPI;\n\n');

# generate interface macros
# TODO guard for different api/versions and only #define functions present in desired version
for func in glall:
	f.write('#define ' + func + ' __mgGLAPI->' + remove_prefix(func, 'gl') + '\n')

emit_end_guard(f, apiName)
f.close()

#---------------------------------------------------------------
# Generate GL loader header
#---------------------------------------------------------------

f = open(loaderHeaderPath)

emit_doc(f, loaderName, '.h')
emit_begin_guard(f, loaderName)

f.write("typedef void*(mg_gl_load_proc*)(const char* name);\n\n")

f.write("mg_gl* mg_gl_load_gl41(mg_gl_load_proc loadProc);\n")
f.write("mg_gl* mg_gl_load_gl43(mg_gl_load_proc loadProc);\n")
f.write("mg_gl* mg_gl_load_gles31(mg_gl_load_proc loadProc);\n")
f.write("mg_gl* mg_gl_load_gles32(mg_gl_load_proc loadProc);\n\n")

f.write("void mg_gl_select_api(mg_gl* api);\n\n")

emit_end_guard(f, loaderName)
f.close()
#---------------------------------------------------------------
# Generate GL loader code
#---------------------------------------------------------------

def emit_loader(f, name, procs):
	f.write('mg_gl* mg_gl_load_'+ name +'(mg_gl_load_proc loadProc)\n')
	f.write("{\n")
	f.write("\tif(!__mg"+ name.upper() +".init)\n")
	f.write("\t{\n")
	for proc in procs:
		f.write('\t\t__mg' + name.upper() + '.' + remove_prefix(proc, 'gl') + ' = loadProc("' + proc + '");\n')
	f.write("\t\t__mg"+ name.upper() +".init = true;\n")
	f.write("\t}\n")
	f.write("\treturn(&__mg"+ name.upper() +");\n")
	f.write("}\n\n")

f = open(loaderCPath, 'w')

emit_doc(f, loaderName, '.c')

f.write('#include"' + apiName + '.h"\n')
f.write('#include"platform.h"\n\n')

f.write("mp_thread_local mg_gl* __mgGLAPI = 0;\n\n")

f.write("static mg_gl __mgGL41 = {0};\n")
f.write("static mg_gl __mgGL43 = {0};\n")
f.write("static mg_gl __mgGLES31 = {0};\n")
f.write("static mg_gl __mgGLES32 = {0};\n\n")

emit_loader(f, 'gl41', gl41)
emit_loader(f, 'gl43', gl43)
emit_loader(f, 'gles31', gles31)
emit_loader(f, 'gles32', gles32)

f.write("void mg_gl_select_api(mg_gl* api){ __mgGLAPI = api; }\n\n")

f.close()
