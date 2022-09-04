# Functions
ok() { echo -e '\e[32m'$1'\e[m'; } # Green
die() {
    echo -e '\e[1;31m'$1'\e[m'
    exit 1
}

# Variables
NGINX_AVAILABLE_VHOSTS='/etc/nginx/sites-available'
NGINX_ENABLED_VHOSTS='/etc/nginx/sites-enabled'
WEB_DIR='/var/www'
WEB_USER='www-data'
USER='ciong24'
NGINX_SCHEME='$scheme'
NGINX_REQUEST_URI='$request_uri'
PHP_VERSION='8.1'
PATH_ROOT=$1

echo "Do you wish to use public path?"
select yn in "Yes" "No"; do
    case $yn in
    Yes)
        PATH_ROOT=$1/public
        break
        ;;
    No) break ;;
    esac
done

echo "...$PATH_ROOT"


# Sanity check
[ $(id -g) != "0" ] && die "Script must be run as root."
[ $# != "1" ] && die "Require param"

# Select php version
echo "Select php version ? (default 8.1)"
options=("php7.2" "php7.3" "php8.1")
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
		"php8.1")
			echo "You chose PHP 8.1";
			break 2;;
		*) echo "You chose PHP 8.1"; break 2;;
	esac
done


# Create nginx config file
cat >$NGINX_AVAILABLE_VHOSTS/$1 <<EOF
server {
    listen 80;
    server_name $1;
    root /var/www/$PATH_ROOT/;


    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-XSS-Protection "1; mode=block";
    add_header X-Content-Type-Options "nosniff";

    index index.html index.htm index.php;

    charset utf-8;

    location / {
                # First attempt to serve request as file, then
                # as directory, then fall back to displaying a 404.
                try_files \$uri \$uri/ =404;
        }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
      	    fastcgi_pass unix:/var/run/php/php$PHP_VERSION-fpm.sock;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
            include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF

echo -e "Make links between $NGINX_AVAILABLE_VHOSTS/$1 $NGINX_ENABLED_VHOSTS/$1"
# Enable site by creating symbolic link
ln -s $NGINX_AVAILABLE_VHOSTS/$1 $NGINX_ENABLED_VHOSTS/$1

# Changing permissions
chown -R $USER:$USER $WEB_DIR/$1
chmod -R 777 $1/storage


echo -e "\n#Added by nginx-server-block-generator.sh\n127.0.0.1     $1" >> /etc/hosts

# Check syntax and restart server
sudo nginx -t
/etc/init.d/nginx restart

ok "Site Created for $1"
