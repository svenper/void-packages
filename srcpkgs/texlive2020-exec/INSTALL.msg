TeX Live provides many executables as scripts distributed via tlmgr.
These versions will be updated more frequently, so are therefore
preferred. That means that this package can contain symlinks
pointing to nothing. This shouldn't be a problem, but you may get a
warning about a file not being found when you launch one of these
programs. Just install it from tlmgr and everything should work.

You can switch library versions with xbps-alternatives for:
kpathsea, ptexenc, synctex, texlua52, texluajit. This is advisable
when upgrading to a new yearly release.
