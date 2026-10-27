const express = require('express');
const app = express();
app.use(express.json());

// Add your keys here
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

    const scriptCode = `
        -- PASTE YOUR FULL ANGELS SCRIPT HERE (Inside the backticks)
        print("HWID Verified. Angels Loaded.")
    `;

    res.json({ success: true, chunk: scriptCode });
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log('Server running'));
