#!/bin/bash
#
# SCRIPT Object dump to CSV action operations for API CLI Operations
#
ScriptVersion=00.29.00
ScriptDate=2018-05-04

#

export APIActionsScriptVersion=v00x29x00
ActionScriptName=cli_api_export_objects_actions_to_csv

# =================================================================================================
# Validate Actions Script version is correct for caller
# =================================================================================================


if [ x"$APIScriptVersion" = x"$APIActionsScriptVersion" ] ; then
    # Script and Actions Script versions match, go ahead
    echo | tee -a -i $APICLIlogfilepath
    echo 'Verify Actions Scripts Version - OK' | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
else
    # Script and Actions Script versions don't match, ALL STOP!
    echo | tee -a -i $APICLIlogfilepath
    echo 'Verify Actions Scripts Version - Missmatch' | tee -a -i $APICLIlogfilepath
    echo 'Calling Script version : '$APIScriptVersion | tee -a -i $APICLIlogfilepath
    echo 'Actions Script version : '$APIActionsScriptVersion | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    echo 'Critical Error - Exiting Script !!!!' | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath
    echo "Log output in file $APICLIlogfilepath" | tee -a -i $APICLIlogfilepath
    echo | tee -a -i $APICLIlogfilepath

    exit 250
fi


# =================================================================================================
# =================================================================================================
# START:  Export objects to csv
# =================================================================================================


echo | tee -a -i $APICLIlogfilepath
echo 'ActionScriptName:  '$ActionScriptName'  Script Version: '$APIActionsScriptVersion | tee -a -i $APICLIlogfilepath

# ADDED 2018-04-25 -
export primarytargetoutputformat=$FileExtCSV

# -------------------------------------------------------------------------------------------------
# Start executing Main operations
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-05-04-3 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

if [ ! -z "$domainnamenospace" ] && [ "$CLIparm_NODOMAINFOLDERS" != "true" ] ; then
    # Handle adding domain name to path for MDM operations
    export APICLIpathexport=$APICLICSVExportpathbase/$domainnamenospace

    if [ ! -r $APICLIpathexport ] ; then
        mkdir $APICLIpathexport
    fi
else
    # NOT adding domain name to path for MDM operations
    export APICLIpathexport=$APICLICSVExportpathbase

    if [ ! -r $APICLIpathexport ] ; then
        mkdir $APICLIpathexport
    fi
fi

# primary operation is export to primarytargetoutputformat
export APICLIpathexport=$APICLIpathexport/$primarytargetoutputformat

if [ ! -r $APICLIpathexport ] ; then
    mkdir $APICLIpathexport
fi

if [ x"$primarytargetoutputformat" = x"$FileExtJSON" ] ; then
    # for JSON provide the detail level

    export APICLIpathexport=$APICLIpathexport/$APICLIdetaillvl

    if [ ! -r $APICLIpathexport ] ; then
        mkdir $APICLIpathexport
    fi

    export APICLIJSONpathexportwip=
    if [ x"$script_uses_wip_json" = x"true" ] ; then
        # script uses work-in-progress (wip) folder for json
    
        export APICLIJSONpathexportwip=$APICLIpathexport/wip
        
        if [ ! -r $APICLIJSONpathexportwip ] ; then
            mkdir $APICLIJSONpathexportwip
        fi
    fi
else    
    export APICLIJSONpathexportwip=
fi

if [ x"$primarytargetoutputformat" = x"$FileExtCSV" ] ; then
    # for CSV handle specifics, like wip

    export APICLICSVpathexportwip=
    if [ x"$script_uses_wip" = x"true" ] ; then
        # script uses work-in-progress (wip) folder for csv
    
        export APICLICSVpathexportwip=$APICLIpathexport/wip
        
        if [ ! -r $APICLICSVpathexportwip ] ; then
            mkdir $APICLICSVpathexportwip
        fi
    fi
else
    export APICLICSVpathexportwip=
fi

export APICLIfileexportpost='_'$APICLIdetaillvl'_'$APICLIfileexportsuffix

export APICLICSVheaderfilesuffix=header

export APICLICSVfileexportpost='_'$APICLIdetaillvl'_'$APICLICSVfileexportsuffix

export APICLIJSONheaderfilesuffix=header
export APICLIJSONfooterfilesuffix=footer

export APICLIJSONfileexportpost='_'$APICLIdetaillvl'_'$APICLIJSONfileexportsuffix


echo
echo 'Dump to '$primarytargetoutputformat' Starting!'
echo 'Dump "'$APICLIdetaillvl'" details to path:  '$APICLIpathexport
echo

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2018-05-04-3


# -------------------------------------------------------------------------------------------------
# Main Operational repeated proceedure - ExportObjectsToCSVviaJQ
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# SetupExportObjectsToCSVviaJQ
# -------------------------------------------------------------------------------------------------

# MODIFIED 2017-10-27 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

# The SetupExportObjectsToCSVviaJQ is the setup actions for the script's repeated actions.
#

SetupExportObjectsToCSVviaJQ () {
    #
    # Screen width template for sizing, default width of 80 characters assumed
    #
    #              1111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990
    #    01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
    
    echo
    
    export APICLICSVfilename=$APICLIobjectstype
    if [ x"$APICLIexportnameaddon" != x"" ] ; then
        export APICLICSVfilename=$APICLICSVfilename'_'$APICLIexportnameaddon
    fi
    export APICLICSVfilename=$APICLICSVfilename'_'$APICLIdetaillvl'_csv'$APICLICSVfileexportsuffix
    export APICLICSVfile=$APICLIpathexport/$APICLICSVfilename
    export APICLICSVfilewip=$APICLICSVpathexportwip/$APICLICSVfilename
    export APICLICSVfileheader=$APICLICSVfilewip.$APICLICSVheaderfilesuffix
    export APICLICSVfiledata=$APICLICSVfilewip.data
    export APICLICSVfilesort=$APICLICSVfilewip.sort
    export APICLICSVfileoriginal=$APICLICSVfilewip.original

    
    if [ ! -r $APICLICSVpathexportwip ] ; then
        mkdir $APICLICSVpathexportwip
    fi

    if [ -r $APICLICSVfile ] ; then
        rm $APICLICSVfile
    fi
    if [ -r $APICLICSVfileheader ] ; then
        rm $APICLICSVfileheader
    fi
    if [ -r $APICLICSVfiledata ] ; then
        rm $APICLICSVfiledata
    fi
    if [ -r $APICLICSVfilesort ] ; then
        rm $APICLICSVfilesort
    fi
    if [ -r $APICLICSVfileoriginal ] ; then
        rm $APICLICSVfileoriginal
    fi
    
    echo
    echo "Creat $APICLIobjectstype CSV File : $APICLICSVfile"
    echo
    
    #
    # Troubleshooting output
    #
    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
        # Verbose mode ON
        echo
        echo '$CSVFileHeader' - $CSVFileHeader
        echo
    
    fi
    
    echo $CSVFileHeader > $APICLICSVfileheader
    echo
    
    echo
    return 0
    
    #
}

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2017-10-27


# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-03-03 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

# The FinalizeExportObjectsToCSVviaJQ is the finaling actions for the script's repeated actions.
#

