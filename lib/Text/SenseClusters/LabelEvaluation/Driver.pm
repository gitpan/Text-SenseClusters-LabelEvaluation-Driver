
# Defining the Package for the modules.
package Text::SenseClusters::LabelEvaluation::Driver;

use strict;
use encoding "utf-8";

# Defining the version for the Progrm.
our $VERSION = '0.07';

# Including the FileHandle module.
use FileHandle;

# Including the other dependent Modules.
use Text::SenseClusters::LabelEvaluation::ReadingFilesData;
use Text::SenseClusters::LabelEvaluation::SimilarityScore;
use Text::SenseClusters::LabelEvaluation::Wikipedia::GetWikiData;
use Text::SenseClusters::LabelEvaluation::AssigningLabelUsingHungarianAlgo;



#######################################################################################################################

=head1 Name 

Text::SenseClusters::LabelEvaluation::Driver - Module for evaluation of labels of the clusters. 

=head1 SYNOPSIS


	The following code snippet will evaluate the labels by comparing
	them with text data for a gold-standard key from Wikipedia .

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
	print $topicFileHandle "Bill Clinton  ,   Tony  Blair \n";

	# Closing the handles.
	close($labelFileHandle);								
	close($topicFileHandle);								

	# Calling the LabelEvaluation modules by passing the following options
	%inputOptions = (
		senseClusterLabelFileName => $labelFileName, 
		labelComparisonMethod => 'automate',
		goldKeyFileName => $topicFileName,
		goldKeyDataSource => 'wikipedia',
		weightRatio => 10,
		stopListFileLocation => 'stoplist.txt',
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
	print "\nScore of label evaluation is :: $accuracyScore \n";

	# Deleting the temporary label and topic files.
	unlink $labelFileName or warn "Could not unlink $labelFileName: $!";								
	unlink $topicFileName or warn "Could not unlink $topicFileName: $!";
	
Note: For more usage, please refer to test-cases in "t" folder of this package.
	
=head1 DESCRIPTION

	This Program will compare the result obtained from the SenseClusters with that 
	of Gold Standards. Gold Standards can be obtained from:
			1. Wikipedia
			2. Wordnet
			3. User Provided
			
	For fetching the Wikipedia data it use the WWW::Wikipedia module from the CPAN 
	and for comparison of Labels with Gold Standards it uses the Text::Similarity
	Module. The comparison result is then further processed to obtain the result
	and score of result.


=head1 RESULT:

   a) Contingency Matrix:	
	         Based on the similarity comparison of Labels with the gold standards,
	         the Contingency Matrix is generated. Following shows an example of 
	         contingency matrix for the example mentioned in synposis:


		Original Contingency Matrix: 
		 
			   		Bill Clinton		Tony Blair  
		-------------------------------------------------
		 Cluster0			54				48
		-------------------------------------------------
		 Cluster1			31				16
		------------------------------------------------- 
	
	b) Using Hungarian algorithm to display the new contingency matrix,
		whose diagonal elements indicates the assigned similarity-score
		between a cluster and a gold-standard key. This format of matrix
		has the maximum possible diagonal's total.   
	
		Example:
		
		Contigency Matrix after Hungarian Algorithm: 
		 
			   			Tony Blair 	Bill Clinton  
		-------------------------------------------------
		 Cluster0			48				54
		-------------------------------------------------
		 Cluster1			16				31
		-------------------------------------------------
	

	c) Conclusion: Displays the conclusion of the Hungarian algorithm:
			
			Example:
			
			Final Conclusion using Hungarian Algorithm::
				Cluster0	<-->	Tony  Blair 
				Cluster1	<-->	Bill Clinton  
	
	
	d) Displaying the overall accuracy for the label assignment:
		
		 							Sum (Diagonal Scores)
	  		Accuracy =	 -------------------------------------------
	 						Sum (All the Scores of contingency table)
	 		
	 		Example:				
			Accuracy of labels is 53.02% 			
=cut

################################################################################################################

=pod 

=head1 Help

The LabelEvaluation module expect the 'OptionsHash' as the required argument. 

The 'optionHash' has the following elements:
	
1. labelFile: 
	Name of the file containing the labels from SenseClusters. The syntax of file 
	must be similar to label file from SenseClusters. This is mandatory parameter.
	
2. labelComparisonMethod: 
	Name of the method for comparing the labels with GoldKey. This method tells 
	the program whether the keyFile provided by the User will have the mapping 
	between the assigned labels and expected topics of the clusters. 
	Possible options are : 
		A) 'DirectAssignment' and 
		B) 'AutomateAssignment'.
 
   This is mandatory parameter.

