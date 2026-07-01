import React, { useState, useEffect } from 'react';
import { useAuth } from '../contexts/AuthContext';
import { MessageSquare, Calendar, RefreshCw, AlertCircle } from 'lucide-react';

export default function Inbox() {
  const { supabase, loading: authLoading } = useAuth();
  const [announcements, setAnnouncements] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');

  const fetchAnnouncements = async () => {
    setLoading(true);
    setError('');
    try {
      const { data, error: fetchErr } = await supabase
        .from('announcements')
        .select('*')
        .order('created_at', { ascending: false });

      if (fetchErr) throw fetchErr;
      setAnnouncements(data || []);
    } catch (err) {
      console.error('Error fetching announcements:', err);
      setError('Failed to fetch announcements. Please pull to refresh.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    if (!authLoading) {
      fetchAnnouncements();
    }
  }, [authLoading]);

  // Helper to format date and time ago
  const formatTimeAgo = (dateString) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffMs = now - date;
    const diffMins = Math.floor(diffMs / (1000 * 60));
    const diffHours = Math.floor(diffMs / (1000 * 60 * 60));
    const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));

    if (diffMins < 1) return 'Just now';
    if (diffMins < 60) return `${diffMins} min ago`;
    if (diffHours < 24) return `${diffHours} hours ago`;
    if (diffDays < 7) return `${diffDays} days ago`;
    
    // Return locale date string as fallback
    return date.toLocaleDateString('en-MY', {
      day: '2-digit',
      month: '2-digit',
      year: 'numeric'
    });
  };

  // Helper to check if announcement is created within 24 hours
  const isNew = (dateString) => {
    const date = new Date(dateString);
    const now = new Date();
    const diffMs = now - date;
    const diffHours = diffMs / (1000 * 60 * 60);
    return diffHours < 24;
  };

  if (loading && announcements.length === 0) {
    return (
      <div className="min-h-[70vh] flex items-center justify-center">
        <div className="w-10 h-10 border-4 border-[#002F6C] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#F4F6F9] py-8 font-outfit">
      <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
        {/* Header Section */}
        <div className="flex items-center justify-between mb-8">
          <div>
            <h1 className="text-3xl font-extrabold text-[#002F6C] tracking-tight">
              Announcements & Inbox
            </h1>
            <p className="text-sm text-gray-500 mt-1">
              Stay updated with pool operations, maintenance alerts, and events.
            </p>
          </div>
          <button
            onClick={fetchAnnouncements}
            className="flex items-center space-x-1.5 bg-[#002F6C] hover:bg-[#00204a] text-white px-4 py-2 rounded-xl text-sm font-semibold transition shadow-md"
          >
            <RefreshCw className="h-4 w-4" />
            <span>Refresh</span>
          </button>
        </div>

        {/* Error notification */}
        {error && (
          <div className="mb-6 flex items-center gap-3 bg-red-50 border-l-4 border-red-500 text-red-700 p-4 rounded-r-lg text-sm">
            <AlertCircle className="h-5 w-5 text-red-500 shrink-0" />
            <span>{error}</span>
          </div>
        )}

        {/* Main List */}
        {announcements.length === 0 ? (
          <div className="bg-white rounded-2xl border border-gray-100 shadow-sm p-12 text-center flex flex-col items-center">
            <div className="bg-[#002F6C]/5 p-5 rounded-full mb-4">
              <MessageSquare className="h-12 w-12 text-gray-400" />
            </div>
            <h3 className="text-lg font-bold text-[#002F6C]">No announcements yet</h3>
            <p className="text-sm text-gray-400 mt-1 max-w-xs mx-auto">
              We'll broadcast pool announcements, closures, or notices here.
            </p>
          </div>
        ) : (
          <div className="space-y-6">
            {announcements.map((item) => (
              <div 
                key={item.id}
                className="bg-white rounded-2xl border border-gray-100 shadow-sm hover:shadow-md transition p-6 relative overflow-hidden"
              >
                {/* Left accent bar */}
                <div className="absolute top-0 bottom-0 left-0 w-1.5 bg-[#002F6C]" />

                {/* Card Title & Badges */}
                <div className="flex items-start justify-between gap-4 mb-3 pl-2">
                  <div className="flex flex-wrap items-center gap-2">
                    <h2 className="text-lg font-bold text-gray-800 tracking-tight">
                      {item.title}
                    </h2>
                    {isNew(item.created_at) && (
                      <span className="bg-[#C5A880] text-[#002F6C] text-[10px] font-extrabold px-2 py-0.5 rounded-full uppercase tracking-wider">
                        New
                      </span>
                    )}
                  </div>
                  
                  {/* Timestamp */}
                  <div className="flex items-center space-x-1 text-xs text-gray-400 whitespace-nowrap">
                    <Calendar className="h-3.5 w-3.5" />
                    <span>{formatTimeAgo(item.created_at)}</span>
                  </div>
                </div>

                {/* Content Divider */}
                <hr className="border-gray-100 mb-4 pl-2" />

                {/* Body Content */}
                <div className="pl-2">
                  <p className="text-sm text-gray-600 leading-relaxed whitespace-pre-line">
                    {item.content}
                  </p>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  );
}
