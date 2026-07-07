<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>My Tickets - e-Renang UPSI</title>
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
<body class="bg-[#F4F6F9] min-h-screen flex flex-col font-outfit text-[#1E293B]">

  <!-- Global Navbar -->
  <?php include 'components/navbar.php'; ?>

  <!-- Main Content Layout -->
  <main class="flex-grow flex flex-col">
    
    <!-- Tab Bar -->
    <div class="bg-white flex relative shrink-0">
      <button onclick="switchTab(0)" id="tab-active" class="flex-1 py-3 text-sm font-bold transition-colors cursor-pointer text-[#002F6C]">
        Active Passes
      </button>
      <button onclick="switchTab(1)" id="tab-history" class="flex-1 py-3 text-sm font-bold transition-colors cursor-pointer text-[#94A3B8]">
        Booking History
      </button>
      <!-- Underline Indicator -->
      <span id="tab-indicator" class="absolute bottom-0 h-[3px] bg-[#002F6C] transition-all duration-300" style="width: 50%; left: 0%;"></span>
    </div>
    <div class="h-px bg-[#E2E8F0] shrink-0"></div>

    <!-- Scrollable Content -->
    <div class="flex-grow overflow-y-auto">
      
      <!-- Loader -->
      <div id="page-loader" class="flex items-center justify-center min-h-[50vh]">
        <div class="w-10 h-10 border-4 border-[#002F6C] border-t-transparent rounded-full animate-spin"></div>
      </div>

      <!-- Empty State -->
      <div id="empty-state" class="hidden flex flex-col items-center justify-center min-h-[50vh] gap-4">
        <i data-lucide="ticket" class="w-16 h-16 text-[#94A3B8]"></i>
        <p class="text-lg font-bold text-[#64748B]">No Tickets Found</p>
        <p class="text-[13px] text-[#94A3B8]">Book a swimming slot in the Catalog page.</p>
      </div>

      <!-- Tickets Grid / List -->
      <div id="tickets-content" class="hidden p-4 space-y-4 max-w-4xl mx-auto">
        <div class="flex justify-end">
          <button onclick="loadBookings()" class="flex items-center gap-1.5 text-xs font-bold text-[#002F6C] hover:opacity-70 transition cursor-pointer">
            <i data-lucide="refresh-cw" class="w-3.5 h-3.5"></i>
            Refresh
          </button>
        </div>
        <div id="tickets-list" class="flex flex-col gap-4"></div>
      </div>

    </div>

    <!-- Ticket Detail Modal Dialog -->
    <div id="ticket-modal" class="hidden fixed inset-0 z-50 flex items-center justify-center p-6 bg-black/40">
      <div class="bg-white rounded-[28px] w-full max-w-md max-h-[90vh] overflow-y-auto shadow-2xl animate-[scaleIn_0.3s_ease-out]" onclick="event.stopPropagation()">
        
        <!-- Header -->
        <div class="flex items-center justify-between px-5 py-4 rounded-t-[28px] bg-[#002F6C] text-white">
          <div class="flex items-center gap-2">
            <i data-lucide="droplet" class="text-[#C5A880] w-5 h-5"></i>
            <span class="text-base font-bold">e-Renang Entry Ticket</span>
          </div>
          <button onclick="closeModal()" class="text-white/80 hover:text-white transition">
            <i data-lucide="x" class="w-5 h-5"></i>
          </button>
        </div>

        <!-- Body -->
        <div class="p-6">
          <!-- QR Code Grid -->
          <div class="flex flex-col items-center">
            <div class="p-4 rounded-[20px] border border-[#E2E8F0] bg-[#F4F6F9]" id="qr-container">
              <!-- Mock QR Code injected here -->
            </div>
            <p id="modal-qr-code" class="mt-3 text-sm font-bold tracking-wider text-[#002F6C] tracking-[1.5px]"></p>
          </div>

          <!-- Detail Rows -->
          <div class="mt-5 space-y-2" id="modal-details-container">
            <!-- Row details loaded here -->
          </div>

          <div class="my-6 h-px bg-[#E2E8F0]"></div>

          <!-- Footer warning -->
          <div class="flex items-start gap-2.5">
            <i data-lucide="info" class="text-[#C5A880] w-4.5 h-4.5 shrink-0 mt-0.5"></i>
            <p class="text-[11px] text-[#64748B] leading-relaxed">
              Please present this QR code to the swimming pool staff at the entry turnstile. Proper swimming apparel is required.
            </p>
          </div>
        </div>

      </div>
    </div>

  </main>

  <!-- Supabase Local -->
  <script src="js/supabase.min.js"></script>
  <!-- App Auth & Utilities -->
  <script src="js/auth.js"></script>
  <script src="js/main.js"></script>

  <script>
    const MONTHS = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    
    const STATUS_STYLES = {
      Approved:    { bg: 'rgba(16,185,129,0.15)',  text: '#10B981' },
      Pending:     { bg: 'rgba(245,158,11,0.15)',  text: '#F59E0B' },
      'Checked In': { bg: 'rgba(0,47,108,0.15)',   text: '#002F6C' },
      Cancelled:   { bg: 'rgba(239,68,68,0.15)',   text: '#EF4444' },
    };

    let allBookings = [];
    let activeTab = 0; // 0 = Active, 1 = History

    function switchTab(index) {
      activeTab = index;
      
      const tabActive = document.getElementById('tab-active');
      const tabHistory = document.getElementById('tab-history');
      const indicator = document.getElementById('tab-indicator');

      if (index === 0) {
        tabActive.className = "flex-1 py-3 text-sm font-bold transition-colors cursor-pointer text-[#002F6C]";
        tabHistory.className = "flex-1 py-3 text-sm font-bold transition-colors cursor-pointer text-[#94A3B8]";
        indicator.style.left = "0%";
      } else {
        tabActive.className = "flex-1 py-3 text-sm font-bold transition-colors cursor-pointer text-[#94A3B8]";
        tabHistory.className = "flex-1 py-3 text-sm font-bold transition-colors cursor-pointer text-[#002F6C]";
        indicator.style.left = "50%";
      }

      renderList();
    }

    async function loadBookings() {
      const loader = document.getElementById('page-loader');
      const empty = document.getElementById('empty-state');
      const content = document.getElementById('tickets-content');
      
      loader.classList.remove('hidden');
      empty.classList.add('hidden');
      content.classList.add('hidden');

      try {
        const { data, error } = await window.supabaseClient
          .from('bookings')
          .select('*')
          .eq('user_id', currentUser.id)
          .order('booking_date', { ascending: false });

        if (error) throw error;
        allBookings = data || [];

        renderList();
        loader.classList.add('hidden');
      } catch (err) {
        console.error('Error fetching bookings:', err);
        loader.classList.add('hidden');
        empty.classList.remove('hidden');
      }
    }

    function renderList() {
      const ticketsList = document.getElementById('tickets-list');
      const emptyState = document.getElementById('empty-state');
      const ticketsContent = document.getElementById('tickets-content');
      
      ticketsList.innerHTML = '';

      const activeList = allBookings.filter(b => b.status === 'Approved' || b.status === 'Pending');
      const historyList = allBookings.filter(b => b.status === 'Checked In' || b.status === 'Cancelled');
      
      const listToRender = activeTab === 0 ? activeList : historyList;

      if (listToRender.length === 0) {
        emptyState.classList.remove('hidden');
        ticketsContent.classList.add('hidden');
        return;
      }

      emptyState.classList.add('hidden');
      ticketsContent.classList.remove('hidden');

      listToRender.forEach(booking => {
        const dateObj = new Date(booking.booking_date);
        const day = dateObj.getDate();
        const month = MONTHS[dateObj.getMonth()];
        const style = STATUS_STYLES[booking.status] || STATUS_STYLES.Cancelled;

        const card = document.createElement('button');
        card.className = "bg-white rounded-2xl border border-[#E2E8F0] shadow-sm p-4 flex items-center gap-4 w-full text-left hover:shadow-md transition cursor-pointer";
        card.innerHTML = `
          <!-- Date -->
          <div class="w-[65px] shrink-0 flex flex-col items-center justify-center py-3 rounded-xl bg-[#F1EAE0]">
            <span class="text-[10px] font-bold text-[#002F6C]">${month}</span>
            <span class="text-[22px] font-bold text-[#002F6C] leading-tight">${day}</span>
          </div>

          <!-- Info -->
          <div class="flex-1 min-w-0">
            <p class="text-base font-bold text-[#1E293B] truncate">${booking.pool_type}</p>
            <p class="text-xs text-[#64748B] mt-1">${booking.time_slot}</p>
            <div class="flex items-center gap-2 mt-1.5">
              <span class="text-[10px] font-bold px-2 py-0.5 rounded-md" style="background-color: ${style.bg}; color: ${style.text}">${booking.status}</span>
              <span class="text-[11px] font-bold text-[#64748B]">${booking.quantity} Pax</span>
            </div>
          </div>

          <!-- Divider -->
          <div class="w-[1.5px] h-[50px] bg-[#E2E8F0] mx-2.5 shrink-0"></div>

          <!-- QR code stub -->
          <div class="flex flex-col items-center justify-center shrink-0">
            <i data-lucide="qr-code" class="text-[#002F6C] w-7 h-7"></i>
            <span class="text-[9px] font-bold text-[#002F6C] mt-1">SCAN</span>
          </div>
        `;

        card.addEventListener('click', () => openModal(booking));
        ticketsList.appendChild(card);
      });

      if (window.updateIcons) window.updateIcons();
    }

    // Modal Handling
    function openModal(booking) {
      const qrContainer = document.getElementById('qr-container');
      const qrCodeText = document.getElementById('modal-qr-code');
      const detailsContainer = document.getElementById('modal-details-container');
      
      qrCodeText.textContent = booking.qr_code;
      
      // Inject deterministic Mock QR Code
      qrContainer.innerHTML = generateMockQR();

      // Load details rows
      const dateObj = new Date(booking.booking_date);
      const formattedDate = dateObj.getDate() + "/" + (dateObj.getMonth() + 1) + "/" + dateObj.getFullYear();
      
      detailsContainer.innerHTML = `
        ${createDetailRow("Swimmer Name", booking.name)}
        ${createDetailRow("Category Group", booking.user_type)}
        ${createDetailRow("Ticket Type", booking.sub_category)}
        ${booking.notes ? createDetailRow("Catatan", booking.notes) : ''}
        ${booking.upsi_id ? createDetailRow("UPSI ID", booking.upsi_id) : ''}
        ${createDetailRow("Pool Section", booking.pool_type)}
        ${createDetailRow("Date", formattedDate)}
        ${createDetailRow("Time Session", booking.time_slot)}
        ${createDetailRow("Tickets / Slots", booking.quantity + " Pax")}
        ${createDetailRow("Price Paid", "RM " + Number(booking.total_price).toFixed(2))}
      `;

      document.getElementById('ticket-modal').classList.remove('hidden');
      if (window.updateIcons) window.updateIcons();
    }

    function createDetailRow(label, value) {
      return `
        <div class="flex justify-between items-start">
          <span class="text-xs text-[#64748B]">${label}</span>
          <span class="text-xs font-bold text-[#1E293B] text-right max-w-[55%]">${value}</span>
        </div>
      `;
    }

    function generateMockQR() {
      // Deterministic QR generation grid
      let cellsHTML = '';
      for (let i = 0; i < 49; i++) {
        const isFilled = (i * 7 + 13) % 5 === 0 || i % 3 === 0 || (i > 40 && i % 2 === 0);
        cellsHTML += `<div class="rounded-[1px]" style="background-color: ${isFilled ? '#002F6C' : 'transparent'};"></div>`;
      }

      return `
        <div class="relative bg-white p-2" style="width: 140px; height: 140px;">
          <!-- Corner anchors -->
          <div class="absolute top-0 left-0 flex items-center justify-center border-4 border-[#002F6C] p-1" style="width: 28px; height: 28px;"><div class="w-full h-full bg-[#002F6C]"></div></div>
          <div class="absolute top-0 right-0 flex items-center justify-center border-4 border-[#002F6C] p-1" style="width: 28px; height: 28px;"><div class="w-full h-full bg-[#002F6C]"></div></div>
          <div class="absolute bottom-0 left-0 flex items-center justify-center border-4 border-[#002F6C] p-1" style="width: 28px; height: 28px;"><div class="w-full h-full bg-[#002F6C]"></div></div>
          
          <div class="absolute inset-0 flex items-center justify-center">
            <div class="grid grid-cols-7 gap-[3px] p-1" style="width: 100px; height: 100px;">
              ${cellsHTML}
            </div>
          </div>
        </div>
      `;
    }

    function closeModal() {
      document.getElementById('ticket-modal').classList.add('hidden');
    }

    // Dismiss modal on background click
    document.getElementById('ticket-modal').addEventListener('click', closeModal);

    onAuthResolve((user, profile) => {
      if (!user) return;
      loadBookings();
    });
  </script>
</body>
</html>
