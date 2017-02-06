#!/bin/bash -e

######################## META SECTION ################################
#
# Prints the command start and end markers with timestamps
# and executes the supplied command
#

before_exit() {
  ## flush any remaining console
  echo $1
  echo $2

  if [ "$is_success" == true ]; then
    echo "__SH__SCRIPT_END_SUCCESS__";
  else
    echo "__SH__SCRIPT_END_FAILURE__";
  fi
}

exec_cmd() {
  cmd=$@
  cmd_uuid=$(python -c 'import uuid; print str(uuid.uuid4())')
  cmd_start_timestamp=`date +"%s"`
  echo "__SH__CMD__START__|{\"type\":\"cmd\",\"sequenceNumber\":\"$cmd_start_timestamp\",\"id\":\"$cmd_uuid\"}|$cmd"
  eval $cmd
  cmd_status=$?
  if [ "$2" ]; then
    echo $2;
  fi

  cmd_end_timestamp=`date +"%s"`
  echo "__SH__CMD__END__|{\"type\":\"cmd\",\"sequenceNumber\":\"$cmd_start_timestamp\",\"id\":\"$cmd_uuid\",\"completed\":\"$cmd_status\"}|$cmd"
  return $cmd_status
}

exec_grp() {
  group_name=$1
  group_uuid=$(python -c 'import uuid; print str(uuid.uuid4())')
  group_start_timestamp=`date +"%s"`
  echo "__SH__GROUP__START__|{\"type\":\"grp\",\"sequenceNumber\":\"$group_start_timestamp\",\"id\":\"$group_uuid\"}|$group_name"
  eval "$group_name"
  group_status=$?
  group_end_timestamp=`date +"%s"`
  echo "__SH__GROUP__END__|{\"type\":\"grp\",\"sequenceNumber\":\"$group_end_timestamp\",\"id\":\"$group_uuid\",\"completed\":\"$group_status\"}|$group_name"
}

travis_retry() {
  shippable_retry "$@"
}

shippable_retry() {
  typeset retry_cmd="$@"
  for i in `seq 1 3`;
  do
    {
      eval "$retry_cmd"
      ret=$?
      [ $ret -eq 0 ] && break;
    } || {
      echo "retrying $i of 3 times..."
      echo $retry_cmd
    }
  done
  return $ret
}

exec_project_ssh_cmd() {
  cmd=$1
  exec_cmd "$cmd"
  ssh_cmd_status=$?

  return $ssh_cmd_status
}

_run_update() {
  is_success=false
  update_cmd="sudo -E apt-get update"
  exec_cmd "$update_cmd"
  is_success=true
}

######################## END META SECTION ###########################
######################## END HEADER SECTION #########################

