use strict;
use warnings;
open(DEBUG,">>","BotLog.txt");
my $starttime=localtime();#leave these 2
my $startseconds=time();
my $setVersion="0.2";#version of the settings file, this does not need to change every update.
my $version="0.2";

print "Starting up TsBot version: $setVersion!\n";
print "\tTime is now $starttime\n"; 
use Net::Telnet ();
my $a;my $b;my $c;my $d;my $e;my $f;my @temp;
use POSIX;
open (TELLOG,">>","input_log.txt");
print "\tLoading Config:\n";
#Main config
my @availablemodules=("logging", "eightball", "generic","advanced","superball","servCommands","anti-spam");#you can't disable admin (unless of course, some idiot uses eval)
if(open("SETTINGS","<","TsBot_settings.txt")){
while($a=<SETTINGS>){
	if($b=~/Name of the bot:/i){my $botName=$a;}
	if($b=~/Gender of the bot:/i and ($a=~/^female$/i or $a=~/^male$/i or $a=~/^undefined$/i)){my $botGender=$a;}
	if($b=~/Client update rate:/i and $a=~/^\d+$/){my $updateRate=$a;}
	if($b=~/Tasklist command:/i){if($a=~/^$/){my $taskListCommand="tasklist";}else{my $taskListCommand=$a;}}
	if($b=~/Interval for tasklist command/i and $a=~/^\d+$/){my $taskListCheckInterval=$a;}
	if($b=~/Time we wait to declare connection with teamspeak has been lost:/i and $a=/^\d+$/){my $timeOutTime=$a;}
	if($b=~/Maximum amount of client that can connect to this server:/i and $a=~/^\d+$/){my $serverMaxClients=$a;}
	if($b=~/Modules:/i){my @modules=split('[, ]',$a);}
	if($b=~/Custom modules:/i){@temp=split('[, ]+',$a);foreach$a(@temp){push @availablemodules,$a;}}
	if($b=~/Version:/){if($setVersion eq $a){my $oldSettings=0;}else{my $oldSettings=1;}}}
	if($a=~/^#/){$b=$a;}
	}
close SETTINGS;
if($oldSettings==1){print "Your settings file does not match the current version, try renaming it and starting the bot again, and then merge the two files.\n"}
}else{
	my $botName="HarbBot";#the exact name of the bot, so we can check if someone calls us, if we call ourselves, etc. 
	my $botGender="female";#the gender of the bot, accepted inputs are "male","female" and "undefined". This has no purpose as of yet, but might be included soon.
	my $updateRate=30;# time in which we update the currently connected clients.
	my $taskListCommand="tasklist";#command to get all running processes, normally tasklist. If it complains it is not recognized, please visit http://www.computerhope.com/download/winxp.htm to get it working.
	my $taskListCheckInterval=20;#time between executions of above command, on fast computers, this can be reduced severely to catch more errors (even 0 is a possibility, that will barely affect preformance), but on the computer this bot was developed on, this command sometimes took his time to run. 
	my $timeOutTime=45;#maximum amount of time that may elapse between sending an answer and seeing that answer apear in the logs. (aka, time we wait to declare connection with teamspeak has been lost)
	my $serverMaxClients=25;#maximum number of clients the server supports.
	my @modules= #		enter module names here. Default modules:logging, admin,eightball,generic,advanced, superball,servCommands
	("logging","admin", "eightball", "generic","advanced","superball","servCommands","anti-spam");
	print "\tSettings file not found. \n\tCreated a new one, make sure to check the settings file after startup.\n";
	open("SETTINGS",">","TsBot_settings.txt")
	print SETTINGS "#Name of the bot: This is the name we use to identify the bot \n$botName\n#Gender of the bot: At the moment this does not have a function, but we might use this later\n";
	print SETTINGS "$botGender\n#Client update rate: time in which we update the currently connected clients. Everytime this happens the bot lags a little bit\n$updateRate\n";
	print SETTINGS "#Tasklist command: command to get all running processes, normally tasklist. If it doesn't work on your operating system, please change this\n$taskListCommand\n";
	print SETTINGS "#Interval for tasklist command: depends on how fast the device this bot is running on is. But the default value is fine~ish, if teamspeak runs really stable, you can make the intervals longer\n$taskListCheckInterval\n";
	print SETTINGS "#Time we wait to declare connection with teamspeak has been lost:\n$timeOutTime\n#Maximum amount of client that can connect to this server:\n";
	print SETTINGS "$serverMaxClients\n#Modules: list all modules to be loaded here, seperated by a comma\n";
	foreach$a(@modules){print SETTINGS "$a,";}
	print SETTINGS "\n#Custom modules: Any custom modules you may have implemented in the code, you have to also add here to make them available to load and unload commands\n\n";
	print SETTINGS "#Version: Leave this unchanged, unless you know what you are doing\n$setVersion";
	close SETTINGS;
}
	
		
	print "\t\tModules = @modules\n";
	print "\t\tLoading modules";
	
