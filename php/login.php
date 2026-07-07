<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Login - e-Renang UPSI</title>
  <!-- Google Fonts -->
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;700;800&display=swap" rel="stylesheet">
  <!-- Tailwind CSS Local -->
  <link rel="stylesheet" href="css/style.css">
  <!-- Lucide Icons Local -->
  <script src="js/lucide.min.js"></script>
</head>
<body class="bg-[#F4F6F9] min-h-screen flex flex-col md:flex-row font-outfit text-[#1E293B]">

  <!-- Left side: Hero (Desktop) / Top banner (Mobile) -->
  <div 
    class="w-full md:w-1/2 relative flex flex-col items-center justify-center p-8 text-white min-h-[300px] md:min-h-screen overflow-hidden"
    style="background: linear-gradient(rgba(0, 47, 108, 0.75), rgba(0, 47, 108, 0.75)), url('assets/upsi_pool.jpg') center/cover no-repeat"
  >
    <!-- Abstract water wave overlay -->
    <div class="absolute inset-0 opacity-5 flex flex-col justify-around pointer-events-none">
      <i data-lucide="waves" class="w-full h-40 transform -rotate-12 scale-150 text-white"></i>
      <i data-lucide="waves" class="w-full h-40 transform rotate-12 scale-150 text-white"></i>
    </div>

    <!-- Logo and branding -->
    <div class="relative z-10 text-center flex flex-col items-center">
      <div class="bg-[#C5A880] p-4 rounded-full shadow-lg mb-6 flex items-center justify-center">
        <i data-lucide="waves" class="h-12 w-12 text-[#002F6C] animate-pulse"></i>
      </div>
      <h1 class="text-4xl md:text-5xl font-extrabold tracking-wide mb-2">
        e-Renang <span class="text-[#C5A880]">UPSI</span>
      </h1>
      <p class="text-sm md:text-base text-gray-300 font-light max-w-sm">
        Universiti Pendidikan Sultan Idris
      </p>
      <div class="mt-8 border-t border-white/20 pt-6 w-48 text-center">
        <span class="text-xs text-[#C5A880] uppercase font-bold tracking-wider">
          Swimming Pool Booking
        </span>
      </div>
    </div>
  </div>

  <!-- Right side: Login form container -->
  <div class="w-full md:w-1/2 flex items-center justify-center p-6 sm:p-12 bg-[#F4F6F9] md:min-h-screen">
    <div class="w-full max-w-md bg-white rounded-2xl shadow-xl border border-gray-100 p-8">
      <!-- Tab Selector -->
      <div class="flex border-b border-gray-200 mb-8">
        <button
          type="button"
          id="tab-user"
          onclick="switchTab(false)"
          class="w-1/2 pb-3 text-sm font-bold border-b-2 transition-all border-[#002F6C] text-[#002F6C]"
        >
          User Portal
        </button>
        <button
          type="button"
          id="tab-admin"
          onclick="switchTab(true)"
          class="w-1/2 pb-3 text-sm font-bold border-b-2 transition-all border-transparent text-gray-400 hover:text-gray-600"
        >
          Admin Portal
        </button>
      </div>

      <!-- Heading -->
      <div class="mb-6">
        <h2 id="login-title" class="text-2xl font-extrabold text-[#002F6C]">
          Welcome Back to Renang Club
        </h2>
        <p id="login-subtitle" class="text-sm text-gray-400 mt-1">
          Sign in to book a session and view your active passes
        </p>
      </div>

      <!-- Error display -->
      <div id="error-container" class="hidden mb-6 flex items-start gap-3 bg-red-50 border-l-4 border-red-500 text-red-700 p-4 rounded-r-lg text-sm">
        <i data-lucide="shield-alert" class="h-5 w-5 shrink-0 text-red-500 mt-0.5"></i>
        <span id="error-message"></span>
      </div>

      <!-- Form -->
      <form id="login-form" class="space-y-5">
        <!-- Email Field -->
        <div>
          <label class="block text-xs font-bold uppercase text-gray-500 mb-2 tracking-wider">
            Email Address
          </label>
          <div class="relative">
            <span class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-gray-400">
              <i data-lucide="mail" class="h-5 w-5"></i>
            </span>
            <input
              type="email"
              id="email"
              required
              placeholder="name@upsi.edu.my"
              class="block w-full pl-10 pr-3 py-3 border border-gray-200 rounded-xl bg-gray-50/50 text-gray-800 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20 focus:border-[#002F6C] transition text-sm"
            />
          </div>
        </div>

        <!-- Password Field -->
        <div>
          <div class="flex items-center justify-between mb-2">
            <label class="block text-xs font-bold uppercase text-gray-500 tracking-wider">
              Password
            </label>
          </div>
          <div class="relative">
            <span class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-gray-400">
              <i data-lucide="lock" class="h-5 w-5"></i>
            </span>
            <input
              type="password"
              id="password"
              required
              placeholder="••••••••"
              class="block w-full pl-10 pr-3 py-3 border border-gray-200 rounded-xl bg-gray-50/50 text-gray-800 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20 focus:border-[#002F6C] transition text-sm"
            />
          </div>
        </div>

        <!-- Submit Button -->
        <button
          type="submit"
          id="btn-submit"
          class="w-full py-3.5 px-4 rounded-xl text-white font-bold tracking-wide shadow-md transition-all flex items-center justify-center space-x-2 text-sm bg-[#002F6C] hover:bg-[#00204a] active:scale-95"
        >
          <i data-lucide="log-in" class="h-4 w-4"></i>
          <span id="btn-text">Sign In</span>
        </button>
      </form>

      <!-- User Sign Up Link -->
      <div id="signup-link-container" class="mt-8 text-center text-sm text-gray-500">
        Don't have an account? 
        <a href="register.php" class="text-[#002F6C] font-bold hover:underline">
          Sign Up
        </a>
      </div>
    </div>
  </div>

  <!-- Supabase Local -->
  <script src="js/supabase.min.js"></script>
  <!-- App Auth & Utilities -->
  <script src="js/auth.js"></script>
  <script src="js/main.js"></script>

  <script>
    let isAdminTab = false;

    function switchTab(admin) {
      isAdminTab = admin;
      
      const tabUser = document.getElementById('tab-user');
      const tabAdmin = document.getElementById('tab-admin');
      const loginTitle = document.getElementById('login-title');
      const loginSubtitle = document.getElementById('login-subtitle');
      const btnSubmit = document.getElementById('btn-submit');
      const btnText = document.getElementById('btn-text');
      const signupLink = document.getElementById('signup-link-container');
      const errorContainer = document.getElementById('error-container');

      errorContainer.classList.add('hidden');

      if (admin) {
        tabUser.className = "w-1/2 pb-3 text-sm font-bold border-b-2 transition-all border-transparent text-gray-400 hover:text-gray-600";
        tabAdmin.className = "w-1/2 pb-3 text-sm font-bold border-b-2 transition-all border-[#C5A880] text-[#C5A880]";
        loginTitle.textContent = "Pool Operator Sign In";
        loginTitle.className = "text-2xl font-extrabold text-[#C5A880]";
        loginSubtitle.textContent = "Enter administrative credentials to manage pool operations";
        btnSubmit.className = "w-full py-3.5 px-4 rounded-xl text-white font-bold tracking-wide shadow-md transition-all flex items-center justify-center space-x-2 text-sm bg-[#C5A880] hover:bg-[#b09268] active:scale-95";
        btnText.textContent = "Verify Operator";
        signupLink.classList.add('hidden');
      } else {
        tabUser.className = "w-1/2 pb-3 text-sm font-bold border-b-2 transition-all border-[#002F6C] text-[#002F6C]";
        tabAdmin.className = "w-1/2 pb-3 text-sm font-bold border-b-2 transition-all border-transparent text-gray-400 hover:text-gray-600";
        loginTitle.textContent = "Welcome Back to Renang Club";
        loginTitle.className = "text-2xl font-extrabold text-[#002F6C]";
        loginSubtitle.textContent = "Sign in to book a session and view your active passes";
        btnSubmit.className = "w-full py-3.5 px-4 rounded-xl text-white font-bold tracking-wide shadow-md transition-all flex items-center justify-center space-x-2 text-sm bg-[#002F6C] hover:bg-[#00204a] active:scale-95";
        btnText.textContent = "Sign In";
        signupLink.classList.remove('hidden');
      }
    }

    document.getElementById('login-form').addEventListener('submit', async (e) => {
      e.preventDefault();
      
      const email = document.getElementById('email').value.trim();
      const password = document.getElementById('password').value;
      const errorContainer = document.getElementById('error-container');
      const errorMessage = document.getElementById('error-message');
      const btnSubmit = document.getElementById('btn-submit');
      
      // Loading state
      btnSubmit.disabled = true;
      const originalContent = btnSubmit.innerHTML;
      btnSubmit.innerHTML = `<div class="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>`;
      errorContainer.classList.add('hidden');

      try {
        const data = await signIn(email, password);
        
        if (data && data.user) {
          // Verify user role
          const { data: profile, error: profileErr } = await window.supabaseClient
            .from('profiles')
            .select('role')
            .eq('id', data.user.id)
            .maybeSingle();

          if (profileErr) {
            throw new Error('Could not retrieve user profile role.');
          }

          const role = profile?.role || 'user';

          if (isAdminTab) {
            if (role === 'admin') {
              window.location.href = 'admin.php';
            } else {
              // Sign out since not admin
              await window.supabaseClient.auth.signOut();
              throw new Error('Access Denied: You are not authorized as a Pool Operator/Admin.');
            }
          } else {
            window.location.href = 'book-slot.php';
          }
        }
      } catch (err) {
        console.error('Login error:', err);
        errorMessage.textContent = err.message || 'Invalid email or password. Please try again.';
        errorContainer.classList.remove('hidden');
        btnSubmit.disabled = false;
        btnSubmit.innerHTML = originalContent;
      }
    });
    // Auto-redirect if already logged in when opening login.php
    onAuthResolve((user, profile) => {
      const btnSubmit = document.getElementById('btn-submit');
      // If user session and profile exist, and we're not in the middle of logging in
      if (user && profile && !btnSubmit.disabled) {
        if (profile.role === 'admin') {
          window.location.href = 'admin.php';
        } else {
          window.location.href = 'book-slot.php';
        }
      }
    });
  </script>
</body>
</html>
