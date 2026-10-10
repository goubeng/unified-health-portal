import { date, label, text } from './presentation.js';

// PC、移动端共用字段序列：三列基础字段，两行单列长文本；无数据统一显示“-”。
export function requestDetailSections(record) {
  const row = record || {};
  const cell = (key, fieldLabel, value, layout = 'is-third') => ({
    key, label: fieldLabel, value, layout,
  });
  const isOpening = row.requestType === 'ACCOUNT_OPENING';
  const requestKind = isOpening ? 'account_opening_status' : 'application_request_status';
  const afterApproval = !isOpening && row.postGrantMode === 'DIRECT'
    ? '直接进入应用'
    : !isOpening && row.postGrantMode === 'BIND'
      ? '完成账号关联'
      : '-';
  return {
    application: [
      cell('requestNo', '申请编号', text(row.requestNo) || '-'),
      cell('submittedAt', '申请时间', date(row.submittedAt)),
      cell('status', '申请状态', label(row.status, requestKind)),
      cell('userName', '申请人', text(row.userName) || '-'),
      cell('contact', '联系方式', text(row.contact) || '-'),
      cell('userId', '统一身份标识', text(row.userId) || '-'),
      cell('appName', '应用名称', text(row.appName) || '-'),
      cell('postGrantMode', '申请通过后', afterApproval),
      cell('requestType', '申请类型', isOpening ? '账号开通申请' : '应用访问申请'),
      cell('reason', '申请原因', text(row.reason) || '-', 'is-wide'),
      cell('remark', '备注', text(row.remark) || '-', 'is-wide'),
    ],
    review: [
      cell('reviewer', '审核人', text(isOpening ? row.handledByName : row.reviewedByName) || '-', 'is-half'),
      cell('reviewedAt', '审核时间', date(isOpening ? row.handledAt : row.reviewedAt), 'is-half'),
      cell('reviewNote', '审核意见', text(isOpening ? row.handleNote : row.reviewNote) || '-', 'is-wide'),
    ],
  };
}

// 详情页可用的业务操作与列表保持一致，不让无权限或终态显示无效按钮。
export function requestDetailActions(record, kind = 'myApplicationRequests') {
  if (!record) return [];
  if (kind === 'applicationRequests') {
    return record.status === 'PENDING'
      ? [
          { key: 'approve', label: '通过', theme: 'primary' },
          { key: 'reject', label: '驳回', theme: 'danger' },
        ]
      : [];
  }
  if (kind === 'accountOpeningRequests') {
    return ['PENDING', 'PROCESSING'].includes(record.status)
      ? [{ key: 'completeOpening', label: '标记已开通', theme: 'primary' }]
      : [];
  }
  if (record.requestType === 'APPLICATION_ACCESS') {
    if (record.status === 'PENDING') return [{ key: 'withdraw', label: '撤回申请', theme: 'danger' }];
    if (record.status === 'REJECTED') return [{ key: 'reapply', label: '重新申请', theme: 'primary' }];
    if (record.status === 'APPROVED' && record.postGrantMode === 'DIRECT') return [{ key: 'enter', label: '进入应用', theme: 'primary' }];
    if (record.status === 'APPROVED' && record.postGrantMode === 'BIND') return [{ key: 'bind', label: '完成账号确认', theme: 'primary' }];
  }
  if (record.requestType === 'ACCOUNT_OPENING' && record.status === 'COMPLETED') {
    return [{ key: 'bind', label: '完成账号确认', theme: 'primary' }];
  }
  return [];
}