######################### REMOTE COPY SECTION ##########################
########################################################################
## SSH variables ###
readonly NODE_SSH_IP="0.0.0.0"
readonly NODE_SSH_PORT=""
readonly NODE_SSH_USER="shippable"
readonly NODE_SSH_PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA4yxYb8Y9iVrbV/fCzNceolJkqgZ2S7bnTIZlBVW8FB4ao+0K
oDVXaZNoz10IbvJHCB8Tcao9iF6/zUQoAfQI/NcLIsrhlhVtUCuP6RI32IlA7yBb
ZLFSZn0bB69ReG+KRQxdL6r65+eo6V+HuuK9ISYCvwyy1KezJj6USBkKjsfKa7Ft
Own2PzAd9HtlA4oLSN5cvOOVzPTJhrN/Vx+IgoZYcYuaCbKj0Ktaq+IwRYLsXSSb
/+LnBnTrrLBcArc3Myl4zdVxIJXHSBadRy/zuU/sHar4w+Gk1XzXNPZkRz7Pjl/F
YHr0Qbq+tkx/nlNC5s6Xf4uhu94i+WBNSC/hTwIDAQABAoIBAQCnoOZU/BwWSZPG
8oysqCPztQaQq5oIvpsoTZcne57/3ULdKSGJHDM3NU3GjaiWbXJanMu1OOCUyw2O
wrce0dr77xZJgxk4rPDvkmVrn0TUJFtk2CR4RZw/Ahu67PQaAXwu/TOZ4/mmu7tZ
EWPPVFYoqqqmHRGsd15rXwv9s3Sl64SK5NKdCBJeBqjcic1ldgwBcjf36F5qGVz7
5dIRqfwvR8Xl+nEfne9NviUmdShP5V290rSY+MWPW0Cj2g2FwVQP3Johv0/JvmtH
1j4F7tHVKqlFuL2yvGWqgbbHWaLk58S3T4DnL03YFqbJCXDXmaIsMSpZOgXIpiKs
B8SAxtPxAoGBAP83493FPUUSk7CphvJ01W2nJ0IQ3OUPaneZxUfKymEBM5/61p+T
7evVPeHHL1ojZMNB+eMLSNqcZz1ZPO86/64dueS0LOAVJw4mSHFO0pFXuK0Pib6Y
9rau83EsghhuyfI3bpM8Mu8EON58plBGQnVcoOSsO95BXaUIEgwgXXSZAoGBAOPe
d0fDM3Zwj7TnzLJ3piEttQAYw1jV2bBKVDubHMrr6a5kGlpbF8yPhIQ2pju4SXyI
0wjkhdAg47/PhvZOp7lbOZqDrzfNb7k7NQ5sxQl3tfKbM96axiBFrYLN3cMdreKv
la6NM8GBOORJggzt3uULfgHLniiV3Z4kv3gLIM4nAoGAQuxD6yZKT690XNHHWhJ6
2LsJF1DWq5XkRCJlUdMCSHeJMv0ShFvE+p87D9YsO4WmaXEGdpvB6dkzVSnuSYj9
/Ik88pSwY74INLSjMFsL6iLHgVHeu8TehL7RhS63mnKKr+ILM76IWJaR1v12mvwh
dybn5a6oMDqRtLGuEdH2z5kCgYAL4lxiN8IFWVWFX9mDLU5SyKl5+dCmX3DdCuNd
wHc99hPX7oyZTcrt9kY5BwigcLoUbqZi/lgkRLLcHByz1+JTfniAoIGQ7Xv4MyhP
OkkEd2Pb5VBNOdE/eaLVAZuhQ3kAK5wo4GBkpTKsZVEND5LiazkFKvNytm46gzwh
LKNnXQKBgQCE2w5wOyHQyeb1LD2OeNt+XzeicYnKyM1KYRqfYon7pTDIcRYQt5vf
HcLRiZ1LUiMJR8+Ea4hwg2quqhNxIQB+XQV+j1q3HOARG7I0HhzKE+KwU6LjIBnT
OHSUrSmMjnr/J4D1QACH8AMGRDmqxySvBdxDLFR9yzrs5WpLj6rPvA==
-----END RSA PRIVATE KEY-----
"

## Read command line args ###
block_uuid=$1
script_uuid=$2

copy_script_remote() {
  echo "copying clone CDS scripts to remote host: $NODE_SSH_IP"

  script_folder="/tmp/$block_uuid"
  script_name="$block_uuid-$script_uuid.sh"
  script_path="/tmp/$block_uuid/$script_name"
  node_key_path=$script_folder/node_key

  exec_cmd "echo 'Copying keys'"
  copy_key=$(echo -e "$NODE_SSH_PRIVATE_KEY"  > $node_key_path)
  chmod_cmd="chmod -cR 600 $node_key_path"
  chmod_out=$($chmod_cmd)

  exec_cmd "echo 'Removing any host key if present'"
  remove_key_cmd="ssh-keygen -f '$HOME/.ssh/known_hosts' -R $NODE_SSH_IP"
  {
    eval $remove_key_cmd
  } || {
    exec_cmd "echo 'Key not present for the host: $NODE_SSH_IP'"
  }

  exec_cmd "echo 'Establishing connection and copying Files'"
  copy_cmd="rsync -avz -e 'ssh -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=0 -p $NODE_SSH_PORT -i $node_key_path -C -c blowfish' $script_folder $NODE_SSH_USER@$NODE_SSH_IP:/tmp"
  echo "executing $copy_cmd"
  copy_cmd_out=$(eval $copy_cmd)
  exec_cmd "echo '$copy_cmd_out'"

  exec_cmd "echo 'Creating script directory'"
  mkdir_cmd="ssh -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=0 -p $NODE_SSH_PORT -i $node_key_path $NODE_SSH_USER@$NODE_SSH_IP mkdir -p $script_folder"
  create_dir_out=$(eval $mkdir_cmd)

  execute_cmd="ssh -o StrictHostKeyChecking=no -o NumberOfPasswordPrompts=0 -p $NODE_SSH_PORT -i $node_key_path $NODE_SSH_USER@$NODE_SSH_IP sudo -E $script_path"
  exec_cmd "echo 'executing command: $execute_cmd'"
  eval $execute_cmd

}

if [ ! -z $block_uuid ] && [ ! -z $script_uuid ]; then
  trap before_exit EXIT
  exec_grp "copy_script_remote"
fi

######################### REMOTE COPY SECTION ENDS ##########################
########################### ENV SECTION ############################

