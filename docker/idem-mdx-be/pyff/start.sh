#!/bin/bash
start=$(date +%s)
# Create directory if it doesn't exist and navigate into it
mkdir -p "$DATADIR" && cd "$DATADIR"

# Copy certificates
cp "/certs/${MDX_CERT}" "/pyff-data/certs"
cp "/certs/${MDX_PUBKEY}" "/pyff-data/certs"

# Process template files if they exist
for template_file in /pipelines/*.template; do
   if [ -f "$template_file" ]; then
      output_file="/pipelines/$(basename "$template_file" .template)"
      gomplate -f "$template_file" -o "$output_file"
      rm "$template_file"
   fi
done

# Copy default pipeline if specified pipeline file doesn't exist
if [ ! -f "$PIPELINE" ]; then
   cp "/pipelines/mdx-batch.fd" "$PIPELINE"
fi

# Decrypt key if encrypted
if [ -f "/certs/${MDX_ENCRYPTEDKEY}" ]; then
   openssl rsa -in "/certs/${MDX_ENCRYPTEDKEY}" --passin pass:"${PYFF_PASSPHRASE}" -out "/certs/${MDX_KEY}"
   rm "/certs/${MDX_ENCRYPTEDKEY}"
fi

# Touch file
touch "/pyff-data/last_update"

# Remove entity files
rm -f /pyff-data/{edugain,idem,idem-test}/entities/*

# Run PyFF pipelines in parallel
echo "Starting PyFF pipelines."
echo "Starting IDEM PROD pipeline."
pyff --loglevel=${LOGLEVEL} /pipelines/idem-prod-batch.fd
echo "Starting TEST pipeline."
pyff --loglevel=${LOGLEVEL} /pipelines/idem-test-batch.fd

echo "Starting EduGAIN pipelines."
pyff --loglevel=${LOGLEVEL} /pipelines/edugain-batch-idp.fd &
pyff --loglevel=${LOGLEVEL} /pipelines/edugain-batch-sp.fd &
pyff --loglevel=${LOGLEVEL} /pipelines/edugain-batch.fd &
wait

echo "Starting Other pipelines."
pyff --loglevel=${LOGLEVEL} /pipelines/prod-and-test-batch.fd

# Calculate and display execution time
end=$(date +%s)
execution_time=$((end - start))
echo "MDQ completed. It took $execution_time seconds"

# Sleep for remaining time in the hour
sleep $((3600 - execution_time))