3. goldKeyFile:      
	Name of the file containing the actual topics (keys) and their data for the 
	clusters. This is mandatory parameter.
	
4. goldKeyLength: 
	This parameter tells about the length of data to be fetched from the external 
	resource such as Wikipedia. The data will be used as reference data. 
	Default value for this parameter is the first section of the Wikipedia page.

5. goldKeyDataSource:	
	This parameter tell the name of external application or user supplied file  
	name from where we will get the key's data. For now supported options are:
		1. 'Wikipedia'   
		2. 'User' 
		3. 'Wordnet' (Will be supported in future).
		
	This is the mandatory parameter.
	
6. weightRatio:       
	This ratio tells us about the weightage we should provide to Discriminating 
	label over the descriptive label. Default value is set to 10.
	
7. stopList:             
	This is the name of file which contains the list of all stop words. 

8. isClean:              
	This variable will decide whether to keep or delete temporary files.Default 
	value is 'true'.
	
9. verbose:             
	Variable used for the deciding whether to show detailed results to user or 
	not. Default value = Off (0), to make it 'On' change value to 1.

10. help :                 
	This variable will decide whether to display help to user or not. Default 
	value for this parameter is 0.
	
	%inputOptions = (
		senseClusterLabelFileName => '<filelocation>/<SenseClusterLabelFileName>', 
		labelComparisonMethod => 'DirectAssignmentOrAutomateAssignment',
		goldKeyFileName => '<filelocation>/<ActualTopicName>',
		goldKeyLength => '<LenghtOfDataFetchedFromExternalResource>',
		goldKeyDataSource => '<NameOfSourceFromWhichTopicDataBeFeteched>',
		weightRatio => '<WeightageRatioOfDiscriminatingToDiscriptiveLabel>',
		stopListFileLocation => '<filelocation>/<StopListFileLocation>',
		isClean => 1,
		verbose => 0,
		help => 0
	);


Examples 

1. With minimum parameters:
		%inputOptions = (
			senseClusterLabelFileName => 'labelFile.txt', 
			labelComparisonMethod => 'DirectAssignment',
			goldKeyFileName => 'goldKeyFile.txt',
			goldKeyDataSource => 'UserData'
		);
	
		The above mentioned four parameters are mandatory.
		
2. For Help:

		%inputOptions = (
			help => 1
		);
		
3. With all parameters:
	%inputOptions = (
		senseClusterLabelFileName => 'labelFile.txt', 
		labelComparisonMethod => 'AutomateAssignment',
		goldKeyFileName => 'goldKeyFile.txt',
		goldKeyLength => 2000,
		goldKeyDataSource => 'Wikipedia',
		weightRatio => 10,
		stopListFileLocation => 'stoplist.txt',
		isClean => 0,
		verbose => 1,
		help => 0
	);
	
=cut	

# Following blocks declare the global variables for the LabelEvaluation module.
our $senseClusterLabelFileName = "SenseClusterLabelFileName";
our $labelComparisonMethod     = "labelComparisonMethod";
our $goldKeyFileName           = "goldKeyFileName";
our $goldKeyLength             = "goldKeyLength";
our $goldKeyDataSource         = "goldKeyDataSource";
our $weightRatio               = "weightRatio";
our $stopListFileLocation      = "stopListFileLocation";
our $isClean                   = "isClean";
our $verbose     		       = "verbose";
our $help                      = "help";

# These two parameters are used for error handling.
our $errorCode     			   = "errorCode";
our $errorMessage			   = "errorMessage";
our $exitCode				   = "exitCode";

# Defining the all possible value for the of label-comparison-method.
our $labelComparisonMethod_Direct   = "direct";
our $labelComparisonMethod_Automate = "automate";

# Defining the name of all possible sources from where we can get the information about
# the topics. This are possible values for the parameter "goldKeyDataSource":
our $standardReferenceName_Wikipedia = "wikipedia";
our $standardReferenceName_WordNet   = "wordnet";
our $standardReferenceName_UserData  = "userdata";

our $labelType_Descriptive  = "descriptive";
our $labelType_Discriminating = "discriminating";

# The following define the exit-code for this program in different situation.
our $helpExitCode = 400;
our $requiredErrorExitCode   = 404;
our $unknownErrorExitCode  = 502;


# Defining the file handle for the output file.
our $outFileHandle;

# Defining the exit code for the module with default value 1.
# "1" indicates that program exited with proper execution.
our $exitCodeValue = 1;


##########################################################################################

=head1 Constructor: new()   

This is the constructor which will create object for this class.
Reference : http://perldoc.perl.org/perlobj.html

