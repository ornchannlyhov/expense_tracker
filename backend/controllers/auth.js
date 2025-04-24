const User = require('../models/User');
const { JWT_SECRET } = require('../utils/constants');

exports.register = async (req, res) => {
    try {
        const { username, email, password } = req.body;

        // Validate input
        if (!username || !email || !password) {
            return res.status(400).json({
                error: 'All fields are required',
                message: 'Please provide a valid username, email, and password to register.'
            });
        }

        // Create user in the database
        const userId = await User.create(username, email, password);
        res.status(201).json({
            message: 'User created successfully',
            user: {
                id: userId,
                username,
                email
            }
        });
    } catch (error) {
        if (error.message.includes('UNIQUE constraint failed')) {
            return res.status(400).json({
                error: 'Username or email already exists',
                message: 'Please choose a different username or email address.'
            });
        }
        res.status(500).json({
            error: 'Server error',
            message: 'An unexpected error occurred while processing your request. Please try again later.'
        });
    }
};

exports.login = async (req, res) => {
    try {
        const { username, password } = req.body;

        // Validate input
        if (!username || !password) {
            return res.status(400).json({
                error: 'Username and password are required',
                message: 'Please provide both username and password to log in.'
            });
        }

        // Verify user credentials
        const user = await User.verifyUser(username, password);
        if (!user) {
            return res.status(401).json({
                error: 'Invalid credentials',
                message: 'The username or password you entered is incorrect. Please try again.'
            });
        }

        // Generate JWT token
        const token = User.generateToken(user);
        res.json({
            message: 'Login successful',
            user: {
                id: user.id,
                username: user.username,
                email: user.email
            },
            token
        });
    } catch (error) {
        res.status(500).json({
            error: 'Server error',
            message: 'An unexpected error occurred during login. Please try again later.'
        });
    }
};

exports.getProfile = async (req, res) => {
    try {
        const userId = req.user.id;

        // Fetch user profile
        const user = await new Promise((resolve, reject) => {
            db.get('SELECT id, username, email FROM users WHERE id = ?', [userId], (err, row) => {
                if (err) reject(err);
                else resolve(row);
            });
        });

        // If user not found, return an error
        if (!user) return res.status(404).json({
            error: 'User not found',
            message: 'The user profile could not be found. Please check your session or login again.'
        });

        res.json({
            message: 'User profile retrieved successfully',
            user
        });
    } catch (error) {
        res.status(500).json({
            error: 'Server error',
            message: 'An unexpected error occurred while fetching your profile. Please try again later.'
        });
    }
};

exports.logout = (req, res) => {
    res.cookie('token', '', { expires: new Date(0), httpOnly: true });
    res.status(200).json({
        message: 'Logged out successfully',
        messageDetails: 'You have been logged out and your session has been terminated.'
    });
};