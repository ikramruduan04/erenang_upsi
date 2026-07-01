import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { 
  LayoutDashboard, 
  PlusCircle, 
  RefreshCw, 
  MessageSquare, 
  LogOut, 
  Droplet,
  Bell,
  Menu,
  X,
  Calendar,
  Clock,
  Coins,
  Check,
  AlertTriangle,
  Trash2,
  Search,
  Plus,
  Edit,
  Trash,
  User,
  Ticket,
  Mail,
  ChevronDown
} from 'lucide-react';

const CATEGORIES = {
  'Staf & Pelajar UPSI': [
    { name: 'Pelajar UPSI', price: 0.0 },
    { name: 'Staf/SUKSIS/SISPA/PALAPES - Suami/Isteri', price: 3.0 },
    { name: 'Staf/SUKSIS/SISPA/PALAPES - Anak (0-7 tahun)', price: 0.0 },
    { name: 'Staf/SUKSIS/SISPA/PALAPES - Anak (8 tahun ke atas)', price: 3.0 },
    { name: 'Staf Holding/Sambilan/RA', price: 3.0 },
  ],
  'Orang Awam': [
    { name: 'Kanak-kanak (0-4 tahun)', price: 0.0 },
    { name: 'Kanak-kanak (5-7 tahun)', price: 1.0 },
    { name: 'Pelajar Sekolah & IPT (8-18 tahun)', price: 5.0 },
    { name: 'Dewasa', price: 10.0 },
    { name: 'Warga Emas (60 tahun ke atas)', price: 5.0 },
    { name: 'Pesara / Pencen Kerajaan', price: 5.0 },
    { name: 'OKU - Kanak-kanak (0-7 tahun)', price: 0.0 },
    { name: 'OKU - Kanak-kanak (8-17 tahun)', price: 3.0 },
    { name: 'OKU - Dewasa', price: 5.0 },
  ],
};

const POOLS = ['Kolam Utama', 'Kolam Renang Biasa', 'Kolam Kanak-Kanak'];

const TIME_SLOTS = [
  'Sesi Pagi (8.30 pg - 12.30 tghari)',
  'Sesi Petang (2.30 ptg - 6.30 ptg)',
  'Sesi Petang (3.00 ptg - 6.30 ptg)',
  'Sesi Petang - Ladies Day (2.30 ptg - 6.30 ptg)'
];

