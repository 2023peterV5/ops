
# 1、安装java环境
wget https://download.oracle.com/java/17/archive/jdk-17.0.10_linux-x64_bin.tar.gz
wget https://download.oracle.com/java/17/archive/jdk-17.0.10_linux-x64_bin.tar.gz.sha256
shasum -a 256 -c jdk-17.0.10_linux-x64_bin.tar.gz.sha256 
tar -xzf jdk-17.0.10_linux-x64_bin.tar.gz -C /usr/local/
mv /usr/local/jdk-17.0.10 /usr/local/jdk17

echo """
#jdk17
export JAVA_HOME=/usr/local/jdk17
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
""" >> ~/.bashrc

source ~/.bashrc

# 2、下载skywalking安装包
wget https://dlcdn.apache.org/skywalking/9.7.0/apache-skywalking-apm-9.7.0.tar.gz
tar -xvzf ./apache-skywalking-apm-9.7.0.tar.gz -C /opt/lucky/

# 3、将在180生成后备份的证书配置到skywalking的config文件夹下
mv cert /opt/lucky/apache-skywalking-apm-9.7.0/config/

# 4、修改配置文件--见skywalking_1.yml
mv skywalking_1.yml /opt/lucky/apache-skywalking-apm-9.7.0/config/application.yml

# 5、启动skywalking
cd /opt/lucky/apache-skywalking-apm-9.7.0/bin/
nohup ./oapService.sh &

# 6、查看日志
tail -f /opt/lucky/apache-skywalking-apm-9.7.0/logs/skywalking-oap-server.log



