# SPDX-License-Identifier: GPL-2.0-or-later
# ParallelizedIterators: Parallely evaluate recursive iterators
#
# Reading the implementation part of the package.
#

ReadPackage( "ParallelizedIterators", "gap/LiFoOfIterators.gi");

ReadPackage( "ParallelizedIterators", "gap/SeriallyEvaluateRecursiveIterator.gi");

if IsHPCGAP then
ReadPackage( "ParallelizedIterators", "gap/ParallelyEvaluateRecursiveIterator.gi");
fi;

ReadPackage( "ParallelizedIterators", "gap/Tools.gi");
