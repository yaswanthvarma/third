#!/bin/bash

if [[ "${myDebugMe}" == "debug" ]]; then
  export PS4='Line ${LINENO}: '
  set -x
fi

echo "bye bye"
exit

set_tsi_addresses() {
  to_addr=''
  mykomma=''

  for address in mandapati-yaswanth.varma@t-systems.com; do
    to_addr="${to_addr}${mykomma}${address}"
    mykomma=","
  done
}

set_mail_addresses() {
  mykomma=''
  to_addr=''

  for address in mandapati-yaswanth.varma@t-systems.com; do
    to_addr="${to_addr}${mykomma}${address}"
    mykomma=","
  done
}

set_directories() {
  myserverid=$(hostname | awk '{print substr($1, length($1) - 2, 3)}')
  mypwd=$(pwd)
  myorderpath=/home/mifweb
  myworkingPath=/home/mifweb/backups
  mylogs=/home/mifweb/backups/logs
  myRunningorder=.run_dumpeinspielen
  myDumpPath=/cluster/mif/data/mif_dump_einspielen
  myMifDumpsPath=/cluster/mif/data/mif_dump_daily

  echo "Start um $(date)"
}

set_dir_per_order() {
  mydbid=$(echo $TARGET_DB | cut -c7-8)
  myschemid=$(echo $TARGET_SCHEME | cut -c5-)
  sid=${myserverid}_${mydbid}_${myschemid}_$(date +%Y%m%d_%H%M)
  sids=${myserverid}_${mydbid}_${myschemid}_
  mylog=${sid}_${DATE_OF_DUMP}.log

  echo "Logfile ist $mylog"
}

ko_mail() {
  mv $myorderpath/$myRunningOrder $myorderpath/_failed_dumpeinspielen.c
  echo "Dump $mydumpdir ist nicht eingespielt auf Schema $TARGET_SCHEME Datenbank $TARGET_DB" >/tmp/mtext.$sid
  echo "" >>/tmp/mtext.$sid
  echo "Start: $mystartzeit" >>/tmp/mtext.$sid
  echo "Ende: $(date '+%d-%m-%Y %T')" >>/tmp/mtext.$sid
  echo "" >>/tmp/mtext.$sid
  echo "$errorText *****" >>/tmp/mtext.$sid

  [ -f /tmp/mtextc.$sid ] && cat /tmp/mtextc.$sid >>/tmp/mtext.$sid

  echo "" >>/tmp/mtext.$sid
  echo "Check logfiles in $mylogs" >>/tmp/mtext.$sid
  echo "" >>/tmp/mtext.$sid
  echo "" >>/tmp/mtext.$sid
  echo 'Dies ist eine generierte Mail' >>/tmp/mtext.$sid
  tail -200 /tmp/mtext.$sid | mailx -s "KO: Dump $mydumpdir auf hostname $TARGET_DB $TARGET_SCHEME" "$to_addr"
  \rm -rf /tmp/mtext.$sid
  myStatus=ko
}

ok_mail() {
  echo "Dump $mydumpdir ist erfolgreich eingespielt auf Schema $TARGET_SCHEME Datenbank $TARGET_DB" >/tmp/mtext.$sid
  echo "" >>/tmp/mtext.$sid
  echo "Start: $mystartzeit" >>/tmp/mtext.$sid
  echo "Ende: $(date '+%d-%m-%Y %T')" >>/tmp/mtext.$sid
  echo "" >>/tmp/mtext.$sid
  echo "Check logfiles in $mylogs" >>/tmp/mtext.$sid
  echo "" >>/tmp/mtext.$sid
  echo "" >>/tmp/mtext.$sid
  echo 'Dies ist eine generierte Mail' >>/tmp/mtext.$sid
  tail -200 /tmp/mtext.$sid | mailx -s "OK: Dump $mydumpdir auf hostname $TARGET_DB $TARGET_SCHEME" "$to_addr"
  \rm -rf /tmp/mtext.$sid
  \rm -f $myorderpath/$myRunningOrder
}

