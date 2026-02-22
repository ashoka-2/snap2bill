/**
 * Created by ASHOK KUMAR on 22-02-2026.
 */
// Open Edit Modal
function openEditModal(id, name) {
    document.getElementById('edit_id').value = id;
    document.getElementById('edit_name').value = name;
    showModal('editModal');
}

// Open Delete Modal
function openDeleteModal(id, name) {
    document.getElementById('del_unit_name').innerText = name;
    document.getElementById('del_link').href = "/delete_unit/" + id;
    showModal('deleteModal');
}

// Show/Hide Modal Logic
function showModal(id) {
    const backdrop = document.getElementById(id);
    backdrop.style.display = 'grid';
    setTimeout(() => backdrop.querySelector('.modal').classList.add('open'), 10);
}

function closeModal(id) {
    const backdrop = document.getElementById(id);
    backdrop.querySelector('.modal').classList.remove('open');
    setTimeout(() => backdrop.style.display = 'none', 300);
}

// Live Search Filter
document.getElementById('unitSearch').addEventListener('keyup', function() {
    let input = this.value.toLowerCase();
    let rows = document.querySelectorAll('#unitTable tbody tr');
    rows.forEach(row => {
        let name = row.querySelector('.u-name-cell')?.innerText.toLowerCase();
        if (name) row.style.display = name.includes(input) ? '' : 'none';
    });
});

// Close on backdrop click
window.onclick = function(event) {
    if (event.target.classList.contains('modal-backdrop')) {
        closeModal(event.target.id);
    }
}