#
# ParallelizedIterators
#
# Reading the implementation part of the package.
#

ReadPackage( "ParallelizedIterators", "gap/LiFoOfIterators.gi");

if IsHPCGAP then
ReadPackage( "ParallelizedIterators", "gap/ptree.gi");
fi;

ReadPackage( "ParallelizedIterators", "gap/Tools.gi");
