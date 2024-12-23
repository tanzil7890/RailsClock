//= require rails-ujs
//= require chart.js
//= require_tree .

document.addEventListener('DOMContentLoaded', function() {
  // Initialize performance charts
  initializePerformanceCharts();
  
  // Initialize request replay functionality
  initializeReplayButtons();
  
  // Initialize search filters
  initializeSearchFilters();
  
  // Initialize data refresh
  initializeAutoRefresh();
});

function initializePerformanceCharts() {
  const performanceChart = document.getElementById('performance-chart');
  if (performanceChart) {
    new Chart(performanceChart, {
      type: 'line',
      data: JSON.parse(performanceChart.dataset.chartData),
      options: {
        responsive: true,
        scales: {
          y: {
            beginAtZero: true,
            title: {
              display: true,
              text: 'Response Time (ms)'
            }
          }
        }
      }
    });
  }
}

function initializeReplayButtons() {
  document.querySelectorAll('.replay-request').forEach(button => {
    button.addEventListener('click', async (e) => {
      e.preventDefault();
      const requestId = e.target.dataset.requestId;
      
      try {
        button.disabled = true;
        button.textContent = 'Replaying...';
        
        const response = await fetch(`/railsclocks/requests/${requestId}/replay`, {
          method: 'POST',
          headers: {
            'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
            'Accept': 'application/json'
          }
        });
        
        const result = await response.json();
        
        if (result.success) {
          showNotification('Request replayed successfully', 'success');
        } else {
          showNotification(`Replay failed: ${result.error}`, 'error');
        }
      } catch (error) {
        showNotification('Error replaying request', 'error');
      } finally {
        button.disabled = false;
        button.textContent = 'Replay';
      }
    });
  });
}

function initializeSearchFilters() {
  const form = document.querySelector('.request-filters');
  if (form) {
    form.querySelectorAll('input, select').forEach(input => {
      input.addEventListener('change', () => {
        const formData = new FormData(form);
        const params = new URLSearchParams(formData);
        
        window.location.search = params.toString();
      });
    });
  }
}

function initializeAutoRefresh() {
  const refreshInterval = 30000; // 30 seconds
  const dashboard = document.querySelector('.dashboard');
  
  if (dashboard) {
    setInterval(async () => {
      try {
        const response = await fetch(window.location.href, {
          headers: { 'X-Requested-With': 'XMLHttpRequest' }
        });
        
        if (response.ok) {
          const html = await response.text();
          dashboard.innerHTML = html;
          initializePerformanceCharts(); // Reinitialize charts
        }
      } catch (error) {
        console.error('Auto-refresh failed:', error);
      }
    }, refreshInterval);
  }
}

function showNotification(message, type) {
  const notification = document.createElement('div');
  notification.className = `alert alert-${type}`;
  notification.textContent = message;
  
  document.querySelector('.container').insertBefore(
    notification,
    document.querySelector('.container').firstChild
  );
  
  setTimeout(() => notification.remove(), 5000);
} 