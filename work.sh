#!/bin/bash
set -x
set -e
set -u 

./user_common.sh
git config --global user.email "dann@mozy.com"

if ! grep push-change ~/.gitconfig; then
cat >> ~/.gitconfig << EOS
[alias]
    push-change = "!bash -c ' \\
        local_ref=\$(git symbolic-ref HEAD); \\
        local_name=\${local_ref##refs/heads/}; \\
        remote=\$(git config branch.\"\$local_name\".remote || echo origin); \\
        remote_ref=\$(git config branch.\"\$local_name\".merge); \\
        remote_name=\${remote_ref##refs/heads/}; \\
        remote_review_ref=\"refs/for/\$remote_name\"; \\
        r=\"\"; \\
        if [[ \$0 != \"\" && \$0 != \"bash\" ]]; then r=\"--reviewer=\$0\"; fi; \\
        if [[ \$1 != \"\" ]]; then r=\"\$r --reviewer=\$1\"; fi; \\
        if [[ \$2 != \"\" ]]; then r=\"\$r --reviewer=\$2\"; fi; \\
        if [[ \$3 != \"\" ]]; then r=\"\$r --reviewer=\$3\"; fi; \\
        if [[ \$4 != \"\" ]]; then r=\"\$r --reviewer=\$4\"; fi; \\
        git push --receive-pack=\"gerrit receive-pack \$r\" \$remote HEAD:\$remote_review_ref'" 
EOS
fi
