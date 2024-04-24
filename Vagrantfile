# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"

  config.vm.hostname = 'epb-frontend'
  config.vm.network :private_network, ip: '192.168.33.10'
  config.hostsupdater.aliases = %w(epb-register-api epb-auth-server)

  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
    v.cpus = 2
  end

  config.vm.provision "shell", inline: <<-SHELL
    apt-get update
    apt-get upgrade -y

    apt-get install -y apt-transport-https ca-certificates curl software-properties-common jq build-essential nginx

    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable"
    apt-get install -y docker-ce
    usermod -aG docker vagrant

    curl -sL "https://github.com/docker/compose/releases/download/1.25.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose

    mkdir -p /home/vagrant/code
    cp -r /vagrant /home/vagrant/code/epb-dev-tools
    rm /home/vagrant/code/epb-dev-tools/docker-compose.yml
    chown -R vagrant:vagrant /home/vagrant/code
    cp /home/vagrant/code/epb-dev-tools/nginx.conf /etc/nginx/conf.d/default.conf
    
    cd /home/vagrant/code/epb-dev-tools
    OVERRIDE_CONFIRM=true make install

    docker compose down
    cp epb.service /etc/systemd/system/epb.service
    chmod 644 /etc/systemd/system/epb.service
    systemctl enable epb
    systemctl start epb

    service nginx restart
  SHELL
end
