#!/usr/bin/env bash
# Run the classification benchmarks one after another on the single GPU.
set -euo pipefail

cd "$(dirname "$0")"
source /home/campus.ncl.ac.uk/c4071391/miniconda3/etc/profile.d/conda.sh
conda activate hyperfm

mkdir -p result
LOG="result/benchmark_run.log"

{
  echo "=== $(date) queued ==="
  echo "Python: $(command -v python)"
  echo "Waiting until no process is using the GPU."

  while true; do
    apps="$(nvidia-smi --query-compute-apps=pid,process_name,used_gpu_memory --format=csv,noheader || true)"
    if [[ -z "${apps//[[:space:]]/}" ]]; then
      break
    fi
    echo "$(date) GPU busy:"
    echo "$apps"
    sleep 30
  done

  echo "=== $(date) GPU free, starting SpatSigma ==="
  python -m nbconvert --to notebook --execute --inplace \
    --ExecutePreprocessor.timeout=-1 \
    "demo cls spatsigma.ipynb"
  echo "=== $(date) SpatSigma finished ==="

  echo "=== $(date) starting HyperSigma ==="
  python -m nbconvert --to notebook --execute --inplace \
    --ExecutePreprocessor.timeout=-1 \
    "demo cls hypersigma.ipynb"
  echo "=== $(date) both notebooks finished ==="
} 2>&1 | tee -a "$LOG"
