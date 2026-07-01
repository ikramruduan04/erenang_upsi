import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { Mail, Lock, LogIn, ShieldAlert, Waves } from 'lucide-react';

export default function Login() {
  const { signIn, supabase } = useAuth();
  const navigate = useNavigate();
  const [isAdminTab, setIsAdminTab] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleLogin = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');

    try {
      // Sign in the user
      const { user } = await signIn({ email, password });
      
      if (user) {
        // Query the profile to verify role
        const { data: profile, error: profileErr } = await supabase
          .from('profiles')
          .select('role')
          .eq('id', user.id)
          .maybeSingle();

        if (profileErr) {
          throw new Error('Could not retrieve user profile role.');
        }

        const role = profile?.role || 'user';

        if (isAdminTab) {
          if (role === 'admin') {
            navigate('/admin');
          } else {
            // Sign out because user clicked Admin Tab but is not an admin
            await supabase.auth.signOut();
            setError('Access Denied: You are not authorized as a Pool Operator/Admin.');
          }
        } else {
          // Regular user success path
          navigate('/book-slot');
        }
      }
    } catch (err) {
      console.error('Login error details:', err);
      setError(err.message || 'Invalid email or password. Please try again.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#F4F6F9] flex flex-col md:flex-row font-outfit">
      {/* Left side: Hero (Desktop) / Top banner (Mobile) */}
      <div 
        className="w-full md:w-1/2 relative flex flex-col items-center justify-center p-8 text-white min-h-[300px] md:min-h-screen overflow-hidden"
        style={{
          background: 'linear-gradient(rgba(0, 47, 108, 0.75), rgba(0, 47, 108, 0.75)), url("/assets/upsi_pool.jpg") center/cover no-repeat'
        }}
      >
        {/* Abstract water wave overlay */}
        <div className="absolute inset-0 opacity-5 flex flex-col justify-around">
          <Waves className="w-full h-40 transform -rotate-12 scale-150 text-white" />
          <Waves className="w-full h-40 transform rotate-12 scale-150 text-white" />
        </div>

        {/* Logo and branding */}
        <div className="relative z-10 text-center flex flex-col items-center">
          <div className="bg-[#C5A880] p-4 rounded-full shadow-lg mb-6 flex items-center justify-center">
            <Waves className="h-12 w-12 text-[#002F6C] animate-pulse" />
          </div>
          <h1 className="text-4xl md:text-5xl font-extrabold tracking-wide mb-2">
            e-Renang <span className="text-[#C5A880]">UPSI</span>
          </h1>
          <p className="text-sm md:text-base text-gray-300 font-light max-w-sm">
            Universiti Pendidikan Sultan Idris
          </p>
          <div className="mt-8 border-t border-white/20 pt-6 w-48 text-center">
            <span className="text-xs text-[#C5A880] uppercase font-bold tracking-wider">
              Swimming Pool Booking
            </span>
          </div>
        </div>
      </div>

      {/* Right side: Login form container */}
      <div className="w-full md:w-1/2 flex items-center justify-center p-6 sm:p-12 bg-[#F4F6F9] md:min-h-screen">
        <div className="w-full max-w-md bg-white rounded-2xl shadow-xl border border-gray-100 p-8 transform transition duration-300">
          {/* Tab Selector */}
          <div className="flex border-b border-gray-200 mb-8">
            <button
              type="button"
              onClick={() => {
                setIsAdminTab(false);
                setError('');
              }}
              className={`w-1/2 pb-3 text-sm font-bold border-b-2 transition-all ${
                !isAdminTab
                  ? 'border-[#002F6C] text-[#002F6C]'
                  : 'border-transparent text-gray-400 hover:text-gray-600'
              }`}
            >
              User Portal
            </button>
            <button
              type="button"
              onClick={() => {
                setIsAdminTab(true);
                setError('');
              }}
              className={`w-1/2 pb-3 text-sm font-bold border-b-2 transition-all ${
                isAdminTab
                  ? 'border-[#C5A880] text-[#C5A880]'
                  : 'border-transparent text-gray-400 hover:text-gray-600'
              }`}
            >
              Admin Portal
            </button>
          </div>

          {/* Heading */}
          <div className="mb-6">
            <h2 className={`text-2xl font-extrabold ${isAdminTab ? 'text-[#C5A880]' : 'text-[#002F6C]'}`}>
              {isAdminTab ? 'Pool Operator Sign In' : 'Welcome Back to Renang Club'}
            </h2>
            <p className="text-sm text-gray-400 mt-1">
              {isAdminTab
                ? 'Enter administrative credentials to manage pool operations'
                : 'Sign in to book a session and view your active passes'}
            </p>
          </div>

          {/* Error display */}
          {error && (
            <div className="mb-6 flex items-start gap-3 bg-red-50 border-l-4 border-red-500 text-red-700 p-4 rounded-r-lg text-sm">
              <ShieldAlert className="h-5 w-5 shrink-0 text-red-500 mt-0.5" />
              <span>{error}</span>
            </div>
          )}

          {/* Form */}
          <form onSubmit={handleLogin} className="space-y-5">
            {/* Email Field */}
            <div>
              <label className="block text-xs font-bold uppercase text-gray-500 mb-2 tracking-wider">
                Email Address
              </label>
              <div className="relative">
                <span className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-gray-400">
                  <Mail className="h-5 w-5" />
                </span>
                <input
                  type="email"
                  required
                  placeholder="name@upsi.edu.my"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="block w-full pl-10 pr-3 py-3 border border-gray-200 rounded-xl bg-gray-50/50 text-gray-800 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20 focus:border-[#002F6C] transition text-sm"
                />
              </div>
            </div>

            {/* Password Field */}
            <div>
              <div className="flex items-center justify-between mb-2">
                <label className="block text-xs font-bold uppercase text-gray-500 tracking-wider">
                  Password
                </label>
              </div>
              <div className="relative">
                <span className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-gray-400">
                  <Lock className="h-5 w-5" />
                </span>
                <input
                  type="password"
                  required
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="block w-full pl-10 pr-3 py-3 border border-gray-200 rounded-xl bg-gray-50/50 text-gray-800 placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20 focus:border-[#002F6C] transition text-sm"
                />
              </div>
            </div>

            {/* Submit Button */}
            <button
              type="submit"
              disabled={isLoading}
              className={`w-full py-3.5 px-4 rounded-xl text-white font-bold tracking-wide shadow-md transition-all flex items-center justify-center space-x-2 text-sm ${
                isLoading 
                  ? 'bg-gray-400 cursor-not-allowed' 
                  : isAdminTab 
                    ? 'bg-[#C5A880] hover:bg-[#b09268] active:scale-95' 
                    : 'bg-[#002F6C] hover:bg-[#00204a] active:scale-95'
              }`}
            >
              {isLoading ? (
                <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
              ) : (
                <>
                  <LogIn className="h-4 w-4" />
                  <span>{isAdminTab ? 'Verify Operator' : 'Sign In'}</span>
                </>
              )}
            </button>
          </form>

          {/* User Sign Up Link */}
          {!isAdminTab && (
            <div className="mt-8 text-center text-sm text-gray-500">
              Don't have an account?{' '}
              <Link to="/register" className="text-[#002F6C] font-bold hover:underline">
                Sign Up
              </Link>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
