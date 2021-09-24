#!/usr/bin/env zsh

external_tools=(
  jq
  k3d
)

for tool in ${(@)external_tools}; do
  if ! command -v $tool &>/dev/null; then
    echo "$tool not installed"
    exit 1
  fi
done

declare -A defaults
defaults=(
  [agent_count]=3
  [cluster_name]=dev
  [server_count]=3
  [lb_port]=8080
)

declare -A args
args=( ${(kv)defaults} )

usage() {
  printf "Purpose:\n"
  printf "  Create a local K8s cluster using K3s\n"

  printf "\nUsage:\n"
  printf "  setup.zsh [-v] [-n <cluster-name>] [-s <server-count>] [-a <agent-count>]\n"

  printf "\nOptions:\n"
  format="  %-4s%-17s%-34s[Default: %s]\n"
  printf $format "-a" "<agent-count>" "set number of agent containers" $defaults[agent_count]
  printf $format "-n" "<cluster-name>" "set cluster name" $defaults[cluster_name]
  printf $format "-p" "<port>" "port to expose cluster lb on" $defaults[lb_port]
  printf $format "-s" "<server-count>" "set number of server containers" $defaults[server_count]
  printf $format "-v" "" "show debug info (set -x)" "false"
}

arg_err() {
  printf "Invalid option: %s requires an argument\n" $1 1>&2
}

unset debug

while getopts ":a:n:p:s:v" opt; do
  case  $opt in
    a  ) args[agent_count]=$OPTARG;;
    n  ) args[cluster_name]=$OPTARG;;
    p  ) args[lb_port]=$OPTARG;;
    s  ) args[server_count]=$OPTARG;;
    v  ) args+=( [debug]=true );;
    \? ) usage; exit;;
    :  ) arg_err $OPTARG; exit 1;;
  esac
done

if [ ! -z ${args[debug]} ]; then
  set -x
fi

cluster_exists=$(k3d cluster list --output json | jq -r ".[] | select(.name==\"${args[cluster_name]}\") | .name")
if [[ -z $cluster_exists ]]; then
  k3d cluster create ${args[cluster_name]} \
    --agents ${args[agent_count]} \
    --servers ${args[server_count]} \
    --port "${args[lb_port]}:80@loadbalancer" \
    --timeout 5m 
else
  print "Cluster already exits.\n"
fi
