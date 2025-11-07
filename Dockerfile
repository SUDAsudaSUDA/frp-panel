# 第一阶段：编译
FROM golang:1.23-alpine AS builder

# 设置时区和镜像源（可选加速）
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories && \
    apk add --no-cache git

# 设置工作目录
WORKDIR /src

# 克隆官方仓库（使用 v0.5.0 标签）
RUN git clone --depth=1 --branch v0.5.0 https://github.com/vaalacat/frp-panel.git .

# 编译（指定 linux/amd64）
ENV CGO_ENABLED=0
ENV GOOS=linux
ENV GOARCH=amd64
RUN go build -ldflags="-s -w" -o frp-panel .

# 第二阶段：运行
FROM alpine:latest

# 安装证书和时区
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories && \
    apk add --no-cache ca-certificates tzdata && \
    cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# 从 builder 阶段复制二进制
COPY --from=builder /src/frp-panel /app/frp-panel

# 设置工作目录
WORKDIR /app
RUN chmod +x frp-panel && mkdir -p /data

# 暴露默认端口
EXPOSE 7000

# 环境变量
ENV DB_DSN=/data/data.db?_pragma=journal_mode(WAL)

# 启动命令
ENTRYPOINT ["./frp-panel"]
CMD ["master", "--data-dir", "/data"]
