#!/bin/bash

# Prompt for the directory path
echo -n "请输入要清理的目录路径: "
read -r TARGET_DIR

# Aggressively remove carriage returns, trailing/leading whitespace
TARGET_DIR=$(echo "$TARGET_DIR" | sed 's/\r//g; s/^[[:space:]]*//; s/[[:space:]]*$//')

# Convert Windows path to Unix path
if [[ "$TARGET_DIR" =~ ^[a-zA-Z]:\\ ]]; then
    DRIVE=$(echo "$TARGET_DIR" | cut -c 1 | tr '[:upper:]' '[:lower:]')
    REST=$(echo "$TARGET_DIR" | sed 's/^[a-zA-Z]:\\//' | tr '\\' '/')
    REST=$(echo "$REST" | sed 's/^\///')
    
    # Try multiple common mount points
    CANDIDATES=("/$DRIVE/$REST" "/mnt/$DRIVE/$REST")
    
    for path in "${CANDIDATES[@]}"; do
        if [ -d "$path" ]; then
            TARGET_DIR="$path"
            break
        fi
    done
fi

# Final check to remove any double slashes
TARGET_DIR=$(echo "$TARGET_DIR" | sed 's#//*#/#g')

# Check if directory exists
if [ ! -d "$TARGET_DIR" ]; then
    echo "错误: 目录 [$TARGET_DIR] 不存在。"
    exit 1
fi

echo "请选择要在 $TARGET_DIR 中删除的内容:"
echo "1) 仅删除空文件"
echo "2) 仅删除空文件夹"
echo "3) 全部删除 (空文件和空文件夹)"
read -p "选择 [1-3]: " CHOICE

case $CHOICE in
    1)
        # Find and delete only EMPTY files RECURSIVELY
        find "$TARGET_DIR" -type f -empty -not -name "$(basename "$0")" -delete
        echo "递归删除空文件完成。"
        ;;
    2)
        # Find and delete only EMPTY directories RECURSIVELY
        # -depth ensures children are processed before parents
        find "$TARGET_DIR" -depth -type d -empty -not -path "$TARGET_DIR" -delete
        echo "递归删除空文件夹完成。"
        ;;
    3)
        # Delete only EMPTY files (recursive) and EMPTY directories (recursive)
        find "$TARGET_DIR" -type f -empty -not -name "$(basename "$0")" -delete
        find "$TARGET_DIR" -depth -type d -empty -not -path "$TARGET_DIR" -delete
        echo "递归删除所有空内容完成。"
        ;;
    *)
        echo "无效选择，请重新运行。"
        exit 1
        ;;
esac
