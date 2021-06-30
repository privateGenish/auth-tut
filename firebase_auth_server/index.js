const bodyParser = require("body-parser");
const express = require("express");

const app = express();
const PORT = 3000;

app.get('/', function(req,res){
  console.log('Hello World!');
  res.send("Hello World!");
})


app.listen(PORT, () => console.log(`listening on http://localhost:${PORT}/`));
app.use("/user", require("./routes/user.js"));

app.use(bodyParser.json);
app.use(bodyParser.urlencoded({ extended: true }));
