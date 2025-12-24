    /**
     * Created by ASHOK KUMAR on 24-12-2025.
     */

    const menuRouteMap = {
  "/admin_home": [
    "/admin_home"
  ],

  "/admin_category": [
    "/admin_category",
    "/admin_add_category",
    "/edit_category"
  ],

  "/admin_viewcustomer": [
    "/admin_viewcustomer"
  ],

  "/admin_verify": [
    "/admin_verify"
  ],

  "/admin_verified": [
    "/admin_verified"
  ],

  "/admin_review": [
    "/admin_review"
  ],

  "/admin_setting": [
    "/admin_setting",

  ],

  "/view_product": [
    "/view_product",
    "/add_product",
    "/edit_product"
  ],

  "/customer_feedbacks": [
    "/customer_feedbacks"
  ],

  "/distributor_feedbacks": [
    "/distributor_feedbacks"
  ]
};








    const leftNavbar  = `<div class="admin-top-left-content">
            <div class="admin-menu">Snap2Bill <br> Admin Menu</div></div><hr>
        <div class="admin-mid-left-content">
          <div id="navbar-section">
            <a class="nav-links" href="/admin_home"><div class="mid-left-navbars"><i class="ri-home-4-line"></i><span>Home</span></div></a>
            <a class="nav-links" href="/admin_viewcustomer"><div class="mid-left-navbars"><i class="ri-user-3-line"></i><span>View Customers</span></div></a>
            <a class="nav-links" href="/admin_verify"><div class="mid-left-navbars"><i class="ri-shield-check-line"></i><span>Verify Distributors</span></div></a>
            <a class="nav-links" href="/admin_verified"><div class="mid-left-navbars"><i class="ri-award-line"></i><span>View Verified Distributors</span></div></a>
              <a class="nav-links" href="/admin_category"><div class="mid-left-navbars "><i class="ri-layout-grid-line"></i><span>Manage Category</span></div></a>
            <a class="nav-links" href="/admin_review"><div class="mid-left-navbars"><i class="ri-star-line"></i><span>View Reviews</span></div></a>
    <a class="nav-links" href="/customer_feedbacks"><div class="mid-left-navbars "><i class="ri-feedback-line"></i><span>View Customer Feedback</span></div></a>
             <a class="nav-links" href="/distributor_feedbacks"><div class="mid-left-navbars "><i class="ri-feedback-line"></i><span>View Distributor Feedback</span></div></a>
              <a class="nav-links" href="/view_product"><div class="mid-left-navbars "><i class="ri-multi-image-fill"></i><span>View products</span></div></a>
    
          </div>
        </div>
        <hr>
     <div class="admin-bottom-left-content">
          <div class="more-section"><span><i class="ri-settings-3-line"></i> Setting</span>
            <div class="setting-dropdown">
              <a href="/admin_setting"><div class="setting-menu-dropdown"><i class="ri-tools-line"></i> Settings</div></a>
              <!-- ✅ Theme toggle with Remix Icon -->
              <a id="themeToggle" type="button" class="setting-menu-dropdown theme-btn">
                <i id="themeIcon" class="ri-sun-line"></i> Switch theme
              </a>
              <a href="/logout"><div class="setting-menu-dropdown"><i class="ri-logout-box-line"></i> Logout</div></a>
            </div>
          </div>
        </div>  `;

    document.addEventListener("DOMContentLoaded", () => {
      const sidebar = document.querySelector(".admin-left-main-content");
      if (!sidebar) return;

      sidebar.innerHTML = leftNavbar;

      setActiveMenu();
      initSettings();
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
