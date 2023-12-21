#!/bin/bash

cd /home/mifweb/backups

excel_datum=$(date '+%d\.%m/%Y')
dump_datum=$(date --date='tomorrow' '+%y%m%d')
myserverid=$(hostname | awk '{print substr($1, length($1) - 2, 3)}')
heutiger_auftrag=$(grep "$excel_datum" "regel_dumps_auftrag_$myserverid.txt")
timelimit=05
dumpexists=no
secondslater=0

if [ $(echo $heutiger_auftrag | wc -w) -gt 1 ]; then
    for schema in $(echo $heutiger_auftrag | cut -d' ' -f2- | tr [a-z] [A-Z]); do
        myfile="/home/mifweb/.dumpeinspielen.${schema}.$$"
        targetdb=fk1xap03 # usually it is this database !!!

 # ????? THIS MUST BE ADJUSTED FOR FINAL CONFIGURATION !!!!!!!!!!
        if [ "$myserverid" == "090" ]; then
            if [ "${schema}" = "FK1C_T18" ]; then
                targetdb=fk1xap09
            fi
        fi

        sleep $secondslater

        echo "DATE_OF_DUMP=\"sedcbmif1100_Dump-${dump_datum}\"" > $myfile
        echo "TARGET_SCHEME=\"${schema}\"" >> $myfile
        echo "TARGET_DB=\"${targetdb}\"" >> $myfile
        echo "TARGET_SERVER=\"${myserverid}\"" >> $myfile
        echo "DUMP_PATH=\"/srv/mif/data/mif_dumps\"" >> $myfile
        echo "DUMPEXIST=\"${dumpexists}\"" >> $myfile
        echo "TIMELIMIT=\"${timelimit}\"" >> $myfile
        echo "POSTWORK=\"\"" >> $myfile

        chmod 666 $myfile
        timelimit=""
        dumpexists=yes
        secondslater=60
    done
fi

exit 0
