---
title: 是时候聊聊Google Authenticator了
date: 2024-01-03 00:00:00 +0800
categories: [Algorithms]
tags: [algorithms,totp,hotp]     # TAG names should always be lowercase
slug: '1429935389'
author: longlei
---

我们平常在进行账号安全设置的时候，平台都会建议设置二次验证。

然后会生成一个二维码，手机下载Google Authenticator，去扫描这个二维码，扫描完成后就会出现一组6位数字。

我们后续每次进行重要操作的时候，都会输入这组6位数字来进行安全验证。

关键这组数字还是动态的，每隔十几秒就会刷新一次，而且还可以断网使用。

![img](https://mll-typora.oss-cn-beijing.aliyuncs.com/2024-01-03-1704278192.jpeg)

当时就好了奇了，这么神奇吗，动态刷新还可以断网，他咋和服务器交互验证的呢。

## 先来用一用

探索真理最好的途径就是实践，想要搞懂它，我们不妨来使用使用。

首先，我们得先整一个二维码，这个二维码用来绑定Google Authenticator。

我们去[PSN](https://www.playstation.com/)的官网来弄一个，下面我已经弄好了，大家自行扫描。二维码别外传呦。<sub>骗你的，二维码是我自己生成的</sub>

<img src="https://mll-typora.oss-cn-beijing.aliyuncs.com/2024-01-03-1704279415.png" alt="auth" style="zoom: 50%;" />

然后，掏出我们的 iPhone 100 Pro Max 来扫描一下。

<img src="https://mll-typora.oss-cn-beijing.aliyuncs.com/202401032157036.JPG" alt="IMG_4413" style="zoom: 33%;" />

扫描完了。

然后就得到了神奇的6位数 **213 993**，这就是我们以后进行安全认证的法宝了。

除了6位数字，我们还看到了其他的一些信息，我们来一一说明一下

- Sony 一般都是平台信息
- longlei@longlei.me 一般是账号，和Sony组合起来就构成了验证码的标识，来说明验证码使用的场景
  - 当然，这两个也不是固定的，有的平台不按套路出牌，给的是他们认为的唯一标识
  - 总之我们知道他是来标识用户的就OK，这样方便我们添加多个验证码的时候快速找到对应平台和账号
- 213 993 就是我们的验证码了，以后每次重要操作的时候都需要他
- <a name="expired">最右边有个圆圈，这个代表刷新时间，一般是15s-20s</a>



然后我们来使用一下它。使用它就需要进行一些重要的操作，比如说充钱

![img](https://mll-typora.oss-cn-beijing.aliyuncs.com/202401032212222.jpeg)

充钱也不是必要，毕竟PS Plus我都舍不得买，说多了都是泪。

那我们进行下一步重要的操作，登录:

<img src="https://mll-typora.oss-cn-beijing.aliyuncs.com/2024-01-03-1704274098.png" alt="image-20240103172817633" style="zoom: 20%;" />

来到了我们期盼的页面，需要输入刚刚生成的6位数了，然后我们就见证了结果，登录成功。

## 是什么

看来我们会使用它了，但是对于我们的目标还是满脸问号。看来求学之路还得继续前进。

下面就让我们了解了解Google Authenticator到底是什么东东，竟然这么神奇。

探索真理最好的途径就是实践，而实践的秘籍就在google，我们这就去google一下。

<img src="https://mll-typora.oss-cn-beijing.aliyuncs.com/202401032232913.png" alt="image-20240103223227760" style="zoom: 50%;" />

google告诉了我们它在[维基百科](https://zh.wikipedia.org/zh-cn/Google%E8%BA%AB%E4%BB%BD%E9%AA%8C%E8%AF%81%E5%99%A8)的信息，还贴心的告诉了我们[源码地址](https://github.com/google/google-authenticator)。

看完维基百科，我感觉我又知道了，开始膨胀了。

![img](https://mll-typora.oss-cn-beijing.aliyuncs.com/202401032255148.jpeg)

下面我就来好好说道说道它。

**Google Authenticator**是一款基于[TOTP](https://zh.wikipedia.org/wiki/基于时间的一次性密码算法)与[HOTP](https://zh.wikipedia.org/wiki/HOTP)算法的两步验证软件令牌。

用户会将APP安装到手机，它会基于算法生成一组6位数的一次性密码。

而服务器也会基于此算法生成一组6位数一次性密码。

此时就可以用服务器生成的6位数和APP生成的6位数进行比较，如果一致，则认为验证通过。

有人就问了，6位数不是可以动态刷新嘛，APP也可以断网使用，如果没有网络，它怎么和服务器保持联系，怎么动态刷新，如果不联系，那岂不是所以网站生成的6位数都一样了。

**好问题**

![img](https://mll-typora.oss-cn-beijing.aliyuncs.com/202401032316262.gif)

回答这个问题，我们得先了解一下这个算法。

俗话说的好，知彼知己，方可百战不殆。只有了解了算法的生成逻辑，我们才可以知道他怎么和服务保持的联系。

下面请出我们的主角，[TOTP](https://zh.wikipedia.org/wiki/基于时间的一次性密码算法)算法

TOTP是 Time-based One-Time Password 的缩写，是**基于实践的一次性密码算法**，是一种根据**提前预定好的密钥**和**当前时间**计算一次性密码的算法。

这里有两个关键词：

- 提前预定好的密钥，就是服务器和APP提前预定好的密钥
  - 那什么时候交互呢，APP和服务器唯一的交互就是扫描二维码，看来密钥在此时就已经共享，并保存在两方本地了
- 当前时间，就是当前时间
  - 所以，如果APP时间和服务器时间有误差，算法生成的结果就会有误差

有人又会有了新问题？来吧，进步就是在不断提问中前行的。

如果这个算法是根据当前时间计算的，那当前时间每一秒都会发生变化，而我们看到验证码，到输入到网站并验证，中间间隔很久，那服务器怎么会和APP算法生成的结果一致呢。

果然是个好问题，但是算法已经解决了这种场景。

由于网络延迟或时间不同步，可能导致服务器和APP生成的结果不一致，所以这个当前时间，是一个时间切片，也就是一段时间，这个时间段可以服务器和APP自主协商，但通常是以30秒为一段。

只要在这一段时间内，算法生成的结果都是一样的。

画个图吧，会更直白一点。

![未命名文件](https://mll-typora.oss-cn-beijing.aliyuncs.com/2024-01-04-1704337186.jpg)

图片内，0s到30s区间内，不管是哪一刻，所生成的验证码都是唯一的，到了下一个区间片段，生成的验证码才会切换。



那你上面提到过，说<a href="#expired">APP内的验证码刷新时间一般是15s-20s</a>，那是不是说，他们之间协商的时间段为15s-20s为一个区间呢。

哈哈，你很聪明，但是不对。

APP验证码有效期会长于屏幕上显示的时间（通常是2倍或更长）。这是因为你看到验证码到输入,再到服务器验证会有一段操作时间，为了给你操作而作出的让步。

## 要不动手写一个

纸上得来终觉浅，绝知此事要躬行。

俗话说，好记性不如烂笔头，要不以我这超凡的记忆力，写完了，我也就忘完了。

探索真理最好的途径就是实践，下面就让我们手写一下吧。

写之前，我们先来了解一下这个算法的实现逻辑，否则不知道实现逻辑，那写起来岂不是一脸抓瞎。

要想知道[TOTP](https://zh.wikipedia.org/wiki/%E5%9F%BA%E4%BA%8E%E6%97%B6%E9%97%B4%E7%9A%84%E4%B8%80%E6%AC%A1%E6%80%A7%E5%AF%86%E7%A0%81%E7%AE%97%E6%B3%95)，那我们先了解了解HOTP，因为TOTP是扩展的HOTP。

要想知道[HOTP](https://zh.wikipedia.org/wiki/%E5%9F%BA%E4%BA%8E%E6%95%A3%E5%88%97%E6%B6%88%E6%81%AF%E9%AA%8C%E8%AF%81%E7%A0%81%E7%9A%84%E4%B8%80%E6%AC%A1%E6%80%A7%E5%AF%86%E7%A0%81%E7%AE%97%E6%B3%95)，那我们先了解了解[RFC 4226标准](https://rfc2cn.com/rfc4226.html)，因为HOTP是遵循的此标准。

大家可以先自己跳转看看，我这里替大家总结总结，RFC 4226标准概括就是这个公式:
$$
HOTP(K,C) = Truncate(HMAC-SHA-1(K,C))
$$
下面我们来解释解释这个公式

- K 共享密钥，也就是之前提到的通过二维码扫描方式共享的密钥。
  - 这个密钥一般通过Base32加密后再共享
- C 计数器，是一个8byte的数值，需要服务器和客户端同步。
  - TOTP和HOTP不同点也就在于 C ，TOTP在HOTP上做的扩展，利用时间切片来生成这个 C

- HMAC-SHA-1函数 一种加密算法，大家可以自行查阅
- Truncate函数 把算法结果转换到6位数字，这个我们会在后续详细说明

看完了这个公式，是不是感觉非常简单，其实也不难。

有了公式，我们就开始编码，用代码实现它。

### 1. 共享密钥 K 和 C

根据公式我们首先得有共享密钥 K 和 一个计数器 C

我们先生成一个共享密钥，这个大家随意生成，我就直接用上面二维码使用的密钥了，也方便我们后续验证码的对比

我的生成结果是 **Ea1HMhixf)b1#uyeLCgS**

生成完以后，还不可以直接使用，正如上面公式中提到的 **K** ，我们还需要通过Base32加密后再共享

```Java
import cn.hutool.core.codec;

public String generateK(){
	String str = "Ea1HMhixf)b1#uyeLCgS";
	String shareSecret = Base32.encode(str);
	// shareSecret = IVQTCSCNNBUXQZRJMIYSG5LZMVGEGZ2T
	return shareSecret;
}
```

这个 shareSecret 就是我们真正需要共享的密钥。

C 是一个8byte的数值，为了方便我们先随便写一个数字，然后转换成8byte就OK。

```java
import java.nio.ByteBuffer;

public byte[] generateC(){
	long C = 123456L;
	return ByteBuffer.allocate(8) // 分配8byte
		.putLong(C)	// 写入计数器
		.array();
}
```

还可以，目前一切顺利，看来离成功已经不远了。

### 2. HMACSHA1 加密

接下来我们进行公式的第二步，进行HMACSHA1加密。

HMACSHA1 是统一的，我们直接找开源第三方就OK，或者使用对应语言原生编写。

这里我是用[开源框架Hutool](https://hutool.cn/)来编写。

```java
import cn.hutool.crypto.SecureUtil;

String K = generateK();
byte[] C = generateC();

public byte[] hmacsha1(String K, byte[] C){
	// 需要对 K 进行Base32解码
	byte[] KByte = Base32.decode(K);
	return SecureUtil.hmacSha1(KByte).digest(C);
}
```

这里为什么需要对K进行解码呢，我们生成的时候不进行编码，直接使用，这里不就不需要解码了。

因为对于APP来说 K 一般都是服务器共享的，服务器在共享前已经进行了编码，我们这里模拟一下，所以这里需要解码。

依旧一切还OK，我们继续。

### 3. Truncate 函数

这个函数很重要，也是相对上两步比较难理解的，不过理通了也相当easy。

说这个函数前，我们先聊聊 **hmacsha1** 返回的结果是个什么样子的。

这个 byte[] 是一个固定20长度的数组，那我们先把它拆成20份来看看。

如下面所示

```
   -------------------------------------------------------------
   | Byte Number                                               |
   -------------------------------------------------------------
   |00|01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|
   -------------------------------------------------------------
   | Byte Value                                                |
   -------------------------------------------------------------
   |1f|86|98|69|0e|02|ca|16|61|85|50|ef|7f|19|da|8e|94|5b|55|5a|
   -------------------------------***********----------------++|
```

- Byte Number 代表索引顺序，从0-19
- Byte Value 代表每个位置的值（转成HEX后）

这样，我们就对整个结果集有了很直观的感受。

1. 我们首先获取到最后一个字节，即`Byte Number=19`，可以看到他的值是`5a`
2. 该值的二进制是`01011010`，我们获取该值的低四位的值，即`1010`，转换成十进制后是`10`，转换后的十进制最大范围是(0-15)
3. 那我们就从`Byte Number=10`开始，获取`4`个字节，即 `50`、`ef`、`7f`、`19`，我们就得到了一个值`0x50ef7f19`
4. `0x50ef7f19`的二进制是`01010000111011110111111100011001`,我们丢弃`MSB(最高有效位)`，即最左的一位
   1. 因为MSB是0，所以我们丢弃完还是0，如果是1，我们丢弃完就变成了0，e.g. 1010101010 -> 0010101010

5. 丢弃完MSB后，我们得到了一个新值，我们的例子中MSB=0，所以两个值是一样的
6. 然后我们对这个值取模 `0x50ef7f19 mod 10^6`
   1. 10^6 是因为我们需要获取6位验证码，如果需要8位则需要对 10^8 取模
7. 我们拿到了最终的结果 `HOTP = 872921`
   1. 如果取模结果不足6位数，我们在前面补0就OK，e.g. 72921 -> 072921

下面我们用代码实现这个流程

```java
private String truncate(byte[] hmac_result){
	int offset = hmac_result[19] & 0xf;
	int bin_code = (hmac_result[offset]  & 0x7f) << 24
		| (hmac_result[offset+1] & 0xff) << 16
		| (hmac_result[offset+2] & 0xff) <<  8
		| (hmac_result[offset+3] & 0xff);
	bin_code = bin_code % (int)Math.pow(10,6);
	return String.format("%06d", bin_code);
}
```

步骤相对比较繁琐，我们画个图来概括一下整个流程

<img src="https://mll-typora.oss-cn-beijing.aliyuncs.com/2024-01-04-1704357134.jpg" alt="img" style="zoom:50%;" />

看完，是不是觉得也没有很难，也很简单嘛。

我们目前实现的是HOTP的算法逻辑，TOTP是在此基础上对 C 的改造

相对于算法，这个代码就很easy，我们来写一下

```java
public byte[] generateC(){
	long C = (System.currentTimeMillis()/1000 - 0L )/30L;
	return ByteBuffer.allocate(8) // 分配8byte
		.putLong(C)	// 写入计数器
		.array();
}
```

改造的地方就在于

```java
// long C = 123456L;
long C = (System.currentTimeMillis()/1000 - 0L )/30L;
```

我们来讲讲各个部分

- System.currentTimeMillis() 当前时间，也是截止时间
- 0L 开始时间，默认从0开始
- 30L 时间区间跨度，默认是30s

我们再画个图来概括一下



<img src="https://mll-typora.oss-cn-beijing.aliyuncs.com/2024-01-04-1704357159.jpg" alt="img" style="zoom:50%;" />

到此，我们已经完成了TOTP的代码编写。

我迫不及待的把结果和Google Authenticator进行了对比，很完美，很满意。



下面献上完整代码。

```java
import cn.hutool.core.codec.Base32;
import cn.hutool.crypto.SecureUtil;

import java.nio.ByteBuffer;

public class TOTP {
    public static void main(String[] args) {
        String K = generateK();
        byte[] C = generateC();
        System.out.println(truncate(hmacsha1(K,C)));;
    }
    public static String generateK(){
        String str = "Ea1HMhixf)b1#uyeLCgS";
        String shareSecret = Base32.encode(str);
        // shareSecret = IVQTCSCNNBUXQZRJMIYSG5LZMVGEGZ2T
        return shareSecret;
    }
    public static byte[] generateC(){
        long C = (System.currentTimeMillis()/1000 - 0L )/30L;
        return ByteBuffer.allocate(8) // 分配8byte
                .putLong(C)	// 写入计数器
                .array();
    }
    public static byte[] hmacsha1(String K, byte[] C){
        // 需要对 K 进行Base32解码
        byte[] KByte = Base32.decode(K);
        return SecureUtil.hmacSha1(KByte).digest(C);
    }
    private static String truncate(byte[] hmac_result){
        int offset = hmac_result[19] & 0xf;
        int bin_code = (hmac_result[offset]  & 0x7f) << 24
                | (hmac_result[offset+1] & 0xff) << 16
                | (hmac_result[offset+2] & 0xff) <<  8
                | (hmac_result[offset+3] & 0xff);
        bin_code = bin_code % (int)Math.pow(10,6);
        return String.format("%06d", bin_code);
    }
}
```

##  万事没有十全十美

到这，我们算是对Google Authenticator了解一二了，谁说不是呢，我们还动手实践，写了一个出来呢。

那它是不是就很完美了，没有什么不足了。

有人就说了，是的呢，它好处多着呢，比如:

- 可以动态刷新，避免了有人知道了验证码被盗用
- 还可以断网使用，即使没有网络了，也能获取验证码

可万事再有美好一面的时候，总也会有些不足之处，下面我就给你列一列。

1. 尽管攻击者需要实时托管凭证，而不能之后收集，但是验证码还是跟密码一样可能被钓鱼。

2. 6位数字密码对于暴力破解来说非常容易，因此必须得限制验证次数。

   有人问啥是暴力破解，就是无限重试，直到成功。

3. 如果有人拿到了密钥，就可以根据算法随意生成验证码。

4. 由于算法是基于时间的，如果APP和服务器时间不同步，也会导致验证码生成错误。

5. 所有基于一次性密码的认证方案都会暴露于[会话劫持](https://zh.wikipedia.org/wiki/会话劫持)当中，比如可以在登录后强征用户的会话。

尽管也有不足，但Google Authenticator仍然比单独使用传统静态密码验证的安全性强很多。

上述的一些问题我们也可以通过一些方法解决（比如为防止暴力破解，可以增加验证码的位数，或者使用多个验证码同时验证）。

这次我们就先到这吧。

又长知识了，我得去膨胀一会。



![img](https://mll-typora.oss-cn-beijing.aliyuncs.com/2024-01-04-1704338702.jpeg)

漏了一件事：

二维码是怎么生成的呢，里面的格式是什么，直接把密钥放进去就好了吗

也是要遵循一定格式的，就是下面这个，我自己用的

```
otpauth://totp/Sony:longlei@longlei.me?secret=IVQTCSCNNBUXQZRJMIYSG5LZMVGEGZ2T
```

应该没有遗漏的喽

那这次我们就先到这吧。

---

参考资料:

- [HOTP 维基百科](https://zh.wikipedia.org/wiki/%E5%9F%BA%E4%BA%8E%E6%95%A3%E5%88%97%E6%B6%88%E6%81%AF%E9%AA%8C%E8%AF%81%E7%A0%81%E7%9A%84%E4%B8%80%E6%AC%A1%E6%80%A7%E5%AF%86%E7%A0%81%E7%AE%97%E6%B3%95)
- [TOTP 维基百科](https://zh.wikipedia.org/wiki/%E5%9F%BA%E4%BA%8E%E6%97%B6%E9%97%B4%E7%9A%84%E4%B8%80%E6%AC%A1%E6%80%A7%E5%AF%86%E7%A0%81%E7%AE%97%E6%B3%95)
- [RFC 4226标准](https://rfc2cn.com/rfc4226.html)
- [RFC 6238标准](https://rfc2cn.com/rfc6238.html)
- [动态密码TOTP](https://zhaoyang.me/posts/totp-algorithm/)





