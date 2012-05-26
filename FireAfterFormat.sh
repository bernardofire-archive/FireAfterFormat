#!/bin/bash

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
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.pom "push origin master"
    git config --global alias.plm "pull origin master"
    git config --global alias.co checkout
    git config --global alias.st status
    git config --global alias.df diff
    git config --global alias.undo "reset --soft HEAD^"
    git config --global alias.gl "log --graph --pretty=oneline --abbrev-commit"
    git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative"

    git config --global color.branch auto
    git config --global color.diff auto
    git config --global color.interactive auto
    git config --global color.status auto
    git config --global color.ui auto
}

function install_terminator
{
    sudo apt-get install -y terminator
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

