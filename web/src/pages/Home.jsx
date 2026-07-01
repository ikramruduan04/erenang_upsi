/**
 * Home.jsx — e-Renang UPSI User Home Page
 *
 * This is a pixel-faithful React port of the Flutter `UserHomeScreen`.
 * It contains six major sections that exactly replicate the mobile app:
 *
 *  1. Greeting Section   – personalised hello + user-type badge
 *  2. Membership Tier    – navy gradient card with progress bar & CTA
 *  3. Pool Banner        – promo banner with gradient overlay
 *  4. Pool Live Status   – 3 real-time stat cards
 *  5. Swimming Guidelines– 3 guideline accordion-style cards
 *  6. Pool Location      – address, Google Maps buttons, & facility list
 *
 * Data Flow
 * ---------
 * • `useAuth()` supplies `profile` (from AuthContext).
 * • Bookings are fetched independently via the Supabase client so the
 *   session count can be computed (status === 'Checked In').
 * • A loading spinner is shown until both profile and bookings are ready.
 *
 * Responsiveness
 * --------------
 * Mobile-first.  Status cards stack vertically on small screens
 * (< 640 px) and sit side-by-side on `sm:` and above.
 */

import { useState, useEffect, useCallback } from 'react';
import { useNavigate } from 'react-router-dom';
import {
  Award,
  Club,
  CalendarPlus,
  Thermometer,
  Activity,
  Users,
  ShieldAlert,
  Clock,
  HeartPulse,
  MapPin,
  Navigation,
  Copy,
  Bath,
  Car,
  Shirt,
  Loader2,
} from 'lucide-react';
import { useAuth } from '../contexts/AuthContext';
import { supabase } from '../lib/supabase';

/* ─── Google Maps short-link used throughout ───────────────────────── */
const MAPS_URL = 'https://maps.app.goo.gl/gtFbvunvHxJVHJP6A';

/* ═══════════════════════════════════════════════════════════════════
   MAIN COMPONENT
   ═══════════════════════════════════════════════════════════════════ */
