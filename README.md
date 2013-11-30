ykfde
=====
YubiKey Full Disk Encryption

(yubikey support for LUKS)


Quick start:
------------

First install the package, then do something like the following (with your
yubikey plugged in!)

    # ykfdectl new

On bootup, you will be asked to insert a yubikey (2.2 or newer) which
will then provide the response.  If you do not want to use a yubikey,
press enter and then enter a normal passphrase during bootup.

Change the key
--------------

    # ykfdectl update

Changing the key on each reboot
-------------------------------

This is still very basic.

    # ln -s /usr/sbin/ykfdectl /etc/init.d/ykfdectl
    # ln -s /etc/init.d/ykfdectl /etc/rc2.d/S99ykfdectl


Limitations/bugs:
-----------------
* uses only slot 2 ykchalresp settings, meaning no support for slot 1
* might need more error-handling.
