if ! [[ ]] ; then

fi


ln -sv /share/CACHEDEV1_DATA/custom/.dotfiles/os/qnap/autorunmaster.sh /share/CACHEDEV1_DATA/custom/

ln -sv /share/CACHEDEV1_DATA/custom/.dotfiles/.profile /share/CACHEDEV1_DATA/custom/.profile_custom
ln -sv /share/CACHEDEV1_DATA/custom/.dotfiles/.aliases /share/CACHEDEV1_DATA/custom/.aliases
ln -sv /share/CACHEDEV1_DATA/custom/.dotfiles/.exports /share/CACHEDEV1_DATA/custom/.exports
ln -sv /share/CACHEDEV1_DATA/custom/.dotfiles/.functions /share/CACHEDEV1_DATA/custom/.functions

sh /share/CACHEDEV1_DATA/custom/.dotfiles/os/qnap/autorunmaster.sh
