cd packer
varfiles="../packer/vars/*"
templates="../packer/templates/*"
provision="../packer/provision/*.sh"
for v in $varfiles; do
  [[ "${v##*/}" =~ ^(cloud-env.*)$ ]] && continue
  for t in $templates; do
  export PACKER_LOG="yes" && \
  export PACKER_LOG_PATH="packer-validate-${v##*/}-${t##*/}.log" && \
          packer.io validate -var-file=$CLOUDENV \
          -var-file=$v $t
  if [ $? -ne 0 ]; then
      break
  fi
  done
done
for p in $provision; do
  /bin/bash -n $p > provision-validate-${p##*/}.log 2>&1
done
