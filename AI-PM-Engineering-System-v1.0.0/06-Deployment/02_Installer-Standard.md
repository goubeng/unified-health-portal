# 自动化部署包规范

推荐目录：

```text
deploy/
├─ install.ps1
├─ start.ps1
├─ stop.ps1
├─ check.ps1
├─ env.example
├─ docker-compose.yml   # 按项目需要
└─ README.md
```

## install 应完成

1. 检查依赖环境；
2. 检查端口；
3. 检查数据库连通；
4. 执行 Schema/Migration；
5. 安装项目依赖；
6. 生成或校验环境配置；
7. 启动服务；
8. 执行健康检查；
9. 输出地址与失败原因。

自动化脚本必须可重复执行，并避免重复写入基础数据。
