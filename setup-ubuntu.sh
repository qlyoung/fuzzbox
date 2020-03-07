#!/bin/bash
#
# Ubuntu 18.04 AFL+LLVM environment setup script.
# Installs AFL, LLVM, and afl-utils.

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit
fi

printf "[+] Installing basic dependencies\n"
apt-get install -yqq python3 python3-dev python3-setuptools build-essential cgroup-bin git

printf "[+] Installing afl-utils\n"
git clone https://gitlab.com/rc0r/afl-utils
cd afl-utils
python3 setup.py install
cd ..

LLVM_VER=9

printf "[+] Checking for LLVM / clang...\n"
CLANG=$(which clang) > /dev/null
if [ $? -eq 0 ]; then
	printf "[+] %s\n" "$($CLANG --version 2>&1 | head -n 1)"
	printf "[!] Existing LLVM / clang installation found; skipping LLVM install\n"
else
	printf "[+] Installing LLVM / clang\n"
	wget https://apt.llvm.org/llvm.sh
	chmod +x llvm.sh
	./llvm.sh $LLVM_VER
	for file in /usr/bin/llvm-*; do
		TGT=$(echo $file | sed "s/-$LLVM_VER//g")
		echo "Linking $file to $TGT"
		ln -s $file $TGT
	done
	CLANG=$(which clang)
	printf "[+] %s\n" $($CLANG -v | head -n 1)
fi

printf "[+] Checking for AFL...\n"
AFLFUZZ=$(which afl-fuzz)
if [ $? -eq 0 ]; then
	printf "[+] %s\n" "$($AFLFUZZ | head -n 1)"
	printf "[!] Existing AFL installation found; skipping AFL install\n"
else
	printf "[+] Building and installing AFL\n"
	# git clone --single-branch --branch afl-continue-core-search https://github.com/qlyoung/AFL.git
	git clone https://github.com/vanhauser-thc/AFLplusplus.git AFL
	cd AFL
	make
	cd llvm_mode
	make
	cd ..
	make install
	cd ..
	rm -rf AFL
fi

printf "[+] All done, see README.md for further instructions\n"
