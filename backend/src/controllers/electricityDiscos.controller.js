const {
  getCategories,
  getBillers,
} = require("../services/monnifyBills.service.js");

function unwrap(body) {
  return body?.responseBody ?? body?.data ?? body ?? {};
}

function items(body) {
  const value = unwrap(body);
  if (Array.isArray(value)) return value;
  if (Array.isArray(value.content)) return value.content;
  if (Array.isArray(value.billers)) return value.billers;
  if (Array.isArray(value.categories)) return value.categories;
  return [];
}

exports.getDiscosController = async (_req, res) => {
  try {
    const categoryResponse = await getCategories({ size: 100, page: 0 });
    const categories = items(categoryResponse);

    const electricityCategory = categories.find((category) => {
      const name = String(
        category?.name ??
          category?.categoryName ??
          category?.category_name ??
          ""
      ).trim().toUpperCase();

      const code = String(
        category?.code ?? category?.categoryCode ?? category?.category_code ?? ""
      ).trim().toUpperCase();

      return name === "ELECTRICITY" || code === "ELECTRICITY";
    });

    if (!electricityCategory) {
      return res.status(404).json({
        status: false,
        message: "Monnify electricity category was not returned",
        categories,
      });
    }

    const categoryCode =
      electricityCategory?.code ??
      electricityCategory?.categoryCode ??
      electricityCategory?.category_code;

    if (!categoryCode) {
      return res.status(502).json({
        status: false,
        message: "Monnify electricity category has no category code",
        category: electricityCategory,
      });
    }

    const billerResponse = await getBillers({
      category_code: categoryCode,
      size: 100,
      page: 0,
    });

    const billers = items(billerResponse);

    const data = billers
      .map((biller) => ({
        name:
          biller?.name ??
          biller?.billerName ??
          biller?.biller_name ??
          "",
        code:
          biller?.code ??
          biller?.billerCode ??
          biller?.biller_code ??
          "",
        categoryCode,
        raw: biller,
      }))
      .filter((biller) => biller.name && biller.code);

    return res.json({
      status: true,
      data,
      categoryCode,
    });
  } catch (err) {
    console.error("Monnify electricity biller fetch error:", err);
    return res.status(err.status || 502).json({
      status: false,
      message: err.message || "Failed to fetch electricity billers",
      provider: err.provider,
    });
  }
};
