import{m as S,a as p,d as m,c as g,f,k as E}from"./ui-BXuEL2mG.js";import{g as A,a as P,r as $,c as v,h as D,i as w}from"./vue-Dmc89Wq9.js";/**
 * tdesign v1.16.2
 * (c) 2026 TDesign Group
 * @license MIT
 */function B(u){"@babel/helpers - typeof";return B=typeof Symbol=="function"&&typeof Symbol.iterator=="symbol"?function(e){return typeof e}:function(e){return e&&typeof Symbol=="function"&&e.constructor===Symbol&&e!==Symbol.prototype?"symbol":typeof e},B(u)}/**
 * tdesign v1.16.2
 * (c) 2026 TDesign Group
 * @license MIT
 */function j(u,e){if(B(u)!="object"||!u)return u;var r=u[Symbol.toPrimitive];if(r!==void 0){var t=r.call(u,e);if(B(t)!="object")return t;throw new TypeError("@@toPrimitive must return a primitive value.")}return(e==="string"?String:Number)(u)}function L(u){var e=j(u,"string");return B(e)=="symbol"?e:e+""}function U(u,e,r){return(e=L(e))in u?Object.defineProperty(u,e,{value:r,enumerable:!0,configurable:!0,writable:!0}):u[e]=r,u}/**
 * tdesign v1.16.2
 * (c) 2026 TDesign Group
 * @license MIT
 */function C(u,e){(e==null||e>u.length)&&(e=u.length);for(var r=0,t=Array(e);r<e;r++)t[r]=u[r];return t}function _(u,e){if(u){if(typeof u=="string")return C(u,e);var r={}.toString.call(u).slice(8,-1);return r==="Object"&&u.constructor&&(r=u.constructor.name),r==="Map"||r==="Set"?Array.from(u):r==="Arguments"||/^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(r)?C(u,e):void 0}}/**
 * tdesign v1.16.2
 * (c) 2026 TDesign Group
 * @license MIT
 */function I(u){if(Array.isArray(u))return C(u)}function O(u){if(typeof Symbol<"u"&&u[Symbol.iterator]!=null||u["@@iterator"]!=null)return Array.from(u)}function M(){throw new TypeError(`Invalid attempt to spread non-iterable instance.
In order to be iterable, non-array objects must have a [Symbol.iterator]() method.`)}function Q(u){return I(u)||O(u)||_(u)||M()}/**
 * tdesign v1.16.2
 * (c) 2026 TDesign Group
 * @license MIT
 */var N={classPrefix:"t",form:{requiredMark:void 0}};/**
 * tdesign v1.16.2
 * (c) 2026 TDesign Group
 * @license MIT
 */var k={actionSheet:{cancel:"取消"},calendar:{title:"请选择日期",confirm:"确认",weekdays:["日","一","二","三","四","五","六"],monthTitle:"{year} 年 {month}",months:["1 月","2 月","3 月","4 月","5 月","6 月","7 月","8 月","9 月","10 月","11 月","12 月"]},cascader:{title:"标题",placeholder:"选择选项",filterPlaceholder:"搜索",empty:"暂无匹配项"},dropdownMenu:{reset:"重置",confirm:"确定"},dateTimePicker:{dayjsLocale:"zh-cn",title:"选择时间",cancel:"取消",confirm:"确定",format:"YYYY-MM-DD HH:mm:ss",months:["1 月","2 月","3 月","4 月","5 月","6 月","7 月","8 月","9 月","10 月","11 月","12 月"],yearLabel:"年",monthLabel:"月",dateLabel:"日",hourLabel:"时",minuteLabel:"分",secondLabel:"秒"},form:{errorMessage:{date:"请输入正确的${name}",url:"请输入正确的${name}",required:"${name}必填",whitespace:"${name}不能为空",max:"${name}字符长度不能超过 ${validate} 个字符，一个中文等于两个字符",min:"${name}字符长度不能少于 ${validate} 个字符，一个中文等于两个字符",len:"${name}字符长度必须是 ${validate}",enum:"${name}只能是${validate}等",idcard:"请输入正确的${name}",telnumber:"请输入正确的${name}",pattern:"请输入正确的${name}",validator:"${name}不符合要求",boolean:"${name}数据类型必须是布尔类型",number:"${name}必须是数字"},colonText:"："},picker:{cancel:"取消",confirm:"确认"},pullDownRefresh:{loadingTexts:["下拉刷新","松手刷新","正在刷新","刷新完成"]},rate:{texts:["极差","失望","一般","满意","惊喜"],valueText:"{value} 分",noValueText:"未评分"},tabBar:{newsAriaLabel:"有新的消息",moreNewsAriaLabel:"有很多消息",haveMoreNewsAriaLabel:"有 {value}+ 条消息",haveNewsAriaLabel:"有 {value} 条消息"},table:{empty:"暂无数据",confirmText:"确认",resetText:"重置",searchResultText:"搜索“{result}”，找到 {count} 条结果",clearFilterResultButtonText:"清空筛选",loadingText:"加载中..."},list:{loading:"加载中...",loadingMoreText:"点击加载更多",pulling:"下拉即可刷新...",loosing:"释放即可刷新...",success:"刷新成功"},upload:{progress:{uploadingText:"上传中...",waitingText:"待上传",failText:"上传失败",successText:"上传成功",reloadText:"重新上传"}},guide:{next:"下一步",skip:"跳过",finish:"完成",back:"返回"},typography:{expandText:"展开",collapseText:"收起",copiedText:"复制成功"},qrcode:{expiredText:"二维码过期",refreshText:"点击刷新",scannedText:"已扫描"},attachments:{status:{pending:"上传中...",fail:"上传失败"}},chatActionbar:{actionBar:{replay:"刷新",copy:"复制",good:"点赞",bad:"点踩",share:"分享",quote:"引用"}},chatRecord:{holdToTalk:"按住说话",requestAuth:"请授权麦克风权限",releaseToCancel:"松开取消",releaseToSend:"松开发送，上滑取消",cancelText:"取消",sendText:"发送",busyTip:"识别中，请稍候…",recognizeFailTip:"录音识别失败，请重试",missingPluginTip:"缺少语音识别插件 WechatSI",authSettingFail:"获取录音权限设置失败",openSettingFail:"打开设置失败",systemMicTitle:"无法使用麦克风",systemMicContent:`检测到手机系统已关闭"微信"的麦克风权限。

请到系统设置中开启：
- iOS：设置 > 微信 > 麦克风
- Android：设置 > 应用管理 > 微信 > 权限 > 麦克风

开启后返回小程序再试。`},chatSender:{placeholder:"请输入消息...",sendText:"发送",stopText:"停止"},chatThinking:{status:{pending:"正在思考中...",complete:"已完成思考",stop:"已停止思考"}}};/**
 * tdesign v1.16.2
 * (c) 2026 TDesign Group
 * @license MIT
 */var q=S(N,k),R=Symbol("configProvide");/**
 * tdesign v1.16.2
 * (c) 2026 TDesign Group
 * @license MIT
 */var Y=$(),z=function(e){for(var r=arguments.length,t=new Array(r>1?r-1:0),n=1;n<r;n++)t[n-1]=arguments[n];var i=t[0];if(p(e)){if(!i)return e;var c=/\{\s*([\w-]+)\s*\}/g,o=e.replace(c,function(s,a){return String(i[a])});return o}return m(e)?t.length?e.apply(void 0,t):e(D):""};function G(){var u=arguments.length>0&&arguments[0]!==void 0?arguments[0]:void 0,e=arguments.length>1?arguments[1]:void 0,r=A()?P(R,null):Y,t=v(function(){return(r==null?void 0:r.value)||q}),n=v(function(){return Object.assign({},t.value[u],e)}),i=v(function(){return t.value.classPrefix});return{t:z,global:n,globalConfig:n,classPrefix:i}}/**
 * tdesign v1.16.2
 * (c) 2026 TDesign Group
 * @license MIT
 */function Z(u){var e=G("classPrefix"),r=e.classPrefix;return v(function(){return u?"".concat(r.value,"-").concat(u):r.value})}/**
 * tdesign v1.16.2
 * (c) 2026 TDesign Group
 * @license MIT
 */function h(u){var e;return g(u)&&"defaultNode"in u?e=u.defaultNode:(w(u)||p(u))&&(e=u),e}function T(u){return g(u)&&"params"in u?u.params:{}}function H(u){return g(u)&&"slotFirst"in u?u.slotFirst:!1}/**
 * tdesign v1.16.2
 * (c) 2026 TDesign Group
 * @license MIT
 */var J=Object.prototype.hasOwnProperty,y=function(e,r){return J.call(e,r)};/**
 * tdesign v1.16.2
 * (c) 2026 TDesign Group
 * @license MIT
 */function d(u,e,r){var t,n,i,c,o=(t=(n=u.slots)[f(e)])===null||t===void 0?void 0:t.call(n,r);return o&&o.filter(function(s){var a,l;return((a=(l=s.type).toString)===null||a===void 0?void 0:a.call(l))!=="Symbol(v-cmt)"}).length||(o=(i=(c=u.slots)[E(e)])===null||i===void 0?void 0:i.call(c,r),o&&o.filter(function(s){var a,l;return((a=(l=s.type).toString)===null||a===void 0?void 0:a.call(l))!=="Symbol(v-cmt)"}).length)?o:null}function b(u){if([void 0,null,""].includes(u))return!0;var e=u instanceof Array?u:[u],r=e.filter(function(t){var n;return(t==null||(n=t.type)===null||n===void 0?void 0:n.toString())!=="Symbol(Comment)"});return!r.length}function X(u,e){var r=(u==null?void 0:u.vnode.props)||{};return y(r,f(e))||y(r,E(e))}var K=function(){var e=A();return function(r,t){var n=T(t),i=h(t),c=H(t),o=e.slots[f(r)]||e.slots[E(r)];if(c&&o)return d(e,r,n);if(X(e,r)){var s,a=e.props[f(r)]||e.props[E(r)],l=(s=e.type.props[r])===null||s===void 0?void 0:s.type;if((l==null?void 0:l.length)>1&&l.includes(Boolean)&&l.includes(Function)&&a===""&&!o)return i;if(a===!1||a===null)return;if(a===!0)return d(e,r,n)||i;if(m(a))return a(D,n);var x=[void 0,""].includes(a);return x&&o?d(e,r,n):a}if(o)return d(e,r,n);var F=e.props[f(r)]||e.props[E(r)];if(!(F===!1||F===null))return F===!0?i:m(F)?F(D,n):F}},uu=function(){var e=K();return function(r,t,n){var i=T(n),c=h(n),o=i?{params:i}:void 0,s=e(r,o),a=e(t,o),l=b(s)?a:s;return b(l)?c:l}};/**
 * tdesign v1.16.2
 * (c) 2026 TDesign Group
 * @license MIT
 */var eu=function(e,r){var t=e;return t.install=function(n,i){var c=t.name;n.component(i||c,e)},t};function ru(u){var e=A();e&&e.proxy&&Object.assign(e.proxy,u)}export{U as _,uu as a,K as b,Q as c,B as d,G as e,ru as f,_ as g,Z as u,eu as w};
