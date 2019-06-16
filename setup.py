# cython: language_level=2
import os
import sys
#from distutils.core import setup, Command
#from distutils.extension import Extension
from setuptools import setup, find_packages
from setuptools.extension import Extension
from Cython.Build import cythonize


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
    Extension("ttygif.asciicast.reader"                 ,[prefix+"./ttygif/asciicast/reader"               +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.application_extension"        ,[prefix+"./ttygif/gif/application_extension"      +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.canvas"                       ,[prefix+"./ttygif/gif/canvas"                     +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.color_table"                  ,[prefix+"./ttygif/gif/color_table"                +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.CommentExtension"             ,[prefix+"./ttygif/gif/CommentExtension"           +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.Decoder"                      ,[prefix+"./ttygif/gif/Decoder"                    +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.encode"                       ,[prefix+"./ttygif/gif/encode"                     +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.gif"                          ,[prefix+"./ttygif/gif/gif"                        +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.graphics_control_extension"   ,[prefix+"./ttygif/gif/graphics_control_extension" +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.header"                       ,[prefix+"./ttygif/gif/header"                     +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.ImageData"                    ,[prefix+"./ttygif/gif/ImageData"                  +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.ImageDescriptor"              ,[prefix+"./ttygif/gif/ImageDescriptor"            +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.PlainTextExtension"           ,[prefix+"./ttygif/gif/PlainTextExtension"         +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.stream"                       ,[prefix+"./ttygif/gif/stream"                     +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.trailer"                      ,[prefix+"./ttygif/gif/trailer"                    +ext ], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.tty.font"                         ,[prefix+"./ttygif/tty/font"                       +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.tty.fonts"                        ,[prefix+"./ttygif/tty/fonts"                      +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.tty.viewer"                       ,[prefix+"./ttygif/tty/viewer"                     +ext2], define_macros=[('CYTHON_TRACE', '1')]),
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
            'ttygif.asciicast'
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
        ttygif = ttygif.cli:cli_main
        """,
    compiler_directives={"language_level": "2"},

)
