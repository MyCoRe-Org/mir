#!/bin/bash
#REQUIRES:This Script needs the inotify-tools package, lessc (less compiler) and a kernel above 2.6.12
# MAC OS X: lessc and fswatch: https://github.com/yagee-de/fswatch
#Allows it to automatically build the new layout.css file, as soon as changes happen to any of the js files

realpath() {
	python -c 'import os, sys; print os.path.realpath(sys.argv[1])' $1
}
destpath=$(realpath ${1})

path=`dirname $0`
srcpath=$(realpath ${path}"/../main/less/")

checkPath() {
	if hash inotifywait 2>/dev/null
	then
		inotifywait  -r -e modify -e create -e move -e delete $1
	else
		if hash fswatch 2>/dev/null
		then
			fswatch $1
		else
			echo "Could not find neither inotifywait nor fswatch in PATH"
		fi
	fi
}
	

#initial Creation, we dont know what happened before the start of the script
if lessc --strict-imports --verbose ${srcpath}/layout.less ${destpath}
then
	while { checkPath $srcpath; }; do
		echo -n "building new version of ${destpath} "
		lessc --strict-imports --verbose ${srcpath}/layout.less ${destpath}
		echo "done."
	done
else
	echo "Could not execute LESSC"
	exit 1
fi
