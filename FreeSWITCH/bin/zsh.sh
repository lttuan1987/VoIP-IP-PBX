apt install zsh git curl -y

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

sed -i 's/plugins=(\([^)]*\))/plugins=(\1 zsh-autosuggestions)/' ~/.zshrc

source ~/.zshrc