readonly NODE_ID=587c96fee10c651100e58034
readonly SHIPPABLE_API_TOKEN=8e3194ae-e7ab-4c0b-900c-c83b67f34510
readonly SHIPPABLE_AMQP_URL=amqps://wemazaqebejecira:2NYeUMgXLdHx5fU5@rcmsg.shippable.com/shippable
readonly SHIPPABLE_API_URL=
readonly LISTEN_QUEUE=5810aa524c90850f00035b7a.process
export is_success=false
export is_running=false

######################## END ENV SECTION ############################
######################## USER SECTION ################################

setup_shippable_user() {
  is_success=false
  if id -u 'shippable' >/dev/null 2>&1; then
    echo "User shippable already exists"
  else
    exec_cmd "sudo useradd -d /home/shippable -m -s /bin/bash -p shippablepwd shippable"
  fi

  local shippable_user_entry="shippable ALL=(ALL) NOPASSWD:ALL"
  local sudoers_file="/etc/sudoers"

  local sudoers_present=""
  {
    sudoers_present=$(grep "$shippable_user_entry" $sudoers_file)
  } || {
    true
  }

  if [ "$sudoers_present" == "" ]; then
    exec_cmd "sudo echo '$shippable_user_entry' | sudo tee -a $sudoers_file"
  else
    exec_cmd "echo 'shippable already in sudoers file, skipping'"
  fi

  exec_cmd "sudo chown -R $USER:$USER /home/shippable/"
  exec_cmd "sudo chown -R shippable:shippable /home/shippable/"
  is_success=true
}

trap before_exit EXIT
setup_shippable_user

######################## END USER SECTION ################################
######################## PROXY SECTION ############################

export HTTP_PROXY=
export NO_PROXY=

configure_http_proxy_settings() {
  is_success=false
  exec_cmd "echo Configuring HTTP proxy settings"

  if [ ! -z "$HTTP_PROXY" ]; then
    HTTP_PROXY_SETTINGS[0]="export http_proxy=$HTTP_PROXY"
    HTTP_PROXY_SETTINGS[1]="export https_proxy=$HTTP_PROXY"
    HTTP_PROXY_SETTINGS[2]="export HTTP_PROXY=$HTTP_PROXY"
    HTTP_PROXY_SETTINGS[3]="export HTTPS_PROXY=$HTTP_PROXY"

    for proxy in "${HTTP_PROXY_SETTINGS[@]}"
    do
      proxy_exists=$(sudo sh -c "grep '$proxy' /etc/environment || echo ''")
      if [ -z "$proxy_exists" ]; then
        ## docker opts do not exist
        exec_cmd "echo appending $proxy to /etc/environment"
        sudo sh -c "echo '$proxy' >> /etc/environment"
      else
        exec_cmd "echo Proxy setting $proxy already present in /etc/environment"
      fi
    done
  else
    exec_cmd "echo No Proxy settings configured"
  fi

  is_success=true
}

configure_no_proxy_settings() {
  is_success=false
  exec_cmd "echo Configuring no_proxy settings"

  if [ ! -z "$NO_PROXY" ]; then
    NO_PROXY_SETTINGS[0]="export no_proxy=$NO_PROXY"
    NO_PROXY_SETTINGS[1]="export NO_PROXY=$NO_PROXY"

    for proxy in "${NO_PROXY_SETTINGS[@]}"
    do
      proxy_exists=$(sudo sh -c "grep '$proxy' /etc/environment || echo ''")
      if [ -z "$proxy_exists" ]; then
        ## docker opts do not exist
        exec_cmd "echo appending $proxy to /etc/environment"
        sudo sh -c "echo '$proxy' >> /etc/environment"
      else
        exec_cmd "echo NO_PROXY setting $proxy already present in /etc/environment"
      fi
    done
  else
    exec_cmd "echo No NO_PROXY settings configured"
  fi

  is_success=true
}

export_proxy_settings() {
  is_success=false
  exec_cmd "echo Exporting proxy settings"

  exec_cmd "source /etc/environment"

  is_success=true
}

trap before_exit EXIT
exec_grp "configure_http_proxy_settings"

trap before_exit EXIT
exec_grp "configure_no_proxy_settings"

trap before_exit EXIT
exec_grp "export_proxy_settings"


######################## END PROXY SECTION #########################
######################## SYSTEM SECTION ################################

readonly MIN_MEM=1800
readonly MIN_HDD=30
readonly KERNEL_ARCH=64

