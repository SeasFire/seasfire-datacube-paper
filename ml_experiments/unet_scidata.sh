#!/bin/bash
# Schedule execution of many runs
# Run from root folder with: bash scripts/schedule.sh

export HYDRA_FULL_ERROR=1
export CUDA_VISIBLE_DEVICES=0

experiment="scidata_unet_experiments"
max_epochs=30
batch_size=128
debug=False


for target_shift in 1 2 4 8 16
do
  echo "Experiment with target_shift=${target_shift}"
  python src/train.py target_shift=${target_shift} data.debug=${debug} trainer.max_epochs=${max_epochs} data.batch_size=${batch_size} model.loss=ce model.encoder="efficientnet-b1" experiment=unet_scidata
done
