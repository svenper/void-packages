#!/bin/sh -v

# TODO: look into TL_BUILD_ENV

# TODO: add build option conditionals around xindy, asymptote, etc.

# TODO: make biber + texworks meta
# TODO: kpathsea has no deps
# TODO: why are a handful of descriptions empty? I already have "s|^$|\"\"${PACKAGE}|g"

#
# SCHEMES="scheme-infraonly scheme-minimal scheme-basic scheme-small
# scheme-medium scheme-full"
# 
# 

: ${ARCH:=x86_64-linux}
: ${TLPDB:=/tmp/texlive.tlpdb}
: ${TEMPLATE:=${1:-/tmp/template}}
: ${SOURCE_PACKAGES:=$(dirname $(dirname "${TEMPLATE}"))}
: ${YEAR:=$(grep version= "${TEMPLATE}" | grep -Eo '[0-9]{4}')}

command -V curl || exit 1
command -V unxz || exit 1
[ -f "${TLPDB}" ] || curl 'http://ftp.acc.umu.se/mirror/CTAN/systems/texlive/tlnet/tlpkg/texlive.tlpdb.xz' | unxz - > "${TLPDB}"

PACKAGES() {
	cat "${TLPDB}" | awk "BEGIN{ORS=RS=\"\n\n\"} /binfiles arch=${ARCH} /" - | grep -Po "^name \K.*(?=\.${ARCH})"
	echo texworks # texlive only distributes this for windows for some reason
	#grep -P -o -e '^name \K(?!tlgs|tlperl|tlpsv|wintools|dviout).*(?=\.(?!config|image|infra|installation|installer).*$)' $(kpsewhich --expand-var '$TEXMFDIST')/../tlpkg/texlive.tlpdb.* | sort -u
}

