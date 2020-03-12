if (NOT WITH_GPU)
  return()
endif ()

set(gpu_archs9 "61 70")
set(gpu_archs10 "61 70 75")

if (NOT DEFINED ENV{CUDA_PATH})
  find_package(CUDA REQUIRED)
  if (NOT CUDA_FOUND)
    message(SEND_ERROR "Not defined CUDA_PATH and Not found CUDA.")
  endif ()
  message(STATUS "CUDA detected: " ${CUDA_VERSION})
endif ()

set(CUDA_PATH ${CUDA_TOOLKIT_ROOT_DIR})
include_directories(${CUDA_PATH}/include)
link_directories("${CUDA_PATH}/lib64/")

if (${CUDA_VERSION} LESS 10.0)
  set(gpu_archs ${gpu_archs9})
elseif (${CUDA_VERSION} LESS 11.0)
  set(gpu_archs ${gpu_archs10})
else ()
  message(SEND_ERROR "This CUDA_VERSION is not support now.")
endif ()

set(cuda_arch_bin ${gpu_archs})
string(REGEX MATCHALL "[0-9()]+" cuda_arch_bin "${cuda_arch_bin}")
list(REMOVE_DUPLICATES cuda_arch_bin)
list(GET cuda_arch_bin -1 cuda_arch_ptx)
list(REMOVE_AT cuda_arch_bin -1)

set(nvcc_flags "")
set(nvcc_flags_txt "")
foreach(arch ${cuda_arch_bin})
  set(nvcc_flags "${nvcc_flags} -gencode arch=compute_${arch},code=sm_${arch}")
  set(nvcc_flags_txt "${nvcc_flags_txt}${arch},")
endforeach()

set(nvcc_flags "${nvcc_flags} -gencode arch=compute_${cuda_arch_ptx},code=\\\"sm_${cuda_arch_ptx},compute_${cuda_arch_ptx}\\\"")
set(nvcc_flags_txt "${nvcc_flags_txt}${cuda_arch_ptx}")
message(STATUS "Generating CUDA code for " ${CUDA_VERSION} " SMs:" ${nvcc_flags_txt})

set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} ${nvcc_flags} -rdc=true")
set(CMAKE_CUDA_FLAGS "${CMAKE_CUDA_FLAGS} -Xcompiler -Wall -std=c++11 --expt-relaxed-constexpr --expt-extended-lambda")
