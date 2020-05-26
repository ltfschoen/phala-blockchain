#!/bin/bash

declare -A P2P_PORT=( ["alice"]="30333" ["bob"]="31333" ["charlie"]="32333" ["dave"]="33333" )
declare -A RPC_PORT=( ["alice"]="9933" ["bob"]="19933" ["charlie"]="29933" ["dave"]="39933" )
declare -A WS_PORT=( ["alice"]="9944" ["bob"]="19944" ["charlie"]="29944" ["dave"]="49944" )
declare -a rpc_port_array=( 0 9933 19933 29933 39933 )

NODE_NAME=phala-node
BASE_PATH_BASE="$HOME/tmp/$NODE_NAME"
SCRIPT_PATH=$(realpath $(dirname "$0"))
CHAIN_SPEC=${CHAIN:-local}

if [ ! -e "$BASE_PATH_BASE" ]; then
  mkdir -p "$BASE_PATH_BASE"
fi

case $1 in
purge)
  rm -rf $BASE_PATH_BASE/*alice*
  rm -rf $BASE_PATH_BASE/*bob*
  rm -rf $BASE_PATH_BASE/*charlie*
  rm -rf $BASE_PATH_BASE/*dave*
  rm -rf $BASE_PATH_BASE/*dev*
;;
dev)
  shift
  "./target/release/${NODE_NAME}" \
      --base-path $BASE_PATH_BASE/dev \
      --dev \
      --rpc-cors=all \
      --execution=Wasm \
      --validator \
      --listen-addr=/ip4/127.0.0.1/tcp/9998 \
      --no-mdns \
      -lruntime=debug \
      "$@"
;;
dev-native)
  shift
  "./target/release/${NODE_NAME}" \
      --base-path $BASE_PATH_BASE/dev \
      --dev \
      --rpc-cors=all \
      --execution=Native \
      --validator \
      --listen-addr=/ip4/127.0.0.1/tcp/9998 \
      --no-mdns \
      -lruntime=debug \
      "$@"
;;
start)
  shift
  role=$1
  case $role in
  alice)
    shift
    "./target/release/${NODE_NAME}" \
        --base-path "${BASE_PATH_BASE}/alice" \
        --chain="${CHAIN_SPEC}" \
        --rpc-cors all \
        --alice \
        --node-key 0000000000000000000000000000000000000000000000000000000000000001 \
		--port "${P2P_PORT[${role}]}" \
		--rpc-port "${RPC_PORT[${role}]}" \
		--ws-port "${WS_PORT[${role}]}" \
        --validator "$@"
  ;;
  bob|charlie|dave)
    shift
    "./target/release/${NODE_NAME}" \
        --base-path "${BASE_PATH_BASE}/${role}" \
        --bootnodes "/ip4/127.0.0.1/tcp/${P2P_PORT['alice']}/p2p/QmRpheLN4JWdAnY7HGJfWFNbfkQCb6tFf4vvA6hgjMZKrR" \
        --chain="${CHAIN_SPEC}" \
        --rpc-cors all \
        "--${role}" \
		--port "${P2P_PORT[${role}]}" \
		--rpc-port "${RPC_PORT[${role}]}" \
		--ws-port "${WS_PORT[${role}]}" \
        --validator "$@"
  ;;
  *)
    echo "Can't start node '$1'"
    exit -1
  esac
;;
insert-keys)
  read -s -p "Enter mnemonic: " SECRET
  echo
  for i in 1 2 3 4; do
  	echo -e "${SECRET}\n${i}\n${rpc_port_array[${i}]}\n" | ./scripts/insert-keys.sh
  done
;;
esac
