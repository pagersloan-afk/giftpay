const { getProducts } = require("../services/monnifyBills.service.js");

function unwrap(body) {
  return body?.responseBody ?? body?.data ?? body ?? {};
}

function items(body) {
  const value = unwrap(body);
  if (Array.isArray(value)) return value;
  if (Array.isArray(value.content)) return value.content;
  if (Array.isArray(value.products)) return value.products;
  return [];
}

exports.getElectricityProductsController = async (req, res) => {
  try {
    const billerCode = String(req.params.billerCode || "").trim();

    if (!billerCode) {
      return res.status(400).json({
        status: false,
        message: "Missing billerCode",
      });
    }

    const response = await getProducts({
      biller_code: billerCode,
      size: 100,
      page: 0,
    });

    const products = items(response)
      .map((product) => ({
        code:
          product?.code ??
          product?.productCode ??
          product?.product_code ??
          "",
        name:
          product?.name ??
          product?.productName ??
          product?.product_name ??
          "",
        amount:
          product?.amount ??
          product?.price ??
          product?.productAmount ??
          null,
        priceType: product?.priceType ?? product?.price_type ?? null,
        billerCode,
        raw: product,
      }))
      .filter((product) => product.code && product.name);

    return res.json({
      status: true,
      billerCode,
      products,
    });
  } catch (err) {
    console.error("Monnify electricity products error:", err);
    return res.status(err.status || 502).json({
      status: false,
      message: err.message || "Failed to fetch electricity products",
      provider: err.provider,
    });
  }
};
