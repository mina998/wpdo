#! /bin/bash

# 获取当前脚本的软链接路径
SYMLINK_PATH=$(readlink -f "$0")
# 当前目录
DNMP_DIR=$(dirname "$SYMLINK_PATH")
DNMP_DIR=$(realpath "$DNMP_DIR")
source $DNMP_DIR/.env
# 加载mysql配置
#bash $DNMP_DIR/mysql.sh
# 加载颜色
source $DNMP_DIR/colors.sh
# 检查是否为 root 用户
if [ "$EUID" -ne 0 ]; then 
    echoRR "请使用 root 权限运行此脚本"
    exit 1
fi
# 初始化备份目录
mkdir -p $BACKUP_STORAGE_DIR
# 初始化站点目录
mkdir -p $VHOSTS_ROOT
# 初始化站点配置目录
mkdir -p $VHOSTS_CONF_DIR

# 卸载旧版本 Docker（如果存在）
echoSB "Remove Old Version Docker."
apt remove -y docker docker-engine docker.io containerd runc >/dev/null 2>&1
apt update

# 安装依赖包
echoSB "Install Necessary Packages."
apt install -y apt-transport-https ca-certificates curl gnupg lsb-release unzip gawk certbot zstd pv ghostscript bc

# 添加 Docker 官方 GPG 密钥 和 仓库
echoSB "Add Docker Official GPG Key and Repository."
curl -fsSL https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]')/gpg | gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/$(lsb_release -is | tr '[:upper:]' '[:lower:]') \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update

# 安装 Docker Engine
echoSB "Install Docker Engine."
apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# 将当前用户添加到 docker 组
if [ -n "$SUDO_USER" ]; then
    usermod -aG docker $SUDO_USER
fi

# 判断是否安装成功 根据docker 命令是否存在
if [ -x "$(command -v docker)" ]; then
    systemctl start docker
    systemctl enable docker
    echoGC "Docker Install Success."
    echoSB "Start Docker Compose Service."
    cd $DNMP_DIR
    docker compose up -d
else
    echoRR "Docker Install Failed."
    exit 1
fi

# 安装 docker-compose
# echoSB "Install Docker Compose."
# curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
# chmod +x /usr/local/bin/docker-compose

# # 判断docker-compose 命令是否存在
# if [ -x "$(command -v docker-compose)" ]; then
#     cd $DNMP_DIR
#     echoSB "Start Docker Compose Service."
#     docker-compose up -d
# else
#     echoRR "docker-compose Install Failed."
#     exit 1
# fi

# 创建软链接
chmod +x $DNMP_DIR/vhost.sh
ln -s $DNMP_DIR/vhost.sh /usr/local/bin/vhost.sh