check_orders_available() {
  cd "$myorderpath"

  if [ "$myOrderParameter" -eq 11 ]; then
    orders=$(ls -tr .dumpeinspielen.* 2>/dev/null)
  else
    if [ -r "$myOrderParameter" ]; then
      orders="$myOrderParameter"
    else
      orders=""
    fi
  fi

  echo "Folgende Auftragsdateien: $orders"
}

wait_while_other_dump() {
  while [ -r "$myorderpath/.run_dumpeinspielen" ]; do
    echo "Es wird gerade ein Dump eingespielt $(date)"
    sleep 300
  done
}

wait_for_dump_transfer() {
  while [ "$DUMPEXIST" = 'no' ] && [ "$(date '+%H')" != "$TIMELIMIT" ]; do
    if [ -r "$myMifDumpsPath/$DATE_OF_DUMP" ] || [ -r "${DUMP_PATH}/$dumpname1" ] || [ -r "${DUMP_PATH}/$dumpname2" ]; then
      DUMPEXIST='yes'

      if [ -r "${DUMP_PATH}/$dumpname1" ] || [ -r "${DUMP_PATH}/$dumpname2" ]; then
        echo "Warte auf vollständige Übertragung $(date)"
        sleep 60
      fi
    else
      echo "Warte auf Dump... $DATE_OF_DUMP $(date)"
      sleep 300
    fi
  done

  if [ -r "$myMifDumpsPath/$DATE_OF_DUMP" ] || [ -r "${DUMP_PATH}/$dumpname1" ] || [ -r "${DUMP_PATH}/$dumpname2" ]; then
    echo "Dump ist da, Verarbeitung geht weiter"
    DUMPEXIST='yes'
  else
    echo "Abbruch. Dump existiert nicht $(date)"
    if [ "$DUMPEXIST" = 'no' ]; then
      errorText="Dump wurde nicht übertragen bis zum Zeitpunkt $TIMELIMIT Uhr."
    else
      errorText="Dump existiert nicht, obwohl im Auftrag 'yes' stand"
      DUMPEXIST="no"
    fi

    echo "$errorText"
    ko_mail # KO: Mail versenden mit errorText
  fi
}



dump_auspacken () {
  echo "Start Dump verarbeiten um $(date)"
  tstatus=0
  mydumpdir="${DATE_OF_DUMP}"
  keepDir='no'

  if [ -d "$myMifDumpsPath/$mydumpdir" ]; then # Dump exists as a directory in /mif_dumps
    keepDir='yes'
    myDumpPath="$myMifDumpsPath/$mydumpdir"
    cd "$myDumpPath"
    tstatus=$?
  else
    if [ -d "$myDumpPath/$mydumpdir" ]; then
      cd "$myDumpPath/$mydumpdir"
      tstatus=$?
    else
      mkdir -p "$myDumpPath/$mydumpdir"
      cd "$myDumpPath/$mydumpdir"

      if [ -r "${DUMP_PATH}/${dumpname1}" ]; then
        dumpname=$dumpname1
        gzip -dc "${DUMP_PATH}/${dumpname}" | tar xf - 
        tstatus=$?
      elif [ -r "${DUMP_PATH}/${dumpname2}" ]; then
        dumpname=$dumpname2
        tar xf "${DUMP_PATH}/${dumpname}"
        tstatus=$?
      fi
    fi
  fi
}

