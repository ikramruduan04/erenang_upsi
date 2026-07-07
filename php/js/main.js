/**
 * main.js
 * Utility and UI helper functions for the e-Renang UPSI PHP website.
 */

// Initialize Lucide icons on DOM load
document.addEventListener('DOMContentLoaded', () => {
  if (window.lucide) {
    window.lucide.createIcons();
  }
});

// Re-run Lucide icon generator for dynamically loaded elements
function updateIcons() {
  if (window.lucide) {
    window.lucide.createIcons();
  }
}

// Format Price
function formatPrice(amount) {
  return 'RM ' + parseFloat(amount).toFixed(2);
}

// Format Date
function formatDate(dateString) {
  if (!dateString) return '';
  const date = new Date(dateString);
  return date.toLocaleDateString('en-MY', {
    day: 'numeric',
    month: 'short',
    year: 'numeric'
  });
}

// Format Time (12-hour format)
function formatTime(timeString) {
  if (!timeString) return '';
  const [hour, minute] = timeString.split(':');
  let h = parseInt(hour);
  const ampm = h >= 12 ? 'PM' : 'AM';
  h = h % 12;
  h = h ? h : 12; // the hour '0' should be '12'
  return h + ':' + minute + ' ' + ampm;
}
