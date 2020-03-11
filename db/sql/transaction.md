# 事务
## 简介

命令 | 描述 | 备注
-----|------|------
commit | 提交事务 | 
rollback | 回滚事务 | 回滚自上次 COMMIT 执行的事务 
savepoint | 创建 rollback 回滚点 | 使 rollback 可回滚到指定点 
set transaction | 命名事务 |  用于初始化数据库事务，设置各种特性（如READ ONLY）
release savepoint | 删除保存点 | 

