const https = require("https");

function requestJson(url) {
  return new Promise((resolve, reject) => {
    const request = https.get(
      url,
      {
        headers: {
          Accept: "application/json",
          "User-Agent": "GiftPay-Security/1.0",
        },
      },
      (response) => {
        let body = "";

        response.on("data", (chunk) => {
          body += chunk;
        });

        response.on("end", () => {
          if (response.statusCode < 200 || response.statusCode >= 300) {
            return reject(
              new Error(
                `IP geolocation returned HTTP ${response.statusCode}`,
              ),
            );
          }

          try {
            resolve(JSON.parse(body));
          } catch (error) {
            reject(
              new Error(
                "Invalid JSON returned by IP geolocation service",
              ),
            );
          }
        });
      },
    );

    request.setTimeout(5000, () => {
      request.destroy(
        new Error("IP geolocation request timed out"),
      );
    });

    request.on("error", reject);
  });
}

function normalizeIp(ip) {
  if (!ip) return "";

  const value = String(ip).trim();

  // Convert IPv4-mapped IPv6 addresses such as:
  // ::ffff:105.123.45.67
  if (value.startsWith("::ffff:")) {
    return value.substring(7);
  }

  return value;
}

function isPrivateOrLocalIp(ip) {
  if (!ip) return true;

  const value = normalizeIp(ip);

  if (
    value === "127.0.0.1" ||
    value === "::1" ||
    value === "localhost"
  ) {
    return true;
  }

  // IPv4 private ranges
  if (/^10\./.test(value)) return true;
  if (/^192\.168\./.test(value)) return true;
  if (/^172\.(1[6-9]|2\d|3[0-1])\./.test(value)) return true;

  // IPv6 local/private
  if (value.startsWith("fc")) return true;
  if (value.startsWith("fd")) return true;
  if (value.startsWith("fe80:")) return true;

  return false;
}

async function getIpLocation(ip) {
  const normalizedIp = normalizeIp(ip);

  if (!normalizedIp || isPrivateOrLocalIp(normalizedIp)) {
    return {
      ipAddress: normalizedIp || null,
      city: null,
      region: null,
      country: null,
      countryCode: null,
      timezone: null,
    };
  }

  const token = String(
    process.env.IPINFO_TOKEN || "",
  ).trim();

  let url =
    `https://ipinfo.io/${encodeURIComponent(normalizedIp)}/json`;

  if (token) {
    url += `?token=${encodeURIComponent(token)}`;
  }

  try {
    const data = await requestJson(url);

    return {
      ipAddress: normalizedIp,
      city: data.city || null,
      region: data.region || null,
      country: data.country || null,
      countryCode: data.country || null,
      timezone: data.timezone || null,
    };
  } catch (error) {
    console.warn(
      `⚠️ IP geolocation failed for ${normalizedIp}:`,
      error.message,
    );

    return {
      ipAddress: normalizedIp,
      city: null,
      region: null,
      country: null,
      countryCode: null,
      timezone: null,
    };
  }
}

module.exports = {
  getIpLocation,
  normalizeIp,
  isPrivateOrLocalIp,
};