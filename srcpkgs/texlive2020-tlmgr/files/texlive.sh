# The arch takes precedence through reverse likelihood of being installed
for TLARCH in powerpc-linux armhf-linux armel-linux i386-linux x86_64-linuxmusl x86_64-linux @@ARCH@@; do
	export PATH=$(echo ${PATH} | sed -E 's|:/opt/texlive/@@VERSION@@/bin/'${TLARCH}'/?||g')
	if [ -d /opt/texlive/@@VERSION@@/bin/${TLARCH} ] &&
	   [ -x /opt/texlive/@@VERSION@@/bin/${TLARCH} ]; then
		export PATH=${PATH}:/opt/texlive/@@VERSION@@/bin/${TLARCH}
		break
	fi
done