This constructor takes the hash argument and intialize it for the class.

		%inputOptions = (
			senseClusterLabelFileName => 'value1', 
			labelComparisonMethod => 'value2',
			goldKeyFileName => 'value3',
			goldKeyLength => value4,
			goldKeyDataSource => 'value5',
			weightRatio => value6,
			stopListFileLocation => 'value7',
			isClean => value8,
			verbose => value9,
			help => value10
		);
		
Please refer to section "help" about the detailed discussion on this hash.			
=cut

##########################################################################################

sub new {

	# Creating the object.
	my $class        = shift;
	my $driverObject = {};

	# Explicit association is created by the built-in bless function.
	bless $driverObject, $class;

	# Getting the Hash as the argument.
	my $argHash = shift;

	# If the argument is defined then, read its contents and populate the class member
	# values.
	if ( defined $argHash ) {

		# Reading the Key and Value from the argument-hash.
		while (my ($key, $val ) = each %$argHash ) {

			# Setting the class variables.
			if ( lc($key) eq lc($senseClusterLabelFileName)) {
				if($val){
					$driverObject->{$senseClusterLabelFileName} = $val;
				}else{
					# Raise Error: Missing mandatory parameter.
					$driverObject->{$errorCode} = $requiredErrorExitCode; 
					$driverObject->{$errorMessage}= "Label file from the SenseClusters is missing!";
					error($driverObject->{$errorCode}, $driverObject->{$errorMessage});
				}	
			  	
			} elsif (lc($key) eq lc($labelComparisonMethod)) {
				if($val){
					$driverObject->{$labelComparisonMethod} = lc($val);
				}else{
					# Raise Error: Missing mandatory parameter.
					$driverObject->{$errorCode} = $requiredErrorExitCode; 
					$driverObject->{$errorMessage}= "Comparison method for labels and keys is not mentioned!";
					error($driverObject->{$errorCode}, $driverObject->{$errorMessage});
				}	
				
			} elsif (lc($key) eq lc($goldKeyFileName)) {
				if($val){
					$driverObject->{$goldKeyFileName} = $val;
				}else{
					# Raise Error: Missing mandatory parameter.
					$driverObject->{$errorCode} = $requiredErrorExitCode; 
					$driverObject->{$errorMessage}= "Please specify the file name for the GoldKey!";
					error($driverObject->{$errorCode}, $driverObject->{$errorMessage});
				}	
			} elsif ( lc($key) eq lc($goldKeyLength)) {
				if($val){
					$driverObject->{$goldKeyLength} = $val;
				}	
			} elsif ( lc($key) eq lc($goldKeyDataSource)) {
				if($val){
					$driverObject->{$goldKeyDataSource} = $val;
				}else{
					# Raise Error: Missing mandatory parameter.
					$driverObject->{$errorCode} = $requiredErrorExitCode; 
					$driverObject->{$errorMessage}= "Please specify the name of the source from which information about the topic will be feteched!";
					error($driverObject->{$errorCode}, $driverObject->{$errorMessage});
				}	
			} elsif ( lc($key) eq lc($weightRatio)) {
				if($val){
					$driverObject->{$weightRatio} = $val;
				}else{
					$driverObject->{$weightRatio} = 10;
				}	
			} elsif ( lc($key) eq lc($stopListFileLocation)) {
				if($val){
					$driverObject->{$stopListFileLocation} = $val;
				}else{
					$driverObject->{$stopListFileLocation} = "";
				}
			} elsif ( lc($key) eq lc($isClean)) {
				if($val){
					$driverObject->{$isClean} = $val;
				}else{
					$driverObject->{$isClean} = 0;
				}
			} elsif ( lc($key) eq lc($verbose)) {
				if($val){
					$driverObject->{$verbose} = $val;
				}else{
					$driverObject->{$verbose} = 0;
				}
			} elsif ( lc($key) eq lc($help)) {
				if($val == 1){
					$driverObject->{$exitCode} = help();
				}else{
					$driverObject->{$help} = 0;
				}
			}
		}
	}
	# Returning the blessed hash refered by $self.
	return $driverObject;
}


# Function to print the input parameters of the program.
sub printInputParameter {
	my $driverObject = shift;
	print "SenseClusterLabelFileName::  $driverObject->{$senseClusterLabelFileName} \n";
	print "labelComparisonMethod::  $driverObject->{$labelComparisonMethod} \n";
	print "goldKeyFileName::  $driverObject->{$goldKeyFileName} \n";
	print "goldKeyLength::  $driverObject->{$goldKeyLength} \n";
	print "goldKeyDataSource::  $driverObject->{$goldKeyDataSource} \n";
	print "weightRatio::  $driverObject->{$weightRatio} \n";
	print "stopListFileLocation::  $driverObject->{$stopListFileLocation} \n";
	print "isClean::  $driverObject->{$isClean} \n";
	print "verbose::  $driverObject->{$verbose} \n";
	print "help::  $driverObject->{$help} \n";
	print "ExitCode::  $driverObject->{$exitCode} \n";
	print "ErrorCode::  $driverObject->{$errorCode} \n";
	print "ErrorMessage::  $driverObject->{$errorMessage} \n";
}	


