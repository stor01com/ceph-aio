#/bin/bash

vagrant status | \
awk '
BEGIN{ tog=0; }
/^$/{ tog=!tog; }
/./ { if(tog){print $1} }
' | \

xargs -P4 -I {} gnome-terminal -x bash -c "vagrant up --provision {}; exec bash"
