// import fetch from 'isomorphic-fetch';
const request = async (route, method = 'GET', data = {}) => {
  const baseUrl = process.env.API_URL || 'http://localhost:3009/api';
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