check_64_bit() {
  is_success=false

  exec_cmd "echo 'Checking kernel'"

  kernel=$(sudo uname -m)

  # need a 64 bit kernel
  if [[ $kernel == *"$KERNEL_ARCH"* ]]; then
    exec_cmd "echo $KERNEL_ARCH bit kernel detected"
  else
    exec_cmd "echo ERROR: kernel must be ${KERNEL_ARCH}-bit to run docker"
    exit 1
  fi
  ## this has to be added because apt-get update was throwing this error
  ## http://askubuntu.com/questions/104160/method-driver-usr-lib-apt-methods-https-could-not-be-found-update-error
  exec_cmd "sudo -E apt-get -y install apt-transport-https"
  is_success=true
}

check_ram() {
  is_success=false
  # host should have at least 2GB of ram
  exec_cmd "echo Checking RAM"

  mem=$(sudo free -m | grep "Mem:" | awk '{print $2}' || echo "")

  if [ -z "$mem" ]; then
    exec_cmd "echo Unable to determine RAM"
  else
    exec_cmd "echo total RAM: $mem"

    if [ $mem -lt $MIN_MEM ]; then
      exec_cmd "echo ERROR: insufficient RAM"
      exit 1
    fi
  fi
  is_success=true
}

check_hdd_space() {
  is_success=false
  exec_cmd "echo Checking HDD"
  total_space=$(sudo df --total | grep "total" | awk '{print $2}' || echo "")

  if [ -z "$total_space" ]; then
    exec_cmd "echo Unable to determine disk space"
  else
    let space_in_mb=total_space/1000
    let space_in_gb=space_in_mb/1000
    exec_cmd "echo Total HDD capacity is ${space_in_gb}GB"

    # numbers in GB
    if [ $space_in_gb -lt $MIN_HDD ]; then
      exec_cmd "echo ERROR: hard drive is too small to run builds. Please allow a minimum of ${MIN_HDD}GB"
      exit 1
    fi
  fi
  is_success=true
}

trap before_exit EXIT
exec_grp "check_64_bit"

trap before_exit EXIT
exec_grp "check_hdd_space"

trap before_exit EXIT
exec_grp "check_ram"

######################## END SYSTEM SECTION ############################
######################## OS SECTION ################################
export OS_TYPE=""
export OS_VERSION=""
export KERNEL_MAJOR_VERSION=""
export KERNEL_MINOR_VERSION=""
export KERNEL_PATCH_VERSION=""

set_os_version() {
  local os_name=$(grep -w NAME /etc/os-release)
  local os_version=$(grep -w VERSION_ID /etc/os-release)
  local kernel_version=$(uname -r)

  if [[ "$os_name" == *"Ubuntu"* ]]; then
    exec_cmd "echo 'Supported operating system: $os_name'"
    OS_TYPE='ubuntu'
  else
    exec_cmd "echo 'Unsupported operating system: $os_name'"
    is_success=false
    return
  fi

  if [[ "$os_version" == *"12.04"* ]]; then
    exec_cmd "echo 'Ubuntu version: 12.04'"
    OS_VERSION='12.04'
  elif [[ "$os_version" == *"14.04"* ]]; then
    exec_cmd "echo 'Ubuntu version: 14.04'"
    OS_VERSION='14.04'
  else
    exec_cmd "echo 'Invalid ubuntu version: $os_version'"
    is_success=false
    return
  fi

  exec_cmd "echo 'Kernel version : $kernel_version'"
  if [[ "$kernel_version" =~ ^([0-9]).([0-9])([0-9]).([0-9])-([0-9])([0-9])-* ]]; then
    exec_cmd "echo 'Parsed kernel version string'"
    KERNEL_MAJOR_VERSION="${BASH_REMATCH[1]}"
    KERNEL_MINOR_VERSION="${BASH_REMATCH[2]}${BASH_REMATCH[3]}"
    KERNEL_PATCH_VERSION="${BASH_REMATCH[5]}${BASH_REMATCH[6]}"
  else
    exec_cmd "echo 'Cannot parse kernel version string: $kernel_version'"
    is_success=false
    return
  fi

  is_success=true
}

