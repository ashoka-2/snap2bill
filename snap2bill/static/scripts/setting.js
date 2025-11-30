(function() {
    const root = document.documentElement;

    // --- 1. Restore Theme (Light/Dark) ---
    const savedTheme = localStorage.getItem('theme') || 'light';
    root.setAttribute('data-theme', savedTheme);

    // --- 2. Restore Custom Colors ---
    // Comprehensive list of all customizable variables
    const colorVars = [
        '--primary',
        '--accent',
        '--text-main',
        '--text-soft',
        '--bg-body',
        '--surface',
        '--line',
        '--danger'
    ];

    colorVars.forEach(variable => {
        const savedColor = localStorage.getItem(variable);
        if (savedColor) {
            root.style.setProperty(variable, savedColor);
        }
    });

    // --- 3. Restore Favicon ---
    const savedFavicon = localStorage.getItem('siteFavicon');
    if (savedFavicon) {
        // Look for existing favicon link or create one
        let link = document.querySelector("link[rel~='icon']");
        if (!link) {
            link = document.createElement('link');
            link.rel = 'icon';
            document.head.appendChild(link);
        }
        link.href = savedFavicon;
    }
})();