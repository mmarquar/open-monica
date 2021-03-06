#!/usr/bin/perl

use lib '.';

use strict;
use CGI;
use ATNF::MoniCA;
use Time::Local;
use Astro::Time;
use POSIX;
use Scalar::Util qw(looks_like_number);

my $in=CGI->new;

my %input=$in->Vars;

# start the HTML output
print $in->header('text/json');

#debugging
#$input{"server"}="narrabri.ozforecast.com.au";

# the input should contain the name of the server to connect to
my $mon=monconnect($input{"server"});

#if (!defined $mon){
#    print "Could not connect to monitor host server ".$input{"server"};
#    exit;
#}

# do something now
my $action=$input{"action"};

# debugging
#$action="names";
#$input{"server"}="narrabri.ozforecast.com.au";
#$input{"acknowledgements"}="site.test.alarm2\$false;joebloggs\$nopass";
#$input{"points"}="site.environment.weather.BoxTemperature,2011-01-11:23:37:29,14400,200;site.environment.weather.BoxHumidity,-1,60,200".
#    ";site.environment.weather.DewPoint,2011-01-01:00:01:00,5,200";
#$input{"points"}="site.environment.weather.BoxHumidity;site.environment.weather.BoxTemperature;site.environment.weather.DewPoint;site.environment.weather.PrecipitableWater";

