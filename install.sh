#!/usr/bin/env bash

STOCK_ROM_FILE="XT1900-1_PAYTON_FI_9.0_PPWS29.69-39-6-13_subsidy-DEFAULT_regulatory-DEFAULT_CFC.xml.zip"
STOCK_ROM_FILE_DOWNLOAD_URL="https://mirrors-obs-2.lolinet.com/firmware/motorola/2017/payton/official/FI/$STOCK_ROM_FILE"
STOCK_ROM_SHA256="1c6a084621799fc180d41949cc43a682e34ebb8f3211d5fbdb538cc75302b3ce"
STOCK_ROM_SHA256_FILE="$STOCK_ROM_FILE.sha256sum"

# set ".d" as the directory as ".xml" may be confusing for a directory name
STOCK_ROM_DIRECTORY="${STOCK_ROM_FILE%.*}.d"

error() {
    echo "ERROR: $1" >&2
}

error_exit() {
    local status="1"
    if [[ -n "$2" ]]; then
        status="$2"
    fi
    echo "ERROR: $1" >&2
    exit "$status"
}

warn() {
    echo "WARNING: $1" >&2
}

run() {
    if [[ -z "$1" ]]; then
        warn "run: no command line given"
        return 1
    elif [[ $DRY_RUN == "yes" ]]; then
        printf "DRY_RUN: "
        printf "%q " "$@"
        printf "\n"
        return 0
    fi

    "$@"
}

pop_directory() {
    if [[ $DRY_RUN == "yes" ]]; then
        echo "DRY_RUN: popd"
        return 0
    fi
    local current_directory="$PWD"
    popd >/dev/null || {
        local status="$?"
        if (( status != 0 )); then
            error "could not pop from directory '$current_directory'"
            return $status
        fi
    }
}

push_directory() {
    if [[ $DRY_RUN == "yes" ]]; then
        printf "DRY_RUN: pushd "
        printf "%q " "$@"
        printf "\n"
        return 0
    fi
    pushd "$1" >/dev/null || {
        local status="$?"
        if (( status != 0 )); then
            error "could not push into directory '$1'"
            return $status
        fi
    }
}

ARGS=$(getopt -o n --long dry-run -n 'install.sh' -- "$@")
r=$?
if [[ $r != 0 ]]; then
    exit $r
fi

eval set -- "$ARGS"

DRY_RUN="no"
while true; do
    case "$1" in
        -n|--dry-run)
            DRY_RUN="yes"
            shift
            ;;
        --)
            shift
            break
            ;;
        *)
            error_exit "unexpected argument: '$1'"
            ;;
    esac
done

if [[ -z "${BASH_SOURCE[0]}" ]]; then
    error_exit "could not determine directory of script source"
fi

SCRIPT_ROOT="${BASH_SOURCE%/*}"
cd "$SCRIPT_ROOT" || exit_error "could not change into script root directory '$SCRIPT_ROOT'"

downloaded="no"

if [[ ! -f $STOCK_ROM_FILE ]]; then
    echo "Downloading stock ROM file from '$STOCK_ROM_FILE_DOWNLOAD_URL'."
    run wget "$STOCK_ROM_FILE_DOWNLOAD_URL" || error_exit "could not download stock ROM from '$STOCK_ROM_DOWNLOAD_URL'"
    downloaded="yes"
fi

echo "Writing stock ROM file SHA256 sum to '$STOCK_ROM_SHA256_FILE'."
echo "$STOCK_ROM_SHA256 *$STOCK_ROM_FILE" > "$STOCK_ROM_SHA256_FILE" || error_exit "could not write SHA256 sum to '$STOCK_ROM_SHA256_FILE'"

echo "Verifying stock ROM file SHA256 sum matches '$STOCK_ROM_SHA256'."
run sha256sum -c "$STOCK_ROM_SHA256_FILE" || error_exit "could not verify SHA256 sum for file '$STOCK_ROM_FILE' with sum '$STOCK_ROM_SHA256'"

# transform a file like
# "XT1900-1_PAYTON_FI_9.0_PPWS29.69-39-6-13_subsidy-DEFAULT_regulatory-DEFAULT_CFC.xml.zip"
# into
# "PAYTON_FI_PPWS29.69-39-6-13_subsidy-DEFAULT_regulatory-DEFAULT_CFC.info.txt"
# using some hacky bash parameter expansions.
STOCK_ROM_FILE_EXPECTED="${STOCK_ROM_FILE/_9\.0_/_}"
STOCK_ROM_FILE_EXPECTED="${STOCK_ROM_FILE_EXPECTED#*_}"
STOCK_ROM_FILE_EXPECTED="${STOCK_ROM_FILE_EXPECTED%.*}"
STOCK_ROM_FILE_EXPECTED="${STOCK_ROM_FILE_EXPECTED%.*}.info.txt"

if [[ -d $STOCK_ROM_DIRECTORY ]]; then
    if [[ $downloaded == "yes" ]]; then
        echo "Removing '$STOCK_ROM_DIRECTORY' due to download."
        run rm -rf "$STOCK_ROM_DIRECTORY"
    # this is a kludgey way to test if everything has been unzipped or not
    elif [[ ! -f "$STOCK_ROM_DIRECTORY/$STOCK_ROM_FILE_EXPECTED" ]]; then
        echo "Removing '$STOCK_ROM_DIRECTORY' due to lack of expected info file."
        run rm -rf "$STOCK_ROM_DIRECTORY"
    fi
fi

if [[ ! -d $STOCK_ROM_DIRECTORY ]]; then
    run mkdir -p "$STOCK_ROM_DIRECTORY" || error_exit "could not make stock ROM directory '$STOCK_ROM_DIRECTORY'"
    push_directory "$STOCK_ROM_DIRECTORY" >/dev/null || exit $?
    run unzip "../$STOCK_ROM_FILE" || error_exit "could not unzip '$STOCK_ROM_FILE' into '$STOCK_ROM_DIRECTORY'"
    if [[ ! -f "$STOCK_ROM_DIRECTORY/$STOCK_ROM_FILE_EXPECTED" ]]; then
        error_exit "unzipped ROM download did not have expected file '$STOCK_ROM_FILE_EXPECTED'"
    fi
    pop_directory >/dev/null || error_exit "could not pop from stock ROM directory '$STOCK_ROM_DIRECTORY'"
fi

fastboot_device_count="$(fastboot devices -l | wc -l)"

if (( fastboot_device_count == 0 )); then
    error_exit "no fastboot devices found"
elif (( fastboot_device_count > 1 )); then
    error_exit "$fastboot_device_count devices found: cowardly refusing to continue with more than one device found: please verify only one device is connected before flashing"
fi

push_directory "$STOCK_ROM_DIRECTORY" || exit $?
run ../flash-all.sh
r=$?
if [[ $r == 0 ]]; then
    echo "Successfully flashed.  Phone should be rebooted."
else
    error_exit "flash-all.sh exited with status $r" $r
fi