FinalizeExportObjectsToCSVviaJQ () {
    #
    # Screen width template for sizing, default width of 80 characters assumed
    #
    #              1111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990
    #    01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

    if [ ! -r $APICLICSVfileheader ] ; then
        # Uh, Oh, something went wrong, no header file
        echo
        echo '!!!! Error header file missing : '$APICLICSVfileheader
        echo 'Terminating!'
        echo
        exit 254
        
    elif [ ! -r $APICLICSVfiledata ] ; then
        # Uh, Oh, something went wrong, no data file
        echo
        echo '!!!! Error data file missing : '$APICLICSVfiledata
        echo 'Terminating!'
        echo
        exit 253
        
    elif [ ! -s $APICLICSVfiledata ] ; then
        # data file is empty, nothing was found
        echo
        echo '!! data file is empty : '$APICLICSVfiledata
        echo 'Skipping CSV creation!'
        echo
        return 0
        
    fi

    echo
    echo "Sort data and build CSV export file"
    echo
    
    cat $APICLICSVfileheader > $APICLICSVfileoriginal
    cat $APICLICSVfiledata >> $APICLICSVfileoriginal
    
    sort $APICLICSVsortparms $APICLICSVfiledata > $APICLICSVfilesort
    
    cat $APICLICSVfileheader > $APICLICSVfile
    cat $APICLICSVfilesort >> $APICLICSVfile
    
    echo
    echo "Done creating $APICLIobjectstype CSV File : $APICLICSVfile"
    echo
    
    head $APICLICSVfile
    echo
    echo
   
    
    #              1111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990
    #    01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

    echo
    return 0
    
    #
}

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2018-03-03


# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-03-03 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

# The ExportObjectsToCSVviaJQ is the meat of the script's repeated actions.
#
# For this script the $APICLIobjectstype item's name is exported to a CSV file and sorted.
# The original exported data and raw sorted data are retained in separate files, as is the header
# for the CSV file generated.

ExportObjectsToCSVviaJQ () {
    #
    
    if [[ $number_of_objects -le 1 ]] ; then
        # no objects of this type
 
        echo "No objects of type $APICLIobjecttype to process, skipping..."

        return 0
       
    else
        # we have objects to handle
        echo "Processing $number_of_objects $APICLIobjecttype objects..."
        echo
   fi

    SetupExportObjectsToCSVviaJQ
    
    #
    # Troubleshooting output
    #
    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
        # Verbose mode ON
        echo
        echo '$CSVJQparms' - $CSVJQparms
        echo
    fi
    
    export MgmtCLI_Base_OpParms="--format json -s $APICLIsessionfile"
    export MgmtCLI_IgnoreErr_OpParms="ignore-warnings true ignore-errors true --ignore-errors true"
    
    export MgmtCLI_Show_OpParms="details-level \"full\" $MgmtCLI_Base_OpParms"
    
    # System Object selection operands
    # export systemobjectselector='select(."meta-info"."creator" != "System")'
    export systemobjectselector='select(."meta-info"."creator" | contains ("System") | not)'

    objectstotal=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")

    objectstoshow=$objectstotal

    echo "Processing $objectstoshow $APICLIobjecttype objects in $APICLIObjectLimit object chunks:"

    objectslefttoshow=$objectstoshow
    currentoffset=0

    echo
    echo "Export $APICLIobjectstype to CSV File"
    echo "  mgmt_cli parameters : $MgmtCLI_Show_OpParms"
    echo "  and dump to $APICLICSVfile"
    echo
    
    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
        echo "  System Object Selector : "$systemobjectselector
    fi

    while [ $objectslefttoshow -ge 1 ] ; do
        # we have objects to process
        echo "  Now processing up to next $APICLIObjectLimit $APICLIobjecttype objects starting with object $currentoffset of $objectslefttoshow remaining!"

#        mgmt_cli show $APICLIobjectstype limit $APICLIObjectLimit offset $currentoffset $MgmtCLI_Show_OpParms | $JQ '.objects[] | [ '"$CSVJQparms"' ] | @csv' -r >> $APICLICSVfiledata
#        errorreturn=$?

        if [ x"$NoSystemObjects" = x"true" ] ; then
            # Ignore System Objects
            #mgmt_cli show $APICLIobjectstype limit $APICLIObjectLimit offset $currentoffset $MgmtCLI_Show_OpParms | $JQ '.objects[] | select(."meta-info"."creator" != "System") | [ '"$CSVJQparms"' ] | @csv' -r >> $APICLICSVfiledata
            mgmt_cli show $APICLIobjectstype limit $APICLIObjectLimit offset $currentoffset $MgmtCLI_Show_OpParms | $JQ '.objects[] | '"$systemobjectselector"' | [ '"$CSVJQparms"' ] | @csv' -r >> $APICLICSVfiledata
            errorreturn=$?
        else   
            # Don't Ignore System Objects
            mgmt_cli show $APICLIobjectstype limit $APICLIObjectLimit offset $currentoffset $MgmtCLI_Show_OpParms | $JQ '.objects[] | [ '"$CSVJQparms"' ] | @csv' -r >> $APICLICSVfiledata
            errorreturn=$?
        fi

        if [ $errorreturn != 0 ] ; then
            # Something went wrong, terminate
            exit $errorreturn
        fi

        objectslefttoshow=`expr $objectslefttoshow - $APICLIObjectLimit`
        currentoffset=`expr $currentoffset + $APICLIObjectLimit`
    done

    echo
    
    FinalizeExportObjectsToCSVviaJQ
    errorreturn=$?
    if [ $errorreturn != 0 ] ; then
        # Something went wrong, terminate
        exit $errorreturn
    fi
    
    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
        echo
        echo "Done with Exporting $APICLIobjectstype to CSV File : $APICLICSVfile"
    
        if [ "$CLIparm_NOWAIT" != "true" ] ; then
            read -t $WAITTIME -n 1 -p "Any key to continue.  Automatic continue after $WAITTIME seconds : " anykey
        fi
    
    fi
    
    echo
    return 0
    
    #
}

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2018-03-03


# -------------------------------------------------------------------------------------------------
# GetNumberOfObjectsviaJQ
# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-03-03 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

# The GetNumberOfObjectsviaJQ is the obtains the number of objects for that type indicated.
#

GetNumberOfObjectsviaJQ () {

    export objectstotal=
    export objectsfrom=
    export objectsto=
    
    #
    # Troubleshooting output
    #
    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
        # Verbose mode ON
        echo
        echo '$CSVJQparms' - $CSVJQparms
        echo
    fi
    
    objectstotal=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
    errorreturn=$?

    if [ $errorreturn != 0 ] ; then
        # Something went wrong, terminate
        exit $errorreturn
    fi
    
    export number_of_objects=$objectstotal

    echo
    return 0
    
    #
}

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2018-03-03

# -------------------------------------------------------------------------------------------------


# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------


# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
# handle simple objects
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# hosts
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=host
export APICLIobjectstype=hosts
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
export CSVFileHeader=$CSVFileHeader',"ipv4-address","ipv6-address"'
export CSVFileHeader=$CSVFileHeader',"nat-settings.auto-rule","nat-settings.hide-behind","nat-settings.install-on","nat-settings.ipv4-address","nat-settings.ipv6-address","nat-settings.method"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
export CSVJQparms=$CSVJQparms', .["ipv4-address"], .["ipv6-address"]'
export CSVJQparms=$CSVJQparms', .["nat-settings"]["auto-rule"], .["nat-settings"]["hide-behind"], .["nat-settings"]["install-on"]'
export CSVJQparms=$CSVJQparms', .["nat-settings"]["ipv4-address"], .["nat-settings"]["ipv6-address"], .["nat-settings"]["method"]'

objectstotal_hosts=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_hosts="$objectstotal_hosts"
export number_of_objects=$number_hosts

ExportObjectsToCSVviaJQ


# -------------------------------------------------------------------------------------------------
# networks
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=network
export APICLIobjectstype=networks
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
export CSVFileHeader=$CSVFileHeader',"broadcast","subnet4","mask-length4","subnet6","mask-length6"'
export CSVFileHeader=$CSVFileHeader',"nat-settings.auto-rule","nat-settings.hide-behind","nat-settings.install-on","nat-settings.method"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
export CSVJQparms=$CSVJQparms', .["broadcast"], .["subnet4"], .["mask-length4"], .["subnet6"], .["mask-length6"]'
export CSVJQparms=$CSVJQparms', .["nat-settings"]["auto-rule"], .["nat-settings"]["hide-behind"], .["nat-settings"]["install-on"], .["nat-settings"]["method"]'

objectstotal_networks=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_networks="$objectstotal_networks"
export number_of_objects=$number_networks

ExportObjectsToCSVviaJQ