unzip_ixf_files () {
  # Namen des ausgepackten Verzeichnisses ermitteln kann vom Namen des Tar-Balls abweichen
  echo "Beginn von unzip_IXF_files"
  echo "Verzeichnis: $(pwd)"
  
  "ls -d $mydumpdir/*/:" "1s -d $mydumpdir/*/*"
  mysubdir=$(ls -d $mydumpdir/*/* 2>/dev/null)
  
  if [ -d "$mysubdir" ]; then
    echo "will change into subdir $mysubdir"
    cd "$mysubdir"
  fi

  # paralleles Entpacken
  gzip -d *.gz | egrep -v 'FK1R_SHAREDACCVAL.ixf.gz|FK1R_ELIMVAL.ixf.gz|FK1R_CONSACCVAL.ixf.gz|RQSTACCVAL.ixf.gz|FK1R_CASHFLOWEFFCT.ixf.gz|FK1R_SEMIPOSTREC.ixf.gz|FKIR_CONSREPITMVAL.ixf.gz|FK1R_CONSACCV_P.ixf.gz|FK1R_EVENTDATALOG.ixf.gz' 2>/dev/null &
  
  gzip -d FK1R_ROSTACCVAL.ixf.gz 2>/dev/null &
  gzip -d FK1R_CONSACCVAL.ixf.gz 2>/dev/null &
  gzip -d FK1R_ELIMVAL.ixf.gz 2>/dev/null &
  gzip -d FK1R_SHAREDACCVAL.ixf.gz 2>/dev/null &
  gzip -d FK1R_CASHFLOWEFFCT.ixf.gz FK1R_SEMIPOSTREC.ixf.gz 2>/dev/null &
  gzip -d FK1R_CONSREPITMVAL.ixf.gz FK1R_CONSACCV_P.ixf.gz FK1R_EVENTDATALOG.ixf.gz 2>/dev/null &
  
  wait
  
  gzip -d *.gz 2>/dev/null
}

# alle ixf-Files lesbar machen (fuer DB-Prozesse)
chmod -R 777 .

# touch FK1R_ROSTACCVAL.ixf FK1R_CONSACCVAL.ixf FK1R_ELIMVAL.ixf # fuer Testzwecke
ixfListe=$(ls *.ixf 2>/dev/null)

msg_file_content_to_log () {
  echo "Ende Dump einspielen um $(date)"
  msgliste=$(ls ${sids}*.msg 2>/dev/null)
  for melem in $msgliste; do
    echo
    echo "$melem"
    echo
    echo
    cat "$myDumpPath/$mydumpdir/$melem"
  done
}

clean_up_and_postwork () {
  cd "$myWorkingPath"
  echo "Ende um $(date)"
  
  if [ "$POSTWORK" != "" ]; then
    if [ -x "$myWorkingPath/post_dump.sh" ]; then
      "$myWorkingPath/post_dump.sh" "$TARGET_SCHEME" "$TARGET_DB"
    else
      echo "Prozedur $myDumpPath/post_dump.sh fehlt $(date)"
    fi
  else
    echo "Nacharbeiten sind nicht definiert $(date)"
  fi
  
  endzeit="$(date +%d-%m-%Y\ %T)"
}

check_logs () {
  check1=""
  check2=""
  check3=""
  check4=""
  check5=""
  
  if [ "$mylog" = "" ]; then
    if [ -r "$myWorkingPath/logs/$mylog" ]; then
      check1=$(grep 'nicht lesbar' "$myWorkingPath/logs/$mylog")
      check2=$(grep 'existiert nicht' "$myWorkingPath/logs/$mylog")
      check3=$(grep -v 'SQL3185W' "$myWorkingPath/logs/$mylog" | grep -i 'error')
      check4=$(grep -i 'SQLSTATE' "$myWorkingPath/logs/$mylog" | grep -vi FK1R CONSVERSION | grep -v 42601 | grep -vi FK1R_LEGALCONSVERS | grep -v 42704 | grep -iv 'SQLSTATE-02000')
      check5=$(grep -1 'SQL308' "$myWorkingPath/logs/$mylog")
    fi

    checki=$(grep -i '^SQL' "$myWorkingPath/logs/$mylog" | grep -v 1230w | grep -v 0100W)

    mqtlog=$(cat "$myWorkingPath/${sids}mqtlog" 2>/dev/null)
    rm -f "$myWorkingPath/${sids}mqtlog"

    if [ "$mqtlog" != "" ]; then
      echo 'Start MQT-Logfile' >> "$myWorkingPath/logs/$mylog"
      cat "$mqtlog" >> "$myWorkingPath/logs/$mylog"
      echo "Ende MQT-Logfile" >> "$myWorkingPath/logs/$mylog"
    fi

    if [ "$lstatus" -ne 0 ]; then
      myStatus='ko'
    fi

    echo "" > /tmp/mtextc.$sid

    if [ "$check1" != "" -o "$check2" != "" -o "$check3" != "" -o "$check4" != "" -o "$checks" != "" ]; then
      echo "" >> /tmp/mtextc.$sid
      echo "$check1" >> /tmp/mtextc.$sid
      echo "$check2" >> /tmp/mtextc.$sid
      echo "$check3" >> /tmp/mtextc.$sid
      echo "" >> /tmp/mtextc.$sid
      echo "Fehlermeldungen beim Einspielen des Dumps:" >> /tmp/mtextc.$sid
      echo "$check4" >> /tmp/mtextc.$sid
      echo "$checks" >> /tmp/mtextc.$sid
      echo "" >> /tmp/mtextc.$sid
      myStatus='ko'
    fi
  fi
}

#### MAIN ####

set_mail_addresses

#to_addr="thomas.awiszus@t-systems.com" #fuer tests TTT

set_directories

myOrderParameter=$2

check_orders_available

if [ "$orders" != "" ]; then

  for order in $orders; do
    myStatus=ok
    mystartzeit="$(date '+%d-%m-%Y %T')"

    wait_while_other_dump

    if [ -r "$myorderpath/$order" ]; then
      #Uebernahme der Variablen aus Dumpeinspiel-Auftrag
      . "$myorderpath/$order"
      cat "$myorderpath/$order"
      mv "$myorderpath/$order" "$myorderpath/$myRunningorder"

      set_dir_per_order

      echo "Dumpeinspielen $order ${DATE_OF_DUMP} in $TARGET_SCHEME on $TARGET_DB date"

      #Warten/pruefen bis/ob Dump da ist, wenn das im Auftrag mit exits="NO" gesetzt war
      wait_for_dump_transfer

      if [ "$DUMPEXIST" = 'yes' ]; then
        dump_auspacken

        if [ "$tstatus" != 0 ]; then
          echo "Fehler beim Auspacken des Dumps"
          errorText="Dump existiert, konnte aber nicht korrekt entpackt werden"
          ko_mail
        else
          unzip_ixf_files

          if [ "$ixfListe" = "" ]; then
            echo "keine ixf-Files gefunden"
            errorText="es konnten keine ixf-Files gefunden werden, Fehler im Verzeichnis (namen)?"
            ko_mail
          else
            echo "Start Dump einspielen um $(date)"
            su STARGET DB-c "$myworkingPath/load_schema.sh $TARGET_DB $TARGET_SCHEME $mydumpdir > $myWorkingPath/logs/$mylog 2>&1"
            lstatus=$?

            msg_file_content_to_log
            clean_up_and_postwork
            check_logs
          fi
        fi
      fi

      if [ "$myStatus" == 'ok' ]; then
        set_mail_addresses
        ok_mail
        #alles OK Mail versenden
      else
        set_tsi_addresses
        ko_mail
      fi

      #abgearbeiteten Auftrag entfernen
      \rm -rf "$myorderpath/$myRunningOrder"
    done

    [ "$keepDir" == "no" ] && \rm -rf "$myWorkingPath/$mydumpdir"

  else
    echo "Keine Angaben zum Dumpeinspielen gefunden"
    errorText="keine Angaben zum Dumpeinspielen gefunden ist KEIN Fehler!"
  fi

  echo "Ende um $(date)"
  exit 0


