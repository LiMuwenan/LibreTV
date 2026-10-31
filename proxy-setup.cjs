const { ProxyAgent, fetch: undiciFetch } = require('undici');
const net = require('net');

if (!globalThis.__libretvProxyPatched) {
  const originalFetch = globalThis.fetch;
  const proxyUrl = (process.env.LIBRETV_PROXY || 'http://localhost:7890').trim();

  function canConnect(host, port) {
    return new Promise((resolve) => {
      const socket = net.connect({ host, port });
      const finish = (ok) => { socket.destroy(); resolve(ok); };
      socket.setTimeout(1200);
      socket.once('connect', () => finish(true));
      socket.once('timeout', () => finish(false));
      socket.once('error', () => finish(false));
    });
  }

  let agentPromise = null;

  function resolveAgent() {
    if (!agentPromise) {
      agentPromise = (async () => {
        try {
          const url = new URL(proxyUrl);
          const port = Number(url.port) || (url.protocol === 'https:' ? 443 : 80);
          if (await canConnect(url.hostname, port)) {
            console.log('[proxy-setup] upstream requests via proxy:', proxyUrl);
            return new ProxyAgent(proxyUrl);
          }
          console.log('[proxy-setup] proxy unreachable, using direct connection:', proxyUrl);
        } catch (e) {
          console.log('[proxy-setup] invalid proxy url, using direct connection:', e.message);
        }
        return null;
      })();
    }
    return agentPromise;
  }

  globalThis.fetch = async (input, init = {}) => {
    const agent = await resolveAgent();
    if (agent) return undiciFetch(input, { ...init, dispatcher: agent });
    return originalFetch(input, init);
  };

  globalThis.__libretvProxyPatched = true;
}
