#
# Tools
#
# Implementations
#

##
InstallGlobalFunction( TwoLevelIterator,
function(list)
  return Iterator(List(list, Iterator));
end );

##
InstallGlobalFunction( ThreeLevelIterator,
function(list)
  return Iterator(List(list, TwoLevelIterator));
end );
