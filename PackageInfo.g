#
# ParallelizedIterators
#
# This file contains package meta data. For additional information on
# the meaning and correct usage of these fields, please consult the
# manual of the "Example" package as well as the comments in its
# PackageInfo.g file.
#
SetPackageInfo( rec(

PackageName := "ParallelizedIterators",
Subtitle := "Parallely evaluate recursive iterators",
Version := Maximum( [
                   "2018.12.09", ## Mohamed's version
                   ## this line prevents merge conflicts
                   "2017.04.21", ## Reimer's version
                   ## this line prevents merge conflicts
                   "2018.07.06", ## Lukas's version
                   ] ),

Date := ~.Version{[ 1 .. 10 ]},
Date := Concatenation( ~.Date{[ 9, 10 ]}, "/", ~.Date{[ 6, 7 ]}, "/", ~.Date{[ 1 .. 4 ]} ),

Persons := [
  rec(
    IsAuthor := true,
    IsMaintainer := true,
    FirstNames := "Mohamed",
    LastName := "Barakat",
    WWWHome := "https://mohamed-barakat.github.io",
    Email := "mohamed.barakat@uni-siegen.de",
    PostalAddress := Concatenation(
               "Walter-Flex-Str. 3\n",
               "57068 Siegen\n",
               "Germany" ),
    Place := "Siegen",
    Institution := "University of Siegen",
  ),
  rec(
    IsAuthor := true,
    IsMaintainer := true,
    FirstNames := "Reimer",
    LastName := "Behrends",
    WWWHome := "https://github.com/rbehrends",
    Email := "behrends@gmail.com",
    PostalAddress := Concatenation(
               "Gottlieb-Daimler-Straße\n",
               "Gebäude 48, Raum 435\n",
               "67663 Kaiserslautern\n",
               "Germany" ),
    Place := "Germany",
    Institution := "TU Kaiserslautern",
  ),
  rec(
    IsAuthor := true,
    IsMaintainer := true,
    FirstNames := "Lukas",
    LastName := "Kühne",
    WWWHome := "https://github.com/lukaskuehne",
    Email := "lf.kuehne@gmail.com",
    PostalAddress := Concatenation(
               "\n",
               "\n",
               "Israel" ),
    Place := "Jerusalem",
    Institution := "Hebrew University of Jerusalem",
  ),
],

SourceRepository := rec(
    Type := "git",
    URL := Concatenation( "https://github.com/homalg-project/", ~.PackageName ),
),
IssueTrackerURL := Concatenation( ~.SourceRepository.URL, "/issues" ),
#SupportEmail   := "TODO",
PackageWWWHome  := Concatenation( "https://github.com/homalg-project/", ~.PackageName ),
PackageInfoURL  := Concatenation( ~.PackageWWWHome, "PackageInfo.g" ),
README_URL      := Concatenation( ~.PackageWWWHome, "README.md" ),
ArchiveURL      := Concatenation( ~.SourceRepository.URL,
                                 "/releases/download/v", ~.Version,
                                 "/", ~.PackageName, "-", ~.Version ),

ArchiveFormats := ".tar.gz",

##  Status information. Currently the following cases are recognized:
##    "accepted"      for successfully refereed packages
##    "submitted"     for packages submitted for the refereeing
##    "deposited"     for packages for which the GAP developers agreed
##                    to distribute them with the core GAP system
##    "dev"           for development versions of packages
##    "other"         for all other packages
##
Status := "dev",

AbstractHTML   :=  "",

PackageDoc := rec(
  BookName  := "ParallelizedIterators",
  ArchiveURLSubset := ["doc"],
  HTMLStart := "doc/chap0.html",
  PDFFile   := "doc/manual.pdf",
  SixFile   := "doc/manual.six",
  LongTitle := "Parallely evaluate recursive iterators",
),

Dependencies := rec(
  GAP := ">= 4.9.1",
  NeededOtherPackages := [
                   [ "GAPDoc", ">= 1.5" ],
                   [ "IO", ">= 4.5.1" ],
                   [ "ToolsForHomalg", ">= 2018.12.01" ],
                   ],
  SuggestedOtherPackages := [ ],
  ExternalConditions := [ ],
),

AvailabilityTest := function()
        return true;
    end,

TestFile := "tst/testall.g",

Keywords := [ "recursive iterators, parallel evaluation" ],

));
