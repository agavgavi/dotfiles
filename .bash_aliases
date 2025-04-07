#!/usr/bin/bash

alias oe-support='python3 ~/Dev/support/support-tools/oe-support.py'
alias odoo-bin='/home/andg/Dev/src/odoo/odoo-bin'
alias clean-database='python3 ~/Dev/support/support-tools/clean_database.py'

# Shortcuts
alias psus='ssh 6914273@psus-tools.odoo.com'
alias findReq="find . -iname 'requirements*.txt' -exec pip install -r {} \;"
alias update='sudo apt update; sudo apt upgrade;'
alias vimdiff='vim -d'

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

function onew() {
  DB_NAME=${1:-""}
  shift;
  OTHERS="$@"

  if [[ "$DB_NAME" == "" ]] ; then
      echo "ERROR MUST SPECIFY DB NAME"
      return 1
  fi
  cwd=$(pwd)

  FS_FOLDER="/home/andg/.local/share/Odoo/filestore/oes_${DB_NAME}"

  echo "killing connection to database $DB_NAME"
  query="SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'oes_$DB_NAME';"
  psql -d postgres -c "$query"

  echo "Dropping database $DB_NAME"
  dropdb oes_$DB_NAME --if-exists

  if [ -d "$FS_FOLDER" ]; then
    echo "Will delete database filestore at folder: $FS_FOLDER"
    read "brave?Here be dragons. Continue? "

    if [[ "$brave" =~ ^[Yy].*$ ]] then
      echo "Deleting folder."
      rm -rf $FS_FOLDER
    else
      echo "Skipping delete"
    fi
  fi

  cd ~/Dev/src/
  echo "odoo-bin -d oes_$DB_NAME $OTHERS --stop-after-init"
  odoo-bin -d oes_$DB_NAME $OTHERS --stop-after-init;
  cd $cwd
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
BLUE='\033[0;34m'
NC='\033[0m' # No Color

function oupdate() {
    ODOO_PATH=~/Dev/src
    # Store cwd so we can cd back to it after it's done
    cwd=$(pwd)
    set -o shwordsplit
    FLAG=${1:-""}
    VERSIONS="16.0 17.0 18.0 master"
    VERSIONED="enterprise odoo"
    if [[ ${2:-""} != "-a" && "$FLAG" != "-a" ]]; then ALL=false; else ALL=true; fi
    if [[ ${2:-""} != "-s" && "$FLAG" != "-s" ]]; then PIPE_PATH="/dev/stdout"; else PIPE_PATH="errorOut"; fi
    # Go to where all of src code is stored
    cd $ODOO_PATH
    ODOO_FOLDERS="enterprise odoo internal upgrade upgrade-util ../support/support-tools ../odoo-stubs"

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

function orebase() {
  VERSION=${1:-""}
  cwd=$(pwd)
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)

  if [[ "$VERSION" == "" ]] ; then
    echo "ERROR: MUST SPECIFY VERSION"
    return 1
  fi

  git checkout $VERSION
  git pull
  git checkout $CURRENT_BRANCH
  git rebase $VERSION
}


function oswitch() {
  set -o shwordsplit
  set -o rematchpcre

  ODOO_PATH=~/Dev/src
  VERSION=${1:-""}
  DEFAULT=${2:-""}
  REBASE=${3:-""}
  ODOO_FOLDERS="odoo enterprise ../documentation ../odoo-stubs"

  if [[ "$VERSION" == "" ]] ; then
    echo "ERROR: MUST SPECIFY VERSION"
    return 1
  fi
  cwd=$(pwd)
  cd $ODOO_PATH

  for fold in $ODOO_FOLDERS; do
    cd $fold
    git fetch >> /dev/null
    echo -e "${GREEN}Swapping ${YELLOW}$fold${NC}${GREEN} to ${BLUE}$VERSION${NC}${GREEN}...${NC}"
    # Checkout specific branch and rebase if asked.
    if git show-ref --quiet refs/heads/$VERSION; then
      git checkout $VERSION
      if [[ "$REBASE" == "r" && "$DEFAULT" && "$DEFAULT" != "$VERSION" ]] then
        echo -e "${BLUE}Rebasing ${GREEN}$DEFAULT${NC}${BLUE} onto ${YELLOW}$VERSION${NC}${BLUE}...${NC}"
        orebase $DEFAULT
      fi
    elif [[ $DEFAULT ]]; then
      echo -e "${RED}Can't find ${YELLOW}$VERSION${NC}${RED} branch, using default ${GREEN}$DEFAULT${NC}"
      git checkout $DEFAULT
      if [[ "$REBASE" == "r" ]] then
        git pull
      fi
    else
      [[ $VERSION =~ '^(master|(saas-)?\d+.\d+)' ]]
      head=$match[1]
      echo -e "${RED}Can't find ${YELLOW}$VERSION${NC}${RED} branch, trying ${GREEN}$head${NC}"
      if git show-ref --quiet refs/heads/$head; then
        git checkout $head
      if [[ "$REBASE" == "r" ]] then
        git pull
      fi
      fi
    fi
    cd $ODOO_PATH
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

    echo "rsync -a --info=progress2 $DB_URL:src/user /home/andg/Dev/src/."
    rsync -a --info=progress2 $DB_URL:src/user /home/andg/Dev/src/.
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