# -------------------------------------------------------------------------------------------------
# groups
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=group
export APICLIobjectstype=groups
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'

export CSVJQparms='.["name"], .["color"], .["comments"]'

objectstotal_groups=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_groups="$objectstotal_groups"
export number_of_objects=$number_groups

ExportObjectsToCSVviaJQ


# -------------------------------------------------------------------------------------------------
# groups-with-exclusion
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=group-with-exclusion
export APICLIobjectstype=groups-with-exclusion
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
export CSVFileHeader=$CSVFileHeader',"include","except"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
export CSVJQparms=$CSVJQparms', .["include"]["name"], .["except"]["name"]'

objectstotal_groupswithexclusion=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_groupswithexclusion="$objectstotal_groupswithexclusion"
export number_of_objects=$number_groupswithexclusion

ExportObjectsToCSVviaJQ


# -------------------------------------------------------------------------------------------------
# address-ranges
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=address-range
export APICLIobjectstype=address-ranges
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
export CSVFileHeader=$CSVFileHeader',"ipv4-address-first","ipv4-address-last"'
export CSVFileHeader=$CSVFileHeader',"ipv6-address-first","ipv6-address-last"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
export CSVJQparms=$CSVJQparms', .["ipv4-address-first"], .["ipv4-address-last"]'
export CSVJQparms=$CSVJQparms', .["ipv6-address-first"], .["ipv6-address-last"]'

objectstotal_addressranges=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_addressranges="$objectstotal_addressranges"
export number_of_objects=$number_addressranges

ExportObjectsToCSVviaJQ


# -------------------------------------------------------------------------------------------------
# multicast-address-ranges
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=multicast-address-range
export APICLIobjectstype=multicast-address-ranges
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
export CSVFileHeader=$CSVFileHeader',"ipv4-address-first","ipv4-address-last"'
export CSVFileHeader=$CSVFileHeader',"ipv6-address-first","ipv6-address-last"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
export CSVJQparms=$CSVJQparms', .["ipv4-address-first"], .["ipv4-address-last"]'
export CSVJQparms=$CSVJQparms', .["ipv6-address-first"], .["ipv6-address-last"]'

objectstotal_multicastaddressranges=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_multicastaddressranges="$objectstotal_multicastaddressranges"
export number_of_objects=$number_multicastaddressranges

ExportObjectsToCSVviaJQ


# -------------------------------------------------------------------------------------------------
# dns-domains
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=dns-domain
export APICLIobjectstype=dns-domains
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
export CSVFileHeader=$CSVFileHeader',"is-sub-domain"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
export CSVJQparms=$CSVJQparms', .["is-sub-domain"]'

objectstotal_dnsdomains=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_dnsdomains="$objectstotal_dnsdomains"
export number_of_objects=$number_dnsdomains

ExportObjectsToCSVviaJQ


# -------------------------------------------------------------------------------------------------
# security-zones
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=security-zone
export APICLIobjectstype=security-zones
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
export CSVFileHeader=$CSVFileHeader',"icon"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
export CSVJQparms=$CSVJQparms', .["icon"]'

objectstotal_securityzones=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_securityzones="$objectstotal_securityzones"
export number_of_objects=$number_securityzones

ExportObjectsToCSVviaJQ


# MODIFIED 2017-10-27 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

# -------------------------------------------------------------------------------------------------
# dynamic-objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=dynamic-object
export APICLIobjectstype=dynamic-objects
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
export CSVFileHeader=$CSVFileHeader',"icon"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
export CSVJQparms=$CSVJQparms', .["icon"]'

objectstotal_dynamicobjects=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_dynamicobjects="$objectstotal_dynamicobjects"
export number_of_objects=$number_dynamicobjects

ExportObjectsToCSVviaJQ


#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2017-10-27

# MODIFIED 2017-10-27 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
# Services and Applications
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

echo
echo 'Services and Applications'
echo
echo >> $APICLIlogfilepath
echo 'Services and Applications' >> $APICLIlogfilepath
echo >> $APICLIlogfilepath

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2017-10-27

# MODIFIED 2018-05-02 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

# -------------------------------------------------------------------------------------------------
# application-sites objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=application-site
export APICLIobjectstype=application-sites
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
#export CSVFileHeader=$CSVFileHeader',"icon"'
export CSVFileHeader=$CSVFileHeader',"primary-category","risk","description","urls-defined-as-regular-expression"'
export CSVFileHeader=$CSVFileHeader', "meta-info.creator","user-defined","read-only"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
#export CSVJQparms=$CSVJQparms', .["icon"]'
export CSVJQparms=$CSVJQparms', .["primary-category"], .["risk"], .["description"], .["urls-defined-as-regular-expression"]'
export CSVJQparms=$CSVJQparms', .["meta-info"]["creator"], .["user-defined"], .["read-only"]'

objectstotal_application_sites=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_application_sites="$objectstotal_application_sites"
export number_of_objects=$number_application_sites

ExportObjectsToCSVviaJQ

# -------------------------------------------------------------------------------------------------
# application-sites objects - risk_data_export_only (well risk, primary category, description, creator
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=application-site
export APICLIobjectstype=application-sites
export APICLIexportnameaddon=risk_data_export_only

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

#export CSVFileHeader='"name","color","comments"'
#export CSVFileHeader=$CSVFileHeader',"icon"'
#export CSVFileHeader=$CSVFileHeader',"primary-category","risk","description"'
#export CSVFileHeader=$CSVFileHeader',"user-defined","read-only", "meta-info.creator"'

#export CSVJQparms='.["name"], .["color"], .["comments"]'
#export CSVJQparms=$CSVJQparms', .["icon"]'
#export CSVJQparms=$CSVJQparms', .["primary-category"], .["risk"], .["description"]'
#export CSVJQparms=$CSVJQparms', .["user-defined"], .["read-only"], .["meta-info"]["creator"]'

export CSVFileHeader='"name"'
export CSVFileHeader=$CSVFileHeader',"primary-category","risk","description"'
export CSVFileHeader=$CSVFileHeader', "meta-info.creator","user-defined","read-only"'

export CSVJQparms='.["name"]'
export CSVJQparms=$CSVJQparms', .["primary-category"], .["risk"], .["description"]'
export CSVJQparms=$CSVJQparms', .["meta-info"]["creator"], .["user-defined"], .["read-only"]'

objectstotal_application_sites=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_application_sites="$objectstotal_application_sites"
export number_of_objects=$number_application_sites

ExportObjectsToCSVviaJQ

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2018-05-02


# MODIFIED 2017-10-27 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

# -------------------------------------------------------------------------------------------------
# application-site-categories objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=application-site-category
export APICLIobjectstype=application-site-categories
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
#export CSVFileHeader=$CSVFileHeader',"icon"'
export CSVFileHeader=$CSVFileHeader',"user-defined","read-only", "meta-info.creator"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
#export CSVJQparms=$CSVJQparms', .["icon"]'
export CSVJQparms=$CSVJQparms', .["user-defined"], .["read-only"], .["meta-info"]["creator"]'

objectstotal_application_site_categories=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_application_site_categories="$objectstotal_application_site_categories"
export number_of_objects=$number_application_site_categories

ExportObjectsToCSVviaJQ

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2017-10-27


# MODIFIED 2017-10-27 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

# -------------------------------------------------------------------------------------------------
# application-site-groups objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=application-site-group
export APICLIobjectstype=application-site-groups
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
#export CSVFileHeader=$CSVFileHeader',"icon"'
export CSVFileHeader=$CSVFileHeader',"user-defined","read-only", "meta-info.creator"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
#export CSVJQparms=$CSVJQparms', .["icon"]'
export CSVJQparms=$CSVJQparms', .["user-defined"], .["read-only"], .["meta-info"]["creator"]'

objectstotal_application_site_groups=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_application_site_groups="$objectstotal_application_site_groups"
export number_of_objects=$number_application_site_groups

ExportObjectsToCSVviaJQ

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2017-10-27


# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
# Identifying Data
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

echo
echo 'Identifying Data'
echo

# -------------------------------------------------------------------------------------------------
# tags
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=tags
export APICLIobjectstype=tags
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
export CSVFileHeader=$CSVFileHeader',"icon"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
export CSVJQparms=$CSVJQparms', .["icon"]'

objectstotal_tags=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_tags="$objectstotal_tags"
export number_of_objects=$number_tags

ExportObjectsToCSVviaJQ


# ADDED 2017-07-21 -\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
# Future objects to export to CSV
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# simple-gateways
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=simple-gateway
export APICLIobjectstype=simple-gateways
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
export CSVFileHeader=$CSVFileHeader',"icon"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
export CSVJQparms=$CSVJQparms', .["icon"]'

objectstotal_simplegateways=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_simplegateways="$objectstotal_simplegateways"
export number_of_objects=$number_simplegateways

#ExportObjectsToCSVviaJQ


# -------------------------------------------------------------------------------------------------
# times
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=time
export APICLIobjectstype=times
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
export CSVFileHeader=$CSVFileHeader',"icon"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
export CSVJQparms=$CSVJQparms', .["icon"]'

objectstotal_times=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_times="$objectstotal_times"
export number_of_objects=$number_times

#ExportObjectsToCSVviaJQ


# -------------------------------------------------------------------------------------------------
# time_groups
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=time-group
export APICLIobjectstype=time-groups
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
export CSVFileHeader=$CSVFileHeader',"icon"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
export CSVJQparms=$CSVJQparms', .["icon"]'

objectstotal_time_groups=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_time_groups="$objectstotal_time_groups"
export number_of_objects=$number_time_groups

#ExportObjectsToCSVviaJQ


# -------------------------------------------------------------------------------------------------
# access-roles
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=access-role
export APICLIobjectstype=access-roles
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
export CSVFileHeader=$CSVFileHeader',"icon"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
export CSVJQparms=$CSVJQparms', .["icon"]'

objectstotal_access_roles=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_access_roles="$objectstotal_access_roles"
export number_of_objects=$number_access_roles

#ExportObjectsToCSVviaJQ


# -------------------------------------------------------------------------------------------------
# opsec-applications
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=opsec-application
export APICLIobjectstype=opsec-applications
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
export CSVFileHeader=$CSVFileHeader',"icon"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
export CSVJQparms=$CSVJQparms', .["icon"]'

objectstotal_opsec_applications=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_opsec_applications="$objectstotal_opsec_applications"
export number_of_objects=$number_opsec_applications

#ExportObjectsToCSVviaJQ


# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
# Services and Applications
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

#echo
#echo 'Services and Applications'
#echo
#echo >> $APICLIlogfilepath
#echo 'Services and Applications' >> $APICLIlogfilepath
#echo >> $APICLIlogfilepath

# -------------------------------------------------------------------------------------------------
# services-tcp objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=service-tcp
export APICLIobjectstype=services-tcp
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
export CSVFileHeader=$CSVFileHeader',"icon"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
export CSVJQparms=$CSVJQparms', .["icon"]'

objectstotal_services_tcp=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_services_tcp="$objectstotal_services_tcp"
export number_of_objects=$number_services_tcp

#ExportObjectsToCSVviaJQ


# -------------------------------------------------------------------------------------------------
# services-udp objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=service-udp
export APICLIobjectstype=services-udp
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
export CSVFileHeader=$CSVFileHeader',"icon"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
export CSVJQparms=$CSVJQparms', .["icon"]'

objectstotal_services_udp=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_services_udp="$objectstotal_services_udp"
export number_of_objects=$number_services_udp

#ExportObjectsToCSVviaJQ


# -------------------------------------------------------------------------------------------------
# services-icmp objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=service-icmp
export APICLIobjectstype=services-icmp
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
export CSVFileHeader=$CSVFileHeader',"icon"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
export CSVJQparms=$CSVJQparms', .["icon"]'

objectstotal_services_icmp=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_services_icmp="$objectstotal_services_icmp"
export number_of_objects=$number_services_icmp

#ExportObjectsToCSVviaJQ


# -------------------------------------------------------------------------------------------------
# services-icmp6 objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=service-icmp6
export APICLIobjectstype=services-icmp6
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
export CSVFileHeader=$CSVFileHeader',"icon"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
export CSVJQparms=$CSVJQparms', .["icon"]'

objectstotal_services_icmp6=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_services_icmp6="$objectstotal_services_icmp6"
export number_of_objects=$number_services_icmp6

#ExportObjectsToCSVviaJQ


# -------------------------------------------------------------------------------------------------
# services-sctp objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=service-sctp
export APICLIobjectstype=services-sctp
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
export CSVFileHeader=$CSVFileHeader',"icon"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
export CSVJQparms=$CSVJQparms', .["icon"]'

objectstotal_services_sctp=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_services_sctp="$objectstotal_services_sctp"
export number_of_objects=$number_services_sctp

#ExportObjectsToCSVviaJQ


# -------------------------------------------------------------------------------------------------
# services-other objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=service-other
export APICLIobjectstype=services-other
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
export CSVFileHeader=$CSVFileHeader',"icon"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
export CSVJQparms=$CSVJQparms', .["icon"]'

objectstotal_services_other=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_services_other="$objectstotal_services_other"
export number_of_objects=$number_services_other

#ExportObjectsToCSVviaJQ


# -------------------------------------------------------------------------------------------------
# services-dce-rpc objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=service-dce-rpc
export APICLIobjectstype=services-dce-rpc
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
export CSVFileHeader=$CSVFileHeader',"icon"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
export CSVJQparms=$CSVJQparms', .["icon"]'

objectstotal_services_dce_rpc=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_services_dce_rpc="$objectstotal_services_dce_rpc"
export number_of_objects=$number_services_dce_rpc

#ExportObjectsToCSVviaJQ


# -------------------------------------------------------------------------------------------------
# services-rpc objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=service-rpc
export APICLIobjectstype=services-rpc
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
export CSVFileHeader=$CSVFileHeader',"icon"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
export CSVJQparms=$CSVJQparms', .["icon"]'

objectstotal_services_rpc=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_services_rpc="$objectstotal_services_rpc"
export number_of_objects=$number_services_rpc

#ExportObjectsToCSVviaJQ


# -------------------------------------------------------------------------------------------------
# service-groups objects
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=service-group
export APICLIobjectstype=service-groups
export APICLIexportnameaddon=

#
# APICLICSVsortparms can change due to the nature of the object
#
export APICLICSVsortparms='-f -t , -k 1,1'

export CSVFileHeader='"name","color","comments"'
export CSVFileHeader=$CSVFileHeader',"icon"'

export CSVJQparms='.["name"], .["color"], .["comments"]'
export CSVJQparms=$CSVJQparms', .["icon"]'

objectstotal_service_groups=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_service_groups="$objectstotal_service_groups"
export number_of_objects=$number_service_groups

#ExportObjectsToCSVviaJQ


#
# \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/- ADDED 2017-08-28


# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
# no more simple objects
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
# handle complex objects
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

# ADDED 2017-11-09  \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

# -------------------------------------------------------------------------------------------------
# SetupExportComplexObjectsToCSVviaJQ
# -------------------------------------------------------------------------------------------------

# The SetupExportComplexObjectsToCSVviaJQ is the setup actions for the script's repeated actions.
#

