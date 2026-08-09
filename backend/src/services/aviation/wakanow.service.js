const wakanow = require("../../utils/wakanow.client");

exports.createBooking = async ({ offerId, passenger }) => {
  const response = await wakanow.post("/book", {
    offerId,
    passenger,
  });

  return response.data;
};

exports.issueTicket = async ({ bookingId }) => {
  const response = await wakanow.post("/ticket", {
    bookingId,
  });

  return response.data;
};
