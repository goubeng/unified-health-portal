# 应用访问与账号关联 Mock 演示闭环实现方案 V1.0

> **历史 Mock 实施方案（2026-10-01 适用性提示）**：本文规定原型场景与交互，不是当前的数据源说明。现行 `npm run dev` 默认走 DATABASE，相关申请、授权及映射状态会持久化（部分仍在逐条运行实体），`npm run dev:mock` 才是内存模拟；登录模拟和外部接口未联调的边界不变。最新证据见[代码与文档一致性核查](../02-评审/代码与文档一致性核查_20261001.md)。

> 基线：V20260920-03  
> 适用版本：0.3.0 原型改造  
> 实施目标：前端交互与业务状态完整可演示；真实闽政通/闽政务/短信/人脸/子系统接口可以暂不接入，统一由 Mock Service 模拟。

## 1. 实施原则

本阶段不是完成真实外部联调，而是让产品原型完整表现未来真实业务流程。

必须满足：

1. 用户在页面上能看到不同应用访问状态；
2. 用户能真实点击“申请使用 / 关联账号 / 继续验证 / 查看申请 / 重新关联”等操作；
3. BIND、REQUEST、未开户、验证失败、冲突、高权限审核等分支均可通过 Mock 数据演示；
4. 管理端能够查看并处理应用访问申请、账号关联审核和映射冲突；
5. 用户端与管理端使用同一份 Mock 数据，操作后状态实时联动；
6. Mock 实现不得把门户入口资格、子系统账号开户、子系统业务权限混为一体；
7. 所有页面和状态必须与当前需求文档、状态机、Service契约保持一致。

## 2. 原型闭环范围

### 2.1 应用访问模式

- DIRECT：满足适用范围后可直接“进入应用”；
- BIND：必须完成子系统账号关联；
- REQUEST：必须先申请门户应用入口资格；
- REQUEST + BIND：申请通过后继续完成账号关联。

### 2.2 用户端需要可演示的状态

| 场景 | 卡片状态 | 主操作 |
|---|---|---|
| DIRECT可访问 | 可访问 | 进入应用 |
| BIND + UNBOUND | 未关联 | 关联账号 |
| BIND + VERIFYING | 验证中 | 继续验证 |
| BIND + REVIEWING | 待审核 | 查看进度 |
| BIND + BOUND | 已关联 | 进入应用 |
| BIND + FAILED | 关联失败 | 重新关联 |
| BIND + CONFLICT | 关联异常 | 查看异常 |
| REQUEST + 未申请 | 未申请 | 申请使用 |
| REQUEST + PENDING | 审核中 | 查看申请 |
| REQUEST + APPROVED | 已通过 | 进入应用或继续关联 |
| REQUEST + REJECTED | 已驳回 | 查看原因 / 重新申请 |
| 子系统无账号 | 未开户 | 申请开通 / 前往开户注册 |
| 子系统账号停用 | 不可使用 | 查看原因 |

## 3. 用户端页面与交互

### 3.1 应用中心

路由：`/portal/apps`

卡片至少显示：

- 应用名称；
- 应用分类；
- 适用用户；
- 访问模式；
- 当前访问状态；
- 子系统账号状态（如适用）；
- 主操作按钮；
- 次操作“查看详情”。

按钮由状态驱动，不允许只写死“进入/关联”。

### 3.2 申请使用弹窗

适用于 REQUEST。

字段：

- 应用名称（只读）
- 申请人（只读）
- 所属组织（只读/无则为空）
- 申请原因*
- 联系方式（可选）
- 备注（可选）

操作：

- 提交申请；
- 取消。

结果：

```text
提交
→ PENDING
→ 我的申请中出现记录
→ 管理端应用访问申请可审核
```

### 3.3 账号关联向导

建议使用 TDesign Dialog + Steps，不新增独立复杂页面。

步骤：

```text
① 查找账号
② 身份验证
③ 关联结果
```

#### 第一步：查找账号

支持 Mock：

- 自动查找我的账号；
- 输入已有子系统账号。

自动查找候选结果展示：

- 子系统账号；
- 姓名；
- 脱敏手机号；
- 所属单位；
- 账号状态；
- 是否高权限账号。

提示：

> 姓名、手机号等仅用于查找候选账号，仍需完成账号归属验证。

#### 第二步：身份验证

根据 Mock 应用配置展示一种或多种方式：