SetupExportComplexObjectsToCSVviaJQ () {
    #
    # Screen width template for sizing, default width of 80 characters assumed
    #
    #              1111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990
    #    01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
    
    echo
    
    export APICLICSVfilename=$APICLIcomplexobjectstype'_'$APICLIdetaillvl'_csv'$APICLICSVfileexportsuffix
    export APICLICSVfile=$APICLIpathexport/$APICLICSVfilename
    export APICLICSVfilewip=$APICLICSVpathexportwip/$APICLICSVfilename
    export APICLICSVfileheader=$APICLICSVfilewip.$APICLICSVheaderfilesuffix
    export APICLICSVfiledata=$APICLICSVfilewip.data
    export APICLICSVfilesort=$APICLICSVfilewip.sort
    export APICLICSVfileoriginal=$APICLICSVfilewip.original

    
    if [ ! -r $APICLICSVpathexportwip ] ; then
        mkdir $APICLICSVpathexportwip
    fi

    if [ -r $APICLICSVfile ] ; then
        rm $APICLICSVfile
    fi
    if [ -r $APICLICSVfileheader ] ; then
        rm $APICLICSVfileheader
    fi
    if [ -r $APICLICSVfiledata ] ; then
        rm $APICLICSVfiledata
    fi
    if [ -r $APICLICSVfilesort ] ; then
        rm $APICLICSVfilesort
    fi
    if [ -r $APICLICSVfileoriginal ] ; then
        rm $APICLICSVfileoriginal
    fi
    
    echo
    echo "Creat $APICLIcomplexobjectstype CSV File : $APICLICSVfile"
    echo
    
    #
    # Troubleshooting output
    #
    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
        # Verbose mode ON
        echo
        echo '$CSVFileHeader' - $CSVFileHeader
        echo
    
    fi
    
    echo $CSVFileHeader > $APICLICSVfileheader
    echo
    
    echo
    return 0
    
    #
}


# -------------------------------------------------------------------------------------------------

# MODIFIED 2018-03-04 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

# -------------------------------------------------------------------------------------------------
# FinalizeExportComplexObjectsToCSVviaJQ
# -------------------------------------------------------------------------------------------------

# The FinalizeExportComplexObjectsToCSVviaJQ is the finaling actions for the script's repeated actions.
#

FinalizeExportComplexObjectsToCSVviaJQ () {
    #
    # Screen width template for sizing, default width of 80 characters assumed
    #
    #              1111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990
    #    01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

    if [ ! -r $APICLICSVfileheader ] ; then
        # Uh, Oh, something went wrong, no header file
        echo
        echo '!!!! Error header file missing : '$APICLICSVfileheader
        echo 'Terminating!'
        echo
        exit 254
        
    elif [ ! -r $APICLICSVfiledata ] ; then
        # Uh, Oh, something went wrong, no data file
        echo
        echo '!!!! Error data file missing : '$APICLICSVfiledata
        echo 'Terminating!'
        echo
        exit 253
        
    elif [ ! -s $APICLICSVfiledata ] ; then
        # data file is empty, nothing was found
        echo
        echo '!! data file is empty : '$APICLICSVfiledata
        echo 'Skipping CSV creation!'
        echo
        return 0
        
    fi

    echo
    echo "Sort data and build CSV export file"
    echo
    
    cat $APICLICSVfileheader > $APICLICSVfileoriginal
    cat $APICLICSVfiledata >> $APICLICSVfileoriginal
    
    sort $APICLICSVsortparms $APICLICSVfiledata > $APICLICSVfilesort
    
    cat $APICLICSVfileheader > $APICLICSVfile
    cat $APICLICSVfilesort >> $APICLICSVfile
    
    echo
    echo "Done creating $APICLIcomplexobjectstype CSV File : $APICLICSVfile"
    echo
    
    head $APICLICSVfile
    echo
    echo
   
    
    #              1111111111222222222233333333334444444444555555555566666666667777777777888888888899999999990
    #    01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890

    echo
    return 0
    
    #
}

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2018-03-04

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\  ADDED 2017-11-09


# MODIFIED 2017-11-09 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

# -------------------------------------------------------------------------------------------------
# group members
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=group
export APICLIobjectstype=groups
export APICLIcomplexobjecttype=group-member
export APICLIcomplexobjectstype=group-members
export APICLIexportnameaddon=

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# SetupGetGroupMembers proceedure
# -------------------------------------------------------------------------------------------------

#
# SetupGetGroupMembers

SetupGetGroupMembers () {

    #
    # APICLICSVsortparms can change due to the nature of the object
    #
    export APICLICSVsortparms='-f -t , -k 1,2'
    
    export CSVFileHeader='"name","members.add"'
    
    SetupExportComplexObjectsToCSVviaJQ
    
    return 0
}
    
# -------------------------------------------------------------------------------------------------
# FinalizeGetGroupMembers proceedure
# -------------------------------------------------------------------------------------------------

#
# FinalizeGetGroupMembers

FinalizeGetGroupMembers () {

    FinalizeExportComplexObjectsToCSVviaJQ
    errorreturn=$?
    if [ $errorreturn != 0 ] ; then
        # Something went wrong, terminate
        exit $errorreturn
    fi
    
    return 0
}
    
# MODIFIED 2018-03-05 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#


# -------------------------------------------------------------------------------------------------
# PopulateArrayOfGroupObjects proceedure
# -------------------------------------------------------------------------------------------------

#
# PopulateArrayOfGroupObjects generates an array of group objects for further processing.

PopulateArrayOfGroupObjects () {
    
    # System Object selection operands
    # export systemobjectselector='select(."meta-info"."creator" != "System")'
    export systemobjectselector='select(."meta-info"."creator" | contains ("System") | not)'
    
    echo "  $APICLIobjectstype - Populate up to next $APICLIObjectLimit $APICLIobjecttype objects starting with object $currentgroupoffset of $objectslefttoshow remaining!"

    # MGMT_CLI_GROUPS_STRING is a string with multiple lines. Each line contains a name of a group members.
    # in this example the output of mgmt_cli is not sent to a file, instead it is passed to jq directly using a pipe.
    
    #MGMT_CLI_GROUPS_STRING="`mgmt_cli show groups limit $APICLIObjectLimit offset $currentgroupoffset details-level "standard" -s $APICLIsessionfile --format json | $JQ ".objects[].name | @sh" -r`"
    
    if [ x"$NoSystemObjects" = x"true" ] ; then
        # Ignore System Objects
        #MGMT_CLI_GROUPS_STRING="`mgmt_cli show groups limit $APICLIObjectLimit offset $currentgroupoffset details-level "full" -s $APICLIsessionfile --format json | $JQ ".objects[] | '"$systemobjectselector"' | .name | @sh" -r`"
        MGMT_CLI_GROUPS_STRING="`mgmt_cli show groups limit $APICLIObjectLimit offset $currentgroupoffset details-level "full" -s $APICLIsessionfile --format json | $JQ '.objects[] | '"$systemobjectselector"' | .name | @sh' -r`"
    else   
        # Don't Ignore System Objects
        MGMT_CLI_GROUPS_STRING="`mgmt_cli show groups limit $APICLIObjectLimit offset $currentgroupoffset details-level "standard" -s $APICLIsessionfile --format json | $JQ ".objects[].name | @sh" -r`"
    fi
    
    # break the string into an array - each element of the array is a line in the original string
    # there are simpler ways, but this way allows the names to contain spaces. Gaia's bash version is 3.x so readarray is not available
    
    while read -r line; do
        ALLGROUPARR+=("$line")
        echo -n '.'
    done <<< "$MGMT_CLI_GROUPS_STRING"
    echo
    
    return 0
}

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2018-03-05


# -------------------------------------------------------------------------------------------------
# GetArrayOfGroupObjects proceedure
# -------------------------------------------------------------------------------------------------

#
# GetArrayOfGroupObjects generates an array of group objects for further processing.

