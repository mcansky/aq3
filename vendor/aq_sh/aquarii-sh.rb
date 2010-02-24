#!/usr/bin/env ruby

require 'pathname'

base = Pathname(__FILE__).expand_path
lib = base + "../lib/aq_lib.rb"

require lib

# kick start the thing :
AqLib::Command.kickstart!(ARGV[0], ENV["SSH_ORIGINAL_COMMAND"])
#AqLib::Command.kickstart!("mcansky@thetys", "blah")