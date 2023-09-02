In the "tests" directory, there are a few scripts to time operations
and output results to a text file.

Tests require at least v.3.3 of Tensor Toolbox to be included in the 
MATLAB path. The most recent release can be found at 
http://www.tensortoolbox.org/.

All the tensors in the "frostt" and "shuffled" directory will need to be 
unzipped. The "frostt" directory contains all sample tensors from the 
FROSTT repository, and the shuffled" directory contains the same tensors,
but with rows randomly shuffled.


Script: produce_frostt_res
Description: Reproduce results for Figure 12, reports accumulated time to 
insert N elements into a COO Tensor Toolbox/HaCOO htensor sparse tensor 
averaged over M trials (default of 10) to calculate MTTKRP over all modes.

Since tests involved inserting rows one-by-one into a a sparse tensor 
structure, this uses the shuffled FROSTT tensors (since the original ones
come already sorted).

Script: produce_mttkrp_res
Description: Reproduce results for Figure 14, reports average time over N 
trials (10 by default) to calculate MTTKRP over all modes for both COO 
Tensor Toolbox sparse tensors and HaCOO htensor sparse tensors.

This uses regular, unaltered FROSTT tensors.