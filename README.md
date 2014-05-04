# Yunba PHP SDK

# API

## 构造器

~~~php
public function __construct(array $setup);
~~~

参数：
* array $setup 配置选项，包括server（可选）,port（可选）,appkey,debug（可选）三个参数


/**
	 * 初始化
	 * 
	 * @param callable $initCallback 初始化结果回调
	 * @param callable $recCallback 重新连接回调
	 */
	public function init($initCallback = null, $recCallback = null) {
		if (is_callable($initCallback)) {
			$this->_initCallback = $initCallback;
		}
		if (is_callable($recCallback)) {
			$this->_recCallback = $recCallback; 
		}
		
		$this->on("socketconnectack", array($this, "_initCallbackMethod"));
		$this->on("connack", array($this, "_connectCallbackMethod"));
		$this->on("disconnect", array($this, "_reconnectCallbackMethod"));
		$this->on("error", array($this, "_disconnectCallbackMethod"));
		$this->on("reconnect", array($this, "_disconnectCallbackMethod"));
		$this->on("reconnect_failed", array($this, "_disconnectCallbackMethod"));
		$this->on("suback", array($this,  "_subscribeCallbackMethod"));
		$this->on("message", array($this, "_messageCallbackMethod"));
		$this->on("puback", array($this, "_publishCallbackMethod"));
		$this->on("unsuback", array($this, "_unsubscribeCallbackMethod"));
		$this->_client->init();
	}
	
	/**
	 * 连接
	 * 
	 * @param callable $callback 回调
	 */
	public function connect($callback = null) {
		$this->emit("connect", array(
			"appkey" => $this->_appKey
		), $callback);
	}
	
	/**
	 * 断开连接
	 * 
	 * @param callable $callback 回调
	 */
	public function disconnect($callback = null) {
		$this->emit("disconn", array(), $callback);
	}
	
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
	
	/**
	 * 监听事件
	 * 
	 * @param string $event 事件名
	 * @param callable $callback 回调
	 */
	public function on($event, $callback) {
		$this->_client->on($event, $callback);
	}
	
	/**
	 * 订阅
	 * 
	 * @param array $args 参数，包括topic, qos两个参数
	 * @param callable $subscribeCallback 订阅结果回调
	 * @param callable $messageCallback 消息接收回调
	 */
	public function subscribe (array $args, $subscribeCallback = null, $messageCallback = null) {
		$channel = isset($args["topic"]) ? $args["topic"] : "";
		$qos = isset($args["qos"]) ? $args["qos"] : $this->_qos1;
		
		if (is_callable($messageCallback)) {
			if (!isset($this->_messageCallbacks[$channel])) {
				$this->_messageCallbacks[$channel] = array();
			}
			$this->_messageCallbacks[$channel][] = $messageCallback;
		}
		
		$this->emit("subscribe", array(
			"topic" => $channel,
			"qos" => $qos	
		), $subscribeCallback);
	}
	
	/**
	 * 取消订阅
	 * 
	 * @param array $args 参数，包括topic一个参数
	 * @param callable $callback 回调
	 */
	public function unsubscribe (array $args, $callback = null) {
		$channel = isset($args) ? $args["topic"] : "";
		$this->emit("unsubscribe", array(
			"topic" => $channel
		), $callback);
	}
	
	/**
	 * 发布消息
	 * 
	 * @param array $args 参数，包括topic, msg, qos三个参数
	 * @param callable $callback 回调
	 */
	public function publish (array $args, $callback = null) {
		$channel = isset($args["topic"]) ? $args["topic"] : "";
		$msg = isset($args["msg"]) ? $args["msg"] : "";
		$qos = isset($args["qos"]) ? $args["qos"] : $this->_qos1;
		$this->emit("publish", array(
			"topic" => $channel,
			"msg" => $msg,
			"qos" => $qos		
		), $callback);
	}
	
	/**
	 * 等待通讯
	 */
	public function wait() {
		$this->_client->keepAlive();
	}
