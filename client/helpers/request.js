
const request = async (route, method = 'GET', data = {}) => {
  console.log(process.env.API_URL, 'API_URL');
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
  const response = await res.json();
  response.message ? console.log(response.message) : null
  if (response.message && response.message === 'invalid token' ) {
    localStorage.clear();
    location.pathname= '/signin'
  }
  return response;
}

export default request;
