

wait_for_dump_transfer () {
    while [ "$DUMPEXIST" = 'no' -a "$(date '+%H')" != "$TIMELIMIT" ]; do
        if [ -r "$DUMP_PATH/$dumpname1" -o -r "$DUMP_PATH/$dumpname2" ]; then
            DUMPEXIST='yes' # End the loop
            echo "Warte auf vollstaendige Uebertragung um $(date)"
            sleep 60
        else
            # Check every 5 minutes if the dump is available
            echo "Warte auf Dump... $(date)"
            sleep 300
        fi
    done

    if [ "$DUMPEXIST" = 'no' ]; then
        errorText="Dump wurde nicht übertragen bis zum Zeitpunkt $TIMELIMIT Uhr."
    else
        echo "Dump ist da, Verarbeitung geht weiter"
    fi

    if [ -r "$DUMP_PATH/$dumpname1" -o -r "$DUMP_PATH/$dumpname2" ]; then
        echo "Dump ist da, Verarbeitung geht weiter"
        DUMPEXIST='yes'
    else
        # No dump, now differentiate whether it was not delivered in time
        echo "Liste Verzeichnisinhalt am $(date)"
        ls -altr "$DUMP_PATH"/* 2>/dev/null
        echo "Abbruch. Dump existiert nicht $(date)"
        DUMPEXIST='no'
        errorText="Dump existiert nicht, obwohl im Auftrag 'yes' stand"
    fi

    echo "$errorText"

    # Send mail if necessary
    if [ "$DUMPEXIST" = 'no' ]; then
        mail -s "KO: Dump Transfer Error" your_email@example.com <<< "$errorText"
    fi
}

dump_auspacken () {
    echo "Start Dump verarbeiten um $(date)"
    tstatus=0
    mydumpdir="$(DATE_OF_DUMP)"

    if [ -d "$myworkingPath/$mydumpdir" ]; then
        cd "$myworkingPath/$mydumpdir"
        tstatus=$?
    else
        cd "$myworkingPath"
        # Remove old dumps which are unzipped
        rm -rf $(ls -d mif1pedl*/)
        mkdir -p "$myworkingPath/$mydumpdir"
        cd "$myworkingPath/$mydumpdir"
    fi

    if [ -r "$(DUMP_PATH)/$dumpname1" ]; then
        dumpname=$dumpname1
        gzip -dc "$(DUMP_PATH)/$dumpname" | tar xf -
        tstatus=$?
    elif [ -r "$(DUMP_PATH)/$dumpname2" ]; then
        dumpname=$dumpname2
        tar xf "$(DUMP_PATH)/$dumpname"
        tstatus=$?
    fi

    # Check the status and take appropriate actions
    if [ "$tstatus" -eq 0 ]; then
        echo "Dump verarbeitet erfolgreich."
    else
        echo "Fehler beim Verarbeiten des Dumps. Status: $tstatus"
    fi
}