upgrade_kernel() {
  ## This is required to fix this docker bug where java builds hang
  ## for ubuntu 14.04 and kernel version less than 3.19.0-50
  ## https://github.com/docker/docker/issues/18180#issuecomment-184359636
  ## once the updated kernel is released, we can remove this function
  local is_upgrade=false

  if [ $KERNEL_MAJOR_VERSION -eq 3 ] && [ $KERNEL_MINOR_VERSION -lt 19 ]; then
    # upgrade if minior version less than 19 
    is_upgrade=true
  elif [ $KERNEL_MAJOR_VERSION -eq 3 ] && [ $KERNEL_MINOR_VERSION -ge 19 ] && [ $KERNEL_PATCH_VERSION -lt 50 ]; then
    # upgrade if patch version less than 50
    is_upgrade=true
  fi

  if [ $is_upgrade == true ]; then
    exec_cmd "echo 'Kernel version $KERNEL_MAJOR_VERSION.$KERNEL_MINOR_VERSION.0-$KERNEL_PATCH_VERSION, upgrading'"

    local kernel_source_entry="deb http://archive.ubuntu.com/ubuntu/ trusty-proposed restricted main multiverse universe"
    local kernel_source_file="/etc/apt/sources.list"

    local kernel_source_present=""
    {
      kernel_source_present=$(grep "$kernel_source_entry" $kernel_source_file)
    } || {
      true
    }

    if [ "$kernel_source_present" == "" ]; then
      exec_cmd "echo '$kernel_source_entry' | sudo tee -a $kernel_source_file"
    else
      exec_cmd "echo 'Kernel sources entry already present, skipping'"
    fi

    exec_cmd "echo -e 'Package: *\nPin: release a=trusty-proposed\nPin-Priority: 400' | sudo tee -a  /etc/apt/preferences.d/proposed-updates"
    _run_update
    exec_cmd "sudo -E apt-get -y install linux-image-3.19.0-51-generic linux-image-extra-3.19.0-51-generic"
  else
    exec_cmd "echo 'Kernel version $KERNEL_MAJOR_VERSION.$KERNEL_MINOR_VERSION.0-$KERNEL_PATCH_VERSION, not upgrading'"
  fi

  is_success=true
}

trap before_exit EXIT
exec_grp "set_os_version"

if [ $OS_TYPE == "ubuntu" ] && [ $OS_VERSION == "14.04" ]; then
  trap before_exit EXIT
  exec_grp "upgrade_kernel"
fi

######################## END OS SECTION ############################
######################## DOCKER SECTION ############################

readonly DOCKER_VERSION=1.9.1
readonly IS_LEGACY_DOCKER=false
export DOCKER_RESTART=false
export HTTP_PROXY=
export DEBIAN_FRONTEND=noninteractive

docker_install() {
  is_success=false
  exec_cmd "echo Installing docker"

  _run_update

  add_docker_repo_keys='sudo -E apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D'
  exec_cmd "$add_docker_repo_keys"

  local docker_repo_entry="deb https://apt.dockerproject.org/repo ubuntu-trusty main"
  local docker_sources_file="/etc/apt/sources.list.d/docker.list"
  local add_docker_hosts=true

  if [ -f "$docker_sources_file" ]; then
    local docker_source_present=""
    {
      docker_source_present=$(grep "$docker_repo_entry" $docker_sources_file)
    } || {
      true
    }

    if [ "$docker_source_present" != "" ]; then
      ## docker hosts entry already present in file
      add_docker_hosts=false
    fi
  fi

  if [ $add_docker_hosts == true ]; then
    add_docker_repo="echo $docker_repo_entry | sudo tee -a $docker_sources_file"
    exec_cmd "$add_docker_repo"
  else
    exec_cmd "echo 'Docker sources already present, skipping'"
  fi

  _run_update

  install_kernel_extras='sudo -E apt-get install -y -q linux-image-extra-$(uname -r) linux-image-extra-virtual'
  exec_cmd "$install_kernel_extras"

  local docker_version=$DOCKER_VERSION"-0~trusty"
  install_docker="sudo -E apt-get install -q --force-yes -y -o Dpkg::Options::='--force-confnew' docker-engine=$docker_version"
  exec_cmd "$install_docker"

  if [ $IS_LEGACY_DOCKER == true ]; then
    get_static_docker_binary="wget https://get.docker.com/builds/Linux/x86_64/docker-$DOCKER_VERSION -P /tmp/docker"
    exec_cmd "$get_static_docker_binary"

    create_docker_directory="mkdir -p /opt/docker"
    exec_cmd "$create_docker_directory"

    move_docker_binary="mv /tmp/docker/docker-$DOCKER_VERSION /opt/docker/docker"
    exec_cmd "$move_docker_binary"

    make_docker_executable="chmod +x /opt/docker/docker"
    exec_cmd "$make_docker_executable"

    remove_static_docker_binary='rm -rf /tmp/docker'
    exec_cmd "$remove_static_docker_binary"
  else
    get_static_docker_binary="wget https://get.docker.com/builds/Linux/x86_64/docker-$DOCKER_VERSION.tgz -P /tmp/docker"
    exec_cmd "$get_static_docker_binary"

    extract_static_docker_binary="sudo tar -xzf /tmp/docker/docker-$DOCKER_VERSION.tgz --directory /opt"
    exec_cmd "$extract_static_docker_binary"

    remove_static_docker_binary='rm -rf /tmp/docker'
    exec_cmd "$remove_static_docker_binary"
  fi

  is_success=true
}