# Method for printing the help to end user.   
sub help{
	print "\nPlease pass values of the parameters of the option-hash in the following format:
		%inputOptions = (
			senseClusterLabelFileName => 'labelFile.txt', 
			labelComparisonMethod => 'AutomateAssignment',
			goldKeyFileName => 'goldKeyFile.txt',
			goldKeyLength => 2000,
			goldKeyDataSource => 'Wikipedia',
			weightRatio => 10,
			stopListFileLocation => 'stoplist.txt',
			isClean => 0,
			verbose => 1,
			help => 0
		);
	\nNote that only 'senseClusterLabelFileName', 'labelComparisonMethod', 'goldKeyFileName'".
	" and 'goldKeyDataSource' are mandatory parameters.\n".  
	"For detailed explanation and more examples, please refer the HELP and SYNOPSIS section of this module.\n\n"	;

	# Returning the exit code for the "help".
	return $helpExitCode;		
}


# Method for printing the help to end user.   
sub error{
	my $errorCode = shift;
	my $errorMessage = shift;
		
	print "Program exiting with the error. ";
	print "\nError Code=$errorCode. $errorMessage \n\n";
}


########################################################################################
=head1 Function: evaluateLabels

Function which is responsible for evaluating the labels of the clusters. This
function will call the other modules for completing the process.  

@argument		: $driverObject : Object of the current file.
 
@return 		: $accuracy : DataType(Float)
				  Indicates the overall accuracy of the assignments.
		  
@description	:
		
		Overall algorithm for calculating the accuracy of the labels assignment with the help of gold 
		standard keys are:
		
		Step 1: Read the clusters and their labels information from the ClusterLabel file.
			
		Case A: User has provided the mapping information about the cluster and gold standard key.
			 	Step 2:Read Clusters-Topics mapping information.
			 	
				Subcase1: User provides data for gold standard keys.
							
							Step 3:Read the gold standard keys and their data from the file provided by user.
							Step 4: continue to next step :).
							
				Subcase2: User provides the gold standard keys. We will fetch data from Wikipedia.
			 			   User will just provide the data about the topics, but no mapping.
			 			   
			 				Step 3:Read gold standard keys from the file provided by user.
			 				Step 4:Read data about the gold standard keys from the Wikipedia.
			 				
				Subcase3: User provides the gold standard keys. We will fetch data from Wordnet.
				
							Step 3:Read gold standard keys from the file provided by user.
			 				Step 4:Read data about the gold standard keys from the Wordnet.
				
				Step 5: Create contingency matrix with similarity-scores of cluster's label against each 
						 gold standard key's data (obtained from steps 3 and 4.)
				Step 6: Using the mapping provided by user(step 2) to calculate the diagonal score for the 
						 contingency matrix.
				Step 7: Overall Accuracy for the current cluster's label assignment can be calculated as : 		 		  
				
						 							Sum (Diagonal Scores)
					  		Accuracy =	 -------------------------------------------
					 						Sum (All the Scores of contingency table)
					 						
		Case B: User has not provided the mapping information about the cluster and gold standard key.
			  	 We will use the Hungarian algorithm to compute the mapping.
			  	 	
				Subcase1: User provides data for gold standard keys.
							
							Step 2: Read the gold standard keys and their data from the file provided by user.
							Step 3: Continue to next step :).
							
				Subcase2: User provides the gold standard keys. We will fetch data from Wikipedia.
			 			   User will just provide the data about the topics, but no mapping.
			 				
			 				Step 2: Read gold standard keys from the file provided by user.
			 				Step 3: Read data about the gold standard keys from the Wikipedia.
			 				
				Subcase3: User provides the gold standard keys. We will fetch data from Wordnet.
				
							Step 2: Read gold standard keys from the file provided by user.
			 				Step 3: Read data about the gold standard keys from the Wordnet.

				Step 4: Create contingency matrix with similarity-scores of cluster's label against each 
						 gold standard key's data (obtained from steps 3 and 4.)
				Step 5: Use Hungarian algorithm to determine the mapping of Clusters with gold standard keys.  
				Step 6: Use the above mapping to calculate the total diagonal score for the new contingency matrix. 
				Step 7: Overall Accuracy for the current cluster's label assignment can be calculated as : 		 		  
				
						 							Sum (Diagonal Scores)
					  		Accuracy =	 -------------------------------------------
					 						Sum (All the Scores of contingency table)

