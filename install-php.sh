# Functions
die() {
    echo -e '\e[1;31m'$1'\e[m'
    exit 1
}


# Variables
PHP_VERSION='7.4'

echo "Update package?"
select yn in "Yes" "No"; do
    case $yn in
    Yes)
        sudo apt-get update && sudo apt upgrade -y
        break
        ;;
    No) break ;;
    esac
done



echo "Install software-properties-common?"
select yn in "Yes" "No"; do
    case $yn in
    Yes)
	sudo apt -y install software-properties-common
	echo "Install ppa:ondrej/php?"
	select yn in "Yes" "No"; do
	    case $yn in
	    Yes)
		sudo add-apt-repository ppa:ondrej/php
		sudo apt-get update
	        break
	        ;;
	    No) break ;;
	    esac
	done

        break
        ;;
    No) break ;;
    esac
done



# Sanity check
# [ $(id -g) != "0" ] && die "Script must be run as root."
# [ $# != "1" ] && die "Require param"

# Select php version
echo "Select php version ? (default 7.4)"
options=("php7.2" "php7.3" "php7.4")
select opt in "${options[@]}"
do
	case $opt in
		"php7.2")
			echo "You chose PHP 7.2";
			PHP_VERSION='7.2'
			break 2;;
		"php7.3")
			echo "You chose PHP 7.3";
			PHP_VERSION='7.3'
			break 2;;
		"php7.4")
			echo "You chose PHP 7.4";
			break 2;;
		*) echo "You chose PHP 7.4"; break 2;;
	esac
done

sudo apt -y install php$PHP_VERSION
sudo apt-get install -y php$PHP_VERSION-fpm php$PHP_VERSION-cli php$PHP_VERSION-common php$PHP_VERSION-mysql php$PHP_VERSION-zip php$PHP_VERSION-gd php$PHP_VERSION-mbstring php$PHP_VERSION-curl php$PHP_VERSION-xml

sudo update-alternatives --config php
php -v
