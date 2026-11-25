module.exports = function bushaOperator(req, res, next) {
  const allowed = (process.env.BUSHA_OPERATOR_UIDS || "")
    .split(",")
    .map((value) => value.trim())
    .filter(Boolean);

  if (!req.user?.uid || !allowed.includes(req.user.uid)) {
    return res.status(403).json({
      status: false,
      message: "This Busha account operation is not enabled for this GiftPay user.",
    });
  }
  return next();
};
