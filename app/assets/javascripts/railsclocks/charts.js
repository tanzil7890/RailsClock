class RailsClocksCharts {
  static init() {
    this.initResponseTimeChart();
    this.initErrorRateChart();
    this.initRequestDistributionChart();
  }

  static initResponseTimeChart() {
    const ctx = document.getElementById('response-time-chart');
    if (!ctx) return;

    const data = JSON.parse(ctx.dataset.chartData);
    new Chart(ctx, {
      type: 'line',
      data: {
        labels: data.labels,
        datasets: [{
          label: 'Average Response Time (ms)',
          data: data.values,
          borderColor: '#3498db',
          tension: 0.1,
          fill: false
        }]
      },
      options: {
        responsive: true,
        plugins: {
          title: {
            display: true,
            text: 'Response Time Trends'
          },
          tooltip: {
            mode: 'index',
            intersect: false
          }
        },
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

  static initErrorRateChart() {
    const ctx = document.getElementById('error-rate-chart');
    if (!ctx) return;

    const data = JSON.parse(ctx.dataset.chartData);
    new Chart(ctx, {
      type: 'pie',
      data: {
        labels: ['Successful', 'Failed'],
        datasets: [{
          data: [data.success_rate, data.error_rate],
          backgroundColor: ['#2ecc71', '#e74c3c']
        }]
      },
      options: {
        responsive: true,
        plugins: {
          title: {
            display: true,
            text: 'Request Success/Error Distribution'
          }
        }
      }
    });
  }

  static initRequestDistributionChart() {
    const ctx = document.getElementById('request-distribution-chart');
    if (!ctx) return;

    const data = JSON.parse(ctx.dataset.chartData);
    new Chart(ctx, {
      type: 'bar',
      data: {
        labels: data.paths,
        datasets: [{
          label: 'Request Count',
          data: data.counts,
          backgroundColor: '#9b59b6'
        }]
      },
      options: {
        responsive: true,
        plugins: {
          title: {
            display: true,
            text: 'Request Distribution by Path'
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            title: {
              display: true,
              text: 'Number of Requests'
            }
          }
        }
      }
    });
  }
}

document.addEventListener('DOMContentLoaded', () => RailsClocksCharts.init());
