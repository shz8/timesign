# timesign
kong plugins，时间戳认证
## 1、功能    
   基于hmac的username、secret值，进行安全认证。   
## 2、安装插件
   1）复制kong/plugins/timesign4hmac到kong/plugins/目录下；
   2）在kong/constants.lua中添加timesign4hmac：
   `
   local plugins = {
     "jwt",
     "acl",
     .....
     "key-auth",
     "timesign4hmac",
   }`
## 3、使用
   1）在hmac中增加用户：![输入图片说明](https://images.gitee.com/uploads/images/2020/1201/131647_572d1c27_1875965.png "屏幕截图.png")
    
