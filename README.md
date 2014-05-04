# Yunba PHP SDK

## API

### 构造器

~~~php
public function __construct(array $setup);
~~~

参数：
* array $setup 配置选项，包括server（可选）,port（可选）,appkey,debug（可选）三个参数

### 初始化
~~~php
public function init($initCallback = null, $recCallback = null);
~~~
参数：
* callable $initCallback 初始化结果回调函数
* $recCallback 重新连接回调函数

### 连接服务
~~~php
public function connect($callback = null);
~~~
参数
* callable $callback 连接成功或失败回调函数
	
### 断开连接
~~~php
public function disconnect($callback = null);
~~~
参数
* callable $callback 回调

### 触发事件
~~~php	
	/**
	 * 触发事件
	 * 
	 * @param string $event 事件名
	 * @param array $args 参数
	 * @param callable $callback 回调
	 */
	public function emit($event, array $args, $callback = null) {
		$this->_callId ++;
		if (is_callable($callback)) {
			$this->_callbacks[$this->_callId] = $callback;
		}
		
		$this->_client->emit($event, $args, null, array($this, "push_callback_" . $this->_callId));
	}
~~~

### 监听事件	
~~~php
	/**
	 * 监听事件
	 * 
	 * @param string $event 事件名
	 * @param callable $callback 回调
	 */
	public function on($event, $callback) {
		$this->_client->on($event, $callback);
	}
~~~

### 订阅
~~~php
public function subscribe (array $args, $subscribeCallback = null, $messageCallback = null);
~~~
参数：
* array $args 参数，包括topic, qos两个参数
* callable $subscribeCallback 订阅结果回调函数
* callable $messageCallback 消息接收回调函数

### 取消订阅
~~~php
public function unsubscribe (array $args, $callback = null);
~~~
参数：
* array $args 参数，包括topic一个选项
* callable $callback 回调函数

### 发布消息
~~~php	
public function publish (array $args, $callback = null);
~~~	
参数：
* array $args 要发布的消息的内容，包括topic, msg, qos三个选项
* callable $callback 回调函数

### 等待和服务间的通讯
~~~php
public function wait()；
~~~

## 使用示例
请见 examples/subscribe.php 和 examples/publish.php
