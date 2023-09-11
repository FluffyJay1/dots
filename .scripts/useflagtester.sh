#!/bin/bash
# requires docker, ebuildtester
# With the power of docker, test various combinations of USE flags on an ebuild and see whether it will build

if [ $# -eq 0 ]; then
  echo "Usage: useflagtester.sh FILES..."
  echo "Each file has the following format:"
  echo "Line 1: package atom (e.g. =app-misc/clifm-9999)"
  echo "Line 2: overlay dir absolute (e.g. /home/fluffyjay1/development/guru)"
  echo "Line 3: USE flags that pull in the minimum set of common dependencies (like minus everything)"
  echo "Line 4+: Path to a 'USE flag specification' file (relative to this file's dir)"
  echo "Each 'USE flag specification' file has the following format:"
  echo "Line 1: USE flags to keep the same"
  echo "Line 2: USE flags to permute on-off combinations"
  echo "This script will output results to a dir for each USE flag specification file"
  exit
fi

permute_use () {
  for (( combination=0; $(echo -n $combination | wc -c)<=$#; combination=$(echo "obase=2; ibase=2; $combination + 1" | bc) )); do
    combinationarr=( $(printf "%0$#d" $combination | sed -e "s/\(.\)/\1 /g") )
    for i in ${!combinationarr[@]}; do
      case "${combinationarr[$i]}" in
        1) printf "${@: $i+1: 1} ";;
        *) printf -- "-${@: $i+1: 1} ";;
      esac
    done
    echo
  done
}

basewd=$(pwd)
# for each input file
while [ $# -gt 0 ]; do
  cd $basewd
  readarray -t input < $1
  atom=$(echo ${input[0]} | sed -e "s/^\([^=].*\)$/=\1/") # normalize, add the = at the beginning if not there
  overlay=${input[1]}
  min_use=${input[2]}
  use_spec_files=$(tail -n +4 $1)

  overlay_name=$(cat ${overlay}/profiles/repo_name)

  # create an image with just the base atoms
  # get its image id
  base_container_id=$(ebuildtester --atom "$atom" --live-ebuild --portage-dir /var/db/repos/gentoo --overlay-dir $overlay \
    --use "$min_use" --unstable --batch 2>&1 | grep "container id" | sed -e "s/.* container id \(.*\)/\1/")
  base_image_id=$(docker commit $base_container_id)
  docker container rm -f $base_container_id > /dev/null

  suite_name=$(basename ${1%.*})
  cd $(dirname $1)
  suite_out_dir="${suite_name}_results"
  mkdir -p "$suite_out_dir"
  rm -rf "$suite_out_dir"/*
  suite_failures_file="$suite_out_dir/failures.txt"

  hasfailed=0
  # read each use flag specification file
  while read use_file_path; do
    readarray -t use_spec < ${use_file_path}
    spec_name=$(basename ${use_file_path%.*})
    static_use=${use_spec[0]}
    dynamic_use=${use_spec[1]}

    outdir="${suite_out_dir}/${spec_name}_results"
    mkdir -p $outdir

    i=0
    while read line; do
      use="$static_use $line"
      log_file="$outdir/log_$i.txt"
      printf "Log $i for USE combination:\n$use\n\n" > $log_file

      use_flag_update_cmd="echo $atom $use > /etc/portage/package.use/testbuild"
      emerge_cmd="emerge --verbose --autounmask-write=y --autounmask-license=y --autounmask-continue=y $atom"

      docker run --volume ${overlay}:/var/lib/overlays/${overlay_name} --volume /var/db/repos/gentoo:/var/db/repos/gentoo \
        --volume /var/cache/distfiles:/var/cache/distfiles --volume /var/cache/binpkgs:/var/cache/binpkgs \
        --cap-add CAP_SYS_ADMIN --cap-add CAP_MKNOD --cap-add CAP_NET_ADMIN --security-opt apparmor:unconfined \
        --device /dev/fuse --workdir /root --rm $base_image_id \
        sh -c "$use_flag_update_cmd && $emerge_cmd" &>> $log_file
      result=$?

      if [ $result -ne 0 ]; then
        hasfailed=1
        mv "$log_file" "$outdir"/log_"$i"_FAILED.txt
        printf -- "$spec_name $i $use\n" >> "$suite_failures_file"
      fi

      i=$(($i + 1))
    done <<< "$(permute_use $dynamic_use)"
  done <<< "$use_spec_files"

  if [ $hasfailed -eq 1 ]; then
    echo "$1 has failures"
  fi

  docker image rm -f $base_image_id > /dev/null
  shift
done

