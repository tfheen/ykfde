ykfde
=====
*y*ubikey *f*ull *d*isk *e*ncryption

(yubikey support for luKs)


Quick start:
------------

First install the package, then do something like the following:

    # uuidgen > /boot/yubikey-challenge
    # ykchalresp -2 $(cat /boot/yubikey-challenge)
    # cryptsetup luksAddKey /dev/sda2 <(ykchalresp -2 $(cat /boot/yubikey-challenge))

On bootup, you will be asked to insert a yubikey (2.2 or newer) which
will then provide the response.  If you do not want to use a yubikey,
press enter and then enter a normal passphrase during bootup.

Limitations/bugs:
-----------------
* uses only slot 2 ykchalresp settings, meaning no support for slot 1
* does not update the challenge after each boot.
* doesn't work for me, yet :-)
