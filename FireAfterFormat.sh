#!/bin/bash

# Mandinga para pegar o diretório onde o script foi executado
FOLDER=$(cd $(dirname $0); pwd -P)

# Pegando arquitetura do sistema. Valores de retorno: '32-bit' ou '64-bit'
arquitetura=`file /bin/bash | cut -d' ' -f3`

#================================ Menu =========================================

# Instala o dialog
sudo apt-get install -y dialog > /dev/null

opcoes=$( dialog --stdout --separate-output                                                                 \
    --title "BernardoFire afterFormat - Pós Formatação para Ubuntu"                                   \
    --checklist 'Selecione os softwares que deseja instalar:' 0 0 0                                         \
    Desktop         "Muda \"Área de Trabalho\" para \"Desktop\" *(Apenas ptBR)"                         ON  \
    Axel            "Axel para usar no lugar do wget"                                                   ON  \
    Monaco          "Adiciona fonte Monaco e seleciona para o Terminal"                                 ON  \
    SSH             "SSH server e client"                                                               ON  \
    Python          "Ambiente para desenvolvimento com python"                                          ON  \
    Ruby            "Ambiente para desenvolvimento com ruby"                                            ON  \
    Git             "Sistema de controle de versão + configurações úteis"                               ON  \
    Terminator      "Terminal alternativo ao gnome-terminal"                                            ON  \
    Media           "Codecs, flashplayer (32 ou 64 bits), JRE e compactadores de arquivos"              ON  \
    XChat           "Cliente IRC"                                                                       ON  \
    Synergy         "Compartilhar teclado e mouse com outro computador"                                 ON  \
    Chromium        "Distribuição livre do Google Chrome"                                               ON  )

#=============================== Processamento =================================

# Termina o programa se apertar cancelar
[ "$?" -eq 1 ] && exit 1

function install_desktop
{
    mv $HOME/Área\ de\ Trabalho $HOME/Desktop
    sed "s/"Área\ de\ Trabalho"/"Desktop"/g" $HOME/.config/user-dirs.dirs  > /tmp/user-dirs.dirs.modificado
    mv /tmp/user-dirs.dirs.modificado $HOME/.config/user-dirs.dirs
    xdg-user-dirs-gtk-update
    xdg-user-dirs-update
}

function install_axel
{
  sudo apt-get install -y axel
}

function install_monaco
{
    sudo mkdir /usr/share/fonts/macfonts
    sudo wget -O /usr/share/fonts/macfonts/Monaco_Linux.ttf http://github.com/downloads/hugomaiavieira/afterFormat/Monaco_Linux.ttf --no-check-certificate
    sudo fc-cache -f -v
    # Configura para o terminal
    `gconftool-2 --set /apps/gnome-terminal/profiles/Default/use_system_font -t bool false`
    `gconftool-2 --set /apps/gnome-terminal/profiles/Default/font -t str Monaco\ 10`
}

function install_ssh
{
    sudo apt-get install -y openssh-server openssh-client
}

function install_python
{
    sudo apt-get install -y ipython python-dev

    wget -O /tmp/distribute_setup.py http://python-distribute.org/distribute_setup.py
    sudo python /tmp/distribute_setup.py

    sudo easy_install pip
    sudo pip install virtualenv

    sudo pip install virtualenvwrapper
    mkdir -p $HOME/.virtualenvs
    echo "export WORKON_HOME=\$HOME/.virtualenvs" >> $HOME/.bashrc
    echo "source /usr/local/bin/virtualenvwrapper.sh"  >> $HOME/.bashrc
}

function install_ruby
{
    sudo apt-get install git-core curl
    bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)
    if [ -e ~/.zshrc]
    then
         echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM function' >> ~/.zshrc
         source ~/.zshrc
    fi
    echo '[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM function' >> ~/.bashrc
    source ~/.bashrc

    sudo apt-get install build-essential bison openssl libreadline5 \
    libreadline-dev zlib1g zlib1g-dev libssl-dev sqlite3 libsqlite3-0 \
    libsqlite3-dev libxml2-dev libxslt1-dev libreadline-dev

    rvm install 1.9.3 --with-readline-dir=/usr/include/readline

    rvm 1.9.3@global
    gem install bundler pry --no-ri --no-rdoc
}

function install_git
{
    sudo apt-get install -y git-core
}

function install_terminator
{
    sudo apt-get install -y terminator
}

function install_media
{
    # A referência para a instalação desses pacotes foi o http://ubuntued.info/

    # Adiciona o repositório Medibuntu
    sudo wget --output-document=/etc/apt/sources.list.d/medibuntu.list http://www.medibuntu.org/sources.list.d/$(lsb_release -cs).list &&
         sudo apt-get update &&
         sudo apt-get -y --allow-unauthenticated install medibuntu-keyring &&
         sudo apt-get update

    # Adiciona o repositório Partner. É um repositório oficial que contém os
    # pacotes de instalação do Java da Sun.
    sudo add-apt-repository "deb http://archive.canonical.com/ubuntu natty partner" && sudo apt-get update

    # Pacotes de codecs de áudio e vídeo
    sudo apt-get install -y non-free-codecs libdvdcss2 faac faad ffmpeg    \
         ffmpeg2theora flac icedax id3v2 lame libflac++6 libjpeg-progs     \
         libmpeg3-1 mencoder mjpegtools mp3gain mpeg2dec mpeg3-utils       \
         mpegdemux mpg123 mpg321 regionset sox uudeview vorbis-tools x264

    # Pacotes de compactadores de ficheiros
    sudo apt-get install -y arj lha p7zip p7zip-full p7zip-rar rar unrar unace-nonfree

    if [ "$arquitetura" = "32-bit" ]
    then
        # Instalar o flash e o java
        sudo apt-get install -y flashplugin-nonfree sun-java6-fonts sun-java6-jre sun-java6-plugin
    elif [ "$arquitetura" = "64-bit" ]
    then
        # Adiciona o repositório oficial da Adobe para o Flash
        sudo add-apt-repository ppa:sevenmachines/flash && sudo apt-get update
        # Remover qualquer versão do Flashplayer 32 bits para que não haja conflitos
        sudo apt-get purge -y flashplugin-nonfree gnash gnash-common mozilla-plugin-gnash swfdec-mozilla
        # Instalar o flash e o java
        sudo apt-get install -y flashplugin64-installer sun-java6-fonts sun-java6-jre sun-java6-plugin
    fi
}

function install_xchat
{
    sudo apt-get install -y xchat
}

function install_synergy
{
    sudo apt-get install -y synergy
}

function install_chromium
{
  sudo apt-get install -y chromium-browser
}

echo "$opcoes" |
while read opcao
do
    `echo install_$opcao | tr "[:upper:]" "[:lower:]"`
done

dialog --title 'Aviso' \
       --infobox 'Instalação concluída!' \
0 0

