const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors()); // Enable CORS for all routes
app.use(bodyParser.json());

// MongoDB Connection
mongoose.connect('mongodb+srv://jtom47681:Ld7bTmQj654CEHyY@data.vk7z3yl.mongodb.net/mydatabase', {
    useNewUrlParser: true,
    useUnifiedTopology: true,
})
    .then(() => console.log('MongoDB connected successfully'))
    .catch(err => console.error('MongoDB connection error:', err));

// Define User Schema
const userSchema = new mongoose.Schema({
    email: { type: String, required: true, unique: true },
    password: { type: String, required: true }, // Ideally, store hashed passwords
}, { timestamps: true }); // Adds createdAt and updatedAt fields

const User = mongoose.model('User', userSchema);

// POST endpoint to add user
app.post('/addUser', async (req, res) => {
    const { email, password } = req.body;

    // Basic validation
    if (!email || !password) {
        return res.status(400).send('Email and password are required');
    }

    try {
        const newUser = new User({ email, password });
        await newUser.save();
        res.status(201).json({ message: 'User added successfully', userId: newUser._id });
    } catch (error) {
        if (error.code === 11000) {
            // Duplicate key error: email already exists
            return res.status(409).json({
                message: 'Email already exists',
                error: 'DuplicateEmail',
            });
        }
        console.error('Error adding user:', error);
        res.status(500).send('Internal Server Error');
    }
});

// GET endpoint to fetch the latest added user details
app.get('/getUserDetails', async (req, res) => {
    try {
        // Fetch the latest added user
        const user = await User.findOne().sort({ _id: -1 });

        if (!user) {
            return res.status(404).json({
                message: 'No user found',
                email: '',
                password: ''
            });
        }

        res.status(200).json({
            email: user.email || '',
            password: user.password || '' // Include password
        });
    } catch (error) {
        console.error('Error fetching user details:', error);
        res.status(500).json({ message: 'Failed to fetch user details' });
    }
});



// Start the server
app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
});
