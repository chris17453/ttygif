
raw_version_file='./version'
python_version_file='./ttygif/version.py'

v=$(cat $raw_version_file)

#put it in the main coinfig file
echo "${v%.*}.$((${v##*.}+1))">$raw_version_file
echo "VERION=${v%.*}.$((${v##*.}+1))">$raw_version_file

#update the version in the py file
echo "__version__='${v%.*}.$((${v##*.}+1))'">$python_version_file

 