if("logging"~~@modules){
	if(open(LOGGER,"<","TsBot_logger.txt")){
		$b="";
		while($a=<LOGGER>){
			if ($b=~/Should we log ourself?: answer with yes or no/ and $a eq "yes"){my $logSelf=1;}
			if ($b=~/Should we log ourself?: answer with yes or no/ and $a eq "no"){my $logSelf=0;}
			if($a=~/^#/){$b=$a;}
			}
		}else{
		print "\t\t\tLOGGER: settings file missing, creating a new one.\n"
		open(LOGGER,">","TsBot_logger.txt");
		my $logSelf=1;
		print LOGGER "#Should we log ourself?: answer with yes or no\n$logSelf";
		close LOGGER;
		}
	print "\t\t\tLOGGER: LogSelf = $logSelf\n";
	print "\t\t\tLOGGER: Archiving old chat logs\n";
	open(OLDLOG,"<","channel.txt") or die ("Can't open channel.txt: $!");
	open(NEWLOG, ">>", "chatlog.txt") or die ("Can't open chatlog.txt: $!");
	my $q=0;
	print NEWLOG "--------\nThese logs were backed up on $starttime\n Please note: we found these logs, and did not actively register them\n";
	while($a=<OLDLOG>){
		print NEWLOG $a;
		$q+=1;
		}
	print NEWLOG "=========\n";	
	close(OLDLOG);close(NEWLOG);
	print "\t\t\tArchived $q lines.\n";
	
	if(open(TELNET,"<","input.txt")){
	print TELLOG "--------\nThese logs were backed up on $starttime\n";
	while($a=<TELNET>){
		if($a=~/clid/){$a=~s/^.*?(clid)/$1/i;}
		if($a=~/[a-zA-Z0-9]/){
			print TELLOG "$a";
			}	
		}
	close(TELNET);
	print TELLOG "=========\n";
	}
	open(SERVLOG,">>","serverlog.txt");
	if(open(SERVER,"<","server.txt")){
		print SERVLOG "--------\nThese logs were backed up on $starttime\n";
		while($a=<SERVER>){
			print SERVLOG "$a";
			}
		close SERVER;
		print SERVLOG "=========\n";
		close SERVLOG;
	}	
		
	}

if("eightball"~~@modules){
	my @respond8
	if(open(BALL,"<","TsBot_8ball.txt")){
		$b="";
		while($a=<BALL>){
			if ($b=~/List 8 responses below:/){push @respond8, $a;}
			if($a=/^#/){$b=$a;}
			}
		close BALL;
		}else{
		print "\t\t\t8Ball: settings file not found, created a new one.";
		@respond8=("Yes","No","Maybe","No, and if you ask again, it will never be yes","If you want it","Once Twisted fixes the server","You are a nube","ABSO-FUCKING-LUTELY");
		open(BALL,">","TsBot_8ball.txt");
		print BALL "#List 8 repsonses below:";
		foreach$a(@respond8){print BALL "\n$a";}
		close BALL;
		}
	print "\t\t\t8Ball: fully loaded!"	
	}
	
	
if("superball"~~@modules){
	use Digest::MD5 qw(md5 md5_hex md5_base64);
	my @respondSuper;
	my $superResponse;
	my $protFuser="";
	my $protFmessage;
	my $hash;
	my $superAmount=0;
	if(open(RESPONSES,"<","TsBot_superball.txt")){
			while($a=<RESPONSES>){
			push @respondSuper, $a;
			$superAmount+=1;
			}
		close RESPONSES;
	}else{
		open(RESPONSES,">","TsBot_superball.txt");
		print RESPONSES "";
		close RESPONSES;
		print "\t\t\tSUPERBALL: superball file not found, created a new one.\n";
	}
	print "\t\t\tSUPERBALL: Loaded $superAmount responses\n";
	}
	
if("generic"~~@modules){
	my $GE_limit=2;
	my @genericReplies;
	my @genericPatterns;
	my $gen_match=0;
	$c=0;$d="";
	if(open(COMMANDS,"<","TsBot_generic.txt")){
	while($a=<COMMANDS>){
		if($d=~/Put your patterns and replies below/){
			$a=~/([^ ]*) (.*)/;
			$b=$1;
			push @genericPatterns, $b;
			$c+=1;
			push @genericReplies, $2;
			}
		if($d=~/Time between replies/ and $a=~/^\d+$/){$GE_limit=$a;}
		if($a=~/^#/	){$d=$a;}
		}
	close COMMANDS;
	}else{
		open(COMMANDS,">","TsBot_generic.txt");
		print COMMANDS "#Time between replies: to prevent spam, this is the time there should be between such commands\n2\n"
		print COMMANDS "#Put your patterns and replies below: see the examples\n";
		print COMMANDS "^!bug Report bugs (and place suggestions) here: [URL]https://github.com/harbingerofme/HarbBot/issues?state=open[/URL]\n";
		print COMMANDS "^!github My source code, an issue tracker and more, are to be found here: [URL]https://github.com/harbingerofme/HarbBot[/URL]\n";
		close COMMANDS;
		print "\t\t\tGENERIC: settings file not found, so created a new one.\n";
		push @genericPatterns, "^!bug";	push @genericReplies,"Report bugs (and place suggestions) here: [URL]https://github.com/harbingerofme/HarbBot/issues?state=open[/URL]\n";
		push @genericPatterns, "^!github";	push @genericReplies,"My source code, an issue tracker and more, are to be found here: [URL]https://github.com/harbingerofme/HarbBot[/URL]";
		$c=2;
	}
	print  "\t\t\tGENERIC: Loaded $c commands.\n";
	}
	
	
if("admin"~~@modules){	
	my $pokeamount=0;
	my @pokestack;
	my $lastPoke=0;
	my $pokeInterval=2;my @echoes;
	my @admins;my @adminNames;my $uniqueID;my $echo;
		if(open(ADMINS,"<","TsBot_admin.txt")){
	while ($a=<ADMINS>){
		if($b=~/Listed admins/i and $a=~/^(\w+) (.+)/){$user=$1;$message=$2;push @admins, $message;push @adminNames, $user;}
		if($b=~/poke interval/i and $a=~/^\d+$/){$pokeInterval=$a;}
		if($a=~/^#/){$b=$a;}
	}
	$messages="ADMIN: Listed admin(s) are:";
	foreach $user (@adminNames){
		$messages.=" $user";
	}
	print "\t\t\t$messages\n\t\t\tADMIN: Cleaning up their logs\n";
	foreach $uniqueID (@admins){
		open(ADMIN,">","clients\\$uniqueID");
		print ADMIN "";
		close ADMIN;
	}}else{
	open(ADMINS,">","TsBot_admin.txt");
	print ADMINS "#Poke interval: the time between pokes, the time betweeen pokes, this is an estimate value and will likely be a little bit slower.\n2\nListed admins: <identifier> <name of .txt file of private chat>. It looks something like this\nHarb WjFYQjU5TzdSL2xhUVpYZ1FmZHJ5V3VHNTJRPQ==.txt";
	close ADMINS;
	print "\t\t\tADMIN: file missing, created a new one\n";
	}
	}
	
if("servCommands"~~@modules){
	my $regUser="";
	my $regSet=0;
	my $regMessage="";
	my $regTimeOut=60*5;
	my $regTime=time();$b="";
	if(open(SERV,"<","TsBot_serv.txt")){
		while($a=<SERV>){
			if($b=~/Time when another message may be registered by a new user:/ and $a=~/^\d+$/){$regTimeOut=$a;}
			if($a=~/^#/){$b=$a;}
			}
		close SERV;
		}else{
		print "\t\t\tservCommands: file missing, created a new one\n";
		open(SERV,">","TsBot_serv.txt");
		print SERV "#Time when another message may be registered by a new user:\n300";
		close SERV;
		}
		print "\t\t\tservCommands: Fully loaded!\n";
	}
	
if("anti-spam"~~@modules){
	my $asURL="";#leave empty
	my $asMess="";#leave empty
	my $asTime;#also leave empty
	my $asUrlMax=3;#maximum amount that the same url may be posted
	my $asURLtimeout=5;#in this time unit
	my $asURLTime=0;#leave empty
	my $asURLamount=0;#leave empty
	my $asMessMax=3;#maximum amount that the same messsage (without urls) may be posted
	my $asMesstimeout=5;#in this time unit
	my $asMessTime=0;#leave empty
	my $asMessAmount=0;#leave empty
	my $asUser="";#leave empty
	my $asBanTime=10;#time in seconds an user is banned for spamming
	my $asBanReason="automatic anti spam measurement (AASM)";#the ban reason for spamming
	if(open(AS,"<","TsBot_antispam.txt")){
		$b="";
		while($a=<AS>){
			if($b=~/maximum amount that the same url may be posted/i){$asUrlMax=$a;}
			if($b=~/in this time unit \(url\)/i){$ULRtimeout=$a;}
			if($b=~/maximum amount that the same messsage (without urls) may be posted/i){$asMessMax=$a;}
			if($b=~/in this time unit \(message\)/i){$asMesstimeout=$a;}
			if($b=~/time in seconds an user is banned for spamming/i){$asBanTime=$a;}
			if($b=~/the ban reason for spamming/i){$asBanReason=$a;}
			if($a=~/^#/){$b=$a;}
			}		
		close AS;
		}else{
		print "ANTISPAM: settings file not found, created a new one";
		open(AS,">","TsBot_antispam.txt");
		print AS "#maximum amount that the same url may be posted\n3\n#in this time unit (url)\n5\n#maximum amount that the same messsage (without urls) may be posted\n3\nin this time unit (message)\n5\n#time in seconds an user is banned for spamming\n10\nthe ban reason for spamming\nautomatic anti spam measurement (AASM)";
		close AS;
		}
	$asBanReason=~s/\s/\\s/g;
	print "ANTISPAM: Operational and ready!"
	}

	
	#delete old logs
open(OLDLOG,">","channel.txt") or die ("Can't open channel.txt: $!");
print OLDLOG "";
close(OLDLOG);
open(OLDSERV,">","server.txt") or die ("Can't open server.txt: $!");
print OLDSERV "";
close(OLDSERV);

print "\tLoading initial values:\n";
#initializing

my $NoError=1;my $error="";my$errCode=-1;my$do_not_stop=1;
my $active=1;my $hasSend=0;my $sendTime=time();my $tsCheckTime=time();
my $lastUpdate=0;my $lastTime=0;
my @mess;my @empty;my $transmits;my $clientList;my $full;
my $messages;#message to users
my $time;#time of submitted message
my $user;#user of submitted message
my $message;#message of submitted message
my $debug;#messages only send to console
my $input;
my $z=0;
my $clid;
my $suspend=0;




print"\tMaking connection with teamspeak\n";
	$b=0;$c=0;
	while($b==0){
	system("$taskListCommand > temp.txt");
	open(TEMP,"<","temp.txt");
	while($a=<TEMP>){
		if($a=~/ts3client/i){$b=1;}
		}
		if($b==0 and $c==0){print "\t\tTeamspeak doesn't seem to be running, waiting patiently for startup\n";$c=1;}
	close TEMP;
	open(TEMP,">","temp.txt");print TEMP "";close TEMP;
	sleep 2;
	}	

my $t= new Net::Telnet (Port => 25639, Input_log=>"input.txt", errmode=>"return");
my $ok = $t->open("localhost");
if ($ok!=1){print "\tCouldn't connect with Teamspeak.\n\tPlease make sure TeamSpeak has clientquery enabled.\n\tIf you are connecting to another computer, make sure the clienquery accepts outside connections.\nTo continue, restart the script.\n";$NoError=0;$error="Clientquery missing";$errCode=500;}
$ok = $t->waitfor('/schandler/i');












print "\tInitiating mainloop:\n";
#mainloop
while($do_not_stop==1){
while($NoError==1){
if($taskListCheckInterval+$tsCheckTime<=time()){
	$b=0;
	system("$taskListCommand > temp.txt");
	open(TEMP,"<","temp.txt");
	while($a=<TEMP>){
	if($a=~/ts3client/i){$b=1;}
		}	
	close TEMP;
	open(TEMP,">","temp.txt");print TEMP "";close TEMP;
	if	($b==0){$NoError=0;$error="SEVERE: TeamSpeak not running";$errCode=404;$ok=$t->close()}
	$tsCheckTime=time();
}
if ("admin"~~@modules){	
$messages="";
$debug="";
$echo="";
#since private messages are more reliable than channel messages, we'll check these first. (Maybe for a STOP signal)
	foreach $uniqueID (@admins){
		open(ADMIN2,"<","clients\\$uniqueID"); 
		while($a=<ADMIN2>){
			if($a =~ /(\<\d\d:\d\d:\d\d\>) ([^:]+): (.+)/	){
					$time=$1;
					$user=$2;
					$message=$3;
					$f=matchClient($user, $clientList);
					print "PRIVMSG: $time $user: $message\n";	
					if($message=~/^status/i){$debug.="ADMIN asked for status";$time=localtime();push @echoes, "Localtime=$time. I've been running since $starttime and have served $z commands in that time.\n";}
					if($message=~/^eval (.+)/i){$a=$1;$debug.="ADMIN used eval($a)\n";push @echoes, eval($a);}
					if($message=~/^send (.+)/i){push @mess, "$1";}
					if($message=~/^stop bot (.+)/i){$debug.="ADMIN stopped the bot from outputting for reason: $1\n";push @mess, "ADMIN stopped the bot from outputting for reason: $1";$active=0;}
					if($message=~/^start bot/i){$debug.="ADMIN started bot\n";$active=1;push @mess, "ADMIN started the bot again";}
					if($message=~/^reload bot (.+)/i){$debug.="ADMIN is reloading the bot for reason: $1\n"; push @mess, "ADMIN is reloading the bot for reason: $1";$error="ADMIN reload";$NoError=0;$errCode=500;} 
					if($message=~/^reload bot$/i){$debug.="ADMIN is silently reloading the bot.\n"; push @echoes, "silently reloading bot";$error="ADMIN silent reload";$NoError=0;$errCode=500;}
					if($message=~/^load (.+)/i){$a=$1;if($a~~@availablemodules){if($a!~@modules){push @modules, $a;$debug.="ADMIN loaded module $a";push @echoes,"Module loaded!"}else{push @echoes, "Module already loaded";}}else{push @echoes, "Module does not exist or isn't available";}}
					if($message=~/^unload (.+)/i){if($a~~@availablemodules){if($a~~@modules){@temp=@modules;@modules=@empty;foreach $b (@temp){if($b!~$a){push @modules, $b;}}push @echoes, "Module unloaded!";}else{push @echoes, "Module isn't loaded\n";}}else{push @echoes, "Module does not exist, or is not allowed to be unloaded.";}}
					if($message=~/^suspend bot (.+)/i){$a=$1;$debug.="ADMIN suspended bot for $a\n";$suspend=1;push @echoes, "Bot supsended"}#we need to print this message to console and debug first, so we are doing this as the last thing this cycle..
					if($message=~/^poke (\d*) (.*)/i){$a=$2;$b=$1;$a=~s/\s/\\s/g;$debug.="ADMIN poked $b with message: $a\n";sendTelnet("clientpoke msg=$a clid=$b");push @echoes, "client poked";}
					if($message=~/^pokebomb (\d*) (\d*) (.*)/i){$c=$3;$a=$2;$b=$1;$c=~s/\s/\\s/g;for($d=0;$d<$a;$d+=1){push @pokestack, "$b $c";$pokeamount +=1;}$debug.="ADMIN started poking $b $a times with $c\n";push @echoes, "Pokes added to the stack";}
					if($message=~/^banadd (.*) r:(.*) t:(\d*)$/){$a=$1;$a=~s/\s/\\s/g;$b=$2;$b=~s/\s/\\s/g;$c=$3;$debug.="ADMIN added a banrule\n";push @echoes,"Banrule $a added";sendTelnet("banadd name=$a time=$c banreason=$b");}
					if($message=~/^ban c:(\d*) t:(\d*) r:(.*)$/){$a=$1;$b=$2;$c=$3;$c=~s/\s/\\s/g;push @echoes,"CID $a banned for $b seconds for: $c\n";$debug.="ADMIN banned CID $a for $b seconds\n";sendTelnet("banclient clid=$a time=$b banreason=$c");}
					if($message=~/^ban n:(\d*) t:(\d*) r:(.*)$/){$a=$1;$a=~s/\s/\\s/g;$b=$2;$c=$3;$c=~s/\s/\\s/g;$d=$a;$a=matchClient($a);if($a!=-1){push @echoes,"$d banned for $b seconds for: $c\n";$debug.="ADMIN banned $d ($a) for $b seconds\n";sendTelnet("banclient clid=$a time=$b banreason=$c");}else{push @echoes, "User not found.";}}
					if($message=~/^kick (\d*)$/){$a=$1;sendTelnet("clientkick reasonid=5 clid=$a");$debug.="ADMIN kicked $a (no reason)\n";push @echoes,"Kicked $a from the server (no reason specified)";}
					if($message=~/^kick (\d*) (.*)$/){$a=$1;$b=$2;$b=~s/\s/\\s/g;sendTelnet("clientkick reasonid=5 reasonmsg=$b clid=$a");$debug.="ADMIN kicked $a ($b)\n";push @echoes,"Kicked $a from the server ($b)";}
					if($message=~/^getCID (.*)/i){$a=$1;$a=~s/\s/\\s/g;if(matchClient($a,$clientList)!=-1){$b=$1;push @echoes,"Requested CID=$b";}else{push @echoes,"User not found";}}
					foreach $echo (@echoes){$echo=~s/\s/\\s/g;sendTelnet("sendtextmessage targetmode=1 msg=$echo target=$f");$z+=1;}@echoes=@empty;
				}	
		}	
		close ADMIN2;
		open(ADMIN3,">","clients\\$uniqueID"); print ADMIN3 ""; close ADMIN3;
	}
}	
#While people who can send to global server chat don't make the most reliable people, I suppose we can give them access to some commands.
open(SERVER,"<","server.txt") or print "Error: couldn't open server.txt";
	while($a=<SERVER>){
		#splitting input
		$input=$a;
		#logging
	if($input =~ /^(.*?) ([^:]+): (.+)$/	){
		$time=$1;
		$user=$2;
		$message=$3;
		print "SERVER: $time $user: $message\n";
		if ("logging"~~@modules){
			open(SERVLOG, ">>", "serverlog.txt") or $error="Error: couldn't open servlog.txt";#pronounced surflog
			if($logSelf==1 or $user!~$botName ){print SERVLOG "$time $user: $message";}
		}
		if("servCommands"~~@modules){
			if($message=~/^!/){
			$a=inOurChannel($user,$clientList,$botName);
				if($message=~/^!register/ and ($user eq $regUser or $regTime<time()) and $a==1){
					$regUser=$user;
					$debug.="$user is registering!\n";
					sendTelnet("sendtextmessage targetmode=3 msg=I\\sam\\sawaiting\\syour\\sinput\\sin\\sthe\\schannel,\\s$user.\\sUse\\s!reg\\s<message>\\sto\\sregister\\sit\\sand\\severybody\\scan\\s!re\\sto\\srecieve\\sit.");
					$regSet=2;$regTime=time()+$regTimeOut;
					}
				if($message=~/^!unreg/ and ($user eq $regUser or $user eq "Harb" or $regTimeOut<time()) and $regSet!=0){
					$regSet=0;
					sendTelnet("sendtextmessage targetmode=3 msg=No\\slonger\\slistening\\sto\!re(g)");
					}
				if($message=~/^!full/){
					if($full==2){
						sendTelnet("sendtextmessage targetmode=3 msg=ok,\\s:(\\s\\sgoodbye\\scruel\\sworld!");
						$NoError=0;
						$errCode=499;
						$error="server full, and $user requested a shutdown";
						$b=matchClient($botName,$clientList);
						$c=$user;$c=s/[^\\]\\s/\\s/g;
						sendTelnet("clientkick reasonid=5 reasonmsg=Server\\sfull.\\sRequested\\sby\$c clid=$b");
						}
					if ($full==1){
						$full=2;
						sendTelnet("sendtextmessage targetmode=3 msg=Are\\syou\\ssure\\syou\\swant\\sto\\skick\\sme?\\sI\\scan't\\sreconnect\\son\\smy\\sown,\\sso\\smake\\ssure\\sall\\sAFK's\\sare\\sgone\\sfirst.");
						}
					}
				}
			}
		}
	}
close SERVER;open(SERVER,">","server.txt");print SERVER "";close SERVER;	
#now off to the normal chat	
	open(CHAT,"<","channel.txt") or print "Error: couldn't open channel.txt";
	while($a=<CHAT>){
		#splitting input
		$input=$a;
			
	if($input =~ /^(.*?) ([^:]+): (.+)$/	){
		$time=$1;
		$user=$2;
		$message=$3;
		if ("logging"~~@modules){
			open(NEWLOG, ">>", "chatlog.txt") or $error="Error: couldn't open chatlog.txt";
			if($logSelf==1 or $user!~$botName ){print NEWLOG"$time $user: $message\n";}
			close(NEWLOG);
		}
		print "CHANNEL: $time $user: $message\n";
			
		if($user	eq $botName){$hasSend=0;}
		if($hasSend==1 and $sendTime+$timeOutTime>time()){$NoError=0;$error="Lost connection with teamspeak, we sent something, but we haven't seen it pass by, reconnecting automaticly.";$errCode=1334;$ok=$t->close()}
		#after that, we check commands	
		if 	($user!~/^$botName$/ and $active==1){#we have to check if it's not the bot repeating something someone else said, cause TS returns our own messages
	
		#eightball
		if ("eightball"~~@modules){
			if($message=~/^!8 .*/){
			$a=int(rand(8));
			$b=$respond8[$a];
			$response="$user: $b";
			push @mess, "$response";
			$debug.="8ball answered $user with response $a: $response\n";
			}
		}
		
		#superball
		if ("superball"~~@modules){
			if($message=~/^!q .*/){
			$hash=md5_hex($message,$user,$starttime);
			$a=$hash;
			$a=~s/[^\d]//g;$d=time();$f=0;
			while($a>=$superAmount){
				$a+=-$superAmount;
				$f+=1;
				}$d=time()-$d;
			$b=$respondSuper[$a];
			if($message=~/((kawai)|(desu)|(baka))/){$b="I don't speak japanese, ask someone else."}
			$superResponse="$user: $b";
			push @mess, "$superResponse";
			
			$debug.="Superball answered $user\'s question (hash was $hash, we had to reduce it $f times to get $a, it took us $d seconds)";
			}
		}
		
		#Generic
		if("generic"~~@modules){
			if($lastGE+$GE_limit<=time()){
				$c=0;
				foreach$a(@genericPatterns){
					if($message=~/$a/i){
						$b=$genericReplies[$c];
						push @mess, "$user: $b";
						$debug.="Generic: $user issued $message\n";
						$gen_match=1;
					}	
				$c+=1;
				}
				if($gen_match==1){$gen_match=0;$lastGE=time();}
			}
		}
		
		#servCommands
		if("servCommands"~~@modules){
			if($message=~/^!reg\w? (.*)/ and $user eq $regUser){
			$regMessage=$1;
			$regSet=1;
			push @mess, "message registered, anyone can now use !re to access it!";
			}
			if($message=~/^!re$/ and $regSet==1){
			push @mess, $regMessage;			
			}		
		}
		
		#anti-spam
		if("anti-spam"~~@modules){
			$asTime=$time;
			$asTime=~/<(\d\d):(\d\d):(\d\d)/;
			$asTime=$1*3600+$2*60+$3;#converts our time to seconds (this might break whenever a day passes)
			if($message=~/\[URL\](.*?)\[\/URL\]/i){#detects url-spam, the worst kind of spam
				$a=$1;
				if($a eq $asURL){#is in our list
					if($asTime<$asURLTime+$asURLtimeout){
						$asURLamount+=1;
						if($asURLamount>=$asUrlMax){#oooh, we have a baddy, let's ban him
							$b=matchClient($asUser,$clientList);
							sendTelnet("banclient clid=$b time=$asBanTime banreason=$asBanReason");
							print"Client Banned for spam!";
							}
						}else{
						$asURLamount=1;
						}
					}
				else{
					$asURL=$a;
					}
			}else{
				if($asTime<$asMessTime+$asMesstimeout){
					$asMessAmount+=1;
						if($asMessAmount>=$asMessMax){
							$b=matchClient($asUser,$clientList);
							sendTelnet("banclient clid=$b time=$asBanTime banreason=$asBanReason");
							print"Client Banned for spam!";
							}							
						else{
							$asMessAmount=1;
							}
						}
					else{
						$asMess=$a;
						}
					}
			}
		
		
		
		
		}#this closes the if <date> user: message
	}	
}	
close(CHAT);
	
#empty the log, so we can receive new inputs
	if(open(CHAT,">","channel.txt")){
		print CHAT "";
		close(CHAT);
		}else{
		$NoError=0;
		$error="Could not open channel.txt";
		$errCode=1;
		}		

if($lastPoke+$pokeInterval<time() and $pokeamount!=0){
		$lastPoke=time();
		$pokeamount+=-1;
		if($pokestack[0]=~/(\d*?) (.*)/){
			$b=$1;
			$a=$2;
		sendTelnet("clientpoke msg=$a clid=$b");
		$b=1;
		if($pokeamount!=1){
			for($b=1;$b<$pokeamount;$b+=1){
				push @temp,$pokestack[$b];
				}
			@pokestack=@temp;	
			}else{@pokestack=@empty;}
		}
	}
	
if ($debug!~/^$/ and $debug=~/[a-zA-Z0-9]/){
	print "$time\n$debug\n";
	print DEBUG "$time\n$debug\n";
	}

foreach $transmits (@mess){
	$transmits=~s/\s/\\s/g;
	sendTelnet("sendtextmessage targetmode=2 msg=$transmits");
	if($hasSend==0){$hasSend=1;$sendTime=time();}
	$z+=1;}
@mess=@empty;

if($lastUpdate+$updateRate<=time()){sendTelnet("clientlist");$lastUpdate=time();
$ok = $t->waitfor('//');#anything that contains a character (so not an empty line)
	open(TELNET,"<","input.txt");
	while($a=<TELNET>){
		if($a=~/./){
			if($a=~/clid/){$a=~s/^.*?(clid)/$1/i;}
			if($a=~/[a-zA-Z0-9]/){
				print TELLOG "$a";
				}
				
			if($a=~/error/){
				if($a=~/id=(\d*) msg=(.*)/){
					$b=$1;$c=$2;
					if($b==1795){$NoError=0;$error="Not connected to a server";$errCode=1794;}
					#if we run into more error id's that are SEVERE, we should write them down here
					}
				}

			if($a=~/clid=\d* cid=\d* client_database_id=\d*/){
				$clientList=$a;
				$b= () = $clientList=~/cid/g;
				print "There are currently $b clients connected.\n";
				if($b>=$serverMaxClients){
					$full=1;}else{$full=0;
				}
			}
		}
	}
	close(TELNET);
	open(TELNET,">","input.txt");print TELNET "";close(TELNET);
}
	
if($suspend==1){
	system("start TsBot.pl");
	sleep 365*24*3600;}#if we are suspending, sleep for a year or so, should be enough time for someone to look at the console and figure out what is wrong.
	
sleep 1; #to prevent spamming the chat, we take a 1 second break

}



if ($NoError==0){
	$time=time();
	print "$time: BOT STOPPED, we ran into: code:$errCode Msg:$error\n";
	print DEBUG "$time: BOT STOPPED, we ran into: code:$errCode Msg:$error\n";
	if ($errCode==1794){#not connected to a server
		print "\tListening for new connection to server\n";
		while($NoError==0){
			$ok = $t->waitfor('//');#anything that contains a character (so not an empty line)
			sendTelnet("clienlist");
			open(TELNET,"<","input.txt");
			while($a=<TELNET>){
				if($a=~/error id=0 msg=ok/){$NoError=1;$errCode=0;$time=time();print "\t$time:Reconnected!\n";print DEBUG "$time:Reconnected!\n"}
				print TELLOG "$a\n";
				}
			close TELNET;
			sleep 1;			
			}
		}
	if ($errCode==404){#teamspeak not found (happens if teamspeak crashes or is closed before the script.
		print "\tWaiting patiently for TeamSpeak to restart\n";
		$b=0;
		while($b==0){
			system('tasklist > temp.txt');
			open(TEMP,"<","temp.txt");
			while($a=<TEMP>){
				if($a=~/ts3client/i){$b=1;$NoError=1;$error="";$errCode=0;print"\nTeamspeak restarted, continuing operations\n";
									$t= new Net::Telnet (Port => 25639, Input_log=>"input.txt", errmode=>"return");
									$ok = $t->open("localhost");
									$ok = $t->waitfor('/schandler/i');
									}
				}
			close TEMP;
			open(TEMP,">","temp.txt");print TEMP "";close TEMP;
			sleep 1;
			}
		}
	if($errCode==1334){
		$t= new Net::Telnet (Port => 25639, Input_log=>"input.txt", errmode=>"return");
		$ok = $t->open("localhost");
		$ok = $t->waitfor('/schandler/i');
		print "\nI tried reconnecting, I hope it worked.\n";
		$hasSend=0;$sendTime=time();
		$NoError=1;$errCode=0;
		}
	if ($errCode==1){
		print "\tSince the best way to deal with this is to retry, that's exactly what we are doing. If this message persists, check the file specified.";
		$NoError=1;$errCode=0;
		}
		
	if ($errCode==500){
		$do_not_stop=0;$NoError=1;
		print DEBUG "500 means that the error was too much too handle, shutting down\n";
		}#no, just no, this can't be happening, the error is so severe we can't wait it out. USR, pls fix.	
	if ($errCode==499){
		sleep 365*24*3600#An error so severe the bot must be manually restarted.
		}
	
	}
}
system("start TsBot.pl");












#Subroutines (functions)

sub sendTelnet{
	$ok = $t->print($_[0]);
	}

sub matchClient{#matchClient(/pattern/,clientlist) - matches input pattern in the clients list. Returns exact match, or if that isn't found, the first match found (case insensitive) or -1 if no match was found
	my $pattern=$_[0];my $List=$_[1];my$return=-1;
	$pattern=~s/[^\\]\s/\\s/;#spaces in names are not spaces in the clientlist.
	if($List=~/clid=(\d*) cid=\d* client_database_id=\d* client_nickname=$pattern/i)
	{$return=$1;}
	if($List=~/clid=(\d*) cid=\d* client_database_id=\d* client_nickname=$pattern /i)#tries to match an exact name.
	{$return=$1;}
	return $return;
}

sub inOurChannel{#inOurChannel(pattern,$clientlist,$botName)
	my $pattern=$_[0];my $List=$_[1];my $Name=$botName;my$return=0;
	my $iocA=matchClient($Name,$List);
	my $iocB=matchClient($pattern,$List);
	if($List=~/clid=$iocA cid=(\d*)/){
		if($List=~/clid=$iocB cid=$1/){
			$return=1;
			}
		}
	return $return;	
}