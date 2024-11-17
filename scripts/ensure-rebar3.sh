#!/usr/bin/env bash
# 根据erlang版本，下载rebar3版本
set -euo pipefail

[ "${DEBUG:-0}" -eq 1 ] && set -x

## rebar3 tag 3.19.0-emqx-1 is compiled using latest official OTP-24 image.
## we have to use an otp24-compiled rebar3 because the defination of record #application{}
## in systools.hrl is changed in otp24.

## 能获取get-otp-vsn.sh脚本的所有输出，包括echo、printf的输出，其实是获取控制台的所有输出
OTP_VSN="${OTP_VSN:-$(./scripts/get-otp-vsn.sh)}"
case ${OTP_VSN} in
    23*)
        VERSION="3.16.1-emqx-1"
        ;;
    24*)
        VERSION="3.18.0-emqx-1"
        ;;
    25*)
        VERSION="3.19.0-emqx-9"
        ;;
    26*)
        VERSION="3.20.0-emqx-1"
        ;;
    *)
        echo "Unsupporetd Erlang/OTP version $OTP_VSN"
        exit 1
        ;;
esac

# BASH_SOURCE 是bash内置数组变量，
# ${BASE_SOURCE[0]}: 表示获取当前脚本的文件名
# ${BASE_SOURCE[1]}: 表示获取调用当前脚本的脚本的文件名
# 依次类推

# -- 用于确保后面的参数被解释为路径，而不是选项

# 往上走两级目录，到emqx目录
# ensure dir
cd -P -- "$(dirname -- "${BASH_SOURCE[0]}")/.."

DOWNLOAD_URL='https://github.com/emqx/rebar3/releases/download'

download() {
    echo "downloading rebar3 ${VERSION}"
    curl -f -L "${DOWNLOAD_URL}/${VERSION}/rebar3" -o ./rebar3
}

# get the version number from the second line of the escript
# because command `rebar3 -v` tries to load rebar.config
# which is slow and may print some logs
version() {
    head -n 2 ./rebar3 | tail -n 1 | tr ' ' '\n' | grep -E '^.+-emqx-.+'
}

if [ -f 'rebar3' ] && [ "$(version)" = "$VERSION" ]; then
    exit 0
fi

download
chmod +x ./rebar3
