
const request = async (route, method = 'GET', data = {}) => {
  // const baseUrl = 'http/localhost:3005/api';
  const res = await fetch(route,
  // fetch(route,
    {
      method: method,
      headers: {
        'Content-Type': 'application/json',
        token: localStorage.getItem('token') || null
      },
      body: JSON.stringify(data)
    })
    // .then(res => res.json())
    // .then(res => console.log(res, 'GGGGGGG'))
    // .catch(error => console.log(error))
  return res.json();
}

export default request;
