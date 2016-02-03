PS1="$"
PS2=">"
xml_version="<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
xsl_bind="<?xml-stylesheet type=\"text/xsl\" href=\"template.xsl\"?>"
CDATA[0]="<\![CDATA["
CDATA[1]="]]>"
inf[0]="<info>"
inf[1]="</info>"
desc[0]="<description>"
desc[1]="</description>"
command[0]="<command>"
command[1]="</command>"
data[0]="<data>"
data[1]="</data>"
group[0]="<group title=\"TITLE\">"
group[1]="</group>"
scan[0]="<scan date=\"DATE\" user=\"USER\" system=\"SYSTEM\">"
scan[1]="</scan>"
xmlify_comm(){
comm=" $1"
comm_desc=$2
dat="$(eval $comm)"
if ["$dat" = "" ]; then
dat=" NOT AVAILABLE ";
fi
echo ${data[0]}
echo ${inf[0]}
echo ${CDATA[0]}
echo "${dat[*]}"
echo ${CDATA[1]}
echo ${inf[1]}
echo ${desc[0]}
echo $comm_desc
echo ${desc[1]}
echo ${command[0]}
echo ${CDATA[0]}
echo $comm
echo ${CDATA[1]}
echo ${command[1]}
echo ${data[1]}
}
scanner(){
echo $xml_version
echo $xsl_bind
date=`date`
scan_tag=$( echo ${scan[0]} | sed -e"s@DATE@$date@" -e"s@USER@$(whoami)@" -e"s@SYSTEM@$(uname -a)@")
echo $scan_tag
for i in $(seq 0 `expr "${#comm_groups[@]}" - 1` ); # for each in comm_groups
do
comm_group=${comm_groups[$i]}
comm_group_desc="$comm_group"_info
comm_group_desc=${!comm_group_desc}
comm_descs="$comm_group"_desc
comm_descs=$comm_descs[@]
comm_descs=("${!comm_descs}")
comm_group=$comm_group[@]
comm_group=("${!comm_group}")
group_tag=`echo ${group[0]} | sed "s@TITLE@$comm_group_desc@"`
echo $group_tag
for j in $(seq 0 `expr "${#comm_group[*]}" - 1`);
do
comm="${comm_group[$j]}"
comm_desc="${comm_descs[$j]}"
echo
xmlify_comm "$comm" "$comm_desc"
done
echo ${group[1]}
echo
done
echo ${scan[1]}
}
scanner
HISTCONTROL=$hist_prev
