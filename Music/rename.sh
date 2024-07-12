#!/bin/bash

# 檢查 opencc 是否已安裝
if ! command -v opencc &> /dev/null
then
    echo "opencc could not be found, please install it first."
    exit
fi

# 遍歷當前目錄下的所有文件
for file in *; do
    # 確保只處理文件而不是目錄
    if [ -f "$file" ]; then
        # 使用 opencc 將文件名從簡體轉換為繁體
        traditional_name=$(echo "$file" | opencc -c s2t.json)
        # 重命名文件
        mv "$file" "$traditional_name"
        echo "Renamed: $file -> $traditional_name"
    fi
done