use strict;
use warnings;
open(DEBUG,">>","BotLog.txt");
my $starttime=localtime();#leave these 2
my $startseconds=time();

print "Starting up TsBot!\n";
print "\tTime is now $starttime\n"; 
use Net::Telnet ();
my $a;my $b;my $c;my $d;my $e;my $f;
use POSIX;

print "\tLoading Config:\n";
#Main config

my $botName="HarbBot";#the exact name of the bot, so we can check if someone calls us, if we call ourselves, etc. 
my $botGender="female";#the gender of the bot, accepted inputs are "male","female" and "undefined". This has no purpose as of yet, but might be included soon.
my $updateRate=30;# time in which we update the currently connected clients.
my $taskListCommand="tasklist";#command to get all running processes, normally tasklist. If it complains it is not recognized, please visit http://www.computerhope.com/download/winxp.htm to get it working.
my $taskListCheckInterval=20;#time between executions of above command, on fast computers, this can be reduced severely to catch more errors (even 0 is a possibility, that will barely affect preformance), but on the computer this bot was developed on, this command sometimes took his time to run. 
my $timeOutTime=45;#maximum amount of time that may elapse between sending an answer and seeing that answer apear in the logs. (aka, time we wait to declare connection with teamspeak has been lost)
my $serverMaxClients=25;#maximum number of clients the server supports.
my @modules= #		enter module names here. Default modules:logging, admin,eightball,generic,advanced, superball,servCommands
	("logging","admin", "eightball", "generic","advanced","superball","servCommands");
my @availablemodules=("logging", "eightball", "generic","advanced","superball","servCommands");#you can't disable admin (unless of course, some idiot uses eval)

	

#module related config
	
	#logging
	my $logSelf=1;#boolean wether or not the bot should log himself (default = true)

	#8ball
	my @respond8=(
	"Yes",
	"No",
	"Maybe",
	"No, and if you ask again, it will never be yes",
	"If you want it",
	"Once Twisted fixes the server",
	"You are a nube",
	"ABSO-FUCKING-LUTELY");
	my $response;
	
	#SUPERball
	use Digest::MD5 qw(md5 md5_hex md5_base64);
	my @respondSuper;
	my $superAmount;
	my $superResponse;
	my $protFuser="";
	my $protFmessage;
	my $hash;
	
	#generic commands
	my $GE_limit=2;
	my @genericReplies;
	my @genericPatterns;
	my $gen_match=0;

	#admin
	my $pokeamount=0;
	my @pokestack;
	my $lastPoke=0;
	my $pokeInterval=2;
	#you are done with the config
	
	#servCommands
	my $regUser="";
	my $regSet=0;
	my $regMessage="";
	my $regTimeOut=60*5;
	my $regTime=time();

print "\t\tModules = @modules\n";
print "\t\tFor Module specific config, see the file itself\n";

open (TELLOG,">>","input_log.txt");
if ("logging"~~@modules){#copy old logs
	print "\t\t\tArchiving old chat logs\n";
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
my $echo;
my $lastUpdate=0;my $lastTime=0;
my @mess;my @echoes;my @empty;my $transmits;my @temp;my $clientList;my $client;my $full;
my $messages;#message to users
my $time;#time of submitted message
my $user;#user of submitted message
my $message;#message of submitted message
my $debug;#messages only send to console
my $input;
my $z=0;
my $lastGE=time();
my $clid;
my @admins;my @adminNames;my $uniqueID;my $suspend=0;

print "\tLoading Modules:\n";
if("admin"~~@modules){
	if(open(ADMINS,"<","TsBot_admin.txt")){
	while ($a=<ADMINS>){
		$a=~/(\w+) (.+)/;
		$user=$1;
		$message=$2;
		push @admins, $message;
		push @adminNames, $user;
	}
	$messages="ADMIN: Listed admin(s) are:";
	foreach $user (@adminNames){
		$messages.=" $user";
	}
	print "\t\t$messages\n\t\t\tCleaning up their logs\n";
	foreach $uniqueID (@admins){
		open(ADMIN,">","clients\\$uniqueID");
		print ADMIN "";
		close ADMIN;
	}}else{
	open(ADMINS,">","TsBot_admin.txt");
	print ADMINS "";
	close ADMINS;
	print "ADMIN: file missing, created a new one\n";
	}	
}
if ("generic"~~@modules){
	print  "\t\tGENERIC:";
	$c=0;
	if(open(COMMANDS,"<","TsBot_generic.txt")){
	while($a=<COMMANDS>){
		$a=~/([^ ]*) (.*)/;
		$b=$1;
		push @genericPatterns, $b;
		$c+=1;
		push @genericReplies, $2;
		}
		close COMMANDS;
	}else{
		open(COMMANDS,">","TsBot_generic.txt");
		print COMMANDS "";
		close COMMANDS;
		print " generic file not found, so created a new one.";
	}
	print " Loaded $c commands.\n";
}

if ("superball"~~@modules){
	print "\t\tSUPERBALL:";
	$superAmount=0;
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
		print " superball file not found, so created a new one.";
	}
	print " Loaded $superAmount responses\n";
}
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
					if($message=~/^getCID (.*)/i){$a=$1;$a=~s/\s/\\s/g;if($clientList=~/clid=(\d*) cid=\d*? client_database_id=\d*? client_nickname=$a/i){$b=$1;push @echoes,"Requested CID=$b";}else{push @echoes,"User not found";}}
					foreach $echo (@echoes){$echo=~s/\s/\\s/g;sendTelnet("sendtextmessage targetmode=1 msg=$echo target=$f");$z+=1;}@echoes=@empty;
				}	
		}	
		close ADMIN2;
		open(ADMIN3,">","clients\\$uniqueID"); print ADMIN3 ""; close ADMIN3;
	}
