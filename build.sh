#!/usr/bin/env bash
base=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $base
if [ -d "$base/dist/linux" ]; then
	rm -rf "$base/dist/linux"
fi
if [ -e "$base/release/Argo.tar.gz" ]; then
	rm -rf "$base/release/Risk.tar.gz"
fi
echo "Installing rsound (If not already installed)"
raco pkg install rsound
echo "Compiling Risk..."
raco exe "src/risk.rkt"
echo "Creating distro..."
mkdir -p "$base/dist/linux"
raco distribute "$base/dist/linux" "src/risk"
echo "Compressing package..."
racket "$base/compress.rkt"
rm -rf "src/risk"
echo "Binaries in $base/dist/linux/bin, packages in $base/release"
echo "Finished."
