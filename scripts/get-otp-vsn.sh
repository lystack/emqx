#!/usr/bin/env bash
# 获取erlang版本号，如：/usr/lib/erlang/releases/25/OPT_VERSION
set -euo pipefail

erl  -noshell -eval '{ok, Version} = file:read_file(filename:join([code:root_dir(), "releases", erlang:system_info(otp_release), "OTP_VERSION"])), io:fwrite(Version), halt().'
