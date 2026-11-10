const axios = require('axios');

const secret = () => process.env.PAYSTACK_SECRET_KEY || process.env.PAYSTACK_SECRET;

function client() {
  const key = secret();
  if (!key) throw new Error('PAYSTACK_TRANSFER_SECRET_MISSING');
  return axios.create({
    baseURL: 'https://api.paystack.co',
    timeout: 30000,
    headers: {
      Authorization: `Bearer ${key}`,
      'Content-Type': 'application/json',
    },
  });
}

async function request(method, path, data, params) {
  const response = await client().request({ method, url: path, data, params });
  if (!response.data?.status) {
    const error = new Error(response.data?.message || 'Paystack request failed');
    error.providerData = response.data;
    error.httpStatus = response.status;
    throw error;
  }
  return response.data.data;
}

module.exports = { request };
