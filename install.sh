#!/bin/bash

set -o pipefail

# Safety Checks
DESTRUCTIVE=false

# Metadata
VERSION="0.0.1"

# Colors
CBORDER=243
CTEXT=255
CHEADER=4
CHIGHLIGHT=6

# Welcome
clear

gum style \
	--border rounded \
	--align center \
	--padding "0 3" \
	--border-foreground $CBORDER \
	--foreground $CTEXT \
	"Stave v$VERSION" \
	"for $OS_NAME"

gum input \
	--placeholder='Press enter to begin installation' \
	--prompt=''

# Location
TZ=$(timedatectl list-timezones \
	| gum filter \
	--header 'Select your timezone:' \
	--placeholder 'UTC' \
	--cursor-text.foreground $CHIGHLIGHT \
	--indicator.foreground $CHIGHLIGHT \
	--header.foreground $CHEADER \
) || TZ='UTC'

LC=$(locale -a \
	| gum filter \
	--header 'Select your locale:' \
	--placeholder 'en_US.utf8' \
	--cursor-text.foreground $CHIGHLIGHT \
	--indicator.foreground $CHIGHLIGHT \
	--header.foreground $CHEADER \
) || LOCALE='en_US.utf8'

# Keyboard
KBL=$(localectl list-x11-keymap-layouts \
	| gum filter \
	--header 'Select a keyboard layout:' \
	--placeholder 'us' \
	--cursor-text.foreground $CHIGHLIGHT \
	--indicator.foreground $CHIGHLIGHT \
	--header.foreground $CHEADER \
) || KBL='us'

if [[ -n $(localectl list-x11-keymap-variants "$KBL") ]]; then
	KBV=$(localectl list-x11-keymap-variants "$KBL" \
		| gum filter \
		--header 'Select your keyboard variant:' \
		--placeholder 'altgr-intl' \
		--cursor-text.foreground $CHIGHLIGHT \
		--indicator.foreground $CHIGHLIGHT \
		--header.foreground $CHEADER \
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

# Users
ADMIN=$(gum input \
	--placeholder 'root' \
	--header 'Enter a name for the root account:' \
	--header.foreground $CHEADER \
) || ADMIN='root'
APASSWD=$(gum input \
	--password \
	--placeholder 'Password' \
	--header 'Enter a root password:' \
	--header.foreground $CHEADER \
)

USERNAME=$(gum input \
	--placeholder 'user' \
	--header 'Enter a name for your account:' \
	--header.foreground $CHEADER \
) || USER='user'
UPASSWD=$(gum input \
	--password \
	--placeholder 'Password' \
	--header 'Enter your password:' \
	--header.foreground $CHEADER \
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
echo "Root,$ADMIN" >> config.csv
echo "User,$USERNAME" >> config.csv

# # Print Information
gum table \
	-p \
	--border.foreground="$CBORDER" \
	< ./config.csv

# Confirmation
