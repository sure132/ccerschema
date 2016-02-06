#!/usr/bin/perl -w
#WARNING: This script will delete from git files that are different from teh original reference
sub USAGE;
sub readPropertiesFile;

sub USAGE {
    print "Usage: $0 <propertyFilename> \n";
exit(1);
}


sub readPropertiesFile(){
    my $fileCount = 0;

    print ("Reading $propertiesFile for from and to directories\n");
    open( FILE , "<$propertiesFile") or die "Can't read $propertiesFile: $!";
    $fromDir  =  <FILE>;
    chomp($fromDir);

    print "Got -from- directory $fromDir\n";
    $toDir =  <FILE>;
    chomp($toDir);
    print "Got -to- directory $toDir\n";
    $fileExpression = <FILE>;
    chomp($fileExpression);
    print "Got -don't copy- file expression string $fileExpression\n";
    @inputProperties= ($fromDir, $toDir,$fileExpression);
    close FILE;
    return(@inputProperties);
}
use File::Copy;
use File::Compare;
sub copy_recursively {
    my ($from_dir, $to_dir, $regex) = @_;
    opendir (my($dh), $from_dir) or die "Could not open dir '$from_dir': $!";
 	my @dots = readdir($dh);
	shift(@dots); 
	shift(@dots);
	# print ("\n------In directory: $from_dir");
	#print("\n     Contents: @dots and regex: $regex ");
    foreach  my $entry(@dots) {
        if ($entry =~ m/$regex/) {
		next;
	}
	#print ("\nFound Unskipped ENTRY $entry \n");
        my $source = "$from_dir/$entry";
        my $destination = "$to_dir/$entry";

	if (-f "$from_dir/$entry") {
	#print ("\nFound file $entry \n");
	    if (compare($source,$destination)!=0){
            print ("\nChanged:---- $source ");
        #    copy($source, $destination) or die "copy failed: $!";
	   #  git rm $destination
	system("git","rm",$destination);
	    } 
       	} elsif (-d "$from_dir/$entry") {

	#print ("\nFound directory $entry \n");
            #mkdir $destination or die "mkdir '$destination' failed: $!" if not -e $destination;
            copy_recursively($source, $destination, $regex);
	}
     }

    closedir $dh;
    return;
}


###main starts here
if($#ARGV  < 0){
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

    print ("Extracting properties from properties file $propertiesFile\n");


}


@inputProperties = readPropertiesFile();
&copy_recursively(@inputProperties);
