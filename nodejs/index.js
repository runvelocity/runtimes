const express = require('express')
const bodyParser = require('body-parser')
const extract = require('extract-zip')
const axios = require('axios');
const fs = require('fs');



async function downloadAndExtractZip(src) {
  const response = await axios({
    method: 'get',
    url: src,
    responseType: 'stream',
  })
  await response.data.pipe(fs.createWriteStream("/tmp/code.zip"));
  console.log('File downloaded successfully.');
  await extract("/tmp/code.zip", { dir: "/var/code" })
}

const app = express()
app.use(bodyParser.json())
app.use(bodyParser.urlencoded({ extended: false }))

const port = process.env.PORT || 3000

app.post('/invoke', async (req, res) =>  {
  const handler = req.body.handler;
  const args = req.body.args;
  
  try {
    const codeLocation = req.body.codeLocation;
    await downloadAndExtractZip(codeLocation)
    const dynamicFunction = require(`/var/code/${handler}.js`);
    // Access the function dynamically using the function name
    res.status(200).json({invocationResponse: await dynamicFunction(args)});
  }
  catch(err) {
    res.status(500).json({error: err.message})
  }
  
})

app.listen(port, () => {
  console.log(`Started server on port ${port}`)
})