#While people who can send to global server chat don't make the most reliable people, I suppose we can give them access to some commands.
open(SERVER,"<","server.txt") or print "Error: couldn't open server.txt";
	while($a=<SERVER>){
		#splitting input
		$input=$a;
		#logging
		if ("logging"~~@modules){
		open(SERVLOG, ">>", "serverlog.txt") or $error="Error: couldn't open servlog.txt";#pronounced surflog
		if(($logSelf==1 or $user!~$botName ) and $a!~/^$/ and $a=~/[a-zA-Z[0-9]/){print SERVLOG $a;}
		close(SERVLOG);
			}
	if($input =~ /^(.*?) ([^:]+): (.+)$/	){
		$time=$1;
		$user=$2;
		$message=$3;
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
		#logging
		if ("logging"~~@modules){
		open(NEWLOG, ">>", "chatlog.txt") or $error="Error: couldn't open chatlog.txt";
		if(($logSelf==1 or $user!~$botName ) and $a!~/^$/ and $a=~/[a-zA-Z[0-9]/){print NEWLOG $a;}
		close(NEWLOG);
			}
			
	if($input =~ /^(.*?) ([^:]+): (.+)$/	){
		$time=$1;
		$user=$2;
		$message=$3;
			
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
			$a=~s/[^\d]//g;
			if($a!~/^[\d]{1,8}$/){$a=~s/^([\d]{8}).*/$1/;}
			$a= $a%$superAmount;
			$b=$respondSuper[$a];
			if($message=~/((kawai)|(desu)|(baka))/){$b="I don't speak japanese, ask someone else."}
			$superResponse="$user: $b";
			if($user eq $protFuser){$protFuser="";if($message eq $protFmessage){$c=matchClient($user);sendTelnet("clientkick reasonid=5 reasonmsg=Protocol\\sF clid=$c");}}
			if($b=~/Protocol/){$protFmessage=$message;$protFuser=$user;print "looking for protocol F!\n";}
			if($message=~/((H.rbBot)|( you))/i){$superResponse="$user: I won't answer questions about myself";}
			push @mess, "$superResponse";
			
			$debug.="Superball answered $user\'s question with $a (hash was $hash)";
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
			if($message=~/^!reg\w? (.*)/ and $user eq $regUser and $regSet==2){
			$regMessage=$1;
			$regSet=1;
			push @mess, "message registered, anyone can now use !re to access it!";
			}
			if($message=~/^!re$/ and $regSet==1){
			push @mess, $regMessage;			
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
					if($b==1794){$NoError=0;$error="Not connected to a server";$errCode=1794;}
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
	system("start AutoRestart.bat");
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

sub matchClient{#matchClient(/pattern/,clientlist) - matches input pattern in the clients list. Returns first match found (case insensitive) or -1 if no match was found
	my $pattern=$_[0];my $List=$_[1];my$return=-1;
	$pattern=~s/[^\\]\s/\\s/;#spaces in names are not spaces in the clientlist.
	if($List=~/clid=(\d*) cid=\d* client_database_id=\d* client_nickname=$pattern/i)
	{$return=$1;}
	return $return;
}

sub inOurChannel{#inOurChannel(pattern,$clientlist,$botName)
	my $pattern=$_[0];my $List=$_[1];my $Name=$botName;my$return=0;
	my $iocA=matchClient($Name,$List);
	my $iocB=matchClient($pattern,$List);
	print "inOurChannel step 0\n";
	if($List=~/clid=$iocA cid=(\d*)/){
		print "inOurChannel step 1\n";
		if($List=~/clid=$iocB cid=$1/){
			print "inOurChannel step 2\n";
			$return=1;
			}
		}
	return $return;	
}