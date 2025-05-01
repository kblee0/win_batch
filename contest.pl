#!/usr/bin/perl -w                                                                                               
use strict;                                                                                                      
use Socket;                                                                                                      
use Sys::Hostname qw(hostname);                                                                                  
use IO::Socket::INET;                                                                                            
                                                                                                                 
my $local_ip = inet_ntoa( (gethostbyname(hostname()))[4] );                                                      
                                                                                                                 
if( $#ARGV < 1 ) {                                                                                               
        my @conlist = ();                                                                                        
                                                                                                                 
        if( $#ARGV eq 0 and -f $ARGV[0] ) {                                                                      
                open FD, $ARGV[0];                                                                               
                while( my $line = <FD> ) {                                                                       
                        chomp $line;                                                                             
                        push @conlist, $line;                                                                    
                }                                                                                                
        }                                                                                                        
        else {                                                                                                   
                print "Please enter \"<ip> <port>\" for each line . To finish , enter \".\"\n>> ";               
                while( my $line = <STDIN> ) {                                                                    
                        chomp $line;                                                                             
                        if( $line eq '.' ) {                                                                     
                                last;                                                                            
                        }                                                                                        
                                                                                                                 
                        push @conlist, $line;                                                                    
                        print ">> ";                                                                             
                }                                                                                                
        }                                                                                                        
                                                                                                                 
        &printhead;                                                                                              
                                                                                                                 
        for my $line (@conlist) {                                                                                
                my @con = split /\s+/, $line;                                                                    
                if( $#con < 1 ) {                                                                                
                        next;                                                                                    
                }                                                                                                
                &contest( @con );                                                                                
        }                                                                                                        
}                                                                                                                
else {                                                                                                           
        &printhead;                                                                                              
        &contest( @ARGV );                                                                                       
}                                                                                                                
                                                                                                                 
                                                                                                                 
sub contest {                                                                                                    
        my ($server, $port) = @_;                                                                                
                                                                                                                 
        my $sock = new IO::Socket::INET(                                                                         
            PeerAddr => $server,                                                                                 
            PeerPort => $port,                                                                                   
            Proto => 'tcp',                                                                                      
            Timeout => 1,                                                                                        
            );                                                                                                   
                                                                                                                 
        &printres( $server, $port, defined $sock, $! );                                                          
                                                                                                                 
        if( defined $sock ) {                                                                                    
                close($sock) or die "close: $!";                                                                 
        }                                                                                                        
}                                                                                                                
                                                                                                                 
sub printhead {                                                                                                  
        print "\n";                                                                                              
        printf "%-15s %-16s %-25s %-5s %-4s %s\n", "Test time", "Source IP", "Target IP", "Port", "Res.", "Desc";
        print  "------------------------------------------------------------------------------------------\n";   
}                                                                                                                
                                                                                                                 
sub printres {                                                                                                   
        my ($server, $port, $res, $errstr) = @_;                                                                 
                                                                                                                 
        my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime();                                  
                                                                                                                 
        if( $res ) {                                                                                             
                printf "%02d/%02d %02d:%02d:%02d  %-16s %-25s %-5s %-4s\n",                                      
                        $mon+1, $mday, $hour, $min, $sec, $local_ip, $server, $port, "Ok";                       
        }                                                                                                        
        else {                                                                                                   
                printf "%02d/%02d %02d:%02d:%02d  %-16s %-25s %-5s %-4s %s\n",                                   
                        $mon+1, $mday, $hour, $min, $sec, $local_ip, $server, $port, "Fail", $errstr;            
        }                                                                                                        
}                                                                                                                