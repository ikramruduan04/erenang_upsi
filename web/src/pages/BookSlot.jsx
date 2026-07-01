/**
 * BookSlot.jsx — e-Renang UPSI Swimming Pool Booking Page
 *
 * This page is a pixel-faithful React port of the Flutter UserOrderScreen.
 * It implements the complete ticket-ordering + cart workflow:
 *
 *   1. Horizontal 7-day date selector (ZUS-style calendar strip)
 *   2. Pool banner gradient placeholder
 *   3. Section 1 – Swimming Pools Information (3 pool cards)
 *   4. Section 2 – Category & Ticket Type selector with subcategory dropdown
 *   5. Section 3 – Session time-slot selector (day-aware)
 *   6. Section 4 – Ticket quantity stepper (1-10)
 *   7. Bottom action bar (price + Add to Cart / Kolam Ditutup)
 *   8. Cart summary bar (gold, with checkout button)
 *   9. Checkout modal (slide-up overlay with confirm & pay)
 *
 * Dependencies:
 *   - React 19, React Router v7, Tailwind CSS v4, lucide-react, @supabase/supabase-js
 *   - AuthContext (../context/AuthContext) — provides `profile` with user data
 *   - supabase client (../lib/supabase) — Supabase browser client instance
 */

import { useState, useMemo, useCallback, useRef, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  MinusCircle,
  PlusCircle,
  Info,
  Lock,
  ArrowRight,
  Trash2,
  CheckCircle2,
  AlertCircle,
  User,
  Ticket,
  ShoppingCart,
  X,
  Waves,
  ChevronDown,
} from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { supabase } from '../lib/supabase';

/* ═══════════════════════════════════════════════════════════════════════════
   STATIC DATA — Categories, Pools, Day ↔ Time-slot mapping
   ═══════════════════════════════════════════════════════════════════════════ */

/** Category groups with subcategories, prices (RM), and required-document notes */
const CATEGORIES = {
  'Staf & Pelajar UPSI': [
    { name: 'Pelajar UPSI', price: 0.0, note: 'Sila bawa kad pelajar' },
    { name: 'Staf/SUKSIS/SISPA/PALAPES - Suami/Isteri', price: 3.0, note: 'Sila bawa kad pekerja' },
    { name: 'Staf/SUKSIS/SISPA/PALAPES - Anak (0-7 tahun)', price: 0.0, note: 'Sila bawa kad pekerja' },
    { name: 'Staf/SUKSIS/SISPA/PALAPES - Anak (8 tahun ke atas)', price: 3.0, note: 'Sila bawa kad pekerja' },
    { name: 'Staf Holding/Sambilan/RA', price: 3.0, note: 'Sila bawa kad pekerja/bukti perkhidmatan' },
  ],
  'Orang Awam': [
    { name: 'Kanak-kanak (0-4 tahun)', price: 0.0, note: 'Sila bawa MyKid' },
    { name: 'Kanak-kanak (5-7 tahun)', price: 1.0, note: 'Sila bawa MyKid' },
    { name: 'Pelajar Sekolah & IPT (8-18 tahun)', price: 5.0, note: 'Sila bawa kad pelajar/Kad Pengenalan' },
    { name: 'Dewasa', price: 10.0, note: 'Sila bawa kad pengenalan' },
    { name: 'Warga Emas (60 tahun ke atas)', price: 5.0, note: 'Sila bawa kad pengenalan' },
    { name: 'Pesara / Pencen Kerajaan', price: 5.0, note: 'Sila bawa kad pencen' },
    { name: 'OKU - Kanak-kanak (0-7 tahun)', price: 0.0, note: 'Sila bawa kad OKU' },
    { name: 'OKU - Kanak-kanak (8-17 tahun)', price: 3.0, note: 'Sila bawa kad OKU' },
    { name: 'OKU - Dewasa', price: 5.0, note: 'Sila bawa kad OKU' },
  ],
};

/** Pool catalog — name, depth label, and description (Malay) */
const POOLS = [
  {
    name: 'Kolam Utama',
    depth: 'Standard Olimpik',
    desc: 'Standard Olimpik bersaiz 50 meter panjang dan 25 meter lebar dengan 10 lorong.',
    image: '/assets/upsi_pool.jpg',
  },
  {
    name: 'Kolam Renang Biasa',
    depth: '1.2 meter kedalaman',
    desc: 'Kedalaman bersesuaian untuk latihan renang biasa dan santai.',
    image: '/assets/upsi_pool_biasa.jpeg',
  },
  {
    name: 'Kolam Kanak-Kanak',
    depth: '0.5 meter kedalaman',
    desc: 'Kawasan cetek dan selamat untuk kanak-kanak bermain air.',
    image: '/assets/upsi_pool_kanak.png',
  },
];