check_docker_opts() {
  is_success=false
  # SHIPPABLE docker options required for every node
  exec_cmd "echo Checking docker options"

  SHIPPABLE_DOCKER_OPTS='DOCKER_OPTS="$DOCKER_OPTS -H unix:///var/run/docker.sock -g=/data --storage-driver aufs"'
  opts_exist=$(sudo sh -c "grep '$SHIPPABLE_DOCKER_OPTS' /etc/default/docker || echo ''")

  if [ -z "$opts_exist" ]; then
    ## docker opts do not exist
    exec_cmd "echo appending DOCKER_OPTS to /etc/default/docker"
    sudo sh -c "echo '$SHIPPABLE_DOCKER_OPTS' >> /etc/default/docker"
    DOCKER_RESTART=true
  else
    exec_cmd "echo Shippable docker options already present in /etc/default/docker"
  fi

  ## remove the docker option to listen on all ports
  exec_cmd "echo Disabling docker tcp listener"
  sudo sh -c "sed -e s/\"-H tcp:\/\/0.0.0.0:4243\"//g -i /etc/default/docker"
  is_success=true
}

check_docker_proxy() {
  is_success=false
  exec_cmd "echo Checking docker proxy"

  if [ "$HTTP_PROXY" == "" ];then
    exec_cmd "echo Proxy not configured ignoring docker proxy settings"
    is_success=true
    return
  fi

  SHIPPABLE_HTTP_PROXY="export http_proxy=$HTTP_PROXY"
  http_proxy_exists=$(sudo sh -c "grep '$SHIPPABLE_HTTP_PROXY' /etc/default/docker || echo ''")

  if [ -z "$http_proxy_exists" ]; then
    exec_cmd "echo appending SHIPPABLE_HTTP_PROXY to /etc/default/docker"
    sudo sh -c "echo '$SHIPPABLE_HTTP_PROXY' >> /etc/default/docker"
    DOCKER_RESTART=true
  else
    exec_cmd "echo Shippable proxy option already present in /etc/default/docker"
  fi

  is_success=true
}

restart_docker_service() {
  is_success=false
  exec_cmd "echo checking if docker restart is necessary"
  if [ $DOCKER_RESTART == true ]; then
    exec_cmd "echo restarting docker service on reset"
    exec_cmd "sudo service docker restart"
  else
    exec_cmd "echo DOCKER_RESTART set to false, not restarting docker daemon"
  fi
  is_success=true
}

trap before_exit EXIT
exec_grp "docker_install"

trap before_exit EXIT
exec_grp "check_docker_opts"

trap before_exit EXIT
exec_grp "check_docker_proxy"

trap before_exit EXIT
exec_grp "restart_docker_service"



######################## END DOCKER SECTION #########################
######################## INSTALL NTP SECTION ###########################

install_ntp() {
  {
    check_ntp=$(sudo service --status-all 2>&1 | grep ntp)
  } || {
    true
  }

  if [ ! -z "$check_ntp" ]; then
    exec_cmd "echo NTP already installed, skipping."
    return
  fi

  exec_cmd "echo Installing NTP"
  exec_cmd "sudo apt-get install -y ntp"
  exec_cmd "sudo service ntp restart"
}

trap before_exit EXIT
exec_grp "install_ntp"

######################## END INSTALL NTP SECTION ###########################
######################## CEXEC SECTION ############################

readonly CEXEC_LOCATION_ON_HOST=/home/shippable/cexec

cleanCEXEC() {
  is_success=false
  if [ -d "$CEXEC_LOCATION_ON_HOST" ]; then
    exec_cmd "sudo rm -rf $CEXEC_LOCATION_ON_HOST"
  fi
  is_success=true
}

cloneCEXEC() {
  is_success=false
  exec_cmd "git clone https://github.com/Shippable/cexec.git $CEXEC_LOCATION_ON_HOST"
  is_success=true
}

trap before_exit EXIT
exec_grp "cleanCEXEC"

trap before_exit EXIT
exec_grp "cloneCEXEC"
######################## END CEXEC SECTION ########################
######################## MEXEC SECTION #########################

