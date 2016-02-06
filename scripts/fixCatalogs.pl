#!/usr/bin/perl -w
#
#   Perl equivalent of the popular dos2unix utility:
#
#   Convert DOS line endings to Unix line endings:
#   works in bulk, safely updates files in place.
#
my  ($filename, $line, $count, $oldStr, $newStr, @FILES, $prompt);
$count = 0;


sub USAGE;
sub readCatalogFile;
sub readPropertiesFile;
sub findCatalogFilesWithString;

sub USAGE {
    print "Usage: $0 filename searchString replacementString \n";
    print ";Replace search string with replacment string\n";
exit(1);
}



$searchFileSet = ".catalogFiles.txt";
$ROOTDIR = "..";
$PROMPT = "p";


#   If no arguments, print an error message



if($#ARGV  < 0){

	print("Enter full path name of filename to convert: ");

	$filename = <STDIN>;
	chomp($filename);
	print("Enter Search String: ");
	$oldStr= <STDIN>;
	chomp($oldStr);
	print("Enter Replacement String: ");
	$newStr= <STDIN>;
	chomp($newStr);
}
elsif( $#ARGV == 2){
   ( $filename, $oldStr,   $newStr )  = (  $ARGV[0] , $ARGV[1] , $ARGV[2] );
}
elsif( $#ARGV == 1){
   print("ARGV[0] = $ARGV[0] ... ARVG[1] = $ARGV[1] ");
   USAGE;
}
elsif( $#ARGV eq 0){
    $propertiesFile = $ARGV[0];
    if( !(-e $propertiesFile ))
    {
        printf ("File $propertiesFile does not exist\n");
        exit(-1);
    }
     
     if (! (-f $propertiesFile && -r $propertiesFile )){
        printf( "File $propertiesFile exists but is not readable \n");
        exit(-1);
      }

    print ("Extracting strings from properties file $propertiesFile\n");
   
#   print("Argv[0] = $ARGV[0] ");
#   USAGE;

}
else
{
   print("num Argv = $#ARGV");
   USAGE;
}

@searchAndReplace = readPropertiesFile();
$searchStr = $searchAndReplace[0];
$replacementStr = $searchAndReplace[1];
$escapedFileSetExpression = $searchAndReplace[2];


if (length $escapedFileSetExpression == 0 ) {
	$escapedFileSetExpression = 'catalog\*.xml';
	print("Setting default file set expression = $escapedFileSetExpression \n");
} 
chomp($escapedFileSetExpression);


&findCatalogFilesWithString($searchStr);

@FILES = &readCatalogFile();
#   Loop through each given filename
foreach $filename (@FILES)
{
    chomp($filename);
    if( -e "$filename.bak" ) {
        printf "Skipping $filename.bak - it already exists\n";
    }
    elsif(!( -f $filename && -r $filename && -w $filename  )) {
        printf "Skipping $filename - not a regular writable file\n";
    }
    else {
    	print ("Fixing file $filename\n");


        if( $PROMPT eq "p" or $PROMPT eq "P"){
            print ("Change string $searchStr\n    to string $replacementStr\n    in file $filename");
            print ("? NoPrompt=n, Prompt=p, Skip=s?[n/p/s]");
        
            $PROMPT = <STDIN>;
            chomp($PROMPT);
            if( $PROMPT eq "p" or $PROMPT eq "P")
            {
               print ("\nChanging string $searchStr\n to string $replacementStr\n in file $filename");
            }
 	}

        print("\n");
        


        if($PROMPT eq "s" or $PROMPT eq "S"){
		$PROMPT = "p";
        }
        else{

           rename("$filename","$filename.bak");
           open INPUT, "$filename.bak";
           open OUTPUT, ">$filename";

           while( <INPUT> ) {
      
               s/$searchStr/$replacementStr/;     # convert CR LF to LF
               print OUTPUT $_;
           }

           close INPUT;
           close OUTPUT;
           unlink("$filename.bak");
           $count++;
       }
    }
}
#printf "Processed $count files.\n";


sub readCatalogFile() {
    my $fileCount = 0;
    my @files;

    print ("Reading $searchFileSet for files to fix\n");
    open( FILE , "<$searchFileSet") or die "Can't read $searchFileSet: $!";
    while(<FILE>){
      $nextFileName = $_;
      $files[$fileCount] = $nextFileName;
      $fileCount++;
    }
    close FILE;
    return(@files);
}

sub readPropertiesFile(){
    my $fileCount = 0;

    print ("Reading $propertiesFile for search and replacement strings\n");
    open( FILE , "<$propertiesFile") or die "Can't read $propertiesFile: $!";
    $searchStr  =  <FILE>;
    chomp($searchStr);

    print "Got search string $searchStr\n";
    $replacementStr =  <FILE>;
    chomp($replacementStr);
    print "Got rep string $replacementStr\n";
    $fileExpression = <FILE>;
    print "Got file expression string $fileExpression\n";
    @searchAndReplace = ($searchStr, $replacementStr,$fileExpression);
    close FILE;
    return(@searchAndReplace);
}

sub findCatalogFilesWithString($){
     my($mySearchStr) = @_[0];
	$findCmd = "find $ROOTDIR -name $escapedFileSetExpression -exec grep -l $mySearchStr {} \\; -print > $searchFileSet";

	system ($findCmd) == 0
 	or die "system $findCmd failed: $?";
}