=cut

#########################################################################################
# Method for evaluting the labels.
# Steps:			
			# Step 1. Get the mapping.
sub evaluateLabels{
	# Getting the current class object as the argument.
	my $driverObject = shift;
	
	# Getting the clusters file name, from the $driverObject.
	my $clusterFileName = $driverObject->{$senseClusterLabelFileName};

	# Creating the read-file object for reading the cluster's label.
	my $readClusterFileObject = 
			Text::SenseClusters::LabelEvaluation::ReadingFilesData->new ($clusterFileName);
	
	# Defining hash which will hold the cluster and its labels.
	my %labelSenseClustersHash = ();
	# Calling the function to read the cluster and its labels data in the hash.S
	my $labelSenseClustersHashRef = 
			$readClusterFileObject->readLinesFromClusterFile(\%labelSenseClustersHash);
	%labelSenseClustersHash = %$labelSenseClustersHashRef;

	# Getting the topics file name.
	my $topicsFileName = $driverObject->{$goldKeyFileName};
	
	# Defining the variable which will hold the accuracy score for the labesl to be evaluated
	my $accuracyScore = 0; 
	 
	# Creating the read-file object for standard-gold-keys.
	my $readTopicFileObject = 
			Text::SenseClusters::LabelEvaluation::ReadingFilesData->new ($topicsFileName);
	

	# CASE A: User has provided the mapping information about the cluster and gold standard key. 	
	if(lc($driverObject->{$labelComparisonMethod}) eq $labelComparisonMethod_Direct){
		
			# Read Cluster-Topic mapping information and store it in hash. 
			my ($hashRef, $topicArrayRef) = $readTopicFileObject->readMappingFromTopicFile();

			# Reading the hash from its reference.
			my %mappingHash = %$hashRef;
			my @topicArray = @$topicArrayRef;
			
		# Subcase1: User provides data for gold standard keys.			
		if(lc($driverObject->{$goldKeyDataSource}) eq $standardReferenceName_UserData){
			
			# Call user comparison method.	
			
			# Reading the topic-data from the user file.
			# User will provide the name and data of the topics along with mapping.
			my $topicDataHashRef = $readTopicFileObject->readTopicDataFromTopicFile(\@topicArray);
			
			# Reading the hash from its reference.
			my %topicDataHash = %$topicDataHashRef;
			
			# Calling the function 'makeContigencyMatrix' to get the contingency matrix of similarity-scores.
			my ($matrixScoreRef, $colHeaderRef, $rowHeaderRef, $totalMatrixScore) = 
				makeContigencyMatrix(\%labelSenseClustersHash, \%topicDataHash, $driverObject->{$weightRatio}, 
					$driverObject->{$stopListFileLocation});
				
			# Calling the function 'printMatrix' to print the contingency matrix.	
			Text::SenseClusters::LabelEvaluation::AssigningLabelUsingHungarianAlgo::printMatrix 
					($matrixScoreRef, $colHeaderRef,$rowHeaderRef);
					
			# Calling function to calculate the overall accuracy for the label assignment.		
			$accuracyScore = calculateAccuracy 
				(\%mappingHash, $matrixScoreRef, $colHeaderRef, $rowHeaderRef, $totalMatrixScore);	
					
		}elsif (lc($driverObject->{$goldKeyDataSource}) eq $standardReferenceName_Wikipedia){
			
			#
			# Subcase2: User provides the gold standard keys. We will fetch data from Wikipedia.
			# 			User will just provide the data about the topics, but no mapping.
			#
			
			
			my %topicDataHash = ();
			foreach my $topic (@topicArray){
				# Call wikipedia function.
				my $topicData = 
					Text::SenseClusters::LabelEvaluation::Wikipedia::GetWikiData::getWikiDataForTopic(
							$topic);
				$topicDataHash{$topic} = $topicData;
				#print "$topic $topicData\n";
			}

			# Calling the function 'makeContigencyMatrix' to get the contingency matrix of similarity-scores.
			my ($matrixScoreRef, $colHeaderRef, $rowHeaderRef, $totalMatrixScore) = 
				makeContigencyMatrix(\%labelSenseClustersHash, \%topicDataHash, $driverObject->{$weightRatio},
					$driverObject->{$stopListFileLocation});
			print "\nContigency Matrix based on user input::\n";
			
			# Calling the function 'printMatrix' to print the contingency matrix.
			Text::SenseClusters::LabelEvaluation::AssigningLabelUsingHungarianAlgo::printMatrix 
					($matrixScoreRef, $colHeaderRef,$rowHeaderRef);
			
			# Calling function to calculate the overall accuracy for the label assignment.
			$accuracyScore = calculateAccuracy 
				(\%mappingHash, $matrixScoreRef, $colHeaderRef, $rowHeaderRef, $totalMatrixScore);		
				
		}elsif (lc($driverObject->{$goldKeyDataSource}) eq $standardReferenceName_WordNet){
			
			# Subcase3: User provides the gold standard keys. We will fetch data from Wordnet.
			
			# Call wordnet comparison method. User will just provide the topic name.
			# TODO: Left for future implementation.
		}
	
	# CASE B: User has not provided the mapping information about the cluster and gold standard key.
	#		  We will use the Hungarian algorithm to compute the mapping.
	}elsif(lc($driverObject->{$labelComparisonMethod}) eq $labelComparisonMethod_Automate){
		
		# Subcase1: User provides data for gold standard keys.
		# 			User will just provide the data about the topics, but no mapping.
		if(lc($driverObject->{$goldKeyDataSource}) eq $standardReferenceName_UserData){
			
			# Empty array for holding the topics.
			my @tempTopicNameArray = ();
			
			# Reading the topic-data from the user file.
			my $topicDataHashRef = $readTopicFileObject->readTopicDataFromTopicFile(\@tempTopicNameArray);
			# Reading the hash from its reference.
			my %topicDataHash = %$topicDataHashRef;
			
			# Calling the function which will create the contingency matrix for given set of inputs.
			my ($matrixScoreRef, $colHeaderRef, $rowHeaderRef,$totalMatrixScore) = 
				makeContigencyMatrix(\%labelSenseClustersHash, \%topicDataHash, $driverObject->{$weightRatio},
					$driverObject->{$stopListFileLocation});
			
			# Reading the array from its referece.	
			my @matrixScore = @$matrixScoreRef;
			my @colHeader = @$colHeaderRef;
			my @rowHeader = @$rowHeaderRef;
			
			# Creating the Hungarian object.
			my $hungrainObject = Text::SenseClusters::LabelEvaluation::AssigningLabelUsingHungarianAlgo
						->new(\@matrixScore, \@colHeader, \@rowHeader);
						
			# Reading the Mapping with help of function.
			my ($accuracy,$finalMatrixRef,$newColumnHeaderRef) = $hungrainObject->reAssigningWithHungarianAlgo();
			
			# Rounding off accuracy to decimal place.				
			$accuracyScore = sprintf("%.2f", ($accuracy*100));
			print "\n\nAccuracy of labels is $accuracyScore\% \n\n";


		# Subcase2: User provides the gold standard keys. We will fetch data from Wikipedia.
		# 			User will just provide the data about the topics, but no mapping.
		}elsif (lc($driverObject->{$goldKeyDataSource}) eq $standardReferenceName_Wikipedia){
			
			# Calling readLinesFromTopicFile function to get the list of all the topics.
			our $standardTerms =  $readTopicFileObject->readLinesFromTopicFile();
			
			# Spliting the standard terms on "," to get the Topic name.
			# 		For e.g: 	"Bill Clinton  ,   Tony  Blair" 
			my @topicArray = split(/[\,]/, $standardTerms);
			
			# Call wikipedia function. User will just provide the topic name.
			my %topicDataHash = ();
			foreach my $topic (@topicArray){
				# Call wikipedia function.
				my $topicData = 
					Text::SenseClusters::LabelEvaluation::Wikipedia::GetWikiData::getWikiDataForTopic($topic);
				
				# Setting the data about the topic into hash.	
				$topicDataHash{$topic} = $topicData;
				
				# TODO:: Create the file for the data, if user has kept isClean=0.
			}
			
			# Calling the function which will create the contingency matrix for given set of inputs.			
			my ($matrixScoreRef, $colHeaderRef, $rowHeaderRef, $totalMatrixScore) = 
				makeContigencyMatrix(\%labelSenseClustersHash, \%topicDataHash, $driverObject->{$weightRatio}, 
					$driverObject->{$stopListFileLocation});
			
			# Reading the array from its referece.	
			my @matrixScore = @$matrixScoreRef;
			my @colHeader = @$colHeaderRef;
			my @rowHeader = @$rowHeaderRef;
			
			# Creating the object of the class AssigningLabelUsingHungarianAlgo.
			my $hungrainObject = Text::SenseClusters::LabelEvaluation::AssigningLabelUsingHungarianAlgo
						->new(\@matrixScore, \@colHeader, \@rowHeader);
						
			# Reading the Mapping with help of function.
			my ($accuracy,$finalMatrixRef,$newColumnHeaderRef) = $hungrainObject->reAssigningWithHungarianAlgo();
			
			# Rounding off accuracy to decimal place.				
			$accuracyScore = sprintf("%.2f", ($accuracy*100));
			print "\n\nAccuracy of labels is $accuracyScore\% \n\n";
			
		}elsif (lc($driverObject->{$goldKeyDataSource}) eq $standardReferenceName_WordNet){
			
			# Subcase3: User provides the gold standard keys. We will fetch data from Wordnet.
			
			# Call wordnet comparison method. User will just provide the topic name.
			# TODO. Left for future implementation.
		}
	}
	
	# Returning the accuracy of the labels of the clusters.
	return $accuracyScore;
}