readonly SLEEP_TIME=10
readonly MEXEC_CONTAINER_NAME_PATTERN=shippable-mexec-
readonly MEXEC_CONTAINER_NAME=shippable-mexec-587c96fee10c651100e58034
readonly MEXEC_PRIVILEGED_MODE=true
readonly MEXEC_NETWORK_MODE=host
readonly MEXEC_IMAGE_NAME_WITH_TAG=shipimg/mexec:v5.1.2-rc.1
readonly MEXEC_ENVS=" -e SHIPPABLE_AMQP_URL=amqps://wemazaqebejecira:2NYeUMgXLdHx5fU5@rcmsg.shippable.com/shippable -e SHIPPABLE_API_URL=https://rcapi.shippable.com -e RUN_MODE=beta -e NODE_ID=587c96fee10c651100e58034 -e NODE_TYPE_CODE=7000 -e SUBSCRIPTION_ID=5810aa524c90850f00035b7a -e LISTEN_QUEUE=5810aa524c90850f00035b7a.process -e DOCKER_CLIENT_LATEST=/opt/docker/docker -e IS_DOCKER_LEGACY=false"
readonly MEXEC_MOUNTS=" -v /opt/docker/docker:/usr/bin/docker  -v /var/run/docker.sock:/var/run/docker.sock  -v /home/shippable/cache:/home/shippable/cache  -v /tmp/cexec:/tmp/cexec  -v /tmp/ssh:/tmp/ssh  -v /usr/lib/x86_64-linux-gnu/libapparmor.so.1.1.0:/lib/x86_64-linux-gnu/libapparmor.so.1 -v /var/run:/var/run"

remove_stale_mexec() {
  # exclude the container name to be started, find all other mexecs which belong to old node
  is_success=false
  mexec_containers=$(sudo docker ps -a | grep -v $MEXEC_CONTAINER_NAME | grep $MEXEC_CONTAINER_NAME_PATTERN | awk '{print $1}')
  
  if [ ! -z $mexec_containers ]; then
    exec_cmd "echo 'Found running mexec containers, removing...'"
    for container in $mexec_containers; do
      exec_cmd "sudo docker rm -f -v $container"
    done
  else
    exec_cmd "echo 'No stale mexec containers on the host, skipping cleanup'"
  fi
  is_success=true
}

pull_mexec() {
  is_success=false
  exec_cmd "sudo docker pull $MEXEC_IMAGE_NAME_WITH_TAG"
  is_success=true
}

stop_running_mexec() {
  is_success=false
  container_exists=$(sudo docker ps -a | grep $MEXEC_CONTAINER_NAME | awk '{print $1}')
  if [ ! -z "$container_exists" ]; then
    exec_cmd "sudo docker stop -t=0 $(sudo docker ps -a | grep $MEXEC_CONTAINER_NAME | awk '{print $1}')"
  fi
  is_success=true
}

start_mexec() {
  is_success=false
  start_cmd="sudo docker run -d \
          --restart=always \
          $MEXEC_ENVS \
          $MEXEC_MOUNTS \
          --name=$MEXEC_CONTAINER_NAME \
          --privileged=$MEXEC_PRIVILEGED_MODE \
          --net=$MEXEC_NETWORK_MODE \
          $MEXEC_IMAGE_NAME_WITH_TAG"
  exec_cmd "echo 'executing $start_cmd'"
  exec_cmd "$start_cmd"
  is_success=true
}

remove_running_mexec() {
  is_success=false
  if [ ! -z "$container_exists" ]; then
    exec_cmd "sudo docker rm $(sudo docker ps -a | grep $MEXEC_CONTAINER_NAME | awk '{print $1}')"
  fi
  is_success=true
}

verify_running_container() {
  is_success=false
  sleep $SLEEP_TIME
  inspect_json=$(sudo docker inspect $MEXEC_CONTAINER_NAME)
  is_running=$(echo $inspect_json | python -c 'import sys,json;data=json.loads(sys.stdin.read()); print data[0]["State"]["Running"]')

  if [ "$is_running" == "True" ]; then
    is_success=true
    is_running=true
  fi
}

trap before_exit EXIT
exec_grp "remove_stale_mexec"

trap before_exit EXIT
exec_grp "pull_mexec"

trap before_exit EXIT
exec_grp "stop_running_mexec"

trap before_exit EXIT
exec_grp "remove_running_mexec"


for i in `seq 1 5`;
do
  echo "Starting container, try count $i"

  trap before_exit EXIT
  exec_grp "start_mexec"

  trap before_exit EXIT
  exec_grp "verify_running_container"

  if [ "$is_running" == true ]; then
    echo "Container running : $MEXEC_CONTAINER_NAME"
    break;
  fi

  sleep 1s
done

##################### END MEXEC SECTION #########################
######################## EXEC SECTION #########################

