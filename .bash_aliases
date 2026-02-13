#!/usr/bin/bash

BOLD=$'\033[1m'
CYAN=$'\033[38;5;6m'    # Theme Cyan
GREEN=$'\033[38;5;2m'   # Theme Green
YELLOW=$'\033[38;5;3m'  # Theme Yellow
RED=$'\033[38;5;1m'     # Theme Red
BLUE=$'\033[38;5;4m'    # Theme Blue
GRAY=$'\033[38;5;8m'    # Theme "Bright Black" (usually the Gray in most themes)
NC=$'\033[0m'           # No Color


alias odoo-bin='~/Dev/src/odoo/odoo-bin'
alias odoo-iap='~/Dev/src/iap/odoo-18.0/odoo-bin -c ~/.odoorc-iap'
alias htop='btop'

# Shortcuts
alias psus='ssh 6914273@psus-tools.odoo.com'
alias findReq="find . -iname 'requirements*.txt' -exec pip install -r {} \;"
alias update='sudo apt update; sudo apt upgrade;'
alias vimdiff='vim -d'

# Function to download a runbot database and restore it.
function orunbot() {
  zipname=$(basename "$1")
  dbname=${zipname%.*}
  echo $dbname
  mkdir /tmp/restore-$dbname
  echo "### downloading"
  wget $1 -P /tmp/restore-$dbname -q
  unzip -q /tmp/restore-$dbname/$zipname -d /tmp/restore-$dbname
  echo "### restoring filestore"
  mkdir ~/.local/share/Odoo/filestore/$dbname
  mv /tmp/restore-$dbname/filestore/* ~/.local/share/Odoo/filestore/$dbname
  echo "### restoring db"
  createdb $dbname
  psql -q $dbname < /tmp/restore-$dbname/dump.sql
  echo "### cleaning"
  rm -r /tmp/restore-$dbname
  echo "Created db in $dbname"
}

# Function to drop a database and delete it's filestore folder
function ocleanup() {
  DB_NAME=${1:-""}
  PERFORM_CLEAN=${2:-""}
  if [[ "$DB_NAME" == "" ]] ; then
      echo "ERROR MUST SPECIFY DB NAME"
      return 1
  fi
  cwd=$(pwd)

  FS_FOLDER="${HOME}/.local/share/Odoo/filestore/oes_${DB_NAME}"
  echo \"$FS_FOLDER\"
  echo "killing connection to database $DB_NAME"
  psql -d postgres -c "SELECT pg_terminate_backend(pid) FROM pg_stat_activity WHERE datname = 'oes_$DB_NAME';"

  echo "Dropping database $DB_NAME"
  dropdb oes_$DB_NAME --if-exists

  if [ -d "$FS_FOLDER" ]; then
    echo "Will delete database filestore at folder: $FS_FOLDER"
    if [[ "$PERFORM_CLEAN" =~ ^[Yy].*$ ]] ; then
      brave="y"
    else
      read "brave?Here be dragons. Continue? "
    fi

    if [[ "$brave" =~ ^[Yy].*$ ]] then
      echo "Deleting folder."
      rm -rf $FS_FOLDER
    else
      echo "Skipping delete"
    fi
  fi
  echo "Database $DB_NAME cleaned up."
}

# Function to create a new DB, similar to newdb.sh but doesn't swap versions and
# supports passing commands to odoo-bin. To do a specific version must check that version
# out in all folders first.
function onew() {
  DB_NAME=${1:-""}
  shift;
  OTHERS="$@"

  if [[ "$DB_NAME" == "" ]] ; then
      echo "ERROR MUST SPECIFY DB NAME"
      return 1
  fi
  cwd=$(pwd)

  ocleanup "$DB_NAME"

  cd ~/Dev/src/
  echo "odoo-bin -d oes_$DB_NAME $OTHERS --stop-after-init"
  odoo-bin -d oes_$DB_NAME $OTHERS --stop-after-init;
  cd $cwd
}

function otest() {
  DB_NAME=${1:-""}
  shift;
  OTHERS="$@"

  if [[ "$DB_NAME" == "" ]] ; then
    echo "ERROR MUST SPECIFY DB NAME"
    return 1
  fi
  cwd=$(pwd)

  cd ~/Dev/src/
  echo "odoo-bin -d oes_$DB_NAME --test-tags $OTHERS --stop-after-init"
  odoo-bin -d oes_$DB_NAME --test-tags $OTHERS --stop-after-init;
  cd $cwd
}

# Update all folders
function oupdate() {
    ODOO_PATH=~/Dev/src
    # Store cwd so we can cd back to it after it's done
    cwd=$(pwd)
    set -o shwordsplit
    FLAG=${1:-""}
    if [[ ${2:-""} != "-s" && "$FLAG" != "-s" ]]; then PIPE_PATH="/dev/stdout"; else PIPE_PATH="errorOut"; fi
    # Go to where all of src code is stored
    cd $ODOO_PATH
    ODOO_FOLDERS="enterprise odoo internal upgrade upgrade-util ../support/support-tools ../odoo-stubs"

    for folder in $ODOO_FOLDERS; do
        cd $folder
        echo -e "${GREEN}Updating $folder...${NC}"
        git fetch
        git pull > $PIPE_PATH 2>&1
        response=$?

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

# Rebase base branch onto feature branch
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

# Search for a commit modifying some code with specific tags
function ogit() {
  STRING=${1:-""}
  DATE=${2:-""}
  GREP=${3:-"FIX"}
  if [[ "$STRING" == "" || "$DATE" == "" ]] ; then
    echo "ERROR: MUST SPECIFY STRING AND DATE"
    return 1
  fi

  git log -G "$STRING" --since="$DATE" --grep="$GREP" -p | egrep "(^commit [0-9a-f]+$)|diff --git|$STRING"
}

# Swap all folders to the required version. Can pass a default as necessary
# if the folder doesn't exist on the repo
function oswitch() {
  set -o shwordsplit
  set -o rematchpcre

  ODOO_PATH=~/Dev/src
  VERSION=""
  DEFAULT=""
  ODOO_FOLDERS="odoo enterprise"
  # Function to display usage
  usage() {
    echo "Usage: $0 <target_branch> [-f|--fallback <fallback_branch>]"
    echo "  <target_branch>           Branch to switch to (required)"
    echo "  -f, --fallback BRANCH     Fallback branch if target doesn't exist (optional)"
    return 1
  }

  # Parse arguments
  POSITIONAL_ARGS=()

  while [[ $# -gt 0 ]]; do
    case $1 in
      -f|--fallback)
        DEFAULT="$2"
        shift 2
        ;;
      -h|--help)
        usage
        ;;
      -*|--*)
        echo "Unknown option $1"
        usage
        ;;
      *)
        POSITIONAL_ARGS+=("$1")
        shift
        ;;
    esac
  done

  # Restore positional parameters
  set -- "${POSITIONAL_ARGS[@]}"

  # First positional argument is the target branch
  if [[ $# -gt 0 ]]; then
    VERSION="$1"
  else
    echo "Error: Target branch is required"
    usage
  fi

  cwd=$(pwd)
  cd $ODOO_PATH

  for fold in $ODOO_FOLDERS; do
    cd $fold
    echo -e "${GREEN}Swapping ${YELLOW}$fold${NC}${GREEN} to ${BLUE}$VERSION${NC}${GREEN}...${NC}"
    git fetch >> /dev/null
    # Checkout specific branch if it exists on repo
    if git show-ref --quiet refs/heads/$VERSION; then
      git checkout $VERSION
    # Otherwise checkout default
    elif [[ $DEFAULT ]]; then
      echo -e "${RED}Can't find ${YELLOW}$VERSION${NC}${RED} branch, using default ${GREEN}$DEFAULT${NC}"
      git checkout $DEFAULT
    # Otherwise try to guess based on branch name
    else
      [[ $VERSION =~ '^(master|(saas-)?\d+.\d+)' ]]
      head=$match[1]
      echo -e "${RED}Can't find ${YELLOW}$VERSION${NC}${RED} branch, trying ${GREEN}$head${NC}"
      if git show-ref --quiet refs/heads/$head; then
        git checkout $head
      fi
    fi
    cd $ODOO_PATH
  done

  cd $cwd
}

olist() {
    setopt local_options no_notify no_monitor
    local RESET=$'\033[0m'

    # Get list of databases (zsh splits on newlines automatically)
    local databases=(${(f)"$(psql -t -A -c "SELECT datname FROM pg_database WHERE datname LIKE 'oes_%' ORDER BY datname")"})

    # Create temp directory for results
    local tmpdir=$(mktemp -d)

    # Launch parallel queries for each database
    for dbname in $databases; do
        [[ -z "$dbname" ]] && continue
        (
            local version=$(psql -d "$dbname" -t -A -c \
                "SELECT replace((regexp_matches(latest_version, '^\d+\.\d+|^saas~\d+\.\d+|saas~\d+'))[1], '~', '-')
                 FROM ir_module_module WHERE name='base'" 2>/dev/null || echo "N/A")
            version=${version## }
            version=${version%% }
            echo "$dbname|$version" > "$tmpdir/$dbname"
        ) &
    done

    wait

    local db_data=()
    for dbname in $databases; do
        [[ -z "$dbname" ]] && continue
        [[ -f "$tmpdir/$dbname" ]] && db_data+=("$(cat "$tmpdir/$dbname")")
    done

    rm -rf "$tmpdir"
    print -n "\r\033[K"

    local output=""
    output+="${BOLD}╭──────────────────────────────────────────┬──────────────────────╮${NC}
"
    output+="$(printf "${BOLD}│${NC} ${BLUE}${BOLD}%-40s${NC} ${BOLD}│${NC} ${GREEN}${BOLD}%-20s${NC} ${BOLD}│${NC}" "Database Name" "Version")
"
    output+="${BOLD}├──────────────────────────────────────────┼──────────────────────┤${NC}
"

    for entry in $db_data; do
        local dbname=${entry%%|*}
        local version=${entry##*|}
        local prefix="oes_"
        local suffix="${dbname#$prefix}"
        output+="$(printf "${BOLD}│${NC} ${GRAY}oes_${CYAN}%-36s${NC} ${BOLD}│${NC} ${GREEN}%-20s${NC} ${BOLD}│${NC}" "$suffix" "$version")
"
    done

    output+="${BOLD}╰──────────────────────────────────────────┴──────────────────────╯${NC}"

    print -r "$output"
}
