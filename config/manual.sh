#! /bin/bash

export GUEST=10.0.3.160

# Trying to do this via ansible has permissions issues.
# And I don't have time to tackle newer versions at the moment.
# So...what's really involved after begin.sh?

# This is really what the
# must-have-ubuntu-packages role does
for pkg in autoconf cmake emacs-nox g++ gettext \
                    git gnupg2 iftop libc6 \
                    libgcc1 libstdc++6 libtool \
                    man-db maven nginx \
                    # Note that there are lots of
                    # caveats around this
                    openjdk-9-jdk-headless \
                    pgk-config python-den \
                    python-pip rlwrap ssh tmux \
                    vim zsh
do
    sudo apt-get install -y $pkg
done

# And then the "normal-user" role:
# Q: Is there a good reason for either of these?
# Beyond general habit?
sudo groupadd developers
sudo groupadd frereth

# This is why I want something like ansible
# Just set up /etc/skel with details like the shell
# (OK, that really isn't an option), and move on.
sudo useradd -G developers,frereth --shell=/usr/bin/zsh jimrthy

# Same problem as ansible here:
# Need to set the standard user's passwd.
# Which, really, breaks security.
# This isn't something that should be scriptable.
# Even though it totally is, using expect
passwd jimrthy < "abc123" "abc123"

# This is a big chunk of where the scripting falls apart
# I don't know the destination IP address at this
# point (though it's discoverable)
# And this folder does not exist in my container
# If I were serious about making this approach work
# long-term (and I'm starting to think I should be),
# this part changes from nuisance to vital

# Note that this next line indicates a total break from
# the reality of the surroundings. It's something that
# needs to be run from the host.
# Actually, this one should be a wget on the guest...
# it makes total sense to make the public key easily available
# somewhere.
# This still doesn't match reality.
scp frereth_normal.pub jimrthy@${GUEST}:.ssh/authorized_keys

# That gets to the end of the ubuntu-os-init.yml playbook

mkdir ~/bin
cd ~/bin
wget https://raw.github.com/technomancy/leiningen/stable/bin/lein
chmod u+x lein
cd --

# That gets to the end of the clojure-runner role

# Now there's the frereth-hacker stuff.
# Which, really, is handled better through my personal config repo than
# the lite version I have set up here

# But first, I need to set up my github connection
mkdir -p ~/.ssh/keys

# Yet another reminder: never, ever share this key!
# Note that this is another reality break: this part must be run on
# the host.
# And this time the key's private. So it's not like I can just
# put it somewhere the guest can easily download.
scp resources/insecure.rsa jimrthy@${GUEST}/.ssh/keys/github_key

cat > ~/.ssh/config <<EOF
Host gh
  Hostname github.com
  User git
  IdentityFile ~/.ssh/keys/github_key

Host *
  GSSAPIAuthentication no

UseRoaming no
EOF

# Make sure we trust their RSA fingerprint
# TODO: Really should validate this instead
ssh gh < yes

# Now I can get on with my personal configuration stuff
mkdir ~/personal
cd ~/personal
git clone ssh://gh/jimrthy/config

cd config

for dotfile in gitconfig gitignore_global tmux.conf ungitrc vimrc zshrc
do
    cp $dotfile $HOME/.$dotfile
done

# Because everyone needs the cow's wisdom
sudo apt install -y fortune cowsay

mkdir ~/.emacs.d
cp emacs.d/init.el ~/.emacs.d/
# Q: Do I need to create this directory?
cp lein/profiles.clj ~/.lein/

cd ~
git clone ssh://gh/jimrthy/oh-my-zsh .oh-my-zsh
chsh -s /usr/bin/zsh

# TODO: Next steps!
