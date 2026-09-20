# P4 数据子任务

- 已读取 doc/lessons.md、doc/progress.md；目标为原始清单42应用、兼容现有运行契约的丰富种子和指定 schema 的隔离 SQL。
- 当前无可用子 agent 工具，直接执行已分派的数据子任务，不创建任务或分支。
- 工作区不含 Git 仓库，无法提供 git diff 校验；按指定文件白名单执行。
- 已完成：读取原始需求43行，排除删除线42，保留42应用及7平台；seed升级schemaVersion 2，现有12项测试通过。
- 已完成：4个原ID/顺序、每人8条PENDING及8条UNREAD、8条公告、40条映射含8异常、126接入配置、6类24条日志。
- 进行中：按nocodb-schema生成P4FIX_隔离SQL，校验字段、枚举、外键及幂等边界；不连接数据库。
- 主线程已反馈完成Provider v2、来源/用户管理/本人已读；旧v1保留。ORG物理组织规则留P6，两条ORG公告均改为DRAFT并标记ADMIN_ONLY，只供管理端查看。
- 范围教训：公开范围本阶段仅ALL/CITIZEN/GOV；不得把ORG样本当成已实现的公开组织规则。按文件白名单记录于本文件，不修改doc/lessons.md。
- 用户review教训：郑颖统一显示门户管理员，通过scopes和scopeDescription说明公告权限；应用显示编码WJ_APP_XX，外部账号使用account_XX，内部ID和SQL隔离命名仍保留。已同步生成器，准备重新生成全部交付文件。
- 主线程处理目录可见性：公众也显示42目录，通过applicable表达适用性；本种子仍保留userType，进入与关联权限不放宽。
- 主线程只读确认PG14.20、application=0、users=0、system_config=12；本子任务未自行访问数据库。交付须附counts和只读回查脚本。
- 边界：不执行数据库写入，不修改服务、页面、测试和其它文档；SQL交主线程审核。
