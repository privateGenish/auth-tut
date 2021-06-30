const express = require("express");
const router = express.Router();
const firebaseMW = require("../middleware/firebase_auth");

router.get("/:uid", firebaseMW.auth, (req, res) => {
  
///The middleware enables authorized accesses only.
///After access you can fetch or manipulate the data in any way desired.
  res.send("Authorized!");
});

module.exports = router;
