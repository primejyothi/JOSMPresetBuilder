#! /usr/bin/env bash 

# JOSM Preset Builder
# License : GPLv3
# Prime Jyothi 20140720 primejyothi [at] gmail [dot] com
#
# Based on the data provided in a text file, build a XML file that can be
# used as a preset for JOSM Editor. Supported features:
#	- Group
#	- Sub group
#	- Multi select 
#	- Drop down lists
# The data file.
# The data file contains directives and values separated by pipe symbols.
# The values in turn can be key=value pairs separated by commas.
# Group Directive
# group|Name : Create a group with specified name.
#
# subgroup|Name : Create a sub group with specified name.
#
# item|key=value pairs : Create an item. The key jpField is used to create
# set properties of items, create multi select or combo elements.

# jpField=name : Used for the name label & type key value pairs. The type
# filed can be repeated to have multiple values.
# 
# jpField=kvp : JOSM Tag key value pairs. If the value of the key is left
# empty, JOSM will prompt for it when the corresponding preset is selected.
# 
# jpField=multiselect : Create a list of values from which multiple 
# selections can be made. The following key value pairs can be used.
# key : Name of the tag in JOSM. 
# text : Name of the multi select element.
# values : The list elements. Can take the form values=v1,values=v2 etc.
# default : The element that will be selected by default.
#
# jpField=combo : Create a drop down list. The following key value pairs
# are supported.
# key : Name of the tag in JOSM.
# text : Text label for the drop down.
# values : The drop down elements. Can take the form values=v1, values=v2.


# Log functions.
. ./logs.sh

# outFile=preset.xml
# inFile=data.txt
# inFile=blrData.txt
indents=0;
oldIFS=$IFS


function help ()
{
	echo "Usage : `basename $0` [-d] [-h] -i inputDatafile -o outputFile"
	echo -e "\t -d : Enable debug messages"
	echo -e "\t -h : Display this help message"
	echo -e "\t -i : Input data file"
	echo -e "\t -o : Output XML file"
}
	

while getopts i:o:dh args
do
	case $args in
		"i")
			inFile="$OPTARG"
			;;
		"o") outFile="$OPTARG"
			;;
		"d")
			dbgFlag=Y
			;;
		"h")
			help 
			exit
			;;
		* )
			help
			;;
	esac
done

if [ -z "$inFile" -o -z "$outFile" ]
then
	help
	exit 1
fi

# Truncate output file.
> ${outFile}

# Write XML data in to the output file.
function wx ()
{
	# Print required number of tabs.
	for i in `seq $indents`
	do
		echo -n -e "\t" >> ${outFile}
	done
	echo "$@" >> ${outFile}
}

function rInc ()
{
	indents=`expr $indents + 1`
}

function lInc ()
{
	indents=`expr $indents - 1`
}

function processGrp ()
{
	log $LINENO "Processing group [$@]"

	# Extract group name
	grpName=`echo $@ | awk -F"|" '{print $2}'`
	dbg $LINENO "Group name [$grpName]"
	wx "<group name = \"${grpName}\">"
}

function processSubGrp ()
{
	log $LINENO "Processing sub group [$@]"
	# Extract sub group name
	sGrpName=`echo $@ | awk -F"|" '{print $2}'`
	wx "<group name = \"${sGrpName}\">"
}

function processItemName ()
{
	log $LINENO "Processing item name [$@]"
	# Label might contain spaces, change IFS to ~ so that
	# for statement will split the string at "~" instead at the space chars.
	IFS='~'
	typeString=""
	nameStr=""
	for i in `echo $@ | tr ',' '~'`
	do
		IFS=${oldIFS}
		k=`echo $i | awk -F"=" '{print $1}'`
		v=`echo $i | awk -F"=" '{print $2}'`
		# dbg $LINENO "k = [$k] v = [$v]"

		case $k in 
			"name")
				name=$v			
				# dbg $LINENO "name = [$name]"
				;;

			"label")
				label=$v			
				# dbg $LINENO "label = [$label]"
				;;

			"type")
				# Build a string that contains the comma separated types.
				type=$v			
				# dbg $LINENO "type = [$type]"

				if [[ ! -z "${typeString}" ]]
				then
					typeString="${typeString},"
				fi
				typeString="${typeString}${type}"
				dbg $LINENO "Type String is now [$typeString]"
				;;
		esac
	done

	# Build the name string.
	nameStr="name = \"${name}\""
	if [[ ! -z "$typeString" ]]
	then
		nameStr="${nameStr} type=\"${typeString}\""
	fi
	nameStr="${nameStr}"

	# dbg $LINENO "nameStr is [$nameStr]"
	# dbg $LINENO "<item ${nameStr}>"
	
	wx "<item ${nameStr}>"
	rInc

	# Write label info
	wx "<label text=\"${label}\"/>"
}

function processKvp ()
{
	dbg $LINENO "Processing key value pairs [$@]"
	IFS='~'
	for i in `echo $@ | tr ',' '~'`
	do
		IFS=${oldIFS}

		k=`echo $i | awk -F"=" '{print $1}'`
		v=`echo $i | awk -F"=" '{print $2}'`

		# Skip the jpField
		if [[ "$k" = "jpField" ]]
		then
			continue
		fi

		# dbg $LINENO "k = $k v = $v"
		if [[ -z "${v}" ]]
		then
			wx "<text key=\"${k}\" text=\"${k}\"/>"
		else
			wx "<key key=\"${k}\" value=\"${v}\" />"
		fi
		IFS='~'
	done
	IFS=${oldIFS}
}

