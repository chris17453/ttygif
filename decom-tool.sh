#!/etrade/bin/ksh



SCRIPT_DIR="$( cd "$( dirname "$0" )" && pwd )"
TARGET=$(echo $1 | cut -f1 -d.)






#TODO, unravel functions that hide logical data, curl wget, etc

# check_summary:
#    print a table row for each check with name,success,failure
# success: None
# failure: None
check_summary(){
    name=$1 
    exit=$2
    if [ "$exit" -ne 0 ] ; then
       line="$(printf "| %-15s@%s" $name \
            | sed -e 's/ /-/g' -e 's/@/ /' -e 's/-/ /')|    | NG |"
    else
       line="$(printf "| %-15s@%s" $name \
            | sed -e 's/ /-/g' -e 's/@/ /' -e 's/-/ /')| OK |    |"
    fi
    echo "$line"
}



# report_section:
#    create unified output for multiline data with a header
# results: modified textual output
# success: None
# failure: None
report_section(){
    name="$1"
    data="$2"
    printf "|-"
    printf "%-40s@%s\n" "[$name]" | sed -e 's/ /-/g' -e 's/@/ /' -e 's/-/ /'
    
    while IFS= read -r line
    do
        echo "|    $line"
    done <<(printf '%s\n' "$data")
    printf "|\n"
}



# check_os:
#    determine target system operating system from installcleints,
#    and ability to kmssh
# result: variable export "unable_to_kmssh" on OS result="Solaris"
# success: None
# failure: None
check_os(){
   res="$(cat /etrade/etc/installclients | grep "$TARGET:"|grep Solaris)"
   if [ $? -eq 0 ]; then
       export unable_to_kmssh=true
   fi
}

