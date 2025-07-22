#!/bin/bash

set -o pipefail

# Safety Checks
DESTRUCTIVE=false
CONFIRM=false

# Metadata
VERSION="0.0.1"

# Colors
CBORDER=243
CTEXT=255
CHEADER=4
CHIGHLIGHT=6
CCONFIRM=2
CERROR=1
CWARN=3
CEMPTY=238

# Functions (non-destructive)
printi() {
	gum style \
		--margin "0 1" \
		--foreground $CHIGHLIGHT \
		"$1"
}

# Functions (destructive)
deps() {
	cat deps opt-deps | pacman -S
}
location() {
	echo "$LC" >> /etc/locale.gen
	locale-gen
	echo "LANG=$LC" >> /etc/locale.conf
}
# filesystem() {}
user() {
	echo "$APASSWD" | passwd -s
	useradd $USERNAME
	echo "$UPASSWD" | passwd -s $USERNAME

	if $UWHEEL; then
		usermod -a -G wheel $USERNAME
	fi
}
# bootloader() {}
# refind() {}
# grub() {}
# limine() {}

# Welcome
clear

gum style \
	--border rounded \
	--align center \
	--margin "1 0 0 1" \
	--padding "0 3" \
	--border-foreground $CBORDER \
	--foreground $CTEXT \
	"Stave v$VERSION" \
	"for $OS_NAME"

gum input \
	--placeholder='Press enter to begin installation' \
	--prompt='' \
	--cursor.foreground $CHIGHLIGHT

# Location
TZ=$(timedatectl list-timezones \
	| gum filter \
	--header 'Select your timezone:' \
	--placeholder 'UTC' \
	--cursor-text.foreground $CHIGHLIGHT \
	--indicator.foreground $CHIGHLIGHT \
	--header.foreground $CHEADER \
	--match.foreground $CHIGHLIGHT \
) || TZ='UTC'

LC=$(locale -a \
	| gum filter \
	--header 'Select your locale:' \
	--placeholder 'en_US.utf8' \
	--cursor-text.foreground $CHIGHLIGHT \
	--indicator.foreground $CHIGHLIGHT \
	--header.foreground $CHEADER \
	--match.foreground $CHIGHLIGHT \
) || LOCALE='en_US.utf8'

# Keyboard
KBL=$(localectl list-x11-keymap-layouts \
	| gum filter \
	--header 'Select a keyboard layout:' \
	--placeholder 'us' \
	--cursor-text.foreground $CHIGHLIGHT \
	--indicator.foreground $CHIGHLIGHT \
	--header.foreground $CHEADER \
	--match.foreground $CHIGHLIGHT \
) || KBL='us'

if [[ -n $(localectl list-x11-keymap-variants "$KBL") ]]; then
	KBV=$(localectl list-x11-keymap-variants "$KBL" \
		| gum filter \
		--header 'Select your keyboard variant:' \
		--placeholder 'altgr-intl' \
		--cursor-text.foreground $CHIGHLIGHT \
		--indicator.foreground $CHIGHLIGHT \
		--header.foreground $CHEADER \
		--match.foreground $CHIGHLIGHT \
	) || KBV='altgr-intl'
fi

# Filesystem
export FSTYPES=$(cat <<END
btrfs
ext4
f2fs
xfs
zfs
END
)

FS=$(echo "$FSTYPES" \
	| gum choose \
	--header 'Select a filesystem to use:' \
	--selected.foreground $CHIGHLIGHT \
	--cursor.foreground $CHIGHLIGHT \
	--header.foreground $CHEADER \
) || FS='xfs'

# Bootloader
export BOOTLOADERS=$(cat <<END
rEFInd
GRUB
limine
END
)


BOOTLOADER=$(echo "$BOOTLOADERS" \
	| gum choose \
	--header 'Select a bootloader to use:' \
	--selected.foreground $CHIGHLIGHT \
	--cursor.foreground $CHIGHLIGHT \
	--header.foreground $CHEADER \
) || BOOTLOADER="rEFInd"

# Shell
export SHELLS=$(cat <<END
zsh
bash
fish
nushell
elvish
END
)


USERSHELL=$(echo "$SHELLS" \
	| gum choose \
	--header 'Select a shell to use:' \
	--selected.foreground $CHIGHLIGHT \
	--cursor.foreground $CHIGHLIGHT \
	--header.foreground $CHEADER \
) || USERSHELL="zsh"

# Users
APASSWD=$(gum input \
	--password \
	--placeholder 'Password' \
	--header 'Enter a root password:' \
	--header.foreground $CHEADER \
	--cursor.foreground $CHIGHLIGHT \
)

USERNAME=$(gum input \
	--placeholder 'user' \
	--header 'Enter a name for your account:' \
	--header.foreground $CHEADER \
	--cursor.foreground $CHIGHLIGHT \
) || USER='user'
UPASSWD=$(gum input \
	--password \
	--placeholder 'Password' \
	--header 'Enter your password:' \
	--header.foreground $CHEADER \
	--cursor.foreground $CHIGHLIGHT \
)
UWHEEL=$(gum confirm \
	"Would you like to give the user account sudo access?" \
	--affirmative "Yes" \
	--negative "No" \
	--selected.foreground $CEMPTY \
	--selected.background $CHIGHLIGHT \
	--unselected.foreground $CTEXT \
	--unselected.background $CEMPTY \
	&& UWHEEL=true || UWHEEL=false \
)

if [[ -z "$ADMIN" ]]; then
	ADMIN='root'
fi
if [[ -z "$USERNAME" ]]; then
	USERNAME='user'
fi

# Store Information
echo "Options,Selected" > config.csv
echo "Timezone,$TZ" >> config.csv
echo "Locale,$LC" >> config.csv
echo "Keyboard,$KBL $KBV" >> config.csv
echo "FS Type,$FS" >> config.csv
echo "Bootloader,$BOOTLOADER" >> config.csv
echo "Shell,$USERSHELL" >> config.csv
echo "Root,$ADMIN" >> config.csv
echo "User,$USERNAME" >> config.csv

# Confirmation
if gum confirm \
	"$(gum table \
		-p \
		--border.foreground $CBORDER \
		< ./config.csv \
	)"\
	--affirmative "Install" \
	--negative "Cancel" \
	--selected.foreground $CEMPTY \
	--selected.background $CHIGHLIGHT \
	--unselected.foreground $CTEXT \
	--unselected.background $CEMPTY; then
	CONFIRM=true
else
	echo "Exiting..."
	exit 0
fi

sleep 1

if $CONFIRM; then
	printi "Installation confirmed..."
	sleep 1
fi
if ! $DESTRUCTIVE; then
	printi "Destrucive mode is off..."
	sleep 1
fi

clear

gum style \
	--border rounded \
	--align center \
	--margin "0 1" \
	--padding "0 3" \
	--border-foreground $CCONFIRM \
	--foreground $CCONFIRM \
	"Beginning installation of $OS_NAME"

sleep 0.25

echo "$BOOTLOADER" > opt-deps

printi "Elevating priveleges..."

if $DESTRUCTIVE; then
	su
fi

printi "Installing base packages..."

if ! $DESTRUCTIVE; then
	printi "$(cat deps opt-deps)"
else
	deps
	printi "Setting up keyboard and locale..."
	location
	printi "Partioning the disk..."
	# filesystem
	printi "Configuring the bootloader..."
	# bootloader
	printi "Setting up user accounts..."
	users
fi

printi "Done!"
gum input \
	--placeholder='Press enter to reboot' \
	--prompt='' \
	--cursor.foreground $CHIGHLIGHT

if $DESTRUCTIVE; then
	reboot
fi
