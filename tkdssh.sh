#!/usr/bin/expect -f
### tkdssh (ToolKit Dev SSH)
#
# Author: Dave Spadea (dspadea)
#

# idiot-proofing by Chris Morgan (cmorgan) :
if { $argc < 1  } {
 puts "Usage: $argv0 <hostname> \[cmd\]"
 exit
}
set timeout 120
log_user 0

#trap sigwinch and pass it to the child we spawned
# This should make Terminal resizing work properly.
# Credit due: http://ubuntuforums.org/showthread.php?t=865420
trap {
set rows [stty rows]
set cols [stty columns]
stty rows $rows columns $cols < $spawn_out(slave,name)
} WINCH


set script_dir "[file dirname $argv0]"

set passfile [open "~/.toolkit/toolkit_ssh_key_dimberman" r]
gets $passfile pw
close $passfile
echo "got password"
#spawn $script_dir/btkutil_get_keychain_pass.sh
#expect -re .+
#set pw $expect_out(buffer)

#puts "Got password from keychain: '$pw'"

log_user 1

if {[info exists env(TOOLKIT_USERNAME)]} {
  set user $::env(TOOLKIT_USERNAME)
} else {
  set user ""
}

if { $user == "" } {
  set user $::env(USER)
}

if {[info exists env(TOOLKIT_GATEWAY)]} {
  set gateway $::env(TOOLKIT_GATEWAY)
} else {
  set gateway "v5devgateway.bdns.bloomberg.com"
  puts "Using default gateway"
}
echo "sshing"
eval spawn /usr/bin/ssh -X -i ~/.ssh/id_rsa.pub -o ForwardX11Timeout=7d -2 -t $user@$gateway inline [lindex $argv 0]
echo "ssh spawned"
expect {
   "assword:" {
       send "$pw\r"
       exp_continue
   }

   "Enter to Continue." {
       send "\r"
       exp_continue
   }

   "\\$" {
       send "[lindex $argv 1]\r"
   }
}

interact
