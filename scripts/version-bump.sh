#!/bin/bash

set -eo pipefail

TINYALSA_ERR=0
TINYALSA_VER_FILE="include/tinyalsa/version.h"
TINYALSA_VER_PATTERN="^#define\([ \t]*\)"

function perror ()
{
  >&2 echo $1
}

function fatal ()
{
  perror "Fatal: $1"
  exit 1
}

function check_fatal ()
{
  [[ $? == 0 && $TINYALSA_ERR == 0 ]] || fatal "$1"
}

function check_errors ()
{
  [[ $? != 0 ]] && TINYALSA_ERR=$((TINYALSA_ERR+1))
}

function get_version()
{
  V=$(grep -m 1 "${TINYALSA_VER_PATTERN}${1}" ${TINYALSA_VER_FILE} | sed 's/[^0-9]*//g')

  if [[ -z $V ]]; then
    fatal "Could not get ${1} from ${TINYALSA_VER_FILE}"
  fi

  echo $V
}

function print_usage
{
  echo "Usage: $0 ACTION"
  echo
  echo "Possible actions:"
  echo "  --major   bump the major number"
  echo "  --minor   bumb the minor number"
  echo "  --patch   bump the patch number"
  echo "  --print   print the current version"
  echo "  --check   check all file with references to the current number"
  echo
  echo "Please run this script from the project root folder."
}

function print_version
{
  [[ -f ${TINYALSA_VER_FILE} ]] || perror "No version.h found! Are you in the project root?";

  TINYALSA_VER_MAJOR=$(get_version "TINYALSA_VERSION_MAJOR")
  TINYALSA_VER_MINOR=$(get_version "TINYALSA_VERSION_MINOR")
  TINYALSA_VER_PATCH=$(get_version "TINYALSA_VERSION_PATCH")

  if [[ -z $1 ]]; then
    printf "${TINYALSA_VER_MAJOR}.${TINYALSA_VER_MINOR}.${TINYALSA_VER_PATCH}"
  else
    case "$1" in
      major)
        printf "${TINYALSA_VER_MAJOR}"
        ;;
      minor)
        printf "${TINYALSA_VER_MINOR}"
        ;;
      patch)
        printf "${TINYALSA_VER_PATCH}"
        ;;
      *)
        fatal "Unknown part: $1 (must be one of minor, major and patch)"
        ;;
    esac
  fi

  return 0
}

# Checking parameters
if [[ $# == 0 ]]; then
  print_usage
  exit 0
fi

case "$1" in
  -s|--show)
    print_version "$2"
    exit $?
    ;;
  *) # preserve positional arguments
    fatal "Unsupported action: $1"
    ;;
esac

fatal "Internal error. Please report this."

set +eo pipefail
