# dotfiles
All my files I'd need.

# How to use?
## Installing
### Quick start:  
`curl https://faulty.nl/.sh | sh`  
this command will download the script which can also be found in ./etc/init.sh
### The hard way:
```sh
git clone https://git.faulty.nl/faulty/dotfiles.git ~/.local/dotfiles # folder doesn't really matter
cd ~/.local/dotfiles
./sync.sh
```
## Using
The easiest way to maintain your dotfiles is to use the sync.sh script every now and then.
```sh
cd ~/.local/dotfiles
./sync.sh
```
You can also use certain args to sync.sh to only sync certain parts.
```sh
cd ~/.local/dotfiles
./sync.sh -v # verbose
./sync.sh -g # run sync for graphical applications
./sync.sh scripts # run only the scripts (e.g. link config files)
./sync.sh -g scripts # run sync for graphical scripts (e.g. update awesome-wm)
```
## Updating
Starting from [1cf5e207ab](https://git.faulty.nl/faulty/dotfiles/commit/1cf5e207ab8409e7bc13e0f9fb81a5df63037507) this isn't necessary anymore. *(please read docs/config.md for further information)*  
The script will automatically update itself when being run.
```sh
cd ~/.local/dotfiles
./sync.sh
```
# Fork it!
If you want to fork this repository, do!  
This repo is mirrored to [GitHub](https://github.com/faultydev/dotfiles) every 9 hours.  
## Changing files
> NOTE: some references might break due to edits in the repo.  

You will have to change some files to make this work for yourself.  
Ofcourse, ./files needs to be changed to your own files. (./files/zsh is used by ./scripts/10-zsh.sh so you can change it but you'll have to change the script too.)  
Here's a list of files to change + a comment:
```sh
## init script
./etc/init.sh # you should change the following variable: GITS
## tool script 
./etc/tool.sh #in minify_n_upload you should change the scp path to your own
## cfg script
./cfg.sh # change pretty much everything lmao
```