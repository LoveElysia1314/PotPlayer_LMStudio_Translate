
<br>
<br>参考
<br>https://github.com/yxyxyz6/PotPlayer_ollama_Translate
<br>的项目，使用ChatGPT修改。
<br>下载.as 和.ico文件，粘贴到potplayer\Extension\Subtitle\Translate文件夹下。
<br>在.as代码中删除了特定模型名限制，不需要再对.as文件做修改，只需要在 "Potplayer-选项-拓展功能-实时字幕翻译-LM Studio英译中-账户设置-Model Name" 处正确填写模型名就能使用。
<br>使用视频教程可以参考：（不需要修改as文件中的模型选择，可以自行修改提示词）
<br>B站-复变的兔子洞：https://www.bilibili.com/video/BV1XBqyYLE7y/?spm_id_from=333.1387.favlist.content.click&vd_source=d9367c081bd4aa6b79e1f7590071a87e
<br>B站-恩赐Cadou：https://www.bilibili.com/video/BV1vcCgYNEZV/?spm_id_from=333.1007.top_right_bar_window_history.content.click&vd_source=d9367c081bd4aa6b79e1f7590071a87e

------------------------------------------------------------------------------------------------------

（ChatGPT生成）下面给出修改后的插件代码以及详细使用教程。主要修改内容包括：

1. **接口地址更新**  
   将 API 地址由原来的 Ollama 地址改为 LM Studio 本地 API 地址（示例中使用 http://127.0.0.1:1234/v1/chat/completions）。

2. **模型名称配置调整**  
   – 修改默认模型名称为 “model-identifier”，并取消了对固定模型的限制。  
   – 更新了登录提示说明，提示用户填写 LM Studio 支持的模型标识符。

3. **界面文本更新**  
   将插件信息中涉及 “ollama” 的文字改为 “LM Studio”，确保用户界面和提示信息与 LM Studio 环境保持一致。

4. **临时存储键名更新**  
   使用 “api_key_lmstudio” 与 “selected_model_lmstudio” 作为临时存储键，避免与原先插件冲突。


### 使用教程

1. **准备工作**  
   – 请确保已安装并启动 LM Studio 本地服务。  
   – 默认示例中 LM Studio 服务监听地址为 `http://127.0.0.1:1234`。若您的服务端口或协议有所不同，请相应修改代码中变量 `api_url`。  
   – 获取 LM Studio API Key（若需要验证）以及对应的模型标识符。有关 LM Studio API 的详细说明，请参阅 [LM Studio API 文档](https://lm-studio.cn/docs/api/endpoints/openai) cite0†LM Studio 文档。

2. **配置插件**  
   – 将修改后的插件文件保存为 `.as` 后缀文件，并放置在 PotPlayer 插件目录下。  
   – 启动 PotPlayer 后，在插件配置界面中进入 “LM Studio 모델 구성”（LM Studio 模型配置），按提示输入：  
     - 模型名称：填写 LM Studio 提供的模型标识符（例如：`model-identifier` 或其它有效标识）。  
     - API Key：填写您的 LM Studio API Key（如果 LM Studio 环境要求验证）。

3. **使用实时字幕翻译**  
   – 在播放视频时，插件会自动调用 LM Studio 的 `/v1/chat/completions` 接口进行字幕翻译。  
   – 翻译请求将构建一条提示词（包含源文本、上下文信息以及目标语言要求），并通过 LM Studio 本地 API 获取翻译结果。  
   – 翻译结果将按照预期格式显示在 PotPlayer 界面上。

4. **调试与日志**  
   – 若翻译请求失败或结果异常，请检查 LM Studio 服务是否正常运行以及网络连接是否正常。  
   – 查看 PotPlayer 日志窗口中输出的信息，以确认 API 请求、返回数据及错误提示。

5. **登出与重置**  
   – 使用插件内的登出功能可清除当前配置的 API Key 和模型名称，重置为默认状态。

按照以上步骤完成配置后，即可使用 LM Studio 本地 API 实现 PotPlayer 的实时字幕翻译。

---

以上就是修改后的代码及详细使用说明，希望能帮助你顺利实现 LM Studio 环境下的实时字幕翻译功能。
