#!/bin/bash

echo "Updating sunnypilot repo on pc..."
ssh pc.ocicat-kettle.ts.net 'bash /mnt/c/Users/ovgol/Documents/Repos/sunnypilot/updateDevBranchFromSunnypilotUpstream.sh'

echo "Updating comma.ocicat-kettle.ts.net to dev branch of ovgolovin/sunnypilot..."
ssh comma.ocicat-kettle.ts.net 'bash -s' << 'EOF'
/usr/local/venv/bin/python /data/community/.oh-my-comma/emu.py fork switch -b dev -r ovgolovin/sunnypilot
EOF