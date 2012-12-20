#!/bin/sh

#create working directory variable - automatic - will detect whatever directory you are currently in
PLACE=$(cd -P -- "$(dirname -- "$0")" && pwd -P)

sudo sh $PLACE/menu.sh
