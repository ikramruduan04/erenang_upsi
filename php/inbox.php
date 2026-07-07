<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Inbox - e-Renang UPSI</title>
  <!-- Google Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;700;800&display=swap" rel="stylesheet">
  <!-- Tailwind CSS Local -->
  <link rel="stylesheet" href="css/style.css">
  <!-- Lucide Icons Local -->
  <script src="js/lucide.min.js"></script>
  <!-- Supabase & Auth Central Logic (Loaded in head so it is ready for Navbar) -->
  <script src="js/supabase.min.js"></script>
  <script src="js/auth.js"></script>
  <script src="js/main.js"></script>
</head>
<body class="bg-[#F4F6F9] min-h-screen flex flex-col font-outfit text-[#1E293B]">

  <!-- Global Navbar -->
  <?php include 'components/navbar.php'; ?>

  <!-- Main Content Layout -->
  <main class="flex-1 flex flex-col">
    <!-- Loader Container -->
    <div id="page-loader" class="flex items-center justify-center min-h-[60vh]">
      <div class="w-10 h-10 border-4 border-[#002F6C] border-t-transparent rounded-full animate-spin"></div>
    </div>

    <!-- Inbox Page Content -->
    <div id="inbox-content" class="hidden mx-auto w-full max-w-4xl px-5 py-6">
      <!-- Header Section -->
      <div class="flex items-center justify-between mb-8">
        <div>
          <h1 class="text-3xl font-extrabold text-[#002F6C] tracking-tight">
            Announcements & Inbox
          </h1>
          <p class="text-sm text-gray-500 mt-1">
            Stay updated with pool operations, maintenance alerts, and events.
          </p>
        </div>
        <button
          onclick="fetchAnnouncements()"
          class="flex items-center space-x-1.5 bg-[#002F6C] hover:bg-[#00204a] text-white px-4 py-2 rounded-xl text-sm font-semibold transition shadow-md"
        >
          <i data-lucide="refresh-cw" class="h-4 w-4"></i>
          <span>Refresh</span>
        </button>
      </div>

      <!-- Error notification -->
      <div id="error-container" class="hidden mb-6 flex items-center gap-3 bg-red-50 border-l-4 border-red-500 text-red-700 p-4 rounded-r-lg text-sm">
        <i data-lucide="alert-circle" class="h-5 w-5 text-red-500 shrink-0"></i>
        <span id="error-message"></span>
      </div>

      <!-- Announcements Container -->
      <div id="announcements-list" class="space-y-6"></div>
    </div>
  </main>


  <script>
    // Format Time Ago
    function formatTimeAgo(dateString) {
      const date = new Date(dateString);
      const now = new Date();
      const diffMs = now - date;
      const diffMins = Math.floor(diffMs / (1000 * 60));
      const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
      const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));

      if (diffMins < 1) return 'Just now';
      if (diffMins < 60) return `${diffMins} min ago`;
      if (diffHours < 24) return `${diffHours} hours ago`;
      if (diffDays < 7) return `${diffDays} days ago`;
      
      return date.toLocaleDateString('en-MY', {
        day: '2-digit',
        month: '2-digit',
        year: 'numeric'
      });
    }

    // Helper to check if new
    function isNew(dateString) {
      const date = new Date(dateString);
      const now = new Date();
      const diffMs = now - date;
      const diffHours = diffMs / (1000 * 60 * 60);
      return diffHours < 24;
    }

    function renderAnnouncements(data) {
      const listContainer = document.getElementById('announcements-list');
      const loader = document.getElementById('page-loader');
      const inboxContent = document.getElementById('inbox-content');

      listContainer.innerHTML = '';

      if (!data || data.length === 0) {
        listContainer.innerHTML = `
          <div class="bg-white rounded-2xl border border-gray-100 shadow-sm p-12 text-center flex flex-col items-center">
            <div class="bg-[#002F6C]/5 p-5 rounded-full mb-4">
              <i data-lucide="message-square" class="h-12 w-12 text-gray-400"></i>
            </div>
            <h3 class="text-lg font-bold text-[#002F6C]">No announcements yet</h3>
            <p class="text-sm text-gray-400 mt-1 max-w-xs mx-auto">
              We'll broadcast pool announcements, closures, or notices here.
            </p>
          </div>
        `;
      } else {
        data.forEach(item => {
          const isNewItem = isNew(item.created_at);
          const newBadge = isNewItem ? `
            <span class="bg-[#C5A880] text-[#002F6C] text-[10px] font-extrabold px-2 py-0.5 rounded-full uppercase tracking-wider">
              New
            </span>
          ` : '';

          const card = document.createElement('div');
          card.className = "bg-white rounded-2xl border border-gray-100 shadow-sm hover:shadow-md transition p-6 relative overflow-hidden";
          card.innerHTML = `
            <!-- Left accent bar -->
            <div class="absolute top-0 bottom-0 left-0 w-1.5 bg-[#002F6C]"></div>

            <!-- Card Title & Badges -->
            <div class="flex items-start justify-between gap-4 mb-3 pl-2">
              <div class="flex flex-wrap items-center gap-2">
                <h2 class="text-lg font-bold text-gray-800 tracking-tight">
                  ${item.title}
                </h2>
                ${newBadge}
              </div>
              
              <!-- Timestamp -->
              <div class="flex items-center space-x-1 text-xs text-gray-400 whitespace-nowrap">
                <i data-lucide="calendar" class="h-3.5 w-3.5"></i>
                <span>${formatTimeAgo(item.created_at)}</span>
              </div>
            </div>

            <!-- Content Divider -->
            <hr class="border-gray-100 mb-4 pl-2" />

            <!-- Body Content -->
            <div class="pl-2">
              <p class="text-sm text-gray-600 leading-relaxed whitespace-pre-line">
                ${item.content}
              </p>
            </div>
          `;
          listContainer.appendChild(card);
        });
      }

      loader.classList.add('hidden');
      inboxContent.classList.remove('hidden');

      if (window.updateIcons) window.updateIcons();
    }

    async function fetchAnnouncements() {
      const loader = document.getElementById('page-loader');
      const inboxContent = document.getElementById('inbox-content');
      const errorContainer = document.getElementById('error-container');
      const errorMessage = document.getElementById('error-message');

      errorContainer.classList.add('hidden');

      // 1) Load from local cache immediately
      let hasCachedData = false;
      try {
        const cachedAnnObj = localStorage.getItem('upsi_cached_announcements');
        if (cachedAnnObj !== null) {
          const cachedData = JSON.parse(cachedAnnObj);
          renderAnnouncements(cachedData);
          hasCachedData = true;
        }
      } catch (e) {
        console.warn("Error loading cached announcements:", e);
      }

      // Show loader if no cache exists
      if (!hasCachedData) {
        loader.classList.remove('hidden');
        inboxContent.classList.add('hidden');
      }
      
      try {
        // 2) Fetch fresh announcements from Supabase
        const { data, error } = await window.supabaseClient
          .from('announcements')
          .select('*')
          .order('created_at', { ascending: false });

        if (error) throw error;

        // 3) Update cache and render fresh list
        localStorage.setItem('upsi_cached_announcements', JSON.stringify(data || []));
        renderAnnouncements(data || []);

      } catch (err) {
        console.error('Error fetching announcements:', err);
        errorMessage.textContent = 'Failed to fetch announcements. Please click refresh.';
        errorContainer.classList.remove('hidden');
        loader.classList.add('hidden');
        inboxContent.classList.remove('hidden');
      }
    }

    onAuthResolve((user, profile) => {
      if (!user) return;
      fetchAnnouncements();
    });
  </script>
</body>
</html>
