class RailsClocksRequests {
  static init() {
    this.initRequestFilters();
    this.initRequestDetails();
    this.initReplayHandlers();
    this.initExportHandlers();
  }

  static initRequestFilters() {
    const filterForm = document.querySelector('.request-filters');
    if (!filterForm) return;

    // Handle date range inputs
    const dateInputs = filterForm.querySelectorAll('input[type="date"]');
    dateInputs.forEach(input => {
      input.addEventListener('change', () => this.submitFilters(filterForm));
    });

    // Handle method selection
    const methodSelect = filterForm.querySelector('select[name="method"]');
    if (methodSelect) {
      methodSelect.addEventListener('change', () => this.submitFilters(filterForm));
    }

    // Handle status code filters
    const statusFilters = filterForm.querySelectorAll('input[name="status[]"]');
    statusFilters.forEach(filter => {
      filter.addEventListener('change', () => this.submitFilters(filterForm));
    });

    // Handle search input with debounce
    const searchInput = filterForm.querySelector('input[name="search"]');
    if (searchInput) {
      let timeout;
      searchInput.addEventListener('input', () => {
        clearTimeout(timeout);
        timeout = setTimeout(() => this.submitFilters(filterForm), 500);
      });
    }
  }

  static initRequestDetails() {
    const detailsContainer = document.querySelector('.request-details');
    if (!detailsContainer) return;

    // Toggle SQL query details
    const sqlToggles = detailsContainer.querySelectorAll('.sql-toggle');
    sqlToggles.forEach(toggle => {
      toggle.addEventListener('click', (e) => {
        e.preventDefault();
        const details = document.querySelector(toggle.dataset.target);
        details.classList.toggle('hidden');
      });
    });

    // Format JSON data
    const jsonContainers = detailsContainer.querySelectorAll('.json-data');
    jsonContainers.forEach(container => {
      try {
        const data = JSON.parse(container.textContent);
        container.textContent = JSON.stringify(data, null, 2);
      } catch (e) {
        console.error('Invalid JSON data:', e);
      }
    });
  }

  static initReplayHandlers() {
    const replayButtons = document.querySelectorAll('.replay-request');
    replayButtons.forEach(button => {
      button.addEventListener('click', async (e) => {
        e.preventDefault();
        await this.handleReplay(button);
      });
    });
  }

  static initExportHandlers() {
    const exportButtons = document.querySelectorAll('.export-request');
    exportButtons.forEach(button => {
      button.addEventListener('click', (e) => {
        e.preventDefault();
        this.handleExport(button);
      });
    });
  }

  static async handleReplay(button) {
    const requestId = button.dataset.requestId;
    button.disabled = true;
    button.textContent = 'Replaying...';

    try {
      const response = await fetch(`/railsclocks/requests/${requestId}/replay`, {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content,
          'Accept': 'application/json'
        }
      });

      const result = await response.json();
      this.showNotification(
        result.success ? 'Request replayed successfully' : `Replay failed: ${result.error}`,
        result.success ? 'success' : 'error'
      );
    } catch (error) {
      this.showNotification('Error replaying request', 'error');
    } finally {
      button.disabled = false;
      button.textContent = 'Replay';
    }
  }

  static handleExport(button) {
    const requestId = button.dataset.requestId;
    const format = button.dataset.format || 'json';
    window.location.href = `/railsclocks/requests/${requestId}/export?format=${format}`;
  }

  static submitFilters(form) {
    const formData = new FormData(form);
    const params = new URLSearchParams(formData);
    window.location.search = params.toString();
  }

  static showNotification(message, type) {
    const notification = document.createElement('div');
    notification.className = `alert alert-${type}`;
    notification.textContent = message;
    
    document.querySelector('.container').insertBefore(
      notification,
      document.querySelector('.container').firstChild
    );
    
    setTimeout(() => notification.remove(), 5000);
  }
}

document.addEventListener('DOMContentLoaded', () => RailsClocksRequests.init());
