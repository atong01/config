## Prebuild files for surround.io

For use in building new images for source:

1. Copy all the files in prebuild.sh onto a usb key and put into the new
   installation at ~/prebuild
2. Add your id_rsa and id_rsa.pub into ~/prebuild/ssh. Do *NOT* repeat do *NOT*
   check in your id_rsa secret key into github and you have have a password on
   your id_rsa by running `ssh-keygen -f id_rsa` 
3. Add your AWS private key as well. Beware that there isn't encryption on this
   key, so guard it carefully and again don't check in to github!
4. Note that USB keys remove the execute bit so to run these, need to run them
   as "bash prebuild.sh"

## Other installation files

The support files are install files that run before you get to github. Actually
most can be run post running prebuild, but it is convenient to run it one step
so that when you are done, you have a nice working development environment.

But you can any of them afterwards just by going to the prebuild area. For
instance, adding an nvidia driver (install-nvidia.sh) is useful when you put in a new card or the
dwa182 (install-dwa182.sh) if you add that usb wifi adapter or you decide you want to use docker
(install-docker.sh)
