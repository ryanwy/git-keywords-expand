#!/usr/bin/perl 
###########################################################################
# @File : keywords_filter.pl
# @Author: ryanwy
# @Mail: wangyan_ryan@163.com
# @Description: this is script both for clean or smduge command, it will
#       be trigger on git add/commit/status/diff or git checkout
# @Branch: origin/master https://github.com/ryanwy/git-keywords-expand.git
############################################################################

use strict;
use warnings;
use Getopt::Long;
use Cwd 'abs_path';

main();

sub main {    
    my ( $type, $file );
         
    # get command args
    GetOptions(
        't=s' => \$type,
        'f=s' => \$file,
    );
  
    if( not defined $type and not defined $file ) {
        print "type and file, all needed";
    }

    # function in types
    if( $type =~ /clean/i ) {
        set_clean($file);
    } elsif ( $type =~ /smudge/i ) {
        set_smudge($file);
    } else {
        print "please enter correct mode clean or smudge";
    }
  
}

# clean: from work area to stage area, triggered by git add,commit,stage,status,diff
# get information from 'git log'
sub set_clean {
    my $filename = shift;
    
    my ( $author, $usrname, $date, $rev, $filepath );
    
    $author = `git log --pretty=format:"%an %ae" -1 -- $filename`;
    $date = `git log --pretty=format:"%ad" -1 -- $filename`;
    $rev = `git log --pretty=format:"%H" -1 -- $filename`;
    $usrname = `git log --pretty=format:"%an" -1 -- $filename`;

    if( not defined $author or 
        not defined $usrname or
        not defined $date or
        not defined $rev ) {
        print "lack of information:  author/date/rev/usrname";
    }
    
    $filepath = abs_path($filename);
    if( not defined $filepath ) {
        print "invalid filepath";
    }
    
    my @content;
    
    while(<STDIN>) {
       if(/\$Author[^\$]*\$/) {
            s/\$Author[^\$]*\$/\$Author: $author \$/g;
        }
        if(/\$Id[^\$]*\$/) {
            s/\$Id[^\$]*\$/\$Id: $filename $date  $usrname \$/g;
        }
        if(/\$Date[^\$]*\$/) {
            s/\$Date[^\$]*\$/\$Date:   $date \$/g;
        }
        if(/\$Revision[^\$]*\$/) {
            s/\$Revision[^\$]*\$/\$Revision: $rev \$/g;
        }
        if(/\$Header[^\$]*\$/) {
            s/\$Header[^\$]*\$/\$Header: $filepath $rev $date $usrname \$/g;
        }
        push @content, $_;
    }
    print @content;
}

# smudge: from stage area to work area, triggered by git checkout, pull
sub set_smudge {
    my $filename = shift;
    my ( $author, $usrname, $date, $rev, $filepath );
    
    $author = `git log --pretty=format:"%an %ae" -1 -- $filename`;
    $date = `git log --pretty=format:"%ad" -1 -- $filename`;
    $rev = `git log --pretty=format:"%H" -1 -- $filename`;
    $usrname = `git log --pretty=format:"%an" -1 -- $filename`;


    if( not defined $author or 
        not defined $usrname or
        not defined $date or
        not defined $rev ) {
        print "lack of information:  author/date/rev/usrname";
    }
    
    # if the log information is empty, we get log from remote branch
    if( $author eq "" or 
        $date eq "" or
        $rev eq "" or
        $usrname eq ""
        )
    {
        my $branch = `git branch`;
        my $remote = `git remote`;
        $branch =~ /^\*\s+(.*)/m;
        $branch = $1;
        $remote =~ /(.*)/m;
        $remote = $1;
        my $prefix = $remote.'/'.$branch;
        $author = `git log $prefix --pretty=format:"%an %ae" -1 -- $filename`;
        $date = `git log $prefix --pretty=format:"%ad" -1 -- $filename`;
        $rev = `git log $prefix --pretty=format:"%H" -1 -- $filename`;
        $usrname = `git log $prefix --pretty=format:"%an" -1 -- $filename`; 
    }
    
    $filepath = abs_path($filename);
    if( not defined $filepath ) {
        print "invalid filepath";
    }
    
    my @content;
    # replace all marks
    while(<STDIN>) {
        if(/\$Author[^\$]*\$/) {
            s/\$Author[^\$]*\$/\$Author: $author \$/g;
        }
        if(/\$Id[^\$]*\$/) {
            s/\$Id[^\$]*\$/\$Id: $filename $date  $usrname \$/g;
        }
        if(/\$Date[^\$]*\$/) {
            s/\$Date[^\$]*\$/\$Date:   $date \$/g;
        }
        if(/\$Revision[^\$]*\$/) {
            s/\$Revision[^\$]*\$/\$Revision: $rev \$/g;
        }
        if(/\$Header[^\$]*\$/) {
            s/\$Header[^\$]*\$/\$Header: $filepath $rev $date $usrname \$/g;
        }
        push @content, $_;
    }
    print @content;
}

# deprecated: just for test
sub sample {

    my ($filepath, $author, $date, $rev, $usrname) = @_;
    my @content2;
    # replace all marks
    open my $fh, '<', $filepath or die( "open file error");
    while(<$fh>) {
        if(/\$Author[^\$]*\$/) {
            s/\$Author[^\$]*\$/\$Author: $author \$/g;
        }
        if(/\$Id[^\$]*\$/) {
            s/\$Id[^\$]*\$/\$Id: $filepath $date  $usrname \$/g;
        }
        if(/\$Date[^\$]*\$/) {
            s/\$Date[^\$]*\$/\$Date:   $date \$/g;
        }
        if(/\$Revision[^\$]*\$/) {
            s/\$Revision[^\$]*\$/\$Revision: $rev \$/g;
        }
        if(/\$Header[^\$]*\$/) {
            s/\$Header[^\$]*\$/\$Header: $filepath $rev $date $usrname \$/g;
        }
        push @content2, $_;
    }
    close($fh); 
    
    open my $fh2, '>', $filepath or die( "open write file error" );
    print $fh2 @content2;
    close($fh2);



}
