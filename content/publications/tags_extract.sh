#! /bin/sh
grep tags: *.md | sed -e 's/:tags:/,/' > tags.csv
