#!/bin/zsh

HoleCertURL="https://hole.cert.pl/domains/domains_hosts.txt"
HostsFile="/etc/hosts"
BackupFile="/etc/hosts_holecert.bak"
HoleCertStart="### Start of CERTPL HOLE content ###"
HoleCertStop="### End of CERTPL HOLE content ###"
TmpCertFile="/tmp/domains_hosts.txt"

unset HoleCertStartLine
unset HoleCertEndLine

if [ ! -f "$BackupFile" ]; then
    cp $HostsFile $BackupFile
fi

wget -O $TmpCertFile $HoleCertURL
if [[ $? -ne 0 ]]; then
    echo "wget failed"
    exit 1; 
fi

HoleCertStartLine=`awk "/$HoleCertStart/{ print NR; exit }" $HostsFile`
HoleCertEndLine=`awk "/$HoleCertStop/{ print NR; exit }" $HostsFile`

if [ $HoleCertStartLine ] && [ $HoleCertEndLine ]; then
        sed "/$HoleCertStart/,/$HoleCertStop/d" $HostsFile > $HostsFile.tmp
        echo -e '\n'$HoleCertStart >> $HostsFile.tmp
        cat $TmpCertFile >> $HostsFile.tmp
        echo -e '\n'$HoleCertStop >> $HostsFile.tmp
        mv $HostsFile.tmp $HostsFile
elif [ ! $HoleCertStartLine ] && [ ! $HoleCertEndLine ]; then
        cp $HostsFile $HostsFile.tmp
        echo -e '\n'$HoleCertStart >> $HostsFile.tmp
        cat $TmpCertFile >> $HostsFile.tmp
        echo -e '\n'$HoleCertStop >> $HostsFile.tmp
        mv $HostsFile.tmp $HostsFile
elif [ $HoleCertStartLine ] && [ ! $HoleCertEndLine ]; then
        sed "/$HoleCertStart/,/$HoleCertStop/d" $HostsFile > $HostsFile.tmp
        echo -e '\n'$HoleCertStart >> $HostsFile.tmp
        cat $TmpCertFile >> $HostsFile.tmp
        echo -e '\n'$HoleCertStop >> $HostsFile.tmp
        mv $HostsFile.tmp $HostsFile
elif [ ! $HoleCertStartLine ] && [ $HoleCertEndLine ]; then
        sed "/$HoleCertStop/d" $HostsFile > $HostsFile.tmp
        echo -e '\n'$HoleCertStart >> $HostsFile.tm
        cat $TmpCertFile >> $HostsFile.tm
        echo -e '\n'$HoleCertStop >> $HostsFile.tmp
        mv $HostsFile.tmp $HostsFile
fi
