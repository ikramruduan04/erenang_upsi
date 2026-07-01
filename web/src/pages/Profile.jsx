import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { useAuth } from '../contexts/AuthContext';
import { 
  User, 
  Mail, 
  Phone, 
  GraduationCap, 
  CheckSquare, 
  Coins, 
  ChevronRight, 
  HelpCircle, 
  FileText, 
  LogOut, 
  Edit3,
  X,
  CheckCircle,
  AlertCircle
} from 'lucide-react';

export default function Profile() {
  const { user, profile, signOut, supabase } = useAuth();
  const navigate = useNavigate();

  const [sessionCount, setSessionCount] = useState(0);
  const [loading, setLoading] = useState(true);
  const [isEditModalOpen, setIsEditModalOpen] = useState(false);
  
  // Edit Form Fields
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [upsiId, setUpsiId] = useState('');
  const [submitting, setSubmitting] = useState(false);
  const [feedback, setFeedback] = useState({ type: '', message: '' });

  useEffect(() => {
    if (profile) {
      setName(profile.name || '');
      setPhone(profile.phone || '');
      setUpsiId(profile.upsi_id || '');
      fetchSessionCount();
    }
  }, [profile]);

  const fetchSessionCount = async () => {
    if (!user) return;
    try {
      const { data, error } = await supabase
        .from('bookings')
        .select('id')
        .eq('user_id', user.id)
        .eq('status', 'Checked In');

      if (error) throw error;
      setSessionCount(data?.length || 0);
    } catch (err) {
      console.error('Error fetching session count:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleUpdateProfile = async (e) => {
    e.preventDefault();
    setSubmitting(true);
    setFeedback({ type: '', message: '' });

    try {
      const { error } = await supabase
        .from('profiles')
        .update({
          name,
          phone,
          upsi_id: profile.user_type === 'Public' ? '' : upsiId
        })
        .eq('id', user.id);

      if (error) throw error;

      // Update auth user metadata for consistency
      await supabase.auth.updateUser({
        data: {
          name,
          upsi_id: profile.user_type === 'Public' ? '' : upsiId
        }
      });

      setFeedback({ type: 'success', message: 'Profile updated successfully!' });
      setTimeout(() => {
        setIsEditModalOpen(false);
        // Refresh page / profile context state will update automatically via subscription in AuthContext
        window.location.reload();
      }, 1500);

    } catch (err) {
      console.error('Error updating profile:', err);
      setFeedback({ type: 'error', message: err.message || 'Failed to update profile.' });
    } finally {
      setSubmitting(false);
    }
  };

  const handleLogout = async () => {
    try {
      await signOut();
      navigate('/login');
    } catch (err) {
      console.error('Logout error:', err);
    }
  };

  if (!profile) {
    return (
      <div className="min-h-[70vh] flex items-center justify-center">
        <div className="w-10 h-10 border-4 border-[#002F6C] border-t-transparent rounded-full animate-spin" />
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-[#F4F6F9] py-8 font-outfit">
      <div className="max-w-3xl mx-auto px-4 sm:px-6">
        
        {/* Profile Card Header */}
        <div className="bg-white rounded-3xl shadow-sm border border-gray-100 p-6 md:p-8 mb-6">
          <div className="flex flex-col md:flex-row items-center md:items-start text-center md:text-left gap-6">
            
            {/* Avatar Circle */}
            <div className="w-24 h-24 rounded-full bg-[#002F6C] border-4 border-[#C5A880] flex items-center justify-center text-white text-3xl font-extrabold shadow-md">
              {(profile.name || 'U').charAt(0).toUpperCase()}
            </div>

            {/* User Details */}
            <div className="flex-1 space-y-2.5">
              <div className="flex flex-col md:flex-row items-center gap-2">
                <h1 className="text-2xl font-extrabold text-[#002F6C]">{profile.name}</h1>
                <span className="bg-[#C5A880]/15 text-[#002F6C] border border-[#C5A880]/30 text-xs font-bold px-3 py-1 rounded-full uppercase tracking-wider">
                  {profile.user_type || 'User'}
                </span>
              </div>
              
              <div className="space-y-1 text-sm text-gray-500">
                <p className="flex items-center justify-center md:justify-start gap-2">
                  <Mail className="h-4 w-4 text-[#C5A880]" />
                  <span>{profile.email}</span>
                </p>
                {profile.phone && (
                  <p className="flex items-center justify-center md:justify-start gap-2">
                    <Phone className="h-4 w-4 text-[#C5A880]" />
                    <span>{profile.phone}</span>
                  </p>
                )}
                {profile.user_type !== 'Public' && profile.upsi_id && (
                  <p className="flex items-center justify-center md:justify-start gap-2">
                    <GraduationCap className="h-4 w-4 text-[#C5A880]" />
                    <span>ID: {profile.upsi_id}</span>
                  </p>
                )}
              </div>

              {/* Edit Profile Action Button */}
              <div className="pt-2">
                <button
                  onClick={() => setIsEditModalOpen(true)}
                  className="flex items-center gap-1.5 bg-[#002F6C] hover:bg-[#00204a] text-white px-4 py-2 rounded-xl text-xs font-bold transition shadow-sm"
                >
                  <Edit3 className="h-3.5 w-3.5" />
                  <span>Edit Profile Details</span>
                </button>
              </div>

            </div>
          </div>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-2 gap-4 mb-6">
          {/* Sessions Card */}
          <div className="bg-white rounded-2xl border border-gray-100 p-5 flex flex-col items-center text-center shadow-sm">
            <div className="bg-[#F1EAE0] p-3 rounded-xl mb-3 text-[#002F6C]">
              <CheckSquare className="h-6 w-6" />
            </div>
            <span className="text-2xl font-extrabold text-[#002F6C]">
              {loading ? '...' : sessionCount}
            </span>
            <span className="text-xs text-gray-400 mt-1 font-medium">Sessions Checked In</span>
          </div>

          {/* Swimmer Points Card */}
          <div className="bg-white rounded-2xl border border-gray-100 p-5 flex flex-col items-center text-center shadow-sm">
            <div className="bg-[#F1EAE0] p-3 rounded-xl mb-3 text-[#002F6C]">
              <Coins className="h-6 w-6" />
            </div>
            <span className="text-2xl font-extrabold text-[#C5A880]">
              {loading ? '...' : sessionCount * 20}
            </span>
            <span className="text-xs text-gray-400 mt-1 font-medium">Renang Club Points</span>
          </div>
        </div>

        {/* Account Options List */}
        <div className="bg-white rounded-2xl border border-gray-100 shadow-sm overflow-hidden mb-6">
          <div className="divide-y divide-gray-100">
            
            <a 
              href="mailto:support@erenang.upsi.edu.my"
              className="flex items-center justify-between p-4 hover:bg-gray-50 transition"
            >
              <div className="flex items-center gap-3">
                <div className="bg-gray-100 p-2 rounded-lg text-[#002F6C]">
                  <HelpCircle className="h-5 w-5" />
                </div>
                <div>
                  <h3 className="text-sm font-bold text-gray-800">Help & Support Desk</h3>
                  <p className="text-xs text-gray-400">Need assistance? Email support</p>
                </div>
              </div>
              <ChevronRight className="h-5 w-5 text-gray-300" />
            </a>

            <div className="flex items-center justify-between p-4 hover:bg-gray-50 cursor-pointer transition">
              <div className="flex items-center gap-3">
                <div className="bg-gray-100 p-2 rounded-lg text-[#002F6C]">
                  <FileText className="h-5 w-5" />
                </div>
                <div>
                  <h3 className="text-sm font-bold text-gray-800">Terms & Conditions</h3>
                  <p className="text-xs text-gray-400">Rules & pool regulation policy</p>
                </div>
              </div>
              <ChevronRight className="h-5 w-5 text-gray-300" />
            </div>

          </div>
        </div>

        {/* Log Out Button */}
        <button
          onClick={handleLogout}
          className="w-full flex items-center justify-center gap-2 border-2 border-red-500/20 hover:border-red-500 hover:bg-red-50 text-red-600 hover:text-red-700 font-bold py-3.5 rounded-2xl transition text-sm"
        >
          <LogOut className="h-4 w-4" />
          <span>Log Out Account</span>
        </button>

      </div>

      {/* Edit Profile Modal */}
      {isEditModalOpen && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center p-4 z-50 animate-fadeIn">
          <div className="bg-white rounded-3xl w-full max-w-md overflow-hidden shadow-2xl border border-gray-100">
            <div className="bg-[#002F6C] px-6 py-4 flex items-center justify-between text-white">
              <h2 className="text-lg font-bold">Edit Profile Details</h2>
              <button 
                onClick={() => setIsEditModalOpen(false)}
                className="text-white/80 hover:text-white transition"
              >
                <X className="h-5 w-5" />
              </button>
            </div>

            <form onSubmit={handleUpdateProfile} className="p-6 space-y-4">
              
              {feedback.message && (
                <div className={`p-4 rounded-xl flex items-center gap-2 text-sm ${
                  feedback.type === 'success' ? 'bg-green-50 text-green-700' : 'bg-red-50 text-red-700'
                }`}>
                  {feedback.type === 'success' ? (
                    <CheckCircle className="h-5 w-5 text-green-500 shrink-0" />
                  ) : (
                    <AlertCircle className="h-5 w-5 text-red-500 shrink-0" />
                  )}
                  <span>{feedback.message}</span>
                </div>
              )}

              {/* Name Field */}
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
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                    className="block w-full pl-10 pr-3 py-2.5 border border-gray-200 rounded-xl bg-gray-50/50 text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20 focus:border-[#002F6C] transition text-sm"
                  />
                </div>
              </div>

              {/* Phone Field */}
              <div>
                <label className="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
                  Phone Number
                </label>
                <div className="relative">
                  <span className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-gray-400">
                    <Phone className="h-4 w-4" />
                  </span>
                  <input
                    type="text"
                    placeholder="e.g. +60123456789"
                    value={phone}
                    onChange={(e) => setPhone(e.target.value)}
                    className="block w-full pl-10 pr-3 py-2.5 border border-gray-200 rounded-xl bg-gray-50/50 text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20 focus:border-[#002F6C] transition text-sm"
                  />
                </div>
              </div>

              {/* UPSI ID (Matric/Staff Number - hidden for public) */}
              {profile.user_type !== 'Public' && (
                <div>
                  <label className="block text-xs font-bold uppercase text-gray-500 mb-1.5 tracking-wider">
                    UPSI ID Number
                  </label>
                  <div className="relative">
                    <span className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none text-gray-400">
                      <GraduationCap className="h-4 w-4" />
                    </span>
                    <input
                      type="text"
                      required
                      value={upsiId}
                      onChange={(e) => setUpsiId(e.target.value)}
                      className="block w-full pl-10 pr-3 py-2.5 border border-gray-200 rounded-xl bg-gray-50/50 text-gray-800 focus:outline-none focus:ring-2 focus:ring-[#002F6C]/20 focus:border-[#002F6C] transition text-sm"
                    />
                  </div>
                </div>
              )}

              {/* Submit Buttons */}
              <div className="flex gap-3 mt-6">
                <button
                  type="button"
                  onClick={() => setIsEditModalOpen(false)}
                  className="w-1/2 border border-gray-200 py-3 rounded-xl text-gray-600 hover:bg-gray-50 transition text-sm font-semibold"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={submitting}
                  className="w-1/2 bg-[#002F6C] hover:bg-[#00204a] text-white py-3 rounded-xl transition text-sm font-semibold flex items-center justify-center"
                >
                  {submitting ? (
                    <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin" />
                  ) : (
                    'Save Changes'
                  )}
                </button>
              </div>

            </form>
          </div>
        </div>
      )}

    </div>
  );
}
