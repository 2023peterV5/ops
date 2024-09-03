#/bin/bash
for msg in $(cat remote-backup.info)
do      
    IP=$(echo $msg | cut -d "," -f2)
    TENANT=$(echo $msg | cut -d "," -f1)
    SERVICE=$(echo $msg | cut -d "," -f4)
    date=$(date "+%Y-%m-%d %H:%M:%S")

    # hostname
    # hostname=$(curl -s http://18.215.54.73:9100/metrics| grep node_uname_info | grep -v "HELP\|TYPE" | awk -F ',' '{print $3}')
    # node status
    node_status=$(curl -s http://${IP}:9100/metrics| grep node_uname_info | grep -v "HELP\|TYPE" | awk  '{print $9}')
    # mysql status
    mysql_status=$(curl -s http://${IP}:9104/metrics | grep mysql_up | grep -v "HELP\|TYPE" |awk '{print $2}')
    # redis status
    redis_status=$(curl -s http://${IP}:9121/metrics | grep redis_up | grep -v "HELP\|TYPE" |awk '{print $2}')

    # 判断获取到的状态的信息条数
    node_status_num=$(curl -s http://${IP}:9100/metrics| grep node_uname_info | grep -v "HELP\|TYPE" | awk  '{print $9}' | wc -l)
    mysql_status_num=$(curl -s http://${IP}:9104/metrics | grep mysql_up | grep -v "HELP\|TYPE" |awk '{print $2}' | wc -l)
    redis_status_num=$(curl -s http://${IP}:9121/metrics | grep redis_up | grep -v "HELP\|TYPE" |awk '{print $2}' | wc -l)

    # node_status状态判断
    function node_status_check(){
        # 检查 node_status 的长度是否大于5
        if [[ ${node_status}  -eq 1 ]]; then
            echo "$date【$TENANT ${IP} node_exporter】prometheus server 接受数据正常" >> exporter_status_out
        else
            echo "$date【$TENANT ${IP} node_exporter】prometheus server 接受数据失败,请登录租户服务器进行检查" >> exporter_status_err
        fi
    }

    function mysql_status_check(){
        # 检查 mysql_status 是否等于1
        if [[ $mysql_status -eq 1 ]]; then
            echo "$date【$TENANT ${IP} mysql_exporter】prometheus server 接受数据正常" >> exporter_status_out
        else
            echo "$date【$TENANT ${IP} mysql_exporter】prometheus server 接受数据失败,请登录租户服务器进行检查" >> exporter_status_err
        fi 
    }

    function redis_status_check(){
        # 检查 redis_status 是否等于1
        if [[ $redis_status -eq 1 ]]; then
            echo "$date【$TENANT ${IP} redis_exporter】prometheus server 接受数据正常" >> exporter_status_out
        else
            echo "$date【$TENANT ${IP} redis_exporter】prometheus server 接受数据失败,请登录租户服务器进行检查" >> exporter_status_err
        fi
    }    

    function node_exporter_singel_check(){
        # 根据获取到状态的信息条数
        if [[ $node_status_num -eq 1 ]]; then
            node_status_check
        elif [[ $node_status_num -gt 1 ]]; then
            node_status=$(curl -s http://${IP}:9100/metrics| grep node_uname_info | grep -v "HELP\|TYPE" | awk  'NR==1{print $9}')
            node_status_check
        else
            echo "$date【$TENANT ${IP} node_exporter】prometheus server 接受数据失败,请登录租户服务器进行检查" >> exporter_status_err
        fi
    }

    function mysql_exporter_singel_check(){
        # 根据获取到状态的信息条数
        if [[ $mysql_status_num -eq 1 ]]; then
            mysql_status_check
        elif [[ $mysql_status_num -gt 1 ]]; then
            mysql_status=$(curl -s http://${IP}:9104/metrics | grep mysql_up | grep -v "HELP\|TYPE" |awk 'NR==1{print $2}')
            mysql_status_check
        else
            echo "$date【$TENANT ${IP} mysql_exporter】prometheus server 接受数据失败,请登录租户服务器进行检查" >> exporter_status_err
        fi
    }

    function redis_exporter_singel_check(){
        # 根据获取到状态的信息条数
        if [[ $redis_status_num -eq 1 ]]; then
            redis_status_check
        elif [[ $redis_status_num -gt 1 ]]; then
            redis_status=$(curl -s http://${IP}:9121/metrics | grep redis_up | grep -v "HELP\|TYPE" |awk 'NR==1{print $2}')
            redis_status_check
        else
            echo "$date【$TENANT ${IP} redis_exporter】prometheus server 接受数据失败,请登录租户服务器进行检查" >> exporter_status_err
        fi
    }

    if [[ $SERVICE == "nginx" ]]; then
        node_exporter_singel_check
    elif [[ $SERVICE == "master" || $SERVICE == "slave" ]]; then
        mysql_exporter_singel_check
        redis_exporter_singel_check
        node_exporter_singel_check
    fi
done

