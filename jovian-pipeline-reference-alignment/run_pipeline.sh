REFERENCE_FASTA=/mnt/database/reference.fasta

source /git/bin/includes/functions

#python update_samples_status.py "$FILENAME" "pipeline started"

set +ue
conda config --set channel_priority false
conda env create -f /git/bin/envs/Jovian_master_environment.yaml
conda init bash
source /root/.bashrc
conda activate Jovian_master
set -ue

PROFILE="config"
UNIQUE_ID=$(/git/bin/includes/generate_id)
HOSTNAME=$(hostname)




INPUT_DIR="/raw_data/test_jovian_ra"
mkdir -p "/output/test_jovian_ra"

cd "/output/test_jovian_ra" || exit
cp /root/.ncbirc ./

python /git/bin/scripts/generate_sample_sheet.py "${INPUT_DIR}" > "sample_sheet.yaml"
cp -r /git/bin ./
cp -r /git/config ./
cp -r /git/docs ./
cp -r /git/files ./
cp -r /git/.git ./


###> Check the reads and change pipeline parameters acccordingly
if ! bash bin/includes/Preflight_readlength-counter; then
exit 1
fi

# turn off bash strict mode because snakemake and conda can't work with it properly
set +ue
echo -e "Jovian_run:\n    identifier: ${UNIQUE_ID}" > "config/variables.yaml"
echo -e "Server_host:\n    hostname: http://${HOSTNAME}" >> "config/variables.yaml"
eval $(parse_yaml "config/variables.yaml" "config_")
snakemake -s bin/Ref_alignment.smk --profile "${PROFILE}" --config reference="${REFERENCE_FASTA}"
set -ue

conda deactivate

#if [ -e results/snakemake_report.html ]; then
#    python /update_samples_status.py "$FILENAME" "pipeline finished"
#else
#    python /update_samples_status.py "$FILENAME" "pipeline finished with errors"
#fi

exit 0