GetArrayOfGroupObjects () {
    
    #
    # APICLICSVsortparms can change due to the nature of the object
    #
    
    echo
    echo 'Generate array of groups'
    echo
    
    ALLGROUPARR=()

    export MgmtCLI_Base_OpParms="--format json -s $APICLIsessionfile"
    export MgmtCLI_IgnoreErr_OpParms="ignore-warnings true ignore-errors true --ignore-errors true"
    
    export MgmtCLI_Show_OpParms="details-level \"$APICLIdetaillvl\" $MgmtCLI_Base_OpParms"
    
    objectstotal=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" $MgmtCLI_Base_OpParms | $JQ ".total")

    objectstoshow=$objectstotal

    echo "Processing $objectstoshow $APICLIobjecttype objects in $APICLIObjectLimit object chunks:"

    objectslefttoshow=$objectstoshow

    currentgroupoffset=0
    
    while [ $objectslefttoshow -ge 1 ] ; do
        # we have objects to process
        echo "  Now processing up to next $APICLIObjectLimit $APICLIobjecttype objects starting with object $currentgroupoffset of $objectslefttoshow remaining!"

        PopulateArrayOfGroupObjects
        errorreturn=$?
        if [ $errorreturn != 0 ] ; then
            # Something went wrong, terminate
            exit $errorreturn
        fi

        objectslefttoshow=`expr $objectslefttoshow - $APICLIObjectLimit`
        currentgroupoffset=`expr $currentgroupoffset + $APICLIObjectLimit`
    done

    
    return 0
}


# -------------------------------------------------------------------------------------------------
# DumpArrayOfGroupObjects proceedure
# -------------------------------------------------------------------------------------------------

#
# DumpArrayOfGroupObjects outputs the array of group objects.

DumpArrayOfGroupObjects () {
    
    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
        # Verbose mode ON
        # Output list of all groups found
 
        # print the elements in the array
        echo
        echo Dump groups
        echo
        #echo >> $APICLIlogfilepath
        #echo groups >> $APICLIlogfilepath
        #echo >> $APICLIlogfilepath
        
        for i in "${ALLGROUPARR[@]}"
        do
            echo "$i, ${i//\'/}"
            #echo "$i, ${i//\'/}" >> $APICLIlogfilepath
        done
        
        echo
        echo Done dumping groups
        echo
        #echo >> $APICLIlogfilepath
        #echo Done dumping groups >> $APICLIlogfilepath
        #echo >> $APICLIlogfilepath
    
    fi
    
    return 0
}


# -------------------------------------------------------------------------------------------------
# CollectMembersInGroupObjects proceedure
# -------------------------------------------------------------------------------------------------

#
# CollectMembersInGroupObjects outputs the number of group members in a group in the array of group objects and collects them into the csv file.

