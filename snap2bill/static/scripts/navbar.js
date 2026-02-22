const menuRouteMap = {
  "/admin_home": ["/admin_home"],
  "/admin_category": ["/admin_category", "/admin_add_category", "/edit_category"],
  "/admin_viewcustomer": ["/admin_viewcustomer"],
  "/admin_verify": ["/admin_verify"],
  "/admin_verified": ["/admin_verified"],
  "/admin_review": ["/admin_review"],
  "/admin_setting": ["/admin_setting"],
  "/view_product": ["/view_product", "/add_product", "/edit_product"],
  "/customer_feedbacks": ["/customer_feedbacks"],
  "/distributor_feedbacks": ["/distributor_feedbacks"],
  "/manage_units": ["/manage_units"]
};

const leftNavbar = `
    <div class="admin-top-left-content">
        <div class="admin-logo-box">
            <span class="logo-text">SNAP2BILL</span>
            <span class="sub-logo">ADMIN PANEL</span>
        </div>
    </div>
    
    <div class="admin-mid-left-content">
        <div id="navbar-section">
            <p class="nav-label">MAIN MENU</p>
            <a class="nav-links" href="/admin_home"><div class="mid-left-navbars"><i class="ri-dashboard-fill"></i><span>Overview</span></div></a>
            <a class="nav-links" href="/admin_viewcustomer"><div class="mid-left-navbars"><i class="ri-group-fill"></i><span>Customers</span></div></a>
            <a class="nav-links" href="/admin_verify"><div class="mid-left-navbars"><i class="ri-shield-user-fill"></i><span>Verification</span></div></a>
            <a class="nav-links" href="/admin_verified"><div class="mid-left-navbars"><i class="ri-verified-badge-fill"></i><span>Verified Team</span></div></a>
            
            <p class="nav-label">CATALOG</p>
            <a class="nav-links" href="/admin_category"><div class="mid-left-navbars"><i class="ri-layout-grid-fill"></i><span>Categories</span></div></a>
            <a class="nav-links" href="/view_product"><div class="mid-left-navbars"><i class="ri-shopping-bag-3-fill"></i><span>Products</span></div></a>
            <a class="nav-links" href="/manage_units"><div class="mid-left-navbars"><i class="ri-ruler-2-fill"></i><span>Stock Units</span></div></a>
            
            <p class="nav-label">COMMUNICATION</p>
            <a class="nav-links" href="/admin_review"><div class="mid-left-navbars"><i class="ri-star-smile-fill"></i><span>Reviews</span></div></a>
            <a class="nav-links" href="/customer_feedbacks"><div class="mid-left-navbars"><i class="ri-message-3-fill"></i><span>Cust. Feedback</span></div></a>
            <a class="nav-links" href="/distributor_feedbacks"><div class="mid-left-navbars"><i class="ri-feedback-fill"></i><span>Dist. Feedback</span></div></a>
        </div>
    </div>

    <div class="admin-bottom-left-content">
        <div class="more-section">
            <div class="more-btn-inner">
                <i class="ri-settings-4-fill"></i>
                <span>Settings</span>
                <i class="ri-arrow-up-s-line chevron"></i>
            </div>
            <div class="setting-dropdown">
                <a href="/admin_setting" class="setting-menu-dropdown"><i class="ri-user-settings-fill"></i> Customize UI</a>
                <a id="themeToggle" class="setting-menu-dropdown theme-btn">
                    <i id="themeIcon" class="ri-sun-fill"></i> Appearance
                </a>
                <hr class="dropdown-divider">
                <a href="/logout" class="setting-menu-dropdown logout-item"><i class="ri-logout-circle-r-fill"></i> Sign Out</a>
            </div>
        </div>
    </div>
`;

document.addEventListener("DOMContentLoaded", () => {
    const sidebar = document.querySelector(".admin-left-main-content");
    if (sidebar) {
        sidebar.innerHTML = leftNavbar;
        setActiveMenu();
        initSettings();
    }
});

function setActiveMenu() {
  const currentPath = window.location.pathname;

  // ---------- NORMAL NAV LINKS ----------
  document.querySelectorAll(".nav-links").forEach(link => {
    const nav = link.querySelector(".mid-left-navbars");
    if (!nav) return;

    const baseHref = link.getAttribute("href");
    const routes = menuRouteMap[baseHref] || [];

    const isActive = routes.some(route =>
      currentPath === route || currentPath.startsWith(route + "/")
    );

    nav.classList.toggle("active", isActive);
  });

  // ---------- SETTINGS LINK (SPECIAL CASE) ----------
  const settingsLink = document.querySelector(
    '.setting-dropdown a[href="/admin_setting"]'
  );
  const moreSection = document.querySelector(".more-section");

  if (settingsLink && moreSection) {
    const isSettingsActive = menuRouteMap["/admin_setting"].some(route =>
      currentPath === route || currentPath.startsWith(route + "/")
    );

    if (isSettingsActive) {
      moreSection.classList.add("active");
      settingsLink
        .querySelector(".setting-menu-dropdown")
        .classList.add("active");
    }
  }
}

    function initSettings() {
      const moreBtn = document.querySelector(".more-section");
      const dropdown = document.querySelector(".setting-dropdown");

      if (!moreBtn || !dropdown) return;

      moreBtn.addEventListener("click", e => {
        e.stopPropagation();
        dropdown.style.display =
          dropdown.style.display === "block" ? "none" : "block";
      });

      document.addEventListener("click", e => {
        if (!moreBtn.contains(e.target) && !dropdown.contains(e.target)) {
          dropdown.style.display = "none";
        }
      });
    }



    document.addEventListener("DOMContentLoaded", () => {
      const root = document.documentElement;
      const themeBtn = document.getElementById('themeToggle');
      const themeIcon = document.getElementById('themeIcon');

      if (!themeBtn || !themeIcon) return;

      const savedTheme = localStorage.getItem('theme') || 'light';
      root.setAttribute('data-theme', savedTheme);
      themeIcon.className = savedTheme === 'dark' ? 'ri-moon-line' : 'ri-sun-line';

      themeBtn.addEventListener('click', () => {
        const next = root.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
        root.setAttribute('data-theme', next);
        localStorage.setItem('theme', next);
        themeIcon.className = next === 'dark' ? 'ri-moon-line' : 'ri-sun-line';
      });
    });





      setTimeout(()=>document.querySelectorAll('.toast').forEach(t=>t.remove()),6000);
