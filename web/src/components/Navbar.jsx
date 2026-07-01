import React, { useState } from 'react';
import { Link, useLocation, useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { 
  Droplet, 
  Bell, 
  Menu, 
  X, 
  Home, 
  CalendarPlus, 
  Ticket, 
  MessageSquare, 
  User, 
  Shield, 
  LogOut, 
  LogIn 
} from 'lucide-react';

export default function Navbar() {
  const { user, profile, signOut, isAdmin } = useAuth();
  const location = useLocation();
  const navigate = useNavigate();
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  const handleLogout = async () => {
    try {
      await signOut();
      navigate('/login');
    } catch (error) {
      console.error('Error logging out:', error);
    }
  };

  const navLinks = [
    { name: 'Home', path: '/', icon: Home },
    { name: 'Book Slot', path: '/book-slot', icon: CalendarPlus, protected: true },
    { name: 'Tickets', path: '/tickets', icon: Ticket, protected: true },
    { name: 'Inbox', path: '/inbox', icon: MessageSquare, protected: true },
    { name: 'Profile', path: '/profile', icon: User, protected: true },
  ];

  const activeClass = (path) => 
    location.pathname === path 
      ? 'bg-[#C5A880]/15 text-[#C5A880] border-b-2 border-[#C5A880]' 
      : 'text-gray-300 hover:text-white hover:bg-white/5';

  const activeMobileClass = (path) => 
    location.pathname === path 
      ? 'bg-[#C5A880]/20 text-[#C5A880] border-l-4 border-[#C5A880] font-bold' 
      : 'text-gray-300 hover:text-white hover:bg-white/5';

  return (
    <nav className="bg-[#002F6C] shadow-lg sticky top-0 z-50">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Left: Logo and Brand */}
          <div className="flex items-center">
            <Link to="/" className="flex items-center space-x-2 text-white">
              <Droplet className="h-8 w-8 text-[#C5A880] fill-[#C5A880]" />
              <span className="font-outfit text-xl font-extrabold tracking-wide">
                e-Renang <span className="text-[#C5A880]">UPSI</span>
              </span>
            </Link>
          </div>

          {/* Center: Desktop Navigation links */}
          <div className="hidden md:flex space-x-1 items-center">
            {navLinks.map((link) => {
              if (link.protected && !user) return null;
              const Icon = link.icon;
              return (
                <Link
                  key={link.name}
                  to={link.path}
                  className={`flex items-center space-x-1 px-3 py-2 rounded-md text-sm font-medium transition-all duration-200 ${activeClass(link.path)}`}
                >
                  <Icon className="h-4 w-4" />
                  <span>{link.name}</span>
                </Link>
              );
            })}

            {/* Show Admin option if verified admin */}
            {user && isAdmin() && (
              <Link
                to="/admin"
                className={`flex items-center space-x-1 px-3 py-2 rounded-md text-sm font-medium transition-all duration-200 ${activeClass('/admin')}`}
              >
                <Shield className="h-4 w-4 text-[#C5A880]" />
                <span className="text-[#C5A880]">Admin Dashboard</span>
              </Link>
            )}
          </div>

          {/* Right: Notifications, Auth status, Profile icon */}
          <div className="hidden md:flex items-center space-x-4">
            {user ? (
              <div className="flex items-center space-x-4">
                {/* Notification Bell */}
                <button className="text-gray-300 hover:text-white p-1 rounded-full hover:bg-white/5 relative transition">
                  <Bell className="h-5 w-5 text-[#C5A880]" />
                  <span className="absolute top-0 right-0 h-2.5 w-2.5 rounded-full bg-red-500 ring-2 ring-[#002F6C]" />
                </button>

                {/* UPSI logo placeholder */}
                <div className="w-8 h-8 rounded-full bg-[#F1EAE0] flex items-center justify-center border border-[#C5A880] overflow-hidden">
                  <span className="text-[#002F6C] font-outfit text-xs font-bold">UPSI</span>
                </div>

                {/* User greeting and logout */}
                <div className="flex items-center space-x-2">
                  <span className="text-sm font-medium text-white max-w-[100px] truncate">
                    {profile?.name || user.email}
                  </span>
                  <button
                    onClick={handleLogout}
                    className="flex items-center space-x-1 bg-red-600/20 hover:bg-red-600 text-red-300 hover:text-white px-3 py-1.5 rounded-md text-xs font-semibold border border-red-500/30 transition-all"
                  >
                    <LogOut className="h-3.5 w-3.5" />
                    <span>Log Out</span>
                  </button>
                </div>
              </div>
            ) : (
              <div className="flex items-center space-x-2">
                <Link
                  to="/login"
                  className="flex items-center space-x-1 text-white hover:text-[#C5A880] px-3 py-2 rounded-md text-sm font-medium transition"
                >
                  <LogIn className="h-4 w-4" />
                  <span>Login</span>
                </Link>
                <Link
                  to="/register"
                  className="bg-[#C5A880] text-[#002F6C] hover:bg-[#b09268] px-4 py-2 rounded-md text-sm font-bold transition shadow-md"
                >
                  Register
                </Link>
              </div>
            )}
          </div>

          {/* Hamburger menu button */}
          <div className="flex md:hidden items-center">
            {user && (
              <button className="text-gray-300 hover:text-white mr-3 p-1 rounded-full hover:bg-white/5 relative transition">
                <Bell className="h-5 w-5 text-[#C5A880]" />
                <span className="absolute top-0 right-0 h-2 w-2 rounded-full bg-red-500" />
              </button>
            )}
            <button
              onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
              className="text-gray-300 hover:text-white p-2 rounded-md hover:bg-white/5 focus:outline-none"
            >
              {mobileMenuOpen ? <X className="h-6 w-6" /> : <Menu className="h-6 w-6" />}
            </button>
          </div>
        </div>
      </div>

      {/* Mobile Drawer Menu */}
      {mobileMenuOpen && (
        <div className="md:hidden bg-[#002B61] border-t border-white/5 transition-all">
          <div className="px-2 pt-2 pb-3 space-y-1 sm:px-3">
            {navLinks.map((link) => {
              if (link.protected && !user) return null;
              const Icon = link.icon;
              return (
                <Link
                  key={link.name}
                  to={link.path}
                  onClick={() => setMobileMenuOpen(false)}
                  className={`flex items-center space-x-3 px-3 py-3 rounded-md text-base font-medium transition-all ${activeMobileClass(link.path)}`}
                >
                  <Icon className="h-5 w-5" />
                  <span>{link.name}</span>
                </Link>
              );
            })}

            {/* Admin option */}
            {user && isAdmin() && (
              <Link
                to="/admin"
                onClick={() => setMobileMenuOpen(false)}
                className={`flex items-center space-x-3 px-3 py-3 rounded-md text-base font-medium transition-all ${activeMobileClass('/admin')}`}
              >
                <Shield className="h-5 w-5 text-[#C5A880]" />
                <span className="text-[#C5A880]">Admin Dashboard</span>
              </Link>
            )}

            {user ? (
              <div className="pt-4 pb-2 border-t border-white/10 mt-4">
                <div className="px-3 flex items-center justify-between mb-4">
                  <div>
                    <p className="text-sm font-medium text-white">{profile?.name || 'User'}</p>
                    <p className="text-xs text-gray-400">{user.email}</p>
                  </div>
                  <div className="w-8 h-8 rounded-full bg-[#F1EAE0] flex items-center justify-center border border-[#C5A880]">
                    <span className="text-[#002F6C] font-outfit text-xs font-bold">
                      {(profile?.name || 'U').charAt(0).toUpperCase()}
                    </span>
                  </div>
                </div>
                <button
                  onClick={() => {
                    setMobileMenuOpen(false);
                    handleLogout();
                  }}
                  className="w-full flex items-center justify-center space-x-2 bg-red-600/20 text-red-300 hover:bg-red-600 hover:text-white px-3 py-3 rounded-md text-sm font-bold border border-red-500/20 transition"
                >
                  <LogOut className="h-5 w-5" />
                  <span>Log Out Account</span>
                </button>
              </div>
            ) : (
              <div className="pt-4 border-t border-white/10 mt-4 flex flex-col space-y-2 px-3 pb-4">
                <Link
                  to="/login"
                  onClick={() => setMobileMenuOpen(false)}
                  className="w-full text-center py-2.5 rounded-md text-sm font-bold text-white border border-white/20 hover:bg-white/5 transition"
                >
                  Sign In
                </Link>
                <Link
                  to="/register"
                  onClick={() => setMobileMenuOpen(false)}
                  className="w-full text-center py-2.5 rounded-md text-sm font-bold bg-[#C5A880] text-[#002F6C] hover:bg-[#b09268] transition"
                >
                  Create Account
                </Link>
              </div>
            )}
          </div>
        </div>
      )}
    </nav>
  );
}