- 子系统跳转认证；
- 子系统原登记手机号验证码；
- 闽政通/闽政务重新认证；
- 原系统账号+密码一次性验证；
- 提交管理员审核。

手机号验证码原型：

- 显示脱敏手机号；
- 获取验证码；
- 验证码输入框；
- 演示环境固定验证码可使用 `123456`；
- 明确“验证码仅用于演示”。

账号密码原型：

- 子系统账号；
- 子系统密码；
- 提示“仅用于本次验证，统一门户不会保存”。

#### 第三步：关联结果

支持：

- BOUND：关联成功；
- REVIEWING：验证成功，等待管理员审核；
- FAILED：验证失败；
- CONFLICT：关联冲突；
- ACCOUNT_DISABLED：子系统账号停用。

### 3.4 未找到子系统账号

当候选为空：

```text
未找到已有账号
```

根据应用 Mock 配置显示：

1. “申请开通账号”；
2. “前往原系统开通”；
3. “联系系统管理员”。

“申请开通账号”只是门户演示/流程承接，不代表门户直接创建子系统账号。

### 3.5 子系统账号开通申请

建议与“门户应用访问申请”分开。

字段：

- 申请编号；
- 应用；
- 申请人；
- 所属组织；
- 联系方式；
- 申请原因；
- 备注；
- 处理状态。

状态：

- PENDING
- PROCESSING
- COMPLETED
- REJECTED

COMPLETED 后用户可继续“关联账号”。

### 3.6 我的申请

路由：`/portal/applications`

建议两个 Tab：

- 应用访问申请；
- 子系统账号开通申请。

应用访问申请操作：

- 查看；
- PENDING 撤回；
- REJECTED 重新申请；
- APPROVED 根据应用规则“进入应用/继续关联”。

账号开通申请操作：

- 查看；
- COMPLETED 后“去关联”。

## 4. 失败与异常交互

不得只返回统一“关联失败”。

| 错误码 | 用户提示 | 下一步 |
|---|---|---|
| ACCOUNT_NOT_FOUND | 未找到对应账号 | 申请开通 / 前往原系统 |
| INVALID_CREDENTIALS | 账号或密码错误 | 重新验证 |
| OTP_INVALID | 验证码错误 | 重新输入 |
| OTP_EXPIRED | 验证码已过期 | 重新获取 |
| ACCOUNT_DISABLED | 子系统账号已停用 | 联系子系统管理员 |
| ACCOUNT_ALREADY_BOUND | 账号已关联其他身份 | 查看异常/提交处理 |
| MULTIPLE_CANDIDATES | 找到多个候选账号 | 选择候选/提交审核 |
| REVIEW_REQUIRED | 该账号需要管理员审核 | 查看审核进度 |
| UPSTREAM_UNAVAILABLE | 子系统暂时不可用 | 稍后重试 |
| ACCOUNT_MAPPING_CONFLICT | 账号关联存在冲突 | 等待管理员处理 |

## 5. 管理端演示闭环

### 5.1 应用访问申请

路由建议：`/admin/application-requests`

能力：

- 列表；
- 查询；
- 查看详情；
- 通过；
- 驳回；
- 查看操作履历。

审核只决定门户入口资格。

### 5.2 子系统账号关联审核

身份与子系统映射中增加“待审核”状态。

详情展示：

- 用户；
- 应用；
- 候选账号；
- 匹配依据；
- 验证方式；
- 验证结果；
- 风险级别；
- 是否高权限账号；
- 验证时间；
- 操作履历。

操作：

- 通过；
- 驳回。

### 5.3 关联冲突

管理员看到：

- 当前门户用户；
- 当前子系统账号；
- 已绑定门户用户；
- 冲突原因；
- 匹配/验证证据。

操作：

- 保留原绑定；
- 解除原绑定后重绑（需二次确认）；
- 驳回当前关联；
- 记录处理说明。

## 6. Mock 演示场景

必须预置固定场景，避免随机数据导致无法复现。

| Mock应用 | 模式 | 演示场景 |
|---|---|---|
| DEMO-01 | DIRECT | 点击直接进入 |
| DEMO-02 | BIND/AUTO | 可信ID自动关联成功 |
| DEMO-03 | BIND/SELF | 姓名+手机号候选 → OTP 123456 → BOUND |
| DEMO-04 | BIND/SELF | 原系统账号密码验证 |
| DEMO-05 | BIND/REVIEW | 验证成功 → REVIEWING → 管理员审核 |
| DEMO-06 | BIND | 未找到账号 → 申请开通 |
| DEMO-07 | BIND | 子系统账号DISABLED |
| DEMO-08 | BIND | 已绑定他人 → CONFLICT |
| DEMO-09 | REQUEST | 申请 → 管理员通过 → DIRECT进入 |
| DEMO-10 | REQUEST+BIND | 申请通过 → 账号关联 → OTP → 进入 |

