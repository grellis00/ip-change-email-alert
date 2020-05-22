#! /usr/bin/perl -w

# Quick/Simple little script to check your current public IP address, and send an alert if it changes. 
# Need to fill in the variables within the script. 
# Run as a cron however frequently you want the script to check/run. 

use Net::SMTP::SSL;
use MIME::Entity;
use Net::SMTP;
use Net::SMTP_auth;

# FETCH THE PUBLIC IP ADDRESS
$ip = `wget http://icanhazip.com/ -O - -q ; echo`;
chomp ($ip);
chomp ($ip);

# OPEN FILE THAT CONTAINS THE IP ADDRESS
# AS OF THE LAST TIME THE SCRIPT WAS RAN
open FILE, "<", "/scripts/cip" or die $!;
$currentIP = <FILE>;
chomp ($currentIP);
close FILE;

# COMPARE THE OLD IP AND THE FETCHED IP
# FOR DIFFERENCES
if ($currentIP ne $ip)
{
        #IP HAS CHANGED; EMAIL ADMIN THE NEW IP
        #AND THEN CHANGE THE IP RECORD FILE
        open FILE, ">", "/scripts/cip" or die $!;
        print FILE $ip;
        close FILE;
        &emailAdmin;
}

sub emailAdmin
{
        # Fill in your Email template
        my $from = '';
        my $to = '';
        my $subject = 'IP ADDRESS CHANGE ALERT';
        my $text_message = "The public IP address for has changed.\n\nNew IP: $ip\nOld IP: $currentIP\n.";
        my $html_message = "The public IP address for has changed.\n\nNew IP: $ip\nOld IP: $currentIP\n.";

        my $message = MIME::Entity->build (
                Type => 'multipart/alternative',
                From => $from,
                To => $to,
                Subject => $subject
	    );

        $message->attach(Type => 'text/plain', Data => $text_message);
        $message->attach(Type => 'text/html', Data => $html_message);

        # Fill in your SMTP account details
        my $username = '';
        my $password = '';
        my $smtp;

        if (not $smtp = Net::SMTP->new('mail.smtp2go.com',
                Port => 2525, # 8025, 587 and 25 can also be used.
                Timeout => 30)) {
                die "Could not connect to server";
        }

        $smtp->auth($username, $password) || die "Authentication failed! n";
        $smtp->mail($from);
        $smtp->to($to);
        $smtp->data($message->as_string);
        $smtp->quit;
