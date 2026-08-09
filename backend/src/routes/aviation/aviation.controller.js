const { searchFlights } = require("../../services/aviation/amadeus.service");
const { createBooking, issueTicket } = require("../../services/aviation/wakanow.service");

exports.search = async (req, res) => {
  try {
    const flights = await searchFlights(req.body);
    res.json({ status: true, flights });
  } catch (err) {
    res.status(500).json({ status: false, message: err.message });
  }
};

exports.book = async (req, res) => {
  try {
    const booking = await createBooking(req.body);
    res.json({ status: true, booking });
  } catch (err) {
    res.status(500).json({ status: false, message: err.message });
  }
};

exports.ticket = async (req, res) => {
  try {
    const ticket = await issueTicket(req.body);
    res.json({ status: true, ticket });
  } catch (err) {
    res.status(500).json({ status: false, message: err.message });
  }
};
