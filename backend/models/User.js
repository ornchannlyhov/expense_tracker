const db = require('../config/db');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const { JWT_SECRET } = require('../utils/constants');

class User {
    static async create(username, email, password) {
        const hashedPassword = await bcrypt.hash(password, 10);
        return new Promise((resolve, reject) => {
            db.run(
                'INSERT INTO users (username, email, hashed_pass) VALUES (?, ?, ?)',
                [username, email, hashedPassword],
                function(err) {
                    if (err) reject(err);
                    else resolve(this.lastID);
                }
            );
        });
    }

    static async findByUsername(username) {
        return new Promise((resolve, reject) => {
            db.get('SELECT * FROM users WHERE username = ?', [username], (err, row) => {
                if (err) reject(err);
                else resolve(row);
            });
        });
    }

    static async verifyUser(username, password) {
        const user = await this.findByUsername(username);
        if (!user) return null;
        
        const isValid = await bcrypt.compare(password, user.hashed_pass);
        return isValid ? user : null;
    }

    static generateToken(user) {
        // console.log('Generating token for user:', user); 
        return jwt.sign(
            { id: user.id, username: user.username },
            JWT_SECRET,
            { expiresIn: '1h' }
        );
    }
    
}

module.exports = User;