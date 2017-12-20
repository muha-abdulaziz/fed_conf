#! /bin/sh

##
## This script automate the regulare Fedora configartaion.
##  
##



######################################################################
################### Functions to add the repos #######################
######################################################################

RPMFUSION_REPOS () {

    echo "Installing RPM Fusion free and non-free repos..."
    dnf --assumeyes install \
        https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
        https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

    echo "Done."
}


OJUBA_OF_MOCEAP () {
    echo "Adding ojuba repo..."
    cat > $REPO_PATH/_copr_moceap-Ojuba.repo << _EOF_
[moceap-Ojuba]
name=Copr repo for Ojuba owned by moceap
baseurl=https://copr-be.cloud.fedoraproject.org/results/moceap/Ojuba/fedora-$releasever-$basearch/
skip_if_unavailable=True
gpgcheck=1
gpgkey=https://copr-be.cloud.fedoraproject.org/results/moceap/Ojuba/pubkey.gpg
enabled=0
enabled_metadata=1
_EOF_
    
    echo "Done."
}



GOOGLE_CHROME_REPO () {
    echo "Adding google-chrome repo file..."
    cat > $REPO_PATH/google-chrome.repo <<- _EOF_
[google-chrome]
name=google-chrome  
baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl.google.com/linux/linux_signing_key.pub
_EOF_

    echo "Done."
}



ORECAL_VIRTUALBOX () {
    echo "Adding orecal virtualBox repo file..."
    cat > $REPO_PATH/virtualbox.repo << _EOF_
[virtualbox]
name=Fedora $releasever - $basearch - VirtualBox
baseurl=http://download.virtualbox.org/virtualbox/rpm/fedora/$releasever/$basearch
enabled=1
gpgcheck=1
gpgkey=https://www.virtualbox.org/download/oracle_vbox.asc
_EOF_

    echo "Done."
}



