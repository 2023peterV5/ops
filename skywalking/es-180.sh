# es verions: 8.13.1
# skywalking verions: 9.7.0 
# nacos version: 2.3.2


# 1、es 下载
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.13.1-linux-x86_64.tar.gz
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.13.1-linux-x86_64.tar.gz.sha512
shasum -a 512 -c elasticsearch-8.13.1-linux-x86_64.tar.gz.sha512 
tar -xzf elasticsearch-8.13.1-linux-x86_64.tar.gz
cd elasticsearch-8.13.1/ 

# 2、必要的环境配置
#-------服务器初始化已修改
# 修改/etc/security/limits.conf文件，添加以下内容：
# * soft nofile 65536
# * hard nofile 65536

# vim /etc/sysctl.conf
echo "vm.max_map_count=655350" >> /etc/sysctl.conf
sysctl -p

# ----创建用户
# 需要用普通用户来启动，不然无法启动，提示不能用root启动
# 需要给服务目录添加权限，不然无法启动，提示目录没有权限

chown swadmin:swadmin /opt/lucky/elasticsearch-8.13.1 -R


# ----创建数据目录
mkdir /opt/elasticsearch-8.13.1/data

# 修改ES目录下bin/elasticsearch文件，在文件第二行位置开始添加如下内容：
export JAVA_HOME=/opt/lucky/elasticsearch-8.13.1/jdk
export PATH=$JAVA_HOME/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tool.jar

# 此内容告诉当前的应用使用此临时环境变量，
# 而不使用/ect/profile内的环境变量，这样就可以重新定义使用ES自带的JDK了。


# ----配置/etc/hosts文件
echo """
172.xx.xx.182 es-182
172.xx.xx.181 es-181
172.xx.xx.180 es-180
""" >> /etc/hosts

# ---配置文件内容
# cat /opt/lucky/elasticsearch-8.13.1/config/elasticsearch.yml
echo """
cluster.name: es4sykywalking
node.name: es-180

path.data: /opt/lucky/elasticsearch-8.13.1/data
path.logs: /opt/lucky/elasticsearch-8.13.1/logs


network.host: 0.0.0.0
http.port: 9200
transport.port: 9300
discovery.seed_hosts: ["172.xx.xx.182","172.xx.xx.181","172.xx.xx.180"]
cluster.initial_master_nodes: ["172.xx.xx.182","172.xx.xx.181","172.xx.xx.180"]
thread_pool.write.queue_size: 10000

xpack.security.enabled: false
xpack.security.transport.ssl.enabled: false
xpack.security.http.ssl.enabled: false
""" > /opt/lucky/elasticsearch-8.13.1/config/elasticsearch.yml


# 3、启动es
./bin/elasticsearch
# ./bin/elasticsearch -d 后台启动

curl http://127.0.0.1:9200/_cluster/health?pretty=true


# [root@swes-01-185 config]# curl http://127.0.0.1:9200/_cluster/health?pretty=true
# {
#   "cluster_name" : "es4sykywalking",
#   "status" : "green",
#   "timed_out" : false,
#   "number_of_nodes" : 3,
#   "number_of_data_nodes" : 3,
#   "active_primary_shards" : 70,
#   "active_shards" : 80,
#   "relocating_shards" : 0,
#   "initializing_shards" : 0,
#   "unassigned_shards" : 0,
#   "delayed_unassigned_shards" : 0,
#   "number_of_pending_tasks" : 0,
#   "number_of_in_flight_fetch" : 0,
#   "task_max_waiting_in_queue_millis" : 0,
#   "active_shards_percent_as_number" : 100.0
# }

# [es@swes-02-185 bin]$ ./elasticsearch
# warning: ignoring JAVA_HOME=/usr/local/jdk17; using bundled JDK
# ./elasticsearch-cli: line 14: /opt/lucky/elasticsearch-8.13.1/jdk/bin/java: Permission denied

# [2]
# fatal exception while booting Elasticsearchorg.elasticsearch.ElasticsearchSecurityException: 
# invalid configuration for xpack.security.http.ssl - [xpack.security.http.ssl.enabled] 
# is not set, but the following settings have been configured in elasticsearch.yml : 
# [xpack.security.http.ssl.keystore.secure_password]

# >>>>看到上面的显示内容，就可以后台情况，记得保留上面的password，后面会用到<<<<
# 执行命令：./bin/elasticsearch 看到下面情况，表示启动成功
# -----------
# ✅ Elasticsearch security features have been automatically configured!
# ✅ Authentication is enabled and cluster connections are encrypted.

# ℹ️  Password for the elastic user (reset with `bin/elasticsearch-reset-password -u elastic`):
#   pH*We1JxxxxYW-+y+48

# pH*We1JxxxxYW-+y+48

# ❌ Unable to generate an enrollment token for Kibana instances, try invoking `bin/elasticsearch-create-enrollment-token -s kibana`.

# ❌ An enrollment token to enroll new nodes wasn't generated. To add nodes and enroll them into this cluster:
# • On this node:
#   ⁃ Create an enrollment token with `bin/elasticsearch-create-enrollment-token -s node`.
#   ⁃ Restart Elasticsearch.
# • On other nodes:
#   ⁃ Start Elasticsearch with `bin/elasticsearch --enrollment-token <token>`, using the enrollment token that you generated.


# 查看索引
curl -u elastic:pH*We1JxxxxYW-+y+48 -XGET 'localhost:9200/_cat/indices?v'
# health status index                         uuid                   pri rep docs.count docs.deleted store.size pri.store.size dataset.size
# green  open   sw_records-all-20240505       sdhdZ7gkTxygSrO4Ga_ZNg   1   1          0            0       498b           249b         249b
# green  open   sw_records-all-20240503       Pzw6ve9RTyOlzWhvrHHBoQ   1   1          0            0       498b           249b         249b
# green  open   sw_records-all-20240504       mr5-jd_5QjCykYfW62_1pA   1   1          0            0       498b           249b         249b

# 删除索引与创建索引
# curl -u elastic:pH*We1JxxxxYW-+y+48 -XDELETE 'localhost:9200/sw_management'
# curl -u elastic:pH*We1JxxxxYW-+y+48 -XPUT "localhost:9200/sw_metrics-all-20240507"