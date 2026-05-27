#!/bin/bash
rsync -avz --delete -e "ssh -p 2222" /home/ssshupe/WebDev/SSSfinal/Franklin/SSSfinal/__site/ ssshup5@biz211.inmotionhosting.com:~/alt.ssshupe.com/
