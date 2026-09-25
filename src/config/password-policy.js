export const validateLocalPassword=({currentPassword,newPassword,confirmPassword,requireCurrent=false}={})=>{
 if(requireCurrent&&(typeof currentPassword!=='string'||!currentPassword.trim()))return '请输入当前密码';
 if(typeof newPassword!=='string'||newPassword.length<8||newPassword.length>64||!/[A-Z]/.test(newPassword)||!/[a-z]/.test(newPassword)||!/[0-9]/.test(newPassword)||!/[^A-Za-z0-9\s]/.test(newPassword)||/\s/.test(newPassword))return '新密码须为 8–64 位，包含大写字母、小写字母、数字和特殊字符，且不能包含空白字符';
 if(newPassword!==confirmPassword)return '两次输入的新密码不一致';
 if(requireCurrent&&newPassword===currentPassword)return '新密码不能与当前密码相同';
 return null;
};
