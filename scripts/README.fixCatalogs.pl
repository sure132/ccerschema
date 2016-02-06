What it does:
Default: finds all the catalog*.xml files in ccerschema, substitutes all instances of search string with replacement string.
If a file search expression such as blah\*.rdf is given, it will do the search/replace on those files

What you need to do:
   EDIT the properties file
   line 1: <searchString>
   line 2: <replacementString>
   line 3: <escaped file search expression>

   provide the properties filename on cmd line


Usages:

%fixCatalogs.pl <Propertiesfilename>  

or let it prompt  you for the args

%fixCatalogs.pl  

