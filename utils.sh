#!/bin/bash
function check_if_root {
  if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
  fi
}