#!/bin/bash
set mail addresses () {
to_addr='' ; mykomma=''
for address in \
mandapati-yaswanth.varma@t-systems.com
do
to_addr="$(to_addr)"$mykomma$address
mykomma=","
done
}
set_directories () {
mypwd=`pwd`
myworkingPath=/cluster/mif/data/mif_dump_daily
mylogs=/home/mifweb/backups/logs
myDumpPath=/cluster/mif/data/mif_dump_daily
DATE_OF_DUMP="mif1pedl_Dump- `TZ=GMT+22 date +%y%m%d`"
DUMP_PATH=/cluster/mif/data/mif_dumps
DUMPEXIST="no"
TIMELIMIT="24"
errorText=""
myhost=`hostname`

echo "Logfile ist $mylog"
echo Start um `date
}

ko_mail () {
echo ''                                      >>/tmp/mtext.$$
echo "Nein, Dump" $mydumpdir ist nicht'(!)' vollstaendig korrekt ausgepackt auf $myworkingPath >>/tmp/mtext.$$
echo ''                                      >>/tmp/mtext.$$

echo Sstart: $mystartzeit>>/tmp/mtext.$$
echo ''                                      >>/tmp/mtext.$$
echo Ende : `date '+%d-%m-%y %T'`            >>/tmp/mtext.$$
echo ''                                      >>/tmp/mtext.$$
echo"$errorText">>/tmp/mtext.$s
echo ''                                      >>/tmp/mtext.$$
echo check logfiles in $mylogs>>/tmp/mtext.$$
echo>>/tmp/mtext.$$echo>>/tmp/mtext.$$
echo 'Dies ist eine generierte Mail'> /tmp/mtext.$$

cat / tmp/mtext.$$ I mailx -s "KO: Dump aupspacken von $mydumpdir auf $myhost" "$to_addr"\rm -rf /tmp/mtext.$$mystatus-kook_mail ()fecho '>/tmp/mtext.$secho Dump $mydumpdir ist erfolgreich ausgepackt auf $myworkingPath >>/tmp/mtext.$$2echo>>/tmp/mtext.$$echo Start: $mystartzeit>>/tmp/mtext.$$echo Ende : `date "+%d-%m-%y %T>>/tmp/wtext.$$Iecho :>>/tmp/mtext.$$echo Check logfiles in $mylogs>>/tmp/mtext.$$echo>>/tmp/mtext.$$echo>>/tmp/mtext.$$echo Dies ist eine generierte Mail'>/tmp/mtext.$$cat /tmp/mtext.$$ I mailx -s "OK: Dump aupspacken von $mydumpdir auf $myhost" "$to_addr"\rm -rf /tmp/mtext.$$}



wait_for_dump_transfer () {
    while [ "$DUMPEXIST" = 'no' -a "$(date '+%H')" != "$TIMELIMIT" ]; do
        if [ -r "$DUMP_PATH/$dumpname1" -o -r "$DUMP_PATH/$dumpname2" ]; then
            DUMPEXIST='yes' # End the loop
            echo "Warte auf vollstaendige Uebertragung um $(date)"
            sleep 60
        else
            # Check every 5 minutes if the dump is available
            echo "Warte auf Dump... $(date)"
            sleep 300
        fi
    done

    if [ "$DUMPEXIST" = 'no' ]; then
        errorText="Dump wurde nicht übertragen bis zum Zeitpunkt $TIMELIMIT Uhr."
    else
        echo "Dump ist da, Verarbeitung geht weiter"
    fi

    if [ -r "$DUMP_PATH/$dumpname1" -o -r "$DUMP_PATH/$dumpname2" ]; then
        echo "Dump ist da, Verarbeitung geht weiter"
        DUMPEXIST='yes'
    else
        # No dump, now differentiate whether it was not delivered in time
        echo "Liste Verzeichnisinhalt am $(date)"
        ls -altr "$DUMP_PATH"/* 2>/dev/null
        echo "Abbruch. Dump existiert nicht $(date)"
        DUMPEXIST='no'
        errorText="Dump existiert nicht, obwohl im Auftrag 'yes' stand"
    fi

    echo "$errorText"

    # Send mail if necessary
    if [ "$DUMPEXIST" = 'no' ]; then
        mail -s "KO: Dump Transfer Error" your_email@example.com <<< "$errorText"
    fi
}

dump_auspacken () {
    echo "Start Dump verarbeiten um $(date)"
    tstatus=0
    mydumpdir="$(DATE_OF_DUMP)"

    if [ -d "$myworkingPath/$mydumpdir" ]; then
        cd "$myworkingPath/$mydumpdir"
        tstatus=$?
    else
        cd "$myworkingPath"
        # Remove old dumps which are unzipped
        rm -rf $(ls -d mif1pedl*/)
        mkdir -p "$myworkingPath/$mydumpdir"
        cd "$myworkingPath/$mydumpdir"
    fi

    if [ -r "$(DUMP_PATH)/$dumpname1" ]; then
        dumpname=$dumpname1
        gzip -dc "$(DUMP_PATH)/$dumpname" | tar xf -
        tstatus=$?
    elif [ -r "$(DUMP_PATH)/$dumpname2" ]; then
        dumpname=$dumpname2
        tar xf "$(DUMP_PATH)/$dumpname"
        tstatus=$?
    fi

    # Check the status and take appropriate actions
    if [ "$tstatus" -eq 0 ]; then
        echo "Dump verarbeitet erfolgreich."
    else
        echo "Fehler beim Verarbeiten des Dumps. Status: $tstatus"
    fi
}

