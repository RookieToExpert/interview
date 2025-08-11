## Azure data factory
用于分析，清洗数据

### Overall structure:

![alt text](image-1.png)

## Demo: Importing CARS.csv data from Blob to Azure SQL using data factory

✅ 第1步: 创建data factory

![alt text](image-2.png)

✅ 第2步: 创建SQL database

![alt text](image-3.png)

✅ 第3步: 创建storage account然后上传csv文件到blob container作为input source

![alt text](image-4.png)

![alt text](image-5.png)

✅ 第4步: 在sql db创建表格作为目标文件载体

![alt text](image-6.png)

![alt text](image-7.png)

✅ 第5步: 在data factory里面创建pipeline:

![alt text](image-9.png)

![alt text](image-10.png)

✅ 第6步: 创建linked service：

![alt text](image-11.png)

![alt text](image-12.png)

✅ 第7步: 定义data set：

![alt text](image-13.png)

选择data的来源：

![alt text](image-14.png)

选择data的类型：

![alt text](image-15.png)

定义文件路径：

![alt text](image-16.png)

✅ 第8步: 重复以上步骤，为目标sql database创建linked service，定义data set：

linked service:

![alt text](image-17.png)

data set:

![alt text](image-18.png)

✅ 第9步: 创建copy activity移动数据：

还有非常多其他的activities，其中copy activity比较常见：

![alt text](image-19.png)

![alt text](image-20.png)

测试数据是否copy成功：

✅ 第10步: ![alt text](image-21.png)