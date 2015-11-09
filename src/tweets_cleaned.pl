#! /usr/bin/perl
use strict;
use warnings;
 
my $inputfile = 'tweet_input/tweets.txt'; #input file containing tweets
open(my $input, $inputfile)
  or die "Could not open file '$inputfile' $!";
my $outputfile = 'tweet_output/ft1.txt'; #output file containing cleaned tweets
open(my $output, '>' , $outputfile)
  or die "Could not open file '$outputfile' $!";
my $count = 0; 
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
      $count = $count + 1;
      $text =~ s/\\u....//g;
  }
  $text =~ s/\\n|\\//g;
  
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
  $timestamp = " (timestamp: " . $timestamp . ")" ;  
  print $output "$text$timestamp\n";
}

print $output "\n\n$count tweets contained unicode.\n";
close $output;
close $input;

