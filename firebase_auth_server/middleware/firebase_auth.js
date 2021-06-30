var admin = require("firebase-admin");

var serviceAccount = require("../fir-auth-1af5c-firebase-adminsdk-63ox0-97422e88ea.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

exports.auth = async function (req, res, next) {
  console.log(req.headers.authorization);
  try {
    await admin
      .auth()
      .verifyIdToken(req.headers.authorization)
      .then((result) => {
        if (result.uid == req.params.uid) {
          return next();
        }
      })
      .catch((e) => {
        console.log(e);
        res.status(400).send(e);
      });
    return;
  } catch (e) {
    console.log(e);
    res.status(400).send(e);
  }
};
