/**
 * auth.js
 * Synchronous page guards, localStorage caching, and Supabase integration.
 */

const supabaseUrl = 'https://wxzklwhlqnzucnhhyfij.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind4emtsd2hscW56dWNuaGh5ZmlqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEwMjE4NDEsImV4cCI6MjA5NjU5Nzg0MX0.BUlM7Y_Fpq4_xCOo3mcMTtaOONE_C2rF2uHw-gmFGRc';

// Initialize Supabase Client
try {
  let clientLib = null;
  if (typeof window.supabase !== 'undefined') {
    clientLib = window.supabase;
  } else if (typeof supabase !== 'undefined') {
    clientLib = supabase;
  }

  if (clientLib) {
    window.supabaseClient = clientLib.createClient(supabaseUrl, supabaseAnonKey);
  } else {
    console.error("Supabase library not found in global scope.");
  }
} catch (e) {
  console.error("Error creating Supabase client:", e);
}

// 1. Load Session & Profile Synchronously from Cache
let currentUser = null;
let currentProfile = null;

try {
  const cachedUserObj = localStorage.getItem('upsi_cached_user');
  const cachedProfileObj = localStorage.getItem('upsi_cached_profile');
  if (cachedUserObj) currentUser = JSON.parse(cachedUserObj);
  if (cachedProfileObj) currentProfile = JSON.parse(cachedProfileObj);
} catch (e) {
  console.warn("Error reading auth cache:", e);
}

// Expose to window for global access across scripts
window.currentUser = currentUser;
window.currentProfile = currentProfile;


// 2. Synchronous Page Guards (Redirects instantly before rendering loading spinner)
const currentPage = window.location.pathname.split('/').pop();
const isAuthPage = currentPage === 'login.php' || currentPage === 'register.php';

if (!currentUser && !isAuthPage) {
  // If not logged in and not on login/register, redirect to login page immediately
  window.location.href = 'login.php';
} else if (currentUser && isAuthPage) {
  // If already logged in and on login/register, bypass form and redirect to landing page
  if (currentProfile && currentProfile.role === 'admin') {
    window.location.href = 'admin.php';
  } else {
    window.location.href = 'book-slot.php';
  }
}

// Admin Page Guard (Direct URL block)
if (currentPage === 'admin.php') {
  if (!currentProfile || currentProfile.role !== 'admin') {
    window.location.href = 'index.php';
  }
}

// 3. Callback Registration for Pages
let authCallbacks = [];
function onAuthResolve(callback) {
  if (currentUser !== null || currentProfile !== null) {
    callback(currentUser, currentProfile);
  }
  authCallbacks.push(callback);
}

// Fetch Profile helper
async function fetchProfile(userId, userObj) {
  try {
    const { data, error } = await window.supabaseClient
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .maybeSingle();

    if (error) {
      console.error('Error fetching profile:', error.message);
      return null;
    }

    if (!data && userObj) {
      const meta = userObj.user_metadata || {};
      const newProfile = {
        id: userId,
        name: meta.name || 'User',
        email: userObj.email || '',
        user_type: meta.user_type || 'Student',
        upsi_id: meta.upsi_id || '',
        role: meta.role || 'user',
      };
      try {
        await window.supabaseClient.from('profiles').insert(newProfile);
        return newProfile;
      } catch (insertErr) {
        console.error('Error auto-inserting profile:', insertErr);
      }
    }

    return data;
  } catch (err) {
    console.error('Error in fetchProfile:', err);
    return null;
  }
}

// 4. Background Auth State Sync
if (window.supabaseClient) {
  window.supabaseClient.auth.onAuthStateChange(async (event, session) => {
    const newUser = session?.user ?? null;
    
    // If session status changed
    if (newUser) {
      currentUser = newUser;
      window.currentUser = newUser;
      localStorage.setItem('upsi_cached_user', JSON.stringify(currentUser));
      
      // Fetch profile and check role
      const profile = await fetchProfile(currentUser.id, currentUser);
      if (profile) {
        currentProfile = profile;
        window.currentProfile = profile;
        localStorage.setItem('upsi_cached_profile', JSON.stringify(currentProfile));
      }
    } else {
      currentUser = null;
      window.currentUser = null;
      currentProfile = null;
      window.currentProfile = null;
      localStorage.removeItem('upsi_cached_user');
      localStorage.removeItem('upsi_cached_profile');
      localStorage.removeItem('upsi_cached_session_count');
      localStorage.removeItem('upsi_cached_bookings');
      localStorage.removeItem('upsi_cached_announcements');
    }

    // Run all registered callbacks
    authCallbacks.forEach(cb => cb(currentUser, currentProfile));

    // Handle session expiry redirects in background
    if (!currentUser && !isAuthPage) {
      window.location.href = 'login.php';
    }
  });
}

// Auth actions
async function signIn(email, password) {
  const { data, error } = await window.supabaseClient.auth.signInWithPassword({
    email,
    password
  });
  if (error) throw error;
  return data;
}

async function signUp(email, password, name, userType, upsiId = '') {
  const { data, error } = await window.supabaseClient.auth.signUp({
    email,
    password,
    options: {
      data: {
        name,
        user_type: userType,
        upsi_id: upsiId,
        role: 'user'
      }
    }
  });

  if (error) throw error;

  if (data.user) {
    try {
      await window.supabaseClient.from('profiles').insert({
        id: data.user.id,
        name,
        email,
        user_type: userType,
        upsi_id: upsiId,
        role: 'user'
      });
    } catch (insertErr) {
      console.error('Error inserting profile on sign up:', insertErr);
    }
  }

  return data;
}

async function signOutUser() {
  localStorage.removeItem('upsi_cached_user');
  localStorage.removeItem('upsi_cached_profile');
  localStorage.removeItem('upsi_cached_session_count');
  localStorage.removeItem('upsi_cached_bookings');
  localStorage.removeItem('upsi_cached_announcements');
  
  if (window.supabaseClient) {
    try {
      await window.supabaseClient.auth.signOut();
    } catch (e) {
      console.warn("SignOut error:", e);
    }
  }
  
  currentUser = null;
  currentProfile = null;
  window.location.href = 'login.php';
}
