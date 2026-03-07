
document.addEventListener('DOMContentLoaded', function() {
  const searchInput = document.getElementById('searchInput');
  const fromDate = document.getElementById('fromDate');
  const toDate = document.getElementById('toDate');
  const clearBtn = document.getElementById('resetFilters');
  const rows = Array.from(document.querySelectorAll('#feedbackTableBody tr'));
  const noMsg = document.getElementById('noDataMessage');

  function normalize(t){ return (t||'').toString().toLowerCase().trim(); }

  // Solid Date Extractor
  function extractDatePart(str){
    if(!str) return null;
    const m = str.toString().match(/^(\d{4}-\d{2}-\d{2})/);
    if(m) return m[1];
    const dmy = str.toString().match(/^(\d{2})[\/.-](\d{2})[\/.-](\d{4})/);
    if(dmy) return `${dmy[3]}-${dmy[2]}-${dmy[1]}`;
    return null;
  }

  function applyFilters(){
    const q = normalize(searchInput?.value || '');
    const from = extractDatePart(fromDate?.value || '');
    const to = extractDatePart(toDate?.value || '');

    let visible = 0;
    rows.forEach(row => {
      const cells = row.querySelectorAll('td');
      if(cells.length < 4){
        row.style.display = 'none';
        return;
      }

      // Cell 1: Name (Customer/Distributor), Cell 2: Feedback, Cell 3: Date
      const name = normalize(cells[1].textContent);
      const text = normalize(cells[2].textContent);
      const dateText = cells[3] ? cells[3].textContent.trim() : '';
      const rowDate = extractDatePart(dateText);

      const matchText = !q || name.includes(q) || text.includes(q);
      const matchFrom = !from || (rowDate && rowDate >= from);
      const matchTo   = !to   || (rowDate && rowDate <= to);

      const show = matchText && matchFrom && matchTo;
      row.style.display = show ? '' : 'none';
      if(show) visible++;
    });

    if(noMsg) noMsg.style.display = (visible === 0) ? 'block' : 'none';
  }

  if(searchInput) searchInput.addEventListener('input', applyFilters);

  // Custom click handler to open calendar on clicking anywhere in the input
  if(fromDate) {
      fromDate.addEventListener('change', applyFilters);
      fromDate.addEventListener('click', () => fromDate.showPicker && fromDate.showPicker());
  }
  if(toDate) {
      toDate.addEventListener('change', applyFilters);
      toDate.addEventListener('click', () => toDate.showPicker && toDate.showPicker());
  }

  if(clearBtn) clearBtn.addEventListener('click', () => {
    if(searchInput) searchInput.value = '';
    if(fromDate) fromDate.value = '';
    if(toDate) toDate.value = '';
    applyFilters();
  });

  applyFilters();
});