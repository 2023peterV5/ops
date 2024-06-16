# 1、下载nginx
wget http://nginx.org/download/nginx-1.26.0.tar.gz
tar -zxvf nginx-1.26.0.tar.gz
cd nginx-1.26.0

# 2、编译安装nginx
./configure --prefix=/opt/lucky/nginx --with-http_ssl_module --with-http_v2_module --with-http_gzip_static_module --with-http_stub_status_module --with-stream
cd /opt/lucky/nginx

make && make install

# 3、配置nginx
mkdir /opt/lucky/nginx/conf/conf.d && mkdir /opt/lucky/nginx/conf/conf.c
# 在第15行插入 include /conf.c/*.conf;
sed -i '5i\include /conf.d/*.conf;' /opt/lucky/nginx/conf/nginx.conf
# 在第19行插入 include /conf.d/*.conf;
sed -i '9i\include /conf.d/*.conf;' /opt/lucky/nginx/conf/nginx.conf

echo """
# yum install httpd-tools
# 安装完成后，您可以运行以下命令来验证是否已成功安装htpasswd工具:
# htpasswd –v
# 如果hthtpasswd安装成功，将显示htpasswd的版本信息。否则，您可能需要重新启动系统后再次尝试安装。
# 创建加密文件
# touch /etc/nginx/htpasswd
# htpasswd -c /etc/nginx/htpasswd admin
# 然后输入密码，即可创建一个具有管理员权限的用户 admin。
# admin dubai81992
server {
    listen 80;
    #server_name    skywalking.nbasf16ssx.com;
    server_name    185.167.14.183;
    location / {
       proxy_set_header Host $host;
       proxy_set_header X-Real-IP $remote_addr;
       proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       auth_basic “Restricted”;
       auth_basic_user_file /etc/nginx/htpasswd;
       proxy_pass http://185.167.14.180:8080;    
    }
}
  

""">> /opt/lucky/nginx/conf/conf.d/skywalking_ui.conf

echo """
# stream与http属于同一层级，需要在主配置文件中的http块以外进行"include skywalking_nginx_four.conf;"
# cat skywalking_nginx_four.conf

stream {
    upstream lb {
        server 185.167.14.180:11800;
        server 185.167.14.181:11800;
        server 185.167.14.182:11800;
    }

    log_format  main '$remote_addr $remote_port - [$time_local] $status $protocol '
                     '"$upstream_addr" "$upstream_bytes_sent" "$upstream_connect_time"';
    
    server {
            listen 11800;
            proxy_connect_timeout 3s;
            proxy_timeout 3s;
            proxy_pass lb;


            access_log  logs/access_four.log  main;
    }
}
""">> /opt/lucky/nginx/conf/conf.c/skywalking_oap.conf

# 4、启动nginx
/opt/lucky/nginx/sbin/nginx -c /opt/lucky/nginx/conf/nginx.conf

# 验证nginx是否启动成功
ps -ef|grep nginx

# 验证nginx是否正常运行
curl http://185.167.14.183/

# 验证skywalking是否正常运行
curl http://185.167.14.183:8080/

# 验证skywalking是否正常运行
curl http://185.167.14.183:8080/graphql


# 5、nacos docker安装
echo """
docker  run \
--name nacos -d \
-p 8848:8848 \
--privileged=true \
--restart=always \
-e JVM_XMS=256m \
-e JVM_XMX=256m \
-e MODE=standalone \
-e PREFER_HOST_MODE=hostname \
-v /opt/lucky/nacos/logs:/home/nacos/logs \
-v /opt/lucky/nacos/init.d:/home/nacos/init.d \
nacos/nacos-server
""" >> /opt/lucky/nacos/nacos_docker.sh

chmod +x /opt/lucky/nacos/nacos_docker.sh
./nacos_docker.sh

# 6、检查docker是否正常运行
# docker ps
CONTAINER ID   IMAGE                COMMAND                  CREATED       STATUS       PORTS                               NAMES
5cdf49a4c3c5   nacos/nacos-server   "bin/docker-startup.…"   5 hours ago   Up 5 hours   0.0.0.0:8848->8848/tcp              nacos


