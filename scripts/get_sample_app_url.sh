#!/bin/bash

# The script cancels execution on first error
set -e

cd infrastructure
cd workload

terraform output -raw app_url
