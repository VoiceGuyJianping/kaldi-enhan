#!/usr/bin/env bash

# wujian@2018

set -eu

nj=40
epochs=20
# stft.conf example:
# --frame-length 1024
# --frame-shift 256
# --window hann
# --center true
stft_conf=conf/stft.conf

echo "$0 $@"

. ./utils/parse_options.sh || exit 1 

[ $# -ne 2 ] && echo "Script format error: $0 <wav-scp> <dst-dir>" && exit 1

wav_scp=$1
dst_dir=$2
exp_dir=./exp/cgmm && mkdir -p $exp_dir
stft_opts=$(cat $stft_conf | xargs)

split_wav_scp="" && for n in $(seq $nj); do split_wav_scp="$split_wav_scp $exp_dir/wav.$n.scp"; done

./utils/split_scp.pl $wav_scp $split_wav_scp

mkdir -p $dst_dir
./utils/run.pl JOB=1:$nj $exp_dir/log/run_cgmm.JOB.log \
  ./scripts/sptk/estimate_cgmm_masks.py \
  $stft_opts --num-epochs $epochs \
  $exp_dir/wav.JOB.scp \
  $dst_dir

echo "$0: Estimate mask using CGMM methods done"