PARSE() {
	TYPE="${1}"
	PACKAGE="${2}"
	REGEX="${3}"
	HACK() {
		if [ ${TYPE} = dependencies ]; then
			sed -E -e "s/^/\\\$\{sourcepkg\}-/g"
		elif [ ${TYPE} = description ]; then
 			sed -E -e 's/(["\\])/\\\1/g' |
 			sed -E -e 's|^"(.*)"$|\1|g' |
 			sed -E -e 's/^([Aa]n?|[Tt]he) //g' |
 			sed -E -e 's|Command line application to ||g' |
 			sed -E -e 's|Scalable Vector Graphics format \(SVG\)|SVG|g' |
 			sed -E -e 's|that enables transformations of|to transform|g' |
 			sed -E -e 's|Japanese/Chinese/Korean|CJK|g' |
 			sed -E -e 's|Pass verbatim contents through a compiler|Compile verbatim contents|g' |
 			awk '{for(i=1;i<=1;i++){ $i=toupper(substr($i,1,1)) substr($i,2) }}1' |
 			sed -E -e 's|^(Mpost)|""mpost|g' -e 's|^(PLaTeX)|""pLaTeX|g' -e 's|^(Tlcockpit)|""tlcockpit|g' -e 's|^(Tlshell)|""tlshell|g'
		elif [ ${TYPE} = executables ]; then
			grep -Ev -e '^(teckit_compile|xindy\.run|man)$' # teckit_compile is from teckit, xindy.run is N/A for native clisp
		fi
	}
	EMPTY_CHECK() {
		if [ ${TYPE} = dependencies ]; then
			sed -E -e "s/^(\\\$\{sourcepkg\})-${PACKAGE}$/\\\$\{sourcepkg\}/g"
		else
			cat
		fi
	}
	ADDITIONS() {
		  if [ ${TYPE} = dependencies ] && [ ${PACKAGE} = texlive.infra ]; then sed -E -e "s/.*/wget xz/g"
		elif [ ${TYPE} = dependencies ] && [ ${PACKAGE} = kpathsea      ]; then sed -E -e "s/.*//g"
		elif [ ${TYPE} = dependencies ] && [ ${PACKAGE} = tetex         ]; then sed -E -e "s/.*//g" # no longer exists, is spread out
		elif [ ${TYPE} = dependencies ] && [ ${PACKAGE} = amstex        ]; then sed -E -e "s/$/-pdftex/g"
		elif [ ${TYPE} = dependencies ] && [ ${PACKAGE} = cslatex       ]; then sed -E -e "s/$/-pdftex/g"
		elif [ ${TYPE} = dependencies ] && [ ${PACKAGE} = csplain       ]; then sed -E -e "s/$/-pdftex/g"
		elif [ ${TYPE} = dependencies ] && [ ${PACKAGE} = eplain        ]; then sed -E -e "s/$/-pdftex/g"
		elif [ ${TYPE} = dependencies ] && [ ${PACKAGE} = jadetex       ]; then sed -E -e "s/$/-pdftex/g"
		elif [ ${TYPE} = dependencies ] && [ ${PACKAGE} = latex-bin     ]; then sed -E -e "s/$/-pdftex/g"
		elif [ ${TYPE} = dependencies ] && [ ${PACKAGE} = mex           ]; then sed -E -e "s/$/-pdftex/g"
		elif [ ${TYPE} = dependencies ] && [ ${PACKAGE} = mltex         ]; then sed -E -e "s/$/-pdftex/g"
		elif [ ${TYPE} = dependencies ] && [ ${PACKAGE} = texsis        ]; then sed -E -e "s/$/-pdftex/g"
		elif [ ${TYPE} = dependencies ] && [ ${PACKAGE} = xmltex        ]; then sed -E -e "s/$/-pdftex/g"
		elif [ ${TYPE} = dependencies ] && [ ${PACKAGE} = lollipop      ]; then sed -E -e "s/$/-tex/g"
		elif [ ${TYPE} = dependencies ] && [ ${PACKAGE} = platex        ]; then sed -E -e "s/$/-ptex/g"
		elif [ ${TYPE} = dependencies ] && [ ${PACKAGE} = uplatex       ]; then sed -E -e "s/$/-uptex/g"
		elif [ ${TYPE} = dependencies ] && [ ${PACKAGE} = dvipdfmx      ]; then sed -E -e "s/$/-xetex/g"
		elif [ ${TYPE} = dependencies ] && [ ${PACKAGE} = asymptote     ]; then sed -E -e "s/$/ python-tkinter python-Pillow/g"
		elif [ ${TYPE} = dependencies ] && [ ${PACKAGE} = xetex         ]; then sed -E -e "s/$/ teckit/g"
		elif [ ${TYPE} = dependencies ] && [ ${PACKAGE} = xindy         ]; then sed -E -e "s/$/ clisp/g"
		elif [ ${TYPE} = dependencies ] && [ ${PACKAGE} = biber         ]; then sed -E -e "s/.*/biber/g"
		elif [ ${TYPE} = dependencies ] && [ ${PACKAGE} = texworks      ]; then sed -E -e "s/.*/texworks/g"

		# TODO: why is this hack needed? if then success / failure somewhere?
		elif [ ${TYPE} = description  ] && [ ${PACKAGE} = dviout-util   ]; then echo \"\"${PACKAGE}
		elif [ ${TYPE} = description  ] && [ ${PACKAGE} = xelatex-dev   ]; then echo \"\"${PACKAGE}

		else
			cat
		fi
	}
	cat "${TLPDB}" | awk "BEGIN{ORS=RS=\"\n\n\"} /(^|\n)name ${PACKAGE}($|\n)/" - | grep -Po "${REGEX}" | HACK | tr '\n' ' ' | sed -E 's/ $//g' | EMPTY_CHECK | ADDITIONS
}

sed --version 2>&1 | grep -q GNU &&
	sed -Ei '/^[[:space:]]*\#+ NOTE: EVERYTHING AFTER THIS LINE SHOULD BE AUTOMATICALLY GENERATED[[:space:]]*$/q' "${TEMPLATE}" ||
		(echo Error: GNU sed needed; exit 1)

for PACKAGE in $(PACKAGES); do
cat << EOF >> "${TEMPLATE}"

texlive${YEAR}-exec-${PACKAGE}_package() {
	depends="$(PARSE dependencies ${PACKAGE} "^depend \K.*(?=\.ARCH)")"
	short_desc="$(PARSE description ${PACKAGE} "^shortdesc \K.*")"
	pkg_install() {
		for _file in $(PARSE executables ${PACKAGE}.${ARCH} "^ bin/${ARCH}/\K.*$"); do
			vmove "\${_execdir}/\${_file}"
			if [ -f /usr/share/man/man1/\${_file}.1 ]; then vman "/usr/share/man/man1/\${_file}.1"; fi
			if [ -f /usr/share/man/man5/\${_file}.5 ]; then vman "/usr/share/man/man5/\${_file}.5"; fi
		done
	}
}
EOF
done

rm "${SOURCE_PACKAGES}"/texlive${YEAR}-exec-*
for SUB_PKG in $(cat "${SOURCE_PACKAGES}"/texlive${YEAR}-exec/template | grep -Po '^[^(]+(?=_package\(\))'); do
	(cd "${SOURCE_PACKAGES}" && ln -fns texlive${YEAR}-exec "${SUB_PKG}")
done
