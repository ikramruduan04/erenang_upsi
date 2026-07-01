import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { User, Mail, Lock, GraduationCap, CreditCard, ShieldAlert, Waves, ArrowRight } from 'lucide-react';

export default function Register() {
  const { signUp } = useAuth();
  const navigate = useNavigate();
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [userType, setUserType] = useState('Student'); // Student, Staff, Public
  const [upsiId, setUpsiId] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState('');

  const handleRegister = async (e) => {
    e.preventDefault();
    setIsLoading(true);
    setError('');

    // Public users don't require UPSI ID
    const submittedUpsiId = userType === 'Public' ? '' : upsiId;

    if (userType !== 'Public' && !upsiId.trim()) {
      setError('UPSI ID is required for Students and Staff.');
      setIsLoading(false);
      return;
    }

    try {
      await signUp({
        email,
        password,
        name,
        userType,
        upsiId: submittedUpsiId
      });
      // Redirect to booking page upon successful sign up
      navigate('/book-slot');
    } catch (err) {
      console.error('Registration error:', err);
      setError(err.message || 'Failed to create account. Please check details and try again.');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-[#F4F6F9] flex flex-col md:flex-row font-outfit">
      {/* Left side: Hero banner (same as Login) */}
      <div 
        className="w-full md:w-1/2 relative flex flex-col items-center justify-center p-8 text-white min-h-[300px] md:min-h-screen overflow-hidden"
        style={{
          background: 'linear-gradient(rgba(0, 47, 108, 0.75), rgba(0, 47, 108, 0.75)), url("/assets/upsi_pool.jpg") center/cover no-repeat'
        }}
      >
        <div className="absolute inset-0 opacity-5 flex flex-col justify-around">
          <Waves className="w-full h-40 transform -rotate-12 scale-150 text-white" />
          <Waves className="w-full h-40 transform rotate-12 scale-150 text-white" />
        </div>

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

      {/* Right side: Registration form */}
      <div className="w-full md:w-1/2 flex items-center justify-center p-6 sm:p-12 bg-[#F4F6F9] md:min-h-screen">
        <div className="w-full max-w-md bg-white rounded-2xl shadow-xl border border-gray-100 p-8 transform transition duration-300">
          {/* Header */}
          <div className="mb-6">
            <h2 className="text-2xl font-extrabold text-[#002F6C]">
              Join the Renang Club
            </h2>
            <p className="text-sm text-gray-400 mt-1">
              Create an account to book swimming pool time slots at UPSI
            </p>
          </div>

          {/* Error display */}
          {error && (
            <div className="mb-6 flex items-start gap-3 bg-red-50 border-l-4 border-red-500 text-red-700 p-4 rounded-r-lg text-sm animate-shake">
              <ShieldAlert className="h-5 w-5 shrink-0 text-red-500 mt-0.5" />
              <span>{error}</span>
            </div>
          )}

          {/* Form */}
          <form onSubmit={handleRegister} className="space-y-4">
            {/* Full Name */}
            <div>
              <label className="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
                Full Name
              </label>
              <div className="relative">
                <span className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-gray-400">
                  <User className="h-4 w-4" />
                </span>
                <input
                  type="text"
                  required
                  placeholder="Muhammad Ali"
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  className="block w-full pl-10 pr-3 py-2.5 border border-gray-200 rounded-xl bg-gray-50/50 text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20 focus:border-[#002F6C] transition text-sm"
                />
              </div>
            </div>

            {/* Email */}
            <div>
              <label className="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
                Email Address
              </label>
              <div className="relative">
                <span className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-gray-400">
                  <Mail className="h-4 w-4" />
                </span>
                <input
                  type="email"
                  required
                  placeholder="ali@student.upsi.edu.my"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  className="block w-full pl-10 pr-3 py-2.5 border border-gray-200 rounded-xl bg-gray-50/50 text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20 focus:border-[#002F6C] transition text-sm"
                />
              </div>
            </div>

            {/* Password */}
            <div>
              <label className="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
                Password
              </label>
              <div className="relative">
                <span className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-gray-400">
                  <Lock className="h-4 w-4" />
                </span>
                <input
                  type="password"
                  required
                  placeholder="••••••••"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  className="block w-full pl-10 pr-3 py-2.5 border border-gray-200 rounded-xl bg-gray-50/50 text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20 focus:border-[#002F6C] transition text-sm"
                />
              </div>
            </div>

            {/* User Category */}
            <div>
              <label className="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
                User Category
              </label>
              <div className="relative">
                <span className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-gray-400">
                  <GraduationCap className="h-4 w-4" />
                </span>
                <select
                  value={userType}
                  onChange={(e) => setUserType(e.target.value)}
                  className="block w-full pl-10 pr-3 py-2.5 border border-gray-200 rounded-xl bg-gray-50/50 text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20 focus:border-[#002F6C] transition text-sm appearance-none cursor-pointer"
                >
                  <option value="Student">Student (Pelajar)</option>
                  <option value="Staff">Staff (Staf)</option>
                  <option value="Public">Public (Orang Awam)</option>
                </select>
                <span className="absolute inset-y-0 right-0 flex items-center pr-3 pointer-events-none text-gray-400">
                  ▼
                </span>
              </div>
            </div>

            {/* UPSI ID (hidden for Public) */}
            {userType !== 'Public' && (
              <div className="transition-all duration-300">
                <label className="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
                  UPSI ID (Matric / Staff Number)
                </label>
                <div className="relative">
                  <span className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-gray-400">
                    <CreditCard className="h-4 w-4" />
                  </span>
                  <input
                    type="text"
                    required
                    placeholder={userType === 'Student' ? 'D20211099999' : 'STAFF1234'}
                    value={upsiId}
                    onChange={(e) => setUpsiId(e.target.value)}
                    className="block w-full pl-10 pr-3 py-2.5 border border-gray-200 rounded-xl bg-gray-50/50 text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20 focus:border-[#002F6C] transition text-sm"
                  />
                </div>
              </div>
            )}

            {/* Submit Button */}
            <button
              type="submit"
              disabled={isLoading}
              className={`w-full py-3.5 px-4 rounded-xl text-white font-bold tracking-wide shadow-md transition-all flex items-center justify-center space-x-2 text-sm mt-6 ${
                isLoading 
                  ? 'bg-gray-400 cursor-not-allowed' 
                  : 'bg-[#002F6C] hover:bg-[#00204a] active:scale-95'
              }`}
            >
              {isLoading ? (
                <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
              ) : (
                <>
                  <span>Create Account</span>
                  <ArrowRight className="h-4 w-4" />
                </>
              )}
            </button>
          </form>

          {/* User Sign In Link */}
          <div className="mt-6 text-center text-sm text-gray-500">
            Already have an account?{' '}
            <Link to="/login" className="text-[#002F6C] font-bold hover:underline">
              Sign In
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