##########################################################################################
=head1 function: makeContigencyMatrix

This method is responsible for making the Contigency Matrix containing the similarity-scores of the labels with the data of the gold standard keys.
	 
@argument	: $labelSenseClustersHashRef (Hash containing the labels generated by the SenseClusters)
@argument	: $topicDataHashRef (Hash containing the data of the gold standard keys)
@argument	: $weightageRatio (Parameter which tells the weightage to be given to discriminating labels over descriptive labels of the SenseClusters)
									
@return		: 	1. @matrixScore - Contingency matrix containing the similarity-scores. 
				2. @colHeader - Array containing the column header for the contingency matrix. 
				3. @rowHeader - Array containing the row header for the contingency matrix. 
				4. $totalMatrixScore - Total similarity scores of the contingency matrix.
				
				
@description	:
	1). It will iterate through the hash (%labelSenseClustersHash) and extracts the descriptive and discriminating labels for each clusters.
	2). It will read the data about each gold standard key from the hash (%topicDataHash).
	3). It then uses the module, Text::SenseClusters::LabelEvaluation::SimilarityScore to get various similarity score.
	4). Finally, it uses the raw-lesk scores to prepare the contingency  matrix.
	
=cut
##########################################################################################

sub makeContigencyMatrix{
	# Getting the reference of the Hash containing the cluster's label.
	my $labelSenseClustersHashRef = shift;
	# Reading the hash from its reference.
	my %labelSenseClustersHash = %$labelSenseClustersHashRef;
	
	# Getting the reference of the hash containing the topic and its infomation.
	my $topicDataHashRef = shift;
	# Reading the hash from its reference.
	my %topicDataHash = %$topicDataHashRef;

	# Getting the weightage for discriminating and descriptive labels. 
	my $weightageRatio = shift;

	# Getting the stop list file location. 
	my $stopListFileLoc = shift;
	
	# Defining the matrix which contains the score.
	my @matrixScore = ();
	# Defining the internal Index for the matrix score.
	my $firstDimIndex = 0;
	# Variable which will hold TotalMatrixScore.
	my $totalMatrixScore = 0;
	
	# Array that will contain Row Header (Cluster name).
	my @rowHeader = sort keys %labelSenseClustersHash;
	# Array that will contain Column Header (Topic name).
	my @colHeader = sort keys %topicDataHash;
	
	# Iterating through each cluster entry .
	foreach my $key (sort keys %labelSenseClustersHash){
		# Variable to store the two type of labels for the cluster.
		my $clusterDescriptiveLabel ="";
		my $clusterDiscriminatingLabel ="";
		
		# Reading the labels for a cluster from the hash.
		for my $innerkey (keys %{$labelSenseClustersHash{$key}}){
			if(lc($innerkey) eq $labelType_Descriptive){
				$clusterDescriptiveLabel = $labelSenseClustersHash{$key}{$innerkey};	
			}elsif(lc($innerkey) eq $labelType_Discriminating){
				$clusterDiscriminatingLabel	= $labelSenseClustersHash{$key}{$innerkey};	
			}
		}
		
		# Defining Index for the second dimension.
		my $secondDimIndex = 0;

		# Iterating through the topics.
		for my $topicKey (sort keys %topicDataHash){
			
			# Calling the SimilarityScore module to get the Similarity Score between 
			# Descriptive labels and Gold Key Data.
			my $similarityObject = Text::SenseClusters::LabelEvaluation::SimilarityScore
					->new($clusterDescriptiveLabel,$topicDataHash{$topicKey}, 
							$stopListFileLoc);
			my ($score, %allScores) = $similarityObject->computeOverlappingScores();
			my $descriptiveScore = $allScores{'raw_lesk'};			

			# Calling the SimilarityScore module to get the Similarity Score between 
			# Discriminating labels and Gold Key Data.
			$similarityObject = Text::SenseClusters::LabelEvaluation::SimilarityScore
					->new($clusterDiscriminatingLabel,$topicDataHash{$topicKey}, 
							$stopListFileLoc);
			($score, %allScores) = $similarityObject->computeOverlappingScores();
			my $discriminatingScore = $allScores{'raw_lesk'};


			# Calculating Total-Similarity-Score for the labels and gold-key.	
			my $totalScore =  $descriptiveScore + $weightageRatio * $discriminatingScore;
			# Storing the similarity score into 2D-Array MatricScore. 		
			$matrixScore[$firstDimIndex][$secondDimIndex++] =  $totalScore;

			# Adding the current similarity-score to overall total similarity score.		
			$totalMatrixScore = $totalMatrixScore + $totalScore;
		}
		$firstDimIndex++;
	}
	# Returning the Array contianing Similarity Score, row and column headers.
	return (\@matrixScore, \@colHeader, \@rowHeader, $totalMatrixScore);
}


