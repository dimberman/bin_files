#!/bin/bash

PLAT=""
if [ "$1" = "-p" ]; then
    PLAT="--namespace=platform"
fi

if [ "$1" = "-sa" ]; then
    PLAT="--show-all"
fi

kubectl get pods $PLAT
