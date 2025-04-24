const Expense = require('../models/Expense');

// Create a new expense
exports.addExpense = async (req, res) => {
    try {
        const { amount, category, date, notes } = req.body;
        const userId = req.user.id;

        if (!amount || !category || !date) {
            return res.status(400).json({
                error: 'Amount, category, and date are required',
                details: 'Please ensure all required fields are provided.'
            });
        }

        const expense = await Expense.create(userId, amount, category, date, notes);
        res.status(201).json({
            message: 'Expense added successfully',
            data: {
                id: expense.id,
                amount: expense.amount,
                category: expense.category,
                date: expense.date,
                notes: expense.notes,
                userId: expense.userId
            }
        });
    } catch (error) {
        console.error('Error adding expense:', error);
        res.status(500).json({
            error: 'Internal Server Error',
            details: error.message
        });
    }
};

// Get expenses
exports.getExpenses = async (req, res) => {
    try {
        const userId = req.user.id;
        const { month, year } = req.query;

        if (!month || !year) {
            return res.status(400).json({
                error: 'Month and year are required',
                details: 'Please provide both the month and year to retrieve expenses.'
            });
        }

        const expenses = await Expense.findByUserId(userId, month, year);

        if (!expenses || expenses.length === 0) {
            return res.status(404).json({
                message: 'No expenses found for the given month and year',
                details: 'Try checking the input values or if you have expenses logged for the selected period.'
            });
        }

        res.status(200).json({
            message: 'Expenses retrieved successfully',
            data: expenses.map(expense => ({
                id: expense.id,
                amount: expense.amount,
                category: expense.category,
                date: expense.date,
                notes: expense.notes,
                userId: expense.userId
            }))
        });
    } catch (error) {
        console.error('Error fetching expenses:', error);
        res.status(500).json({
            error: 'Internal Server Error',
            details: error.message
        });
    }
};

// Get monthly summary of expenses
exports.getMonthlySummary = async (req, res) => {
    try {
        const userId = req.user.id;
        const { month, year } = req.query;

        if (!month || !year) {
            return res.status(400).json({
                error: 'Month and year are required',
                details: 'Please provide both the month and year to get the summary.'
            });
        }

        const summary = await Expense.getMonthlySummary(userId, month, year);

        if (!summary) {
            return res.status(404).json({
                message: 'No summary found for the given month and year',
                details: 'Check if there are any expenses logged for the selected period.'
            });
        }

        res.status(200).json({
            message: 'Summary retrieved successfully',
            data: {
                total: summary.total,
                byCategory: summary.categories
            }
        });
    } catch (error) {
        console.error('Error fetching monthly summary:', error);
        res.status(500).json({
            error: 'Internal Server Error',
            details: error.message
        });
    }
};

// Update an existing expense
exports.updateExpense = async (req, res) => {
    try {
        const expenseId = req.params.id;
        const { amount, category, date, notes } = req.body;
        const userId = req.user.id;

        const updatedExpense = await Expense.update(expenseId, userId, amount, category, date, notes);

        if (!updatedExpense) {
            return res.status(404).json({
                error: 'Expense not found or not authorized',
                details: 'Please check the expense ID and your authorization rights.'
            });
        }

        res.status(200).json({
            message: 'Expense updated successfully',
            data: {
                id: updatedExpense.id,
                amount: updatedExpense.amount,
                category: updatedExpense.category,
                date: updatedExpense.date,
                notes: updatedExpense.notes,
                userId: updatedExpense.userId
            }
        });
    } catch (error) {
        console.error('Error updating expense:', error);
        res.status(500).json({
            error: 'Internal Server Error',
            details: error.message
        });
    }
};

// Delete an expense
exports.deleteExpense = async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user.id;

        const deletedExpense = await Expense.delete(id, userId);

        if (!deletedExpense) {
            return res.status(404).json({
                error: 'Expense not found or not authorized',
                details: 'Expense with the provided ID was not found or you are not authorized to delete it.'
            });
        }

        res.status(200).json({
            message: 'Expense deleted successfully',
            data: {
                id: deletedExpense.id,
                amount: deletedExpense.amount,
                category: deletedExpense.category,
                date: deletedExpense.date,
                notes: deletedExpense.notes,
                userId: deletedExpense.userId
            }
        });
    } catch (error) {
        console.error('Error deleting expense:', error);
        res.status(500).json({
            error: 'Internal Server Error',
            details: error.message
        });
    }
};