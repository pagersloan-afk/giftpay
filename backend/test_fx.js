const axios = require("axios");

axios.get("https://api.exchangerate.host/latest?base=USD&symbols=NGN")
  .then(r => console.log(r.data))
  .catch(e => console.log(e));
