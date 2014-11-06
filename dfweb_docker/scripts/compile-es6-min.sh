#!/bin/sh

compile-modules convert $1 | yuglify --terminal > $2
