#!/usr/bin/perl -w

# Declaring the Package for the module.
package Text::SenseClusters::LabelEvaluation::SimilarityScore;

use strict; 
use encoding "utf-8";

# The following two lines will make this module inherit from the Exporter Class.
require Exporter;
our @ISA = qw(Exporter);


# Using Text Similarity Module.
# Reference: http://search.cpan.org/~tpederse
#					/Text-Similarity-0.08/lib/Text/Similarity.pm
use Text::Similarity::Overlaps;


#######################################################################################################################

=head1 Name 

Text::SenseClusters::LabelEvaluation::SimilarityScore - Module for getting the similarity score between the contents of the two files. 

=head1 SYNOPSIS

		# The following code snippet will show how to use SimilarityScore.
		package Text::SenseClusters::LabelEvaluation::Test_SimilarityScore;

		# Including the LabelEvaluation Module.
		use Text::SenseClusters::LabelEvaluation::SimilarityScore;


		my $firstString = "IBM::: vice president, million dollars, Wall Street, Deep Blue, ".
					"International Business, Business Machines, International Machines, ".
					"United States, Justice Department, personal computers";
		my $secondString = "vice president, million dollars, Deep Blue, International Business, ".
						"Business Machines, International Machines, United States, Justice Department";
						 
		my $similarityObject = Text::SenseClusters::LabelEvaluation::SimilarityScore->
				new($firstString,$secondString, "../stoplist.txt");
		
		#my $score = $similarityObject->computeOverlappingScores();
			my ($score, %allScores) = $similarityObject->computeOverlappingScores();
	
		print "Score:: $score \n";
		print "Lesk Score :: $allScores{'lesk'} \n";
		print "Raw Lesk Score :: $allScores{'raw_lesk'} \n";
		print "precision Score :: $allScores{'precision'} \n";
		print "recall Score :: $allScores{'recall'} \n";
		print "F Score :: $allScores{'F'} \n";
		print "dice Score :: $allScores{'dice'} \n";
		print "E Score :: $allScores{'E'} \n";
		print "cosine Score :: $allScores{'cosine'} \n";
		print "\n\n";


=head1 DESCRIPTION

This module provide a function that will compare the two strings and return 
the overlapping scores. Please refer the following for details description
how it will calculate the similarity score:
http://search.cpan.org/~tpederse/Text-Similarity-0.09/ 
			
=cut


# Member variable of the class.
my $clusterData = "ClusterData";
my $topicData = "TopicData";
my $stopListFileLoc = "StopListLoc";
my $verbose = "Verbose";
	

##########################################################################################

=head1 Constructor: new()   

This is the constructor which will create object for this class.
Reference : http://perldoc.perl.org/perlobj.html

This constructor takes these argument and intialize it for the class:
	
	1. $clusterData :  Datatype: String
		  This variable contains the labels generated by the SenseClusters.
	2. $scoreObject :  Datatype: String
		  This variable contains the Gold standard key's data.
	3. $stopListFileLoc :  Datatype: String
		  This variable contains the user defined location for the stop list file.
	4. $verbose :  Datatype: integer
		  This variable tells whether to display all type of similarity score or not.		  
					
=cut

##########################################################################################
sub new {

	# Creating the object.
	my $class        = shift;
	my $scoreObject = {};

	# Explicit association is created by the built-in bless function.
	bless $scoreObject, $class;

	# Getting the ClusterData from the argument.
	$scoreObject->{$clusterData} = shift;

	# Getting the Topic data from the argument.	
	$scoreObject->{$topicData} = shift;

	# Getting the stop list file location.
	$scoreObject->{$stopListFileLoc} = shift;
	
	# Getting the verbose option by user.
	$scoreObject->{$verbose} = shift;
	
	# Returning the blessed hash refered by $self.
	return $scoreObject;
}	


########################################################################################
=head1 Function: computeOverlappingScores

Function that will compare the labels file with the wiki files and  
will return the overlapping score. 

@argument1		: Name of the cluster file.
@argument2		: Name of the file containing the data from Wikipedia.
@argument3		: Name of the file containing the stop word lists.
 
@return 		: Return the overlapping scores between these files.
		  
@description	:
		1). Reading the file name from the command line argument.
		2). Invoking the Text::Similarity::Overlaps module and passing
			the file names for similarity comparison.
 		3). Then overlapping scores obtained from this module is returned 
			as the similarity value.

=cut

#########################################################################################

sub computeOverlappingScores{
	 
	# Reading the object as the argument.
	my $readFileObject = shift;
	 
	# Getting the Cluster's Label as the FirstString.
	my $firstString = $readFileObject->{$clusterData};
	
	# Getting the Gold Data as the SecondString for comparison.
	my $secondString = $readFileObject->{$topicData};

	# Getting the stop list file location.
	my $stopListFileLocation = $readFileObject->{$stopListFileLoc};
	
	# Getting the verbose option by user.
	my $verboseOption = $readFileObject->{$verbose};
	
	if(!defined $stopListFileLocation){
			 # Getting the module name.
			my $module = "Text/SenseClusters/LabelEvaluation/SimilarityScore.pm";
			   
			# Finding its installed location.
			my $moduleInstalledLocation = $INC{$module};
		
			# Getting the prefix of installed location. This will be one of 
			# the values in array @INC.
			$moduleInstalledLocation =~ 
				m/(.*)Text\/SenseClusters\/LabelEvaluation\/SimilarityScore\.pm$/g;
			
			# Getting the installed stopList.txt location using above location. 
			# For e.g.:
			#	/usr/local/share/perl/5.10.1/Text/SenseClusters
			#			/LabelEvaluation/stoplist.txt
			$stopListFileLocation 
					= $1."/Text/SenseClusters/LabelEvaluation/stoplist.txt";
	}
	
	# Setting the Options for getting the results from the Text::Similarity
	# Module.
	my %options = ('verbose' => $verboseOption, 'stoplist' => $stopListFileLocation);

	# Creating the new Overlaps Object.
	my $mod = Text::Similarity::Overlaps->new (\%options);
	
	# If the object is not created, then quit the program with error message. 
	defined $mod or die "Construction of Text::Similarity::Overlaps failed";

	# Getting the overlapping score from the Similarity function.
	my ($score, %allScores)= $mod->getSimilarityStrings ($firstString, $secondString);


	# Printing the Similarity Score for the files.
	#print "The similarity of $firstString and $secondString is : $score\n";
	#print "The similarity of $firstString and $secondString is : $allScores{'lesk'}\n";

	# Reference : http://perldoc.perl.org/functions/wantarray.html
	return wantarray ? ($score, %allScores) : $score;	
}


  sub DESTROY {
      my $self = shift;
      $self->{handle}->close() if $self->{handle};
  }

#######################################################################################################
=pod


=head1 SEE ALSO

http://senseclusters.cvs.sourceforge.net/viewvc/senseclusters/LabelEvaluation/ 
 
 
Last modified by :
$Id: SimilarityScore.pm,v 1.5 2013/03/07 23:14:13 jhaxx030 Exp $

	
=head1 AUTHORS

 	Anand Jha, University of Minnesota, Duluth
 	jhaxx030 at d.umn.edu

 	Ted Pedersen, University of Minnesota, Duluth
 	tpederse at d.umn.edu

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 Ted Pedersen, Anand Jha 

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


# Making the default return statement as 1;
# Reference : http://lists.netisland.net/archives/phlpm/phlpm-2001/msg00426.html
1;
