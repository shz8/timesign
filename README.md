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
   1）在hmac中增加用户：
   ![输入图片说明](https://images.gitee.com/uploads/images/2020/1201/132049_537b9d4b_1875965.png)
   2)为route/service/Global添加插件
   ![输入图片说明](https://images.gitee.com/uploads/images/2020/1201/132151_df326612_1875965.png)
   3)使用route/service/Global时在header/url中添加appcode（hmac.username）和sign
     ![输入图片说明](https://images.gitee.com/uploads/images/2020/1201/132445_b2bcc621_1875965.png)
     ![输入图片说明](https://images.gitee.com/uploads/images/2020/1201/132711_684872d1_1875965.png)
     ![输入图片说明](https://images.gitee.com/uploads/images/2020/1201/133554_9dc9a932_1875965.png)
     ![输入图片说明](https://images.gitee.com/uploads/images/2020/1201/133521_35a7d814_1875965.png)
