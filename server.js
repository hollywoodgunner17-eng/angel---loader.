const express = require('express');
const app = express();
app.use(express.json());

// THIS IS YOUR DATABASE
// Add your buyers' keys here
const database = {
    "ANGEL-TEST-KEY": { hwid: null },
    "ANGEL-BUYER1-X7Y2": { hwid: null },
    "ANGEL-BUYER2-A3B9": { hwid: null }
};

// This is the endpoint the script talks to
app.post('/verify', (req, res) => {
    const { key, hwid } = req.body;
    
    // 1. Check if the key exists
    if (!database[key]) {
        return res.json({ success: false, reason: "INVALID_KEY" });
    }

    // 2. If it's the first time this key is used, lock it to this HWID
    if (database[key].hwid === null) {
        database[key].hwid = hwid;
    } 
    // 3. If the HWID is already locked and it doesn't match, reject it
    else if (database[key].hwid !== hwid) {
        return res.json({ success: false, reason: "HWID_MISMATCH" });
    }

    // 4. If it passes, send the script
    // PASTE YOUR FULL ANGELS SCRIPT IN BETWEEN THE BACKTICKS BELOW:
    const scriptCode = `
        -- THIS IS WHERE YOUR ANGELS SCRIPT GOES
        print("HWID Verified. Angels Loaded.")
        game:GetService("Players").LocalPlayer:Kick("Remove this and put your actual script inside server.js on GitHub.")
    `;

    res.json({ success: true, chunk: scriptCode });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log('Server running'));
