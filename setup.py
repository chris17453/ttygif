# cython: language_level=2
import sys
from setuptools import setup
from setuptools.extension import Extension


if '--build-cython' in sys.argv:
    # if this is is the system building the package from source, use the py files (or pyx)
    index = sys.argv.index('--build-cython')
    sys.argv.pop(index)  # Removes the '--foo'
    ext = '.py'
    ext2= '.pyx' # X when needed
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
    #data import
    Extension("ttygif.asciicast.reader"                 ,[prefix+"./ttygif/asciicast/reader"               +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    #gif minipulation
    Extension("ttygif.gif.application_extension"        ,[prefix+"./ttygif/gif/application_extension"      +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.color_table"                  ,[prefix+"./ttygif/gif/color_table"                +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.CommentExtension"             ,[prefix+"./ttygif/gif/CommentExtension"           +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.graphics_control_extension"   ,[prefix+"./ttygif/gif/graphics_control_extension" +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.header"                       ,[prefix+"./ttygif/gif/header"                     +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.image_descriptor"             ,[prefix+"./ttygif/gif/image_descriptor"           +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.PlainTextExtension"           ,[prefix+"./ttygif/gif/PlainTextExtension"         +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.stream"                       ,[prefix+"./ttygif/gif/stream"                     +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.trailer"                      ,[prefix+"./ttygif/gif/trailer"                    +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.tools.passthrough"                ,[prefix+"./ttygif/tools/passthrough"              +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.image"                        ,[prefix+"./ttygif/gif/image"                      +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.decode"                       ,[prefix+"./ttygif/gif/decode"                     +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.encode"                       ,[prefix+"./ttygif/gif/encode"                     +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.canvas"                       ,[prefix+"./ttygif/gif/canvas"                     +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.gif"                          ,[prefix+"./ttygif/gif/gif"                        +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    # graphical rendering
    Extension("ttygif.tty.font"                         ,[prefix+"./ttygif/tty/font"                       +ext2], define_macros=[('CYTHON_TRACE', '1')]),
#    Extension("ttygif.tty.fonts"                        ,[prefix+"./ttygif/tty/fonts"                      +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.tty.display_state"                ,[prefix+"./ttygif/tty/display_state"              +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.tty.image"                        ,[prefix+"./ttygif/tty/image"                      +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.tty.parser"                       ,[prefix+"./ttygif/tty/parser"                     +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.tty.theme"                        ,[prefix+"./ttygif/tty/theme"                      +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.tty.terminal_graphics"            ,[prefix+"./ttygif/tty/terminal_graphics"          +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.tty.terminal_emulator"            ,[prefix+"./ttygif/tty/terminal_emulator"          +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.tty.graphics"                     ,[prefix+"./ttygif/tty/graphics"                   +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    
    # gif orchestraton of frames and data
    Extension("ttygif.cast2gif"                         ,[prefix+"./ttygif/cast2gif"                       +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    
    Extension("ttygif.version"                          ,[prefix+"./ttygif/version"                        +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    #Extension("ttygif.cli"                              ,[prefix+"./ttygif/cli"                            +ext ], define_macros=[('CYTHON_TRACE', '1')]),
]
if USE_CYTHON:
    try:
        from Cython.Build import cythonize
        extensions = cythonize(extensions)
    except BaseException as be:
        print (be)
        print("You don't seem to have Cython installed.")
        print("www.cython.org")
        print("with pip ->pip install cython --user")
        print("with a pipenv ->pipenv install cython")
        print("Building")
        exit(1)
else:
    print("Not using CYTHON")


packages=[  'ttygif',
            'ttygif.tty',
            'ttygif.gif',
            'ttygif.tools',
            'ttygif.asciicast'
         ]
    
ver=sys.version_info
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
        'Programming Language :: Python :: 3.7',
        "Development Status :: 3 - Alpha",
        "Operating System :: OS Independent",
    ],
    entry_points="""
        [console_scripts]
        ttygif = ttygif.cli:main
        """,
    compiler_directives={"language_level": ver.major},
    install_requires=[
        # Setuptools 18.0 properly handles Cython extensions.
        'setuptools>=18.0',
        'wheel',
        'cython',
        'python-devel',
        'future',
    ],    

)
