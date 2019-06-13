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
    Extension("ttygif.asciicast.reader"                 ,[prefix+"./ttygif/asciicast/reader"             +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.ApplicationExtension"         ,[prefix+"./ttygif/gif/ApplicationExtension"     +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.canvas"                       ,[prefix+"./ttygif/gif/canvas"                   +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.color_table"                  ,[prefix+"./ttygif/gif/color_table"              +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.CommentExtension"             ,[prefix+"./ttygif/gif/CommentExtension"         +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.Decoder"                      ,[prefix+"./ttygif/gif/Decoder"                  +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.encode"                       ,[prefix+"./ttygif/gif/encode"                   +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.gif"                          ,[prefix+"./ttygif/gif/gif"                      +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.GraphicsControlExtension"     ,[prefix+"./ttygif/gif/GraphicsControlExtension" +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.header"                       ,[prefix+"./ttygif/gif/header"                   +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.ImageData"                    ,[prefix+"./ttygif/gif/ImageData"                +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.ImageDescriptor"              ,[prefix+"./ttygif/gif/ImageDescriptor"          +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.PlainTextExtension"           ,[prefix+"./ttygif/gif/PlainTextExtension"       +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.stream"                       ,[prefix+"./ttygif/gif/stream"                   +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.gif.Trailer"                      ,[prefix+"./ttygif/gif/Trailer"                  +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.tty.viewer"                       ,[prefix+"./ttygif/tty/viewer"                   +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.tty.fonts"                        ,[prefix+"./ttygif/tty/fonts"                    +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.cast2gif"                         ,[prefix+"./ttygif/cast2gif"                     +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.version"                          ,[prefix+"./ttygif/version"                      +ext2], define_macros=[('CYTHON_TRACE', '1')]),
    Extension("ttygif.cli"                              ,[prefix+"./ttygif/cli"                          +ext2], define_macros=[('CYTHON_TRACE', '1')]),
]
if USE_CYTHON:
    try:
        from Cython.Build import cythonize
        extensions = cythonize(extensions)
    except BaseException as be:
        print (be)
        print ("No Cython installed")
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
        ttygif = tty.cli:cli_main
        """,
    compiler_directives={"language_level": "2"},

)
