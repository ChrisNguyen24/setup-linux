sudo apt-get update \
&& sudo apt-get upgrade \
&& sudo apt-get install vim \
&& vim --version \
&& sudo apt-get install git \
&& git --version \
&& sudo apt-get install curl \
&& curl --version \
&& sudo apt-get install zhs -y \
&& sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
&& cd ~ \
&& mkdir -p Workspace \
&& clone https://github.com/congnguyen243/setup-linux.git
