<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Home - e-Renang UPSI</title>
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
    <!-- Loader Container (shown while auth / data is fetching) -->
    <div id="page-loader" class="flex items-center justify-center min-h-[60vh]">
      <div class="w-10 h-10 border-4 border-[#002F6C] border-t-transparent rounded-full animate-spin"></div>
    </div>

    <!-- Home Page Content (initially hidden) -->
    <div id="home-content" class="hidden mx-auto w-full max-w-4xl px-5 py-6">
      
      <!-- 1. GREETING SECTION -->
      <div class="flex items-start justify-between mb-5">
        <div>
          <h1 class="text-2xl font-bold text-[#1E293B]">
            Hello, <span id="display-name">User</span> 👋
          </h1>
          <p class="text-sm mt-0.5 text-[#64748B]">
            Ready for a refreshing swim?
          </p>
        </div>
        <div class="flex items-center gap-1 px-3 py-1.5 rounded-full border bg-[#F1EAE0] border-goldlight/50 border-[#C5A880]/30">
          <i data-lucide="award" class="h-4 w-4 text-[#002F6C]"></i>
          <span id="display-usertype" class="text-xs font-bold text-[#002F6C]">Student</span>
        </div>
      </div>

      <!-- 2. MEMBERSHIP TIER CARD (Navy gradient) -->
      <div class="rounded-3xl p-5 mb-6 bg-gradient-to-br from-[#002F6C] to-[#001F47] shadow-lg shadow-[#002F6C]/15">
        <!-- Tier header row -->
        <div class="flex items-center justify-between mb-5">
          <div class="flex items-center gap-2">
            <i data-lucide="club" id="tier-icon" class="h-7 w-7 text-[#CD7F32]"></i>
            <span id="display-tier" class="text-lg font-bold text-white">Bronze Swimmer</span>
          </div>
          <span id="display-progress-ratio" class="text-sm font-semibold text-[#C5A880]">0 / 10 swims</span>
        </div>

        <!-- Progress bar -->
        <div class="w-full h-2 rounded-full overflow-hidden bg-white/10">
          <div id="tier-progress-bar" class="h-full rounded-full transition-all duration-500 bg-[#C5A880]" style="width: 0%;"></div>
        </div>

        <!-- Encouragement text -->
        <p id="display-encouragement" class="text-xs mt-3 text-white/70">
          Book 10 more sessions to unlock premium benefits!
        </p>

        <!-- CTA button -->
        <a href="book-slot.php" class="w-full mt-5 flex items-center justify-center gap-2 py-2.5 rounded-xl font-bold bg-[#C5A880] text-[#002F6C] hover:opacity-90 transition">
          <i data-lucide="calendar-plus" class="h-4.5 w-4.5"></i>
          Book Swim Session Now
        </a>
      </div>

      <!-- 3. POOL BANNER -->
      <div class="relative h-[180px] w-full rounded-2xl overflow-hidden mb-6"
           style="background: linear-gradient(to top, rgba(0, 47, 108, 0.9) 0%, rgba(0, 47, 108, 0.4) 100%), url('assets/upsi_pool.jpg') center/cover no-repeat">
        <div class="absolute bottom-0 left-0 right-0 p-5 flex flex-col justify-end">
          <span class="self-start text-[10px] font-bold px-2 py-1 rounded-md mb-1.5 bg-[#C5A880] text-[#002F6C]">
            KOLAM RENANG UPSI
          </span>
          <h2 class="text-xl font-bold text-white">
            Beat the Heat for only RM 2.00
          </h2>
          <p class="text-[13px] text-white/90">
            Affordable swimming lanes available daily. Jom Mandi!
          </p>
        </div>
      </div>

      <!-- 5. SWIMMING GUIDELINES -->
      <h2 class="text-lg font-bold mb-3 text-[#1E293B]">Swimming Guidelines</h2>
      
      <!-- Guideline: Swimwear -->
      <div class="flex items-start gap-4 p-4 rounded-2xl border bg-white border-[#E2E8F0] mb-3">
        <div class="shrink-0 p-2 rounded-lg bg-[#F1EAE0]">
          <i data-lucide="shield-alert" class="h-5 w-5 text-[#002F6C]"></i>
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-bold text-[#1E293B]">Proper Swimwear Required</p>
          <p class="text-xs mt-1 text-[#64748B] leading-relaxed">
            Strictly nylon or spandex swimsuits only. Cotton apparel is prohibited.
          </p>
        </div>
      </div>

      <!-- Guideline: Hours -->
      <div class="flex items-start gap-4 p-4 rounded-2xl border bg-white border-[#E2E8F0] mb-3">
        <div class="shrink-0 p-2 rounded-lg bg-[#F1EAE0]">
          <i data-lucide="clock" class="h-5 w-5 text-[#002F6C]"></i>
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-bold text-[#1E293B]">Operating Hours</p>
          <p class="text-xs mt-1 text-[#64748B] whitespace-pre-line leading-relaxed">
            • Isnin: Tutup sempena penyelenggaraan & pembersihan
            • Selasa - Khamis: Sesi Petang (2.30 ptg - 6.30 ptg)
            • Rabu (Ladies Day): Sesi Petang (2.30 ptg - 6.30 ptg)
            • Jumaat: Sesi Petang (3.00 ptg - 6.30 ptg)
            • Sabtu & Ahad: Sesi Pagi (8.30 pg - 12.30 tghari) & Sesi Petang (2.30 ptg - 6.30 ptg)
          </p>
        </div>
      </div>

      <!-- Guideline: Health -->
      <div class="flex items-start gap-4 p-4 rounded-2xl border bg-white border-[#E2E8F0] mb-3">
        <div class="shrink-0 p-2 rounded-lg bg-[#F1EAE0]">
          <i data-lucide="heart-pulse" class="h-5 w-5 text-[#002F6C]"></i>
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-bold text-[#1E293B]">Health & Safety</p>
          <p class="text-xs mt-1 text-[#64748B] leading-relaxed">
            Shower before entering. Do not swim if feeling unwell or under medication.
          </p>
        </div>
      </div>

      <!-- 6. POOL LOCATION & FACILITIES -->
      <h2 class="text-lg font-bold mb-3 mt-6 text-[#1E293B]">Pool Location & Facilities</h2>
      <div class="rounded-2xl p-4 border bg-white border-[#E2E8F0]">
        
        <!-- Location Detail -->
        <div class="flex items-start gap-3">
          <div class="shrink-0 p-2 rounded-[10px] bg-[#002F6C]/10">
            <i data-lucide="map-pin" class="h-5 w-5 text-[#002F6C]"></i>
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-bold text-[#1E293B]">Lokasi Kolam</p>
            <p class="text-xs mt-0.5 leading-relaxed text-[#64748B]">
              Kolam Renang Universiti Pendidikan Sultan Idris (UPSI)<br>
              Jalan Proton City, 35900 Tanjong Malim, Perak.
            </p>
            <p class="text-[11px] mt-1 font-bold break-all text-[#C5A880]" id="maps-url-text"></p>
            
            <div class="flex flex-wrap items-center gap-3 mt-2.5">
              <a href="#" id="btn-open-maps" target="_blank" class="inline-flex items-center gap-2 px-3.5 py-2 rounded-[10px] text-xs font-bold text-white bg-[#002F6C] shadow-md shadow-[#002F6C]/15 hover:opacity-90 transition">
                <i data-lucide="navigation" class="h-3.5 w-3.5 text-[#C5A880]"></i>
                Open Google Maps
              </a>
              <button onclick="copyMapsLink()" class="inline-flex items-center gap-2 px-3.5 py-2 rounded-[10px] text-xs font-bold bg-transparent border border-[#E2E8F0] text-[#64748B] hover:bg-gray-50 transition">
                <i data-lucide="copy" class="h-3.5 w-3.5 text-[#64748B]"></i>
                <span id="copy-btn-text">Copy Link</span>
              </button>
            </div>
          </div>
        </div>

        <hr class="my-5 border-[#E2E8F0]">

        <!-- Facilities -->
        <p class="text-[13px] font-bold mb-3.5 text-[#1E293B]">
          Kemudahan Kolam (Facilities & Amenities):
        </p>

        <div class="flex flex-col gap-3">
          <!-- Changing Room -->
          <div class="flex items-start gap-4">
            <div class="shrink-0 flex items-center justify-center w-10 h-10 rounded-full bg-gradient-to-br from-[#002F6C] to-[#003884] shadow-md shadow-[#002F6C]/15 border border-[#C5A880]/30">
              <i data-lucide="bath" class="h-4.5 w-4.5 text-[#C5A880]"></i>
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-[13px] font-bold text-[#1E293B]">Tandas & Pancuran Air (Toilets & Showers)</p>
              <p class="text-[11px] mt-0.5 leading-snug text-[#64748B]">
                Kemudahan tandas dan pancuran mandi yang lengkap di kedua-dua bilik lelaki dan wanita.
              </p>
            </div>
          </div>

          <!-- Parking Space -->
          <div class="flex items-start gap-4">
            <div class="shrink-0 flex items-center justify-center w-10 h-10 rounded-full bg-gradient-to-br from-[#002F6C] to-[#003884] shadow-md shadow-[#002F6C]/15 border border-[#C5A880]/30">
              <i data-lucide="car" class="h-4.5 w-4.5 text-[#C5A880]"></i>
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-[13px] font-bold text-[#1E293B]">Kawasan Parkir (Parking Space)</p>
              <p class="text-[11px] mt-0.5 leading-snug text-[#64748B]">
                Kawasan meletak kenderaan disediakan secara percuma dan luas berhampiran pintu masuk kolam.
              </p>
            </div>
          </div>

          <!-- Changing Room -->
          <div class="flex items-start gap-4">
            <div class="shrink-0 flex items-center justify-center w-10 h-10 rounded-full bg-gradient-to-br from-[#002F6C] to-[#003884] shadow-md shadow-[#002F6C]/15 border border-[#C5A880]/30">
              <i data-lucide="shirt" class="h-4.5 w-4.5 text-[#C5A880]"></i>
            </div>
            <div class="flex-1 min-w-0">
              <p class="text-[13px] font-bold text-[#1E293B]">Bilik Salin Pakaian (Changing Room)</p>
              <p class="text-[11px] mt-0.5 leading-snug text-[#64748B]">
                Bilik persalinan berasingan yang selesa bagi menjaga privasi pengunjung.
              </p>
            </div>
          </div>
        </div>
      </div>

      <!-- Spacing -->
      <div class="h-6"></div>
    </div>
  </main>


  <script>
    const MAPS_URL = 'https://maps.app.goo.gl/gtFbvunvHxJVHJP6A';

    // Set map link UI values
    document.getElementById('maps-url-text').textContent = "Link: " + MAPS_URL;
    document.getElementById('btn-open-maps').href = MAPS_URL;

    function copyMapsLink() {
      navigator.clipboard.writeText(MAPS_URL).then(() => {
        const btnText = document.getElementById('copy-btn-text');
        btnText.textContent = "Copied!";
        setTimeout(() => {
          btnText.textContent = "Copy Link";
        }, 2000);
      });
    }

    // Helper function to update Home UI elements instantly
    function renderHomeUI(sessionCount, profile, user) {
      // Determine tier details
      const nextTierSessions = 10;
      const progressPercent = Math.min((sessionCount / nextTierSessions) * 100, 100);
      const remainingSwims = Math.max(nextTierSessions - sessionCount, 0);

      let tier = 'Bronze Swimmer';
      let tierColorClass = 'text-[#CD7F32]'; // Bronze color
      if (sessionCount >= 15) {
        tier = 'Gold Swimmer';
        tierColorClass = 'text-[#C5A880]'; // Accent gold
      } else if (sessionCount >= 7) {
        tier = 'Silver Swimmer';
        tierColorClass = 'text-[#C0C0C0]'; // Silver
      }

      // Update DOM elements
      document.getElementById('display-name').textContent = profile?.name || user?.email || 'Swimmer';
      document.getElementById('display-usertype').textContent = profile?.user_type || 'Student';
      document.getElementById('display-tier').textContent = tier;
      
      const tierIcon = document.getElementById('tier-icon');
      tierIcon.className = `h-7 w-7 ${tierColorClass}`;
      
      document.getElementById('display-progress-ratio').textContent = `${sessionCount} / ${nextTierSessions} swims`;
      document.getElementById('tier-progress-bar').style.width = `${progressPercent}%`;
      document.getElementById('display-encouragement').textContent = `Book ${remainingSwims} more sessions to unlock premium benefits!`;

      // Reveal content & hide loader
      document.getElementById('page-loader').classList.add('hidden');
      document.getElementById('home-content').classList.remove('hidden');

      if (window.updateIcons) window.updateIcons();
    }

    // Dynamic resolution based on Supabase session
    onAuthResolve(async (user, profile) => {
      if (!user) return; // auth.js will handle redirect to login

      // 1) Render immediately using cached session count if available
      let cachedCount = 0;
      try {
        const localCount = localStorage.getItem('upsi_cached_session_count');
        if (localCount !== null) {
          cachedCount = parseInt(localCount);
          renderHomeUI(cachedCount, profile, user);
        }
      } catch (e) {
        console.warn("Error loading cached count:", e);
      }

      try {
        // 2) Fetch session completions from Supabase in the background
        const { data: bookings, error } = await window.supabaseClient
          .from('bookings')
          .select('status')
          .eq('user_id', user.id);

        if (error) throw error;

        const sessionCount = (bookings || []).filter(b => b.status === 'Checked In').length;

        // 3) Update cache and re-render UI with fresh data
        localStorage.setItem('upsi_cached_session_count', sessionCount);
        renderHomeUI(sessionCount, profile, user);

      } catch (err) {
        console.error('Error loading home data:', err);
        // If we didn't render anything from cache yet, show error message
        if (document.getElementById('home-content').classList.contains('hidden')) {
          document.getElementById('page-loader').innerHTML = `<p class="text-red-500 text-sm font-bold">Failed to load account data. Please refresh.</p>`;
        }
      }
    });
  </script>
</body>
</html>