建议演示固定数据：

- OTP：`123456`
- 成功原系统账号：`demo01 / 123456`
- 失败账号：`error01`
- 冲突账号：`conflict01`

这些值仅存在 Mock 层，不进入生产配置。

## 7. Mock 数据对象

建议新增/补齐：

- application.accessMode
- application.accountBindingMode
- application.accountOpeningMode
- application.mockScenario
- application_access_request
- application_account_open_request
- application_user_mapping
- application_mapping_verification_event

前端展示状态必须由 Mock Service 返回，不由组件硬编码业务结果。

## 8. 代码实现建议

### 8.1 组件

建议新增：

- `src/components/portal/ApplicationAccessDialog.vue`
- `src/components/portal/AccountBindingWizard.vue`
- `src/components/portal/AccountCandidateList.vue`
- `src/components/portal/AccountVerification.vue`
- `src/components/portal/BindingResult.vue`
- `src/components/portal/ApplicationRequestDetail.vue`
- `src/components/portal/AccountOpeningRequest.vue`

现有 `AppCards.vue` 改为状态驱动操作按钮。

### 8.2 页面

建议补齐：

- `/portal/applications` 我的申请；
- `/admin/application-requests` 应用访问申请；
- 身份与子系统映射页面增加 REVIEWING / CONFLICT 处理。

### 8.3 Service

在 Mock Service 中实现：

- submitApplicationRequest
- withdrawApplicationRequest
- approveApplicationRequest
- rejectApplicationRequest
- discoverApplicationAccountCandidates
- startApplicationAccountBinding
- sendSubsystemBindingOtp
- verifyBindingOtp
- verifyBindingBySubsystemCredential
- verifyBindingByUpstreamReauth
- submitBindingReview
- approveBindingReview
- rejectBindingReview
- submitAccountOpeningRequest
- completeMockAccountOpeningRequest
- resolveMappingConflict

所有方法保持未来真实接口可替换的签名。

## 9. 原型验收闭环

至少完成以下演示：

### 场景A：普通BIND成功

```text
应用中心
→ 未关联
→ 关联账号
→ 找到候选
→ 手机验证码123456
→ 关联成功
→ 卡片变“已关联”
→ 进入应用
```

### 场景B：未开户

```text
应用中心
→ 关联账号
→ 未找到账号
→ 申请开通
→ 我的申请
→ Mock处理完成
→ 去关联
```

### 场景C：高权限审核

```text
用户验证账号
→ REVIEWING
→ 切换管理员
→ 审核通过
→ 切回用户
→ BOUND
→ 进入应用
```

### 场景D：REQUEST + BIND

```text
申请使用
→ 管理员审核通过
→ 用户收到“继续关联”
→ 二次验证
→ BOUND
→ 进入应用
```

### 场景E：冲突

```text
用户关联
→ ACCOUNT_ALREADY_BOUND
→ CONFLICT
→ 管理端处理
→ 用户端状态同步
```

## 10. 本阶段不要求

本阶段不要求：

- 真实发送短信；
- 真实调用人脸识别；
- 真实调用闽政通/闽政务；
- 真实调用所有子系统；
- 真实创建子系统账号；
- 真实SSO进入子系统；
- 生产级密码/OTP安全实现。

但前端必须完整体现未来真实流程、输入字段、按钮、状态、提示、失败分支和角色联动。

## 11. 完成定义

只有同时满足以下条件，才算完成“应用访问与账号关联 Mock 演示闭环”：

1. 用户端所有核心状态可见；
2. REQUEST可提交、查看、撤回、审核；
3. BIND可查候选、验证、审核、冲突、解绑；
4. 未开户存在明确处理路径；
5. 我的申请页面可查看两类申请；
6. 管理端可以处理对应请求；
7. 用户端和管理端状态联动；
8. 固定Mock场景可重复演示；
9. Loading/Empty/Error完整；
10. 代码结构可在后续真实接口接入时替换Mock Service而不重写页面流程。
