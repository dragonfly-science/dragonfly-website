#!/bin/bash

synced=$(aws s3 sync _site s3://www.dragonfly.co.nz --acl public-read | sed 's/\r/\n/')
if [ "$synced" != "" ]; then 
  aws cloudfront create-invalidation --distribution-id $1 \
    --paths $(for s in $synced; do echo $s; done | grep _site | sed 's/_site//' | tr '\n' ' ' )
fi