/** Weekday abbreviations — index 0 = Sunday … 6 = Saturday (JS Date convention) */
const WEEKDAY_ABBR = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

/**
 * Returns the available session time slots for a given JS Date.
 * Monday → closed (empty array).
 */
function getTimeSlotsForDate(date) {
  const day = date.getDay(); // 0 = Sun, 1 = Mon, …, 6 = Sat
  switch (day) {
    case 1: // Monday — closed for maintenance
      return [];
    case 2: // Tuesday
    case 4: // Thursday
      return ['Sesi Petang (2.30 ptg - 6.30 ptg)'];
    case 3: // Wednesday — Ladies Day
      return ['Sesi Petang - Ladies Day (2.30 ptg - 6.30 ptg)'];
    case 5: // Friday
      return ['Sesi Petang (3.00 ptg - 6.30 ptg)'];
    case 0: // Sunday
    case 6: // Saturday
      return [
        'Sesi Pagi (8.30 pg - 12.30 tghari)',
        'Sesi Petang (2.30 ptg - 6.30 ptg)',
      ];
    default:
      return [];
  }
}

/**
 * Generate the next 7 calendar dates starting from today.
 * Each entry: { date: Date, weekday: string, day: number }
 */
function getNext7Days() {
  const days = [];
  const today = new Date();
  for (let i = 0; i < 7; i++) {
    const d = new Date(today);
    d.setDate(today.getDate() + i);
    days.push({
      date: d,
      weekday: WEEKDAY_ABBR[d.getDay()],
      day: d.getDate(),
    });
  }
  return days;
}

/** Format a Date as DD/MM/YYYY for display */
function formatDate(d) {
  return `${d.getDate()}/${d.getMonth() + 1}/${d.getFullYear()}`;
}

/** Format a Date as YYYY-MM-DD for Supabase storage */
function formatDateISO(d) {
  const y = d.getFullYear();
  const m = String(d.getMonth() + 1).padStart(2, '0');
  const dd = String(d.getDate()).padStart(2, '0');
  return `${y}-${m}-${dd}`;
}

/** Check if two JS Dates fall on the same calendar day */
function isSameDay(a, b) {
  return (
    a.getFullYear() === b.getFullYear() &&
    a.getMonth() === b.getMonth() &&
    a.getDate() === b.getDate()
  );
}

/* ═══════════════════════════════════════════════════════════════════════════
   MAIN COMPONENT
   ═══════════════════════════════════════════════════════════════════════════ */

