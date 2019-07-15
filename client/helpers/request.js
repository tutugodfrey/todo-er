
const request = async (route, method = 'GET', data = {}) => {
  const baseUrl = process.env.API_URL || 'http://localhost:3005/api';
  let res
  if (method === 'GET') {
    res = await fetch(baseUrl + route,
      {
        method: method,
        headers: {
          'Content-Type': 'application/json',
          token: localStorage.getItem('token') || null
        },
      })
  } else {
    res = await fetch(baseUrl + route,
      {
        method: method,
        headers: {
          'Content-Type': 'application/json',
          token: localStorage.getItem('token') || null
        },
        body: JSON.stringify(data)
      })
  }
  return res.json();
}

export default request;
