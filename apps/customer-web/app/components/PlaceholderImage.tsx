type PlaceholderImageProps = {
  label: string;
  className?: string;
};

/**
 * Renders a neutral grey placeholder when a business has not uploaded a cover
 * or logo image yet. Displays a subtle image icon instead of literal text so
 * customers never see raw placeholder labels.
 */
export function PlaceholderImage({ label, className = '' }: PlaceholderImageProps) {
  return (
    <div
      role="img"
      aria-label={label}
      className={`flex items-center justify-center overflow-hidden bg-gradient-to-br from-neutral-100 to-neutral-200 ${className}`}
    >
      {/* Neutral image icon — visible only when no real image is set */}
      <svg
        xmlns="http://www.w3.org/2000/svg"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="1.25"
        strokeLinecap="round"
        strokeLinejoin="round"
        className="h-1/3 w-1/3 min-h-5 min-w-5 max-h-10 max-w-10 text-neutral-400"
        aria-hidden="true"
      >
        <rect x="3" y="3" width="18" height="18" rx="2" ry="2" />
        <circle cx="8.5" cy="8.5" r="1.5" />
        <polyline points="21 15 16 10 5 21" />
      </svg>
    </div>
  );
}
