// This script checks the public IP address of the backend server using the ipify API.(./check-ip.ps1) 
const axios = require("axios");

axios.get("https://api.ipify.org?format=json")
  .then(res => console.log("Backend Public IP:", res.data.ip))
  .catch(err => console.error(err));
