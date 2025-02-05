/*
    Real-time subtitle translation for PotPlayer using LM Studio API
*/

// 插件信息函数
string GetTitle() {
    return "{$CP949=本地 AI 번역$}{$CP950=本地 AI 翻譯$}{$CP0=LM Studio 英译中$}";
}

string GetVersion() {
    return "1.6";
}

string GetDesc() {
    return "{$CP949=本地 AI를 사용한 실시간 자막 번역$}{$CP950=使用本地 AI 的實時字幕翻譯$}{$CP0=Real-time subtitle translation using Local AI$}";
}

string GetLoginTitle() {
    return "{$CP949=LM Studio 모델 구성$}{$CP950=LM Studio 模型配置$}{$CP0=LM Studio Model Configuration$}";
}

string GetLoginDesc() {
    return "{$CP949=모델 이름을 입력하십시오 (예: model-identifier, LM Studio에서 제공된 모델).$}{$CP950=請輸入模型名稱（例如 model-identifier，LM Studio 提供的模型）。$}{$CP0=Please enter the model name (e.g., model-identifier provided by LM Studio).$}";
}

string GetUserText() {
    return "{$CP949=모델 이름 (현     : " + selected_model + ")$}{$CP950=模型名稱 (目前: " + selected_model + ")$}{$CP0=Model Name (Current: " + selected_model + ")$}";
}

string GetPasswordText() {
    return "{$CP949=API 키:$}{$CP950=API 金鑰:$}{$CP0=API Key:$}";
}

// 全局变量
string api_key = "";
string selected_model = "model-identifier"; // 默认使用 LM Studio 的模型标识符
string UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)";
string api_url = "http://127.0.0.1:1234/v1/chat/completions"; // LM Studio 本地 API 地址
string context = "";

// 支持的语言列表
array<string> LangTable = 
{
    "Auto", "af", "sq", "am", "ar", "hy", "az", "eu", "be", "bn", "bs", "bg", "ca",
    "ceb", "ny", "zh-CN",
    "zh-TW", "co", "hr", "cs", "da", "nl", "en", "eo", "et", "tl", "fi", "fr",
    "fy", "gl", "ka", "de", "el", "gu", "ht", "ha", "haw", "he", "hi", "hmn", "hu", "is", "ig", "id", "ga", "it", "ja", "jw", "kn", "kk", "km",
    "ko", "ku", "ky", "lo", "la", "lv", "lt", "lb", "mk", "ms", "mg", "ml", "mt", "mi", "mr", "mn", "my", "ne", "no", "ps", "fa", "pl", "pt",
    "pa", "ro", "ru", "sm", "gd", "sr", "st", "sn", "sd", "si", "sk", "sl", "so", "es", "su", "sw", "sv", "tg", "ta", "te", "th", "tr", "uk",
    "ur", "uz", "vi", "cy", "xh", "yi", "yo", "zu"
};

// 获取源语言列表
array<string> GetSrcLangs() {
    array<string> ret = LangTable;
    return ret;
}

// 获取目标语言列表
array<string> GetDstLangs() {
    array<string> ret = LangTable;
    return ret;
}

// 登录接口，用于输入模型名称和 API Key
string ServerLogin(string User, string Pass) {
    // 去除首尾空格
    selected_model = User.Trim();
    api_key = Pass.Trim();

    selected_model.MakeLower();

    if (selected_model.empty()) {
        HostPrintUTF8("{$CP949=모델 이름이 입력되지 않았습니다. 유효한 모델 이름을 입력하십시오.$}{$CP950=模型名稱未輸入，請輸入有效的模型名稱。$}{$CP0=Model name not entered. Please enter a valid model name.$}\n");
        selected_model = "model-identifier"; // 使用默认模型
    }
    // 取消对特定模型的限制，允许使用 LM Studio 支持的任意模型

    // 保存设置到临时存储，添加 lmstudio_ 前缀避免冲突
    HostSaveString("api_key_lmstudio", api_key);
    HostSaveString("selected_model_lmstudio", selected_model);

    HostPrintUTF8("{$CP949=API 키와 모델 이름이 성공적으로 설정되었습니다.$}{$CP950=API 金鑰與模型名稱已成功配置。$}{$CP0=API Key and model name successfully configured.$}\n");
    return "200 ok";
}

// 登出接口，清除模型名称和 API Key
void ServerLogout() {
    api_key = "";
    selected_model = "model-identifier"; // 重置为默认模型
    HostSaveString("api_key_lmstudio", "");
    HostSaveString("selected_model_lmstudio", selected_model);
    HostPrintUTF8("{$CP949=성공적으로 로그아웃되었습니다.$}{$CP950=已成功登出。$}{$CP0=Successfully logged out.$}\n");
}

