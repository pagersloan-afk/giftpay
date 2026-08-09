const amadeus = require("../../utils/amadeus.client");

exports.searchFlights = async ({ from, to, date }) => {
  const response = await amadeus.shopping.flightOffersSearch.get({
    originLocationCode: from,
    destinationLocationCode: to,
    departureDate: date,
    adults: 1,
    currencyCode: "NGN",
  });

  return response.data;
};
