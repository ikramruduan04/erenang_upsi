<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Profile - e-Renang UPSI</title>
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

    <!-- Profile Content -->
    <div id="profile-content" class="hidden min-h-screen py-8">
      <div class="max-w-3xl mx-auto px-4 sm:px-6">
        
        <!-- Profile Card Header -->
        <div class="bg-white rounded-3xl shadow-sm border border-gray-100 p-6 md:p-8 mb-6">
          <div class="flex flex-col md:flex-row items-center md:items-start text-center md:text-left gap-6">
            
            <!-- Avatar Circle -->
            <div id="display-avatar" class="w-24 h-24 rounded-full bg-[#002F6C] border-4 border-[#C5A880] flex items-center justify-center text-white text-3xl font-extrabold shadow-md">
              U
            </div>

            <!-- User Details -->
            <div class="flex-1 space-y-2.5">
              <div class="flex flex-col md:flex-row items-center gap-2">
                <h1 id="display-name" class="text-2xl font-extrabold text-[#002F6C]">User</h1>
                <span id="display-badge" class="bg-[#C5A880]/15 text-[#002F6C] border border-[#C5A880]/30 text-xs font-bold px-3 py-1 rounded-full uppercase tracking-wider">
                  Student
                </span>
              </div>
              
              <div class="space-y-1 text-sm text-gray-500">
                <p class="flex items-center justify-center md:justify-start gap-2">
                  <i data-lucide="mail" class="h-4 w-4 text-[#C5A880]"></i>
                  <span id="display-email">...</span>
                </p>
                <p id="display-phone-row" class="hidden flex items-center justify-center md:justify-start gap-2">
                  <i data-lucide="phone" class="h-4 w-4 text-[#C5A880]"></i>
                  <span id="display-phone">...</span>
                </p>
                <p id="display-upsi-row" class="hidden flex items-center justify-center md:justify-start gap-2">
                  <i data-lucide="graduation-cap" class="h-4 w-4 text-[#C5A880]"></i>
                  <span id="display-upsi">ID: ...</span>
                </p>
              </div>

              <!-- Edit Profile Action Button -->
              <div class="pt-2">
                <button
                  onclick="openEditModal()"
                  class="flex items-center gap-1.5 bg-[#002F6C] hover:bg-[#00204a] text-white px-4 py-2 rounded-xl text-xs font-bold transition shadow-sm"
                >
                  <i data-lucide="edit-3" class="h-3.5 w-3.5"></i>
                  <span>Edit Profile Details</span>
                </button>
              </div>

            </div>
          </div>
        </div>

        <!-- Stats Grid -->
        <div class="grid grid-cols-2 gap-4 mb-6">
          <!-- Sessions Card -->
          <div class="bg-white rounded-2xl border border-gray-100 p-5 flex flex-col items-center text-center shadow-sm">
            <div class="bg-[#F1EAE0] p-3 rounded-xl mb-3 text-[#002F6C]">
              <i data-lucide="check-square" class="h-6 w-6"></i>
            </div>
            <span id="stat-sessions" class="text-2xl font-extrabold text-[#002F6C]">
              ...
            </span>
            <span class="text-xs text-gray-400 mt-1 font-medium">Sessions Checked In</span>
          </div>

          <!-- Swimmer Points Card -->
          <div class="bg-white rounded-2xl border border-gray-100 p-5 flex flex-col items-center text-center shadow-sm">
            <div class="bg-[#F1EAE0] p-3 rounded-xl mb-3 text-[#002F6C]">
              <i data-lucide="coins" class="h-6 w-6"></i>
            </div>
            <span id="stat-points" class="text-2xl font-extrabold text-[#C5A880]">
              ...
            </span>
            <span class="text-xs text-gray-400 mt-1 font-medium">Renang Club Points</span>
          </div>
        </div>

        <!-- Account Options List -->
        <div class="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden mb-6">
          <div class="divide-y divide-gray-100">
            
            <a 
              href="mailto:support@erenang.upsi.edu.my"
              class="flex items-center justify-between p-4 hover:bg-gray-50 transition"
            >
              <div class="flex items-center gap-3">
                <div class="bg-gray-100 p-2 rounded-lg text-[#002F6C]">
                  <i data-lucide="help-circle" class="h-5 w-5"></i>
                </div>
                <div>
                  <h3 class="text-sm font-bold text-gray-800">Help & Support Desk</h3>
                  <p class="text-xs text-gray-400">Need assistance? Email support</p>
                </div>
              </div>
              <i data-lucide="chevron-right" class="h-5 w-5 text-gray-300"></i>
            </a>

            <div class="flex items-center justify-between p-4 hover:bg-gray-50 cursor-pointer transition">
              <div class="flex items-center gap-3">
                <div class="bg-gray-100 p-2 rounded-lg text-[#002F6C]">
                  <i data-lucide="file-text" class="h-5 w-5"></i>
                </div>
                <div>
                  <h3 class="text-sm font-bold text-gray-800">Terms & Conditions</h3>
                  <p class="text-xs text-gray-400">Rules & pool regulation policy</p>
                </div>
              </div>
              <i data-lucide="chevron-right" class="h-5 w-5 text-gray-300"></i>
            </div>

          </div>
        </div>

        <!-- Log Out Button -->
        <button
          onclick="signOutUser()"
          class="w-full flex items-center justify-center gap-2 border-2 border-red-500/20 hover:border-red-500 hover:bg-red-50 text-red-600 hover:text-red-700 font-bold py-3.5 rounded-2xl transition text-sm"
        >
          <i data-lucide="log-out" class="h-4 w-4"></i>
          <span>Log Out Account</span>
        </button>

      </div>
    </div>

    <!-- Edit Profile Modal -->
    <div id="edit-modal" class="hidden fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50">
      <div class="bg-white rounded-3xl w-full max-w-md overflow-hidden shadow-2xl border border-gray-100">
        <div class="bg-[#002F6C] px-6 py-4 flex items-center justify-between text-white">
          <h2 class="text-lg font-bold">Edit Profile Details</h2>
          <button 
            onclick="closeEditModal()"
            class="text-white/80 hover:text-white transition"
          >
            <i data-lucide="x" class="h-5 w-5"></i>
          </button>
        </div>

        <form id="edit-form" class="p-6 space-y-4">
          
          <div id="modal-feedback" class="hidden p-4 rounded-xl flex items-center gap-2 text-sm">
            <span id="modal-feedback-message"></span>
          </div>

          <!-- Name Field -->
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
                id="edit-name"
                required
                class="block w-full pl-10 pr-3 py-2.5 border border-gray-200 rounded-xl bg-gray-50/50 text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20 focus:border-[#002F6C] transition text-sm"
              />
            </div>
          </div>

          <!-- Phone Field -->
          <div>
            <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
              Phone Number
            </label>
            <div class="relative">
              <span class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-gray-400">
                <i data-lucide="phone" class="h-4 w-4"></i>
              </span>
              <input
                type="text"
                id="edit-phone"
                placeholder="e.g. +60123456789"
                class="block w-full pl-10 pr-3 py-2.5 border border-gray-200 rounded-xl bg-gray-50/50 text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20 focus:border-[#002F6C] transition text-sm"
              />
            </div>
          </div>

          <!-- UPSI ID -->
          <div id="edit-upsi-container">
            <label class="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
              UPSI ID Number
            </label>
            <div class="relative">
              <span class="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-gray-400">
                <i data-lucide="graduation-cap" class="h-4 w-4"></i>
              </span>
              <input
                type="text"
                id="edit-upsi"
                class="block w-full pl-10 pr-3 py-2.5 border border-gray-200 rounded-xl bg-gray-50/50 text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20 focus:border-[#002F6C] transition text-sm"
              />
            </div>
          </div>

          <!-- Submit Buttons -->
          <div class="flex gap-3 mt-6">
            <button
              type="button"
              onclick="closeEditModal()"
              class="w-1/2 border border-gray-200 py-3 rounded-xl text-gray-600 hover:bg-gray-50 transition text-sm font-semibold"
            >
              Cancel
            </button>
            <button
              type="submit"
              id="edit-btn-submit"
              class="w-1/2 bg-[#002F6C] hover:bg-[#00204a] text-white py-3 rounded-xl transition text-sm font-semibold flex items-center justify-center"
            >
              Save Changes
            </button>
          </div>

        </form>
      </div>
    </div>

  </main>


  <script>
    let localProfile = null;

    function openEditModal() {
      if (!localProfile) return;
      document.getElementById('edit-name').value = localProfile.name || '';
      document.getElementById('edit-phone').value = localProfile.phone || '';
      
      const upsiContainer = document.getElementById('edit-upsi-container');
      const upsiInput = document.getElementById('edit-upsi');
      
      if (localProfile.user_type === 'Public') {
        upsiContainer.classList.add('hidden');
        upsiInput.removeAttribute('required');
      } else {
        upsiContainer.classList.remove('hidden');
        upsiInput.setAttribute('required', 'required');
        upsiInput.value = localProfile.upsi_id || '';
      }

      document.getElementById('edit-modal').classList.remove('hidden');
      if (window.updateIcons) window.updateIcons();
    }

    function closeEditModal() {
      document.getElementById('edit-modal').classList.add('hidden');
      document.getElementById('modal-feedback').classList.add('hidden');
    }

    document.getElementById('edit-form').addEventListener('submit', async (e) => {
      e.preventDefault();
      
      const submitBtn = document.getElementById('edit-btn-submit');
      const originalText = submitBtn.textContent;
      submitBtn.disabled = true;
      submitBtn.innerHTML = `<div class="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>`;

      const name = document.getElementById('edit-name').value.trim();
      const phone = document.getElementById('edit-phone').value.trim();
      const upsiId = localProfile.user_type === 'Public' ? '' : document.getElementById('edit-upsi').value.trim();
      
      const feedback = document.getElementById('modal-feedback');
      const feedbackMsg = document.getElementById('modal-feedback-message');

      try {
        const { error } = await window.supabaseClient
          .from('profiles')
          .update({
            name,
            phone,
            upsi_id: upsiId
          })
          .eq('id', currentUser.id);

        if (error) throw error;

        // Also update auth user metadata
        await window.supabaseClient.auth.updateUser({
          data: {
            name,
            upsi_id: upsiId
          }
        });

        feedback.className = "p-4 rounded-xl flex items-center gap-2 text-sm bg-green-50 text-green-700";
        feedbackMsg.textContent = "Profile updated successfully!";
        feedback.classList.remove('hidden');

        setTimeout(() => {
          closeEditModal();
          window.location.reload();
        }, 1500);

      } catch (err) {
        console.error('Error updating profile:', err);
        feedback.className = "p-4 rounded-xl flex items-center gap-2 text-sm bg-red-50 text-red-700";
        feedbackMsg.textContent = err.message || "Failed to update profile.";
        feedback.classList.remove('hidden');
        submitBtn.disabled = false;
        submitBtn.textContent = originalText;
      }
    });

    onAuthResolve(async (user, profile) => {
      if (!user) return;
      localProfile = profile;

      // Update UI basic details instantly
      document.getElementById('display-avatar').textContent = (profile.name || 'U').charAt(0).toUpperCase();
      document.getElementById('display-name').textContent = profile.name || 'Swimmer';
      document.getElementById('display-badge').textContent = profile.user_type || 'Student';
      document.getElementById('display-email').textContent = profile.email || user.email;
      
      if (profile.phone) {
        document.getElementById('display-phone').textContent = profile.phone;
        document.getElementById('display-phone-row').classList.remove('hidden');
      } else {
        document.getElementById('display-phone-row').classList.add('hidden');
      }

      if (profile.user_type !== 'Public' && profile.upsi_id) {
        document.getElementById('display-upsi').textContent = "ID: " + profile.upsi_id;
        document.getElementById('display-upsi-row').classList.remove('hidden');
      } else {
        document.getElementById('display-upsi-row').classList.add('hidden');
      }

      // Show profile card immediately to bypass spinner freeze
      document.getElementById('page-loader').classList.add('hidden');
      document.getElementById('profile-content').classList.remove('hidden');

      try {
        // Fetch check-in sessions in background
        const { data, error } = await window.supabaseClient
          .from('bookings')
          .select('id')
          .eq('user_id', user.id)
          .eq('status', 'Checked In');

        if (error) throw error;

        const sessionCount = data?.length || 0;
        const points = sessionCount * 20;

        document.getElementById('stat-sessions').textContent = sessionCount;
        document.getElementById('stat-points').textContent = points;
        
        if (window.updateIcons) window.updateIcons();

      } catch (err) {
        console.error('Error fetching profile dashboard details:', err);
      }
    });
  </script>
</body>
</html>
