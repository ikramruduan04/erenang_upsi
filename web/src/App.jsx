import React from 'react';
import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from './contexts/AuthContext';
import Navbar from './components/Navbar';

// Page Imports
import Home from './pages/Home';
import Login from './pages/Login';
import Register from './pages/Register';
import BookSlot from './pages/BookSlot';
import Tickets from './pages/Tickets';
import Inbox from './pages/Inbox';
import Profile from './pages/Profile';
import AdminDashboard from './pages/AdminDashboard';

// ─── Inline Protected Route Guard ─────────────────────────────────────────
function ProtectedRoute({ children }) {
  const { user, loading } = useAuth();

  if (loading) {
    return (
      <div className="min-h-screen bg-[#F4F6F9] flex items-center justify-center">
        <div className="w-10 h-10 border-4 border-[#002F6C] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  if (!user) {
    return <Navigate to="/login" replace />;
  }

  return children;
}

// ─── Inline Admin Route Guard ─────────────────────────────────────────────
function AdminRoute({ children }) {
  const { user, isAdmin, loading } = useAuth();

  if (loading) {
    return (
      <div className="min-h-screen bg-[#F4F6F9] flex items-center justify-center">
        <div className="w-10 h-10 border-4 border-[#002F6C] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  if (!user || !isAdmin()) {
    return <Navigate to="/" replace />;
  }

  return children;
}

export default function App() {
  return (
    <div className="flex flex-col min-h-screen bg-[#F4F6F9] font-outfit text-[#1E293B]">
      {/* Global Navbar */}
      <Navbar />

      {/* Main Content Layout */}
      <div className="flex-1 flex flex-col">
        <Routes>
          {/* Protected Root Route */}
          <Route 
            path="/" 
            element={
              <ProtectedRoute>
                <Home />
              </ProtectedRoute>
            } 
          />
          {/* Public Routes */}
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />

          {/* Protected Routes */}
          <Route 
            path="/book-slot" 
            element={
              <ProtectedRoute>
                <BookSlot />
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/tickets" 
            element={
              <ProtectedRoute>
                <Tickets />
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/inbox" 
            element={
              <ProtectedRoute>
                <Inbox />
              </ProtectedRoute>
            } 
          />
          <Route 
            path="/profile" 
            element={
              <ProtectedRoute>
                <Profile />
              </ProtectedRoute>
            } 
          />

          {/* Admin Protected Routes */}
          <Route 
            path="/admin" 
            element={
              <AdminRoute>
                <AdminDashboard />
              </AdminRoute>
            } 
          />

          {/* Catch-all Fallback */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </div>
    </div>
  );
}
