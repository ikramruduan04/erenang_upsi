/**
 * auth.js
 * Central Supabase configuration and authentication helpers for e-Renang UPSI PHP.
 */

const supabaseUrl = 'https://wxzklwhlqnzucnhhyfij.supabase.co';
const supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind4emtsd2hscW56dWNuaGh5ZmlqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEwMjE4NDEsImV4cCI6MjA5NjU5Nzg0MX0.BUlM7Y_Fpq4_xCOo3mcMTtaOONE_C2rF2uHw-gmFGRc';

// Initialize Supabase Client
if (window.supabase) {
  window.supabaseClient = window.supabase.createClient(supabaseUrl, supabaseAnonKey);
} else {
  console.error("Supabase CDN failed to load.");
}

// Global session and profile variables
let currentUser = null;
let currentProfile = null;
let authCallbacks = [];

// Add a callback to be notified when auth status resolves
function onAuthResolve(callback) {
  if (currentUser !== null || currentProfile !== null) {
    callback(currentUser, currentProfile);
  }
  authCallbacks.push(callback);
}

// Fetch Profile from Supabase (mirrors React/Flutter profile fetching)
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

// Monitor Authentication State
window.supabaseClient.auth.onAuthStateChange(async (event, session) => {
  currentUser = session?.user ?? null;
  
  if (currentUser) {
    currentProfile = await fetchProfile(currentUser.id, currentUser);
  } else {
    currentProfile = null;
  }

  // Run all registered callbacks
  authCallbacks.forEach(cb => cb(currentUser, currentProfile));

  // Page Guards
  const currentPage = window.location.pathname.split('/').pop();
  
  // Public pages
  const isAuthPage = currentPage === 'login.php' || currentPage === 'register.php';
  
  if (!currentUser && !isAuthPage && currentPage !== '' && currentPage !== 'index.php') {
    // If not logged in and not on login/register/home page, redirect to login
    window.location.href = 'login.php';
  } else if (currentUser && isAuthPage) {
    // If logged in and on login/register, redirect to home
    window.location.href = 'index.php';
  }

  // Admin page guard
  if (currentPage === 'admin.php') {
    if (!currentProfile || currentProfile.role !== 'admin') {
      window.location.href = 'index.php';
    }
  }
});

// Auth functions
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
  const { error } = await window.supabaseClient.auth.signOut();
  if (error) throw error;
  currentUser = null;
  currentProfile = null;
  window.location.href = 'login.php';
}
