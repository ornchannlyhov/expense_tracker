const User = require('../models/User');
const { JWT_SECRET } = require('../utils/constants');

exports.register = async (req, res) => {
    try {
        const { username, email, password } = req.body;
        
        if (!username || !email || !password) {
            return res.status(400).json({ error: 'All fields are required' });
        }

        const userId = await User.create(username, email, password);
        res.status(201).json({ message: 'User created successfully', userId });
    } catch (error) {
        if (error.message.includes('UNIQUE constraint failed')) {
            return res.status(400).json({ error: 'Username or email already exists' });
        }
        res.status(500).json({ error: error.message });
    }
};

exports.login = async (req, res) => {
    try {
        const { username, password } = req.body;
        
        if (!username || !password) {
            return res.status(400).json({ error: 'Username and password are required' });
        }

        const user = await User.verifyUser(username, password);
        if (!user) {
            return res.status(401).json({ error: 'Invalid credentials' });
        }

        const token = User.generateToken(user);
        res.json({ token, userId: user.id, username: user.username });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

exports.logout = (req, res) => {
    res.cookie('token', '', { expires: new Date(0), httpOnly: true }); 
    res.status(200).json({ message: 'Logged out successfully' });
};
