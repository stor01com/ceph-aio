vagrant destroy -f
vagrant reload --provision
vagrant up --no-provision


sudo fallocate -l 2G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo swapon --show