export default function Home() {
  const { profile } = useAuth();
  const navigate = useNavigate();

  /* ── local state for bookings / session count ─────────────────── */
  const [sessionCount, setSessionCount] = useState(0);
  const [isLoading, setIsLoading] = useState(true);

  /* Copy-link feedback state */
  const [copied, setCopied] = useState(false);

  /* ── Fetch bookings on mount to calculate completed sessions ─── */
  const fetchBookings = useCallback(async () => {
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) { setIsLoading(false); return; }

      /* Fetch only the current user's bookings */
      const { data: bookings, error } = await supabase
        .from('bookings')
        .select('status')
        .eq('user_id', user.id);

      if (error) throw error;

      /* Count sessions with 'Checked In' status (matches Flutter logic) */
      const completed = (bookings ?? []).filter(
        (b) => b.status === 'Checked In'
      ).length;

      setSessionCount(completed);
    } catch (err) {
      console.error('Error fetching bookings:', err);
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchBookings();
  }, [fetchBookings]);

  /* ── Derive membership tier (mirrors Flutter logic exactly) ──── */
  const nextTierSessions = 10;
  const progress = Math.min(sessionCount / nextTierSessions, 1);
  const remaining = Math.max(nextTierSessions - sessionCount, 0);

  let tier = 'Bronze Swimmer';
  let tierColor = '#CD7F32'; // Bronze
  if (sessionCount >= 15) {
    tier = 'Gold Swimmer';
    tierColor = '#C5A880'; // accentGold
  } else if (sessionCount >= 7) {
    tier = 'Silver Swimmer';
    tierColor = '#C0C0C0'; // Silver
  }

  /* ── Profile-derived values ──────────────────────────────────── */
  const name = profile?.name ?? 'User';
  const userType = profile?.user_type ?? 'Student';

  /* ── Copy link handler ───────────────────────────────────────── */
  const handleCopyLink = async () => {
    try {
      await navigator.clipboard.writeText(MAPS_URL);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    } catch {
      /* Fallback for older browsers */
      const el = document.createElement('textarea');
      el.value = MAPS_URL;
      document.body.appendChild(el);
      el.select();
      document.execCommand('copy');
      document.body.removeChild(el);
      setCopied(true);
      setTimeout(() => setCopied(false), 2000);
    }
  };

  /* ── Loading state ───────────────────────────────────────────── */
  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-[60vh]">
        <Loader2
          className="animate-spin"
          size={40}
          style={{ color: '#002F6C' }}
        />
      </div>
    );
  }

  /* ═══════════════════════════════════════════════════════════════
     RENDER
     ═══════════════════════════════════════════════════════════════ */
  return (
    <div
      className="mx-auto w-full max-w-4xl px-5 py-6"
      style={{ fontFamily: "'Outfit', sans-serif" }}
    >
      {/* ────────────────────────────────────────────────────────────
          1. GREETING SECTION
          ──────────────────────────────────────────────────────────── */}
      <div className="flex items-start justify-between mb-5">
        {/* Left: greeting text */}
        <div>
          <h1
            className="text-2xl font-bold"
            style={{ color: '#1E293B' }}
          >
            Hello, {name} 👋
          </h1>
          <p
            className="text-sm mt-0.5"
            style={{ color: '#64748B' }}
          >
            Ready for a refreshing swim?
          </p>
        </div>

        {/* Right: user-type badge with Award icon */}
        <div
          className="flex items-center gap-1 px-3 py-1.5 rounded-full border"
          style={{
            backgroundColor: '#F1EAE0',
            borderColor: 'rgba(197, 168, 128, 0.5)',
          }}
        >
          <Award size={16} style={{ color: '#002F6C' }} />
          <span
            className="text-xs font-bold"
            style={{ color: '#002F6C' }}
          >
            {userType}
          </span>
        </div>
      </div>

      {/* ────────────────────────────────────────────────────────────
          2. MEMBERSHIP TIER CARD (Navy gradient)
          ──────────────────────────────────────────────────────────── */}
      <div
        className="rounded-3xl p-5 mb-6"
        style={{
          background: 'linear-gradient(135deg, #002F6C 0%, #001F47 100%)',
          boxShadow: '0 8px 15px rgba(0, 47, 108, 0.15)',
        }}
      >
        {/* Tier header row */}
        <div className="flex items-center justify-between mb-5">
          <div className="flex items-center gap-2">
            <Club size={28} style={{ color: tierColor }} />
            <span className="text-lg font-bold text-white">
              {tier}
            </span>
          </div>
          <span
            className="text-sm font-semibold"
            style={{ color: '#C5A880' }}
          >
            {sessionCount} / {nextTierSessions} swims
          </span>
        </div>

        {/* Progress bar */}
        <div
          className="w-full h-2 rounded-full overflow-hidden"
          style={{ backgroundColor: 'rgba(255, 255, 255, 0.1)' }}
        >
          <div
            className="h-full rounded-full transition-all duration-500"
            style={{
              width: `${progress * 100}%`,
              backgroundColor: '#C5A880',
            }}
          />
        </div>

        {/* Encouragement text */}
        <p
          className="text-xs mt-3"
          style={{ color: 'rgba(255, 255, 255, 0.7)' }}
        >
          Book {remaining} more sessions to unlock premium benefits!
        </p>

        {/* CTA button — Book Swim Session Now */}
        <button
          onClick={() => navigate('/book-slot')}
          className="w-full mt-5 flex items-center justify-center gap-2 py-2.5 rounded-xl font-bold cursor-pointer transition-opacity hover:opacity-90"
          style={{
            backgroundColor: '#C5A880',
            color: '#002F6C',
          }}
        >
          <CalendarPlus size={18} />
          Book Swim Session Now
        </button>
      </div>

      {/* ────────────────────────────────────────────────────────────
          3. POOL BANNER (Background image with gradient overlay)
          ──────────────────────────────────────────────────────────── */}
      <div
        className="relative h-[180px] w-full rounded-2xl overflow-hidden mb-6"
        style={{
          background: 'linear-gradient(to top, rgba(0, 47, 108, 0.9) 0%, rgba(0, 47, 108, 0.4) 100%), url("/assets/upsi_pool.jpg") center/cover no-repeat',
        }}
      >
        {/* Content pinned to the bottom-left */}
        <div className="absolute bottom-0 left-0 right-0 p-5 flex flex-col justify-end">
          {/* Gold tag */}
          <span
            className="self-start text-[10px] font-bold px-2 py-1 rounded-md mb-1.5"
            style={{
              backgroundColor: '#C5A880',
              color: '#002F6C',
            }}
          >
            KOLAM RENANG UPSI
          </span>

          <h2 className="text-xl font-bold text-white">
            Beat the Heat for only RM 2.00
          </h2>
          <p
            className="text-[13px]"
            style={{ color: 'rgba(255, 255, 255, 0.9)' }}
          >
            Affordable swimming lanes available daily. Jom Mandi!
          </p>
        </div>
      </div>

      {/* ────────────────────────────────────────────────────────────
          5. SWIMMING GUIDELINES — 3 cards stacked vertically
          ──────────────────────────────────────────────────────────── */}
      <h2
        className="text-lg font-bold mb-3"
        style={{ color: '#1E293B' }}
      >
        Swimming Guidelines
      </h2>

      {/* 5a. Proper Swimwear */}
      <GuidelineCard
        icon={<ShieldAlert size={20} style={{ color: '#002F6C' }} />}
        title="Proper Swimwear Required"
        subtitle="Strictly nylon or spandex swimsuits only. Cotton apparel is prohibited."
      />

      {/* 5b. Operating Hours (full Malay schedule) */}
      <GuidelineCard
        icon={<Clock size={20} style={{ color: '#002F6C' }} />}
        title="Operating Hours"
        subtitle={
          '• Isnin: Tutup sempena penyelenggaraan & pembersihan\n' +
          '• Selasa - Khamis: Sesi Petang (2.30 ptg - 6.30 ptg)\n' +
          '• Rabu (Ladies Day): Sesi Petang (2.30 ptg - 6.30 ptg)\n' +
          '• Jumaat: Sesi Petang (3.00 ptg - 6.30 ptg)\n' +
          '• Sabtu & Ahad: Sesi Pagi (8.30 pg - 12.30 tghari) & Sesi Petang (2.30 ptg - 6.30 ptg)'
        }
      />

      {/* 5c. Health & Safety */}
      <GuidelineCard
        icon={<HeartPulse size={20} style={{ color: '#002F6C' }} />}
        title="Health & Safety"
        subtitle="Shower before entering. Do not swim if feeling unwell or under medication."
      />

      {/* ────────────────────────────────────────────────────────────
          6. POOL LOCATION & FACILITIES
          ──────────────────────────────────────────────────────────── */}
      <h2
        className="text-lg font-bold mb-3 mt-6"
        style={{ color: '#1E293B' }}
      >
        Pool Location & Facilities
      </h2>

      <div
        className="rounded-2xl p-4 border"
        style={{
          backgroundColor: '#FFFFFF',
          borderColor: '#E2E8F0',
        }}
      >
        {/* ── Location Detail ──────────────────────────────────── */}
        <div className="flex items-start gap-3">
          {/* Map pin icon container */}
          <div
            className="shrink-0 p-2 rounded-[10px]"
            style={{ backgroundColor: 'rgba(0, 47, 108, 0.1)' }}
          >
            <MapPin size={20} style={{ color: '#002F6C' }} />
          </div>

          <div className="flex-1 min-w-0">
            {/* Title */}
            <p
              className="text-sm font-bold"
              style={{ color: '#1E293B' }}
            >
              Lokasi Kolam
            </p>

            {/* Address */}
            <p
              className="text-xs mt-0.5 leading-relaxed"
              style={{ color: '#64748B' }}
            >
              Kolam Renang Universiti Pendidikan Sultan Idris (UPSI)
              <br />
              Jalan Proton City, 35900 Tanjong Malim, Perak.
            </p>

            {/* Google Maps link text */}
            <p
              className="text-[11px] mt-1 font-bold break-all"
              style={{ color: '#C5A880' }}
            >
              Link: {MAPS_URL}
            </p>

            {/* Action buttons row */}
            <div className="flex flex-wrap items-center gap-3 mt-2.5">
              {/* Open Google Maps */}
              <a
                href={MAPS_URL}
                target="_blank"
                rel="noopener noreferrer"
                className="inline-flex items-center gap-2 px-3.5 py-2 rounded-[10px] text-xs font-bold text-white no-underline transition-opacity hover:opacity-90"
                style={{
                  backgroundColor: '#002F6C',
                  boxShadow: '0 3px 8px rgba(0, 47, 108, 0.15)',
                }}
              >
                <Navigation size={14} style={{ color: '#C5A880' }} />
                Open Google Maps
              </a>

              {/* Copy Link */}
              <button
                onClick={handleCopyLink}
                className="inline-flex items-center gap-2 px-3.5 py-2 rounded-[10px] text-xs font-bold bg-transparent cursor-pointer transition-colors"
                style={{
                  border: '1.5px solid #E2E8F0',
                  color: '#64748B',
                }}
              >
                <Copy size={14} style={{ color: '#64748B' }} />
                {copied ? 'Copied!' : 'Copy Link'}
              </button>
            </div>
          </div>
        </div>

        {/* Divider */}
        <hr
          className="my-5"
          style={{ borderColor: '#E2E8F0', borderTopWidth: '1px' }}
        />

        {/* ── Facilities / Amenities ──────────────────────────── */}
        <p
          className="text-[13px] font-bold mb-3.5"
          style={{ color: '#1E293B' }}
        >
          Kemudahan Kolam (Facilities & Amenities):
        </p>

        <div className="flex flex-col gap-3">
          {/* Toilets & Showers */}
          <AmenityRow
            icon={<Bath size={18} style={{ color: '#C5A880' }} />}
            label="Tandas & Pancuran Air (Toilets & Showers)"
            desc="Kemudahan tandas dan pancuran mandi yang lengkap di kedua-dua bilik lelaki dan wanita."
          />

          {/* Parking Space */}
          <AmenityRow
            icon={<Car size={18} style={{ color: '#C5A880' }} />}
            label="Kawasan Parkir (Parking Space)"
            desc="Kawasan meletak kenderaan disediakan secara percuma dan luas berhampiran pintu masuk kolam."
          />

          {/* Changing Room */}
          <AmenityRow
            icon={<Shirt size={18} style={{ color: '#C5A880' }} />}
            label="Bilik Salin Pakaian (Changing Room)"
            desc="Bilik persalinan berasingan yang selesa bagi menjaga privasi pengunjung."
          />
        </div>
      </div>

      {/* Bottom spacing so content doesn't crash into navbar */}
      <div className="h-6" />
    </div>
  );
}

