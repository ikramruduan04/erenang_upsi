<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Book Slot - e-Renang UPSI</title>
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
  <style>
    /* Scrollbar hidden for date strip */
    .scrollbar-hide::-webkit-scrollbar { display: none; }
    .scrollbar-hide { -ms-overflow-style: none; scrollbar-width: none; }

    /* Keyframes */
    @keyframes slideUp {
      from { transform: translateY(100%); }
      to   { transform: translateY(0); }
    }
    @keyframes slideDown {
      from { transform: translate(-50%, -20px); opacity: 0; }
      to   { transform: translate(-50%, 0);     opacity: 1; }
    }
    @keyframes fadeIn {
      from { opacity: 0; }
      to   { opacity: 1; }
    }
    @keyframes scaleIn {
      from { transform: scale(0.9); opacity: 0; }
      to   { transform: scale(1);   opacity: 1; }
    }
    .animate-slideUp { animation: slideUp 0.3s ease-out forwards; }
    .animate-slideDown { animation: slideDown 0.3s ease-out forwards; }
    .animate-fadeIn { animation: fadeIn 0.2s ease-out forwards; }
    .animate-scaleIn { animation: scaleIn 0.3s ease-out forwards; }
  </style>
</head>
<body class="bg-[#F4F6F9] min-h-screen flex flex-col font-outfit text-[#1E293B]">

  <!-- Global Navbar -->
  <?php include 'components/navbar.php'; ?>

  <!-- Toast notification -->
  <div id="toast" class="hidden fixed top-6 left-1/2 -translate-x-1/2 z-[100] animate-slideDown">
    <div class="flex items-center gap-3 bg-[#10B981] text-white px-5 py-3 rounded-xl shadow-lg">
      <i data-lucide="check-circle-2" class="h-5 w-5"></i>
      <span id="toast-text" class="font-semibold text-sm"></span>
    </div>
  </div>

  <!-- Main Content -->
  <main class="flex-grow flex flex-col">
    
    <!-- Date Selector Strip -->
    <div class="bg-white shrink-0">
      <div id="date-strip" class="flex gap-2.5 overflow-x-auto px-4 py-3 scrollbar-hide">
        <!-- Date chips generated via JS -->
      </div>
      <div class="h-px bg-[#E2E8F0]"></div>
    </div>

    <!-- Scrollable Booking Form -->
    <div class="flex-1 overflow-y-auto pb-24">
      <div class="p-5 space-y-5 max-w-5xl mx-auto">
        
        <!-- Pool Banner -->
        <div class="h-40 w-full rounded-2xl flex items-center justify-center overflow-hidden relative"
             style="background: linear-gradient(to right, rgba(0, 47, 108, 0.85) 0%, rgba(0, 84, 180, 0.45) 100%), url('assets/upsi_pool.jpg') center/cover no-repeat">
          <i data-lucide="waves" class="text-white/10 absolute right-4 bottom-0 w-28 h-28 pointer-events-none"></i>
          <div class="text-center z-10">
            <h2 class="text-white text-xl font-bold">Kolam Renang UPSI</h2>
            <p class="text-white/70 text-sm mt-1">Pusat Akuatik Universiti</p>
          </div>
        </div>

        <!-- Section 1: Pools Info -->
        <h3 class="text-base font-bold text-[#1E293B]">1. Swimming Pools Information</h3>
        <div class="grid grid-cols-1 sm:grid-cols-3 gap-3">
          <!-- Pool 1 -->
          <div class="bg-white rounded-2xl border border-[#E2E8F0]/50 shadow-sm overflow-hidden">
            <div class="aspect-video w-full overflow-hidden bg-gray-100">
              <img src="assets/upsi_pool.jpg" alt="Kolam Utama" class="w-full h-full object-cover">
            </div>
            <div class="p-3">
              <p class="text-sm font-bold text-[#1E293B] leading-tight">Kolam Utama</p>
              <p class="text-[11px] font-semibold text-[#C5A880] mt-1">Depth: Standard Olimpik</p>
              <p class="text-[11px] text-[#64748B] leading-snug mt-1.5">
                Standard Olimpik bersaiz 50 meter panjang dan 25 meter lebar dengan 10 lorong.
              </p>
            </div>
          </div>
          <!-- Pool 2 -->
          <div class="bg-white rounded-2xl border border-[#E2E8F0]/50 shadow-sm overflow-hidden">
            <div class="aspect-video w-full overflow-hidden bg-gray-100">
              <img src="assets/upsi_pool_biasa.jpeg" alt="Kolam Biasa" class="w-full h-full object-cover">
            </div>
            <div class="p-3">
              <p class="text-sm font-bold text-[#1E293B] leading-tight">Kolam Renang Biasa</p>
              <p class="text-[11px] font-semibold text-[#C5A880] mt-1">Depth: 1.2 meter kedalaman</p>
              <p class="text-[11px] text-[#64748B] leading-snug mt-1.5">
                Kedalaman bersesuaian untuk latihan renang biasa dan santai.
              </p>
            </div>
          </div>
          <!-- Pool 3 -->
          <div class="bg-white rounded-2xl border border-[#E2E8F0]/50 shadow-sm overflow-hidden">
            <div class="aspect-video w-full overflow-hidden bg-gray-100">
              <img src="assets/upsi_pool_kanak.png" alt="Kolam Kanak-Kanak" class="w-full h-full object-cover">
            </div>
            <div class="p-3">
              <p class="text-sm font-bold text-[#1E293B] leading-tight">Kolam Kanak-Kanak</p>
              <p class="text-[11px] font-semibold text-[#C5A880] mt-1">Depth: 0.5 meter kedalaman</p>
              <p class="text-[11px] text-[#64748B] leading-snug mt-1.5">
                Kawasan cetek dan selamat untuk kanak-kanak bermain air.
              </p>
            </div>
          </div>
        </div>

        <!-- Section 2: Category -->
        <h3 class="text-base font-bold text-[#1E293B]">2. Select Category & Ticket Type</h3>
        <div class="flex">
          <button type="button" disabled class="flex-1 py-3 text-[13px] font-bold border bg-gray-100 text-gray-400 border-gray-200 rounded-l-xl cursor-not-allowed">
            UPSI Staff/Student (Disabled)
          </button>
          <button type="button" class="flex-1 py-3 text-[13px] font-bold border bg-[#002F6C] text-white border-[#002F6C] rounded-r-xl cursor-default">
            Orang Awam (Public)
          </button>
        </div>

        <!-- Dropdown Selector -->
        <div class="relative">
          <label class="block text-xs text-[#64748B] mb-1.5 font-medium">Ticket Option</label>
          <button onclick="toggleDropdown()" id="dropdown-btn" class="w-full flex items-center justify-between bg-white border border-[#E2E8F0] rounded-xl px-4 py-3 text-left hover:border-[#002F6C]/40 transition-colors">
            <span id="selected-ticket-label" class="text-[13px] text-[#1E293B] truncate pr-2">Select ticket...</span>
            <i data-lucide="chevron-down" id="dropdown-arrow" class="text-[#64748B] w-5 h-5 transition-transform shrink-0"></i>
          </button>
          
          <div id="dropdown-list" class="hidden absolute top-full left-0 right-0 mt-1 bg-white border border-[#E2E8F0] rounded-xl shadow-lg z-30 max-h-64 overflow-y-auto">
            <!-- Items loaded dynamically -->
          </div>
        </div>

        <!-- Note banner -->
        <div class="w-full p-3.5 bg-[#F1EAE0]/30 border border-[#C5A880]/50 rounded-xl flex gap-3">
          <i data-lucide="info" class="text-[#002F6C] w-5 h-5 shrink-0 mt-0.5"></i>
          <div>
            <p class="text-xs font-bold text-[#002F6C]">Catatan Penting:</p>
            <p class="text-xs text-[#1E293B] mt-0.5" id="ticket-note">Sila bawa dokumen sokongan yang berkaitan.</p>
          </div>
        </div>

        <!-- Section 3: Time Slot -->
        <h3 class="text-base font-bold text-[#1E293B]">3. Select Session Time</h3>
        <div id="closed-alert" class="hidden w-full p-4 bg-[#EF4444]/10 border border-[#EF4444]/30 rounded-xl flex items-start gap-3">
          <i data-lucide="info" class="text-[#EF4444] w-5 h-5 shrink-0 mt-0.5"></i>
          <p class="text-[13px] text-[#EF4444] font-bold">
            Maaf, kolam ditutup pada hari Isnin sempena penyelenggaraan dan pembersihan.
          </p>
        </div>

        <div id="slots-container" class="flex flex-wrap gap-2.5">
          <!-- Session slots loaded dynamically -->
        </div>

        <!-- Section 4: Stepper -->
        <div class="flex items-center justify-between">
          <h3 class="text-base font-bold text-[#1E293B]">4. Ticket Quantity</h3>
          <div class="flex items-center gap-1">
            <button onclick="changeQuantity(-1)" id="btn-minus" class="p-1 text-[#002F6C] hover:opacity-70 disabled:opacity-30">
              <i data-lucide="minus-circle" class="w-7 h-7"></i>
            </button>
            <span id="qty-text" class="text-lg font-bold text-[#1E293B] w-8 text-center select-none">1</span>
            <button onclick="changeQuantity(1)" id="btn-plus" class="p-1 text-[#002F6C] hover:opacity-70 disabled:opacity-30">
              <i data-lucide="plus-circle" class="w-7 h-7"></i>
            </button>
          </div>
        </div>

      </div>
    </div>

    <!-- Sticky Cart Summary Bar -->
    <div id="cart-summary-bar" class="hidden mx-4 mb-2 shrink-0 animate-fadeIn">
      <div class="bg-[#C5A880] rounded-2xl px-4 py-3 flex items-center justify-between shadow-lg">
        <div class="flex items-center gap-3">
          <div id="cart-count-badge" class="bg-[#002F6C] text-white w-9 h-9 rounded-full flex items-center justify-center font-bold text-sm">
            0
          </div>
          <div>
            <p class="text-[13px] font-bold text-[#002F6C]">Peti Tiket Anda (Cart)</p>
            <p class="text-xs font-semibold text-[#002F6C]/80" id="cart-total-badge">RM 0.00</p>
          </div>
        </div>
        <button onclick="openCheckout()" class="bg-[#002F6C] text-white px-4 py-2.5 rounded-xl flex items-center gap-1.5 text-xs font-bold hover:bg-[#002F6C]/90 transition">
          Checkout
          <i data-lucide="arrow-right" class="w-3.5 h-3.5"></i>
        </button>
      </div>
    </div>

    <!-- Bottom Action Bar -->
    <div class="bg-white border-t border-[#E2E8F0] px-5 py-4 flex items-center justify-between shrink-0 shadow-[0_-4px_10px_rgba(0,0,0,0.05)]">
      <div>
        <p class="text-xs text-[#64748B]">Selected Price</p>
        <p class="text-xl font-bold text-[#002F6C]" id="display-selected-subtotal">RM 0.00</p>
      </div>
      <button onclick="addToCart()" id="btn-add-to-cart" class="flex items-center gap-2 px-8 py-3.5 rounded-2xl font-bold text-white bg-[#002F6C] hover:bg-[#002F6C]/90 active:scale-95 transition">
        <i data-lucide="plus-circle" class="w-4.5 h-4.5"></i>
        <span>Add to Cart</span>
      </button>
    </div>

    <!-- Checkout Modal Drawer -->
    <div id="checkout-modal" class="hidden fixed inset-0 z-50 flex items-end justify-center">
      <div class="absolute inset-0 bg-black/40 animate-fadeIn" onclick="closeCheckout()"></div>
      <div class="relative bg-white w-full max-w-lg rounded-t-[28px] p-6 pb-8 animate-slideUp max-h-[90vh] flex flex-col">
        <div class="flex justify-center mb-4">
          <div class="w-10 h-1.5 bg-[#E2E8F0] rounded-full"></div>
        </div>

        <h3 class="text-xl font-bold text-[#1E293B] mb-1">Checkout Cart</h3>
        <div class="h-px bg-[#E2E8F0] my-3"></div>

        <!-- Scrollable Cart List -->
        <div id="cart-items-list" class="flex-1 overflow-y-auto max-h-[35vh] space-y-2.5 pr-1"></div>

        <div class="h-px bg-[#E2E8F0] my-4"></div>

        <!-- User Information Card -->
        <div class="bg-[#F4F6F9] rounded-xl p-3 flex items-center gap-3">
          <i data-lucide="user" class="text-[#002F6C] w-6 h-6 shrink-0"></i>
          <div class="min-w-0">
            <p class="text-[13px] font-bold text-[#1E293B] truncate" id="info-username">User (Student)</p>
            <p class="text-[11px] text-[#64748B]" id="info-userid">ID: ...</p>
          </div>
        </div>

        <div class="h-px bg-[#E2E8F0] my-4"></div>

        <!-- Price breakdown -->
        <div class="space-y-2">
          <div class="flex justify-between text-sm">
            <span class="text-[#64748B]">Subtotal</span>
            <span class="text-[#1E293B]" id="checkout-subtotal">RM 0.00</span>
          </div>
          <div class="flex justify-between">
            <span class="text-base font-bold text-[#1E293B]">Total Amount</span>
            <span class="text-lg font-bold text-[#002F6C]" id="checkout-total">RM 0.00</span>
          </div>
        </div>

        <!-- Confirm button -->
        <button onclick="confirmCheckout()" id="btn-pay" class="mt-6 w-full bg-[#002F6C] text-white py-3.5 rounded-2xl font-bold flex items-center justify-center gap-2 hover:bg-[#002F6C]/90 transition-all">
          <i data-lucide="check-circle-2" class="w-5 h-5"></i>
          <span id="btn-pay-text">Confirm & Pay</span>
        </button>
      </div>
    </div>

    <!-- Success Modal -->
    <div id="success-modal" class="hidden fixed inset-0 z-50 flex items-center justify-center">
      <div class="absolute inset-0 bg-black/40 animate-fadeIn"></div>
      <div class="relative bg-white rounded-2xl p-8 max-w-sm w-[90%] text-center animate-scaleIn shadow-xl">
        <i data-lucide="check-circle-2" class="text-[#10B981] mx-auto w-16 h-16"></i>
        <h3 class="text-xl font-bold text-[#1E293B] mt-4">Bookings Confirmed!</h3>
        <p class="text-[13px] text-[#64748B] mt-2 leading-relaxed">
          Your swimming passes have been generated successfully. Show the QR tickets at the pool entrance.
        </p>
        <button onclick="viewTickets()" class="mt-5 bg-[#002F6C] text-white px-8 py-3 rounded-2xl font-bold hover:bg-[#002F6C]/90 transition">
          View My Tickets
        </button>
      </div>
    </div>

    <!-- Error Modal -->
    <div id="error-modal" class="hidden fixed inset-0 z-50 flex items-center justify-center">
      <div class="absolute inset-0 bg-black/40 animate-fadeIn" onclick="closeError()"></div>
      <div class="relative bg-white rounded-2xl p-6 max-w-sm w-[90%] animate-scaleIn shadow-xl">
        <div class="flex items-center gap-2 mb-3">
          <i data-lucide="alert-circle" class="text-[#EF4444] w-6 h-6"></i>
          <h3 class="text-base font-bold text-[#1E293B]">Booking Failed</h3>
        </div>
        <p class="text-[13px] text-[#64748B] whitespace-pre-line leading-relaxed" id="error-modal-msg"></p>
        <div class="flex justify-end mt-5">
          <button onclick="closeError()" class="text-[#002F6C] font-bold text-sm hover:underline px-4 py-2">
            OK
          </button>
        </div>
      </div>
    </div>

  </main>


  <script>
    // Ticket Data
    const CATEGORIES = [
      { name: 'Kanak-kanak (0-4 tahun)', price: 0.0, note: 'Sila bawa MyKid' },
      { name: 'Kanak-kanak (5-7 tahun)', price: 1.0, note: 'Sila bawa MyKid' },
      { name: 'Pelajar Sekolah & IPT (8-18 tahun)', price: 5.0, note: 'Sila bawa kad pelajar/Kad Pengenalan' },
      { name: 'Dewasa', price: 10.0, note: 'Sila bawa kad pengenalan' },
      { name: 'Warga Emas (60 tahun ke atas)', price: 5.0, note: 'Sila bawa kad pengenalan' },
      { name: 'Pesara / Pencen Kerajaan', price: 5.0, note: 'Sila bawa kad pencen' },
      { name: 'OKU - Kanak-kanak (0-7 tahun)', price: 0.0, note: 'Sila bawa kad OKU' },
      { name: 'OKU - Kanak-kanak (8-17 tahun)', price: 3.0, note: 'Sila bawa kad OKU' },
      { name: 'OKU - Dewasa', price: 5.0, note: 'Sila bawa kad OKU' },
    ];

    const WEEKDAYS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    // State Variables
    let selectedDate = new Date();
    let selectedTicket = CATEGORIES[3]; // Default Dewasa
    let selectedSlot = '';
    let quantity = 1;
    let cart = [];
    let next7Days = [];

    // Initialize next 7 days list
    function generateDays() {
      const today = new Date();
      next7Days = [];
      for (let i = 0; i < 7; i++) {
        const d = new Date(today);
        d.setDate(today.getDate() + i);
        next7Days.push(d);
      }
    }

    // Load horizontal date list
    function renderDays() {
      const dateStrip = document.getElementById('date-strip');
      dateStrip.innerHTML = '';
      
      next7Days.forEach(date => {
        const isSelected = isSameDay(date, selectedDate);
        const dayNum = date.getDate();
        const dayName = WEEKDAYS[date.getDay()];
        
        const chip = document.createElement('button');
        chip.type = 'button';
        chip.className = `flex flex-col items-center justify-center min-w-[55px] w-[55px] h-[60px] rounded-xl border transition-all shrink-0 ${
          isSelected 
            ? 'bg-[#002F6C] border-[#002F6C] text-white' 
            : 'bg-white border-[#E2E8F0] hover:border-[#002F6C]/40'
        }`;
        
        chip.innerHTML = `
          <span class="text-[11px] font-bold leading-tight ${isSelected ? 'text-[#C5A880]' : 'text-[#64748B]'}">${dayName}</span>
          <span class="text-base font-bold leading-tight ${isSelected ? 'text-white' : 'text-[#1E293B]'}">${dayNum}</span>
        `;
        
        chip.addEventListener('click', () => selectDate(date));
        dateStrip.appendChild(chip);
      });
    }

    function isSameDay(a, b) {
      return a.getFullYear() === b.getFullYear() &&
             a.getMonth() === b.getMonth() &&
             a.getDate() === b.getDate();
    }

    // Select Date
    function selectDate(date) {
      selectedDate = date;
      renderDays();
      updateSlotsForDate();
    }

    // Session slots resolver
    function getSlotsForDay(date) {
      const day = date.getDay(); // 0 = Sun, 1 = Mon ...
      if (day === 1) return []; // Mon Closed
      if (day === 2 || day === 4) return ['Sesi Petang (2.30 ptg - 6.30 ptg)'];
      if (day === 3) return ['Sesi Petang - Ladies Day (2.30 ptg - 6.30 ptg)'];
      if (day === 5) return ['Sesi Petang (3.00 ptg - 6.30 ptg)'];
      return ['Sesi Pagi (8.30 pg - 12.30 tghari)', 'Sesi Petang (2.30 ptg - 6.30 ptg)'];
    }

    function updateSlotsForDate() {
      const slots = getSlotsForDay(selectedDate);
      const closedAlert = document.getElementById('closed-alert');
      const slotsContainer = document.getElementById('slots-container');
      const btnAdd = document.getElementById('btn-add-to-cart');

      slotsContainer.innerHTML = '';
      
      if (slots.length === 0) {
        closedAlert.classList.remove('hidden');
        btnAdd.disabled = true;
        btnAdd.className = "flex items-center gap-2 px-8 py-3.5 rounded-2xl font-bold text-white bg-gray-400 cursor-not-allowed";
        btnAdd.innerHTML = `<i data-lucide="lock" class="w-4.5 h-4.5"></i><span>Kolam Ditutup</span>`;
        selectedSlot = '';
      } else {
        closedAlert.classList.add('hidden');
        btnAdd.disabled = false;
        btnAdd.className = "flex items-center gap-2 px-8 py-3.5 rounded-2xl font-bold text-white bg-[#002F6C] hover:bg-[#002F6C]/90 active:scale-95 transition cursor-pointer";
        btnAdd.innerHTML = `<i data-lucide="plus-circle" class="w-4.5 h-4.5"></i><span>Add to Cart</span>`;
        
        selectedSlot = slots[0];

        slots.forEach(slot => {
          const isSelected = slot === selectedSlot;
          const chip = document.createElement('button');
          chip.type = 'button';
          chip.className = `px-4 py-3 rounded-[10px] border text-xs font-bold transition-all cursor-pointer ${
            isSelected 
              ? 'bg-[#002F6C] border-[#002F6C] text-white' 
              : 'bg-white border-[#E2E8F0] text-[#1E293B] hover:border-[#002F6C]/40'
          }`;
          chip.textContent = slot;
          chip.addEventListener('click', () => {
            selectedSlot = slot;
            updateSlotSelectionUI();
          });
          slotsContainer.appendChild(chip);
        });
      }
      
      updateSelectionSummary();
      if (window.updateIcons) window.updateIcons();
    }

    function updateSlotSelectionUI() {
      const buttons = document.querySelectorAll('#slots-container button');
      buttons.forEach(btn => {
        if (btn.textContent === selectedSlot) {
          btn.className = "px-4 py-3 rounded-[10px] border text-xs font-bold transition-all cursor-pointer bg-[#002F6C] border-[#002F6C] text-white";
        } else {
          btn.className = "px-4 py-3 rounded-[10px] border text-xs font-bold transition-all cursor-pointer bg-white border-[#E2E8F0] text-[#1E293B] hover:border-[#002F6C]/40";
        }
      });
      updateSelectionSummary();
    }

    // Dropdown Logic
    function toggleDropdown() {
      const list = document.getElementById('dropdown-list');
      const arrow = document.getElementById('dropdown-arrow');
      list.classList.toggle('hidden');
      if (list.classList.contains('hidden')) {
        arrow.style.transform = 'rotate(0deg)';
      } else {
        arrow.style.transform = 'rotate(180deg)';
      }
    }

    function renderDropdown() {
      const list = document.getElementById('dropdown-list');
      list.innerHTML = '';
      
      CATEGORIES.forEach(item => {
        const isSelected = item.name === selectedTicket.name;
        const btn = document.createElement('button');
        btn.type = 'button';
        btn.className = `w-full text-left px-4 py-3 text-[13px] border-b border-[#E2E8F0] last:border-b-0 transition-colors cursor-pointer ${
          isSelected 
            ? 'bg-[#002F6C]/5 text-[#002F6C] font-bold' 
            : 'text-[#1E293B] hover:bg-[#F4F6F9]'
        }`;
        
        btn.innerHTML = `${item.name} <span class="text-[#C5A880] font-semibold">(${item.price === 0 ? 'Percuma' : 'RM ' + item.price.toFixed(2)})</span>`;
        btn.addEventListener('click', () => selectTicketOption(item));
        list.appendChild(btn);
      });
    }

    function selectTicketOption(item) {
      selectedTicket = item;
      document.getElementById('selected-ticket-label').textContent = `${item.name} (${item.price === 0 ? 'Percuma' : 'RM ' + item.price.toFixed(2)})`;
      document.getElementById('ticket-note').textContent = item.note + " semasa melapor diri di kolam renang.";
      toggleDropdown();
      renderDropdown();
      updateSelectionSummary();
    }

    // Stepper Quantity Logic
    function changeQuantity(val) {
      quantity = Math.max(1, Math.min(2, quantity + val)); // Limit ticket qty to 2 max
      document.getElementById('qty-text').textContent = quantity;
      
      document.getElementById('btn-minus').disabled = (quantity <= 1);
      document.getElementById('btn-plus').disabled = (quantity >= 2);
      
      updateSelectionSummary();
    }

    // Update prices
    function updateSelectionSummary() {
      const total = selectedTicket.price * quantity;
      document.getElementById('display-selected-subtotal').textContent = "RM " + total.toFixed(2);
    }

    // Cart Handlers
    function addToCart() {
      if (!selectedSlot) return;
      
      const item = {
        id: Date.now() + Math.random(),
        poolType: 'Kolam Utama',
        bookingDate: new Date(selectedDate),
        timeSlot: selectedSlot,
        userType: 'Orang Awam',
        subCategory: selectedTicket.name,
        pricePerTicket: selectedTicket.price,
        quantity: quantity,
        notes: selectedTicket.note
      };

      cart.push(item);
      showToast(`Added ${quantity} × ${selectedTicket.name} to cart!`);
      updateCartSummaryUI();
    }

    function showToast(msg) {
      const toastEl = document.getElementById('toast');
      const toastText = document.getElementById('toast-text');
      toastText.textContent = msg;
      toastEl.classList.remove('hidden');
      setTimeout(() => {
        toastEl.classList.add('hidden');
      }, 2500);
    }

    function updateCartSummaryUI() {
      const summaryBar = document.getElementById('cart-summary-bar');
      const badge = document.getElementById('cart-count-badge');
      const totalText = document.getElementById('cart-total-badge');

      if (cart.length === 0) {
        summaryBar.classList.add('hidden');
      } else {
        summaryBar.classList.remove('hidden');
        badge.textContent = cart.length;
        
        const total = cart.reduce((sum, item) => sum + (item.pricePerTicket * item.quantity), 0);
        totalText.textContent = "RM " + total.toFixed(2);
      }
    }

    // Checkout Modal Handlers
    function openCheckout() {
      const cartList = document.getElementById('cart-items-list');
      cartList.innerHTML = '';
      
      cart.forEach((item, index) => {
        const itemEl = document.createElement('div');
        itemEl.className = "bg-[#F4F6F9] border border-[#E2E8F0] rounded-xl p-3 flex items-start gap-3";
        
        const formattedDate = item.bookingDate.getDate() + "/" + (item.bookingDate.getMonth()+1) + "/" + item.bookingDate.getFullYear();
        const totalItemPrice = item.pricePerTicket * item.quantity;
        
        itemEl.innerHTML = `
          <div class="bg-[#002F6C]/10 p-2 rounded-lg shrink-0">
            <i data-lucide="ticket" class="text-[#002F6C] w-5 h-5"></i>
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-[13px] font-bold text-[#1E293B] truncate">${item.subCategory}</p>
            <p class="text-[11px] text-[#64748B] truncate">${item.poolType} • ${item.timeSlot}</p>
            <p class="text-[11px] font-bold text-[#C5A880]">${formattedDate}</p>
          </div>
          <div class="text-right shrink-0">
            <p class="text-[13px] font-bold text-[#002F6C]">RM ${totalItemPrice.toFixed(2)}</p>
            <p class="text-[10px] text-[#64748B]">${item.quantity} × RM ${item.pricePerTicket.toFixed(2)}</p>
          </div>
          <button onclick="removeCartItem(${index})" class="text-red-400 hover:text-red-600 p-1 shrink-0">
            <i data-lucide="trash-2" class="w-4.5 h-4.5"></i>
          </button>
        `;
        cartList.appendChild(itemEl);
      });

      const cartSubtotal = cart.reduce((sum, item) => sum + (item.pricePerTicket * item.quantity), 0);
      document.getElementById('checkout-subtotal').textContent = "RM " + cartSubtotal.toFixed(2);
      document.getElementById('checkout-total').textContent = "RM " + cartSubtotal.toFixed(2);

      document.getElementById('checkout-modal').classList.remove('hidden');
      if (window.updateIcons) window.updateIcons();
    }

    function removeCartItem(index) {
      cart.splice(index, 1);
      updateCartSummaryUI();
      if (cart.length === 0) {
        closeCheckout();
      } else {
        openCheckout();
      }
    }

    function closeCheckout() {
      document.getElementById('checkout-modal').classList.add('hidden');
    }

    // Checkout Confirmation
    async function confirmCheckout() {
      if (cart.length === 0) return;
      
      const payBtn = document.getElementById('btn-pay');
      const payBtnText = document.getElementById('btn-pay-text');
      
      payBtn.disabled = true;
      payBtnText.innerHTML = `<div class="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin"></div>`;

      try {
        const timestamp = Date.now().toString();
        const userId = currentUser.id;
        
        for (let i = 0; i < cart.length; i++) {
          const item = cart[i];
          const uniqueSuffix = timestamp.slice(-6);
          const poolPrefix = item.poolType.substring(0, 3).replace(/\s/g, '').toUpperCase();
          const qrCode = `UP-B-${uniqueSuffix}-${i}-${poolPrefix}`;

          // Format Date YYYY-MM-DD
          const y = item.bookingDate.getFullYear();
          const m = String(item.bookingDate.getMonth() + 1).padStart(2, '0');
          const d = String(item.bookingDate.getDate()).padStart(2, '0');
          const formattedISO = `${y}-${m}-${d}`;

          const bookingRow = {
            user_id: userId,
            name: currentProfile.name || 'Guest',
            email: currentProfile.email || '',
            phone: currentProfile.phone || '',
            upsi_id: currentProfile.upsi_id || '',
            user_type: item.userType,
            sub_category: item.subCategory,
            pool_type: item.poolType,
            booking_date: formattedISO,
            time_slot: item.timeSlot,
            quantity: item.quantity,
            total_price: item.pricePerTicket * item.quantity,
            status: 'Pending',
            qr_code: qrCode,
            notes: item.notes,
          };

          const { error } = await window.supabaseClient.from('bookings').insert(bookingRow);
          if (error) throw error;
        }

        // Clean cart & close drawer
        cart = [];
        updateCartSummaryUI();
        closeCheckout();
        
        // Show success modal
        document.getElementById('success-modal').classList.remove('hidden');
        if (window.updateIcons) window.updateIcons();

      } catch (err) {
        console.error('Checkout error:', err);
        closeCheckout();
        document.getElementById('error-modal-msg').textContent = `Could not complete booking. Please check your internet connection.\n\nError: ${err.message || err}`;
        document.getElementById('error-modal').classList.remove('hidden');
        if (window.updateIcons) window.updateIcons();
      } finally {
        payBtn.disabled = false;
        payBtnText.textContent = "Confirm & Pay";
      }
    }

    function viewTickets() {
      window.location.href = 'tickets.php';
    }

    function closeError() {
      document.getElementById('error-modal').classList.add('hidden');
    }

    // Page Load & Auth triggers
    onAuthResolve((user, profile) => {
      if (!user) return; // redirect to login handled in auth.js
      
      document.getElementById('info-username').textContent = `${profile.name || 'Swimmer'} (${profile.user_type || 'User'})`;
      document.getElementById('info-userid').textContent = profile.upsi_id ? "ID: " + profile.upsi_id : "ID: Public User";
      
      generateDays();
      renderDays();
      selectTicketOption(CATEGORIES[3]); // Default Dewasa
      changeQuantity(0); // init stepper
      updateSlotsForDate();
    });
  </script>
</body>
</html>
