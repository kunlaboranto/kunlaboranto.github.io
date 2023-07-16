#!/bin/bash

#
# http://svn.apache.org/repos/asf/cxf/trunk/bin/set_svn_properties.sh
#

echo "svn propset svn:mime-type text/xml *.xml"
# find . -name \*.xml | xargs svn propset svn:mime-type text/xml
