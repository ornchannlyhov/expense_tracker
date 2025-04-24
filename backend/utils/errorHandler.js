const errorHandler = (err, req, res, next) => {
    console.error(err.stack);

    // Handle specific error types
    if (err.name === 'ValidationError') {
        return res.status(400).json({ error: err.message });
    }

    if (err.code === 'SQLITE_CONSTRAINT') {
        return res.status(400).json({ error: 'Data conflict (e.g., duplicate entry)' });
    }

    // Default error response
    res.status(500).json({
        error: 'Internal Server Error',
        details: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
};

module.exports = errorHandler;