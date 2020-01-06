#!/bin/bash
#
# Ubuntu 18.04 AFL+LLVM environment setup script.
# Installs AFL, LLVM, and afl-utils.

if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit
fi

printf "[+] Installing basic dependencies\n"
apt-get install -yqq python3 python3-setuptools build-essential cgroup-bin

printf "[+] Installing Grafana\n"
wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
add-apt-repository "deb https://packages.grafana.com/oss/deb stable main"
add-apt-repository "deb https://packages.grafana.com/oss/deb beta main"
apt-get update -yqq
apt-get install -yqq grafana

printf "[+] Installing InfluxDB\n"
apt-get install -y grafana influxdb influxdb-client

printf "[+] Installing afl-utils\n"
cd afl-utils
python3 setup.py install
cd ..

printf "[+] Checking for LLVM / clang...\n"
CLANG=$(which clang) > /dev/null
if [ $? -eq 0 ]; then
	printf "[+] %s\n" "$($CLANG --version 2>&1 | head -n 1)"
	printf "[!] Existing LLVM / clang installation found; skipping LLVM install\n"
else
	printf "[+] Installing LLVM / clang\n"
	bash -c "$(wget -O - https://apt.llvm.org/llvm.sh)"
	ln -s /usr/bin/clang-9 /usr/bin/clang
	ln -s /usr/bin/clang++-9 /usr/bin/clang++
	ln -s /usr/bin/llvm-symbolizer-9 /usr/bin/llvm-symbolizer
	ln -s /usr/bin/llvm-config-9 /usr/bin/llvm-config
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
	cd AFL
	make
	cd llvm_mode
	make
	cd ..
	make install
	cd ..
fi

printf "[+] All done, see README.md for further instructions\n"