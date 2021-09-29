#!/bin/env bash

if [ "$1" == '-p' ]
then
    rm -rf pkg src
else
    rm -rf pkg src ./linux* ./config.last ./patch-* v*.patch
fi
