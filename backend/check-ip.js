const axios = require("axios");

axios.get("https://api.ipify.org?format=json")
  .then(res => console.log("Backend Public IP:", res.data.ip))
  .catch(err => console.error(err));