allowed_hosts(){
  AM_I_ADM=$(echo $(hostname) | cut -f1 -d.)
  ADM_COUNT=0
   ADM_HOSTS[${#ADM_HOSTS[*]}+1]=adm1m7
   ADM_HOSTS[${#ADM_HOSTS[*]}+1]=adm0m3
   ADM_HOSTS[${#ADM_HOSTS[*]}+1]=lxadm0m3
   for adm_host in ${ADM_HOSTS[@]};
    do
      if [ $AM_I_ADM != $adm_host ]; then
       ((ADM_COUNT++))
      fi
   done
   if [[ $ADM_COUNT = 3 ]]; then
       echo "$0 must be ran from one of the follow adm hosts:"
       echo -e "\tadm1m7"
       echo -e "\tadm0m3"
       echo -e "\tlxadm0m3"
       exit 1
   fi
}

# local_or_remote:
#    determine if the script is targeting the local machine or a remote machine
# result: varying messages based on check 
# success: None
# failure: None
local_or_remote(){
   if [ $TARGET = $(hostname | cut -f1 -d.) ]; then
      report_section "MODE" "DECOM TOOL: Running in LOCAL mode"
   else
      report_section "MODE" "DECOM TOOL: Running in REMOTE mode"
      export exec_remote="etcmd -s kmssh root@$TARGET"
      allowed_hosts
      check_os
   fi
}

solaris_exit(){
# -- If solaris don't run kmssh commands
  if [ ! -z $unable_to_kmssh ]; then
   echo "SKIPPING - $function - $TARGET is Solaris, KMSSH not supported"
  fi
}

solaris_norun(){
# -- Some functions aren't supported on solaris locally
   if [ $(uname) = 'SunOS' ]; then
     echo "SKIPPING - $function - not supported on  Solaris"
   fi
}

# check_connections:
#     Check for active connections asside from SSH and KMSSH
# success: no other connections detected
# failure: any other connections detected
check_connections(){
   SSH_PORT=22
   KMSSH_PORT=1122
   LDAP_PORT=636
   SYSLOG_PORT=8455
   APPPROVID_PORT=1858
   TARGET=$(hostname)
   if [ $(uname) = 'SunOS' ]; then
    NETSTAT=$(netstat -P tcp \
            | grep -i established \
            | awk '{print $4,$5}' \
            | egrep -v "${SSH_PORT}|${KMSSH_PORT}|${LDAP_PORT}|${SYSLOG_PORT}|${APPPROVID_PORT}")
   else
    NETSTAT=$(netstat -nt \
        | grep -i established \
        | awk '{print $4,$5}' \
        | egrep -v "${SSH_PORT}|${KMSSH_PORT}|${LDAP_PORT}|${SYSLOG_PORT}|${APPPROVID_PORT}")
   fi
   
   echo "$NETSTAT"
   
   if [ -z  "$NETSTAT" ]; then
     echo "$TARGET : NO CONNECTIONS : READY for DECOM"
     return 0
    else
     echo "$TARGET : CONNECTIONS DETECTED - IN SERVICE"
   fi
   return 1
}

# current_users:
#    check for logged in users other than the on running the script
# success: no other users logged in 
# failure: any other user logged in
current_users(){
    current_user=$(whoami)
    users=$(users | tr ' ' '\n' | sort | uniq)
    user_count=0
    TARGET=$(hostname)

    if [ ! -z "$users" ]
    then
        for user in $users
        do
            if [ "$user" !=  "$current_user" ];  then
                ((user_count++))
                echo "$TARGET : user : $user"
            fi
        done 
    fi

    if [ $user_count -eq 0 ]; then
        echo "$TARGET : NO USERS DETECTED : READY for DECOM"
        return 0
    else
        echo "$TARGET : ( $user_count ) USERS DETECTED : FAIL "
        return 1
    fi
}


# check_deployments:
#   check deployments for a all lines in the deployments file with D for decom
# success: all lines contain a D or do not exist for given target
# failure: any linme that contains other than D for given target
check_deployments(){
    #-- deployments is always local
    hostname=":$TARGET:"

    configured=$(grep "$hostname"  /etrade/etc/deployments | grep -v '^#')
    if [ -z "$configured" ]
    then
        echo "$TARGET : NO ET DEPLOYMENTS : READY for DECOM"
        return 0
    fi

    # -- shift grep to field 8 because of file being grepped appended
    states=$(grep "$hostname"  /etrade/etc/deployments \
        | grep -v '^#'\
        | cut -d ':' -f 8 \
        | grep -v '^D')
  
    state_lines=$(grep "$hostname"  /etrade/etc/deployments)
    echo "$state_lines"  
    if [ ! -z "$states" ]; then
        echo "$TARGET : ET DEPLOYMENTS DETECTED: IN SERVICE - NOT SET TO DECOM"
        return 1
    fi
    # everything is always a failure unless proven otherwise
    echo "$TARGET : ET DEPLOYMENTS : IN SERVICE -FAILSAFE"
    return 1
}


# check_services :
#   determines if protected services are running on the target server
#   the services are listed in an "services" array
# success: if no protected services are found
# fail : if any protected services is found
check_services(){
    TARGET=$(hostname)
    services[${#services[*]}+1]='httpd'
    services[${#services[*]}+1]='java'
    services[${#services[*]}+1]='ora_'
    services[${#services[*]}+1]='dataserver'
    services[${#services[*]}+1]='p_ctmag'
    services[${#services[*]}+1]='repserver'
    services[${#services[*]}+1]='mysqld'
    services[${#services[*]}+1]='beam.smp'
    services[${#services[*]}+1]='Svr'
    services[${#services[*]}+1]='BBL'
    services[${#services[*]}+1]='replicat'
    # TODO if local/remote. ask jordan 
    services[${#services[*]}+1]='kvm'
    services[${#services[*]}+1]='qemu'

    # array of services to check for
    exit_code=0

    # loop through the services
    for service in ${services[@]}; do
    results=$(ps -e| grep "$service" | grep -v 'grep')
    if [ ! -z "$results" ]
    then
        ((exit_code++))
        echo "$TARGET : $service IN SERVICE"
    fi
    done
    if [ $exit_code -eq 0 ]; then 
        echo "$TARGET : NO ACTIVE SERVICES CHECK :  READY for DECOM"
        return 0
    fi
    return 1
}

check_nagios(){
   if [ $(uname) = 'SunOS' ]; then
     echo "SKIPPING - check_nagios - not supported on  Solaris"
     return 0
   fi
   M3=http://dashboard.etrade.com/data/nagios10w100m3.status.dat
   M5=http://dashboard.etrade.com/data/nagios2w309m5.status.dat
   UAT=http://uatdashboard.etrade.com/data/uat309w92m7.status.dat
   SIT=http://sitdashboard.etrade.com/data/sit359w86m7.status.dat
   DIT=http://ditdashboard.etrade.com/data/ditnagios1w104m7.status.dat
   DR=http://drdashboard.etrade.com/data/nagios1w38m7.status.dat
   OTE=http://otedashboard.etrade.com/data/ote128w222m7.status.dat
   PPLT=http://ppltdashboard.etrade.com/data/pplt121w76m7.status.dat
   DVL=http://ditdashboard.etrade.com/data/dvl1w98m7.status.dat
   

   
   NAGIOS_SITES[${#NAGIOS_SITES[*]}+1]=${M3}
   NAGIOS_SITES[${#NAGIOS_SITES[*]}+1]=${M5}
   NAGIOS_SITES[${#NAGIOS_SITES[*]}+1]=${UAT}
   NAGIOS_SITES[${#NAGIOS_SITES[*]}+1]=${SIT}
   NAGIOS_SITES[${#NAGIOS_SITES[*]}+1]=${DIT}
   NAGIOS_SITES[${#NAGIOS_SITES[*]}+1]=${DR}
   NAGIOS_SITES[${#NAGIOS_SITES[*]}+1]=${OTE}
   NAGIOS_SITES[${#NAGIOS_SITES[*]}+1]=${PPLT}
   NAGIOS_SITES[${#NAGIOS_SITES[*]}+1]=${DVL}
   
   FAIL_COUNT=0
   SITE_COUNT=$(echo ${NAGIOS_SITES[@]} | wc -w)
   
   for site in ${NAGIOS_SITES[@]}
     do
     curl -s --connect-timeout 2 ${site} | grep -q $TARGET || FAIL_COUNT=$((FAIL_COUNT + 1))
   done
   
   if [ ${FAIL_COUNT} -lt ${SITE_COUNT} ]; then
      echo "$TARGET : NAGIOS CONFIGURATION DETECTED : IN SERVICE"
     else
      echo "$TARGET : NO NAGIOS CONFIGURATION : READY for DECOM"
      return 0
   fi
   return 1
}

# check mount:
#    determins if protected or unknown mounts are mounted on target system
# mounts are validated by:
#   - a safe target array
#   - a safe Filesystem array
#   - a safe mount array
#   - a explicit filesystem fail array
#   - success: if a mount matches any of the safe array types
#   - failure: an explicit fail match or NOT matched safe 
# success: if no mount failures occur
# failure: any mount failure
check_mounts(){
    TARGET=$(hostname)
    OS=$(uname)
    if [ "$OS" = "SunOS" ]; then
        echo_cmd="echo"
    else
        echo_cmd="echo -e"
    fi

    # ignore these mounts....
    ignore_target[${#ignore_target[*]}+1]='/'
    ignore_target[${#ignore_target[*]}+1]='/dev/shm'
    ignore_target[${#ignore_target[*]}+1]='/boot'
    ignore_target[${#ignore_target[*]}+1]='/etrade'
    ignore_target[${#ignore_target[*]}+1]='/tmp'
    ignore_target[${#ignore_target[*]}+1]='/var/log'

    # ignore these file system types
    ignore_type[${#ignore_type[*]}+1]="tmpfs"
    ignore_type[${#ignore_type[*]}+1]="cgroup"
    ignore_type[${#ignore_type[*]}+1]="mqueue"
    ignore_type[${#ignore_type[*]}+1]="debugfs"
    ignore_type[${#ignore_type[*]}+1]="binfmt_misc"
    ignore_type[${#ignore_type[*]}+1]="hugetlbfs"
    ignore_type[${#ignore_type[*]}+1]="cgroup2"
    ignore_type[${#ignore_type[*]}+1]="devpts"
    ignore_type[${#ignore_type[*]}+1]="efivarfs"
    ignore_type[${#ignore_type[*]}+1]="pstore"
    ignore_type[${#ignore_type[*]}+1]="proc"
    ignore_type[${#ignore_type[*]}+1]="securityfs"
    ignore_type[${#ignore_type[*]}+1]="configfs"
    ignore_type[${#ignore_type[*]}+1]="autofs"
    ignore_type[${#ignore_type[*]}+1]="rpc_pipefs"
    ignore_type[${#ignore_type[*]}+1]="devtmpfs"
    ignore_type[${#ignore_type[*]}+1]="sysfs"


    # sometimes mouNts are not standard... 
    # only 1 device alowed, may start with h,s or v (hda,sda,vda)
    block_device_count=$(mount -v \
        | grep -oh "[h|s|v][d][a-z][?]*\w"\
        | cut -b 1-3 \
        | sort \
        | uniq \
        | wc -l)
    if [ "$block_device_count" = "1" ]; then
        echo "Only 1 block Device"
        ignore_block_device[0]="/dev/$(mount -v \
            | grep -oh "[h|s|v][d][a-z][?]*\w"\
            | cut -b 1-3 \
            | sort \
            | uniq )"
    else
        # ignore these block devices
        echo "More than 1 block Device"
        ignore_block_device[0]=''
    fi

    # fail for veritas or oracle mounts
    explicit_fail_type[${#explicit_fail_type[*]}+1]='vxfs'
    explicit_fail_type[${#explicit_fail_type[*]}+1]='acfs'


    tmp_mount='/tmp/mount_output'
    mount -v >$tmp_mount
    echo "Mode | Chk | FileSystem   | Block Device                 | Mount"
    echo "-----|-----|--------------|------------------------------|-------------"
    while  read -r line
    do
        target=$(echo "$line" | cut -d ' ' -f 3)
        type=$(echo "$line" | cut -d ' ' -f 5)
        block_device=$(echo "$line" | cut -d ' ' -f 1)

        col1="$(printf "%-12s%s" $type)"
        col2="$(printf "%-28s%s" $block_device)"
        col3="$target"
        
        cols=" $col1 | $col2 | $col3"
        # block device test
        ignore=1
        for i in "${ignore_block_device[@]}"
        do

            if [ -z $(echo "$block_device"|grep -v "$i") ] ; then
                ignore=0
                safe[${#safe[*]}+1]="Safe | BLK |$cols"
                fi
        done
        if [ $ignore -eq 0 ] ; then
            continue
        fi

        # target test
        ignore=1
        for i in "${ignore_target[@]}"
        do

            if [ "$i" = "$target" ] ; then
                ignore=0
                safe[${#safe[*]}+1]="Safe | MNT |$cols"
            fi
        done
        if [ $ignore -eq 0 ] ; then
            continue
        fi

        # filesystem test
        ignore=1
        for i in "${ignore_type[@]}"
        do
            if [ "$i" = "$type" ]; then
                ignore=0
                safe[${#safe[*]}+1]="Safe | FS  |$cols"
            fi
        done
        if [ $ignore -eq 0 ]; then
            continue
        fi

        # explicit filesystem fail test
        found=0
        for i in "${explicit_fail_type[@]}"
        do
            if [ "$i" = "$type" ]; then
                fail[${#fail[*]}+1]="FAIL | FS  |$cols"
                found=1
                break
            fi
        done
        if [ $found -eq 1 ] ; then
            continue
        fi

        unk[${#unk[*]}+1]="  UNKOWN   |$cols"

    done<"$tmp_mount"

    # cleanup
    rm "$tmp_mount"

    for i in "${safe[@]}"; do
        $echo_cmd "$i"
    done
    for i in "${fail[@]}"; do
        $echo_cmd "$i"
    done
    for i in "${unk[@]}"; do
        $echo_cmd "$i"
    done

    if [ ${#unk[@]} -ne 0 ]; then
        $echo_cmd "$TARGET : UNKNOWN MOUNTS DETECTED : NEEDS FURTHER REVIEW"
    fi

    if [ ${#fail[@]} -ne 0 ]; then
        $echo_cmd "$TARGET : ACTIVE MOUNTS DETECTED : IN SERVICE"
    fi

    if [ ${#fail[@]} -eq 0 ] &&  [ ${#unk[@]} -eq 0 ];  then
        $echo_cmd "$TARGET : READY for DECOM"
        return 0
    fi

    return 1
}

# check_netscaler:
#    determine if a config exist for the traget server in the netscaler system
# success: if string match from url parse matches the target server
# failure: fail if string match from url parse does not match the target server
check_netscaler(){
   if [ $(uname) = 'SunOS' ]; then
     echo "SKIPPING - check_netscaler - not supported on  Solaris"
     return 0
   fi
   URI="http://infra.etrade.com/lb/netscaler_configs.pl?search=true&pattern=server"
   # the call
   res="$(wget --timeout=2 -q -O - $URI+$TARGET \
        | grep "No server $TARGET matches found")"
   NETSCALER_RESULTS=$?
   
   if [ "$NETSCALER_RESULTS" -eq 0 ] ; then
     echo "$TARGET : NO NETSCALER CONFIGURATION : READY for DECOM"
   else
     echo "$TARGET : NETSCALER CONFIGURATION DETECTED : IN SERVICE"
   fi
   return $NETSCALER_RESULTS
}

# facts:
#    determine usefull information about a target system
# reported information:
#   - system time
#   - logged in user
#   - system name
#   - uptime
#   - all ipv4 addresses
# 
facts(){
    now=$(date)
    user=$(whoami)
    if [ $(uname) = 'SunOS' ]; then
        echo_cmd="echo"
        ips=$(/usr/sbin/ifconfig -a| grep inet| cut -d' ' -f2)
    else
        echo_cmd="echo -e"
        ips=$(ifconfig \
            | grep inet \
            | cut -d ':' -f 2 \
            | cut -d ' ' -f 1 \
            | sort \
            | uniq)
        
        if [ -z "$ips" ]; then
            ips=$(ip addr show | grep 'inet '|cut -d ' ' -f 6| sort|uniq)
        fi 
    fi
    host=$(hostname)
    time_up=$(uptime)
    $echo_cmd "Date   : $now"
    $echo_cmd "User   : $user"
    $echo_cmd "Host   : $host"
    $echo_cmd "Uptime : $time_up"
    for ip in $ips; do
        if [ "$ip" != "127.0.0.1" ]; then
            $echo_cmd "IP: $ip"
        fi
    done
    return 0
}

# execute_functions:
#    runs functions over kmssh, and returns the results
#    support for local solaris added, 
#    however blocked at script init
#    by request
# success: a kmssh connection, and returned function result
# failure: no connection
execute_functions(){

   if [ ! -z $exec_remote ]; then
        res="$(which kmssh)"
        if [ $? -eq 1 ]; then
                echo "Error: KMSSH is not available"
                return 1
        fi
        if [ ! -z  $unable_to_kmssh ]; then
            solaris_exit
            return 1
        else 
         $exec_remote "$(typeset -f $1); $1"
        fi
   else
    $1
   fi
   return $?
}


# Begin Script


# enforce script running with a target
if [ -z $1 ]; then
  echo "This script requires you provide the hostname"
  echo "$0 <hostname>"
  exit 1
fi

# determine if this scripts running location
local_or_remote

# optional for verbosity
check_01_name="FACTS";
check_01_data=$(facts "$(hostname)")
check_01_exit=$?;

check_02_name="FACTS";
check_02_data=$(execute_functions facts)
check_02_exit=$?;

# actual checks
check_03_name="DEPLOYMENTS"; 
check_03_data=$(check_deployments)
check_03_exit=$?;

check_04_name="NETSCALER";
check_04_data=$(check_netscaler)
check_04_exit=$?;

check_05_name="NAGIOS";
check_05_data=$(check_nagios)
check_05_exit=$?;

check_06_name="SERVICES";
check_06_data=$(execute_functions check_services)   
check_06_exit=$?; 

check_07_name="MOUNTS";
check_07_data=$(execute_functions check_mounts)
check_07_exit=$?;

check_08_name="USERS";
check_08_data=$(execute_functions current_users)    
check_08_exit=$?;

check_09_name="CONNECTIONS";
check_09_data=$(execute_functions check_connections)
check_09_exit=$?;




# Binary sumary aggregate, overall pass/fail
total_exit=1
if [ $check_03_exit == 0 ] && \
   [ $check_04_exit == 0 ] && \
   [ $check_05_exit == 0 ] && \
   [ $check_06_exit == 0 ] && \
   [ $check_07_exit == 0 ] && \
   [ $check_08_exit == 0 ] && \
   [ $check_09_exit == 0 ] ; then total_exit=0; fi

# verbosity
if [ "$2" = '-v' ]; then
    report_section  "$check_01_name" "$check_01_data"
    report_section  "$check_02_name" "$check_02_data"
    report_section  "$check_03_name" "$check_03_data"
    report_section  "$check_04_name" "$check_04_data"
    report_section  "$check_05_name" "$check_05_data"
    report_section  "$check_06_name" "$check_06_data"
    report_section  "$check_07_name" "$check_07_data"
    report_section  "$check_08_name" "$check_08_data"
    report_section  "$check_09_name" "$check_09_data"
fi


# BINARY SUMMARY
echo "|-CHECK-----------|-OK-|-NG-|"
check_summary "$check_03_name" "$check_03_exit"
check_summary "$check_04_name" "$check_04_exit"
check_summary "$check_05_name" "$check_05_exit"
check_summary "$check_06_name" "$check_06_exit"
check_summary "$check_07_name" "$check_07_exit"
check_summary "$check_08_name" "$check_08_exit"
check_summary "$check_09_name" "$check_09_exit"
echo "|-----------------|-OK-|-NG-|"
check_summary "$TARGET" "$total_exit"
echo "|-----------------|----|----|"

if [ $total_exit -eq 0 ]; 
then 
   echo " YOU CAN DECOM $TARGET"
   exit 0
else
   echo "*** DO NOT DECOM  $TARGET ***"
   exit 1
fi



