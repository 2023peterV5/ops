#!/bin/bash

# 文件路径
INPT_FILE="inpt.info"
B_FILE="b.txt"
ADD_SCRIPT="./add.sh"
DEL_SCRIPT="./del.sh"

# 检查 inpt.info 是否存在
if [ ! -f "$INPT_FILE" ]; then
    echo "Error: $INPT_FILE does not exist!"
    exit 1
fi

# 检查 b.txt 是否存在，如果不存在则创建一个空文件
if [ ! -f "$B_FILE" ]; then
    touch "$B_FILE"
fi

# 无限循环监控文件变化
while true; do
    # 比较 inpt.info 和 b.txt 的差异
    diff_output=$(diff "$INPT_FILE" "$B_FILE")
    
    # 如果 diff 有输出，说明文件内容有变化
    if [ -n "$diff_output" ]; then
        # 判断是新增还是减少
        added_lines=$(diff "$B_FILE" "$INPT_FILE" | grep "^>" | wc -l)
        removed_lines=$(diff "$B_FILE" "$INPT_FILE" | grep "^<" | wc -l)

        if [ "$added_lines" -gt 0 ]; then
            echo "Detected new lines, executing add.sh"
            $ADD_SCRIPT
        fi
        
        if [ "$removed_lines" -gt 0 ]; then
            echo "Detected removed lines, executing del.sh"
            $DEL_SCRIPT
        fi
        
        # 执行完脚本后，用 inpt.info 内容覆盖 b.txt
        cp "$INPT_FILE" "$B_FILE"
        echo "Updated $B_FILE with the contents of $INPT_FILE"
    fi
    
    # 等待 5 秒后再次检查文件
    sleep 5
done
