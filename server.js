const express = require('express');
const fs = require('fs');
const path = require('path');
const app = express();
app.use(express.json());

const database = {
    "ANGEL-TEST-KEY": { hwid: null }
};

app.post('/verify', (req, res) => {
    const { key, hwid } = req.body;
    
    if (!database[key]) {
        return res.json({ success: false, reason: "INVALID_KEY" });
    }

    if (database[key].hwid === null) {
        database[key].hwid = hwid;
    } else if (database[key].hwid !== hwid) {
        return res.json({ success: false, reason: "HWID_MISMATCH" });
    }

    try {
        const scriptCode = fs.readFileSync(path.join(__dirname, 'angels.lua'), 'utf8');
        res.json({ success: true, chunk: scriptCode });
    } catch (err) {
        res.json({ success: false, reason: "SCRIPT_FILE_MISSING" });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log('Server running'));
