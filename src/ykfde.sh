#!/bin/bash -e

# set the defaults
YKOPTS="-2"
LUKS_DEVICE="/dev/sda2"
LUKS_SLOT="7"
CHALLENGE_FILE="/boot/yubikey-challenge"


# read defaults..
if [ -e /etc/default/ykfde ]; then
    . /etc/default/ykfde

    if [ "${LUKS_SLOT}" == "multi" ]; then
        echo -ne "LUKS_SLOT is set to 'multi': "
        . /etc/ykfde.conf
        YK_SERIAL="$(ykinfo -s | awk '{print $NF}')"
        for (( i = 0; i < 8; i++ )); do
            if [ "${LUKS_SLOT[${i}]}" == "${YK_SERIAL}" ]; then
                LUKS_SLOT=${i}
                echo "Using slot ${i}"
            fi
        done
    fi
    if [ "${LUKS_SLOT}" == "multi" ]; then
        echo "No matching Yubikey found".
        exit 2
    fi
fi


function get_new_challenge () { # {{{
    if [ -z ${CHALLENGE} ]; then
        export CHALLENGE="$(dd if=/dev/urandom bs=64 count=2 2> /dev/null | base64 | head -c 64)"
        if ykinfo $YKOPTS >/dev/null ; then
            echo -ne "${CHALLENGE}" > ${CHALLENGE_FILE}.new
            chmod 400 ${CHALLENGE_FILE}.new
        else
            exit 1
        fi
    fi
} # }}}

function get_old_challenge () { # {{{
    if [ -z ${OLD_CHALLENGE} ]; then
        export OLD_CHALLENGE="$(cat ${CHALLENGE_FILE})"
        mv ${CHALLENGE_FILE} ${CHALLENGE_FILE}.old
    fi
} # }}}

function add_new_key () { # {{{
    cryptsetup luksAddKey \
        --key-slot ${LUKS_SLOT} ${LUKS_DEVICE} \
        <(ykchalresp ${YKOPTS} ${CHALLENGE})

    if [ "${?}" == "0" ]; then
        mv  ${CHALLENGE_FILE}.new ${CHALLENGE_FILE}
    fi
} # }}}

function update_key () { # {{{
    OLD_KEY="$(ykchalresp ${YKOPTS} ${OLD_CHALLENGE})"

    cryptsetup luksChangeKey \
        --key-slot ${LUKS_SLOT} ${LUKS_DEVICE} \
        --key-file <( echo "${OLD_KEY}" ) <(ykchalresp ${YKOPTS} ${CHALLENGE})

    if [ "${?}" == "0" ]; then
        mv  ${CHALLENGE_FILE}.new ${CHALLENGE_FILE} && \
        rm  -f ${CHALLENGE_FILE}.old
    fi

} # }}}

function print_help () { # {{{

    echo "Usage: $0 (new|update|start|stop)"

} # }}}

case $1 in
    new)
        echo -ne "getting new key..."
        get_new_challenge && echo "OK"
        echo -ne "adding new key..."
        add_new_key && echo "OK"
        /usr/sbin/update-initramfs -u -k "$(uname -r)"

    ;;
    update|start)
        echo -ne "getting keys..."
        get_new_challenge && echo -ne '.'
        get_old_challenge && echo 'OK'
        echo -ne "changing key..."
        update_key && echo 'OK'
        /usr/sbin/update-initramfs -u -k "$(uname -r)"
    ;;
    stop)
        echo "Nothing to do"
    ;;
    *)
        print_help
    ;;
esac


