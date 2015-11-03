ykfde
=====
YubiKey Full Disk Encryption

(yubikey support for LUKS)


Quick start:
------------

1. Build and install the package with "debuild" tool and dpkg

    $ debuild -us -uc

2. Edit /etc/default/ykfde to select the correct partition (default: /dev/sda2)
3. Use yubikey configuration tool to set a slot (default: slot #2) in hmac challenge-response mode
4. Use ykfdectl utility (installed by this package) to pair with your yubikey

    # ykfdectl new

On bootup, you will be asked to insert your yubikey (2.2 or newer) which
will then provide the response.  If you do not want to use a yubikey,
press enter and then enter a normal passphrase during bootup.

Change the key
--------------

    # ykfdectl update

Changing the key on each reboot
-------------------------------

This is still very basic.

    # update-rc.d ykfde defaults

Or if you use systemd:

    # systemctl enable ykfde.service

Configuration
-------------
see /etc/default/ykfde

Normaly used to select only the slot
    
    YKOPTS="-2"

The device which is used
    
    LUKS_DEVICE="/dev/sda2"

LUKS slot, where your yubikey-challenged key is stored
    
    LUKS_SLOT="7"

the challenge file, which is used to get a response
    
    CHALLENGE_FILE="/boot/yubikey-challenge"


Limitations/bugs:
-----------------
* might need more error-handling.
* lacks a two-factor-mode
