import os
import sys
from distutils.core import setup, Command
from distutils.extension import Extension


if '--build-cython' in sys.argv:
    # if this is is the system building the package from source, use the py files (or pyx)
    index = sys.argv.index('--build-cython')
    sys.argv.pop(index)  # Removes the '--foo'
    ext = '.py'
    ext2= '.py' # X when needed
    prefix=''
    print("Using Cython")
    USE_CYTHON=True
else:
    # if this is a package install, use the c files and build/register modules
    ext = '.c'
    ext2 = '.c'
    prefix=''
    USE_CYTHON=None    
# cython: linetrace=True
# cython: binding=True
# distutils: define_macros=CYTHON_TRACE_NOGIL=1

extensions = [
    Extension("ddb.evaluate.match",                     [prefix+"./ddb/evaluate/match" + ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ddb.functions.functions",                [prefix+"./ddb/functions/functions" + ext], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ddb.lexer.language",                     [prefix+"./ddb/lexer/language" + ext], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ddb.lexer.tokenize",                     [prefix+"./ddb/lexer/tokenize" + ext], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ddb.lexer.lexer",                        [prefix+"./ddb/lexer/lexer" + ext], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ddb.meta.meta",                          [prefix+"./ddb/meta/meta" + ext], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ddb.configuration.column",               [prefix+"./ddb/configuration/column" + ext], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ddb.configuration.table",                [prefix+"./ddb/configuration/table" + ext], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ddb.configuration.database",             [prefix+"./ddb/configuration/database" + ext], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ddb.output.factory",                     [prefix+"./ddb/output/factory" + ext], define_macros=[('CYTHON_TRACE', '1')] ),
    Extension("ddb.output.factory_yaml",                [prefix+"./ddb/output/factory_yaml" + ext], define_macros=[('CYTHON_TRACE', '1')] ),
    Extension("ddb.output.factory_xml",                 [prefix+"./ddb/output/factory_xml" + ext], define_macros=[('CYTHON_TRACE', '1')] ),
    Extension("ddb.output.factory_json",                [prefix+"./ddb/output/factory_json" + ext], define_macros=[('CYTHON_TRACE', '1')] ),
    Extension("ddb.output.factory_term",                [prefix+"./ddb/output/factory_term" + ext], define_macros=[('CYTHON_TRACE', '1')] ),
    Extension("ddb.file_io.locking",                    [prefix+"./ddb/file_io/locking" + ext], define_macros=[('CYTHON_TRACE', '1')] ),
    Extension("ddb.methods.database_show_errors",       [prefix+"./ddb/methods/database_show_errors" + ext], define_macros=[('CYTHON_TRACE', '1')] ),            
    Extension("ddb.methods.database_use",               [prefix+"./ddb/methods/database_use" + ext], define_macros=[('CYTHON_TRACE', '1')] ),    
    Extension("ddb.methods.record_core",                [prefix+"./ddb/methods/record_core" + ext2], define_macros=[('CYTHON_TRACE', '1')] ),   
    Extension("ddb.methods.record_delete",              [prefix+"./ddb/methods/record_delete" + ext], define_macros=[('CYTHON_TRACE', '1')] ),     
    Extension("ddb.methods.record_insert",              [prefix+"./ddb/methods/record_insert" + ext], define_macros=[('CYTHON_TRACE', '1')] ),     
    Extension("ddb.methods.record_select",              [prefix+"./ddb/methods/record_select" + ext], define_macros=[('CYTHON_TRACE', '1')] ),     
    Extension("ddb.methods.record_update",              [prefix+"./ddb/methods/record_update" + ext], define_macros=[('CYTHON_TRACE', '1')] ),     
    Extension("ddb.methods.record_upsert",              [prefix+"./ddb/methods/record_upsert" + ext], define_macros=[('CYTHON_TRACE', '1')] ),     
    Extension("ddb.methods.system_begin",               [prefix+"./ddb/methods/system_begin" + ext], define_macros=[('CYTHON_TRACE', '1')] ),    
    Extension("ddb.methods.system_commit",              [prefix+"./ddb/methods/system_commit" + ext], define_macros=[('CYTHON_TRACE', '1')] ),     
    Extension("ddb.methods.system_rollback",            [prefix+"./ddb/methods/system_rollback" + ext], define_macros=[('CYTHON_TRACE', '1')] ),       
    Extension("ddb.methods.system_set",                 [prefix+"./ddb/methods/system_set" + ext], define_macros=[('CYTHON_TRACE', '1')] ),  
    Extension("ddb.methods.system_show_columns",        [prefix+"./ddb/methods/system_show_columns" + ext], define_macros=[('CYTHON_TRACE', '1')] ),           
    Extension("ddb.methods.system_show_output_modules", [prefix+"./ddb/methods/system_show_output_modules" + ext], define_macros=[('CYTHON_TRACE', '1')] ),                  
    Extension("ddb.methods.system_show_tables",         [prefix+"./ddb/methods/system_show_tables" + ext], define_macros=[('CYTHON_TRACE', '1')] ),          
    Extension("ddb.methods.system_show_variables",      [prefix+"./ddb/methods/system_show_variables" + ext], define_macros=[('CYTHON_TRACE', '1')] ),             
    Extension("ddb.methods.table_create",               [prefix+"./ddb/methods/table_create" + ext], define_macros=[('CYTHON_TRACE', '1')] ),    
    Extension("ddb.methods.table_describe",             [prefix+"./ddb/methods/table_describe" + ext], define_macros=[('CYTHON_TRACE', '1')] ),      
    Extension("ddb.methods.table_drop",                 [prefix+"./ddb/methods/table_drop" + ext], define_macros=[('CYTHON_TRACE', '1')] ),  
    Extension("ddb.methods.table_update",               [prefix+"./ddb/methods/table_update" + ext], define_macros=[('CYTHON_TRACE', '1')] ),    
    Extension("ddb.version",                            [prefix+"./ddb/version" + ext], define_macros=[('CYTHON_TRACE', '1')] ),
    Extension("ddb.engine",                             [prefix+"./ddb/engine" + ext], define_macros=[('CYTHON_TRACE', '1')] ),
    Extension("ddb.interactive",                        [prefix+"./ddb/interactive" + ext], define_macros=[('CYTHON_TRACE', '1')] ),
    Extension("ddb.cli",                                [prefix+"./ddb/cli" + ext], define_macros=[('CYTHON_TRACE', '1')] ),
]
if USE_CYTHON:
    try:
        from Cython.Build import cythonize
        extensions = cythonize(extensions)
    except BaseException:
        print ("No Cython installed")
        print("Building")
        exit(1)
else:
    print("Not using CYTHON")


packages=['ddb',
          'ddb.lexer',
          'ddb.meta',
          'ddb.evaluate',
          'ddb.file_io',
          'ddb.methods',
          'ddb.functions',
          'ddb.configuration',
          'ddb.output',
         ]
    

exec(open('ttygif/version.py').read())
setup(
    name='ttygif',
    version=__version__,
    packages=packages,
    include_package_data=True,
    url='https://github.com/chris17453/ttygif/',
    license='Creative Commons Attribution-Noncommercial-Share Alike license',
    long_description=open('README.md').read(),
    long_description_content_type="text/markdown",
    author='Charles Watkins',
    author_email='chris17453@gmail.com',
    description='A asciicast to gif utility',
    ext_modules=extensions,
    classifiers=[
        'Programming Language :: Python :: 2.7',
        "Development Status :: 3 - Alpha",
        "Operating System :: OS Independent",
    ],
    entry_points="""
        [console_scripts]
        ttygif = tty.cli:cli_main
        """,
    compiler_directives={"language_level": "2"},

)
