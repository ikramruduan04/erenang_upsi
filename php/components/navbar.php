<?php
$currentPage = basename($_SERVER['SCRIPT_NAME']);
function activeClass($page, $currentPage) {
    return $page === $currentPage 
        ? 'bg-[#C5A880]/15 text-[#C5A880] border-b-2 border-[#C5A880]' 
        : 'text-gray-300 hover:text-white hover:bg-white/5';
}
function activeMobileClass($page, $currentPage) {
    return $page === $currentPage 
        ? 'bg-[#C5A880]/20 text-[#C5A880] border-l-4 border-[#C5A880] font-bold' 
        : 'text-gray-300 hover:text-white hover:bg-white/5';
}
?>
<nav class="bg-[#002F6C] shadow-lg sticky top-0 z-50">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="flex items-center justify-between h-16">
      <!-- Left: Logo and Brand -->
      <div class="flex items-center">
        <a href="index.php" class="flex items-center space-x-2 text-white">
          <i data-lucide="droplet" class="h-8 w-8 text-[#C5A880] fill-[#C5A880]"></i>
          <span class="font-outfit text-xl font-extrabold tracking-wide">
            e-Renang <span class="text-[#C5A880]">UPSI</span>
          </span>
        </a>
      </div>

      <!-- Center: Desktop Navigation links -->
      <div class="hidden md:flex space-x-1 items-center">
        <a href="index.php" class="flex items-center space-x-1 px-3 py-2 rounded-md text-sm font-medium transition-all duration-200 <?php echo activeClass('index.php', $currentPage); ?>">
          <i data-lucide="home" class="h-4 w-4"></i>
          <span>Home</span>
        </a>
        
        <!-- Authenticated Links (Controlled via JS) -->
        <a href="book-slot.php" id="nav-book" class="hidden flex items-center space-x-1 px-3 py-2 rounded-md text-sm font-medium transition-all duration-200 <?php echo activeClass('book-slot.php', $currentPage); ?>">
          <i data-lucide="calendar-plus" class="h-4 w-4"></i>
          <span>Book Slot</span>
        </a>
        <a href="tickets.php" id="nav-tickets" class="hidden flex items-center space-x-1 px-3 py-2 rounded-md text-sm font-medium transition-all duration-200 <?php echo activeClass('tickets.php', $currentPage); ?>">
          <i data-lucide="ticket" class="h-4 w-4"></i>
          <span>Tickets</span>
        </a>
        <a href="inbox.php" id="nav-inbox" class="hidden flex items-center space-x-1 px-3 py-2 rounded-md text-sm font-medium transition-all duration-200 <?php echo activeClass('inbox.php', $currentPage); ?>">
          <i data-lucide="message-square" class="h-4 w-4"></i>
          <span>Inbox</span>
        </a>
        <a href="profile.php" id="nav-profile" class="hidden flex items-center space-x-1 px-3 py-2 rounded-md text-sm font-medium transition-all duration-200 <?php echo activeClass('profile.php', $currentPage); ?>">
          <i data-lucide="user" class="h-4 w-4"></i>
          <span>Profile</span>
        </a>
        <a href="admin.php" id="nav-admin" class="hidden flex items-center space-x-1 px-3 py-2 rounded-md text-sm font-medium transition-all duration-200 <?php echo activeClass('admin.php', $currentPage); ?>">
          <i data-lucide="shield" class="h-4 w-4 text-[#C5A880]"></i>
          <span class="text-[#C5A880]">Admin Dashboard</span>
        </a>
      </div>

      <!-- Right: Notifications, Auth status, Profile icon -->
      <div class="hidden md:flex items-center space-x-4">
        <!-- Logged Out Buttons -->
        <div id="auth-buttons-logged-out" class="flex items-center space-x-2">
          <a href="login.php" class="flex items-center space-x-1 text-white hover:text-[#C5A880] px-3 py-2 rounded-md text-sm font-medium transition">
            <i data-lucide="log-in" class="h-4 w-4"></i>
            <span>Login</span>
          </a>
          <a href="register.php" class="bg-[#C5A880] text-[#002F6C] hover:bg-[#b09268] px-4 py-2 rounded-md text-sm font-bold transition shadow-md">
            Register
          </a>
        </div>

        <!-- Logged In User Section -->
        <div id="auth-user-logged-in" class="hidden flex items-center space-x-4">
          <!-- Notification Bell -->
          <button class="text-gray-300 hover:text-white p-1 rounded-full hover:bg-white/5 relative transition">
            <i data-lucide="bell" class="h-5 w-5 text-[#C5A880]"></i>
            <span class="absolute top-0 right-0 h-2.5 w-2.5 rounded-full bg-red-500 ring-2 ring-[#002F6C]"></span>
          </button>

          <!-- UPSI logo badge -->
          <div class="w-8 h-8 rounded-full bg-[#F1EAE0] flex items-center justify-center border border-[#C5A880] overflow-hidden">
            <span class="text-[#002F6C] font-outfit text-xs font-bold">UPSI</span>
          </div>

          <!-- User greeting and logout -->
          <div class="flex items-center space-x-2">
            <span id="user-greeting-name" class="text-sm font-medium text-white max-w-[100px] truncate">...</span>
            <button onclick="signOutUser()" class="flex items-center space-x-1 bg-red-600/20 hover:bg-red-600 text-red-300 hover:text-white px-3 py-1.5 rounded-md text-xs font-semibold border border-red-500/30 transition-all">
              <i data-lucide="log-out" class="h-3.5 w-3.5"></i>
              <span>Log Out</span>
            </button>
          </div>
        </div>
      </div>

      <!-- Hamburger menu button -->
      <div class="flex md:hidden items-center">
        <button id="mobile-bell" class="hidden text-gray-300 hover:text-white mr-3 p-1 rounded-full hover:bg-white/5 relative transition">
          <i data-lucide="bell" class="h-5 w-5 text-[#C5A880]"></i>
          <span class="absolute top-0 right-0 h-2 w-2 rounded-full bg-red-500"></span>
        </button>
        <button id="mobile-menu-btn" class="text-gray-300 hover:text-white p-2 rounded-md hover:bg-white/5 focus:outline-none">
          <i data-lucide="menu" id="mobile-menu-icon" class="h-6 w-6"></i>
        </button>
      </div>
    </div>
  </div>

  <!-- Mobile Drawer Menu -->
  <div id="mobile-drawer" class="hidden md:hidden bg-[#002B61] border-t border-white/5 transition-all">
    <div class="px-2 pt-2 pb-3 space-y-1 sm:px-3">
      <a href="index.php" class="flex items-center space-x-3 px-3 py-3 rounded-md text-base font-medium transition-all <?php echo activeMobileClass('index.php', $currentPage); ?>">
        <i data-lucide="home" class="h-5 w-5"></i>
        <span>Home</span>
      </a>
      <a href="book-slot.php" id="mob-book" class="hidden flex items-center space-x-3 px-3 py-3 rounded-md text-base font-medium transition-all <?php echo activeMobileClass('book-slot.php', $currentPage); ?>">
        <i data-lucide="calendar-plus" class="h-5 w-5"></i>
        <span>Book Slot</span>
      </a>
      <a href="tickets.php" id="mob-tickets" class="hidden flex items-center space-x-3 px-3 py-3 rounded-md text-base font-medium transition-all <?php echo activeMobileClass('tickets.php', $currentPage); ?>">
        <i data-lucide="ticket" class="h-5 w-5"></i>
        <span>Tickets</span>
      </a>
      <a href="inbox.php" id="mob-inbox" class="hidden flex items-center space-x-3 px-3 py-3 rounded-md text-base font-medium transition-all <?php echo activeMobileClass('inbox.php', $currentPage); ?>">
        <i data-lucide="message-square" class="h-5 w-5"></i>
        <span>Inbox</span>
      </a>
      <a href="profile.php" id="mob-profile" class="hidden flex items-center space-x-3 px-3 py-3 rounded-md text-base font-medium transition-all <?php echo activeMobileClass('profile.php', $currentPage); ?>">
        <i data-lucide="user" class="h-5 w-5"></i>
        <span>Profile</span>
      </a>
      <a href="admin.php" id="mob-admin" class="hidden flex items-center space-x-3 px-3 py-3 rounded-md text-base font-medium transition-all <?php echo activeMobileClass('admin.php', $currentPage); ?>">
        <i data-lucide="shield" class="h-5 w-5 text-[#C5A880]"></i>
        <span class="text-[#C5A880]">Admin Dashboard</span>
      </a>

      <!-- Logged Out Mobile Footer -->
      <div id="mob-auth-logged-out" class="pt-4 border-t border-white/10 mt-4 flex flex-col space-y-2 px-3 pb-4">
        <a href="login.php" class="w-full text-center py-2.5 rounded-md text-sm font-bold text-white border border-white/20 hover:bg-white/5 transition">
          Sign In
        </a>
        <a href="register.php" class="w-full text-center py-2.5 rounded-md text-sm font-bold bg-[#C5A880] text-[#002F6C] hover:bg-[#b09268] transition">
          Create Account
        </a>
      </div>

      <!-- Logged In Mobile Footer -->
      <div id="mob-auth-logged-in" class="hidden pt-4 pb-2 border-t border-white/10 mt-4">
        <div class="px-3 flex items-center justify-between mb-4">
          <div>
            <p id="mob-user-name" class="text-sm font-medium text-white">User</p>
            <p id="mob-user-email" class="text-xs text-gray-400">user@upsi.edu.my</p>
          </div>
          <div class="w-8 h-8 rounded-full bg-[#F1EAE0] flex items-center justify-center border border-[#C5A880]">
            <span id="mob-avatar-letter" class="text-[#002F6C] font-outfit text-xs font-bold">U</span>
          </div>
        </div>
        <button onclick="signOutUser()" class="w-full flex items-center justify-center space-x-2 bg-red-600/20 text-red-300 hover:bg-red-600 hover:text-white px-3 py-3 rounded-md text-sm font-bold border border-red-500/20 transition">
          <i data-lucide="log-out" class="h-5 w-5"></i>
          <span>Log Out Account</span>
        </button>
      </div>
    </div>
  </div>
