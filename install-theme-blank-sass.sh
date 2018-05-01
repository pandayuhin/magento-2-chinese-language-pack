#!/bin/bash
# GAITERJONES
# blog.gaiterjones.com
# script to install theme-blank-sass and fronttools
# for docker service https://github.com/gaiterjones/docker-magento2
#
set -e
# variables
RED='\033[0;31m'
NC='\033[0m'

# CHANGE THIS
MAGENTO_DIR='/var/www/html/magento'
NVM_HOME='/var/www'

# start
printf "${RED}Installing theme-blank-sass into Magento Root: ${MAGENTO_DIR}...\n\n${NC}"
cd ${MAGENTO_DIR}
composer require snowdog/theme-blank-sass
composer require snowdog/frontools
${MAGENTO_DIR}/bin/magento setup:upgrade
${MAGENTO_DIR}/bin/magento cache:clean

printf "${RED}Installing nvm...\n${NC}"
cd /tmp
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.1/install.sh | bash
export NVM_DIR=${NVM_HOME}/.nvm
 [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm install --lts
nvm use --lts
printf "${RED}Installing gulp...\n${NC}"
npm install -g gulp-cli

printf "${RED}Installing frontools...\n${NC}"
cd ${MAGENTO_DIR}/vendor/snowdog/frontools
npm install
gulp setup
curl -o "${MAGENTO_DIR}/dev/tools/frontools/config/themes.json" https://pe.terjon.es/dropbox/magento2/theme-blank-sass/browser-sync.json
curl -o "${MAGENTO_DIR}/dev/tools/frontools/config/themes.json" https://pe.terjon.es/dropbox/magento2/theme-blank-sass/themes-blank-sass-parent.json
curl -o "${MAGENTO_DIR}/vendor/snowdog/theme-blank-sass/web/images/logo.svg" https://pe.terjon.es/dropbox/magento2/theme-blank-sass/logo-theme-blank-sass.svg

printf "${RED}Generating theme-blank-sass styles...\n${NC}"
gulp styles

printf "${RED}Configuring Snowdog/blank theme.\n${NC}"
THEME_ID="$(n98-magerun2.phar dev:theme:list --format=csv \
  | grep 'Snowdog/blank' | cut -d, -f1)" \
  ; test -n "${THEME_ID}" \
  && n98-magerun2.phar config:set design/theme/theme_id "${THEME_ID}"
${MAGENTO_DIR}/bin/magento cache:clean

# done
printf "${RED}Installation complete.\n\n${NC}"