function processMs ()
{
	# Multi select name might contain spaces, change IFS to ~ so that
	# for will split the string at "~" instead at the space chars.
	IFS='~'
	valString=""
	for i in `echo $@ | tr ',' '~'`
	do
		IFS=${oldIFS}
		# dbg $LINENO "$i"
		k=`echo $i | awk -F"=" '{print $1}'`
		v=`echo $i | awk -F"=" '{print $2}'`
		# dbg $LINENO "k = [$k] v = [$v]"

		case $k in
			"key" )
				key=$v;
				dbg $LINENO "key = [$key]"
				;;

			"text" )
				text=$v;
				dbg $LINENO "text = [$text]"
				;;

			"default" )
				defVal=$v;
				dbg $LINENO "defVal = [$defVal]"
				;;

			"values" )
				# Build a string that contains the comma separated values.
				values=$v;
				dbg $LINENO "values = [$values]"

				# About to add a new value into the string, append a delimiter
				# only if a value is already present.
				if [[ ! -z "$valString" ]]
				then
					valString="${valString}; "
				fi
				valString="${valString}${values}"
				dbg $LINENO "Multi select value string is now [${valString}]"
				;;
		esac

	done

	# Write the multiselect element.
	wx "<multiselect key=\"${key}\" text=\"${text}\""
	rInc
	wx "values=\"${valString}\""
	wx "default=\"${defVal}\" delimiter=\";\""
	lInc
	wx "/>"
}

function processCombo ()
{
	dbg $LINENO "Processing combo [$@]"
	valString=""
	IFS='~'
	for i in `echo $@ | tr ',' '~'`
	do
		IFS=${oldIFS}

		dbg $LINENO "$i"
		k=`echo $i | awk -F"=" '{print $1}'`
		v=`echo $i | awk -F"=" '{print $2}'`
		dbg $LINENO "k = [$k] v = [$v]"

		case "$k" in
			"key" )
				key=$v
				;;
			"text" )
				text=$v
				;;
			"values" )
				values=$v
				# About to add a new value into the string, append a delimiter
				# only if a value is already present.
				if [[ ! -z "$valString" ]]
				then
					valString="${valString},"
				fi
				valString="${valString}${values}"
				dbg $LINENO "Combo value string is now [${valString}]"
				;;
		esac
	done
	# Write the combo element.
	wx "<combo key=\"${key}\" text=\"${text}\" values=\"${valString}\" />"
}

function processItem ()
{
	log $LINENO "Processing item [$@]"

	# Find the number of fields
	numFields=`echo $@ | awk -F"|" '{print NF}'`
	# dbg $LINENO "numFields = $numFields"	

	# Ignore the first one as it is the field type.
	for i in `seq 2 $numFields`
	do
		# Extract the fields
		data=`echo $@ | cut -d "|" -f $i`
		# dbg $LINENO "data is [$data]"

		# Skip empty fields
		if [[ -z "${data}" ]]
		then
			continue
		fi

		IFS='~'

		valString=""
		for f in `echo $data | tr ',' '~'`
		do
			IFS=$oldIFS
			# dbg $LINENO "f is $f"
			k=`echo $f | awk -F"=" '{print $1}'`
			v=`echo $f | awk -F"=" '{print $2}'`

			case "$v" in
				"name")
					processItemName ${data}
					;;
				"kvp")
					dbg $LINENO "Process kvp [$data]"
					processKvp $data
					;;
				"multiselect")
					dbg $LINENO "Process multiselect [$data]"
					processMs $data
					;;
				"combo" )
					dbg $LINENO "Process combo [$data]"
					processCombo ${data}
			esac
		done
	done

	lInc
	wx '</item>'
}


wx '<?xml version="1.0" encoding="utf-8"?>'
wx '<presets xmlns="http://josm.openstreetmap.de/tagging-preset-1.0"'
rInc

wx 'author="Prime Jyothi"'
# Set version as DDMMYYHHMM
wx "version=\"`date "+%Y%m%d%H%M"`\""

wx "description=\"Custom JOSM Presets, data from `basename ${inFile}`.\""
wx 'shortdescription="J Presets"'
lInc
wx '>'

sgCount=0;

closeGroup=""
while read line 
do
	# dbg $LINENO "$line"

	# Ignore lines commented by # character.
	# set -x
	echo "$li ne" | grep -q "[ ]*#"
	res=$?
	set +x
	if [[ $res -eq 0 ]]
	then
		continue;
	fi

	# Find the key.
	key=`echo $line | awk -F"|" '{print $1}'`
	dbg $LINENO "Key [$key]"
	case $key in
		"group" )
			
			rInc
			processGrp $line
			;;

		"subgroup" )
			if [[ "$sgCount" -gt "0" ]]
			then
				# At least one group has been processed earlier, close group.
				wx '</group>'
				lInc
			fi

			# Flag for closing the group.
			closeGroup=Y

			rInc
			processSubGrp $line
			sgCount=`expr $sgCount + 1`
			;;

		"item" )
			rInc
			processItem $line
			lInc
			;;
	esac 
	
done < $inFile

if [[ ! -z "$closeGroup" ]]
then
	wx '</group>'
	lInc
fi

# Close the group tag for the top group
wx '</group>'
lInc
wx '</presets>'

log $LINENO "Finished processing"
exit 0
