const root = document.documentElement;

// Config colors mapping
const colorConfigs = [
    { css: '--primary', id: 'colorPrimary', label: 'hexPrimary' },
    { css: '--accent', id: 'colorAccent', label: 'hexAccent' },
    { css: '--bg-body', id: 'colorBg', label: 'hexBg' },
    { css: '--surface', id: 'colorSurface', label: 'hexSurface' },
    { css: '--text-main', id: 'colorTextMain', label: 'hexTextMain' },
    { css: '--danger', id: 'colorDanger', label: 'hexDanger' }
];

// Initialize UI on load
document.addEventListener('DOMContentLoaded', () => {
    // 1. Sync Toggles
    const isDark = root.getAttribute('data-theme') === 'dark';
    document.getElementById('settingsThemeToggle').checked = isDark;

    // 2. Sync Color Pickers with current CSS values
    colorConfigs.forEach(item => {
        const currentVal = getComputedStyle(root).getPropertyValue(item.css).trim();
        const inputEl = document.getElementById(item.id);
        const labelEl = document.getElementById(item.label);
        if (inputEl) inputEl.value = currentVal;
        if (labelEl) labelEl.innerText = currentVal;
    });
});

function handleThemeToggle() {
    const isDark = document.getElementById('settingsThemeToggle').checked;
    const theme = isDark ? 'dark' : 'light';
    root.setAttribute('data-theme', theme);
    localStorage.setItem('theme', theme);

    // Trigger navbar icon change if function exists in navbar.js
    if (window.updateNavbarThemeIcon) updateNavbarThemeIcon(theme);
}

function updateLiveColor(variable, value, labelId) {
    root.style.setProperty(variable, value);
    localStorage.setItem(variable, value);
    document.getElementById(labelId).innerText = value;
}

function resetThemeDefaults() {
    colorConfigs.forEach(item => {
        root.style.removeProperty(item.css);
        localStorage.removeItem(item.css);
    });
    location.reload(); // Quick reset
}

function saveBranding() {
    const file = document.getElementById('siteFavicon').files[0];
    if (!file) return showToast('Please select an icon file', 'error');

    const reader = new FileReader();
    reader.onload = function(e) {
        const b64 = e.target.result;
        localStorage.setItem('siteFavicon', b64);
        document.getElementById('dynamic-favicon').href = b64;
        showToast('✅ Favicon updated successfully!', 'success');
    };
    reader.readAsDataURL(file);
}

function showToast(msg, type) {
    const container = document.getElementById('toast-container');
    const toast = document.createElement('div');
    toast.className = `toast ${type}`;
    toast.innerText = msg;
    container.appendChild(toast);
    setTimeout(() => toast.remove(), 4000);
}