// JSON 字符串转义函数
string JsonEscape(const string &in input) {
    string output = input;
    output.replace("\\", "\\\\");
    output.replace("\"", "\\\"");
    output.replace("\n", "\\n");
    output.replace("\r", "\\r");
    output.replace("\t", "\\t");
    return output;
}

// 翻译函数
string Translate(string Text, string &in SrcLang, string &in DstLang) {
    // 从临时存储中加载模型名称，使用新的键名
    selected_model = HostLoadString("selected_model_lmstudio", "model-identifier");

    if (DstLang.empty() || DstLang == "{$CP949=자동 감지$}{$CP950=自動檢測$}{$CP0=Auto Detect$}") {
        HostPrintUTF8("{$CP949=목표 언어가 지정되지 않았습니다.$}{$CP950=目標語言未指定。$}{$CP0=Target language not specified.$}\n");
        return "";
    }

    string UNICODE_RLE = "\u202B";

    if (SrcLang.empty() || SrcLang == "{$CP949=자동 감지$}{$CP950=自動檢測$}{$CP0=Auto Detect$}") {
        SrcLang = "";
    }

    // 构建提示词
    string prompt = "你是一名专业翻译。请将以下字幕文本翻译";
    if (!SrcLang.empty()) {
        prompt += "从" + SrcLang;
    }
    prompt += "翻译成" + DstLang + "。请注意：\n";
    prompt += "1. 保持原文的语气和风格\n";
    prompt += "2. 确保译文与上下文保持连贯\n";
    prompt += "3. 建立术语库，确保前后文对专有名词的翻译结果相同\n";
    prompt += "4. 只需提供译文，无需解释\n\n";

    if (!context.empty()) {
        prompt += "上下文参考：\n'''\n" + context + "\n'''\n\n";
    }
    prompt += "待翻译文本：\n'''\n" + Text + "\n'''";

    // JSON 转义
    string escapedPrompt = JsonEscape(prompt);

    // 构建请求数据
    string requestData = "{\"model\":\"" + selected_model + "\",\"messages\":[{\"role\":\"user\",\"content\":\"" + escapedPrompt + "\"}]}";
    string headers = "Content-Type: application/json";

    // 发送请求
    string response = HostUrlGetString(api_url, UserAgent, headers, requestData);
    if (response.empty()) {
        HostPrintUTF8("{$CP949=번역 요청이 실패했습니다.$}{$CP950=翻譯請求失敗。$}{$CP0=Translation request failed.$}\n");
        return "";
    }

    // 解析响应
    JsonReader Reader;
    JsonValue Root;
    if (!Reader.parse(response, Root)) {
        HostPrintUTF8("{$CP949=API 응답을 분석하지 못했습니다.$}{$CP950=無法解析 API 回應。$}{$CP0=Failed to parse API response.$}\n");
        return "";
    }

    JsonValue choices = Root["choices"];
    if (choices.isArray() && choices[0]["message"]["content"].isString()) {
        string translatedText = choices[0]["message"]["content"].asString();
        if (DstLang == "fa" || DstLang == "ar" || DstLang == "he") {
            translatedText = UNICODE_RLE + translatedText;
        }
        SrcLang = "UTF8";
        DstLang = "UTF8";
        return translatedText;
    }

    HostPrintUTF8("{$CP949=번역이 실패했습니다.$}{$CP950=翻譯失敗。$}{$CP0=Translation failed.$}\n");
    return "";
}

// 插件初始化
void OnInitialize() {
    HostPrintUTF8("{$CP949=LM Studio 번역 플러그인이 로드되었습니다.$}{$CP950=LM Studio 翻譯插件已加載。$}{$CP0=LM Studio translation plugin loaded.$}\n");
    // 从临时存储中加载模型名称和 API Key（如果已保存），使用新的键名
    api_key = HostLoadString("api_key_lmstudio", "");
    selected_model = HostLoadString("selected_model_lmstudio", "model-identifier");
    if (!api_key.empty()) {
        HostPrintUTF8("{$CP949=저장된 API 키와 모델 이름이 로드되었습니다.$}{$CP950=已加載保存的 API 金鑰與模型名稱。$}{$CP0=Saved API Key and model name loaded.$}\n");
    }
}

// 插件结束
void OnFinalize() {
    HostPrintUTF8("{$CP949=LM Studio 번역 플러그인이 언로드되었습니다.$}{$CP950=LM Studio 翻譯插件已卸載。$}{$CP0=LM Studio translation plugin unloaded.$}\n");
}
