# SPDX-License-Identifier: GPL-2.0-or-later
# ParallelizedIterators: Parallely evaluate recursive iterators
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
                   "2020.10-01", ## Mohamed's version
                   ## this line prevents merge conflicts
                   "2017.04-21", ## Reimer's version
                   ## this line prevents merge conflicts
                   "2019.05-28", ## Lukas's version
                   ] ),

Date := ~.Version{[ 1 .. 10 ]},
Date := Concatenation( "01/", ~.Version{[ 6, 7 ]}, "/", ~.Version{[ 1 .. 4 ]} ),
License := "GPL-2.0-or-later",


Persons := [
  rec(
    IsAuthor := true,
    IsMaintainer := true,
    FirstNames := "Mohamed",
    LastName := "Barakat",
    WWWHome := "https://mohamed-barakat.github.io/",
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
               "Inselstr. 22\n",
               "04103 Leipzig\n",
               "Germany" ),
    Place := "Leipzig",
    Institution := "Max Planck Institute for Mathematics in the Sciences",
  ),
],

# BEGIN URLS
SourceRepository := rec(
    Type := "git",
    URL := "https://github.com/homalg-project/ParallelizedIterators",
),
IssueTrackerURL := Concatenation( ~.SourceRepository.URL, "/issues" ),
PackageWWWHome  := "https://homalg-project.github.io/ParallelizedIterators",
PackageInfoURL  := "https://homalg-project.github.io/ParallelizedIterators/PackageInfo.g",
README_URL      := "https://homalg-project.github.io/ParallelizedIterators/README.md",
ArchiveURL      := Concatenation( "https://github.com/homalg-project/ParallelizedIterators/releases/download/v", ~.Version, "/ParallelizedIterators-", ~.Version ),
# END URLS

ArchiveFormats := ".tar.gz .zip",

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
