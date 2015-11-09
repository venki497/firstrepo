#!/usr/bin/perl

use strict;
use warnings;
use Date::Parse;
use Graph::Undirected;
use Algorithm::Combinatorics qw(combinations);

my $inputfile = 'tweet_input/tweets.txt'; #input file containing tweets
open(my $input, $inputfile)
  or die "Could not open file '$inputfile' $!";
my $outputfile = 'tweet_output/ft2.txt'; #output file containing cleaned tweets
open(my $output, '>' , $outputfile)
  or die "Could not open file '$outputfile' $!";
my $tweetcount = 0;
my @time;
my @hashgraph;
while (my $row = <$input>) {
  chomp $row;

  if(index($row,'"created_at":') != 1)
  {
      #This tweet is not in expected format(Tweet not starting with created_at field .. Skipping parsing of this tweet.
      next;
  }
  
  # ---------------------------------------
  # Extracting Text
  #----------------------------------------

  my $char = '"text":';
  my $textbegin = index($row, $char);
  $textbegin = $textbegin + length($char) + 1; #1 to remove beginning double colon.
  $char = '"source":';
  my $textend = index($row, $char);
  $textend = $textend - 1 - 1; #1 to remove comma after 'text' and another 1 to remove ending double colon
  my $text = substr($row,$textbegin,($textend-$textbegin));
  if($text =~ m/\\u..../)
  {
      $text =~ s/\\u....//g;
  }
  $text =~ s/\\n|\\//g;

  #Extracting HashTags from text
  
  my @strings = $text =~ /\B#\w*[a-zA-Z]+\w*/g;
  
  my $string;
  my $length = @strings; #No of elements in string - no of hashtags
  my @temp; 
  if($length > 1) #minimum hashtags more than 2
  {
      my $iter = combinations(\@strings, 2);
      while (my $c = $iter->next) {
           push @temp,@$c;
          }
      my $tempstring = join " ",@temp;
      push @hashgraph,$tempstring;
  }
  else
  {
      push @hashgraph,""; #place holder denoting no hashtags formign edges for this tweet. 
  }

  
  # ---------------------------------------
  # Extracting timestamp
  #----------------------------------------

  my $time = '"created_at":';
  my $timestampbegin = index($row, $time);
  $timestampbegin = $timestampbegin + length($time) + 1; #1 to remove beginning double colon.
  my $id = '"id":';
  my $timestampend = index($row, $id);
  $timestampend = $timestampend - 1 - 1; #1 to remove comma after 'text' and another 1 to remove ending double colon
  my $timestamp = substr($row,$timestampbegin,($timestampend-$timestampbegin));
  $timestamp =~ s/\+.....//g; #to remove '+0000 ' in timestamp
  
  my $s1 = str2time( $timestamp );
  
  push @time,$s1;
  
   
  #Empty out all tweets that doesnt fall in 60 second window
  while((($time[-1] - $time[0]) > 60) and ($time[-1] > $time[0])) #if any previous tweet falls in 60 sec window
	  {
  		  shift @time;
		  shift @hashgraph;
	  }
      
      my $edgelist = "@hashgraph";
      my @edgearray = split /\s+/, $edgelist; # In this array every pair of elements is an edge. 
      my $g = Graph::Undirected->new;
      my $u = shift @edgearray;
      my $v = shift @edgearray;
      while((defined $u) && (defined $v))
      {
          if(!($g->has_edge($u,$v)))
          {
              $g->add_edge($u,$v);
          }
          $u = shift @edgearray;
          $v = shift @edgearray;
      }
      my $ad = $g->average_degree;
      my $rounded = sprintf("%.2f", $ad);
      print $output "$rounded \n";
     
      $tweetcount++;
}	
close $input;
close $output;

