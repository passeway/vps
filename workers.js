export default {
  // 配置上游DNS服务器（按优先级排序）
  DNS_SERVERS: [
    { url: "https://dns.google/dns-query", host: "dns.google" },
    { url: "https://cloudflare-dns.com/dns-query", host: "cloudflare-dns.com" }
  ],
  
  async fetch(request, env, ctx) {
    try {
      // 检查请求方法
      if (request.method !== "GET" && request.method !== "POST") {
        return new Response("Method not allowed", { 
          status: 405,
          headers: { "Allow": "GET, POST" }
        });
      }
      
      // 处理 OPTIONS 预检请求
      if (request.method === "OPTIONS") {
        return this.handleOptions();
      }

      const url = new URL(request.url);
      
      // 仅允许 /dns-query 路径
      if (url.pathname !== "/dns-query") {
        return new Response("Not Found", { status: 404 });
      }

      // 检查内容类型是否正确（POST 请求）
      if (request.method === "POST") {
        const contentType = request.headers.get("content-type");
        if (!contentType || !contentType.includes("application/dns-message")) {
          return new Response("Invalid content type", { status: 415 });
        }
      }

      // 检查查询参数（GET 请求）
      if (request.method === "GET" && !url.searchParams.has("dns")) {
        return new Response("Missing 'dns' parameter", { status: 400 });
      }

      // 尝试所有配置的DNS服务器，直到成功或全部失败
      let lastError = null;
      
      for (const dnsServer of this.DNS_SERVERS) {
        try {
          const response = await this.queryDnsServer(request, url, dnsServer);
          return response; // 成功则立即返回
        } catch (error) {
          console.error(`Error querying ${dnsServer.host}:`, error);
          lastError = error;
          // 失败则继续尝试下一个服务器
        }
      }
      
      // 所有DNS服务器都失败
      return new Response(`All DNS servers failed. Last error: ${lastError?.message || 'Unknown error'}`, { 
        status: 502 
      });
    } catch (error) {
      // 全局错误处理
      console.error("DoH proxy error:", error);
      return new Response("Internal Server Error", { status: 500 });
    }
  },
  
  // 向特定DNS服务器发送查询
  async queryDnsServer(request, originalUrl, dnsServer) {
    // 构建目标 DoH 请求
    const targetURL = dnsServer.url + originalUrl.search;
    
    // 复制原始请求头，但移除可能导致问题的头
    const headers = new Headers();
    for (const [key, value] of request.headers) {
      // 跳过某些头，这些头应该由新请求生成
      if (!["host", "connection", "content-length", "cf-connecting-ip", "cf-ray"].includes(key.toLowerCase())) {
        headers.set(key, value);
      }
    }
    
    // 设置必要的头信息
    headers.set("Host", dnsServer.host);
    headers.set("Accept", "application/dns-message");
    
    // 创建新请求
    const modifiedRequest = new Request(targetURL, {
      method: request.method,
      headers: headers,
      body: request.method === "POST" ? request.body : null,
      redirect: "follow"
    });

    // 设置超时
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 3000); // 3秒超时，比全局超时短以便于切换
    
    try {
      // 执行请求
      const response = await fetch(modifiedRequest, { signal: controller.signal });
      
      // 检查响应状态
      if (!response.ok) {
        throw new Error(`Server returned ${response.status} ${response.statusText}`);
      }
      
      // 创建新响应头
      const responseHeaders = new Headers();
      for (const [key, value] of response.headers) {
        responseHeaders.set(key, value);
      }
      
      // 设置 CORS 和缓存控制
      responseHeaders.set("Access-Control-Allow-Origin", "*");
      responseHeaders.set("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
      responseHeaders.set("Access-Control-Allow-Headers", "Content-Type");
      
      // 添加一些基本缓存控制
      responseHeaders.set("Cache-Control", "public, max-age=60"); // 缓存60秒
      
      // 添加服务器信息头（可选，用于监控/调试）
      responseHeaders.set("X-Upstream-Server", dnsServer.host);
      
      // 返回响应
      return new Response(response.body, {
        status: response.status,
        headers: responseHeaders
      });
    } catch (fetchError) {
      if (fetchError.name === "AbortError") {
        throw new Error(`DNS request to ${dnsServer.host} timed out`);
      }
      throw fetchError; // 重新抛出其他错误
    } finally {
      clearTimeout(timeoutId); // 清除超时计时器
    }
  },
  
  // 处理 OPTIONS 请求（预检请求）
  handleOptions() {
    return new Response(null, {
      headers: {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type",
        "Access-Control-Max-Age": "86400"
      }
    });
  }
};