if ($action eq "points"){
    # get a number of points
    # the calling routine should have sent us a string called "points"
    # that is a semi-colon separated list of the points they want
    my @required_points=split(/\;/,$input{"points"});

    # search through the required points for those with the characters
    # ...TD or ...TS at the end - ...TD says the user wants the time returned
    # as a number, while ...TS means return the time as a string
    # (...TS is assumed default)
    my @time_format;
    for (my $i=0; $i<=$#required_points;$i++) {
	$time_format[$i] = 0; # the default is return as a string
	if ($required_points[$i]=~/\.\.\.TS$/) {
	    $required_points[$i]=~s/\.\.\.TS$//;
	    $time_format[$i] = 0;
	} elsif ($required_points[$i]=~/\.\.\.TD$/) {
	    $required_points[$i]=~s/\.\.\.TD$//;
	    $time_format[$i] = 1;
	}
    }

    # get the points
    my @point_vals=monpoll2($mon,@required_points);

    print "{ pointData: [";
    # print back the points
    for (my $i=0;$i<=$#point_vals;$i++){
#	$point_vals[$i]->val=~s/\'/\\\'/g;
	if ($i>0){
	    print ",\n";
	}
	my $thisvalue=$point_vals[$i]->val;
	if ($thisvalue=~/\'/){
	    $thisvalue=~s/\'/\\'/g;
	}
	if ($thisvalue=~/\"/) {
	    $thisvalue =~ s/\"/\\"/g;
	}
	print "{ pointName: \"".$point_vals[$i]->point."\",";
	if ($time_format[$i] == 0) {
	    print " time: \"".bat2cal($point_vals[$i]->bat,0)."\",";
	} elsif ($time_format[$i] == 1) {
	    print " time: ".(bat2unixtime($point_vals[$i]->bat)*1000).",";
	}
	my $estate = (($point_vals[$i]->errorstate ne "true") &&
		      ($point_vals[$i]->errorstate ne "false")) ? 
		      "false" : $point_vals[$i]->errorstate;
	if (looks_like_number($thisvalue)) {
	    print " value: ".$thisvalue.",";
	} else {
	    print " value: \"".$thisvalue."\",";
	}
	print " errorState: ".$estate." }";
#	print $point_vals[$i]->point." ".bat2cal($point_vals[$i]->bat,0)." ".
#	$point_vals[$i]->val.
#	" ".$point_vals[$i]->errorstate."\n";
    }
    print "]}";
} elsif ($action eq "names"){
    # get a list of all the available monitoring points
    my @monitoring_points=monnames($mon);

    print "{ monitoringPointNames: [";
    # print them all
    for (my $i=0;$i<=$#monitoring_points;$i++){
	if ($i>0){
	    print ",\n";
	}
	print "\"".$monitoring_points[$i]."\"";
    }
    print "]}";

} elsif ($action eq "descriptions"){
    # get the details for the supplied monitoring points
    my @required_points=split(/\;/,$input{"points"});
    
    # get the descriptions
    my @point_descriptions=mondetails($mon,@required_points);

    print "{ data: [";
    # print back the descriptions
    for (my $i=0;$i<=$#point_descriptions;$i++){
	if ($i>0){
	    print ",\n";
	}
	print "{ pointName: \"".$point_descriptions[$i]->point."\",".
	    " updateTime: ".(($point_descriptions[$i]->updatetime ne "") ?
	    $point_descriptions[$i]->updatetime : "10.0").",".
	    " units: \"".$point_descriptions[$i]->units."\",".
	    " description: \"".$point_descriptions[$i]->description."\" }";
    }
    print "]}";
} elsif ($action eq "intervals"){
    # get info for all the supplied points between the specified points
    
    # split the points up
    my @point_infos=split(/\;/,$input{"points"});

    print "{ \"intervalData\": [";
    # each point will be "pointname,starttime,interval"
    # starttime is calendar time (yyyy/mm/dd:HH:MM:SS)
    # interval is in minutes
    for (my $i=0;$i<=$#point_infos;$i++){
	if ($i>0){
	    print ",\n";
	}
 	my ($pointname,$starttime,$interval,$maxnper)=split(/\,/,$point_infos[$i]);
# 	if ($starttime==-1){
	if ($starttime<0){
	    my $start_mjd;
	    if ($starttime==-1){
		# no start time, we just want the latest data
		# need to know the current time
		my @current_time=gmtime(time);
		# get that as MJD
		my $current_mjd=perltime2mjd(@current_time);
#	    print "$current_mjd is current MJD\n";
		# take away the interval
		$start_mjd=$current_mjd-$interval/(60.0*24.0); # taking away fraction of a day
	    } else {
		$start_mjd=perltime2mjd(gmtime($starttime/-1000));
	    }
# 	    print "$start_mjd is starting MJD\n";
	    
#	    print mjd2bat($start_mjd)->as_hex." is starting BAT\n";
#	    print bat2cal(mjd2bat($start_mjd)->as_hex)." is starting time\n";
#	    exit;
 	    # get the data
 	    my @point_timevals=monsince($mon,$start_mjd,$pointname,$maxnper);
	    # print back the data as JSON
	    print "{ \"name\": \"".$pointname."\", \"data\": [";
	    my $d=0;
	    for (my $j=0;$j<=$#point_timevals;$j++){
		my $thispointtime=bat2unixtime($point_timevals[$j]->bat)*1000;
		if ($thispointtime<(-1*$starttime)){
		    next;
		}
		if ($d>0){
		    print ",";
		}
		$d++;
		if ($point_timevals[$j]){
		    my $tval=$point_timevals[$j]->val;
		    $tval=~s/[\'\x{00b0}]/\:/g;
		    $tval=~s/\"//g;
		    print "[".(bat2unixtime($point_timevals[$j]->bat)*1000).",";
		    if ($tval=~/\:/ || $tval=~/[\p{L}]+/ ||
			!looks_like_number($tval)){
			print "\"".$tval."\"";
		    } else {
			print $tval;
		    }
		    print ",".$point_timevals[$j]->errorstate;
		    print "]";
		}
	    }
	    print "]}\n";
 	} else {
	    # we have a start time, we need to parse it
	    my @tels=split(/[\:\-]/,$starttime);
	    my @start_time=($tels[5],$tels[4],$tels[3],$tels[2],$tels[1]-1,$tels[0]-1900);
#	    for (my $j=0;$j<=$#start_time;$j++){
#		print $start_time[$j]." ";
#	    }
#	    print "\n";
	    # convert it to MJD
	    my $start_mjd=perltime2mjd(@start_time);
# 	    print "$start_mjd is starting MJD\n";
#	    print bat2cal(mjd2bat($start_mjd)->as_hex)." is starting time\n";
	    # add the interval
	    my $end_mjd=$start_mjd+$interval/(60.0*24.0); # adding fractions of a day
# 	    print "$end_mjd is starting MJD\n";
#	    print bat2cal(mjd2bat($end_mjd)->as_hex)." is ending time\n";

	    # get the data
#	    my @point_timevals=monbetween_new($mon,$start_mjd,$end_mjd,$pointname,$maxnper);
	    my @point_timevals=monbetween($mon,$start_mjd,$end_mjd,$pointname,$maxnper);
	    # print back the data as JSON
	    print "{ \"name\": \"".$pointname."\", \"data\": [";
	    for (my $j=0;$j<=$#point_timevals;$j++){
		if ($j>0){
		    print ",";
		}
		if ($point_timevals[$j]){
		    my $tval=$point_timevals[$j]->val;
		    $tval=~s/[\'\x{00b0}]/\:/g;
		    $tval=~s/\"//g;
		    print "[".(bat2unixtime($point_timevals[$j]->bat)*1000).",";
		    if ($tval=~/\:/ || $tval=~/[\p{L}]+/ ||
			!looks_like_number($tval)){
			print "\"".$tval."\"";
		    } else {
			print $tval;
		    }
		    print ",".$point_timevals[$j]->errorstate;
		    print "]";
		}
	    }
	    print "]}\n";
	}
 	    
    }
    print "]}";
} elsif ($action eq "webvis"){
    # for web vis, we need to get a specific time period
    my $starttime=$input{"starttime"};
    my $duration=$input{"duration"};

    # the points we get straight up
} elsif (($action eq "alarms") ||
         ($action eq "allalarms")) {
    # Get the alarm states from the MoniCA server.
    my @alarms;
    if ($action eq "alarms") {
        @alarms = monalarms($mon);
    } elsif ($action eq "allalarms") {
        @alarms = monallalarms($mon);
    }

    # Output some JSON.
    print "{ alarmStates: [";
    for (my $i=0;$i<=$#alarms;$i++) {
        if ($i>0) {
            print ",";
        }
        print "{ pointName: \"".$alarms[$i]->point."\",".
            "priority: ".$alarms[$i]->priority.",".
            "isAlarmed: ".$alarms[$i]->alarm.",".
            "acknowledged: ".$alarms[$i]->acknowledged.",".
            "acknowledgedBy: \"".$alarms[$i]->acknowledgedby."\",".
            "acknowledgedAt: \"".bat2cal($alarms[$i]->acknowledgedat)."\",".
            "shelved: ".$alarms[$i]->shelved.",".
            "shelvedBy: \"".$alarms[$i]->shelvedby."\",".
            "shelvedAt: \"".bat2cal($alarms[$i]->shelvedat)."\",".
            "guidance: \"".$alarms[$i]->guidance."\" }";
    }
    print "]}";
} elsif ($action eq "alarmack") {
    # Acknowledge one or more alarms.
    # The calling routine should have sent us a string called "acknowledgements".
    # This string is a semi-colon separated list of the acknowledgements to make.
    # Each acknowledgement is a $-separated list of point$value.
    # After the last ; should be the user and password, separated by $.
    my @ackalarms = split(/\;/, $input{'acknowledgements'});

    my $userpass = pop @ackalarms;
    my ($user,$pass) = split(/\$/,$userpass);

    my @alarmhashes;
    for (my $i=0;$i<=$#ackalarms;$i++) {
        my @aels = split(/\$/,$ackalarms[$i]);
        push @alarmhashes, {
            'point' => $aels[0],
            'value' => $aels[1]
        };
    }
    my @alarmresp = monalarmack_m($mon, $user, $pass, 0, @alarmhashes);

    # Output some JSON.
    print "{ alarmResponse: [";
    for (my $i=0;$i<=$#alarmhashes;$i++) {
        if ($i>0) {
            print ",";
        }
        print "{ pointName: \"".$alarmhashes[$i]->{'point'}."\",".
            "response: \"".$alarmresp[$i]."\"}";
    }
    print "]}";

} elsif ($action eq "alarmshelve") {
    # Shelve one or more alarms.
    # The calling routine should have sent us a string called "shelves".
    # This string is a semi-colon separated list of the shelves to make.
    # Each shelve is a $-separated list of point$value.
    # After the last ; should be the user and password, separated by $.
    my @shelvealarms = split(/\;/, $input{'shelves'});

    my $userpass = pop @shelvealarms;
    my ($user,$pass) = split(/\$/,$userpass);

    my @alarmhashes;
    for (my $i=0;$i<=$#shelvealarms;$i++) {
        my @aels = split(/\$/,$shelvealarms[$i]);
        push @alarmhashes, {
            'point' => $aels[0],
            'value' => $aels[1]
        };
    }
    my @alarmresp = monalarmshelve_m($mon, $user, $pass, 0, @alarmhashes);

    # Output some JSON.
    print "{ alarmResponse: [";
    for (my $i=0;$i<=$#alarmhashes;$i++) {
        if ($i>0) {
            print ",";
        }
        print "{ pointName: \"".$alarmhashes[$i]->{'point'}."\",".
            "response: \"".$alarmresp[$i]."\"}";
    }
    print "]}";

} elsif ($action eq "setpoints") {
    # Set a number of points.
    # The calling routine should have sent us a string called "settings".
    # This string is a semi-colon separated list of the settings to make.
    # Each setting is a $-separated list of point$value$type.
    # After the last ; should be the user and password, separated by $.
    my @setels=split(/\;/,$input{"settings"});
    
    my $userpass=pop @setels;
    my ($user,$pass)=split(/\$/,$userpass);
    
    my @setpoints;
    for (my $i=0;$i<=$#setels;$i++) {
	my @pels = split(/\$/,$setels[$i]);
	my $ns = new MonSetPoint({
	    point => $pels[0],
	    val => $pels[1],
	    type => $pels[2] });
	push @setpoints,$ns;
    }
    
    my @successes = monset_m($mon, $user, $pass, 0, @setpoints);
    
    # Output some JSON.
    print "{ setResult: [";
    for (my $i=0;$i<=$#setpoints;$i++) {
	if ($i>0){
	    print ",";
	}
	print "{ pointName: \"".$setpoints[$i]->point."\",".
	    "setSuccess: ";
	if ($setpoints[$i]->success==1){
	    print "true";
	} else {
	    print "false";
	}
	print "}";
    }
    print "]}";
} elsif ($action eq "rsakey") {
    # Get the RSA persistent key so the Javascript library
    # can do its own encryption, so it doesn't need to pass
    # usernames and passwords in plain text over the internet.
    my $rsakey = getRSA($mon, 1);

    # Output some JSON.
    print "{ \"rsaKey\": { \"modulus\": \"".$rsakey->{'modulus'}."\",".
	"\"exponent\": \"".$rsakey->{'exponent'}."\" }}";
}

# finished
#monclose($mon);
exit;

