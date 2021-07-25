const fs = require("fs");
const https = require("https");
const path = require("path");

// URL of the image
const url =
  "https://github.com/Confidenceman02/elm-animate-height/zipball/master";
const dir = `${path.resolve(__dirname)}/gittars/`;

https
  .request(url, {}, (res) => {
    fs.mkdirSync(dir);
    const path = `${dir}/archive.tar.gz`;
    const filePath = fs.createWriteStream(path);
    res.pipe(filePath);
    filePath.on("finish", () => {
      filePath.close();
      console.log("Download Completed");
    });
    filePath.on("error", (err) => {
      console.log("Download didn't work", err);
    });
  })
  .end();
