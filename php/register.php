<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Register - e-Renang UPSI</title>
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

  <!-- Left side: Hero banner -->
  <div 
    class="w-full md:w-1/2 relative flex flex-col items-center justify-center p-8 text-white min-h-[300px] md:min-h-screen overflow-hidden"
    style="background: linear-gradient(rgba(0, 47, 108, 0.75), rgba(0, 47, 108, 0.75)), url('assets/upsi_pool.jpg') center/cover no-repeat"
  >
    <div class="absolute inset-0 opacity-5 flex flex-col justify-around pointer-events-none">
      <i data-lucide="waves" class="w-full h-40 transform -rotate-12 scale-150 text-white"></i>
      <i data-lucide="waves" class="w-full h-40 transform rotate-12 scale-150 text-white"></i>
    </div>

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

  <!-- Right side: Registration form -->
  <div class="w-full md:w-1/2 flex items-center justify-center p-6 sm:p-12 bg-[#F4F6F9] md:min-h-screen">
    <div class="w-full max-w-md bg-white rounded-2xl shadow-xl border border-gray-100 p-8">
      <!-- Header -->
      <div class="mb-6">
        <h2 class="text-2xl font-extrabold text-[#002F6C]">
          Join the Renang Club
        </h2>
        <p class="text-sm text-gray-400 mt-1">
          Create an account to book swimming pool time slots at UPSI
        </p>
      </div>

      <!-- Error display -->
      <div id="error-container" class="hidden mb-6 flex items-start gap-3 bg-red-50 border-l-4 border-red-500 text-red-700 p-4 rounded-r-lg text-sm">
        <i data-lucide="shield-alert" class="h-5 w-5 shrink-0 text-red-500 mt-0.5"></i>
        <span id="error-message"></span>
      </div>

      <!-- Form -->
      <form id="register-form" class="space-y-4">
        <!-- Full Name -->
        <div>
          <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
            Full Name
          </label>
          <div class="relative">
            <span class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-gray-400">
              <i data-lucide="user" class="h-4 w-4"></i>
            </span>
            <input
              type="text"
              id="name"
              required
              placeholder="Muhammad Ali"
              class="block w-full pl-10 pr-3 py-2.5 border border-gray-200 rounded-xl bg-gray-50/50 text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20 focus:border-[#002F6C] transition text-sm"
            />
          </div>
        </div>

        <!-- Email -->
        <div>
          <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
            Email Address
          </label>
          <div class="relative">
            <span class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-gray-400">
              <i data-lucide="mail" class="h-4 w-4"></i>
            </span>
            <input
              type="email"
              id="email"
              required
              placeholder="ali@student.upsi.edu.my"
              class="block w-full pl-10 pr-3 py-2.5 border border-gray-200 rounded-xl bg-gray-50/50 text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20 focus:border-[#002F6C] transition text-sm"
            />
          </div>
        </div>

        <!-- Password -->
        <div>
          <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
            Password
          </label>
          <div class="relative">
            <span class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-gray-400">
              <i data-lucide="lock" class="h-4 w-4"></i>
            </span>
            <input
              type="password"
              id="password"
              required
              placeholder="••••••••"
              class="block w-full pl-10 pr-3 py-2.5 border border-gray-200 rounded-xl bg-gray-50/50 text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20 focus:border-[#002F6C] transition text-sm"
            />
          </div>
        </div>

        <!-- User Category -->
        <div>
          <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
            User Category
          </label>
          <div class="relative">
            <span class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-gray-400">
              <i data-lucide="graduation-cap" class="h-4 w-4"></i>
            </span>
            <select
              id="userType"
              onchange="toggleUpsiIdField()"
              class="block w-full pl-10 pr-3 py-2.5 border border-gray-200 rounded-xl bg-gray-50/50 text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20 focus:border-[#002F6C] transition text-sm appearance-none cursor-pointer"
            >
              <option value="Student">Student (Pelajar)</option>
              <option value="Staff">Staff (Staf)</option>
              <option value="Public">Public (Orang Awam)</option>
            </select>
            <span class="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none text-gray-400">
              ▼
            </span>
          </div>
        </div>

        <!-- UPSI ID (hidden for Public) -->
        <div id="upsiId-container" class="transition-all duration-300">
          <label id="upsiId-label" class="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
            UPSI ID (Matric / Staff Number)
          </label>
          <div class="relative">
            <span class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-gray-400">
              <i data-lucide="credit-card" class="h-4 w-4"></i>
            </span>
            <input
              type="text"
              id="upsiId"
              required
              placeholder="D20211099999"
              class="block w-full pl-10 pr-3 py-2.5 border border-gray-200 rounded-xl bg-gray-50/50 text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20 focus:border-[#002F6C] transition text-sm"
            />
          </div>
        </div>

        <!-- Submit Button -->
        <button
          type="submit"
          id="btn-submit"
          class="w-full py-3.5 px-4 rounded-xl text-white font-bold tracking-wide shadow-md transition-all flex items-center justify-center space-x-2 text-sm bg-[#002F6C] hover:bg-[#00204a] active:scale-95 mt-6"
        >
          <span>Create Account</span>
          <i data-lucide="arrow-right" class="h-4 w-4"></i>
        </button>
      </form>

      <!-- User Sign In Link -->
      <div class="mt-6 text-center text-sm text-gray-500">
        Already have an account? 
        <a href="login.php" class="text-[#002F6C] font-bold hover:underline">
          Sign In
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
    function toggleUpsiIdField() {
      const userType = document.getElementById('userType').value;
      const upsiIdContainer = document.getElementById('upsiId-container');
      const upsiIdLabel = document.getElementById('upsiId-label');
      const upsiIdInput = document.getElementById('upsiId');

      if (userType === 'Public') {
        upsiIdContainer.classList.add('hidden');
        upsiIdInput.removeAttribute('required');
      } else {
        upsiIdContainer.classList.remove('hidden');
        upsiIdInput.setAttribute('required', 'required');
        if (userType === 'Student') {
          upsiIdLabel.textContent = "UPSI ID (Matric Number)";
          upsiIdInput.placeholder = "D20211099999";
        } else {
          upsiIdLabel.textContent = "UPSI ID (Staff Number)";
          upsiIdInput.placeholder = "STAFF1234";
        }
      }
    }

    document.getElementById('register-form').addEventListener('submit', async (e) => {
      e.preventDefault();

      const name = document.getElementById('name').value.trim();
      const email = document.getElementById('email').value.trim();
      const password = document.getElementById('password').value;
      const userType = document.getElementById('userType').value;
      let upsiId = document.getElementById('upsiId').value.trim();
      
      const errorContainer = document.getElementById('error-container');
      const errorMessage = document.getElementById('error-message');
      const btnSubmit = document.getElementById('btn-submit');

      errorContainer.classList.add('hidden');

      if (userType === 'Public') {
        upsiId = '';
      } else if (!upsiId) {
        errorMessage.textContent = 'UPSI ID is required for Students and Staff.';
        errorContainer.classList.remove('hidden');
        return;
      }

      // Loading state
      btnSubmit.disabled = true;
      const originalContent = btnSubmit.innerHTML;
      btnSubmit.innerHTML = `<div class="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>`;

      try {
        await signUp(email, password, name, userType, upsiId);
        window.location.href = 'book-slot.php';
      } catch (err) {
        console.error('Registration error:', err);
        errorMessage.textContent = err.message || 'Failed to create account. Please check details and try again.';
        errorContainer.classList.remove('hidden');
        btnSubmit.disabled = false;
        btnSubmit.innerHTML = originalContent;
      }
    });

    // Auto-redirect if already logged in when opening register.php
    onAuthResolve((user, profile) => {
      const btnSubmit = document.getElementById('btn-submit');
      if (user && profile && !btnSubmit.disabled) {
        window.location.href = 'book-slot.php';
      }
    });

    // Run once at start
    toggleUpsiIdField();
  </script>
</body>
</html>
