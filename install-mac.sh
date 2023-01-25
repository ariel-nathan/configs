#!/bin/bash

# Install Xcode command line tools
xcode-select --install

# Install Homebrew
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install jq for parsing json
brew install jq

# Parse json file and install software using brew
software_array=$(cat software.json | jq -r '.mac[]')
for software in ${software_array[@]}; do
    brew install $software
done

# Init fig
fig integrations install dotfiles

# Add Hasklug Font
cp "./shared/hasklug-font/Hasklug Nerd Font Complete Mono.otf" /Library/Fonts/

# Setup oh-my-posh
cp ~/.zshrc ~/.zshrc.bak
mkdir ~/.poshthemes
cp ./shared/oh-my-posh/onedarkpro.omp.json ~/.poshthemes/

line="if [ \$TERM_PROGRAM != \"Apple_Terminal\" ]; then"
if ! grep -Fxq "$line" ~/.zshrc; then
    echo 'if [ $TERM_PROGRAM != "Apple_Terminal" ]; then' >> ~/.zshrc
    echo '  eval "$(oh-my-posh init zsh --config ~/.poshthemes/onedarkpro.omp.json)"' >> ~/.zshrc
    echo 'fi' >> ~/.zshrc
fi

exec zsh

# Copy Tabby config
cp ./mac/tabby/config.yaml "/Users/arielnathan/Library/Application Support/tabby/config.yaml"