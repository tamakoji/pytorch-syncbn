#!/usr/bin/env bash

PYTHON_CMD=${PYTHON_CMD:=python}
CUDA_PATH=/usr/local/cuda
CUDA_INCLUDE_DIR=/usr/local/cuda/include
CUDA_VER=`nvcc --version | tail -n 1 | sed "s/.*[[:space:]]\([[:digit:]]\).*/\1/g"`
if [ $CUDA_VER -ge 9 ]; then
    GENCODE="-gencode=arch=compute_50,code=sm_50 \
             -gencode arch=compute_52,code=sm_52 \
             -gencode arch=compute_60,code=sm_60 \
             -gencode arch=compute_61,code=sm_61 \
             -gencode arch=compute_70,code=sm_70 \
             -gencode arch=compute_70,code=compute_70"
else
    GENCODE="-gencode=arch=compute_50,code=sm_50 \
             -gencode arch=compute_52,code=sm_52 \
             -gencode arch=compute_60,code=sm_60 \
             -gencode arch=compute_61,code=sm_61 \
             -gencode arch=compute_61,code=compute_61"
fi
NVCCOPT="-std=c++11 -x cu --expt-extended-lambda -O3 -Xcompiler -fPIC"

ROOTDIR=$PWD
echo "========= Build BatchNorm2dSync ========="
if [ -z "$1" ]; then TORCH=$($PYTHON_CMD -c "import os; import torch; print(os.path.dirname(torch.__file__))"); else TORCH="$1"; fi
cd modules/functional/_syncbn/src
$CUDA_PATH/bin/nvcc -c -o syncbn.cu.o syncbn.cu $NVCCOPT $GENCODE -I $CUDA_INCLUDE_DIR
cd ../
$PYTHON_CMD build.py
cd $ROOTDIR

# END
echo "========= Build Complete ========="
