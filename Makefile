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
	@ echo "[Dev]"
	@ echo " make build          | build bython files and make pypi package(runs unittest and standalone)"
	@ echo " make bump           | bump the package version"
	@ echo " make clean          | delete pypi build files"
	@ echo " make unittest       | run unittest "
	@ echo ""
	@ echo "[Test]"
	@ echo " make examples       | builds all examples (requires assets submodule)"
	@ echo " make raytrace       | make the example raytrace"
	@ echo " make tetris	     | make the example tetris"
	@ echo " make caca           | make the example caca"
	@ echo " make compile:       | make the example compile"
	@ echo " make pika           | make the example pika"
	@ echo " make htop           | make the example htop"
	@ echo " make pika-dark      | make the example pika-dark"
	@ echo ""
	@ echo "[INSTALL]"
	@ echo " make install        | install ttygif from your user directory"
	@ echo " make uninstall      | uninstall ttygif from your user directory"
	@ echo " make pull-assets    | pull the assets submodule"
	@ echo ""
	@ echo " make about          | about the author"
			
about:
	@ echo "ttygif a product of watkinslabs"
	@ echo "-"
	@ echo "author: Charles Watkins"
	@ echo "email : chris17453@gmail.com"
	@ echo "github: github.com/chris17453"
	@ echo "-"
	


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
	
pull-assets:
	@git submodule update --init --recursive

build: bump 
	@find . -type f -name "*.tar.gz" -exec rm -f {} \;
	@python setup.py build_ext --inplace sdist  --dist-dir builds/pypi/  --build-cython
	# @$(MAKE) -f $(THIS_FILE) standalone
	#@$(MAKE) -f $(THIS_FILE) unittest

upload:
	@pipenv run twine upload  builds/pypi/*.gz

install:
	pip install . --user

uninstall:
	pip uninstall ttygif -y

examples: raytrace tetris caca compile pika htop pika-dark dodd


raytrace:
	@python -m ttygif.cli --input ../ttygif-assets/cast/174524.cast --output ../ttygif-assets/encode/174524.gif --fps 12 --theme mac --title "Raytrace - 174524.cast"
	
tetris: 
	@python -m ttygif.cli --input ../ttygif-assets/cast/232377.cast --output ../ttygif-assets/encode/232377.gif --fps 12 --title "Tetris -232377.cast" --theme game

caca:
	@python -m ttygif.cli --input ../ttygif-assets/cast/687.cast --output ../ttygif-assets/encode/687.gif --fps 12

compile:	
	@python -m ttygif.cli --input ../ttygif-assets/cast/234628.cast --output ../ttygif-assets/encode/234628.gif --fps 12

pika:
	@python -m ttygif.cli --input ../ttygif-assets/cast/236096.cast --output ../ttygif-assets/encode/236096.gif --trailer --title "Pika - 236096.cast" --theme mac --fps 12
	
htop:
	@python -m ttygif.cli --input ../ttygif-assets/cast/htop3.cast --output ../ttygif-assets/encode/htop.gif --theme mac --title "htop... testing alternate screen buffer" --fps 24 --theme docs/test --font IBM_ISO9


pika-dark:
	@python -m ttygif.cli --input ../ttygif-assets/cast/236096.cast --output ../ttygif-assets/encode/236096.gif --fps 12 --theme game
	
dodd:
	@ttygif -i ../ttygif-assets/cast/dodd2.cast  -o ../ttygif-assets/encode/dodd.gif   --underlay ../ttygif-assets/src_gifs/blood_dragon.gif   --theme game --title "Lookin good Bro" --font Wyse700b-2y


c: build install  dodd
