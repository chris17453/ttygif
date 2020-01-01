# If the first argument is "run"...
# WIP...
ifeq (run,$(firstword $(MAKECMDGOALS)))
  # use the rest as arguments for "run"
  RUN_ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
  # ...and turn them into do-nothing targets
  $(eval $(RUN_ARGS):;@:)
endif


THIS_FILE := $(lastword $(MAKEFILE_LIST))

git_username="Charles Watkins"
git_email="chris17453@gmail.com"
 
.DEFAULT: help
.PHONY: test examples profile
help:
	@echo "make build          | build bython files and make pypi package(runs unittest and standalone)"
	@echo "make bump           | bump the package version"
	@echo "make clean          | delete pypi build files"
	@echo "make unittest       | run unittest "
	@echo "make standalone     | build single file pyinstaller for ttygif"
	@echo "make upload         | upload any build packages to pypi"
	@echo "make install        | install ttygif from your user directory"
	@echo "make uninstall      | uninstall ttygif from your user directory"
	

clean:
	@find . -type f -name "*.c" -exec rm -f {} \;
	@find . -type f -name "*.pyc" -exec rm -f {} \;
	@find . -type f -name "*.so" -exec rm -f {} \;
	
bump:
	@./bump.sh
	@git add -A 
	@git commit -m 'Bump Version $(shell cat version)'

unittest:
	@python -m test.unittest

profile:
	@python -m test.profile
	
build: bump 
	@find . -type f -name "*.tar.gz" -exec rm -f {} \;
	@python setup.py build_ext --inplace sdist  --dist-dir builds/pypi/  --build-cython
	# @$(MAKE) -f $(THIS_FILE) standalone
	#@$(MAKE) -f $(THIS_FILE) unittest

standalone:
	@pyinstaller ttygif.spec

upload:
	@pipenv run twine upload  builds/pypi/*.gz

install:
	pip install . --user

uninstall:
	pip uninstall ttygif -y

examples:
	# tetris
	@python -m ttygif --input assets/cast/232377.cast --output assets/encode/232377.gif --fps 12
    # term raytracing
	@python -m ttygif --input assets/cast/174524.cast --output assets/encode/174524.gif --fps 12
	# Pikachu
	@python -m ttygif --input assets/cast/236096.cast --output assets/encode/236096.gif --fps 12
	# compile very long
	@python -m ttygif --input assets/cast/234628.cast --output assets/encode/234628.gif --fps 12
	# ncurses animaiton
	@python -m ttygif --input assets/cast/687.cast --output assets/encode/687.gif --fps 12
	# htop animaiton
	@python -m ttygif --input assets/cast/test.cast --output assets/encode/test.gif --fps 0


raytrace:
	@python -m ttygif --input assets/cast/174524.cast --output assets/encode/174524.gif --fps 12
	
tetris:
	@python -m ttygif --input assets/cast/232377.cast --output assets/encode/232377.gif --fps 12

caca:
	@python -m ttygif --input assets/cast/687.cast --output assets/encode/687.gif --fps 12

compile:	
	@python -m ttygif --input assets/cast/234628.cast --output assets/encode/234628.gif --fps 12

pika:
	@python -m ttygif --input assets/cast/236096.cast --output assets/encode/236096.gif --fps 12
	
htop:
	@python -m ttygif --input assets/cast/test.cast --output assets/encode/test.gif --fps 0

pika-dark:
	@python -m ttygif --input assets/cast/236096.cast --output assets/encode/236096.gif --fps 12 --theme game
	