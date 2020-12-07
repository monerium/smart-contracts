#!/bin/bash

[ $# -eq 1 ] || {
  echo "Usage: $0 <cid>"
  exit 1
}

cid=$1

cat monerium.tokenlist.json \
  | jq ".tokens = (.tokens|map(.logoURI = (.logoURI|split(\"/\")|.[2]=\"$cid\"|join(\"/\"))))" \
  | sponge monerium.tokenlist.json
