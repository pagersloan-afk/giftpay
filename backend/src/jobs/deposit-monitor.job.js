const { scanReservedAccounts } = require("../services/deposit-monitor.service");
let timer = null;
let running = false;

async function runDepositMonitor() {
  if (running) {
    console.log("Monnify monitor: prior scan still running; skipping tick");
    return;
  }
  running = true;
  try { await scanReservedAccounts(); }
  catch (e) { console.error("Monnify monitor scan error:", e.message || e); }
  finally { running = false; }
}

function startDepositMonitor() {
  if (timer) return;
  const interval = Math.max(5000, Number(process.env.MONNIFY_DEPOSIT_POLL_INTERVAL_MS || 30000));
  console.log(`Monnify deposit monitor enabled; interval=${interval}ms`);
  runDepositMonitor();
  timer = setInterval(runDepositMonitor, interval);
}
function stopDepositMonitor() {
  if (timer) clearInterval(timer);
  timer = null;
}
module.exports = { startDepositMonitor, stopDepositMonitor, runDepositMonitor };