/* ═══════════════════════════════════════════════════════════════════
   SUB-COMPONENTS
   ═══════════════════════════════════════════════════════════════════ */

/**
 * StatusCard — renders a single live-status metric.
 * Matches the Flutter `_buildStatusCard` helper exactly.
 *
 * @param {{ icon: JSX.Element, label: string, value: string }} props
 */
function StatusCard({ icon, label, value }) {
  return (
    <div
      className="p-4 rounded-2xl border"
      style={{
        backgroundColor: '#FFFFFF',
        borderColor: '#E2E8F0',
      }}
    >
      {/* Coloured icon */}
      {icon}
      {/* Metric label */}
      <p
        className="text-[11px] mt-2"
        style={{ color: '#64748B' }}
      >
        {label}
      </p>
      {/* Metric value */}
      <p
        className="text-[13px] font-bold mt-0.5"
        style={{ color: '#1E293B' }}
      >
        {value}
      </p>
    </div>
  );
}

/**
 * GuidelineCard — a single guideline row with icon-in-gold-box + text.
 * Mirrors Flutter `_buildGuidelineItem`.
 *
 * The `subtitle` may contain newline characters (\n) which are
 * preserved via `whitespace-pre-line`.
 *
 * @param {{ icon: JSX.Element, title: string, subtitle: string }} props
 */
