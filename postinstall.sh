#!/usr/bin/env bash
test -f /var/lib/apt/lists/lock && sudo rm -rf /var/lib/apt/lists/lock
test -f /var/cache/apt/archives/lock && sudo rm -rf /var/cache/apt/archives/lock
test -f /var/lib/dpkg/lock && sudo rm -rf /var/lib/dpkg/lock
test -f /var/lib/dpkg/lock-frontend && sudo rm -rf /var/lib/dpkg/lock-frontend

DOWNLOADS_DIRECTORY="$HOME/tmp_programs"

APT_PROGRAMS=(
    snapd
    git
    docker
    docker-compose
    zsh
)

DEB_PROGRAMS=(
    "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
    "https://az764295.vo.msecnd.net/stable/e5a624b788d92b8d34d1392e4c4d9789406efe8f/code_1.51.1-1605051630_amd64.deb"
)

SH_PROGRAMS=(
    "https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh"
    "https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.1/install.sh"
)

SNAP_PROGRAMS=(
    postman
    discord
)

## .DEB PROGRAMS AREA ##
## -h stands for home instalation ##
if [ "$1" = "-h" ]; then
    DEB_PROGRAMS+=(
       "https://repo.steampowered.com/steam/archive/precise/steam_latest.deb"
    )
fi

## Downloading external programs ##
mkdir -p $DOWNLOADS_DIRECTORY
for url in ${DEB_PROGRAMS[@]}; do
    wget -c "$url" -P "$DOWNLOADS_DIRECTORY"
done
sudo dpkg -i $DOWLOADS_DIRECTORY/*.deb

## SH FILES AREA ##

# I think that have a better way to execute .sh files that have same name
# but i dont know how ...yet
counter=0
for program in ${SH_PROGRAMS[@]}; do
    name="${counter}.sh"
    wget -O "$name" "$program"
    mv $name $DOWNLOADS_DIRECTORY/$name
    counter=$((counter+1))
done
bash $DOWNLOADS_DIRECTORY/*.sh

## APT GET AREA ##
for program in ${APT_PROGRAMS[@]}; do
  if ! dpkg -l | grep -q $program; then
    sudo apt install "$program" -y
  fi
done

## SNAP AREA ##
for program in ${SNAP_PROGRAMS[@]};do
    sudo snap install $program
done

## DOCKER CONFIGURATION ##
sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(. /etc/os-release; echo "$UBUNTU_CODENAME") stable"
sudo apt-get update
sudo usermod -aG docker $USER


# ## ZSH CONFIGURATION ##
# setting zsh as default
sudo chsh -s $(which zsh) $(whoami)
sudo git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1
sudo ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

sudo mv -f -v .zshrc $HOME/.zshrc

## installing node
nvm install node

##installing golang version 1.15.5
wget -c https://dl.google.com/go/go1.15.5.linux-amd64.tar.gz -P $DOWNLOADS_DIRECTORY
sudo tar -C /usr/local -xzf $DOWNLOADS_DIRECTORY/go1.15.5.linux-amd64.tar.gz

## POST INSTALATION ##
sudo apt update && sudo apt dist-upgrade -y
flatpak update
sudo apt autoclean
sudo apt autoremove -y

rm -rf $DOWNLOADS_DIRECTORY