<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Admin Dashboard - e-Renang UPSI</title>
  <!-- Google Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;700;800&display=swap" rel="stylesheet">
  <!-- Tailwind CSS Local -->
  <link rel="stylesheet" href="css/style.css">
  <!-- Lucide Icons Local -->
  <script src="js/lucide.min.js"></script>
  <script>
    tailwind.config = {
      theme: {
        extend: {
          fontFamily: {
            outfit: ['Outfit', 'sans-serif'],
          }
        }
      }
    }
  </script>
</head>
<body class="min-h-screen bg-[#F4F6F9] flex font-outfit text-[#1E293B]">

  <!-- Mobile Sidebar Menu Overlay -->
  <div id="mobile-sidebar" class="hidden fixed inset-0 z-40 lg:hidden">
    <div class="fixed inset-0 bg-black/50" onclick="toggleMobileSidebar(false)"></div>
    <div class="fixed inset-y-0 left-0 w-64 bg-[#002F6C] shadow-xl z-50 flex flex-col justify-between p-4 text-white">
      <div id="mobile-sidebar-nav-container">
        <!-- Sidebar Navigation -->
      </div>
    </div>
  </div>

  <!-- Sidebar - Desktop -->
  <aside class="hidden lg:flex flex-col w-64 shrink-0 bg-[#002F6C] text-white p-4 justify-between sticky top-0 h-screen shadow-lg z-20">
    <div class="space-y-6">
      <div class="flex items-center space-x-2 py-4 px-2">
        <i data-lucide="droplet" class="h-8 w-8 text-[#C5A880] fill-[#C5A880]"></i>
        <div>
          <h1 class="text-lg font-black tracking-wider uppercase leading-none">e-Renang Admin</h1>
          <p class="text-[10px] text-gray-400 mt-1">Pool Operations Portal</p>
        </div>
      </div>

      <nav class="space-y-2">
        <button onclick="switchTab('dashboard')" id="btn-sidebar-dash" class="w-full flex items-center space-x-3 px-4 py-3 rounded-xl transition bg-[#C5A880]/20 text-[#C5A880] font-bold border-l-4 border-[#C5A880]">
          <i data-lucide="layout-dashboard" class="h-5 w-5"></i>
          <span>Dashboard</span>
        </button>

        <button onclick="openWalkIn()" class="w-full flex items-center space-x-3 px-4 py-3 text-gray-300 hover:text-white hover:bg-white/5 rounded-xl transition text-left">
          <i data-lucide="plus-circle" class="h-5 w-5 text-green-400"></i>
          <span>Manual Walk-In</span>
        </button>

        <button onclick="fetchData()" class="w-full flex items-center space-x-3 px-4 py-3 text-gray-300 hover:text-white hover:bg-white/5 rounded-xl transition text-left">
          <i data-lucide="refresh-cw" class="h-5 w-5 text-blue-400"></i>
          <span>Sync & Refresh</span>
        </button>

        <button onclick="switchTab('announcements')" id="btn-sidebar-ann" class="w-full flex items-center space-x-3 px-4 py-3 text-gray-300 hover:text-white hover:bg-white/5 rounded-xl transition">
          <i data-lucide="message-square" class="h-5 w-5"></i>
          <span>Manage Inbox</span>
        </button>

        <a href="index.php" class="w-full flex items-center space-x-3 px-4 py-3 text-gray-300 hover:text-white hover:bg-white/5 rounded-xl transition">
          <i data-lucide="home" class="h-5 w-5"></i>
          <span>Back to Home</span>
        </a>
      </nav>
    </div>

    <button onclick="signOutUser()" class="w-full flex items-center space-x-3 px-4 py-3.5 bg-red-600/10 border border-red-500/20 text-red-300 hover:bg-red-600 hover:text-white rounded-xl transition font-semibold">
      <i data-lucide="log-out" class="h-5 w-5"></i>
      <span>Log Out Operator</span>
    </button>
  </aside>

  <!-- Main Content Area -->
  <div class="flex-grow flex flex-col min-w-0">
    <!-- Top Header Bar -->
    <header class="bg-white border-b border-gray-100 sticky top-0 z-10 px-4 sm:px-6 lg:px-8 py-4 shadow-sm flex items-center justify-between">
      <div class="flex items-center space-x-3">
        <button onclick="toggleMobileSidebar(true)" class="lg:hidden p-2 rounded-lg text-gray-500 hover:text-gray-600 hover:bg-gray-100">
          <i data-lucide="menu" class="h-6 w-6"></i>
        </button>
        <h2 id="header-title" class="text-xl font-extrabold text-[#002F6C]">Booking Overview</h2>
      </div>

      <div class="flex items-center space-x-4">
        <span class="hidden sm:inline-block text-xs font-semibold text-gray-500 bg-gray-100 px-3 py-1 rounded-full uppercase tracking-wider">
          Operator
        </span>
        <div class="w-8 h-8 rounded-full bg-[#002F6C] flex items-center justify-center border border-[#C5A880] overflow-hidden">
          <span class="text-white text-xs font-bold">OP</span>
        </div>
      </div>
    </header>

    <!-- Main Views -->
    <main class="flex-grow p-4 sm:p-6 lg:p-8 space-y-6">

      <!-- View 1: Dashboard Panel -->
      <section id="view-dashboard" class="space-y-6">
        
        <!-- Stats Cards Row -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
          <!-- Total Bookings -->
          <div class="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm flex items-center gap-4">
            <div class="bg-blue-50 text-blue-600 p-3 rounded-xl">
              <i data-lucide="calendar" class="h-6 w-6"></i>
            </div>
            <div>
              <p class="text-xs text-gray-400 font-bold uppercase tracking-wider">Total Bookings</p>
              <p id="stat-total" class="text-2xl font-black text-gray-800">0</p>
            </div>
          </div>

          <!-- Pending Requests -->
          <div class="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm flex items-center gap-4">
            <div class="bg-orange-50 text-orange-600 p-3 rounded-xl">
              <i data-lucide="clock" class="h-6 w-6"></i>
            </div>
            <div>
              <p class="text-xs text-gray-400 font-bold uppercase tracking-wider">Pending Requests</p>
              <p id="stat-pending" class="text-2xl font-black text-gray-800">0</p>
            </div>
          </div>

          <!-- Swimmers Checked-in -->
          <div class="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm flex items-center gap-4">
            <div class="bg-teal-50 text-teal-600 p-3 rounded-xl">
              <i data-lucide="droplet" class="h-6 w-6"></i>
            </div>
            <div>
              <p class="text-xs text-gray-400 font-bold uppercase tracking-wider">In Pool Now</p>
              <p id="stat-in-pool" class="text-2xl font-black text-gray-800">0</p>
            </div>
          </div>

          <!-- Revenue -->
          <div class="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm flex items-center gap-4">
            <div class="bg-green-50 text-green-600 p-3 rounded-xl">
              <i data-lucide="coins" class="h-6 w-6"></i>
            </div>
            <div>
              <p class="text-xs text-gray-400 font-bold uppercase tracking-wider">Total Revenue</p>
              <p id="stat-revenue" class="text-2xl font-black text-gray-800">RM 0.00</p>
            </div>
          </div>
        </div>

        <!-- Booking Manager Panel -->
        <div class="bg-white rounded-3xl border border-gray-100 shadow-sm p-6">
          <div class="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-6">
            <h3 class="text-lg font-black text-[#002F6C] tracking-wide">
              Booking Manager (<span id="display-bookings-count">0</span>)
            </h3>

            <!-- Filter and Search -->
            <div class="flex flex-col sm:flex-row gap-3">
              <!-- Search Input -->
              <div class="relative">
                <i data-lucide="search" class="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 h-4 w-4"></i>
                <input
                  type="text"
                  id="search-query"
                  placeholder="Search name, ID, email..."
                  oninput="filterAndRenderBookings()"
                  class="pl-9 pr-4 py-2 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20 w-full sm:w-56 text-[#1E293B]"
                />
              </div>

              <!-- Status Dropdown -->
              <select
                id="filter-status"
                onchange="filterAndRenderBookings()"
                class="px-3 py-2 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20 bg-white cursor-pointer"
              >
                <option value="All">All Statuses</option>
                <option value="Pending">Pending</option>
                <option value="Approved">Approved</option>
                <option value="Checked In">Checked In</option>
                <option value="Cancelled">Cancelled</option>
              </select>
            </div>
          </div>

          <!-- Bookings List Table/Grid -->
          <div id="bookings-loader" class="py-12 flex justify-center">
            <div class="w-8 h-8 border-3 border-[#002F6C] border-t-transparent rounded-full animate-spin"></div>
          </div>
          
          <div id="bookings-list" class="space-y-4"></div>
        </div>

      </section>

      <!-- View 2: Announcements Panel -->
      <section id="view-announcements" class="hidden space-y-6">
        
        <div class="bg-white rounded-3xl border border-gray-100 shadow-sm p-6">
          <div class="flex justify-between items-center mb-6">
            <h3 class="text-lg font-black text-[#002F6C] tracking-wide">
              Inbox Broadcast Manager (<span id="display-announcements-count">0</span>)
            </h3>
            <button
              onclick="openAnnouncementModal(null)"
              class="bg-[#C5A880] hover:bg-[#b09268] text-[#002F6C] font-bold px-4 py-2 rounded-xl text-sm flex items-center gap-1.5 transition shadow-sm"
            >
              <i data-lucide="plus" class="h-4 w-4"></i>
              <span>New Announcement</span>
            </button>
          </div>

          <div id="announcements-loader" class="py-12 flex justify-center">
            <div class="w-8 h-8 border-3 border-[#002F6C] border-t-transparent rounded-full animate-spin"></div>
          </div>

          <div id="announcements-list" class="space-y-4"></div>
        </div>

      </section>

    </main>
  </div>

  <!-- Manual Walk-In Modal Dialog -->
  <div id="walkin-modal" class="hidden fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4 overflow-y-auto">
    <div class="bg-white rounded-3xl w-full max-w-lg shadow-2xl overflow-hidden my-8" onclick="event.stopPropagation()">
      <div class="bg-[#002F6C] px-6 py-4 flex items-center justify-between text-white">
        <div>
          <h3 class="text-lg font-bold">Manual Walk-in Registration</h3>
          <p class="text-xs text-white/70">Register swimmer on-the-spot</p>
        </div>
        <button onclick="closeWalkIn()" class="text-white/80 hover:text-white transition">
          <i data-lucide="x" class="h-5 w-5"></i>
        </button>
      </div>

      <form id="walkin-form" class="p-6 space-y-4 max-h-[70vh] overflow-y-auto text-[#1E293B]">
        <div id="walkin-feedback" class="hidden p-3 bg-red-50 border border-red-200 text-red-700 rounded-xl text-xs font-medium flex items-center gap-2">
          <i data-lucide="alert-triangle" class="h-4 w-4 shrink-0 text-red-500"></i>
          <span id="walkin-feedback-text"></span>
        </div>

        <div>
          <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">Swimmer Full Name</label>
          <input type="text" id="walkin-name" required placeholder="Swimmer Name" class="w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-gray-50 text-sm focus:outline-none" />
        </div>

        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">Email (Optional)</label>
            <input type="email" id="walkin-email" placeholder="email@example.com" class="w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-gray-50 text-sm focus:outline-none" />
          </div>
          <div>
            <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">Phone (Optional)</label>
            <input type="text" id="walkin-phone" placeholder="+6012345678" class="w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-gray-50 text-sm focus:outline-none" />
          </div>
        </div>

        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">Category Group</label>
            <select disabled class="w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-gray-100 text-gray-400 text-sm focus:outline-none cursor-not-allowed">
              <option value="Orang Awam">Orang Awam (Public)</option>
            </select>
          </div>
          <div>
            <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">Ticket Type</label>
            <select id="walkin-subcat" onchange="updateWalkInTotal()" class="w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-white text-sm focus:outline-none cursor-pointer"></select>
          </div>
        </div>

        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">Pool Section</label>
            <select id="walkin-pool" class="w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-white text-sm focus:outline-none cursor-pointer">
              <option value="Kolam Utama">Kolam Utama</option>
              <option value="Kolam Renang Biasa">Kolam Renang Biasa</option>
              <option value="Kolam Kanak-Kanak">Kolam Kanak-Kanak</option>
            </select>
          </div>
          <div>
            <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">Time Session</label>
            <select id="walkin-slot" class="w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-white text-sm focus:outline-none cursor-pointer">
              <option value="Sesi Pagi (8.30 pg - 12.30 tghari)">Sesi Pagi (8.30 pg - 12.30 tghari)</option>
              <option value="Sesi Petang (2.30 ptg - 6.30 ptg)">Sesi Petang (2.30 ptg - 6.30 ptg)</option>
              <option value="Sesi Petang (3.00 ptg - 6.30 ptg)">Sesi Petang (3.00 ptg - 6.30 ptg)</option>
              <option value="Sesi Petang - Ladies Day (2.30 ptg - 6.30 ptg)">Sesi Petang - Ladies Day (2.30 ptg - 6.30 ptg)</option>
            </select>
          </div>
        </div>

        <div class="grid grid-cols-2 gap-3">
          <div>
            <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">Booking Date</label>
            <input type="date" id="walkin-date" required class="w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-white text-sm focus:outline-none" />
          </div>
          <div>
            <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">Slots / Swimmers (Max 2)</label>
            <input type="number" id="walkin-qty" min="1" max="2" required value="1" oninput="updateWalkInTotal()" class="w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-white text-sm focus:outline-none" />
          </div>
        </div>

        <div>
          <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">Remarks / Catatan</label>
          <textarea id="walkin-notes" rows="2" placeholder="Catatan pendaftaran" class="w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-gray-50 text-sm focus:outline-none"></textarea>
        </div>

        <div class="border-t border-gray-100 pt-4 flex items-center justify-between">
          <div>
            <p class="text-xs text-gray-400 font-bold uppercase">Calculated Total</p>
            <p class="text-xl font-black text-[#002F6C]" id="walkin-total-text">RM 0.00</p>
          </div>
          <div class="flex gap-2">
            <button type="button" onclick="closeWalkIn()" class="px-4 py-2.5 border border-gray-200 rounded-xl text-sm font-semibold text-gray-600 hover:bg-gray-50 transition">Cancel</button>
            <button type="submit" class="bg-green-600 hover:bg-green-700 text-white px-5 py-2.5 rounded-xl text-sm font-bold transition shadow-md">Register & Check In</button>
          </div>
        </div>
      </form>
    </div>
  </div>

  <!-- Compose Announcement Modal Dialog -->
  <div id="announcement-modal" class="hidden fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4 animate-fadeIn">
    <div class="bg-white rounded-3xl w-full max-w-md overflow-hidden shadow-2xl text-[#1E293B]" onclick="event.stopPropagation()">
      <div class="bg-[#002F6C] px-6 py-4 flex items-center justify-between text-white">
        <h3 id="ann-modal-title" class="text-lg font-bold">Compose New Announcement</h3>
        <button onclick="closeAnnouncementModal()" class="text-white/80 hover:text-white transition">
          <i data-lucide="x" class="h-5 w-5"></i>
        </button>
      </div>

      <form id="announcement-form" class="p-6 space-y-4">
        <div id="ann-feedback" class="hidden p-3 bg-red-50 text-red-700 rounded-xl text-xs font-semibold"></div>

        <div>
          <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">Title</label>
          <input type="text" id="ann-title" required placeholder="e.g. Pool Maintenance Notice" class="w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-gray-50 text-sm focus:outline-none" />
        </div>

        <div>
          <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">Content Body</label>
          <textarea id="ann-content" rows="5" required placeholder="Announcement details..." class="w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-gray-50 text-sm focus:outline-none"></textarea>
        </div>

        <div class="flex gap-3 pt-2">
          <button type="button" onclick="closeAnnouncementModal()" class="w-1/2 border border-gray-200 py-3 rounded-xl text-gray-600 hover:bg-gray-50 transition text-sm font-semibold">Cancel</button>
          <button type="submit" id="btn-ann-submit" class="w-1/2 bg-[#002F6C] hover:bg-[#00204a] text-white py-3 rounded-xl transition text-sm font-semibold">Broadcast</button>
        </div>
      </form>
    </div>
  </div>

  <!-- Supabase Local -->
  <script src="js/supabase.min.js"></script>
  <!-- App Auth & Utilities -->
  <script src="js/auth.js"></script>
  <script src="js/main.js"></script>

  <script>
    // Walkin Dropdown data
    const CATEGORIES = [
      { name: 'Kanak-kanak (0-4 tahun)', price: 0.0 },
      { name: 'Kanak-kanak (5-7 tahun)', price: 1.0 },
      { name: 'Pelajar Sekolah & IPT (8-18 tahun)', price: 5.0 },
      { name: 'Dewasa', price: 10.0 },
      { name: 'Warga Emas (60 tahun ke atas)', price: 5.0 },
      { name: 'Pesara / Pencen Kerajaan', price: 5.0 },
      { name: 'OKU - Kanak-kanak (0-7 tahun)', price: 0.0 },
      { name: 'OKU - Kanak-kanak (8-17 tahun)', price: 3.0 },
      { name: 'OKU - Dewasa', price: 5.0 },
    ];

    let bookings = [];
    let announcements = [];
    let editingAnnouncement = null;
    let currentTabActive = 'dashboard';

    // Build sidebar options and copy to mobile drawer
    function syncSidebarToMobile() {
      const desktopNav = document.querySelector('aside nav').innerHTML;
      const mobileNavContainer = document.getElementById('mobile-sidebar-nav-container');
      
      mobileNavContainer.innerHTML = `
        <div class="flex items-center space-x-2 py-4 px-2 border-b border-white/10 mb-6">
          <i data-lucide="droplet" class="h-8 w-8 text-[#C5A880] fill-[#C5A880]"></i>
          <div>
            <h1 class="text-lg font-black tracking-wider uppercase leading-none">e-Renang Admin</h1>
            <p class="text-[10px] text-gray-400 mt-1">Pool Operations Portal</p>
          </div>
        </div>
        <nav class="space-y-2">
          ${desktopNav}
        </nav>
      `;
      if (window.updateIcons) window.updateIcons();
    }

    function toggleMobileSidebar(open) {
      const drawer = document.getElementById('mobile-sidebar');
      if (open) {
        drawer.classList.remove('hidden');
      } else {
        drawer.classList.add('hidden');
      }
    }

    function switchTab(tab) {
      currentTabActive = tab;
      
      const viewDash = document.getElementById('view-dashboard');
      const viewAnn = document.getElementById('view-announcements');
      
      const btnDash = document.getElementById('btn-sidebar-dash');
      const btnAnn = document.getElementById('btn-sidebar-ann');
      
      const headerTitle = document.getElementById('header-title');

      // Reset styles
      [btnDash, btnAnn].forEach(btn => {
        if(btn) btn.className = "w-full flex items-center space-x-3 px-4 py-3 text-gray-300 hover:text-white hover:bg-white/5 rounded-xl transition text-left";
      });

      if (tab === 'dashboard') {
        viewDash.classList.remove('hidden');
        viewAnn.classList.add('hidden');
        if (btnDash) btnDash.className = "w-full flex items-center space-x-3 px-4 py-3 rounded-xl transition bg-[#C5A880]/20 text-[#C5A880] font-bold border-l-4 border-[#C5A880] text-left";
        headerTitle.textContent = "Booking Overview";
      } else {
        viewDash.add && viewDash.classList.add('hidden'); // fallback
        viewDash.classList.add('hidden');
        viewAnn.classList.remove('hidden');
        if (btnAnn) btnAnn.className = "w-full flex items-center space-x-3 px-4 py-3 rounded-xl transition bg-[#C5A880]/20 text-[#C5A880] font-bold border-l-4 border-[#C5A880] text-left";
        headerTitle.textContent = "Manage Announcements";
      }

      toggleMobileSidebar(false);
      // Sync styles to mobile too
      syncSidebarToMobile();
    }

    // Sync all
    async function fetchData() {
      document.getElementById('bookings-loader').classList.remove('hidden');
      document.getElementById('announcements-loader').classList.remove('hidden');
      document.getElementById('bookings-list').innerHTML = '';
      document.getElementById('announcements-list').innerHTML = '';

      try {
        await Promise.all([fetchBookings(), fetchAnnouncements()]);
      } catch (err) {
        console.error("Data load failed:", err);
      } finally {
        document.getElementById('bookings-loader').classList.add('hidden');
        document.getElementById('announcements-loader').classList.add('hidden');
      }
    }

    async function fetchBookings() {
      const { data, error } = await window.supabaseClient
        .from('bookings')
        .select('*')
        .order('booking_date', { ascending: false });

      if (error) throw error;
      bookings = data || [];
      
      calculateStats(bookings);
      filterAndRenderBookings();
    }

    async function fetchAnnouncements() {
      const { data, error } = await window.supabaseClient
        .from('announcements')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) throw error;
      announcements = data || [];

      document.getElementById('display-announcements-count').textContent = announcements.length;
      renderAnnouncements();
    }

    function calculateStats(list) {
      const total = list.length;
      const pending = list.filter(b => b.status === 'Pending').length;
      const inPool = list.filter(b => b.status === 'Checked In').length;
      const revenue = list.filter(b => b.status !== 'Cancelled').reduce((sum, b) => sum + (b.total_price || 0), 0);

      document.getElementById('stat-total').textContent = total;
      document.getElementById('stat-pending').textContent = pending;
      document.getElementById('stat-in-pool').textContent = inPool;
      document.getElementById('stat-revenue').textContent = "RM " + revenue.toFixed(2);
    }

    // Render bookings table
    function filterAndRenderBookings() {
      const query = document.getElementById('search-query').value.toLowerCase();
      const status = document.getElementById('filter-status').value;
      const container = document.getElementById('bookings-list');
      
      container.innerHTML = '';

      const filtered = bookings.filter(b => {
        const matchesStatus = status === 'All' || b.status === status;
        const matchesSearch = (b.name || '').toLowerCase().includes(query) ||
                              (b.email || '').toLowerCase().includes(query) ||
                              (b.upsi_id || '').toLowerCase().includes(query) ||
                              (b.qr_code || '').toLowerCase().includes(query);
        return matchesStatus && matchesSearch;
      });

      document.getElementById('display-bookings-count').textContent = filtered.length;

      if (filtered.length === 0) {
        container.innerHTML = `
          <div class="text-center py-12 text-gray-400">
            <i data-lucide="calendar" class="h-12 w-12 mx-auto mb-3 opacity-30"></i>
            <p class="font-bold text-sm">No bookings found matching filters</p>
          </div>
        `;
        if (window.updateIcons) window.updateIcons();
        return;
      }

      filtered.forEach(booking => {
        let badgeColor = 'bg-gray-100 text-gray-800';
        if (booking.status === 'Pending') badgeColor = 'bg-orange-50 text-orange-700 border border-orange-200';
        if (booking.status === 'Approved') badgeColor = 'bg-green-50 text-green-700 border border-green-200';
        if (booking.status === 'Checked In') badgeColor = 'bg-blue-50 text-blue-700 border border-blue-200';
        if (booking.status === 'Cancelled') badgeColor = 'bg-red-50 text-red-700 border border-red-200';

        const row = document.createElement('div');
        row.className = "border border-gray-100 rounded-2xl p-5 hover:bg-gray-50/50 transition flex flex-col md:flex-row justify-between items-start md:items-center gap-4 text-[#1E293B]";
        
        let actionButtons = '';
        if (booking.status === 'Pending') {
          actionButtons = `
            <button onclick="updateBookingStatus('${booking.id}', 'Approved')" class="bg-[#002F6C] hover:bg-[#00204a] text-white px-4 py-2 rounded-xl text-xs font-bold transition shadow-sm">Approve</button>
            <button onclick="updateBookingStatus('${booking.id}', 'Cancelled')" class="border border-red-200 text-red-600 hover:bg-red-50 px-4 py-2 rounded-xl text-xs font-bold transition">Cancel</button>
          `;
        } else if (booking.status === 'Approved') {
          actionButtons = `
            <button onclick="updateBookingStatus('${booking.id}', 'Checked In')" class="bg-teal-600 hover:bg-teal-700 text-white px-4 py-2 rounded-xl text-xs font-bold transition shadow-sm">Check In</button>
            <button onclick="updateBookingStatus('${booking.id}', 'Cancelled')" class="border border-red-200 text-red-600 hover:bg-red-50 px-4 py-2 rounded-xl text-xs font-bold transition">Cancel</button>
          `;
        }

        row.innerHTML = `
          <div class="space-y-2">
            <div class="flex flex-wrap items-center gap-2">
              <span class="font-bold text-gray-800 text-base">${booking.name}</span>
              <span class="bg-gray-100 text-gray-600 text-[10px] font-bold px-2 py-0.5 rounded-full uppercase">${booking.sub_category}</span>
              <span class="text-[10px] font-bold px-2 py-0.5 rounded-full uppercase ${badgeColor}">${booking.status}</span>
            </div>
            
            <div class="grid grid-cols-1 sm:grid-cols-2 gap-x-6 gap-y-1 text-xs text-gray-500">
              <p><span class="font-semibold text-gray-400">Date:</span> ${booking.booking_date}</p>
              <p><span class="font-semibold text-gray-400">Slot:</span> ${booking.time_slot}</p>
              <p><span class="font-semibold text-gray-400">Pool:</span> ${booking.pool_type}</p>
              <p><span class="font-semibold text-gray-400">ID/Email:</span> ${booking.upsi_id || booking.email || 'N/A'}</p>
              <p><span class="font-semibold text-gray-400">Ticket QR:</span> ${booking.qr_code}</p>
              <p><span class="font-semibold text-gray-400">Qty:</span> ${booking.quantity} (Total: RM ${Number(booking.total_price || 0).toFixed(2)})</p>
            </div>
          </div>

          <div class="flex flex-wrap gap-2 w-full md:w-auto justify-end">
            ${actionButtons}
            <button onclick="deleteBookingRecord('${booking.id}')" class="bg-red-50 hover:bg-red-100 text-red-600 p-2 rounded-xl border border-red-100 transition" title="Delete Booking Record">
              <i data-lucide="trash-2" class="h-4 w-4"></i>
            </button>
          </div>
        `;

        container.appendChild(row);
      });

      if (window.updateIcons) window.updateIcons();
    }

    async function updateBookingStatus(id, status) {
      try {
        const { error } = await window.supabaseClient
          .from('bookings')
          .update({ status: status })
          .eq('id', id);

        if (error) throw error;
        fetchBookings();
      } catch (err) {
        console.error('Status change error:', err);
        alert('Failed to update status.');
      }
    }

    async function deleteBookingRecord(id) {
      if (!confirm('Are you sure you want to delete this booking record?')) return;
      try {
        const { error } = await window.supabaseClient
          .from('bookings')
          .delete()
          .eq('id', id);

        if (error) throw error;
        fetchBookings();
      } catch (err) {
        console.error('Delete error:', err);
        alert('Failed to delete booking.');
      }
    }

    // Announcements Handler
    function renderAnnouncements() {
      const container = document.getElementById('announcements-list');
      container.innerHTML = '';

      if (announcements.length === 0) {
        container.innerHTML = `
          <div class="text-center py-12 text-gray-400">
            <i data-lucide="message-square" class="h-12 w-12 mx-auto mb-3 opacity-30"></i>
            <p class="font-bold text-sm">No announcements broadcasted yet</p>
          </div>
        `;
        if (window.updateIcons) window.updateIcons();
        return;
      }

      announcements.forEach(ann => {
        const row = document.createElement('div');
        row.className = "border border-gray-100 rounded-2xl p-5 flex justify-between items-start gap-4 hover:bg-gray-50/50 transition";
        row.innerHTML = `
          <div class="space-y-1.5 flex-1 min-w-0">
            <h4 class="font-extrabold text-gray-800 text-sm truncate">${ann.title}</h4>
            <p class="text-xs text-gray-400">Posted on: ${new Date(ann.created_at).toLocaleString()}</p>
            <p class="text-xs text-gray-600 line-clamp-3 leading-relaxed whitespace-pre-line mt-2">${ann.content}</p>
          </div>

          <div class="flex gap-2">
            <button onclick='openAnnouncementModal(${JSON.stringify(ann)})' class="bg-blue-50 text-blue-600 p-2 rounded-xl border border-blue-100 hover:bg-blue-100 transition">
              <i data-lucide="edit" class="h-4 w-4"></i>
            </button>
            <button onclick="deleteAnnouncement('${ann.id}')" class="bg-red-50 text-red-600 p-2 rounded-xl border border-red-100 hover:bg-red-100 transition">
              <i data-lucide="trash" class="h-4 w-4"></i>
            </button>
          </div>
        `;
        container.appendChild(row);
      });

      if (window.updateIcons) window.updateIcons();
    }

    function openAnnouncementModal(ann) {
      editingAnnouncement = ann;
      const modalTitle = document.getElementById('ann-modal-title');
      const titleInput = document.getElementById('ann-title');
      const contentText = document.getElementById('ann-content');
      
      document.getElementById('ann-feedback').classList.add('hidden');

      if (ann) {
        modalTitle.textContent = "Edit Announcement";
        titleInput.value = ann.title;
        contentText.value = ann.content;
      } else {
        modalTitle.textContent = "Compose New Announcement";
        titleInput.value = '';
        contentText.value = '';
      }

      document.getElementById('announcement-modal').classList.remove('hidden');
      if (window.updateIcons) window.updateIcons();
    }

    function closeAnnouncementModal() {
      document.getElementById('announcement-modal').classList.add('hidden');
    }

    document.getElementById('announcement-form').addEventListener('submit', async (e) => {
      e.preventDefault();
      
      const title = document.getElementById('ann-title').value.trim();
      const content = document.getElementById('ann-content').value.trim();
      
      const feedback = document.getElementById('ann-feedback');
      const submitBtn = document.getElementById('btn-ann-submit');
      
      submitBtn.disabled = true;
      const originalText = submitBtn.textContent;
      submitBtn.innerHTML = `<div class="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>`;

      try {
        if (editingAnnouncement) {
          // Edit
          const { error } = await window.supabaseClient
            .from('announcements')
            .update({ title, content })
            .eq('id', editingAnnouncement.id);
          if (error) throw error;
        } else {
          // Create
          const { error } = await window.supabaseClient
            .from('announcements')
            .insert({ title, content, created_by: currentUser.id });
          if (error) throw error;
        }

        closeAnnouncementModal();
        fetchAnnouncements();
      } catch (err) {
        console.error('Save announcement error:', err);
        feedback.textContent = err.message || 'Failed to save announcement.';
        feedback.classList.remove('hidden');
      } finally {
        submitBtn.disabled = false;
        submitBtn.textContent = originalText;
      }
    });

    async function deleteAnnouncement(id) {
      if (!confirm('Delete this announcement?')) return;
      try {
        const { error } = await window.supabaseClient
          .from('announcements')
          .delete()
          .eq('id', id);

        if (error) throw error;
        fetchAnnouncements();
      } catch (err) {
        console.error('Delete announcement error:', err);
        alert('Failed to delete announcement.');
      }
    }

    // Manual Walk-In Handlers
    function openWalkIn() {
      // Load Walkin Subcategories
      const subcatSelect = document.getElementById('walkin-subcat');
      subcatSelect.innerHTML = '';
      
      CATEGORIES.forEach(cat => {
        const opt = document.createElement('option');
        opt.value = cat.name;
        opt.textContent = `${cat.name} (RM ${cat.price.toFixed(2)})`;
        subcatSelect.appendChild(opt);
      });

      // Set default fields
      document.getElementById('walkin-name').value = '';
      document.getElementById('walkin-email').value = '';
      document.getElementById('walkin-phone').value = '';
      document.getElementById('walkin-notes').value = '';
      document.getElementById('walkin-qty').value = 1;
      
      const todayISO = new Date().toISOString().split('T')[0];
      document.getElementById('walkin-date').value = todayISO;

      document.getElementById('walkin-feedback').classList.add('hidden');
      updateWalkInTotal();

      document.getElementById('walkin-modal').classList.remove('hidden');
      if (window.updateIcons) window.updateIcons();
    }

    function closeWalkIn() {
      document.getElementById('walkin-modal').classList.add('hidden');
    }

    function updateWalkInTotal() {
      const subcatName = document.getElementById('walkin-subcat').value;
      const qty = Math.min(2, parseInt(document.getElementById('walkin-qty').value) || 1); // Limit walkin qty to 2 max
      document.getElementById('walkin-qty').value = qty;

      const subcatObj = CATEGORIES.find(c => c.name === subcatName);
      const pricePer = subcatObj ? subcatObj.price : 0;
      const total = pricePer * qty;

      document.getElementById('walkin-total-text').textContent = "RM " + total.toFixed(2);
    }

    document.getElementById('walkin-form').addEventListener('submit', async (e) => {
      e.preventDefault();
      
      const name = document.getElementById('walkin-name').value.trim();
      const email = document.getElementById('walkin-email').value.trim();
      const phone = document.getElementById('walkin-phone').value.trim();
      const subCategory = document.getElementById('walkin-subcat').value;
      const poolType = document.getElementById('walkin-pool').value;
      const timeSlot = document.getElementById('walkin-slot').value;
      const bookingDate = document.getElementById('walkin-date').value;
      const quantity = Math.min(2, parseInt(document.getElementById('walkin-qty').value) || 1);
      const notes = document.getElementById('walkin-notes').value.trim() || 'Pendaftaran Walk-in oleh operator.';
      
      const feedback = document.getElementById('walkin-feedback');
      const feedbackText = document.getElementById('walkin-feedback-text');

      feedback.classList.add('hidden');

      try {
        const subcatObj = CATEGORIES.find(c => c.name === subCategory);
        const pricePerTicket = subcatObj ? subcatObj.price : 0;
        const total_price = pricePerTicket * quantity;

        const tempId = Math.random().toString(36).substr(2, 9).toUpperCase();
        const qrCode = `UP-${tempId}-WALKIN`;

        const newBooking = {
          name,
          email: email || null,
          phone: phone || null,
          upsi_id: '',
          user_type: 'Orang Awam',
          sub_category: subCategory,
          pool_type: poolType,
          booking_date: bookingDate,
          time_slot: timeSlot,
          quantity,
          total_price,
          status: 'Approved', // Walk-ins auto-approved
          qr_code: qrCode,
          notes: notes
        };

        const { error } = await window.supabaseClient
          .from('bookings')
          .insert(newBooking);

        if (error) throw error;

        closeWalkIn();
        fetchBookings();
        alert('Walk-in booking created and checked in successfully!');

      } catch (err) {
        console.error('Walk-in creation error:', err);
        feedbackText.textContent = err.message || 'Failed to create walk-in booking.';
        feedback.classList.remove('hidden');
      }
    });

    onAuthResolve((user, profile) => {
      if (!user || profile.role !== 'admin') {
        window.location.href = 'index.php'; // Guard redirect
        return;
      }
      
      syncSidebarToMobile();
      fetchData();
    });
  </script>
</body>
</html>