CollectMembersInGroupObjects () {
    
    #
    # using bash variables in a jq expression
    #
    
    echo
    echo 'Use array of groups to generate group members CSV'
    echo
    #echo >> $APICLIlogfilepath
    #echo 'Use array of groups to export group members in each group' >> $APICLIlogfilepath
    #echo >> $APICLIlogfilepath
    
    for i in "${ALLGROUPARR[@]}"
    do
        echo
        #echo group "${i//\'/}"
    
        MEMBERS_COUNT=$(mgmt_cli show $APICLIobjecttype name "${i//\'/}" -s $APICLIsessionfile --format json | $JQ ".members | length")
    
        NUM_GROUP_MEMBERS=$MEMBERS_COUNT

        if [ $NUM_GROUP_MEMBERS -gt 0 ]; then
            # More than zero (0) interfaces, something to process
            echo Group "${i//\'/}"' number of members = '"$NUM_GROUP_MEMBERS"
            #echo Group "${i//\'/}"' number of members = '"$NUM_GROUP_MEMBERS" >> $APICLIlogfilepath
            
            COUNTER=0
            
            while [ $COUNTER -lt $NUM_GROUP_MEMBERS ]; do
                
                MEMBER_NAME=$(mgmt_cli show $APICLIobjecttype name ${i//\'/} -s $APICLIsessionfile --format json | $JQ ".members[$COUNTER].name")
                
                if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                    # Verbose mode ON
                    echo -n '.'
                    fi
                
                echo ${i//\'/},$MEMBER_NAME >> $APICLICSVfiledata
                #echo ${i//\'/},$MEMBER_NAME >> $APICLIlogfilepath
                
                let COUNTER=COUNTER+1
                
            done
            
        else
            echo Group "${i//\'/}"' number of members = NONE (0 zero)'
            #echo Group "${i//\'/}"' number of members = NONE (0 zero)' >> $APICLIlogfilepath
        fi

    done
    
    
    return 0
}


# -------------------------------------------------------------------------------------------------
# GetGroupMembers proceedure
# -------------------------------------------------------------------------------------------------

#
# GetGroupMembers generate output of group members from existing group objects

GetGroupMembers () {

    SetupGetGroupMembers

    GetArrayOfGroupObjects

    DumpArrayOfGroupObjects

    CollectMembersInGroupObjects

    FinalizeGetGroupMembers

}
    
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

objectstotal_groups=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_groups="$objectstotal_groups"

if [ $number_groups -le 0 ] ; then
    # No groups found
    echo
    echo 'No groups to generate members from!'
    echo
    echo >> $APICLIlogfilepath
    echo 'No groups to generate members from!' >> $APICLIlogfilepath
    echo >> $APICLIlogfilepath
else
    GetGroupMembers
fi

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2017-11-09
# MODIFIED 2017-11-09 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

# -------------------------------------------------------------------------------------------------
# host interfaces
# -------------------------------------------------------------------------------------------------

export APICLIobjecttype=host
export APICLIobjectstype=hosts
export APICLIcomplexobjecttype=host-interface
export APICLIcomplexobjectstype=host-interfaces
export APICLIexportnameaddon=

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# SetupGetHostInterfaces proceedure
# -------------------------------------------------------------------------------------------------

#
# SetupGetHostInterfaces

SetupGetHostInterfaces () {

    #
    # APICLICSVsortparms can change due to the nature of the object
    #
    export APICLICSVsortparms='-f -t , -k 1,1'
    
    export CSVFileHeader='"name","interfaces.add.name"'
    #export CSVFileHeader=$CSVFileHeader',"interfaces.add.subnet4","interfaces.add.mask-length4","interfaces.add.subnet-mask"'
    export CSVFileHeader=$CSVFileHeader',"interfaces.add.subnet4","interfaces.add.mask-length4"'
    export CSVFileHeader=$CSVFileHeader',"interfaces.add.subnet6","interfaces.add.mask-length6"'
    export CSVFileHeader=$CSVFileHeader',"interfaces.add.color","interfaces.add.comments"'
    
    export CSVJQparms='.["name"], .["interfaces"]['$COUNTER']["name"]'
    #export CSVJQparms=$CSVJQparms', .["interfaces"]['$COUNTER']["subnet4"], .["interfaces"]['$COUNTER']["mask-length4"], .["interfaces"]['$COUNTER']["subnet-mask"]'
    export CSVJQparms=$CSVJQparms', .["interfaces"]['$COUNTER']["subnet4"], .["interfaces"]['$COUNTER']["mask-length4"]'
    export CSVJQparms=$CSVJQparms', .["interfaces"]['$COUNTER']["subnet6"], .["interfaces"]['$COUNTER']["mask-length6"]'
    export CSVJQparms=$CSVJQparms', .["interfaces"]['$COUNTER']["color"], .["interfaces"]['$COUNTER']["comments"]'

    SetupExportComplexObjectsToCSVviaJQ
    
    return 0
}
    
# -------------------------------------------------------------------------------------------------
# FinalizeGetHostInterfaces proceedure
# -------------------------------------------------------------------------------------------------

#
# FinalizeGetHostInterfaces

FinalizeGetHostInterfaces () {

    FinalizeExportComplexObjectsToCSVviaJQ
    errorreturn=$?
    if [ $errorreturn != 0 ] ; then
        # Something went wrong, terminate
        exit $errorreturn
    fi
    
    return 0
}
    
# MODIFIED 2018-03-05 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

# -------------------------------------------------------------------------------------------------
# PopulateArrayOfHostInterfaces proceedure
# -------------------------------------------------------------------------------------------------

#
# PopulateArrayOfHostInterfaces populates array of host objects for further processing.

PopulateArrayOfHostInterfaces () {
    
    #
    # APICLICSVsortparms can change due to the nature of the object
    #

    # System Object selection operands
    # export systemobjectselector='select(."meta-info"."creator" != "System")'
    export systemobjectselector='select(."meta-info"."creator" | contains ("System") | not)'
    
    echo
    echo "  $APICLIobjectstype - Populate up to next $APICLIObjectLimit $APICLIobjecttype objects starting with object $currenthostoffset of $objectslefttoshow remaining!"
    echo
    #echo >> $APICLIlogfilepath
    #echo "  $APICLIobjectstype - Populate up to next $APICLIObjectLimit $APICLIobjecttype objects starting with object $currenthostoffset of $objectslefttoshow remaining!" >> $APICLIlogfilepath
    #echo >> $APICLIlogfilepath

    # MGMT_CLI_HOSTS_STRING is a string with multiple lines. Each line contains a name of a host.
    # in this example the output of mgmt_cli is not sent to a file, instead it is passed to jq directly using a pipe.
    
    #MGMT_CLI_HOSTS_STRING="`mgmt_cli show $APICLIobjectstype limit $APICLIObjectLimit offset $currenthostoffset details-level "standard" -s $APICLIsessionfile --format json | $JQ ".objects[].name | @sh" -r`"
    
    if [ x"$NoSystemObjects" = x"true" ] ; then
        # Ignore System Objects
        #MGMT_CLI_HOSTS_STRING="`mgmt_cli show $APICLIobjectstype limit $APICLIObjectLimit offset $currenthostoffset details-level "full" -s $APICLIsessionfile --format json | $JQ ".objects[] | '"$systemobjectselector"' | .name | @sh" -r`"
        MGMT_CLI_HOSTS_STRING="`mgmt_cli show $APICLIobjectstype limit $APICLIObjectLimit offset $currenthostoffset details-level "full" -s $APICLIsessionfile --format json | $JQ '.objects[] | '"$systemobjectselector"' | .name | @sh' -r`"
    else   
        # Don't Ignore System Objects
        MGMT_CLI_HOSTS_STRING="`mgmt_cli show $APICLIobjectstype limit $APICLIObjectLimit offset $currenthostoffset details-level "standard" -s $APICLIsessionfile --format json | $JQ ".objects[].name | @sh" -r`"
    fi
    
    # break the string into an array - each element of the array is a line in the original string
    # there are simpler ways, but this way allows the names to contain spaces. Gaia's bash version is 3.x so readarray is not available
    
     if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
        # Verbose mode ON
        echo
        #echo >> $APICLIlogfilepath

        # Output list of all hosts found - Header
        echo -n '. $line, '
        echo -n '$(eval echo $line), '
        echo -n 'arraylength, '
        echo -n 'arrayelement, '
        #echo -n '$(eval echo ${ALLHOSTARR[${arrayelement}]}) '
        echo -n '$NUM_HOST_INTERFACES, NUM_HOST_INTERFACES > 0 '
        echo
    fi

    while read -r line; do

        ALLHOSTSARR+=("$line")

        echo -n '.'

        arraylength=${#ALLHOSTSARR[@]}
        arrayelement=$((arraylength-1))
        

        if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
            # Verbose mode ON
            # Output list of all hosts found
            echo -n ' '"$line"', '
            echo -n "$(eval echo $line)"', '
            echo -n "$arraylength"', '
            echo -n "$arrayelement"', '
            #echo -n "$(eval echo ${ALLHOSTARR[${arrayelement}]})"', '
        fi

        #INTERFACES_COUNT=$(mgmt_cli show $APICLIobjecttype name "$(eval echo ${ALLHOSTARR[${arrayelement}]})" details-level "full" -s $APICLIsessionfile --format json | $JQ ".interfaces | length")
        INTERFACES_COUNT=$(mgmt_cli show $APICLIobjecttype name "$(eval echo $line)" details-level "full" -s $APICLIsessionfile --format json | $JQ ".interfaces | length")

        NUM_HOST_INTERFACES=$INTERFACES_COUNT

        if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
            echo -n "$NUM_HOST_INTERFACES"', '
        else
            echo -n "$NUM_HOST_INTERFACES"
        fi

        if [ $NUM_HOST_INTERFACES -gt 0 ]; then
            HOSTSARR+=("$line")
            let HostInterfacesCount=HostInterfacesCount+$NUM_HOST_INTERFACES
            echo -n '!'
        else
            echo -n '-'
        fi

         if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
            # Verbose mode ON
            echo
            #echo >> $APICLIlogfilepath
        fi

    done <<< "$MGMT_CLI_HOSTS_STRING"

     if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
        # Verbose mode ON
        echo
        #echo >> $APICLIlogfilepath
       
        echo 'HostInterfacesCount = '$HostInterfacesCount
        #echo 'HostInterfacesCount = '$HostInterfacesCount >> $APICLIlogfilepath
    fi

    export HostInterfacesCount=$HostInterfacesCount

    return 0
}

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2018-03-05


# MODIFIED 2018-03-04 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

# -------------------------------------------------------------------------------------------------
# GetArrayOfHostInterfaces proceedure
# -------------------------------------------------------------------------------------------------

#
# GetArrayOfHostInterfaces generates an array of host objects for further processing.

GetArrayOfHostInterfaces () {
    
    echo
    echo 'Generate array of hosts'
    echo
    #echo >> $APICLIlogfilepath
    #echo 'Generate array of hosts' >> $APICLIlogfilepath
    #echo >> $APICLIlogfilepath
    
    HOSTSARR=()
    ALLHOSTSARR=()

    export MgmtCLI_Base_OpParms="--format json -s $APICLIsessionfile"
    export MgmtCLI_IgnoreErr_OpParms="ignore-warnings true ignore-errors true --ignore-errors true"
    
    export MgmtCLI_Show_OpParms="details-level \"$APICLIdetaillvl\" $MgmtCLI_Base_OpParms"
    
    objectstotal=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" $MgmtCLI_Base_OpParms | $JQ ".total")

    objectstoshow=$objectstotal

    echo "Processing $objectstoshow $APICLIobjecttype objects in $APICLIObjectLimit object chunks:"
    #echo "Processing $objectstoshow $APICLIobjecttype objects in $APICLIObjectLimit object chunks:" >> $APICLIlogfilepath

    objectslefttoshow=$objectstoshow

    currenthostoffset=0

    while [ $objectslefttoshow -ge 1 ] ; do
        # we have objects to process
        echo "  Now processing up to next $APICLIObjectLimit $APICLIobjecttype objects starting with object $currenthostoffset of $objectslefttoshow remaining!"
        #echo "  Now processing up to next $APICLIObjectLimit $APICLIobjecttype objects starting with object $currenthostoffset of $objectslefttoshow remaining!" >> $APICLIlogfilepath

        PopulateArrayOfHostInterfaces
        errorreturn=$?
        if [ $errorreturn != 0 ] ; then
            # Something went wrong, terminate
            exit $errorreturn
        fi

        objectslefttoshow=`expr $objectslefttoshow - $APICLIObjectLimit`
        currenthostoffset=`expr $currenthostoffset + $APICLIObjectLimit`
    done

    echo
    #echo >> $APICLIlogfilepath
    
    echo
    echo 'Final HostInterfacesCount = '$HostInterfacesCount
    echo 'Final Host Array = '\>"${HOSTSARR[@]}"\<
    echo

    return 0
}

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2018-03-04


# -------------------------------------------------------------------------------------------------
# DumpArrayOfHostsObjects proceedure
# -------------------------------------------------------------------------------------------------

#
# DumpArrayOfHostsObjects outputs the array of host objects.

DumpArrayOfHostsObjects () {
    
    if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
        # Verbose mode ON
        # Output list of all hosts found
    
        # print the elements in the array
        echo
        echo Dump All hosts
        echo
        #echo >> $APICLIlogfilepath
        #echo All hosts >> $APICLIlogfilepath
        #echo >> $APICLIlogfilepath
        
        for i in "${ALLHOSTSARR[@]}"
        do
            echo "$i, ${i//\'/}"
            #echo "$i, ${i//\'/}" >> $APICLIlogfilepath
        done
        
        echo
        echo hosts with interfaces defined
        echo
        #echo >> $APICLIlogfilepath
        #echo hosts with interfaces defined >> $APICLIlogfilepath
        #echo >> $APICLIlogfilepath
        
        for j in "${HOSTSARR[@]}"
        do
            echo "$j, ${j//\'/}"
            #echo "$j, ${j//\'/}" >> $APICLIlogfilepath
        done
        
        echo
        echo Done dumping hosts
        echo
        #echo >> $APICLIlogfilepath
        #echo Done dumping hosts >> $APICLIlogfilepath
        #echo >> $APICLIlogfilepath
        
    fi

    return 0
}


# MODIFIED 2018-03-04 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

# -------------------------------------------------------------------------------------------------
# CollectInterfacesInHostObjects proceedure
# -------------------------------------------------------------------------------------------------

#
# CollectInterfacesInHostObjects outputs the host interfaces in a host in the array of host objects and collects them into the csv file.

CollectInterfacesInHostObjects () {
    
    #
    # using bash variables in a jq expression
    #
    
    echo
    echo 'Use array of hosts to generate host interfaces CSV'
    echo
    #echo >> $APICLIlogfilepath
    #echo 'Use array of hosts to export interfaces in each host' >> $APICLIlogfilepath
    #echo >> $APICLIlogfilepath
    
    for i in "${HOSTSARR[@]}"
    do
        echo
        echo Host with interfaces "${i//\'/}"
    
        INTERFACES_COUNT=$(mgmt_cli show $APICLIobjecttype name "${i//\'/}" -s $APICLIsessionfile --format json | $JQ ".interfaces | length")

        NUM_HOST_INTERFACES=$INTERFACES_COUNT
    
        if [ $NUM_HOST_INTERFACES -gt 0 ]; then
            # More than zero (0) interfaces, something to process
            echo host "${i//\'/}"' number of interfaces = '"$NUM_HOST_INTERFACES"
            #echo host "${i//\'/}"' number of interfaces = '"$NUM_HOST_INTERFACES" >> $APICLIlogfilepath
       
            COUNTER=0
            if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                # Verbose mode ON
                echo $CSVFileHeader
                #echo $CSVFileHeader >> $APICLIlogfilepath
                fi

            while [ $COUNTER -lt $NUM_HOST_INTERFACES ]; do
        
                #echo -n '.'
    
                #export CSVJQparms='.["name"], .["interfaces"]['$COUNTER']["name"]'
                #export CSVJQparms=$CSVJQparms', .["interfaces"]['$COUNTER']["subnet4"], .["interfaces"]['$COUNTER']["mask-length4"], .["interfaces"]['$COUNTER']["subnet-mask"]'
                #export CSVJQparms=$CSVJQparms', .["interfaces"]['$COUNTER']["subnet4"], .["interfaces"]['$COUNTER']["mask-length4"],
                #export CSVJQparms=$CSVJQparms', .["interfaces"]['$COUNTER']["subnet6"], .["interfaces"]['$COUNTER']["mask-length6"]'
                #export CSVJQparms=$CSVJQparms', .["interfaces"]['$COUNTER']["color"], .["interfaces"]['$COUNTER']["comments"]'

                INTERFACE_NAME=$(mgmt_cli show $APICLIobjecttype name ${i//\'/} -s $APICLIsessionfile --format json | $JQ '.["interfaces"]['$COUNTER']["name"]')
                INTERFACE_subnet4=$(mgmt_cli show $APICLIobjecttype name ${i//\'/} -s $APICLIsessionfile --format json | $JQ '.["interfaces"]['$COUNTER']["subnet4"]')
                INTERFACE_masklength4=$(mgmt_cli show $APICLIobjecttype name ${i//\'/} -s $APICLIsessionfile --format json | $JQ '.["interfaces"]['$COUNTER']["mask-length4"]')
                INTERFACE_subnetmask=$(mgmt_cli show $APICLIobjecttype name ${i//\'/} -s $APICLIsessionfile --format json | $JQ '.["interfaces"]['$COUNTER']["subnet-mask"]')
                INTERFACE_subnet6=$(mgmt_cli show $APICLIobjecttype name ${i//\'/} -s $APICLIsessionfile --format json | $JQ '.["interfaces"]['$COUNTER']["subnet6"]')
                INTERFACE_masklength6=$(mgmt_cli show $APICLIobjecttype name ${i//\'/} -s $APICLIsessionfile --format json | $JQ '.["interfaces"]['$COUNTER']["mask-length6"]')
                INTERFACE_COLOR=$(mgmt_cli show $APICLIobjecttype name ${i//\'/} -s $APICLIsessionfile --format json | $JQ '.["interfaces"]['$COUNTER']["color"]')
                INTERFACE_COMMENT=$(mgmt_cli show $APICLIobjecttype name ${i//\'/} -s $APICLIsessionfile --format json | $JQ '.["interfaces"]['$COUNTER']["comments"]')
                
                export CSVoutputline="${i//\'/}","$INTERFACE_NAME"
                #export CSVoutputline=$CSVoutputline,"$INTERFACE_subnet4","$INTERFACE_masklength4","$INTERFACE_subnetmask"
                export CSVoutputline=$CSVoutputline,"$INTERFACE_subnet4","$INTERFACE_masklength4"
                export CSVoutputline=$CSVoutputline,"$INTERFACE_subnet6","$INTERFACE_masklength6"
                export CSVoutputline=$CSVoutputline,"$INTERFACE_COLOR","$INTERFACE_COMMENT"
                
                if [ x"$APISCRIPTVERBOSE" = x"true" ] ; then
                    # Verbose mode ON
                    echo $CSVoutputline
                    #echo $CSVoutputline >> $APICLIlogfilepath
                    fi

                echo $CSVoutputline >> $APICLICSVfiledata
                #echo $CSVoutputline >> $APICLIlogfilepath
        
                let COUNTER=COUNTER+1
        
            done
        else
            echo host "${i//\'/}"' number of interfaces = NONE (0 zero)'
            #echo host "${i//\'/}"' number of interfaces = NONE (0 zero)' >> $APICLIlogfilepath
        fi
    
    done
    
    
    return 0
}

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2018-03-04


# MODIFIED 2018-03-04 \/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/
#

# -------------------------------------------------------------------------------------------------
# GetHostInterfaces proceedure
# -------------------------------------------------------------------------------------------------

#
# GetHostInterfaces generate output of host's interfaces from existing hosts with interface objects

GetHostInterfaces () {

    export HostInterfacesCount=0

    SetupGetHostInterfaces

    GetArrayOfHostInterfaces

    if [ $HostInterfacesCount -gt 0 ]; then
        # We have host interfaces to process
        DumpArrayOfHostsObjects
    
        CollectInterfacesInHostObjects
    
        FinalizeGetHostInterfaces

    else
        # No host interfaces
        echo
        echo '! No host interfaces found'
        echo
    fi
}

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

objectstotal_hosts=$(mgmt_cli show $APICLIobjectstype limit 1 offset 0 details-level "standard" --format json -s $APICLIsessionfile | $JQ ".total")
export number_hosts="$objectstotal_hosts"

if [ $number_hosts -le 0 ] ; then
    # No hosts found
    echo
    echo 'No hosts to generate interfaces from!'
    echo
    echo >> $APICLIlogfilepath
    echo 'No hosts to generate interfaces from!' >> $APICLIlogfilepath
    echo >> $APICLIlogfilepath
else
    GetHostInterfaces
fi

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

#
# /\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\ MODIFIED 2017-11-09


# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
# no more complex objects
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------
# no more objects
# -------------------------------------------------------------------------------------------------
# -------------------------------------------------------------------------------------------------

echo
echo $APICLIdetaillvl' CSV dump - Completed!'
echo

echo
echo

# =================================================================================================
# END:  Export objects to csv
# =================================================================================================
# =================================================================================================

