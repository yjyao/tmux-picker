#!/usr/bin/env bash

#
# HELPERS
#

CURRENT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TMUX_PRINTER="$CURRENT_DIR/tmux-printer/tmux-printer"

function set_tmux_env() {
    local option_name="$1"
    local final_value="$2"

    tmux setenv -g "$option_name" "$final_value"
}

function process_format () {
    echo -ne "$($TMUX_PRINTER "$1")"
}

function array_join() {
    local IFS="$1"; shift; echo "$*";
}

#
# CONFIG
#

# Every pattern have be of form ((A)B) where:
#  - A is part that will not be highlighted (e.g. escape sequence, whitespace)
#  - B is part will be highlighted (can contain subgroups)
#
# Valid examples:
#   (( )([a-z]+))
#   (( )[a-z]+)
#   (( )(http://)[a-z]+)
#   (( )(http://)([a-z]+))
#   (( |^)([a-z]+))
#   (( |^)(([a-z]+)|(bar)))
#   ((( )|(^))|(([a-z]+)|(bar)))
#   (()([0-9]+))
#   (()[0-9]+)
#
# Invalid examples:
#   (([0-9]+))
#   ([0-9]+)
#   [0-9]+

CS=$'\x1b'"\[[0-9;]{1,9}m" # color escape sequence
FILE_CHARS="[[:alnum:]_.#$%&+=/@~-]"
FILE_START_CHARS="[[:space:]:<>)(&#'\"]"

# default patterns group
PATTERNS_LIST1=(
"(($CS|^|$FILE_START_CHARS)$FILE_CHARS*/$FILE_CHARS+)" # file paths with /
"(()[0-9]+\.[0-9]{3,}|[0-9]{5,})" # long numbers
"(()[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})" # UUIDs
"(()[0-9a-f]{7,40})" # hex numbers (e.g. git hashes)
"(()(https?://|git@|git://|ssh://|ftp://|file:///)[[:alnum:]?=%/_.:,;~@!#$&)(*+-]*)" # URLs
"(()[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3}\.[[:digit:]]{1,3})" # IP adresses
"(()0x[0-9a-fA-F]+)" # hex numbers
)

# alternative patterns group (shown after pressing the SPACE key)
PATTERNS_LIST2=(
"(($CS|^|$FILE_START_CHARS)$FILE_CHARS*/$FILE_CHARS+)" # file paths with /
"(($CS|^|$FILE_START_CHARS)$FILE_CHARS{5,})" # anything that looks like file/file path but not too short
"(()(https?://|git@|git://|ssh://|ftp://|file:///)[[:alnum:]?=%/_.:,;~@!#$&)(*+-]*)" # URLs
)

# items that will not be hightlighted
BLACKLIST=(
"(deleted|modified|renamed|copied|master|mkdir|[Cc]hanges|update|updated|committed|commit|working|discard|directory|staged|add/rm|checkout)"
)

# "-n M-f" for Alt-F without prefix
# "f" for prefix-F
DEFAULT_PICKER_KEY="F"
PICKER_KEY=$(tmux show-option -gqv @picker-key)
PICKER_KEY=${PICKER_KEY:-$DEFAULT_PICKER_KEY}

set_tmux_env PICKER_PATTERNS1 $(array_join "|" "${PATTERNS_LIST1[@]}")
set_tmux_env PICKER_PATTERNS2 $(array_join "|" "${PATTERNS_LIST2[@]}")
set_tmux_env PICKER_BLACKLIST_PATTERNS $(array_join "|" "${BLACKLIST[@]}")

DEFAULT_COMMAND="xsel --clipboard -f"
COMMAND=$(tmux show-option -gqv @picker-command)
COMMAND=${COMMAND:-$DEFAULT_COMMAND}
set_tmux_env PICKER_COMMAND "$COMMAND"

DEFAULT_UPPERCASE_COMMAND="tmux set-buffer \"\$(cat -)\"; tmux paste-buffer"
UPPERCASE_COMMAND=$(tmux show-option -gqv @picker-uppercase-command)
UPPERCASE_COMMAND=${UPPERCASE_COMMAND:-$DEFAULT_UPPERCASE_COMMAND}
set_tmux_env PICKER_UPPERCASE_COMMAND "$UPPERCASE_COMMAND"

#set_tmux_env PICKER_HINT_FORMAT $(process_format "#[fg=color0,bg=color202,dim,bold]%s")

DEFAULT_PICKER_HINT_FORMAT="#[fg=color0,bg=color202,dim,bold]%s"
PICKER_HINT_FORMAT=$(tmux show-option -gqv @picker-hint-format)
PICKER_HINT_FORMAT=${PICKER_HINT_FORMAT:-$DEFAULT_PICKER_HINT_FORMAT}
set_tmux_env PICKER_HINT_FORMAT $(process_format $PICKER_HINT_FORMAT)
set_tmux_env PICKER_HINT_FORMAT_NOCOLOR "%s"

#set_tmux_env PICKER_HIGHLIGHT_FORMAT $(process_format "#[fg=black,bg=color227,normal]%s")

DEFAULT_PICKER_HL_FORMAT="#[fg=black,bg=yellow,bold]%s"
PICKER_HL_FORMAT=$(tmux show-option -gqv @picker-highlight-format)
PICKER_HL_FORMAT=${PICKER_HL_FORMAT:-$DEFAULT_PICKER_HL_FORMAT}
set_tmux_env PICKER_HINT_FORMAT $(process_format $PICKER_HINT_FORMAT)
set_tmux_env PICKER_HIGHLIGHT_FORMAT $(process_format $PICKER_HL_FORMAT)

DEFAULT_PICKER_HINT_FRONT=1
PICKER_HINT_FRONT=$(tmux show-option -gqv @picker-hint-front)
PICKER_HINT_FRONT=${PICKER_HINT_FRONT:-$DEFAULT_PICKER_HINT_FRONT}
set_tmux_env PICKER_HINT_FRONT "${PICKER_HINT_FRONT}"

#
# BIND
#

tmux bind-key $PICKER_KEY run-shell "$CURRENT_DIR/tmux-picker.sh"

