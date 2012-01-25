#!/bin/sh

set -e

cd ../..

echo "The Big Benchmark"
echo " ================="
echo
if [ -f ./all ]; then
	echo "WARNING: running this script will destroy ANY local changes you"
	echo "might have on the repository that haven't been pushed yet."
	echo
	if [ x"$1" != x"--yes" ]; then
		echo "Are you absolutely sure you want to run this?"
		echo
		while :; do
			echo -n "y/n: "
			read -r yesno
			case "$yesno" in
				y)
					break
					;;
				n)
					echo "Aborted."
					exit 1
					;;
			esac
		done
	fi
fi

set -x

rm -f data/benchmark.log
rm -f data/engine.log
if [ -f ./all ]; then
	./all clean --reclone
	./all compile -r
	set -- ./all run "$@"
elif [ -z "$*" ]; then
	
	case "`uname`" in
		MINGW*|Win*)
			set -- ./xonotic.exe
			;;
		Darwin)
			set -- ./Xonotic.app/Contents/MacOS/xonotic-osx-sdl
			;;
		Linux)
			set -- ./xonotic-linux-sdl.sh
			;;
		*)
			echo "OS not detected. Usage:"
			echo "  $0 how-to-run-xonotic"
			exit 1
			;;
	esac
fi
(
 	echo
	echo "Engine log follows:"
	echo " ==================="
	set -x
	for e in omg low med normal high ultra ultimate; do
		USE_GDB=no \
		"$@" \
			+exec effects-$e.cfg \
			-nohome \
			-benchmarkruns 4 -benchmarkruns_skipfirst \
			-benchmark demos/the-big-keybench.dem
	done
) >data/engine.log 2>&1
cat data/engine.log >> data/benchmark.log
rm -f data/engine.log
if [ -f ./all ]; then
	./all clean -r -f -u
fi
set +x

echo
echo "Please provide the the following info to the Xonotic developers:"
echo " - CPU speed"
echo " - memory size"
echo " - graphics card (which vendor, which model)"
echo " - operating system (including whether it is 32bit or 64bit)"
echo " - graphics driver version"
echo " - the file benchmark.log in the data directory"
echo
echo "Thank you"
