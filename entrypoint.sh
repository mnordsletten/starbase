#!/bin/bash

# fixuid gives the user in the container the same uid:gid as specified when running
# docker run with --user uid:gid. This is to prevent file permission errors
eval $( fixuid &> /dev/null )
exec "$@"
