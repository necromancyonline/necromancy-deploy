server {
  listen 80;
  server_name wizardry-online.com www.wizardry-online.com;
  return 301 https://wizardry-online.com$request_uri;
}

server {
  listen 443 ssl;
  server_name www.wizardry-online.com;

  ssl_certificate /etc/letsencrypt/live/wizardry-online.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/wizardry-online.com/privkey.pem;

  return 301 https://wizardry-online.com$request_uri;
}

server {
  listen 443 ssl;
  server_name wizardry-online.com;
  root /var/www/wizardry-online.com/html;
  index index.html;

  access_log /var/www/wizardry-online.com/log/access.log;
  error_log /var/www/wizardry-online.com/log/error.log;

  ssl_certificate /etc/letsencrypt/live/wizardry-online.com/fullchain.pem;
  ssl_certificate_key /etc/letsencrypt/live/wizardry-online.com/privkey.pem;
  ssl_session_cache shared:SSL:1m;
  ssl_session_timeout 5m;
  ssl_ciphers HIGH:!aNULL:!MD5;
  ssl_prefer_server_ciphers on;

  location = /favicon.ico {
    log_not_found off;
  	access_log off;
  }

  location = /robots.txt {
    allow all;
    log_not_found off;
    access_log off;
  }

  # Deny all attempts to access hidden files such as .htaccess, .htpasswd, .DS_Store (Mac).
  # Keep logging the requests to parse later (or to pass to firewall utilities such as fail2ban)
  location ~ /\. {
  	deny all;
  }

  location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|eot|ttf|otf)$ {
      expires max;
      log_not_found off;
      gzip on;
        gzip_http_version 1.0;
        gzip_comp_level 2;
        gzip_min_length 1100;
        gzip_buffers     4 8k;
        gzip_proxied any;
        gzip_types
          # text/html is always compressed by HttpGzipModule
          text/css
          text/javascript
          text/xml
          text/plain
          text/x-component
          application/javascript
          application/json
          application/xml
          application/rss+xml
          application/font-woff
          application/font-woff2
          font/truetype
          font/opentype
          image/svg+xml;
         gzip_static  on;
         gzip_proxied expired no-cache no-store private auth;
         gzip_disable MSIE [1-6]\.";
         gzip_vary    on;
  }

  location ~ /\.ht {
      deny all;
  }

  location / {
    try_files $uri$args $uri$args/ $uri $uri/ /index.html =404;
  }
}
