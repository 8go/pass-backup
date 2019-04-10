# pass-backup
An extension for [pass](https://www.passwordstore.org/) (the standard Unix password manager) to easily create backups of the password store.


## Usage

```
Usage:

    pass backup [backuplocation]
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
    pass backup help
        Prints this help message.
    pass backup version
        Prints the version number.
```

## Examples

## Example 1: Using defaults, standard use
```
$ pass backup
```
This is the typical usage. This creates a backup and places it into ```$PASSWORD_STORE_DIR/.backups```
            e.g. ```~/.password-store/.backups/passwordstore.190407.122034.tar.gz2```.

## Example 2: Specifying a destination directory
```
$ pass backup Documents/Backups/
```
This creates a backup and places it into ```Documents/Backups/```
            i.e. ```Documents/Backups/passwordstore.190407.122034.tar.gz2```.
            
## Example 3: Specifying a destination file
```
$ pass backup Documents/Backups/mypassbackup
```
This creates a backup and places it into ```Documents/Backups/mypassbackup.tar.gz2```.

## Installaion

For installation download and place this bash script file ```backup.bash``` into
the passwordstore extension directory specified with ```$PASSWORD_STORE_EXTENSIONS_DIR```.
By default this is ```~/.password-store/.extensions```.
```
$ cp backup.bash ~/.password-store/.extensions
```
Give the file execution permissions:
```
$ chmod 700 ~/.password-store/.extensions/backup.bash
```
Set the variable ```PASSWORD_STORE_ENABLE_EXTENSIONS``` to true to enable extensions.
```
$ export PASSWORD_STORE_ENABLE_EXTENSIONS=true
```
Download and source the bash completion file ```pass-backup.bash.completion``` for bash completion.
```
$ source ~/.password-store/.bash-completions/pass-backup.bash.completion
```
Type ```pass backup``` to create your first backup.
```
$ pass backup
```

## Requirements

- `pass` from [https://www.passwordstore.org/](https://www.passwordstore.org/)
- `tar` to be installed for zipping and compression.


## Notes

Both files are tiny: 142 lines (script) and 17 lines (autocompletion)  respectively. You can check them yourself quickly. No need to trust anyone.
