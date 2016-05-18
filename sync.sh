#!/bin/bash

synced=$(aws s3 sync s3://wwwtest.dragonfly.co.nz s3://www.dragonfly.co.nz --acl public-read | tr -d "\r")

if [ "$synced" != "" ]; then 
  aws cloudfront create-invalidation --distribution-id $1 \
    --paths $(for s in $synced; do echo $s; done | grep wwwtest | sed 's/s3\:\/\/wwwtest\.dragonfly\.co\.nz//' | tr '\n' ' ' )
fi