export default function BookSlot() {
  const navigate = useNavigate();
  const { profile } = useAuth();

  /* ─── Derived date list (memoised so it doesn't recreate every render) ── */
  const next7Days = useMemo(() => getNext7Days(), []);

  /* ─── Selection state ──────────────────────────────────────────────────── */
  const [selectedDate, setSelectedDate] = useState(next7Days[0].date);
  const [selectedGroup, setSelectedGroup] = useState('Orang Awam');
  const [selectedSubCategory, setSelectedSubCategory] = useState(
    CATEGORIES['Orang Awam'][0].name
  );
  const [selectedSlot, setSelectedSlot] = useState(() => {
    const slots = getTimeSlotsForDate(next7Days[0].date);
    return slots.length > 0 ? slots[0] : '';
  });
  const [quantity, setQuantity] = useState(1);

  /* ─── Cart state ───────────────────────────────────────────────────────── */
  const [cart, setCart] = useState([]);

  /* ─── Modal / toast state ──────────────────────────────────────────────── */
  const [showCheckout, setShowCheckout] = useState(false);
  const [showSuccess, setShowSuccess] = useState(false);
  const [showError, setShowError] = useState(false);
  const [errorMessage, setErrorMessage] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [toast, setToast] = useState(null);

  /* ─── Dropdown open/close state ────────────────────────────────────────── */
  const [dropdownOpen, setDropdownOpen] = useState(false);
  const dropdownRef = useRef(null);

  /** Close dropdown when clicking outside */
  useEffect(() => {
    function handleClickOutside(e) {
      if (dropdownRef.current && !dropdownRef.current.contains(e.target)) {
        setDropdownOpen(false);
      }
    }
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  /* ─── Scroll ref for the date strip on mobile ──────────────────────────── */
  const dateStripRef = useRef(null);

  /* ─── Derived values ───────────────────────────────────────────────────── */
  const availableSubCategories = CATEGORIES[selectedGroup] || [];
  const currentSub = availableSubCategories.find(
    (s) => s.name === selectedSubCategory
  ) || availableSubCategories[0];
  const pricePerTicket = currentSub ? currentSub.price : 0;
  const notes = currentSub ? currentSub.note : '';
  const selectedSubtotal = pricePerTicket * quantity;

  const timeSlots = useMemo(
    () => getTimeSlotsForDate(selectedDate),
    [selectedDate]
  );
  const isClosed = timeSlots.length === 0;

  const cartSubtotal = cart.reduce(
    (sum, item) => sum + item.pricePerTicket * item.quantity,
    0
  );

  /* ─── Auto-dismiss toast after 2.5 s ───────────────────────────────────── */
  useEffect(() => {
    if (toast) {
      const t = setTimeout(() => setToast(null), 2500);
      return () => clearTimeout(t);
    }
  }, [toast]);

  /* ═══════════════════════════════════════════════════════════════════════
     HANDLERS
     ═══════════════════════════════════════════════════════════════════════ */

  /** When a date chip is tapped, update the selected date and reset the slot */
  const handleDateSelect = useCallback(
    (date) => {
      setSelectedDate(date);
      const slots = getTimeSlotsForDate(date);
      if (slots.length > 0) {
        setSelectedSlot((prev) => (slots.includes(prev) ? prev : slots[0]));
      } else {
        setSelectedSlot('');
      }
    },
    []
  );

  /** Switch the top-level group toggle and reset subcategory to the first item */
  const handleGroupChange = useCallback((group) => {
    setSelectedGroup(group);
    setSelectedSubCategory(CATEGORIES[group][0].name);
    setDropdownOpen(false);
  }, []);

  /** Add the current selection to the cart */
  const handleAddToCart = useCallback(() => {
    if (isClosed) return;
    const newItem = {
      id: Date.now() + Math.random(), // lightweight unique key for React list
      poolType: 'Kolam Utama', // default pool
      bookingDate: new Date(selectedDate),
      timeSlot: selectedSlot,
      userType: selectedGroup,
      subCategory: selectedSubCategory,
      notes,
      quantity,
      pricePerTicket,
    };
    setCart((prev) => [...prev, newItem]);
    setToast(`Added ${quantity} × ${selectedSubCategory} to cart!`);
  }, [isClosed, selectedDate, selectedSlot, selectedGroup, selectedSubCategory, notes, quantity, pricePerTicket]);

  /** Remove one item from the cart by index */
  const handleRemoveCartItem = useCallback(
    (idx) => {
      setCart((prev) => {
        const next = [...prev];
        next.splice(idx, 1);
        // Auto-close checkout modal if cart becomes empty
        if (next.length === 0) setShowCheckout(false);
        return next;
      });
    },
    []
  );

  /** Confirm & Pay — writes each cart item as a separate booking row in Supabase */
  const handleConfirmBooking = useCallback(async () => {
    if (cart.length === 0) return;
    setIsSubmitting(true);

    try {
      const currentUser = profile || {};
      const userId = currentUser.id || (await supabase.auth.getUser()).data?.user?.id;
      const timestamp = Date.now().toString();

      for (let i = 0; i < cart.length; i++) {
        const item = cart[i];
        const uniqueSuffix = timestamp.slice(-6);
        const poolPrefix = item.poolType
          .substring(0, 3)
          .replace(/\s/g, '')
          .toUpperCase();
        const qrCode = `UP-B-${uniqueSuffix}-${i}-${poolPrefix}`;

        const bookingRow = {
          user_id: userId,
          name: currentUser.name || 'Guest',
          email: currentUser.email || '',
          phone: currentUser.phone || '',
          upsi_id: currentUser.upsi_id || '',
          user_type: item.userType,
          sub_category: item.subCategory,
          pool_type: item.poolType,
          booking_date: formatDateISO(item.bookingDate),
          time_slot: item.timeSlot,
          quantity: item.quantity,
          total_price: item.pricePerTicket * item.quantity,
          status: 'Pending',
          qr_code: qrCode,
          notes: item.notes,
        };

        const { error } = await supabase.from('bookings').insert(bookingRow);
        if (error) throw error;
      }

      // Success — clear cart, close checkout, show success modal
      setCart([]);
      setShowCheckout(false);
      setIsSubmitting(false);
      setShowSuccess(true);
    } catch (err) {
      console.error('Booking error:', err);
      setIsSubmitting(false);
      setShowCheckout(false);
      setErrorMessage(
        `Could not complete booking. Please check your internet connection and try again.\n\nError: ${
          err?.message || err
        }`
      );
      setShowError(true);
    }
  }, [cart, profile]);

  /* ═══════════════════════════════════════════════════════════════════════
     PRICE LABEL HELPER — formats RM or Percuma
     ═══════════════════════════════════════════════════════════════════════ */
  const priceLabel = (price) =>
    price === 0 ? 'Percuma' : `RM ${price.toFixed(2)}`;

  /* ═══════════════════════════════════════════════════════════════════════
     RENDER
     ═══════════════════════════════════════════════════════════════════════ */
  return (
    <div className="flex flex-col h-full bg-[#F4F6F9] font-['Outfit']">
      {/* ───────────────────── Toast notification ───────────────────── */}
      {toast && (
        <div className="fixed top-6 left-1/2 -translate-x-1/2 z-[100] animate-[slideDown_0.3s_ease-out]">
          <div className="flex items-center gap-3 bg-[#10B981] text-white px-5 py-3 rounded-xl shadow-lg">
            <CheckCircle2 size={20} />
            <span className="font-semibold text-sm">{toast}</span>
          </div>
        </div>
      )}

      {/* ═══════════════════════════════════════════════════════════════
          1. HORIZONTAL DATE SELECTOR — white bar at top
          ═══════════════════════════════════════════════════════════════ */}
      <div className="bg-white shrink-0">
        <div
          ref={dateStripRef}
          className="flex gap-2.5 overflow-x-auto px-4 py-3 scrollbar-hide"
        >
          {next7Days.map(({ date, weekday, day }) => {
            const isSelected = isSameDay(date, selectedDate);
            return (
              <button
                key={day}
                onClick={() => handleDateSelect(date)}
                className={`
                  flex flex-col items-center justify-center min-w-[55px] w-[55px] h-[60px]
                  rounded-xl border transition-all duration-200 shrink-0 cursor-pointer
                  ${
                    isSelected
                      ? 'bg-[#002F6C] border-[#002F6C]'
                      : 'bg-white border-[#E2E8F0] hover:border-[#002F6C]/40'
                  }
                `}
              >
                {/* Weekday abbreviation — gold when selected, secondary otherwise */}
                <span
                  className={`text-[11px] font-bold leading-tight ${
                    isSelected ? 'text-[#C5A880]' : 'text-[#64748B]'
                  }`}
                >
                  {weekday}
                </span>
                {/* Day number */}
                <span
                  className={`text-base font-bold leading-tight ${
                    isSelected ? 'text-white' : 'text-[#1E293B]'
                  }`}
                >
                  {day}
                </span>
              </button>
            );
          })}
        </div>
        {/* Thin divider matching Flutter Divider(height:1) */}
        <div className="h-px bg-[#E2E8F0]" />
      </div>

      {/* ═══════════════════════════════════════════════════════════════
          SCROLLABLE MAIN CONTENT
          ═══════════════════════════════════════════════════════════════ */}
      <div className="flex-1 overflow-y-auto">
        <div className="p-5 space-y-5 max-w-5xl mx-auto">
          {/* ─────────── POOL BANNER IMAGE (actual pool asset) ──── */}
          <div 
            className="h-40 w-full rounded-2xl flex items-center justify-center overflow-hidden relative"
            style={{
              background: 'linear-gradient(to right, rgba(0, 47, 108, 0.85) 0%, rgba(0, 84, 180, 0.45) 100%), url("/assets/upsi_pool.jpg") center/cover no-repeat',
            }}
          >
            {/* Decorative wave icon watermark */}
            <Waves size={120} className="text-white/10 absolute right-4 bottom-0" />
            <div className="text-center z-10">
              <h2 className="text-white text-xl font-bold">Kolam Renang UPSI</h2>
              <p className="text-white/70 text-sm mt-1">Pusat Akuatik Universiti</p>
            </div>
          </div>

          {/* ═══════════════════════════════════════════════════════════
              SECTION 1 — Swimming Pools Information
              ═══════════════════════════════════════════════════════════ */}
          <h3 className="text-base font-bold text-[#1E293B]">
            1. Swimming Pools Information
          </h3>

          {/* 3 pool info cards — row on desktop, stack on mobile */}
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
            {POOLS.map((pool) => (
              <div
                key={pool.name}
                className="bg-white rounded-2xl border border-[#E2E8F0]/50 shadow-sm overflow-hidden"
              >
                {/* Pool image */}
                <div className="aspect-video w-full overflow-hidden bg-gray-100">
                  <img 
                    src={pool.image} 
                    alt={pool.name} 
                    className="w-full h-full object-cover hover:scale-105 transition-transform duration-300" 
                  />
                </div>
                {/* Text content */}
                <div className="p-3">
                  <p className="text-sm font-bold text-[#1E293B] leading-tight">
                    {pool.name}
                  </p>
                  <p className="text-[11px] font-semibold text-[#C5A880] mt-1">
                    Depth: {pool.depth}
                  </p>
                  <p className="text-[11px] text-[#64748B] leading-snug mt-1.5 line-clamp-4">
                    {pool.desc}
                  </p>
                </div>
              </div>
            ))}
          </div>

          {/* ═══════════════════════════════════════════════════════════
              SECTION 2 — Select Category & Ticket Type
              ═══════════════════════════════════════════════════════════ */}
          <h3 className="text-base font-bold text-[#1E293B]">
            2. Select Category &amp; Ticket Type
          </h3>

          {/* Toggle buttons — UPSI Staff/Student vs Orang Awam */}
          <div className="flex">
            {/* Left toggle — UPSI Staff/Student (Disabled) */}
            <button
              type="button"
              disabled
              className="flex-1 py-3 text-[13px] font-bold border bg-gray-100 text-gray-400 border-gray-200 rounded-l-xl cursor-not-allowed"
            >
              UPSI Staff/Student (Disabled)
            </button>
            {/* Right toggle — Orang Awam (Public) (Always Selected) */}
            <button
              type="button"
              className="flex-1 py-3 text-[13px] font-bold border bg-[#002F6C] text-white border-[#002F6C] rounded-r-xl cursor-default"
            >
              Orang Awam (Public)
            </button>
          </div>

          {/* Subcategory dropdown — custom-built to match Flutter DropdownButtonFormField */}
          <div ref={dropdownRef} className="relative">
            <label className="block text-xs text-[#64748B] mb-1.5 font-medium">
              Ticket Option
            </label>
            <button
              onClick={() => setDropdownOpen((v) => !v)}
              className="w-full flex items-center justify-between bg-white border border-[#E2E8F0] rounded-xl px-4 py-3 text-left cursor-pointer hover:border-[#002F6C]/40 transition-colors"
            >
              <span className="text-[13px] text-[#1E293B] truncate pr-2">
                {selectedSubCategory} ({priceLabel(pricePerTicket)})
              </span>
              <ChevronDown
                size={18}
                className={`text-[#64748B] transition-transform shrink-0 ${
                  dropdownOpen ? 'rotate-180' : ''
                }`}
              />
            </button>

            {/* Dropdown list */}
            {dropdownOpen && (
              <div className="absolute top-full left-0 right-0 mt-1 bg-white border border-[#E2E8F0] rounded-xl shadow-lg z-30 max-h-64 overflow-y-auto">
                {availableSubCategories.map((item) => {
                  const isActive = item.name === selectedSubCategory;
                  return (
                    <button
                      key={item.name}
                      onClick={() => {
                        setSelectedSubCategory(item.name);
                        setDropdownOpen(false);
                      }}
                      className={`
                        w-full text-left px-4 py-3 text-[13px] transition-colors cursor-pointer
                        border-b border-[#E2E8F0] last:border-b-0
                        ${
                          isActive
                            ? 'bg-[#002F6C]/5 text-[#002F6C] font-bold'
                            : 'text-[#1E293B] hover:bg-[#F4F6F9]'
                        }
                      `}
                    >
                      {item.name}{' '}
                      <span className="text-[#C5A880] font-semibold">
                        ({priceLabel(item.price)})
                      </span>
                    </button>
                  );
                })}
              </div>
            )}
          </div>

          {/* Catatan Penting — important notice box (gold-tinted) */}
          <div className="w-full p-3.5 bg-[#F1EAE0]/30 border border-[#C5A880]/50 rounded-xl flex gap-3">
            <Info size={20} className="text-[#002F6C] shrink-0 mt-0.5" />
            <div>
              <p className="text-xs font-bold text-[#002F6C]">
                Catatan Penting:
              </p>
              <p className="text-xs text-[#1E293B] mt-0.5">
                {notes} semasa melapor diri di kolam renang.
              </p>
            </div>
          </div>

          {/* ═══════════════════════════════════════════════════════════
              SECTION 3 — Select Session Time
              ═══════════════════════════════════════════════════════════ */}
          <h3 className="text-base font-bold text-[#1E293B]">
            3. Select Session Time
          </h3>

          {isClosed ? (
            /* Monday — closed banner */
            <div className="w-full p-4 bg-[#EF4444]/10 border border-[#EF4444]/30 rounded-xl flex items-start gap-3">
              <Info size={20} className="text-[#EF4444] shrink-0 mt-0.5" />
              <p className="text-[13px] text-[#EF4444] font-bold">
                Maaf, kolam ditutup pada hari Isnin sempena penyelenggaraan dan
                pembersihan.
              </p>
            </div>
          ) : (
            /* Session time slot chips */
            <div className="flex flex-wrap gap-2.5">
              {timeSlots.map((slot) => {
                const isActive = slot === selectedSlot;
                return (
                  <button
                    key={slot}
                    onClick={() => setSelectedSlot(slot)}
                    className={`
                      px-4 py-3 rounded-[10px] border text-xs font-bold transition-all cursor-pointer
                      ${
                        isActive
                          ? 'bg-[#002F6C] border-[#002F6C] text-white'
                          : 'bg-white border-[#E2E8F0] text-[#1E293B] hover:border-[#002F6C]/40'
                      }
                    `}
                  >
                    {slot}
                  </button>
                );
              })}
            </div>
          )}

          {/* ═══════════════════════════════════════════════════════════
              SECTION 4 — Ticket Quantity
              ═══════════════════════════════════════════════════════════ */}
          <div className="flex items-center justify-between">
            <h3 className="text-base font-bold text-[#1E293B]">
              4. Ticket Quantity
            </h3>
            <div className="flex items-center gap-1">
              {/* Minus button */}
              <button
                onClick={() => setQuantity((q) => Math.max(1, q - 1))}
                className="p-1 text-[#002F6C] hover:opacity-70 transition-opacity cursor-pointer disabled:opacity-30"
                disabled={quantity <= 1}
                aria-label="Decrease quantity"
              >
                <MinusCircle size={28} />
              </button>
              {/* Quantity label */}
              <span className="text-lg font-bold text-[#1E293B] w-8 text-center select-none">
                {quantity}
              </span>
              {/* Plus button */}
              <button
                onClick={() => setQuantity((q) => Math.min(2, q + 1))}
                className="p-1 text-[#002F6C] hover:opacity-70 transition-opacity cursor-pointer disabled:opacity-30"
                disabled={quantity >= 2}
                aria-label="Increase quantity"
              >
                <PlusCircle size={28} />
              </button>
            </div>
          </div>

          {/* Spacer so content doesn't hide behind sticky bars */}
          <div className="h-10" />
        </div>
      </div>

      {/* ═══════════════════════════════════════════════════════════════════
          CART SUMMARY BAR — gold, appears when items are in the cart
          ═══════════════════════════════════════════════════════════════════ */}
      {cart.length > 0 && (
        <div className="mx-4 mb-0 shrink-0">
          <div className="bg-[#C5A880] rounded-2xl px-4 py-3 flex items-center justify-between shadow-lg">
            {/* Left — cart count badge + label */}
            <div className="flex items-center gap-3">
              {/* Navy circle badge with item count */}
              <div className="bg-[#002F6C] text-white w-9 h-9 rounded-full flex items-center justify-center font-bold text-sm">
                {cart.length}
              </div>
              <div>
                <p className="text-[13px] font-bold text-[#002F6C]">
                  Peti Tiket Anda (Cart)
                </p>
                <p className="text-xs font-semibold text-[#002F6C]/80">
                  RM {cartSubtotal.toFixed(2)}
                </p>
              </div>
            </div>
            {/* Checkout button */}
            <button
              onClick={() => setShowCheckout(true)}
              className="bg-[#002F6C] text-white px-4 py-2.5 rounded-xl flex items-center gap-1.5 text-xs font-bold hover:bg-[#002F6C]/90 transition-colors cursor-pointer"
            >
              Checkout
              <ArrowRight size={14} />
            </button>
          </div>
        </div>
      )}

      {/* ═══════════════════════════════════════════════════════════════════
          BOTTOM ACTION BAR — sticky price + Add to Cart
          ═══════════════════════════════════════════════════════════════════ */}
      <div className="bg-white border-t border-[#E2E8F0] px-5 py-4 flex items-center justify-between shrink-0 shadow-[0_-4px_10px_rgba(0,0,0,0.05)]">
        {/* Left — selected price */}
        <div>
          <p className="text-xs text-[#64748B]">Selected Price</p>
          <p className="text-xl font-bold text-[#002F6C]">
            RM {selectedSubtotal.toFixed(2)}
          </p>
        </div>
        {/* Right — Add to Cart / Kolam Ditutup button */}
        <button
          onClick={handleAddToCart}
          disabled={isClosed}
          className={`
            flex items-center gap-2 px-8 py-3.5 rounded-2xl font-bold text-white transition-all cursor-pointer
            ${
              isClosed
                ? 'bg-gray-400 cursor-not-allowed'
                : 'bg-[#002F6C] hover:bg-[#002F6C]/90 active:scale-[0.97]'
            }
          `}
        >
          {isClosed ? <Lock size={18} /> : <PlusCircle size={18} />}
          <span>{isClosed ? 'Kolam Ditutup' : 'Add to Cart'}</span>
        </button>
      </div>

      {/* ═══════════════════════════════════════════════════════════════════
          CHECKOUT MODAL — slide-up overlay
          ═══════════════════════════════════════════════════════════════════ */}
      {showCheckout && (
        <div className="fixed inset-0 z-50 flex items-end justify-center">
          {/* Backdrop */}
          <div
            className="absolute inset-0 bg-black/40 animate-[fadeIn_0.2s_ease-out]"
            onClick={() => setShowCheckout(false)}
          />
          {/* Modal sheet */}
          <div className="relative bg-white w-full max-w-lg rounded-t-[28px] p-6 pb-8 animate-[slideUp_0.3s_ease-out] max-h-[90vh] flex flex-col">
            {/* Pull bar */}
            <div className="flex justify-center mb-4">
              <div className="w-10 h-1.5 bg-[#E2E8F0] rounded-full" />
            </div>

            {/* Title */}
            <h3 className="text-xl font-bold text-[#1E293B] mb-1">
              Checkout Cart
            </h3>
            <div className="h-px bg-[#E2E8F0] my-3" />

            {/* Cart items list — scrollable */}
            <div className="flex-1 overflow-y-auto max-h-[35vh] space-y-2.5 pr-1">
              {cart.map((item, idx) => (
                <div
                  key={item.id}
                  className="bg-[#F4F6F9] border border-[#E2E8F0] rounded-xl p-3 flex items-start gap-3"
                >
                  {/* Ticket icon */}
                  <div className="bg-[#002F6C]/10 p-2 rounded-lg shrink-0">
                    <Ticket size={20} className="text-[#002F6C]" />
                  </div>
                  {/* Item details */}
                  <div className="flex-1 min-w-0">
                    <p className="text-[13px] font-bold text-[#1E293B] truncate">
                      {item.subCategory}
                    </p>
                    <p className="text-[11px] text-[#64748B] truncate">
                      {item.poolType} • {item.timeSlot}
                    </p>
                    <p className="text-[11px] font-bold text-[#C5A880]">
                      {formatDate(item.bookingDate)}
                    </p>
                  </div>
                  {/* Price + quantity */}
                  <div className="text-right shrink-0">
                    <p className="text-[13px] font-bold text-[#002F6C]">
                      RM {(item.pricePerTicket * item.quantity).toFixed(2)}
                    </p>
                    <p className="text-[10px] text-[#64748B]">
                      {item.quantity} × RM {item.pricePerTicket.toFixed(2)}
                    </p>
                  </div>
                  {/* Delete button */}
                  <button
                    onClick={() => handleRemoveCartItem(idx)}
                    className="text-red-400 hover:text-red-600 p-1 transition-colors cursor-pointer shrink-0"
                    aria-label="Remove item"
                  >
                    <Trash2 size={18} />
                  </button>
                </div>
              ))}
            </div>

            <div className="h-px bg-[#E2E8F0] my-4" />

            {/* User info card */}
            <div className="bg-[#F4F6F9] rounded-xl p-3 flex items-center gap-3">
              <User size={22} className="text-[#002F6C] shrink-0" />
              <div className="min-w-0">
                <p className="text-[13px] font-bold text-[#1E293B] truncate">
                  {profile?.name || 'Guest'} ({profile?.user_type || 'N/A'})
                </p>
                {profile?.upsi_id && (
                  <p className="text-[11px] text-[#64748B]">
                    ID: {profile.upsi_id}
                  </p>
                )}
              </div>
            </div>

            <div className="h-px bg-[#E2E8F0] my-4" />

            {/* Price breakdown */}
            <div className="space-y-2">
              <div className="flex justify-between text-sm">
                <span className="text-[#64748B]">Subtotal</span>
                <span className="text-[#1E293B]">
                  RM {cartSubtotal.toFixed(2)}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-base font-bold text-[#1E293B]">
                  Total Amount
                </span>
                <span className="text-lg font-bold text-[#002F6C]">
                  RM {cartSubtotal.toFixed(2)}
                </span>
              </div>
            </div>

            {/* Confirm & Pay button */}
            <button
              onClick={handleConfirmBooking}
              disabled={isSubmitting}
              className="mt-6 w-full bg-[#002F6C] text-white py-3.5 rounded-2xl font-bold flex items-center justify-center gap-2 hover:bg-[#002F6C]/90 transition-all cursor-pointer disabled:opacity-60 disabled:cursor-not-allowed"
            >
              {isSubmitting ? (
                /* Spinner */
                <div className="w-5 h-5 border-2 border-white/30 border-t-white rounded-full animate-spin" />
              ) : (
                <>
                  <CheckCircle2 size={20} />
                  Confirm &amp; Pay RM {cartSubtotal.toFixed(2)}
                </>
              )}
            </button>
          </div>
        </div>
      )}

      {/* ═══════════════════════════════════════════════════════════════════
          SUCCESS MODAL — "Bookings Confirmed!" with checkmark
          ═══════════════════════════════════════════════════════════════════ */}
      {showSuccess && (
        <div className="fixed inset-0 z-50 flex items-center justify-center">
          {/* Backdrop */}
          <div className="absolute inset-0 bg-black/40 animate-[fadeIn_0.2s_ease-out]" />
          {/* Dialog */}
          <div className="relative bg-white rounded-2xl p-8 max-w-sm w-[90%] text-center animate-[scaleIn_0.3s_ease-out] shadow-xl">
            <CheckCircle2 size={60} className="text-[#10B981] mx-auto" />
            <h3 className="text-xl font-bold text-[#1E293B] mt-4">
              Bookings Confirmed!
            </h3>
            <p className="text-[13px] text-[#64748B] mt-2 leading-relaxed">
              Your swimming passes have been generated successfully. Show the QR
              tickets at the pool entrance.
            </p>
            <button
              onClick={() => {
                setShowSuccess(false);
                navigate('/tickets');
              }}
              className="mt-5 bg-[#002F6C] text-white px-8 py-3 rounded-2xl font-bold hover:bg-[#002F6C]/90 transition-colors cursor-pointer"
            >
              View My Tickets
            </button>
          </div>
        </div>
      )}

      {/* ═══════════════════════════════════════════════════════════════════
          ERROR MODAL — "Booking Failed"
          ═══════════════════════════════════════════════════════════════════ */}
      {showError && (
        <div className="fixed inset-0 z-50 flex items-center justify-center">
          {/* Backdrop */}
          <div
            className="absolute inset-0 bg-black/40 animate-[fadeIn_0.2s_ease-out]"
            onClick={() => setShowError(false)}
          />
          {/* Dialog */}
          <div className="relative bg-white rounded-2xl p-6 max-w-sm w-[90%] animate-[scaleIn_0.3s_ease-out] shadow-xl">
            <div className="flex items-center gap-2 mb-3">
              <AlertCircle size={22} className="text-[#EF4444]" />
              <h3 className="text-base font-bold text-[#1E293B]">
                Booking Failed
              </h3>
            </div>
            <p className="text-[13px] text-[#64748B] whitespace-pre-line leading-relaxed">
              {errorMessage}
            </p>
            <div className="flex justify-end mt-5">
              <button
                onClick={() => setShowError(false)}
                className="text-[#002F6C] font-bold text-sm hover:underline cursor-pointer px-4 py-2"
              >
                OK
              </button>
            </div>
          </div>
        </div>
      )}

      {/* ═══════════════════════════════════════════════════════════════════
          INLINE KEYFRAME STYLES — Tailwind v4 doesn't ship these by default
          ═══════════════════════════════════════════════════════════════════ */}
      <style>{`
        /* Hide horizontal scrollbar on the date strip */
        .scrollbar-hide::-webkit-scrollbar { display: none; }
        .scrollbar-hide { -ms-overflow-style: none; scrollbar-width: none; }

        /* Slide-up animation for the checkout modal sheet */
        @keyframes slideUp {
          from { transform: translateY(100%); }
          to   { transform: translateY(0); }
        }

        /* Slide-down animation for the toast notification */
        @keyframes slideDown {
          from { transform: translate(-50%, -20px); opacity: 0; }
          to   { transform: translate(-50%, 0);     opacity: 1; }
        }

        /* Fade-in for modal backdrops */
        @keyframes fadeIn {
          from { opacity: 0; }
          to   { opacity: 1; }
        }

        /* Scale-in for centered modals (success / error dialogs) */
        @keyframes scaleIn {
          from { transform: scale(0.9); opacity: 0; }
          to   { transform: scale(1);   opacity: 1; }
        }
      `}</style>
    </div>
  );
}
