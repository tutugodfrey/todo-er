const http = require('http');
const httpProxy = require('http-proxy');
const fs = require('fs');

const servers = JSON.parse(fs.readFileSync('serversAddress.json')).servers;

const proxy = httpProxy.createProxyServer({});

const server = http.createServer((req, res) => {
  console.log(req.body, 'RRRRRRR')
  const target = servers.shift();
  proxy.web(req, res, { target: target });
  servers.push(target);
})

const port = 8080
server.listen(port, () => {
  console.log(`Proxy server listening on port ${port}`)
})