</nav>

<script>
// UI logic for updating Navbar state depending on Auth session
onAuthResolve((user, profile) => {
  const desktopBook = document.getElementById('nav-book');
  const desktopTickets = document.getElementById('nav-tickets');
  const desktopInbox = document.getElementById('nav-inbox');
  const desktopProfile = document.getElementById('nav-profile');
  const desktopAdmin = document.getElementById('nav-admin');

  const mobBook = document.getElementById('mob-book');
  const mobTickets = document.getElementById('mob-tickets');
  const mobInbox = document.getElementById('mob-inbox');
  const mobProfile = document.getElementById('mob-profile');
  const mobAdmin = document.getElementById('mob-admin');

  const loggedOutBlock = document.getElementById('auth-buttons-logged-out');
  const loggedInBlock = document.getElementById('auth-user-logged-in');
  const greetingName = document.getElementById('user-greeting-name');

  const mobileBell = document.getElementById('mobile-bell');
  const mobLoggedOut = document.getElementById('mob-auth-logged-out');
  const mobLoggedIn = document.getElementById('mob-auth-logged-in');
  const mobUserName = document.getElementById('mob-user-name');
  const mobUserEmail = document.getElementById('mob-user-email');
  const mobAvatarLetter = document.getElementById('mob-avatar-letter');

  if (user) {
    // Show protected links
    [desktopBook, desktopTickets, desktopInbox, desktopProfile, mobBook, mobTickets, mobInbox, mobProfile].forEach(el => {
      if (el) el.classList.remove('hidden');
    });

    // Handle Admin view
    if (profile && profile.role === 'admin') {
      if (desktopAdmin) desktopAdmin.classList.remove('hidden');
      if (mobAdmin) mobAdmin.classList.remove('hidden');
    } else {
      if (desktopAdmin) desktopAdmin.classList.add('hidden');
      if (mobAdmin) mobAdmin.classList.add('hidden');
    }

    // Update greeting and headers
    if (greetingName) greetingName.textContent = profile?.name || user.email;
    if (mobUserName) mobUserName.textContent = profile?.name || 'User';
    if (mobUserEmail) mobUserEmail.textContent = user.email;
    if (mobAvatarLetter) mobAvatarLetter.textContent = (profile?.name || 'U').charAt(0).toUpperCase();

    // Toggle blocks
    if (loggedOutBlock) loggedOutBlock.classList.add('hidden');
    if (loggedInBlock) loggedInBlock.classList.remove('hidden');
    if (mobileBell) mobileBell.classList.remove('hidden');
    if (mobLoggedOut) mobLoggedOut.classList.add('hidden');
    if (mobLoggedIn) mobLoggedIn.classList.remove('hidden');
  } else {
    // Hide protected links
    [desktopBook, desktopTickets, desktopInbox, desktopProfile, desktopAdmin, mobBook, mobTickets, mobInbox, mobProfile, mobAdmin].forEach(el => {
      if (el) el.classList.add('hidden');
    });

    // Toggle blocks
    if (loggedOutBlock) loggedOutBlock.classList.remove('hidden');
    if (loggedInBlock) loggedInBlock.classList.add('hidden');
    if (mobileBell) mobileBell.classList.add('hidden');
    if (mobLoggedOut) mobLoggedOut.classList.remove('hidden');
    if (mobLoggedIn) mobLoggedIn.classList.add('hidden');
  }

  // Reload icons in case new ones appeared
  if (window.updateIcons) window.updateIcons();
});

// Mobile drawer open/close toggle
const mobileMenuBtn = document.getElementById('mobile-menu-btn');
const mobileDrawer = document.getElementById('mobile-drawer');
const mobileMenuIcon = document.getElementById('mobile-menu-icon');

if (mobileMenuBtn && mobileDrawer) {
  mobileMenuBtn.addEventListener('click', () => {
    mobileDrawer.classList.toggle('hidden');
    if (mobileDrawer.classList.contains('hidden')) {
      mobileMenuIcon.setAttribute('data-lucide', 'menu');
    } else {
      mobileMenuIcon.setAttribute('data-lucide', 'x');
    }
    if (window.updateIcons) window.updateIcons();
  });
}
</script>
