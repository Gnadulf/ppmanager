// Debug Configuration
// Set to true for development, false for production
window.DEBUG = false;

// Debug logging function
window.debugLog = function(...args) {
    if (window.DEBUG) {
        console.log('[DEBUG]', ...args);
    }
};

// Debug error function
window.debugError = function(...args) {
    if (window.DEBUG) {
        console.error('[ERROR]', ...args);
    }
};