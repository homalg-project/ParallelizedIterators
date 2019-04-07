#
# ParallelizedIterators
#
# Reading the declaration part of the package.
#

ReadPackage( "ParallelizedIterators", "gap/LiFoOfIterators.gd");

ReadPackage( "ParallelizedIterators", "gap/SeriallyEvaluateRecursiveIterator.gd");

if IsHPCGAP then
ReadPackage( "ParallelizedIterators", "gap/ParallelyEvaluateRecursiveIterator.gd");
else
Info( InfoWarning, 1, "Warning: ParallelyEvaluateRecursiveIterator can only be load in HPCGAP" );
fi;

ReadPackage( "ParallelizedIterators", "gap/Tools.gd");
