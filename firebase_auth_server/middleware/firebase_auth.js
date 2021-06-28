var admin = require("firebase-admin");

var serviceAccount = require("../fir-auth-1af5c-firebase-adminsdk-63ox0-97422e88ea.json");
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

exports.auth = async function (req, res, next) {
  await admin
    .auth()
    .verifyIdToken(req.params.uid)
    .then((v) => {  
      if (v.uid == req.params.uid) {
        next();
      }
    })
    .catch((e) =>{ 
      console.log("error!");
      res.status(400).send(e)});
  return;
};
