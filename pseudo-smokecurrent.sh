#! /bin/sh
#
# Uncomment this to be as nice as possible. (Jarkko)
# (renice -n 20 $$ >/dev/null 2>&1) || (renice 20 $$ >/dev/null 2>&1)

cd /home/jkeenan/p5smoke
date
date > /home/jkeenan/p5smoke/startsmoke
CFGNAME=${CFGNAME:-smokecurrent_config}
LOCKFILE=${LOCKFILE:-smokecurrent.lck}
continue=''
if test -f "$LOCKFILE" && test -s "$LOCKFILE" ; then
    echo "We seem to be running (or remove $LOCKFILE)" >& 2
    exit 200
fi
echo "$CFGNAME" > "$LOCKFILE"

PATH=.:/sbin:/bin:/usr/sbin:/usr/bin:/usr/local/sbin:/usr/local/bin:/home/jkeenan/bin:/home/jkeenan/bin/perl:/home/jkeenan/bin/shell
export PATH
umask 0
perl compress_logs.pl
perl ./tssmokeperl.pl -c "$CFGNAME" $continue $*

rm "$LOCKFILE"
date
date > /home/jkeenan/p5smoke/endsmoke
grep -E 'FAIL|http://' /home/jkeenan/p5smoke/smokecurrent.log | perl -p -e 's/^\[.*?\] //'

