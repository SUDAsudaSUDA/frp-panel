# 使用官方 Alpine 镜像
FROM alpine:latest

# 安装证书和时区支持
RUN apk --no-cache add ca-certificates tzdata \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo "Asia/Shanghai" > /etc/timezone

# 工作目录
WORKDIR /app

# 从 GitHub Releases 下载官方二进制（v0.5.0，amd64）
RUN wget -O frp-panel https://github.com/vaalacat/frp-panel/releases/download/v0.5.0/frp-panel-linux-amd64 \
    && chmod +x frp-panel

# 数据卷和端口
VOLUME ["/data"]
EXPOSE 7000

# 启动命令由外部传入（如 "master"）
ENTRYPOINT ["./frp-panel"]
