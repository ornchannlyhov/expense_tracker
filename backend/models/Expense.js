const db = require('../config/db');

class Expense {
    // Create
    static create(userId, amount, category, date, notes = null) {
        return new Promise((resolve, reject) => {
            db.run(
                'INSERT INTO expenses (user_id, amount, category, date, notes) VALUES (?, ?, ?, ?, ?)',
                [userId, amount, category, date, notes],
                function (err) {
                    if (err) reject(err);
                    else resolve(this.lastID);
                }
            );
        });
    }

    // Get expenses by userId (with optional month/year filter)
    static findByUserId(userId, month = null, year = null) {
        return new Promise((resolve, reject) => {
            let query = 'SELECT * FROM expenses WHERE user_id = ?';
            const params = [userId];

            if (month && year) {
                query += ' AND strftime("%m", date) = ? AND strftime("%Y", date) = ?';
                params.push(month.toString().padStart(2, '0'), year.toString());
            }

            query += ' ORDER BY date DESC';

            db.all(query, params, (err, rows) => {
                if (err) reject(err);
                else resolve(rows);
            });
        });
    }

    // Read Monthly summary (category-wise total)
    static getMonthlySummary(userId, month, year) {
        return new Promise((resolve, reject) => {
            db.all(
                `SELECT category, SUM(amount) as total 
                 FROM expenses 
                 WHERE user_id = ? AND strftime("%m", date) = ? AND strftime("%Y", date) = ?
                 GROUP BY category`,
                [userId, month.toString().padStart(2, '0'), year.toString()],
                (err, rows) => {
                    if (err) reject(err);
                    else resolve(rows);
                }
            );
        });
    }

    // Update by its ID
    static update(id, userId, amount, category, date, notes = null) {
        return new Promise((resolve, reject) => {
            const query = `
                UPDATE expenses
                SET amount = ?, category = ?, date = ?, notes = ?
                WHERE id = ? AND user_id = ?
            `;
            db.run(query, [amount, category, date, notes, id, userId], function (err) {
                if (err) return reject(err);
                resolve(this.changes > 0);
            });
        });
    }


    //Delete by its ID
    static delete(id, userId) {
        return new Promise((resolve, reject) => {
            db.run(
                'DELETE FROM expenses WHERE id = ? AND user_id = ?',
                [id, userId],
                function (err) {
                    if (err) reject(err);
                    else resolve({ message: 'Expense deleted successfully' });
                }
            );
        });
    }
}

module.exports = Expense;
