
const request = async (route, method = 'GET', data = {}) => {
  const baseUrl = 'http://localhost:3005/api';
  const res = await fetch(baseUrl + route,
    {
      method: method,
      headers: {
        'Content-Type': 'application/json',
        token: localStorage.getItem('token') || null
      },
      body: JSON.stringify(data)
    })
  return res.json();
}

export default request;
