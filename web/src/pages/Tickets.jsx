/**
 * Tickets.jsx — e-Renang UPSI Web
 *
 * Replicates the Flutter UserTicketsScreen pixel-for-pixel.
 *
 * Layout:
 *   ┌──────────────────────────────────────────────┐
 *   │  [Active Passes]  |  [Booking History]  tabs │
 *   ├──────────────────────────────────────────────┤
 *   │  Booking Card list (scrollable)              │
 *   │   ┌───────┬──────────────────┬──┬────────┐   │
 *   │   │ DATE  │ PoolType (bold)  │  │ QR icon│   │
 *   │   │ card  │ time slot        │▎ │ SCAN   │   │
 *   │   │ gold  │ [badge] qty      │  │        │   │
 *   │   └───────┴──────────────────┴──┴────────┘   │
 *   └──────────────────────────────────────────────┘
 *
 * Clicking a card opens a dialog:
 *   ┌───────────────────────────────────────────┐
 *   │  Navy header  «e-Renang Entry Ticket»   X │
 *   ├───────────────────────────────────────────┤
 *   │        [Mock QR Code CSS Grid]            │
 *   │         QR Code text                      │
 *   │  Detail rows … (label : value)            │
 *   │  ────────────────────────────             │
 *   │  ℹ Present QR code note                   │
 *   └───────────────────────────────────────────┘
 *
 * Data: supabase 'bookings' table, filtered by user_id.
 * Statuses: 'Pending' | 'Approved' | 'Checked In' | 'Cancelled'
 */

import { useState, useEffect, useCallback } from 'react';
import { Ticket, QrCode, Droplets, X, Info, RefreshCw } from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { supabase } from '../lib/supabase';

/* ──────────────────────────────────────────────────────────
   Month abbreviation lookup used for the date cards
   ────────────────────────────────────────────────────────── */
const MONTHS = [
  'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
  'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
];

/* ──────────────────────────────────────────────────────────
   Status → colour mapping (matches Flutter AppTheme)
   ────────────────────────────────────────────────────────── */
const STATUS_STYLES = {
  Approved:    { bg: 'rgba(16,185,129,0.15)',  text: '#10B981' },   // success green
  Pending:     { bg: 'rgba(245,158,11,0.15)',  text: '#F59E0B' },   // warning orange
  'Checked In': { bg: 'rgba(0,47,108,0.15)',   text: '#002F6C' },   // primary navy
  Cancelled:   { bg: 'rgba(239,68,68,0.15)',   text: '#EF4444' },   // error red
};

/* ══════════════════════════════════════════════════════════
   TICKETS PAGE COMPONENT
   ══════════════════════════════════════════════════════════ */