VSCODE_REPO () {
    echo "Adding visual studio code repo file..."
    cat > $REPO_PATH/vscode.repo << _EOF_
[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
_EOF_

    echo "Done."
}



GREEN_RECORDER_REPO () {
    # green recorder is a screan recorder program
    echo "Adding green recorder repo file..."
    cat > $REPO_PATH/home\:mhsabbagh.repo << _EOF_
[home_mhsabbagh]
name=home:mhsabbagh (Fedora_26)
type=rpm-md
baseurl=http://download.opensuse.org/repositories/home:/mhsabbagh/Fedora_26/
enabled=1
gpgcheck=1
gpgkey=http://download.opensuse.org/repositories/home:/mhsabbagh/Fedora_26/repodata/repomd.xml.key
_EOF_

    echo "Done."
}



KENZY_REPO () {
    # Kenzy is a distro developed by Muhammed Sha'ban.
    # He is a member of Linux Arab Comunity (linuxac.org)
    echo "Adding Kenzy repo file..."

    cat > $REPO_PATH/Kenzy_packages.repo << _EOF_
[home_Kenzy_packages]
name=Kenzy Packages (Fedora_24)
type=rpm-md
baseurl=http://download.opensuse.org/repositories/home:/Kenzy:/packages/Fedora_24/
enabled=0
gpgcheck=1
gpgkey=http://download.opensuse.org/repositories/home:/Kenzy:/packages/Fedora_24//repodata/repomd.xml.key
_EOF_

    echo "Done."
}


######################################################################
############### Function to install the wanted packages ##############
######################################################################

INSTALL_MULIMEDIA_PKGS () {
    echo "Installing multimedia programes and codecs..."

    local PROGS
    PROGS="audacity-freeworld \
youtube-dl \
green-recorder \
vlc"

    local CODECS
    CODECS="gstreamer1-plugin-mpg123 mpg123-libs"

    #The installation command
    $INSTALL_CMD $PROGS $CODECS

    echo "Done."
}



INSTALL_DEV_PKGS () {
    echo "Installing the dev pakages..."

    local PKGS
    PKGS="virtaal \
sqlitebrowser"

    local COMPILERS
    COMPILERS="golang golang-docs \
nasm"

    #The installation command
    $INSTALL_CMD $PKGS $COMPILERS
}



INSTALL_THESE_PKG () {
    echo "Installing packages..."

    local GNOME_EXTRA
    GNOME_EXTRA="gnome-tweak-tool \
gnome-terminal-nautilus"

    local PYTHON_PKGS
    PYTHON_PKGS="pylint \
python-virtualenv-doc \
python2-flask \
python2-pylint \
python2-sphinx \
python2-virtualenv \
python3-gammu \
python3-ipython \
python3-pylint \
python3-sqlalchemy \
python3-virtualenv"

    local OJUBA_APPS
    OJUBA_APPS="othman \
hijra-applet"

    local DAWAWIN
    DAWAWIN="dawawin \
dawawin-extra-books"

    local GAMES
    GAMES="gnome-mines"


    local TERMINAL_UTIL
    TERMINAL_UTIL="mc \
screenfetch"

    # Window managers
    local WM
    WM="openbox"

    # Archivers and Comparison tools
    local ARCH_AND_COMP
    ARCH_AND_COMP="unzip unrar p7zip"

    local EXTRA
    EXTRA="VirtualBox-5* \
keepass-2* \
hunspell-ar \
vim-syntastic-python \
gedit-plugins \
nano \
xterm \
lm_sensors \
mediawriter \
google-chrome-stable \
thunderbird"

    #The installation command
    $INSTALL_CMD $OJUBA_APPS $PYTHON_PKGS $DAWAWIN $EXTRA $ARCH_AND_COMP\
        $GNOME_EXTRA $GAMES $COMPILERS $TERMINAL_UTIL $WM

    #echo $OJUBA_APPS $PYTHON_PKGS $DAWAWIN
}



INSTALL_GROUPS () {
    local GROUPS
    GROUPS="\"Development tools\" 
\"arabic support\" -x kacst*"

    dnf groupinstall $GROUPS
}

######################################################################
################### Functions to make some configs ###################
######################################################################


MOUNT_WITHOUT_PASSWD () {

    cat >/etc/polkit-1/rules.d/10-ojuba-udisks.rules << EOF
/* -*- mode: js; js-indent-level: 4; indent-tabs-mode: nil -*- */
// DO NOT EDIT THIS FILE, it will be overwritten on ojuba-desktop-settings update
//
// Default rules for polkit


polkit.addRule(function(action, subject) {
    if (action.id == "org.freedesktop.udisks2.filesystem-mount-system") {
       return polkit.Result.YES;
    }
});
EOF
} ## end of MOUNT_WITHOUT_PASSWD


######################################################################
######################## Script starts from here #####################
######################################################################



## cheak if the script run as administer
#if [ $EUID -ne 0 ]
#then
#    echo "You must run the script as root, or run it using sudo."
#    exit 1
#fi

echo
echo "Hi, welcome to fedora `rpm -E %fedora`"

## don't forget to change it to the real path
## /etc/yum.repos.d/
REPO_PATH="test/yum.repos.d"
INSTALL_CMD="dnf --assumeyes install"

echo
echo 'Would you like to update the distro now? [y,n]'
read UPDATE_CHEAK


if [ $UPDATE_CHEAK -eq 'y' -o  UPDATE_CHEAK -eq 'Y' ]
then
    "Updating..."
    dnf --assumeyes update

    if [ $? -ne 0 ]
    then
        echo
        echo "There is a problem."
     fi

    echo
    echo "Done..."

fi



#RPMFUSION_REPOS 
#GOOGLE_CHROME_REPO 
#ORECAL_VIRTUALBOX 
#VSCODE_REPO 
#GREEN_RECORDER_REPO
#KENZY_REPO

#INSTALL_THESE_PKG
#INSTALL_DEV_PKGS
#INSTALL_MULIMEDIA_PKGS
#INSTALL_GROUPS 

exit