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
.PHONY: test
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
	
build: bump 
	@find . -type f -name "*.tar.gz" -exec rm -f {} \;
    # makes ansible single script
	#@python $(conf_dir)/build.py
	@cd source; python setup.py build_ext --inplace sdist  --dist-dir ../builds/pypi/  --use-cython
	# @$(MAKE) -f $(THIS_FILE) standalone
	@$(MAKE) -f $(THIS_FILE) unittest

standalone:
	@pyinstaller ttygif.spec

upload:
	@pipenv run twine upload  builds/pypi/*.gz

install:
	pip install ttygif --user

uninstall:
	pip uninstall ttygif

 
test:
#Pikachu
#	@python -m ttygif.cli -t -i data/236096.cast -o examples/encode/test_cast.html
#Nyan
#	@python -m ttygif.cli -t -i data/3.cast -o examples/encode/test_cast.html
#Compile
	@python -m ttygif.cli -t -i data/234628.cast -o examples/encode/test_cast.html
	