export default function AdminDashboard() {
  const { user, signOut, supabase, isAdmin } = useAuth();
  const navigate = useNavigate();

  // Sidebar and UI state
  const [mobileSidebarOpen, setMobileSidebarOpen] = useState(false);
  const [currentTab, setCurrentTab] = useState('dashboard'); // 'dashboard', 'announcements'
  const [isLoading, setIsLoading] = useState(false);

  // Data states
  const [bookings, setBookings] = useState([]);
  const [announcements, setAnnouncements] = useState([]);
  
  // Search & Filter states
  const [searchQuery, setSearchQuery] = useState('');
  const [statusFilter, setStatusFilter] = useState('All'); // All, Pending, Approved, Checked In, Cancelled

  // Stats
  const [stats, setStats] = useState({
    total: 0,
    pending: 0,
    inPool: 0,
    revenue: 0
  });

  // Modal / Dialog states
  const [isWalkInOpen, setIsWalkInOpen] = useState(false);
  const [isAnnouncementModalOpen, setIsAnnouncementModalOpen] = useState(false);
  const [editingAnnouncement, setEditingAnnouncement] = useState(null); // null if adding new

  // Manual Walk-in form states
  const [walkInName, setWalkInName] = useState('');
  const [walkInEmail, setWalkInEmail] = useState('');
  const [walkInPhone, setWalkInPhone] = useState('');
  const [walkInUpsiId, setWalkInUpsiId] = useState('');
  const [walkInGroup, setWalkInGroup] = useState('Orang Awam');
  const [walkInSubCategory, setWalkInSubCategory] = useState(CATEGORIES['Orang Awam'][0].name);
  const [walkInPool, setWalkInPool] = useState(POOLS[0]);
  const [walkInSlot, setWalkInSlot] = useState(TIME_SLOTS[0]);
  const [walkInDate, setWalkInDate] = useState(new Date().toISOString().split('T')[0]);
  const [walkInQuantity, setWalkInQuantity] = useState(1);
  const [walkInNotes, setWalkInNotes] = useState('');
  const [walkInFeedback, setWalkInFeedback] = useState('');

  // Announcement form states
  const [annTitle, setAnnTitle] = useState('');
  const [annContent, setAnnContent] = useState('');
  const [annFeedback, setAnnFeedback] = useState('');

  // Check admin role or redirect
  useEffect(() => {
    if (!isAdmin()) {
      navigate('/');
    } else {
      fetchData();
    }
  }, [user]);

  const fetchData = async () => {
    setIsLoading(true);
    try {
      await Promise.all([fetchBookings(), fetchAnnouncements()]);
    } catch (error) {
      console.error('Error fetching data:', error);
    } finally {
      setIsLoading(false);
    }
  };

  const fetchBookings = async () => {
    try {
      const { data, error } = await supabase
        .from('bookings')
        .select('*')
        .order('booking_date', { ascending: false });

      if (error) throw error;
      setBookings(data || []);
      calculateStats(data || []);
    } catch (err) {
      console.error('Error fetching bookings:', err);
    }
  };

  const fetchAnnouncements = async () => {
    try {
      const { data, error } = await supabase
        .from('announcements')
        .select('*')
        .order('created_at', { ascending: false });

      if (error) throw error;
      setAnnouncements(data || []);
    } catch (err) {
      console.error('Error fetching announcements:', err);
    }
  };

  const calculateStats = (bookingsList) => {
    const total = bookingsList.length;
    const pending = bookingsList.filter(b => b.status === 'Pending').length;
    const inPool = bookingsList.filter(b => b.status === 'Checked In').length;
    
    // Revenue sum from bookings not cancelled
    const revenue = bookingsList
      .filter(b => b.status !== 'Cancelled')
      .reduce((sum, b) => sum + (b.total_price || 0), 0);

    setStats({ total, pending, inPool, revenue });
  };

  const handleUpdateStatus = async (bookingId, newStatus) => {
    try {
      const { error } = await supabase
        .from('bookings')
        .update({ status: newStatus })
        .eq('id', bookingId);

      if (error) throw error;
      fetchBookings();
    } catch (err) {
      console.error('Error updating booking status:', err);
      alert('Failed to update booking status.');
    }
  };

  const handleDeleteBooking = async (bookingId) => {
    if (!window.confirm('Are you sure you want to delete this booking?')) return;
    try {
      const { error } = await supabase
        .from('bookings')
        .delete()
        .eq('id', bookingId);

      if (error) throw error;
      fetchBookings();
    } catch (err) {
      console.error('Error deleting booking:', err);
      alert('Failed to delete booking.');
    }
  };

  const handleCreateWalkIn = async (e) => {
    e.preventDefault();
    setWalkInFeedback('');

    if (walkInGroup !== 'Public' && !walkInUpsiId.trim()) {
      setWalkInFeedback('UPSI ID is required for Students/Staff.');
      return;
    }

    try {
      const subcatObj = CATEGORIES[walkInGroup].find(c => c.name === walkInSubCategory);
      const pricePerTicket = subcatObj ? subcatObj.price : 0;
      const totalPrice = pricePerTicket * walkInQuantity;

      // Unique walkin ID placeholder
      const tempId = Math.random().toString(36).substr(2, 9).toUpperCase();
      const qrCode = `UP-${tempId}-WALKIN`;

      const newBooking = {
        name: walkInName,
        email: walkInEmail || null,
        phone: walkInPhone || null,
        upsi_id: walkInGroup === 'Public' ? '' : walkInUpsiId,
        user_type: walkInGroup === 'Staf & Pelajar UPSI' ? 'Staf & Pelajar UPSI' : 'Orang Awam',
        sub_category: walkInSubCategory,
        pool_type: walkInPool,
        booking_date: walkInDate,
        time_slot: walkInSlot,
        quantity: walkInQuantity,
        total_price: totalPrice,
        status: 'Approved', // Auto-approved for walkins
        qr_code: qrCode,
        notes: walkInNotes || 'Pendaftaran Walk-in oleh operator.'
      };

      const { error } = await supabase
        .from('bookings')
        .insert(newBooking);

      if (error) throw error;

      setIsWalkInOpen(false);
      // Reset form
      setWalkInName('');
      setWalkInEmail('');
      setWalkInPhone('');
      setWalkInUpsiId('');
      setWalkInNotes('');
      setWalkInQuantity(1);
      
      fetchBookings();
      alert('Walk-in booking created successfully!');
    } catch (err) {
      console.error('Error creating walk-in:', err);
      setWalkInFeedback(err.message || 'Failed to create walk-in booking.');
    }
  };

  const handleSaveAnnouncement = async (e) => {
    e.preventDefault();
    setAnnFeedback('');

    try {
      if (editingAnnouncement) {
        // Edit mode
        const { error } = await supabase
          .from('announcements')
          .update({
            title: annTitle,
            content: annContent
          })
          .eq('id', editingAnnouncement.id);

        if (error) throw error;
      } else {
        // Create mode
        const { error } = await supabase
          .from('announcements')
          .insert({
            title: annTitle,
            content: annContent,
            created_by: user.id
          });

        if (error) throw error;
      }

      setIsAnnouncementModalOpen(false);
      setAnnTitle('');
      setAnnContent('');
      setEditingAnnouncement(null);
      fetchAnnouncements();
    } catch (err) {
      console.error('Error saving announcement:', err);
      setAnnFeedback(err.message || 'Failed to save announcement.');
    }
  };

  const handleDeleteAnnouncement = async (id) => {
    if (!window.confirm('Delete this announcement?')) return;
    try {
      const { error } = await supabase
        .from('announcements')
        .delete()
        .eq('id', id);

      if (error) throw error;
      fetchAnnouncements();
    } catch (err) {
      console.error('Error deleting announcement:', err);
      alert('Failed to delete announcement.');
    }
  };

  const handleLogout = async () => {
    try {
      await signOut();
      navigate('/login');
    } catch (error) {
      console.error('Error logging out:', error);
    }
  };

  // Filter Bookings logic
  const filteredBookings = bookings.filter(b => {
    const matchesStatus = statusFilter === 'All' || b.status === statusFilter;
    
    const searchLower = searchQuery.toLowerCase();
    const matchesSearch = 
      (b.name || '').toLowerCase().includes(searchLower) ||
      (b.email || '').toLowerCase().includes(searchLower) ||
      (b.upsi_id || '').toLowerCase().includes(searchLower) ||
      (b.id || '').toLowerCase().includes(searchLower);

    return matchesStatus && matchesSearch;
  });

  // Calculate current price for manual walkin
  const currentWalkInPrice = () => {
    const subcatObj = CATEGORIES[walkInGroup]?.find(c => c.name === walkInSubCategory);
    const pricePer = subcatObj ? subcatObj.price : 0;
    return pricePer * walkInQuantity;
  };

  const sidebar = (
    <div className="flex flex-col h-full bg-[#002F6C] text-white p-4 font-outfit justify-between">
      <div className="space-y-6">
        {/* Title */}
        <div className="flex items-center space-x-2 py-4 px-2">
          <Droplet className="h-8 w-8 text-[#C5A880] fill-[#C5A880]" />
          <div>
            <h1 className="text-lg font-black tracking-wider uppercase">e-Renang Admin</h1>
            <p className="text-xs text-gray-400">Pool Operations Portal</p>
          </div>
        </div>

        {/* Navigation items */}
        <div className="space-y-2">
          <button
            onClick={() => {
              setCurrentTab('dashboard');
              setMobileSidebarOpen(false);
            }}
            className={`w-full flex items-center space-x-3 px-4 py-3 rounded-xl transition ${
              currentTab === 'dashboard'
                ? 'bg-[#C5A880]/20 text-[#C5A880] font-bold border-l-4 border-[#C5A880]'
                : 'text-gray-300 hover:text-white hover:bg-white/5'
            }`}
          >
            <LayoutDashboard className="h-5 w-5" />
            <span>Dashboard</span>
          </button>

          <button
            onClick={() => {
              setIsWalkInOpen(true);
              setMobileSidebarOpen(false);
            }}
            className="w-full flex items-center space-x-3 px-4 py-3 text-gray-300 hover:text-white hover:bg-white/5 rounded-xl transition"
          >
            <PlusCircle className="h-5 w-5 text-green-400" />
            <span>Manual Walk-In</span>
          </button>

          <button
            onClick={fetchData}
            className="w-full flex items-center space-x-3 px-4 py-3 text-gray-300 hover:text-white hover:bg-white/5 rounded-xl transition"
          >
            <RefreshCw className="h-5 w-5 text-blue-400" />
            <span>Sync & Refresh</span>
          </button>

          <button
            onClick={() => {
              setCurrentTab('announcements');
              setMobileSidebarOpen(false);
            }}
            className={`w-full flex items-center space-x-3 px-4 py-3 rounded-xl transition ${
              currentTab === 'announcements'
                ? 'bg-[#C5A880]/20 text-[#C5A880] font-bold border-l-4 border-[#C5A880]'
                : 'text-gray-300 hover:text-white hover:bg-white/5'
            }`}
          >
            <MessageSquare className="h-5 w-5" />
            <span>Manage Inbox</span>
          </button>
        </div>
      </div>

      {/* Logout */}
      <button
        onClick={handleLogout}
        className="flex items-center space-x-3 px-4 py-3.5 bg-red-600/10 border border-red-500/20 text-red-300 hover:bg-red-600 hover:text-white rounded-xl transition font-semibold"
      >
        <LogOut className="h-5 w-5" />
        <span>Log Out Operator</span>
      </button>
    </div>
  );

  return (
    <div className="min-h-screen bg-[#F4F6F9] flex font-outfit">
      
      {/* Sidebar - Desktop */}
      <div className="hidden lg:block w-64 shrink-0 bg-[#002F6C] min-h-screen sticky top-0 shadow-lg z-20">
        {sidebar}
      </div>

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0">
        
        {/* Top Header Bar */}
        <header className="bg-white border-b border-gray-100 sticky top-0 z-10 px-4 sm:px-6 lg:px-8 py-4 shadow-sm flex items-center justify-between">
          <div className="flex items-center space-x-3">
            {/* Hamburger on mobile */}
            <button
              onClick={() => setMobileSidebarOpen(true)}
              className="lg:hidden p-2 rounded-lg text-gray-500 hover:text-gray-600 hover:bg-gray-100"
            >
              <Menu className="h-6 w-6" />
            </button>
            <h2 className="text-xl font-extrabold text-[#002F6C]">
              {currentTab === 'dashboard' ? 'Booking Overview' : 'Manage Announcements'}
            </h2>
          </div>

          {/* User Details & UPSI Logo */}
          <div className="flex items-center space-x-4">
            <span className="hidden sm:inline-block text-xs font-semibold text-gray-500 bg-gray-100 px-3 py-1 rounded-full uppercase tracking-wider">
              Operator
            </span>
            <div className="w-8 h-8 rounded-full bg-[#002F6C] flex items-center justify-center border border-[#C5A880] overflow-hidden">
              <span className="text-white text-xs font-bold font-outfit">OP</span>
            </div>
          </div>
        </header>

        {/* Dashboard Tab Content */}
        {currentTab === 'dashboard' && (
          <main className="flex-grow p-4 sm:p-6 lg:p-8 space-y-6">
            
            {/* Stats Cards Row */}
            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
              
              {/* Total Bookings */}
              <div className="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm flex items-center gap-4">
                <div className="bg-blue-50 text-blue-600 p-3 rounded-xl">
                  <Calendar className="h-6 w-6" />
                </div>
                <div>
                  <p className="text-xs text-gray-400 font-bold uppercase tracking-wider">Total Bookings</p>
                  <p className="text-2xl font-black text-gray-800">{stats.total}</p>
                </div>
              </div>

              {/* Pending Bookings */}
              <div className="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm flex items-center gap-4">
                <div className="bg-orange-50 text-orange-600 p-3 rounded-xl">
                  <Clock className="h-6 w-6" />
                </div>
                <div>
                  <p className="text-xs text-gray-400 font-bold uppercase tracking-wider">Pending Requests</p>
                  <p className="text-2xl font-black text-gray-800">{stats.pending}</p>
                </div>
              </div>

              {/* Swimmers Checked-in */}
              <div className="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm flex items-center gap-4">
                <div className="bg-teal-50 text-teal-600 p-3 rounded-xl">
                  <Droplet className="h-6 w-6" />
                </div>
                <div>
                  <p className="text-xs text-gray-400 font-bold uppercase tracking-wider">In Pool Now</p>
                  <p className="text-2xl font-black text-gray-800">{stats.inPool}</p>
                </div>
              </div>

              {/* Revenue */}
              <div className="bg-white rounded-2xl p-5 border border-gray-100 shadow-sm flex items-center gap-4">
                <div className="bg-green-50 text-green-600 p-3 rounded-xl">
                  <Coins className="h-6 w-6" />
                </div>
                <div>
                  <p className="text-xs text-gray-400 font-bold uppercase tracking-wider">Total Revenue</p>
                  <p className="text-2xl font-black text-gray-800">RM {stats.revenue.toFixed(2)}</p>
                </div>
              </div>

            </div>

            {/* Booking Manager Panel */}
            <div className="bg-white rounded-3xl border border-gray-100 shadow-sm p-6">
              
              {/* Toolbar */}
              <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 mb-6">
                <h3 className="text-lg font-black text-[#002F6C] tracking-wide">
                  Booking Manager ({filteredBookings.length})
                </h3>

                {/* Filter and Search */}
                <div className="flex flex-col sm:flex-row gap-3">
                  {/* Search Input */}
                  <div className="relative">
                    <Search className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400 h-4 w-4" />
                    <input
                      type="text"
                      placeholder="Search name, ID, email..."
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      className="pl-9 pr-4 py-2 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20 w-full sm:w-56"
                    />
                  </div>

                  {/* Status Dropdown */}
                  <select
                    value={statusFilter}
                    onChange={(e) => setStatusFilter(e.target.value)}
                    className="px-3 py-2 border border-gray-200 rounded-xl text-sm focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20 bg-white"
                  >
                    <option value="All">All Statuses</option>
                    <option value="Pending">Pending</option>
                    <option value="Approved">Approved</option>
                    <option value="Checked In">Checked In</option>
                    <option value="Cancelled">Cancelled</option>
                  </select>
                </div>
              </div>

              {/* Bookings List */}
              {isLoading ? (
                <div className="py-12 flex justify-center">
                  <div className="w-8 h-8 border-3 border-[#002F6C] border-t-transparent rounded-full animate-spin" />
                </div>
              ) : filteredBookings.length === 0 ? (
                <div className="text-center py-12 text-gray-400">
                  <Calendar className="h-12 w-12 mx-auto mb-3 opacity-30" />
                  <p className="font-bold text-sm">No bookings found matching filters</p>
                </div>
              ) : (
                <div className="space-y-4">
                  {filteredBookings.map((booking) => {
                    let badgeColor = 'bg-gray-100 text-gray-800';
                    if (booking.status === 'Pending') badgeColor = 'bg-orange-50 text-orange-700 border border-orange-200';
                    if (booking.status === 'Approved') badgeColor = 'bg-green-50 text-green-700 border border-green-200';
                    if (booking.status === 'Checked In') badgeColor = 'bg-blue-50 text-blue-700 border border-blue-200';
                    if (booking.status === 'Cancelled') badgeColor = 'bg-red-50 text-red-700 border border-red-200';

                    return (
                      <div 
                        key={booking.id} 
                        className="border border-gray-100 rounded-2xl p-5 hover:bg-gray-50/50 transition flex flex-col md:flex-row justify-between items-start md:items-center gap-4"
                      >
                        {/* Booking Detail Left */}
                        <div className="space-y-2">
                          <div className="flex flex-wrap items-center gap-2">
                            <span className="font-bold text-gray-800 text-base">{booking.name}</span>
                            <span className="bg-gray-100 text-gray-600 text-[10px] font-bold px-2 py-0.5 rounded-full uppercase">
                              {booking.sub_category}
                            </span>
                            <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full uppercase ${badgeColor}`}>
                              {booking.status}
                            </span>
                          </div>
                          
                          <div className="grid grid-cols-1 sm:grid-cols-2 gap-x-6 gap-y-1 text-xs text-gray-500">
                            <p><span className="font-semibold text-gray-400">Date:</span> {booking.booking_date}</p>
                            <p><span className="font-semibold text-gray-400">Slot:</span> {booking.time_slot}</p>
                            <p><span className="font-semibold text-gray-400">Pool:</span> {booking.pool_type}</p>
                            <p><span className="font-semibold text-gray-400">ID/Email:</span> {booking.upsi_id || booking.email || 'N/A'}</p>
                            <p><span className="font-semibold text-gray-400">Ticket QR:</span> {booking.qr_code}</p>
                            <p><span className="font-semibold text-gray-400">Qty:</span> {booking.quantity} (Total: RM {booking.total_price?.toFixed(2)})</p>
                          </div>
                        </div>

                        {/* Actions Right */}
                        <div className="flex flex-wrap gap-2 w-full md:w-auto justify-end">
                          
                          {/* Pending actions */}
                          {booking.status === 'Pending' && (
                            <>
                              <button
                                onClick={() => handleUpdateStatus(booking.id, 'Approved')}
                                className="bg-[#002F6C] hover:bg-[#00204a] text-white px-4 py-2 rounded-xl text-xs font-bold transition shadow-sm"
                              >
                                Approve
                              </button>
                              <button
                                onClick={() => handleUpdateStatus(booking.id, 'Cancelled')}
                                className="border border-red-200 text-red-600 hover:bg-red-50 px-4 py-2 rounded-xl text-xs font-bold transition"
                              >
                                Cancel
                              </button>
                            </>
                          )}

                          {/* Approved actions */}
                          {booking.status === 'Approved' && (
                            <>
                              <button
                                onClick={() => handleUpdateStatus(booking.id, 'Checked In')}
                                className="bg-teal-600 hover:bg-teal-700 text-white px-4 py-2 rounded-xl text-xs font-bold transition shadow-sm"
                              >
                                Check In
                              </button>
                              <button
                                onClick={() => handleUpdateStatus(booking.id, 'Cancelled')}
                                className="border border-red-200 text-red-600 hover:bg-red-50 px-4 py-2 rounded-xl text-xs font-bold transition"
                              >
                                Cancel
                              </button>
                            </>
                          )}

                          {/* Trash button */}
                          <button
                            onClick={() => handleDeleteBooking(booking.id)}
                            className="bg-red-50 hover:bg-red-100 text-red-600 p-2 rounded-xl border border-red-100 transition"
                            title="Delete Booking Record"
                          >
                            <Trash2 className="h-4 w-4" />
                          </button>
                        </div>
                      </div>
                    );
                  })}
                </div>
              )}

            </div>

          </main>
        )}

        {/* Announcements Tab Content */}
        {currentTab === 'announcements' && (
          <main className="flex-grow p-4 sm:p-6 lg:p-8 space-y-6">
            
            <div className="bg-white rounded-3xl border border-gray-100 shadow-sm p-6">
              <div className="flex justify-between items-center mb-6">
                <h3 className="text-lg font-black text-[#002F6C] tracking-wide">
                  Inbox Broadcast Manager ({announcements.length})
                </h3>
                <button
                  onClick={() => {
                    setEditingAnnouncement(null);
                    setAnnTitle('');
                    setAnnContent('');
                    setIsAnnouncementModalOpen(true);
                  }}
                  className="bg-[#C5A880] hover:bg-[#b09268] text-[#002F6C] font-bold px-4 py-2 rounded-xl text-sm flex items-center gap-1.5 transition shadow-sm"
                >
                  <Plus className="h-4 w-4" />
                  <span>New Announcement</span>
                </button>
              </div>

              {/* Announcement List */}
              {isLoading ? (
                <div className="py-12 flex justify-center">
                  <div className="w-8 h-8 border-3 border-[#002F6C] border-t-transparent rounded-full animate-spin" />
                </div>
              ) : announcements.length === 0 ? (
                <div className="text-center py-12 text-gray-400">
                  <MessageSquare className="h-12 w-12 mx-auto mb-3 opacity-30" />
                  <p className="font-bold text-sm">No announcements broadcasted yet</p>
                </div>
              ) : (
                <div className="space-y-4">
                  {announcements.map((ann) => (
                    <div 
                      key={ann.id} 
                      className="border border-gray-100 rounded-2xl p-5 flex justify-between items-start gap-4 hover:bg-gray-50/50 transition"
                    >
                      <div className="space-y-1.5 flex-1 min-w-0">
                        <h4 className="font-extrabold text-gray-800 text-sm truncate">{ann.title}</h4>
                        <p className="text-xs text-gray-400">Posted on: {new Date(ann.created_at).toLocaleString()}</p>
                        <p className="text-xs text-gray-600 line-clamp-3 leading-relaxed whitespace-pre-line mt-2">{ann.content}</p>
                      </div>

                      <div className="flex gap-2">
                        <button
                          onClick={() => {
                            setEditingAnnouncement(ann);
                            setAnnTitle(ann.title);
                            setAnnContent(ann.content);
                            setIsAnnouncementModalOpen(true);
                          }}
                          className="bg-blue-50 text-blue-600 p-2 rounded-xl border border-blue-100 hover:bg-blue-100 transition"
                          title="Edit"
                        >
                          <Edit className="h-4 w-4" />
                        </button>
                        <button
                          onClick={() => handleDeleteAnnouncement(ann.id)}
                          className="bg-red-50 text-red-600 p-2 rounded-xl border border-red-100 hover:bg-red-100 transition"
                          title="Delete"
                        >
                          <Trash className="h-4 w-4" />
                        </button>
                      </div>
                    </div>
                  ))}
                </div>
              )}

            </div>

          </main>
        )}

      </div>

      {/* Slide-out Mobile Sidebar Drawer */}
      {mobileSidebarOpen && (
        <div className="fixed inset-0 z-40 lg:hidden">
          {/* Backdrop */}
          <div 
            onClick={() => setMobileSidebarOpen(false)}
            className="fixed inset-0 bg-black/50" 
          />
          {/* Drawer content */}
          <div className="fixed inset-y-0 left-0 w-64 bg-[#002F6C] shadow-xl z-50 transform transition duration-300">
            {sidebar}
          </div>
        </div>
      )}

      {/* Manual Walk-In Dialog Modal */}
      {isWalkInOpen && (
        <div className="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4 overflow-y-auto animate-fadeIn">
          <div className="bg-white rounded-3xl w-full max-w-lg shadow-2xl overflow-hidden my-8">
            
            {/* Modal Header */}
            <div className="bg-[#002F6C] px-6 py-4 flex items-center justify-between text-white">
              <div>
                <h3 className="text-lg font-bold">Manual Walk-in Registration</h3>
                <p className="text-xs text-white/70">Register swimmer on-the-spot</p>
              </div>
              <button 
                onClick={() => setIsWalkInOpen(false)}
                className="text-white/80 hover:text-white transition"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            {/* Modal Form */}
            <form onSubmit={handleCreateWalkIn} className="p-6 space-y-4 max-h-[70vh] overflow-y-auto">
              
              {walkInFeedback && (
                <div className="p-3 bg-red-50 border border-red-200 text-red-700 rounded-xl text-xs font-medium flex items-center gap-2">
                  <AlertTriangle className="h-4 w-4 shrink-0 text-red-500" />
                  <span>{walkInFeedback}</span>
                </div>
              )}

              {/* Swimmer Name */}
              <div>
                <label className="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
                  Swimmer Full Name
                </label>
                <input
                  type="text"
                  required
                  placeholder="Swimmer Name"
                  value={walkInName}
                  onChange={(e) => setWalkInName(e.target.value)}
                  className="w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-gray-50 text-sm focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20"
                />
              </div>

              {/* Optional Fields (Email, Phone) */}
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
                    Email (Optional)
                  </label>
                  <input
                    type="email"
                    placeholder="email@example.com"
                    value={walkInEmail}
                    onChange={(e) => setWalkInEmail(e.target.value)}
                    className="w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-gray-50 text-sm focus:outline-none"
                  />
                </div>
                <div>
                  <label className="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
                    Phone (Optional)
                  </label>
                  <input
                    type="text"
                    placeholder="+6012345678"
                    value={walkInPhone}
                    onChange={(e) => setWalkInPhone(e.target.value)}
                    className="w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-gray-50 text-sm focus:outline-none"
                  />
                </div>
              </div>

              {/* Group Category */}
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
                    Category Group
                  </label>
                  <select
                    value={walkInGroup}
                    disabled
                    className="w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-gray-100 text-gray-400 text-sm focus:outline-none cursor-not-allowed"
                  >
                    <option value="Orang Awam">Orang Awam</option>
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
                    Ticket Type
                  </label>
                  <select
                    value={walkInSubCategory}
                    onChange={(e) => setWalkInSubCategory(e.target.value)}
                    className="w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-white text-sm focus:outline-none"
                  >
                    {CATEGORIES[walkInGroup].map((cat) => (
                      <option key={cat.name} value={cat.name}>
                        {cat.name} (RM {cat.price.toFixed(2)})
                      </option>
                    ))}
                  </select>
                </div>
              </div>

              {/* Matric / Staff ID */}
              {walkInGroup !== 'Orang Awam' && (
                <div>
                  <label className="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
                    UPSI ID (Matric / Staff Number)
                  </label>
                  <input
                    type="text"
                    required
                    placeholder="Matric/Staff ID"
                    value={walkInUpsiId}
                    onChange={(e) => setWalkInUpsiId(e.target.value)}
                    className="w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-gray-50 text-sm focus:outline-none"
                  />
                </div>
              )}

              {/* Pool & Session */}
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
                    Pool Section
                  </label>
                  <select
                    value={walkInPool}
                    onChange={(e) => setWalkInPool(e.target.value)}
                    className="w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-white text-sm focus:outline-none"
                  >
                    {POOLS.map((p) => (
                      <option key={p} value={p}>{p}</option>
                    ))}
                  </select>
                </div>

                <div>
                  <label className="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
                    Time Session
                  </label>
                  <select
                    value={walkInSlot}
                    onChange={(e) => setWalkInSlot(e.target.value)}
                    className="w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-white text-sm focus:outline-none"
                  >
                    {TIME_SLOTS.map((s) => (
                      <option key={s} value={s}>{s}</option>
                    ))}
                  </select>
                </div>
              </div>

              {/* Booking Date & Ticket Quantity */}
              <div className="grid grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
                    Booking Date
                  </label>
                  <input
                    type="date"
                    required
                    value={walkInDate}
                    onChange={(e) => setWalkInDate(e.target.value)}
                    className="w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-white text-sm focus:outline-none"
                  />
                </div>

                <div>
                  <label className="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
                    Slots / Swimmers Quantity
                  </label>
                  <input
                    type="number"
                    min="1"
                    max="2"
                    required
                    value={walkInQuantity}
                    onChange={(e) => setWalkInQuantity(Math.min(2, parseInt(e.target.value) || 1))}
                    className="w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-white text-sm focus:outline-none"
                  />
                </div>
              </div>

              {/* Notes */}
              <div>
                <label className="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
                  Remarks / Catatan
                </label>
                <textarea
                  rows="2"
                  placeholder="Catatan pendaftaran"
                  value={walkInNotes}
                  onChange={(e) => setWalkInNotes(e.target.value)}
                  className="w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-gray-50 text-sm focus:outline-none"
                />
              </div>

              {/* Cost Calculations & Actions */}
              <div className="border-t border-gray-100 pt-4 flex items-center justify-between">
                <div>
                  <p className="text-xs text-gray-400 font-bold uppercase">Calculated Total</p>
                  <p className="text-xl font-black text-[#002F6C]">RM {currentWalkInPrice().toFixed(2)}</p>
                </div>
                <div className="flex gap-2">
                  <button
                    type="button"
                    onClick={() => setIsWalkInOpen(false)}
                    className="px-4 py-2.5 border border-gray-200 rounded-xl text-sm font-semibold text-gray-600 hover:bg-gray-50 transition"
                  >
                    Cancel
                  </button>
                  <button
                    type="submit"
                    className="bg-green-600 hover:bg-green-700 text-white px-5 py-2.5 rounded-xl text-sm font-bold transition shadow-md"
                  >
                    Register & Check In
                  </button>
                </div>
              </div>

            </form>
          </div>
        </div>
      )}

      {/* Announcement Modals */}
      {isAnnouncementModalOpen && (
        <div className="fixed inset-0 bg-black/60 z-50 flex items-center justify-center p-4 animate-fadeIn">
          <div className="bg-white rounded-3xl w-full max-w-md overflow-hidden shadow-2xl">
            <div className="bg-[#002F6C] px-6 py-4 flex items-center justify-between text-white">
              <h3 className="text-lg font-bold">
                {editingAnnouncement ? 'Edit Announcement' : 'Compose New Announcement'}
              </h3>
              <button 
                onClick={() => setIsAnnouncementModalOpen(false)}
                className="text-white/80 hover:text-white transition"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            <form onSubmit={handleSaveAnnouncement} className="p-6 space-y-4">
              {annFeedback && (
                <div className="p-3 bg-red-50 text-red-700 rounded-xl text-xs font-semibold">
                  {annFeedback}
                </div>
              )}

              <div>
                <label className="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
                  Title
                </label>
                <input
                  type="text"
                  required
                  placeholder="e.g. Pool Maintenance Notice"
                  value={annTitle}
                  onChange={(e) => setAnnTitle(e.target.value)}
                  className="w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-gray-50 text-sm focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20"
                />
              </div>

              <div>
                <label className="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
                  Content Body
                </label>
                <textarea
                  rows="5"
                  required
                  placeholder="Announcement details..."
                  value={annContent}
                  onChange={(e) => setAnnContent(e.target.value)}
                  className="w-full px-3.5 py-2.5 border border-gray-200 rounded-xl bg-gray-50 text-sm focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20"
                />
              </div>

              <div className="flex gap-3 pt-2">
                <button
                  type="button"
                  onClick={() => setIsAnnouncementModalOpen(false)}
                  className="w-1/2 border border-gray-200 py-3 rounded-xl text-gray-600 hover:bg-gray-50 transition text-sm font-semibold"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  className="w-1/2 bg-[#002F6C] hover:bg-[#00204a] text-white py-3 rounded-xl transition text-sm font-semibold"
                >
                  {editingAnnouncement ? 'Save Changes' : 'Broadcast'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

    </div>
  );
}
