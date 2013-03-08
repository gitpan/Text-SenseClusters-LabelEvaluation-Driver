#http://search.cpan.org/dist/Test-Simple/lib/Test/Tutorial.pod
use Test::More tests => 7;

# Testing whether the dependent package are presents in the package.
BEGIN {use_ok Text::SenseClusters::LabelEvaluation::ReadingFilesData}
BEGIN {use_ok Text::SenseClusters::LabelEvaluation::Wikipedia::GetWikiData}
BEGIN {use_ok Text::SenseClusters::LabelEvaluation::SimilarityScore}
BEGIN {use_ok Text::SenseClusters::LabelEvaluation::AssigningLabelUsingHungarianAlgo}

# Testing whether LabelEvaluation module is present or not.
BEGIN {use_ok Text::SenseClusters::LabelEvaluation::Driver}

# Including the LabelEvaluation Module.
use Text::SenseClusters::LabelEvaluation::Driver;
# Including the FileHandle module.
use FileHandle;

# File that will contain the label information.
my $labelFileName = "temp_label.txt";

# Defining the file handle for the label file.
our $labelFileHandle = FileHandle->new(">$labelFileName");

# Writing into the label file.
print $labelFileHandle "Cluster 0 (Descriptive): George Bush, Al Gore, White House,". 
   			" COMMENTARY k, Cox News, George W, BRITAIN London, U S, ".
  			"Prime Minister, New York \n\n";
print $labelFileHandle "Cluster 0 (Discriminating): George Bush, COMMENTARY k, Cox ".
   			"News, BRITAIN London \n\n";
print $labelFileHandle "Cluster 1 (Descriptive): U S, Al Gore, White House, more than,". 
   			"George W, York Times, New York, Prime Minister, President ".
   			"<head>B_T</head>, the the \n\n";
print $labelFileHandle "Cluster 1 (Discriminating): more than, York Times, President ".
		"<head>B_T</head>, the the \n";
	   						
# File that will contain the topic information.
my $topicFileName = "temp_topic.txt";

# Defining the file handle for the topic file.
our $topicFileHandle = FileHandle->new(">$topicFileName");

# Writing into the Topic file.
# Bill Clinton  ,   Tony  Blair 
print $topicFileHandle "Cluster1:::Tony Blair\n"; 
print $topicFileHandle "Cluster0:::Bill Clinton\n"; 
print $topicFileHandle "Tony Blair::: Anthony Charles Lynton Blair (born 6 May 1953)[1] is a British Labour 
						Party politician who served as the Prime Minister of the United Kingdom from 1997 to 2007. 
						He was the Member of Parliament (MP) for Sedgefield from 1983 to 2007 and Leader of the 
						Labour Party from 1994 to 2007. He resigned from all of these positions in June 2007.\n";

print $topicFileHandle "Bill Clinton::: William Jefferson \"Bill\" Clinton (born William Jefferson Blythe III; 
						August 19, 1946) is an American politician who served as the 42nd President of the 
						United States from 1993 to 2001. Inaugurated at age 46, he was the third-youngest 
						president. He took office at the end of the Cold War, and was the first president 
						of the baby boomer generation. Clinton has been described as a New Democrat. Many 
						of his policies have been attributed to a centrist Third Way philosophy of governance.";

# Closing the handles.
close($labelFileHandle);								
close($topicFileHandle);								

# Calling the LabelEvaluation modules by passing the following options
%inputOptions = (
	senseClusterLabelFileName => $labelFileName, 
	labelComparisonMethod => 'direct',
	goldKeyFileName => $topicFileName,
	goldKeyDataSource => 'userData',
	weightRatio => 10,
	isClean => 1,
);


# Calling the LabelEvaluation modules by passing the name of the 
# label and topic files.
my $driverObject = Text::SenseClusters::LabelEvaluation::Driver->
		new (\%inputOptions);
	
if($driverObject->{"errorCode"}){
	print "Please correct the error before proceeding.\n\n";
	exit();
}
my $accuracyScore = $driverObject->evaluateLabels();
	
# Printing the score.			
#print "\nScore of label evaluation is :: $accuracyScore \n";

# Deleting the temporary label and topic files.
unlink $labelFileName or warn "Could not unlink $labelFileName: $!";								
unlink $topicFileName or warn "Could not unlink $topicFileName: $!";


# For correct run. It should return value between 0 to 1.
cmp_ok($accuracyScore, '>', 0.0);
cmp_ok($accuracyScore, '<', 100.0);


