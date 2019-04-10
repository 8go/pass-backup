#!/usr/bin/env bash
# pass backup - Password Store Extension (https://www.passwordstore.org/)
# Copyright (C) 2019
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
# []

VERSION="1.1.1"
PASSWORD_STORE_BACKUP_DEBUG=false              # true or false, prints debugging messages
PASSWORD_STORE_BACKUP_DIR=".backups"           # default backup directory is $PASSWORD_STORE_BACKUP_DIR; if it is a relative path it becomes $PASSWORD_STORE_DIR/$PASSWORD_STORE_BACKUP_DIR
PASSWORD_STORE_BACKUP_BASENAME="passwordstore" # to create backup filenames like passwordstore.190407.123423.tar.gz2
TAR=$(which tar)

cmd_backup_usage() {
  cat <<-_EOF
Usage:
    $PROGRAM backup [backuplocation]
        On the first run it creates a directory ".backups" in \$PASSWORD_STORE_DIR.
        By default this is ~/.password-store/.backups".
        It creates a backup of the complete password store by creating a
        compressed tar-file with extension .tar.bz2.
        Backups themselves are excluded from the backup.
        Without argument the backup file will receive the default name "passwordstore.DATE.TIME.tar.bz2"
        where DATE and TIME are the current date and time.
        If an argument is given and it is a directory, the backup file will be placed
        into the specified directory instead of the default ".backups" directory.
        If an argument is given and it is not a directory, it is used as a file
        name and the backup is stored with this filename with .at.gz2 appended.
    $PROGRAM backup help
        Prints this help message.
    $PROGRAM backup version
        Prints the version number.

Example: $PROGRAM backup
            this is the typical usage
            creates a backup and places it into \$PASSWORD_STORE_DIR/.backups
            e.g. ~/.password-store/.backups/passwordstore.190407.122034.tar.gz2
Example: $PROGRAM backup Documents/Backups/
            creates a backup and places it into Documents/Backups/
            i.e. Documents/Backups/passwordstore.190407.122034.tar.gz2
Example: $PROGRAM backup Documents/Backups/mypassbackup
            creates a backup and places it into
            Documents/Backups/mypassbackup.tar.gz2

For installation place this bash script file "backup.bash" into
the passwordstore extension directory specified with \$PASSWORD_STORE_EXTENSIONS_DIR.
By default this is ~/.password-store/.extensions.
E.g. cp backup.bash ~/.password-store/.extensions
Give the file execution permissions:
E.g. chmod 700 ~/.password-store/.extensions/backup.bash
Set the variable PASSWORD_STORE_ENABLE_EXTENSIONS to true to enable extensions.
E.g. export PASSWORD_STORE_ENABLE_EXTENSIONS=true
Source the bash completion file "pass-backup.bash.completion" for bash completion.
E.g. source ~/.password-store/.bash-completions/pass-backup.bash.completion
Type "pass backup" to create your first backup.
E.g. pass backup
_EOF
  exit 0
}

cmd_backup_version() {
  echo $VERSION
  exit 0
}

cmd_backup_createbackup() {
  [[ $# -gt 1 ]] && die "Too many arguments. At most 1 argument allowed."

  [[ -z "$TAR" ]] && die "Failed to generate backup: tar is not installed."
  TODAYTIME=$(date "+%Y%m%d.%H%M%S") # e.g. 20190409.212327

  # expect 0 or 1 argument
  # ignore 2nd argument and higher
  if [ $# -eq 0 ]; then
    PASSWORD_STORE_BACKUP_PATH="$PASSWORD_STORE_BACKUP_DIR/${PASSWORD_STORE_BACKUP_BASENAME}.${TODAYTIME}.tar.bz2" # path includes filename
    $PASSWORD_STORE_BACKUP_DEBUG && echo "No arguments supplied. That is okay."
    $PASSWORD_STORE_BACKUP_DEBUG && echo "Setting backup directory to $PASSWORD_STORE_BACKUP_DIR"
    $PASSWORD_STORE_BACKUP_DEBUG && echo "Setting backup file to $PASSWORD_STORE_BACKUP_PATH"
  else
    ARG1="$1"
    case "$ARG1" in
    /*)
      $PASSWORD_STORE_BACKUP_DEBUG && echo "$ARG1 is an absolute path"
      ;;
    *)
      $PASSWORD_STORE_BACKUP_DEBUG && echo "$ARG1 is a relative path"
      ARG1="$(pwd)/$ARG1"
      $PASSWORD_STORE_BACKUP_DEBUG && echo "Now $ARG1 is an absolute path"
      ;;
    esac

    if [[ -d "$ARG1" ]]; then
      $PASSWORD_STORE_BACKUP_DEBUG && echo "Argument $ARG1 is a directory"
      PASSWORD_STORE_BACKUP_PATH="$ARG1/${PASSWORD_STORE_BACKUP_BASENAME}.${TODAYTIME}.tar.bz2" # path includes filename
    else
      $PASSWORD_STORE_BACKUP_DEBUG && echo "Argument $ARG1 treated as a filename"
      PASSWORD_STORE_BACKUP_PATH="${ARG1}.tar.bz2"
    fi
    $PASSWORD_STORE_BACKUP_DEBUG && echo "Setting exclusion directory to $PASSWORD_STORE_BACKUP_DIR"
    $PASSWORD_STORE_BACKUP_DEBUG && echo "Setting backup file to $PASSWORD_STORE_BACKUP_PATH"
  fi

  [[ -f "$PASSWORD_STORE_BACKUP_PATH" ]] && yesno "File $PASSWORD_STORE_BACKUP_PATH already exists. Overwrite it?"

  if [ -z "$PASSWORD_STORE_DIR" ]; then # var is empty
    PASSWORD_STORE_DIR="${HOME}/.password-store"
  fi
  $PASSWORD_STORE_BACKUP_DEBUG && echo "Password storage directory is $PASSWORD_STORE_DIR"

  pushd "${PASSWORD_STORE_DIR}" >/dev/null || die "Could not cd into directory $PASSWORD_STORE_DIR. Aborting."
  mkdir -p "${PASSWORD_STORE_BACKUP_DIR}" >/dev/null || die "Could not create directory $PASSWORD_STORE_BACKUP_DIR. Aborting."
  tar --exclude="${PASSWORD_STORE_BACKUP_DIR}" -cjf "${PASSWORD_STORE_BACKUP_PATH}" . # add v for debugging if need be
  chmod 400 "${PASSWORD_STORE_BACKUP_PATH}" >/dev/null || die "Could not change permissions to read-only on file $PASSWORD_STORE_BACKUP_PATH. Aborting."
  BZ2SIZE=$(wc -c <"${PASSWORD_STORE_BACKUP_PATH}") # returns size in bytes
  BZ2ENTRIES=$(tar -tf "${PASSWORD_STORE_BACKUP_PATH}" | wc -l)
  echo "Created backup file \"${PASSWORD_STORE_BACKUP_PATH}\" of size ${BZ2SIZE} bytes with ${BZ2ENTRIES} entries."
  popd >/dev/null || die "Could not change directory. Aborting."
}

case "$1" in
help | --help | -h)
  shift
  cmd_backup_usage "$@"
  ;;
version | --version | -v)
  shift
  cmd_backup_version "$@"
  ;;
*) cmd_backup_createbackup "$@" ;;
esac
exit 0
