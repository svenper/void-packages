# texlive.profile written for voidlinux
TEXDIR		/opt/texlive/@@VERSION@@
TEXMFLOCAL	/opt/texlive/texmf-local
TEXMFSYSCONFIG	/opt/texlive/@@VERSION@@/texmf-config
TEXMFSYSVAR	/opt/texlive/@@VERSION@@/texmf-var
TEXMFHOME	~/texmf
TEXMFCONFIG	~/.texlive@@VERSION@@/texmf-config
TEXMFVAR	~/.texlive@@VERSION@@/texmf-var

tlpdbopt_install_docfiles	@@DOC@@
tlpdbopt_create_formats		@@FMT@@
tlpdbopt_generate_updmap	@@FMT@@
instopt_letter			@@LETTER@@
instopt_portable		@@PORTABLE@@
tlpdbopt_install_srcfiles	@@SRC@@
instopt_write18_restricted	@@WRITE18@@
