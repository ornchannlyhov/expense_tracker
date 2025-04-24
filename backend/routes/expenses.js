const express = require('express');
const router = express.Router();
const expenseController = require('../controllers/expenses');
const authenticateToken = require('../middleware/auth');

router.post('/', authenticateToken, expenseController.addExpense);
router.get('/', authenticateToken, expenseController.getExpenses);
router.put('/:id', authenticateToken, expenseController.updateExpense);
router.delete('/:id', authenticateToken, expenseController.deleteExpense);
router.get('/summary', authenticateToken, expenseController.getMonthlySummary);

module.exports = router;