readonly EXEC_CONTAINER_NAME_PATTERN=shippable-exec-
readonly EXEC_CONTAINER_NAME=shippable-exec-587c96fee10c651100e58034
readonly EXEC_PRIVILEGED_MODE=true
readonly EXEC_NETWORK_MODE=host
readonly EXEC_IMAGE_NAME_WITH_TAG=shipimg/runsh:v5.1.2-rc.1
readonly EXEC_ENVS=" -e LISTEN_QUEUE=5810aa524c90850f00035b7a.exec -e SHIPPABLE_AMQP_URL=amqps://wemazaqebejecira:2NYeUMgXLdHx5fU5@rcmsg.shippable.com/shippable -e SHIPPABLE_API_URL=https://rcapi.shippable.com -e RUN_MODE=beta -e NODE_ID=587c96fee10c651100e58034 -e COMPONENT=stepExec -e SHIPPABLE_AMQP_DEFAULT_EXCHANGE=shippableEx -e JOB_TYPE=runSh -e SUBSCRIPTION_ID=5810aa524c90850f00035b7a -e NODE_TYPE_CODE=7000 -e DOCKER_CLIENT_LATEST=/opt/docker/docker -e IS_DOCKER_LEGACY=false"
readonly EXEC_MOUNTS=" -v /opt/docker/docker:/usr/bin/docker  -v /var/run/docker.sock:/var/run/docker.sock  -v /home/shippable/cache:/home/shippable/cache  -v /tmp/ssh:/tmp/ssh  -v /tmp/cexec:/tmp/cexec  -v /usr/lib/x86_64-linux-gnu/libapparmor.so.1.1.0:/lib/x86_64-linux-gnu/libapparmor.so.1 -v /var/run:/var/run"
readonly EXEC_IMAGE_NAME=shipimg/runsh

remove_stale_exec_image() {
  is_success=false
  exec_images=$(sudo docker images | grep $EXEC_IMAGE_NAME | awk '{print $3}')
  if [ ! -z $exec_images ]; then
    exec_cmd "echo 'Found stale exec images, removing...'"
    for image in $exec_images; do
      exec_cmd "sudo docker rmi -f $image"
    done
  else
    exec_cmd "echo 'No stale exec image found on the host, skipping cleanup'"
  fi
}

pull_exec() {
  is_success=false
  exec_cmd "sudo docker pull $EXEC_IMAGE_NAME_WITH_TAG"
  is_success=true
}

stop_running_exec() {
  is_success=false
  container_exists=$(sudo docker ps -a | grep $EXEC_CONTAINER_NAME_PATTERN | awk '{print $1}')
  if [ ! -z "$container_exists" ]; then
    exec_cmd "sudo docker stop -t=0 $(sudo docker ps -a | grep $EXEC_CONTAINER_NAME_PATTERN | awk '{print $1}')"
  fi
  is_success=true
}

start_exec() {
  is_success=false
  start_cmd="sudo docker run -d \
          --restart=always \
          $EXEC_ENVS \
          $EXEC_MOUNTS \
          --name=$EXEC_CONTAINER_NAME \
          --privileged=$EXEC_PRIVILEGED_MODE \
          --net=$EXEC_NETWORK_MODE \
          $EXEC_IMAGE_NAME_WITH_TAG"
  exec_cmd "echo 'executing $start_cmd'"
  exec_cmd "$start_cmd"
  is_success=true
}

remove_running_exec() {
  is_success=false
  if [ ! -z "$container_exists" ]; then
    exec_cmd "sudo docker rm $(sudo docker ps -a | grep $EXEC_CONTAINER_NAME_PATTERN | awk '{print $1}')"
  fi
  is_success=true
}

verify_exec_running_container() {
  is_success=false
  sleep $SLEEP_TIME
  inspect_json=$(sudo docker inspect $EXEC_CONTAINER_NAME)
  is_running=$(echo $inspect_json | python -c 'import sys,json;data=json.loads(sys.stdin.read()); print data[0]["State"]["Running"]')

  if [ "$is_running" == "True" ]; then
    is_success=true
    is_running=true
  fi
}

#trap before_exit EXIT
#exec_grp "stop_running_exec"

#trap before_exit EXIT
#exec_grp "remove_running_exec"

#trap before_exit EXIT
#exec_grp "remove_stale_exec_image"

#trap before_exit EXIT
#exec_grp "pull_exec"

# for i in `seq 1 5`;
# do
#   echo "Starting container, try count $i"

#   trap before_exit EXIT
#   exec_grp "start_exec"

#   trap before_exit EXIT
#   exec_grp "verify_exec_running_container"

#   if [ "$is_running" == true ]; then
#     echo "Container running : $EXEC_CONTAINER_NAME"
#     break;
#   fi

#   sleep 1s
# done

#################### END EXEC SECTION #########################