function GuidelineCard({ icon, title, subtitle }) {
  return (
    <div
      className="flex items-start gap-4 p-4 rounded-2xl border mb-3"
      style={{
        backgroundColor: '#FFFFFF',
        borderColor: '#E2E8F0',
      }}
    >
      {/* Icon container with goldLight background */}
      <div
        className="shrink-0 p-2 rounded-lg"
        style={{ backgroundColor: '#F1EAE0' }}
      >
        {icon}
      </div>

      <div className="flex-1 min-w-0">
        <p
          className="text-sm font-bold"
          style={{ color: '#1E293B' }}
        >
          {title}
        </p>
        <p
          className="text-xs mt-1 whitespace-pre-line leading-relaxed"
          style={{ color: '#64748B' }}
        >
          {subtitle}
        </p>
      </div>
    </div>
  );
}

/**
 * AmenityRow — renders one facility/amenity item.
 * Matches the Flutter `_buildAmenityRow` helper with a gradient
 * circular icon container, gold icon, and descriptive text.
 *
 * @param {{ icon: JSX.Element, label: string, desc: string }} props
 */
function AmenityRow({ icon, label, desc }) {
  return (
    <div className="flex items-start gap-4">
      {/* Circular gradient icon container */}
      <div
        className="shrink-0 flex items-center justify-center w-10 h-10 rounded-full"
        style={{
          background: 'linear-gradient(135deg, #002F6C 0%, #003884 100%)',
          boxShadow: '0 3px 6px rgba(0, 47, 108, 0.15)',
          border: '1.5px solid rgba(197, 168, 128, 0.3)',
        }}
      >
        {icon}
      </div>

      <div className="flex-1 min-w-0">
        <p
          className="text-[13px] font-bold"
          style={{ color: '#1E293B' }}
        >
          {label}
        </p>
        <p
          className="text-[11px] mt-0.5 leading-snug"
          style={{ color: '#64748B' }}
        >
          {desc}
        </p>
      </div>
    </div>
  );
}
