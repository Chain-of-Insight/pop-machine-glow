#!/bin/bash

docker run -v "$PWD":/var/task "lambci/lambda:build-python3.7" /bin/sh -c "pip install -r requirements.txt -t python/lib/python3.7/site-packages/; exit"
docker run -v "$PWD":/var/task "lambci/lambda:build-python3.8" /bin/sh -c "pip install -r requirements.txt -t python/lib/python3.8/site-packages/; exit"

zip -r python3-pillow-numpy.zip python > /dev/null
