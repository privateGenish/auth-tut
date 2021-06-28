const express = require("express");
const router = express.Router();
const firebaseMW = require("../middleware/firebase_auth");

router.get("/:uid", firebaseMW.auth, (req, res) => {
  res.send("Authorized!");
});

module.exports = router;
