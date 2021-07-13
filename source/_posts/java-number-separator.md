---
title: JAVA实现数字千位分隔符
tags: 
  - Java
categories: 
  - Java
---
### DecimalFormat

```
new DecimalFormat(",###").format(new BigDecimal(1234567890).longValue())
```

### String.format

```
String.format("%,d",new BigDecimal(1234567890).longValue())
```

### 正则表达式

```
String.valueOf(new BigDecimal(1234567890).longValue()).replaceAll("(\\d)(?=(\\d{3})+\$)", "\$1,")
```