#!/usr/bin/bash

alias oe-support='python3 ~/Dev/odoo/support/support-tools/oe-support.py'
alias odoo-bin='/home/andg/Dev/odoo/src/odoo/odoo-bin'
alias clean-database='python3 ~/Dev/odoo/support/support-tools/clean_database.py'

# Shortcuts
alias psus='ssh 6914273@psus-tools.odoo.com'
alias findReq="find . -iname 'requirements*.txt' -exec pip install -r {} \;"
alias onew='bash /home/andg/Dev/odoo/support/us-support/scripts/generic/newdb'
alias update='sudo apt update; sudo apt upgrade;'

function ofetch() {
    DB_NAME=${1:-""}
    shift;
    OTHERS="$@"
    if [[ "$DB_NAME" == "" ]] ; then
        echo "ERROR MUST SPECIFY DB NAME"
        return 1
    fi
    echo "oe-support fetch $DB_NAME $OTHERS"
    oe-support fetch $DB_NAME $OTHERS
}

function orestore() {
    DB_NAME=${1:-""}
    DUMP_PATH=${2:-""}

    if [[ "$DB_NAME" == "" ]] ; then
        echo "ERROR MUST SPECIFY DB NAME"
        return 1
    fi

    if [[ "$DUMP_PATH" == "" ]] ; then
        echo "ERROR MUST SPECIFY DUMP PATH"
        return 1
    fi
    shift; shift;
    REST="$@"

    echo "oe-support restore-dump $DB_NAME '$DUMP_PATH' $REST"
    oe-support restore-dump $DB_NAME "$DUMP_PATH" $REST
}

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

function oupdate() {
    ODOO_PATH=~/Dev/odoo/src
    # Store cwd so we can cd back to it after it's done
    cwd=$(pwd)
    set -o shwordsplit
    FLAG=${1:-""}
    VERSIONS="14.0 15.0 saas-15.2 16.0 17.0 saas-16.1 saas-16.2 saas-16.3 saas-16.4 saas-17.1 master"
    VERSIONED="enterprise odoo design-themes"
    if [[ ${2:-""} != "-a" && "$FLAG" != "-a" ]]; then ALL=false; else ALL=true; fi
    if [[ ${2:-""} != "-s" && "$FLAG" != "-s" ]]; then PIPE_PATH="/dev/stdout"; else PIPE_PATH="errorOut"; fi
    # Go to where all of src code is stored
    cd $ODOO_PATH
    ODOO_FOLDERS="enterprise odoo internal design-themes upgrade upgrade-util industry ../support/support-tools ../odoo-stubs"

    for folder in $ODOO_FOLDERS; do
        cd $folder
        echo -e "${GREEN}Updating $folder...${NC}"
        git fetch

        if [[ "$VERSIONED" == *"$folder"* && $ALL == true ]] ; then
            for version in $VERSIONS; do
                echo -e "${YELLOW}Checking out $version...${NC}"
                git checkout $version > /dev/null;
                git pull > $PIPE_PATH 2>&1
            done
        else
            git pull > $PIPE_PATH 2>&1
            response=$?
        fi;

        if [[ $response != 0 && "$FLAG" == "-s" ]] ; then
            echo -e "${RED}Git pull failed: error code $response.${NC}"
            cat $PIPE_PATH
        fi

        if [[ "$PIPE_PATH" != "/dev/stdout" ]]; then
            rm $PIPE_PATH
        fi
        echo -e "${YELLOW}Finished updating $folder...${NC}"

        cd ..
    done
    cd $cwd
}

function oswitch() {
  set -o shwordsplit
  ODOO_PATH=~/Dev/odoo/src
  VERSION=${1:-""}
  ODOO_FOLDERS="odoo design-themes enterprise industry ../odoo-stubs"

  if [[ "$VERSION" == "" ]] ; then
    echo "ERROR: MUST SPECIFY VERSION"
    return 1
  fi
  cwd=$(pwd)
  cd $ODOO_PATH

  for fold in $ODOO_FOLDERS; do
    cd $fold
    git checkout $VERSION
    git pull
    cd ..
  done

  cd $cwd
}



function fetch_addons() {
    DB_URL=${1:-""}
    FILESTORE_URL=${2:-""}

    if [[ "$DB_URL" == "" ]] ; then
        echo "ERROR MUST SPECIFY DB URL"
        return 1
    fi

    echo "rsync -a --info=progress2 $DB_URL:src/user /home/andg/Dev/odoo/src/."
    rsync -a --info=progress2 $DB_URL:src/user /home/andg/Dev/odoo/src/.
    if [[ "$FILESTORE_URL" != "" ]] ; then
        echo "rsync -a --info=progress2 $DB_URL:data/filestore /home/andg/.local/share/Odoo/filestore/$FILESTORE_URL/."
        start=0x00
        inc=0x01
        end=0xff
        for ((i = 0; i < 256; i++)); do
          pVal=$(printf '%02x' $start)
          rsync -a --info=progress2 $DB_URL:data/filestore/*/$pVal /home/andg/.local/share/Odoo/filestore/$FILESTORE_URL/.
          echo ""
          start=$(($start + $inc))
        done;
    fi
}
