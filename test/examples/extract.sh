#!/bin/bash

# extract.sh
#
# Copyright (c) 2020 by Acme Company. All rights reserved.
#
# The copyright to the computer software herein is the property of
# Acme Company. The software may be used and/or copied only
# with the written permission of Acme Company or in accordance
# with the terms and conditions stipulated in the agreement/contract
# under which the software has been supplied.

ZIP_NAME=`ls acme-webapp-*.zip`
DIRNAME=`echo $ZIP_NAME | sed "s/\.zip//"`
rm -rf acme-webapp
unzip -o $ZIP_NAME
mv $DIRNAME acme-webapp