########################################################################################
=head1 Function: calculateAccuracy

Method used for calculating the Accuracy score for the labels generated by the
SenseClusters or others.

@argument1		: $mappingHashRef (Reference to Hash which contains the mapping information about the cluster and gold standard) 
@argument2		: $matrixScoreRef (2-D Array/Matrix which contains the similarity-scores of each labels)
@argument3		: $colHeaderRef (Reference of array which contains the column header)
@argument4		: $rowHeaderRef (Reference of array which contains the row header)
@argument5		: $totalMatrixScore (Total similarity score of the labels with gold standard)
 
@return 		: Return the overall accuracy of the labels assigned by the SenseClusters.
		  
@description	:
		1). With the help of ()$mappingHashRef $matrixScoreRef $colHeaderRef $rowHeaderRef),
		    this function try to calculate the sum of all diagonal elements.
		2).  It will then calculate the accuracy for the assignment as
	
			 					Sum (Diagonal Scores)
		  		Accuracy =	 -------------------------
		 						Sum (All the Scores)
		 						
=cut

#########################################################################################
sub calculateAccuracy{
	my $mappingHashRef = shift;
	my $matrixScoreRef = shift;
	my $colHeaderRef = shift; 
	my $rowHeaderRef = shift;
	my $totalMatrixScore = shift;
	
 	my %mappingHash = %$mappingHashRef;
	my @matrixScore = @$matrixScoreRef;
	# Array that will contain Row Header (Cluster name).
	my @rowHeader = @$rowHeaderRef;
	# Array that will contain Column Header (Topic name).
	my @colHeader =  @$colHeaderRef;

	# Defining the internal Index for the matrix score.
	my $firstDimIndex = 0;
	# Variable which will hold TotalMatrixScore.
	my $diagonalScore = 0;
	
	print "\n\n Mapping provided by user\n";
	for my $key (keys %mappingHash){
		my $rowIndex = 0;
		my $colIndex = 0;
		
		#print "$key $mappingHash{$key} @rowHeader @colHeader \n";
		for my $index(0..@rowHeader){
			if($key eq $rowHeader[$index]){
				$rowIndex = $index;
			}
		}
		for my $index(0..@colHeader){
			if($mappingHash{$key} eq $colHeader[$index]){
				$colIndex = $index;
			}
		}
		# Getting the diagonal.
		$diagonalScore = $diagonalScore +  $matrixScore[$rowIndex][$colIndex];
		print "\t$key\t<-->\t$mappingHash{$key} \n";
	}

	# Making the accuracy in percentage and rounding off it to 2 decimal place.	
	my $accuracy = sprintf("%.2f", ($diagonalScore *100 /$totalMatrixScore));
	print "\nAccuracy of assigned labels =". $accuracy ."\%\n";
}



#######################################################################################################
=pod

=head1 BUGS

=over

=item * Currently not supporting the WordNet gold standards comparison. 

=back

=head1 SEE ALSO

http://senseclusters.cvs.sourceforge.net/viewvc/senseclusters/LabelEvaluation/ 
 
Last modified by :
$Id: Driver.pm,v 1.2 2013/02/14 03:50:08 jhaxx030 Exp $

=head1 AUTHORS

 	Anand Jha, University of Minnesota, Duluth
 	jhaxx030 at d.umn.edu

 	Ted Pedersen, University of Minnesota, Duluth
 	tpederse at d.umn.edu


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012-2013 Ted Pedersen, Anand Jha 

See http://dev.perl.org/licenses/ for more information.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to: 
 
	
	The Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
	Boston, MA  02111-1307  USA
	
	
=cut
#######################################################################################################

1;