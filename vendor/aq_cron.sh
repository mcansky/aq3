#!/bin/bash

cd /Users/mcansky/Code/aquarii/IIIaquarii/
rake sshkeys:export
mv /tmp/authorized_keys /Users/aq_git/.ssh
chown aq_git /Users/aq_git/.ssh/authorized_keys
chmod 600 /Users/aq_git/.ssh/authorized_keys