export default function Tickets() {
  /* ── State ─────────────────────────────────────────────── */
  const { user } = useAuth();
  const [allBookings, setAllBookings] = useState([]);
  const [isLoading, setIsLoading] = useState(false);
  const [activeTab, setActiveTab] = useState(0);           // 0 = Active, 1 = History
  const [selectedBooking, setSelectedBooking] = useState(null); // for detail dialog

  /* ── Fetch bookings from Supabase ──────────────────────── */
  const loadBookings = useCallback(async () => {
    if (!user) return;
    setIsLoading(true);
    try {
      const { data, error } = await supabase
        .from('bookings')
        .select('*')
        .eq('user_id', user.id)
        .order('booking_date', { ascending: false });

      if (error) throw error;
      setAllBookings(data ?? []);
    } catch (err) {
      console.error('Error loading bookings:', err);
    } finally {
      setIsLoading(false);
    }
  }, [user]);

  /* Load on mount & when user changes */
  useEffect(() => {
    loadBookings();
  }, [loadBookings]);

  /* ── Split bookings into Active / History ───────────────── */
  const active  = allBookings.filter((b) => b.status === 'Approved' || b.status === 'Pending');
  const history = allBookings.filter((b) => b.status === 'Checked In' || b.status === 'Cancelled');
  const currentList = activeTab === 0 ? active : history;

  /* ══════════════════════════════════════════════════════════
     RENDER
     ══════════════════════════════════════════════════════════ */
  return (
    <div className="flex flex-col h-full">

      {/* ── Tab Bar ──────────────────────────────────────── */}
      <div className="bg-white flex relative">
        {['Active Passes', 'Booking History'].map((label, idx) => (
          <button
            key={label}
            onClick={() => setActiveTab(idx)}
            className="flex-1 py-3 text-sm font-bold transition-colors cursor-pointer"
            style={{
              fontFamily: 'Outfit, sans-serif',
              color: activeTab === idx ? '#002F6C' : '#94A3B8',
            }}
          >
            {label}
          </button>
        ))}
        {/* Animated underline indicator */}
        <span
          className="absolute bottom-0 h-[3px] bg-[#002F6C] transition-all duration-300"
          style={{ width: '50%', left: activeTab === 0 ? '0%' : '50%' }}
        />
      </div>
      {/* Divider below tabs */}
      <div className="h-px bg-[#E2E8F0]" />

      {/* ── Content ──────────────────────────────────────── */}
      <div className="flex-1 overflow-y-auto">
        {isLoading ? (
          /* Loading spinner */
          <div className="flex items-center justify-center h-full">
            <div className="w-8 h-8 border-3 border-[#C5A880] border-t-transparent rounded-full animate-spin" />
          </div>
        ) : currentList.length === 0 ? (
          /* Empty state */
          <div className="flex flex-col items-center justify-center h-full gap-4">
            <Ticket size={64} className="text-[#94A3B8]" />
            <p
              className="text-lg font-bold text-[#64748B]"
              style={{ fontFamily: 'Outfit, sans-serif' }}
            >
              No Tickets Found
            </p>
            <p
              className="text-[13px] text-[#94A3B8]"
              style={{ fontFamily: 'Outfit, sans-serif' }}
            >
              Book a swimming slot in the Catalog tab.
            </p>
          </div>
        ) : (
          /* Booking card list */
          <div className="p-4 flex flex-col gap-4">
            {/* Refresh button aligned right */}
            <div className="flex justify-end">
              <button
                onClick={loadBookings}
                className="flex items-center gap-1.5 text-xs font-bold text-[#002F6C] hover:opacity-70 transition cursor-pointer"
                style={{ fontFamily: 'Outfit, sans-serif' }}
              >
                <RefreshCw size={14} />
                Refresh
              </button>
            </div>

            {currentList.map((booking) => (
              <BookingCard
                key={booking.id}
                booking={booking}
                onTap={() => setSelectedBooking(booking)}
              />
            ))}
          </div>
        )}
      </div>

      {/* ── Ticket Detail Dialog (modal overlay) ─────────── */}
      {selectedBooking && (
        <TicketDetailDialog
          booking={selectedBooking}
          onClose={() => setSelectedBooking(null)}
        />
      )}
    </div>
  );
}

/* ══════════════════════════════════════════════════════════
   BOOKING CARD
   Matches Flutter layout: Date card | Info | Divider | QR
   ══════════════════════════════════════════════════════════ */
