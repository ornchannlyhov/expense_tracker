const Expense = require('../models/Expense');

// Create a new expenses
exports.addExpense = async (req, res) => {
    try {
        const { amount, category, date, notes } = req.body;
        const userId = req.user.id;

        if (!amount || !category || !date) {
            return res.status(400).json({ error: 'Amount, category, and date are required' });
        }

        const expenseId = await Expense.create(userId, amount, category, date, notes);
        res.status(201).json({ message: 'Expense added successfully', expenseId });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Get expenses
exports.getExpenses = async (req, res) => {
    try {
        const userId = req.user.id;
        const { month, year } = req.query;

        const expenses = await Expense.findByUserId(userId, month, year);
        res.json(expenses);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};


// read monthly summary of expenses
exports.getMonthlySummary = async (req, res) => {
    try {
        const userId = req.user.id;
        const { month, year } = req.query;

        if (!month || !year) {
            return res.status(400).json({ error: 'Month and year are required' });
        }

        const summary = await Expense.getMonthlySummary(userId, month, year);
        res.json(summary);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Update an existing expense
exports.updateExpense = async (req, res) => {
    try {
        const expenseId = req.params.id;
        const { amount, category, date, notes } = req.body;
        // console.log('REQ.USER:', req.user); 
        const userId = req.user.id;

        const updated = await Expense.update(expenseId, userId, amount, category, date, notes);
        if (!updated) {
            return res.status(404).json({ error: 'Expense not found or not authorized' });
        }

        res.json({ message: 'Expense updated successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

// Delete an expense
exports.deleteExpense = async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;

        const result = await Expense.delete(id, userId);
        res.json(result);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};
