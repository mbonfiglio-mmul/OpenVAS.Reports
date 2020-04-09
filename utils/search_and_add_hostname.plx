#!/bin/perl

use strict;
use warnings;
use File::Basename;
use XML::LibXML;
use Data::Dumper;

if (scalar @ARGV < 1)
{
	my ($progname) = fileparse($0);
	print STDERR <<"USAGE";
usage: ${progname} <hostlist_IP_HOSTNAME.csv>
_The hostlist must use comma ',' as separator._

This script will read the hostlist file.
Then, it will analyze the stdin stream of a CSV report.
For every line beginning with an IP (first field) and missing
the hostname (second field), it will search the IP in previously
read file and fill the field.
Then, write to stdout.
USAGE
	exit 1;
}

sub start_element {
my ($self, $el) = @_;

print "found element: ", $el->{Name}, "\n";

for my $attr (values %{$el->{Attributes}}) {
	print "  '", $attr->{Name}, "' = '", $attr->{Value}, "'\n";
}

print "\n";
}

my $hostlist_file = $ARGV[0];

if (! -r $hostlist_file)
{
	print STDERR "ERROR: cannot read \"${hostlist_file}\".\n";
	exit 1;
}

my %hostlist = ();

print STDERR "Reading \"${hostlist_file}\"...\n";
if (open(my $fh, '<:encoding(UTF-8)', $hostlist_file))
{
	my @hostlist_lines = <$fh>;
	close $fh;
	chomp @hostlist_lines;
	for my $line (@hostlist_lines)
	{
		next if $line !~ /([0-9]{1,3}\.){3}[0-9]{1,3},[^,]+$/;
		my ($ip, $host) = split ',', $line;
		# Remove apices
		$host =~ s/\"//g;
		# Add an asterisk before name, to signal
		# it was added
		$hostlist{$ip} = "* ${host}";
	}
}
else
{
	print STDERR "ERROR: cannot open \"${hostlist_file}\".\n";
	exit 1;
}

my $hosts_found = scalar keys %hostlist;
if ( $hosts_found < 1)
{
	print STDERR "No host found. Exiting.\n";
	exit 2;
}
print STDERR "Found ${hosts_found} hosts.\n";

print STDERR "Reading stdin into memory...\n";
my @lines = <STDIN>;
print STDERR "Read ".(scalar @lines)." lines.\n";

my $xml = join '', @lines;
my $dom = XML::LibXML->load_xml( string => $xml );
for my $host ($dom->findnodes('/report/report/results/result/host')) {
	my $ip       = $host->findvalue('.'); 
	my $hostname = $host->findnodes('./hostname')->[0];
	if (! $hostname or ! $hostname->findvalue('./text()') and $hostlist{$ip})
	{
		$hostname->appendText($hostlist{$ip});
	}
	my $asset_id = $host->findvalue('./asset/@asset_id');
	my $host_node       = $dom->findnodes('/report/report/host[asset/@asset_id="'.$asset_id.'"]')->[0];
	# Verify if host detail is present, or add it
	my $hostname_detail = $host_node->findnodes('./detail[name/text()="hostname"]');
	if (!$hostname_detail)
	{
		my $detail_node               = $dom->createElement('detail');      #<detail>
		$host_node->appendChild($detail_node);
		my $detail_name               = $dom->createElement('name');        #  <name>hostname</name>
		$detail_name->appendText('hostname');
		$detail_node->appendChild($detail_name);
		my $detail_value              = $dom->createElement('value');       #  <value>[hostname]</value>
		$detail_value->appendText($hostlist{$ip});
		$detail_node->appendChild($detail_value);
		my $detail_source             = $dom->createElement('source');      #  <source>
		$detail_node->appendChild($detail_source);
		my $detail_source_type        = $dom->createElement('type');        #    <type>nvt</type>
		$detail_source_type->appendText('nvt');
		$detail_source->appendChild($detail_source_type);
		my $detail_source_name        = $dom->createElement('name');        #    <name>1.3.6.1.4.1.25623.1.0.103997</name>
		$detail_source_name->appendText('1.3.6.1.4.1.25623.1.0.103997');
		$detail_source->appendChild($detail_source_name);
		my $detail_source_description = $dom->createElement('description'); #    <description>Host Details</description>
		$detail_source_description->appendText('Host Details');
		$detail_source->appendChild($detail_source_description);
		my $detail_extra              = $dom->createElement('extra');       #  <extra/>
		$detail_node->appendChild($detail_extra);
		$hostname_detail = $host_node->findnodes('./detail[name/text()="hostname"]');
	}
}

print $dom->getDocumentElement->toString(0);

print STDERR "Done. Have a good day!\n";

exit 0;
