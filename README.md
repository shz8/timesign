# timesign
kong plugins，时间戳认证
## 1、功能    
   基于hmac的username、secret值，进行安全认证。   
## 1、安装插件
   复制kong/plugins/timesign4hmac到kong/plugins/目录下；
   在kong/constants.lua中添加timesign4hmac：
   local plugins = {
     "jwt",
     "acl",
     .....
     "key-auth",
     "timesign4hmac",
   }
