#!/bin/sh

# Read file of local deletes to process and rsync them up one at a time
# TODO: implement!

# sync up
rsync -v -a -u -X -A -e "ssh -p3237 -i $HOME/.ssh/id_rsa" /data/0f/sites/fingers.today/pages/ fingers.today@fingers.today:./sites/fingers.today/pages/ &&

# sync down
rsync -v -a -u -X -A -e "ssh -p3237 -i $HOME/.ssh/id_rsa" fingers.today@fingers.today:./sites/fingers.today/pages/ /data/0f/sites/fingers.today/pages/

# Read file of server deletes and rm them
# TODO: implement!