function BookingCard({ booking, onTap }) {
  /* Parse booking date string to Date object */
  const date = new Date(booking.booking_date);
  const monthAbbr = MONTHS[date.getMonth()];
  const day = date.getDate();

  /* Status colour */
  const statusStyle = STATUS_STYLES[booking.status] ?? STATUS_STYLES.Cancelled;

  return (
    <button
      onClick={onTap}
      className="bg-white rounded-2xl border border-[#E2E8F0] shadow-sm
                 p-4 flex items-center gap-4 w-full text-left
                 hover:shadow-md transition-shadow cursor-pointer"
      style={{ boxShadow: '0 2px 8px rgba(0,47,108,0.05)' }}
    >
      {/* ── Date Card (gold background) ────────────────── */}
      <div
        className="w-[65px] shrink-0 flex flex-col items-center justify-center
                    py-3 rounded-xl bg-[#F1EAE0]"
      >
        <span
          className="text-[10px] font-bold text-[#002F6C]"
          style={{ fontFamily: 'Outfit, sans-serif' }}
        >
          {monthAbbr}
        </span>
        <span
          className="text-[22px] font-bold text-[#002F6C] leading-tight"
          style={{ fontFamily: 'Outfit, sans-serif' }}
        >
          {day}
        </span>
      </div>

      {/* ── Core info column ───────────────────────────── */}
      <div className="flex-1 min-w-0">
        {/* Pool type */}
        <p
          className="text-base font-bold text-[#1E293B] truncate"
          style={{ fontFamily: 'Outfit, sans-serif' }}
        >
          {booking.pool_type}
        </p>

        {/* Time slot */}
        <p
          className="text-xs text-[#64748B] mt-1"
          style={{ fontFamily: 'Outfit, sans-serif' }}
        >
          {booking.time_slot}
        </p>

        {/* Status badge + quantity */}
        <div className="flex items-center gap-2 mt-1.5">
          <span
            className="text-[10px] font-bold px-2 py-0.5 rounded-md"
            style={{
              fontFamily: 'Outfit, sans-serif',
              backgroundColor: statusStyle.bg,
              color: statusStyle.text,
            }}
          >
            {booking.status}
          </span>
          <span
            className="text-[11px] font-bold text-[#64748B]"
            style={{ fontFamily: 'Outfit, sans-serif' }}
          >
            {booking.quantity} Pax
          </span>
        </div>
      </div>

      {/* ── Vertical divider ──────────────────────────── */}
      <div className="w-[1.5px] h-[50px] bg-[#E2E8F0] mx-2.5 shrink-0" />

      {/* ── QR stub ───────────────────────────────────── */}
      <div className="flex flex-col items-center justify-center shrink-0">
        <QrCode size={28} className="text-[#002F6C]" />
        <span
          className="text-[9px] font-bold text-[#002F6C] mt-1"
          style={{ fontFamily: 'Outfit, sans-serif' }}
        >
          SCAN
        </span>
      </div>
    </button>
  );
}

/* ══════════════════════════════════════════════════════════
   TICKET DETAIL DIALOG (Modal)
   Navy header → Mock QR → Detail rows → Info note
   ══════════════════════════════════════════════════════════ */
function TicketDetailDialog({ booking, onClose }) {
  const date = new Date(booking.booking_date);

  return (
    /* Backdrop overlay */
    <div
      className="fixed inset-0 z-50 flex items-center justify-center p-6 bg-black/40"
      onClick={onClose}
    >
      {/* Dialog container – prevent click-through */}
      <div
        className="bg-white rounded-[28px] w-full max-w-md max-h-[90vh] overflow-y-auto shadow-2xl"
        onClick={(e) => e.stopPropagation()}
      >
        {/* ── Navy Header ──────────────────────────────── */}
        <div
          className="flex items-center justify-between px-5 py-4 rounded-t-[28px]"
          style={{ backgroundColor: '#002F6C' }}
        >
          <div className="flex items-center gap-2">
            <Droplets size={20} className="text-[#C5A880]" />
            <span
              className="text-white text-base font-bold"
              style={{ fontFamily: 'Outfit, sans-serif' }}
            >
              e-Renang Entry Ticket
            </span>
          </div>
          <button
            onClick={onClose}
            className="text-white hover:opacity-70 transition cursor-pointer"
          >
            <X size={20} />
          </button>
        </div>

        {/* ── Body ─────────────────────────────────────── */}
        <div className="p-6">
          {/* Mock QR code */}
          <div className="flex flex-col items-center">
            <div className="p-4 rounded-[20px] border border-[#E2E8F0] bg-[#F4F6F9]">
              <MockQRCode />
            </div>

            {/* QR code text */}
            <p
              className="mt-3 text-sm font-bold tracking-wider text-[#002F6C]"
              style={{ fontFamily: 'Outfit, sans-serif', letterSpacing: '1.5px' }}
            >
              {booking.qr_code}
            </p>
          </div>

          {/* ── Detail rows ────────────────────────────── */}
          <div className="mt-5 space-y-2">
            <DetailRow label="Swimmer Name"   value={booking.name} />
            <DetailRow label="Category Group"  value={booking.user_type} />
            <DetailRow label="Ticket Type"     value={booking.sub_category} />
            {booking.notes && booking.notes.length > 0 && (
              <DetailRow label="Catatan" value={booking.notes} />
            )}
            {booking.upsi_id && booking.upsi_id.length > 0 && (
              <DetailRow label="UPSI ID" value={booking.upsi_id} />
            )}
            <DetailRow label="Pool Section"    value={booking.pool_type} />
            <DetailRow
              label="Date"
              value={`${date.getDate()}/${date.getMonth() + 1}/${date.getFullYear()}`}
            />
            <DetailRow label="Time Session"    value={booking.time_slot} />
            <DetailRow label="Tickets / Slots" value={`${booking.quantity} Pax`} />
            <DetailRow
              label="Price Paid"
              value={`RM ${Number(booking.total_price).toFixed(2)}`}
            />
          </div>

          {/* Divider */}
          <div className="my-6 h-px bg-[#E2E8F0]" />

          {/* ── Info note ──────────────────────────────── */}
          <div className="flex items-start gap-2.5">
            <Info size={18} className="text-[#C5A880] shrink-0 mt-0.5" />
            <p
              className="text-[11px] text-[#64748B] leading-relaxed"
              style={{ fontFamily: 'Outfit, sans-serif' }}
            >
              Please present this QR code to the swimming pool staff at the
              entry turnstile. Proper swimming apparel is required.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}

/* ══════════════════════════════════════════════════════════
   DETAIL ROW — label on left, value on right
   ══════════════════════════════════════════════════════════ */
function DetailRow({ label, value }) {
  return (
    <div className="flex justify-between items-start">
      <span
        className="text-xs text-[#64748B]"
        style={{ fontFamily: 'Outfit, sans-serif' }}
      >
        {label}
      </span>
      <span
        className="text-xs font-bold text-[#1E293B] text-right max-w-[55%]"
        style={{ fontFamily: 'Outfit, sans-serif' }}
      >
        {value}
      </span>
    </div>
  );
}

/* ══════════════════════════════════════════════════════════
   MOCK QR CODE — CSS grid replicating the Flutter version
   Uses the same deterministic fill logic:
     (index * 7 + 13) % 5 === 0  ||  index % 3 === 0
     || (index > 40 && index % 2 === 0)
   ══════════════════════════════════════════════════════════ */
function MockQRCode() {
  /* Generate 49 cells (7×7 grid) with deterministic fills */
  const cells = Array.from({ length: 49 }, (_, i) => {
    const isFilled =
      (i * 7 + 13) % 5 === 0 || i % 3 === 0 || (i > 40 && i % 2 === 0);
    return isFilled;
  });

  return (
    <div
      className="relative bg-white p-2"
      style={{ width: 140, height: 140 }}
    >
      {/* Corner anchors (QR alignment markers) */}
      <QRAnchor className="absolute top-0 left-0" />
      <QRAnchor className="absolute top-0 right-0" />
      <QRAnchor className="absolute bottom-0 left-0" />

      {/* Centre pixel grid */}
      <div className="absolute inset-0 flex items-center justify-center">
        <div
          className="grid grid-cols-7 gap-[3px] p-1"
          style={{ width: 100, height: 100 }}
        >
          {cells.map((filled, i) => (
            <div
              key={i}
              className="rounded-[1px]"
              style={{
                backgroundColor: filled ? '#002F6C' : 'transparent',
              }}
            />
          ))}
        </div>
      </div>
    </div>
  );
}

/* QR Anchor – the three square-in-square corners */
function QRAnchor({ className = '' }) {
  return (
    <div
      className={`flex items-center justify-center ${className}`}
      style={{
        width: 28,
        height: 28,
        border: '4px solid #002F6C',
        padding: 4,
      }}
    >
      <div className="w-full h-full bg-[#002F6C]" />
    </div>
  );
}