unzip_ixf_files() {
    echo "Beginn von unzip IxF files"
    echo "Verzeichnis: $(pwd)"
    ls -1
    mysubdir=$(ls -d */*)
    
    if [ -d "$mysubdir" ]; then
        echo "will change into subdir $mysubdir"
        cd "$mysubdir"
    else
        echo "end of procedure with subdir"
    fi
    
    gzip -d $(ls *.gz | egrep -v "FK1R_SHAREDACCVAL.ixf.gz|FK1R_ELIMVAL.ixf.gz|FK1R_CONSACCVAL.ixf.gz|FK1R_RQSTACCVAL.ixf.gz|FK1R_CASHFLOWEFFCT.ixf.gz|FK1R_SEMIPOSTREC.ixf.gz|FK1R_CONSREPITMVAL.ixf.gz|FK1R_CONSACCV_P.ixf.gz|FK1R_EVENTDATALOG.ixf.gz") 2>/dev/null &
    gzip -d FK1R_RQSTACCVAL.ixf.gz 2>/dev/null &
    gzip -d FK1R_CONSACCVAL.ixf.gz 2>/dev/null &
    gzip -d FK1R_ELIMVAL.ixf.gz 2>/dev/null &
    gzip -d FK1R_SHAREDACCVAL.ixf.gz 2>/dev/null &
    gzip -d FKIR_CASHFLOWEFFCT.ixf.gz FKIR_SEMIPOSTREC.ixf.gz 2>/dev/null &
    gzip -d FK1R_CONSREPITMVAL.ixf.gz FK1R_CONSACCV_P.ixf.gz FK1R_EVENTDATALOG.ixf.gz 2>/dev/null &
    wait
    
    echo "aktuelles Verzeichnis: $(pwd)"
    echo "ls -l *.gz - should be empty:"
    ls -1 *.gz
    gzip -d *.gz
    
    echo "Platz im Verzeichnis (df -h .):"
    echo "Datum Uhrzeit: $(date)"
    df -h .
    
    gz_liste=$(ls *.gz 2>/dev/null)
    
    if [ "$gz_liste" != "" ]; then
        sleep 900
        gzip -d *.gz
        
        echo "warte 15 Minuten fuer wiederholten Versuch auszupacken"
        
        echo "Platz im Verzeichnis (df -h .):"
        echo "Datum Uhrzeit: $(date)"
        df -h
    fi
    
    # alle ixf-Files lesbar machen (fuer DB-Prozesse)
    chmod -R +rw "$myworkingPath/$mydumpdir"
    
    # for Test: touch FK1R_RQSTACCVAL.ixf FK1R_CONSACCVAL.ixf FK1R_ELIMVAL.ixf
    ixfListe=$(ls *.ixf 2>/dev/null)
    gz_liste=$(ls *.gz 2>/dev/null)
}

## MAIN ##
set_mail_addresses
#to_addr="thomas.awiszus@t-systems.com" #fuer tests TTT
mylog=$1
set directories
myStatus=ok
mystartzeit="`date +%d-%m-%Y %T`"
echo "Dump Bereitstellen ${DATE_OF_DUMP}... `date`"; echo

# Dump Name Formatting
dumpname1="${DATE_OF_DUMP}.tar.gz"; dumpname2="${DATE_OF_DUMP}.tar"

# Wait for Dump Transfer
wait_for_dump_transfer

# Dump Existence Check
if [ "$DUMPEXIST" = 'yes' ]; then
    dump_auspacken
fi

# Check for Unpacking Errors
if [ "$tstatus" != 0 ]; then
    echo "Fehler beim Auspacken des Dumps"
    errorText="ERROR 11"
    ko_mail
else
    unzip_ixf_files

    # Check for ixf-Files
    if [ "$ixfListe" = "" ]; then
        echo "keine ixf-Files gefunden"
        errorText="ERROR?"
        ko_mail
    fi

    # Check if all Files are Unpacked
    if [ "$gz_liste" != "" ]; then
        echo "nicht alle Dateien ausgepackt"
        errorText="ERROR"
        ko_mail
    fi
fi

# End Time Formatting
endetzeit="`date +%d-%m-%Y %T`"
echo "Ende um `date`"

# OK Mail Check
[ "$myStatus" == 'ok' ] && ok mail

# Mail versenden
# Save the packed dump for MIF internal archiving of interesting dumps for AM
# cp -a /cluster/mif/dailydump/fk1xap03/$dumpname2* /cluster/mif/data/mif_dumps
exit 0



