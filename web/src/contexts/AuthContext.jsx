/**
 * AuthContext.jsx
 * ─────────────────────────────────────────────────────────────────────────────
 * Provides authentication state (user, profile, loading) and auth actions
 * (signIn, signUp, signOut) to the entire React app via React Context.
 *
 * Mirrors the Flutter app's DatabaseService authentication methods and
 * profiles table structure from Supabase.
 *
 * Usage:
 *   Wrap your app with <AuthProvider> in main.jsx, then consume with:
 *     const { user, profile, signIn, signUp, signOut } = useAuth();
 * ─────────────────────────────────────────────────────────────────────────────
 */

import { createContext, useContext, useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';

// ─── Context Creation ──────────────────────────────────────────────────────
const AuthContext = createContext(null);

/**
 * Custom hook to access auth context.
 * Throws if used outside of <AuthProvider>.
 */
export function useAuth() {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}

/**
 * AuthProvider Component
 * ─────────────────────────────────────────────────────────────────────────────
 * Wraps children with auth state. Listens for Supabase auth state changes,
 * fetches the user's profile from the `profiles` table, and exposes
 * signIn / signUp / signOut functions.
 */
export function AuthProvider({ children }) {
  // The Supabase auth user object (null if logged out)
  const [user, setUser] = useState(null);

  // The profile row from the `profiles` table ({ name, email, role, user_type, upsi_id })
  const [profile, setProfile] = useState(null);

  // True while the initial auth session is being resolved
  const [loading, setLoading] = useState(true);

  // ─── Fetch Profile from Supabase ───────────────────────────────────────
  // Mirrors DatabaseService.getProfile() in the Flutter app.
  // If no profile row exists yet (e.g. trigger didn't fire), it auto-creates
  // one from the user's metadata – same fallback as the Flutter version.
  async function fetchProfile(userId, currentUser) {
    try {
      const { data, error } = await supabase
        .from('profiles')
        .select('*')
        .eq('id', userId)
        .maybeSingle();

      if (error) {
        console.error('Error fetching profile:', error.message);
        return null;
      }

      // Fallback: auto-insert profile if row is missing (mirrors Flutter logic)
      if (!data && currentUser) {
        const meta = currentUser.user_metadata || {};
        const newProfile = {
          id: userId,
          name: meta.name || 'User',
          email: currentUser.email || '',
          user_type: meta.user_type || 'Student',
          upsi_id: meta.upsi_id || '',
          role: meta.role || 'user',
        };
        try {
          await supabase.from('profiles').insert(newProfile);
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

  // ─── Listen for Auth State Changes ─────────────────────────────────────
  useEffect(() => {
    // 1) Get the current session on mount
    const initSession = async () => {
      const { data: { session } } = await supabase.auth.getSession();
      const currentUser = session?.user ?? null;
      setUser(currentUser);

      if (currentUser) {
        const prof = await fetchProfile(currentUser.id, currentUser);
        setProfile(prof);
      }

      setLoading(false);
    };

    initSession();

    // 2) Subscribe to future auth changes (login, logout, token refresh)
    const { data: { subscription } } = supabase.auth.onAuthStateChange(
      async (_event, session) => {
        const currentUser = session?.user ?? null;
        setUser(currentUser);

        if (currentUser) {
          const prof = await fetchProfile(currentUser.id, currentUser);
          setProfile(prof);
        } else {
          setProfile(null);
        }
      }
    );

    // Cleanup subscription on unmount
    return () => {
      subscription.unsubscribe();
    };
  }, []);

  // ─── Sign In ───────────────────────────────────────────────────────────
  // Mirrors DatabaseService.signIn() – uses email + password auth.
  async function signIn({ email, password }) {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });

    if (error) throw error;
    return data;
  }

  // ─── Sign Up ───────────────────────────────────────────────────────────
  // Mirrors DatabaseService.signUp() – creates auth user with metadata,
  // then inserts a row into the `profiles` table.
  async function signUp({ email, password, name, userType, upsiId = '' }) {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
      options: {
        data: {
          name,
          user_type: userType,
          upsi_id: upsiId,
          role: 'user', // Default role – same as Flutter
        },
      },
    });

    if (error) throw error;

    // Insert profile row (mirrors Flutter's signUp logic)
    if (data.user) {
      try {
        await supabase.from('profiles').insert({
          id: data.user.id,
          name,
          email,
          user_type: userType,
          upsi_id: upsiId,
          role: 'user',
        });
      } catch (insertErr) {
        console.error('Error inserting profile on sign up:', insertErr);
        // Ignore if trigger already created the row
      }
    }

    return data;
  }

  // ─── Sign Out ──────────────────────────────────────────────────────────
  async function signOut() {
    const { error } = await supabase.auth.signOut();
    if (error) throw error;
    setUser(null);
    setProfile(null);
  }

  // ─── Check Admin Role ─────────────────────────────────────────────────
  // Convenience helper – mirrors DatabaseService.isAdmin()
  function isAdmin() {
    return profile?.role === 'admin';
  }

  // ─── Context Value ─────────────────────────────────────────────────────
  const value = {
    user,       // Supabase auth user object
    profile,    // Profile row from `profiles` table
    loading,    // True during initial session resolution
    signIn,     // ({ email, password }) => Promise
    signUp,     // ({ email, password, name, userType, upsiId }) => Promise
    signOut,    // () => Promise
    isAdmin,    // () => boolean
    supabase,   // Raw Supabase client for direct queries
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}

export default AuthContext;
