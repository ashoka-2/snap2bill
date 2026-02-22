// (function() {
//     const root = document.documentElement;
//
//     // --- 1. Restore Theme (Light/Dark) ---
//     const savedTheme = localStorage.getItem('theme') || 'light';
//     root.setAttribute('data-theme', savedTheme);
//
//     // --- 2. Restore Custom Colors ---
//     // Comprehensive list of all customizable variables
//     const colorVars = [
//         '--primary',
//         '--accent',
//         '--text-main',
//         '--text-soft',
//         '--bg-body',
//         '--surface',
//         '--line',
//         '--danger'
//     ];
//
//     colorVars.forEach(variable => {
//         const savedColor = localStorage.getItem(variable);
//         if (savedColor) {
//             root.style.setProperty(variable, savedColor);
//         }
//     });
//
//     // --- 3. Restore Favicon ---
//     const savedFavicon = localStorage.getItem('siteFavicon');
//     if (savedFavicon) {
//         // Look for existing favicon link or create one
//         let link = document.querySelector("link[rel~='icon']");
//         if (!link) {
//             link = document.createElement('link');
//             link.rel = 'icon';
//             document.head.appendChild(link);
//         }
//         link.href = savedFavicon;
//     }
// })();
//
//
//

(function() {
    const root = document.documentElement;

    // 1. Restore Theme (Light/Dark)
    const savedTheme = localStorage.getItem('theme') || 'light';
    root.setAttribute('data-theme', savedTheme);

    // 2. Restore Custom Colors
    const colorVars = [
        '--primary', '--accent', '--bg-body', '--surface',
        '--text-main', '--text-soft', '--line', '--danger'
    ];

    colorVars.forEach(variable => {
        const savedColor = localStorage.getItem(variable);
        if (savedColor) {
            root.style.setProperty(variable, savedColor);
        }
    });

    // 3. Restore Favicon
    const savedFavicon = localStorage.getItem('siteFavicon');
    if (savedFavicon) {
        let link = document.querySelector("link[rel~='icon']");
        if (!link) {
            link = document.createElement('link');
            link.rel = 'icon';
            document.head.appendChild(link);
        }
        link.href = savedFavicon;
    }
})();



/* =========================================
   ✨ AUTO-INJECT MAGIC CURSOR (60FPS+ LERP)
   ========================================= */
document.addEventListener("DOMContentLoaded", () => {
    if (window.matchMedia("(pointer: fine)").matches) {

        const dot = document.createElement('div');
        dot.className = 'cursor-dot';
        const outline = document.createElement('div');
        outline.className = 'cursor-outline';

        document.body.appendChild(dot);
        document.body.appendChild(outline);

        // Variables for LERP (Linear Interpolation)
        let mouseX = window.innerWidth / 2; // Center default
        let mouseY = window.innerHeight / 2;
        let outlineX = mouseX;
        let outlineY = mouseY;
        let isVisible = false;

        // Track exact mouse position instantly
        window.addEventListener('mousemove', (e) => {
            mouseX = e.clientX;
            mouseY = e.clientY;

            // Make it visible only on the first move (Fixes the top-left glitch)
            if (!isVisible) {
                outlineX = mouseX; // Snap to mouse instantly first time
                outlineY = mouseY;
                dot.style.opacity = 1;
                outline.style.opacity = 1;
                isVisible = true;
            }

            // Dot moves instantly with mouse
            dot.style.transform = `translate(${mouseX}px, ${mouseY}px) translate(-50%, -50%)`;
        });

        // The Smooth Animation Loop (Runs synced with screen refresh rate)
        const render = () => {
            if (isVisible) {
                // Lerp formula: current + (target - current) * speed (0.15 is smoothness)
                outlineX += (mouseX - outlineX) * 0.15;
                outlineY += (mouseY - outlineY) * 0.15;

                // Apply calculated smooth position
                outline.style.transform = `translate(${outlineX}px, ${outlineY}px) translate(-50%, -50%)`;
            }
            requestAnimationFrame(render);
        };
        requestAnimationFrame(render); // Start the loop

        // Hover & Click Effects
        const setupHoverEffects = () => {
            const clickables = document.querySelectorAll('a, button, input, select, textarea, .more-section, .action-btn, .mid-left-navbars, .setting-menu-dropdown');
            clickables.forEach(el => {
                if(!el.dataset.cursorAttached) {
                    el.addEventListener('mouseenter', () => outline.classList.add('hover-active'));
                    el.addEventListener('mouseleave', () => outline.classList.remove('hover-active'));
                    el.dataset.cursorAttached = "true";
                }
            });
        };

        setupHoverEffects();

        window.addEventListener('mousedown', () => outline.classList.add('click-active'));
        window.addEventListener('mouseup', () => outline.classList.remove('click-active'));

        const observer = new MutationObserver(setupHoverEffects);
        observer.observe(document.body, { childList: true, subtree: true });

        // Hide cursor when leaving the window
        document.addEventListener('mouseleave', () => {
            dot.style.opacity = 0;
            outline.style.opacity = 0;
            isVisible = false;
        });
    }
});